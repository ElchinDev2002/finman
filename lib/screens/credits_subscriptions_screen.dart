import 'package:flutter/material.dart';
import '../api/api_client.dart';
import '../app_theme.dart';
import '../widgets/app_card.dart';
import 'package:intl/intl.dart';

class CreditsSubscriptionsScreen extends StatefulWidget {
  const CreditsSubscriptionsScreen({super.key});

  @override
  State<CreditsSubscriptionsScreen> createState() =>
      _CreditsSubscriptionsScreenState();
}

class _CreditsSubscriptionsScreenState
    extends State<CreditsSubscriptionsScreen> {
  List<dynamic> _upcoming = [];
  String? _error;
  bool _loading = true;
  final NumberFormat _currencyFormat =
      NumberFormat.currency(locale: 'az', symbol: '');
  final DateFormat _dateFormat =
      DateFormat('dd.MM.yyyy'); // Just date for recurring items

  @override
  void initState() {
    super.initState();
    _loadUpcoming();
  }

  Future<void> _loadUpcoming() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await ApiClient.instance.get('/upcoming');
      setState(() => _upcoming = List<dynamic>.from(data));
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      setState(() => _loading = false);
    }
  }

  List<dynamic> _getSubscriptions() {
    return _upcoming
        .where((item) => item['kind'] == 'subscription')
        .toList();
  }

  List<dynamic> _getCreditsAndBills() {
    return _upcoming
        .where((item) => item['kind'] == 'credit' || item['kind'] == 'bill')
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Кредиты и подписки'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _loadUpcoming,
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_error!, style: const TextStyle(color: AppColors.danger)),
                        const SizedBox(height: 12),
                        OutlinedButton(onPressed: _loadUpcoming, child: const Text('Повторить')),
                      ],
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildSubscriptionsSection(),
                      const SizedBox(height: 24),
                      _buildCreditsAndBillsSection(),
                    ],
                  ),
      ),
    );
  }

  Widget _buildSubscriptionsSection() {
    final subscriptions = _getSubscriptions();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Подписки',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          subscriptions.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Нет активных подписок'),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: subscriptions.length,
                  itemBuilder: (context, index) {
                    final sub = subscriptions[index];
                    final amount = sub['amount']?.toDouble() ?? 0;
                    final date = DateTime.parse(sub['date']);
                    final formattedDate = _dateFormat.format(date);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface2,
                        borderRadius: BorderRadius.circular(AppRadius.card),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: AppColors.accent.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Center(
                              child: Text(
                                sub['icon'] ?? '?',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  sub['name'] ?? '',
                                  style: const TextStyle(
                                      fontSize: 16, fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${_currencyFormat.format(amount)} • $formattedDate',
                                  style: TextStyle(
                                      fontSize: 14, color: AppColors.muted),
                                ),
                              ],
                            ),
                          ),
                          // Status indicator - active subscription
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: AppColors.accent,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildCreditsAndBillsSection() {
    final items = _getCreditsAndBills();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Кредиты и счета',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          items.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Нет активных кредитов или счетов'),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final amount = item['amount']?.toDouble() ?? 0;
                    final date = DateTime.parse(item['date']);
                    final formattedDate = _dateFormat.format(date);
                    final isCredit = item['kind'] == 'credit';
                    final isBill = item['kind'] == 'bill';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isCredit
                            ? AppColors.accent.withOpacity(0.1)
                            : AppColors.danger.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppRadius.card),
                        border: Border.all(
                          color: isCredit
                              ? AppColors.accent.withOpacity(0.3)
                              : AppColors.danger.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: isCredit
                                  ? AppColors.accent.withOpacity(0.2)
                                  : AppColors.danger.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Center(
                              child: Text(
                                item['icon'] ?? (isCredit ? '���🏦' : '���🧾'),
                                style: const TextStyle(
                                    fontSize: 14,
                                    color: isCredit
                                        ? AppColors.accent
                                        : AppColors.danger),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['name'] ?? '',
                                  style: const TextStyle(
                                      fontSize: 16, fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${isCredit ? 'Кредит' : 'Счет'} • $formattedDate',
                                  style: TextStyle(
                                      fontSize: 14, color: AppColors.muted),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${_currencyFormat.format(amount)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isCredit
                                  ? AppColors.accent
                                  : AppColors.danger,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}