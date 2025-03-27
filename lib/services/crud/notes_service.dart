import 'dart:async';

// import 'package:posex/services/auth/auth_exceptions.dart';
import 'package:posex/services/crud/crud_exceptions.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' show join;
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class ExcerciseService {
  Database? _db;
  List<DatabaseExcercise> _excercises = [];
  final _excercisesStreamController =
      StreamController<List<DatabaseExcercise>>.broadcast();

  ExcerciseService._sharedInstance();
  static final ExcerciseService _shared = ExcerciseService._sharedInstance();
  factory ExcerciseService() => _shared;

  Stream<List<DatabaseExcercise>> get allExcercises =>
      _excercisesStreamController.stream;

  Future<void> _ensureDbIsOpen() async {
    try {
      await open();
    } on databaseAlreadyOpenException {
      //empty
    }
  }

  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw databaseIsNotOpen();
    } else {
      return db;
    }
  }

  Future<void> _cacheExcercises() async {
    final allExcercises = await getAllExcercises();
    _excercises = allExcercises.toList();
    _excercisesStreamController.add(_excercises);
  }

  Future<void> open() async {
    if (_db != null) {
      throw databaseAlreadyOpenException();
    }
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;

      //create the user table
      await db.execute(createUserTable);

      //create the excercises table
      await db.execute(createExcerciseTabel);

      //create the mistakes table
      await db.execute(createMistakesTabel);

      await _cacheExcercises();
    } on MissingPlatformDirectoryException catch (_) {
      throw unableToGetDocumentException();
    }
  }

  //look at this code if not working
  Future<void> close() async {
    final db = _getDatabaseOrThrow();
    db.close();
    _db = null;
  }

  Future<DatabaseUser> getOrCreateUser({required String email}) async {
    try {
      final user = await getUser(email: email);
      return user;
    } on couldNotFindUserException catch (_) {
      final createdUser = await createUser(email: email, age: 0, userName: 'christo');
      return createdUser;
    } catch (_) {
      rethrow;
    }
  }

  Future<void> deleteUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      userTable,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (deletedCount < 1) {
      throw couldNotDeleteException();
    }
  }

  Future<DatabaseUser> createUser({
    required String email,
    required int age,
    required String userName,
  }) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final isAlreadyExisting = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (isAlreadyExisting.isNotEmpty) {
      throw userAlreadyExistsException();
    } else {
      final userID = await db.insert(userTable, {
        emailColoumn: email.toLowerCase(),
        userNameColoumn: userName.toLowerCase(),
        ageColumn: age,
      });
      return DatabaseUser(id: userID, email: email, userName: userName, age: age);
    }
  }

  Future<DatabaseUser> getUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final result = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (result.isEmpty) {
      throw couldNotFindUserException();
    }
    return DatabaseUser.fromRow(result.first);
  }

//creates an instance of an excercise with all string fields as emply strings
  Future<DatabaseExcercise> createExcercise() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    // final dbUser = await getUser(email: owner.email);
    // //checking if the id provided and the actual id corresponding to the email are the same. Check the implementation of == in DatabaseUser for clarification
    // if (dbUser != owner) {
    //   throw UserNotFoundAuthError();
    // }

    const text = '';
    //creating the note
    final excerciseId = await db.insert(excerciseTable, {
      exNameColoumn: text,
      instructionsColoumn: text,
      focusedMusclesColoumn: text,
    });

    final note = DatabaseExcercise(
      excerciseId: excerciseId,
      exName: text,
      instructions: text,
      focusedMuscles: text,
    );

    _excercises.add(note);
    _excercisesStreamController.add(_excercises);

    return note;
  }

  Future<void> deleteExcercise({required int excerciseId}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final rowsDeleted = await db.delete(
      excerciseTable,
      where: 'excerciseId = ?',
      whereArgs: [excerciseId],
    );
    if (rowsDeleted == 0) {
      throw couldNotDeleteExcerciseException();
    } else {
      _excercises.removeWhere((excercise) => excercise.excerciseId == excerciseId);
      _excercisesStreamController.add(_excercises);
    }
  }

  Future<int> deleteAllExcercises() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final numOfDeletions = await db.delete(excerciseTable);

    _excercises = [];
    _excercisesStreamController.add(_excercises);

    return numOfDeletions;
  }

  Future<DatabaseExcercise> getExcercise({required int exerciseId}) async {
    final db = _getDatabaseOrThrow();
    final excercise = await db.query(
      excerciseTable,
      limit: 1,
      where: 'excerciseId = ?',
      whereArgs: [exerciseId],
    );
    if (excercise.isEmpty) {
      throw couldNotFindNoteException();
    } else {
      final fetchedExcercise = DatabaseExcercise.fromRow(excercise.first);

      _excercises.removeWhere((excercise) => (excercise.excerciseId) == exerciseId);
      _excercises.add(fetchedExcercise);
      _excercisesStreamController.add(_excercises);

      return fetchedExcercise;
    }
  }

  Future<Iterable<DatabaseExcercise>> getAllExcercises() async {
    await _ensureDbIsOpen();
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final excercises = await db.query(excerciseTable);
    return excercises.map((excerciseRow) => DatabaseExcercise.fromRow(excerciseRow));
  }

  Future<DatabaseExcercise> updateExcercise({
    required DatabaseExcercise excercise,
    required exName,
    required instructions,
    required focusedMuscles,
  }) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    await getExcercise(exerciseId: excercise.excerciseId);
    final updatedCount = await db.update(excerciseTable, {
      exNameColoumn: exName,
      instructionsColoumn: instructions,
      focusedMusclesColoumn: focusedMuscles,
    });

    if (updatedCount == 0) {
      throw couldNotUpdateExcerciseException();
    } else {
      final updatedExcercise = await getExcercise(exerciseId: excercise.excerciseId);

      _excercises.removeWhere((excercise) => (excercise.excerciseId) == updatedExcercise.excerciseId);
      _excercises.add(updatedExcercise);
      _excercisesStreamController.add(_excercises);

      return updatedExcercise;
    }
  }
}

