import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phone_form_field/phone_form_field.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

void main() {
  group('SupaPasswordAuth', () {
    testWidgets('should render SupaPasswordAuth', (tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(_wrapWithApp(SupaPasswordAuth(
        onSignInComplete: (response) {},
        onSignUpComplete: (response) {},
      )));

      expect(find.byType(SupaPasswordAuth), findsOneWidget);
      expect(find.byType(PhoneFormField), findsNothing);

      await tester.tap(find.text('Phone'));
      await tester.pumpAndSettle();

      expect(find.byType(PhoneFormField), findsOneWidget);
    });

    testWidgets('should render SupaPasswordAuth with only phone auth enabled',
        (tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(_wrapWithApp(SupaPasswordAuth(
        onSignInComplete: (response) {},
        onSignUpComplete: (response) {},
        identities: {SupaPasswordIdentity.phone},
      )));

      // Verify that only phone auth is rendered
      expect(find.byType(SupaPasswordAuth), findsOneWidget);
      expect(find.byType(PhoneFormField), findsOneWidget);
    });
  });
}

/// Wrap the widget with MaterialApp to provide localization
MaterialApp _wrapWithApp(Widget child) {
  return MaterialApp(
    localizationsDelegates: const [SupabaseAuthUILocalizations.delegate],
    home: Scaffold(body: child),
  );
}
