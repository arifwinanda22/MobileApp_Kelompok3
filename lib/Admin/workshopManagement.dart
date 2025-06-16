// Admin/workshopManagement.dart
// UI‑only implementation (no Firebase integration yet)
// -----------------------------------------------------------------------------
//  • Workshop data model
//  • WorkshopManagement screen (similar look‑and‑feel to CompetitionManagement)
//  • Add / Edit dialogs with basic validation
//  • Search + filter + mock statistics
// -----------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// -----------------------------------------------------------------------------
// Workshop model – can later be moved to its own file under /models
// -----------------------------------------------------------------------------
class Workshop {
  final String id;
  String title;
  String description;
  String category; // akademik | non‑akademik
  double price; // registration fee or price
  String imageUrl;
  DateTime scheduleDate; // date of the workshop (could be multi‑day)
  String status; // active | inactive | draft
  int participants;
  DateTime createdAt;

  Workshop({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.imageUrl,
    required this.scheduleDate,
    required this.status,
    required this.participants,
    required this.createdAt,
  });
}

// -----------------------------------------------------------------------------
// WorkshopManagement Screen (Admin only)
// -----------------------------------------------------------------------------
class WorkshopManagement extends StatefulWidget {
  const WorkshopManagement({Key? key}) : super(key: key);

  @override
  State<WorkshopManagement> createState() => _WorkshopManagementState();
}

class _WorkshopManagementState extends State<WorkshopManagement> {
  // Mock workshop list – replace with real data layer later
  List<Workshop> _workshops = [];
  bool _isLoading = true;

  // Statistics
  int get _totalWorkshops => _workshops.length;
  int get _activeWorkshops =>
      _workshops.where((w) => w.status == 'active').length;
  int get _inactiveWorkshops =>
      _workshops.where((w) => w.status == 'inactive').length;
  int get _draftWorkshops =>
      _workshops.where((w) => w.status == 'draft').length;

  // Filters
  String _searchQuery = '';
  String _filterStatus = 'all'; // all, active, inactive, draft
  String _filterCategory = 'all'; // all, akademik, non‑akademik

  @override
  void initState() {
    super.initState();
    _loadMockData();
  }

