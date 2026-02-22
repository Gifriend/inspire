import 'package:flutter/material.dart';
import '../../constants/constants.dart';

class DropdownWidget<T> extends StatelessWidget {
  final List<T> items;
  final T? value;
  final String hintText;
  final bool isLoading;
  final String Function(T item) itemLabelBuilder;
  final void Function(T? value)? onChanged;
  final String? Function(T? value)? validator;
  final String? labelText;

  const DropdownWidget({
    super.key,
    required this.items,
    required this.value,
    required this.hintText,
    required this.itemLabelBuilder,
    required this.onChanged,
    this.isLoading = false,
    this.validator,
    this.labelText,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      focusColor: BaseColor.transparent,
      dropdownColor: BaseColor.white,
      value: value,
      isExpanded: true,
      menuMaxHeight: 300, 
      decoration: InputDecoration(
        labelText: labelText,
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: BaseColor.grey, width: 1.0),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: BaseColor.primaryInspire,
            width: 2.0,
          ),
        ),
        border: const OutlineInputBorder(),
        hintText: hintText,
      ),
      validator: validator,
      selectedItemBuilder: (BuildContext context) {
        return items.map<Widget>((item) {
          return Text(
            itemLabelBuilder(item),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          );
        }).toList();
      },
      items: items.map((item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Container(
            width: double.infinity,
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: BaseColor.grey.shade300, 
                  width: 1.0,
                ),
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Text(
              itemLabelBuilder(item),
              style: BaseTypography.bodyLarge, 
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        );
      }).toList(),
      onChanged: isLoading ? null : onChanged,
    );
  }
}