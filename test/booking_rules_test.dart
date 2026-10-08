import 'package:flutter_test/flutter_test.dart';
import 'package:fixora/models/booking.dart';
import 'package:fixora/utils/booking_rules.dart';

void main() {
  test('calculates Saturday surcharge and visiting charge', () {
    final total = calculateTotal(
      hourlyRate: 2000,
      hours: 2,
      date: DateTime(2026, 10, 10),
    );
    expect(total, 5100);
  });

  test('blocks invalid status transitions', () {
    expect(nextStatus(BookingStatus.pending, 'start'), isNull);
    expect(
      nextStatus(BookingStatus.confirmed, 'start'),
      BookingStatus.inProgress,
    );
    expect(nextStatus(BookingStatus.pending, 'reject'), BookingStatus.rejected);
    expect(nextStatus(BookingStatus.confirmed, 'reject'), isNull);
  });

  test('blocks active double booking', () {
    final date = DateTime(2026, 10, 10);
    final booking = Booking(
      id: '1',
      providerId: 'p001',
      providerName: 'Kamal',
      category: 'plumbing',
      date: date,
      slot: '8–10 AM',
      customerName: 'Asha',
      phone: '0712345678',
      address: '123 Main Street',
      hours: 2,
      description: 'Fix the kitchen sink please',
      total: 4500,
    );
    expect(isAvailableSlot([booking], 'p001', date, '8–10 AM'), isFalse);
    expect(isAvailableSlot([booking], 'p001', date, '10 AM–12 PM'), isTrue);
    expect(
      isAvailableSlot(
        [booking.copyWith(status: BookingStatus.rejected)],
        'p001',
        date,
        '8–10 AM',
      ),
      isTrue,
    );
  });

  test('validates Sri Lankan mobile numbers', () {
    expect(isValidPhone('0712345678'), isTrue);
    expect(isValidPhone('+94712345678'), isTrue);
    expect(isValidPhone('0812345678'), isFalse);
  });

  test('does not add weekend surcharge on a weekday', () {
    final total = calculateTotal(
      hourlyRate: 2000,
      hours: 2,
      date: DateTime(2026, 10, 9),
    );

    expect(total, 4500);
  });
}
