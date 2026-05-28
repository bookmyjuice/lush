import 'package:equatable/equatable.dart';

/// Represents a single entry in the BottleLedger — a computed view of
/// bottle transactions aggregated by customer and bottle type.
class BottleLedgerEntry extends Equatable {
  final String customerId;
  final String bottleType;
  final int totalIssued;
  final int totalReturned;
  final int totalBroken;
  final int outstanding;
  final String? lastTransactionAt;

  const BottleLedgerEntry({
    required this.customerId,
    required this.bottleType,
    required this.totalIssued,
    required this.totalReturned,
    required this.totalBroken,
    required this.outstanding,
    this.lastTransactionAt,
  });

  factory BottleLedgerEntry.fromJson(Map<String, dynamic> json) {
    return BottleLedgerEntry(
      customerId: json['customerId'] as String? ?? '',
      bottleType: json['bottleType'] as String? ?? '',
      totalIssued: json['totalIssued'] as int? ?? 0,
      totalReturned: json['totalReturned'] as int? ?? 0,
      totalBroken: json['totalBroken'] as int? ?? 0,
      outstanding: json['outstanding'] as int? ?? 0,
      lastTransactionAt: json['lastTransactionAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'customerId': customerId,
        'bottleType': bottleType,
        'totalIssued': totalIssued,
        'totalReturned': totalReturned,
        'totalBroken': totalBroken,
        'outstanding': outstanding,
        'lastTransactionAt': lastTransactionAt,
      };

  @override
  List<Object?> get props => [
        customerId,
        bottleType,
        totalIssued,
        totalReturned,
        totalBroken,
        outstanding,
        lastTransactionAt,
      ];
}

/// Represents a single bottle transaction record.
class BottleTransaction extends Equatable {
  final int? id;
  final String orderId;
  final String customerId;
  final String bottleType;
  final int quantity;
  final String action; // ISSUED | RETURNED | BROKEN
  final String? referenceId;
  final String? notes;
  final String? createdAt;
  final String? updatedAt;

  const BottleTransaction({
    this.id,
    required this.orderId,
    required this.customerId,
    required this.bottleType,
    required this.quantity,
    required this.action,
    this.referenceId,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory BottleTransaction.fromJson(Map<String, dynamic> json) {
    return BottleTransaction(
      id: json['id'] as int?,
      orderId: json['orderId'] as String? ?? '',
      customerId: json['customerId'] as String? ?? '',
      bottleType: json['bottleType'] as String? ?? '',
      quantity: json['quantity'] as int? ?? 0,
      action: json['action'] as String? ?? '',
      referenceId: json['referenceId'] as String?,
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'orderId': orderId,
        'customerId': customerId,
        'bottleType': bottleType,
        'quantity': quantity,
        'action': action,
        'referenceId': referenceId,
        'notes': notes,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };

  @override
  List<Object?> get props => [
        id,
        orderId,
        customerId,
        bottleType,
        quantity,
        action,
        referenceId,
        notes,
        createdAt,
        updatedAt,
      ];
}
