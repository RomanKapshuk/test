import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';

import 'package:visibility_detector/visibility_detector.dart';

@Deprecated('Please use the TestBaseTextFormField widget instead')
Widget TestTextField(Color cursorColor, bool obscureText, String placeholder, TextStyle textStyle,
    bool enabled, Widget suffix, VoidCallback onChange, bool autofocus) {
  return TextFormField(
    enabled: enabled,
    cursorColor: cursorColor,
    obscureText: obscureText,
    autofocus: autofocus,
    decoration: InputDecoration(
      isDense: true,
      border: InputBorder.none,
      focusedBorder: InputBorder.none,
      enabledBorder: InputBorder.none,
      errorBorder: InputBorder.none,
      disabledBorder: InputBorder.none,
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      focusColor: Colors.red,
      hintText: placeholder,
      hintStyle: textStyle,
      suffixIcon: suffix,
    ),
  );
}

class TestBaseTextFormField extends StatefulWidget {
  const TestBaseTextFormField({
    this.enabled = true,
    this.obscureText = false,
    this.autofocus = false,
    this.isDense = true,
    this.isCollapsed = false,
    this.readOnly = false,
    this.filled = false,
    this.required = false,
    this.isErrorMessageInside = true,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.inputFormatters,
    this.autoValidateMode,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization,
    this.cursorColor,
    this.fillColor,
    this.focusColor,
    this.label,
    this.semanticLabel,
    this.hintText,
    this.focusNode,
    this.textStyle,
    this.style,
    this.hintStyle,
    this.labelStyle,
    this.errorStyle,
    this.contentPadding,
    this.outsideErrorPadding,
    this.scrollPadding,
    this.margin,
    this.decoration,
    this.suffixIconConstraints,
    this.suffixIcon,
    this.prefixIcon,
    this.prefixIconConstraints,
    this.suffix,
    this.inputBorder,
    this.minLines,
    this.maxLines = 1,
    required this.controller,
    this.onChanged,
    this.onEditingComplete,
    this.validator,
    this.maxLength,
    this.minFontSize,
    this.onFieldSubmitted,
    this.autoScale = false,
    this.autoTextSize = false,
    this.contextMenuBuilder,
    this.dismissFocusOnGone = false,
    this.onTap,
    this.overflow,
    this.scrollController,
    Key? key,
  })  : assert(
          !enabled
              ? autoScale
                  ? minFontSize != null
                  : true
              : true,
          'with enabled autoScale the minFontSize mustn\'t be null',
        ),
        assert(
          !autoScale && !autoTextSize && overflow == null ||
              !autoScale && !autoTextSize && overflow != null ||
              autoScale && !autoTextSize && overflow == null ||
              !autoScale && autoTextSize && overflow == null,
          'with enabled autoScale the text overflow is not possible, please choose either autoScale or autoTextSize or overflow',
        ),
        super(key: key);

  final bool enabled;
  final bool obscureText;
  final bool autofocus;
  final bool isDense;
  final bool isCollapsed;
  final bool readOnly;
  final bool filled;
  final bool required;
  final bool autocorrect;
  final bool enableSuggestions;
  final bool autoScale;
  final bool autoTextSize;
  final bool dismissFocusOnGone;

  // Если нужно отобразить ошибку валидации вне области текстового
  // поля (под серым закругленным прямоугольником) - передавать false
  final bool isErrorMessageInside;

  final List<TextInputFormatter>? inputFormatters;
  final AutovalidateMode? autoValidateMode;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization? textCapitalization;

  final Color? cursorColor;
  final Color? fillColor;
  final Color? focusColor;

  final String? label;
  final String? semanticLabel;
  final String? hintText;
  final FocusNode? focusNode;
  final TextStyle? textStyle;
  final TextStyle? style;
  final TextStyle? hintStyle;
  final TextStyle? labelStyle;
  final TextStyle? errorStyle;
  final EdgeInsetsGeometry? contentPadding;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? outsideErrorPadding;
  final EdgeInsets? scrollPadding;

