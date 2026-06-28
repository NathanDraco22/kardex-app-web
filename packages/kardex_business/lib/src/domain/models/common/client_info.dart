class ClientInfo {
  String name;
  String group;
  String? cardId;
  String? phone;
  String? address;
  String? location;
  String? email;

  ClientInfo({
    required this.name,
    required this.group,
    this.cardId,
    this.phone,
    this.address,
    this.location,
    this.email,
  });

  factory ClientInfo.fromJson(Map<String, dynamic> json) => ClientInfo(
    name: json['name'],
    group: json['group'] ?? '',
    cardId: json['cardId'],
    phone: json['phone'],
    address: json['address'],
    location: json['location'],
    email: json['email'],
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'group': group,
    'cardId': cardId,
    'phone': phone,
    'address': address,
    'location': location,
    'email': email,
  };
}
