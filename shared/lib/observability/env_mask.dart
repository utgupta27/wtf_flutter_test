final RegExp _sensitiveKeyPattern = RegExp(
  r'(secret|token|key|password|auth)',
  caseSensitive: false,
);

/// Masks [value] when [key] looks sensitive; otherwise returns [value].
String maskEnvValue(String key, String value) {
  if (value.isEmpty) {
    return value;
  }
  if (!_sensitiveKeyPattern.hasMatch(key)) {
    return value;
  }
  if (value.length <= 4) {
    return '••••';
  }
  return '${value.substring(0, 4)}••••';
}

/// Applies [maskEnvValue] to every entry in [values].
Map<String, String> maskEnvMap(Map<String, String> values) {
  return {
    for (final entry in values.entries)
      entry.key: maskEnvValue(entry.key, entry.value),
  };
}
