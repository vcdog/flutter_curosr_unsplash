import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/unsplash_image.dart';
import '../models/photo_category.dart';
import '../services/unsplash_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final UnsplashService _unsplashService = UnsplashService();
  final ScrollController _scrollController = ScrollController();
  final List<UnsplashImage> _images = [];
  final List<PhotoCategory> _categories = [];

  String? _selectedCategoryId;
  bool _isLoading = false;
  int _currentPage = 1;
  static const int _perPage = 30;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadInitialData();
  }

  /// 加载初始数据
  Future<void> _loadInitialData() async {
    try {
      final categories = await _unsplashService.getCategories();
      setState(() {
        _categories.clear();
        _categories.add(const PhotoCategory(id: '', name: '全部'));
        _categories.addAll(categories);
      });
      await _loadImages(refresh: true);
    } catch (e) {
      print('Error loading initial data: $e');
      _showError('加载失败');
    }
  }

  /// 加载图片
  /// [refresh] 是否刷新列表
  Future<void> _loadImages({bool refresh = false}) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      if (refresh) {
        _currentPage = 1;
        _images.clear();
      }
    });

    try {
      final newImages = await _unsplashService.getPhotos(
        page: _currentPage,
        perPage: _perPage,
        categoryId: _selectedCategoryId,
      );

      setState(() {
        _images.addAll(newImages);
        _currentPage++;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading images: $e');
      setState(() {
        _isLoading = false;
      });
      _showError('加载图片失败');
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadImages();
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('壁纸工具', style: TextStyle(color: Colors.black87)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildCategoryList(),
          Expanded(child: _buildImageGrid()),
        ],
      ),
    );
  }

  Widget _buildCategoryList() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category.id == _selectedCategoryId;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(category.name),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategoryId = selected ? category.id : null;
                });
                _loadImages(refresh: true);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildImageGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = (constraints.maxWidth / 150).floor();
        return RefreshIndicator(
          onRefresh: () => _loadImages(refresh: true),
          child: GridView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(8),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: 1,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: _images.length + (_isLoading ? crossAxisCount : 0),
            itemBuilder: (context, index) {
              if (index >= _images.length) {
                return const Center(child: CircularProgressIndicator());
              }

              final image = _images[index];
              return CachedNetworkImage(
                imageUrl: image.imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.error),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
