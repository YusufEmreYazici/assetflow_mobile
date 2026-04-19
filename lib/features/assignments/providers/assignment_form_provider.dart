import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assetflow_mobile/data/models/assignment_form_model.dart';
import 'package:assetflow_mobile/data/services/assignment_form_service.dart';

class AssignmentFormNotifier
    extends StateNotifier<AsyncValue<List<AssignmentForm>>> {
  final String assignmentId;
  final AssignmentFormService _service;

  AssignmentFormNotifier(this.assignmentId, this._service)
      : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    state = const AsyncValue.loading();
    try {
      final forms = await _service.getByAssignment(assignmentId);
      state = AsyncValue.data(forms);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() => _load();

  Future<AssignmentForm> generateAssignmentForm() async {
    final form = await _service.generateAssignmentForm(assignmentId);
    await _load();
    return form;
  }

  Future<AssignmentForm> generateReturnForm() async {
    final form = await _service.generateReturnForm(assignmentId);
    await _load();
    return form;
  }

  Future<void> uploadSigned(
    String formId,
    String filePath,
    String fileName,
  ) async {
    await _service.uploadSigned(formId, filePath, fileName);
    await _load();
  }
}

final _assignmentFormServiceProvider =
    Provider<AssignmentFormService>((_) => AssignmentFormService());

final assignmentFormProvider = StateNotifierProvider.family<
    AssignmentFormNotifier,
    AsyncValue<List<AssignmentForm>>,
    String>(
  (ref, assignmentId) => AssignmentFormNotifier(
    assignmentId,
    ref.watch(_assignmentFormServiceProvider),
  ),
);
