import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/report_form_provider.dart';
import 'report_form_screen.dart';
import '../models/incident.dart';
import '../providers/auth_provider.dart';
import '../providers/incident_provider.dart';
import '../widgets/app_nav_bar.dart';
import 'home_screen.dart';
import 'incident_detail_screen.dart';
import 'reports_screen.dart';
import 'profile_screen.dart';
import 'staff_queue_screen.dart';

void openReportForm(
  BuildContext context, {
  String? category,
  Incident? editing,
}) {
  final user = context.read<AuthProvider>().user!;
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ChangeNotifierProvider(
        create: (_) => ReportFormProvider(
          category: category,
          editing: editing,
          anonymous: user.hideNameByDefault,
        ),
        child: const ReportFormScreen(),
      ),
    ),
  );
}

void openIncident(BuildContext context, Incident incident) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => IncidentDetailScreen(incidentId: incident.id),
    ),
  );
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _tab = 0;

  void _goTo(int tab) => setState(() => _tab = tab);

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user!;
    final newCount = context
        .watch<IncidentProvider>()
        .all
        .where((i) => i.status == IncidentStatus.submitted)
        .length;

    final pages = [
      user.isStaff
          ? const StaffQueueScreen()
          : HomeScreen(onSeeAll: () => _goTo(1)),
      const ReportsScreen(),
      ProfileScreen(onMyReports: () => _goTo(1)),
    ];

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(index: _tab, children: pages),
      ),
      // No Report button on Profile.
      floatingActionButton: _tab == 2
          ? null
          : FloatingActionButton.extended(
              onPressed: () => openReportForm(context),
              icon: const Icon(Icons.add),
              label: const Text('Report issue'),
            ),
      bottomNavigationBar: AppNavBar(
        isStaff: user.isStaff,
        currentIndex: _tab,
        onSelect: _goTo,
        newCount: newCount,
      ),
    );
  }
}
