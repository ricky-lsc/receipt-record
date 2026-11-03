import 'package:uuid/uuid.dart';

class SplitParticipant {
  final String id;
  String name;
  double amount;
  bool isPaid;

  SplitParticipant({
    required this.id,
    required this.name,
    required this.amount,
    this.isPaid = false,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'amount': amount,
        'isPaid': isPaid,
      };

  factory SplitParticipant.fromMap(Map<String, dynamic> map) {
    return SplitParticipant(
      id: map['id'] as String? ?? const Uuid().v4(),
      name: map['name'] as String? ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      isPaid: map['isPaid'] as bool? ?? false,
    );
  }

  SplitParticipant copyWith({
    String? id,
    String? name,
    double? amount,
    bool? isPaid,
  }) {
    return SplitParticipant(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      isPaid: isPaid ?? this.isPaid,
    );
  }
}

class ReceiptSplit {
  final List<SplitParticipant> participants;
  final bool isCustomized;

  const ReceiptSplit({
    required this.participants,
    this.isCustomized = false,
  });

  double get totalAllocated =>
      participants.fold(0.0, (sum, p) => sum + p.amount);

  Map<String, dynamic> toMap() => {
        'participants': participants.map((p) => p.toMap()).toList(),
        'isCustomized': isCustomized,
      };

  factory ReceiptSplit.fromMap(Map<String, dynamic> map) {
    return ReceiptSplit(
      participants: (map['participants'] as List<dynamic>?)
              ?.map((p) => SplitParticipant.fromMap(p as Map<String, dynamic>))
              .toList() ??
          [],
      isCustomized: map['isCustomized'] as bool? ?? false,
    );
  }

  ReceiptSplit copyWith({
    List<SplitParticipant>? participants,
    bool? isCustomized,
  }) {
    return ReceiptSplit(
      participants: participants ?? this.participants,
      isCustomized: isCustomized ?? this.isCustomized,
    );
  }
}
