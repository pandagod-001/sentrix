import 'package:flutter/foundation.dart';
import '../models/group_models.dart';
import '../../../services/api_service.dart';

/// Groups Controller - Manages groups and group memberships
class GroupsController extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<GroupModel> _groups = [];
  List<GroupMember> _currentGroupMembers = [];
  String? _selectedGroupId;
  String? _error;
  List<Map<String, String>> _memberCandidates = [];

  bool _isLoading = false;

  List<GroupModel> get groups => _groups;
  List<GroupMember> get currentGroupMembers =>
      _currentGroupMembers;
  String? get selectedGroupId => _selectedGroupId;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Map<String, String>> get memberCandidates => _memberCandidates;

  String _cleanError(Object error) {
    final raw = error.toString();
    return raw
        .replaceFirst('Exception: ', '')
        .replaceFirst('API Request Failed: ', '')
        .trim();
  }

  GroupsController() {
    refreshGroups();
  }

  /// Select a group and load its members
  Future<void> selectGroup(String groupId) async {
    _selectedGroupId = groupId;
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.get<Map<String, dynamic>>('/groups/$groupId/members');
      final data = response['data'] as Map<String, dynamic>?;
      final members = data?['members'] as List<dynamic>? ?? <dynamic>[];

      _currentGroupMembers = members
          .whereType<Map<String, dynamic>>()
          .map(
            (m) => GroupMember(
              id: (m['id'] ?? '').toString(),
              name: (m['username'] ?? 'Unknown').toString(),
              email: ((m['username'] ?? 'user').toString()) + '@sentrix.local',
              role: (m['role'] ?? 'member').toString(),
              joinedAt: DateTime.now(),
              avatar: null,
              status: 'offline',
            ),
          )
          .toList();
      _error = null;
    } catch (_) {
      _currentGroupMembers = [];
      _error = 'Failed to load group members';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Create new group
  Future<bool> createGroup(
    String name,
    String description,
    String type, {
    String? personnelId,
    List<String> selectedMemberIds = const <String>[],
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (type == 'family') {
        if (personnelId == null || personnelId.isEmpty) {
          throw Exception('Personnel selection is required for family groups');
        }
        await _apiService.createFamilyGroup(personnelId);
      } else {
        await _apiService.createGroup(name, selectedMemberIds);
      }
      await refreshGroups();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _cleanError(e);
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Add member to group
  Future<void> addMemberToGroup(String groupId, String memberId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _apiService.post<Map<String, dynamic>>('/groups/$groupId/add-member', {'member_id': memberId});
      await selectGroup(groupId);
      await refreshGroups();
      _isLoading = false;
      notifyListeners();
      return;
    } catch (e) {
      _error = _cleanError(e);
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Remove member from group
  Future<void> removeMemberFromGroup(
    String groupId,
    String memberId,
  ) async {
    try {
      await _apiService.delete<Map<String, dynamic>>('/groups/$groupId/remove-member?member_id=$memberId');
      await refreshGroups();
      await selectGroup(groupId);
      return;
    } catch (_) {
      _error = 'Failed to remove member';
    }

    notifyListeners();
  }

  /// Leave group
  Future<void> leaveGroup(String groupId) async {
    try {
      await _apiService.delete<Map<String, dynamic>>('/groups/$groupId');
    } catch (_) {
      _error = 'Failed to leave group';
    }

    _groups.removeWhere((g) => g.id == groupId);

    if (_selectedGroupId == groupId) {
      _selectedGroupId = null;
      _currentGroupMembers.clear();
    }

    notifyListeners();
  }

  /// Delete group (admin only)
  Future<void> deleteGroup(String groupId) async {
    try {
      await _apiService.delete<Map<String, dynamic>>('/groups/$groupId');
    } catch (_) {
      _error = 'Failed to delete group';
    }

    _groups.removeWhere((g) => g.id == groupId);

    if (_selectedGroupId == groupId) {
      _selectedGroupId = null;
      _currentGroupMembers.clear();
    }

    notifyListeners();
  }

  /// Mute group notifications
  void muteGroup(String groupId) {
    final index = _groups.indexWhere((g) => g.id == groupId);
    if (index != -1) {
      final group = _groups[index];
      _groups[index] = group.copyWith(isMuted: true);
      notifyListeners();
    }
  }

  /// Unmute group notifications
  void unmuteGroup(String groupId) {
    final index = _groups.indexWhere((g) => g.id == groupId);
    if (index != -1) {
      final group = _groups[index];
      _groups[index] = group.copyWith(isMuted: false);
      notifyListeners();
    }
  }

  /// Search groups
  List<GroupModel> searchGroups(String query) {
    final q = query.toLowerCase();
    return _groups
        .where((g) =>
            g.name.toLowerCase().contains(q) ||
            g.description.toLowerCase().contains(q))
        .toList();
  }

  /// Get group details
  GroupModel? getGroupDetails(String groupId) {
    try {
      return _groups.firstWhere((g) => g.id == groupId);
    } catch (e) {
      return null;
    }
  }

  /// Update group info
  Future<void> updateGroup(String groupId, String name, String description) async {
    final index = _groups.indexWhere((g) => g.id == groupId);
    if (index != -1) {
      final group = _groups[index];
      _groups[index] = group.copyWith(
        name: name,
        description: description,
      );
      notifyListeners();
    }
  }

  Future<void> refreshGroups() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.getGroups();
      final data = response['data'] as Map<String, dynamic>?;
      final groups = data?['groups'] as List<dynamic>? ?? <dynamic>[];

      _groups = groups
          .whereType<Map<String, dynamic>>()
          .map(
            (g) => GroupModel(
              id: (g['id'] ?? '').toString(),
              name: (g['name'] ?? 'Group').toString(),
              description: (g['type'] ?? 'group').toString(),
              type: (g['type'] ?? 'official').toString(),
              createdBy: 'System',
              createdAt: DateTime.now(),
              memberCount: (g['member_count'] as int?) ?? 0,
              messages: 0,
              lastActivity: DateTime.now(),
              isAdmin: true,
              isMuted: false,
            ),
          )
          .toList();
      _error = null;
    } catch (e) {
      _groups = [];
      _error = _cleanError(e);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadMemberCandidatesForType(String type) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (type == 'official' || type == 'family') {
        final response = await _apiService.getAllUsers();
        final data = response['data'] as Map<String, dynamic>?;
        final users = data?['users'] as List<dynamic>? ?? <dynamic>[];

        _memberCandidates = users
            .whereType<Map<String, dynamic>>()
            .where((u) => (u['role'] ?? '').toString() == 'personnel')
            .map((u) => {
                  'id': (u['id'] ?? '').toString(),
                  'name': (u['username'] ?? 'Unknown').toString(),
                  'role': (u['role'] ?? '').toString(),
                })
            .toList();
      }
    } catch (e) {
      _memberCandidates = [];
      _error = _cleanError(e);
    }

    _isLoading = false;
    notifyListeners();
  }
}
