/// SENTRIX App Routes
/// Centralized route definitions for navigation
class AppRoutes {
  // ========== Auth Routes ==========
  static const String splash = '/splash';
  static const String login = '/login';
  static const String deviceVerify = '/device_verify';
  static const String faceAuth = '/face_auth';
  static const String pendingApproval = '/pending_approval';

  // ========== Main Routes ==========
  static const String home = '/home';
  static const String settings = '/settings';
  static const String profile = '/profile';

  // ========== Chat Routes ==========
  static const String chatList = '/chat_list';
  static const String chatScreen = '/chat_screen';

  // ========== Group Routes ==========
  static const String groupList = '/group_list';
  static const String groupChat = '/group_chat';
  static const String createGroup = '/create_group';

  // ========== QR Routes ==========
  static const String qrDisplay = '/qr_display';
  static const String qrScan = '/qr_scan';
  static const String uniqueCode = '/unique_code';

  // ========== Admin Routes ==========
  static const String adminDashboard = '/admin_dashboard';
  static const String authorityFaceScan = '/authority_face_scan';
  static const String managePersonnel = '/manage_personnel';
  static const String manageDependents = '/manage_dependents';
  static const String createOfficialGroup = '/create_official_group';
  static const String createFamilyGroup = '/create_family_group';

  // ========== Dependent Routes ==========
  static const String dependentHome = '/dependent_home';

  // ========== Error Routes ==========
  static const String notFound = '/not_found';
  static const String accessDenied = '/access_denied';

  // ========== All Routes List ==========
  static const List<String> allRoutes = [
    splash,
    login,
    deviceVerify,
    faceAuth,
    pendingApproval,
    home,
    chatList,
    chatScreen,
    groupList,
    groupChat,
    createGroup,
    qrDisplay,
    qrScan,
    uniqueCode,
    adminDashboard,
    authorityFaceScan,
    managePersonnel,
    manageDependents,
    createOfficialGroup,
    createFamilyGroup,
    dependentHome,
    settings,
    profile,
    notFound,
    accessDenied,
  ];
}
