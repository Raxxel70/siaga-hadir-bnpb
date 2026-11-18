class AttendanceModel {
  final String id;
  final String userId;
  final String nip;
  final String userName;
  final String mode; // 'wfo', 'wfh', 'field'
  final DateTime timestamp;
  final double latitude;
  final double longitude;
  final double distanceToTarget;
  final bool isMockLocation;
  final String? photoPath;
  final String? photoUrl;
  final String? operationName;
  final String? sptDocumentUrl;
  final String? notes;
  final String syncStatus; // 'synced', 'pending_sync', 'failed'

  const AttendanceModel({
    required this.id,
    required this.userId,
    required this.nip,
    required this.userName,
    required this.mode,
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    required this.distanceToTarget,
    required this.isMockLocation,
    this.photoPath,
    this.photoUrl,
    this.operationName,
    this.sptDocumentUrl,
    this.notes,
    required this.syncStatus,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'nip': nip,
      'userName': userName,
      'mode': mode,
      'timestamp': timestamp.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'distanceToTarget': distanceToTarget,
      'isMockLocation': isMockLocation,
      'photoPath': photoPath,
      'photoUrl': photoUrl,
      'operationName': operationName,
      'sptDocumentUrl': sptDocumentUrl,
      'notes': notes,
      'syncStatus': syncStatus,
    };
  }

  factory AttendanceModel.fromMap(Map<String, dynamic> map, {String? documentId}) {
    return AttendanceModel(
      id: documentId ?? map['id'] ?? '',
      userId: map['userId'] ?? '',
      nip: map['nip'] ?? '',
      userName: map['userName'] ?? '',
      mode: map['mode'] ?? 'wfo',
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      distanceToTarget: (map['distanceToTarget'] as num?)?.toDouble() ?? 0.0,
      isMockLocation: map['isMockLocation'] ?? false,
      photoPath: map['photoPath'],
      photoUrl: map['photoUrl'],
      operationName: map['operationName'],
      sptDocumentUrl: map['sptDocumentUrl'],
      notes: map['notes'],
      syncStatus: map['syncStatus'] ?? 'pending_sync',
    );
  }

  AttendanceModel copyWith({
    String? id,
    String? userId,
    String? nip,
    String? userName,
    String? mode,
    DateTime? timestamp,
    double? latitude,
    double? longitude,
    double? distanceToTarget,
    bool? isMockLocation,
    String? photoPath,
    String? photoUrl,
    String? operationName,
    String? sptDocumentUrl,
    String? notes,
    String? syncStatus,
  }) {
    return AttendanceModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      nip: nip ?? this.nip,
      userName: userName ?? this.userName,
      mode: mode ?? this.mode,
      timestamp: timestamp ?? this.timestamp,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      distanceToTarget: distanceToTarget ?? this.distanceToTarget,
      isMockLocation: isMockLocation ?? this.isMockLocation,
      photoPath: photoPath ?? this.photoPath,
      photoUrl: photoUrl ?? this.photoUrl,
      operationName: operationName ?? this.operationName,
      sptDocumentUrl: sptDocumentUrl ?? this.sptDocumentUrl,
      notes: notes ?? this.notes,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}
