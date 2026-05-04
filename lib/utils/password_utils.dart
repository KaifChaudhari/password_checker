import 'dart:math';

/// Password strength levels from empty to very strong.
enum PasswordStrengthLevel { empty, weak, medium, strong, veryStrong }

/// Tracks which individual requirements a password meets.
class PasswordRequirements {
  final bool has8Chars;
  final bool has12Chars;
  final bool hasLowercase;
  final bool hasUppercase;
  final bool hasNumber;
  final bool hasSymbol;

  const PasswordRequirements({
    required this.has8Chars,
    required this.has12Chars,
    required this.hasLowercase,
    required this.hasUppercase,
    required this.hasNumber,
    required this.hasSymbol,
  });

  /// Number of requirements met (0–6).
  int get metCount => [
        has8Chars,
        has12Chars,
        hasLowercase,
        hasUppercase,
        hasNumber,
        hasSymbol,
      ].where((e) => e).length;
}

/// Result of evaluating a password's strength.
class PasswordResult {
  final PasswordStrengthLevel level;
  final double strengthValue;
  final String label;
  final String suggestion;
  final double entropyBits;
  final PasswordRequirements requirements;

  const PasswordResult({
    required this.level,
    required this.strengthValue,
    required this.label,
    required this.suggestion,
    required this.entropyBits,
    required this.requirements,
  });
}

/// Core password utility — strength checking, entropy calculation, and generation.
class PasswordUtils {
  PasswordUtils._();

  static const _lowercase = 'abcdefghijklmnopqrstuvwxyz';
  static const _uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static const _digits = '0123456789';
  static const _symbols = r'''!@#$%^&*()_+-=[]{}|;:',.<>?/~`"''';

  /// Calculate Shannon entropy in bits.
  static double calculateEntropy(String password) {
    if (password.isEmpty) return 0;

    int poolSize = 0;
    if (password.contains(RegExp(r'[a-z]'))) poolSize += 26;
    if (password.contains(RegExp(r'[A-Z]'))) poolSize += 26;
    if (password.contains(RegExp(r'[0-9]'))) poolSize += 10;
    if (password.contains(RegExp(r'[^a-zA-Z0-9]'))) poolSize += 32;

    if (poolSize == 0) return 0;
    return password.length * (log(poolSize) / log(2));
  }

  /// Evaluate a password and return a comprehensive [PasswordResult].
  static PasswordResult checkPassword(String password) {
    const emptyReqs = PasswordRequirements(
      has8Chars: false,
      has12Chars: false,
      hasLowercase: false,
      hasUppercase: false,
      hasNumber: false,
      hasSymbol: false,
    );

    if (password.isEmpty) {
      return const PasswordResult(
        level: PasswordStrengthLevel.empty,
        strengthValue: 0,
        label: '',
        suggestion: '',
        entropyBits: 0,
        requirements: emptyReqs,
      );
    }

    final reqs = PasswordRequirements(
      has8Chars: password.length >= 8,
      has12Chars: password.length >= 12,
      hasLowercase: password.contains(RegExp(r'[a-z]')),
      hasUppercase: password.contains(RegExp(r'[A-Z]')),
      hasNumber: password.contains(RegExp(r'[0-9]')),
      // Catches ALL non-alphanumeric characters — no symbols are missed.
      hasSymbol: password.contains(RegExp(r'[^a-zA-Z0-9]')),
    );

    final entropy = calculateEntropy(password);
    final score = reqs.metCount;

    PasswordStrengthLevel level;
    double strengthValue;
    String label;
    String suggestion;

    if (score <= 2) {
      level = PasswordStrengthLevel.weak;
      strengthValue = 0.25;
      label = 'Weak Password ❌';
      suggestion = password.length < 8
          ? 'Use at least 8 characters'
          : 'Add uppercase, numbers & special symbols';
    } else if (score <= 4) {
      level = PasswordStrengthLevel.medium;
      strengthValue = 0.5;
      label = 'Medium Password ⚠️';
      suggestion = 'Add more variety: uppercase, numbers, or symbols';
    } else if (score == 5) {
      level = PasswordStrengthLevel.strong;
      strengthValue = 0.75;
      label = 'Strong Password ✅';
      suggestion = 'Great password!';
    } else {
      level = PasswordStrengthLevel.veryStrong;
      strengthValue = 1.0;
      label = 'Very Strong Password 🔒';
      suggestion = 'Excellent! Very secure password!';
    }

    return PasswordResult(
      level: level,
      strengthValue: strengthValue,
      label: label,
      suggestion: suggestion,
      entropyBits: entropy,
      requirements: reqs,
    );
  }

  /// Generate a cryptographically secure random password.
  static String generateStrongPassword({int length = 16}) {
    final random = Random.secure();
    final allChars = _lowercase + _uppercase + _digits + _symbols;

    // Guarantee at least one character from each category.
    final chars = <String>[
      _lowercase[random.nextInt(_lowercase.length)],
      _uppercase[random.nextInt(_uppercase.length)],
      _digits[random.nextInt(_digits.length)],
      _symbols[random.nextInt(_symbols.length)],
    ];

    for (int i = chars.length; i < length; i++) {
      chars.add(allChars[random.nextInt(allChars.length)]);
    }

    chars.shuffle(random);
    return chars.join();
  }
}
