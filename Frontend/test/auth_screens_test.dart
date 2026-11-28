import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oneul_economy/screens/onboarding_auth_screens.dart';

bool _enabled(WidgetTester tester, String label) =>
    tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, label)).onPressed != null;

void main() {
  testWidgets('로그인: 빈칸이면 버튼이 꺼져 있고, 이메일 형식이 틀리면 오류가 보인다', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: EmailLoginScreen()));
    expect(_enabled(tester, '로그인'), isFalse);

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'not-an-email');
    await tester.enterText(fields.at(1), 'pw');
    await tester.pump();
    expect(_enabled(tester, '로그인'), isTrue);

    await tester.tap(find.widgetWithText(ElevatedButton, '로그인'));
    await tester.pump();
    expect(find.textContaining('이메일 형식을 확인해 주세요'), findsOneWidget);
  });

  testWidgets('회원가입: 규칙·일치·필수 약관을 모두 채워야 버튼이 켜진다', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SignUpScreen()));
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'jimin@gmail.com');
    await tester.enterText(fields.at(1), 'abcdefgh'); // 숫자 없음
    await tester.enterText(fields.at(2), 'abcdefgh');
    await tester.pump();
    expect(_enabled(tester, '가입하고 계속하기'), isFalse);

    await tester.enterText(fields.at(1), 'abcd1234');
    await tester.pump();
    expect(find.text('비밀번호가 일치하지 않아요'), findsOneWidget);

    await tester.enterText(fields.at(2), 'abcd1234');
    await tester.pump();
    expect(find.text('비밀번호가 일치해요'), findsOneWidget);
    expect(_enabled(tester, '가입하고 계속하기'), isFalse); // 약관 동의 전

    await tester.ensureVisible(find.text('전체 동의'));
    await tester.tap(find.text('전체 동의'));
    await tester.pump();
    expect(_enabled(tester, '가입하고 계속하기'), isTrue);
  });
}
