import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        String userEmail = 'Unknown';
        if (state is AuthAuthenticated) {
          userEmail = state.user.email ?? 'Unknown';
        }
        
        return Scaffold(
          appBar: AppBar(
            title: const Text('sellco project tracking'),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Sign out',
                onPressed: () {
                  context.read<AuthBloc>().add(AuthSignOutRequested());
                },
              ),
            ],
          ),
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_outline, size: 80, color: Colors.green),
                const SizedBox(height: 16),
                Text(
                  'Signed in as: $userEmail',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                const Text('This is a placeholder home screen.'),
              ],
            ),
          ),
        );
      },
    );
  }
}


