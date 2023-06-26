import { google } from "googleapis";
import * as fs from "fs";
import { join } from "path";

enum TRACK {
  "production" = "production",
  "internal" = "internal",
  "alpha" = "alpha",
  "beta" = "beta",
}

const credentials = require("./privateKey.json");

async function uploadAabFile(
  packageName: string,
  track: TRACK,
  aabFilePath: string,
  version: string
): Promise<void> {
  try {
    // Configure the authentication
    const auth = new google.auth.GoogleAuth({
      credentials,
      scopes: ["https://www.googleapis.com/auth/androidpublisher"],
    });

    // Create the publisher client
    const androidPublisher = google.androidpublisher({ version: "v3", auth });
    console.log(`Uploading version ${version} to '${track}' track...`);

    const editId = await androidPublisher.edits.insert({ packageName }).then((res) => String(res.data.id));
    console.log("Edit Id:", editId);

    if (!fs.existsSync(aabFilePath)) return console.log("File not found:", aabFilePath);
    console.log("Upload the AAB file...");
    const uploadResponse = await androidPublisher.edits.bundles.upload({
      packageName,
      editId,
      media: {
        mimeType: "application/octet-stream",
        body: fs.createReadStream(aabFilePath),
      },
    });
    console.log(`uploadResponse: ${JSON.stringify(uploadResponse.data)}`);

    const { versionCode } = uploadResponse.data;
    console.log("Version code:", versionCode);

    // Assign the uploaded AAB to a release track
    androidPublisher.edits.tracks.update({
      packageName,
      editId,
      track,
      requestBody: {
        releases: [{ name: version, versionCodes: [`${versionCode}`], status: "completed" }],
      },
    });

    console.log("AAB file uploaded and assigned to the track.");
    await androidPublisher.edits.commit({
      packageName,
      editId,
    });

    console.log("Changes committed successfully.");
  } catch (error: any) {
    console.error("Error publishing AAB file:", error.message);
  }
}

async function main() {
  if (!Object.values(TRACK).includes(track)) {
    return console.log("Please specify the track (e.g., 'production',  'internal', 'alpha', 'beta')");
  }
  const packageName = "com.nternouski.budget";

  const relativePath = "../build/app/outputs/bundle/release/app-release.aab";
  const aabFilePath = join(__dirname, relativePath);

  await uploadAabFile(packageName, track, aabFilePath, version);
}

const track = process.argv[2] as TRACK;
const version = process.argv[3];

main();
