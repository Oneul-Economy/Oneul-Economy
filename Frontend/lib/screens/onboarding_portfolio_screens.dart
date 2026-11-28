import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../api/portfolio_api.dart';
import '../models/holding.dart';
import '../stores/portfolio_store.dart';
import '../theme/app_colors.dart';
import '../theme/app_fonts.dart';
import '../utils/number_format.dart';
import 'onboarding_auth_screens.dart';

/// 이미지를 고르고 인식 화면으로 넘긴다. 포트폴리오 탭의 '재첨부'에서도 쓴다.
Future<void> pickAndScanPortfolio(
  BuildContext context, {
  required bool onboarding,
  bool replace = false,
}) async {
  final XFile? file;
  try {
    file = await ImagePicker().pickImage(source: ImageSource.gallery);
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('이미지를 열지 못했어요.')));
    return;
  }
  if (file == null || !context.mounted) return;
  final route = MaterialPageRoute<void>(
    builder: (_) =>
        OnboardingPortfolioScanningScreen(image: file!, onboarding: onboarding),
  );
  if (replace) {
    Navigator.pushReplacement(context, route);
  } else {
    Navigator.push(context, route);
  }
}

/// 보유 종목 등록을 마쳤을 때: 온보딩이면 완료 화면, 아니면 첫 화면(탭)으로.
void _finishRegister(
  BuildContext context,
  List<Holding> holdings, {
  required bool onboarding,
}) {
  portfolioStore.setHoldings(holdings);
  if (onboarding) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const OnboardingCompleteScreen()),
    );
  } else {
    Navigator.popUntil(context, (r) => r.isFirst);
  }
}

/// 온보딩 06: 포트폴리오 첨부 (STEP 3/3)
///
/// [onboarding]이 false면 포트폴리오 탭에서 다시 올리는 경우라 단계 표시·건너뛰기를 숨긴다.
class OnboardingPortfolioUploadScreen extends StatelessWidget {
  const OnboardingPortfolioUploadScreen({super.key, this.onboarding = true});

  final bool onboarding;

