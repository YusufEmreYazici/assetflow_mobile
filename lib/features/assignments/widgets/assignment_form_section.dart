import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';
import 'package:assetflow_mobile/data/models/assignment_form_model.dart';
import 'package:assetflow_mobile/features/assignments/providers/assignment_form_provider.dart';
import 'package:assetflow_mobile/features/assignments/widgets/form_action_sheet.dart';

class AssignmentFormSection extends ConsumerWidget {
  final String assignmentId;

  const AssignmentFormSection({super.key, required this.assignmentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncForms = ref.watch(assignmentFormProvider(assignmentId));

    return asyncForms.when(
      loading: () => const _Shimmer(),
      error: (e, _) => _ErrorState(message: e.toString()),
      data: (forms) {
        if (forms.isEmpty) {
          return _EmptyState(
            onGenerate: () => ref
                .read(assignmentFormProvider(assignmentId).notifier)
                .generateAssignmentForm(),
          );
        }
        return _FormCard(form: forms.first);
      },
    );
  }
}

class _FormCard extends StatelessWidget {
  final AssignmentForm form;

  const _FormCard({required this.form});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd.MM.yyyy').format(form.generatedAt);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.dark800,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Icon(
          form.type == 0 ? Icons.assignment : Icons.assignment_return,
          color: AppColors.primary400,
        ),
        title: Text(
          form.typeLabel,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'No: ${form.formNumber}',
              style: const TextStyle(
                fontSize: 11,
                fontFamily: 'monospace',
                color: AppColors.textTertiary,
              ),
            ),
            Text(
              dateStr,
              style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
            ),
            if (form.isSigned)
              const Text(
                '✓ İmzalı',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.download, color: AppColors.primary400),
          tooltip: 'İndir / Paylaş',
          onPressed: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => FormActionSheet(form: form),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final Future<void> Function() onGenerate;

  const _EmptyState({required this.onGenerate});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.dark800,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.description_outlined,
              color: AppColors.textTertiary, size: 20),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Henüz form oluşturulmadı',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: onGenerate,
            child: const Text('Üret'),
          ),
        ],
      ),
    );
  }
}

class _Shimmer extends StatelessWidget {
  const _Shimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.dark800,
      highlightColor: AppColors.dark700,
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: AppColors.dark800,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;

  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Form yüklenemedi: $message',
              style:
                  const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
