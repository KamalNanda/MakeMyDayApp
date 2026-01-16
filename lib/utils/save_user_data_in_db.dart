import 'package:makemyday/utils/apiService.dart';

Future<void> save_user_data_in_db(Map<String, dynamic> data) async {
  ApiService apiService = ApiService();
  try {
    var response = await apiService.postRequest(
      "/mmd/v1/users/upsert-user",
      data,
    );
    print('Response data: $response');
  } catch (e) {
    print('Error saving user data: $e');
    // Don't rethrow - allow the app to continue even if saving fails
  }
}
