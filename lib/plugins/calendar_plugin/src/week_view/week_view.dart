// Copyright (c) 2021 Simform Solutions. All rights reserved.
// Use of this source code is governed by a MIT-style license
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import '../calendar_constants.dart';
import '../calendar_controller_provider.dart';
import '../calendar_event_data.dart';
import '../components/components.dart';
import '../components/event_scroll_notifier.dart';
import '../constants.dart';
import '../enumerations.dart';
import '../event_arrangers/event_arrangers.dart';
import '../event_controller.dart';
import '../extensions.dart';
import '../modals.dart';
import '../typedefs.dart';
import '_internal_week_view_page.dart';

/// [Widget] to display week view.
class WeekView<T extends Object?> extends StatefulWidget {
  /// Builder to build tile for events.
  final EventTileBuilder<T>? eventTileBuilder;

  /// Builder for timeline.
  final DateWidgetBuilder? timeLineBuilder;

  /// Header builder for week page header.
  final WeekPageHeaderBuilder? weekPageHeaderBuilder;

  /// Arrange events.
  final EventArranger<T>? eventArranger;

  /// Called whenever user changes week.
  final CalendarPageChangeCallBack? onPageChange;

  /// Minimum day to display in week view.
  ///
  /// In calendar first date of the week that contains this data will be
  /// minimum date.
  ///
  /// ex, If minDay is 16th March, 2022 then week containing this date will have
  /// dates from 14th to 20th (Monday to Sunday). adn 14th date will
  /// be the actual minimum date.
  final DateTime? minDay;

  /// Maximum day to display in week view.
  ///
  /// In calendar last date of the week that contains this data will be
  /// maximum date.
  ///
  /// ex, If maxDay is 16th March, 2022 then week containing this date will have
  /// dates from 14th to 20th (Monday to Sunday). adn 20th date will
  /// be the actual maximum date.
  final DateTime? maxDay;

  /// Initial week to display in week view.
  final DateTime? initialDay;

  /// Settings for hour indicator settings.
  final HourIndicatorSettings? hourIndicatorSettings;

  /// Settings for live time indicator settings.
  final HourIndicatorSettings? liveTimeIndicatorSettings;

  /// duration for page transition while changing the week.
  final Duration pageTransitionDuration;

  /// Transition curve for transition.
  final Curve pageTransitionCurve;

  /// Controller for Week view thia will refresh view when user adds or removes
  /// event from controller.
  final EventController<T>? controller;

  /// Defines height occupied by one minute of time span. This parameter will
  /// be used to calculate total height of Week view.
  final double heightPerMinute;

  /// Width of time line.
  final double? timeLineWidth;

  /// Flag to show live time indicator in all day or only [initialDay]
  final bool showLiveTimeLineInAllDays;

  /// Offset of time line
  final double timeLineOffset;

  /// Width of week view. If null provided device width will be considered.
  final double? width;

  /// Height of week day title,
  final double weekTitleHeight;

  final int startTime, endTime;

  /// Builder to build week day.
  final DateWidgetBuilder? weekDayBuilder;

  /// Background color of week view page.
  final Color backgroundColor;

  /// Scroll offset of week view page.
  final double scrollOffset;

  /// Called when user taps on event tile.
  final CellTapCallback<T>? onEventTap;

  /// Show weekends or not
  ///
  /// Default value is true.
  ///
  /// If it is false week view will remove weekends from week
  /// even if weekends are added in [weekDays].
  ///
  /// ex, if [showWeekends] is false and [weekDays] are monday, tuesday,
  /// saturday and sunday, only monday and tuesday will be visible in week view.
  final bool showWeekends;

  /// Defines which days should be displayed in one week.
  ///
  /// By default all the days will be visible.
  /// Sequence will be monday to sunday.
  ///
  /// Duplicate values will be removed from list.
  ///
  /// ex, if there are two mondays in list it will display only one.
  final List<WeekDays> weekDays;

  /// This method will be called when user long press on calendar.
  final DatePressCallback? onDateLongPress;

  /// Defines the day from which the week starts.
  ///
  /// Default value is [WeekDays.monday].
  final WeekDays startDay;

  /// Defines size of the slots that provides long press callback on area
  /// where events are not there.
  final MinuteSlotSize minuteSlotSize;

