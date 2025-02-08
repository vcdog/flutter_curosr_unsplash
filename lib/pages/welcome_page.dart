import 'package:flutter/material.dart';
import '../models/unsplash_image.dart';
import '../services/unsplash_service.dart';
import '../services/preferences_service.dart';

class WelcomePage extends StatefulWidget {
  final PreferencesService preferencesService;

  const WelcomePage({
    Key? key,
    required this.preferencesService,
  }) : super(key: key);

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final UnsplashService _unsplashService = UnsplashService();
  UnsplashImage? _currentImage;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRandomImage();
  }

  Future<void> _loadRandomImage() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final image = await _unsplashService.getRandomPhoto();
      setState(() {
        _currentImage = image;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 背景图片
          _buildBackground(),

          // 内容层
          SafeArea(
            child: Column(
              children: [
                // 刷新按钮
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _loadRandomImage,
                    color: Colors.white,
                  ),
                ),

                const Spacer(),

                // 作者信息
                if (_currentImage != null)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Photo by ${_currentImage!.photographerName} on Unsplash',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),

                // 确认按钮
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      await widget.preferencesService.setWelcomeShown(true);
                      if (mounted) {
                        Navigator.of(context).pushReplacementNamed('/home');
                      }
                    },
                    child: const Text('开始使用'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null || _currentImage == null) {
      return Image.asset(
        'assets/default_background.jpg',
        fit: BoxFit.cover,
      );
    }

    return Image.network(
      _currentImage!.imageUrl,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const Center(child: CircularProgressIndicator());
      },
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(
          'assets/default_background.jpg',
          fit: BoxFit.cover,
        );
      },
    );
  }
}
