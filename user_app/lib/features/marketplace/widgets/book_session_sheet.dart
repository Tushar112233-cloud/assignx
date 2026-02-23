import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/tutor_model.dart';

/// Bottom sheet for booking a session with a tutor.
///
/// Features:
/// - Calendar widget for date selection
/// - Time slot selection (morning, afternoon, evening)
/// - Session type selection (1-on-1, Group)
/// - Session duration selection
/// - Topic/subject input
/// - Price display
/// - Notes field
/// - Book button with payment integration
class BookSessionSheet extends StatefulWidget {
  /// The tutor to book with.
  final Tutor tutor;

  /// Callback when booking is successful.
  final void Function(BookedSession session)? onBookingComplete;

  const BookSessionSheet({
    super.key,
    required this.tutor,
    this.onBookingComplete,
  });

  /// Show the book session sheet as a modal bottom sheet.
  static Future<void> show({
    required BuildContext context,
    required Tutor tutor,
    void Function(BookedSession session)? onBookingComplete,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BookSessionSheet(
        tutor: tutor,
        onBookingComplete: onBookingComplete,
      ),
    );
  }

  @override
  State<BookSessionSheet> createState() => _BookSessionSheetState();
}

class _BookSessionSheetState extends State<BookSessionSheet> {
  // Form state
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDate;
  String? _selectedTimeSlot;
  SessionType _sessionType = SessionType.oneOnOne;
  SessionDuration _duration = SessionDuration.oneHour;
  String? _selectedSubject;
  final TextEditingController _topicController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  bool _isSubmitting = false;

  // Available time slots
  final List<TimeSlot> _timeSlots = [
    const TimeSlot(id: '09:00', time: '9:00 AM', period: 'morning'),
    const TimeSlot(id: '10:00', time: '10:00 AM', period: 'morning'),
    const TimeSlot(id: '11:00', time: '11:00 AM', period: 'morning'),
    const TimeSlot(id: '12:00', time: '12:00 PM', period: 'afternoon'),
    const TimeSlot(id: '13:00', time: '1:00 PM', period: 'afternoon'),
    const TimeSlot(id: '14:00', time: '2:00 PM', period: 'afternoon'),
    const TimeSlot(id: '15:00', time: '3:00 PM', period: 'afternoon'),
    const TimeSlot(id: '16:00', time: '4:00 PM', period: 'evening'),
    const TimeSlot(id: '17:00', time: '5:00 PM', period: 'evening'),
    const TimeSlot(id: '18:00', time: '6:00 PM', period: 'evening'),
    const TimeSlot(id: '19:00', time: '7:00 PM', period: 'evening'),
    const TimeSlot(id: '20:00', time: '8:00 PM', period: 'evening'),
  ];