  final BoxDecoration? decoration;

  final BoxConstraints? suffixIconConstraints;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final BoxConstraints? prefixIconConstraints;
  final Widget? suffix;

  final InputBorder? inputBorder;
  final int? minLines;
  final int maxLines;
  final int? maxLength;
  final double? minFontSize;

  final TextEditingController controller;
  final ScrollController? scrollController;

  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final FormFieldValidator<String>? validator;
  final Function(String term)? onFieldSubmitted;
  final EditableTextContextMenuBuilder? contextMenuBuilder;
  final TextOverflow? overflow;

  final GestureTapCallback? onTap;

  @override
  State<TestBaseTextFormField> createState() => _TestBaseTextFormFieldState();
}

class _TestBaseTextFormFieldState extends State<TestBaseTextFormField> {
  final errorNotifier = _TestErrorNotifier();
  bool _interactiveSelection = true;
  late final Key _visibilityDetectorKey;
  static const int _visiblePercentToGone = 90;
  double _prefixIconWidth = 0.0;
  double _suffixWidth = 0.0;
  double _suffixIconWidth = 0.0;

  @override
  void initState() {
    super.initState();
    _prefixIconWidth = widget.prefixIconConstraints?.maxWidth ?? 0.0;
    _suffixIconWidth = widget.suffixIconConstraints?.maxWidth ?? 0.0;
    _visibilityDetectorKey = UniqueKey();
    widget.controller.addListener(_cleanTextControllerStateOnInvalidSelection);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_cleanTextControllerStateOnInvalidSelection);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    const defaultDecoration = BoxDecoration(
      color: Colors.transparent,
      borderRadius: BorderRadius.all(Radius.circular(14)),
    );

