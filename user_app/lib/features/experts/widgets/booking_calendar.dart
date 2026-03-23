import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/translation/translation_extensions.dart';
import '../../../data/models/expert_model.dart';

/// Booking calendar widget for selecting date and time slots.
///
/// Displays a horizontal scrollable date picker filtered by the expert's
/// available days, plus a grid of time slots for the selected date.
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

  /// Set of weekday numbers the expert is available (1=Mon, 7=Sun).
  /// If empty, all weekdays Mon-Sat are considered available.
  final Set<int> availableWeekdays;

  const BookingCalendar({
    super.key,
    required this.expertId,
    this.selectedDate,
    this.selectedTimeSlot,
    this.timeSlots = const [],
    required this.onDateSelected,
    required this.onTimeSlotSelected,
    this.isLoading = false,
    this.availableWeekdays = const {1, 2, 3, 4, 5, 6},
  });

  @override
  State<BookingCalendar> createState() => _BookingCalendarState();
}

class _BookingCalendarState extends State<BookingCalendar> {
  late List<DateTime> _availableDates;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _buildAvailableDates();
  }

  @override
  void didUpdateWidget(covariant BookingCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.availableWeekdays != widget.availableWeekdays) {
      _buildAvailableDates();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Build the list of selectable dates (next 30 days, filtered by available weekdays).
  void _buildAvailableDates() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final effectiveWeekdays = widget.availableWeekdays.isNotEmpty
        ? widget.availableWeekdays
        : {1, 2, 3, 4, 5, 6};

    _availableDates = [];
    for (int i = 0; i <= 30; i++) {
      final date = today.add(Duration(days: i));
      if (effectiveWeekdays.contains(date.weekday)) {
        _availableDates.add(date);
      }
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date selection
        _buildDateSection(context),
        const SizedBox(height: 16),

        // Time slots
        if (widget.selectedDate != null) _buildTimeSlotsSection(context),
      ],
    );
  }

  Widget _buildDateSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Select Date'.tr(context),
                style: AppTextStyles.labelLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (_availableDates.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'No available dates in the next 30 days'.tr(context),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
            )
          else
            SizedBox(
              height: 76,
              child: ListView.separated(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                itemCount: _availableDates.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final date = _availableDates[index];
                  final isSelected = widget.selectedDate != null &&
                      _isSameDay(date, widget.selectedDate!);
                  final isToday = _isSameDay(date, DateTime.now());

                  return _DateChip(
                    date: date,
                    isSelected: isSelected,
                    isToday: isToday,
                    onTap: () => widget.onDateSelected(date),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTimeSlotsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.access_time, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${'Available Times for'.tr(context)} ${DateFormat('EEEE, MMM d').format(widget.selectedDate!)}',
                  style: AppTextStyles.labelLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (widget.isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else if (widget.timeSlots.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'No available time slots for this date'.tr(context),
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
        ],
      ),
    );
  }
}

/// Date chip for horizontal date picker.
class _DateChip extends StatelessWidget {
  final DateTime date;
  final bool isSelected;
  final bool isToday;
  final VoidCallback onTap;

  const _DateChip({
    required this.date,
    required this.isSelected,
    required this.isToday,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dayName = DateFormat('E').format(date).substring(0, 3);
    final dayNumber = date.day.toString();

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 52,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : isToday
                    ? AppColors.primary
                    : AppColors.border,
            width: isSelected || isToday ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              dayName,
              style: AppTextStyles.caption.copyWith(
                color: isSelected
                    ? Colors.white.withAlpha(200)
                    : AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              dayNumber,
              style: AppTextStyles.labelLarge.copyWith(
                color: isSelected ? Colors.white : AppColors.textPrimary,
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : isAvailable
                  ? Colors.white
                  : AppColors.surfaceVariant.withAlpha(128),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
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
