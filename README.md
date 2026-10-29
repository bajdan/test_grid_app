# Grid Path Finder

A Flutter app that loads grid tasks from a full API URL, calculates shortest routes, submits the results, and previews each route on its grid.

## Run

```sh
flutter pub get
flutter run
```

Enter a full HTTPS endpoint URL on the Home screen. The app uses that URL for both `GET` and `POST`, including any query parameters. Successfully fetched URLs are saved in local preferences for later selection; do not include secret credentials in query parameters.

## Path rules

Each move visits one adjacent cell in any of eight directions. The destination must be free; diagonal moves may pass between blocked side cells. The app uses breadth-first search to find a path with the fewest moves.

## Verify

```sh
flutter test
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/app_flow_test.dart -d emulator-5554
```
