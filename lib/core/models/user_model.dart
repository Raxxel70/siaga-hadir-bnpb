class UserModel {
  final String id;
  final String nip;
  final String name;
  final String email;
  final String role;
  final String registeredDeviceId;
  final double? homeLatitude;
  final double? homeLongitude;
  final String department;

  const UserModel({
    required this.id,
    required this.nip,
    required this.name,
    required this.email,
    required this.role,
    required this.registeredDeviceId,
    this.homeLatitude,
    this.homeLongitude,
    required this.department,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nip': nip,
      'name': name,
      'email': email,
      'role': role,
      'registeredDeviceId': registeredDeviceId,
      'homeLatitude': homeLatitude,
      'homeLongitude': homeLongitude,
      'department': department,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, {String? documentId}) {
    return UserModel(
      id: documentId ?? map['id'] ?? '',
      nip: map['nip'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'staff',
      registeredDeviceId: map['registeredDeviceId'] ?? '',
      homeLatitude: (map['homeLatitude'] as num?)?.toDouble(),
      homeLongitude: (map['homeLongitude'] as num?)?.toDouble(),
      department: map['department'] ?? 'BNPB',
    );
  }

  UserModel copyWith({
    String? id,
    String? nip,
    String? name,
    String? email,
    String? role,
    String? registeredDeviceId,
    double? homeLatitude,
    double? homeLongitude,
    String? department,
  }) {
    return UserModel(
      id: id ?? this.id,
      nip: nip ?? this.nip,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      registeredDeviceId: registeredDeviceId ?? this.registeredDeviceId,
      homeLatitude: homeLatitude ?? this.homeLatitude,
      homeLongitude: homeLongitude ?? this.homeLongitude,
      department: department ?? this.department,
    );
  }
}
