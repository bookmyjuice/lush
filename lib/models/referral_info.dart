import 'package:equatable/equatable.dart';

class ReferralInfo extends Equatable {
  final String referralCode;
  final int referralCount;
  final double totalRewardAmount;

  const ReferralInfo({
    required this.referralCode,
    required this.referralCount,
    required this.totalRewardAmount,
  });

  factory ReferralInfo.fromJson(Map<String, dynamic> json) {
    return ReferralInfo(
      referralCode: json['referralCode'] as String? ?? '',
      referralCount: (json['referralCount'] as num?)?.toInt() ?? 0,
      totalRewardAmount: (json['totalRewardAmount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'referralCode': referralCode,
        'referralCount': referralCount,
        'totalRewardAmount': totalRewardAmount,
      };

  @override
  List<Object?> get props => [referralCode, referralCount, totalRewardAmount];
}