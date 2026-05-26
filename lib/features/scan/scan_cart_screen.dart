import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner_plus/flutter_barcode_scanner_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ScanCartScreen extends StatefulWidget {
  const ScanCartScreen({super.key});

  @override
  State<ScanCartScreen> createState() => _ScanCartScreenState();
}

class _ScanCartScreenState extends State<ScanCartScreen> {
  List<Map<String, dynamic>> cartItems = [];

  int get total {
    int sum = 0;
    for (var item in cartItems) {
      sum += (item["qty"] as int) * (item["price"] as int);
    }
    return sum;
  }

  Future<void> _scanProduct() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        "#ff6666",
        "Cancel",
        true,
        ScanMode.BARCODE,
      );
    } catch (e) {
      barcodeScanRes = 'Failed to get platform version.';
    }

    if (!mounted) return;

    // -1 means user cancelled the scan
    if (barcodeScanRes == "-1") return;

    _handleBarcode(barcodeScanRes);
  }

  Future<void> _handleBarcode(String barcodeScanRes) async {
    final String barcode = barcodeScanRes.trim();

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not logged in")),
      );
      return;
    }

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('products')
          .where('id', isEqualTo: barcode)
          .get();

      if (mounted) Navigator.pop(context); // Remove loading indicator

      if (snapshot.docs.isNotEmpty) {
        final productData = snapshot.docs.first.data();
        final name = productData['name'] ?? "Unknown";
        final price = (productData['price'] is int) 
            ? productData['price'] 
            : int.tryParse(productData['price'].toString()) ?? 0;

        setState(() {
          // Check if item already exists in cart
          int index = cartItems.indexWhere((item) => item['barcode'] == barcode);
          if (index != -1) {
            // Increment existing item quantity
            cartItems[index]['qty'] = (cartItems[index]['qty'] as int) + 1;
          } else {
            // Add new item
            cartItems.add({
              'barcode': barcode,
              'name': name,
              'price': price,
              'qty': 1,
            });
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Product ($barcode) not found in inventory!")),
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching product: $e")),
      );
    }
  }

  void _showManualEntryDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Manual Product Entry"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: "Enter Barcode / Product ID",
            hintText: "e.g. 12345678",
          ),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                Navigator.pop(context);
                _handleBarcode(controller.text);
              }
            },
            child: const Text("Add Product"),
          ),
        ],
      ),
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
          "Scan Product",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(
              Icons.flash_on,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          /// CAMERA SECTION (TAP TO SCAN)
          GestureDetector(
            onTap: _scanProduct,
            child: Container(
              margin: const EdgeInsets.all(15),
              height: 260,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                // image: const DecorationImage(
                //   image: NetworkImage(
                //     "https://images.unsplash.com/photo-1586880244406-556ebe35f282",
                //   ),
                //   fit: BoxFit.cover,
                // ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Container(
                      width: 260,
                      height: 160,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.greenAccent,
                          width: 4,
                        ),
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                  const Center(
                    child: Icon(
                      Icons.qr_code_scanner,
                      color: Colors.white,
                      size: 55,
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              "Tap to Scan Barcode",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextButton.icon(
                            onPressed: () => _showManualEntryDialog(context),
                            icon: const Icon(Icons.keyboard, color: Colors.white70, size: 20),
                            label: const Text(
                              "Enter Manually",
                              style: TextStyle(color: Colors.white70),
                            ),
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.white10,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),

          /// CART SECTION
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(35),
                  topRight: Radius.circular(35),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    /// TOP ROW
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Scanned Items",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              cartItems.clear();
                            });
                          },
                          child: const Text(
                            "Clear All",
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    /// PRODUCT LIST
                    Expanded(
                      child: cartItems.isEmpty
                          ? const Center(
                              child: Text(
                                "No items scanned yet",
                                style: TextStyle(color: Colors.grey, fontSize: 16),
                              ),
                            )
                          : ListView.builder(
                              itemCount: cartItems.length,
                              itemBuilder: (context, index) {
                                final item = cartItems[index];

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 15),
                                  padding: const EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Row(
                                    children: [
                                      /// PRODUCT IMAGE
                                      Container(
                                        width: 55,
                                        height: 55,
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade100,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Icon(
                                          Icons.shopping_bag,
                                          color: Colors.blue,
                                        ),
                                      ),

                                      const SizedBox(width: 15),

                                      /// PRODUCT DETAILS
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item["name"],
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                              "Qty: ${item["qty"]}",
                                              style: const TextStyle(
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      /// PRICE
                                      Text(
                                        "Rs.${item["price"] * item["qty"]}",
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),

                    /// TOTAL SECTION
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "TOTAL",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Rs.$total",
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// BUTTONS
                    Row(
                      children: [
                        /// CLEAR CART
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                cartItems.clear();
                              });
                            },
                            icon: const Icon(Icons.delete),
                            label: const Text(
                              "Clear Cart",
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF031B3A),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 15),

                        /// GENERATE BILL
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              if (cartItems.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Cart is empty!")),
                                );
                                return;
                              }
                              Navigator.pushNamed(context, '/generate-bill', arguments: cartItems);
                            },
                            icon: const Icon(Icons.receipt_long),
                            label: const Text(
                              "Generate Bill",
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF031B3A),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
