import 'package:flutter/material.dart';
import 'package:phone_form_field/phone_form_field.dart';
import 'package:supabase_auth_ui/localization/intl/messages.dart';
import 'package:supabase_auth_ui/src/utils/constants.dart';
import 'package:supabase_auth_ui/src/utils/supa_auth_action.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// UI component to create a phone + password signin/ signup form
class SupaPhoneAuth extends StatefulWidget {
  /// Whether the user is sining in or signin up
  final SupaAuthAction authAction;

  /// Method to be called when the auth action is success
  final void Function(AuthResponse response) onSuccess;

  /// Method to be called when the auth action threw an excepction
  final void Function(Object error)? onError;

  const SupaPhoneAuth({
    super.key,
    required this.authAction,
    required this.onSuccess,
    this.onError,
  });

  @override
  State<SupaPhoneAuth> createState() => _SupaPhoneAuthState();
}

class _SupaPhoneAuthState extends State<SupaPhoneAuth> {
  final _formKey = GlobalKey<FormState>();
  final _phone = PhoneController();
  final _password = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localization = SupabaseAuthUILocalizations.of(context);
    final isSigningIn = widget.authAction == SupaAuthAction.signIn;
    return AutofillGroup(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PhoneFormField(
              autofillHints: const [AutofillHints.telephoneNumber],
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || !value.isValid()) {
                  return localization.validPhoneNumberError;
                }
                return null;
              },
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.phone),
                label: Text(localization.enterPhoneNumber),
              ),
              controller: _phone,
            ),
            spacer(16),
            TextFormField(
              autofillHints: isSigningIn
                  ? [AutofillHints.password]
                  : [AutofillHints.newPassword],
              textInputAction: TextInputAction.done,
              validator: (value) {
                if (value == null || value.isEmpty || value.length < 6) {
                  return localization.passwordLengthError;
                }
                return null;
              },
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.lock),
                label: Text(localization.enterPassword),
              ),
              obscureText: true,
              controller: _password,
            ),
            spacer(16),
            ElevatedButton(
              child:
                  Text(isSigningIn ? localization.signIn : localization.signUp),
              onPressed: () async {
                if (!_formKey.currentState!.validate()) {
                  return;
                }
                try {
                  if (isSigningIn) {
                    final response = await supabase.auth.signInWithPassword(
                      phone: _phone.value.international,
                      password: _password.text,
                    );
                    widget.onSuccess(response);
                  } else {
                    late final AuthResponse response;
                    final user = supabase.auth.currentUser;
                    if (user?.isAnonymous == true) {
                      await supabase.auth.updateUser(
                        UserAttributes(
                          phone: _phone.value.international,
                          password: _password.text,
                        ),
                      );
                    } else {
                      response = await supabase.auth.signUp(
                        phone: _phone.value.international,
                        password: _password.text,
                      );
                    }
                    if (!mounted) return;
                    widget.onSuccess(response);
                  }
                } on AuthException catch (error) {
                  if (widget.onError == null && context.mounted) {
                    context.showErrorSnackBar(error.message);
                  } else {
                    widget.onError?.call(error);
                  }
                } catch (error) {
                  if (widget.onError == null && context.mounted) {
                    context.showErrorSnackBar(
                        '${localization.unexpectedError}: $error');
                  } else {
                    widget.onError?.call(error);
                  }
                }
                setState(() {
                  _phone.value = _phone.initialValue;
                  _password.text = '';
                });
              },
            ),
            spacer(10),
          ],
        ),
      ),
    );
  }
}
