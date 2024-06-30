import * as dotEnv from 'dotenv'
import { initializeApp, cert } from 'firebase-admin/app'
import { getAuth, UserRecord } from 'firebase-admin/auth'
import * as fs from 'node:fs/promises'

async function main() {
    // load env variables into process.env
    dotEnv.config({
        path: '.env'
    })

    // TODO find and select service account keys dynamically
    console.log(`info load firebase service account credentials`)
    /**
     * @type {{
     *  project_id: string
     * }}
     */
    const serviceAccount = await fs.readFile(
        `./service_account_keys/${process.env.service_account_key}.json`,
        undefined,
        'r'
    )
    .then(JSON.parse)
    // console.log(`debug service account = ${JSON.stringify(serviceAccount)}`)
    const databaseUrl = process.env.database_url || undefined

    const firebaseApp = initializeApp({
        credential: cert(serviceAccount),
        name: serviceAccount.project_id
    })
    console.log(`info initialized firebase admin for ${firebaseApp.name}`)

    /**
     * @type {{
     *  documentId: string?,
     *  email: string,
     *  authUser: UserRecord
     * }}
     */
    const user = {
        documentId: null,
        email: 'apple@host.tld',
        authUser: null
    }
    console.log(`info get user ${user.email}`)
    const firebaseAuth = getAuth()
    try {
        user.authUser = await firebaseAuth.getUserByEmail(user.email)
        console.log(`into firebase auth user ${user.email} uid=${user.authUser.uid}`)
        
        console.log(`info delete user ${user.email}=${user.authUser.uid}`)
        try {
            await firebaseAuth.deleteUser(user.authUser.uid)
            console.log(`info user ${user.email} deleted`)
        }
        catch (err) {
            console.log(`error failed to delete auth user ${user.email}. ${err}`)
        }
    }
    catch (err) {
        console.log(`error ${err}`)
        throw err
    }
}

import('temp_js_logger').then((logger_mod) => {
    const temp_logger = logger_mod.default
    temp_logger.imports_promise.then(main)
})

