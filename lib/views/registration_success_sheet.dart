import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/registration_plan.dart';
import '../models/registration_submit_result.dart';

void showRegistrationSuccessSheet(
  BuildContext context, {
  required RegistrationSubmitResult result,
  required String registrationType,
}) {
  final isPartner = registrationType == RegistrationPlan.typePartner;
  final code = result.partnerCode;
  final cashback = result.cashbackCredited;

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 64),
              const SizedBox(height: 16),
              Text(
                isPartner ? 'Partner registration complete' : 'Registration complete',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              if (isPartner && code != null) ...[
                const Text(
                  'Your partner code (share with referrals):',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                SelectableText(
                  code,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2196F3),
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: code));
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(content: Text('Partner code copied')),
                    );
                  },
                  icon: const Icon(Icons.copy),
                  label: const Text('Copy partner code'),
                ),
              ],
              if (!isPartner && cashback != null && cashback > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Partner received ₹${cashback.toStringAsFixed(2)} cashback in their wallet.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2196F3),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Go to login'),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
