import 'package:flutter/material.dart';

class DayButton extends StatelessWidget {
  final DateTime day;

  const DayButton({super.key, required this.day});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: () {}, child: Text(day.day.toString()));
  }
}
