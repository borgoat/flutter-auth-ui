import 'package:flutter/material.dart';

/// {@template metadata_field}
/// Information about the metadata to pass to the signup form
///
/// You can use this object to create additional text fields that will be
/// passed to the metadata of the user upon signup.
/// For example, in order to create additional `username` field, you can use the following:
/// ```dart
/// MetaDataField(label: 'Username', key: 'username')
/// ```
///
/// Which will update the user's metadata in like the following:
///
/// ```dart
/// { 'username': 'Whatever your user entered' }
/// ```
/// {@endtemplate}
class MetaDataField {
  /// Label of the `TextFormField` for this metadata
  final String label;

  /// Key to be used when sending the metadata to Supabase
  final String key;

  /// Validator function for the metadata field
  final String? Function(String?)? validator;

  /// Icon to show as the prefix icon in TextFormField
  final Icon? prefixIcon;

  /// {@macro metadata_field}
  MetaDataField({
    required this.label,
    required this.key,
    this.validator,
    this.prefixIcon,
  });
}

/// {@template boolean_metadata_field}
/// Represents a boolean metadata field for the signup form.
///
/// This class is used to create checkbox fields that will be passed
/// to the metadata of the user upon signup. It supports both simple
/// text labels and rich text labels with interactive elements.
///
/// For example, in order to add a simple consent checkbox,
/// you can use the following:
/// ```dart
/// BooleanMetaDataField(
///   label: 'I agree to marketing emails',
///   key: 'email_consent',
/// )
/// ```
///
/// Which will update the user's metadata accordingly:
///
/// ```dart
/// { 'email_consent': true }
/// ```
///
/// You can also use rich text labels with interactive elements.
/// For example:
/// ```dart
/// BooleanMetaDataField(
///   key: 'terms_and_conditions_consent',
///   required: true,
///   richLabelSpans: [
///     TextSpan(text: 'I have read and agree to the '),
///     TextSpan(
///       text: 'Terms and Conditions',
///       style: TextStyle(color: Colors.blue),
///       recognizer: TapGestureRecognizer()
///         ..onTap = () {
///           // Handle tap on 'Terms and Conditions'
///         },
///     ),
///   ],
/// )
/// ```
///
/// This will create a checkbox with a label that includes a link to the terms
/// and conditions. When the user taps on the link, you can handle the tap
/// event in your application. Because `required` is set to `true`, the user
/// must check the checkbox in order to sign up.
/// {@endtemplate}
class BooleanMetaDataField extends MetaDataField {
  /// Whether the checkbox is initially checked.
  final bool value;

  /// Rich text spans for the label. If provided, this will be used instead of [label].
  final List<InlineSpan>? richLabelSpans;

  /// Position of the checkbox in the [ListTile] created by this.
  ///
  /// Default is to ListTileControlAffinity.platform, which matches the default
  /// value of the underlying ListTile widget.
  final ListTileControlAffinity checkboxPosition;

  /// Whether the field is required.
  ///
  /// If true, the user must check the checkbox in order for the form to submit.
  final bool isRequired;

  /// Semantic label for the checkbox.
  final String? checkboxSemanticLabel;

  /// {@macro boolean_metadata_field}
  BooleanMetaDataField({
    String? label,
    this.value = false,
    this.richLabelSpans,
    this.checkboxSemanticLabel,
    this.isRequired = false,
    this.checkboxPosition = ListTileControlAffinity.platform,
    required super.key,
  })  : assert(label != null || richLabelSpans != null,
            'Either label or richLabelSpans must be provided'),
        super(label: label ?? '');

  Widget getLabelWidget(BuildContext context) {
    // This matches the default style of [TextField], to match the other fields
    // in the form. TextField's default style uses `bodyLarge` for Material 3,
    // or otherwise `titleMedium`.
    final defaultStyle = Theme.of(context).useMaterial3
        ? Theme.of(context).textTheme.bodyLarge
        : Theme.of(context).textTheme.titleMedium;
    return richLabelSpans != null
        ? RichText(
            text: TextSpan(
              style: defaultStyle,
              children: richLabelSpans,
            ),
          )
        : Text(label, style: defaultStyle);
  }
}

// Used to allow storing both bool and TextEditingController in the same map.
typedef MetadataController = Object;
