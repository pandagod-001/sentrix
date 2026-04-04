import 'package:flutter/foundation.dart';
import '../models/admin_models.dart';
import '../../../services/api_service.dart';

/// Admin Dashboard Statistics
class AdminStats {
  final int totalUsers;
  final int activeUsers;
  final int pendingApprovals;
  final int totalGroups;
  final int totalMessages;
  final DateTime lastUpdated;

  AdminStats({
    required this.totalUsers,
    required this.activeUsers,
    required this.pendingApprovals,
    required this.totalGroups,
    required this.totalMessages,
    required this.lastUpdated,
  });

  int get inactiveUsers => totalUsers - activeUsers;
}

/// Admin Controller - Manages admin dashboard and user approvals
class AdminController extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<AdminApprovalRequest> _pendingApprovals = [];
  List<AdminPersonnelRecord> _personnelRecords = [];
  List<AdminGroupRecord> _groupRecords = [];
  List<AdminFaceScanRecord> _faceScans = [];
  AdminStats? _stats;

  bool _isLoading = false;
  String? _errorMessage;

  List<AdminApprovalRequest> get pendingApprovals => _pendingApprovals;
  List<AdminPersonnelRecord> get personnelRecords => _personnelRecords;
  List<AdminGroupRecord> get groupRecords => _groupRecords;
  List<AdminFaceScanRecord> get faceScans => _faceScans;
  AdminStats? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AdminController() {
    refreshAdminData();
  }

  /// Approve a pending user
  Future<bool> approveUser(String approvalRequestId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.approveUser(approvalRequestId);
      if (response['success'] == true) {
        await refreshAdminData();
        _isLoading = false;
        notifyListeners();
        return true;
      }
      throw Exception(response['message'] ?? 'Approval failed');
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }

  }

  Future<void> _loadFromApi() async {
    final usersResponse = await _apiService.getPendingApprovals();
    final data = usersResponse['data'] as Map<String, dynamic>?;
    final users = data?['users'] as List<dynamic>? ?? <dynamic>[];

    final groupsResponse = await _apiService.getGroups();
    final groupsData = groupsResponse['data'] as Map<String, dynamic>?;
    final groups = groupsData?['groups'] as List<dynamic>? ?? <dynamic>[];

    final scansResponse = await _apiService.getFaceScanHistory(limit: 5);
    final scansData = scansResponse['data'] as Map<String, dynamic>?;
    final scans = scansData?['scans'] as List<dynamic>? ?? <dynamic>[];

    final mappedUsers = users.whereType<Map<String, dynamic>>().toList();

    _pendingApprovals = mappedUsers
        .where((u) => (u['is_approved'] ?? false) == false)
        .map(
          (u) => AdminApprovalRequest(
            id: (u['id'] ?? u['_id'] ?? '').toString(),
            userName: (u['username'] ?? 'Unknown').toString(),
            userEmail: (u['username'] ?? 'Unknown').toString(),
            userRole: (u['role'] ?? 'personnel').toString(),
            requestedAt: DateTime.now(),
            status: 'pending',
            reason: 'New account registration',
          ),
        )
        .toList();

    _personnelRecords = mappedUsers
        .map(
          (u) => AdminPersonnelRecord(
            id: (u['id'] ?? u['_id'] ?? '').toString(),
            name: (u['username'] ?? 'Unknown').toString(),
            email: (u['username'] ?? 'Unknown').toString(),
            role: (u['role'] ?? 'personnel').toString(),
            status: ((u['is_approved'] ?? false) == true) ? 'active' : 'inactive',
            joinedAt: DateTime.now(),
            isApproved: (u['is_approved'] ?? false) as bool,
            lastActive: DateTime.now(),
          ),
        )
        .toList();

    _groupRecords = groups
        .whereType<Map<String, dynamic>>()
        .map(
          (g) => AdminGroupRecord(
            id: (g['id'] ?? '').toString(),
            name: (g['name'] ?? 'Group').toString(),
            createdBy: 'System',
            memberCount: (g['member_count'] as int?) ?? 0,
            createdAt: DateTime.now(),
            lastActivityAt: DateTime.now(),
            type: (g['type'] ?? 'official').toString(),
            description: (g['type'] ?? 'group').toString(),
          ),
        )
        .toList();

      _faceScans = scans
        .whereType<Map<String, dynamic>>()
        .map((scan) => AdminFaceScanRecord.fromJson(scan))
        .toList();

    _stats = AdminStats(
      totalUsers: _personnelRecords.length,
      activeUsers: _personnelRecords.where((p) => p.status == 'active').length,
      pendingApprovals: _pendingApprovals.length,
      totalGroups: _groupRecords.length,
      totalMessages: _stats?.totalMessages ?? 0,
      lastUpdated: DateTime.now(),
    );
  }

  /// Reject a pending user
  Future<bool> rejectUser(String approvalRequestId, String reason) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.rejectUser(approvalRequestId, reason);
      if (response['success'] == true) {
        await refreshAdminData();
        _isLoading = false;
        notifyListeners();
        return true;
      }
      throw Exception(response['message'] ?? 'Rejection failed');
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Suspend a personnel account
  Future<void> suspendPersonnel(String personnelId, String reason) async {
    final index = _personnelRecords
        .indexWhere((p) => p.id == personnelId);

    if (index != -1) {
      final record = _personnelRecords[index];
      _personnelRecords[index] = record.copyWith(
        status: 'suspended',
      );
      notifyListeners();
    }
  }

  /// Activate a suspended account
  Future<void> activatePersonnel(String personnelId) async {
    final index = _personnelRecords
        .indexWhere((p) => p.id == personnelId);

    if (index != -1) {
      final record = _personnelRecords[index];
      _personnelRecords[index] = record.copyWith(
        status: 'active',
      );
      notifyListeners();
    }
  }

  /// Get detailed user info
  AdminPersonnelRecord? getPersonnelDetails(String personnelId) {
    try {
      return _personnelRecords
          .firstWhere((p) => p.id == personnelId);
    } catch (e) {
      return null;
    }
  }

  /// Get approval request details
  AdminApprovalRequest? getApprovalDetails(String approvalId) {
    try {
      return _pendingApprovals
          .firstWhere((apr) => apr.id == approvalId);
    } catch (e) {
      return null;
    }
  }

  /// Get group details
  AdminGroupRecord? getGroupDetails(String groupId) {
    try {
      return _groupRecords
          .firstWhere((g) => g.id == groupId);
    } catch (e) {
      return null;
    }
  }

  /// Search personnel by name or member ID
  List<AdminPersonnelRecord> searchPersonnel(String query) {
    final q = query.toLowerCase();
    return _personnelRecords
        .where((p) =>
            p.name.toLowerCase().contains(q) ||
            p.email.toLowerCase().contains(q))
        .toList();
  }

  /// Get pending approvals count
  int getPendingApprovalsCount() {
    return _pendingApprovals
        .where((apr) => apr.status == 'pending')
        .length;
  }

  /// Get active personnel count
  int getActivePersonnelCount() {
    return _personnelRecords
        .where((p) => p.status == 'active')
        .length;
  }

  /// Refresh admin data
  Future<void> refreshAdminData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _loadFromApi();
      _isLoading = false;
      notifyListeners();
      return;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return;
    }

  }

  /// Export admin report
  String exportAdminReport() {
    final buffer = StringBuffer();
    buffer.writeln('SENTRIX Admin Report');
    buffer.writeln('Generated: ${DateTime.now()}');
    buffer.writeln('===========================================');

    buffer.writeln('\nSTATISTICS:');
    if (_stats != null) {
      buffer.writeln('Total Users: ${_stats!.totalUsers}');
      buffer.writeln('Active Users: ${_stats!.activeUsers}');
      buffer.writeln('Pending Approvals: ${_stats!.pendingApprovals}');
      buffer.writeln('Total Groups: ${_stats!.totalGroups}');
      buffer.writeln('Total Messages: ${_stats!.totalMessages}');
    }

    buffer.writeln('\nPENDING APPROVALS:');
    for (var approval in _pendingApprovals) {
      buffer.writeln('- ${approval.userName} (${approval.userEmail})');
    }

    buffer.writeln('\nPERSONNEL RECORDS:');
    for (var personnel in _personnelRecords) {
      buffer.writeln('- ${personnel.name} (${personnel.status})');
    }

    return buffer.toString();
  }
}
