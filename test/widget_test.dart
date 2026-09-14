import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:abu_cbt_admin/app/abu_cbt_admin_app.dart';
import 'package:abu_cbt_admin/core/auth/auth_session.dart';
import 'package:abu_cbt_admin/core/network/api_client.dart';
import 'package:abu_cbt_admin/features/admin_shell/admin_operations_shell.dart';
import 'package:abu_cbt_admin/features/admin_shell/role_locked_admin_shell.dart';
import 'package:abu_cbt_admin/features/staff_management/data/staff_management_api.dart';
import 'package:abu_cbt_admin/models/admin_role.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AuthSession.instance.signOut();
  });

  test('only the five requested roles can be assigned', () {
    expect(staffRoleOptions, [
      'lecturer',
      'moderator',
      'exam_officer',
      'hod',
      'ict_admin',
    ]);
    expect(
      staffRoleOptions.map(adminRoleFromCode).toSet(),
      AdminRole.values.toSet(),
    );
    for (final code in [
      'invigilator',
      'proctor',
      'academic_records',
      'records_department',
      'department_admin',
      'faculty_admin',
      'dlc_director',
      'level_adviser',
      'support_team',
      'reports_team',
      'dean',
      'marker',
      '',
      'unknown',
    ]) {
      expect(adminRoleFromCode(code), isNull, reason: code);
    }
    expect(adminRoleFromCode(null), isNull);
    expect(adminRoleFromCode('general_ict_admin'), AdminRole.ictAdmin);
    expect(adminRoleFromCode('system_admin'), AdminRole.ictAdmin);
  });

  test('staff API rejects removed roles before making a request', () async {
    final api = StaffManagementApi();
    addTearDown(api.close);
    await expectLater(
      api.createStaff({'role_code': 'invigilator'}),
      throwsA(isA<ApiException>()),
    );
    await expectLater(
      api.assignRole(staffId: '1', role: 'dlc_director'),
      throwsA(isA<ApiException>()),
    );
  });

  testWidgets('sign-in displays ABU branding and the five portals', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1600, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const AbuCbtAdminApp());
    await tester.pumpAndSettle();
    expect(find.text('ABU CBT Admin'), findsOneWidget);
    expect(
      find.textContaining('Ahmadu Bello University, Zaria.'),
      findsNWidgets(2),
    );
    for (final role in AdminRole.values) {
      expect(find.text(role.label), findsOneWidget);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('removed role is denied instead of falling back to lecturer', (
    tester,
  ) async {
    await AuthSession.instance.saveLogin({
      'token': 'test',
      'user': {
        'roles': ['invigilator'],
      },
    });
    await tester.pumpWidget(const MaterialApp(home: RoleLockedAdminShell()));
    await tester.pumpAndSettle();
    expect(
      find.text('This account does not have access to ABU CBT Admin.'),
      findsOneWidget,
    );
    expect(find.byType(AdminOperationsShell), findsNothing);
    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();
    expect(AuthSession.instance.isSignedIn, isFalse);
  });

  for (final role in AdminRole.values) {
    testWidgets('${role.label} portal renders with its locked navigation', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1600, 1100);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          home: AdminOperationsShell(initialRole: role, lockRole: true),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Workspace role'), findsNothing);
      expect(find.textContaining(role.label), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('lecturer can reach Exam Questions from compact navigation', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(600, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      const MaterialApp(
        home: AdminOperationsShell(
          initialRole: AdminRole.lecturer,
          lockRole: true,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    expect(find.text('Exam Questions'), findsOneWidget);
    expect(find.text('Workspace role'), findsNothing);
  });
}
