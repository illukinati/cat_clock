// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:flare_flutter/flare_actor.dart';

enum _Element {
  background,
  text,
  shadow,
}

final _lightTheme = {
  _Element.background: Color(0xFF81B3FE),
  _Element.text: Colors.white,
  _Element.shadow: Colors.black,
};

final _darkTheme = {
  _Element.background: Colors.black,
  _Element.text: Colors.white,
  _Element.shadow: Color(0xFF174EA6),
};

/// A basic digital clock.
///
/// You can do better than this!
class DigitalClock extends StatefulWidget {
  const DigitalClock(this.model);

  final ClockModel model;

  @override
  _DigitalClockState createState() => _DigitalClockState();
}

class _DigitalClockState extends State<DigitalClock> {
  DateTime _dateTime = DateTime.now();
  Timer _timer;

  // My own code
  List<AutoScrollController> scrollController = new List(6);
  final num = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0"];
  final scrollDirection = Axis.vertical;
  var clocks = new List(5);

  var catAnimation = "watching_around";

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);

    // scroll widget
    for (int i = 0; i < scrollController.length; i++) {
      scrollController[i] = AutoScrollController(
          viewportBoundaryGetter: () =>
              Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
          axis: scrollDirection);
    }

    _updateTime();
    _updateModel();
  }

  @override
  void didUpdateWidget(DigitalClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    widget.model.dispose();
    super.dispose();
  }

  void _updateModel() {
    setState(() {
      // Cause the clock to rebuild when the model changes.
    });
  }

  void _updateTime() {
    setState(() {
      _dateTime = DateTime.now();
      clocks[0] = DateFormat(widget.model.is24HourFormat ? 'HH' : 'hh')
          .format(_dateTime)[0];
      clocks[1] = DateFormat(widget.model.is24HourFormat ? 'HH' : 'hh')
          .format(_dateTime)[1];
      clocks[2] = DateFormat('mm').format(_dateTime)[0];
      clocks[3] = DateFormat('mm').format(_dateTime)[1];
      clocks[4] = DateFormat('ss').format(_dateTime);

      for (int i = 0; i < clocks.length; i++) {
        scrollController[i].scrollToIndex(int.parse(clocks[i]),
            preferPosition: AutoScrollPosition.begin);
      }

      _timer = Timer(
        Duration(seconds: 1) - Duration(milliseconds: _dateTime.millisecond),
        _updateTime,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Container(
        color: Colors.white,
        height: double.infinity,
        alignment: Alignment.bottomCenter,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              margin: EdgeInsets.all(MediaQuery.of(context).size.width / 30),
              color: Color(0xFFC8896E),
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 2,
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(10, 10, 1, 10),
                      color: Colors.blue[100],
                      child:
                          verticalSlideClock(0, MediaQuery.of(context).size.width / 2.5),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(1.0, 10, 10, 10),
                      color: Colors.blue[100],
                      child:
                          verticalSlideClock(1, MediaQuery.of(context).size.width / 2.5),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Container(
                      child: Column(
                        children: <Widget>[
                          Expanded(
                            flex: 2,
                            child: Container(
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    flex: 1,
                                    child: Container(
                                      margin: const EdgeInsets.only(
                                          top: 10, right: 10, bottom: 10),
                                      color: Colors.orange[100],
                                      child: verticalSlideClock(
                                          2,
                                          MediaQuery.of(context).size.width / 3.8),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Container(
                                      margin: const EdgeInsets.only(
                                          top: 10, right: 10, bottom: 10),
                                      color: Colors.orange[100],
                                      child: verticalSlideClock(
                                          3,
                                          MediaQuery.of(context).size.width / 3.8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: horizontalSlideClock()
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
//            Container(
//              child: Image.asset("assets/images/frame.png", fit: BoxFit.cover),
//            ),
            Container(
              alignment: Alignment.bottomLeft,
              child: FlareActor("assets/flares/cat.flr",
                  fit: BoxFit.fitHeight, animation: "back_to_normal"),
            ),
          ],
        ),
      ),
    );
  }

  Widget verticalSlideClock(int index, double fontSize) {
    return Container(
      alignment: Alignment.center,
      child: ListView.builder(
        scrollDirection: this.scrollDirection,
        controller: this.scrollController[index],
        itemCount: this.num.length,
        itemBuilder: (context, i) {
          return AutoScrollTag(
            key: ValueKey(i),
            controller: scrollController[index],
            index: i,
            child: Container(
              child: Center(
                child: Text(
                  i.toString(),
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: fontSize,
                    fontFamily: "Solway",
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget horizontalSlideClock() {
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.only(bottom: 10.0, right: 10.0),
      color: Colors.red[100],
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        controller: this.scrollController[4],
        itemCount: 62,
        itemBuilder: (context, i) {
          var tick = (i - 1).toString();
          if (tick.length == 1) tick = "0$tick";

          return AutoScrollTag(
            key: ValueKey(i),
            controller: scrollController[4],
            index: i,
            child: Container(
              width:
              MediaQuery.of(context).size.width / 8,
              height:
              MediaQuery.of(context).size.height / 11,
              child: Center(
                child: Text(
                  (tick == "-1")
                      ? ""
                      : (tick == "60") ? "" : "$tick",
                  style: TextStyle(
                      fontSize: (tick == clocks[4])
                          ? MediaQuery.of(context).size.width / 11
                          : MediaQuery.of(context).size.width / 15,
                      color: (tick == clocks[4])
                          ? Colors.black
                          : Colors.white,
                      fontFamily: "Solway"),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
