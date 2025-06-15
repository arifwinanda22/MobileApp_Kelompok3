import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FeedbackScreen(),
    );
  }
}

class FeedbackScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF1F2F6),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              color: Color(0xFFBFA7F2),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Image.asset('assets1/gambar-removebg-preview.png',
                      height: 30),
                  SizedBox(width: 12),
                  Text(
                    'SmartComp',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 24),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search for competition or workshop',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none, // hilangkan garis border
                        ),
                        fillColor: Colors.white,
                        filled: true,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 0,
                          horizontal: 12,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 5),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12), //radius sama
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ), //lebar dan tinggi
                    ),
                    child: Text(
                      'Search',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  SizedBox(width: 12),
                  Icon(Icons.shopping_cart),
                  SizedBox(width: 12),
                  Icon(Icons.notifications_none),
                  SizedBox(width: 12),
                  Icon(Icons.account_circle),
                ],
              ),
            ),

            // Expanded scrollable body
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Feedback Form
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Pesan', style: TextStyle(fontSize: 16)),
                              SizedBox(height: 8),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                child: TextField(
                                  maxLines: 6,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.all(12),
                                  ),
                                ),
                              ),
                              SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFFD2AFFF),
                                ),
                                child: Text('Kirim Feedback'),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(width: 32),

                        // Feedback List
                        Expanded(
                          flex: 3,
                          child: Column(
                            children: List.generate(
                              3,
                              (index) => _feedbackCard(),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 24),

                    // Footer
                    Column(
                      children: [
                        SizedBox(height: 8),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 8,
                          children: [
                            _pageButton('Previous'),
                            _pageButton('1'),
                            _pageButton('2'),
                            _pageButton('3'),
                            _pageButton('Next'),
                          ],
                        ),
                        SizedBox(height: 10),
                        Text(
                          '© 2024 SmartComp. All rights reserved.',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),

                    SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _feedbackCard() {
    return Card(
      elevation: 3,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('User', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text(
              '2 jam yang lalu',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Sangat membantu saya dalam menentukan lomba yang sangat cocok dengan saya',
            ),
            SizedBox(height: 8),
            GestureDetector(
              onTap: () {},
              child: Text('Lihat', style: TextStyle(color: Colors.blue)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pageButton(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: OutlinedButton(onPressed: () {}, child: Text(label)),
    );
  }
}
