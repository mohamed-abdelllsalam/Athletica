import 'package:dio/dio.dart';

import 'failures.dart';

/// Maps [DioException]s carrying the documented Athletica error body
/// (`{"error": "<key>", "details": [...]}`) into typed [AppFailure]s.
AppFailure mapDioException(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.connectionError:
      return const NetworkFailure(
        'No internet connection. Please check your connection and try again.',
      );
    default:
      break;
  }

  final response = e.response;
  final statusCode = response?.statusCode;

  if (statusCode == 401) {
    return const UnauthorizedFailure('Your session has expired, please login again.');
  }

  String message;
  final data = response?.data;
  if (data is Map<String, dynamic>) {
    message = _messageFromBody(data);
  } else {
    message = _fallbackForStatus(statusCode);
  }
  return ServerFailure(message);
}

String _messageFromBody(Map<String, dynamic> data) {
  final key = data['error'];
  final details = data['details'];
  final detailsText =
      details is List && details.isNotEmpty ? details.join(', ') : null;

  if (key is String && key.isNotEmpty) {
    final mapped = _messageForKey(key);
    if (mapped != null) {
      return detailsText == null ? mapped : '$mapped $detailsText';
    }
    return detailsText ?? key;
  }

  if (detailsText != null) return detailsText;
  return _fallbackForStatus(null);
}

String? _messageForKey(String key) => switch (key) {
      'validation_failed' =>
        'Please check the provided information and try again.',
      'template_has_active_plans' =>
        'This template has active plans and cannot be deleted.',
      'template_has_no_meals' =>
        'Add at least one meal before assigning this template.',
      'template_has_no_days' =>
        'Add at least one day before assigning this template.',
      'template_has_no_exercises' =>
        'Add at least one exercise before assigning this template.',
      'is_rest_invalid' => 'Cannot add exercises to a rest day.',
      'day_orders_incomplete' => 'Day order must include all days.',
      'day_number_conflict' => 'A day with this number already exists.',
      'exercise_order_conflict' =>
        'An exercise with this order already exists.',
      'workout_today_only' => "Only today's workout can be updated.",
      'exercise_not_completed' => 'This exercise is not completed.',
      'sets_invalid' => 'Sets must be a positive number.',
      'reps_invalid' => 'Reps must be a positive number.',
      'workout_day_not_found' => 'Workout day not found.',
      'exercise_log_not_found' => 'Exercise log not found.',
      'food_already_in_meal' => 'This food is already in the meal.',
      'food_archived' => 'This food is archived and cannot be added.',
      'meal_today_only' => "Only today's meals can be updated.",
      'meal_not_completed' => 'This meal is not completed.',
      'meal_orders_incomplete' => 'Meal order must include all meals.',
      'meal_orders_invalid' => 'Invalid meal order provided.',
      'plan_not_active' => 'This plan is not active.',
      'start_date_invalid' => 'Invalid start date.',
      'invalid_or_expired_token' => 'Invite link is invalid or expired.',
      'cannot_assign_self' => 'You cannot use your own invite link.',
      'already_have_coach' => 'This client already has a coach.',
      'wait_before_resubmit' =>
        'Please wait 5 minutes before sending another request.',
      'request_not_pending' => 'This request is no longer pending.',
      'auth_required' => 'Please login to continue.',
      'template_not_found' => 'Template not found.',
      'plan_not_found' => 'Plan not found.',
      'meal_not_found' => 'Meal not found.',
      'food_not_found' => 'Food not found.',
      'template_food_not_found' => 'Food not found in this meal.',
      'plan_food_not_found' => 'Food not found in this meal.',
      'client_not_assigned_to_coach' => 'This client is not assigned to you.',
      'coach_profile_not_found' => 'Coach profile not found.',
      'client_profile_not_found' => 'Client profile not found.',
      'day_not_found' => 'Day not found.',
      'exercise_not_found' => 'Exercise not found.',
      'username_already_taken' => 'This username is already taken.',
      'username_length' => 'Username must be between 1 and 100 characters.',
      'no_fields_to_update' => 'No changes to save.',
      'No fields to update' => 'No changes to save.',
      'specialization_invalid' => 'Invalid specialization.',
      'phone_number_invalid' => 'Invalid phone number.',
      'location_invalid' => 'Invalid location.',
      'gender_invalid' => 'Invalid gender.',
      'birth_date_invalid' => 'Invalid birth date.',
      'height_invalid' => 'Invalid height.',
      'weight_invalid' => 'Invalid weight.',
      'goal_invalid' => 'Invalid goal.',
      'bio_invalid' => 'Invalid bio.',
      'image_required' => 'Please select an image.',
      'invalid_file_type' => 'Only JPEG, PNG, and WEBP images are allowed.',
      'file_too_large' => 'Image must be 5 MB or smaller.',
      'no_profile_image' => 'No profile image to delete.',
      'no_active_plan_found' => 'No active plan found.',
      'no_active_invite' => 'No active invite link to revoke.',
      'request_not_found' => 'Request not found.',
      'no_coach_assigned' => 'No coach assigned.',
      'client_not_assigned' => 'Client not assigned to you.',
      'meal_log_not_found' => 'Meal log not found.',
      'record_not_found' => 'Record not found.',
      'request_already_exists' => 'A request already exists.',
      'internal_server_error' =>
        'Something went wrong on our side. Please try again.',
      _ => null,
    };

String _fallbackForStatus(int? statusCode) {
  if (statusCode == null) {
    return 'Something went wrong. Please try again.';
  }
  if (statusCode >= 500) {
    return 'Server error. Please try again later.';
  }
  if (statusCode >= 400) {
    return 'Request failed. Please try again.';
  }
  return 'Something went wrong. Please try again.';
}
