class Verse {
  final int id;
  final String arabic;
  final String? translation;

  Verse({required this.id, required this.arabic, this.translation});

  factory Verse.fromJson(Map<String, dynamic> json) {
    return Verse(
      id: json['id'] as int,
      arabic: json['text'] as String,
      translation: json['translation'] as String?,
    );
  }
}
