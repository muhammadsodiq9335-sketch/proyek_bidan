import '../models/user_profile.dart';

class AppState {
  static UserProfile? currentUser;
  static List<Map<String, dynamic>> userReservations = [];
  
  // You can add more global state variables here as needed during migration
}
