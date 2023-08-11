class User {
  final DateTime createdAt;
  final String email;
  final String name;
  final List<int> currentGames;

  User({
    required this.createdAt,
    required this.email,
    required this.name,
    required this.currentGames,
  });
}
