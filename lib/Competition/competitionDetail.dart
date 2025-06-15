import 'package:flutter/material.dart';

class CompetitionDetail extends StatelessWidget {
  final String title;
  final String imageUrl;

  const CompetitionDetail(
      {Key? key, required this.title, required this.imageUrl})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Competition description based on title
    String description = _getDescription(title);
    String price = _getPrice(title);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF999AE6),
        title: const Text(
          'Competition Detail',
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
            // Competition image
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

            // Competition details
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

                  // Competition details section
                  _buildDetailsSection(),

                  // Timeline section
                  const SizedBox(height: 20),
                  const Text(
                    'Timeline',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildTimelineSection(),

                  // Prizes section
                  const SizedBox(height: 20),
                  const Text(
                    'Prizes',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildPrizesSection(title),

                  // Requirements section
                  const SizedBox(height: 20),
                  const Text(
                    'Requirements',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ..._getRequirements(title)
                      .map((req) => Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.check_circle,
                                    color: Color(0xFF999AE6)),
                                const SizedBox(width: 8),
                                Expanded(child: Text(req)),
                              ],
                            ),
                          ))
                      .toList(),

                  // Registration button
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
                        _showRegistrationDialog(context, price);
                      },
                      child: const Text(
                        'Register Now',
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

  Widget _buildDetailsSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildDetailRow(
                Icons.calendar_today, 'Registration Deadline', '15 May 2025'),
            const Divider(),
            _buildDetailRow(Icons.location_on, 'Location', 'Online / Virtual'),
            const Divider(),
            _buildDetailRow(Icons.people, 'Team Size', '1-3 members'),
            const Divider(),
            _buildDetailRow(Icons.school, 'Eligibility', 'University Students'),
            const Divider(),
            _buildDetailRow(
                Icons.attach_money, 'Registration Fee', _getPrice(title)),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF999AE6)),
          const SizedBox(width: 10),
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildTimelineSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTimelineItem('Registration Opens', '1 May 2025'),
            _buildTimelineItem('Registration Closes', '15 May 2025'),
            _buildTimelineItem('Technical Meeting', '18 May 2025'),
            _buildTimelineItem('Competition Day', '20-21 May 2025'),
            _buildTimelineItem('Announcement of Winners', '25 May 2025'),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(String event, String date) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 15,
            height: 15,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF999AE6),
            ),
            margin: const EdgeInsets.only(top: 3),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(date),
                if (event != 'Announcement of Winners')
                  Container(
                    height: 20,
                    width: 1,
                    color: Colors.grey[300],
                    margin: const EdgeInsets.only(left: 7),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrizesSection(String title) {
    final prizes = _getPrizes(title);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildPrizeItem('1st Place', prizes[0], Icons.looks_one),
        _buildPrizeItem('2nd Place', prizes[1], Icons.looks_two),
        _buildPrizeItem('3rd Place', prizes[2], Icons.looks_3),
      ],
    );
  }

  Widget _buildPrizeItem(String place, String amount, IconData icon) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        width: 90,
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF999AE6), size: 30),
            const SizedBox(height: 8),
            Text(
              place,
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              amount,
              style: const TextStyle(color: Colors.green),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Get description based on competition title
  String _getDescription(String title) {
    switch (title) {
      case 'Conquer the Math Olympiad':
        return 'Challenge yourself in this prestigious mathematics competition designed to test your problem-solving skills and analytical thinking. Compete against the brightest minds and showcase your mathematical ability.';
      case 'Scientific Writing Challenge: KTI Mastery':
        return 'Develop your research and academic writing skills in this scientific paper competition. Present innovative ideas and solutions to real-world problems through well-structured scientific papers.';
      case 'Code Clash: Competitive Programming Battle':
        return 'Test your coding skills against other programmers in this fast-paced algorithmic competition. Solve complex problems efficiently and compete for the title of top programmer.';
      case 'Crack the Case: Business Strategy Competition':
        return 'Analyze real business cases and develop strategic solutions in this business competition. Showcase your analytical thinking, problem-solving abilities, and presentation skills.';
      case 'Essay Contest: Express Your Ideas':
        return 'Express your thoughts and perspectives on contemporary issues through compelling essays. This competition rewards clarity of thought, persuasive writing, and originality.';
      case 'English Speech Mastery Contest':
        return 'Demonstrate your public speaking and English language proficiency in this speech competition. Captivate the audience with your eloquence, persuasive arguments, and confident delivery.';
      case 'Hackathon: Innovate & Solve in 24 Hours':
        return 'Put your technical skills and creativity to the test in this 24-hour coding marathon. Develop innovative solutions to challenging problems within a limited timeframe.';
      case 'Academic Debate Championship':
        return 'Showcase your critical thinking, research abilities, and persuasive speaking skills in this academic debate competition. Engage in structured arguments on various topics while demonstrating logical reasoning.';
      default:
        return 'A prestigious competition designed to challenge participants and showcase their skills in this academic field. Join us to demonstrate your expertise and compete with peers.';
    }
  }

  // Get price based on competition title
  String _getPrice(String title) {
    switch (title) {
      case 'Conquer the Math Olympiad':
        return 'Rp 150.000';
      case 'Scientific Writing Challenge: KTI Mastery':
        return 'Rp 200.000';
      case 'Code Clash: Competitive Programming Battle':
        return 'Rp 175.000';
      case 'Crack the Case: Business Strategy Competition':
        return 'Rp 250.000';
      case 'Essay Contest: Express Your Ideas':
        return 'Rp 100.000';
      case 'English Speech Mastery Contest':
        return 'Rp 125.000';
      case 'Hackathon: Innovate & Solve in 24 Hours':
        return 'Rp 300.000';
      case 'Academic Debate Championship':
        return 'Rp 225.000';
      default:
        return 'Rp 175.000';
    }
  }

  // Get prizes based on competition title
  List<String> _getPrizes(String title) {
    switch (title) {
      case 'Conquer the Math Olympiad':
        return ['Rp 3.000.000', 'Rp 2.000.000', 'Rp 1.000.000'];
      case 'Scientific Writing Challenge: KTI Mastery':
        return ['Rp 5.000.000', 'Rp 3.000.000', 'Rp 2.000.000'];
      case 'Code Clash: Competitive Programming Battle':
        return ['Rp 4.000.000', 'Rp 2.500.000', 'Rp 1.500.000'];
      case 'Crack the Case: Business Strategy Competition':
        return ['Rp 5.000.000', 'Rp 3.500.000', 'Rp 2.000.000'];
      case 'Essay Contest: Express Your Ideas':
        return ['Rp 2.000.000', 'Rp 1.500.000', 'Rp 1.000.000'];
      case 'English Speech Mastery Contest':
        return ['Rp 2.500.000', 'Rp 1.500.000', 'Rp 1.000.000'];
      case 'Hackathon: Innovate & Solve in 24 Hours':
        return ['Rp 7.500.000', 'Rp 5.000.000', 'Rp 2.500.000'];
      case 'Academic Debate Championship':
        return ['Rp 4.000.000', 'Rp 2.500.000', 'Rp 1.500.000'];
      default:
        return ['Rp 3.000.000', 'Rp 2.000.000', 'Rp 1.000.000'];
    }
  }

  // Get requirements based on competition title
  List<String> _getRequirements(String title) {
    switch (title) {
      case 'Conquer the Math Olympiad':
        return [
          'Active university student (ID card required)',
          'Strong foundation in calculus, algebra, and number theory',
          'Individual participation only',
          'No calculator allowed during competition',
          'Complete registration form and payment before deadline'
        ];
      case 'Scientific Writing Challenge: KTI Mastery':
        return [
          'Teams of 1-3 students from the same university',
          'Original unpublished research paper',
          'Follow the provided template and formatting guidelines',
          'Topic must be related to this year\'s theme: "Innovation for Sustainable Development"',
          'Submit abstract before deadline, full paper after selection'
        ];
      case 'Code Clash: Competitive Programming Battle':
        return [
          'Individual or team participation (max 2 members)',
          'Proficiency in at least one programming language (C++, Java, Python)',
          'Ability to solve algorithmic problems within time constraints',
          'Valid student ID card',
          'Internet connection for online competition platform'
        ];
      case 'Crack the Case: Business Strategy Competition':
        return [
          'Teams of 3-4 students',
          'At least one team member must be from business/economics background',
          'Preliminary round: Written case analysis submission',
          'Final round: Live presentation to panel of judges',
          'Business professional attire for final round'
        ];
      default:
        return [
          'Active university student status',
          'Complete registration before deadline',
          'Follow all competition guidelines and rules',
          'Submit required documents',
          'Pay registration fee'
        ];
    }
  }

  // Show registration dialog
  void _showRegistrationDialog(BuildContext context, String price) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Register for Competition'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Competition: $title'),
              const SizedBox(height: 8),
              Text('Registration Fee: $price'),
              const SizedBox(height: 16),
              const Text('Team Information:'),
              const SizedBox(height: 8),
              TextField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Team Name',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Team Leader Email',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Institution/University',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF999AE6),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context);
                _showPaymentOptions(context, price);
              },
              child: const Text('Continue to Payment'),
            ),
          ],
        );
      },
    );
  }

  // Show payment options
  void _showPaymentOptions(BuildContext context, String price) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Payment Method'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Registration Fee: $price'),
              const SizedBox(height: 16),
              const Text('Choose payment method:'),
              const SizedBox(height: 8),
              _buildPaymentOption(context, 'Bank Transfer'),
              _buildPaymentOption(context, 'Credit/Debit Card'),
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
        // Process payment
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
