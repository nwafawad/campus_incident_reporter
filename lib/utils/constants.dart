import 'package:flutter/material.dart';

import '../models/app_user.dart';

// Demo staff account: remove before real use (also in firestore.rules).
const demoStaffEmail = 'nwafawad49@gmail.com';

// Cloudinary
const cloudinaryCloudName = 'duhvg9zwd';
const cloudinaryUploadPreset = 'campuscare_unsigned';

UserRole roleFromEmail(String email) {
  final e = email.toLowerCase();
  if (e.endsWith('@alueducation.com') || e == demoStaffEmail) {
    return UserRole.staff;
  }
  return UserRole.student;
}

// Report limits
const titleMaxLength = 60;
const descriptionMaxLength = 500;
const maxPhotos = 3;
const maxPhotoBytes = 5 * 1024 * 1024;
const overdueAfter = Duration(days: 5);

// Categories
const categories = [
  'Facilities',
  'Water',
  'Electricity',
  'Furniture',
  'Sanitation',
  'Safety',
];

const categoryIcons = <String, IconData>{
  'Facilities': Icons.domain_outlined,
  'Water': Icons.water_drop_outlined,
  'Electricity': Icons.bolt_outlined,
  'Furniture': Icons.chair_outlined,
  'Sanitation': Icons.delete_outline,
  'Safety': Icons.shield_outlined,
};

IconData iconForCategory(String category) =>
    categoryIcons[category] ?? Icons.report_outlined;

// Campus buildings (used by the staff queue's Building filter)
const learningCommons = 'Learning Commons';
const enterpriseCommons = 'Enterprise Commons';
const socialCommons = 'Social Commons';
const outdoors = 'Outdoors';
const acrossCampus = 'Across campus';

const campusBuildings = [
  learningCommons,
  enterpriseCommons,
  socialCommons,
  outdoors,
  acrossCampus,
];

// Campus zones (ALU Kigali, Bumbogo)
class CampusZone {
  const CampusZone(this.name, this.group, this.building, this.areas);

  final String name;
  final String group; // short tag shown beside the selected zone
  final String building;
  final List<String> areas;
}

/// Short tag -> heading shown in the zone dropdown.
const zoneGroups = {
  'Academic': 'Academic and collaborative spaces',
  'Support': 'Administrative and support hubs',
  'Social': 'Social, dining and outdoor areas',
  'Facilities': 'Shared facilities',
};

const campusZones = <CampusZone>[
  // Academic and collaborative spaces
  CampusZone('Learning Labs', 'Academic', learningCommons, [
    'Labs 1–7',
    'Labs 8–14',
    'Labs 15–21',
    'Corridor',
  ]),
  CampusZone('Meeting & Study Pods', 'Academic', learningCommons, [
    'Ground floor pods',
    'Upper floor pods',
  ]),
  CampusZone('Work Hives', 'Academic', learningCommons, [
    'Ground floor',
    'Upper floor',
  ]),
  CampusZone('Fab Lab / Maker Space', 'Academic', enterpriseCommons, [
    'Workbenches',
    '3D printers & tools',
    'Electronics bench',
    'Storage',
  ]),
  CampusZone('Library & Resource Center', 'Academic', learningCommons, [
    'Quiet study area',
    'Book stacks',
    'Front desk',
  ]),
  CampusZone('SDL Skills Lab', 'Academic', learningCommons, [
    'Main room',
    'Coaching rooms',
  ]),

  // Administrative and support hubs
  CampusZone('Reception & Main Lobby', 'Support', learningCommons, [
    'Front desk',
    'Waiting area',
    'Main entrance',
  ]),
  CampusZone('Student Life Hub', 'Support', socialCommons, [
    'Front office',
    'Club rooms',
  ]),
  CampusZone('Wellness & Counseling Center', 'Support', socialCommons, [
    'Reception',
    'Counseling rooms',
  ]),
  CampusZone('Career Development Hub', 'Support', enterpriseCommons, [
    'Help desk',
    'Meeting rooms',
  ]),
  CampusZone('IT Support & Helpdesk', 'Support', enterpriseCommons, [
    'Help desk',
    'Office',
  ]),
  CampusZone('Faculty & Administration Offices', 'Support', learningCommons, [
    'Faculty offices',
    'Leadership offices',
    'Meeting rooms',
    'Staff kitchen',
  ]),

  // Social, dining and outdoor areas
  CampusZone('Main Courtyard & Amphitheatre', 'Social', outdoors, [
    'Amphitheatre steps',
    'Stage',
    'Walkways',
    'Lawn',
  ]),
  CampusZone('Cafeteria & Coffee Shop', 'Social', socialCommons, [
    'Food service counter',
    'Kitchen area',
    'Seating area',
    'Coffee shop',
  ]),
  CampusZone('Student Lounge & Recreation', 'Social', socialCommons, [
    'Seating area',
    'Games area',
  ]),
  CampusZone('Rooftop Terraces', 'Social', acrossCampus, [
    'Learning Commons roof',
    'Enterprise Commons roof',
    'Social Commons roof',
  ]),
  CampusZone('Exterior Study Pods & Gardens', 'Social', outdoors, [
    'Study pods',
    'Gardens',
    'Walkways',
  ]),
  CampusZone('Main Security Gate & Parking', 'Social', outdoors, [
    'Security gate',
    'Parking',
    'Drop-off zone',
  ]),

  // Shared facilities
  CampusZone('Restrooms', 'Facilities', acrossCampus, [
    'Ground floor · Male',
    'Ground floor · Female',
    'Ground floor · Accessible',
    'Upper level · Male',
    'Upper level · Female',
    'Upper level · Accessible',
  ]),
];

CampusZone? zoneByName(String? name) {
  for (final z in campusZones) {
    if (z.name == name) return z;
  }
  return null;
}

String buildingForZone(String zone) =>
    zoneByName(zone)?.building ?? acrossCampus;
