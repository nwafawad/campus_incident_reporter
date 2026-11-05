import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/incident.dart';
import '../services/incident_service.dart';

class IncidentProvider extends ChangeNotifier {
  final _service = IncidentService();
  StreamSubscription<List<Incident>>? _sub;

  String? uid;
  List<Incident> all = [];
  bool loading = true;

  // Reports screen filters
  bool mineOnly = true;
  String search = '';
  IncidentStatus? statusFilter;
  String? categoryFilter;

  // Starts listening to reports once a user signs in.
  void start(String? newUid) {
    if (newUid == null || newUid == uid) return;
    uid = newUid;
    _sub?.cancel();
    _sub = _service.watchAll().listen((list) {
      all = list;
      loading = false;
      notifyListeners();
    });
  }

  List<Incident> get mine => all.where((i) => i.reporterId == uid).toList();

  List<Incident> get filtered {
    final q = search.trim().toLowerCase();
    return (mineOnly ? mine : all).where((i) {
      final matchesStatus = statusFilter == null || i.status == statusFilter;
      final matchesCategory =
          categoryFilter == null || i.category == categoryFilter;
      final matchesSearch = '${i.title} ${i.zone} ${i.area}'
          .toLowerCase()
          .contains(q);
      return matchesStatus && matchesCategory && matchesSearch;
    }).toList();
  }

  int countMine(IncidentStatus status) =>
      mine.where((i) => i.status == status).length;

  Incident? byId(String id) => all.where((i) => i.id == id).firstOrNull;

  // changes a filter and refreshes the screen.
  void update(VoidCallback change) {
    change();
    notifyListeners();
  }

  // actions
  Stream<List<StatusUpdate>> updatesFor(String id) => _service.watchUpdates(id);

  Future<void> toggleMeToo(Incident i) =>
      _service.setAffected(i.id, uid!, !i.affectedBy.contains(uid));

  Future<void> delete(String id) => _service.delete(id);

  Future<void> updateStatus(
    String id,
    IncidentStatus status,
    String note,
    String staffName,
  ) => _service.updateStatus(id, status, note, staffName);
}
