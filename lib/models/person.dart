class Person {
  final String username;
  final String name;
  final String email;
  final String birthday;

  Person({
    required this.username,
    required this.name,
    required this.email,
    required this.birthday,
  });

  factory Person.fromJson(Map<String, dynamic> json){
    return Person(
      username: json['username'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      birthday: json['birthday'] ?? '',
    );
  }
}
