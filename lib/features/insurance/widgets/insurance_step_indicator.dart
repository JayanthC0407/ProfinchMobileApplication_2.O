import 'package:flutter/material.dart';

/// Public step-progress indicator used across all 3 buy-insurance steps.
/// Was previously a private `_StepIndicator` inside buy_insurance_fill_screen.dart
/// which Dart won't allow importing into other files. Extracted here so every
/// step screen can import it without restriction.
class InsuranceStepIndicator extends StatelessWidget {
  final int current; // 1, 2, or 3

  const InsuranceStepIndicator({super.key, required this.current});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Step $current of 3',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 12),
          ),
          const SizedBox(height: 6),
          Row(
            children: List.generate(3, (i) {
              return Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 3,
                  margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
                  decoration: BoxDecoration(
                    color: (i < current) ? Colors.white : Colors.white38,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}