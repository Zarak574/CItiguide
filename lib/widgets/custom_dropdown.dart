import 'package:flutter/material.dart';

class CustomDropdownButton extends StatelessWidget {
  final String? value;
  final List<String> items;
  final String hint;
  final String labelText;
  final ValueChanged<String?>? onChanged;

  const CustomDropdownButton({
    Key? key,
    required this.items,
    required this.hint,
    this.value,
    this.onChanged, required this.labelText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      initialValue: value,
      onSelected: onChanged,
      color: Theme.of(context).colorScheme.secondary,
      popUpAnimationStyle: AnimationStyle.noAnimation,
      itemBuilder: (BuildContext context) {
        return items.map<PopupMenuEntry<String>>((String item) {
          return PopupMenuItem<String>(
            value: item,
            padding: const EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Text(item),
            ),
          );
        }).toList();
      },
      offset: const Offset(10, 0),
      child: InputDecorator(
        decoration: InputDecoration(
          filled: true,
          labelText: labelText,
          labelStyle: const TextStyle(color: Color(0xFF56C6D3), fontSize: 18),
          fillColor: Theme.of(context).colorScheme.secondary,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide( width: 1.0),
          ),
           enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(color: Color(0xFF56C6D3),width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(color: Color(0xFF56C6D3), width: 2.0),
          ),
          hintText: hint,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16), 
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(value ?? hint),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }
}
