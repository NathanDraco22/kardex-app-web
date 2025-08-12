import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateFieldSelector extends StatefulWidget {
  const DateFieldSelector({
    super.key,
    required this.onSelectedDate,
  });

  final void Function(DateTime? value) onSelectedDate;

  @override
  State<DateFieldSelector> createState() => _DateFieldSelectorState();
}

class _DateFieldSelectorState extends State<DateFieldSelector> {
  DateTime? selectedDate;
  TextEditingController controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return TextField(
      textAlign: TextAlign.center,
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
