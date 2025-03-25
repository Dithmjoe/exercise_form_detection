// login exceptions
class UserNotFoundAuthError implements Exception {}
// class WrongPasswordAuthError implements Exception {}
class InvalidCredentialsAuthError implements Exception {}

//register exceptions
class WeakPasswordAuthError implements Exception {}

class EmailAlreadyInUseAuthError implements Exception {}

class InvalidEmailAuthError implements Exception {}


//generic exceptions
class GenericAuthError implements Exception {}

class UserNotLoggedInAuthError implements Exception {}