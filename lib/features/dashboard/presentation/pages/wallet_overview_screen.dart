import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:frontend_transactional_engine/features/auth/application/auth_flow_controller.dart';

class WalletOverviewScreen extends StatelessWidget {
  const WalletOverviewScreen({super.key});

  String _formatPhone(String phone) {
    if (phone.isEmpty) return '';
    final buffer = StringBuffer();
    for (var i = 0; i < phone.length; i++) {
      buffer.write(phone[i]);
      if (i.isOdd && i != phone.length - 1) {
        buffer.write(' ');
      }
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthFlowController>();

    final userFirstName = authController.profile?.firstName ?? 'Utilisateur';
    final userLastName = authController.profile?.lastName ?? '';
    final phoneNumberRaw =
        authController.storedPhoneNumber ?? authController.phoneNumber ?? '';
    final phoneNumber = _formatPhone(phoneNumberRaw);

    final greeting = userLastName.isNotEmpty
        ? '$userFirstName $userLastName'
        : userFirstName;

    final quickActions = [
      _QuickActionData(
        label: 'Transfert',
        icon: Icons.swap_horiz_rounded,
        background: const Color(0xFF6B3FE8),
      ),
      _QuickActionData(
        label: 'Paiement',
        icon: Icons.payments_rounded,
        background: const Color(0xFF4CAF50),
      ),
      _QuickActionData(
        label: 'Recharge',
        icon: Icons.phone_android_rounded,
        background: const Color(0xFFFF9800),
      ),
      _QuickActionData(
        label: 'Favoris',
        icon: Icons.star_rounded,
        background: const Color(0xFF00BCD4),
      ),
    ];

    final transactions = [
      const _TransactionData(
        title: 'Paiement Facture Senelec',
        subtitle: '11 Nov • 10:12',
        amount: '-12 500 CFA',
        isDebit: true,
      ),
      const _TransactionData(
        title: 'Transfert reçu - A. Diop',
        subtitle: '10 Nov • 18:45',
        amount: '+75 000 CFA',
        isDebit: false,
      ),
      const _TransactionData(
        title: 'Achat Crédit Orange',
        subtitle: '09 Nov • 08:21',
        amount: '-2 500 CFA',
        isDebit: true,
      ),
      const _TransactionData(
        title: 'Cash-in Agence Plateau',
        subtitle: '08 Nov • 16:05',
        amount: '+150 000 CFA',
        isDebit: false,
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              height: 280,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0D47FF), Color(0xFF4C6DFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(36),
                  bottomRight: Radius.circular(36),
                ),
              ),
            ),
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(greeting, phoneNumber),
                    const SizedBox(height: 24),
                    _buildBalanceCard(context),
                    const SizedBox(height: 24),
                    _buildQrCard(context, phoneNumber),
                    const SizedBox(height: 28),
                    Text(
                      'Actions rapides',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF2D2D2D),
                          ),
                    ),
                    const SizedBox(height: 14),
                    _QuickActionsRow(quickActions: quickActions),
                    const SizedBox(height: 32),
                    Text(
                      'Historique des transactions',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF2D2D2D),
                          ),
                    ),
                    const SizedBox(height: 14),
                    _TransactionList(transactions: transactions),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String greeting, String phoneNumber) {
    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: Colors.white.withOpacity(0.18),
          ),
          child: const Center(
            child: Icon(
              Icons.person,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bonjour,',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                greeting,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              if (phoneNumber.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  phoneNumber,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ],
          ),
        ),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.18),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Center(
            child: Icon(
              Icons.notifications_none_rounded,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D47FF).withOpacity(0.18),
            offset: const Offset(0, 18),
            blurRadius: 36,
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -40,
            top: -40,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF0D47FF).withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            left: -20,
            bottom: -30,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF4C6DFF).withOpacity(0.12),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF0FF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Portefeuille principal',
                        style: TextStyle(
                          color: Color(0xFF0D47FF),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.remove_red_eye_outlined),
                      color: const Color(0xFF9297B5),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  '350 250 CFA',
                  style: TextStyle(
                    color: Color(0xFF1A1C2D),
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.check_circle,
                      color: Color(0xFF4CAF50),
                      size: 18,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Solde à jour • Dernière synchro 2 min',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6F728C),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: _BalanceMeta(
                        label: 'Entrées',
                        value: '+75 000 CFA',
                        valueColor: const Color(0xFF1A1C2D),
                        icon: Icons.north_east_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _BalanceMeta(
                        label: 'Sorties',
                        value: '−32 700 CFA',
                        valueColor: const Color(0xFF1A1C2D),
                        icon: Icons.south_west_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _BalanceMeta(
                        label: 'Frais',
                        value: '1 050 CFA',
                        valueColor: const Color(0xFF1A1C2D),
                        icon: Icons.receipt_long_rounded,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQrCard(BuildContext context, String phoneNumber) {
    final qrData = phoneNumber.isNotEmpty
        ? 'wallet:$phoneNumber'
        : 'wallet:temp-${DateTime.now().millisecondsSinceEpoch}';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF0D47FF), Color(0xFF4C6DFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D47FF).withOpacity(0.18),
            offset: const Offset(0, 14),
            blurRadius: 28,
          ),
        ],
      ),
      padding: const EdgeInsets.all(3.2),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF1FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Carte dynamique',
                      style: TextStyle(
                        color: Color(0xFF0D47FF),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.more_horiz_rounded,
                      color: Color(0xFF0D47FF),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F7FB),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFE4E6F4),
                    width: 1.2,
                  ),
                ),
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    QrImageView(
                      data: qrData,
                      version: QrVersions.auto,
                      size: 200,
                      backgroundColor: Colors.transparent,
                      eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.circle,
                        color: Color(0xFF0D47FF),
                      ),
                      dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.circle,
                        color: Color(0xFF242843),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      phoneNumber.isNotEmpty
                          ? 'Wallet ID : $phoneNumber'
                          : 'Wallet ID temporaire',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1C2D),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(
                    Icons.shield_outlined,
                    color: Color(0xFF0D47FF),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      phoneNumber.isNotEmpty
                          ? 'Présentez ce code pour encaisser ou payer en toute sécurité, comme sur Wave.'
                          : 'Complétez votre profil pour générer un QR code définitif.',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6F6F7C),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
      ),
    );
  }
}