  /// Main widget for week view.
  const WeekView({
    Key? key,
    this.controller,
    this.eventTileBuilder,
    this.pageTransitionDuration = const Duration(milliseconds: 300),
    this.pageTransitionCurve = Curves.ease,
    this.heightPerMinute = 1,
    this.timeLineOffset = 0,
    this.showLiveTimeLineInAllDays = false,
    this.width,
    this.minDay,
    this.maxDay,
    this.initialDay,
    this.hourIndicatorSettings,
    this.timeLineBuilder,
    this.timeLineWidth,
    this.liveTimeIndicatorSettings,
    this.onPageChange,
    this.weekPageHeaderBuilder,
    this.eventArranger,
    this.weekTitleHeight = 50,
    this.weekDayBuilder,
    this.backgroundColor = Colors.white,
    this.scrollOffset = 0.0,
    this.onEventTap,
    this.onDateLongPress,
    this.startTime=0,
    this.endTime=24,
    this.weekDays = WeekDays.values,
    this.showWeekends = true,
    this.startDay = WeekDays.monday,
    this.minuteSlotSize = MinuteSlotSize.minutes60,
  })  : assert((timeLineOffset) >= 0,
            "timeLineOffset must be greater than or equal to 0"),
        assert(width == null || width > 0,
            "Calendar width must be greater than 0."),
        assert(timeLineWidth == null || timeLineWidth > 0,
            "Time line width must be greater than 0."),
        assert(
            heightPerMinute > 0, "Height per minute must be greater than 0."),
        super(key: key);

  @override
  WeekViewState<T> createState() => WeekViewState<T>();
}

class WeekViewState<T extends Object?> extends State<WeekView<T>> {
  late double _width;
  late double _height;
  late double _timeLineWidth;
  late double _hourHeight;
  late DateTime _currentStartDate;
  late DateTime _currentEndDate;
  late DateTime _maxDate;
  late DateTime _minDate;
  late DateTime _currentWeek;
  late int _totalWeeks;
  late int _currentIndex;
  late int _startTime, _endTime;

  late EventArranger<T> _eventArranger;

  late HourIndicatorSettings _hourIndicatorSettings;
  late HourIndicatorSettings _liveTimeIndicatorSettings;

  late PageController _pageController;

  late DateWidgetBuilder _timeLineBuilder;
  late EventTileBuilder<T> _eventTileBuilder;
  late WeekPageHeaderBuilder _weekHeaderBuilder;
  late DateWidgetBuilder _weekDayBuilder;

  late double _weekTitleWidth;
  late int _totalDaysInWeek;

  late VoidCallback _reloadCallback;

  EventController<T>? _controller;

  late ScrollController _scrollController;
  late List<WeekDays> _weekDays;

  final _scrollConfiguration = EventScrollConfiguration();

  @override
  void initState() {
    super.initState();

    _reloadCallback = _reload;

    _setWeekDays();
    _setDateRange();

    _startTime = widget.startTime;
    _endTime = widget.endTime;

    _currentWeek = (widget.initialDay ?? DateTime.now()).withoutTime;

    _regulateCurrentDate();

    _calculateHeights();
    _scrollController =
        ScrollController(initialScrollOffset: widget.scrollOffset);
    _pageController = PageController(initialPage: _currentIndex);
    _eventArranger = widget.eventArranger ?? SideEventArranger<T>();

    _assignBuilders();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final newController = widget.controller ??
        CalendarControllerProvider.of<T>(context).controller;

    if (_controller != newController) {
      _controller = newController;

      _controller!
        // Removes existing callback.
        ..removeListener(_reloadCallback)

        // Reloads the view if there is any change in controller or
        // user adds new events.
        ..addListener(_reloadCallback);
    }

    _updateViewDimensions();
  }

  @override
  void didUpdateWidget(WeekView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update controller.
    final newController = widget.controller ??
        CalendarControllerProvider.of<T>(context).controller;

    if (newController != _controller) {
      _controller?.removeListener(_reloadCallback);
      _controller = newController;
      _controller?.addListener(_reloadCallback);
    }

    _setWeekDays();

    // Update date range.
    if (widget.minDay != oldWidget.minDay ||
        widget.maxDay != oldWidget.maxDay) {
      _setDateRange();
      _regulateCurrentDate();

      _pageController.jumpToPage(_currentIndex);
    }

    _eventArranger = widget.eventArranger ?? SideEventArranger<T>();

    // Update heights.
    _calculateHeights();

    _updateViewDimensions();

    // Update builders and callbacks
    _assignBuilders();
  }

