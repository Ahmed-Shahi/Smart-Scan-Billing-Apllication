import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ShopSelectionScreen extends StatefulWidget {
  const ShopSelectionScreen({super.key});

  @override
  State<ShopSelectionScreen> createState() => _ShopSelectionScreenState();
}

class _ShopSelectionScreenState extends State<ShopSelectionScreen> {
  String? selectedShopName;
  String? selectedShopId;
  String searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.0,
            colors: [
              Color(0xFF4FC3F7),
              Color(0xFF0A3D62),
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.qr_code_scanner, color: Colors.white, size: 32),
                  SizedBox(width: 10),
                  Text(
                    "SmartScan",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              const Text(
                "Select Your Shop",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                "Choose a shop to see product prices",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 30),
              
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(25),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8F9FB),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Search Shop",
                        style: TextStyle(
                          color: Color(0xFF0A3D62),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) {
                            setState(() {
                              searchQuery = value;
                            });
                          },
                          decoration: const InputDecoration(
                            hintText: "Search for a shop...",
                            prefixIcon: Icon(Icons.search, color: Color(0xFF0A3D62)),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance.collection('users').snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                              return const Center(child: Text("No shops registered yet."));
                            }

                            final allShops = snapshot.data!.docs.where((doc) {
                              final data = doc.data() as Map<String, dynamic>;
                              final name = (data['shopName'] ?? "").toString().toLowerCase();
                              return name.contains(searchQuery.toLowerCase());
                            }).toList();

                            if (allShops.isEmpty) {
                              return const Center(child: Text("No shops match your search."));
                            }

                            return ListView.builder(
                              itemCount: allShops.length,
                              itemBuilder: (context, index) {
                                final shopDoc = allShops[index];
                                final shopData = shopDoc.data() as Map<String, dynamic>;
                                final shopName = shopData['shopName'] ?? "Unnamed Shop";
                                final shopId = shopDoc.id;
                                final isSelected = selectedShopId == shopId;

                                return GestureDetector(
                                  onTap: () => setState(() {
                                    selectedShopName = shopName;
                                    selectedShopId = shopId;
                                  }),
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: isSelected ? const Color(0xFF0A3D62).withOpacity(0.05) : Colors.white,
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(
                                        color: isSelected ? const Color(0xFF0A3D62) : Colors.transparent,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: const Icon(Icons.store, color: Colors.blue, size: 20),
                                        ),
                                        const SizedBox(width: 15),
                                        Text(
                                          shopName,
                                          style: TextStyle(
                                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                            color: Colors.black87,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const Spacer(),
                                        if (isSelected)
                                          const Icon(Icons.check, color: Color(0xFF0A3D62), size: 20),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A3D62).withOpacity(0.05),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.verified_user_outlined, color: Color(0xFF0A3D62), size: 30),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    "Why select shop?",
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                  Text(
                                    "Prices and products may vary from shop to shop.",
                                    style: TextStyle(color: Colors.black54, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: selectedShopId != null ? () {
                            Navigator.pushNamed(
                              context, 
                              '/product-price-scanner', 
                              arguments: {
                                'shopName': selectedShopName,
                                'shopId': selectedShopId,
                              }
                            );
                          } : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0A3D62),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.arrow_forward, size: 20),
                              SizedBox(width: 10),
                              Text("Start Scanning", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
