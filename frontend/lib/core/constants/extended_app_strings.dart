/// Extended App Strings for SENTRIX
/// Additional strings beyond the core app_strings.dart
class ExtendedAppStrings {
  // Error Messages
  static const String errorNetworkFailure = 'Network request failed. Please check your internet connection.';
  static const String errorServerError = 'Server error. Please try again later.';
  static const String errorUnauthorized = 'You are not authorized to access this resource.';
  static const String errorNotFound = 'Resource not found.';
  static const String errorTimeoutUploading = 'Upload timed out. Please try again.';
  static const String errorTimeoutDownloading = 'Download timed out. Please try again.';
  static const String errorInvalidCredentials = 'Invalid Member ID or password.';
  static const String errorAccountSuspended = 'Your account has been suspended.';
  static const String errorAccountNotApproved = 'Your account is pending approval.';
  static const String errorFaceNotRecognized = 'Face not recognized. Please try again.';
  static const String errorCameraPermission = 'Camera permission required for face authentication.';
  static const String errorNoInternetConnection = 'No internet connection. Please check your connectivity.';

  // Success Messages
  static const String successLoginComplete = 'Login successful.';
  static const String successLogoutComplete = 'Logged out successfully.';
  static const String successMessageSent = 'Message sent successfully.';
  static const String successGroupCreated = 'Group created successfully.';
  static const String successGroupUpdated = 'Group updated successfully.';
  static const String successGroupDeleted = 'Group deleted successfully.';
  static const String successMemberAdded = 'Member added to group.';
  static const String successMemberRemoved = 'Member removed from group.';
  static const String successQRGenerated = 'QR code generated successfully.';
  static const String successQRScanned = 'QR code scanned successfully.';
  static const String successProfileUpdated = 'Profile updated successfully.';
  static const String successSettingsSaved = 'Settings saved successfully.';
  static const String successNotificationSent = 'Notification sent successfully.';

  // Confirmation Messages
  static const String confirmDeleteMessage = 'Are you sure you want to delete this message?';
  static const String confirmDeleteChat = 'Are you sure you want to delete this chat?';
  static const String confirmDeleteGroup = 'Are you sure you want to delete this group?';
  static const String confirmLeaveGroup = 'Are you sure you want to leave this group?';
  static const String confirmRemoveMember = 'Are you sure you want to remove this member?';
  static const String confirmBlockUser = 'Are you sure you want to block this user?';
  static const String confirmUnblockUser = 'Are you sure you want to unblock this user?';
  static const String confirmLogout = 'Are you sure you want to sign out?';
  static const String confirmResetSettings = 'This will reset all settings to defaults. Continue?';

  // Dialog Titles
  static const String titleConfirmAction = 'Confirm Action';
  static const String titleWarning = 'Warning';
  static const String titleError = 'Error';
  static const String titleSuccess = 'Success';
  static const String titleInfo = 'Information';
  static const String titleInputRequired = 'Input Required';

  // Button Labels
  static const String btnOkay = 'Okay';
  static const String btnConfirm = 'Confirm';
  static const String btnCancel = 'Cancel';
  static const String btnDelete = 'Delete';
  static const String btnEdit = 'Edit';
  static const String btnSave = 'Save';
  static const String btnRetry = 'Retry';
  static const String btnTryAgain = 'Try Again';
  static const String btnGoBack = 'Go Back';
  static const String btnGoHome = 'Go Home';
  static const String btnSkip = 'Skip';
  static const String btnNext = 'Next';
  static const String btnPrevious = 'Previous';
  static const String btnClose = 'Close';
  static const String btnMore = 'More';

  // Feature-Specific Strings
  static const String qrExpiringSoon = 'Your QR code expires in 6 hours';
  static const String qrExpired = 'Your QR code has expired';
  static const String qrGenerating = 'Generating QR code...';
  static const String qrScanning = 'Scanning QR code...';
  static const String noPendingApprovals = 'No pending approvals';
  static const String noGroups = 'No groups. Create one to get started.';
  static const String noChats = 'No chats yet. Start a conversation.';
  static const String noNotifications = 'No notifications';
  static const String noResults = 'No results found';
  static const String noData = 'No data available';
  static const String loadingData = 'Loading data...';
  static const String syncingData = 'Syncing data...';

  // Date/Time Related
  static const String just_now = 'Just now';
  static const String today = 'Today';
  static const String yesterday = 'Yesterday';
  static const String this_week = 'This week';
  static const String this_month = 'This month';
  static const String this_year = 'This year';

  // Common Labels
  static const String labelEmail = 'Member ID';
  static const String labelPassword = 'Password';
  static const String labelName = 'Name';
  static const String labelPhone = 'Phone';
  static const String labelRole = 'Role';
  static const String labelStatus = 'Status';
  static const String labelCreatedAt = 'Created At';
  static const String labelUpdatedAt = 'Updated At';
  static const String labelMessage = 'Message';
  static const String labelSearchHint = 'Search...';
  static const String labelAreYouSure = 'Are you sure?';
  
  // Placeholder Texts
  static const String placeholderSearch = 'Search by name or Member ID...';
  static const String placeholderMessage = 'Type your message...';
  static const String placeholderGroupName = 'Enter group name...';
  static const String placeholderGroupDescription = 'Enter group description (optional)';
  static const String placeholderReason = 'Enter reason (optional)...';
  
  // Validation Messages
  static const String validateFieldRequired = 'This field is required';
  static const String validateEmailInvalid = 'Please enter a valid Member ID';
  static const String validatePasswordTooShort = 'Password must be at least 8 characters';
  static const String validatePasswordsDoNotMatch = 'Passwords do not match';
  static const String validatePhoneInvalid = 'Please enter a valid phone number';
  static const String validateNameTooShort = 'Name must be at least 2 characters';
  static const String validateGroupNameRequired = 'Group name is required';
  static const String validateMessageTooLong = 'Message is too long (max 1000 characters)';

  // Statistics/Metrics
  static const String statTotalUsers = 'Total Users';
  static const String statActiveUsers = 'Active Users';
  static const String statPendingApprovals = 'Pending Approvals';
  static const String statTotalGroups = 'Total Groups';
  static const String statTotalMessages = 'Total Messages';
  static const String statLastSync = 'Last Sync';
  static const String statOnlineNow = 'Online Now';
  static const String statSyncInProgress = 'Sync in progress...';
}
