import 'package:flutter/material.dart';

class ProUpgradeSheet extends StatelessWidget {
  const ProUpgradeSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("You've used your 3 free complaint letters",
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
          const SizedBox(height: 8),
          const Text('Upgrade to JusLegal Pro for unlimited access'),
          const SizedBox(height: 12),
          const Text(
              '✅ Unlimited complaint letters\n✅ Priority AI case analysis\n✅ Lawyer consultation\n✅ Hindi language support'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Upgrade — ₹99/month'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Maybe Later'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
