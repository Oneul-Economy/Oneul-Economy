import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_fonts.dart';
import 'onboarding_auth_screens.dart';

/// MY · 로그인 화면
class MyTabScreen extends StatefulWidget {
  const MyTabScreen({super.key});

  @override
  State<MyTabScreen> createState() => _MyTabScreenState();
}

class _MyTabScreenState extends State<MyTabScreen> {
  bool _isLoggedIn = true;

  @override
  Widget build(BuildContext context) {
    if (!_isLoggedIn) {
      return MyGuestScreen(
        onLoginDemo: () => setState(() => _isLoggedIn = true),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.paper,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          children: [
            // 프로필 헤더
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileEditScreen()),
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.ink.withValues(alpha: 0.08),
                    child: Text(
                      '지',
                      style: TextStyle(
                        fontFamily: AppFonts.serif,
                        color: AppColors.ink,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '김지민',
                          style: TextStyle(
                            fontFamily: AppFonts.serif,
                            color: AppColors.ink,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '관심 종목 4 · 관심 키워드 3',
                          style: TextStyle(
                            fontFamily: AppFonts.sans,
                            color: AppColors.muted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: AppColors.muted),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Divider(color: AppColors.ink.withValues(alpha: 0.12), height: 1),
            const SizedBox(height: 18),

            // 활동 통계 카드
            Container(
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border:
                    Border.all(color: AppColors.ink.withValues(alpha: 0.06)),
              ),
              child: const Row(
                children: [
                  Expanded(child: _StatItem('48', '읽은 기사')),
                  _VerticalLine(),
                  Expanded(child: _StatItem('31', '푼 퀴즈')),
                  _VerticalLine(),
                  Expanded(child: _StatItem('58', '쓴 일지')),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 내가 모은 것
            Text(
              '내가 모은 것',
              style: TextStyle(
                fontFamily: AppFonts.sans,
                color: AppColors.ink,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            _CollectionCard(
              icon: Icons.article_outlined,
              title: '기사집',
              count: '12개',
              onTap: () {},
            ),
            const SizedBox(height: 10),
            _CollectionCard(
              icon: Icons.menu_book_outlined,
              title: '용어집',
              count: '23개',
              onTap: () {},
            ),
            const SizedBox(height: 10),
            _CollectionCard(
              icon: Icons.help_outline,
              title: '퀴즈집',
              count: '31개',
              onTap: () {},
            ),
            const SizedBox(height: 22),

            // 설정 메뉴
            _MenuRow('알림 설정', onTap: () {}),
            _MenuRow('고객센터', onTap: () {}),
            _MenuRow(
              '로그아웃',
              onTap: () => setState(() => _isLoggedIn = false),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem(this.value, this.label);
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontFamily: AppFonts.serif,
            color: AppColors.ink,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontFamily: AppFonts.sans,
            color: AppColors.muted,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _VerticalLine extends StatelessWidget {
  const _VerticalLine();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 28,
      color: AppColors.ink.withValues(alpha: 0.1),
    );
  }
}

class _CollectionCard extends StatelessWidget {
  const _CollectionCard({
    required this.icon,
    required this.title,
    required this.count,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.ink.withValues(alpha: 0.06)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.ink),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontFamily: AppFonts.sans,
                color: AppColors.ink,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            Text(
              count,
              style: TextStyle(
                fontFamily: AppFonts.sans,
                color: AppColors.muted,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, size: 18, color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow(this.label, {required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: AppFonts.sans,
                color: AppColors.ink,
                fontSize: 13,
              ),
            ),
            Icon(Icons.chevron_right, size: 18, color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}

/// MY · 비로그인 화면
class MyGuestScreen extends StatelessWidget {
  const MyGuestScreen({super.key, this.onLoginDemo});
  final VoidCallback? onLoginDemo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.ink.withValues(alpha: 0.08),
                  child: Icon(Icons.person_outline,
                      size: 28, color: AppColors.muted),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                '로그인하고\n나만의 경제 노트를 만들어요',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppFonts.serif,
                  color: AppColors.ink,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '나만의 투자 포트폴리오를 구성하고\n기사, 용어, 퀴즈, 일지를 차곡차곡 쌓아요.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppFonts.sans,
                  color: AppColors.muted,
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (onLoginDemo != null) {
                    onLoginDemo!();
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EmailLoginScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.ink,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  '로그인',
                  style: TextStyle(
                    fontFamily: AppFonts.sans,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SignUpScreen()),
                    );
                  },
                  child: Text(
                    '회원가입',
                    style: TextStyle(
                      fontFamily: AppFonts.sans,
                      color: AppColors.muted,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 프로필 편집 화면
class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _nameController = TextEditingController(text: '김지민');
  final _ageController = TextEditingController(text: '28');
  String _selectedIncome = '3천~5천만원';
  final List<String> _stocks = ['삼성전자', 'SK하이닉스', '현대차', 'NAVER'];
  final List<String> _keywords = ['#반도체', '#환율', '#AI'];

  static const _incomes = [
    '3천만원 미만',
    '3천~5천만원',
    '5천~7천만원',
    '7천만~1억원',
    '1억원 이상',
    '밝히지 않을래요',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        backgroundColor: AppColors.paper,
        elevation: 0,
        foregroundColor: AppColors.ink,
        centerTitle: true,
        title: Text(
          '프로필',
          style: TextStyle(
            fontFamily: AppFonts.sans,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '저장',
              style: TextStyle(
                fontFamily: AppFonts.sans,
                color: AppColors.ink,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 34,
                    backgroundColor: AppColors.ink.withValues(alpha: 0.08),
                    child: Text(
                      '지',
                      style: TextStyle(
                        fontFamily: AppFonts.serif,
                        color: AppColors.ink,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: AppColors.ink,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.photo_camera_outlined,
                        size: 13,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                'jimin@gmail.com · Google 로그인',
                style: TextStyle(
                  fontFamily: AppFonts.sans,
                  color: AppColors.muted,
                  fontSize: 11,
                ),
              ),
            ),
            const SizedBox(height: 24),

            Text(
              '기본 정보',
              style: TextStyle(
                fontFamily: AppFonts.sans,
                color: AppColors.ink,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            _profileLabel('이름'),
            const SizedBox(height: 6),
            TextField(
              controller: _nameController,
              decoration: _profileInput(),
            ),
            const SizedBox(height: 14),
            _profileLabel('나이'),
            const SizedBox(height: 6),
            TextField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              decoration: _profileInput(suffixText: '세'),
            ),
            const SizedBox(height: 16),
            _profileLabel('연 수입'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _incomes.map((inc) {
                final selected = inc == _selectedIncome;
                return ChoiceChip(
                  label: Text(inc),
                  selected: selected,
                  onSelected: (_) => setState(() => _selectedIncome = inc),
                  selectedColor: AppColors.ink,
                  backgroundColor: Colors.white,
                  showCheckmark: false,
                  labelStyle: TextStyle(
                    fontFamily: AppFonts.sans,
                    color: selected ? Colors.white : AppColors.ink,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // 관심 종목
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '관심 종목',
                  style: TextStyle(
                    fontFamily: AppFonts.sans,
                    color: AppColors.ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '기사 추천 기준이 돼요',
                  style: TextStyle(
                    fontFamily: AppFonts.sans,
                    color: AppColors.muted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ..._stocks.map(
                  (s) => Chip(
                    label: Text(s),
                    backgroundColor: Colors.white,
                    deleteIcon: const Icon(Icons.close, size: 14),
                    onDeleted: () => setState(() => _stocks.remove(s)),
                  ),
                ),
                ActionChip(
                  label: const Text('+ 종목 추가'),
                  backgroundColor: AppColors.paper,
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 22),

            // 관심 키워드
            Text(
              '관심 키워드',
              style: TextStyle(
                fontFamily: AppFonts.sans,
                color: AppColors.ink,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ..._keywords.map(
                  (k) => Chip(
                    label: Text(k),
                    backgroundColor: Colors.white,
                    deleteIcon: const Icon(Icons.close, size: 14),
                    onDeleted: () => setState(() => _keywords.remove(k)),
                  ),
                ),
                ActionChip(
                  label: const Text('+ 키워드 추가'),
                  backgroundColor: AppColors.paper,
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Widget _profileLabel(String text) {
  return Text(
    text,
    style: TextStyle(
      fontFamily: AppFonts.sans,
      color: AppColors.muted,
      fontSize: 12,
    ),
  );
}

InputDecoration _profileInput({String? suffixText}) {
  return InputDecoration(
    filled: true,
    fillColor: Colors.white,
    suffixText: suffixText,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.ink.withValues(alpha: 0.12)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.ink, width: 1.4),
    ),
  );
}