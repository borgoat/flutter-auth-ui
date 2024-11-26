import 'package:flutter/material.dart';

class CheckboxController extends ValueNotifier<bool> {
  CheckboxController({bool initialValue = false}) : super(initialValue);
}

class CheckboxFormField extends FormField<bool> {
  CheckboxFormField({
    super.key,
    super.validator,
    this.controller,
    this.onChanged,
    this.title,
    this.checkboxSemanticLabel,
    this.checkboxPosition,
    bool? initialValue,
  })  : assert(initialValue == null || controller == null,
            'Cannot provide both a controller and an initialValue.'),
        super(
            initialValue: controller?.value ?? initialValue,
            builder: (state) => (state as _CheckboxFormFieldState).builder());

  /// Controls the state of the checkbox.
  ///
  /// If null, this checkbox will create its own [CheckboxController].
  /// and initialize it with [initialValue].
  final CheckboxController? controller;

  /// Called when the value of the checkbox changes.
  final ValueChanged<bool>? onChanged;

  /// The primary content of the list tile.
  ///
  /// Typically a [Text] widget.
  final Widget? title;

  /// {@macro flutter.material.checkbox.semanticLabel}
  final String? checkboxSemanticLabel;

  /// Where to place the control relative to the text.
  final ListTileControlAffinity? checkboxPosition;

  @override
  FormFieldState<bool> createState() => _CheckboxFormFieldState();
}

class _CheckboxFormFieldState extends FormFieldState<bool> {
  late final CheckboxController controller;

  @override
  CheckboxFormField get widget => super.widget as CheckboxFormField;

  @override
  void initState() {
    super.initState();

    controller = widget.controller ??
        CheckboxController(initialValue: widget.initialValue ?? false);
    controller.addListener(_handleControllerChanged);
  }

  @override
  void dispose() {
    controller.removeListener(_handleControllerChanged);
    super.dispose();
  }

  @override
  void didChange(bool? value) {
    super.didChange(value);
    if (controller.value != value) {
      controller.value = value!;
    }
  }

  @override
  void reset() {
    controller.value = widget.initialValue ?? false;
    super.reset();
  }

  void _handleControllerChanged() {
    if (controller.value != value) {
      didChange(controller.value);
    }
  }

  Widget builder() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CheckboxListTile(
          title: widget.title,
          value: value,
          onChanged: (bool? value) {
            didChange(value);
          },
          checkboxSemanticLabel: widget.checkboxSemanticLabel,
          controlAffinity:
              widget.checkboxPosition ?? ListTileControlAffinity.platform,
          contentPadding: const EdgeInsets.symmetric(horizontal: 4.0),
          isError: hasError,
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 4),
            child: Text(
              errorText!,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }
}
