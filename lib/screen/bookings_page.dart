import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/booking.dart';
import '../state/app_state.dart';
import '../utils/booking_rules.dart';

class BookingsPage extends StatelessWidget {
  const BookingsPage({super.key, this.providerMode = false});
  final bool providerMode;
  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final list = providerMode
        ? state.bookings.where((b) => b.providerId == 'p001').toList()
        : state.bookings;
    final upcoming = list
        .where(
          (b) => [
            BookingStatus.pending,
            BookingStatus.confirmed,
            BookingStatus.inProgress,
          ].contains(b.status),
        )
        .toList();
    final history = list
        .where(
          (b) => ![
            BookingStatus.pending,
            BookingStatus.confirmed,
            BookingStatus.inProgress,
          ].contains(b.status),
        )
        .toList();
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(providerMode ? 'Provider jobs' : 'My bookings'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Upcoming'),
              Tab(text: 'History'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _list(context, upcoming, providerMode),
            _list(context, history, providerMode),
          ],
        ),
      ),
    );
  }

  Widget _list(BuildContext context, List<Booking> items, bool providerMode) =>
      items.isEmpty
      ? const Center(child: Text('Nothing here yet'))
      : ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          separatorBuilder: (_, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final booking = items[index];
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            booking.providerName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Chip(label: Text(booking.status.label)),
                      ],
                    ),
                    Text(
                      '${booking.date.day}/${booking.date.month}/${booking.date.year}  •  ${booking.slot}',
                    ),
                    Text('LKR ${booking.total}'),
                    if (providerMode) _providerActions(context, booking),
                    if (!providerMode && canCancel(booking, DateTime.now()))
                      TextButton(
                        onPressed: () => context.read<AppState>().updateBooking(
                          booking.id,
                          BookingStatus.cancelled,
                        ),
                        child: const Text('Cancel booking'),
                      ),
                  ],
                ),
              ),
            );
          },
        );
  Widget _providerActions(BuildContext context, Booking booking) {
    final actions = switch (booking.status) {
      BookingStatus.pending => [
          (label: 'Accept', status: BookingStatus.confirmed),
          (label: 'Reject', status: BookingStatus.rejected),
        ],
      BookingStatus.confirmed => [
          (label: 'Start job', status: BookingStatus.inProgress),
        ],
      BookingStatus.inProgress => [
          (label: 'Mark complete', status: BookingStatus.completed),
        ],
      _ => <({String label, BookingStatus status})>[],
    };
    if (actions.isEmpty) return const SizedBox.shrink();
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: actions
          .map(
            (action) => TextButton(
              onPressed: () async {
                try {
                  await context.read<AppState>().updateBooking(
                    booking.id,
                    action.status,
                  );
                } on StateError catch (error) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(error.message)));
                  }
                }
              },
              style: action.status == BookingStatus.rejected
                  ? TextButton.styleFrom(foregroundColor: Colors.red)
                  : null,
              child: Text(action.label),
            ),
          )
          .toList(),
    );
  }
}