  @override
  Widget build(BuildContext context) {
    void pick() => pickAndScanPortfolio(context, onboarding: onboarding);

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        backgroundColor: AppColors.paper,
        elevation: 0,
        foregroundColor: AppColors.ink,
        actions: [
          if (onboarding)
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const OnboardingCompleteScreen(),
                  ),
                );
              },
              child: Text(
                '건너뛰기',
                style: TextStyle(
                  fontFamily: AppFonts.sans,
                  color: AppColors.muted,
                  fontSize: 13,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (onboarding) ...[
                const OnboardingStepBar(step: 3),
                const SizedBox(height: 20),
                Text(
                  'STEP 3 / 3',
                  style: TextStyle(
                    fontFamily: AppFonts.sans,
                    color: AppColors.muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: 6),
              Text(
                '증권 앱 화면을\n캡처해서 올려주세요',
                style: TextStyle(
                  fontFamily: AppFonts.serif,
                  color: AppColors.ink,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '보유 종목과 수량을 자동으로 읽어서 등록해요.',
                style: TextStyle(
                  fontFamily: AppFonts.sans,
                  color: AppColors.muted,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 20),
              InkWell(
                onTap: pick,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 34),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.ink.withValues(alpha: 0.18),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.paper,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.upload_outlined,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '캡처 이미지 선택',
                        style: TextStyle(
                          fontFamily: AppFonts.sans,
                          color: AppColors.ink,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '한 장씩 올려주세요 · JPG, PNG',
                        style: TextStyle(
                          fontFamily: AppFonts.sans,
                          color: AppColors.muted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '이렇게 캡처해 주세요',
                      style: TextStyle(
                        fontFamily: AppFonts.sans,
                        color: AppColors.ink,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _GuideLine('01', '증권 앱에서 \'잔고\' 또는 \'보유 종목\' 화면 열기'),
                    const SizedBox(height: 6),
                    _GuideLine('02', '종목명 · 수량 · 평균단가가 보이게 캡처'),
                    const SizedBox(height: 6),
                    _GuideLine('03', '위 영역을 눌러 이미지 올리기'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.lock_outline, size: 14, color: AppColors.muted),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '이미지는 인식 후 바로 삭제돼요. 계좌번호는 저장하지 않아요.',
                      style: TextStyle(
                        fontFamily: AppFonts.sans,
                        color: AppColors.muted,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: pick,
                icon: const Icon(Icons.image_outlined, size: 18),
                label: Text(
                  '이미지 올리기',
                  style: TextStyle(
                    fontFamily: AppFonts.sans,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.ink,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OnboardingPortfolioResultScreen(
                          holdings: const [],
                          onboarding: onboarding,
                        ),
                      ),
                    );
                  },
                  child: Text(
                    '직접 입력할게요',
                    style: TextStyle(
                      fontFamily: AppFonts.sans,
                      color: AppColors.muted,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
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

class _GuideLine extends StatelessWidget {
  const _GuideLine(this.num, this.text);
  final String num;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          num,
          style: TextStyle(
            fontFamily: AppFonts.sans,
            color: AppColors.gold,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontFamily: AppFonts.sans,
              color: AppColors.ink,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

/// 온보딩 07: 이미지 인식 중. 고른 캡처를 서버로 보내고 결과를 기다린다.
class OnboardingPortfolioScanningScreen extends StatefulWidget {
  const OnboardingPortfolioScanningScreen({
    super.key,
    required this.image,
    this.onboarding = true,
  });

  final XFile image;
  final bool onboarding;

  @override
  State<OnboardingPortfolioScanningScreen> createState() =>
      _OnboardingPortfolioScanningScreenState();
}

class _OnboardingPortfolioScanningScreenState
    extends State<OnboardingPortfolioScanningScreen> {
  String? _error;

  @override
  void initState() {
    super.initState();
    _scan();
  }

  Future<void> _scan() async {
    setState(() => _error = null);
    try {
      final bytes = await widget.image.readAsBytes();
      final holdings = await scanPortfolio(
        bytes,
        fileName: widget.image.name,
        mimeType: imageMediaType(widget.image.name) == null
            ? widget.image.mimeType
            : null,
      );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => OnboardingPortfolioResultScreen(
            holdings: holdings,
            onboarding: widget.onboarding,
            scannedAt: DateTime.now(),
          ),
        ),
      );
    } on PortfolioScanException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) setState(() => _error = '이미지를 읽지 못했어요.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final failed = _error != null;
    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        backgroundColor: AppColors.paper,
        elevation: 0,
        foregroundColor: AppColors.ink,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.onboarding) const OnboardingStepBar(step: 3),
              const Spacer(),
              Center(
                child: Container(
                  width: 150,
                  height: 190,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: failed
                      ? const Icon(
                          Icons.image_not_supported_outlined,
                          size: 40,
                          color: AppColors.muted,
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(
                            4,
                            (_) => Container(
                              height: 14,
                              decoration: BoxDecoration(
                                color: AppColors.paper,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                failed ? '캡처를 읽지 못했어요' : '캡처 이미지를\n읽고 있어요',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppFonts.serif,
                  color: AppColors.ink,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                failed ? _error! : '종목명과 수량을 찾는 중이에요 · 10초 정도 걸려요',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppFonts.sans,
                  color: AppColors.muted,
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              if (!failed)
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Column(
                    children: [
                      _ScanStepRow('이미지 올리기', done: true),
                      Divider(height: 20),
                      _ScanStepRow('글자 읽고 종목 · 수량 맞춰보는 중…', done: false),
                    ],
                  ),
                ),
              const Spacer(),
              if (failed) ...[
                ElevatedButton(
                  onPressed: () => pickAndScanPortfolio(
                    context,
                    onboarding: widget.onboarding,
                    replace: true,
                  ),
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
                    '다른 이미지 고르기',
                    style: TextStyle(
                      fontFamily: AppFonts.sans,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: _scan,
                      child: Text(
                        '다시 시도',
                        style: TextStyle(
                          fontFamily: AppFonts.sans,
                          color: AppColors.muted,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OnboardingPortfolioResultScreen(
                            holdings: const [],
                            onboarding: widget.onboarding,
                          ),
                        ),
                      ),
                      child: Text(
                        '직접 입력할게요',
                        style: TextStyle(
                          fontFamily: AppFonts.sans,
                          color: AppColors.muted,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ScanStepRow extends StatelessWidget {
  const _ScanStepRow(this.label, {required this.done});
  final String label;
  final bool done;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          done ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 18,
          color: done ? AppColors.ink : AppColors.gold,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: AppFonts.sans,
              color: done ? AppColors.muted : AppColors.ink,
              fontSize: 13,
              fontWeight: done ? FontWeight.w500 : FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

/// 수정 중인 종목 한 줄 (입력칸 컨트롤러를 들고 있음).
class _HoldingDraft {
  _HoldingDraft(this.base)
    : name = TextEditingController(text: base?.stockName ?? ''),
      qty = TextEditingController(
        text: base?.quantity == null
            ? ''
            : formatNumber(base!.quantity!, decimals: 6),
      ),
      price = TextEditingController(
        text: base?.avgPrice == null
            ? ''
            : formatNumber(base!.avgPrice!, decimals: 6),
      );

  final Holding? base;
  final TextEditingController name;
  final TextEditingController qty;
  final TextEditingController price;

  bool get hasBlank => qty.text.trim().isEmpty || price.text.trim().isEmpty;

  /// 이름이 비었으면 null (저장하지 않음).
  Holding? toHolding() {
    final n = name.text.trim();
    if (n.isEmpty) return null;
    return Holding.edited(
      base,
      stockName: n,
      quantity: parseNumber(qty.text),
      avgPrice: parseNumber(price.text),
    );
  }

  void dispose() {
    name.dispose();
    qty.dispose();
    price.dispose();
  }
}

/// 온보딩 08: 인식 결과 확인. 틀린 값을 고치고 등록한다.
class OnboardingPortfolioResultScreen extends StatefulWidget {
  const OnboardingPortfolioResultScreen({
    super.key,
    required this.holdings,
    this.onboarding = true,
    this.scannedAt,
  });

  final List<Holding> holdings;
  final bool onboarding;

  /// 캡처를 인식한 시각. 직접 입력이면 null.
  final DateTime? scannedAt;

  @override
  State<OnboardingPortfolioResultScreen> createState() =>
      _OnboardingPortfolioResultScreenState();
}

class _OnboardingPortfolioResultScreenState
    extends State<OnboardingPortfolioResultScreen> {
  late final List<_HoldingDraft> _rows = widget.holdings
      .map(_HoldingDraft.new)
      .toList();

  @override
  void initState() {
    super.initState();
    if (_rows.isEmpty) _rows.add(_HoldingDraft(null));
  }

  @override
  void dispose() {
    for (final r in _rows) {
      r.dispose();
    }
    super.dispose();
  }

  void _submit() {
    final holdings = _rows.map((r) => r.toHolding()).whereType<Holding>();
    if (holdings.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('종목을 하나 이상 입력해 주세요.')));
      return;
    }
    _finishRegister(context, holdings.toList(), onboarding: widget.onboarding);
  }

  @override
  Widget build(BuildContext context) {
    final scanned = widget.scannedAt;
    final found = widget.holdings.length;
    final title = scanned == null
        ? '보유 종목을 입력해 주세요'
        : (found == 0 ? '종목을 찾지 못했어요' : '$found개 종목을 찾았어요');
    final hasBlank = _rows.any((r) => r.hasBlank);

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        backgroundColor: AppColors.paper,
        elevation: 0,
        foregroundColor: AppColors.ink,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                children: [
                  if (widget.onboarding) const OnboardingStepBar(step: 3),
                  const SizedBox(height: 20),
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: AppFonts.serif,
                      color: AppColors.ink,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    scanned != null && found == 0
                        ? '보유 종목 화면이 맞는지 확인하거나 직접 입력해 주세요.'
                        : '틀린 값이 있으면 눌러서 고쳐주세요.',
                    style: TextStyle(
                      fontFamily: AppFonts.sans,
                      color: AppColors.muted,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (scanned != null) ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.paper,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.image_outlined, size: 18),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '캡처 1장',
                                  style: TextStyle(
                                    fontFamily: AppFonts.sans,
                                    color: AppColors.ink,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  '${scanned.month}월 ${scanned.day}일 '
                                  '${scanned.hour.toString().padLeft(2, '0')}:'
                                  '${scanned.minute.toString().padLeft(2, '0')} 업로드',
                                  style: TextStyle(
                                    fontFamily: AppFonts.sans,
                                    color: AppColors.muted,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () => pickAndScanPortfolio(
                              context,
                              onboarding: widget.onboarding,
                              replace: true,
                            ),
                            child: Text(
                              '다시 올리기',
                              style: TextStyle(
                                fontFamily: AppFonts.sans,
                                color: AppColors.muted,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 16, 8, 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(flex: 4, child: _headerText('종목')),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 2,
                              child: _headerText('수량', right: true),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 3,
                              child: _headerText('평균 단가', right: true),
                            ),
                            const SizedBox(width: 32),
                          ],
                        ),
                        const SizedBox(height: 4),
                        for (final (i, r) in _rows.indexed)
                          _StockEditRow(
                            key: ObjectKey(r),
                            draft: r,
                            autofocus:
                                r.base == null &&
                                i == _rows.length - 1 &&
                                i > 0,
                            onChanged: () => setState(() {}),
                            onDelete: () {
                              final removed = _rows.removeAt(i);
                              setState(() {});
                              // 입력칸이 화면에서 빠진 뒤에 정리
                              WidgetsBinding.instance.addPostFrameCallback(
                                (_) => removed.dispose(),
                              );
                            },
                          ),
                        if (hasBlank) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 13,
                                color: AppColors.muted,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  '빈 칸은 캡처에서 읽지 못한 값이에요. 확인해 주세요',
                                  style: TextStyle(
                                    fontFamily: AppFonts.sans,
                                    color: AppColors.muted,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () =>
                        setState(() => _rows.add(_HoldingDraft(null))),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.ink,
                      side: BorderSide(
                        color: AppColors.ink.withValues(alpha: 0.2),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      '+ 빠진 종목 직접 추가',
                      style: TextStyle(
                        fontFamily: AppFonts.sans,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: ElevatedButton(
                onPressed: _submit,
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
                  '이대로 등록하기',
                  style: TextStyle(
                    fontFamily: AppFonts.sans,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _headerText(String text, {bool right = false}) {
  return Text(
    text,
    textAlign: right ? TextAlign.right : TextAlign.left,
    style: TextStyle(
      fontFamily: AppFonts.sans,
      color: AppColors.muted,
      fontSize: 11,
    ),
  );
}

class _StockEditRow extends StatelessWidget {
  const _StockEditRow({
    super.key,
    required this.draft,
    required this.onChanged,
    required this.onDelete,
    this.autofocus = false,
  });

  final _HoldingDraft draft;
  final VoidCallback onChanged;
  final VoidCallback onDelete;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final currency = draft.base?.currency ?? 'KRW';
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: _cell(
            draft.name,
            hint: '종목명',
            bold: true,
            autofocus: autofocus,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: _cell(draft.qty, hint: '수량', suffix: '주', number: true),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 3,
          child: _cell(
            draft.price,
            hint: '단가',
            suffix: currency == 'KRW' ? '원' : currency,
            number: true,
          ),
        ),
        IconButton(
          onPressed: onDelete,
          tooltip: '삭제',
          icon: const Icon(Icons.close, size: 16, color: AppColors.muted),
          constraints: const BoxConstraints.tightFor(width: 32, height: 32),
          padding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _cell(
    TextEditingController c, {
    required String hint,
    String? suffix,
    bool number = false,
    bool bold = false,
    bool autofocus = false,
  }) {
    final empty = c.text.trim().isEmpty;
    return TextField(
      controller: c,
      autofocus: autofocus,
      onChanged: (_) => onChanged(),
      textAlign: number ? TextAlign.right : TextAlign.left,
      keyboardType: number
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      style: TextStyle(
        fontFamily: AppFonts.sans,
        color: AppColors.ink,
        fontSize: 13,
        fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
      ),
      decoration: InputDecoration(
        isDense: true,
        hintText: hint,
        hintStyle: TextStyle(
          fontFamily: AppFonts.sans,
          color: AppColors.muted.withValues(alpha: 0.6),
          fontSize: 13,
        ),
        suffixText: empty ? null : suffix,
        suffixStyle: TextStyle(
          fontFamily: AppFonts.sans,
          color: AppColors.muted,
          fontSize: 12,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        border: InputBorder.none,
        filled: number && empty,
        fillColor: AppColors.paper,
      ),
    );
  }
}

/// 온보딩 09: 완료
class OnboardingCompleteScreen extends StatelessWidget {
  const OnboardingCompleteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: AppColors.ink,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '준비가 끝났어요,\n지민님',
                style: TextStyle(
                  fontFamily: AppFonts.serif,
                  color: AppColors.ink,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '내일 아침부터 내 종목 기준으로\n기사를 골라드릴게요.',
                style: TextStyle(
                  fontFamily: AppFonts.sans,
                  color: AppColors.muted,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const _SummaryRow('관심 종목', '삼성전자 외 3개'),
                    const Divider(height: 22),
                    const _SummaryRow('관심 키워드', '반도체 · 환율 · AI'),
                    const Divider(height: 22),
                    _SummaryRow('보유 종목', _holdingsSummary()),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.ink.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.notifications_none,
                      size: 16,
                      color: AppColors.muted,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '매일 아침 7시에 오늘의 브리핑을 보내드릴게요',
                      style: TextStyle(
                        fontFamily: AppFonts.sans,
                        color: AppColors.ink,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
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
                  '오늘의 경제 시작하기',
                  style: TextStyle(
                    fontFamily: AppFonts.sans,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
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

String _holdingsSummary() {
  if (portfolioStore.isEmpty) return '나중에 등록';
  final count = '${portfolioStore.holdings.length}개';
  final total = portfolioStore.totalKrw;
  return total == null ? count : '$count · ${formatMoney(total, 'KRW')}';
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: AppFonts.sans,
            color: AppColors.muted,
            fontSize: 13,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: AppFonts.sans,
            color: AppColors.ink,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
