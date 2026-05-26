import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  String searchQuery = "";
  final String? storeId = FirebaseAuth.instance.currentUser?.uid;

  /// Fetch products from Firestore in real-time
  Stream<QuerySnapshot> get productsStream {
    if (storeId == null) return const Stream.empty();
    return FirebaseFirestore.instance
        .collection('users')
        .doc(storeId)
        .collection('products')
        .snapshots();
  }

  /// ADD / EDIT PRODUCT FORM
  void showProductForm({Map<String, dynamic>? product}) {
    final idController = TextEditingController(text: product?["id"] ?? "");
    final nameController = TextEditingController(text: product?["name"] ?? "");
    final priceController = TextEditingController(
      text: product?["price"]?.toString() ?? "",
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                product == null ? "Add Product" : "Edit Product",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: idController,
                decoration: const InputDecoration(
                  labelText: "Product ID / Barcode",
                  prefixIcon: Icon(Icons.qr_code),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Product Name",
                  prefixIcon: Icon(Icons.inventory),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Price",
                  prefixIcon: Icon(Icons.currency_rupee),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final id = idController.text.trim();
                  final name = nameController.text.trim();
                  final price = int.tryParse(priceController.text) ?? 0;

                  if (id.isEmpty || name.isEmpty) return;
                  
                  if (storeId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Error: Store ID not found.")),
                    );
                    return;
                  }

                  final collection = FirebaseFirestore.instance
                      .collection('users')
                      .doc(storeId)
                      .collection('products');

                  try {
                    if (product == null) {
                      await collection.add({
                        "id": id,
                        "name": name,
                        "price": price,
                        "createdAt": FieldValue.serverTimestamp(),
                      });
                    } else {
                      await collection.doc(product["docId"]).update({
                        "id": id,
                        "name": name,
                        "price": price,
                        "updatedAt": FieldValue.serverTimestamp(),
                      });
                    }

                    if (mounted) Navigator.pop(context);
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error saving product: $e")),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text("Save Product"),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF031B3A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF031B3A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Inventory",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => showProductForm(),
          ),
        ],
      ),
      body: Column(
        children: [
          /// SEARCH BAR
          Padding(
            padding: const EdgeInsets.all(15),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: "Search Product...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          /// PRODUCT LIST
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(35),
                  topRight: Radius.circular(35),
                ),
              ),
              child: StreamBuilder<QuerySnapshot>(
                stream: productsStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text("Error loading inventory"));
                  }
                  
                  final docs = snapshot.data?.docs ?? [];
                  
                  if (docs.isEmpty) {
                    return const Center(
                      child: Text(
                        "No products found",
                        style: TextStyle(fontSize: 18),
                      ),
                    );
                  }

                  final allProducts = docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return {
                      "docId": doc.id,
                      "id": data["id"]?.toString() ?? "",
                      "name": data["name"]?.toString() ?? "",
                      "price": data["price"] ?? 0,
                    };
                  }).toList();

                  final filteredProducts = allProducts.where((product) {
                    return product["name"].toString().toLowerCase().contains(searchQuery.toLowerCase());
                  }).toList();

                  if (filteredProducts.isEmpty) {
                    return const Center(
                      child: Text(
                        "No matching products",
                        style: TextStyle(fontSize: 18),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 15),
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          children: [
                            /// ICON
                            Container(
                              width: 55,
                              height: 55,
                              decoration: BoxDecoration(
                                color: Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.inventory,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(width: 15),
                            /// DETAILS
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product["name"],
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    "ID: ${product["id"]}",
                                    style: const TextStyle(
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    "Price: Rs.${product["price"]}",
                                    style: const TextStyle(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            /// ACTIONS
                            Row(
                              children: [
                                /// EDIT
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () => showProductForm(
                                    product: product,
                                  ),
                                ),
                                /// DELETE
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () async {
                                    if (storeId != null) {
                                      try {
                                        await FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(storeId)
                                            .collection('products')
                                            .doc(product["docId"])
                                            .delete();
                                      } catch (e) {
                                        if (mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text("Error deleting product: $e")),
                                          );
                                        }
                                      }
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
