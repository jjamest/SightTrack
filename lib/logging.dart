import 'package:logger/logger.dart';

var logger = Logger(
  filter: null, // Use the default LogFilter (-> only log in debug mode)
  printer: PrettyPrinter(
    methodCount: 0, // No method chain
    errorMethodCount: 0, // No method chain for errors
    lineLength: 120, // Adjust line length if needed
    colors: false, // Colorful output
    printEmojis: true, // Emojis are helpful for distinguishing log types
    dateTimeFormat: DateTimeFormat.none,
  ),
  output: null, // Use the default LogOutput (-> send everything to console)
);
