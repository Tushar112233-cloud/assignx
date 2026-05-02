import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/api/api_client.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/services/payment_service.dart';
import '../../../core/utils/extensions.dart';
import '../../../data/models/expert_model.dart';
import '../../../core/translation/translation_extensions.dart';
import '../../../providers/experts_provider.dart';
import '../../../shared/widgets/skeleton_loader.dart';
import '../widgets/booking_calendar.dart';
import '../../../shared/widgets/subtle_gradient_scaffold.dart';
import '../widgets/price_breakdown.dart';

/// 3-step booking screen matching the web flow:
/// Step 1: Date & Time
/// Step 2: Session Details (topic required, notes optional)
/// Step 3: Confirm & Pay
class BookingScreen extends ConsumerStatefulWidget {
  final String expertId;

  const BookingScreen({super.key, required this.expertId});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  int _currentStep = 0; // 0=datetime, 1=details, 2=confirm
  DateTime? _selectedDate;
  ExpertTimeSlot? _selectedTimeSlot;
  ExpertSessionType _selectedSessionType = ExpertSessionType.oneHour;
  final _topicController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isLoading = false;

  static const double _platformFeePercent = 10.0;
  static const double _gstPercent = 18.0;

  static const _stepLabels = ['Date & Time', 'Details', 'Confirm'];
  static const _stepIcons = [
    Icons.calendar_today_rounded,
    Icons.edit_note_rounded,
    Icons.check_circle_outline_rounded,
  ];