    const defaultErrorTextStyle = TextStyle(
      fontSize: 13,
      color: Colors.orange,
    );
    final errorTextStyle = defaultErrorTextStyle.merge(widget.errorStyle);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: widget.decoration ?? defaultDecoration,
          child: buildTextField(context, screenWidth),
        ),
        if (!widget.isErrorMessageInside)
          ValueListenableBuilder<String?>(
            valueListenable: errorNotifier,
            builder: (BuildContext context, String? value, Widget? child) {
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: value == null
                    ? const SizedBox()
                    : Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Padding(
                          padding: widget.outsideErrorPadding ??
                              const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 16,
                              ),
                          child: Text(value, style: errorTextStyle),
                        ),
                      ),
              );
            },
          ),
      ],
    );
  }

  Widget buildTextField(BuildContext context, double screenWidth) {
    // Определяем свойства по умолчанию в соответствии с дизайном
    const defaultContentPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 13);

    TextStyle defaultTextStyle = widget.textStyle ?? const TextStyle();

    defaultTextStyle = defaultTextStyle.copyWith(
      fontSize: widget.autoTextSize
          ? defaultTextStyle.fontSize! * textScaleFactorOf(screenWidth)
          : defaultTextStyle.fontSize,
    );

    const defaultErrorTextStyle = TextStyle();

    const defaultLabelTextStyle = TextStyle();

    final defaultHintTextStyle = defaultTextStyle.copyWith(
      color: Colors.red,
    );

    final providedTextStyle = widget.style?.copyWith(
          fontSize: widget.autoTextSize
              ? (widget.style?.fontSize ?? 13) * textScaleFactorOf(screenWidth)
              : (widget.style?.fontSize ?? 13),
        ) ??
        const TextStyle();

    final contentPadding = widget.isErrorMessageInside
        ? EdgeInsets.zero
        : widget.contentPadding ?? defaultContentPadding;

    final errorTextStyle = defaultErrorTextStyle.merge(widget.errorStyle);
    TextStyle primaryTextStyle = defaultTextStyle.merge(providedTextStyle);
    TextStyle labelTextStyle = defaultLabelTextStyle.merge(widget.labelStyle);
    TextStyle hintTextStyle = defaultHintTextStyle.merge(widget.hintStyle);

    if (!widget.enabled) {
      primaryTextStyle = primaryTextStyle.copyWith(color: Colors.black);
      labelTextStyle = labelTextStyle.copyWith(color: Colors.purple);
      hintTextStyle = hintTextStyle.copyWith(color: Colors.pink);
    }

    if (primaryTextStyle.letterSpacing == null || primaryTextStyle.letterSpacing == 0) {
      primaryTextStyle = primaryTextStyle.copyWith(letterSpacing: 0.25);
    }

    Widget? labelWidget;
    if (widget.label != null) {
      labelWidget = Text(widget.label ?? '', style: labelTextStyle);
    }

    return Padding(
      padding: widget.isErrorMessageInside
          ? widget.contentPadding ?? defaultContentPadding
          : EdgeInsets.zero,
      child: widget.autoScale
          ? AutoScaleFontSize(
              initialTextStyle: primaryTextStyle,
              initialHintStyle: hintTextStyle,
              hintText: widget.hintText ?? '',
              text: widget.controller.text,
              minTextSize: widget.minFontSize ?? 0.0,
              builder: (textStyle, hintStyle) => _textField(
                textStyle,
                labelWidget,
                hintStyle,
                errorTextStyle,
                widget.controller,
                contentPadding,
              ),
            )
          : widget.overflow != null
              ? _textFieldOverflow(
                  primaryTextStyle,
                  contentPadding,
                  labelWidget,
                  hintTextStyle,
                  errorTextStyle,
                )
              : _textField(
                  primaryTextStyle,
                  labelWidget,
                  hintTextStyle,
                  errorTextStyle,
                  widget.controller,
                  contentPadding,
                ),
    );
  }

  String? baseRequiredFieldValidator(String? value) {
    if (!widget.required) return null;

    if (value == null || value.isEmpty) {
      return 'validationErrorRequired';
    }
    return null;
  }

  Widget _textField(
    TextStyle textStyle,
    Widget? labelWidget,
    TextStyle hintTextStyle,
    TextStyle errorTextStyle,
    TextEditingController controller,
    EdgeInsetsGeometry contentPadding, {
    Widget? Function()? suffixWrapper,
    Widget? Function()? suffixIconWrapper,
    Widget? Function()? prefixIconWrapper,
  }) {
    if (widget.dismissFocusOnGone) {
      return VisibilityDetector(
        key: _visibilityDetectorKey,
        onVisibilityChanged: (visibilityInfo) {
          final visiblePercentage = visibilityInfo.visibleFraction * 100;
          if (visiblePercentage <= _visiblePercentToGone &&
              _interactiveSelection &&
              widget.focusNode?.hasFocus == true &&
              hasSelection()) {
            _interactiveSelection = false;
            widget.focusNode?.unfocus();
          } else if (visiblePercentage >= 100 && !_interactiveSelection) {
            _interactiveSelection = true;
          }
        },
        child: _plainTextField(
          textStyle,
          labelWidget,
          hintTextStyle,
          errorTextStyle,
          controller,
          contentPadding,
          suffixWrapper: suffixWrapper,
          suffixIconWrapper: suffixIconWrapper,
          prefixIconWrapper: prefixIconWrapper,
        ),
      );
    }

    return _plainTextField(
      textStyle,
      labelWidget,
      hintTextStyle,
      errorTextStyle,
      controller,
      contentPadding,
      suffixWrapper: suffixWrapper,
      suffixIconWrapper: suffixIconWrapper,
      prefixIconWrapper: prefixIconWrapper,
    );
  }

  Widget _plainTextField(
    TextStyle textStyle,
    Widget? labelWidget,
    TextStyle hintTextStyle,
    TextStyle errorTextStyle,
    TextEditingController controller,
    EdgeInsetsGeometry contentPadding, {
    Widget? Function()? suffixWrapper,
    Widget? Function()? suffixIconWrapper,
    Widget? Function()? prefixIconWrapper,
  }) =>
      Semantics(
        label: widget.semanticLabel,
        child: TextFormField(
          onTap: widget.onTap,
          scrollPadding: widget.scrollPadding ?? const EdgeInsets.all(20),
          cursorColor: widget.cursorColor ?? Colors.amberAccent,
          validator: (String? string) {
            final errorMessage = (widget.validator ?? baseRequiredFieldValidator).call(string);

            if (widget.isErrorMessageInside) {
              return errorMessage;
            }

            if (errorNotifier.value != errorMessage) {
              WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                errorNotifier.value = errorMessage;
              });
            }
            return null;
          },
          enableSuggestions: widget.enableSuggestions,
          autocorrect: widget.autocorrect,
          obscureText: widget.obscureText,
          controller: controller,
          autofocus: widget.autofocus,
          readOnly: widget.readOnly,
          enabled: widget.enabled,
          minLines: widget.minLines,
          maxLines: widget.maxLines,
          maxLength: widget.maxLength,
          onChanged: widget.onChanged,
          focusNode: widget.focusNode,
          scrollController: widget.scrollController,
          onEditingComplete: widget.onEditingComplete,
          style: textStyle,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          inputFormatters: widget.inputFormatters,
          autovalidateMode: widget.autoValidateMode,
          textCapitalization: widget.textCapitalization ?? TextCapitalization.none,
          onFieldSubmitted: widget.onFieldSubmitted,
          contextMenuBuilder: widget.contextMenuBuilder ?? _defaultContextMenuBuilder,
          decoration: InputDecoration(
            isDense: widget.isDense,
            filled: widget.filled,
            isCollapsed: widget.isCollapsed,
            counterText: '',
            counterStyle: const TextStyle(fontSize: 0.0),
            label: labelWidget,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            border: widget.inputBorder ?? InputBorder.none,
            errorBorder: widget.inputBorder ?? InputBorder.none,
            focusedBorder: widget.inputBorder ?? InputBorder.none,
            enabledBorder: widget.inputBorder ?? InputBorder.none,
            disabledBorder: widget.inputBorder ?? InputBorder.none,
            focusedErrorBorder: widget.inputBorder ?? InputBorder.none,
            fillColor: widget.fillColor ?? Colors.grey,
            focusColor: widget.focusColor ?? Colors.amber,
            hintText: widget.hintText,
            hintStyle: hintTextStyle,
            errorStyle: errorTextStyle,
            suffix: suffixWrapper != null ? suffixWrapper() : widget.suffix,
            suffixIcon: suffixIconWrapper != null ? suffixIconWrapper() : widget.suffixIcon,
            prefixIcon: prefixIconWrapper != null ? prefixIconWrapper() : widget.prefixIcon,
            suffixIconConstraints: widget.suffixIconConstraints,
            prefixIconConstraints: widget.prefixIconConstraints,
            contentPadding: widget.isErrorMessageInside
                ? EdgeInsets.zero
                : widget.contentPadding ?? contentPadding,
          ),
        ),
      );

  TextOverflowWidget _textFieldOverflow(
    TextStyle primaryTextStyle,
    EdgeInsetsGeometry contentPadding,
    Widget? labelWidget,
    TextStyle hintTextStyle,
    TextStyle errorTextStyle,
  ) =>
      TextOverflowWidget(
        initialTextStyle: primaryTextStyle,
        originalController: widget.controller,
        focusNode: widget.focusNode,
        verticalOffset: contentPadding.vertical +
            _prefixIconWidth.nonNaN +
            _suffixIconWidth.nonNaN +
            _suffixWidth,
        maxLines: widget.maxLines,
        builder: (controller) {
          final isNeedMeasurePrefixWidth = widget.prefixIconConstraints == null ||
              _prefixIconWidth.isNaN ||
              _prefixIconWidth.isInfinite;
          final isNeedMeasureSuffixWidth = widget.suffixIconConstraints == null ||
              _suffixIconWidth.isNaN ||
              _suffixIconWidth.isInfinite;
          return _textField(
            primaryTextStyle,
            labelWidget,
            hintTextStyle,
            errorTextStyle,
            controller,
            contentPadding,
            prefixIconWrapper: widget.prefixIcon != null && isNeedMeasurePrefixWidth
                ? () => WidgetSizeWrapper(
                      onSizeChange: (size) {
                        _prefixIconWidth = size.width;
                      },
                      child: widget.prefixIcon!,
                    )
                : () => widget.prefixIcon,
            suffixWrapper: widget.suffix != null
                ? () => WidgetSizeWrapper(
                      onSizeChange: (size) {
                        _suffixWidth = size.width;
                      },
                      child: widget.suffix!,
                    )
                : () => widget.suffix,
            suffixIconWrapper: widget.suffixIcon != null && isNeedMeasureSuffixWidth
                ? () => WidgetSizeWrapper(
                      onSizeChange: (size) {
                        _suffixIconWidth = size.width;
                      },
                      child: widget.suffixIcon!,
                    )
                : () => widget.suffixIcon,
          );
        },
      );

  static Widget _defaultContextMenuBuilder(
      BuildContext context, EditableTextState editableTextState) {
    return AdaptiveTextSelectionToolbar.editableText(
      editableTextState: editableTextState,
    );
  }

  // This will fix the android issue when using number keyboard
  // flutter can set the text selection as invalid
  void _cleanTextControllerStateOnInvalidSelection() {
    if (!widget.controller.selection.isValid && widget.controller.text.isEmpty) {
      widget.controller.clear();
    }
  }

  bool hasSelection() {
    final start = widget.controller.selection.start;
    final end = widget.controller.selection.end;
    return start != end;
  }
}

