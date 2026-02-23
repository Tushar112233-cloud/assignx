// Copyright 2024 Doer App. All rights reserved.
// Use of this source code is governed by a BSD-style license.

/// Data models for the Doer application.
///
/// This library exports all data model classes used throughout the application,
/// providing a single import point for accessing domain entities.
///
/// ## Architecture Overview
///
/// The models are organized following a layered architecture:
///
/// ### Core User Models
/// - [ProfileModel] - Base user profile from the `profiles` table, shared across
///   all user types (doer, student, supervisor, admin)
/// - [DoerModel] - Doer-specific data from the `doers` table, including
///   qualifications, experience, and performance metrics
/// - [UserModel] - Combined view of profile + doer data for UI consumption
///
/// ### Activation Flow Models
/// - [ActivationStatus] - Tracks doer activation progress through training,
///   quiz, and bank details steps
/// - [ActivationState] - Full activation state including modules and progress
/// - [TrainingModule] - Training content metadata (video, PDF, article)
/// - [TrainingProgress] - Doer's progress through training modules
/// - [QuizQuestion] - Quiz questions with multiple choice options
/// - [QuizAttempt] - Records of quiz attempts and results
///
/// ### Project & Work Models
/// - [ProjectModel] - Task/project assignments with deadlines and requirements
/// - [DoerStats] - Aggregated performance statistics
/// - [ReviewModel] - Project reviews and ratings
///
/// ### Supporting Models
/// - [BankDetails] - Bank account information for payments
/// - [SkillModel] - Skills that doers can possess
/// - [SubjectModel] - Academic subjects doers specialize in
///
/// ## Database Relationships
///
/// ```
/// profiles (1) ──── (1) doers
///                      │
///                      ├── (N) doer_skills ──── (N) skills
///                      ├── (N) doer_subjects ──── (N) subjects
///                      └── (1) doer_activation
/// ```
///
/// ## Usage
///
/// Import this file to access all models:
///
/// ```dart
/// import 'package:doer_app/data/models/models.dart';
///
/// // Use any model class
/// final user = UserModel.fromJson(data);
/// final project = ProjectModel.fromJson(data);
/// ```
///
/// ## See Also
///
/// - [AuthRepository] for authentication and user data operations
/// - [ActivationProvider] for managing activation flow state
library models;

export 'activation_model.dart';
export 'bank_details_model.dart' hide BankDetailsFormData;
export 'chat_model.dart';
export 'deliverable_model.dart';
export 'doer_model.dart';
export 'doer_project_model.dart';
export 'profile_model.dart';
export 'project_model.dart';
export 'quiz_model.dart';
export 'training_model.dart';
export 'user_model.dart';
export 'wallet_model.dart';
