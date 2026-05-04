import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants.dart';
import '../utils/password_utils.dart';

/// Main screen — password input, live requirements checklist,
/// animated strength bar, entropy display, and generate/copy actions.
class PasswordCheckerScreen extends StatefulWidget {
  const PasswordCheckerScreen({super.key});

  @override
  State<PasswordCheckerScreen> createState() => _PasswordCheckerScreenState();
}

class _PasswordCheckerScreenState extends State<PasswordCheckerScreen> {
  bool _isHidden = true;
  PasswordResult _result = PasswordUtils.checkPassword('');
  PasswordStrengthLevel _previousLevel = PasswordStrengthLevel.empty;
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // --------------- Handlers ---------------

  void _onPasswordChanged(String password) {
    final newResult = PasswordUtils.checkPassword(password);

    // Haptic feedback on strength level change (mobile only, no-op on desktop).
    if (newResult.level != _previousLevel &&
        newResult.level != PasswordStrengthLevel.empty) {
      HapticFeedback.lightImpact();
    }

    setState(() {
      _previousLevel = _result.level;
      _result = newResult;
    });
  }

  void _clear() {
    _controller.clear();
    setState(() {
      _result = PasswordUtils.checkPassword('');
      _previousLevel = PasswordStrengthLevel.empty;
    });
  }

  void _generate() {
    final password = PasswordUtils.generateStrongPassword();
    _controller.text = password;
    _onPasswordChanged(password);
    setState(() => _isHidden = false);
  }

  void _copy() {
    if (_controller.text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: _controller.text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(AppStrings.copySuccess),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // --------------- Colours ---------------

  Color _strengthColor(ColorScheme cs) {
    switch (_result.level) {
      case PasswordStrengthLevel.empty:
        return cs.onSurface.withAlpha(77); // ~30 %
      case PasswordStrengthLevel.weak:
        return Colors.redAccent;
      case PasswordStrengthLevel.medium:
        return Colors.orangeAccent;
      case PasswordStrengthLevel.strong:
        return Colors.lightGreen;
      case PasswordStrengthLevel.veryStrong:
        return Colors.green;
    }
  }

  // --------------- Build ---------------

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = _strengthColor(cs);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appTitle),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(maxWidth: AppDimensions.cardMaxWidth),
            child: Card(
              elevation: AppDimensions.cardElevation,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppDimensions.cardBorderRadius),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.cardPadding),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ---- Password field ----
                    _buildPasswordField(cs),

                    const SizedBox(height: 8),
                    Text(
                      AppStrings.passwordRequirementHint,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: AppDimensions.hintFontSize,
                        color: cs.onSurface.withAlpha(128),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ---- Requirements checklist ----
                    if (_controller.text.isNotEmpty) ...[
                      _buildChecklist(cs),
                      const SizedBox(height: 16),
                    ],

                    // ---- Animated strength bar ----
                    _buildStrengthBar(cs, color),

                    // ---- Entropy ----
                    if (_result.entropyBits > 0) ...[
                      const SizedBox(height: 6),
                      Text(
                        '${_result.entropyBits.toStringAsFixed(1)} bits of entropy',
                        style: TextStyle(
                          fontSize: AppDimensions.entropyFontSize,
                          fontStyle: FontStyle.italic,
                          color: cs.onSurface.withAlpha(128),
                        ),
                      ),
                    ],

                    const SizedBox(height: 15),

                    // ---- Result label ----
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: TextStyle(
                        fontSize: AppDimensions.resultFontSize,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                      child: Text(_result.label),
                    ),

                    const SizedBox(height: 8),

                    // ---- Suggestion ----
                    AnimatedOpacity(
                      opacity: _result.suggestion.isNotEmpty ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        _result.suggestion,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: AppDimensions.suggestionFontSize,
                          color: cs.onSurface.withAlpha(153),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ---- Action buttons ----
                    _buildActions(),

                    const SizedBox(height: 12),

                    // ---- Footer ----
                    Text(
                      AppStrings.footerText,
                      style: TextStyle(
                        fontSize: AppDimensions.footerFontSize,
                        color: cs.onSurface.withAlpha(102),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --------------- Sub-widgets ---------------

  Widget _buildPasswordField(ColorScheme cs) {
    return TextField(
      controller: _controller,
      obscureText: _isHidden,
      decoration: InputDecoration(
        labelText: AppStrings.passwordLabel,
        hintText: AppStrings.passwordHint,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_controller.text.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.copy, size: 20),
                tooltip: 'Copy password',
                onPressed: _copy,
              ),
            IconButton(
              icon: Icon(
                _isHidden ? Icons.visibility_off : Icons.visibility,
              ),
              tooltip: _isHidden ? 'Show password' : 'Hide password',
              onPressed: () => setState(() => _isHidden = !_isHidden),
            ),
          ],
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.inputBorderRadius),
        ),
      ),
      onChanged: _onPasswordChanged,
    );
  }

  Widget _buildStrengthBar(ColorScheme cs, Color color) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: _result.strengthValue),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      builder: (context, value, _) {
        return ClipRRect(
          borderRadius:
              BorderRadius.circular(AppDimensions.strengthBarRadius),
          child: LinearProgressIndicator(
            value: value,
            minHeight: AppDimensions.strengthBarHeight,
            backgroundColor: cs.onSurface.withAlpha(26),
            color: color,
          ),
        );
      },
    );
  }

  Widget _buildChecklist(ColorScheme cs) {
    final r = _result.requirements;
    final items = [
      ('8+ characters', r.has8Chars),
      ('12+ characters (bonus)', r.has12Chars),
      ('Lowercase letter (a-z)', r.hasLowercase),
      ('Uppercase letter (A-Z)', r.hasUppercase),
      ('Number (0-9)', r.hasNumber),
      (r'Special symbol (!@#$...)', r.hasSymbol),
    ];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.onSurface.withAlpha(15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items.map((item) {
          final (label, met) = item;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    met
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    key: ValueKey('$label-$met'),
                    size: 18,
                    color: met
                        ? Colors.green
                        : cs.onSurface.withAlpha(77),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: AppDimensions.checklistFontSize,
                      color: met
                          ? cs.onSurface
                          : cs.onSurface.withAlpha(128),
                      decoration:
                          met ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActions() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        FilledButton.tonal(
          onPressed: _generate,
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.auto_fix_high, size: 18),
              SizedBox(width: 6),
              Text(AppStrings.generateButton),
            ],
          ),
        ),
        OutlinedButton(
          onPressed: _copy,
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.copy, size: 18),
              SizedBox(width: 6),
              Text('Copy'),
            ],
          ),
        ),
        TextButton(
          onPressed: _clear,
          child: const Text(AppStrings.clearButton),
        ),
      ],
    );
  }
}
