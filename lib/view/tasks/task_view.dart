import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../main.dart';
import '../../models/task.dart';
import '../../utils/colors.dart';
import '../../utils/strings.dart';

class TaskView extends StatefulWidget {
  const TaskView({Key? key, this.taskControllerForTitle, this.taskControllerForSubtitle, this.task}) : super(key: key);
  final TextEditingController? taskControllerForTitle;
  final TextEditingController? taskControllerForSubtitle;
  final Task? task;

  @override
  State<TaskView> createState() => _TaskViewState();
}

class _TaskViewState extends State<TaskView> {
  late TextEditingController _titleController;
  late TextEditingController _subtitleController;
  DateTime? _selectedTime;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _titleController = widget.taskControllerForTitle ?? TextEditingController(text: widget.task?.title ?? '');
    _subtitleController = widget.taskControllerForSubtitle ?? TextEditingController(text: widget.task?.subtitle ?? '');
    _selectedTime = widget.task?.createdAtTime ?? DateTime.now();
    _selectedDate = widget.task?.createdAtDate ?? DateTime.now();
  }

  @override
  void dispose() {
    if (widget.taskControllerForTitle == null) _titleController.dispose();
    if (widget.taskControllerForSubtitle == null) _subtitleController.dispose();
    super.dispose();
  }

  bool get isUpdateMode => widget.task != null;

  void _saveTask() {
    final title = _titleController.text.trim();
    final subtitle = _subtitleController.text.trim();
    if (title.isEmpty || subtitle.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    if (isUpdateMode) {
      widget.task!..title = title;
      widget.task!..subtitle = subtitle;
      widget.task!..createdAtTime = _selectedTime!;
      widget.task!..createdAtDate = _selectedDate!;
      widget.task!.save();
    } else {
      final task = Task.create(title: title, subtitle: subtitle, createdAtTime: _selectedTime, createdAtDate: _selectedDate);
      BaseWidget.of(context).dataStore.addTask(task: task);
    }
    Navigator.pop(context);
  }

  void _deleteTask() {
    widget.task?.delete();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: const MyAppBar(),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildHeader(textTheme),
              const SizedBox(height: 20),
              _buildTextField(_titleController, "Bạn đang lên kế hoạch gì ?", maxLines: 6),
              const SizedBox(height: 20),
              _buildTextField(_subtitleController, MyString.addNote, prefixIcon: Icons.bookmark_border),
              const SizedBox(height: 20),
              _buildTimePicker(context, textTheme),
              const SizedBox(height: 10),
              _buildDatePicker(context, textTheme),
              const SizedBox(height: 30),
              _buildButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(TextTheme textTheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox(width: 70, child: Divider(thickness: 2)),
        RichText(
          text: TextSpan(
            text: isUpdateMode ? MyString.updateCurrentTask : MyString.addNewTask,
            style: textTheme.displayMedium,
            children: const [TextSpan(text: MyString.taskString, style: TextStyle(fontWeight: FontWeight.w400))],
          ),
        ),
        const SizedBox(width: 70, child: Divider(thickness: 2)),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {int maxLines = 1, IconData? prefixIcon}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: Colors.grey) : null,
        enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
      ),
    );
  }

  Widget _buildTimePicker(BuildContext context, TextTheme textTheme) {
    return _pickerBox(
      label: MyString.timeString,
      value: DateFormat('hh:mm a').format(_selectedTime!),
      onTap: () async {
        final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_selectedTime!));
        if (time != null) setState(() => _selectedTime = DateTime(2020, 1, 1, time.hour, time.minute));
      },
      textTheme: textTheme,
    );
  }

  Widget _buildDatePicker(BuildContext context, TextTheme textTheme) {
    return _pickerBox(
      label: MyString.dateString,
      value: DateFormat.yMMMEd().format(_selectedDate!),
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _selectedDate!,
          firstDate: DateTime.now(),
          lastDate: DateTime(2030),
        );
        if (date != null) setState(() => _selectedDate = date);
      },
      textTheme: textTheme,
      width: 140,
    );
  }

  Widget _pickerBox({required String label, required String value, required VoidCallback onTap, required TextTheme textTheme, double width = 80}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(10)),
        child: Row(
          children: [
            Text(label, style: textTheme.titleLarge),
            const Spacer(),
            Container(
              width: width,
              height: 35,
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
              alignment: Alignment.center,
              child: Text(value, style: textTheme.titleMedium),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtons() {
    return Row(
      mainAxisAlignment: isUpdateMode ? MainAxisAlignment.spaceEvenly : MainAxisAlignment.center,
      children: [
        if (isUpdateMode)
          ElevatedButton.icon(
            onPressed: _deleteTask,
            icon: const Icon(Icons.close),
            label: const Text(MyString.deleteTask),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: MyColors.primaryColor, side: const BorderSide(color: MyColors.primaryColor)),
          ),
        ElevatedButton(
          onPressed: _saveTask,
          style: ElevatedButton.styleFrom(backgroundColor: MyColors.primaryColor),
          child: Text(isUpdateMode ? MyString.updateTaskString : MyString.addTaskString, style: const TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MyAppBar({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Row(
          children: [
            IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 50)),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(100);
}