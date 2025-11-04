class Challenge {
  final String? id;
  final String firstWord;
  final String secondWord;
  final String thirdWord;
  final String fourthWord;
  final String fifthWord;
  final List<String> forbiddenWords;
  final String? prompt;
  final String? imageUrl;
  final String? answer;
  final bool? isResolved;
  final String? createdBy;

  Challenge({
    this.id,
    required this.firstWord,
    required this.secondWord,
    required this.thirdWord,
    required this.fourthWord,
    required this.fifthWord,
    required this.forbiddenWords,
    this.prompt,
    this.imageUrl,
    this.answer,
    this.isResolved,
    this.createdBy,
  });

  String get fullPhrase =>
      '$firstWord $secondWord $thirdWord $fourthWord $fifthWord';

  factory Challenge.fromJson(Map<String, dynamic> json) {
    // L'API retourne un id de type int, on le convertit en String
    final rawId = json['id'] ?? json['_id'] ?? json['challengeId'];
    final rawCreatedBy = json['createdBy'] ?? json['created_by'];
    return Challenge(
      id: rawId != null ? rawId.toString() : null,
      firstWord: json['first_word'] ?? '',
      secondWord: json['second_word'] ?? '',
      thirdWord: json['third_word'] ?? '',
      fourthWord: json['fourth_word'] ?? '',
      fifthWord: json['fifth_word'] ?? '',
      forbiddenWords: json['forbidden_words'] != null
          ? List<String>.from(json['forbidden_words'])
          : [],
      prompt: json['prompt'],
      imageUrl: json['imageUrl'] ?? json['image_url'],
      answer: json['answer'],
      isResolved: json['is_resolved'],
      createdBy: rawCreatedBy != null ? rawCreatedBy.toString() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'first_word': firstWord,
      'second_word': secondWord,
      'third_word': thirdWord,
      'fourth_word': fourthWord,
      'fifth_word': fifthWord,
      'forbidden_words': forbiddenWords,
      if (prompt != null) 'prompt': prompt,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (answer != null) 'answer': answer,
      if (isResolved != null) 'is_resolved': isResolved,
      if (createdBy != null) 'createdBy': createdBy,
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'first_word': firstWord,
      'second_word': secondWord,
      'third_word': thirdWord,
      'fourth_word': fourthWord,
      'fifth_word': fifthWord,
      'forbidden_words': forbiddenWords,
    };
  }
}
