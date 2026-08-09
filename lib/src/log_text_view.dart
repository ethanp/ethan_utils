import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// One rendered log line for [LogTextView].
class LogTextLine {
  const LogTextLine({
    required this.text,
    this.color,
    this.fontWeight,
  });

  final String text;
  final Color? color;
  final FontWeight? fontWeight;
}

/// Pattern-based color override applied after a line's base color.
class LogLineHighlight {
  const LogLineHighlight({
    required this.pattern,
    required this.color,
    this.fontWeight = FontWeight.w600,
  });

  /// Matched against each log line (without a trailing newline).
  final Pattern pattern;
  final Color color;
  final FontWeight fontWeight;

  bool matches(String line) {
    final pattern = this.pattern;
    if (pattern is RegExp) return pattern.hasMatch(line);
    return line.contains(pattern);
  }
}

/// Selectable monospace log text pane with optional scroll/hug controls.
///
/// Pass either [log] (split on newlines) or [lines]. When both are provided,
/// [lines] wins.
class LogTextView extends StatefulWidget {
  const LogTextView({
    super.key,
    this.log,
    this.lines,
    required this.textStyle,
    this.controller,
    this.maxHeight,
    this.emptyMessage = '(no log yet)',
    this.highlights = const [],
    this.trimBeforeLastHighlight = false,
    this.padding = const EdgeInsets.all(12),
    this.reverse = false,
    this.showScrollControls = true,
    this.controlColor,
    this.controlActiveColor,
  });

  /// Raw log dump; split on `\n` into lines.
  final String? log;

  /// Pre-colored lines (e.g. from [AppLogEntry] level mapping).
  final List<LogTextLine>? lines;

  /// Base monospace style; per-line color/weight overlays this.
  final TextStyle textStyle;

  final ScrollController? controller;
  final double? maxHeight;
  final String emptyMessage;
  final List<LogLineHighlight> highlights;

  /// When true, hide lines before the last highlight match until the eye
  /// toggle reveals them (e.g. pre–hot-restart flutter run output).
  final bool trimBeforeLastHighlight;

  final EdgeInsetsGeometry padding;

  /// When true and scroll controls are off with no external controller, uses a
  /// reverse list so newest content stays visible.
  final bool reverse;

  /// Icon-only scroll-to-bottom and hug-to-bottom controls.
  final bool showScrollControls;

  /// Idle icon color for scroll controls.
  final Color? controlColor;

  /// Color when hug-to-bottom is active.
  final Color? controlActiveColor;

  @override
  State<LogTextView> createState() => _LogTextViewState();
}

class _LogTextViewState extends State<LogTextView> {
  final FocusNode _selectionFocusNode = FocusNode(debugLabel: 'LogTextView');
  ScrollController? _ownedController;
  bool _hugBottom = true;
  bool _programmaticScrollInProgress = false;
  bool _showPrecedingLog = false;

