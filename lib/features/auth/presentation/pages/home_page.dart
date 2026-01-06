import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'profile_page.dart';
import '../../../adoptante/presentation/pages/adoptante_main_page.dart';
import '../../../refugio/presentation/pages/refugio_main_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = (context.select((AuthBloc bloc) {
      final state = bloc.state;
      return state is AuthAuthenticated ? state.user : null;
    }));

    // Redirigir según el rol
    if (user?.role == 'adoptante') {
      return const AdoptanteMainPage();
    } else if (user?.role == 'refugio') {
      return const RefugioMainPage();
    }

    // Si no tiene rol asignado, mostrar pantalla de selección de rol
    return Scaffold(
      backgroundColor: const Color(0xFF8B5CF6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF7C3AED),
        elevation: 0,
        title: const Text(
          'PetaAdpotApp',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const ProfilePage()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => context.read<AuthBloc>().add(LogoutEvent()),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.pets, size: 100, color: Colors.white),
            const SizedBox(height: 24),
            Text(
              'Bienvenido${user?.name != null ? ', ${user!.name}' : ''}',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            if (user != null)
              Text(
                user.email,
                style: const TextStyle(fontSize: 16, color: Colors.white70),
              ),
            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Por favor selecciona tu tipo de cuenta en la configuración',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
