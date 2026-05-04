/// All application constants — no magic numbers or hardcoded strings.

class AppStrings {
  AppStrings._();

  static const appTitle = 'Password Strength Checker';
  static const passwordLabel = 'Password';
  static const passwordHint = 'Enter your password';
  static const clearButton = 'Clear';
  static const generateButton = 'Generate';
  static const copySuccess = 'Password copied to clipboard!';
  static const footerText = 'Educational Cyber Security Tool';
  static const passwordRequirementHint =
      'Password must be at least 8 characters and include uppercase, numbers & symbols';

  // Strength labels
  static const weakLabel = 'Weak Password ❌';
  static const mediumLabel = 'Medium Password ⚠️';
  static const strongLabel = 'Strong Password ✅';
  static const veryStrongLabel = 'Very Strong Password 🔒';

  // Suggestions
  static const suggestLength = 'Use at least 8 characters';
  static const suggestMore = 'Add uppercase, numbers & special symbols';
  static const suggestVariety = 'Add more variety: uppercase, numbers, or symbols';
  static const suggestGreat = 'Great password!';
  static const suggestExcellent = 'Excellent! Very secure password!';
}

class StrengthValues {
  StrengthValues._();

  static const double empty = 0.0;
  static const double weak = 0.25;
  static const double medium = 0.5;
  static const double strong = 0.75;
  static const double veryStrong = 1.0;
}

class AppDimensions {
  AppDimensions._();

  static const double cardMaxWidth = 420.0;
  static const double cardPadding = 24.0;
  static const double cardElevation = 8.0;
  static const double cardBorderRadius = 20.0;
  static const double inputBorderRadius = 14.0;
  static const double strengthBarHeight = 14.0;
  static const double strengthBarRadius = 10.0;
  static const double resultFontSize = 22.0;
  static const double suggestionFontSize = 14.0;
  static const double hintFontSize = 12.0;
  static const double footerFontSize = 11.0;
  static const double entropyFontSize = 13.0;
  static const double checklistFontSize = 13.0;
}
