import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  // Color scheme for the calendar
  final Color primaryColor = const Color(0xFF3D5A80);
  final Color accentColor = const Color(0xFF98C1D9);
  final Color todayColor = const Color(0xFFEE6C4D);
  final Color markedColor = const Color(0xFF293241);
  final Color textColor = const Color(0xFF333333);
  final Color backgroundColor = const Color(0xFFF5F5F5);

  DateTime _selectedDate = DateTime.now();
  final List<DateTime> _markedDates = [];
  late DateTime _today;

  @override
  void initState() {
    super.initState();
    _today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        title: const Text('Kalender'),
        backgroundColor: primaryColor,
      ),
      body: Column(
        children: [
          _buildMonthHeader(),
          _buildWeekdayHeader(),
          _buildCalendarGrid(),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildMonthHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(color: accentColor.withOpacity(0.3), width: 1),
        ),
      ),
      child: Center(
        child: Text(
          DateFormat('MMMM yyyy').format(_selectedDate),
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
      ),
    );
  }

  Widget _buildWeekdayHeader() {
    final List<String> weekdays = [
      'Min',
      'Sen',
      'Sel',
      'Rab',
      'Kam',
      'Jum',
      'Sab'
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.05),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: weekdays
            .map((day) => Expanded(
                  child: Center(
                    child: Text(
                      day,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: textColor.withOpacity(0.8),
                      ),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final int daysInMonth = _getDaysInMonth(_selectedDate);
    final int firstDayOfWeek =
        DateTime(_selectedDate.year, _selectedDate.month, 1).weekday % 7;
    final int totalCells = daysInMonth + firstDayOfWeek;
    final int totalRows = (totalCells / 7).ceil();

    return Expanded(
      child: GridView.builder(
        padding: const EdgeInsets.all(8.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          childAspectRatio: 1.0,
          mainAxisSpacing: 4.0,
          crossAxisSpacing: 4.0,
        ),
        itemCount: totalRows * 7,
        itemBuilder: (context, index) {
          if (index < firstDayOfWeek || index >= daysInMonth + firstDayOfWeek) {
            return const SizedBox.shrink();
          }

          final int dayNumber = index - firstDayOfWeek + 1;
          final DateTime currentDate =
              DateTime(_selectedDate.year, _selectedDate.month, dayNumber);
          final bool isToday = _isSameDay(currentDate, _today);
          final bool isMarked = _isDateMarked(currentDate);

          return _buildDayCell(dayNumber, currentDate, isToday, isMarked);
        },
      ),
    );
  }

  Widget _buildDayCell(
      int dayNumber, DateTime date, bool isToday, bool isMarked) {
    Color cellColor = Colors.transparent;
    Color textColor = this.textColor;

    if (isToday) {
      cellColor = todayColor;
      textColor = Colors.white;
    } else if (isMarked) {
      cellColor = markedColor;
      textColor = Colors.white;
    }

    return GestureDetector(
      onTap: () => _toggleMarkDate(date),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: cellColor,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: isMarked || isToday
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
          border: !isMarked && !isToday
              ? Border.all(color: accentColor.withOpacity(0.3))
              : null,
        ),
        child: Center(
          child: Text(
            '$dayNumber',
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight:
                  isToday || isMarked ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavigationButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onPressed: _goToPreviousMonth,
            label: 'Sebelumnya',
          ),
          TextButton(
            onPressed: _goToCurrentMonth,
            style: TextButton.styleFrom(
              foregroundColor: primaryColor,
              backgroundColor: accentColor.withOpacity(0.1),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('Hari Ini'),
          ),
          _buildNavigationButton(
            icon: Icons.arrow_forward_ios_rounded,
            onPressed: _goToNextMonth,
            label: 'Berikutnya',
            isRight: true,
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String label,
    bool isRight = false,
  }) {
    return TextButton.icon(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 8),
      ),
      icon: isRight ? const SizedBox.shrink() : Icon(icon, size: 18),
      label: isRight
          ? Row(
              children: [
                Text(label),
                const SizedBox(width: 4),
                Icon(icon, size: 18),
              ],
            )
          : Text(label),
    );
  }

  void _toggleMarkDate(DateTime date) {
    setState(() {
      final normalizedDate = DateTime(date.year, date.month, date.day);
      if (_isDateMarked(normalizedDate)) {
        _markedDates.removeWhere((d) => _isSameDay(d, normalizedDate));
      } else {
        _markedDates.add(normalizedDate);
      }
    });
  }

  void _goToPreviousMonth() {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1);
    });
  }

  void _goToNextMonth() {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1);
    });
  }

  void _goToCurrentMonth() {
    setState(() {
      _selectedDate = DateTime.now();
    });
  }

  int _getDaysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }

  bool _isDateMarked(DateTime date) {
    return _markedDates.any((d) => _isSameDay(d, date));
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
