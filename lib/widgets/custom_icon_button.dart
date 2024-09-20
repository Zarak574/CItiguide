
import 'package:flutter/material.dart';
class CustomIconButton extends StatelessWidget {

  final Icon icon;
  final VoidCallback onPressed;

   CustomIconButton({
    Key? key,
    required this.icon, required this.onPressed,

  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color:Color(0xFFFF8340)),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: onPressed,
        constraints: const BoxConstraints.tightFor(width: 40),
        color: Color(0xFF56C6D3),
        icon: icon,
        splashRadius: 20,
      ),
    );
  }
}
