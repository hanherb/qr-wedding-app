class Invitation {
  final String id;
  final String name;
  final String qrcode;
  final String? checkInTime;

  const Invitation({
    required this.id,
    required this.name,
    required this.qrcode,
    this.checkInTime
  });

  factory Invitation.fromJson(Map<String, dynamic> json) {
    return Invitation(
      id: json['id'], 
      name: json['name'], 
      qrcode: json['qrcode'],
      checkInTime: json['check_in_time'],
    );
  }
}