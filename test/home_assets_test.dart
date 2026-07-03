import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_digital_registration/constants/home_images.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('home image assets are bundled', () async {
    const paths = [
      HomeImages.banner,
      HomeImages.carouselServices,
      HomeImages.carouselIndia,
      HomeImages.digital,
      HomeImages.security,
      HomeImages.skills,
      HomeImages.business,
      HomeImages.services,
      HomeImages.workspace,
    ];

    for (final path in paths) {
      final data = await rootBundle.load(path);
      expect(data.lengthInBytes, greaterThan(1000), reason: path);
    }
  });
}
