/// UserAddress model matching the backend API response for delivery addresses.
class UserAddress {
  final int id;
  final String fullName;
  final String phone;
  final String addressLine1;
  final String addressLine2;
  final String landmark;
  final String city;
  final String state;
  final String pincode;
  final String label;
  final bool isDefault;

  const UserAddress({
    required this.id,
    this.fullName = '',
    this.phone = '',
    this.addressLine1 = '',
    this.addressLine2 = '',
    this.landmark = '',
    this.city = '',
    this.state = '',
    this.pincode = '',
    this.label = '',
    this.isDefault = false,
  });

  factory UserAddress.fromJson(Map<String, dynamic> json) {
    return UserAddress(
      id: (json['id'] as int?) ?? 0,
      fullName: (json['fullName'] as String?) ?? '',
      phone: (json['phone'] as String?) ?? '',
      addressLine1: (json['addressLine1'] as String?) ?? '',
      addressLine2: (json['addressLine2'] as String?) ?? '',
      landmark: (json['landmark'] as String?) ?? '',
      city: (json['city'] as String?) ?? '',
      state: (json['state'] as String?) ?? '',
      pincode: (json['pincode'] as String?) ?? '',
      label: (json['label'] as String?) ?? '',
      isDefault: (json['default'] == true || json['isDefault'] == true),
    );
  }

  Map<String, dynamic> toJson() => {
        'fullName': fullName,
        'phone': phone,
        'addressLine1': addressLine1,
        'addressLine2': addressLine2,
        'landmark': landmark,
        'city': city,
        'state': state,
        'pincode': pincode,
        'label': label,
      };

  String get formattedAddress {
    final parts = <String>[
      if (addressLine1.isNotEmpty) addressLine1,
      if (addressLine2.isNotEmpty) addressLine2,
      if (city.isNotEmpty) city,
      if (state.isNotEmpty) state,
      if (pincode.isNotEmpty) 'PIN: $pincode',
    ];
    return parts.join(', ');
  }
}