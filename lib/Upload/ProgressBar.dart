
import 'package:flutter/material.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';



ValueNotifier<double> progress = ValueNotifier<double>(0);

class ProgressBar extends StatefulWidget {
  @override
  _ProgressBarState createState() => _ProgressBarState();
}

class _ProgressBarState extends State<ProgressBar> {
  @override
  void initState() {
    progress.value = 0;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  Widget contentBox(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      height: 80,
      width: MediaQuery.of(context).size.width / 2.4,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Uploading...'),
          ValueListenableBuilder(
            valueListenable: progress,
            builder: (BuildContext context, double prog, _) {
              return FAProgressBar(
                currentValue: prog,
                displayText: '%',
              );
            },
          ),
        ],
      ),
    );
  }
}
