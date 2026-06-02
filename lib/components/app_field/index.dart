import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:oolaf_flutted/components/app_field/app_field_controller.dart';
import 'package:oolaf_flutted/components/app_field/app_field_types.dart';

class AppField extends StatefulWidget {
  const AppField({
    super.key,
    this.value = '',
    this.label,
    this.name,
    this.id,
    this.type = AppFieldType.text,
    this.size = AppFieldSize.normal,
    this.maxLength,
    this.min,
    this.max,
    this.placeholder,
    this.border = true,
    this.disabled = false,
    this.readOnly = false,
    this.colon = false,
    this.required,
    this.center = false,
    this.clearable = false,
    this.clearIcon = CupertinoIcons.clear_circled_solid,
    this.clearTrigger = AppFieldClearTrigger.focus,
    this.clickable = false,
    this.isLink = false,
    this.autofocus = false,
    this.showWordLimit = false,
    this.error = false,
    this.errorMessage,
    this.errorMessageAlign = AppFieldTextAlign.left,
    this.formatter,
    this.formatTrigger = AppFieldFormatTrigger.onChange,
    this.arrowDirection = AppFieldArrowDirection.right,
    this.labelWidth = 96,
    this.labelAlign = AppFieldTextAlign.left,
    this.inputAlign = AppFieldTextAlign.left,
    this.autosize = false,
    this.autosizeConfig,
    this.leftIcon,
    this.rightIcon,
    this.button,
    this.extra,
    this.rules = const <AppFieldRule>[],
    this.rows = 1,
    this.onChanged,
    this.onFocus,
    this.onBlur,
    this.onClear,
    this.onTap,
    this.onTapInput,
    this.onTapLeftIcon,
    this.onTapRightIcon,
    this.onStartValidate,
    this.onEndValidate,
    this.controller,
    this.autocomplete,
    this.autocapitalize,
    this.enterKeyHint,
    this.spellcheck,
    this.autocorrect,
    this.inputmode,
    this.labelWidget,
    this.errorMessageWidget,
  });

  final String value;
  final String? label;
  final String? name;
  final String? id;
  final AppFieldType type;
  final AppFieldSize size;
  final int? maxLength;
  final double? min;
  final double? max;
  final String? placeholder;
  final bool border;
  final bool disabled;
  final bool readOnly;
  final bool colon;
  final bool? required;
  final bool center;
  final bool clearable;
  final IconData clearIcon;
  final AppFieldClearTrigger clearTrigger;
  final bool clickable;
  final bool isLink;
  final bool autofocus;
  final bool showWordLimit;
  final bool error;
  final String? errorMessage;
  final AppFieldTextAlign errorMessageAlign;
  final AppFieldFormatter? formatter;
  final AppFieldFormatTrigger formatTrigger;
  final AppFieldArrowDirection arrowDirection;
  final double labelWidth;
  final AppFieldTextAlign labelAlign;
  final AppFieldTextAlign inputAlign;
  final bool autosize;
  final AppFieldAutosizeConfig? autosizeConfig;
  final Widget? leftIcon;
  final Widget? rightIcon;
  final Widget? button;
  final Widget? extra;
  final List<AppFieldRule> rules;
  final int rows;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFocus;
  final VoidCallback? onBlur;
  final VoidCallback? onClear;
  final VoidCallback? onTap;
  final VoidCallback? onTapInput;
  final VoidCallback? onTapLeftIcon;
  final VoidCallback? onTapRightIcon;
  final VoidCallback? onStartValidate;
  final ValueChanged<AppFieldValidateResult>? onEndValidate;
  final AppFieldController? controller;
  final String? autocomplete;
  final String? autocapitalize;
  final String? enterKeyHint;
  final bool? spellcheck;
  final String? autocorrect;
  final String? inputmode;
  final Widget? labelWidget;
  final Widget? errorMessageWidget;

  @override
  State<AppField> createState() => _AppFieldState();
}

class _AppFieldState extends State<AppField> {
  late final TextEditingController _textController;
  late final FocusNode _focusNode;
  bool _isFocused = false;
  String _internalErrorMessage = '';

  bool get _hasError =>
      widget.error ||
      (widget.errorMessage?.isNotEmpty ?? false) ||
      _internalErrorMessage.isNotEmpty;

  String get _effectiveErrorMessage => widget.errorMessage?.isNotEmpty == true
      ? widget.errorMessage!
      : _internalErrorMessage;

