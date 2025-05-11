/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

// const {onRequest} = require("firebase-functions/v2/https");
// const logger = require("firebase-functions/logger");

const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

const firestore = admin.firestore();

/**
 * Callable function to delete a user and all subcollections.
 */
exports.recursiveDeleteUser = functions.https.onCall(async (data, context) => {
  const uid = data.uid;
  const path = `users/${uid}`;

  console.log(`Starting recursive delete of ${path}`);

  try {
    await admin.firestore().recursiveDelete(firestore.doc(path));
    console.log(`Successfully deleted ${path}`);
    return {success: true};
  } catch (error) {
    console.error(`Error deleting ${path}`, error);
    throw new functions.https.HttpsError("internal", "Delete failed");
  }
});

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
