class Validators {
  static bool isValidEmail(String email) {
    final emailRegExp = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.(de|com|org|net|edu|gov)$',
    );
    return emailRegExp.hasMatch(email);
  }
}
