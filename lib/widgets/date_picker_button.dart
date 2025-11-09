import 'package:flutter/material.dart';
import 'package:kardex_app_front/src/tools/datetime_tool.dart';

class DatePickerButton extends StatefulWidget {
  const DatePickerButton({
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
  DatePickerButtonState createState() => DatePickerButtonState();
}

class DatePickerButtonState extends State<DatePickerButton> {
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

    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 104),
      child: InkWell(
        onTap: !widget.isActive ? null : () => _selectDate(context),
        child: Ink(
          padding: const EdgeInsets.all(4),
          child: Row(
            spacing: 8,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Icon(Icons.calendar_today),
              Column(
                spacing: 4,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.title),
                  Text(
                    text,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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
