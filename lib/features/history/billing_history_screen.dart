import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class BillingHistoryScreen extends StatelessWidget {
  const BillingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

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
          "Billing History",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 20),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Recent Transactions",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: userId == null
                    ? const Center(child: Text("User not logged in"))
                    : StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(userId)
                            .collection('history')
                            .orderBy('createdAt', descending: true)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (snapshot.hasError) {
                            return Center(child: Text("Error: ${snapshot.error}"));
                          }
                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return const Center(child: Text("No transactions found"));
                          }

                          final docs = snapshot.data!.docs;

                          return ListView.builder(
                            itemCount: docs.length,
                            itemBuilder: (context, index) {
                              final item = docs[index].data() as Map<String, dynamic>;
                              final billNo = item['billNo'] ?? "---";
                              final amount = item['amount'] ?? 0;
                              final dateStr = item['date'] ?? "";
                              
                              String formattedDate = "---";
                              if (dateStr.isNotEmpty) {
                                try {
                                  final date = DateTime.parse(dateStr);
                                  formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(date);
                                } catch (e) {
                                  formattedDate = dateStr;
                                }
                              }

                              return Card(
                                margin: const EdgeInsets.only(bottom: 15),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                elevation: 2,
                                child: ListTile(
                                  leading: const CircleAvatar(
                                    backgroundColor: Color(0xFF031B3A),
                                    child: Icon(Icons.receipt, color: Colors.white),
                                  ),
                                  title: Text("Bill $billNo", style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Text("Date: $formattedDate"),
                                  trailing: Text(
                                    "Rs.$amount",
                                    style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  onTap: () {
                                    // Optional: Show bill details
                                  },
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
