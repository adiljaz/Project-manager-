import 'package:flutter/material.dart';

class AuthTextField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final String? hintText;
  final VoidCallback? onEditingComplete;
  final Function(String)? onChanged;
  final FocusNode? focusNode;
  final int? maxLength;
  final TextInputAction? textInputAction;
  final bool autofocus;
  final EdgeInsetsGeometry? contentPadding;
  final Color normalBorderColor;
  final Color focusedBorderColor;
  final Color errorBorderColor;

  const AuthTextField({
    Key? key,
    required this.label,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.hintText,
    this.onEditingComplete,
    this.onChanged,
    this.focusNode,
    this.maxLength,
    this.textInputAction,
    this.autofocus = false,
    this.contentPadding,
    this.normalBorderColor = Colors.black,
    this.focusedBorderColor = Colors.blue,
    this.errorBorderColor = Colors.red,
  }) : super(key: key);

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              widget.label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
        TextFormField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          obscureText: widget.obscureText ? _isObscured : false,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          onEditingComplete: widget.onEditingComplete,
          onChanged: widget.onChanged,
          maxLength: widget.maxLength,
          textInputAction: widget.textInputAction,
          autofocus: widget.autofocus,
          style: TextStyle(
            color: theme.textTheme.bodyLarge?.color,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: const TextStyle(color: Colors.black54),
            prefixIcon:
                widget.prefixIcon != null
                    ? Icon(widget.prefixIcon, color: Colors.black, size: 22)
                    : null,
            suffixIcon:
                widget.obscureText
                    ? IconButton(
                      icon: Icon(
                        _isObscured ? Icons.visibility_off : Icons.visibility,
                        color: Colors.black54,
                        size: 22,
                      ),
                      onPressed: () {
                        setState(() {
                          _isObscured = !_isObscured;
                        });
                      },
                    )
                    : widget.suffixIcon,
            contentPadding:
                widget.contentPadding ??
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: widget.normalBorderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: widget.normalBorderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: widget.focusedBorderColor,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: widget.errorBorderColor),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: widget.errorBorderColor, width: 2),
            ),
            filled: true,
            fillColor:
                theme.inputDecorationTheme.fillColor ?? Colors.grey.shade50,
          ),
        ),
      ],
    );
  }
}
