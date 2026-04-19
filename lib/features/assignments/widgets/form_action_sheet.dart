import 'package:flutter/material.dart';
import 'package:assetflow_mobile/data/models/assignment_form_model.dart';

// TODO(T6): Tam implementasyon T6'da tamamlanacak
class FormActionSheet extends StatelessWidget {
  final AssignmentForm form;

  const FormActionSheet({super.key, required this.form});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              form.typeLabel,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text('Form No: ${form.formNumber}'),
            const SizedBox(height: 16),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
