import 'package:flutter/cupertino.dart';

import 'app_log_buffer.dart';

/// Colors and spacing for [AppLogViewer], so apps can match their own theme.
class AppLogViewerStyle {
  const AppLogViewerStyle({
    required this.surface,
    required this.surfaceElevated,
    required this.border,
    required this.accent,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.warning,
    required this.error,
    this.radius = 12,
    this.spacingXs = 4,
    this.spacingSm = 8,
    this.spacingMd = 12,
    this.spacingXl = 24,
  });

  final Color surface;
  final Color surfaceElevated;
  final Color border;
  final Color accent;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color warning;
  final Color error;
  final double radius;
  final double spacingXs;
  final double spacingSm;
  final double spacingMd;
  final double spacingXl;
}

/// In-app viewer for [appLogBuffer] entries (filter, clear, follow).
class AppLogViewer extends StatefulWidget {
  const AppLogViewer(
      {required this.style,
      this.emptyMessage = 'No logs yet',
      this.showClearButton = true,
      this.logFontSize = 12});

  final AppLogViewerStyle style;
  final String emptyMessage;
  final bool showClearButton;
  final double logFontSize;

  @override
  State<AppLogViewer> createState() => _AppLogViewerState();
}

class _AppLogViewerState extends State<AppLogViewer> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _filterController = TextEditingController();
  final FocusNode _selectionFocusNode = FocusNode();
  bool _userScrolledAwayFromBottom = false;
  bool _programmaticScrollInProgress = false;
  String _filterText = '';

  AppLogViewerStyle get _style => widget.style;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScrollChanged);
    _filterController.addListener(
      () => setState(() => _filterText = _filterController.text),
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScrollChanged);
    _scrollController.dispose();
    _filterController.dispose();
    _selectionFocusNode.dispose();
    super.dispose();
  }

  List<AppLogEntry> _applyFilter(List<AppLogEntry> entries) {
    if (_filterText.isEmpty) return entries;
    try {
      final regex = RegExp(_filterText, caseSensitive: false);
      return entries
          .where((entry) => regex.hasMatch(entry.formattedText))
          .toList(growable: false);
    } on FormatException {
      return entries;
    }
  }

  bool get _filterIsInvalidRegex {
    if (_filterText.isEmpty) return false;
    try {
      RegExp(_filterText);
      return false;
    } on FormatException {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appLogBuffer,
      builder: (context, child) {
        final allEntries = appLogBuffer.entries;
        final visibleEntries = _applyFilter(allEntries);
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
        return Container(
          decoration: BoxDecoration(
            color: _style.surface,
            borderRadius: BorderRadius.circular(_style.radius),
            border: Border.all(color: _style.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _header(visibleEntries.length, allEntries.length),
              Container(height: 1, color: _style.border),
              Expanded(child: _viewerBody(visibleEntries)),
            ],
          ),
        );
      },
    );
  }

  Widget _header(int visibleCount, int totalCount) {
    final countLabel = _filterText.isEmpty
        ? 'Logs ($totalCount)'
        : 'Logs ($visibleCount / $totalCount)';
    return Padding(
      padding: EdgeInsets.fromLTRB(
        _style.spacingMd,
        _style.spacingSm,
        _style.spacingSm,
        _style.spacingSm,
      ),
      child: Row(
        children: [
          Text(
            countLabel,
            style: TextStyle(
              color: _style.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: _style.spacingSm),
          Expanded(child: _filterField()),
          if (_userScrolledAwayFromBottom) _followButton(),
          if (widget.showClearButton) _clearButton(),
        ],
      ),
    );
  }

  Widget _filterField() {
    return CupertinoTextField(
      controller: _filterController,
      placeholder: 'filter regex… e.g. ERROR| or WARN',
      padding: EdgeInsets.symmetric(
        horizontal: _style.spacingSm,
        vertical: _style.spacingXs,
      ),
      style: TextStyle(
        color: _style.textPrimary,
        fontFamily: 'monospace',
        fontSize: 13,
      ),
      placeholderStyle: TextStyle(
        color: _style.textTertiary,
        fontSize: 13,
      ),
      decoration: BoxDecoration(
        color: _style.surfaceElevated,
        borderRadius: BorderRadius.circular(_style.radius * 0.67),
        border: Border.all(
          color: _filterIsInvalidRegex ? _style.error : _style.border,
        ),
      ),
      suffix: _filterText.isEmpty
          ? null
          : CupertinoButton(
              padding: EdgeInsets.only(right: _style.spacingXs),
              minimumSize: Size.zero,
              onPressed: _filterController.clear,
              child: Icon(
                CupertinoIcons.clear_circled_solid,
                size: 16,
                color: _style.textTertiary,
              ),
            ),
    );
  }

  Widget _followButton() {
    return CupertinoButton(
      padding: EdgeInsets.symmetric(horizontal: _style.spacingSm),
      minimumSize: Size.zero,
      onPressed: () {
        setState(() => _userScrolledAwayFromBottom = false);
        _scrollToBottom();
      },
      child: Text(
        'Follow',
        style: TextStyle(color: _style.accent, fontSize: 13),
      ),
    );
  }

  Widget _clearButton() {
    return CupertinoButton(
      padding: EdgeInsets.symmetric(horizontal: _style.spacingSm),
      minimumSize: Size.zero,
      onPressed: appLogBuffer.clear,
      child: Icon(
        CupertinoIcons.clear,
        size: 18,
        color: _style.textTertiary,
      ),
    );
  }

  Widget _viewerBody(List<AppLogEntry> entries) {
    if (entries.isEmpty) return _emptyState();
    return _entryList(entries);
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(_style.spacingXl),
        child: Text(
          widget.emptyMessage,
          style: TextStyle(
            color: _style.textTertiary,
            fontSize: 13,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }

  Widget _entryList(List<AppLogEntry> entries) {
    // Cupertino SelectableRegion — Material SelectionArea needs
    // MaterialLocalizations that CupertinoApp does not provide.
    return SelectableRegion(
      focusNode: _selectionFocusNode,
      selectionControls: cupertinoTextSelectionHandleControls,
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.symmetric(
          horizontal: _style.spacingMd,
          vertical: _style.spacingSm,
        ),
        itemCount: entries.length,
        itemBuilder: (context, index) => _entryText(entries[index]),
      ),
    );
  }

  Widget _entryText(AppLogEntry entry) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        entry.formattedText,
        style: TextStyle(
          color: _entryColor(entry.level),
          fontFamily: 'monospace',
          fontSize: widget.logFontSize,
          height: 1.35,
        ),
      ),
    );
  }

  Color _entryColor(AppLogLevel level) => switch (level) {
        AppLogLevel.info => _style.textSecondary,
        AppLogLevel.warning => _style.warning,
        AppLogLevel.error => _style.error,
        AppLogLevel.fine => _style.textTertiary,
      };

  void _onScrollChanged() {
    if (!_scrollController.hasClients || _programmaticScrollInProgress) return;
    final position = _scrollController.position;
    final isNearBottom = position.pixels >= position.maxScrollExtent - 50;
    if (_userScrolledAwayFromBottom && isNearBottom) {
      setState(() => _userScrolledAwayFromBottom = false);
      return;
    }
    if (!isNearBottom && !_userScrolledAwayFromBottom) {
      setState(() => _userScrolledAwayFromBottom = true);
    }
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients || _userScrolledAwayFromBottom) return;
    _programmaticScrollInProgress = true;
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _programmaticScrollInProgress = false;
    });
  }
}
