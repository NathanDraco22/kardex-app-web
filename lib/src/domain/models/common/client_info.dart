class ClientInfo {
  String name;
  String? cardId;
  String? phone;
  String? address;
  String? location;
  String? email;

  ClientInfo({
    required this.name,
    this.cardId,
    this.phone,
    this.address,
    this.location,
    this.email,
  });

  factory ClientInfo.fromJson(Map<String, dynamic> json) => ClientInfo(
    name: json['name'],
    cardId: json['cardId'],
    phone: json['phone'],
    address: json['address'],
    location: json['location'],
    email: json['email'],
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'cardId': cardId,
    'phone': phone,
    'address': address,
    'location': location,
    'email': email,
  };
}
