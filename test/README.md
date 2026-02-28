# Test Structure (By Type)

This folder is organized by **test type** so you can run exactly what you need.

## Folders

- `test/usecase/` → Use case tests (domain/business use cases)
- `test/unit/` → Unit tests (view models, logic, services)
- `test/widget/` → Widget tests (UI behavior)

## Run Commands

From project root (`peerpicks`):

- Run all use case tests:
  - `flutter test test/usecase`
- Run all unit tests:
  - `flutter test test/unit`
- Run all widget tests:
  - `flutter test test/widget`
- Run everything:
  - `flutter test`
- Run coverage:
  - `flutter test --coverage`

## Current Mapping

- **UseCase**
  - `test/usecase/auth/auth_usecases_test.dart`

- **Unit**
  - `test/unit/auth/auth_viewmodel_test.dart`
  - `test/unit/auth/auth_viewmodel_riverpod_test.dart`
  - `test/unit/dashboard/dashboard_logic_test.dart`
  - `test/unit/core/shared_prefs_test.dart`

- **Widget**
  - `test/widget/auth/login_view_test.dart`
  - `test/widget/auth/onboarding_widget_test.dart`
  - `test/widget/dashboard/dashboard_screen_test.dart`
  - `test/widget/onboarding/onboarding_navigation_test.dart`
  - `test/widget/onboarding/onboarding_screen_test.dart`
  - `test/widget/onboarding/onboarding_widgets_extra_test.dart`
  - `test/widget/profile/profile_screen_test.dart`
