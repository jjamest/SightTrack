/*
  SightTrackMainGateway

  Updated API urls
*/
class ApiConstants {
  static const String baseURL =
      'https://hy6sxmw15g.execute-api.us-east-1.amazonaws.com/prod';
  static const String getPresignedUrl =
      'https://hy6sxmw15g.execute-api.us-east-1.amazonaws.com/prod/getPresignedUrl';
  static const String analyzePhoto =
      'https://hy6sxmw15g.execute-api.us-east-1.amazonaws.com/prod/analyzePhoto';
  static const String savePhotoMarker =
      'https://hy6sxmw15g.execute-api.us-east-1.amazonaws.com/prod/savePhotoMarker';
  static const String getPhotoMarkers =
      'https://hy6sxmw15g.execute-api.us-east-1.amazonaws.com/prod/getPhotoMarkers';
  static const String getAnalysis =
      'https://hy6sxmw15g.execute-api.us-east-1.amazonaws.com/prod/getAnalysis';
}

/*
  Deprecated URLs
  Separate APIs
*/
// class ApiConstants {
//   static const String getPresignedURL =
//       'https://i6683l9uod.execute-api.us-east-1.amazonaws.com/prod/get-presigned-url';
//   static const String rekognitionURL =
//       'https://i6683l9uod.execute-api.us-east-1.amazonaws.com/prod/analyze';
//   static const String dynamoSaveURL =
//       'https://ry9z08o9pd.execute-api.us-east-1.amazonaws.com/prod/savePhotoMetadata';
//   static const String dynamoRetrieveURL =
//       'https://ry9z08o9pd.execute-api.us-east-1.amazonaws.com/prod/getPhotoMarkers';
//   static const String analysisURL =
//       'https://7cmdtvnqj6.execute-api.us-east-1.amazonaws.com/prod/getDataAnalysis';
// }
