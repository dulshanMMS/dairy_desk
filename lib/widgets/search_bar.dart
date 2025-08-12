import 'package:flutter/material.dart';

class CustomSearchBar extends StatelessWidget {
  final String hintText;
  final void Function(String)? onChanged;
  final TextEditingController? controller;
  final VoidCallback? onClear;
  final bool showClearButton;

  const CustomSearchBar({
    super.key,
    this.hintText = 'Search...',
    this.onChanged,
    this.controller,
    this.onClear,
    this.showClearButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(
            Icons.search,
            color: theme.primaryColor,
          ),
          suffixIcon: showClearButton && 
                     controller != null && 
                     controller!.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    controller!.clear();
                    if (onClear != null) onClear!();
                    if (onChanged != null) onChanged!('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
