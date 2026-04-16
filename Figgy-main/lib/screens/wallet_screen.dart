import 'package:flutter/material.dart';
import 'package:figgy_app/theme/app_theme.dart';
import 'package:figgy_app/services/wallet_service.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final WalletService _wallet = WalletService();
  bool _loading = true;
  int _balance = 0;
  List<WalletTransaction> _txs = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final txs = await _wallet.getTransactions();
    final bal = txs.fold<int>(0, (s, t) => s + t.amountInr);
    if (!mounted) return;
    setState(() {
      _txs = txs;
      _balance = bal;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.brandDeepBlue, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'WALLET',
          style: AppTypography.small.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: 2.0,
            color: AppColors.brandDeepBlue,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _load,
            icon: const Icon(Icons.refresh_rounded, color: AppColors.brandDeepBlue),
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.border.withValues(alpha: 0.3), height: 1),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.brandPrimary))
          : LayoutBuilder(
              builder: (context, constraints) {
                final double hPadding = constraints.maxWidth > 600 ? constraints.maxWidth * 0.15 : 20.0;
                return RefreshIndicator(
                  onRefresh: _load,
                  color: AppColors.brandPrimary,
                  child: ListView(
                    padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: AppSpacing.standard),
                    children: [
                      _buildBalanceCard(),
                      const SizedBox(height: AppSpacing.section),
                      Text(
                        'TRANSACTIONS',
                        style: AppTypography.small.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.standard),
                      if (_txs.isEmpty) _buildEmptyState() else ..._txs.map(_buildTxTile),
                      const SizedBox(height: 40),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildBalanceCard() {
    final isPositive = _balance >= 0;
    final balanceColor = isPositive ? AppColors.success : AppColors.error;
    final sign = isPositive ? '' : '-';
    final display = '${sign}₹${_balance.abs()}';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.3)),
        boxShadow: AppStyles.softShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: balanceColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.account_balance_wallet_outlined, color: balanceColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Available Balance', style: AppTypography.small.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(display, style: AppTypography.h1.copyWith(fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.brandDeepBlue)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppStyles.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.brandPrimary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.receipt_long_rounded, color: AppColors.brandPrimary, size: 44),
          ),
          const SizedBox(height: 20),
          Text('No transactions yet', style: AppTypography.h3.copyWith(fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Text(
            'Premium payments and claim payouts will appear here.',
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildTxTile(WalletTransaction tx) {
    final isCredit = tx.amountInr >= 0;
    final amountColor = isCredit ? AppColors.success : AppColors.error;
    final amountStr = (isCredit ? '+₹' : '-₹') + tx.amountInr.abs().toString();

    IconData icon;
    Color iconColor;
    switch (tx.category) {
      case 'premium':
        icon = Icons.shield_rounded;
        iconColor = AppColors.brandPrimary;
        break;
      case 'payout':
        icon = Icons.payments_rounded;
        iconColor = AppColors.success;
        break;
      default:
        icon = Icons.receipt_long_rounded;
        iconColor = AppColors.info;
        break;
    }

    final dateStr =
        '${tx.createdAt.day.toString().padLeft(2, '0')}/${tx.createdAt.month.toString().padLeft(2, '0')}/${tx.createdAt.year}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.3)),
        boxShadow: AppStyles.softShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx.reason, style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                Text(
                  tx.refId != null && tx.refId!.isNotEmpty ? '$dateStr  •  ${tx.refId}' : dateStr,
                  style: AppTypography.small.copyWith(color: AppColors.textSecondary, fontSize: 10),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            amountStr,
            style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w900, color: amountColor),
          ),
        ],
      ),
    );
  }
}

