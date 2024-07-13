# Gemini Proact

Leverages Gemini natural language model to generate a custom action plan for the user to achieve a certain goal, built for the 2024 Gemini API dev competition.

# Firebase config

Firebase deployment is configured in `firebase.json`, under the project selected as default in `.firebaserc`.

> **TODO** Note these instructions are from before multi-app integration between flutter and firebase was done. I think `firebase.json` is now deprecated in favor of `gemini_proact_flutter/firebase.json`.

## Frontend local deploy

Your IDE may have an integration with Flutter so that you can skip using the `flutter` cli directly for this.

### Frontend local deploy as webpage to chrome browser

```sh
cd gemini_proact_flutter
flutter run -d chrome
```

### Frontend local deploy as mobile app to Android simulator

```sh
cd gemini_proact_flutter
flutter build apk --dart-define-from-file .env --debug

# find devices; one should be that is running android emulator
flutter devices

# in my case, emulator device id is "emulator-5554"
flutter run -d emulator-5554 --use-application-binary "build/app/outputs/flutter-apk/app-debug.apk"
```

## Deploy flutter frontend

Currently not integrated with the GitHub repo, so you can deploy the frontend flutter webpages from any branch with the following command.

The `gemini_proact_flutter/.env` environment variables file, even though this is not compatible with the web deployment, is used in the below example to illustrate the option.

```sh
# build with custom options
cd gemini_proact_flutter
flutter build web --dart-define-from-file ".env"

# deploy to firebase web hosting
cd ..
firebase deploy --only "hosting" -m "<description of deployment version>"
```

## Backend local deploy

```sh
image="gemini-proact-server:latest"
container="gemini-proact-server"
server_port=8080
host_port=54321

# docker build image described in Dockerfile
docker build -pull --rm -f "gemini_proact_server/Dockerfile" -t $image "gemini_proact_server"

docker container create --publish $host_port:$server_port --name "$container" --env PORT=$server_port "$image"

docker container run $container
```

Now you can test sending requests to `https://localhost:$host_port` using the locally deployed container. 

To skip the local container deployment for a full mock of how it would run in Google Cloud Run:

<!--TODO cli_wrapper no longer exists -->

```sh
cd gemini_proact_server && python cli_wrapper.py
```

and test sending requests to `https://localhost:$server_port`.

## Backend test components

Many individual components have some live tests written when called as entrypoints.

### `FirebaseClient`

```sh
cd gemini_proact_server
python -m database.FirebaseClient
```

### `GeminiClient`

```sh
cd gemini_proact_server
python -m GeminiClient
```

## Deploy python-flask backend

This project is deployed to Google Cloud Run as service **gemini-proact-server** under the same project selected in `.firebaserc`.

```sh
project="gemini-goalkeeper-2024"
service="gemini-proact-server"
region="us-east1"

cd gemini_proact_server
# submit container image to registry
gcloud builds submit --tag "gcr.io/$project/$service"
# deploy to cloud run
gcloud run deploy $service --image "gcr.io/$project/$service" --region $region
```

## `firebase.json` comments

### `hosting.rewrites.run`

Instead of using the `hosting.public` frontend website, firebase uses the specified google cloud run service (here, our internal api server) to handle the requests for the given path prefix.

**However**, this is not yet correctly configured, as the api server does not handle the current path prefix.

### `hosting.rewrites.run.pinTag`

If `true`, this syncronizes deployment versioning between the `hosting.public` frontend and `hosting.rewrites.run.serviceId` backend.
