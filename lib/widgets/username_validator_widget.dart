import 'package:flutter/material.dart';
import 'dart:async';
import '../utils/error_checker.dart';

class UsernameValidatorWidget extends StatefulWidget {
  final TextEditingController controller;
  final String? hintText;
  final Function(bool isValid, String? errorMessage)? onValidationChanged;
  final bool enabled;

  const UsernameValidatorWidget({
    super.key,
    required this.controller,
    this.hintText = 'Enter username',
    this.onValidationChanged,
    this.enabled = true,
  });

  @override
  State<UsernameValidatorWidget> createState() => _UsernameValidatorWidgetState();
}

class _UsernameValidatorWidgetState extends State<UsernameValidatorWidget> {
  Timer? _debounceTimer;
  String? _validationMessage;
  bool _isChecking = false;
  bool _isValid = false;
  Color _borderColor = Colors.grey;
  IconData? _suffixIcon;
  Color _suffixIconColor = Colors.grey;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final username = widget.controller.text.trim();
    
    if (username.isEmpty) {
      _updateValidationState(null, false, Colors.grey, null, Colors.grey);
      return;
    }

    // Cancel previous timer
    _debounceTimer?.cancel();
    
    // Show checking state immediately for better UX
    setState(() {
      _isChecking = true;
      _suffixIcon = Icons.hourglass_empty;
      _suffixIconColor = Colors.orange;
      _borderColor = Colors.orange;
    });

    // Debounce the actual validation to avoid too many API calls
    _debounceTimer = Timer(const Duration(milliseconds: 800), () {
      _validateUsername(username);
    });
  }

  Future<void> _validateUsername(String username) async {
    try {
      final errorMessage = await ErrorChecker.checkUsernameRealTime(username);
      
      if (errorMessage == null) {
        // Username is valid and available
        _updateValidationState(
          '✓ Username is available!', 
          true, 
          Colors.green, 
          Icons.check_circle, 
          Colors.green
        );
      } else {
        // Username has issues
        _updateValidationState(
          errorMessage, 
          false, 
          Colors.red, 
          Icons.error, 
          Colors.red
        );
      }
    } catch (e) {
      // Handle error gracefully
      _updateValidationState(
        'Unable to check username availability', 
        false, 
        Colors.orange, 
        Icons.warning, 
        Colors.orange
      );
    }
  }

  void _updateValidationState(
    String? message, 
    bool isValid, 
    Color borderColor, 
    IconData? icon, 
    Color iconColor
  ) {
    if (mounted) {
      setState(() {
        _validationMessage = message;
        _isValid = isValid;
        _isChecking = false;
        _borderColor = borderColor;
        _suffixIcon = icon;
        _suffixIconColor = iconColor;
      });
      
      // Notify parent widget
      widget.onValidationChanged?.call(isValid, message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _borderColor,
              width: 1.5,
            ),
          ),
          child: TextField(
            controller: widget.controller,
            enabled: widget.enabled,
            style: theme.textTheme.bodyLarge,
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              prefixIcon: Icon(
                Icons.alternate_email,
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              suffixIcon: _isChecking
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(_suffixIconColor),
                        ),
                      ),
                    )
                  : _suffixIcon != null
                      ? Icon(_suffixIcon, color: _suffixIconColor)
                      : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            textCapitalization: TextCapitalization.none,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
          ),
        ),
        if (_validationMessage != null) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Icon(
                  _isValid ? Icons.check_circle : Icons.error,
                  size: 16,
                  color: _isValid ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _validationMessage!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: _isValid ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
