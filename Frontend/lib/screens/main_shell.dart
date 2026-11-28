import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'article_tab_screen.dart';
import 'home_screen.dart';
import 'journal_screens.dart';
import 'my_profile_screens.dart';
import 'portfolio_screens.dart';

/// 하단 메뉴바(홈 / 기사 / 포트폴리오 / 일지 / MY)가 있는 앱의 뼈대.
///
/// 탭을 바꿔도 각 화면 상태(스크롤 위치 등)가 남도록 IndexedStack을 쓴다.
/// 본문·기사집 같은 하위 화면은 Navigator.push로 이 위에 덮어서 연다.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  static const _tabs = [
    (icon: Icons.home_outlined, selectedIcon: Icons.home_rounded, label: '홈'),
    (
      icon: Icons.article_outlined,
      selectedIcon: Icons.article_rounded,
      label: '기사',
    ),
    (
      icon: Icons.pie_chart_outline_rounded,
      selectedIcon: Icons.pie_chart_rounded,
      label: '포트폴리오',
    ),
    (
      icon: Icons.edit_outlined,
      selectedIcon: Icons.edit_rounded,
      label: '일지',
    ),
    (
      icon: Icons.person_outline_rounded,
      selectedIcon: Icons.person_rounded,
      label: 'MY',
    ),
  ];

  static const _screens = [
    HomeScreen(),
    ArticleTabScreen(),
    PortfolioTabScreen(),
    JournalTabScreen(),
    MyTabScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: _BottomBar(
        index: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}

/// Figma 교육형 홈 하단 탭 모양: 흰 배경, 위 구분선,
/// 선택된 탭만 진한 글자색 + 굵게, 나머지는 muted.
class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.index, required this.onTap});

  final int index;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE8E4DC))),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              for (var i = 0; i < _MainShellState._tabs.length; i++)
                Expanded(
                  child: _BottomBarItem(
                    tab: _MainShellState._tabs[i],
                    selected: i == index,
                    onTap: () => onTap(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomBarItem extends StatelessWidget {
  const _BottomBarItem({
    required this.tab,
    required this.selected,
    required this.onTap,
  });

  final ({IconData icon, IconData selectedIcon, String label}) tab;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.ink : AppColors.muted;
    return InkWell(
      onTap: onTap,
      child: Semantics(
        selected: selected,
        button: true,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(selected ? tab.selectedIcon : tab.icon, color: color),
            const SizedBox(height: 4),
            Text(
              tab.label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}