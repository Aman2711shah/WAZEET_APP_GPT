import 'package:flutter/material.dart';

/// A small floating button that appears after scrolling and scrolls back to top.
class BackToTopButton extends StatefulWidget {
  final ScrollController controller;
  final double showOffset;

  const BackToTopButton({
    super.key,
    required this.controller,
    this.showOffset = 400,
  });

  @override
  State<BackToTopButton> createState() => _BackToTopButtonState();
}

class _BackToTopButtonState extends State<BackToTopButton> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onScroll);
    // Initialize state in case controller already has offset
    _visible =
        widget.controller.hasClients &&
        widget.controller.offset > widget.showOffset;
  }

  @override
  void didUpdateWidget(covariant BackToTopButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onScroll);
      widget.controller.addListener(_onScroll);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    final shouldShow = widget.controller.offset > widget.showOffset;
    if (shouldShow != _visible && mounted) {
      setState(() => _visible = shouldShow);
    }
  }

  Future<void> _scrollToTop() async {
    if (!widget.controller.hasClients) return;
    await widget.controller.animateTo(
      0,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Scroll to top',
      child: AnimatedScale(
        duration: const Duration(milliseconds: 180),
        scale: _visible ? 1 : 0.8,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 180),
          opacity: _visible ? 1 : 0,
          child: IgnorePointer(
            ignoring: !_visible,
            child: FloatingActionButton(
              onPressed: _scrollToTop,
              tooltip: 'Scroll to top',
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              elevation: 6,
              child: const Icon(Icons.arrow_upward),
            ),
          ),
        ),
      ),
    );
  }
}
