import 'package:flutter/material.dart';

class WorkshopDetail extends StatelessWidget {
  final String title;
  final String imageUrl;

  const WorkshopDetail({Key? key, required this.title, required this.imageUrl})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Workshop description based on title
    String description = _getDescription(title);
    String price = _getPrice(title);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF999AE6),
        title: const Text(
          'Workshop Detail',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Workshop image
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(imageUrl),
                  fit: BoxFit.cover,
                  onError: (exception, stackTrace) {
                    // Placeholder for error
                  },
                ),
              ),
            ),

            // Workshop details
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today),
                      const SizedBox(width: 8),
                      const Text(
                        'Schedule: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text('Every Saturday, 9:00 AM - 12:00 PM'),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.access_time),
                      const SizedBox(width: 8),
                      const Text(
                        'Duration: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text('30 days'),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.sell),
                      const SizedBox(width: 8),
                      const Text(
                        'Price: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(price),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Instructor section
                  const Text(
                    'Instructor',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ListTile(
                    leading: CircleAvatar(
                      backgroundImage: AssetImage('assets1/instructor.jpg'),
                      onBackgroundImageError: (exception, stackTrace) {
                        // Placeholder for error
                      },
                      child: Icon(Icons.person),
                    ),
                    title: Text(_getInstructor(title)),
                    subtitle:
                        const Text('Senior Developer with 8+ years experience'),
                  ),

                  // What you'll learn section
                  const SizedBox(height: 20),
                  const Text(
                    'What you\'ll learn',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ..._getLearningPoints(title)
                      .map((point) => Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.check,
                                    color: Color(0xFF999AE6)),
                                const SizedBox(width: 8),
                                Expanded(child: Text(point)),
                              ],
                            ),
                          ))
                      .toList(),

                  // Payment button
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF999AE6),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      onPressed: () {
                        _showPaymentDialog(context);
                      },
                      child: const Text(
                        'Pay Now',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Get description based on workshop title
  String _getDescription(String title) {
    switch (title) {
      case 'UI/UX Designer For 30 days':
        return 'Learn UI/UX design from scratch with practical projects and industry best practices. Perfect for beginners wanting to enter the design field.';
      case 'The Complete Web Development Academy':
        return 'Learn full-stack web development with this comprehensive course. Includes hands-on projects and interactive lessons on HTML, CSS, JavaScript, and modern frameworks.';
      case 'Project Development Using JAVA for Beginners':
        return 'Master Java programming with practical project-based learning. Perfect for beginners who want to build real applications while learning.';
      case 'IoT Study Club Academy':
        return 'Join our IoT study club to learn about Internet of Things development, including sensors, microcontrollers, and connected applications.';
      case 'Membuat Karya Tulis Ilmiah dari 0':
        return 'Learn how to write scientific papers from scratch. This workshop covers research methodology, paper structure, citation styles, and academic writing.';
      default:
        return 'A comprehensive workshop designed to help you master new skills and advance your career.';
    }
  }

  // Get price based on workshop title
  String _getPrice(String title) {
    switch (title) {
      case 'UI/UX Designer For 30 days':
        return 'Rp 1.299.000';
      case 'The Complete Web Development Academy':
        return 'Rp 1.499.000';
      case 'Project Development Using JAVA for Beginners':
        return 'Rp 999.000';
      case 'IoT Study Club Academy':
        return 'Rp 1.199.000';
      case 'Membuat Karya Tulis Ilmiah dari 0':
        return 'Rp 799.000';
      default:
        return 'Rp 1.099.000';
    }
  }

  // Get instructor name based on workshop title
  String _getInstructor(String title) {
    switch (title) {
      case 'UI/UX Designer For 30 days':
        return 'Sarah Design';
      case 'The Complete Web Development Academy':
        return 'John Webdev';
      case 'Project Development Using JAVA for Beginners':
        return 'Michael Java';
      case 'IoT Study Club Academy':
        return 'Tony IoT';
      case 'Membuat Karya Tulis Ilmiah dari 0':
        return 'Dr. Anita Researcher';
      default:
        return 'Expert Instructor';
    }
  }

  // Get learning points based on workshop title
  List<String> _getLearningPoints(String title) {
    switch (title) {
      case 'UI/UX Designer For 30 days':
        return [
          'Master the fundamentals of UI/UX design principles',
          'Create user-centered designs using industry-standard tools like Figma',
          'Build a professional portfolio of UI/UX projects',
          'Learn how to conduct user research and usability testing',
          'Understand design systems and component libraries'
        ];
      case 'The Complete Web Development Academy':
        return [
          'Build responsive websites with HTML5, CSS3, and JavaScript',
          'Master front-end frameworks like React or Angular',
          'Develop back-end systems with Node.js or PHP',
          'Work with databases like MySQL and MongoDB',
          'Deploy your applications to production environments'
        ];
      case 'Project Development Using JAVA for Beginners':
        return [
          'Understand Java syntax and object-oriented programming',
          'Build desktop applications with JavaFX',
          'Develop Android applications using Java',
          'Work with databases using JDBC',
          'Apply software design patterns in real projects'
        ];
      case 'IoT Study Club Academy':
        return [
          'Program Arduino and Raspberry Pi devices',
          'Connect sensors and actuators to create IoT systems',
          'Develop IoT applications using various protocols',
          'Implement cloud connectivity for IoT projects',
          'Design and build a complete IoT project from scratch'
        ];
      case 'Membuat Karya Tulis Ilmiah dari 0':
        return [
          'Memahami struktur karya tulis ilmiah',
          'Melakukan penelitian dan pengambilan data',
          'Menulis dengan gaya akademik yang tepat',
          'Membuat kutipan dan daftar pustaka dengan benar',
          'Mempublikasikan karya tulis di jurnal ilmiah'
        ];
      default:
        return [
          'Master fundamental concepts in the field',
          'Complete hands-on projects for practical experience',
          'Learn industry best practices',
          'Develop a portfolio to showcase your skills',
          'Connect with experts and peers in the community'
        ];
    }
  }

  // Show payment dialog
  void _showPaymentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Payment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Workshop: $title'),
              const SizedBox(height: 8),
              Text('Price: ${_getPrice(title)}'),
              const SizedBox(height: 16),
              const Text('Choose payment method:'),
              const SizedBox(height: 8),
              _buildPaymentOption(context, 'Credit Card'),
              _buildPaymentOption(context, 'Bank Transfer'),
              _buildPaymentOption(context, 'E-Wallet'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // Build payment option button
  Widget _buildPaymentOption(BuildContext context, String method) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        // Navigate to payment page with selected method
        // This would be implemented in a real app
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Processing $method payment...')));
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF999AE6)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(method),
      ),
    );
  }
}
