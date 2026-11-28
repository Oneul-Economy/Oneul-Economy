import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../models/holding.dart';
import 'api_config.dart';

class PortfolioScanException implements Exception {
  const PortfolioScanException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// 확장자로 이미지 형식을 맞춘다. 서버는 png, jpeg, webp, gif만 받는다.
String? imageMediaType(String fileName) {
  final ext = fileName.split('.').last.toLowerCase();
  return switch (ext) {
    'png' => 'image/png',
    'jpg' || 'jpeg' => 'image/jpeg',
    'webp' => 'image/webp',
    'gif' => 'image/gif',
    _ => null,
  };
}

/// 증권 앱 캡처를 서버(`POST /portfolio/scan`)로 보내 보유 종목을 받는다.
Future<List<Holding>> scanPortfolio(
  Uint8List bytes, {
  required String fileName,
  String? mimeType,
  http.Client? client,
}) async {
  final type = mimeType ?? imageMediaType(fileName);
  if (type == null) {
    throw const PortfolioScanException('PNG, JPG, WEBP, GIF 이미지만 올릴 수 있어요.');
  }
  final parts = type.split('/');
  final request =
      http.MultipartRequest('POST', Uri.parse('$apiBaseUrl/portfolio/scan'))
        ..files.add(
          http.MultipartFile.fromBytes(
            'image',
            bytes,
            filename: fileName,
            contentType: MediaType(parts[0], parts[1]),
          ),
        );

  final c = client ?? http.Client();
  final http.Response res;
  try {
    res = await c
        .send(request)
        .then(http.Response.fromStream)
        .timeout(const Duration(seconds: 90));
  } catch (_) {
    throw const PortfolioScanException('서버에 연결하지 못했어요. 잠시 후 다시 시도해 주세요.');
  } finally {
    if (client == null) c.close();
  }

  final body = utf8.decode(res.bodyBytes);
  if (res.statusCode != 200) {
    String? detail;
    try {
      detail = (jsonDecode(body) as Map<String, dynamic>)['detail'] as String?;
    } catch (_) {}
    throw PortfolioScanException(detail ?? '이미지를 읽지 못했어요 (${res.statusCode}).');
  }
  final json = jsonDecode(body) as Map<String, dynamic>;
  return (json['holdings'] as List)
      .map((e) => Holding.fromJson(e as Map<String, dynamic>))
      .toList();
}
