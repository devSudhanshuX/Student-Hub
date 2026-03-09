class User {
  final String uid;
  final String email;
  final String mobileNumber;
  final String displayName;
  final DateTime createdAt;

  User({
    required this.uid,
    required this.email,
    required this.mobileNumber,
    this.displayName = '',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'mobileNumber': mobileNumber,
      'displayName': displayName,
      'createdAt': createdAt,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      mobileNumber: map['mobileNumber'] ?? '',
      displayName: map['displayName'] ?? '',
      createdAt: map['createdAt'] is DateTime
          ? map['createdAt']
          : DateTime.parse(map['createdAt'] ?? DateTime.now().toString()),
    );
  }
}
