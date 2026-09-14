import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kslas_admin_ui/app/kslas_admin_app.dart';

void main() {
  testWidgets('renders the KSLAS admin dashboard', (tester) async {
    await tester.pumpWidget(const KslasAdminApp());

    expect(find.text('KSLAS Admin'), findsWidgets);
    expect(find.text('All Admins workspace'), findsOneWidget);
    expect(find.text('Priority work'), findsOneWidget);
    expect(find.byIcon(Icons.assignment_outlined), findsWidgets);
  });
}
