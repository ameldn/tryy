import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:tryy/pages/jadwal_add_page.dart';
import 'package:tryy/pages/login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  final String title = "Beranda";

  @override
  State<HomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomePage> {
  Future<void> _refresh() async {
    setState(() {});
  }

  void _showEditDialog(String id, Map<String, dynamic> data) {
    final TextEditingController topikController = TextEditingController(
      text: data['topik'],
    );
    final TextEditingController tanggalController = TextEditingController(
      text: data['tanggal'],
    );
    final TextEditingController jamController = TextEditingController(
      text: data['jam'],
    );
    final TextEditingController durasiController = TextEditingController(
      text: data['durasi'],
    );
    final TextEditingController tagController = TextEditingController(
      text: data['tag'],
    );
    final TextEditingController pengingatController = TextEditingController(
      text: data['pengingat'],
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Edit Jadwal'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: topikController,
                    decoration: const InputDecoration(labelText: 'Topik'),
                  ),
                  TextField(
                    controller: tanggalController,
                    decoration: const InputDecoration(labelText: 'Tanggal'),
                  ),
                  TextField(
                    controller: jamController,
                    decoration: const InputDecoration(labelText: 'Jam'),
                  ),
                  TextField(
                    controller: durasiController,
                    decoration: const InputDecoration(labelText: 'Durasi'),
                  ),
                  TextField(
                    controller: tagController,
                    decoration: const InputDecoration(labelText: 'Tag'),
                  ),
                  TextField(
                    controller: pengingatController,
                    decoration: const InputDecoration(labelText: 'Pengingat'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await FirebaseFirestore.instance
                      .collection('jadwal')
                      .doc(id)
                      .update({
                        'topik': topikController.text,
                        'tanggal': tanggalController.text,
                        'jam': jamController.text,
                        'durasi': durasiController.text,
                        'tag': tagController.text,
                        'pengingat': pengingatController.text,
                      });
                  Navigator.pop(context);
                },
                child: const Text('Simpan'),
              ),
            ],
          ),
    );
  }

  void _deleteJadwal(String id, BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Konfirmasi Hapus"),
          content: Text("Apakah Anda yakin ingin menghapus jadwal ini?"),
          actions: <Widget>[
            TextButton(
              child: Text("Batal"),
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
              },
            ),
            TextButton(
              child: Text("Hapus", style: TextStyle(color: Colors.red)),
              onPressed: () async {
                Navigator.of(context).pop(); // Tutup dialog
                await FirebaseFirestore.instance
                    .collection('jadwal')
                    .doc(id)
                    .delete();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Jadwal berhasil dihapus")),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              // Logout dari Firebase
              await FirebaseAuth.instance.signOut();

              // Logout dari Google (jika pakai Google Sign-In)
              await GoogleSignIn().signOut();

              // Navigasi ke halaman login (sesuaikan dengan nama route-mu)
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (context) => LoginPage()));
            },
          ),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: _refresh,
        child: StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance
                  .collection('jadwal')
                  .orderBy('dibuat', descending: true)
                  .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('Terjadi kesalahan'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final docs = snapshot.data!.docs;

            if (docs.isEmpty) {
              return const Center(child: Text('Belum ada jadwal'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final doc = docs[index];
                final data = doc.data() as Map<String, dynamic>;
                final id = doc.id;

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    title: Text(
                      data['topik'] ?? 'Tanpa topik',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    subtitle: Text(
                      'Tanggal: ${data['tanggal']}\n'
                      'Jam: ${data['jam']}, Durasi: ${data['durasi']}\n'
                      'Tag: ${data['tag']} | Pengingat: ${data['pengingat']}',
                    ),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _showEditDialog(id, data),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteJadwal(id, context),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const JadwalAddPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
