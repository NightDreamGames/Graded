import 'package:flutter/material.dart';

import 'view_state.dart';

class DestinationTitleContent extends StatelessWidget {
  final String text;
  final TextStyle fontStyle;
  final int maxLines;
  final TextOverflow overflow;
  final bool isOverflow;

  const DestinationTitleContent({
    Key? key,
    required this.text,
    required this.fontStyle,
    required this.maxLines,
    required this.overflow,
    required this.isOverflow,
  }) : super(key: key);

  Widget _buildTitleText() => Text(
        text,
        maxLines: maxLines,
        overflow: overflow,
        style: fontStyle,
      );

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: isOverflow
          ? OverflowBox(
              alignment: Alignment.topLeft,
              maxWidth: double.infinity,
              maxHeight: double.infinity,
              child: _buildTitleText(),
            )
          : _buildTitleText(),
    );
  }
}

class DestinationTitle extends StatefulWidget {
  final String title;
  final ViewState viewState;
  final TextStyle beginFontStyle;
  final TextStyle endFontStyle;
  final int maxLines;
  final TextOverflow textOverflow;
  final bool isOverflow;

  const DestinationTitle({
    Key? key,
    required this.title,
    required this.viewState,
    this.beginFontStyle = const TextStyle(fontSize: 18.0, fontWeight: FontWeight.normal),
    this.endFontStyle = const TextStyle(fontSize: 42.0, fontWeight: FontWeight.bold),
    this.maxLines = 1,
    this.textOverflow = TextOverflow.visible,
    this.isOverflow = true,
  }) : super(key: key);

  @override
  _DestinationTitleState createState() => _DestinationTitleState();
}

class _DestinationTitleState extends State<DestinationTitle> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<TextStyle> _fontSizeTween;

  late TextStyle fontStyle;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 330),
    )..addListener(() {
        setState(() {
          fontStyle = _fontSizeTween.value;
        });
      });

    switch (widget.viewState) {
      case ViewState.enlarge:
        _fontSizeTween = TextStyleTween(
          begin: widget.beginFontStyle,
          end: widget.endFontStyle,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );

        _animationController.forward(from: 0.0);
        break;

      case ViewState.enlarged:
        fontStyle = widget.endFontStyle;
        break;

      case ViewState.shrink:
        _fontSizeTween = TextStyleTween(
          begin: widget.endFontStyle,
          end: widget.beginFontStyle,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );

        _animationController.forward(from: 0.0);

        Tween<TextStyle> a = TextStyleTween(
          begin: TextStyle(fontWeight: FontWeight.bold),
          end: TextStyle(fontWeight: FontWeight.bold),
        );

        break;

      case ViewState.shrunk:
        fontStyle = widget.beginFontStyle;
        break;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DestinationTitleContent(
      text: widget.title,
      fontStyle: fontStyle,
      maxLines: widget.maxLines,
      overflow: widget.textOverflow,
      isOverflow: widget.isOverflow,
    );
  }
}
