import 'package:flutter/material.dart';
import '../api/api_client.dart';
import '../app_theme.dart';
import '../widgets/app_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Map<String, dynamic>? _userData;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await ApiClient.instance.me();
      setState(() => _userData = data);
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      setState(() => _loading = false);
    }
  }

  void _logout() async {
    await ApiClient.instance.logout();
    if (mounted) {
      // Navigate to login screen
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!, style: const TextStyle(color: AppColors.danger)),
                      const SizedBox(height: 12),
                      OutlinedButton(onPressed: _loadUserData, child: const Text('Повторить')),
                    ],
                  ),
                )
              : ListView(
                  children: [
                    _buildProfileSection(),
                    const SizedBox(height: 24),
                    _buildNotificationsSection(),
                    const SizedBox(height: 24),
                    _buildSecuritySection(),
                    const SizedBox(height: 24),
                    _buildAppearanceSection(),
                    const SizedBox(height: 24),
                    _buildAboutSection(),
                    const SizedBox(height: 32),
                    _buildLogoutButton(),
                  ],
                ),
    );
  }

  Widget _buildProfileSection() {
    final userName = _userData?['name'] ?? 'Пользователь';
    final userEmail = _userData?['email'] ?? '';

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Профиль',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.ink),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userEmail,
                      style: TextStyle(fontSize: 14, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSettingsRow(
            icon: Icons.edit,
            title: 'Редактировать профиль',
            onTap: () {
              // TODO: Navigate to edit profile screen
            },
          ),
          _buildSettingsRow(
            icon: Icons.photo,
            title: 'Изменить аватар',
            onTap: () {
              // TODO: Implement avatar change
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsSection() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Уведомления',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          _buildSettingsRow(
            icon: Icons.notifications_active,
            title: 'Уведомления о транзакциях',
            trailing: Switch(
              value: true,
              onChanged: (value) {
                // TODO: Implement notification toggle
              },
              activeColor: AppColors.accent,
            ),
          ),
          _buildSettingsRow(
            icon: Icons.notifications_none,
            title: 'Еженедельные отчёты',
            trailing: Switch(
              value: false,
              onChanged: (value) {
                // TODO: Implement notification toggle
              },
              activeColor: AppColors.accent,
            ),
          ),
          _buildSettingsRow(
            icon: Icons.warning,
            title: 'Предупреждения о бюджете',
            trailing: Switch(
              value: true,
              onChanged: (value) {
                // TODO: Implement notification toggle
              },
              activeColor: AppColors.accent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecuritySection() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Безопасность',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          _buildSettingsRow(
            icon: Icons.lock,
            title: 'Изменить пароль',
            onTap: () {
              // TODO: Navigate to change password screen
            },
          ),
          _buildSettingsRow(
            icon: Icons.login,
            title: 'Двухфакторная аутентификация',
            trailing: Switch(
              value: false,
              onChanged: (value) {
                // TODO: Implement 2FA toggle
              },
              activeColor: AppColors.accent,
            ),
          ),
          _buildSettingsRow(
            icon: Icons.login,
            title: 'Сессии устройств',
            onTap: () {
              // TODO: Navigate to device sessions screen
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAppearanceSection() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Внешний вид',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          _buildSettingsRow(
            icon: Icons.brightness_6,
            title: 'Тема приложения',
            trailing: DropdownButton<String>(
              value: 'tёмная',
              underline: const SizedBox(),
              icon: const Icon(Icons.arrow_drop_down,
                  color: AppColors.muted),
              items: const [
                DropdownMenuItem(
                  value: 'тёмная',
                  child: Text('Тёмная',
                      style: TextStyle(color: AppColors.fg)),
                ),
                DropdownMenuItem(
                  value: 'светлая',
                  child: Text('Светлая',
                      style: TextStyle(color: AppColors.fg)),
                ),
              ],
              onChanged: (value) {
                // TODO: Implement theme change
                // This would require restarting the app or using ThemeMode
              },
            ),
          ),
          _buildSettingsRow(
            icon: Icons.currency_exchange,
            title: 'Валюта по умолчанию',
            trailing: DropdownButton<String>(
              value: 'AZN',
              underline: const SizedBox(),
              icon: const Icon(Icons.arrow_drop_down,
                  color: AppColors.muted),
              items: const [
                DropdownMenuItem(
                  value: 'AZN',
                  child: Text('Азербайджанский манат (AZN)',
                      style: TextStyle(color: AppColors.fg)),
                ),
                DropdownMenuItem(
                  value: 'USD',
                  child: Text('Доллар США (USD)',
                      style: TextStyle(color: AppColors.fg)),
                ),
                DropdownMenuItem(
                  value: 'EUR',
                  child: Text('Евро (EUR)',
                      style: TextStyle(color: AppColors.fg)),
                ),
                DropdownMenuItem(
                  value: 'RUB',
                  child: Text('Российский рубль (RUB)',
                      style: TextStyle(color: AppColors.fg)),
                ),
              ],
              onChanged: (value) {
                // TODO: Implement currency change
              },
            ),
          ),
          _buildSettingsRow(
            icon: Icons.calendar_today,
            title: 'Формат даты',
            trailing: DropdownButton<String>(
              value: 'дд.мм.гггг',
              underline: const SizedBox(),
              icon: const Icon(Icons.arrow_drop_down,
                  color: AppColors.muted),
              items: const [
                DropdownMenuItem(
                  value: 'дд.мм.гггг',
                  child: Text('ДД.ММ.ГГГГ',
                      style: TextStyle(color: AppColors.fg)),
                ),
                DropdownMenuItem(
                  value: 'мм/дд/гггг',
                  child: Text('ММ/ДД/ГГГГ',
                      style: TextStyle(color: AppColors.fg)),
                ),
                DropdownMenuItem(
                  value: 'гггг-мм-дд',
                  child: Text('ГГГГ-ММ-ДД',
                      style: TextStyle(color: AppColors.fg)),
                ),
              ],
              onChanged: (value) {
                // TODO: Implement date format change
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'О приложении',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          _buildSettingsRow(
            icon: Icons.info,
            title: 'Версия приложения',
            trailing: const Text('1.0.0',
                style: TextStyle(color: AppColors.muted)),
          ),
          _buildSettingsRow(
            icon: Icons.update,
            title: 'Обновления',
            trailing: const Text('Доступно',
                style: TextStyle(color: AppColors.accent)),
          ),
          _buildSettingsRow(
            icon: Icons.feedback,
            title: 'Обратная связь',
            onTap: () {
              // TODO: Implement feedback mechanism
            },
          ),
          _buildSettingsRow(
            icon: Icons.policy,
            title: 'Политика конфиденциальности',
            onTap: () {
              // TODO: Navigate to privacy policy
            },
          ),
          _buildSettingsRow(
            icon: Icons.gavel,
            title: 'Условия использования',
            onTap: () {
              // TODO: Navigate to terms of service
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsRow({
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: ListTile(
        leading: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.surface2,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Icon(icon, size: 18, color: AppColors.fg),
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16),
        ),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton(
        onPressed: _logout,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.danger,
          foregroundColor: AppColors.ink,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.field),
          ),
        ),
        child: const Text(
          'Выйти из аккаунта',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}