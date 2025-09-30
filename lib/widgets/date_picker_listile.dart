import 'package:flutter/material.dart';
import 'package:kardex_app_front/src/tools/datetime_tool.dart';

class DatePickerListTile extends StatefulWidget {
  const DatePickerListTile({
    super.key,
    required this.title,
    required this.onSelected,
    this.defaultDate,
    this.isActive = true,
  });

  final String title;
  final ValueChanged<DateTime> onSelected;
  final bool isActive;
  final DateTime? defaultDate;

  @override
  DatePickerListTileState createState() => DatePickerListTileState();
}

class DatePickerListTileState extends State<DatePickerListTile> {
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.defaultDate;
  }

  @override
  Widget build(BuildContext context) {
    String text = '  -  -   ';

    if (_selectedDate != null) {
      text = DateTimeTool.formatddMMyy(_selectedDate!);

      if (_selectedDate!.day == DateTimeTool.getTodayMidnight().day) {
        text = 'Hoy';
      }
    }

    return ListTile(
      title: Text(widget.title),
      subtitle: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          color: Colors.black,
          fontSize: 16,
        ),
      ),
      trailing: const Icon(Icons.calendar_today),
      onTap: !widget.isActive ? null : () => _selectDate(context),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      widget.onSelected(picked);
    }
  }
}
