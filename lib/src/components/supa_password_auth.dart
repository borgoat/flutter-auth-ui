import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:phone_form_field/phone_form_field.dart';
import 'package:supabase_auth_ui/localization/intl/messages.dart';
import 'package:supabase_auth_ui/src/utils/constants.dart';
import 'package:supabase_auth_ui/src/utils/metadata.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Users can associate a password with their identity using their email address or a phone number.
enum SupaPasswordIdentity { email, phone }

/// {@template supa_password_auth}
/// UI component to create signup and signin forms with
/// * email and password
/// * phone and password.
///
/// ```dart
/// SupaPasswordAuth(
///   onSignInComplete: (response) {
///     // handle sign in complete here
///   },
///   onSignUpComplete: (response) {
///     // handle sign up complete here
///   },
/// ),
/// ```
/// {@endtemplate}
class SupaPasswordAuth extends StatefulWidget {
  /// The URL to redirect the user to when clicking on the link on the
  /// confirmation link after signing up.
  final String? redirectTo;

  /// The URL to redirect the user to when clicking on the link on the
  /// password recovery link.
  ///
  /// If unspecified, the [redirectTo] value will be used.
  final String? resetPasswordRedirectTo;

  /// Validator function for the password field
  ///
  /// If null, a default validator will be used that checks if
  /// the password is at least 6 characters long.
  final String? Function(String?)? passwordValidator;

  /// Callback for the user to complete a sign in.
  final void Function(AuthResponse response) onSignInComplete;

  /// Callback for the user to complete a signUp.
  ///
  /// If email confirmation is turned on, the user is
  final void Function(AuthResponse response) onSignUpComplete;

  /// Callback for sending the password reset email
  final void Function()? onPasswordResetEmailSent;

  /// Callback for when the auth action threw an exception
  ///
  /// If set to `null`, a snack bar with error color will show up.
  final void Function(Object error)? onError;

  /// Callback for toggling between sign in and sign up
  final void Function(bool isSigningIn)? onToggleSignIn;

  /// Callback for toggling between sign-in/ sign-up and password recovery
  final void Function(bool isRecoveringPassword)? onToggleRecoverPassword;

  /// Set of additional fields to the signup form that will become
  /// part of the user_metadata
  final List<MetaDataField>? metadataFields;

  /// Additional properties for user_metadata on signup
  final Map<String, dynamic>? extraMetadata;

  /// Whether the form should display sign-in or sign-up initially
  final bool isInitiallySigningIn;

  /// Icons or custom prefix widgets for email UI
  final Widget? prefixIconEmail;
  final Widget? prefixIconPassword;

  /// Icon or custom prefix widget for OTP input field
  final Widget? prefixIconOtp;

  /// Whether the confirm password field should be displayed
  final bool showConfirmPasswordField;

  /// Set of identities that the user can use to sign in
  final Set<SupaPasswordIdentity> identities;

  /// {@macro supa_email_auth}
  const SupaPasswordAuth({
    super.key,
    this.redirectTo,
    this.resetPasswordRedirectTo,
    this.passwordValidator,
    required this.onSignInComplete,
    required this.onSignUpComplete,
    this.onPasswordResetEmailSent,
    this.onError,
    this.onToggleSignIn,
    this.onToggleRecoverPassword,
    this.metadataFields,
    this.extraMetadata,
    this.isInitiallySigningIn = true,
    this.prefixIconEmail = const Icon(Icons.email),
    this.prefixIconPassword = const Icon(Icons.lock),
    this.prefixIconOtp = const Icon(Icons.security),
    this.showConfirmPasswordField = false,
    this.identities = const {
      SupaPasswordIdentity.email,
      SupaPasswordIdentity.phone
    },
  });

  @override
  State<SupaPasswordAuth> createState() => _SupaPasswordAuthState();
}

class _SupaPasswordAuthState extends State<SupaPasswordAuth> {
  /// The localization instance
  SupabaseAuthUILocalizations get _localization =>
      SupabaseAuthUILocalizations.of(context);

  /// The selected identity - late because it depends on the widget configuration
  late SupaPasswordIdentity _selectedIdentity;

  /// True when the user is signing in, false when signing up;
  /// late because it depends on the widget configuration
  late bool _isSigningIn;

  /// True when waiting for a response from the server
  bool _isLoading = false;

  /// The user has pressed forgot password button
  bool _isRecoveringPassword = false;

  /// Whether the user is entering OTP code
  bool _isEnteringOtp = false;

  /// Whether it is possible to switch between multiple identities to sign in
  bool get _multipleIdentitiesAvailable => widget.identities.length > 1;

