import 'package:shared/models/message.dart';

const String imageMessagePrefix = 'img://';

bool isImageMessage(Message message) =>
    message.text.startsWith(imageMessagePrefix);

String imageMessagePath(Message message) =>
    message.text.substring(imageMessagePrefix.length);

String imageMessageText(String filePath) => '$imageMessagePrefix$filePath';
