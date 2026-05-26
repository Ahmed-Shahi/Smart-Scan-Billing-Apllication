import 'package:flutter/material.dart';
import 'settings_popup.dart';
import '../../services/firestore_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  String _shopName = "Loading...";

  @override
  void initState() {
    super.initState();
    _loadShopName();
  }

  Future<void> _loadShopName() async {
    final shopName = await FirestoreService.getShopName();
    if (mounted) {
      setState(() {
        _shopName = shopName ?? "My Shop";
      });
    }
  }

  void _onItemTapped(int index) {
    if (index == 3) {
      // Settings index
      showSettingsPopup(context);
    } else {
      setState(() {
        _selectedIndex = index;
      });
      // Handle other navigation if needed, e.g., index 1 -> /inventory
      if (index == 1) Navigator.pushNamed(context, '/inventory');
      if (index == 2) Navigator.pushNamed(context, '/history');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF031B3A),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF06254B),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white60,
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: "Inventory",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: "History",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings",
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// TOP BAR
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Icon(
                    Icons.menu,
                    color: Colors.white,
                    size: 30,
                  ),
                  Icon(
                    Icons.notifications_none,
                    color: Colors.white,
                    size: 30,
                  ),
                ],
              ),
              const SizedBox(height: 30),

              /// WELCOME TEXT
              const Text(
                "Welcome,",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                _shopName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                "SmartScan Store",
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 40),

              /// GRID BUTTONS
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 18,
                  mainAxisSpacing: 18,
                  children: [
                    DashboardCard(
                      title: "Scan Product",
                      subtitle: "Start Scanning",
                      icon: Icons.qr_code_scanner,
                      color: const Color(0xFF4A90E2), // Vibrant Blue
                      onTap: () {
                        Navigator.pushNamed(context, '/scan');
                      },
                    ),
                    DashboardCard(
                      title: "Generate Bill",
                      subtitle: "Create Invoice",
                      icon: Icons.receipt_long,
                      color: const Color(0xFF26A69A), // Vibrant Teal
                      onTap: () {
                        Navigator.pushNamed(context, '/generate-bill');
                      },
                    ),
                    DashboardCard(
                      title: "Inventory",
                      subtitle: "Manage Products",
                      icon: Icons.inventory_2,
                      color: const Color(0xFF7E57C2), // Vibrant Purple
                      onTap: () {
                        Navigator.pushNamed(context, '/inventory');
                      },
                    ),
                    DashboardCard(
                      title: "Billing History",
                      subtitle: "View Bills",
                      icon: Icons.history,
                      color: const Color(0xFFFFA726), // Vibrant Orange
                      onTap: () {
                        Navigator.pushNamed(context, '/history');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const DashboardCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 55,
                color: Colors.white,
              ),
              const SizedBox(height: 18),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
