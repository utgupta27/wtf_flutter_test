/// Structured log domain tags for WTF Platform.
enum LogTag {
  chat,
  rtc,
  schedule,
  auth,
}

/// Returns the bracketed prefix for [tag], e.g. `[CHAT]`.
String logTagPrefix(LogTag tag) {
  switch (tag) {
    case LogTag.chat:
      return '[CHAT]';
    case LogTag.rtc:
      return '[RTC]';
    case LogTag.schedule:
      return '[SCHEDULE]';
    case LogTag.auth:
      return '[AUTH]';
  }
}
