class StudentDetails {
  final String fullName;
  final String email;

  StudentDetails({required this.fullName, required this.email});

  factory StudentDetails.fromMap(Map<String, dynamic> map) {
    return StudentDetails(
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
    );
  }
}