  @override
  void dispose() {
    _controller?.removeListener(_reloadCallback);
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        width: _width,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: widget.backgroundColor,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _weekHeaderBuilder(_currentStartDate, _currentEndDate),
              Expanded(
                child: SizedBox(
                  height: _height,
                  width: _width,
                  child: PageView.builder(
                    itemCount: _totalWeeks,
                    controller: _pageController,
                    onPageChanged: _onPageChange,
                    itemBuilder: (_, index) {
                      final dates = _minDate
                          .add(Duration(days: index * DateTime.daysPerWeek))
                          .datesOfWeek(start: widget.startDay);

                      return ValueListenableBuilder(
                          valueListenable: _scrollConfiguration,
                          builder: (_, __, ___) => InternalWeekViewPage<T>(
                                key: ValueKey(_hourHeight.toString() +
                                    dates[0].toString()),
                                height: _height,
                                width: _width,
                                startTime: _startTime,
                                endTime: _endTime,
                                weekTitleWidth: _weekTitleWidth,
                                weekTitleHeight: widget.weekTitleHeight,
                                weekDayBuilder: _weekDayBuilder,
                                liveTimeIndicatorSettings:
                                    _liveTimeIndicatorSettings,
                                timeLineBuilder: _timeLineBuilder,
                                onTileTap: widget.onEventTap,
                                onDateLongPress: widget.onDateLongPress,
                                eventTileBuilder: _eventTileBuilder,
                                heightPerMinute: widget.heightPerMinute,
                                hourIndicatorSettings: _hourIndicatorSettings,
                                dates: dates,
                                showLiveLine:
                                    widget.showLiveTimeLineInAllDays ||
                                        _showLiveTimeIndicator(dates),
                                timeLineOffset: widget.timeLineOffset,
                                timeLineWidth: _timeLineWidth,
                                verticalLineOffset: 0,
                                showVerticalLine: true,
                                controller: controller,
                                hourHeight: _hourHeight,
                                scrollController: _scrollController,
                                eventArranger: _eventArranger,
                                weekDays: _weekDays,
                                minuteSlotSize: widget.minuteSlotSize,
                                scrollConfiguration: _scrollConfiguration,
                              ));
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Returns [EventController] associated with this Widget.
  ///
  /// This will throw [AssertionError] if controller is called before its
  /// initialization is complete.
  EventController<T> get controller {
    if (_controller == null) {
      throw "EventController is not initialized yet.";
    }

    return _controller!;
  }

  /// Reloads page.
  void _reload() {
    if (mounted) {
      setState(() {});
    }
  }

  void _setWeekDays() {
    _weekDays = widget.weekDays.toSet().toList();

    if (!widget.showWeekends) {
      _weekDays
        ..remove(WeekDays.saturday)
        ..remove(WeekDays.sunday);
    } else _weekDays.remove(WeekDays.sunday);

    assert(
        _weekDays.isNotEmpty,
        "weekDays can not be empty.\n"
        "Make sure you are providing weekdays in initialization of "
        "WeekView. or showWeekends is true if you are providing only "
        "saturday or sunday in weekDays.");
    _totalDaysInWeek = _weekDays.length;
  }

  void _updateViewDimensions() {
    _width = widget.width ?? MediaQuery.of(context).size.width;

    _timeLineWidth = widget.timeLineWidth ?? _width * 0.13;

    _liveTimeIndicatorSettings = widget.liveTimeIndicatorSettings ??
        HourIndicatorSettings(
          color: Constants.defaultLiveTimeIndicatorColor,
          height: widget.heightPerMinute,
          offset: 5,
          startTime: _startTime,
        );

    assert(_liveTimeIndicatorSettings.height < _hourHeight,
        "liveTimeIndicator height must be less than minuteHeight * 60");

    _hourIndicatorSettings = widget.hourIndicatorSettings ??
        HourIndicatorSettings(
          height: widget.heightPerMinute,
          color: Constants.defaultBorderColor,
          offset: 5,
        );

    assert(_hourIndicatorSettings.height < _hourHeight,
        "hourIndicator height must be less than minuteHeight * 60");

    _weekTitleWidth =
        (_width - _timeLineWidth - _hourIndicatorSettings.offset) /
            _totalDaysInWeek;
  }

  void _calculateHeights() {
    _hourHeight = widget.heightPerMinute * 60;
    _height = _hourHeight * (_endTime-_startTime);
  }

  void _assignBuilders() {
    _timeLineBuilder = widget.timeLineBuilder ?? _defaultTimeLineBuilder;
    _eventTileBuilder = widget.eventTileBuilder ?? _defaultEventTileBuilder;
    _weekHeaderBuilder =
        widget.weekPageHeaderBuilder ?? _defaultWeekPageHeaderBuilder;
    _weekDayBuilder = widget.weekDayBuilder ?? _defaultWeekDayBuilder;
  }

  /// Sets the current date of this month.
  ///
  /// This method is used in initState and onUpdateWidget methods to
  /// regulate current date in Month view.
  ///
  /// If maximum and minimum dates are change then first call _setDateRange
  /// and then _regulateCurrentDate method.
  ///
  void _regulateCurrentDate() {
    if (_currentWeek.isBefore(_minDate)) {
      _currentWeek = _minDate;
    } else if (_currentWeek.isAfter(_maxDate)) {
      _currentWeek = _maxDate;
    }

    _currentStartDate = _currentWeek.firstDayOfWeek(start: widget.startDay);
    _currentEndDate = _currentWeek.lastDayOfWeek(start: widget.startDay);
    _currentIndex =
        _minDate.getWeekDifference(_currentEndDate, start: widget.startDay);
  }

  /// Sets the minimum and maximum dates for current view.
  void _setDateRange() {
    _minDate = (widget.minDay ?? CalendarConstants.epochDate)
        .firstDayOfWeek(start: widget.startDay)
        .withoutTime;

    _maxDate = (widget.maxDay ?? CalendarConstants.maxDate)
        .lastDayOfWeek(start: widget.startDay)
        .withoutTime;

    assert(
      _minDate.isBefore(_maxDate),
      "Minimum date must be less than maximum date.\n"
      "Provided minimum date: $_minDate, maximum date: $_maxDate",
    );

    _totalWeeks =
        _minDate.getWeekDifference(_maxDate, start: widget.startDay) + 1;
  }

  /// Default builder for week line.
  Widget _defaultWeekDayBuilder(DateTime date) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(Constants.weekTitles[date.weekday - 1]),
          Text(date.day.toString()),
        ],
      ),
    );
  }

  /// Default timeline builder this builder will be used if
  /// [widget.eventTileBuilder] is null
  ///
  Widget _defaultTimeLineBuilder(DateTime date) {
    return Transform.translate(
      offset: Offset(0, -7.5),
      child: Padding(
        padding: const EdgeInsets.only(right: 7.0),
        child: Text(
          "${date.hour < 10 ? "0" : ""}${date.hour}:00 ",
          textAlign: TextAlign.right,
          style: TextStyle(
            fontSize: 15.0,
          ),
        ),
      ),
    );
  }

  /// Default timeline builder. This builder will be used if
  /// [widget.eventTileBuilder] is null
  Widget _defaultEventTileBuilder(
      DateTime date,
      List<CalendarEventData<T>> events,
      Rect boundary,
      DateTime startDuration,
      DateTime endDuration) {
    if (events.isNotEmpty)
      return RoundedEventTile(
        borderRadius: BorderRadius.circular(6.0),
        title: events[0].title,
        titleStyle: TextStyle(
          fontSize: 12,
          color: events[0].color.accent,
        ),
        totalEvents: events.length,
        padding: EdgeInsets.all(7.0),
        backgroundColor: events[0].color,
      );
    else
      return Container();
  }

  /// Default view header builder. This builder will be used if
  /// [widget.dayTitleBuilder] is null.
  Widget _defaultWeekPageHeaderBuilder(DateTime startDate, DateTime endDate) {
    return WeekPageHeader(
      startDate: _currentStartDate,
      endDate: _currentEndDate,
      onNextDay: nextPage,
      onPreviousDay: previousPage,
      onTitleTapped: () async {
        final selectedDate = await showDatePicker(
          context: context,
          initialDate: startDate,
          firstDate: _minDate,
          lastDate: _maxDate,
        );

        if (selectedDate == null) return;
        jumpToWeek(selectedDate);
      },
    );
  }

  /// Called when user change page using any gesture or inbuilt functions.
  void _onPageChange(int index) {
    if (mounted) {
      setState(() {
        _currentStartDate = DateTime(
          _currentStartDate.year,
          _currentStartDate.month,
          _currentStartDate.day + (index - _currentIndex) * 7,
        );
        _currentEndDate = _currentStartDate.add(Duration(days: 6));
        _currentIndex = index;
      });
    }
    widget.onPageChange?.call(_currentStartDate, _currentIndex);
  }

  /// Animate to next page
  ///
  /// Arguments [duration] and [curve] will override default values provided
  /// as [DayView.pageTransitionDuration] and [DayView.pageTransitionCurve]
  /// respectively.
  void nextPage({Duration? duration, Curve? curve}) {
    _pageController.nextPage(
      duration: duration ?? widget.pageTransitionDuration,
      curve: curve ?? widget.pageTransitionCurve,
    );
  }

  /// Animate to previous page
  ///
  /// Arguments [duration] and [curve] will override default values provided
  /// as [DayView.pageTransitionDuration] and [DayView.pageTransitionCurve]
  /// respectively.
  void previousPage({Duration? duration, Curve? curve}) {
    _pageController.previousPage(
      duration: duration ?? widget.pageTransitionDuration,
      curve: curve ?? widget.pageTransitionCurve,
    );
  }

  /// Jumps to page number [page]
  ///
  ///
  void jumpToPage(int page) => _pageController.jumpToPage(page);

  /// Animate to page number [page].
  ///
  /// Arguments [duration] and [curve] will override default values provided
  /// as [DayView.pageTransitionDuration] and [DayView.pageTransitionCurve]
  /// respectively.
  Future<void> animateToPage(int page,
      {Duration? duration, Curve? curve}) async {
    await _pageController.animateToPage(page,
        duration: duration ?? widget.pageTransitionDuration,
        curve: curve ?? widget.pageTransitionCurve);
  }

  /// Returns current page number.
  int get currentPage => _currentIndex;

  /// Jumps to page which gives day calendar for [week]
  void jumpToWeek(DateTime week) {
    if (week.isBefore(_minDate) || week.isAfter(_maxDate)) {
      throw "Invalid date selected.";
    }
    _pageController
        .jumpToPage(_minDate.getWeekDifference(week, start: widget.startDay));
  }

  /// Animate to page which gives day calendar for [week].
  ///
  /// Arguments [duration] and [curve] will override default values provided
  /// as [WeekView.pageTransitionDuration] and [WeekView.pageTransitionCurve]
  /// respectively.
  Future<void> animateToWeek(DateTime week,
      {Duration? duration, Curve? curve}) async {
    if (week.isBefore(_minDate) || week.isAfter(_maxDate)) {
      throw "Invalid date selected.";
    }
    await _pageController.animateToPage(
      _minDate.getWeekDifference(week, start: widget.startDay),
      duration: duration ?? widget.pageTransitionDuration,
      curve: curve ?? widget.pageTransitionCurve,
    );
  }

  /// Returns the current visible week's first date.
  DateTime get currentDate => DateTime(
      _currentStartDate.year, _currentStartDate.month, _currentStartDate.day);

  /// Jumps to page which contains given events and make event
  /// tile visible to user.
  ///
  Future<void> jumpToEvent(CalendarEventData<T> event) async {
    jumpToWeek(event.date);

    await _scrollConfiguration.setScrollEvent(
      event: event,
      duration: Duration.zero,
      curve: Curves.ease,
    );
  }

  /// Animate to page which contains given events and make event
  /// tile visible to user.
  ///
  /// Arguments [duration] and [curve] will override default values provided
  /// as [DayView.pageTransitionDuration] and [DayView.pageTransitionCurve]
  /// respectively.
  ///
  /// Actual duration will be 2 times the given duration.
  ///
  /// Ex, If provided duration is 200 milliseconds then this function will take
  /// 200 milliseconds for animate to page then 200 milliseconds for
  /// scroll to event tile.
  ///
  ///
  Future<void> animateToEvent(CalendarEventData<T> event,
      {Duration? duration, Curve? curve}) async {
    await animateToWeek(event.date, duration: duration, curve: curve);
    await _scrollConfiguration.setScrollEvent(
      event: event,
      duration: duration ?? widget.pageTransitionDuration,
      curve: curve ?? widget.pageTransitionCurve,
    );
  }

  /// check if any dates contains current date or not.
  /// Returns true if it does else false.
  bool _showLiveTimeIndicator(List<DateTime> dates) =>
      dates.any((date) => date.compareWithoutTime(DateTime.now()));
}
