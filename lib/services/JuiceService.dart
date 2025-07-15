// import 'package:lush/UserRepository/userRepository.dart';
// import 'package:lush/getIt.dart';
// import 'package:lush/views/models/DynamicJuice.dart';
// import 'package:lush/views/models/Juice.dart';

// class JuiceService {
//   final UserRepository _userRepository = getIt.get<UserRepository>();
  
//   /// Fetch juices from backend and convert to DynamicJuice objects
//   Future<List<DynamicJuice>> fetchJuices() async {
//     try {
//       List<Map<String, dynamic>> apiResponse = await _userRepository.getChargeItems();
      
//       List<DynamicJuice> juices = apiResponse
//           .map((json) => DynamicJuice.fromApiResponse(json))
//           .where((juice) => juice.isDisplayReady()) // Filter out inactive/incomplete items
//           .toList();
      
//       // Sort by popularity (if available) or alphabetically
//       juices.sort((a, b) {
//         if (a.popularity != b.popularity) {
//           return b.popularity.compareTo(a.popularity); // Higher popularity first
//         }
//         return a.displayName.compareTo(b.displayName); // Alphabetical fallback
//       });
      
//       return juices;
//     } catch (e) {
//       print('Error fetching juices from backend: $e');
//       // Return fallback data based on static juice list
//       return _getFallbackJuices();
//     }
//   }

//   /// Get fallback juices based on the original static data
//   List<DynamicJuice> _getFallbackJuices() {
//     return Juice.tabIconsList.map((juice) {
//       return DynamicJuice(
//         juiceID: juice.juiceID.toString(),
//         name: juice.titleTxt,
//         description: '${juice.titleTxt} juice',
//         imagePath: juice.imagePath,
//         startColor: juice.startColor,
//         endColor: juice.endColor,
//         meals: juice.meals ?? [],
//         kacl: juice.kacl,
//         type: 'CHARGE',
//         status: 'ACTIVE',
//         enabledForCheckout: true,
//         enabledInPortal: true,
//         category: 'juice',
//       );
//     }).toList();
//   }

//   /// Convert DynamicJuice to old Juice format for backward compatibility
//   List<Juice> convertToOldJuiceFormat(List<DynamicJuice> dynamicJuices) {
//     return dynamicJuices.asMap().entries.map((entry) {
//       int index = entry.key;
//       DynamicJuice dynamic = entry.value;
      
//       // Use index as fallback if parsing fails to ensure unique IDs
//       int juiceId = int.tryParse(dynamic.juiceID) ?? index;
      
//       return Juice(
//         juiceID: juiceId,
//         imagePath: dynamic.imagePath,
//         titleTxt: dynamic.displayName, // Use displayName which prioritizes externalName
//         startColor: dynamic.startColor,
//         endColor: dynamic.endColor,
//         meals: dynamic.meals,
//         kacl: dynamic.kacl,
//       );
//     }).toList();
//   }
// }