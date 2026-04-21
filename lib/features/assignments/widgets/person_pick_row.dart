import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';
import 'package:assetflow_mobile/data/models/employee_model.dart';

class PersonPickRow extends StatelessWidget {
  final Employee employee;
  final bool selected;
  final VoidCallback onTap;

  const PersonPickRow({
    super.key,
    required this.employee,
    required this.selected,
    required this.onTap,
  });

  String get _initials {
    final parts = employee.fullName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return employee.fullName.substring(0, 2).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.infoBg
              : AppColors.surfaceWhite,
          border: Border.all(
            color: selected ? AppColors.navy : AppColors.surfaceDivider,
          ),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: selected ? AppColors.navy : AppColors.surfaceLight,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                _initials,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: selected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    employee.fullName,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (employee.title != null || employee.department != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      [employee.title, employee.department]
                          .whereType<String>()
                          .join(' · '),
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle, size: 20, color: AppColors.navy)
            else
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.surfaceInputBorder),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
