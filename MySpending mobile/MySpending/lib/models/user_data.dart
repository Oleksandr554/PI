class UserData {
  String username; 
  String email;  
  String? imagePath;

  UserData({
    required this.username,
    required this.email,
    this.imagePath,
  });

  factory UserData.initial(String loginUsername, [String? initialEmail]) {
    return UserData(
      username: loginUsername,
      email: initialEmail ??
          "${loginUsername.toLowerCase().replaceAll(' ', '_')}@example.com",
      imagePath: null,
    );
  }
}
