import 'package:flutter_test/flutter_test.dart';
import 'package:password_checker/utils/password_utils.dart';

void main() {
  group('PasswordUtils.checkPassword', () {
    test('empty password returns empty result', () {
      final result = PasswordUtils.checkPassword('');
      expect(result.level, PasswordStrengthLevel.empty);
      expect(result.strengthValue, 0.0);
      expect(result.label, '');
      expect(result.entropyBits, 0.0);
    });

    test('short password is weak', () {
      final result = PasswordUtils.checkPassword('abc');
      expect(result.level, PasswordStrengthLevel.weak);
      expect(result.strengthValue, 0.25);
      expect(result.requirements.has8Chars, false);
    });

    test('lowercase-only 8+ chars is still weak (only 2 criteria)', () {
      final result = PasswordUtils.checkPassword('abcdefgh');
      expect(result.level, PasswordStrengthLevel.weak);
      expect(result.requirements.has8Chars, true);
      expect(result.requirements.hasLowercase, true);
      expect(result.requirements.hasUppercase, false);
      expect(result.requirements.metCount, 2);
    });

    test('8+ chars with lowercase + uppercase + number = medium', () {
      final result = PasswordUtils.checkPassword('Abcdefg1');
      expect(result.level, PasswordStrengthLevel.medium);
      expect(result.requirements.metCount, 4);
    });

    test('12+ chars with lowercase + uppercase + number = strong (5 criteria)', () {
      final result = PasswordUtils.checkPassword('Abcdefghij1x');
      expect(result.level, PasswordStrengthLevel.strong);
      expect(result.requirements.has12Chars, true);
      expect(result.requirements.metCount, 5);
    });

    test('12+ chars with all character types = very strong (6 criteria)', () {
      final result = PasswordUtils.checkPassword('Abcdefghij1!');
      expect(result.level, PasswordStrengthLevel.veryStrong);
      expect(result.strengthValue, 1.0);
      expect(result.requirements.metCount, 6);
    });

    test('detects non-standard symbols via broad regex', () {
      final result = PasswordUtils.checkPassword('Abcdefg1~');
      expect(result.requirements.hasSymbol, true);

      final result2 = PasswordUtils.checkPassword(r'Abcdefg1\');
      expect(result2.requirements.hasSymbol, true);

      final result3 = PasswordUtils.checkPassword('Abcdefg1é');
      expect(result3.requirements.hasSymbol, true);
    });
  });

  group('PasswordUtils.calculateEntropy', () {
    test('empty string has zero entropy', () {
      expect(PasswordUtils.calculateEntropy(''), 0.0);
    });

    test('lowercase-only password', () {
      final entropy = PasswordUtils.calculateEntropy('abcdefgh');
      // 8 * log2(26) ≈ 37.6
      expect(entropy, closeTo(37.6, 0.1));
    });

    test('mixed character set increases entropy', () {
      final low = PasswordUtils.calculateEntropy('aaaaaaaa');
      final mixed = PasswordUtils.calculateEntropy('aA1!aA1!');
      expect(mixed, greaterThan(low));
    });
  });

  group('PasswordUtils.generateStrongPassword', () {
    test('default length is 16', () {
      final pw = PasswordUtils.generateStrongPassword();
      expect(pw.length, 16);
    });

    test('custom length', () {
      final pw = PasswordUtils.generateStrongPassword(length: 24);
      expect(pw.length, 24);
    });

    test('contains all character types', () {
      // Run a few times to guard against flaky randomness.
      for (int i = 0; i < 10; i++) {
        final pw = PasswordUtils.generateStrongPassword();
        expect(pw.contains(RegExp(r'[a-z]')), true);
        expect(pw.contains(RegExp(r'[A-Z]')), true);
        expect(pw.contains(RegExp(r'[0-9]')), true);
        expect(pw.contains(RegExp(r'[^a-zA-Z0-9]')), true);
      }
    });

    test('generated password is rated very strong', () {
      final pw = PasswordUtils.generateStrongPassword();
      final result = PasswordUtils.checkPassword(pw);
      expect(result.level, PasswordStrengthLevel.veryStrong);
    });
  });
}
