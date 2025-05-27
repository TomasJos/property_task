
import 'dart:html' as html;

void showWebNotification(String title, String body) {
  if (!html.Notification.supported) {
    print('Browser does not support notifications.');
    return;
  }

  if (html.Notification.permission == 'granted') {
    html.Notification(title, body: body);
  } else if (html.Notification.permission != 'denied') {
    html.Notification.requestPermission().then((permission) {
      if (permission == 'granted') {
        html.Notification(title, body: body);
      } else {
        print('Notification permission denied.');
      }
    });
  } else {
    print('Notification permission previously denied.');
  }
}
