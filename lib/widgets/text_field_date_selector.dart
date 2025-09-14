import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateFieldSelector extends StatefulWidget {
  const DateFieldSelector({
    super.key,
    required this.onSelectedDate,
    this.initDate,
  });

  final void Function(DateTime? value) onSelectedDate;
  final DateTime? initDate;

  @override
  State<DateFieldSelector> createState() => _DateFieldSelectorState();
}

class _DateFieldSelectorState extends State<DateFieldSelector> {
  DateTime? selectedDate;
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initDate;
    if (selectedDate != null) {
      controller.text = DateFormat('dd/MM/yyyy').format(selectedDate!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      textAlign: TextAlign.center,
      style: const TextStyle(fontWeight: FontWeight.w500),
      readOnly: true,
      controller: controller,
      onTap: () async {
        final res = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2022),
          lastDate: DateTime.now(),
        );

        if (res == null) return;
        selectedDate = res;
        controller.text = DateFormat('dd/MM/yyyy').format(res);
        widget.onSelectedDate(selectedDate);
      },
    );
  }
}
