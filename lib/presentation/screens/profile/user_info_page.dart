import 'package:drivebuy/data/repositories/auth_repository.dart';
import 'package:drivebuy/data/repositories/user_repository.dart';
import 'package:drivebuy/presentation/app/bloc/auth_cubit.dart';
import 'package:drivebuy/presentation/app/di/locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'bloc/user_info_bloc.dart';
import 'bloc/user_info_event.dart';
import 'bloc/user_info_state.dart';

class UserInfoPage extends StatelessWidget {
  const UserInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UserInfoBloc(
        userRepository: locator<UserRepository>(),
        router: locator<GoRouter>(),
        authRepository: locator<AuthRepository>(),
      )..add(const UserInfoLoaded()),
      child: const UserInfoView(),
    );
  }
}

class UserInfoView extends StatelessWidget {
  const UserInfoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Профил'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              context.read<UserInfoBloc>().add(const NavigateToEditUser());
            },
          ),
        ],
      ),
      body: SafeArea(
        bottom: true,
        child: BlocBuilder<UserInfoBloc, UserInfoState>(
        builder: (context, state) {
          final user = context.watch<AuthCubit>().state;
          if (user == null) {
            // If not authenticated, redirect to marketplace
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.read<UserInfoBloc>().add(const GoToMarketplace());
            });
            return const SizedBox.shrink();
          }

          if (state.status == UserInfoStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == UserInfoStatus.failure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    state.errorMessage ?? 'Неуспешно зареждане на профил',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<UserInfoBloc>().add(const UserInfoLoaded());
                    },
                    child: const Text('Повторен опит'),
                  ),
                ],
              ),
            );
          }

          if (state.user == null) {
            return const Center(child: Text('Потребителят не е намерен'));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Theme.of(context).primaryColor,
                child: Text(
                  _getInitials(state.user!['name'] ?? ''),
                  style: const TextStyle(fontSize: 32, color: Colors.white),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                state.user!['name'] ?? 'Неизвестен потребител',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Email: ${state.user!['email'] ?? ''}',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              if ((state.user!['phone'] ?? '').isNotEmpty)
                Text(
                  'Телефон: ${state.user!['phone']}',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 32),
              _buildSection(
                context,
                'Моите обяви',
                Icons.car_rental,
                () {
                  context.read<UserInfoBloc>().add(const NavigateToUserListedAds());
                },
              ),
              _buildSection(
                context,
                'Запазени обяви',
                Icons.favorite,
                () {
                  context.read<UserInfoBloc>().add(const NavigateToUserSavedAds());
                },
              ),
              // _buildSection(
              //   context,
              //   'Настройки',
              //   Icons.settings,
              //   () {
              //     // TODO: Navigate to settings
              //   },
              // ),
              // _buildSection(
              //   context,
              //   'Помощ и поддръжка',
              //   Icons.help,
              //   () {
              //     // TODO: Navigate to help & support
              //   },
              // ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => _handleLogout(context),
                icon: const Icon(Icons.logout),
                label: const Text('Изход от профила'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          );
        },
        ),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'U';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  void _handleLogout(BuildContext context) async {
    try {
      await locator<AuthRepository>().signOut();
      // The AuthCubit will automatically update the UI when the user signs out
      if (context.mounted) {
        context.read<UserInfoBloc>().add(const GoToMarketplace());
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Неуспешно излизане: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
} 