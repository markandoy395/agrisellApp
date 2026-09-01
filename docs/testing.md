# Testing

AgriSell uses static analysis, Dart unit tests, Flutter widget tests,
SQL-contract tests, and device-driven integration tests.

## Standard validation

Run these commands from the repository root:

```sh
flutter pub get
flutter analyze
flutter test
```

Use the full suite before merging a broad feature or backend-contract change.
For a focused edit, run the closest targeted test first and then expand the
scope based on risk.

## Targeted tests

Run one test file:

```sh
flutter test test/basket_controller_test.dart
```

Run a named test or group:

```sh
flutter test test/basket_controller_test.dart --plain-name "descriptive test name"
```

Run all tests whose filenames concern one workflow with your shell's file
selection support, or invoke the relevant files explicitly. Keeping a failing
test command reproducible is more useful than relying on an IDE-only filter.

## Test categories

### Unit tests

Domain rules, validators, codecs, mappers, matching logic, repositories, and
controllers are tested without rendering a complete application. Prefer small
fakes or typed fixtures from `test/support` over live network dependencies.

### Widget tests

Widget tests verify visible loading, ready, empty, error, validation, and
interaction states. Test keys and semantic labels should identify meaningful
controls without coupling every assertion to layout details.

### SQL-contract tests

Files with names such as `*_sql_test.dart` inspect migration SQL and assert
security or schema requirements. These tests are fast guardrails; they do not
replace applying migrations to a local or staging Supabase database.

When a migration changes an RPC, policy, trigger, or column contract, update or
add both:

- a SQL-contract test for the server definition; and
- a repository/domain test for the Flutter-side mapping or behavior.

### Integration tests

The current device-driven performance/navigation test is under
`integration_test/`:

```sh
flutter devices
flutter test -d <device-id> integration_test/navigation_frame_timing_test.dart
```

Integration tests require a supported running target. Results can vary with
device performance, debug/profile mode, animations, permissions, and network
state, so record the target and mode when investigating a regression.

## Coverage

Generate Flutter test coverage:

```sh
flutter test --coverage
```

The output is written to `coverage/lcov.info` and is ignored by Git. Coverage
is a diagnostic, not a substitute for assertions around important role,
authorization, payment, and delivery transitions.

## Test organization

```text
test/
  *_test.dart          Unit, widget, repository, and SQL-contract tests
  support/             Shared fixtures, harnesses, fakes, and test helpers
integration_test/
  *_test.dart          Tests executed through a Flutter device target
test_driver/            Legacy integration-test driver support
```

Production code must never import `test/` fixtures or local demo stores.

## What to test by change type

| Change | Minimum relevant validation |
| --- | --- |
| Pure domain rule or validator | Targeted unit test and `flutter analyze` |
| Repository mapping or mutation | Repository tests, error mapping, and affected controller tests |
| Screen or reusable widget | Widget tests for primary states and interactions |
| Authentication or role routing | Session, role-selection, route-guard, and navigation tests |
| Order or payment workflow | Controller/repository tests plus status-transition and validation tests |
| Rider delivery workflow | Matching, acceptance, pickup, evidence, completion, and authorization tests as affected |
| Supabase migration/RPC/RLS | SQL-contract tests, repository tests, and local/staging migration validation |
| Assets, Android manifest, or build config | Analysis, tests, and an appropriate target build/run |

## Reliable test design

- Keep tests deterministic and independent of execution order.
- Use fake clocks or explicit timestamps for expiry and deadline logic.
- Avoid real Supabase, Firebase, GPS, image-picker, or network calls in unit and
  widget tests.
- Assert authorization failures and retry/error states, not only successful
  paths.
- Use representative buyer, farmer, and rider fixtures without real personal
  information or credentials.
- Add a regression test before or with every bug fix when the behavior can be
  reproduced automatically.

## Before handing off a change

Record which commands passed, which targeted tests were used, and any check
that could not run. Do not describe an unexecuted test as passing.
