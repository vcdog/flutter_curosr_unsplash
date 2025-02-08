import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/unsplash_image.dart';
import '../models/photo_category.dart';
import 'dart:async';

class UnsplashApiException implements Exception {
  final String message;
  final int? statusCode;

  UnsplashApiException(this.message, {this.statusCode});

  @override
  String toString() =>
      'UnsplashApiException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

class UnsplashService {
  static const String _baseUrl = 'https://api.unsplash.com';
  static const String _accessKey = '你的access key';

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
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return UnsplashImage.fromJson(json.decode(response.body));
      } else if (response.statusCode == 401) {
        throw UnsplashApiException('Unauthorized: Invalid access key',
            statusCode: response.statusCode);
      } else {
        throw UnsplashApiException('Failed to load image',
            statusCode: response.statusCode);
      }
    } on TimeoutException {
      throw UnsplashApiException('Connection timeout');
    } catch (e) {
      throw UnsplashApiException('Network error: $e');
    }
  }

  /// 获取图片列表
  /// [page] 页码，从1开始
  /// [perPage] 每页数量
  /// [categoryId] 分类ID，可选
  /// 返回 List<UnsplashImage>
  Future<List<UnsplashImage>> getPhotos({
    required int page,
    required int perPage,
    String? categoryId,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'per_page': perPage.toString(),
        'w': '200',
        'h': '200',
      };

      if (categoryId != null && categoryId.isNotEmpty) {
        queryParams['collections'] = categoryId;
      }

      final uri =
          Uri.parse('$_baseUrl/photos').replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {'Authorization': 'Client-ID $_accessKey'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => UnsplashImage.fromJson(json)).toList();
      } else {
        print(
            'Error fetching photos: ${response.statusCode} - ${response.body}');
        throw UnsplashApiException('Failed to load images',
            statusCode: response.statusCode);
      }
    } catch (e) {
      print('Error in getPhotos: $e');
      rethrow;
    }
  }

  /// 获取分类列表
  /// 返回 List<PhotoCategory>
  Future<List<PhotoCategory>> getCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/collections'),
        headers: {'Authorization': 'Client-ID $_accessKey'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data
            .map((json) => PhotoCategory(
                  id: json['id'].toString(),
                  name: json['title'],
                ))
            .toList();
      } else {
        print(
            'Error fetching categories: ${response.statusCode} - ${response.body}');
        throw UnsplashApiException('Failed to load categories');
      }
    } catch (e) {
      print('Error in getCategories: $e');
      rethrow;
    }
  }
}
