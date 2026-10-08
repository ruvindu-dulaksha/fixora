enum BookingStatus { pending, confirmed, inProgress, completed, cancelled, rejected }

extension BookingStatusText on BookingStatus {
  String get label => switch (this) {
        BookingStatus.pending => 'Pending',
        BookingStatus.confirmed => 'Confirmed',
        BookingStatus.inProgress => 'In Progress',
        BookingStatus.completed => 'Completed',
        BookingStatus.cancelled => 'Cancelled',
        BookingStatus.rejected => 'Rejected',
      };
}

class Booking {
  const Booking({
    required this.id,
    required this.providerId,
    required this.providerName,
    required this.category,
    required this.date,
    required this.slot,
    required this.customerName,
    required this.phone,
    required this.address,
    required this.hours,
    required this.description,
    required this.total,
    this.status = BookingStatus.pending,
  });

  final String id;
  final String providerId;
  final String providerName;
  final String category;
  final DateTime date;
  final String slot;
  final String customerName;
  final String phone;
  final String address;
  final int hours;
  final String description;
  final int total;
  final BookingStatus status;

  Booking copyWith({BookingStatus? status}) => Booking(
        id: id,
        providerId: providerId,
        providerName: providerName,
        category: category,
        date: date,
        slot: slot,
        customerName: customerName,
        phone: phone,
        address: address,
        hours: hours,
        description: description,
        total: total,
        status: status ?? this.status,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'providerId': providerId,
        'providerName': providerName,
        'category': category,
        'date': date.toIso8601String(),
        'slot': slot,
        'customerName': customerName,
        'phone': phone,
        'address': address,
        'hours': hours,
        'description': description,
        'total': total,
        'status': status.name,
      };

  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
        id: json['id'] as String,
        providerId: json['providerId'] as String,
        providerName: json['providerName'] as String,
        category: json['category'] as String,
        date: DateTime.parse(json['date'] as String),
        slot: json['slot'] as String,
        customerName: json['customerName'] as String,
        phone: json['phone'] as String,
        address: json['address'] as String,
        hours: json['hours'] as int,
        description: json['description'] as String,
        total: json['total'] as int,
        status: BookingStatus.values.byName(json['status'] as String),
      );
}