final class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

class _TestErrorNotifier extends ValueNotifier<String?> {
  _TestErrorNotifier({String? value}) : super(value);
}

double textScaleFactorOf(double width, {bool testIos = false}) {
  if (Platform.isIOS || testIos) {
    if (width <= 320) {
      return 0.90;
    } else if (width < 414) {
      return 0.97;
    }
  } else {
    if (width <= 360) {
      return 0.90;
    } else if (width < 380) {
      return 0.97;
    }
  }
  return 1;
}

const ellipsisString = '...';

@immutable
class TextOverflowWidget extends StatefulWidget {
  final TextStyle _initialTextStyle;
  final TextEditingController _originalController;
  final FocusNode? _focusNode;
  final double _verticalOffset;
  final int maxLines;

  final Widget Function(TextEditingController controller) _builder;

  const TextOverflowWidget({
    super.key,
    required Widget Function(TextEditingController controller) builder,
    required TextStyle initialTextStyle,
    required TextEditingController originalController,
    required FocusNode? focusNode,
    double verticalOffset = 0,
    required this.maxLines,
  })  : _builder = builder,
        _initialTextStyle = initialTextStyle,
        _originalController = originalController,
        _focusNode = focusNode,
        _verticalOffset = verticalOffset;

  @override
  State<StatefulWidget> createState() => _TextOverflowWidgetState();
}

