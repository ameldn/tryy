import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tryy/pages/jadwal_add_page.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 31, 33, 142)),
      ),
      home: const MyHomePage(title: 'Flutter demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<void> _refresh() async {
    setState(() {});
  }

  void _showEditDialog(String id, Map<String, dynamic> data) {
    final TextEditingController topikController =
        TextEditingController(text: data['topik']);
    final TextEditingController tanggalController =
        TextEditingController(text: data['tanggal']);
    final TextEditingController jamController =
        TextEditingController(text: data['jam']);
    final TextEditingController durasiController =
        TextEditingController(text: data['durasi']);
    final TextEditingController tagController =
        TextEditingController(text: data['tag']);
    final TextEditingController pengingatController =
        TextEditingController(text: data['pengingat']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Jadwal'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: topikController, decoration: const InputDecoration(labelText: 'Topik')),
              TextField(controller: tanggalController, decoration: const InputDecoration(labelText: 'Tanggal')),
              TextField(controller: jamController, decoration: const InputDecoration(labelText: 'Jam')),
              TextField(controller: durasiController, decoration: const InputDecoration(labelText: 'Durasi')),
              TextField(controller: tagController, decoration: const InputDecoration(labelText: 'Tag')),
              TextField(controller: pengingatController, decoration: const InputDecoration(labelText: 'Pengingat')),
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
              await FirebaseFirestore.instance.collection('jadwal').doc(id).update({
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

  void _deleteJadwal(String id) async {
    await FirebaseFirestore.instance.collection('jadwal').doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
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
                    title: Text(data['topik'] ?? 'Tanpa topik',
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
                          onPressed: () => _deleteJadwal(id),
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
