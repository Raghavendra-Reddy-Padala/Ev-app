import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constants/colors.dart';

enum TextFieldVariant { outlined, filled, underlined }

class AppTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final TextCapitalization textCapitalization;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final bool readOnly;
  final bool autofocus;
  final bool enabled;
  final Widget? prefix;
  final Widget? suffix;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final EdgeInsetsGeometry? contentPadding;
  final TextFieldVariant variant;
  final Color? fillColor;
  final TextStyle? textStyle;
  final GestureTapCallback? onTap;

  const AppTextField({
    Key? key,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.controller,
    this.focusNode,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.textCapitalization = TextCapitalization.none,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.onChanged,
    this.onEditingComplete,
    this.onSubmitted,
    this.inputFormatters,
    this.readOnly = false,
    this.autofocus = false,
    this.enabled = true,
    this.prefix,
    this.suffix,
    this.prefixIcon,
    this.suffixIcon,
    this.contentPadding,
    this.variant = TextFieldVariant.outlined,
    this.fillColor,
    this.textStyle,
    this.onTap,
  }) : super(key: key);

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _isPasswordVisible;

  @override
  void initState() {
    super.initState();
    _isPasswordVisible = !widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: widget.enabled
                  ? Theme.of(context).brightness == Brightness.light
                      ? Colors.black87
                      : Colors.white70
                  : AppColors.disabled,
            ),
          ),
          SizedBox(height: 8.h),
        ],
        TextField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          obscureText: widget.keyboardType == TextInputType.visiblePassword
              ? !_isPasswordVisible
              : widget.obscureText,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          textCapitalization: widget.textCapitalization,
          maxLines: widget.maxLines,
          minLines: widget.minLines,
          maxLength: widget.maxLength,
          onChanged: widget.onChanged,
          onEditingComplete: widget.onEditingComplete,
          onSubmitted: widget.onSubmitted,
          inputFormatters: widget.inputFormatters,
          readOnly: widget.readOnly,
          autofocus: widget.autofocus,
          enabled: widget.enabled,
          style: widget.textStyle ??
              TextStyle(
                fontSize: 16.sp,
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.black
                    : Colors.white,
              ),
          onTap: widget.onTap,
          cursorColor: AppColors.primary,
          decoration: _buildInputDecoration(),
        ),
        if (widget.helperText != null && widget.errorText == null) ...[
          SizedBox(height: 4.h),
          Text(
            widget.helperText!,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ],
    );
  }

  InputDecoration _buildInputDecoration() {
    return InputDecoration(
      hintText: widget.hint,
      errorText: widget.errorText,
      filled: widget.variant == TextFieldVariant.filled,
      fillColor: widget.fillColor ??
          (widget.variant == TextFieldVariant.filled
              ? Theme.of(context).brightness == Brightness.light
                  ? Colors.grey.shade100
                  : Colors.grey.shade800
              : null),
      prefixIcon: widget.prefixIcon,
      prefix: widget.prefix,
      suffixIcon: _buildSuffixIcon(),
      suffix: widget.suffix,
      contentPadding: widget.contentPadding ??
          EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      border: _getBorder(),
      enabledBorder: _getEnabledBorder(),
      focusedBorder: _getFocusedBorder(),
      errorBorder: _getErrorBorder(),
      focusedErrorBorder: _getErrorBorder(),
      disabledBorder: _getDisabledBorder(),
      hintStyle: TextStyle(
        fontSize: 16.sp,
        color: Colors.grey.shade500,
      ),
      errorStyle: TextStyle(
        fontSize: 12.sp,
        color: AppColors.error,
      ),
      counterText: '',
    );
  }

  InputBorder _getBorder() {
    switch (widget.variant) {
      case TextFieldVariant.outlined:
        return OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: Colors.grey.shade400),
        );
      case TextFieldVariant.filled:
        return OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide.none,
        );
      case TextFieldVariant.underlined:
        return const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        );
    }
  }

  InputBorder _getEnabledBorder() {
    switch (widget.variant) {
      case TextFieldVariant.outlined:
        return OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: Colors.grey.shade400),
        );
      case TextFieldVariant.filled:
        return OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide.none,
        );
      case TextFieldVariant.underlined:
        return const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        );
    }
  }

  InputBorder _getFocusedBorder() {
    switch (widget.variant) {
      case TextFieldVariant.outlined:
        return OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        );
      case TextFieldVariant.filled:
        return OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        );
      case TextFieldVariant.underlined:
        return UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        );
    }
  }

  InputBorder _getErrorBorder() {
    switch (widget.variant) {
      case TextFieldVariant.outlined:
        return OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: AppColors.error, width: 1.5),
        );
      case TextFieldVariant.filled:
        return OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: AppColors.error, width: 1.5),
        );
      case TextFieldVariant.underlined:
        return UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.error, width: 1.5),
        );
    }
  }

  InputBorder _getDisabledBorder() {
    switch (widget.variant) {
      case TextFieldVariant.outlined:
        return OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: Colors.grey.shade300),
        );
      case TextFieldVariant.filled:
        return OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide.none,
        );
      case TextFieldVariant.underlined:
        return UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade300),
        );
    }
  }

  Widget? _buildSuffixIcon() {
    if (widget.keyboardType == TextInputType.visiblePassword) {
      return IconButton(
        icon: Icon(
          _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
          color: Colors.grey,
        ),
        onPressed: () {
          setState(() {
            _isPasswordVisible = !_isPasswordVisible;
          });
        },
      );
    } else {
      return widget.suffixIcon;
    }
  }
}
