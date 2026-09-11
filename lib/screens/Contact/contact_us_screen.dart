// Create this new screen: lib/screens/contact_us_screen.dart

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: Text('Contact Us')),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Get in Touch',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'Email:\nkamalnanda@makemydaynow.com',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            GestureDetector(
              onTap: () async {
                final Uri emailUri = Uri(
                  scheme: 'mailto',
                  path: 'kamalnanda@makemydaynow.com',
                  queryParameters: {
                    'subject': 'MakeMyDay App Feedback',
                  },
                );
                try {
                  final launched = await launchUrl(
                    emailUri,
                    mode: LaunchMode.externalApplication,
                  );
                  if (!launched) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Could not open email client')),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Could not open email client')),
                  );
                }
              },
              child: Text(
                'Send us an email',
                style: TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Visit our website:\nmakemydaynow.com',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            GestureDetector(
              onTap: () async {
                final Uri url = Uri.parse('https://makemydaynow.com/');
                try {
                  final launched = await launchUrl(
                    url,
                    mode: LaunchMode.externalApplication,
                  );
                  if (!launched) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Could not open browser')),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Could not open browser')),
                  );
                }
              },
              child: Text(
                'Visit Website',
                style: TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            SizedBox(height: 30),
            Text(
              'Developer: MakeMyDay Team',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}