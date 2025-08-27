const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

const db = admin.firestore();

exports.generateDailyQuizzes = functions.pubsub
  .schedule("every day 00:01")
  .onRun(async (context) => {
    const today = new Date();
    const dateStr = today.toISOString().slice(0, 10); // yyyy-mm-dd

    // 1. Get all tutors
    const tutorsSnap = await db.collection("tutors").get();
    for (const tutorDoc of tutorsSnap.docs) {
      const tutorId = tutorDoc.id;

      // 2. Get all categories for this tutor
      const categoriesSnap = await db
        .collection("categories")
        .where("tutorId", "==", tutorId)
        .get();

      let allQuestions = [];
      for (const catDoc of categoriesSnap.docs) {
        const catId = catDoc.id;
        // 3. Get all questions in this category
        const questionsSnap = await db
          .collection("categories")
          .doc(catId)
          .collection("questions")
          .get();
        questionsSnap.forEach((qDoc) => {
          allQuestions.push(qDoc.data());
        });
      }

      if (allQuestions.length === 0) continue;

      // 4. Shuffle and pick 10
      allQuestions = shuffleArray(allQuestions).slice(0, 10);

      // 5. Write to daily_quizzes/{date}_{tutorId}
      await db
        .collection("daily_quizzes")
        .doc(`${dateStr}_${tutorId}`)
        .set({
          tutorId,
          date: dateStr,
          questions: allQuestions,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });
    }
    return null;
  });

/**
 * Shuffles array in place.
 * @param {Array} array The array to shuffle.
 * @returns {Array} The shuffled array.
 */
function shuffleArray(array) {
  for (let i = array.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [array[i], array[j]] = [array[j], array[i]];
  }
  return array;
}
