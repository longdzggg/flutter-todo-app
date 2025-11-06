import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/task.dart';
import '../../../utils/colors.dart';
import '../../tasks/task_view.dart';

class TaskWidget extends StatefulWidget {
  const TaskWidget({Key? key, required this.task}) : super(key: key);
  final Task task;

  @override
  _TaskWidgetState createState() => _TaskWidgetState();
}

class _TaskWidgetState extends State<TaskWidget> {
  late TextEditingController titleController;
  late TextEditingController subtitleController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.task.title);
    subtitleController = TextEditingController(text: widget.task.subtitle);
  }

  @override
  void dispose() {
    titleController.dispose();
    subtitleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (ctx) => TaskView(
              taskControllerForTitle: titleController,
              taskControllerForSubtitle: subtitleController,
              task: widget.task,
            ),
          ),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: widget.task.isCompleted
              ? const Color.fromARGB(154, 119, 144, 229)
              : Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(.1), offset: const Offset(0, 4), blurRadius: 10),
          ],
        ),
        child: ListTile(
          leading: GestureDetector(
            onTap: () {
              setState(() {
                widget.task.isCompleted = !widget.task.isCompleted;
                widget.task.save();
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              decoration: BoxDecoration(
                color: widget.task.isCompleted ? MyColors.primaryColor : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey, width: .8),
              ),
              child: const Icon(Icons.check, color: Colors.white),
            ),
          ),
          title: Text(
            titleController.text,
            style: TextStyle(
              color: widget.task.isCompleted ? MyColors.primaryColor : Colors.black,
              fontWeight: FontWeight.w500,
              decoration: widget.task.isCompleted ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                subtitleController.text,
                style: TextStyle(
                  color: widget.task.isCompleted ? MyColors.primaryColor : Colors.grey,
                  decoration: widget.task.isCompleted ? TextDecoration.lineThrough : null,
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                  child: Column(
                    children: [
                      Text(DateFormat('hh:mm a').format(widget.task.createdAtTime),
                          style: TextStyle(color: widget.task.isCompleted ? Colors.white : Colors.grey)),
                      Text(DateFormat.yMMMEd().format(widget.task.createdAtDate),
                          style: TextStyle(color: widget.task.isCompleted ? Colors.white : Colors.grey)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}