import 'package:flutter/material.dart';

import '../legal_info_banner.dart';

class DisclaimerBanner extends StatelessWidget {
  const DisclaimerBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalInfoBanner(
      message:
          'AI-generated documents only. Review carefully and consult a lawyer before use.',
    );
  }
}
