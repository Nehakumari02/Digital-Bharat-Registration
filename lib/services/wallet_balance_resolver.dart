import '../controllers/partner_wallet_controller.dart';
import '../utils/user_profile_helpers.dart';
import 'auth_session.dart';
import 'partner_wallet_store.dart';

/// Resolves wallet balance (API + referrals + local pending) and saves to session.
abstract final class WalletBalanceResolver {
  static Future<double> resolve(Map<String, dynamic> userData) async {
    final user = UserProfileHelpers.normalize(
      Map<String, dynamic>.from(userData),
    );
    final code = UserProfileHelpers.displayPartnerCode(user);
    final profileBalance = UserProfileHelpers.walletBalance(user);
    final id = int.tryParse(user['id']?.toString() ?? '');

    final info = await PartnerWalletController().fetchWallet(
      id,
      partnerCode: code,
      profileBalance: profileBalance,
      user: user,
    );
    if (info != null) return info.balance;

    var balance = profileBalance;
    if (code != null) {
      balance += await PartnerWalletStore.unsyncedBalanceForCode(code);
    }
    return balance;
  }

  static Future<double> resolveAndPersist(Map<String, dynamic> userData) async {
    final balance = await resolve(userData);
    final updated = Map<String, dynamic>.from(userData)
      ..['wallet_balance'] = balance;
    await AuthSession.save(updated);
    return balance;
  }
}
