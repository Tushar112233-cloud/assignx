import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/expert_model.dart';
import '../../../providers/experts_provider.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/skeleton_loader.dart';
import '../widgets/booking_calendar.dart';
import '../widgets/price_breakdown.dart';

/// Booking screen for scheduling expert consultations.
///
/// Allows users to select a date, time slot, session type, and
/// view the price before confirming a booking.
class BookingScreen extends ConsumerStatefulWidget {
  /// Expert ID to book with.
  final String expertId;

  const BookingScreen({
    super.key,
    required this.expertId,
  });

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  DateTime? _selectedDate;
  ExpertTimeSlot? _selectedTimeSlot;
  ExpertSessionType _selectedSessionType = ExpertSessionType.oneHour;
  String? _topic;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final expertAsync = ref.watch(expertDetailProvider(widget.expertId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(200),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        title: Text(
          'Book Session',
          style: AppTextStyles.headingSmall.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: expertAsync.when(
        data: (expert) {
          if (expert == null) {
            return const Center(child: Text('Expert not found'));
          }

          return _BookingContent(
            expert: expert,
            selectedDate: _selectedDate,
            selectedTimeSlot: _selectedTimeSlot,
            selectedSessionType: _selectedSessionType,
            topic: _topic,
            onDateSelected: (date) {
              setState(() {
                _selectedDate = date;
                _selectedTimeSlot = null;
              });
            },
            onTimeSlotSelected: (slot) {
              setState(() {
                _selectedTimeSlot = slot;
              });
            },
            onSessionTypeChanged: (type) {
              setState(() {
                _selectedSessionType = type;
              });
            },
            onTopicChanged: (topic) {
              setState(() {
                _topic = topic;
              });
            },
          );
        },
        loading: () => const _LoadingSkeleton(),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              Text('Failed to load expert', style: AppTextStyles.bodyMedium),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    ref.invalidate(expertDetailProvider(widget.expertId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: expertAsync.whenData(
        (expert) {
          if (expert == null) return const SizedBox.shrink();
          return _BookingBar(
            expert: expert,
            selectedDate: _selectedDate,
            selectedTimeSlot: _selectedTimeSlot,
            selectedSessionType: _selectedSessionType,
            isLoading: _isLoading,
            onConfirm: () => _confirmBooking(expert),
          );
        },
      ).valueOrNull,
    );
  }

  Future<void> _confirmBooking(Expert expert) async {
    if (_selectedDate == null || _selectedTimeSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a date and time'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        // Show success dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => _SuccessDialog(
            expert: expert,
            date: _selectedDate!,
            timeSlot: _selectedTimeSlot!,
            sessionType: _selectedSessionType,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

/// Main booking content.
class _BookingContent extends ConsumerWidget {
  final Expert expert;
  final DateTime? selectedDate;
  final ExpertTimeSlot? selectedTimeSlot;
  final ExpertSessionType selectedSessionType;
  final String? topic;
  final ValueChanged<DateTime> onDateSelected;
  final ValueChanged<ExpertTimeSlot> onTimeSlotSelected;
  final ValueChanged<ExpertSessionType> onSessionTypeChanged;
  final ValueChanged<String?> onTopicChanged;

  const _BookingContent({
    required this.expert,
    required this.selectedDate,
    required this.selectedTimeSlot,
    required this.selectedSessionType,
    required this.topic,
    required this.onDateSelected,
    required this.onTimeSlotSelected,
    required this.onSessionTypeChanged,
    required this.onTopicChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slotsAsync = selectedDate != null
        ? ref.watch(availableSlotsProvider(
            (expertId: expert.id, date: selectedDate!)))
        : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Expert info card
          _ExpertInfoCard(expert: expert),
          const SizedBox(height: 20),

          // Calendar
          BookingCalendar(
            expertId: expert.id,
            selectedDate: selectedDate,
            selectedTimeSlot: selectedTimeSlot,
            timeSlots: slotsAsync?.valueOrNull ?? [],
            onDateSelected: onDateSelected,
            onTimeSlotSelected: onTimeSlotSelected,
            isLoading: slotsAsync?.isLoading ?? false,
          ),
          const SizedBox(height: 20),

          // Session type selector
          _SessionTypeSelector(
            selectedType: selectedSessionType,
            pricePerSession: expert.pricePerSession,
            onTypeChanged: onSessionTypeChanged,
          ),
          const SizedBox(height: 20),

          // Topic input
          _TopicInput(
            topic: topic,
            onChanged: onTopicChanged,
          ),
          const SizedBox(height: 20),

          // Price breakdown
          if (selectedDate != null && selectedTimeSlot != null)
            PriceBreakdown(
              basePrice: expert.pricePerSession * selectedSessionType.priceMultiplier,
              platformFeePercent: 5.0,
              taxPercent: 18.0,
              initiallyExpanded: false,
            ),

          // Bottom padding
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

/// Expert info card.
class _ExpertInfoCard extends StatelessWidget {
  final Expert expert;

  const _ExpertInfoCard({required this.expert});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      blur: 10,
      opacity: 0.8,
      padding: const EdgeInsets.all(14),
      borderRadius: BorderRadius.circular(16),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(20),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.primaryLight.withAlpha(50),
              backgroundImage:
                  expert.avatar != null ? NetworkImage(expert.avatar!) : null,
              child: expert.avatar == null
                  ? Text(
                      expert.initials,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        expert.name,
                        style: AppTextStyles.labelLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (expert.verified) ...[
                      const SizedBox(width: 4),
                      Icon(
                        Icons.verified,
                        size: 16,
                        color: AppColors.success,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  expert.designation,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.star, size: 14, color: AppColors.warning),
                    const SizedBox(width: 4),
                    Text(
                      expert.ratingString,
                      style: AppTextStyles.labelSmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      ' (${expert.reviewCount})',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Session type selector.
class _SessionTypeSelector extends StatelessWidget {
  final ExpertSessionType selectedType;
  final double pricePerSession;
  final ValueChanged<ExpertSessionType> onTypeChanged;

  const _SessionTypeSelector({
    required this.selectedType,
    required this.pricePerSession,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.timer, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              'Session Duration',
              style: AppTextStyles.labelLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...ExpertSessionType.values.map((type) {
          final isSelected = selectedType == type;
          final price = pricePerSession * type.priceMultiplier;

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GestureDetector(
              onTap: () => onTypeChanged(type),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withAlpha(20)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? AppColors.primary
                            : Colors.transparent,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textTertiary,
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              size: 14,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        type.displayName,
                        style: AppTextStyles.labelMedium.copyWith(
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      '\u20B9${price.toStringAsFixed(0)}',
                      style: AppTextStyles.labelLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

/// Topic input.
class _TopicInput extends StatelessWidget {
  final String? topic;
  final ValueChanged<String?> onChanged;

  const _TopicInput({
    required this.topic,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.topic, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              'Topic (Optional)',
              style: AppTextStyles.labelLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GlassCard(
          blur: 10,
          opacity: 0.8,
          padding: EdgeInsets.zero,
          borderRadius: BorderRadius.circular(14),
          child: TextField(
            onChanged: onChanged,
            maxLines: 3,
            style: AppTextStyles.bodyMedium,
            decoration: InputDecoration(
              hintText: 'What would you like to discuss?',
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textTertiary,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }
}

/// Bottom booking bar.
class _BookingBar extends StatelessWidget {
  final Expert expert;
  final DateTime? selectedDate;
  final ExpertTimeSlot? selectedTimeSlot;
  final ExpertSessionType selectedSessionType;
  final bool isLoading;
  final VoidCallback onConfirm;

  const _BookingBar({
    required this.expert,
    required this.selectedDate,
    required this.selectedTimeSlot,
    required this.selectedSessionType,
    required this.isLoading,
    required this.onConfirm,
  });

  bool get _canBook => selectedDate != null && selectedTimeSlot != null;

  @override
  Widget build(BuildContext context) {
    final totalPrice = expert.pricePerSession * selectedSessionType.priceMultiplier;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '\u20B9${totalPrice.toStringAsFixed(0)}',
                  style: AppTextStyles.headingMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Total amount',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Material(
                color: _canBook ? AppColors.darkBrown : AppColors.neutralGray,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: _canBook && !isLoading ? onConfirm : null,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    alignment: Alignment.center,
                    child: isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'Confirm Booking',
                            style: AppTextStyles.buttonMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Success dialog.
class _SuccessDialog extends StatelessWidget {
  final Expert expert;
  final DateTime date;
  final ExpertTimeSlot timeSlot;
  final ExpertSessionType sessionType;

  const _SuccessDialog({
    required this.expert,
    required this.date,
    required this.timeSlot,
    required this.sessionType,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.success.withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                size: 48,
                color: AppColors.success,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Booking Confirmed!',
              style: AppTextStyles.headingMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your session with ${expert.name} has been scheduled.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('EEEE, MMMM d, yyyy').format(date),
                        style: AppTextStyles.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.access_time,
                          size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 8),
                      Text(
                        '${timeSlot.displayTime} (${sessionType.displayName})',
                        style: AppTextStyles.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.go('/home');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkBrown,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'View My Bookings',
                  style: AppTextStyles.buttonMedium.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Loading skeleton.
class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          SkeletonLoader(height: 80),
          SizedBox(height: 20),
          SkeletonLoader(height: 250),
          SizedBox(height: 20),
          SkeletonLoader(height: 60),
          SizedBox(height: 10),
          SkeletonLoader(height: 60),
          SizedBox(height: 10),
          SkeletonLoader(height: 60),
        ],
      ),
    );
  }
}
