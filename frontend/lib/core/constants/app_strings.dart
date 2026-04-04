/// App Strings
class AppStrings {
  // ========== App Info ==========
  static const String appName = 'VYRA';
  static const String appSubtitle = 'Secure Identity System';

  // ========== Auth Strings ==========
  static const String splashTitle = 'VYRA';
  static const String splashSubtitle = 'Secure Identity System';

  static const String loginTitle = 'VYRA';
  static const String loginSubtitle = 'Secure Identity System';
  static const String emailLabel = 'Member ID';
  static const String emailHint = 'Enter your Member ID';
  static const String passwordLabel = 'Password';
  static const String passwordHint = 'Enter your password';
  static const String loginButton = 'Sign In with Member ID';
  static const String forgotPassword = 'Forgot Password?';
  static const String quickLoginPersonnel = 'Login as Personnel';
  static const String quickLoginDependent = 'Login as Dependent';
  static const String quickLoginAdmin = 'Login as Admin';

  static const String deviceVerifyTitle = 'Verify Device';
  static const String deviceVerifySubtitle = 'This appears to be a new device';
  static const String deviceCode = 'Device Code: SEN-8392-XY1Z';
  static const String verifyButton = 'Verify Device';
  static const String verifyingDevice = 'Verifying...';

  static const String faceAuthTitle = 'Face Authentication';
  static const String faceAuthSubtitle = 'Align your face in the frame';
  static const String scanFaceButton = 'Scan Face';
  static const String scanningFace = 'Scanning...';
  static const String faceRecognized = 'Face Recognized!';

  static const String pendingApprovalTitle = 'Awaiting Approval';
  static const String pendingApprovalSubtitle =
      'Your account is being verified by administrators';
  static const String pendingApprovalMessage =
      'You will be notified once your access is approved.';
  static const String checkingApproval = 'Checking approval status...';

  // ========== Home Strings ==========
  static const String homeGreeting = 'Welcome';
  static const String homeSubtitle = 'You have 5 new messages';
  static const String homeStatsOnline = 'Online Users';
  static const String homeStatsChats = 'Recent Chats';
  static const String homeRecentChats = 'Recent Conversations';
  static const String homeViewAll = 'View All';
  static const String homeQuickActions = 'Quick Actions';
  static const String homeScanQR = 'Scan QR';
  static const String homeGenerateQR = 'Generate QR';

  // ========== Chat Strings ==========
  static const String chatListTitle = 'Messages';
  static const String chatEmpty = 'No conversations yet';
  static const String chatSearchHint = 'Search conversations...';
  static const String chatTyping = 'is typing...';
  static const String chatOnline = 'Online';
  static const String chatOffline = 'Offline';
  static const String chatYou = 'You';
  static const String messageInputHint = 'Type a message...';
  static const String messageSendButton = 'Send';

  // ========== Groups Strings ==========
  static const String groupListTitle = 'Groups';
  static const String groupEmpty = 'No groups yet';
  static const String groupCreateButton = 'Create Group';
  static const String groupCreateTitle = 'Create New Group';
  static const String groupName = 'Group Name';
  static const String groupDescription = 'Description (optional)';
  static const String groupMembers = 'Members';
  static const String groupSelectMembers = 'Select members';
  static const String groupCreateConfirm = 'Create';

  // ========== QR Strings ==========
  static const String qrDisplayTitle = 'My QR Code';
  static const String qrScanTitle = 'Scan QR Code';
  static const String qrUniqueCodeTitle = 'Unique Code';
  static const String qrCode = 'QR Code';
  static const String qrPersonalCode = 'Personal Code';
  static const String qrCopyButton = 'Copy Code';
  static const String qrShareButton = 'Share';
  static const String qrRefreshButton = 'Regenerate';
  static const String qrScanButton = 'Scan QR';
  static const String qrScannedCode = 'Scanned Code';
  static const String qrEnterCode = 'Enter Code Manually';

