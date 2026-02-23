import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/expert_model.dart';
import '../../../shared/widgets/glass_container.dart';

/// Booking calendar widget for selecting date and time slots.
///
/// Displays a week view calendar with selectable dates and time slots
/// for booking expert consultations.
class BookingCalendar extends StatefulWidget {
  /// Expert ID for fetching availability.
  final String expertId;

  /// Currently selected date.
  final DateTime? selectedDate;

  /// Currently selected time slot.
  final ExpertTimeSlot? selectedTimeSlot;

  /// Available time slots for the selected date.
  final List<ExpertTimeSlot> timeSlots;

  /// Called when a date is selected.
  final ValueChanged<DateTime> onDateSelected;

  /// Called when a time slot is selected.
  final ValueChanged<ExpertTimeSlot> onTimeSlotSelected;

  /// Whether the calendar is loading.
  final bool isLoading;

  const BookingCalendar({
    super.key,
    required this.expertId,
    this.selectedDate,
    this.selectedTimeSlot,
    this.timeSlots = const [],
    required this.onDateSelected,
    required this.onTimeSlotSelected,
    this.isLoading = false,
  });

  @override
  State<BookingCalendar> createState() => _BookingCalendarState();
}

class _BookingCalendarState extends State<BookingCalendar> {
  late DateTime _currentWeekStart;
  late DateTime _today;

  @override
  void initState() {
    super.initState();
    _today = DateTime.now();
    _currentWeekStart = _getWeekStart(_today);
  }

  DateTime _getWeekStart(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  void _goToPreviousWeek() {
    final previousWeek = _currentWeekStart.subtract(const Duration(days: 7));
    if (!previousWeek.isBefore(_getWeekStart(_today))) {
      setState(() {
        _currentWeekStart = previousWeek;
      });
    }
  }

  void _goToNextWeek() {
    final maxDate = _today.add(const Duration(days: 30));
    final nextWeek = _currentWeekStart.add(const Duration(days: 7));
    if (nextWeek.isBefore(maxDate)) {
      setState(() {
        _currentWeekStart = nextWeek;
      });
    }
  }

  bool _isDateSelectable(DateTime date) {
    final now = DateTime.now();
    final maxDate = now.add(const Duration(days: 30));
    return !date.isBefore(DateTime(now.year, now.month, now.day)) &&
        date.isBefore(maxDate) &&
        date.weekday != 7; // Exclude Sundays
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date selection header
        GlassCard(
          blur: 10,
          opacity: 0.8,
          padding: const EdgeInsets.all(16),
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Select Date',
                    style: AppTextStyles.labelLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Week navigation
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: _currentWeekStart
                            .isAfter(_getWeekStart(_today))
                        ? _goToPreviousWeek
                        : null,
                    icon: Icon(
                      Icons.chevron_left,
                      color: _currentWeekStart.isAfter(_getWeekStart(_today))
                          ? AppColors.textPrimary
                          : AppColors.textTertiary,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  ),
                  Text(
                    _getMonthYearString(),
                    style: AppTextStyles.labelMedium.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  IconButton(
                    onPressed: _goToNextWeek,
                    icon: const Icon(Icons.chevron_right),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Week days
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(7, (index) {
                  final date = _currentWeekStart.add(Duration(days: index));
                  final isSelected = widget.selectedDate != null &&
                      _isSameDay(date, widget.selectedDate!);
                  final isToday = _isSameDay(date, _today);
                  final isSelectable = _isDateSelectable(date);

                  return _DateCell(
                    date: date,
                    isSelected: isSelected,
                    isToday: isToday,
                    isSelectable: isSelectable,
                    onTap: isSelectable
                        ? () => widget.onDateSelected(date)
                        : null,
                  );
                }),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Time slots
        if (widget.selectedDate != null) ...[
          GlassCard(
            blur: 10,
            opacity: 0.8,
            padding: const EdgeInsets.all(16),
            borderRadius: BorderRadius.circular(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Available Times for ${DateFormat('EEEE, MMM d').format(widget.selectedDate!)}',
                      style: AppTextStyles.labelLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                if (widget.isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                  )
                else if (widget.timeSlots.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'No available time slots for this date',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),
                  )
                else
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: widget.timeSlots.map((slot) {
                      final isSelected = widget.selectedTimeSlot?.id == slot.id;
                      return _TimeSlotChip(
                        slot: slot,
                        isSelected: isSelected,
                        onTap: slot.available
                            ? () => widget.onTimeSlotSelected(slot)
                            : null,
                      );
                    }).toList(),
                  ),

                const SizedBox(height: 12),
                Text(
                  'Session duration: 60 minutes',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],

        // Selection summary
        if (widget.selectedDate != null && widget.selectedTimeSlot != null) ...[
          const SizedBox(height: 16),
          GlassCard(
            blur: 10,
            opacity: 0.9,
            padding: const EdgeInsets.all(16),
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withAlpha(20),
                Colors.white.withAlpha(200),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selected Session',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('EEEE, MMMM d, yyyy')
                            .format(widget.selectedDate!),
                        style: AppTextStyles.labelLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${widget.selectedTimeSlot!.displayTime} (60 min)',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withAlpha(30),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Available',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  String _getMonthYearString() {
    final weekEnd = _currentWeekStart.add(const Duration(days: 6));
    if (_currentWeekStart.month == weekEnd.month) {
      return DateFormat('MMMM yyyy').format(_currentWeekStart);
    }
    return '${DateFormat('MMM').format(_currentWeekStart)} - ${DateFormat('MMM yyyy').format(weekEnd)}';
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

/// Date cell widget for the calendar.
class _DateCell extends StatelessWidget {
  final DateTime date;
  final bool isSelected;
  final bool isToday;
  final bool isSelectable;
  final VoidCallback? onTap;

  const _DateCell({
    required this.date,
    required this.isSelected,
    required this.isToday,
    required this.isSelectable,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dayName = DateFormat('E').format(date).substring(0, 2);
    final dayNumber = date.day.toString();

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 42,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.darkBrown
              : isToday
                  ? AppColors.surfaceVariant
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isToday && !isSelected
              ? Border.all(color: AppColors.primary, width: 1.5)
              : null,
        ),
        child: Column(
          children: [
            Text(
              dayName,
              style: AppTextStyles.caption.copyWith(
                color: isSelected
                    ? Colors.white.withAlpha(180)
                    : isSelectable
                        ? AppColors.textSecondary
                        : AppColors.textTertiary,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              dayNumber,
              style: AppTextStyles.labelMedium.copyWith(
                color: isSelected
                    ? Colors.white
                    : isSelectable
                        ? AppColors.textPrimary
                        : AppColors.textTertiary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Time slot chip widget.
class _TimeSlotChip extends StatelessWidget {
  final ExpertTimeSlot slot;
  final bool isSelected;
  final VoidCallback? onTap;

  const _TimeSlotChip({
    required this.slot,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isAvailable = slot.available;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.darkBrown
              : isAvailable
                  ? Colors.white
                  : AppColors.surfaceVariant.withAlpha(128),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? AppColors.darkBrown
                : isAvailable
                    ? AppColors.border
                    : AppColors.border.withAlpha(50),
          ),
        ),
        child: Text(
          slot.displayTime,
          style: AppTextStyles.labelSmall.copyWith(
            color: isSelected
                ? Colors.white
                : isAvailable
                    ? AppColors.textPrimary
                    : AppColors.textTertiary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
