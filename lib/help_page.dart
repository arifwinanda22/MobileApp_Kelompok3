import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final faqList = [
      {
        'title': 'Cara Reschedule Jadwal',
        'body':
            'Ingin mengubah jadwal keikutsertaan Anda pada acara atau workshop di SmartComp? Kami memahami bahwa kadang-kadang rencana bisa berubah, dan itulah mengapa kami menyediakan opsi untuk mereschedule. Di topik ini, Anda akan menemukan panduan langkah demi langkah tentang cara memeriksa jadwal yang tersedia dan melakukan perubahan pada waktu yang paling sesuai untuk Anda. Anda juga akan mendapatkan informasi tentang ketentuan reschedule, termasuk apakah ada biaya tambahan yang perlu diperhatikan.',
      },
      {
        'title': 'Cara Membatalkan dan Refund Pesanan',
        'body':
            'Jika Anda perlu membatalkan keikutsertaan pada suatu acara atau workshop, kami menyediakan opsi pembatalan beserta kebijakan pengembalian dana. Topik ini mencakup panduan tentang cara membatalkan pesanan dengan benar dan langkah-langkah untuk mengajukan refund. Anda juga akan mendapatkan informasi mengenai durasi proses pengembalian dana dan syarat-syarat yang perlu dipenuhi, seperti tenggat waktu pembatalan dan ketentuan pengembalian sesuai dengan jenis acara atau layanan yang telah dipesan.',
      },
      {
        'title': 'Cara Koreksi Nama atau Peserta',
        'body':
            'Terkadang, kesalahan dalam penulisan nama bisa terjadi saat mendaftar untuk acara atau workshop. Jangan khawatir, di SmartComp kami menyediakan fitur koreksi nama agar Anda dapat memperbarui informasi dengan mudah. Panduan ini mencakup langkah-langkah untuk mengubah data nama dan informasi lainnya yang mungkin salah input. Anda akan diberi tahu juga tentang batas waktu koreksi data serta dokumen pendukung yang diperlukan untuk mempercepat proses verifikasi.',
      },
      {
        'title': 'Cara Mengatur Notifikasi',
        'body':
            'SmartComp memberikan notifikasi untuk mengingatkan Anda tentang acara yang akan datang, perubahan jadwal, atau informasi penting lainnya. Di panduan ini, Anda akan menemukan cara mengatur preferensi notifikasi sesuai kebutuhan Anda. Apakah Anda ingin menerima semua notifikasi, atau hanya yang berkaitan dengan event yang Anda ikuti? Panduan ini membantu Anda menyesuaikan notifikasi agar Anda tidak ketinggalan informasi penting tanpa merasa terganggu.',
      },
      {
        'title': 'Panduan Penggunaan Forum Diskusi',
        'body':
            'Forum Diskusi di SmartComp adalah tempat yang tepat untuk berbagi ide, bertanya, dan berdiskusi dengan anggota komunitas lainnya. Panduan ini akan membantu Anda memahami cara membuat topik baru, membalas diskusi, dan menggunakan fitur like atau upvote untuk mendukung komentar yang Anda anggap bermanfaat. Anda juga bisa belajar tentang etika penggunaan forum dan bagaimana menjaga komunikasi yang positif dengan sesama pengguna.',
      },
      {
        'title': 'Kebijakan Refund SmartComp',
        'body':
            'Kebijakan refund kami dirancang untuk memberikan transparansi dan kepastian bagi pengguna. Di topik ini, Anda akan mendapatkan penjelasan lengkap mengenai prosedur pengembalian dana untuk berbagai layanan yang ditawarkan, jenis-jenis refund yang tersedia, dan estimasi waktu pencairan dana. Selain itu, kami menjelaskan juga metode pembayaran yang digunakan untuk refund, serta cara memantau status pengembalian dana Anda melalui aplikasi. Panduan ini memastikan Anda mendapatkan pemahaman penuh tentang hak dan kewajiban Anda terkait kebijakan refund.',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF999AE6),
        title: Row(
          children: [
            Image.asset(
              'assets1/gambar-removebg-preview.png',
              width: 40,
              height: 40,
            ),
            const SizedBox(width: 8),
            const Text(
              'SmartComp',
              style: TextStyle(
                color: Colors.black,
                fontFamily: 'Montaga',
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Color(0xffbfa7f2)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'SmartComp Menu',
                    style: TextStyle(fontSize: 22, color: Colors.white),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'SmartComp Navigation',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text("Home"),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/home');
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text("About"),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/about');
              },
            ),
            ListTile(
              leading: const Icon(Icons.help),
              title: const Text("Help"),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text("Login"),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                Text(
                  'Pusat Bantuan SmartComp',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),
                Text(
                  'Selamat datang di Pusat Bantuan SmartComp! Di sini, kami siap membantu Anda untuk mendapatkan jawaban dan solusi atas pertanyaan atau kendala yang mungkin Anda alami saat menggunakan aplikasi SmartComp.',
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),
                Text(
                  'SmartComp adalah aplikasi untuk membantu Anda mengakses berbagai layanan dan informasi terkait event, workshop, kompetisi, akademik, dan forum diskusi di dunia IT. Kami bertujuan untuk menyediakan platform yang nyaman dan mudah digunakan untuk meningkatkan pengalaman Anda dalam belajar dan berkolaborasi di dunia teknologi.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const TextField(
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Ketuk untuk mencari',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Topik Populer',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...faqList.map((faq) {
            return ExpansionTile(
              title: Text(faq['title']!),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(faq['body']!),
                ),
              ],
            );
          }).toList(),
          const SizedBox(height: 20),
          Center(
            child: Column(
              children: [
                const Text('Tidak menemukan jawaban Anda?'),
                TextButton(
                  onPressed: () {
                    // Arahkan ke halaman kontak atau email
                  },
                  child: const Text('Hubungi Kami'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF9C6EFF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Text(
                '© 2024 SmartComp. All rights reserved.',
                style: TextStyle(fontSize: 12, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
