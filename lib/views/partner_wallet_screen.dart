import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/registration_plan.dart';
import '../controllers/partner_wallet_controller.dart';
import '../services/partner_code_registry.dart';
import '../services/partner_wallet_store.dart';
import '../services/auth_session.dart';
import '../utils/partner_code_util.dart';
import '../utils/user_profile_helpers.dart';
import '../widgets/responsive_layout.dart';

class PartnerWalletScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const PartnerWalletScreen({super.key, required this.userData});

  @override
  State<PartnerWalletScreen> createState() => _PartnerWalletScreenState();
}

class _PartnerWalletScreenState extends State<PartnerWalletScreen> {
  final _walletController = PartnerWalletController();
  PartnerWalletInfo? _remote;
  List<ReferralCreditEntry> _referralHistory = [];
  bool _loading = true;
  String? _localPartnerCode;
  String? _resolvedCode;
  bool _codeFromRegistrationSeed = false;
  bool _registryPartner = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = UserProfileHelpers.normalize(
      Map<String, dynamic>.from(widget.userData),
    );
    final mobile = user['mobile']?.toString();
    if (mobile != null && mobile.isNotEmpty) {
      _localPartnerCode = await PartnerCodeRegistry.partnerCodeForMobile(mobile);
      _registryPartner = _localPartnerCode != null && _localPartnerCode!.isNotEmpty;
    }

    final resolvedEarly = _resolvePartnerCodeFromProfile(user);
    final profileBalance = UserProfileHelpers.walletBalance(user);
    final id = int.tryParse(user['id']?.toString() ?? '');

    final info = await _walletController.fetchWallet(
      id,
      partnerCode: resolvedEarly,
      profileBalance: profileBalance,
      user: user,
    );
    if (mounted) {
      setState(() {
        _remote = info;
      });
    }

    final resolved = _resolvePartnerCode(user);
    if (resolved != null && resolved.isNotEmpty && mobile != null && mobile.isNotEmpty) {
      await PartnerCodeRegistry.savePartner(
        code: resolved,
        name: user['name']?.toString() ?? 'Partner',
        partnerId: int.tryParse(user['id']?.toString() ?? ''),
        mobile: mobile,
      );
    }

    if (resolved != null && resolved.isNotEmpty) {
      _referralHistory = await PartnerWalletStore.historyForCode(resolved);
    }

    final finalBalance = _remote?.balance ?? profileBalance;
    final updatedUser = Map<String, dynamic>.from(user)
      ..['wallet_balance'] = finalBalance;
    if (_registryPartner || UserProfileHelpers.isPartner(user)) {
      updatedUser['is_partner'] = true;
      if (resolved != null) {
        updatedUser['partner_code'] = resolved;
      }
    }
    await AuthSession.save(updatedUser);

