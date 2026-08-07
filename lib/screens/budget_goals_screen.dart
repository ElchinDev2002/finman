import 'package:flutter/material.dart';
import '../api/api_client.dart';
import '../app_theme.dart';
import '../widgets/app_card.dart';
import 'package:intl/intl.dart';

class BudgetGoalsScreen extends StatefulWidget {
  const BudgetGoalsScreen({super.key});

  @override
  State<BudgetGoalsScreen> createState() => _BudgetGoalsScreenState();
}

class _BudgetGoalsScreenState extends State<BudgetGoalsScreen> {
  Map<String, dynamic>? _dashboardData;
  List<dynamic> _goals = [];
  String? _error;
  bool _loading = true;
  final NumberFormat _currencyFormat =
      NumberFormat.currency(locale: 'az', symbol: '');

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      // Fetch dashboard data for budget plan
      final dashboardData = await ApiClient.instance.dashboard();
      // Fetch goals data
      final goalsData = await ApiClient.instance.get('/api/goals');

      setState(() {
        _dashboardData = dashboardData;
        _goals = List<dynamic>.from(goalsData);
      });
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
        title: const Text('Бюджет и цели'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_error!, style: const TextStyle(color: AppColors.danger)),
                        const SizedBox(height: 12),
                        OutlinedButton(onPressed: _loadData, child: const Text('Повторить')),
                      ],
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (_dashboardData != null) ...[
                        _buildBudgetSection(),
                        const SizedBox(height: 24),
                      ],
                      if (_goals.isNotEmpty) ...[
                        _buildGoalsSection(),
                      ] else ...[
                        const AppCard(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Text('Нет данных о целях',
                                style: TextStyle(color: AppColors.muted)),
                          ),
                        ),
                      ],
                    ],
                  ),
      ),
    );
  }

  Widget _buildBudgetSection() {
    final budgetPlan =
        _dashboardData?['budgetPlan'] as List<dynamic>? ?? [];

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Бюджет',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          budgetPlan.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Нет данных о бюджете'),
                )
              : Column(
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
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                            Text(
                              '${_currencyFormat.format(spent)} / ${_currencyFormat.format(limit)}',
                              style: const TextStyle(fontSize: 14, color: AppColors.muted),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: percent.clamp(0.0, 1.0),
                            backgroundColor: AppColors.surface2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                percent > 0.9 ? AppColors.danger : AppColors.accent),
                            minHeight: 8,
                          ),
                        ),
                        if (percent > 0.9) ...[
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              'Превышен лимит!',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.danger,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                      ],
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildGoalsSection() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Финансовые цели',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _goals.length,
            itemBuilder: (context, index) {
              final goal = _goals[index];
              final saved = goal['savedAmount']?.toDouble() ?? 0;
              final target = goal['targetAmount']?.toDouble() ?? 0;
              final percent = target > 0 ? saved / target : 0;
              final remaining = target - saved;

              return Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        alignment: Alignment.center,
                        child: Text(
                          goal['emoji'] ?? '���🎯',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          goal['name'] ?? '',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${_currencyFormat.format(saved)} / ${_currencyFormat.format(target)}',
                          style: const TextStyle(fontSize: 14, color: AppColors.muted),
                        ),
                      ),
                      if (remaining > 0) ...[
                        Text(
                          'Осталось: ${_currencyFormat.format(remaining)}',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.muted),
                        ),
                      ],
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
                  if (index < _goals.length - 1)
                    const SizedBox(height: 24),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}