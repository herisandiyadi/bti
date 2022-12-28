import 'dart:convert';

import 'package:bti_test_kosong_satu/constants.dart';
import 'package:http/http.dart' as http;

class FcmServices {
  void sendNotif(String fcmKey, String message, String name) async {
    var headers = {
      'Authorization': 'key=$fcm_key',
      'Content-Type': 'application/json'
    };
    var request = http.Request('POST', Uri.parse(FCM_URL));
    request.body = json.encode({
      "to": fcmKey,
      "collapse_key": "type_a",
      "notification": {"body": message, "title": name},
      "data": {
        "body": "body of your notification in data",
        "title": "title of your notification in title",
        "key_2": "Value for key_2"
      }
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    print(response);
    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    } else {
      print(response.reasonPhrase);
    }
  }
}
