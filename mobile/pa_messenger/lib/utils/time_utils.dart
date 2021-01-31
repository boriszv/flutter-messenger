calculateTimestamp(DateTime dateTime) {
  var timestamp = 'Now';

  final diff = DateTime.now().difference(dateTime);

  if (diff.inDays >= 7) {
    timestamp = '${dateTime.day}/${dateTime.month}';
  }

  if (dateTime.year != DateTime.now().year) {
    timestamp = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  if (diff.inDays == 1) {
    timestamp = 'Yesterday';
  } else if (diff.inDays > 1) {
    timestamp = '${diff.inDays} days ago';
  } else if (diff.inHours >= 1) {
    timestamp = '${diff.inHours}h';
  } else if (diff.inMinutes >= 1) {
    timestamp = '${diff.inMinutes}m';
  } else if (diff.inSeconds > 3) {
    timestamp = '${diff.inSeconds}s';
  }

  return timestamp;
}
