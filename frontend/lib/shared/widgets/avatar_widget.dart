import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/text_styles.dart';

/// Avatar Widget - Displays user avatar with initials or image
class AvatarWidget extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final double size;
  final Color? backgroundColor;
  final Color? textColor;
  final bool showOnlineBadge;
  final bool isOnline;

  const AvatarWidget({
    Key? key,
    required this.name,
    this.imageUrl,
    this.size = 48,
    this.backgroundColor,
    this.textColor = Colors.white,
    this.showOnlineBadge = false,
    this.isOnline = false,
  }) : super(key: key);

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '?';
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  Color _getBackgroundColor() {
    if (backgroundColor != null) return backgroundColor!;

    // Generate color based on name hash
    final hash = name.hashCode;
    final colors = [
      Colors.blue,
      Colors.purple,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
    ];
    return colors[hash.abs() % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _getBackgroundColor(),
            image: imageUrl != null
                ? DecorationImage(
                    image: NetworkImage(imageUrl!),
                    fit: BoxFit.cover,
                  )
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: imageUrl == null
              ? Center(
                  child: Text(
                    _getInitials(name),
                    style: TextStyle(
                      color: textColor,
                      fontSize: size * 0.4,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : null,
        ),
        if (showOnlineBadge)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: size * 0.35,
              height: size * 0.35,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isOnline ? Colors.green : AppColors.muted,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Large Avatar for profile screens
class LargeAvatarWidget extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final double size;
  final VoidCallback? onTap;

  const LargeAvatarWidget({
    Key? key,
    required this.name,
    this.imageUrl,
    this.size = 120,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: AppColors.softShadow,
        ),
        child: AvatarWidget(
          name: name,
          imageUrl: imageUrl,
          size: size,
          textColor: Colors.white,
        ),
      ),
    );
  }
}

/// Avatar List Item (for people lists)
class AvatarListItem extends StatelessWidget {
  final String name;
  final String? subtitle;
  final String? imageUrl;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool showOnlineBadge;
  final bool isOnline;

  const AvatarListItem({
    Key? key,
    required this.name,
    this.subtitle,
    this.imageUrl,
    this.onTap,
    this.trailing,
    this.showOnlineBadge = false,
    this.isOnline = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: AvatarWidget(
        name: name,
        imageUrl: imageUrl,
        size: 48,
        showOnlineBadge: showOnlineBadge,
        isOnline: isOnline,
      ),
      title: Text(name, style: AppTextStyles.titleSmall),
      subtitle: subtitle != null
          ? Text(subtitle!, style: AppTextStyles.bodySecondary)
          : null,
      trailing: trailing,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }
}
