import 'package:flutter/material.dart';
import 'package:test_application/controllers/text_changes_controller.dart';


class CustomTextField extends StatelessWidget {
  final TextChangesController controller;

  const CustomTextField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller.textController,
      maxLines: 8,
      keyboardType: TextInputType.multiline,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
      ),
    );
  }
}