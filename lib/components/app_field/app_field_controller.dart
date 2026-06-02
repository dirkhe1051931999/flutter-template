import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/components/app_field/app_field_types.dart';

class AppFieldController {
  TextEditingController? _textEditingController;
  FocusNode? _focusNode;
  Future<AppFieldValidateResult> Function()? _validate;

  String get text => _textEditingController?.text ?? '';

  set text(String value) {
    final controller = _textEditingController;
    if (controller == null) {
      return;
    }
    controller.value = controller.value.copyWith(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
      composing: TextRange.empty,
    );
  }

  void focus() {
    _focusNode?.requestFocus();
  }

  void blur() {
    _focusNode?.unfocus();
  }

  Future<AppFieldValidateResult> validate() async {
    final callback = _validate;
    if (callback == null) {
      return const AppFieldValidateResult(
        status: AppFieldValidationStatus.passed,
        message: '',
      );
    }
    return callback();
  }

  void bind({
    required TextEditingController textEditingController,
    required FocusNode focusNode,
    required Future<AppFieldValidateResult> Function() validate,
  }) {
    _textEditingController = textEditingController;
    _focusNode = focusNode;
    _validate = validate;
  }

  void unbind() {
    _textEditingController = null;
    _focusNode = null;
    _validate = null;
  }
}