  @override
  void dispose() {
    _topicController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _autoSelectDate(Expert expert) {
    if (_selectedDate != null) return;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    for (int i = 0; i <= 30; i++) {
      final date = today.add(Duration(days: i));
      if (expert.isAvailableOnDate(date)) {
        setState(() => _selectedDate = date);
        return;
      }
    }
  }

  double _calculateTotal(double basePrice) {
    final platformFee = basePrice * (_platformFeePercent / 100);
    final subtotal = basePrice + platformFee;
    final gst = subtotal * (_gstPercent / 100);
    return subtotal + gst;
  }

  bool get _canAdvance {
    switch (_currentStep) {
      case 0:
        return _selectedDate != null && _selectedTimeSlot != null;
      case 1:
        return _topicController.text.trim().isNotEmpty;
      case 2:
        return true;
      default:
        return false;
    }
  }

  void _nextStep() {
    if (!_canAdvance) return;
    if (_currentStep < 2) {
      setState(() => _currentStep++);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      context.pop();
    }
  }

  String _getButtonLabel() {
    switch (_currentStep) {
      case 0:
        return _canAdvance ? 'Continue' : 'Select date & time';
      case 1:
        return _canAdvance ? 'Review & Pay' : 'Enter topic to continue';
      case 2:
        return 'Pay & Confirm';
      default:
        return 'Continue';
    }
  }

  @override
  Widget build(BuildContext context) {
    final expertAsync = ref.watch(expertDetailProvider(widget.expertId));

    return SubtleGradientScaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        backgroundColor: Colors.white.withValues(alpha: 0.95),
        elevation: 0,
        leading: GestureDetector(
          onTap: _prevStep,
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          ),
        ),
        title: Text(
          'Book Session'.tr(context),
          style: AppTextStyles.headingSmall.copyWith(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: expertAsync.when(
        data: (expert) {
          if (expert == null) {
            return Center(child: Text('Expert not found'.tr(context)));
          }
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _autoSelectDate(expert);
          });

          return Column(
            children: [
              // Step indicator
              _StepIndicator(
                currentStep: _currentStep,
                labels: _stepLabels,
                icons: _stepIcons,
              ),

              // Step content
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: _currentStep == 0
                      ? _DateTimeStep(
                          key: const ValueKey(0),
                          expert: expert,
                          selectedDate: _selectedDate,
                          selectedTimeSlot: _selectedTimeSlot,
                          selectedSessionType: _selectedSessionType,
                          onDateSelected: (d) => setState(() {
                            _selectedDate = d;
                            _selectedTimeSlot = null;
                          }),
                          onTimeSlotSelected: (s) =>
                              setState(() => _selectedTimeSlot = s),
                          onSessionTypeChanged: (t) =>
                              setState(() => _selectedSessionType = t),
                        )
                      : _currentStep == 1
                          ? _DetailsStep(
                              key: const ValueKey(1),
                              topicController: _topicController,
                              notesController: _notesController,
                              onChanged: () => setState(() {}),
                            )
                          : _ConfirmStep(
                              key: const ValueKey(2),
                              expert: expert,
                              selectedDate: _selectedDate!,
                              selectedTimeSlot: _selectedTimeSlot!,
                              selectedSessionType: _selectedSessionType,
                              topic: _topicController.text.trim(),
                              notes: _notesController.text.trim(),
                              platformFeePercent: _platformFeePercent,
                              gstPercent: _gstPercent,
                            ),
                ),
              ),
            ],
          );
        },
        loading: () => const _LoadingSkeleton(),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              Text('Failed to load expert'.tr(context)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    ref.invalidate(expertDetailProvider(widget.expertId)),
                child: Text('Retry'.tr(context)),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: expertAsync.whenData((expert) {
        if (expert == null) return const SizedBox.shrink();
        final basePrice =
            expert.pricePerSession * _selectedSessionType.priceMultiplier;
        final totalAmount = _calculateTotal(basePrice);

        return Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: SafeArea(
            child: Row(
              children: [
                // Price
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '\u20B9${totalAmount.toStringAsFixed(0)}',
                      style: AppTextStyles.headingSmall.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'incl. fees & GST'.tr(context),
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textTertiary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                // Action button
                Expanded(
                  child: Material(
                    color: _canAdvance
                        ? (_currentStep == 2
                            ? AppColors.darkBrown
                            : AppColors.primary)
                        : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      onTap: _canAdvance && !_isLoading
                          ? () {
                              if (_currentStep == 2) {
                                _confirmBooking(expert);
                              } else {
                                _nextStep();
                              }
                            }
                          : null,
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        alignment: Alignment.center,
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : Text(
                                _getButtonLabel().tr(context),
                                style: AppTextStyles.buttonMedium.copyWith(
                                  color: _canAdvance
                                      ? Colors.white
                                      : AppColors.textTertiary,
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
      }).valueOrNull,
    );
  }

  Future<void> _confirmBooking(Expert expert) async {
    if (_selectedDate == null || _selectedTimeSlot == null) return;

    setState(() => _isLoading = true);

    try {
      final basePrice =
          expert.pricePerSession * _selectedSessionType.priceMultiplier;
      final totalAmount = _calculateTotal(basePrice);

      final orderResponse =
          await ApiClient.post('/experts/bookings/create-order', {
        'expertId': expert.id,
        'amount': totalAmount,
      });

      final orderData = orderResponse as Map<String, dynamic>;
      final orderId = orderData['orderId'] as String;
      final keyId = orderData['keyId'] as String;
      final amountInPaise = orderData['amount'] as int;

      final paymentService = PaymentService();
      final dateStr = _selectedDate!.toIso8601String().split('T')[0];

      paymentService.payCustomOrder(
        orderId: orderId,
        keyId: keyId,
        amountInPaise: amountInPaise,
        description: 'Consultation with ${expert.name}',
        onSuccess: (result) async {
          try {
            await ApiClient.post('/experts/bookings/verify-payment', {
              'razorpay_order_id': result.orderId ?? orderId,
              'razorpay_payment_id': result.paymentId ?? '',
              'razorpay_signature': result.signature ?? '',
              'expertId': expert.id,
              'date': dateStr,
              'time': _selectedTimeSlot!.time,
              'startTime': _selectedTimeSlot!.time,
              'endTime': '',
              'duration': _selectedSessionType.minutes,
              'topic': _topicController.text.trim(),
              'notes': _notesController.text.trim(),
              'amount': totalAmount,
              'sessionType': _selectedSessionType.displayName,
            });

            ref.invalidate(userBookingsProvider);

            if (mounted) {
              setState(() => _isLoading = false);
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
              setState(() => _isLoading = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Payment verified but booking failed: $e'),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          }
        },
        onError: (result) {
          if (mounted) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Payment failed: ${result.errorMessage ?? 'Unknown error'}'),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
      );
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking failed: ${e.message}'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking failed: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

// =============================================================================
// Step Indicator
// =============================================================================

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  final List<String> labels;
  final List<IconData> icons;

  const _StepIndicator({
    required this.currentStep,
    required this.labels,
    required this.icons,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      color: Colors.white.withValues(alpha: 0.95),
      child: Row(
        children: List.generate(labels.length, (i) {
          final isCompleted = i < currentStep;
          final isCurrent = i == currentStep;
          return Expanded(
            child: Row(
              children: [
                if (i > 0)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      color: isCompleted
                          ? AppColors.primary
                          : AppColors.border,
                    ),
                  ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCompleted
                            ? AppColors.primary
                            : isCurrent
                                ? AppColors.primary.withValues(alpha: 0.1)
                                : AppColors.surfaceVariant,
                        border: Border.all(
                          color: isCompleted || isCurrent
                              ? AppColors.primary
                              : AppColors.border,
                          width: isCurrent ? 2 : 1,
                        ),
                      ),
                      child: Icon(
                        isCompleted ? Icons.check : icons[i],
                        size: 16,
                        color: isCompleted
                            ? Colors.white
                            : isCurrent
                                ? AppColors.primary
                                : AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      labels[i].tr(context),
                      style: AppTextStyles.caption.copyWith(
                        fontSize: 10,
                        fontWeight:
                            isCurrent ? FontWeight.w600 : FontWeight.w400,
                        color: isCurrent
                            ? AppColors.primary
                            : AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// =============================================================================
// Step 1: Date & Time
// =============================================================================

class _DateTimeStep extends ConsumerWidget {
  final Expert expert;
  final DateTime? selectedDate;
  final ExpertTimeSlot? selectedTimeSlot;
  final ExpertSessionType selectedSessionType;
  final ValueChanged<DateTime> onDateSelected;
  final ValueChanged<ExpertTimeSlot> onTimeSlotSelected;
  final ValueChanged<ExpertSessionType> onSessionTypeChanged;

  const _DateTimeStep({
    super.key,
    required this.expert,
    required this.selectedDate,
    required this.selectedTimeSlot,
    required this.selectedSessionType,
    required this.onDateSelected,
    required this.onTimeSlotSelected,
    required this.onSessionTypeChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slotsAsync = selectedDate != null
        ? ref.watch(
            availableSlotsProvider((expertId: expert.id, date: selectedDate!)))
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
            availableWeekdays: expert.availableWeekdays,
          ),
          const SizedBox(height: 20),

          // Session duration
          _SessionTypeSelector(
            selectedType: selectedSessionType,
            pricePerSession: expert.pricePerSession,
            onTypeChanged: onSessionTypeChanged,
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

// =============================================================================
// Step 2: Details
// =============================================================================

class _DetailsStep extends StatelessWidget {
  final TextEditingController topicController;
  final TextEditingController notesController;
  final VoidCallback onChanged;

  const _DetailsStep({
    super.key,
    required this.topicController,
    required this.notesController,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.edit_note_rounded,
                    size: 20, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Session Details'.tr(context),
                      style: AppTextStyles.headingSmall
                          .copyWith(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    Text(
                      'Tell the expert what you need help with'.tr(context),
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Topic field (required)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Topic / Subject'.tr(context),
                      style: AppTextStyles.labelMedium
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 4),
                    Text('*',
                        style: TextStyle(
                            color: AppColors.error, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: topicController,
                  onChanged: (_) => onChanged(),
                  maxLength: 100,
                  style: AppTextStyles.bodyMedium,
                  decoration: InputDecoration(
                    hintText: 'e.g., Machine Learning Project Help'.tr(context),
                    hintStyle: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.textTertiary),
                    filled: true,
                    fillColor: AppColors.surfaceVariant,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    counterText: '',
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Brief description of what you need help with'.tr(context),
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Notes field (optional)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Additional Notes (Optional)'.tr(context),
                  style: AppTextStyles.labelMedium
                      .copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: notesController,
                  onChanged: (_) => onChanged(),
                  maxLines: 4,
                  maxLength: 500,
                  style: AppTextStyles.bodyMedium,
                  decoration: InputDecoration(
                    hintText:
                        'Any specific questions or materials you want to discuss...'
                            .tr(context),
                    hintStyle: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.textTertiary),
                    filled: true,
                    fillColor: AppColors.surfaceVariant,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

// =============================================================================
// Step 3: Confirm
// =============================================================================

class _ConfirmStep extends StatelessWidget {
  final Expert expert;
  final DateTime selectedDate;
  final ExpertTimeSlot selectedTimeSlot;
  final ExpertSessionType selectedSessionType;
  final String topic;
  final String notes;
  final double platformFeePercent;
  final double gstPercent;

  const _ConfirmStep({
    super.key,
    required this.expert,
    required this.selectedDate,
    required this.selectedTimeSlot,
    required this.selectedSessionType,
    required this.topic,
    required this.notes,
    required this.platformFeePercent,
    required this.gstPercent,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.check_circle_outline_rounded,
                    size: 20, color: AppColors.success),
              ),
              const SizedBox(width: 12),
              Text(
                'Review Your Booking'.tr(context),
                style: AppTextStyles.headingSmall
                    .copyWith(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Booking summary card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                // Expert
                _SummaryRow(
                  icon: Icons.person_outline,
                  label: 'Expert'.tr(context),
                  value: expert.name,
                ),
                const Divider(height: 20),
                // Date
                _SummaryRow(
                  icon: Icons.calendar_today_rounded,
                  label: 'Date'.tr(context),
                  value: DateFormat('EEEE, MMM d, yyyy').format(selectedDate),
                ),
                const Divider(height: 20),
                // Time
                _SummaryRow(
                  icon: Icons.access_time_rounded,
                  label: 'Time'.tr(context),
                  value: selectedTimeSlot.displayTime,
                ),
                const Divider(height: 20),
                // Duration
                _SummaryRow(
                  icon: Icons.timer_outlined,
                  label: 'Duration'.tr(context),
                  value: selectedSessionType.displayName,
                ),
                const Divider(height: 20),
                // Topic
                _SummaryRow(
                  icon: Icons.topic_outlined,
                  label: 'Topic'.tr(context),
                  value: topic,
                ),
                if (notes.isNotEmpty) ...[
                  const Divider(height: 20),
                  _SummaryRow(
                    icon: Icons.note_outlined,
                    label: 'Notes'.tr(context),
                    value: notes,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Price breakdown
          PriceBreakdown(
            basePrice:
                expert.pricePerSession * selectedSessionType.priceMultiplier,
            platformFeePercent: platformFeePercent,
            taxPercent: gstPercent,
            initiallyExpanded: true,
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 10),
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodySmall
                .copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Shared widgets (Expert card, Session selector, Success dialog, Skeleton)
// =============================================================================

class _ExpertInfoCard extends StatelessWidget {
  final Expert expert;
  const _ExpertInfoCard({required this.expert});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primaryLight.withAlpha(50),
            backgroundImage: isValidImageUrl(expert.avatar)
                ? NetworkImage(expert.avatar!)
                : null,
            child: !isValidImageUrl(expert.avatar)
                ? Text(expert.initials,
                    style: AppTextStyles.labelLarge
                        .copyWith(color: AppColors.primary, fontWeight: FontWeight.w600))
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(expert.name,
                          style: AppTextStyles.labelLarge
                              .copyWith(fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ),
                    if (expert.verified) ...[
                      const SizedBox(width: 4),
                      Icon(Icons.verified, size: 16, color: AppColors.success),
                    ],
                  ],
                ),
                Text(expert.designation,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Text(
            '\u20B9${expert.pricePerSession.toStringAsFixed(0)}/hr',
            style: AppTextStyles.labelSmall
                .copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

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
            Text('Session Duration'.tr(context),
                style: AppTextStyles.labelLarge
                    .copyWith(fontWeight: FontWeight.w600)),
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
                      ? AppColors.primary.withAlpha(15)
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
                        color: isSelected ? AppColors.primary : Colors.transparent,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textTertiary,
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, size: 14, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(type.displayName.tr(context),
                          style: AppTextStyles.labelMedium.copyWith(
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500)),
                    ),
                    Text('\u20B9${price.toStringAsFixed(0)}',
                        style: AppTextStyles.labelLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textPrimary,
                        )),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
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
              child: Icon(Icons.check_circle, size: 48, color: AppColors.success),
            ),
            const SizedBox(height: 20),
            Text('Booking Confirmed!'.tr(context),
                style: AppTextStyles.headingMedium
                    .copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              '${'Your session with'.tr(context)} ${expert.name} ${'has been scheduled.'.tr(context)}',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
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
                  Row(children: [
                    Icon(Icons.calendar_today,
                        size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 8),
                    Text(DateFormat('EEEE, MMMM d, yyyy').format(date),
                        style: AppTextStyles.bodyMedium),
                  ]),
                  const SizedBox(height: 8),
                  Row(children: [
                    Icon(Icons.access_time,
                        size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 8),
                    Text('${timeSlot.displayTime} (${sessionType.displayName})',
                        style: AppTextStyles.bodyMedium),
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.go('/experts/my-bookings');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('View My Bookings'.tr(context),
                    style: AppTextStyles.buttonMedium
                        .copyWith(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
