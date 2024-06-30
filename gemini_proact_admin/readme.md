# Proact firebase admin

Use this tool when the desired operation is not available using the Firebase web UI.

## Install

1. `cd gemini_proact_admin`
1. `npm install`
1. Download a firebase admin service account key and save to `gemini_proact_admin/service_account_keys/<key-file-name>.json`.
1. Create `.env` and set `service_account_key=<key-file-name>`.

## Delete Firebase Auth user

Currently this tool does not support cli args, so you have to update the source code of `firebase_admin.js` to select the auth user by email.

Find the definition of `user.email` and update to the user you want to delete.

Run with `node firebase_admin.js`.
