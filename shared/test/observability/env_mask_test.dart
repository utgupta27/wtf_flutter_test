import 'package:flutter_test/flutter_test.dart';
import 'package:shared/observability/env_mask.dart';

void main() {
  test('masks sensitive keys', () {
    expect(
      maskEnvValue('HMS_APP_SECRET', 'abcdefghijklmnop'),
      'abcd••••',
    );
  });

  test('leaves non-sensitive keys readable', () {
    const url = 'http://127.0.0.1:3000';
    expect(maskEnvValue('SYNC_BASE_URL', url), url);
  });

  test('maskEnvMap applies per key', () {
    final masked = maskEnvMap({
      'SYNC_BASE_URL': 'http://localhost:3000',
      'AUTH_TOKEN': 'secret-token-value',
    });
    expect(masked['SYNC_BASE_URL'], 'http://localhost:3000');
    expect(masked['AUTH_TOKEN'], 'secr••••');
  });
}
