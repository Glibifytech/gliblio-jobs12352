import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../theme/app_theme.dart';

class OtpInputWidget extends StatefulWidget {
  final TextEditingController controller;
  final Function(String)? onCompleted;
  final Function(String)? onChanged;
  final int length;
  final double? fieldWidth;
  final double? fieldHeight;

  const OtpInputWidget({
    super.key,
    required this.controller,
    this.onCompleted,
    this.onChanged,
    this.length = 6,
    this.fieldWidth,
    this.fieldHeight,
  });

  @override
  State<OtpInputWidget> createState() => _OtpInputWidgetState();
}

class _OtpInputWidgetState extends State<OtpInputWidget> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.length,
      (index) => TextEditingController(),
    );
    _focusNodes = List.generate(
      widget.length,
      (index) => FocusNode(),
    );

    // Listen to the main controller changes
    widget.controller.addListener(_onMainControllerChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onMainControllerChanged);
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _onMainControllerChanged() {
    final text = widget.controller.text;

    // Update individual controllers
    for (int i = 0; i < widget.length; i++) {
      _controllers[i].text = i < text.length ? text[i] : '';
    }
  }

  void _onFieldChanged(int index, String value) {
    // Update main controller
    String newValue = '';
    for (int i = 0; i < widget.length; i++) {
      if (i == index) {
        newValue += value;
      } else {
        newValue += _controllers[i].text;
      }
    }

    widget.controller.text = newValue;

    // Move focus and handle backspace
    if (value.isNotEmpty) {
      if (index < widget.length - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    } else {
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
    }

    // Trigger callbacks
    widget.onChanged?.call(newValue);

    if (newValue.length == widget.length) {
      widget.onCompleted?.call(newValue);
    }
  }

  void _onKeyPressed(int index, KeyEvent event) {
    if (event is KeyDownEvent) {
      // Handle backspace
      if (event.logicalKey == LogicalKeyboardKey.backspace) {
        if (_controllers[index].text.isEmpty && index > 0) {
          _focusNodes[index - 1].requestFocus();
          _controllers[index - 1].clear();
          _onFieldChanged(index - 1, '');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final fieldWidth = widget.fieldWidth ?? 12.w;
    final fieldHeight = widget.fieldHeight ?? 7.h;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(
        widget.length,
        (index) => Container(
          width: fieldWidth,
          height: fieldHeight,
          decoration: BoxDecoration(
            border: Border.all(
              color: _focusNodes[index].hasFocus
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.3),
              width: _focusNodes[index].hasFocus ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
            color: _focusNodes[index].hasFocus
                ? AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.05)
                : Colors.transparent,
          ),
          child: KeyboardListener(
            focusNode: FocusNode(),
            onKeyEvent: (event) => _onKeyPressed(index, event),
            child: TextFormField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 1,
              style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(1),
              ],
              decoration: InputDecoration(
                counterText: '',
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                hintText: '●',
                hintStyle: TextStyle(
                  color: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.5),
                  fontSize: 24,
                ),
              ),
              onChanged: (value) => _onFieldChanged(index, value),
              onTap: () {
                // Clear field on tap for better UX
                if (_controllers[index].text.isNotEmpty) {
                  _controllers[index].selection = TextSelection(
                    baseOffset: 0,
                    extentOffset: _controllers[index].text.length,
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
