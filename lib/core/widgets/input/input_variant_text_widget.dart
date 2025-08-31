import 'package:flutter/material.dart';
import 'package:inspire/core/assets/assets.dart';
import 'package:inspire/core/constants/constants.dart';

import '../widgets.dart';

class InputVariantTextWidget extends StatefulWidget {
  const InputVariantTextWidget({
    super.key,
    this.controller,
    this.onChanged,
    this.maxLines,
    this.hint,
    this.endIcon,
    this.textInputType,
    this.borderColor,
    this.errorText,
    this.initialValue,
    this.leadIcon,
    this.obscureText = false, // Tambahan parameter untuk obscure text
  });

  final String? initialValue;
  final TextEditingController? controller;
  final void Function(String value)? onChanged;
  final int? maxLines;
  final String? hint;
  final SvgGenImage? endIcon;
  final SvgGenImage? leadIcon;
  final TextInputType? textInputType;
  final Color? borderColor;
  final String? errorText;
  final bool obscureText; // Property untuk obscure text

  @override
  State<InputVariantTextWidget> createState() => _InputVariantTextWidgetState();
}

class _InputVariantTextWidgetState extends State<InputVariantTextWidget> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  void _toggleObscureText() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: BaseSize.w12),
      decoration: BoxDecoration(
        color: BaseColor.white,
        border: Border.all(color: widget.borderColor ?? Colors.transparent),
        borderRadius: BorderRadius.circular(BaseSize.radiusMd),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          widget.leadIcon == null ? const SizedBox() : _buildLeadIcon(),
          Expanded(child: _buildTextFormField()),
          _buildEndIcon(),
        ],
      ),
    );
  }

  Widget _buildTextFormField() {
    return TextFormField(
      controller: widget.controller,
      onChanged: widget.onChanged,
      maxLines: widget.obscureText ? 1 : widget.maxLines,
      keyboardType: widget.textInputType,
      initialValue: widget.initialValue,
      obscureText: _obscureText,
      decoration: InputDecoration(
        hintText: widget.hint,
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        fillColor: BaseColor.cardBackground1,
        errorText: widget.errorText,
      ),
    );
  }

  Widget _buildLeadIcon() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        widget.leadIcon!.svg(width: BaseSize.w12, height: BaseSize.w12),
        Gap.w12,
        DividerWidget(height: BaseSize.h20),
        Gap.w12,
      ],
    );
  }

  Widget _buildEndIcon() {
    // Jika obscureText aktif dan tidak ada endIcon yang diberikan,
    // tampilkan icon toggle untuk show/hide password
    if (widget.obscureText && widget.endIcon == null) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Gap.w12,
          GestureDetector(
            onTap: _toggleObscureText,
            child: Icon(
              _obscureText ? Icons.visibility_off : Icons.visibility,
              size: BaseSize.h18,
              color: BaseColor.grey,
            ),
          ),
        ],
      );
    }

    // Jika obscureText aktif dan ada endIcon, tampilkan keduanya
    if (widget.obscureText && widget.endIcon != null) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Gap.w12,
          GestureDetector(
            onTap: _toggleObscureText,
            child: Icon(
              _obscureText ? Icons.visibility_off : Icons.visibility,
              size: BaseSize.h18,
              color: BaseColor.grey,
            ),
          ),
          Gap.w8,
          widget.endIcon!.svg(width: BaseSize.w12, height: BaseSize.w12),
        ],
      );
    }

    // Jika tidak obscureText tapi ada endIcon
    if (widget.endIcon != null) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Gap.w12,
          widget.endIcon!.svg(width: BaseSize.w12, height: BaseSize.w12),
        ],
      );
    }

    return const SizedBox();
  }
}
