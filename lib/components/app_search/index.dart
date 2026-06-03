import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:oolaf_flutted/components/app_search/app_search_types.dart';

class AppSearch extends StatefulWidget {
  const AppSearch({
    super.key,
    this.value = '',
    this.controller,
    this.focusNode,
    this.label,
    this.name,
    this.shape = AppSearchShape.square,
    this.id = 'app-search-input',
    this.background = const Color(0xFFF2F2F7),
    this.maxLength,
    this.placeholder,
    this.clearable = true,
    this.clearIcon = CupertinoIcons.clear_circled_solid,
    this.clearTrigger = AppSearchClearTrigger.focus,
    this.autofocus = false,
    this.showAction = false,
    this.actionText = '取消',
    this.disabled = false,
    this.readOnly = false,
    this.error = false,
    this.errorMessage,
    this.formatter,
    this.formatTrigger = AppSearchFormatTrigger.onChange,
    this.inputAlign = AppSearchTextAlign.left,
    this.leftIcon = CupertinoIcons.search,
    this.rightIcon,
    this.onChanged,
    this.onSubmitted,
    this.onSearch,
    this.onClear,
    this.onActionTap,
    this.onTap,
    this.onTapInput,
    this.onTapLeftIcon,
    this.onTapRightIcon,
    this.outerPadding = const EdgeInsets.fromLTRB(12, 10, 12, 10),
    this.fieldPadding = const EdgeInsets.symmetric(
      horizontal: 14,
      vertical: 12,
    ),
    this.borderRadius,
    this.fieldBorderRadius,
  });

  final String value;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? label;
  final String? name;
  final AppSearchShape shape;
  final String id;
  final Color background;
  final int? maxLength;
  final String? placeholder;
  final bool clearable;
  final IconData clearIcon;
  final AppSearchClearTrigger clearTrigger;
  final bool autofocus;
  final bool showAction;
  final String actionText;
  final bool disabled;
  final bool readOnly;
  final bool error;
  final String? errorMessage;
  final AppSearchFormatter? formatter;
  final AppSearchFormatTrigger formatTrigger;
  final AppSearchTextAlign inputAlign;
  final IconData leftIcon;
  final IconData? rightIcon;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onSearch;
  final VoidCallback? onClear;
  final VoidCallback? onActionTap;
  final VoidCallback? onTap;
  final VoidCallback? onTapInput;
  final VoidCallback? onTapLeftIcon;
  final VoidCallback? onTapRightIcon;
  final EdgeInsetsGeometry outerPadding;
  final EdgeInsetsGeometry fieldPadding;
  final double? borderRadius;
  final double? fieldBorderRadius;

  @override
  State<AppSearch> createState() => _AppSearchState();
}

class _AppSearchState extends State<AppSearch> {
  late final TextEditingController _textController;
  late final FocusNode _focusNode;
  late final bool _ownsTextController;
  late final bool _ownsFocusNode;
  bool _isFocused = false;

  bool get _showClear {
    return widget.clearable &&
        !widget.disabled &&
        !widget.readOnly &&
        _textController.text.isNotEmpty &&
        (widget.clearTrigger == AppSearchClearTrigger.always || _isFocused);
  }

