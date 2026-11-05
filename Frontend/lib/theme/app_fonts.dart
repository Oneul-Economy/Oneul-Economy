/// 앱에 넣어 둔 폰트 (pubspec.yaml `fonts:`).
///
/// 원본 Noto 폰트는 한 굵기당 6~14MB라 웹에서 늦게 뜨거나 아예 안 떠서,
/// 자주 쓰는 한글 2,350자 + 영문·숫자·기호만 남긴 subset 파일을 쓴다.
/// 목록에 없는 글자는 기본 폰트로 표시된다.
class AppFonts {
  AppFonts._();

  /// 본문·라벨 (Regular 400, SemiBold 600, Bold 700)
  static const sans = 'NotoSansKR';

  /// 제목·번호 (Bold 700)
  static const serif = 'NotoSerifKR';
}
