import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class JadwalAddPage extends StatefulWidget {
  const JadwalAddPage({super.key});

  @override
  State<JadwalAddPage> createState() => _JadwalAddPageState();
}

class _JadwalAddPageState extends State<JadwalAddPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _tanggalController = TextEditingController();
  final TextEditingController _topikController = TextEditingController();
  final TextEditingController _jamController = TextEditingController();
  final TextEditingController _durasiController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  final TextEditingController _pengingatController = TextEditingController();

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final data = {
        'tanggal': _tanggalController.text,
        'topik': _topikController.text,
        'jam': _jamController.text,
        'durasi': _durasiController.text,
        'tag': _tagController.text,
        'pengingat': _pengingatController.text,
        'dibuat': FieldValue.serverTimestamp(), // Menyimpan waktu pembuatan
      };

      await FirebaseFirestore.instance.collection('jadwal').add(data);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jadwal berhasil disimpan!')),
      );

      Navigator.pop(context); // Kembali ke halaman utama
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Jadwal')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _tanggalController,
                decoration:
                    const InputDecoration(labelText: 'Tanggal (YYYY-MM-DD)'),
                validator: (value) =>
                    value!.isEmpty ? 'Tanggal wajib diisi' : null,
              ),
              TextFormField(
                controller: _topikController,
                decoration: const InputDecoration(labelText: 'Topik'),
                validator: (value) =>
                    value!.isEmpty ? 'Topik wajib diisi' : null,
              ),
              TextFormField(
                controller: _jamController,
                decoration: const InputDecoration(labelText: 'Jam (HH:MM)'),
                validator: (value) =>
                    value!.isEmpty ? 'Jam wajib diisi' : null,
              ),
              TextFormField(
                controller: _durasiController,
                decoration:
                    const InputDecoration(labelText: 'Durasi (contoh: 1 jam)'),
                validator: (value) =>
                    value!.isEmpty ? 'Durasi wajib diisi' : null,
              ),
              TextFormField(
                controller: _tagController,
                decoration: const InputDecoration(labelText: 'Tag'),
                validator: (value) =>
                    value!.isEmpty ? 'Tag wajib diisi' : null,
              ),
              TextFormField(
                controller: _pengingatController,
                decoration: const InputDecoration(
                    labelText: 'Pengingat (contoh: 15 menit sebelum)'),
                validator: (value) =>
                    value!.isEmpty ? 'Pengingat wajib diisi' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Simpan Jadwal'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
