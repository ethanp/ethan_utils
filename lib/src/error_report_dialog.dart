import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class ErrorReportDialog extends StatelessWidget {
  const ErrorReportDialog({
    required this.title,
    required this.userMessage,
    required this.emailSubject,
    required this.reportBody,
    this.emailAddress = 'etahnp@gmail.com',
    super.key,
  });

  final String title;
  final String userMessage;
  final String emailSubject;
  final String reportBody;
  final String emailAddress;

  static Future<void> show({
    required BuildContext context,
    required String title,
    required String userMessage,
    required String emailSubject,
    required String reportBody,
    String emailAddress = 'etahnp@gmail.com',
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => ErrorReportDialog(
        title: title,
        userMessage: userMessage,
        emailSubject: emailSubject,
        reportBody: reportBody,
        emailAddress: emailAddress,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: _content(),
      actions: [
        TextButton(
          onPressed: () => _emailReport(),
          child: const Text('Email to me'),
        ),
        TextButton(
          onPressed: () => Clipboard.setData(ClipboardData(text: reportBody)),
          child: const Text('Copy'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Dismiss'),
        ),
      ],
    );
  }

  Widget _content() {
    return SizedBox(
      width: 520,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(userMessage),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 220),
            child: SingleChildScrollView(
              child: SelectableText(
                reportBody,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _emailReport() async {
    final encodedSubject = Uri.encodeComponent(emailSubject);
    final encodedBody = Uri.encodeComponent(reportBody);
    final gmailUri = Uri.parse(
      'googlegmail:///co?to=$emailAddress&subject=$encodedSubject&body=$encodedBody',
    );
    if (await canLaunchUrl(gmailUri)) {
      await launchUrl(gmailUri, mode: LaunchMode.externalApplication);
      return;
    }

    final webUri = Uri.parse(
      'https://mail.google.com/mail/?view=cm'
      '&to=$emailAddress&su=$encodedSubject&body=$encodedBody',
    );
    await launchUrl(webUri, mode: LaunchMode.externalApplication);
  }
}
