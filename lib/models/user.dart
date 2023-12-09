class User {
  final String id;
  final String email;
  int credits;

  User({required this.id, required this.email, required this.credits});

  // Method to deduct credits
  bool deductCredits(int amount) {
    if (credits >= amount) {
      credits -= amount;
      return true;
    } else {
      return false; // Not enough credits
    }
  }
}
