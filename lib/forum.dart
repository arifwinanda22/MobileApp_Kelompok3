// forum_screen.dart
// -----------------------------------------------------------------------------
// Forum / Feedback UI (dashboard‑style) with two discussion spaces
//   – Workshop Discussions
//   – Competition Discussions
// Users can switch tabs and post messages; a floating “Diskusi Baru” FAB
// scrolls to the composer and focuses it so they can start typing.
// -----------------------------------------------------------------------------
// NOTE: pure‑UI, no network/Firebase integration yet.
// -----------------------------------------------------------------------------
import 'package:flutter/material.dart';

const kPrimary = Color(0xFF999AE6);
const kBg      = Color(0xFFF1F2F6);

class SmartcompApp extends StatelessWidget {
  const SmartcompApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SmartComp Forum',
      theme: ThemeData(
        primaryColor: kPrimary,
        colorScheme: ColorScheme.fromSeed(seedColor: kPrimary),
        fontFamily: 'Montserrat',
      ),
      home: const FeedbackScreen(),
    );
  }
}

// -----------------------------------------------------------------------------
// Main Screen
// -----------------------------------------------------------------------------
class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({Key? key}) : super(key: key);
  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabC;
  final _msgCtrl   = TextEditingController();
  final _msgFocus  = FocusNode();
  final _scrollC   = ScrollController();

  final List<_Feedback> _workshopPosts    = [];
  final List<_Feedback> _competitionPosts = [];

  List<_Feedback> get _activeList =>
      _tabC.index == 0 ? _workshopPosts : _competitionPosts;

  @override
  void initState() {
    super.initState();
    _tabC = TabController(length: 2, vsync: this);
    // seed with dummy data
    for (int i = 0; i < 4; i++) {
      _workshopPosts.add(_Feedback(
          user: 'User W$i',
          message: 'Diskusi workshop ke‑$i sangat bermanfaat!',
          createdAt: DateTime.now().subtract(Duration(hours: i * 3))));
      _competitionPosts.add(_Feedback(
          user: 'User C$i',
          message: 'Bagaimana aturan kompetisi $i?',
          createdAt: DateTime.now().subtract(Duration(hours: i * 4))));
    }
  }

  @override
  void dispose() {
    _tabC.dispose();
    _msgCtrl.dispose();
    _msgFocus.dispose();
    _scrollC.dispose();
    super.dispose();
  }

  // ───────────────────────── build ─────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: _buildAppBar(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _scrollToComposer,
        backgroundColor: kPrimary,
        icon: const Icon(Icons.add_comment),
        label: const Text('Diskusi Baru'),
      ),
      body: SafeArea(
        child: Column(children: [
          Expanded(child: _buildBody()),
          _buildComposer(),
          _buildFooter(),
        ]),
      ),
    );
  }

  // ───────────────────────── AppBar ─────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: kPrimary,
      automaticallyImplyLeading: false,
      title: Row(children: [
        Image.asset('assets1/gambar-removebg-preview.png', height: 32),
        const SizedBox(width: 8),
        const Text('SmartComp'),
      ]),
      actions: [
        IconButton(icon: const Icon(Icons.shopping_cart), onPressed: () {}),
        IconButton(icon: const Icon(Icons.notifications_none), onPressed: () {}),
        IconButton(icon: const Icon(Icons.account_circle), onPressed: () {}),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(children: [
              Expanded(child: _buildSearchField()),
              const SizedBox(width: 6),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                child:
                    const Text('Search', style: TextStyle(color: Colors.black)),
              ),
            ]),
          ),
          TabBar(
            controller: _tabC,
            indicatorColor: Colors.white,
            tabs: const [
              Tab(text: 'Workshops'),
              Tab(text: 'Competitions'),
            ],
          ),
        ]),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search discussions…',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      ),
    );
  }

  // ───────────────────────── Body (lists) ─────────────────────────
  Widget _buildBody() {
    return TabBarView(
      controller: _tabC,
      children: [
        _postList(_workshopPosts),
        _postList(_competitionPosts),
      ],
    );
  }

  Widget _postList(List<_Feedback> list) {
    return Scrollbar(
      controller: _scrollC,
      thumbVisibility: true,
      child: ListView.builder(
        controller: _scrollC,
        padding: const EdgeInsets.all(24),
        itemCount: list.length,
        itemBuilder: (_, i) => _feedbackCard(list[i]),
      ),
    );
  }

  // ───────────────────────── Composer ─────────────────────────
  Widget _buildComposer() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      color: Colors.white,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
        const Text('Tulis Pesan', style: TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: TextField(
            controller: _msgCtrl,
            focusNode: _msgFocus,
            maxLines: 4,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(12),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: kPrimary),
            onPressed: _handleSend,
            child: const Text('Kirim'),
          ),
        ),
      ]),
    );
  }

  void _handleSend() {
    final txt = _msgCtrl.text.trim();
    if (txt.isEmpty) return;
    setState(() {
      _activeList.insert(0, _Feedback(user: 'You', message: txt, createdAt: DateTime.now()));
      _msgCtrl.clear();
    });
    // scroll to top of list to show new post
    _scrollC.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  void _scrollToComposer() {
    // make sure composer is visible and focus text field
    _scrollC.animateTo(_scrollC.position.maxScrollExtent + 250,
        duration: const Duration(milliseconds: 400), curve: Curves.easeOut);
    FocusScope.of(context).requestFocus(_msgFocus);
  }

  // ───────────────────────── Footer ─────────────────────────
  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(children:[
        Wrap(spacing: 6, alignment: WrapAlignment.center, children: const [
          _PageBtn('Previous'), _PageBtn('1'), _PageBtn('2'), _PageBtn('Next'),
        ]),
        const SizedBox(height: 8),
        const Text('© 2025 SmartComp. All rights reserved.',
            style: TextStyle(fontSize: 12, color: Colors.grey)),
      ]),
    );
  }

  // ───────────────────────── Card & Helpers ─────────────────────────
  Widget _feedbackCard(_Feedback fb) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
          Text(fb.user, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(_timeAgo(fb.createdAt),
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 8),
          Text(fb.message),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {},
            child: const Text('Lihat', style: TextStyle(color: Colors.blue)),
          ),
        ]),
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit yang lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam yang lalu';
    return '${diff.inDays} hari yang lalu';
  }
}

// -----------------------------------------------------------------------------
// Helper model & widgets
// -----------------------------------------------------------------------------
class _Feedback {
  final String user;
  final String message;
  final DateTime createdAt;
  _Feedback({required this.user, required this.message, required this.createdAt});
}

class _PageBtn extends StatelessWidget {
  final String lbl;
  const _PageBtn(this.lbl, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return OutlinedButton(onPressed: () {}, child: Text(lbl));
  }
}
