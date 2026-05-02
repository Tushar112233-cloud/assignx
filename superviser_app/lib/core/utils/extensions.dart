/// Utility exports for the Superviser App.
///
/// This barrel file exports all utility modules for convenient importing.
/// Instead of importing individual utility files, you can import this file
/// to get access to all utilities.
///
/// ## Exported Modules
///
/// - [Validators] - Form validation utilities
/// - [Formatters] - Data formatting utilities
///
/// ## Usage
///
/// ```dart
/// // Single import for all utilities
/// import 'package:superviser_app/core/utils/extensions.dart';
///
/// // Now you can use:
/// Validators.email('test@example.com');
/// Formatters.currency(1234.56);
/// ```
///
/// ## Adding New Utilities
///
/// When creating new utility files, add an export statement here:
/// ```dart
/// export 'new_utility.dart';
/// ```
///
/// See also:
/// - [Validators] for form validation
/// - [Formatters] for data formatting
library;

export 'validators.dart';
export 'formatters.dart';
