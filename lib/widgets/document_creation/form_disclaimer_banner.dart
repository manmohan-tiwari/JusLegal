import 'package:flutter/material.dart';

import '../legal_info_banner.dart';

class FormDisclaimerBanner extends StatelessWidget {
  const FormDisclaimerBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalInfoBanner(
      message:
          'These are draft templates only. Verify with the concerned authority before submission. JusLegal is not responsible for rejection of forms.',
    );
  }
}
