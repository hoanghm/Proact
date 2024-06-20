# Gemini Proact

Leverages Gemini natural language model to generate a custom action plan for the user to achieve a certain goal, built for the 2024 Gemini API dev competition.

## Frontend local deploy

Your IDE may have an integration with Flutter so that you can skip using the `flutter` cli directly for this.

### Frontend local deploy as webpage to chrome browser

```sh
cd gemini_proact_flutter
flutter run -d chrome
```

## Deploy flutter frontend

Currently not integrated with the GitHub repo, so you can deploy the frontend flutter webpages from any branch with the following command.

The `gemini_proact_flutter/.env` environment variables file, even though this is not compatible with the web deployment, is used in the below example.

```sh
# build with custom options
cd gemini_proact_flutter
flutter build web --dart-define-from-file ".env"

# deploy to firebase web hosting
cd ..
firebase deploy --only "hosting" -m "<description of deployment version>"
```

### firebase config

Firebase deployment is configured in `firebase.json`.

#### `firebase.json` comments

`functions.predeploy.0` In order to pass custom options to `flutter build`, I disable