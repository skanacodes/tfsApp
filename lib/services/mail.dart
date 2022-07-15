// ignore_for_file: deprecated_member_use, avoid_print

import 'dart:io';

import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';

class MailSending {
  Future<String?> sendMails(file, userEmail) async {
    try {
      String username = 'tfs.sofwares@gmail.com';
      String password = 'Tfs@12345';
      final smtpServer = gmail(username, password);

      //  final smtpServer = gmail(username, password);
      // Use the SmtpServer class to configure an SMTP server:
      // final smtpServer = SmtpServer('smtp.domain.com');
      // See the named arguments of SmtpServer for further configuration
      // options.

      // Create our message.
      final message = Message()
        ..from = Address(username, 'TFS')
        ..recipients.add(userEmail)
        ..subject = 'Receipt '
        ..text = 'Dear, Receive Your Receipt From TFS .'
        ..html =
            "<h5>Dear,  $userEmail</h5>\n<p> Receive Your Receipt From TFS</p>"
        ..attachments = [
          FileAttachment(File('$file'))
            ..location = Location.inline
            ..cid = '<mydoc@1.001>'
        ];

      final sendReport = await send(message, smtpServer);
      print('Message sent: $sendReport');
      return "Email Sent Successfull";
    } on MailerException catch (e) {
      print('Message not sent. $e');

      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
        return "Problem Occured While Sending Email";
      }
    }
    return null;
  }
}
