import 'package:cloud_firestore/cloud_firestore.dart';

enum IncidentStatus {
  submitted('Submitted'),
  inProgress('In progress'),
  resolved('Resolved'),
  notActionable('Not actionable');

  const IncidentStatus(this.label);
  final String label;
}

enum Urgency {
  low('Low'),
  medium('Medium'),
  high('High');

  const Urgency(this.label);
  final String label;
}

// createdAt is null for a moment right after saving, until the server sets it.
DateTime _date(dynamic value) =>
    value is Timestamp ? value.toDate() : DateTime.now();

class Incident {
  Incident({
    this.id = '',
    required this.title,
    required this.description,
    required this.category,
    required this.urgency,
    required this.zone,
    required this.area,
    this.landmark = '',
    this.photoUrls = const [],
    this.status = IncidentStatus.submitted,
    required this.reporterId,
    required this.reporterName,
    this.anonymous = false,
    this.affectedBy = const [],
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final String id;
  final String title;
  final String description;
  final String category;
  final Urgency urgency;
  final String zone;
  final String area;
  final String landmark;
  final List<String> photoUrls;
  final IncidentStatus status;
  final String reporterId;
  final String reporterName;
  final bool anonymous;
  final List<String> affectedBy;
  final DateTime createdAt;

  // Students can edit or delete only while staff haven't started.
  bool get isLocked => status != IncidentStatus.submitted;

  Map<String, dynamic> toMap() => {
    'title': title,
    'description': description,
    'category': category,
    'urgency': urgency.name,
    'zone': zone,
    'area': area,
    'landmark': landmark,
    'photoUrls': photoUrls,
    'status': status.name,
    'reporterId': reporterId,
    'reporterName': reporterName,
    'anonymous': anonymous,
    'affectedBy': affectedBy,
  };

  factory Incident.fromMap(String id, Map<String, dynamic> map) => Incident(
    id: id,
    title: map['title'] ?? '',
    description: map['description'] ?? '',
    category: map['category'] ?? '',
    urgency: Urgency.values.byName(map['urgency'] ?? 'medium'),
    zone: map['zone'] ?? '',
    area: map['area'] ?? '',
    landmark: map['landmark'] ?? '',
    photoUrls: List<String>.from(map['photoUrls'] ?? []),
    status: IncidentStatus.values.byName(map['status'] ?? 'submitted'),
    reporterId: map['reporterId'] ?? '',
    reporterName: map['reporterName'] ?? '',
    anonymous: map['anonymous'] ?? false,
    affectedBy: List<String>.from(map['affectedBy'] ?? []),
    createdAt: _date(map['createdAt']),
  );
}

class StatusUpdate {
  StatusUpdate({
    required this.status,
    required this.note,
    required this.staffName,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final IncidentStatus status;
  final String note;
  final String staffName;
  final DateTime createdAt;

  Map<String, dynamic> toMap() => {
    'status': status.name,
    'note': note,
    'staffName': staffName,
  };

  factory StatusUpdate.fromMap(Map<String, dynamic> map) => StatusUpdate(
    status: IncidentStatus.values.byName(map['status'] ?? 'submitted'),
    note: map['note'] ?? '',
    staffName: map['staffName'] ?? '',
    createdAt: _date(map['createdAt']),
  );
}
