import 'package:animate_do/animate_do.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';

import '../../main.dart';
import '../../models/task.dart';
import '../../utils/colors.dart';
import '../../utils/strings.dart';
import 'widgets/task_widget.dart';
import '../tasks/task_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  GlobalKey<SliderDrawerState> drawerKey = GlobalKey<SliderDrawerState>();

  int checkDoneTask(List<Task> tasks) => tasks.where((t) => t.isCompleted).length;

  double valueOfIndicator(List<Task> tasks) => tasks.isEmpty ? 1 : tasks.length.toDouble();

  @override
  Widget build(BuildContext context) {
    final base = BaseWidget.of(context);
    final textTheme = Theme.of(context).textTheme;

    return ValueListenableBuilder(
      valueListenable: base.dataStore.listenToTask(),
      builder: (ctx, Box<Task> box, _) {
        var tasks = box.values.toList()..sort((a, b) => a.createdAtDate.compareTo(b.createdAtDate));

        return Scaffold(
          backgroundColor: Colors.white,
          floatingActionButton: const FAB(),
          body: SliderDrawer(
            key: drawerKey,
            isDraggable: false,
            animationDuration: 1000,
            appBar: MyAppBar(drawerKey: drawerKey),
            slider: const MySlider(),
            child: _buildBody(tasks, base, textTheme),
          ),
        );
      },
    );
  }

  Widget _buildBody(List<Task> tasks, BaseWidget base, TextTheme textTheme) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(55, 0, 0, 0),
            width: double.infinity,
            height: 100,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 25,
                  height: 25,
                  child: CircularProgressIndicator(
                    value: checkDoneTask(tasks) / valueOfIndicator(tasks),
                    valueColor: const AlwaysStoppedAnimation(MyColors.primaryColor),
                    backgroundColor: Colors.grey,
                  ),
                ),
                const SizedBox(width: 25),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(MyString.mainTitle, style: textTheme.displayLarge),
                    Text("${checkDoneTask(tasks)} of ${tasks.length} task", style: textTheme.titleMedium),
                  ],
                ),
              ],
            ),
          ),
          const Padding(padding: EdgeInsets.only(top: 10), child: Divider(thickness: 2, indent: 100)),
          SizedBox(
            height: 585,
            child: tasks.isEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FadeIn(child: Lottie.asset('assets/lottie/1.json', width: 200, height: 200)),
                      FadeInUp(from: 30, child: const Text(MyString.doneAllTask)),
                    ],
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: tasks.length,
                    itemBuilder: (_, i) => Dismissible(
                      key: Key(tasks[i].id),
                      direction: DismissDirection.horizontal,
                      background: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [Icon(Icons.delete_outline, color: Colors.grey), Text("Deleted")],
                      ),
                      onDismissed: (_) => base.dataStore.deleteTask(task: tasks[i]),
                      child: TaskWidget(task: tasks[i]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class MySlider extends StatelessWidget {
  const MySlider({Key? key}) : super(key: key);

  // Dùng const cho danh sách
  static const List<IconData> icons = [
    CupertinoIcons.home,
    CupertinoIcons.person_fill,
    CupertinoIcons.settings,
    CupertinoIcons.info_circle_fill,
  ];

  static const List<String> texts = [
    "Home",
    "Profile",
    "Settings",
    "Details",
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 90),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: MyColors.primaryGradientColor,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundImage: AssetImage('assets/img/main.png'),
          ),
          const SizedBox(height: 8),
          Text("Vũ Đình Long", style: textTheme.headlineMedium),
          Text("63CNTT2", style: textTheme.titleSmall),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 30, horizontal: 10),
            height: 300,
            child: ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: icons.length,
              itemBuilder: (_, i) => ListTile(
                leading: Icon(icons[i], color: Colors.white, size: 30),
                title: Text(texts[i], style: const TextStyle(color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
class MyAppBar extends StatefulWidget implements PreferredSizeWidget {
  const MyAppBar({Key? key, required this.drawerKey}) : super(key: key);
  final GlobalKey<SliderDrawerState> drawerKey;

  @override
  State<MyAppBar> createState() => _MyAppBarState();
  @override
  Size get preferredSize => const Size.fromHeight(100);
}

class _MyAppBarState extends State<MyAppBar> with SingleTickerProviderStateMixin {
  late AnimationController controller;
  bool isDrawerOpen = false;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void toggle() {
    setState(() {
      isDrawerOpen = !isDrawerOpen;
      isDrawerOpen ? controller.forward() : controller.reverse();
      isDrawerOpen ? widget.drawerKey.currentState!.openSlider() : widget.drawerKey.currentState!.closeSlider();
    });
  }

  @override
  Widget build(BuildContext context) {
    final box = BaseWidget.of(context).dataStore.box;
    return SizedBox(
      width: double.infinity,
      height: 132,
      child: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(onPressed: toggle, icon: AnimatedIcon(icon: AnimatedIcons.menu_close, progress: controller, size: 40)),
            GestureDetector(
              onTap: () => box.isEmpty ? _showWarning(context) : _showDeleteAll(context),
              child: const Padding(padding: EdgeInsets.only(right: 20), child: Icon(CupertinoIcons.trash, size: 40)),
            ),
          ],
        ),
      ),
    );
  }

  void _showWarning(BuildContext context) => showDialog(context: context, builder: (_) => const AlertDialog(title: Text("No Task!"), content: Text("Add some tasks first.")));
  void _showDeleteAll(BuildContext context) => showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Delete All?"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("No")),
            TextButton(
              onPressed: () {
                BaseWidget.of(context).dataStore.box.clear();
                Navigator.pop(context);
              },
              child: const Text("Yes"),
            ),
          ],
        ),
      );
}

class FAB extends StatelessWidget {
  const FAB({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, CupertinoPageRoute(builder: (_) => const TaskView())),
      child: Material(
        borderRadius: BorderRadius.circular(15),
        elevation: 10,
        child: Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(color: MyColors.primaryColor, borderRadius: BorderRadius.circular(15)),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}