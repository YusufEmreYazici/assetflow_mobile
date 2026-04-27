import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';

class StepIndicator extends StatelessWidget {
  final List<String> steps;
  final int currentStep;

  const StepIndicator({
    super.key,
    required this.steps,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: List.generate(steps.length * 2 - 1, (i) {
          if (i.isOdd) {
            final stepIndex = i ~/ 2;
            final done = stepIndex < currentStep;
            return Expanded(
              child: Container(
                height: 1,
                color: done ? AppColors.navy : AppColors.surfaceDivider,
              ),
            );
          }
          final stepIndex = i ~/ 2;
          return _StepDot(
            label: steps[stepIndex],
            index: stepIndex + 1,
            state: stepIndex < currentStep
                ? _StepState.done
                : stepIndex == currentStep
                ? _StepState.active
                : _StepState.idle,
          );
        }),
      ),
    );
  }
}

enum _StepState { done, active, idle }

class _StepDot extends StatelessWidget {
  final String label;
  final int index;
  final _StepState state;

  const _StepDot({
    required this.label,
    required this.index,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = state == _StepState.active;
    final isDone = state == _StepState.done;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDone
                ? AppColors.navy
                : isActive
                ? AppColors.navy
                : AppColors.surfaceDivider,
            border: Border.all(
              color: isDone || isActive
                  ? AppColors.navy
                  : AppColors.surfaceInputBorder,
              width: 1.5,
            ),
          ),
          child: Center(
            child: isDone
                ? const Icon(Icons.check, size: 14, color: Colors.white)
                : Text(
                    '$index',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isActive ? Colors.white : AppColors.textTertiary,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
            color: isActive || isDone ? AppColors.navy : AppColors.textTertiary,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}