  // ========== Admin Strings ==========
  static const String adminDashboardTitle = 'Authority Dashboard';
  static const String adminPersonnelTitle = 'Manage Personnel';
  static const String adminDependentsTitle = 'Manage Dependents';
  static const String adminCreateGroupTitle = 'Create Group';
  static const String adminCreateOfficialGroup = 'Official Group';
  static const String adminCreateFamilyGroup = 'Family Group';
  static const String adminApprovals = 'Pending Approvals';
  static const String adminStats = 'Statistics';
  static const String adminApproveButton = 'Approve';
  static const String adminRejectButton = 'Reject';
  static const String adminTotalUsers = 'Total Users';
  static const String adminTotalGroups = 'Total Groups';
  static const String adminPendingApprovals = 'Pending Approvals';

  // ========== Settings Strings ==========
  static const String settingsTitle = 'Settings';
  static const String settingsProfile = 'Profile';
  static const String settingsPrivacy = 'Privacy';
  static const String settingsNotifications = 'Notifications';
  static const String settingsTheme = 'Theme';
  static const String settingsAbout = 'About';
  static const String settingsVersion = 'Version 1.0.0';

  // ========== Error Strings ==========
  static const String errorNotFound = 'Page Not Found';
  static const String errorAccessDenied = 'Access Denied';
  static const String errorAccessDeniedMessage =
      'Your account has limited access to this feature';
  static const String errorTryAgain = 'Try Again';
  static const String errorGoHome = 'Go Home';

  // ========== Generic Strings ==========
  static const String loading = 'Loading...';
  static const String retryButton = 'Retry';
  static const String cancelButton = 'Cancel';
  static const String okButton = 'OK';
  static const String deleteButton = 'Delete';
  static const String editButton = 'Edit';
  static const String saveButton = 'Save';
  static const String backButton = 'Back';

  // ========== Demo Data ==========
  static const List<String> sampleUserNames = [
    'Raj Kumar',
    'Priya Singh',
    'Amit Patel',
    'Neha Sharma',
    'Arjun Rao',
    'Anjali Verma',
    'Rohan Mishra',
    'Sophia Chen',
    'Marcus Johnson',
    'Elena Rodriguez',
  ];

  static const List<String> sampleChatMessages = [
    'Hey, how are you?',
    'Did you complete the report?',
    'Let me know when you\'re available',
    'Thanks for the update',
    'See you tomorrow',
    'Can we reschedule the meeting?',
    'Perfect, thanks!',
    'Just checking in',
    'Need your approval on this',
    'All set for the operation',
  ];

  static const List<String> sampleGroupNames = [
    'Operations Team Alpha',
    'Medical Support Unit',
    'Communications Hub',
    'Field Division A',
    'Command Center',
    'Supply Chain Team',
    'Family Group - Kumar',
    'Logistics Team',
  ];

  static const List<String> userStatuses = [
    'Online',
    'Offline',
    'Away',
    'Busy',
  ];

  static const List<Map<String, String>> samplePersonnelList = [
    {'name': 'Raj Kumar', 'role': 'Officer', 'status': 'Online'},
    {'name': 'Priya Singh', 'role': 'Analyst', 'status': 'Online'},
    {'name': 'Amit Patel', 'role': 'Manager', 'status': 'Offline'},
    {'name': 'Neha Sharma', 'role': 'Coordinator', 'status': 'Online'},
    {'name': 'Arjun Rao', 'role': 'Specialist', 'status': 'Away'},
    {'name': 'Anjali Verma', 'role': 'Officer', 'status': 'Online'},
    {'name': 'Rohan Mishra', 'role': 'Technician', 'status': 'Offline'},
    {'name': 'Sophia Chen', 'role': 'Analyst', 'status': 'Online'},
  ];

  static const List<Map<String, String>> sampleApprovalRequests = [
    {'name': 'John Smith', 'role': 'personnel', 'date': '2 hours ago'},
    {'name': 'Sarah Wilson', 'role': 'dependent', 'date': '5 hours ago'},
    {'name': 'Mike Johnson', 'role': 'personnel', 'date': '1 day ago'},
    {'name': 'Emma Davis', 'role': 'dependent', 'date': '2 days ago'},
    {'name': 'Alex Brown', 'role': 'personnel', 'date': '3 days ago'},
  ];
}
