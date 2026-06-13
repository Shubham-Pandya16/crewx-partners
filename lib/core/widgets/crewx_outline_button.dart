import 'package:flutter/material.dart';

class CrewXOutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const CrewXOutlineButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      child: Text(label),
    );
  }
}
