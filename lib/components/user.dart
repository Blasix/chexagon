class User {
  final DateTime createdAt;
  final String pfpUrl;
  final String email;
  final String name;
  final List<int> currentGames;

  User({
    required this.createdAt,
    required this.email,
    required this.name,
    required this.pfpUrl,
    required this.currentGames,
  });
}
