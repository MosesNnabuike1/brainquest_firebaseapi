import 'package:flutter_svg/svg.dart';
import 'package:flutter/material.dart';

class FixedHeader extends StatelessWidget {
  final String studentName;
  final VoidCallback onProfileTap;
  final VoidCallback onSettingsTap;
  final VoidCallback onDrawerOpen;

  const FixedHeader({
    Key? key,
    required this.studentName,
    required this.onProfileTap,
    required this.onSettingsTap,
    required this.onDrawerOpen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Scaffold.of(context).openDrawer(),
            child: const CircleAvatar(
              radius: 24,
              backgroundColor: Color(0xFF181DB4),
              child: Icon(
                Icons.person,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: SvgPicture.asset(
                  'assets/icons/gear.svg',
                  width: 24,
                  height: 24,
                ),
                onPressed: onSettingsTap,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