class _TextOverflowWidgetState extends State<TextOverflowWidget> {
  final TextEditingController _overflowController = TextEditingController();
  late TextEditingController _controller;

  late final double _ellipsisTextWidth;
  double _textLayoutWidth = double.infinity;

  @override
  void initState() {
    _controller = widget._originalController;
    _controller.addListener(_onOriginalControllerChanged);
    widget._focusNode?.addListener(_focusListener);
    _ellipsisTextWidth = StringTools.calcTextSize(ellipsisString, widget._initialTextStyle,
            maxLines: widget.maxLines)
        .width;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final unfocused = !(widget._focusNode?.hasFocus ?? true);
      final hasTextOverflowed = _hasOverflowed();
      if (unfocused && hasTextOverflowed) {
        _ellipsizeText();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    widget._focusNode?.removeListener(_focusListener);
    widget._originalController.removeListener(_onOriginalControllerChanged);
    super.dispose();
  }

  _focusListener() {
    final unfocused = !(widget._focusNode?.hasFocus ?? true);
    if (unfocused && _hasOverflowed()) {
      _ellipsizeText();
    } else {
      if (_controller != widget._originalController) {
        setState(() {
          _controller = widget._originalController;
        });
      }
    }
  }

  bool _hasOverflowed() {
    final textWidth = StringTools.calcTextSize(
            widget._originalController.text, widget._initialTextStyle,
            maxLines: widget.maxLines)
        .width;
    final textWidthLines = textWidth / widget.maxLines;
    return _textLayoutWidth - widget._verticalOffset - 4 < textWidthLines;
  }

  void _ellipsizeText() {
    setState(() {
      final newTextEllipsized = _calculateEllipsis(widget._originalController.text);
      _overflowController.text = newTextEllipsized;
      _controller = _overflowController;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _textLayoutWidth = constraints.maxWidth;
        return widget._builder(_controller);
      },
    );
  }

  String _calculateEllipsis(String text) {
    if (text.isEmpty) {
      return text;
    }

    final textWidth =
        StringTools.calcTextSize(text, widget._initialTextStyle, maxLines: widget.maxLines).width;
    final letterWidth = textWidth / text.length;
    final maxLettersLine = ((_textLayoutWidth - widget._verticalOffset) ~/ letterWidth) - 1;
    final maxLettersMultiLine = maxLettersLine * widget.maxLines;

    if (maxLettersMultiLine > text.length) {
      return text;
    }

    for (var i = maxLettersMultiLine; i > -1; i--) {
      final substringEllipsisText = text.substring(0, i);
      final subStringTextWidth = StringTools.calcTextSize(
              substringEllipsisText, widget._initialTextStyle,
              maxLines: widget.maxLines)
          .width;
      final subStringTextWidthLines = subStringTextWidth / widget.maxLines;
      if (subStringTextWidthLines + _ellipsisTextWidth + widget._verticalOffset <
          _textLayoutWidth) {
        return substringEllipsisText + ellipsisString;
      }
    }

    return text;
  }

  void _onOriginalControllerChanged() {
    final unfocused = !(widget._focusNode?.hasFocus ?? true);
    if (unfocused) {
      _ellipsizeText();
    }
  }
}

/// String tools
class StringTools {
  static const empty = '';
  static const emptySpace = ' ';

