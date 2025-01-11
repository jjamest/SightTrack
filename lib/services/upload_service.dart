import "dart:convert";
import "dart:typed_data";
import "package:http/http.dart" as http;
import "package:http_parser/http_parser.dart";
import "package:sighttrack_app/logging.dart";
import "package:sighttrack_app/settings.dart";

Future<Map<String, dynamic>> getPresignedURL() async {
  try {
    final response = await http.get(Uri.parse(ApiConstants.getPresignedUrl));
    logger.d(response.body);

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return responseData;
    } else {
      logger.e("Failed to get pre-signed URL: ${response.statusCode}");
      throw Exception("Failed to get pre-signed URL");
    }
  } catch (e) {
    logger.e("Error getting pre-signed URL: $e");
    rethrow;
  }
}

Future<List<dynamic>?> uploadImageToS3(
  Map<String, dynamic> presignedData,
  Uint8List imageBytes,
) async {
  try {
    // Step 1: Get the pre-signed URL and fields
    final String url = presignedData["url"];
    final Map<String, dynamic> fields =
        Map<String, dynamic>.from(presignedData["fields"]);
    final String objectKey = presignedData["object_key"];

    // Step 2: Create a multipart request
    final uri = Uri.parse(url);
    final request = http.MultipartRequest("POST", uri);

    // Step 3: Add the pre-signed fields to the request
    fields.forEach((key, value) {
      request.fields[key] = value;
    });

    // Step 4: Add the image file to the request
    request.files.add(
      http.MultipartFile.fromBytes(
        "file", // The 'file' field is required for S3 uploads
        imageBytes,
        filename: objectKey,
        contentType: MediaType("image", "jpeg"),
      ),
    );

    // Step 5: Send the request
    final response = await request.send();

    if (response.statusCode == 204) {
      logger.i("Image uploaded as $objectKey");

      // Proceed to get labels from the uploaded image
      List<dynamic>? labels = await getLabelsFromAPI(objectKey);
      return labels;
    } else {
      logger.e("Failed to upload image. Status code: ${response.statusCode}");
    }
  } catch (e) {
    logger.e("Error uploading image to S3: $e");
  }
  return null;
}

Future<List<dynamic>?> getLabelsFromAPI(String objectKey) async {
  try {
    final response = await http.post(
      Uri.parse(ApiConstants.analyzePhoto),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"object_key": objectKey}),
    );

    logger.i(response.body);
    logger.i(objectKey);

    if (response.statusCode == 200) {
      dynamic responseData = jsonDecode(response.body);

      Map<String, dynamic> data;

      if (responseData is String) {
        // 'body' is a JSON string; parse it
        data = jsonDecode(responseData);
      } else if (responseData is Map<String, dynamic>) {
        // 'body' is already a Map; use it directly
        data = responseData;
      } else {
        logger.w(
          'Unexpected type for responseData["body"]: ${responseData.runtimeType}',
        );
        return null;
      }

      final labels = data["labels"];

      if (labels != null && labels is List<dynamic>) {
        return labels;
      } else {
        logger.e("No labels found or invalid data format.");
      }
    } else {
      logger.e("Failed to get labels. Status code: ${response.statusCode}");
      logger.t("Response body: ${response.body}");
    }
  } catch (e) {
    logger.e("Error getting labels: $e");
  }
  return null;
}
