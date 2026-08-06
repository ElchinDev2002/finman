import 'package:flutter/material.dart';
import '../api/api_client.dart';
import '../app_theme.dart';
import '../widgets/app_card.dart';
import 'package:intl/intl.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  List<dynamic> _transactions = [];
  String? _error;
  bool _loading = true;
  final NumberFormat _currencyFormat =
      NumberFormat.currency(locale: 'az', symbol: '');

  // Filters
  String _selectedType = 'all'; // all, income, expense
  DateTime? _startDate;
  DateTime? _endDate;
  String _selectedCategory = 'all';

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await ApiClient.instance.get('/transactions');
      setState(() => _transactions = List<dynamic>.from(data));
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      setState(() => _loading = false);
    }
  }

  List<dynamic> _getFilteredTransactions() {
    return _transactions.where((tx) {
      final typeMatch =
          _selectedType == 'all' || tx['type'] == _selectedType;
      final date = DateTime.parse(tx['date']);
      final dateMatch = (_startDate == null ||
              date.isAfter(_startDate!.subtract(const Duration(days: 1)))) &&
          (_endDate == null ||
              date.isBefore(_endDate!.add(const Duration(days: 1))));
      final categoryMatch =
          _selectedCategory == 'all' || tx['category'] == _selectedCategory;
      return typeMatch && dateMatch && categoryMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Транзакции'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTransactions,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadTransactions,
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_error!, style: const TextStyle(color: AppColors.danger)),
                        const SizedBox(height: 12),
                        OutlinedButton(onPressed: _loadTransactions, child: const Text('Повторить')),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      _buildSummaryStats(),
                      const SizedBox(height: 16),
                      Expanded(
                        child: _getFilteredTransactions().isEmpty
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(24),
                                  child: Text('Нет транзакций'),
                                ),
                              )
                            : ListView.builder(
                                itemCount: _getFilteredTransactions().length,
                                itemBuilder: (context, index) {
                                  final tx = _getFilteredTransactions()[index];
                                  return _buildTransactionItem(tx);
                                },
                              ),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildSummaryStats() {
    final filtered = _getFilteredTransactions();
    final income =
        filtered.where((tx) => tx['type'] == 'income').fold(0.0, (sum, tx) => sum + (tx['amount']?.toDouble() ?? 0));
    final expenses =
        filtered.where((tx) => tx['type'] == 'expense').fold(0.0, (sum, tx) => sum + (tx['amount']?.toDouble() ?? 0));
    final count = filtered.length;

    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem('Всего', count.toString(), AppColors.fg),
            _buildStatItem('Доход', '+${_currencyFormat.format(income)}', AppColors.accent),
            _buildStatItem('Расход', '-${_currencyFormat.format(expenses)}', AppColors.danger),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: AppColors.muted)),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: color)),
      ],
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> tx) {
    final amount = tx['amount']?.toDouble() ?? 0;
    final type = tx['type'] == 'income' ? 'income' : 'expense';
    final isIncome = type == 'income';
    final date = DateTime.parse(tx['date']);
    final formattedDate = DateFormat('dd.MM.yyyy HH:mm').format(date);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border),
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
              color: isIncome ? AppColors.accent : AppColors.danger,
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
                const SizedBox(height: 4),
                Text(
                  '${tx['category'] ?? ''} • ${tx['account'] ?? ''}',
                  style: TextStyle(fontSize: 12, color: AppColors.muted),
                ),
                const SizedBox(height: 2),
                Text(
                  formattedDate,
                  style: TextStyle(fontSize: 10, color: AppColors.muted),
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
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.85,
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Фильтры',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 24),
              _buildTypeFilter(),
              const SizedBox(height: 16),
              _buildDateFilter(),
              const SizedBox(height: 16),
              _buildCategoryFilter(),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Сбросить'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {}); // Trigger rebuild with new filters
                      Navigator.pop(context);
                    },
                    child: const Text('Применить'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Тип', style: TextStyle(fontSize: 14, color: AppColors.muted)),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildFilterButton('Все', 'all'),
            const SizedBox(width: 8),
            _buildFilterButton('Доход', 'income'),
            const SizedBox(width: 8),
            _buildFilterButton('Расход', 'expense'),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterButton(String label, String value) {
    final selected = _selectedType == value;
    return Expanded(
      child: OutlinedButton(
        onPressed: () => setState(() => _selectedType = value),
        style: OutlinedButton.styleFrom(
          backgroundColor: selected ? AppColors.accent : null,
          foregroundColor: selected ? AppColors.ink : AppColors.fg,
          side: BorderSide(color: AppColors.border),
        ),
        child: Text(label),
      ),
    );
  }

  Widget _buildDateFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Дата', style: TextStyle(fontSize: 14, color: AppColors.muted)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildDatePickerField('С', _startDate, (date) {
                setState(() => _startDate = date);
              }),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDatePickerField('По', _endDate, (date) {
                setState(() => _endDate = date);
              }),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDatePickerField(String label, DateTime? date, Function(DateTime?) onChanged) {
    return TextField(
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppColors.muted),
        suffixIcon: const Icon(Icons.calendar_today, size: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.field),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.field),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.field),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
      ),
      controller: TextEditingController(
          text: date != null ? DateFormat('dd.MM.yyyy').format(date) : ''),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        if (picked != null) onChanged(picked);
      },
    );
  }

  Widget _buildCategoryFilter() {
    // Get unique categories from transactions
    final categories = <String>{
      'all',
      ..._transactions.map((tx) => tx['category'] as String?).where((c) => c != null).cast<String>()
    }.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Категория', style: TextStyle(fontSize: 14, color: AppColors.muted)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: categories.map((category) {
            final selected = _selectedCategory == category;
            return FilterChip(
              label: Text(category),
              selected: selected,
              onSelected: (selected) =>
                  setState(() => _selectedCategory = selected ? category : 'all'),
              backgroundColor: AppColors.surface2,
              selectedColor: AppColors.accent.withOpacity(0.2),
              labelStyle: TextStyle(
                color: selected ? AppColors.accent : AppColors.fg,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}