  // ---------------------------------------------------------------------------
  // MOCK DATA LOADER – simulate fetch delay
  // ---------------------------------------------------------------------------
  Future<void> _loadMockData() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    _workshops = [
      Workshop(
        id: 'w1',
        title: 'UI/UX Designer For 30 Days',
        description: 'Intensive bootcamp covering UX research to prototyping.',
        category: 'non‑akademik',
        price: 250000,
        imageUrl: 'assets1/UI_UX-Designer-img.jpg',
        scheduleDate: DateTime.now().add(const Duration(days: 10)),
        status: 'active',
        participants: 42,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Workshop(
        id: 'w2',
        title: 'Project Development Using JAVA for Beginners',
        description: 'Learn Java fundamentals while building mini‑projects.',
        category: 'akademik',
        price: 150000,
        imageUrl: 'assets1/Java-Course.jpg',
        scheduleDate: DateTime.now().add(const Duration(days: 25)),
        status: 'draft',
        participants: 0,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];
    setState(() => _isLoading = false);
  }

  // ---------------------------------------------------------------------------
  // FILTER helpers
  // ---------------------------------------------------------------------------
  List<Workshop> get _filteredWorkshops {
    return _workshops.where((wk) {
      // search
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        if (!wk.title.toLowerCase().contains(q) &&
            !wk.category.toLowerCase().contains(q)) {
          return false;
        }
      }
      // status
      if (_filterStatus != 'all' && wk.status != _filterStatus) return false;
      // category
      if (_filterCategory != 'all' && wk.category != _filterCategory) {
        return false;
      }
      return true;
    }).toList();
  }

  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(children: const [
          Icon(Icons.school),
          SizedBox(width: 8),
          Text('Workshop Management'),
        ]),
        backgroundColor: const Color(0xFF999AE6),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMockData,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsSection(),
                  const SizedBox(height: 16),
                  _buildSearchAndFilter(),
                  const SizedBox(height: 16),
                  _buildWorkshopList(),
                ],
              ),
            ),
    );
  }

  // ---------------------------------------------------------------------------
  // UI WIDGETS
  // ---------------------------------------------------------------------------
  Widget _buildStatsSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Workshop Statistics',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStatCard('Total', _totalWorkshops, Colors.blue, Icons.list),
              const SizedBox(width: 12),
              _buildStatCard(
                  'Active', _activeWorkshops, Colors.green, Icons.play_circle),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStatCard('Inactive', _inactiveWorkshops, Colors.orange,
                  Icons.pause_circle),
              const SizedBox(width: 12),
              _buildStatCard('Draft', _draftWorkshops, Colors.grey, Icons.drafts),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, int value, Color color, IconData iconData) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(iconData, color: color),
            const SizedBox(height: 8),
            Text('$value',
                style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(title,
                style: TextStyle(fontSize: 12, color: Colors.grey[700])),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(children: [
        TextField(
          onChanged: (v) => setState(() => _searchQuery = v),
          decoration: InputDecoration(
            hintText: 'Search workshops…',
            prefixIcon: const Icon(Icons.search),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _filterStatus,
              decoration: InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              items: const [
                DropdownMenuItem(value: 'all', child: Text('All Status')),
                DropdownMenuItem(value: 'active', child: Text('Active')),
                DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                DropdownMenuItem(value: 'draft', child: Text('Draft')),
              ],
              onChanged: (v) => setState(() => _filterStatus = v ?? 'all'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _filterCategory,
              decoration: InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              items: const [
                DropdownMenuItem(value: 'all', child: Text('All Categories')),
                DropdownMenuItem(value: 'akademik', child: Text('Akademik')),
                DropdownMenuItem(value: 'non‑akademik', child: Text('Non‑Akademik')),
              ],
              onChanged: (v) => setState(() => _filterCategory = v ?? 'all'),
            ),
          ),
        ]),
      ]),
    );
  }

  Widget _buildWorkshopList() {
    final list = _filteredWorkshops;
    if (list.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Column(children: [
          Icon(Icons.school_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 12),
          const Text('No workshops found'),
        ]),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Workshops (${list.length})',
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: list.length,
            itemBuilder: (ctx, i) => _buildWorkshopCard(list[i]),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkshopCard(Workshop wk) {
    final dateFmt = DateFormat('MMM dd, yyyy');
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.1), blurRadius: 6, offset: const Offset(0, 2))
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Thumbnail placeholder
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFF999AE6).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.school, color: Color(0xFF999AE6)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(
                    child: Text(wk.title,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  _buildStatusChip(wk.status),
                ]),
                const SizedBox(height: 4),
                Text(wk.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[600])),
                const SizedBox(height: 8),
                Row(children: [
                  const Icon(Icons.category, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(_prettyCategory(wk.category),
                      style: TextStyle(color: Colors.grey[700], fontSize: 12)),
                  const SizedBox(width: 16),
                  const Icon(Icons.people, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text('${wk.participants} participants',
                      style: TextStyle(color: Colors.grey[700], fontSize: 12)),
                ]),
              ]),
            ),
          ]),
        ),
        // Details + buttons
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
          ),
          child: Column(children: [
            Row(children: [
              Expanded(child: _infoColumn('Fee', 'Rp ${wk.price.toStringAsFixed(0)}')),
              Expanded(child: _infoColumn('Schedule', dateFmt.format(wk.scheduleDate))),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit'),
                  onPressed: () => _showEditDialog(wk),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF999AE6),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  icon: Icon(wk.status == 'active' ? Icons.pause : Icons.play_arrow,
                      size: 16),
                  label: Text(wk.status == 'active' ? 'Pause' : 'Activate'),
                  onPressed: () => _toggleStatus(wk),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: wk.status == 'active'
                        ? Colors.orange
                        : Colors.green,
                    side: BorderSide(
                        color: wk.status == 'active'
                            ? Colors.orange
                            : Colors.green),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteWorkshop(wk),
              ),
            ]),
          ]),
        ),
      ]),
    );
  }

  Widget _infoColumn(String label, String value) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      const SizedBox(height: 2),
      Text(value,
          style:
              const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
    ]);
  }

  Widget _buildStatusChip(String status) {
    Color bg;
    Color text;
    IconData icon;
    switch (status) {
      case 'active':
        bg = Colors.green.withOpacity(0.1);
        text = Colors.green;
        icon = Icons.play_circle;
        break;
      case 'inactive':
        bg = Colors.orange.withOpacity(0.1);
        text = Colors.orange;
        icon = Icons.pause_circle;
        break;
      default: // draft
        bg = Colors.grey.withOpacity(0.1);
        text = Colors.grey;
        icon = Icons.drafts;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: text),
        const SizedBox(width: 4),
        Text(_capitalize(status),
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: text)),
      ]),
    );
  }

  // ---------------------------------------------------------------------------
  // ACTIONS
  // ---------------------------------------------------------------------------
  void _toggleStatus(Workshop wk) async {
    setState(() {
      wk.status = wk.status == 'active' ? 'inactive' : 'active';
    });
  }

  void _deleteWorkshop(Workshop wk) async {
    final ok = await _confirmDialog(
      'Delete Workshop',
      'Are you sure you want to delete this workshop? This cannot be undone.',
    );
    if (ok) setState(() => _workshops.remove(wk));
  }

  // ---------------------------------------------------------------------------
  // DIALOGS: ADD & EDIT
  // ---------------------------------------------------------------------------
  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (_) => _WorkshopDialog(
        onSave: (newWorkshop) {
          setState(() => _workshops.add(newWorkshop));
        },
      ),
    );
  }

  void _showEditDialog(Workshop wk) {
    showDialog(
      context: context,
      builder: (_) => _WorkshopDialog(
        original: wk,
        onSave: (updated) {
          setState(() {
            final idx = _workshops.indexWhere((w) => w.id == updated.id);
            _workshops[idx] = updated;
          });
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  Future<bool> _confirmDialog(String title, String msg) async {
    return (await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(title),
            content: Text(msg),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel')),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Delete')),
            ],
          ),
        )) ??
        false;
  }

  // ---------------------------------------------------------------------------
  // UTILITIES
  // ---------------------------------------------------------------------------
  String _capitalize(String s) => s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';
  String _prettyCategory(String c) =>
      c == 'non‑akademik' ? 'Non‑Akademik' : 'Akademik';
}

