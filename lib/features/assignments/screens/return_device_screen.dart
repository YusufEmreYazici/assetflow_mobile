import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';
import 'package:assetflow_mobile/core/widgets/app_button.dart';
import 'package:assetflow_mobile/data/models/assignment_model.dart';
import 'package:assetflow_mobile/features/assignments/providers/assignment_form_provider.dart';
import 'package:assetflow_mobile/features/assignments/providers/assignment_provider.dart';
import 'package:assetflow_mobile/features/assignments/widgets/form_action_sheet.dart';

class ReturnDeviceScreen extends ConsumerStatefulWidget {
  final Assignment assignment;

  const ReturnDeviceScreen({super.key, required this.assignment});

  @override
  ConsumerState<ReturnDeviceScreen> createState() => _ReturnDeviceScreenState();
}

class _ReturnDeviceScreenState extends ConsumerState<ReturnDeviceScreen> {
  int _condition = 0;
  final _returnNotesCtrl = TextEditingController();
  final _deviceNotesCtrl = TextEditingController();
  bool _retireDevice = false;
  bool _saving = false;

  @override
  void dispose() {
    _returnNotesCtrl.dispose();
    _deviceNotesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cihaz İade')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SummaryCard(assignment: widget.assignment),
            const SizedBox(height: 24),

            const Text(
              'İade Durumu *',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              initialValue: _condition,
              dropdownColor: AppColors.dark800,
              items: ReturnConditionLabels.entries
                  .map(
                    (e) => DropdownMenuItem(value: e.key, child: Text(e.value)),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _condition = v ?? 0),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.check_circle_outline, size: 18),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              'İade Notu',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _returnNotesCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Örnek: Ekran çatladı, servis gerekiyor',
                contentPadding: EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              'Cihaza Eklenecek Not (opsiyonel)',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _deviceNotesCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Gelecekteki zimmetlerde görünür',
                contentPadding: EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 16),

            Container(
              decoration: BoxDecoration(
                color: _retireDevice
                    ? AppColors.error.withValues(alpha: 0.08)
                    : AppColors.dark800,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _retireDevice
                      ? AppColors.error.withValues(alpha: 0.4)
                      : AppColors.border,
                ),
              ),
              child: SwitchListTile(
                title: const Text(
                  'Cihazı Emekli Et',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text(
                  'Envantere geri dönmez — hurda, kayıp veya onarılamaz',
                  style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
                ),
                value: _retireDevice,
                onChanged: (v) => setState(() => _retireDevice = v),
                secondary: Icon(
                  Icons.delete_outline,
                  color: _retireDevice
                      ? AppColors.error
                      : AppColors.textTertiary,
                ),
                activeThumbColor: AppColors.error,
              ),
            ),
            const SizedBox(height: 32),

            AppButton(
              text: _retireDevice ? 'Emekli Et ve İade' : 'İade Et',
              icon: Icons.check_circle,
              onPressed: _saving ? null : _submit,
              isLoading: _saving,
              isFullWidth: true,
              variant: _retireDevice
                  ? AppButtonVariant.danger
                  : AppButtonVariant.primary,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_retireDevice ? 'Emekli Et?' : 'İade Onayı'),
        content: Text(
          _retireDevice
              ? '"${widget.assignment.deviceName}" emekli edilecek ve envanterden düşürülecek. Emin misiniz?'
              : 'İade işlemi tamamlanacak. Onaylıyor musunuz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Onayla'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _saving = true);
    try {
      await ref
          .read(assignmentProvider.notifier)
          .returnDevice(
            widget.assignment.id,
            returnCondition: _condition,
            returnNotes: _returnNotesCtrl.text.trim().isEmpty
                ? null
                : _returnNotesCtrl.text.trim(),
            deviceNotes: _deviceNotesCtrl.text.trim().isEmpty
                ? null
                : _deviceNotesCtrl.text.trim(),
            retireDevice: _retireDevice,
          );

      if (!mounted) return;

      final generateForm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('İade Formu'),
          content: const Text('İade formu oluşturulup indirilsin mi?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Hayır'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Evet, Üret'),
            ),
          ],
        ),
      );

      if (!mounted) return;
      Navigator.pop(context, true);

      if (generateForm == true && mounted) {
        final form = await ref
            .read(assignmentFormProvider(widget.assignment.id).notifier)
            .generateReturnForm();
        if (!mounted) return;
        await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (_) => FormActionSheet(form: form),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('İade başarısız: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _SummaryCard extends StatelessWidget {
  final Assignment assignment;

  const _SummaryCard({required this.assignment});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.dark800,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (assignment.assetTag != null)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primary600.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                assignment.assetTag!,
                style: const TextStyle(
                  fontSize: 12,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary400,
                ),
              ),
            ),
          Row(
            children: [
              const Icon(
                Icons.computer,
                size: 16,
                color: AppColors.textTertiary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  assignment.deviceName ?? '-',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.person, size: 16, color: AppColors.textTertiary),
              const SizedBox(width: 8),
              Text(
                assignment.employeeName ?? '-',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              if (assignment.employeeDepartment != null) ...[
                const SizedBox(width: 6),
                Text(
                  '— ${assignment.employeeDepartment}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
