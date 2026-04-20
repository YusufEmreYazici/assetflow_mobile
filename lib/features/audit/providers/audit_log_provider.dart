import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assetflow_mobile/data/models/audit_log_model.dart';
import 'package:assetflow_mobile/data/models/paged_result.dart';
import 'package:assetflow_mobile/data/services/audit_log_service.dart';

final auditLogServiceProvider = Provider((ref) => AuditLogService());

final deviceAuditLogsProvider =
    FutureProvider.autoDispose.family<PagedResult<AuditLog>, String>(
  (ref, deviceId) async {
    final service = ref.read(auditLogServiceProvider);
    return service.getForDevice(deviceId, page: 1, pageSize: 20);
  },
);
