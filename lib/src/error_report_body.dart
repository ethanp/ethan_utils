class ErrorReportBody {
  const ErrorReportBody({
    required this.summary,
    this.sections = const [],
    this.stackTrace,
    this.createdAt,
  });

  final String summary;
  final List<ErrorReportSection> sections;
  final StackTrace? stackTrace;
  final DateTime? createdAt;

  @override
  String toString() {
    final reportLines = <String>[
      'Error at ${(createdAt ?? DateTime.now()).toIso8601String()}',
      '',
      'Summary:',
      summary,
    ];

    for (final reportSection in sections) {
      reportLines
        ..add('')
        ..add('${reportSection.title}:')
        ..addAll(reportSection.lines);
    }

    reportLines
      ..add('')
      ..add('Stack trace:')
      ..add(stackTrace?.toString() ?? 'No stack trace available.');

    return reportLines.join('\n');
  }
}

ErrorReportSection section({
  required String title,
  List<String>? lines,
  List<ErrorReportField>? fields,
}) {
  if (fields != null) return ErrorReportSection.fields(title, fields);
  return ErrorReportSection(title, lines ?? const []);
}

class ErrorReportSection {
  const ErrorReportSection(this.title, this.lines);

  ErrorReportSection.fields(
    this.title,
    List<ErrorReportField> fields,
  ) : lines = fields
            .map((reportField) => '${reportField.name}: ${reportField.text}')
            .toList();

  final String title;
  final List<String> lines;
}

ErrorReportField field({
  required String name,
  required Object? value,
}) =>
    ErrorReportField(name, value);

class ErrorReportField {
  ErrorReportField(this.name, Object? fieldValue)
      : text = fieldValue?.toString() ?? '<missing>';

  final String name;
  final String text;
}
