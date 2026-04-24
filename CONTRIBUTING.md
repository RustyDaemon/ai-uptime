# Contributing

Thanks for helping improve AI Uptime.

## Before you start

- Search existing issues and pull requests before starting similar work.
- Open or comment on an issue before making large behavior changes or new features.
- Keep pull requests focused. Small, reviewable changes are easier to merge.

## Local setup

1. Install Flutter with desktop support enabled.
2. Fetch dependencies:

   ```bash
   flutter pub get
   ```

3. Run the app on your target platform:

   ```bash
   flutter run -d macos
   flutter run -d linux
   ```

## Development expectations

- Follow the existing project structure and Riverpod-based state flow.
- Update docs when behavior, setup, or user-visible flows change.
- Avoid unrelated refactors in the same pull request.
- Prefer clear, direct fixes over speculative cleanup.

## Validation

Run the existing checks before opening a pull request:

```bash
flutter analyze
flutter test
```

## Pull requests

Include:

- a short summary of the change
- any screenshots or notes for user-visible UI changes
- testing notes covering what you ran

If your change touches platform-specific behavior, mention which platform you verified.
