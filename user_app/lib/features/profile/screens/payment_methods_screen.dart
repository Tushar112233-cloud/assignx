/// Payment Methods Screen for managing saved cards and UPI IDs with modern UI.
///
/// Features:
/// - Gradient background
/// - Glass morphism cards
/// - Add/remove payment methods
/// - Set default payment method
/// - Form validation
/// - Loading states
///
/// Implements U91 from feature spec.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/subtle_gradient_scaffold.dart';

/// Payment method type
enum PaymentMethodType { card, upi }

/// Payment method model
class PaymentMethod {
  final String id;
  final PaymentMethodType type;
  final bool isDefault;
  // Card fields
  final String? cardLast4;
  final String? cardBrand;
  final String? cardExpiry;
  final String? cardholderName;
  // UPI fields
  final String? upiId;

  const PaymentMethod({
    required this.id,
    required this.type,
    required this.isDefault,
    this.cardLast4,
    this.cardBrand,
    this.cardExpiry,
    this.cardholderName,
    this.upiId,
  });

  PaymentMethod copyWith({bool? isDefault}) {
    return PaymentMethod(
      id: id,
      type: type,
      isDefault: isDefault ?? this.isDefault,
      cardLast4: cardLast4,
      cardBrand: cardBrand,
      cardExpiry: cardExpiry,
      cardholderName: cardholderName,
      upiId: upiId,
    );
  }
}

