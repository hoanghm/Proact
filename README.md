# Gemini Proact

Leverages Gemini natural language model to generate a custom action plan for the user to achieve a certain goal, built for the 2024 Gemini API dev competition.

## Frontend local deploy

Your IDE may have an integration with Flutter so that you can skip using the `flutter` cli directly for this.

```sh
cd gemini_proact_flutter # app name pending
flutter run -d chrome
```

## Deploy

Currently not integrated with the GitHub repo, so you can deploy the frontend flutter webpages from any branch with the following command.

```sh
firebase deploy -m "description of deployment"
```