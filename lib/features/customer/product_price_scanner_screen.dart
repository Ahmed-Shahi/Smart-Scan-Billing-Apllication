import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner_plus/flutter_barcode_scanner_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductPriceScannerScreen extends StatefulWidget {
  const ProductPriceScannerScreen({super.key});

  @override
  State<ProductPriceScannerScreen> createState() => _ProductPriceScannerScreenState();
}

class _ProductPriceScannerScreenState extends State<ProductPriceScannerScreen> {
  bool _isScanning = false;
  Map<String, dynamic>? _foundProduct;
  String? _lastScannedBarcode;

  Future<void> _scanProduct(String shopId) async {
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

    if (barcodeScanRes == "-1") {
      setState(() {
        _isScanning = false;
      });
      return;
    }

    _handleBarcode(shopId, barcodeScanRes);
  }

  Future<void> _handleBarcode(String shopId, String barcodeScanRes) async {
    final String barcode = barcodeScanRes.trim();
    setState(() {
      _isScanning = true;
      _foundProduct = null;
      _lastScannedBarcode = barcode;
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(shopId)
          .collection('products')
          .where('id', isEqualTo: barcode)
          .get();

      if (mounted) {
        if (snapshot.docs.isNotEmpty) {
          setState(() {
            _isScanning = false;
            _foundProduct = snapshot.docs.first.data();
          });
        } else {
          setState(() {
            _isScanning = false;
            _foundProduct = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Product ($barcode) not found in this shop.")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error fetching product: $e")),
        );
      }
    }
  }

  void _showManualEntryDialog(BuildContext context, String shopId) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Manual Price Check"),
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
                _handleBarcode(shopId, controller.text);
              }
            },
            child: const Text("Check Price"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};
    final String shopName = args['shopName'] ?? "Shop";
    final String shopId = args['shopId'] ?? "";

    return Scaffold(
      backgroundColor: const Color(0xFF0A3D62),
      body: Column(
        children: [
          // Header Section
          Container(
            padding: const EdgeInsets.only(top: 50, left: 10, right: 10, bottom: 20),
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.5,
                colors: [Color(0xFF4FC3F7), Color(0xFF0A3D62)],
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        shopName,
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(color: Colors.greenAccent, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 5),
                          const Text("Connected Shop", style: TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Scanner Area
          Expanded(
            child: Stack(
              children: [
                // Container(
                //   width: double.infinity,
                //   height: double.infinity,
                  // decoration: const BoxDecoration(
                  //   image: DecorationImage(
                  //     image: NetworkImage("https://images.unsplash.com/photo-1586880244406-556ebe35f282"),
                  //     fit: BoxFit.cover,
                  //   ),
                  // ),
                // ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () => _scanProduct(shopId),
                        child: Container(
                          width: 250,
                          height: 250,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white, width: 2),
                            borderRadius: BorderRadius.circular(30),
                            color: Colors.black26,
                          ),
                          child: Stack(
                            children: [
                              _buildCorner(top: 0, left: 0),
                              _buildCorner(top: 0, right: 0),
                              _buildCorner(bottom: 0, left: 0),
                              _buildCorner(bottom: 0, right: 0),
                              Center(
                                child: Container(
                                  width: 230,
                                  height: 2,
                                  color: _isScanning ? Colors.red : Colors.greenAccent,
                                ),
                              ),
                              if (_isScanning)
                                const Center(child: CircularProgressIndicator(color: Colors.white70)),
                              if (!_isScanning && _foundProduct == null)
                                const Center(
                                  child: Icon(Icons.qr_code_scanner, color: Colors.white, size: 60),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(_isScanning ? Icons.sync : Icons.touch_app, color: Colors.white, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  _isScanning ? "Scanning..." : "Tap Box to Scan",
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                            if (!_isScanning) ...[
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () => _showManualEntryDialog(context, shopId),
                                child: const Text(
                                  "Or Enter Manually",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom Product Details Card
          if (!_isScanning && _foundProduct != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(35),
                  topRight: Radius.circular(35),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                        child: const Icon(Icons.check, color: Colors.white, size: 14),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "Product Found",
                        style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A3D62).withOpacity(0.03),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _foundProduct?["name"] ?? "---",
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0A3D62)),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Product Name",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Rs. ${_foundProduct?["price"] ?? "0"}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: () => _scanProduct(shopId),
                      icon: const Icon(Icons.qr_code_scanner),
                      label: const Text(
                        "Scan Another Product",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF0A3D62),
                        side: const BorderSide(color: Color(0xFF0A3D62)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCorner({double? top, double? bottom, double? left, double? right}) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          border: Border(
            top: top != null ? const BorderSide(color: Colors.white, width: 4) : BorderSide.none,
            bottom: bottom != null ? const BorderSide(color: Colors.white, width: 4) : BorderSide.none,
            left: left != null ? const BorderSide(color: Colors.white, width: 4) : BorderSide.none,
            right: right != null ? const BorderSide(color: Colors.white, width: 4) : BorderSide.none,
          ),
        ),
      ),
    );
  }
}
