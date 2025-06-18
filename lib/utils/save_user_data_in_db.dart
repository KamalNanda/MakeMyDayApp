  import 'package:makemyday/utils/apiService.dart';

void save_user_data_in_db(Map<String, dynamic> data) async {
    ApiService apiService = ApiService();
    try {
      var response = await apiService.postRequest(
        "/mmd/v1/users/upsert-user", data
      );
      print('Response data: ${response.data}');
 
    } catch (e) {
      print(e);
    }
  }