  /// Whether the user is using email to sign in instead of phone
  bool get _isUsingEmail => _selectedIdentity == SupaPasswordIdentity.email;

  /// Whether the user is using phone to sign in instead of email
  bool get _isUsingPhone => _selectedIdentity == SupaPasswordIdentity.phone;

  /// Whether the user is signing up
  bool get _isSigningUp => !_isSigningIn;

  /// Whether there are metadata fields to show
  bool get _thereAreMetadataFields =>
      widget.metadataFields != null && widget.metadataFields!.isNotEmpty;

  final _formKey = GlobalKey<FormState>();

  /// Focus node for the identity field - only one is shown at a time anyway
  final _identityFocusNode = FocusNode();

  /// Controller for email input field
  final _emailController = TextEditingController();

  /// Controller for phone input field
  final _phoneController = PhoneController();

  /// Controller for password input field
  final _passwordController = TextEditingController();

  /// Controller for confirm password input field
  final _confirmPasswordController = TextEditingController();

  /// Controller for OTP input field
  final _otpController = TextEditingController();

  /// Controller for new password input field
  final _newPasswordController = TextEditingController();

  /// Controller for confirm new password input field
  final _confirmNewPasswordController = TextEditingController();

  /// Optional additional controllers for metadata fields
  late final Map<String, MetadataController> _metadataControllers;

