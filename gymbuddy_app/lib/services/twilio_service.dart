import 'dart:convert';
import 'package:http/http.dart' as http;

/// Sends WhatsApp messages via Twilio Content API
/// Mirrors the send_whatsapp() function in the Python app.py
class TwilioService {
  final String accountSid;
  final String authToken;
  final String fromNumber; // e.g. +17372508034
  final String contentSid; // pre-approved template SID

  TwilioService({
    required this.accountSid,
    required this.authToken,
    required this.fromNumber,
    required this.contentSid,
  });

  /// Sends the daily nutrition summary via WhatsApp template.
  /// [toNumber] must be in E.164 format (+91XXXXXXXXXX)
  /// [userName] maps to {{1}} in the Twilio content template
  /// [summary] maps to {{2}} — truncated to 1500 chars like the Python version
  Future<TwilioResult> sendSummary({
    required String toNumber,
    required String userName,
    required String summary,
  }) async {
    final truncatedSummary = _cleanText(summary);

    final contentVariables = jsonEncode({
      '1': userName,
      '2': truncatedSummary,
    });

    // Twilio Messages API endpoint
    final uri = Uri.parse(
        'https://api.twilio.com/2010-04-01/Accounts/$accountSid/Messages.json');

    final response = await http.post(
      uri,
      headers: {
        'Authorization':
            'Basic ${base64Encode(utf8.encode('$accountSid:$authToken'))}',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'From': 'whatsapp:$fromNumber',
        'To': 'whatsapp:$toNumber',
        'ContentSid': contentSid,
        'ContentVariables': contentVariables,
      },
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200 || response.statusCode == 201) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return TwilioResult(success: true, sid: body['sid'] as String?);
    } else {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final msg = body['message'] as String? ?? response.body;
      return TwilioResult(success: false, error: msg);
    }
  }

  /// Collapses whitespace/newlines and truncates to 1500 chars
  /// — same logic as clean_whatsapp_text() in Python
  String _cleanText(String text) {
    final collapsed = text.split(RegExp(r'\s+')).join(' ').trim();
    if (collapsed.length > 1500) {
      return '${collapsed.substring(0, 1497)}...';
    }
    return collapsed;
  }
}

class TwilioResult {
  final bool success;
  final String? sid;
  final String? error;

  const TwilioResult({required this.success, this.sid, this.error});
}
