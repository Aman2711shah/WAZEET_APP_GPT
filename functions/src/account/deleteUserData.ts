import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

/**
 * Delete all user data from Firestore and Storage
 * HTTPS Callable function that requires authentication
 * Should be called BEFORE deleting the Firebase Auth user
 */
export const deleteUserData = functions.https.onCall(async (data, context) => {
    // Verify authentication
    if (!context.auth) {
        throw new functions.https.HttpsError(
            "unauthenticated",
            "User must be authenticated to delete data"
        );
    }

    const userId = context.auth.uid;
    const db = admin.firestore();
    const storage = admin.storage();

    try {
        // Safety check: Ensure the user is deleting their own data
        if (data && data.userId && data.userId !== userId) {
            throw new functions.https.HttpsError(
                "permission-denied",
                "Users can only delete their own data"
            );
        }

        // 1. Delete user document and all subcollections
        await deleteUserDocument(db, userId);

        // 2. Delete user-related documents in other collections
        await deleteUserRelatedDocuments(db, userId);

        // 3. Delete user files from Storage
        await deleteUserFiles(storage, userId);

        // 4. Delete exports folder
        await deleteUserExports(storage, userId);

        functions.logger.info(`Successfully deleted all data for user: ${userId}`);

        return {
            success: true,
            message: "All user data has been permanently deleted",
            deletedAt: new Date().toISOString(),
        };
    } catch (error) {
        functions.logger.error("Error deleting user data:", error);
        throw new functions.https.HttpsError(
            "internal",
            "Failed to delete user data",
            error
        );
    }
});

/**
 * Delete user document and all subcollections
 */
async function deleteUserDocument(
    db: admin.firestore.Firestore,
    userId: string
): Promise<void> {
    const userRef = db.collection("users").doc(userId);

    // Delete all subcollections
    const subcollections = ["preferences", "activity", "notifications"];

    for (const subcollection of subcollections) {
        const subcollectionRef = userRef.collection(subcollection);
        await deleteCollection(db, subcollectionRef, 100);
    }

    // Delete the user document itself
    await userRef.delete();
    functions.logger.info(`Deleted user document: ${userId}`);
}

/**
 * Delete user-related documents in other collections
 */
async function deleteUserRelatedDocuments(
    db: admin.firestore.Firestore,
    userId: string
): Promise<void> {
    const collections = [
        "bookings",
        "favorites",
        "reviews",
        "applications",
        "messages",
    ];

    for (const collectionName of collections) {
        const snapshot = await db.collection(collectionName)
            .where("userId", "==", userId)
            .get();

        if (!snapshot.empty) {
            const batch = db.batch();
            snapshot.docs.forEach((doc) => {
                batch.delete(doc.ref);
            });
            await batch.commit();
            functions.logger.info(
                `Deleted ${snapshot.size} documents from ${collectionName}`
            );
        }
    }
}

/**
 * Delete user files from Storage
 */
async function deleteUserFiles(
    storage: admin.storage.Storage,
    userId: string
): Promise<void> {
    const bucket = storage.bucket();

    // Delete profile pictures
    const [profilePictures] = await bucket.getFiles({
        prefix: `profile_pictures/${userId}/`,
    });

    for (const file of profilePictures) {
        await file.delete();
    }

    if (profilePictures.length > 0) {
        functions.logger.info(
            `Deleted ${profilePictures.length} profile picture(s)`
        );
    }

    // Delete any other user-specific files
    const userPaths = [
        `applications/${userId}/`,
        `documents/${userId}/`,
        `uploads/${userId}/`,
    ];

    for (const pathPrefix of userPaths) {
        const [files] = await bucket.getFiles({ prefix: pathPrefix });
        for (const file of files) {
            await file.delete();
        }
        if (files.length > 0) {
            functions.logger.info(`Deleted ${files.length} files from ${pathPrefix}`);
        }
    }
}

/**
 * Delete user exports folder
 */
async function deleteUserExports(
    storage: admin.storage.Storage,
    userId: string
): Promise<void> {
    const bucket = storage.bucket();
    const [exports] = await bucket.getFiles({
        prefix: `exports/${userId}/`,
    });

    for (const file of exports) {
        await file.delete();
    }

    if (exports.length > 0) {
        functions.logger.info(`Deleted ${exports.length} export file(s)`);
    }
}

/**
 * Delete a collection in batches
 */
async function deleteCollection(
    db: admin.firestore.Firestore,
    collectionRef: admin.firestore.CollectionReference,
    batchSize: number
): Promise<void> {
    const query = collectionRef.limit(batchSize);

    return new Promise((resolve, reject) => {
        deleteQueryBatch(db, query, resolve).catch(reject);
    });
}

/**
 * Delete query batch recursively
 */
async function deleteQueryBatch(
    db: admin.firestore.Firestore,
    query: admin.firestore.Query,
    resolve: () => void
): Promise<void> {
    const snapshot = await query.get();

    const batchSize = snapshot.size;
    if (batchSize === 0) {
        resolve();
        return;
    }

    const batch = db.batch();
    snapshot.docs.forEach((doc) => {
        batch.delete(doc.ref);
    });
    await batch.commit();

    process.nextTick(() => {
        deleteQueryBatch(db, query, resolve);
    });
}
