import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';
import 'package:assetflow_mobile/data/models/assignment_form_model.dart';
import 'package:assetflow_mobile/data/services/assignment_form_service.dart';
import 'package:assetflow_mobile/features/assignments/providers/assignment_form_provider.dart';

class FormActionSheet extends ConsumerStatefulWidget {
  final AssignmentForm form;

  const FormActionSheet({super.key, required this.form});

  @override
  ConsumerState<FormActionSheet> createState() => _FormActionSheetState();
}

class _FormActionSheetState extends ConsumerState<FormActionSheet> {
  File? _localFile;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _download();
  }

  Future<void> _download() async {
    setState(() => _loading = true);
    try {
      final bytes = await AssignmentFormService().downloadForm(widget.form.id);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/${widget.form.fileName}');
      await file.writeAsBytes(bytes);
      if (mounted) setState(() => _localFile = file);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('İndirme hatası: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _open() async {
    if (_localFile == null) return;
    await OpenFile.open(_localFile!.path);
  }

  Future<void> _share() async {
    if (_localFile == null) return;
    await Share.shareXFiles(
      [XFile(_localFile!.path)],
      subject: widget.form.fileName,
    );
  }

  Future<void> _uploadSigned() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'pdf', 'png', 'jpg'],
      withData: false,
    );
    if (result == null || result.files.isEmpty) return;

    final picked = result.files.first;
    if (picked.path == null) return;

    setState(() => _loading = true);
    try {
      await ref
          .read(assignmentFormProvider(widget.form.assignmentId).notifier)
          .uploadSigned(widget.form.id, picked.path!, picked.name);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('İmzalı form yüklendi'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Yükleme hatası: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  widget.form.type == 0
                      ? Icons.assignment
                      : Icons.assignment_return,
                  color: AppColors.primary400,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.form.typeLabel,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        'Form No: ${widget.form.formNumber}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textTertiary,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.form.isSigned)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      '✓ İmzalı',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (_loading)
              const LinearProgressIndicator(
                color: AppColors.primary500,
                backgroundColor: AppColors.dark800,
              )
            else
              const SizedBox(height: 2),
            const SizedBox(height: 8),
            const Divider(color: AppColors.border),
            ListTile(
              leading: const Icon(Icons.open_in_new, color: AppColors.primary400),
              title: const Text('Aç'),
              subtitle: const Text('Excel görüntüleyicide aç'),
              enabled: _localFile != null,
              onTap: _open,
            ),
            ListTile(
              leading: const Icon(Icons.share, color: AppColors.info),
              title: const Text('Paylaş'),
              subtitle: const Text('WhatsApp, e-posta veya diğer uygulamalar'),
              enabled: _localFile != null,
              onTap: _share,
            ),
            ListTile(
              leading:
                  const Icon(Icons.upload_file, color: AppColors.success),
              title: const Text('İmzalı Form Yükle'),
              subtitle: const Text('xlsx, pdf, png veya jpg'),
              onTap: _loading ? null : _uploadSigned,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