  @override
  void initState() {
    super.initState();
    _selectedIdentity = widget.identities.first;
    _isSigningIn = widget.isInitiallySigningIn;
    _metadataControllers = {
      for (final metadataField in widget.metadataFields ?? [])
        metadataField.key: metadataField is BooleanMetaDataField
            ? metadataField.value
            : TextEditingController(),
    };
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    for (final controller in _metadataControllers.values) {
      if (controller is TextEditingController) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AutofillGroup(
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // If the user can sign in with both email and phone,
            // show a segment control to switch between the two.
            if (_multipleIdentitiesAvailable) ...[
              _identitySwitchButton(),
              spacer(16),
            ],

            // Show the email or phone field based on the selected identity.
            if (_isUsingEmail) _emailFormField() else _phoneFormField(),

            // Show the password fields if the user is signing in or signing up.
            if (!_isRecoveringPassword) ...[
              spacer(16),
              _passwordFormField(),
              if (widget.showConfirmPasswordField && _isSigningUp) ...[
                spacer(16),
                _confirmPasswordFormField(),
              ],
              spacer(16),
              if (_thereAreMetadataFields && _isSigningUp)
                for (final metadataField in widget.metadataFields!)
                  // Render a Checkbox that displays an error message
                  // beneath it if the field is required and the user
                  // hasn't checked it when submitting the form.
                  if (metadataField is BooleanMetaDataField)
                    _booleanMetaDataFormField(metadataField)
                  else
                    // Otherwise render a normal TextFormField matching
                    // the style of the other fields in the form.
                    _textMetaDataFormField(metadataField),
              spacer(16),

              // This is to start the sign-in or sign-up action
              _signInSignUpButton(),
              spacer(16),

              // Show the password recovery button if the user is signing in.
              if (_isSigningIn) _forgotPasswordButton(),
              // A button to toggle between sign-in and sign-up
              _signInSignUpToggle(),
            ],

            // Show the password recovery form if the user is recovering their password.
            if (_isSigningIn && _isRecoveringPassword) ...[
              spacer(16),
              // Show just the email or phone field and the button to send the recovery email
              if (!_isEnteringOtp)
                _sendPasswordRecoveryButton()
              else ...[
                // Else show the OTP field and the button to change the password
                _otpFormField(),
                spacer(16),
                _newPasswordFormField(),
                spacer(16),
                _confirmNewPasswordFormField(),
                spacer(16),
                _changePasswordButton(),
              ],
              spacer(16),
              _backToSignInButton(),
            ],
          ],
        ),
      ),
    );
  }

  /// A button to switch between email and phone sign-in/sign-up
  Widget _identitySwitchButton() {
    final identityMap = {
      SupaPasswordIdentity.email: _localization.email,
      SupaPasswordIdentity.phone: _localization.phone,
    };

    return SegmentedButton<SupaPasswordIdentity>(
      segments: [
        for (final identity in widget.identities)
          ButtonSegment(
            value: identity,
            label: Text(identityMap[identity]!),
          ),
      ],
      selected: {_selectedIdentity},
      onSelectionChanged: (identities) {
        setState(() {
          _selectedIdentity = identities.first;
          _isEnteringOtp = false;
          _isRecoveringPassword = false;
        });
      },
    );
  }

  /// The email input field, used for sign-in and sign-up.
  Widget _emailFormField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      autofillHints: const [AutofillHints.email],
      autofocus: true,
      focusNode: _identityFocusNode,
      enabled: !_isEnteringOtp,
      textInputAction:
          _isRecoveringPassword ? TextInputAction.done : TextInputAction.next,
      validator: (value) {
        if (value == null ||
            value.isEmpty ||
            !EmailValidator.validate(_emailController.text)) {
          return _localization.validEmailError;
        }
        return null;
      },
      decoration: InputDecoration(
        prefixIcon: widget.prefixIconEmail,
        label: Text(_localization.enterEmail),
      ),
      onFieldSubmitted: (_) {
        if (_isRecoveringPassword) {
          _passwordRecovery();
        }
      },
    );
  }

  /// The phone input field
  Widget _phoneFormField() {
    return PhoneFormField(
      controller: _phoneController,
      autofillHints: const [AutofillHints.telephoneNumber],
      autofocus: true,
      focusNode: _identityFocusNode,
      enabled: !_isEnteringOtp,
      textInputAction:
          _isRecoveringPassword ? TextInputAction.done : TextInputAction.next,
      validator: (value) {
        if (value == null || !value.isValid()) {
          return _localization.validPhoneNumberError;
        }
        return null;
      },
      decoration: InputDecoration(
        label: Text(_localization.enterPhoneNumber),
      ),
    );
  }

  /// The password or new password input field, depending on the context
  Widget _passwordFormField() {
    return TextFormField(
      autofillHints:
          _isSigningIn ? [AutofillHints.password] : [AutofillHints.newPassword],
      textInputAction: widget.metadataFields != null && !_isSigningIn
          ? TextInputAction.next
          : TextInputAction.done,
      validator: _passwordValidator(),
      decoration: InputDecoration(
        prefixIcon: widget.prefixIconPassword,
        label: Text(_localization.enterPassword),
      ),
      obscureText: true,
      controller: _passwordController,
      onFieldSubmitted: (_) {
        if (widget.metadataFields == null || _isSigningIn) {
          _signInSignUp();
        }
      },
    );
  }

  /// The confirm password input field for sign-up
  Widget _confirmPasswordFormField() {
    return TextFormField(
      controller: _confirmPasswordController,
      decoration: InputDecoration(
        prefixIcon: widget.prefixIconPassword,
        label: Text(_localization.confirmPassword),
      ),
      obscureText: true,
      validator: (value) {
        if (value != _passwordController.text) {
          return _localization.confirmPasswordError;
        }
        return null;
      },
    );
  }

  /// A widget to display boolean metadata fields (checkboxes)
  Widget _booleanMetaDataFormField(BooleanMetaDataField metadataField) {
    final theme = Theme.of(context);

    // TODO: introduce a dedicated widget for metadata fields
    return FormField<bool>(
      validator: metadataField.isRequired
          ? (bool? value) {
              if (value != true) {
                return _localization.requiredFieldError;
              }
              return null;
            }
          : null,
      builder: (FormFieldState<bool> field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CheckboxListTile(
              title: metadataField.getLabelWidget(context),
              value: _metadataControllers[metadataField.key] as bool,
              onChanged: (bool? value) {
                setState(() {
                  _metadataControllers[metadataField.key] = value ?? false;
                });
                field.didChange(value);
              },
              checkboxSemanticLabel: metadataField.checkboxSemanticLabel,
              controlAffinity: metadataField.checkboxPosition,
              contentPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              isError: field.hasError,
            ),
            if (field.hasError)
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 4),
                child: Text(
                  field.errorText!,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  /// A widget to display plain text metadata fields
  Widget _textMetaDataFormField(MetaDataField metadataField) {
    final isLast = widget.metadataFields!.last == metadataField;

    return TextFormField(
      controller:
          _metadataControllers[metadataField.key] as TextEditingController,
      textInputAction: isLast ? TextInputAction.done : TextInputAction.next,
      decoration: InputDecoration(
        label: Text(metadataField.label),
        prefixIcon: metadataField.prefixIcon,
      ),
      validator: metadataField.validator,
      onFieldSubmitted: (_) {
        if (!isLast) {
          FocusScope.of(context).nextFocus();
        } else {
          _signInSignUp();
        }
      },
    );
  }

  /// A button to sign in or sign up
  Widget _signInSignUpButton() {
    return ElevatedButton(
      onPressed: () => _signInSignUp(),
      child: (_isLoading)
          ? SizedBox(
              height: 16,
              width: 16,
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.onPrimary,
                strokeWidth: 1.5,
              ),
            )
          : Text(_isSigningIn ? _localization.signIn : _localization.signUp),
    );
  }

  /// Button to switch to password recovery
  Widget _forgotPasswordButton() {
    return TextButton(
      onPressed: () {
        setState(() {
          _isRecoveringPassword = true;
        });
        widget.onToggleRecoverPassword?.call(_isRecoveringPassword);
      },
      child: Text(_localization.forgotPassword),
    );
  }

  /// A button to toggle between sign-in and sign-up
  Widget _signInSignUpToggle() {
    return TextButton(
      key: const ValueKey('toggleSignInButton'),
      onPressed: () {
        setState(() {
          _isRecoveringPassword = false;
          _isSigningIn = !_isSigningIn;
        });
        widget.onToggleSignIn?.call(_isSigningIn);
        widget.onToggleRecoverPassword?.call(_isRecoveringPassword);
      },
      child: Text(
        _isSigningIn
            ? _localization.dontHaveAccount
            : _localization.haveAccount,
      ),
    );
  }

  /// A button to send the password recovery email or OTP code
  Widget _sendPasswordRecoveryButton() {
    return ElevatedButton(
      onPressed: () => _passwordRecovery(),
      child: _isUsingEmail
          ? Text(_localization.sendPasswordResetEmail)
          : Text(_localization.sendPasswordResetPhone),
    );
  }

  /// The OTP input field
  Widget _otpFormField() {
    return TextFormField(
      controller: _otpController,
      autofillHints: const [AutofillHints.oneTimeCode],
      decoration: InputDecoration(
        prefixIcon: widget.prefixIconOtp,
        label: Text(_localization.enterOtpCode),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return _localization.otpCodeError;
        }
        return null;
      },
    );
  }

  /// The new password input field
  Widget _newPasswordFormField() {
    return TextFormField(
      controller: _newPasswordController,
      decoration: InputDecoration(
        label: Text(_localization.enterNewPassword),
        prefixIcon: widget.prefixIconPassword,
      ),
      obscureText: true,
      validator: _passwordValidator(),
    );
  }

  /// The confirm new password input field
  Widget _confirmNewPasswordFormField() {
    return TextFormField(
      controller: _confirmNewPasswordController,
      decoration: InputDecoration(
        label: Text(_localization.confirmPassword),
        prefixIcon: widget.prefixIconPassword,
      ),
      obscureText: true,
      validator: (value) {
        if (value?.trim() != _resolveNewPassword()) {
          return _localization.confirmPasswordError;
        }
        return null;
      },
    );
  }

  /// A button to change the password after verifying the OTP code
  Widget _changePasswordButton() {
    return ElevatedButton(
      onPressed: () => _verifyOtpAndResetPassword(),
      child: _isLoading
          ? SizedBox(
              height: 16,
              width: 16,
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.onPrimary,
                strokeWidth: 1.5,
              ),
            )
          : Text(_localization.changePassword),
    );
  }

  /// A button to go back to sign-in
  Widget _backToSignInButton() {
    return TextButton(
      onPressed: () {
        setState(() {
          _isRecoveringPassword = false;
          _isEnteringOtp = false;
        });
      },
      child: Text(_localization.backToSignIn),
    );
  }

  /// Perform the sign-in or sign-up action
  Future<void> _signInSignUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      if (_isSigningIn) {
        final response = await supabase.auth.signInWithPassword(
          email: _resolveEmail(),
          phone: _resolvePhone(),
          password: _resolvePassword(),
        );
        widget.onSignInComplete.call(response);
      } else {
        final user = supabase.auth.currentUser;
        late final AuthResponse response;
        if (user?.isAnonymous == true) {
          await supabase.auth.updateUser(
            UserAttributes(
              email: _resolveEmail(),
              phone: _resolvePhone(),
              password: _resolvePassword(),
              data: _resolveData(),
            ),
            emailRedirectTo: widget.redirectTo,
          );
          final newSession = supabase.auth.currentSession;
          response = AuthResponse(session: newSession);
        } else {
          response = await supabase.auth.signUp(
            email: _resolveEmail(),
            phone: _resolvePhone(),
            password: _resolvePassword(),
            emailRedirectTo: widget.redirectTo,
            data: _resolveData(),
          );

          // TODO: if verification is required, explain to the user
          //       that they can either tap on the link in the email or
          //       enter the OTP code sent to their email/phone.
        }
        widget.onSignUpComplete.call(response);
      }
    } on AuthException catch (error) {
      if (widget.onError == null && mounted) {
        context.showErrorSnackBar(error.message);
      } else {
        widget.onError?.call(error);
      }
      _identityFocusNode.requestFocus();
    } catch (error) {
      if (widget.onError == null && mounted) {
        context.showErrorSnackBar('${_localization.unexpectedError}: $error');
      } else {
        widget.onError?.call(error);
      }
      _identityFocusNode.requestFocus();
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _passwordRecovery() async {
    try {
      if (!_formKey.currentState!.validate()) {
        // Focus on identity field if validation fails
        _identityFocusNode.requestFocus();
        return;
      }
      setState(() {
        _isLoading = true;
      });

      // If the user is recovering their password with email,
      // send a password reset email.
      // If the user is recovering their password with phone,
      // send an OTP code.
      if (_selectedIdentity == SupaPasswordIdentity.email) {
        await supabase.auth.resetPasswordForEmail(
          _resolveEmail()!,
          redirectTo: widget.resetPasswordRedirectTo ?? widget.redirectTo,
        );
        widget.onPasswordResetEmailSent?.call();
        if (!mounted) return;
        context.showSnackBar(_localization.passwordResetSentEmail);
      } else {
        await supabase.auth.signInWithOtp(
          phone: _resolvePhone(),
        );
        if (!mounted) return;
        context.showSnackBar(_localization.passwordResetSentPhone);
      }

      // Always show the OTP field after sending the email or OTP code
      setState(() {
        _isEnteringOtp = true;
      });
    } on AuthException catch (error) {
      widget.onError?.call(error);
    } catch (error) {
      widget.onError?.call(error);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// First verify the OTP code and then reset the user's password.
  Future<void> _verifyOtpAndResetPassword() async {
    try {
      if (!_formKey.currentState!.validate()) return;

      setState(() {
        _isLoading = true;
      });

      final response = await _verifyOtp();

      if (response == null) return;

      await supabase.auth.updateUser(
        UserAttributes(password: _resolveNewPassword()),
      );

      if (!mounted) return;
      context.showSnackBar(_localization.passwordChangedSuccess);

      setState(() {
        _isRecoveringPassword = false;
        _isEnteringOtp = false;
      });
    } catch (error) {
      widget.onError?.call(error);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Verify the OTP code sent to the user's email or phone,
  /// depending on the selected identity.
  Future<AuthResponse?> _verifyOtp() async {
    try {
      return supabase.auth.verifyOTP(
        // TODO: type can be other values depending on the use case...
        type: _resolveOtpType(),
        token: _resolveOtp(),
        email: _resolveEmail(),
        phone: _resolvePhone(),
      );
    } on AuthException catch (error) {
      if (error.code == 'otp_expired') {
        if (!mounted) return null;
        context.showErrorSnackBar(_localization.otpCodeError);
        return null;
      } else if (error.code == 'otp_disabled') {
        if (!mounted) return null;
        context.showErrorSnackBar(_localization.otpDisabledError);
        return null;
      }
      rethrow;
    }
  }

  /// A reusable validator for the password and new password fields
  FormFieldValidator<String> _passwordValidator() {
    return widget.passwordValidator ??
        (value) {
          if (value == null || value.isEmpty || value.length < 6) {
            return _localization.passwordLengthError;
          }
          return null;
        };
  }

  /// Resolve the email that we will send during sign-up,
  /// or null if the user is signing up with phone.
  String? _resolveEmail() =>
      _isUsingEmail ? _emailController.text.trim() : null;

  /// Resolve the phone number that we will send during sign-up,
  /// or null if the user is signing up with email.
  String? _resolvePhone() =>
      _isUsingPhone ? _phoneController.value.international : null;

  /// Resolve the password that we will send during sign-up
  String _resolvePassword() => _passwordController.text.trim();

  /// Resolve the new password that we will send during password recovery
  String _resolveNewPassword() => _newPasswordController.text.trim();

  /// Resolve the OTP type to distinguish between SMS and recovery OTP
  OtpType _resolveOtpType() => _isUsingPhone ? OtpType.sms : OtpType.recovery;

  /// Resolve the OTP that we will send during sign-up
  String _resolveOtp() => _otpController.text.trim();

  /// Resolve the user_metadata that we will send during sign-up
  ///
  /// In case both MetadataFields and extraMetadata have the same
  /// key in their map, the MetadataFields (form fields) win
  Map<String, dynamic> _resolveData() {
    final extra = widget.extraMetadata ?? <String, dynamic>{};
    extra.addAll(_resolveMetadataFieldsData());
    return extra;
  }

  /// Resolve the user_metadata coming from the metadataFields
  Map<String, dynamic> _resolveMetadataFieldsData() {
    return {
      for (final entry in _metadataControllers.entries)
        entry.key: entry.value is TextEditingController
            ? (entry.value as TextEditingController).text
            : entry.value
    };
  }
}