  bool get _canEdit => !widget.disabled && !widget.readOnly;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.value);
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChanged);
    widget.controller?.bind(
      textEditingController: _textController,
      focusNode: _focusNode,
      validate: _runValidate,
    );
  }

  @override
  void didUpdateWidget(covariant AppField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value &&
        widget.value != _textController.text) {
      _textController.value = _textController.value.copyWith(
        text: widget.value,
        selection: TextSelection.collapsed(offset: widget.value.length),
        composing: TextRange.empty,
      );
    }

    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.unbind();
      widget.controller?.bind(
        textEditingController: _textController,
        focusNode: _focusNode,
        validate: _runValidate,
      );
    }
  }

  @override
  void dispose() {
    widget.controller?.unbind();
    _focusNode
      ..removeListener(_handleFocusChanged)
      ..dispose();
    _textController.dispose();
    super.dispose();
  }

  void _handleFocusChanged() {
    final focused = _focusNode.hasFocus;
    if (_isFocused == focused) {
      return;
    }

    setState(() {
      _isFocused = focused;
    });

    if (focused) {
      widget.onFocus?.call();
      return;
    }

    if (widget.formatter != null &&
        widget.formatTrigger == AppFieldFormatTrigger.onBlur) {
      _applyFormattedValue(widget.formatter!(_textController.text));
    }
    _clampNumericValueIfNeeded();
    unawaited(_runValidate(trigger: AppFieldValidateTrigger.onBlur));
    widget.onBlur?.call();
  }

  void _applyFormattedValue(String nextValue) {
    if (nextValue == _textController.text) {
      return;
    }
    _textController.value = _textController.value.copyWith(
      text: nextValue,
      selection: TextSelection.collapsed(offset: nextValue.length),
      composing: TextRange.empty,
    );
    widget.onChanged?.call(nextValue);
  }

  void _handleChanged(String rawValue) {
    var nextValue = rawValue;
    if (widget.formatter != null &&
        widget.formatTrigger == AppFieldFormatTrigger.onChange) {
      nextValue = widget.formatter!(rawValue);
    }
    if (nextValue != rawValue) {
      _applyFormattedValue(nextValue);
    } else {
      widget.onChanged?.call(nextValue);
    }

    if (widget.rules.any(
      (rule) => rule.trigger == AppFieldValidateTrigger.onChange,
    )) {
      unawaited(_runValidate(trigger: AppFieldValidateTrigger.onChange));
    }
    setState(() {});
  }

  Future<AppFieldValidateResult> _runValidate({
    AppFieldValidateTrigger? trigger,
  }) async {
    widget.onStartValidate?.call();
    final value = _textController.text;

    for (final rule in widget.rules) {
      if (trigger != null && rule.trigger != trigger) {
        continue;
      }
      if (rule.required && value.trim().isEmpty) {
        return _finishValidate(
          const AppFieldValidateResult(
            status: AppFieldValidationStatus.failed,
            message: '',
          ),
          fallbackMessage: rule.message,
        );
      }
      if (rule.pattern != null &&
          value.isNotEmpty &&
          !rule.pattern!.hasMatch(value)) {
        return _finishValidate(
          const AppFieldValidateResult(
            status: AppFieldValidationStatus.failed,
            message: '',
          ),
          fallbackMessage: rule.message,
        );
      }
      if (rule.validator != null) {
        final message = rule.validator!(value);
        if (message != null && message.isNotEmpty) {
          return _finishValidate(
            AppFieldValidateResult(
              status: AppFieldValidationStatus.failed,
              message: message,
            ),
            fallbackMessage: rule.message,
          );
        }
      }
    }

    return _finishValidate(
      const AppFieldValidateResult(
        status: AppFieldValidationStatus.passed,
        message: '',
      ),
    );
  }

  AppFieldValidateResult _finishValidate(
    AppFieldValidateResult result, {
    String? fallbackMessage,
  }) {
    final message = result.message.isNotEmpty
        ? result.message
        : (result.status == AppFieldValidationStatus.failed
            ? (fallbackMessage ?? '')
            : '');
    final finalResult = AppFieldValidateResult(
      status: result.status,
      message: message,
    );
    if (mounted) {
      setState(() {
        _internalErrorMessage =
            finalResult.status == AppFieldValidationStatus.failed
                ? finalResult.message
                : '';
      });
    }
    widget.onEndValidate?.call(finalResult);
    return finalResult;
  }

  void _handleClear() {
    _textController.clear();
    widget.onChanged?.call('');
    widget.onClear?.call();
    setState(() {
      _internalErrorMessage = '';
    });
  }

  void _clampNumericValueIfNeeded() {
    if ((widget.type != AppFieldType.number &&
            widget.type != AppFieldType.digit) ||
        _textController.text.isEmpty) {
      return;
    }

    final parsed = double.tryParse(_textController.text);
    if (parsed == null) {
      return;
    }

    double nextValue = parsed;
    if (widget.min != null && nextValue < widget.min!) {
      nextValue = widget.min!;
    }
    if (widget.max != null && nextValue > widget.max!) {
      nextValue = widget.max!;
    }

    final formatted = widget.type == AppFieldType.digit
        ? nextValue.round().toString()
        : nextValue % 1 == 0
            ? nextValue.toInt().toString()
            : nextValue.toString();
    _applyFormattedValue(formatted);
  }

  @override
  Widget build(BuildContext context) {
    final showClear = widget.clearable &&
        _canEdit &&
        _textController.text.isNotEmpty &&
        (widget.clearTrigger == AppFieldClearTrigger.always || _isFocused);
    final showWordLimit = widget.showWordLimit && widget.maxLength != null;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        widget.onTap?.call();
        if (widget.clickable || widget.isLink || widget.readOnly) {
          _focusNode.unfocus();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: widget.disabled
              ? const Color(0xFFF3F4F6)
              : const Color(0xCCFFFFFF),
          borderRadius: BorderRadius.circular(
              widget.size == AppFieldSize.large ? 26 : 22),
          border: Border.all(
            color: _hasError
                ? const Color(0x33E5484D)
                : _isFocused
                    ? const Color(0x332E90FA)
                    : const Color(0x12000000),
          ),
          boxShadow: widget.clickable || widget.isLink || _isFocused
              ? const [
                  BoxShadow(
                    color: Color(0x10000000),
                    blurRadius: 18,
                    offset: Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            widget.size == AppFieldSize.large ? 16 : 14,
            16,
            widget.size == AppFieldSize.large ? 14 : 12,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment:
                    widget.center || widget.type != AppFieldType.textarea
                        ? CrossAxisAlignment.center
                        : CrossAxisAlignment.start,
                children: [
                  if (widget.leftIcon != null)
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: widget.onTapLeftIcon,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: widget.leftIcon,
                      ),
                    ),
                  SizedBox(
                    width: widget.labelWidth,
                    child: DefaultTextStyle(
                      style: TextStyle(
                        color: widget.disabled
                            ? const Color(0xFF98A2B3)
                            : const Color(0xFF111827),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      child: widget.labelWidget ??
                          Text.rich(
                            TextSpan(
                              children: [
                                if (widget.required == true)
                                  const TextSpan(
                                    text: '* ',
                                    style: TextStyle(color: Color(0xFFE5484D)),
                                  ),
                                TextSpan(
                                  text:
                                      '${widget.label ?? ''}${widget.colon && (widget.label?.isNotEmpty ?? false) ? ':' : ''}',
                                ),
                              ],
                            ),
                            textAlign:
                                appFieldTextAlignToTextAlign(widget.labelAlign),
                          ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          appFieldLabelCrossAxisAlignment(widget.inputAlign),
                      children: [
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            widget.onTapInput?.call();
                            if (!_canEdit) {
                              return;
                            }
                            _focusNode.requestFocus();
                          },
                          child: ConstrainedBox(
                            constraints: _autosizeConstraints(),
                            child: CupertinoTextField.borderless(
                              controller: _textController,
                              focusNode: _focusNode,
                              enabled: !widget.disabled,
                              readOnly: widget.readOnly ||
                                  widget.clickable ||
                                  widget.isLink,
                              autofocus: widget.autofocus,
                              placeholder: widget.placeholder,
                              keyboardType: _keyboardType(),
                              textInputAction: _textInputAction(),
                              obscureText: widget.type == AppFieldType.password,
                              maxLength: widget.maxLength,
                              maxLines: widget.type == AppFieldType.textarea
                                  ? (widget.autosize ? null : widget.rows)
                                  : 1,
                              minLines: widget.type == AppFieldType.textarea
                                  ? widget.rows
                                  : 1,
                              textAlign: appFieldTextAlignToTextAlign(
                                  widget.inputAlign),
                              style: TextStyle(
                                color: widget.disabled
                                    ? const Color(0xFF98A2B3)
                                    : const Color(0xFF111827),
                                fontSize:
                                    widget.size == AppFieldSize.large ? 16 : 15,
                                fontWeight: FontWeight.w600,
                                height: 1.35,
                              ),
                              placeholderStyle: const TextStyle(
                                color: Color(0xFF98A2B3),
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                              inputFormatters: _inputFormatters(),
                              autocorrect:
                                  (widget.autocorrect ?? 'default') != 'off',
                              textCapitalization: _textCapitalization(),
                              onChanged: _handleChanged,
                            ),
                          ),
                        ),
                        if (_effectiveErrorMessage.isNotEmpty ||
                            showWordLimit ||
                            widget.extra != null) ...[
                          const SizedBox(height: 10),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Align(
                                  alignment: appFieldErrorAlignment(
                                      widget.errorMessageAlign),
                                  child: widget.errorMessageWidget ??
                                      (_effectiveErrorMessage.isEmpty
                                          ? const SizedBox.shrink()
                                          : Text(
                                              _effectiveErrorMessage,
                                              textAlign:
                                                  appFieldTextAlignToTextAlign(
                                                widget.errorMessageAlign,
                                              ),
                                              style: const TextStyle(
                                                color: Color(0xFFE5484D),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                height: 1.35,
                                              ),
                                            )),
                                ),
                              ),
                              if (widget.extra != null) ...[
                                const SizedBox(width: 10),
                                widget.extra!,
                              ],
                              if (showWordLimit) ...[
                                const SizedBox(width: 10),
                                Text(
                                  '${_textController.text.characters.length}/${widget.maxLength}',
                                  style: const TextStyle(
                                    color: Color(0xFF98A2B3),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (showClear)
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _handleClear,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Icon(
                          widget.clearIcon,
                          size: 18,
                          color: const Color(0xFF98A2B3),
                        ),
                      ),
                    ),
                  if (widget.rightIcon != null)
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: widget.onTapRightIcon,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: widget.rightIcon,
                      ),
                    ),
                  if (widget.button != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: widget.button,
                    ),
                  if (widget.isLink)
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Icon(
                        appFieldArrowIcon(widget.arrowDirection),
                        size: 16,
                        color: const Color(0xFF98A2B3),
                      ),
                    ),
                ],
              ),
              if (widget.border) ...[
                const SizedBox(height: 12),
                Container(
                  height: 1,
                  color: const Color(0x0F000000),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  BoxConstraints _autosizeConstraints() {
    if (widget.type != AppFieldType.textarea || !widget.autosize) {
      return const BoxConstraints();
    }
    return BoxConstraints(
      minHeight: widget.autosizeConfig?.minHeight ?? widget.rows * 22,
      maxHeight: widget.autosizeConfig?.maxHeight ?? 180,
    );
  }

  TextCapitalization _textCapitalization() {
    return switch (widget.autocapitalize) {
      'characters' => TextCapitalization.characters,
      'words' => TextCapitalization.words,
      'sentences' => TextCapitalization.sentences,
      _ => TextCapitalization.none,
    };
  }

  TextInputAction _textInputAction() {
    return switch (widget.enterKeyHint) {
      'done' => TextInputAction.done,
      'search' => TextInputAction.search,
      'send' => TextInputAction.send,
      'next' => TextInputAction.next,
      'go' => TextInputAction.go,
      _ => widget.type == AppFieldType.textarea
          ? TextInputAction.newline
          : TextInputAction.done,
    };
  }

  TextInputType _keyboardType() {
    if (widget.inputmode == 'numeric') {
      return TextInputType.number;
    }
    return switch (widget.type) {
      AppFieldType.number =>
        const TextInputType.numberWithOptions(decimal: true),
      AppFieldType.digit => TextInputType.number,
      AppFieldType.textarea => TextInputType.multiline,
      AppFieldType.password => TextInputType.visiblePassword,
      _ => TextInputType.text,
    };
  }

  List<TextInputFormatter>? _inputFormatters() {
    final formatters = <TextInputFormatter>[];
    if (widget.type == AppFieldType.digit) {
      formatters.add(FilteringTextInputFormatter.digitsOnly);
    } else if (widget.type == AppFieldType.number) {
      formatters.add(
        FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*')),
      );
    }
    return formatters.isEmpty ? null : formatters;
  }
}
