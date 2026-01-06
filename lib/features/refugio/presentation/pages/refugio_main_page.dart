import 'package:flutter/material.dart';
import 'refugio_home_page.dart';
import 'mis_mascotas_page.dart';
import 'solicitudes_refugio_page.dart';
import '../../../auth/presentation/pages/profile_page.dart';

class RefugioMainPage extends StatefulWidget {
  const RefugioMainPage({Key? key}) : super(key: key);

  @override
  State<RefugioMainPage> createState() => _RefugioMainPageState();
}

class _RefugioMainPageState extends State<RefugioMainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const RefugioHomePage(),
    const MisMascotasPage(),
    const SolicitudesRefugioPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF7C3AED), // Morado
          unselectedItemColor: const Color(0xFF9CA3AF),
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 11,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Inicio',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.pets_rounded),
              label: 'Mascotas',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment_rounded),
              label: 'Solicitudes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}
