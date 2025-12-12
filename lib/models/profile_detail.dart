class ProfileDetail {
  const ProfileDetail({
    required this.lookingFor,
    required this.languages,
    required this.interests,
    required this.typeName,
    required this.typeStatus,
    required this.typeSummary,
    required this.cognitiveScores,
  });

  final List<String> lookingFor;
  final List<String> languages;
  final List<String> interests;
  final String typeName;
  final String typeStatus;
  final String typeSummary;
  final Map<String, String> cognitiveScores;
}

