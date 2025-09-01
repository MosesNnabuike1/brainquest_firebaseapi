import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CommonBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CommonBottomNav({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          backgroundColor: const Color(0xFF181DB4),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          type: BottomNavigationBarType.fixed,
          currentIndex: currentIndex,
          elevation: 0,
          enableFeedback: false,
          onTap: (index) {
            if (index != currentIndex) {
              onTap(index);
            }
          },
          items: [
            BottomNavigationBarItem(
              icon: currentIndex == 0
                  ? Image.asset(
                      'assets/icons/homefilled.png',
                      width: 24,
                      height: 24,
                      color: Colors.white,
                    )
                  : SvgPicture.asset(
                      'assets/icons/home1.svg',
                      width: 24,
                      height: 24,
                    ),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                currentIndex == 1
                    ? 'assets/icons/category_filled.svg'
                    : 'assets/icons/category.svg',
                width: 24,
                height: 24,
                colorFilter: currentIndex == 1
                    ? const ColorFilter.mode(Colors.white, BlendMode.srcIn)
                    : null,
              ),
              label: "Category",
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                currentIndex == 2
                    ? 'assets/icons/resultfilled.svg'
                    : 'assets/icons/result.svg',
                width: 24,
                height: 24,
                colorFilter: currentIndex == 2
                    ? const ColorFilter.mode(Colors.white, BlendMode.srcIn)
                    : null,
              ),
              label: "Result",
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                currentIndex == 3
                    ? 'assets/icons/personfilled.svg'
                    : 'assets/icons/user.svg',
                width: 24,
                height: 24,
                colorFilter: currentIndex == 3
                    ? const ColorFilter.mode(Colors.white, BlendMode.srcIn)
                    : null,
              ),
              label: "Profile",
            ),
          ],
        ),
      ),
    );
  }
}
