import '../lib/models/journey.dart';

void main() {
  print('Testing Journey.incrementRead behavior');

  // Conditional prayer: timesPerDay = 3
  final cond = Journey(
    id: 'cond1',
    prayerId: 'p1',
    prayerTitle: 'Conditional Prayer',
    timesPerDay: 3,
    totalDays: 40,
    currentDay: 0,
    currentReadCount: 0,
    totalReads: 0,
  );
  print('\nConditional prayer initial: currentDay=${cond.currentDay}, currentReadCount=${cond.currentReadCount}');
  cond.incrementRead();
  print('After 1 read: currentDay=${cond.currentDay}, currentReadCount=${cond.currentReadCount}');
  cond.incrementRead();
  print('After 2 reads: currentDay=${cond.currentDay}, currentReadCount=${cond.currentReadCount}');
  cond.incrementRead();
  print('After 3 reads: currentDay=${cond.currentDay}, currentReadCount=${cond.currentReadCount} (expected currentDay=1, currentReadCount=0)');

  // Unconditional prayer: timesPerDay = null
  final uncond = Journey(
    id: 'unc1',
    prayerId: 'p2',
    prayerTitle: 'Unconditional Prayer',
    timesPerDay: null,
    totalDays: 10,
    currentDay: 0,
    currentReadCount: 0,
    totalReads: 0,
  );
  print('\nUnconditional prayer initial: currentDay=${uncond.currentDay}, lastReadDate=${uncond.lastReadDate}');
  uncond.incrementRead();
  print('After 1 read: currentDay=${uncond.currentDay}, currentReadCount=${uncond.currentReadCount} (expected currentDay=1)');
}
