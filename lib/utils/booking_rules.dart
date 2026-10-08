import '../models/booking.dart';

int calculateTotal({required int hourlyRate, required int hours, required DateTime date}) {
  final labour = hourlyRate * hours;
  final weekend = date.weekday == DateTime.saturday ? (labour * 0.15).round() : 0;
  return labour + 500 + weekend;
}

bool isValidPhone(String value) => RegExp(r'^(07\d{8}|\+947\d{8})$').hasMatch(value.trim());

bool isAvailableSlot(List<Booking> bookings, String providerId, DateTime date, String slot) =>
    !bookings.any((booking) =>
        booking.providerId == providerId &&
        booking.date.year == date.year &&
        booking.date.month == date.month &&
        booking.date.day == date.day &&
        booking.slot == slot &&
        [BookingStatus.pending, BookingStatus.confirmed, BookingStatus.inProgress]
            .contains(booking.status));

BookingStatus? nextStatus(BookingStatus current, String action) {
  if (current == BookingStatus.pending && action == 'accept') return BookingStatus.confirmed;
  if (current == BookingStatus.pending && action == 'reject') return BookingStatus.rejected;
  if (current == BookingStatus.confirmed && action == 'start') return BookingStatus.inProgress;
  if (current == BookingStatus.inProgress && action == 'complete') return BookingStatus.completed;
  return null;
}

bool canCancel(Booking booking, DateTime now) =>
    [BookingStatus.pending, BookingStatus.confirmed].contains(booking.status) &&
    booking.date.difference(now).inHours > 24;