  @override
  void initState() {
    super.initState();
    _ownsTextController = widget.controller == null;
    _ownsFocusNode = widget.focusNode == null;
    _textController =
        widget.controller ?? TextEditingController(text: widget.value);
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);
    _isFocused = _focusNode.hasFocus;
  }

  @override
  void didUpdateWidget(covariant AppSearch oldWidget) {
    super.didUpdateWidget(oldWidget);
    final shouldSyncFromValue =
        widget.controller == null &&
        oldWidget.value != widget.value &&
        widget.value != _textController.text;
    if (shouldSyncFromValue) {
      _textController.value = _textController.value.copyWith(
        text: widget.value,
        selection: TextSelection.collapsed(offset: widget.value.length),
        composing: TextRange.empty,
      );
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    if (_ownsFocusNode) {
      _focusNode.dispose();
    }
    if (_ownsTextController) {
      _textController.dispose();
    }
    super.dispose();
  }

  void _handleFocusChange() {
    final isFocused = _focusNode.hasFocus;
    if (_isFocused == isFocused) {
      return;
    }

    setState(() {
      _isFocused = isFocused;
    });

    if (!isFocused &&
        widget.formatter != null &&
        widget.formatTrigger == AppSearchFormatTrigger.onBlur) {
      _applyFormattedValue(widget.formatter!(_textController.text));
    }
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
        widget.formatTrigger == AppSearchFormatTrigger.onChange) {
      nextValue = widget.formatter!(rawValue);
    }

    if (nextValue != rawValue) {
      _applyFormattedValue(nextValue);
    } else {
      widget.onChanged?.call(nextValue);
    }

    setState(() {});
  }

  void _handleClear() {
    _textController.clear();
    widget.onChanged?.call('');
    widget.onClear?.call();
    setState(() {});
    _focusNode.requestFocus();
  }

  void _handleSubmit(String value) {
    final currentValue = _textController.text;
    widget.onSubmitted?.call(currentValue);
    widget.onSearch?.call(currentValue);
  }

  @override
  Widget build(BuildContext context) {
    final fieldRadius = widget.fieldBorderRadius ??
        (widget.shape == AppSearchShape.round ? 999.0 : 22.0);
    final outerRadius = widget.borderRadius ?? 24.0;
    final fieldBorderColor = widget.error
        ? const Color(0x33FF3B30)
        : _isFocused
            ? const Color(0x333A7BFF)
            : const Color(0x10000000);
    final hasTrailingSlot = widget.clearable || widget.rightIcon != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          padding: widget.outerPadding,
          decoration: BoxDecoration(
            color: widget.background,
            borderRadius: BorderRadius.circular(outerRadius),
          ),
          child: Row(
            children: [
              if (widget.label != null && widget.label!.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Text(
                    widget.label!,
                    style: TextStyle(
                      color: widget.disabled
                          ? const Color(0xFFB6BDC9)
                          : const Color(0xFF4B5563),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    widget.onTap?.call();
                    widget.onTapInput?.call();
                    if (!widget.disabled && !widget.readOnly) {
                      _focusNode.requestFocus();
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOutCubic,
                    padding: widget.fieldPadding,
                    decoration: BoxDecoration(
                      color: widget.disabled
                          ? const Color(0x99FFFFFF)
                          : const Color(0xEFFFFFFF),
                      borderRadius: BorderRadius.circular(fieldRadius),
                      border: Border.all(color: fieldBorderColor),
                      boxShadow: _isFocused
                          ? const [
                              BoxShadow(
                                color: Color(0x143A7BFF),
                                blurRadius: 18,
                                offset: Offset(0, 8),
                              ),
                            ]
                          : const [
                              BoxShadow(
                                color: Color(0x08000000),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: widget.onTapLeftIcon,
                          child: Icon(
                            widget.leftIcon,
                            size: 16,
                            color: widget.disabled
                                ? const Color(0xFFB6BDC9)
                                : const Color(0xFF7A869A),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: CupertinoTextField.borderless(
                            controller: _textController,
                            focusNode: _focusNode,
                            autofocus: widget.autofocus,
                            enabled: !widget.disabled,
                            readOnly: widget.readOnly,
                            placeholder: widget.placeholder,
                            maxLength: widget.maxLength,
                            textAlign:
                                appSearchTextAlignToTextAlign(widget.inputAlign),
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.search,
                            style: TextStyle(
                              color: widget.disabled
                                  ? const Color(0xFFB6BDC9)
                                  : const Color(0xFF111827),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              height: 1.2,
                            ),
                            placeholderStyle: const TextStyle(
                              color: Color(0xFF9AA3B2),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            padding: EdgeInsets.zero,
                            decoration: null,
                            onChanged: _handleChanged,
                            onSubmitted: _handleSubmit,
                            inputFormatters: widget.maxLength == null
                                ? null
                                : <TextInputFormatter>[
                                    LengthLimitingTextInputFormatter(
                                      widget.maxLength,
                                    ),
                                  ],
                          ),
                        ),
                        if (hasTrailingSlot) ...[
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: _showClear
                                ? GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: _handleClear,
                                    child: Icon(
                                      widget.clearIcon,
                                      size: 16,
                                      color: const Color(0xFF98A2B3),
                                    ),
                                  )
                                : widget.rightIcon != null
                                    ? GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onTap: widget.onTapRightIcon,
                                        child: Icon(
                                          widget.rightIcon,
                                          size: 16,
                                          color: const Color(0xFF667085),
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                          ),
                        ] else if (widget.rightIcon != null) ...[
                          const SizedBox(width: 8),
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: widget.onTapRightIcon,
                            child: Icon(
                              widget.rightIcon,
                              size: 16,
                              color: const Color(0xFF667085),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              if (widget.showAction) ...[
                const SizedBox(width: 10),
                CupertinoButton(
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  onPressed: widget.disabled
                      ? null
                      : () {
                          _focusNode.unfocus();
                          widget.onActionTap?.call();
                        },
                  child: Text(
                    widget.actionText,
                    style: const TextStyle(
                      color: Color(0xFF2563EB),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (widget.errorMessage != null && widget.errorMessage!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Align(
              alignment: appSearchAlignment(widget.inputAlign),
              child: Text(
                widget.errorMessage!,
                style: const TextStyle(
                  color: Color(0xFFFF3B30),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
                textAlign: appSearchTextAlignToTextAlign(widget.inputAlign),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
