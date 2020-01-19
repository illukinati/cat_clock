// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:flare_flutter/flare_actor.dart';

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

  String catAnimation = "sunny";
  String catTheme = "light_theme";
  Color skyColor = Colors.lightBlueAccent[100];
  Color groundColor = Colors.lightGreenAccent[100];
  bool isSleeping = false;

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

  void _updateModel() async {
    if(widget.model.theme != catTheme){
      setState(() {
        catAnimation = widget.model.theme;
        catTheme = widget.model.theme;
      });
    }
    await Future.delayed(const Duration(seconds: 1));
    _weatherConverter(widget.model.weatherString);
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

      _checkSleep();
      _skyController(DateTime.now().hour);
      _groundController();

      _timer = Timer(
        Duration(seconds: 1) - Duration(milliseconds: _dateTime.millisecond),
        _updateTime,
      );
    });
  }

  void _weatherConverter(String weather){
    switch(weather){
      case "sunny":
        _becomeSunny();
        break;
      case "rainy":
        _startToRain();
        break;
      case "thunderstorm":
        _startToThunderstorm();
        break;
      case "snowy":
        _startToSnow();
        break;
      case "windy":
        _becomeWindy();
        break;
      case "cloudy":
        _startCloudy();
        break;
    }
  }

  /// Weather Controller
  void _startToRain() async {
    if(catAnimation != "sunny"){
      setState(() => catAnimation = "back_to_normal");
      await Future.delayed(const Duration(seconds: 1));
    }
    setState(() => catAnimation = "start_raining");
    await Future.delayed(const Duration(seconds: 1));
    setState(() => catAnimation = "rainy");
  }

  void _startToThunderstorm() async {
    setState(() => catAnimation = "start_raining");
    await Future.delayed(const Duration(seconds: 1));
    setState(() => catAnimation = "thunderstorm");
  }

  void _becomeSunny() async{
    if(catAnimation == "rainy" || catAnimation == "thunderstorm"){
      setState(() => catAnimation = "stop_raining");
    } else if (catAnimation == "snowy" || catAnimation == "cloudy"){
      setState(() => catAnimation = "back_to_normal");
    }
    await Future.delayed(const Duration(seconds: 1));
    setState(() => catAnimation = "sunny");
  }

  void _startToSnow() async{
    setState(() => catAnimation = "back_to_normal");
    await Future.delayed(const Duration(seconds: 1));
    setState(() => catAnimation = "snowy");
  }

  void _startCloudy() async{
    setState(() => catAnimation = "back_to_normal");
    await Future.delayed(const Duration(seconds: 1));
    setState(() => catAnimation = "start_cloudy");
    await Future.delayed(const Duration(seconds: 3));
    setState(() => catAnimation = "cloudy");
  }

  void _becomeWindy() async{
    setState(() => catAnimation = "back_to_normal");
    await Future.delayed(const Duration(seconds: 1));
    setState(() => catAnimation = "windy");
  }

  /// Awake or not controller
  void _checkSleep() {
    if(DateTime.now().hour > 20){
      if(!isSleeping){
        _goToSleep();
      }
      else
        setState(() => catAnimation = "sleeping");
    } else {
      if(isSleeping)
        _wakeUp();
    }
  }

  void _goToSleep() async {
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() => catAnimation = "start_to_sleep");
    await Future.delayed(const Duration(seconds: 4));
    setState(() {
      catAnimation = "sleeping";
      isSleeping = true;
    });
  }

  void _wakeUp() async{
    setState(() => catAnimation = "wake_up");
    await Future.delayed(const Duration(seconds: 3));
    setState(()=>isSleeping = false);
    _weatherConverter(widget.model.weatherString);
  }

  /// Sky controller
  void _skyController(int hour){
    if(catAnimation == "rainy" || catAnimation == "start_raining" || catAnimation == "thunderstorm"){
      setState(() => skyColor = Color(0xFF31414F));
    } else if(catAnimation == "snowy") {
      setState(() => skyColor = Color(0xFFD0E4F5));
    } else if(hour >= 4 && hour <= 10 || catAnimation == "cloudy"){
      setState(() => skyColor = Colors.lightBlueAccent[100]);
    } else if (hour >= 11 && hour <= 14){
      setState(() => skyColor = Color(0xFFF1F29D));
    } else if (hour >= 15 && hour <= 18){
      setState(() => skyColor = Color(0xFFF2CB8D));
    } else if (hour >= 19 && hour <= 21){
      setState(() => skyColor = Color(0xFF78A4CC));
    } else if (hour >= 21 && hour <= 3){
      setState(() => skyColor = Color(0xFF31414F));
    }
  }

  /// Ground controller
  void _groundController(){
    if(catAnimation == "snowy"){
      setState(() => groundColor = Colors.white);
      return;
    }
    if(catTheme == "light_theme"){
      setState(() => groundColor = Colors.greenAccent[100]);
    } else if(catTheme == "dark_theme"){
      setState(() => groundColor = Color(0xFF856D4C));
    }
  }


  @override
  Widget build(BuildContext context) {

    Color hourBg = (catTheme == "light_theme") ? Colors.blue[100]: Colors.black;
    Color minuteBg = (catTheme == "light_theme") ? Colors.orange[100]: Colors.black;
    Color secondBg = (catTheme == "light_theme") ? Colors.red[100]: Colors.black;

    Color num = (catTheme == "light_theme") ? Colors.black : Color(0xFFFAFA66);

    return Container(
      child: Container(
        height: double.infinity,
        alignment: Alignment.bottomCenter,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Container(
              child: Column(
                children: <Widget>[
                  Expanded(
                    flex: 2,
                    child: Container(
                      color: skyColor,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      color: groundColor,
                    ),
                  )
                ],
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              margin: EdgeInsets.all(MediaQuery.of(context).size.width / 30),
              color: (catTheme == "light_theme") ? Color(0xFF5C422D) : Colors.grey[100],
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 2,
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(10, 10, 5, 10),
                      color: hourBg,
                      child:
                          verticalSlideClock(0, MediaQuery.of(context).size.width / 2.5, num),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                      color: hourBg,
                      child:
                          verticalSlideClock(1, MediaQuery.of(context).size.width / 2.5, num),
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
                                      margin: const EdgeInsets.fromLTRB(10, 10, 5, 10),
                                      color: minuteBg,
                                      child: verticalSlideClock(
                                          2,
                                          MediaQuery.of(context).size.width / 3.8, num),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Container(
                                      margin: const EdgeInsets.fromLTRB(0, 10, 10, 10),
                                      color: minuteBg,
                                      child: verticalSlideClock(
                                          3,
                                          MediaQuery.of(context).size.width / 3.8, num),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: horizontalSlideClock(secondBg, num)
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              alignment: Alignment.bottomLeft,
              child: FlareActor("assets/flares/cat.flr",
                  fit: BoxFit.fitHeight, animation: catAnimation),
            ),
          ],
        ),
      ),
    );
  }

  Widget verticalSlideClock(int index, double fontSize, Color colorNum) {
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
                    color: colorNum,
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

  Widget horizontalSlideClock(Color bg, Color colorNum) {
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.only(left: 10.0, bottom: 10.0, right: 10.0),
      color: bg,
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
                          ? colorNum
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
