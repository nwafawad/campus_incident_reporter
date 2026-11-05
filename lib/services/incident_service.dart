import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/incident.dart';

/// Firestore reads and writes for reports and their status timeline.
class IncidentService {
  final _incidents = FirebaseFirestore.instance.collection('incidents');

  /// All campus reports, newest first, updating live.
  Stream<List<Incident>> watchAll() => _incidents
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map(
        (snap) =>
            snap.docs.map((d) => Incident.fromMap(d.id, d.data())).toList(),
      );

  /// Status timeline steps for one report, oldest first.
  Stream<List<StatusUpdate>> watchUpdates(String id) => _incidents
      .doc(id)
      .collection('updates')
      .orderBy('createdAt')
      .snapshots()
      .map(
        (snap) => snap.docs.map((d) => StatusUpdate.fromMap(d.data())).toList(),
      );

  /// A new ID so photos can go into its Cloudinary folder before saving.
  String newId() => _incidents.doc().id;

  Future<void> create(String id, Incident incident) => _incidents.doc(id).set({
    ...incident.toMap(),
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  });

  /// Reporter edits. Status, reporter and affectedBy are left alone.
  Future<void> edit(Incident i) => _incidents.doc(i.id).update({
    'title': i.title,
    'description': i.description,
    'category': i.category,
    'urgency': i.urgency.name,
    'zone': i.zone,
    'area': i.area,
    'landmark': i.landmark,
    'photoUrls': i.photoUrls,
    'anonymous': i.anonymous,
    'updatedAt': FieldValue.serverTimestamp(),
  });

  Future<void> delete(String id) => _incidents.doc(id).delete();

  /// adds or removes only this user's ID.
  Future<void> setAffected(String id, String uid, bool affected) =>
      _incidents.doc(id).update({
        'affectedBy': affected
            ? FieldValue.arrayUnion([uid])
            : FieldValue.arrayRemove([uid]),
      });

  /// Staff only changes the status and adds a timeline step together.
  Future<void> updateStatus(
    String id,
    IncidentStatus status,
    String note,
    String staffName,
  ) {
    final batch = FirebaseFirestore.instance.batch();
    batch.update(_incidents.doc(id), {
      'status': status.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    batch.set(_incidents.doc(id).collection('updates').doc(), {
      ...StatusUpdate(
        status: status,
        note: note.trim(),
        staffName: staffName,
      ).toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    return batch.commit();
  }
}
