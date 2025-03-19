class Contract {
  final String id; // Add this line
  final String name;
  final String email;
  final List<String> services;
  final String date;
  final String? endDate;
  final String address;
  final String city;
  final String state;
  final String zipCode;

  Contract({
    String? id, // Make it optional in constructor
    required this.name,
    required this.email,
    required this.services,
    required this.date,
    this.endDate,
    required this.address,
    required this.city,
    required this.state,
    required this.zipCode,
  }) : id = id ??
            DateTime.now()
                .millisecondsSinceEpoch
                .toString(); // Generate ID if not provided
}
