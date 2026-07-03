import 'package:flutter/material.dart';

import '../services/auth_session.dart';
import '../services/wallet_balance_resolver.dart';
import 'dashboard_screen.dart';
import 'login_screen.dart';

/// Restores login after app restart / browser refresh (Flutter web).
class SessionRoot extends StatefulWidget {
  const SessionRoot({super.key});

  @override
  State<SessionRoot> createState() => _SessionRootState();
}

class _SessionRootState extends State<SessionRoot> {
  Map<String, dynamic>? _user;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _restore();
  }

  Future<void> _restore() async {
    var user = await AuthSession.load();
    if (user != null) {
      try {
        final balance = await WalletBalanceResolver.resolve(user).timeout(
          const Duration(seconds: 8),
        );
        user = Map<String, dynamic>.from(user)..['wallet_balance'] = balance;
        await AuthSession.save(user);
      } catch (_) {
        // Still show dashboard if wallet sync is slow or offline.
      }
    }
    if (!mounted) return;
    setState(() {
      _user = user;
      _ready = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF2196F3)),
        ),
      );
    }

    if (_user != null) {
      return DashboardScreen(userData: _user!);
    }

    return const LoginScreen();
  }
}
