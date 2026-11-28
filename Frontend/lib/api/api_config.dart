/// 서버 주소. 실행할 때 바꾸려면:
/// `flutter run --dart-define=API_BASE_URL=http://192.168.0.10:8000`
/// (안드로이드 에뮬레이터에서는 http://10.0.2.2:8000)
const apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:8000',
);