  static String formatByPattern(
      {String? stringToFormat = '',
      String? separator = ' ',
      required List<int> separatorPosition}) {
    if (stringToFormat == null || stringToFormat.length < separatorPosition.first) {
      return stringToFormat ?? '';
    }

    final resultString = StringBuffer();

    var currentPos = 0;

    for (final pos in separatorPosition) {
      if (currentPos > stringToFormat.length) {
        break;
      }
      if (pos > stringToFormat.length) {
        resultString
            .writeAll(stringToFormat.substring(currentPos, stringToFormat.length).characters);
      } else {
        resultString.writeAll(stringToFormat.substring(currentPos, pos).characters);
        resultString.write(separator);
      }

      currentPos = pos;
    }

    if (currentPos < stringToFormat.length) {
      resultString.writeAll(stringToFormat.substring(currentPos, stringToFormat.length).characters);
    }

    return resultString.toString();
  }

  static String? formatPhoneNumber(String? phone) {
    if (phone == null) return null;

    final digits = phone.replaceAll(RegExp(r'\D'), '');

    final regexp = RegExp(r'(\d{2})(\d{3})(\d{3})(\d{2})(\d{2})');

    if (regexp.hasMatch(digits)) {
      final match = regexp.firstMatch(digits);

      if (match != null) {
        return '+${match.group(1)} (${match.group(2)}) '
            '${match.group(3)}-${match.group(4)}-${match.group(5)}';
      }
    }

    return phone;
  }

