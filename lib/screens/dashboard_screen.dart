import 'package:flutter/material.dart';
import '../api/api_client.dart';
import '../app_theme.dart';
import '../widgets/app_card.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? _data;
  String? _error;
  bool _loading = true;
  final NumberFormat _currencyFormat =
      NumberFormat.currency(locale: 'az', symbol: '');

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await ApiClient.instance.dashboard();
      setState(() => _data = data);
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
            : _error != null
                ? ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      Text(_error!, style: const TextStyle(color: AppColors.danger)),
                      const SizedBox(height: 12),
                      OutlinedButton(onPressed: _load, child: const Text('Повторить')),
                    ],
                  )
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildWelcomeSection(),
                      const SizedBox(height: 16),
                      _buildStatsRow(),
                      const SizedBox(height: 16),
                      _buildCategoriesSection(),
                      const SizedBox(height: 16),
                      _buildBudgetProgressSection(),
                      const SizedBox(height: 16),
                      _buildRecentTransactionsSection(),
                      const SizedBox(height: 16),
                      _buildAccountsSection(),
                      const SizedBox(height: 16),
                      _buildGoalsSection(),
                      const SizedBox(height: 16),
                      _buildSubscriptionsSection(),
                      const SizedBox(height: 16),
                      _buildUpcomingSection(),
                      const SizedBox(height: 16),
                      _buildPaydayAndTipsSection(),
                    ],
                  ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    final userName = _data?['userName'] ?? 'Пользователь';
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Привет, $userName!',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          const Text(
            'Ваш текущий баланс',
            style: TextStyle(fontSize: 14, color: AppColors.muted),
          ),
          const SizedBox(height: 8),
          Text(
            '${_currencyFormat.format(_data?['balance'] ?? 0)}',
            style: const TextStyle(
                fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.fg),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    final income = _data?['income'] ?? 0;
    final expenses = _data?['expenses'] ?? 0;
    final spendableToday = _data?['spendableToday'] ?? 0;
    final budgetRemaining = _data?['budgetRemaining'] ?? 0;

    return Row(
      children: [
        _buildStatCard('Доход', '+${_currencyFormat.format(income)}', AppColors.accent),
        const SizedBox(width: 12),
        _buildStatCard('Расход', '-${_currencyFormat.format(expenses)}', AppColors.danger),
        const SizedBox(width: 12),
        _buildStatCard('Сегодня можно потратить', _currencyFormat.format(spendableToday), AppColors.brand),
        const SizedBox(width: 12),
        _buildStatCard('Осталось бюджета', _currencyFormat.format(budgetRemaining), AppColors.accent2),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: AppCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12, color: AppColors.muted),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesSection() {
    final categories = _data?['categories'] as List? ?? [];
    if (categories.isEmpty) {
      return const AppCard(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Нет данных о категориях'),
        ),
      );
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Расходы по категориям',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: categories.map((category) {
                final amount = category['amount']?.toDouble() ?? 0;
                final pct = category['pct']?.toDouble() ?? 0;
                return Container(
                  width: 80,
                  margin: const EdgeInsets.only(right: 12),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Color(int.parse(
                              category['color']?.replaceFirst('#', '0xFF') ?? '0xFFCCCCCC')),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            category['icon'] ?? '?',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        category['name'] ?? '',
                        style: const TextStyle(fontSize: 10),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${_currencyFormat.format(amount)} (${pct.toStringAsFixed(0)}%)',
                        style: const TextStyle(fontSize: 10, color: AppColors.muted),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetProgressSection() {
    final budgetPlan = _data?['budgetPlan'] as List? ?? [];
    if (budgetPlan.isEmpty) {
      return const AppCard(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Нет данных о бюджете'),
        ),
      );
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Бюджет',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Column(
            children: budgetPlan.map((item) {
              final limit = item['limit']?.toDouble() ?? 0;
              final spent = item['spent']?.toDouble() ?? 0;
              final percent = limit > 0 ? (spent / limit) : 0;
              final remaining = limit - spent;

              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item['name'] ?? '',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      Text(
                        '${_currencyFormat.format(spent)} / ${_currencyFormat.format(limit)}',
                        style: const TextStyle(fontSize: 12, color: AppColors.muted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: percent.clamp(0.0, 1.0),
                      backgroundColor: AppColors.surface2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          percent > 0.9 ? AppColors.danger : AppColors.accent),
                      minHeight: 6,
                    ),
                  ),
                  if (percent > 0.9)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Превышен лимит!',
                        style: TextStyle(
                            fontSize: 10, color: AppColors.danger, fontWeight: FontWeight.w500),
                      ),
                    ),
                  const SizedBox(height: 12),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactionsSection() {
    final recent = _data?['recent'] as List? ?? [];
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Последние операции',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              TextButton(
                onPressed: () {
                  // TODO: Navigate to transactions screen
                },
                child: const Text('Показать все',
                    style: TextStyle(color: AppColors.accent)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          recent.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('Нет операций'),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recent.length > 5 ? 5 : recent.length,
                  itemBuilder: (context, index) {
                    final tx = recent[index];
                    final amount = tx['amount']?.toDouble() ?? 0;
                    final type = tx['type'] == 'income' ? 'income' : 'expense';
                    final isIncome = type == 'income';
                    final date = DateTime.parse(tx['date']);
                    final formattedDate =
                        DateFormat('dd.MM').format(date); // Just day.month for today's context

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surface2,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: isIncome
                                  ? AppColors.accent.withOpacity(0.2)
                                  : AppColors.danger.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Icon(
                              isIncome ? Icons.arrow_upward : Icons.arrow_downward,
                              size: 16,
                              color: isIncome
                                  ? AppColors.accent
                                  : AppColors.danger,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tx['description'] ?? '',
                                  style: const TextStyle(
                                      fontSize: 14, fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${tx['category'] ?? ''} • ${tx['account'] ?? ''}',
                                  style: TextStyle(
                                      fontSize: 12, color: AppColors.muted),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${isIncome ? '+' : '-'}${_currencyFormat.format(amount)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isIncome ? AppColors.accent : AppColors.danger,
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

  Widget _buildAccountsSection() {
    final accounts = _data?['accounts'] as List? ?? [];
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Счета',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              TextButton(
                onPressed: () {
                  // TODO: Navigate to accounts screen
                },
                child: const Text('Показать все',
                    style: TextStyle(color: AppColors.accent)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          accounts.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('Нет счетов'),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: accounts.length,
                  itemBuilder: (context, index) {
                    final acc = accounts[index];
                    final balance = acc['balance']?.toDouble() ?? 0;
                    return ListTile(
                      leading: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.surface2,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Center(
                          child: Text(
                            acc['icon'] ?? '?',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                      title: Text(
                        acc['name'] ?? '',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(
                        acc['type'] ?? '',
                        style: TextStyle(fontSize: 12, color: AppColors.muted),
                      ),
                      trailing: Text(
                        '${_currencyFormat.format(balance)}',
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildGoalsSection() {
    final goals = _data?['goals'] as List? ?? [];
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Цели',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              TextButton(
                onPressed: () {
                  // TODO: Navigate to goals screen
                },
                child: const Text('Показать все',
                    style: TextStyle(color: AppColors.accent)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          goals.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('Нет целей'),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: goals.length,
                  itemBuilder: (context, index) {
                    final goal = goals[index];
                    final saved = goal['saved']?.toDouble() ?? 0;
                    final target = goal['target']?.toDouble() ?? 0;
                    final percent = target > 0 ? saved / target : 0;
                    final remaining = goal['remaining']?.toDouble() ?? 0;

                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                goal['name'] ?? '',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            Text(
                              '${_currencyFormat.format(saved)} / ${_currencyFormat.format(target)}',
                              style: const TextStyle(fontSize: 12, color: AppColors.muted),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: percent.clamp(0.0, 1.0),
                            backgroundColor: AppColors.surface2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                            minHeight: 6,
                          ),
                        ),
                        if (remaining > 0)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              'Осталось: ${_currencyFormat.format(remaining)}',
                              style: TextStyle(
                                  fontSize: 10, color: AppColors.muted),
                            ),
                          ),
                        const SizedBox(height: 12),
                      ],
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionsSection() {
    final subscriptions = _data?['subscriptions'] as List? ?? [];
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Подписки',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              TextButton(
                onPressed: () {
                  // TODO: Navigate to subscriptions screen
                },
                child: const Text('Показать все',
                    style: TextStyle(color: AppColors.accent)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          subscriptions.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('Нет подписок'),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: subscriptions.length,
                  itemBuilder: (context, index) {
                    final sub = subscriptions[index];
                    final amount = sub['amount']?.toDouble() ?? 0;
                    final date = DateTime.parse(sub['date']);
                    final formattedDate =
                        DateFormat('dd.MM').format(date);

                    return ListTile(
                      leading: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.surface2,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Center(
                          child: Text(
                            sub['icon'] ?? '?',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                      title: Text(
                        sub['name'] ?? '',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(
                        '${_currencyFormat.format(amount)} • $formattedDate',
                        style: TextStyle(fontSize: 12, color: AppColors.muted),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildUpcomingSection() {
    final upcoming = _data?['upcoming'] as List? ?? [];
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Ближайшие платежи',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              TextButton(
                onPressed: () {
                  // TODO: Navigate to upcoming screen
                },
                child: const Text('Показать все',
                    style: TextStyle(color: AppColors.accent)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          upcoming.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('Ближайших платежей нет'),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: upcoming.length,
                  itemBuilder: (context, index) {
                    final up = upcoming[index];
                    final amount = up['amount']?.toDouble() ?? 0;
                    final date = DateTime.parse(up['date']);
                    final formattedDate =
                        DateFormat('dd.MM').format(date);

                    return ListTile(
                      leading: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.danger.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Center(
                          child: Text(
                            up['icon'] ?? '?',
                            style: const TextStyle(fontSize: 14,
                                color: AppColors.danger),
                          ),
                        ),
                      ),
                      title: Text(
                        up['name'] ?? '',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(
                        '${_currencyFormat.format(amount)} • $formattedDate',
                        style: TextStyle(fontSize: 12, color: AppColors.muted),
                      ),
                      trailing: Icon(Icons.chevron_right,
                          color: AppColors.muted, size: 18),
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildPaydayAndTipsSection() {
    final payday = _data?['payday'] as Map? ?? {};
    final tips = _data?['tips'] as List? ?? [];

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'До зарплаты и советы',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'До зарплаты: ${payday['days'] ?? 0} дней',
                      style: const TextStyle(fontSize: 14),
                    ),
                    if (payday['date'] != null)
                      Text(
                        DateFormat('dd.MM.yyyy')
                            .format(DateTime.parse(payday['date'])),
                        style: TextStyle(fontSize: 12, color: AppColors.muted),
                      ),
                  ],
                ),
              ),
              // Tips section
              if (tips.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: tips.map((tip) {
                    return Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surface2,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            alignment: Alignment.center,
                            child: Text(tip['icon'] ?? '?'),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(tip['text'] ?? '',
                                    style: const TextStyle(fontSize: 12)),
                                if (tip['highlight'] != null)
                                  Text(
                                    tip['highlight'] ?? '',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.accent),
                                  ),
                                if (tip['tail'] != null)
                                  Text(tip['tail'] ?? '',
                                      style: const TextStyle(fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ],
      ),
    );
  }
}