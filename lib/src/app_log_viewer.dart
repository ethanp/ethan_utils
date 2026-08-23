import 'package:flutter/material.dart';

import 'app_log_buffer.dart';
import 'log_text_view.dart';

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

/// In-app viewer for [appLogBuffer] entries (filter, clear, hug).
class AppLogViewer extends StatefulWidget {
  const AppLogViewer({
    required this.style,
    this.emptyMessage = 'No logs yet',
    this.showClearButton = true,
    this.logFontSize = 12,
    this.maxBodyHeight,
  });

  final AppLogViewerStyle style;
  final String emptyMessage;
  final bool showClearButton;
  final double logFontSize;

  /// When set, the log body is height-capped instead of [Expanded].
  final double? maxBodyHeight;

  @override
  State<AppLogViewer> createState() => _AppLogViewerState();
}

class _AppLogViewerState extends State<AppLogViewer> {
  final TextEditingController _filterController = TextEditingController();
  String _filterText = '';

  @override
  void initState() {
    super.initState();
    _filterController.addListener(_syncFilterTextFromController);
  }

  @override
  void dispose() {
    _filterController.dispose();
    super.dispose();
  }

  void _syncFilterTextFromController() {
    setState(() => _filterText = _filterController.text);
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
    final viewer = AnimatedBuilder(
      animation: appLogBuffer,
      builder: (context, child) {
        final allEntries = appLogBuffer.entries;
        final visibleEntries = _applyFilter(allEntries);
        return Material(
          color: widget.style.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(widget.style.radius),
            side: BorderSide(color: widget.style.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _header(visibleEntries.length, allEntries.length),
              Container(height: 1, color: widget.style.border),
              _viewerBody(visibleEntries),
            ],
          ),
        );
      },
    );

    // Material TextField / IconButton need MaterialLocalizations; CupertinoApp
    // hosts (workouts, etc.) do not provide them unless we inject here.
    if (Localizations.of<MaterialLocalizations>(
          context,
          MaterialLocalizations,
        ) !=
        null) {
      return viewer;
    }
    return Localizations(
      locale: Localizations.maybeLocaleOf(context) ?? const Locale('en', 'US'),
      delegates: const [
        DefaultMaterialLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
      ],
      child: viewer,
    );
  }

  Widget _header(int visibleCount, int totalCount) {
    final countLabel = _filterText.isEmpty
        ? 'Logs ($totalCount)'
        : 'Logs ($visibleCount / $totalCount)';
    return Padding(
      padding: EdgeInsets.fromLTRB(
        widget.style.spacingMd,
        widget.style.spacingSm,
        widget.style.spacingSm,
        widget.style.spacingSm,
      ),
      child: Row(
        children: [
          Text(
            countLabel,
            style: TextStyle(
              color: widget.style.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: widget.style.spacingSm),
          Expanded(child: _filterField()),
          if (widget.showClearButton) _clearButton(),
        ],
      ),
    );
  }

  Widget _filterField() {
    final borderColor = _filterIsInvalidRegex ? widget.style.error : widget.style.border;
    return TextField(
      controller: _filterController,
      style: TextStyle(
        color: widget.style.textPrimary,
        fontFamily: 'monospace',
        fontSize: 13,
      ),
      cursorColor: widget.style.accent,
      decoration: InputDecoration(
        isDense: true,
        hintText: 'filter regex… e.g. ERROR| or WARN',
        hintStyle: TextStyle(color: widget.style.textTertiary, fontSize: 13),
        filled: true,
        fillColor: widget.style.surfaceElevated,
        contentPadding: EdgeInsets.symmetric(
          horizontal: widget.style.spacingSm,
          vertical: widget.style.spacingXs + 2,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.style.radius * 0.67),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.style.radius * 0.67),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.style.radius * 0.67),
          borderSide: BorderSide(color: borderColor, width: 1.5),
        ),
        suffixIcon: _filterText.isEmpty
            ? null
            : IconButton(
                tooltip: 'Clear filter',
                onPressed: _filterController.clear,
                iconSize: 16,
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(width: 28, height: 28),
                icon: Icon(Icons.cancel, color: widget.style.textTertiary),
              ),
      ),
    );
  }

  Widget _clearButton() {
    return IconButton(
      tooltip: 'Clear logs',
      onPressed: appLogBuffer.clear,
      iconSize: 18,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.symmetric(horizontal: widget.style.spacingSm),
      constraints: const BoxConstraints.tightFor(width: 36, height: 32),
      icon: Icon(Icons.clear_all, color: widget.style.textTertiary),
    );
  }

  Widget _viewerBody(List<AppLogEntry> entries) {
    final logLines = [
      for (final entry in entries)
        LogTextLine(
          text: entry.formattedText,
          color: _entryColor(entry.level),
        ),
    ];
    final viewer = LogTextView(
      lines: logLines,
      emptyMessage: widget.emptyMessage,
      maxHeight: widget.maxBodyHeight,
      padding: EdgeInsets.symmetric(
        horizontal: widget.style.spacingMd,
        vertical: widget.style.spacingSm,
      ),
      textStyle: TextStyle(
        color: widget.style.textSecondary,
        fontFamily: 'monospace',
        fontSize: widget.logFontSize,
        height: 1.35,
      ),
      controlColor: widget.style.textTertiary,
      controlActiveColor: widget.style.accent,
    );

    if (widget.maxBodyHeight != null) return viewer;
    return Expanded(child: viewer);
  }

  Color _entryColor(AppLogLevel level) => switch (level) {
        AppLogLevel.info => widget.style.textSecondary,
        AppLogLevel.warning => widget.style.warning,
        AppLogLevel.error => widget.style.error,
        AppLogLevel.fine => widget.style.textTertiary,
      };
}