class _BalanceMeta extends StatelessWidget {
  const _BalanceMeta({
    required this.label,
    required this.value,
    required this.valueColor,
    required this.icon,
  });

  final String label;
  final String value;
  final Color valueColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFEAF0FF),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF0D47FF),
            size: 20,
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 90),
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF7C8094),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 100),
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: valueColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickActionData {
  const _QuickActionData({
    required this.label,
    required this.icon,
    required this.background,
  });

  final String label;
  final IconData icon;
  final Color background;
}

class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow({required this.quickActions});

  final List<_QuickActionData> quickActions;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: quickActions
          .map(
            (action) => _QuickActionButton(action: action),
          )
          .toList(),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({required this.action});

  final _QuickActionData action;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: action.background.withOpacity(0.13),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: action.background,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                action.icon,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          action.label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF40404E),
          ),
        ),
      ],
    );
  }
}

class _TransactionData {
  const _TransactionData({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isDebit,
  });

  final String title;
  final String subtitle;
  final String amount;
  final bool isDebit;
}

class _TransactionList extends StatelessWidget {
  const _TransactionList({required this.transactions});

  final List<_TransactionData> transactions;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F0F2D).withOpacity(0.06),
            offset: const Offset(0, 12),
            blurRadius: 24,
          ),
        ],
      ),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 12),
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final transaction = transactions[index];
          return ListTile(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: transaction.isDebit
                    ? const Color(0xFFFFEBEE)
                    : const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                transaction.isDebit
                    ? Icons.call_made_rounded
                    : Icons.call_received_rounded,
                color: transaction.isDebit
                    ? const Color(0xFFE53935)
                    : const Color(0xFF1E88E5),
              ),
            ),
            title: Text(
              transaction.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D2D2D),
              ),
            ),
            subtitle: Text(
              transaction.subtitle,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF8A8A9E),
              ),
            ),
            trailing: Text(
              transaction.amount,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: transaction.isDebit
                    ? const Color(0xFFE53935)
                    : const Color(0xFF1E88E5),
              ),
            ),
          );
        },
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: const Color(0xFFEFF1F8),
          indent: 16,
          endIndent: 16,
        ),
      ),
    );
  }
}

