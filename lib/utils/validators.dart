import 'constants.dart';

String? validateAluEmail(String? value) {
  final e = (value ?? '').trim().toLowerCase();
  if (e.endsWith('@alustudent.com') ||
      e.endsWith('@alueducation.com') ||
      e == demoStaffEmail) {
    return null;
  }
  return 'Use your ALU email ending in @alustudent.com';
}

String? validateRequired(String? value, String field) =>
    (value == null || value.trim().isEmpty) ? '$field is required' : null;

String? validateName(String? value) {
  final v = (value ?? '').trim();
  if (v.isEmpty) return 'Enter your full name';
  if (v.length < 3) return 'Name is too short';
  return null;
}

String? validatePassword(String? value) {
  final p = value ?? '';
  if (p.length < 8) return 'Use at least 8 characters';
  if (!RegExp(r'\d').hasMatch(p)) return 'Add at least one number';
  if (!RegExp(r'[^A-Za-z0-9]').hasMatch(p)) return 'Add at least one symbol';
  return null;
}

String? validateConfirmPassword(String? value, String password) =>
    value == password ? null : 'Passwords don\'t match';

int passwordStrength(String p) {
  if (p.isEmpty) return 0;
  var score = 0;
  if (p.length >= 8) score++;
  if (RegExp(r'\d').hasMatch(p)) score++;
  if (RegExp(r'[^A-Za-z0-9]').hasMatch(p)) score++;
  if (p.length >= 12 &&
      RegExp(r'[A-Z]').hasMatch(p) &&
      RegExp(r'[a-z]').hasMatch(p)) {
    score++;
  }
  return score == 0 ? 1 : score;
}

String passwordStrengthLabel(int strength) => switch (strength) {
  0 => '8+ characters with a number and symbol',
  1 => 'Weak — add more characters',
  2 => 'Fair — add a number and symbol',
  3 => 'Strong — 8+ characters with a number and symbol',
  _ => 'Very strong',
};