/// Payment Methods Screen widget
class PaymentMethodsScreen extends ConsumerStatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  ConsumerState<PaymentMethodsScreen> createState() =>
      _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends ConsumerState<PaymentMethodsScreen> {
  bool _isLoading = true;
  List<PaymentMethod> _methods = [];

  @override
  void initState() {
    super.initState();
    _loadPaymentMethods();
  }

  Future<void> _loadPaymentMethods() async {
    setState(() => _isLoading = true);

    try {
      // In production: Fetch from Razorpay/Supabase
      await Future.delayed(const Duration(milliseconds: 500));

      // Mock data
      _methods = [
        const PaymentMethod(
          id: 'card-1',
          type: PaymentMethodType.card,
          isDefault: true,
          cardLast4: '4242',
          cardBrand: 'visa',
          cardExpiry: '12/26',
          cardholderName: 'John Doe',
        ),
        const PaymentMethod(
          id: 'upi-1',
          type: PaymentMethodType.upi,
          isDefault: false,
          upiId: 'john@okaxis',
        ),
      ];
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SubtleGradientScaffold.standard(
      body: SafeArea(
        child: Column(
          children: [
            // Custom app bar
            _buildAppBar(),

            // Content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _loadPaymentMethods,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Info text
                            Text(
                              'Manage your saved cards and UPI IDs for faster checkout',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Saved methods
                            if (_methods.isEmpty)
                              _buildEmptyState()
                            else
                              ..._methods.map((method) => _buildMethodCard(method)),

                            const SizedBox(height: 24),

                            // Add buttons
                            _buildAddButtons(),

                            const SizedBox(height: 32),

                            // Security note
                            _buildSecurityNote(),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the custom app bar.
  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(10),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_back, size: 22),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'Payment Methods',
            style: AppTextStyles.headingSmall,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return GlassCard(
      blur: 10,
      opacity: 0.9,
      padding: const EdgeInsets.symmetric(vertical: 48),
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withAlpha(40),
                  AppColors.primary.withAlpha(20),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.credit_card,
              size: 48,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No payment methods saved',
            style: AppTextStyles.labelLarge,
          ),
          const SizedBox(height: 4),
          Text(
            'Add a card or UPI ID for faster checkout',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodCard(PaymentMethod method) {
    final isCard = method.type == PaymentMethodType.card;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        blur: 10,
        opacity: 0.9,
        padding: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(14),
        elevation: method.isDefault ? 3 : 1,
        child: Container(
          decoration: method.isDefault
              ? BoxDecoration(
                  border: Border.all(
                    color: AppColors.primary,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(14),
                )
              : null,
          padding: method.isDefault ? const EdgeInsets.all(2) : null,
          child: Row(
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isCard
                        ? [Colors.grey.shade700, Colors.grey.shade900]
                        : [Colors.green.shade500, Colors.green.shade700],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isCard ? Icons.credit_card : Icons.smartphone,
                  color: Colors.white,
                  size: 24,
                ),
              ),

              const SizedBox(width: 14),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isCard) ...[
                      Text(
                        '•••• •••• •••• ${method.cardLast4}',
                        style: AppTextStyles.labelMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${method.cardholderName} • Expires ${method.cardExpiry}',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ] else ...[
                      Text(
                        method.upiId ?? '',
                        style: AppTextStyles.labelMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'UPI ID',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Actions
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (method.isDefault)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.primary.withAlpha(200),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check,
                            size: 12,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Default',
                            style: AppTextStyles.labelSmall.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    TextButton(
                      onPressed: () => _setDefault(method.id),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Set Default',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  const SizedBox(height: 4),
                  IconButton(
                    onPressed: () => _confirmDelete(method),
                    icon: const Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: AppColors.textTertiary,
                    ),
                    style: IconButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(32, 32),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddButtons() {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withAlpha(200),
                  AppColors.primary,
                ],
              ),
            ),
            child: OutlinedButton.icon(
              onPressed: _showAddCardDialog,
              icon: const Icon(Icons.credit_card, size: 18, color: Colors.white),
              label: Text('Add Card', style: AppTextStyles.labelMedium.copyWith(color: Colors.white)),
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.transparent,
                side: BorderSide.none,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _showAddUpiDialog,
            icon: Icon(Icons.smartphone, size: 18, color: AppColors.primary),
            label: Text('Add UPI', style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary)),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityNote() {
    return GlassCard(
      blur: 8,
      opacity: 0.9,
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(12),
      elevation: 1,
      child: Row(
        children: [
          Icon(
            Icons.shield,
            size: 20,
            color: AppColors.success,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Your payment information is encrypted and securely stored via Razorpay (PCI DSS Compliant)',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _setDefault(String id) async {
    setState(() {
      _methods = _methods.map((m) {
        return m.copyWith(isDefault: m.id == id);
      }).toList();
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('Default payment method updated'),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Future<void> _deleteMethod(String id) async {
    final method = _methods.firstWhere((m) => m.id == id);

    if (method.isDefault && _methods.length > 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Set another method as default first'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _methods = _methods.where((m) => m.id != id).toList();
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('Payment method removed'),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void _showAddCardDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddCardSheet(
        onAdd: (card) {
          setState(() {
            _methods = [
              ..._methods,
              card.copyWith(isDefault: _methods.isEmpty),
            ];
          });
        },
      ),
    );
  }

  void _showAddUpiDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddUpiSheet(
        onAdd: (upi) {
          setState(() {
            _methods = [
              ..._methods,
              upi.copyWith(isDefault: _methods.isEmpty),
            ];
          });
        },
      ),
    );
  }

  void _confirmDelete(PaymentMethod method) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Remove Payment Method?'),
        content: Text(
          method.type == PaymentMethodType.card
              ? 'Remove card ending in ${method.cardLast4}?'
              : 'Remove UPI ID ${method.upiId}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteMethod(method.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}

/// Add Card Bottom Sheet
class _AddCardSheet extends StatefulWidget {
  final Function(PaymentMethod) onAdd;

  const _AddCardSheet({required this.onAdd});

  @override
  State<_AddCardSheet> createState() => _AddCardSheetState();
}

class _AddCardSheetState extends State<_AddCardSheet> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  String _formatCardNumber(String value) {
    final cleaned = value.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();
    for (int i = 0; i < cleaned.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(cleaned[i]);
    }
    return buffer.toString();
  }

  String _formatExpiry(String value) {
    final cleaned = value.replaceAll(RegExp(r'\D'), '');
    if (cleaned.length >= 2) {
      return '${cleaned.substring(0, 2)}/${cleaned.substring(2)}';
    }
    return cleaned;
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      // In production: Tokenize via Razorpay
      await Future.delayed(const Duration(seconds: 1));

      final card = PaymentMethod(
        id: 'card-${DateTime.now().millisecondsSinceEpoch}',
        type: PaymentMethodType.card,
        isDefault: false,
        cardLast4: _cardNumberController.text.replaceAll(' ', '').substring(
            _cardNumberController.text.replaceAll(' ', '').length - 4),
        cardBrand: 'visa',
        cardExpiry: _expiryController.text,
        cardholderName: _nameController.text,
      );

      widget.onAdd(card);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Card added successfully'),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
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
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Header
            Text(
              'Add Debit/Credit Card',
              style: AppTextStyles.headingSmall.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Your card details are securely stored via Razorpay',
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),

            // Card Number
            TextFormField(
              controller: _cardNumberController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(16),
              ],
              decoration: const InputDecoration(
                labelText: 'Card Number',
                hintText: '1234 5678 9012 3456',
                prefixIcon: Icon(Icons.credit_card),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                final formatted = _formatCardNumber(value);
                if (formatted != value) {
                  _cardNumberController.value = TextEditingValue(
                    text: formatted,
                    selection: TextSelection.collapsed(offset: formatted.length),
                  );
                }
              },
              validator: (value) {
                if (value == null || value.replaceAll(' ', '').length < 16) {
                  return 'Enter valid card number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Expiry and CVV
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _expiryController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Expiry',
                      hintText: 'MM/YY',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      final formatted = _formatExpiry(value);
                      if (formatted != value) {
                        _expiryController.value = TextEditingValue(
                          text: formatted,
                          selection: TextSelection.collapsed(offset: formatted.length),
                        );
                      }
                    },
                    validator: (value) {
                      if (value == null || value.length < 5) {
                        return 'Invalid';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _cvvController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'CVV',
                      hintText: '•••',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.length < 3) {
                        return 'Invalid';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Name
            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Cardholder Name',
                hintText: 'Name on card',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Enter name';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Submit
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Add Card'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Add UPI Bottom Sheet
class _AddUpiSheet extends StatefulWidget {
  final Function(PaymentMethod) onAdd;

  const _AddUpiSheet({required this.onAdd});

  @override
  State<_AddUpiSheet> createState() => _AddUpiSheetState();
}

class _AddUpiSheetState extends State<_AddUpiSheet> {
  final _formKey = GlobalKey<FormState>();
  final _upiController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _upiController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      // In production: Verify UPI ID
      await Future.delayed(const Duration(milliseconds: 500));

      final upi = PaymentMethod(
        id: 'upi-${DateTime.now().millisecondsSinceEpoch}',
        type: PaymentMethodType.upi,
        isDefault: false,
        upiId: _upiController.text.toLowerCase(),
      );

      widget.onAdd(upi);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('UPI ID added successfully'),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
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
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Header
            Text(
              'Add UPI ID',
              style: AppTextStyles.headingSmall.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Link your UPI ID for quick payments',
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),

            // UPI ID
            TextFormField(
              controller: _upiController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'UPI ID',
                hintText: 'yourname@upi',
                prefixIcon: Icon(Icons.smartphone),
                border: OutlineInputBorder(),
                helperText: 'Example: name@okaxis, name@ybl, name@paytm',
              ),
              validator: (value) {
                if (value == null || !value.contains('@')) {
                  return 'Enter valid UPI ID';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Submit
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Add UPI ID'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
