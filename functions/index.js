const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.createFirebaseProject = functions.https.onCall(async (data, context) =>{
  const idToken = data.idToken;
  console.log("Auth context:", context.auth);
  console.log("Full context received:", JSON.stringify(context));

  if (!idToken) {
    console.error("No ID token provided");
    throw new functions.https.HttpsError("unauthenticated",
        "No ID token provided.");
  }

  try {
    // Verify the ID token
    const decodedToken = await admin.auth().verifyIdToken(idToken);
    console.log("User authenticated:", decodedToken);

    // Continue with your logic after verifying the token
    const userId = decodedToken.uid;
    console.log(`Authenticated user ID: ${userId}`);

    // Your project creation logic here
    // For example, creating a Firebase project

    return {message: "Project creation logic here"};
  } catch (error) {
    console.error("Error verifying ID token:", error);
    throw new functions.https.HttpsError("unauthenticated",
        "Failed to authenticate user.");
  }
});