    if (mounted) {
      setState(() {
        _resolvedCode = resolved;
        _loading = false;
      });
    }
  }

  String? _resolvePartnerCodeFromProfile(Map<String, dynamic> user) {
    final fromProfile = UserProfileHelpers.partnerCode(user);
    if (fromProfile != null) return fromProfile;
    if (_localPartnerCode != null && _localPartnerCode!.isNotEmpty) {
      return _localPartnerCode;
    }
    return null;
  }

  String? _resolvePartnerCode(Map<String, dynamic> user) {
    final fromRemote = _remote?.partnerCode.trim();
    if (fromRemote != null && fromRemote.isNotEmpty && fromRemote != '—') {
      return PartnerCodeUtil.normalizeInput(fromRemote);
    }

    final fromProfile = UserProfileHelpers.partnerCode(user);
    if (fromProfile != null) return fromProfile;

    if (_localPartnerCode != null && _localPartnerCode!.isNotEmpty) {
      return _localPartnerCode;
    }

    if (_canEarnReferrals(user)) {
      final seed = user['mobile']?.toString().trim();
      final email = user['email']?.toString().trim();
      final generated = PartnerCodeUtil.generate(
        seed: (seed != null && seed.isNotEmpty) ? seed : email,
      );
      _codeFromRegistrationSeed = true;
      return generated;
    }

    return null;
  }

  bool _canEarnReferrals(Map<String, dynamic> user) {
    if (_registryPartner) return true;
    if (UserProfileHelpers.isPartner(user)) return true;
    if (UserProfileHelpers.registrationFee(user) == RegistrationPlan.partnerFeeInr) {
      return true;
    }
    return false;
  }

  bool _shouldShowOwnPartnerCode(Map<String, dynamic> user) {
    if (_resolvedCode != null && _resolvedCode!.isNotEmpty) return true;
    return _canEarnReferrals(user);
  }

  @override
  Widget build(BuildContext context) {
    final user = UserProfileHelpers.normalize(
      Map<String, dynamic>.from(widget.userData),
    );
    final code = _resolvedCode ?? '—';
    final hasCode = code != '—';
    final balance = _remote?.balance ?? UserProfileHelpers.walletBalance(user);
    final pendingLocal = _remote?.localBalance ?? 0;
    final deviceLedger = _remote?.deviceLedgerBalance ?? 0;
    final cashbackEach = RegistrationPlan.cashbackForNormalRegistration();
    final showOwnCode = _shouldShowOwnPartnerCode(user);
    final isNormal = UserProfileHelpers.isNormalAccount(user) && !showOwnCode;
    final category = user['category']?.toString() ?? 'User';
    final planLabel = UserProfileHelpers.accountPlanLabel(user);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wallet'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Refresh balance',
            onPressed: _loading ? null : () => _load(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ResponsiveScrollBody(
          maxWidth: 560,
          children: [
            if (_loading) const LinearProgressIndicator(minHeight: 2),
            _accountStatusCard(
              category: category,
              planLabel: planLabel,
              isNormal: isNormal,
              showOwnCode: showOwnCode,
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2196F3), Color(0xFF1E88E5)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Wallet balance',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₹${balance.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (deviceLedger > 0 || pendingLocal > 0) ...[
                    const SizedBox(height: 6),
                    Text(
                      deviceLedger > 0
                          ? 'Includes ₹${deviceLedger.toStringAsFixed(2)} from referrals on this browser.'
                          : 'Includes ₹${pendingLocal.toStringAsFixed(2)} pending server sync.',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        height: 1.3,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Text(
                    showOwnCode
                        ? 'Earn 10% (₹${RegistrationPlan.normalFeeInr} → ₹${cashbackEach.toStringAsFixed(0)}) when someone registers with your code below.'
                        : 'This wallet is for Partner referral earnings only. Normal ($category) accounts do not receive referral cashback here.',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            if (showOwnCode) ...[
              const SizedBox(height: 24),
              _buildOwnPartnerCodeCard(context, code, hasCode: hasCode),
            ],
            if (isNormal) ...[
              const SizedBox(height: 16),
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue),
                          SizedBox(width: 8),
                          Text(
                            'Why is balance ₹0?',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'You signed up as $category · $planLabel.\n\n'
                        '• Normal users do not earn partner referral money.\n'
                        '• If you used someone else\'s partner code, their wallet gets the ₹${cashbackEach.toStringAsFixed(0)} cashback.\n\n'
                        'To earn referrals, register a new account as Partner (₹${RegistrationPlan.partnerFeeInr}) or ask admin to set your account to Partner on the server.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade800,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            if (!showOwnCode && !isNormal) ...[
              const SizedBox(height: 16),
              Card(
                color: const Color(0xFF2196F3).withValues(alpha: 0.08),
                child: const ListTile(
                  leading: Icon(Icons.workspace_premium, color: Color(0xFF2196F3)),
                  title: Text('Become a Partner'),
                  subtitle: Text(
                    'Pay ₹5999 during registration to get your PRT- partner code and start earning on referrals.',
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
            if (_remote?.referralCount != null && (_remote!.referralCount ?? 0) > 0)
              _statRow('Successful referrals', '${_remote!.referralCount}'),
            if (_remote?.totalCashbackEarned != null &&
                (_remote!.totalCashbackEarned ?? 0) > 0)
              _statRow(
                'Total cashback earned',
                '₹${_remote!.totalCashbackEarned!.toStringAsFixed(2)}',
              ),
            if (_referralHistory.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Recent referral earnings',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              ..._referralHistory.take(10).map(_referralTile),
            ],
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.info_outline, color: Color(0xFF2196F3)),
                title: const Text('How it works'),
                subtitle: Text(
                  showOwnCode && hasCode
                      ? 'Share your partner code. When they choose Normal registration (₹${RegistrationPlan.normalFeeInr}) and enter your code, you receive ${(RegistrationPlan.referralCashbackRate * 100).toInt()}% (₹${cashbackEach.toStringAsFixed(0)}).'
                      : 'Normal registration cashback goes to the partner whose code was used — not to your wallet.',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _accountStatusCard({
    required String category,
    required String planLabel,
    required bool isNormal,
    required bool showOwnCode,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(
          showOwnCode ? Icons.verified : Icons.person_outline,
          color: const Color(0xFF2196F3),
        ),
        title: Text('$category · $planLabel'),
        subtitle: Text(
          showOwnCode
              ? 'Partner wallet — share your code to earn'
              : isNormal
                  ? 'Normal account — referral earnings not applicable'
                  : 'Check registration plan on server',
        ),
      ),
    );
  }

  Widget _referralTile(ReferralCreditEntry entry) {
    final date = '${entry.at.day}/${entry.at.month}/${entry.at.year}';
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.person_add_alt_1, color: Color(0xFF2196F3)),
        title: Text(entry.refereeName),
        subtitle: Text(
          '${entry.refereeMobile ?? 'Referral'} · $date'
          '${entry.syncedToServer ? '' : ' · pending server sync'}',
        ),
        trailing: Text(
          '+₹${entry.amount.toStringAsFixed(2)}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2196F3),
          ),
        ),
      ),
    );
  }

  Widget _buildOwnPartnerCodeCard(
    BuildContext context,
    String code, {
    required bool hasCode,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Row(
          children: [
            Icon(Icons.card_giftcard, color: Color(0xFF2196F3)),
            SizedBox(width: 8),
            Text(
              'Your partner code',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Share this code — others enter it during Normal registration (₹${RegistrationPlan.normalFeeInr}).',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF2196F3).withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF2196F3).withValues(alpha: 0.35),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: SelectableText(
                  hasCode ? code : '—',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: hasCode ? const Color(0xFF2196F3) : Colors.grey,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Copy your partner code',
                onPressed: hasCode
                    ? () {
                        Clipboard.setData(ClipboardData(text: code));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Partner code copied')),
                        );
                      }
                    : null,
                icon: const Icon(Icons.copy_rounded, color: Color(0xFF2196F3), size: 26),
              ),
            ],
          ),
        ),
        if (_codeFromRegistrationSeed && hasCode)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Code derived from your mobile until the server returns your official partner_code.',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600, height: 1.35),
            ),
          ),
      ],
    );
  }

  Widget _statRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade700)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
