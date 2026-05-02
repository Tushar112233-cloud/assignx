import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:superviser_app/features/projects/domain/entities/project_status.dart';

void main() {
  group('ProjectStatus', () {
    test('has all expected values', () {
      expect(ProjectStatus.values.length, 20);
      expect(ProjectStatus.values, contains(ProjectStatus.submitted));
      expect(ProjectStatus.values, contains(ProjectStatus.completed));
      expect(ProjectStatus.values, contains(ProjectStatus.cancelled));
    });

    test('fromString returns correct status', () {
      expect(ProjectStatus.fromString('submitted'), ProjectStatus.submitted);
      expect(ProjectStatus.fromString('in_progress'), ProjectStatus.inProgress);
      expect(ProjectStatus.fromString('completed'), ProjectStatus.completed);
    });

    test('fromString returns submitted for null value', () {
      expect(ProjectStatus.fromString(null), ProjectStatus.submitted);
    });

    test('fromString returns submitted for unknown value', () {
      expect(ProjectStatus.fromString('unknown_status'), ProjectStatus.submitted);
    });

    test('each status has displayName', () {
      for (final status in ProjectStatus.values) {
        expect(status.displayName, isNotEmpty);
      }
    });

    test('each status has icon', () {
      for (final status in ProjectStatus.values) {
        expect(status.icon, isA<IconData>());
      }
    });

    test('each status has color', () {
      for (final status in ProjectStatus.values) {
        expect(status.color, isA<Color>());
      }
    });

    test('displayName is properly formatted', () {
      expect(ProjectStatus.submitted.displayName, 'Submitted');
      expect(ProjectStatus.inProgress.displayName, 'In Progress');
      expect(ProjectStatus.forReview.displayName, 'For Review');
    });
  });

  group('ProjectStatus.isActive', () {
    test('returns true for active statuses', () {
      expect(ProjectStatus.assigned.isActive, isTrue);
      expect(ProjectStatus.inProgress.isActive, isTrue);
      expect(ProjectStatus.delivered.isActive, isTrue);
      expect(ProjectStatus.inRevision.isActive, isTrue);
    });

    test('returns false for non-active statuses', () {
      expect(ProjectStatus.submitted.isActive, isFalse);
      expect(ProjectStatus.completed.isActive, isFalse);
      expect(ProjectStatus.cancelled.isActive, isFalse);
    });
  });

  group('ProjectStatus.requiresAction', () {
    test('returns true for statuses requiring action', () {
      expect(ProjectStatus.submitted.requiresAction, isTrue);
      expect(ProjectStatus.forReview.requiresAction, isTrue);
      expect(ProjectStatus.delivered.requiresAction, isTrue);
    });

    test('returns false for statuses not requiring action', () {
      expect(ProjectStatus.assigned.requiresAction, isFalse);
      expect(ProjectStatus.inProgress.requiresAction, isFalse);
      expect(ProjectStatus.completed.requiresAction, isFalse);
    });
  });

  group('ProjectStatus.isForReview', () {
    test('returns true for review statuses', () {
      expect(ProjectStatus.delivered.isForReview, isTrue);
      expect(ProjectStatus.forReview.isForReview, isTrue);
    });

    test('returns false for non-review statuses', () {
      expect(ProjectStatus.inProgress.isForReview, isFalse);
      expect(ProjectStatus.completed.isForReview, isFalse);
    });
  });

  group('ProjectStatus.isFinal', () {
    test('returns true for final statuses', () {
      expect(ProjectStatus.completed.isFinal, isTrue);
      expect(ProjectStatus.cancelled.isFinal, isTrue);
      expect(ProjectStatus.refunded.isFinal, isTrue);
    });

    test('returns false for non-final statuses', () {
      expect(ProjectStatus.submitted.isFinal, isFalse);
      expect(ProjectStatus.inProgress.isFinal, isFalse);
      expect(ProjectStatus.forReview.isFinal, isFalse);
    });
  });

  group('ProjectStatus.value', () {
    test('returns correct database value', () {
      expect(ProjectStatus.submitted.value, 'submitted');
      expect(ProjectStatus.inProgress.value, 'in_progress');
      expect(ProjectStatus.paymentPending.value, 'payment_pending');
      expect(ProjectStatus.readyToAssign.value, 'ready_to_assign');
    });
  });
}
