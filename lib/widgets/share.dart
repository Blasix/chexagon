import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void showShareDialog(BuildContext context, String share) {
  showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: const Text('Share'),
            content: SelectableText(share),
            actions: [
              TextButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: share));
                  Navigator.of(context).pop();
                },
                child: const Text('Copy', style: TextStyle(color: Colors.blue)),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close', style: TextStyle(color: Colors.red)),
              ),
            ],
          ));
}