  ScrollController get _scrollController =>
      widget.controller ?? _ownedController!;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _ownedController = ScrollController();
    }
    _scrollController.addListener(_onScrollChanged);
  }

  @override
  void didUpdateWidget(LogTextView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onScrollChanged);
      _ownedController?.removeListener(_onScrollChanged);
      _ownedController?.dispose();
      _ownedController = null;
      if (widget.controller == null) {
        _ownedController = ScrollController();
      }
      _scrollController.addListener(_onScrollChanged);
    }
    if (!widget.trimBeforeLastHighlight) {
      _showPrecedingLog = false;
    }
    if (_hugBottom) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _scrollToBottomIfHugging());
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScrollChanged);
    _ownedController?.dispose();
    _selectionFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allLines = _resolvedLines();
    final trimStart = _trimStartIndex(allLines);
    final visibleLines =
        trimStart == null ? allLines : allLines.sublist(trimStart);
    final lastHighlight = _lastHighlightIndex(allLines);
    final canRevealPreceding = widget.trimBeforeLastHighlight &&
        lastHighlight > 0;

    final body =
        visibleLines.isEmpty ? _emptyState() : _lineList(visibleLines);

    final scrollable = Scrollbar(
      controller: _scrollController,
      child: body,
    );

    final withControls = widget.showScrollControls
        ? Stack(
            children: [
              Positioned.fill(child: scrollable),
              Positioned(
                right: 4,
                bottom: 4,
                child: _scrollControls(canRevealPreceding: canRevealPreceding),
              ),
            ],
          )
        : scrollable;

    if (widget.maxHeight == null) return withControls;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: widget.maxHeight!),
      child: withControls,
    );
  }

  Widget _scrollControls({required bool canRevealPreceding}) {
    final idleColor =
        widget.controlColor ?? widget.textStyle.color?.withValues(alpha: 0.55);
    final activeColor =
        widget.controlActiveColor ?? widget.textStyle.color ?? Colors.blueAccent;

    return Material(
      type: MaterialType.transparency,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (canRevealPreceding)
            IconButton(
              tooltip: _showPrecedingLog
                  ? 'Hide earlier log'
                  : 'Show earlier log',
              onPressed: () {
                setState(() => _showPrecedingLog = !_showPrecedingLog);
              },
              iconSize: 20,
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(width: 32, height: 32),
              icon: Icon(
                _showPrecedingLog
                    ? Icons.visibility
                    : Icons.visibility_off_outlined,
                color: _showPrecedingLog ? activeColor : idleColor,
              ),
            ),
          IconButton(
            tooltip: 'Scroll to bottom',
            onPressed: _scrollToBottomOnce,
            iconSize: 20,
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 32, height: 32),
            icon: Icon(Icons.arrow_circle_down, color: idleColor),
          ),
          IconButton(
            tooltip: _hugBottom ? 'Stop hugging bottom' : 'Hug bottom',
            onPressed: _toggleHugBottom,
            iconSize: 20,
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 32, height: 32),
            icon: Icon(
              _hugBottom ? Icons.push_pin : Icons.push_pin_outlined,
              color: _hugBottom ? activeColor : idleColor,
            ),
          ),
        ],
      ),
    );
  }

  List<LogTextLine> _resolvedLines() {
    final providedLines = widget.lines;
    if (providedLines != null) return providedLines;
    final logText = widget.log;
    if (logText == null || logText.isEmpty) return const [];
    return [
      for (final line in logText.split('\n')) LogTextLine(text: line),
    ];
  }

  /// First visible index when trimming; null means show the full log.
  int? _trimStartIndex(List<LogTextLine> lines) {
    if (!widget.trimBeforeLastHighlight || _showPrecedingLog) return null;
    final lastHighlight = _lastHighlightIndex(lines);
    if (lastHighlight <= 0) return null;
    return lastHighlight;
  }

  int _lastHighlightIndex(List<LogTextLine> lines) {
    var last = -1;
    for (var index = 0; index < lines.length; index++) {
      if (_highlightFor(lines[index].text) != null) last = index;
    }
    return last;
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: widget.padding,
        child: Text(
          widget.emptyMessage,
          style: widget.textStyle.copyWith(fontStyle: FontStyle.italic),
        ),
      ),
    );
  }

  Widget _lineList(List<LogTextLine> logLines) {
    // Cupertino SelectableRegion — Material SelectionArea needs
    // MaterialLocalizations that CupertinoApp does not provide.
    return SelectableRegion(
      focusNode: _selectionFocusNode,
      selectionControls: cupertinoTextSelectionHandleControls,
      child: ListView.builder(
        controller: _scrollController,
        reverse: widget.reverse &&
            widget.controller == null &&
            !widget.showScrollControls,
        padding: widget.padding,
        itemCount: logLines.length,
        itemBuilder: (context, index) {
          final line = logLines[index];
          final highlight = _highlightFor(line.text);
          return Text(
            line.text,
            style: widget.textStyle.copyWith(
              color: highlight?.color ?? line.color ?? widget.textStyle.color,
              fontWeight: highlight?.fontWeight ??
                  line.fontWeight ??
                  widget.textStyle.fontWeight,
            ),
          );
        },
      ),
    );
  }

  LogLineHighlight? _highlightFor(String line) {
    for (final highlight in widget.highlights) {
      if (highlight.matches(line)) return highlight;
    }
    return null;
  }

  void _toggleHugBottom() {
    final enableHug = !_hugBottom;
    setState(() => _hugBottom = enableHug);
    if (enableHug) _scrollToBottomOnce();
  }

  void _scrollToBottomOnce() {
    if (!_scrollController.hasClients) return;
    _programmaticScrollInProgress = true;
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _programmaticScrollInProgress = false;
    });
  }

  void _scrollToBottomIfHugging() {
    if (!_hugBottom) return;
    _scrollToBottomOnce();
  }

  void _onScrollChanged() {
    if (!_scrollController.hasClients || _programmaticScrollInProgress) return;
    final position = _scrollController.position;
    final isNearBottom = position.pixels >= position.maxScrollExtent - 50;
    if (_hugBottom && !isNearBottom) {
      setState(() => _hugBottom = false);
    } else if (!_hugBottom && isNearBottom) {
      setState(() => _hugBottom = true);
    }
  }
}
