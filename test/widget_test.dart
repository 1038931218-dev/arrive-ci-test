import 'package:flutter_test/flutter_test.dart';
import 'package:arrive/utils/distance_utils.dart';

void main() {
  test('distance between two identical points is zero', () {
    final d = DistanceUtils.distanceMeters(31.2304, 121.4737, 31.2304, 121.4737);
    expect(d, lessThan(0.001));
  });

  test('distance between two known points is plausible', () {
    final d = DistanceUtils.distanceMeters(31.2304, 121.4737, 31.2497, 121.4560);
    expect(d, greaterThan(1000));
    expect(d, lessThan(5000));
  });
}
