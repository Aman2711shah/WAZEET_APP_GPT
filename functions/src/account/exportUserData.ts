import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import archiver from "archiver";
import * as fs from "fs";
import * as path from "path";
import * as os from "os";

/**
 * Export all user data as a downloadable ZIP archive
 * HTTPS Callable function that requires authentication
 */
export const exportUserData = functions.https.onCall(async (data, context) => {
    // Verify authentication
    if (!context.auth) {
        throw new functions.https.HttpsError(
            "unauthenticated",
            "User must be authenticated to export data"
        );
    }

    const userId = context.auth.uid;
    const db = admin.firestore();
    const storage = admin.storage();

    try {
        // Create temporary directory for export files
        const tmpDir = fs.mkdtempSync(path.join(os.tmpdir(), "user-export-"));
        const zipPath = path.join(tmpDir, `user-data-${userId}.zip`);

        // Create write stream for ZIP
        const output = fs.createWriteStream(zipPath);
        const archive = archiver("zip", { zlib: { level: 9 } });

        // Pipe archive to file
        archive.pipe(output);

        // 1. Export user document
        const userDoc = await db.collection("users").doc(userId).get();
        if (userDoc.exists) {
            archive.append(
                JSON.stringify(userDoc.data(), null, 2),
                { name: "user-profile.json" }
            );
        }

        // 2. Export user preferences
        const preferencesDoc = await db.collection("users").doc(userId)
            .collection("preferences").doc(userId).get();
        if (preferencesDoc.exists) {
            archive.append(
                JSON.stringify(preferencesDoc.data(), null, 2),
                { name: "preferences.json" }
            );
        }

        // 3. Export user activity/history (if you have such collections)
        const activitySnapshot = await db.collection("users").doc(userId)
            .collection("activity").get();
        if (!activitySnapshot.empty) {
            const activities = activitySnapshot.docs.map((doc) => ({
                id: doc.id,
                ...doc.data(),
            }));
            archive.append(
                JSON.stringify(activities, null, 2),
                { name: "activity.json" }
            );
        }

        // 4. Export any other user-related collections
        // Add more collections here as needed
        const collectionsToExport = [
            "bookings",
            "favorites",
            "reviews",
            "applications",
        ];

        for (const collectionName of collectionsToExport) {
            const collectionSnapshot = await db.collection(collectionName)
                .where("userId", "==", userId)
                .get();

            if (!collectionSnapshot.empty) {
                const items = collectionSnapshot.docs.map((doc) => ({
                    id: doc.id,
                    ...doc.data(),
                }));
                archive.append(
                    JSON.stringify(items, null, 2),
                    { name: `${collectionName}.json` }
                );
            }
        }

        // 5. Export metadata
        const metadata = {
            exportDate: new Date().toISOString(),
            userId: userId,
            version: "1.0",
            dataIncluded: [
                "user-profile",
                "preferences",
                "activity",
                ...collectionsToExport,
            ],
        };
        archive.append(
            JSON.stringify(metadata, null, 2),
            { name: "export-metadata.json" }
        );

        // Finalize archive
        await archive.finalize();

        // Wait for the stream to finish
        await new Promise<void>((resolve, reject) => {
            output.on("close", () => resolve());
            output.on("error", reject);
        });

        // Upload ZIP to Firebase Storage
        const bucket = storage.bucket();
        const destination = `exports/${userId}/user-data-${Date.now()}.zip`;
        await bucket.upload(zipPath, {
            destination: destination,
            metadata: {
                contentType: "application/zip",
                metadata: {
                    userId: userId,
                    exportDate: new Date().toISOString(),
                },
            },
        });

        // Generate signed URL (expires in 1 hour)
        const file = bucket.file(destination);
        const [signedUrl] = await file.getSignedUrl({
            action: "read",
            expires: Date.now() + 60 * 60 * 1000, // 1 hour
        });

        // Clean up temporary files
        fs.unlinkSync(zipPath);
        fs.rmdirSync(tmpDir);

        return {
            url: signedUrl,
            expiresAt: new Date(Date.now() + 60 * 60 * 1000).toISOString(),
        };
    } catch (error) {
        console.error("Error exporting user data:", error);
        throw new functions.https.HttpsError(
            "internal",
            "Failed to export user data",
            error
        );
    }
});
