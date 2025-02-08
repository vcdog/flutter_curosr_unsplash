class UnsplashImage {
  final String id;
  final String imageUrl;
  final String photographerName;
  final String photographerUrl;

  UnsplashImage({
    required this.id,
    required this.imageUrl,
    required this.photographerName,
    required this.photographerUrl,
  });

  factory UnsplashImage.fromJson(Map<String, dynamic> json) {
    return UnsplashImage(
      id: json['id'],
      imageUrl: json['urls']['regular'],
      photographerName: json['user']['name'],
      photographerUrl: json['user']['links']['html'],
    );
  }
}
