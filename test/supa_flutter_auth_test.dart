import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:phone_form_field/phone_form_field.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

import 'mock_gotrue_client.dart';

void main() {
  group('SupaPasswordAuth', () {
    final auth = MockGoTrueClient();

    tearDown(() => reset(auth));

    testWidgets('should render SupaPasswordAuth', (tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(_wrapWithApp(SupaPasswordAuth(
        goTrueClient: auth,
        onSignInComplete: (response) {},
        onSignUpComplete: (response) {},
      )));

      expect(find.byType(SupaPasswordAuth), findsOneWidget);
      expect(find.byType(PhoneFormField), findsNothing);

      await tester.tap(find.text('Phone'));
      await tester.pumpAndSettle();

      expect(find.byType(PhoneFormField), findsOneWidget);
    });

    testWidgets('can directly sign up with phone', (tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(_wrapWithApp(SupaPasswordAuth(
        goTrueClient: auth,
        onSignInComplete: (response) {},
        onSignUpComplete: (response) {},
        identities: {SupaPasswordIdentity.phone},
        isInitiallySigningIn: false,
      )));

      // Verify that only phone auth is rendered
      expect(find.byType(SupaPasswordAuth), findsOneWidget);
      expect(find.byType(PhoneFormField), findsOneWidget);

      await tester.enterText(find.byType(PhoneFormField), '+1 (415) 555‑0132');
      await tester.enterText(find.byType(TextFormField), 'password');
      await tester.tap(find.text('Sign up'));

      verify(() => auth.signUp(
            phone: '+14155550132',
            password: 'password',
          )).called(1);
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