@immutable
class DatabaseUser {
  final int id;
  final String userName;
  final String email;
  final int age;
  final int? weight;
  final int? height;
  const DatabaseUser({
    required this.id,
    required this.userName,
    required this.email,
    required this.age,
    this.height,
    this.weight,
  });

  DatabaseUser.fromRow(Map<String, Object?> map)
    : id = map[userIdColoumn] as int,
      email = map[emailColoumn] as String,
      userName = map[userNameColoumn] as String,
      age = map[ageColumn] as int,
      weight = map[weightColoumn] as int?,
      height = map[heightColoumn] as int?;

  @override
  String toString() => 'Person with id=$id and name=$userName and email=$email';

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class DatabaseExcercise {
  final int excerciseId;
  final String exName;
  final String instructions;
  final String focusedMuscles;

  DatabaseExcercise({
    required this.excerciseId,
    required this.exName,
    required this.instructions,
    required this.focusedMuscles,
  });

  DatabaseExcercise.fromRow(Map<String, Object?> map)
    : excerciseId = map[excerciseIdColoumn] as int,
      exName = map[exNameColoumn] as String,
      instructions = map[instructionsColoumn] as String,
      focusedMuscles = map[focusedMusclesColoumn] as String;

  @override
  String toString() => 'Note with id=$excerciseId and name=$exName';

  @override
  bool operator ==(covariant DatabaseExcercise other) =>
      excerciseId == other.excerciseId;

  @override
  int get hashCode => excerciseId.hashCode;
}

class DatabaseMistakes {
  final int mistakeId;
  final int excerciseId;
  final String? mistakeDescription;

  DatabaseMistakes({
    required this.mistakeId,
    required this.excerciseId,
    this.mistakeDescription,
  });

  DatabaseMistakes.fromRow(Map<String, Object?> map)
    : mistakeId = map[mistakeDescriptionColoumn] as int,
      excerciseId = map[excerciseIdColoumn] as int,
      mistakeDescription = map[mistakeDescriptionColoumn] as String?;

  @override
  String toString() =>
      'Note with missid=$mistakeId and desc=$mistakeDescription';

  @override
  bool operator ==(covariant DatabaseMistakes other) =>
      excerciseId == other.excerciseId;

  @override
  int get hashCode => mistakeId.hashCode;
}

const excerciseIdColoumn = 'excerciseId';
const emailColoumn = 'email';
const userIdColoumn = 'userID';
const exNameColoumn = 'exName';
const ageColumn = 'age';
const weightColoumn = 'weight';
const heightColoumn = 'height';
const userNameColoumn = 'username';
const instructionsColoumn = 'instructions';
const focusedMusclesColoumn = 'focusedMuscles';
const mistakeIdColumn = 'mistakeId';
const mistakeDescriptionColoumn = 'mistakeDescription';
const dbName = 'posex.db';
const excerciseTable = 'excercise';
const userTable = 'user';
const mistakesTable = 'mistakes';
const createUserTable = '''CREATE TABLE "user" (
        "Id"	INTEGER NOT NULL,
        "username"	NUMERIC NOT NULL,
        "email"	TEXT NOT NULL UNIQUE,
        "weight"	INTEGER,
        "height"	INTEGER,
        "age"	INTEGER NOT NULL,
        PRIMARY KEY("Id" AUTOINCREMENT)
      );''';
const createExcerciseTabel = '''CREATE TABLE "excercise" (
        "excerciseId"	INTEGER NOT NULL,
        "exName"	TEXT NOT NULL,
        "instructions"	TEXT NOT NULL,
        "focusedMuscles"	TEXT,
        PRIMARY KEY("excerciseId" AUTOINCREMENT)
      );''';

const createMistakesTabel = '''CREATE TABLE "mistakes" (
        "mistakeId"	INTEGER NOT NULL,
        "excerciseId"	INTEGER NOT NULL,
        "mistakeDescription"	TEXT NOT NULL,
        PRIMARY KEY("mistakeId" AUTOINCREMENT),
        FOREIGN KEY("excerciseId") REFERENCES "excercise"("excerciseId")
      );''';