  static bool isTextLongerLines(String text, TextStyle style, double maxWidth) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: style,
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxWidth);
    return textPainter.size.width >= maxWidth;
  }

  static String formatEllipsis(String text, TextStyle style, double maxWidth) {
    final isDotsNeeded = isTextLongerLines(text, style, maxWidth);
    if (isDotsNeeded) {
      String tempText = '';
      for (int i = 0; i < text.length; i++) {
        tempText += text[i];

        final isTempDotsNeeded = isTextLongerLines(tempText, style, maxWidth);

        if (isTempDotsNeeded) {
          return tempText.replaceRange(tempText.length - 3, tempText.length, ' ...');
        }
      }
    }
    return text;
  }

  static Size calcTextSize(String text, TextStyle style, {int maxLines = 1}) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      textScaleFactor: WidgetsBinding.instance.window.textScaleFactor,
      maxLines: maxLines,
    )..layout();
    return textPainter.size;
  }
}

extension DoubleExtension on double {
  double get nonNaN => isNaN || isInfinite ? 0.0 : this;
}

class WidgetSizeWrapper extends SingleChildRenderObjectWidget {
  final OnWidgetSizeChange onSizeChange;

  const WidgetSizeWrapper({
    Key? key,
    required this.onSizeChange,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return WidgetSizeRenderObject(onSizeChange);
  }
}

typedef OnWidgetSizeChange = void Function(Size size);

class WidgetSizeRenderObject extends RenderProxyBox {
  final OnWidgetSizeChange onSizeChange;
  Size? currentSize;

  WidgetSizeRenderObject(this.onSizeChange);

  @override
  void performLayout() {
    super.performLayout();

    final newSize = child?.size;

    if (newSize != null && currentSize != newSize) {
      currentSize = newSize;
      WidgetsBinding.instance.addPostFrameCallback((_) => onSizeChange(newSize));
    }
  }
}

@immutable
class AutoScaleFontSize extends StatelessWidget {
  final TextStyle _initialTextStyle;
  final TextStyle _initialHintStyle;

  final String _text;
  final String _hint;

  final double _minTextSize;
  final Widget Function(TextStyle textStyle, TextStyle hintStyle) _builder;

  const AutoScaleFontSize({
    super.key,
    required Widget Function(TextStyle textStyle, TextStyle hintStyle) builder,
    required TextStyle initialTextStyle,
    required String text,
    required double minTextSize,
    String hintText = '',
    TextStyle initialHintStyle = const TextStyle(),
  })  : _builder = builder,
        _initialTextStyle = initialTextStyle,
        _initialHintStyle = initialHintStyle,
        _text = text,
        _hint = hintText,
        _minTextSize = minTextSize;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final textLayoutWidth = constraints.maxWidth;

        final textWidth = StringTools.calcTextSize(_text, _initialTextStyle).width;
        final hintWidth = StringTools.calcTextSize(_hint, _initialHintStyle).width;

        TextStyle textStyle = _initialTextStyle;
        TextStyle hintStyle = _initialHintStyle;

        textStyle = autoScaleStyle(textWidth, textLayoutWidth, _initialTextStyle, _text);
        hintStyle = autoScaleStyle(hintWidth, textLayoutWidth, _initialHintStyle, _hint);

        return _builder(textStyle, hintStyle);
      },
    );
  }

  TextStyle autoScaleStyle(
      double textWidth, double textLayoutWidth, TextStyle textStyle, String text) {
    if (textWidth > textLayoutWidth) {
      final scaleFactor = textWidth / textLayoutWidth;
      double fontSize = textStyle.fontSize != null
          ? (textStyle.fontSize! / scaleFactor).floor() - 1.0
          : textStyle.fontSize ?? 0.0;
      fontSize = max(fontSize, _minTextSize);

      return textStyle.copyWith(fontSize: fontSize);
    }
    return textStyle;
  }
}
