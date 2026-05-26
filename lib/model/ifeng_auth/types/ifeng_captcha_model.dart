class IfengCaptchaModel {
  const IfengCaptchaModel({
    required this.id,
    required this.imageUrl,
    required this.words,
  });

  final String id;
  final String imageUrl;
  final String words;

  bool get isValid {
    return id.trim().isNotEmpty &&
        imageUrl.trim().isNotEmpty &&
        words.trim().isNotEmpty;
  }

  factory IfengCaptchaModel.fromJson(Map<String, dynamic> json) {
    return IfengCaptchaModel(
      id: json['id']?.toString() ?? '',
      imageUrl: json['image']?.toString() ?? '',
      words: json['words']?.toString() ?? '',
    );
  }
}
