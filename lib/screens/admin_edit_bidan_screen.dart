import 'package:flutter/material.dart';
import '../mock_data.dart';

class AdminEditBidanScreen extends StatefulWidget {
  final bool isEdit;
  final int? index;
  final Map<String, String>? data;

  const AdminEditBidanScreen({
    super.key,
    this.isEdit = false,
    this.index,
    this.data,
  });

  @override
  State<AdminEditBidanScreen> createState() =>
      _AdminEditBidanScreenState();
}

class _AdminEditBidanScreenState
    extends State<AdminEditBidanScreen> {

  final namaC = TextEditingController();
  final nikC = TextEditingController();
  final nipC = TextEditingController();
  final strC = TextEditingController();
  final hpC = TextEditingController();
  final alamatC = TextEditingController();

  @override
  void initState() {
    super.initState();

    /// ===== ISI DATA SAAT EDIT =====
    if (widget.isEdit && widget.data != null) {
      namaC.text = widget.data!["nama"] ?? "";
      nikC.text = widget.data!["nik"] ?? "";
      nipC.text = widget.data!["nip"] ?? "";
      strC.text =
          widget.data!["str"]?.replaceAll("No. STR: ", "") ?? "";
      hpC.text = widget.data!["hp"] ?? "";
      alamatC.text = widget.data!["alamat"] ?? "";
    }
  }

  void simpanData() {
    if (namaC.text.isEmpty || strC.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nama & STR wajib diisi")),
      );
      return;
    }

    final dataBaru = BidanProfile(
      nama: namaC.text,
      nik: nikC.text,
      nip: nipC.text,
      str: "No. STR: ${strC.text}",
      hp: hpC.text,
      alamat: alamatC.text,
    );

    if (widget.isEdit) {
      /// ===== EDIT =====
      MockDatabase.bidanList[widget.index!] = dataBaru;
    } else {
      /// ===== TAMBAH =====
      MockDatabase.bidanList.add(dataBaru);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDDE6CF),

      /// ===== APPBAR =====
      appBar: AppBar(
        backgroundColor: const Color(0xFFDDE6CF),
        elevation: 0,
        title: Text(
          widget.isEdit ? "Edit Data Bidan" : "Tambah Bidan Baru",
          style: const TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      /// ===== BODY =====
      body: Container(
        color: const Color(0xFFE6B8BE),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [

              /// ===== UPLOAD FOTO =====
              Container(
                width: 140,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: const [
                    Icon(Icons.add, size: 40),
                    SizedBox(height: 8),
                    Text(
                      "Upload Foto",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Upload foto formal background merah ukuran 3x4",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 10),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 16),

              /// ===== INPUT FIELD =====
              _input("Nama Lengkap", "Contoh: Siti Aminah, S.Tr.Keb", namaC),
              _input("NIK (KTP)", "16 Digit Nomor Induk Kependudukan", nikC),
              _input("NIP (Pegawai)", "Nomor Induk Pegawai", nipC),
              _input("Nomor STR", "Surat Tanda Registrasi", strC),
              _input("No. HP", "08xx xxxx xxxx", hpC),
              _input("Alamat Lengkap", "Jl. Raya Utama No.12", alamatC),

              const SizedBox(height: 20),

              /// ===== BUTTON =====
              Row(
                children: [

                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Batal"),
                    ),
                  ),

                  Expanded(
                    child: ElevatedButton(
                      onPressed: simpanData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        widget.isEdit
                            ? "Update Data"
                            : "Simpan Data Bidan",
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  /// ===== INPUT WIDGET =====
  Widget _input(String label, String hint, TextEditingController c) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 4),
          TextField(
            controller: c,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: Colors.white,
              prefixIcon: const Icon(Icons.edit, size: 18),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}