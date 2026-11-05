import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../models/app_user.dart';
import '../models/incident.dart';
import '../services/incident_service.dart';
import '../services/storage_service.dart';

class ReportFormProvider extends ChangeNotifier {
  ReportFormProvider({this.category, this.editing, this.anonymous = false}) {
    final e = editing;
    if (e != null) {
      category = e.category;
      title = e.title;
      description = e.description;
      zone = e.zone;
      area = e.area;
      landmark = e.landmark;
      urgency = e.urgency;
      photoUrls = [...e.photoUrls];
      anonymous = e.anonymous;
    }
  }

  final Incident? editing;

  String? category;
  String title = '';
  String description = '';
  String? zone;
  String? area;
  String landmark = '';
  Urgency urgency = Urgency.medium;
  List<XFile> photos = [];
  List<String> photoUrls = [];
  bool anonymous;

  bool submitting = false;
  String? error;

  bool get canSubmit =>
      category != null &&
      title.trim().isNotEmpty &&
      description.trim().isNotEmpty &&
      zone != null &&
      area != null &&
      !submitting;

  void update(VoidCallback change) {
    change();
    notifyListeners();
  }

  Future<String?> submit(AppUser reporter) async {
    update(() {
      submitting = true;
      error = null;
    });

    try {
      final incidents = IncidentService();
      final id = editing?.id ?? incidents.newId();
      final newUrls = await StorageService().uploadPhotos(photos, id);

      final incident = Incident(
        id: id,
        title: title.trim(),
        description: description.trim(),
        category: category!,
        urgency: urgency,
        zone: zone!,
        area: area!,
        landmark: landmark.trim(),
        photoUrls: [...photoUrls, ...newUrls],
        reporterId: reporter.uid,
        reporterName: reporter.name,
        anonymous: anonymous,
        affectedBy: editing?.affectedBy ?? [reporter.uid],
      );

      if (editing == null) {
        await incidents.create(id, incident);
      } else {
        await incidents.edit(incident);
      }
      return id;
    } catch (_) {
      error =
          "Couldn't submit your report. Check your connection and try again.";
      return null;
    } finally {
      update(() => submitting = false);
    }
  }
}
