import 'package:flutter/material.dart';

class TextFormInput extends StatefulWidget {
  const TextFormInput({
    super.key,
    required this.controller,
    this.keyboardType,
    this.labelText,
    this.suffix,
    this.prefix,
    this.hasDropdown = false,
    this.readOnly = false,
  });

  final String? labelText;
  final String? suffix;
  final String? prefix;
  final bool? hasDropdown;
  final bool readOnly;

  final TextInputType? keyboardType;
  final TextEditingController controller;

  @override
  State<TextFormInput> createState() => _TextFormInputState();
}

class _TextFormInputState extends State<TextFormInput> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      readOnly: widget.readOnly,
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 5,
            children: [
              Text(
                widget.prefix ?? "",
                style: TextStyle(fontSize: 12),
              ),
              Icon(
                Icons.info_outlined,
                size: 14,
              )
            ],
          ),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        suffixIcon: Padding(
          padding: const EdgeInsets.only(right: 15, top: 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.suffix ?? "",
                style: TextStyle(fontSize: 12),
              ),
              if (widget.hasDropdown ?? true) ...[
                Icon(
                  Icons.arrow_drop_down_outlined,
                  size: 25,
                )
              ]
            ],
          ),
        ),
      ),
      keyboardType: widget.keyboardType,
    );
  }
}
