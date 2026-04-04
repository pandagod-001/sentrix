import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';

/// Custom Tab Bar Widget
class CustomTabBar extends StatefulWidget {
  final List<String> tabs;
  final ValueChanged<int> onTabChanged;
  final int initialIndex;
  final ScrollPhysics? scrollPhysics;

  const CustomTabBar({
    Key? key,
    required this.tabs,
    required this.onTabChanged,
    this.initialIndex = 0,
    this.scrollPhysics,
  }) : super(key: key);

  @override
  State<CustomTabBar> createState() => _CustomTabBarState();
}

class _CustomTabBarState extends State<CustomTabBar> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: widget.scrollPhysics ?? const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 0),
        itemCount: widget.tabs.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedIndex = index;
              });
              widget.onTabChanged(index);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isSelected
                        ? AppColors.accentBlue
                        : Colors.transparent,
                    width: 3,
                  ),
                ),
              ),
              child: Text(
                widget.tabs[index],
                style: isSelected
                    ? AppTextStyles.titleSmall.copyWith(
                        color: AppColors.accentBlue,
                      )
                    : AppTextStyles.titleSmall.copyWith(
                        color: AppColors.secondary,
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Segmented Tab Bar (alternative)
class SegmentedTabBar extends StatefulWidget {
  final List<String> tabs;
  final ValueChanged<int> onTabChanged;
  final int initialIndex;

  const SegmentedTabBar({
    Key? key,
    required this.tabs,
    required this.onTabChanged,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  State<SegmentedTabBar> createState() => _SegmentedTabBarState();
}

class _SegmentedTabBarState extends State<SegmentedTabBar> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: List.generate(
          widget.tabs.length,
          (index) {
            final isSelected = _selectedIndex == index;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedIndex = index;
                  });
                  widget.onTabChanged(index);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.card : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      widget.tabs[index],
                      style: isSelected
                          ? AppTextStyles.titleSmall.copyWith(
                              color: AppColors.accentBlue,
                            )
                          : AppTextStyles.titleSmall.copyWith(
                              color: AppColors.secondary,
                            ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
