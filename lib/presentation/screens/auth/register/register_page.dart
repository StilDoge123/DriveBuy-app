import 'package:drivebuy/presentation/app/di/locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/register_bloc.dart';
import 'bloc/register_event.dart';
import 'bloc/register_state.dart';
import 'package:go_router/go_router.dart';
import 'package:drivebuy/presentation/app/bloc/auth_cubit.dart';
import 'package:drivebuy/data/repositories/auth_repository.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final router = locator<GoRouter>();
    return BlocProvider(
      create: (context) => RegisterBloc(
        authRepository: AuthRepository(),
        router: router,
      ),
      child: const RegisterView(),
    );
  }
}

class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RegisterBloc(
        authRepository: AuthRepository(),
        router: locator<GoRouter>(),
      ),
    child: Scaffold(
      appBar: AppBar(
        title: const Text('Създай акаунт'),
      ),
      body: BlocListener<RegisterBloc, RegisterState>(
        listener: (context, state) {
          if (state.status == RegisterStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Неуспешна регистрация'),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state.status == RegisterStatus.success) {
            // Set AuthCubit to true and navigate to home/marketplace
            context.read<AuthCubit>().setRegistered(true);
            context.read<RegisterBloc>().add(const NavigateToMarketplace());
          }
        },
        child: SafeArea(
          bottom: true,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.car_rental,
                  size: 100,
                  color: Colors.blue,
                ),
                const SizedBox(height: 32),
                Text(
                  'Регистрирай се в DriveBuy',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                _NameInput(),
                const SizedBox(height: 16),
                _EmailInput(),
                const SizedBox(height: 16),
                _PhoneInput(),
                const SizedBox(height: 16),
                _PasswordInput(),
                const SizedBox(height: 16),
                _ConfirmPasswordInput(),
                const SizedBox(height: 24),
                _RegisterButton(),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    context.read<RegisterBloc>().add(const NavigateToLogin());
                  },
                  child: const Text('Имате акаунт? Влезте тук'),
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}

class _NameInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterBloc, RegisterState>(
      buildWhen: (previous, current) => previous.name != current.name,
      builder: (context, state) {
        return TextField(
          key: const Key('registerForm_nameInput_textField'),
          onChanged: (name) =>
              context.read<RegisterBloc>().add(RegisterNameChanged(name)),
          decoration: const InputDecoration(
            labelText: 'Име',
            helperText: '',
            prefixIcon: Icon(Icons.person),
            border: OutlineInputBorder(),
          ),
        );
      },
    );
  }
}

class _EmailInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterBloc, RegisterState>(
      buildWhen: (previous, current) => previous.email != current.email,
      builder: (context, state) {
        return TextField(
          key: const Key('registerForm_emailInput_textField'),
          onChanged: (email) =>
              context.read<RegisterBloc>().add(RegisterEmailChanged(email)),
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Email',
            helperText: '',
            prefixIcon: Icon(Icons.email),
            border: OutlineInputBorder(),
          ),
        );
      },
    );
  }
}

class _PhoneInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterBloc, RegisterState>(
      buildWhen: (previous, current) => previous.phone != current.phone,
      builder: (context, state) {
        return TextField(
          key: const Key('registerForm_phoneInput_textField'),
          onChanged: (phone) =>
              context.read<RegisterBloc>().add(RegisterPhoneChanged(phone)),
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Телефон',
            helperText: '',
            prefixIcon: Icon(Icons.phone),
            border: OutlineInputBorder(),
          ),
        );
      },
    );
  }
}

class _PasswordInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterBloc, RegisterState>(
      buildWhen: (previous, current) => previous.password != current.password,
      builder: (context, state) {
        return TextField(
          key: const Key('registerForm_passwordInput_textField'),
          onChanged: (password) =>
              context.read<RegisterBloc>().add(RegisterPasswordChanged(password)),
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Парола',
            helperText: '',
            prefixIcon: Icon(Icons.lock),
            border: OutlineInputBorder(),
          ),
        );
      },
    );
  }
}

class _ConfirmPasswordInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterBloc, RegisterState>(
      buildWhen: (previous, current) =>
          previous.confirmPassword != current.confirmPassword,
      builder: (context, state) {
        return TextField(
          key: const Key('registerForm_confirmPasswordInput_textField'),
          onChanged: (confirmPassword) => context
              .read<RegisterBloc>()
              .add(RegisterConfirmPasswordChanged(confirmPassword)),
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Потвърдете паролата',
            helperText: '',
            prefixIcon: Icon(Icons.lock),
            border: OutlineInputBorder(),
          ),
        );
      },
    );
  }
}

class _RegisterButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterBloc, RegisterState>(
      buildWhen: (previous, current) => previous.status != current.status,
      builder: (context, state) {
        return state.status == RegisterStatus.loading
            ? const Center(child: CircularProgressIndicator())
            : ElevatedButton(
                key: const Key('registerForm_continue_raisedButton'),
                onPressed: () =>
                    context.read<RegisterBloc>().add(const RegisterSubmitted()),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text('Създай акаунт'),
                ),
              );
      },
    );
  }
} 