// -----------------------------------------------------------------------------
// _WorkshopDialog – used for both Add & Edit
// -----------------------------------------------------------------------------
class _WorkshopDialog extends StatefulWidget {
  final Workshop? original;
  final void Function(Workshop saved) onSave;

  const _WorkshopDialog({Key? key, this.original, required this.onSave}) : super(key: key);

  @override
  State<_WorkshopDialog> createState() => _WorkshopDialogState();
}

class _WorkshopDialogState extends State<_WorkshopDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _priceCtrl;
  late String _category;
  DateTime _scheduleDate = DateTime.now().add(const Duration(days: 14));
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final ori = widget.original;
    _titleCtrl = TextEditingController(text: ori?.title ?? '');
    _descCtrl = TextEditingController(text: ori?.description ?? '');
    _priceCtrl = TextEditingController(text: ori != null ? ori.price.toStringAsFixed(0) : '');
    _category = ori?.category ?? 'akademik';
    if (ori != null) _scheduleDate = ori.scheduleDate;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.original == null ? 'Add New Workshop' : 'Edit Workshop'),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: 'Workshop Title', border: OutlineInputBorder()),
                validator: (v) => v == null || v.trim().isEmpty ? 'Enter a title' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                maxLines: 3,
                validator: (v) => v == null || v.trim().isEmpty ? 'Enter description' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _category,
                items: const [
                  DropdownMenuItem(value: 'akademik', child: Text('Akademik')),
                  DropdownMenuItem(value: 'non‑akademik', child: Text('Non‑Akademik')),
                ],
                onChanged: (v) => setState(() => _category = v ?? 'akademik'),
                decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _priceCtrl,
                decoration: const InputDecoration(labelText: 'Fee (Rp)', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.trim().isEmpty ? 'Enter fee' : null,
              ),
              const SizedBox(height: 12),
              ListTile(
                title: const Text('Schedule Date'),
                subtitle: Text(DateFormat('MMM dd, yyyy').format(_scheduleDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _scheduleDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) setState(() => _scheduleDate = picked);
                },
              ),
            ]),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: _isSaving ? null : () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF999AE6), foregroundColor: Colors.white),
          onPressed: _isSaving ? null : _save,
          child: _isSaving
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Save'),
        ),
      ],
    );
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 400)); // simulate delay

    // build workshop object
    final saved = Workshop(
      id: widget.original?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      category: _category,
      price: double.tryParse(_priceCtrl.text.trim()) ?? 0,
      imageUrl: '', // placeholder – implement picker later
      scheduleDate: _scheduleDate,
      status: widget.original?.status ?? 'draft',
      participants: widget.original?.participants ?? 0,
      createdAt: widget.original?.createdAt ?? DateTime.now(),
    );

    widget.onSave(saved);
    if (mounted) Navigator.pop(context);
  }
}
