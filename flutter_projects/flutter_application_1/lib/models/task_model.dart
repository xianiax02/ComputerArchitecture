import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter_application_1/constants.dart'; // Import constants.dart

class CategoryColor {
  static final Map<String, Color> _categoryColorMap = {};
  static int _colorIndex = 0; // New counter for predefined colors

  static Color getColor(String category) {
    if (category.isEmpty) {
      // Fallback to random if category is empty, or handle as per requirement
      final Random random = Random(); // Local random for this case
      return Color.fromARGB(
        255,
        random.nextInt(256),
        random.nextInt(256),
        random.nextInt(256),
      );
    }

    if (_categoryColorMap.containsKey(category)) {
      return _categoryColorMap[category]!;
    } else {
      // Assign color from predefined list
      final color =
          predefinedCategoryColors[_colorIndex %
              predefinedCategoryColors.length];
      _categoryColorMap[category] = color;
      _colorIndex++; // Increment for the next category
      return color;
    }
  }
}

class Task {
  final String id;
  final String title;
  final String details;
  final String category;
  final Color color;
  final bool isCompleted;
  final String index; // Changed to String

  Task({
    required this.id,
    required this.title,
    required this.details,
    required this.index,
    required this.category,
    this.isCompleted = false,
  }) : color = CategoryColor.getColor(category);

  factory Task.createDefault(int taskIndex) {
    // Ensure taskIndex is within the bounds of the indices list
    final String defaultIndex = (taskIndex < indices.length)
        ? indices[taskIndex]
        : 'index${taskIndex + 1}';

    return Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Task${taskIndex + 1}',
      details: 'details',
      category: 'category',
      index: defaultIndex, // Use the string index
    );
  }
}
