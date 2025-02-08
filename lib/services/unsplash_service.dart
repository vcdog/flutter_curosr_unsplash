import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/unsplash_image.dart';

class UnsplashService {
  static const String _baseUrl = 'https://api.unsplash.com';
  static const String _accessKey = 'YOUR_ACCESS_KEY'; // 请替换成您的access key

  /// 获取随机图片
  /// 返回 UnsplashImage 对象，包含图片信息
  /// 如果发生错误，会抛出异常
  Future<UnsplashImage> getRandomPhoto() async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/photos/random?orientation=landscape&w=1920&h=1080',
        ),
        headers: {'Authorization': 'Client-ID $_accessKey'},
      );

      if (response.statusCode == 200) {
        return UnsplashImage.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load image');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