  @override
  void dispose() {
    _topicController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  /// Calculate total price based on duration and session type.
  double get _totalPrice {
    double basePrice = widget.tutor.hourlyRate * _duration.multiplier;
    if (_sessionType == SessionType.group) {
      basePrice *= 0.6; // 40% discount for group sessions
    }
    return basePrice;
  }

  /// Check if booking can be submitted.
  bool get _canSubmit =>
      _selectedDate != null && _selectedTimeSlot != null && !_isSubmitting;

  /// Handle booking submission.
  Future<void> _handleSubmit() async {
    if (!_canSubmit) return;

    setState(() => _isSubmitting = true);

    try {
      // Create the booked session
      final session = BookedSession(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        tutorId: widget.tutor.id,
        studentId: '', // Would be filled from auth
        date: _selectedDate!,
        timeSlot: _selectedTimeSlot!,
        sessionType: _sessionType,
        duration: _duration,
        topic: _selectedSubject ?? _topicController.text,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        totalPrice: _totalPrice,
        createdAt: DateTime.now(),
      );

      // TODO: Call API to book session

      // Show success message
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Session booked successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        widget.onBookingComplete?.call(session);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to book session: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppSpacing.radiusXl),
            ),
          ),
          child: Column(
            children: [
              // Drag handle
              _buildDragHandle(),

              // Header
              _buildHeader(),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Calendar
                      _buildSectionTitle('Select Date', Icons.calendar_today),
                      _buildCalendar(),
                      const SizedBox(height: AppSpacing.lg),

                      // Time slots
                      if (_selectedDate != null) ...[
                        _buildSectionTitle('Select Time', Icons.access_time),
                        _buildTimeSlots(),
                        const SizedBox(height: AppSpacing.lg),
                      ],

                      // Session type
                      _buildSectionTitle('Session Type', Icons.people_outline),
                      _buildSessionTypeSelector(),
                      const SizedBox(height: AppSpacing.lg),

                      // Duration
                      _buildSectionTitle('Duration', Icons.timer_outlined),
                      _buildDurationSelector(),
                      const SizedBox(height: AppSpacing.lg),

                      // Subject/Topic
                      _buildSectionTitle('Subject', Icons.subject),
                      _buildSubjectSelector(),
                      const SizedBox(height: AppSpacing.md),

                      // Custom topic input
                      TextField(
                        controller: _topicController,
                        decoration: InputDecoration(
                          hintText: 'Or enter a specific topic...',
                          filled: true,
                          fillColor: AppColors.surfaceVariant,
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusMd),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Notes
                      _buildSectionTitle('Notes (Optional)', Icons.note_outlined),
                      TextField(
                        controller: _notesController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText:
                              'What would you like to focus on in this session?',
                          filled: true,
                          fillColor: AppColors.surfaceVariant,
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusMd),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Price summary
                      _buildPriceSummary(),

                      // Bottom spacing
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),

              // Bottom button
              _buildBottomButton(),
            ],
          ),
        );
      },
    );
  }

  /// Build the drag handle.
  Widget _buildDragHandle() {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.border,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  /// Build the header with tutor info.
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        children: [
          // Tutor avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              color: AppColors.primaryLight.withAlpha(50),
            ),
            child: widget.tutor.avatar != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    child: Image.network(
                      widget.tutor.avatar!,
                      fit: BoxFit.cover,
                    ),
                  )
                : Center(
                    child: Text(
                      widget.tutor.initials,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: AppSpacing.sm),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Book a Session',
                  style: AppTextStyles.headingSmall,
                ),
                Text(
                  'with ${widget.tutor.name}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Close button
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.surfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  /// Build section title with icon.
  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: AppTextStyles.labelLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Build the calendar widget.
  Widget _buildCalendar() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: TableCalendar(
        firstDay: DateTime.now(),
        lastDay: DateTime.now().add(const Duration(days: 90)),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDate = selectedDay;
            _focusedDay = focusedDay;
            _selectedTimeSlot = null; // Reset time slot
          });
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
        calendarFormat: CalendarFormat.month,
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: AppTextStyles.labelLarge,
          leftChevronIcon: const Icon(
            Icons.chevron_left,
            color: AppColors.textSecondary,
          ),
          rightChevronIcon: const Icon(
            Icons.chevron_right,
            color: AppColors.textSecondary,
          ),
        ),
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: AppColors.primary.withAlpha(30),
            shape: BoxShape.circle,
          ),
          todayTextStyle: AppTextStyles.labelMedium.copyWith(
            color: AppColors.primary,
          ),
          selectedDecoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          selectedTextStyle: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textOnPrimary,
          ),
          weekendTextStyle: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textSecondary,
          ),
          disabledTextStyle: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textTertiary,
          ),
          outsideTextStyle: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: AppTextStyles.caption.copyWith(
            fontWeight: FontWeight.w600,
          ),
          weekendStyle: AppTextStyles.caption.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        enabledDayPredicate: (day) {
          // Disable past dates
          return day.isAfter(DateTime.now().subtract(const Duration(days: 1)));
        },
      ),
    );
  }

  /// Build time slot selector grouped by period.
  Widget _buildTimeSlots() {
    final morningSlots =
        _timeSlots.where((s) => s.period == 'morning').toList();
    final afternoonSlots =
        _timeSlots.where((s) => s.period == 'afternoon').toList();
    final eveningSlots =
        _timeSlots.where((s) => s.period == 'evening').toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Morning slots
        _buildTimePeriod('Morning', morningSlots),
        const SizedBox(height: AppSpacing.sm),

        // Afternoon slots
        _buildTimePeriod('Afternoon', afternoonSlots),
        const SizedBox(height: AppSpacing.sm),

        // Evening slots
        _buildTimePeriod('Evening', eveningSlots),
      ],
    );
  }

  /// Build time period section.
  Widget _buildTimePeriod(String label, List<TimeSlot> slots) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: slots.map((slot) {
            final isSelected = _selectedTimeSlot == slot.id;
            return GestureDetector(
              onTap: slot.isAvailable
                  ? () => setState(() => _selectedTimeSlot = slot.id)
                  : null,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : slot.isAvailable
                          ? AppColors.surfaceVariant
                          : AppColors.surfaceVariant.withAlpha(100),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : slot.isAvailable
                            ? AppColors.border
                            : AppColors.border.withAlpha(100),
                  ),
                ),
                child: Text(
                  slot.time,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: isSelected
                        ? AppColors.textOnPrimary
                        : slot.isAvailable
                            ? AppColors.textPrimary
                            : AppColors.textTertiary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// Build session type selector.
  Widget _buildSessionTypeSelector() {
    return Row(
      children: SessionType.values.map((type) {
        final isSelected = _sessionType == type;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _sessionType = type),
            child: Container(
              margin: EdgeInsets.only(
                right: type != SessionType.values.last ? AppSpacing.sm : 0,
              ),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withAlpha(15)
                    : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    type == SessionType.oneOnOne
                        ? Icons.person
                        : Icons.groups,
                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    type.displayName,
                    style: AppTextStyles.labelMedium.copyWith(
                      color:
                          isSelected ? AppColors.primary : AppColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                  if (type == SessionType.group)
                    Text(
                      '40% off',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.success,
                        fontSize: 10,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Build duration selector.
  Widget _buildDurationSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: SessionDuration.values.map((dur) {
          final isSelected = _duration == dur;
          final price = widget.tutor.hourlyRate * dur.multiplier;
          return GestureDetector(
            onTap: () => setState(() => _duration = dur),
            child: Container(
              margin: const EdgeInsets.only(right: AppSpacing.sm),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withAlpha(15)
                    : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    dur.displayName,
                    style: AppTextStyles.labelMedium.copyWith(
                      color:
                          isSelected ? AppColors.primary : AppColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '\u20B9${price.toStringAsFixed(0)}',
                    style: AppTextStyles.caption.copyWith(
                      color:
                          isSelected ? AppColors.primary : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Build subject selector from tutor's subjects.
  Widget _buildSubjectSelector() {
    if (widget.tutor.subjects.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: widget.tutor.subjects.map((subject) {
        final isSelected = _selectedSubject == subject;
        return GestureDetector(
          onTap: () => setState(() {
            _selectedSubject = isSelected ? null : subject;
          }),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary
                  : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
              ),
            ),
            child: Text(
              subject,
              style: AppTextStyles.labelSmall.copyWith(
                color: isSelected
                    ? AppColors.textOnPrimary
                    : AppColors.textPrimary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Build price summary section.
  Widget _buildPriceSummary() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Column(
        children: [
          // Session rate
          _buildSummaryRow(
            'Session Rate',
            '\u20B9${widget.tutor.hourlyRate.toStringAsFixed(0)}/hour',
          ),
          const SizedBox(height: 8),

          // Duration
          _buildSummaryRow(
            'Duration',
            _duration.displayName,
          ),
          const SizedBox(height: 8),

          // Session type discount
          if (_sessionType == SessionType.group) ...[
            _buildSummaryRow(
              'Group Discount',
              '-40%',
              isDiscount: true,
            ),
            const SizedBox(height: 8),
          ],

          // Date and time
          if (_selectedDate != null && _selectedTimeSlot != null) ...[
            _buildSummaryRow(
              'Date & Time',
              '${DateFormat('EEE, MMM d').format(_selectedDate!)} at ${_timeSlots.firstWhere((s) => s.id == _selectedTimeSlot).time}',
            ),
            const SizedBox(height: 8),
          ],

          const Divider(),
          const SizedBox(height: 8),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: AppTextStyles.labelLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '\u20B9${_totalPrice.toStringAsFixed(0)}',
                style: AppTextStyles.headingSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build summary row helper.
  Widget _buildSummaryRow(String label, String value, {bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.labelMedium.copyWith(
            color: isDiscount ? AppColors.success : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  /// Build the fixed bottom button.
  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(
          top: BorderSide(color: AppColors.border),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _canSubmit ? _handleSubmit : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              elevation: 0,
              disabledBackgroundColor: AppColors.border,
            ),
            child: _isSubmitting
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.textOnPrimary),
                    ),
                  )
                : Text(
                    _canSubmit
                        ? 'Confirm Booking - \u20B9${_totalPrice.toStringAsFixed(0)}'
                        : 'Select date and time',
                    style: AppTextStyles.buttonLarge,
                  ),
          ),
        ),
      ),
    );
  }
}
