const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

const db = admin.firestore();

// Data pekerjaan (mengadopsi data dari Flutter)
const jobList = [
  {
    position: "UI/UX Designer",
    companyName: "Creative Studio",
    location: "Jakarta, Indonesia",
    companyLogoPath: "assets/images/logo_creative_studio.png",
    jobType: "Full-time",
    categories: ["Design"],
    jobDetails: {
      jobDescription: "We are looking for a talented UI/UX Designer...",
      requirements: [
        "Bachelor’s degree in Design or related field",
        "2+ years of experience in UI/UX Design",
        "Proficiency in design tools like Figma, Sketch",
      ],
      location: "Jakarta, Indonesia",
      facilities: ["Health Insurance", "Remote Work", "Paid Time Off"],
      companyDetails: {
        aboutCompany: "Creative Studio is a leading design agency...",
        website: "https://creativestudio.com",
        industry: "Creative Industry",
        companyGalleryPaths: [
          "assets/images/gallery1.jpg",
          "assets/images/gallery2.jpg",
        ],
      },
    },
    isApplied: true,
    applyStatus: "inProcess",
    isRecommended: true,
    isSaved: true,
  },
  // Tambahkan data pekerjaan lainnya di sini (copy dari jobList di Flutter)
];

// Function untuk menulis data ke Firestore
exports.addJobsToFirestore = functions.https.onRequest(async (req, res) => {
  try {
    const batch = db.batch(); // Menggunakan batch untuk efisiensi

    jobList.forEach((job, index) => {
      const jobRef = db.collection("jobs").doc(`job_${index + 1}`);
      batch.set(jobRef, job); // Menyimpan data ke Firestore
    });

    await batch.commit(); // Commit semua operasi batch
    res.status(200).send("Data jobs berhasil ditambahkan ke Firestore!");
  } catch (error) {
    console.error("Error adding jobs to Firestore:", error);
    res.status(500).send("Gagal menambahkan data ke Firestore.");
  }
});
