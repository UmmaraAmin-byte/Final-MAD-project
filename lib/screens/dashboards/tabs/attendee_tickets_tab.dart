import 'package:flutter/material.dart';
import '../../../services/auth_service.dart';
import '../../../services/registration_service.dart';

const _kPrimary = Color(0xFF4F46E5);
const _kPrimaryLight = Color(0xFFEEF2FF);
const _kTextDark = Color(0xFF1E1B4B);
const _kTextMid = Color(0xFF64748B);
const _kTextLight = Color(0xFF94A3B8);
const _kBorder = Color(0xFFE2E8F0);
const _kSuccess = Color(0xFF059669);
const _kSuccessLight = Color(0xFFD1FAE5);

const _catColors = <String, Color>{
  'Technology':     Color(0xFF4F46E5),
  'Business':       Color(0xFF059669),
  'Arts & Culture': Color(0xFF7C3AED),
  'Education':      Color(0xFFD97706),
  'Workshop':       Color(0xFF0891B2),
  'Seminar':        Color(0xFF7C3AED),
  'Conference':     Color(0xFF2563EB),
  'Networking':     Color(0xFF475569),
  'Health':         Color(0xFFDC2626),
  'Finance':        Color(0xFF16A34A),
};

Color _catColor(String c) => _catColors[c] ?? _kPrimary;

class AttendeeTicketsTab extends StatelessWidget {
  final Set<String> registeredIds;
  final void Function(Map<String, dynamic>) onEventTap;
  final String Function(Map<String, dynamic>) locationLabel;
  final String Function(Map<String, dynamic>) organizerName;

  const AttendeeTicketsTab({
    super.key,
    required this.registeredIds,
    required this.onEventTap,
    required this.locationLabel,
    required this.organizerName,
  });

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
    final reg = RegistrationService();

    if (!auth.isLoggedIn) {
      return _notLoggedIn();
    }

    final userId = auth.currentUser!.id;
    final now = DateTime.now();

    final myEvents = auth.allEvents
        .where((e) => registeredIds.contains(e['id'] as String))
        .toList()
      ..sort((a, b) {
        final sa = a['start'] as DateTime?;
        final sb = b['start'] as DateTime?;
        if (sa == null && sb == null) return 0;
        if (sa == null) return 1;
        if (sb == null) return -1;
        return sa.compareTo(sb);
      });

    final upcoming = myEvents
        .where((e) => (e['start'] as DateTime?)?.isAfter(now) ?? false)
        .toList();
    final past = myEvents
        .where((e) => !((e['start'] as DateTime?)?.isAfter(now) ?? false))
        .toList();

    if (myEvents.isEmpty) {
      return _emptyState();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats row
          Row(
            children: [
              _statBadge('${myEvents.length}', 'Total Tickets', Icons.confirmation_num_outlined, _kPrimary),
              const SizedBox(width: 10),
              _statBadge('${upcoming.length}', 'Upcoming', Icons.upcoming_outlined, _kSuccess),
              const SizedBox(width: 10),
              _statBadge('${past.length}', 'Attended', Icons.check_circle_outline, _kTextMid),
            ],
          ),
          const SizedBox(height: 24),

          if (upcoming.isNotEmpty) ...[
            _sectionLabel('Upcoming Events', upcoming.length),
            const SizedBox(height: 12),
            ...upcoming.map((e) => _ticketCard(e, reg, userId, isUpcoming: true)),
            const SizedBox(height: 24),
          ],

          if (past.isNotEmpty) ...[
            _sectionLabel('Past Events', past.length),
            const SizedBox(height: 12),
            ...past.map((e) => _ticketCard(e, reg, userId, isUpcoming: false)),
          ],
        ],
      ),
    );
  }

  Widget _sectionLabel(String title, int count) {
    return Row(
      children: [
        Text(title,
            style: const TextStyle(
                color: _kTextDark, fontSize: 15, fontWeight: FontWeight.w700)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: _kPrimaryLight,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text('$count',
              style: const TextStyle(
                  color: _kPrimary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }

  Widget _statBadge(
      String value, String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _kBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 6),
            Text(value,
                style: TextStyle(
                    color: color,
                    fontSize: 20,
                    fontWeight: FontWeight.w800)),
            Text(label,
                style: const TextStyle(color: _kTextLight, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _ticketCard(Map<String, dynamic> e, RegistrationService reg,
      String userId, {required bool isUpcoming}) {
    final category = (e['category'] as String? ?? '');
    final color = _catColor(category);
    final start = e['start'] as DateTime?;
    final end = e['end'] as DateTime?;
    final loc = locationLabel(e);
    final org = organizerName(e);
    final eventId = e['id'] as String? ?? '';
    final regs = reg.registrationsForAttendee(userId);
    final isAttended = regs.any((r) =>
        r['eventId'] == eventId && (r['attended'] as bool? ?? false));

    return GestureDetector(
      onTap: () => onEventTap(e),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _kBorder),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ticket header strip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withOpacity(0.7)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(15)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      category.isEmpty ? 'Event' : category,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                  const Spacer(),
                  if (isAttended)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _kSuccessLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle,
                              color: _kSuccess, size: 12),
                          SizedBox(width: 4),
                          Text('Attended',
                              style: TextStyle(
                                  color: _kSuccess,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    )
                  else if (isUpcoming)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('Confirmed',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700)),
                    ),
                ],
              ),
            ),

            // Ticket body
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          e['title'] as String? ?? 'Untitled Event',
                          style: const TextStyle(
                              color: _kTextDark,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              height: 1.2),
                        ),
                        const SizedBox(height: 8),
                        if (start != null) ...[
                          _infoRow(Icons.calendar_today_outlined,
                              _fmtDate(start)),
                          const SizedBox(height: 4),
                          _infoRow(Icons.access_time_outlined,
                              '${_fmtTime(start)}${end != null ? ' – ${_fmtTime(end)}' : ''}'),
                        ],
                        if (loc.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          _infoRow(Icons.location_on_outlined, loc),
                        ],
                        if (org.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          _infoRow(Icons.person_outline, 'By $org'),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // QR placeholder
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: _kPrimaryLight,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: color.withOpacity(0.2)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.qr_code_2_rounded,
                            color: color, size: 32),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Dashed divider
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _dashedDivider(),
            ),

            // Ticket footer
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Icon(Icons.confirmation_num_outlined,
                      size: 13, color: _kTextLight),
                  const SizedBox(width: 4),
                  Text(
                    'Ticket #${eventId.substring(0, 8).toUpperCase()}',
                    style: const TextStyle(
                        color: _kTextLight,
                        fontSize: 11,
                        fontFamily: 'monospace'),
                  ),
                  const Spacer(),
                  if (isUpcoming && start != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _daysUntil(start),
                        style: TextStyle(
                            color: color,
                            fontSize: 11,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 13, color: _kTextMid),
        const SizedBox(width: 5),
        Expanded(
          child: Text(text,
              style: const TextStyle(color: _kTextMid, fontSize: 12)),
        ),
      ],
    );
  }

  Widget _dashedDivider() {
    return SizedBox(
      height: 1,
      child: LayoutBuilder(
        builder: (_, constraints) {
          final count = (constraints.maxWidth / 8).floor();
          return Row(
            children: List.generate(
              count,
              (i) => Expanded(
                child: Container(
                  height: 1,
                  color: i.isEven ? _kBorder : Colors.transparent,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _fmtDate(DateTime dt) {
    const m = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    const w = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    return '${w[dt.weekday - 1]}, ${dt.day} ${m[dt.month - 1]} ${dt.year}';
  }

  String _fmtTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  String _daysUntil(DateTime start) {
    final diff = start.difference(DateTime.now());
    if (diff.inDays == 0) return 'Today!';
    if (diff.inDays == 1) return 'Tomorrow';
    if (diff.inDays < 7) return 'In ${diff.inDays} days';
    if (diff.inDays < 30) return 'In ${(diff.inDays / 7).round()} weeks';
    return 'In ${(diff.inDays / 30).round()} months';
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                  color: _kPrimaryLight, shape: BoxShape.circle),
              child: const Icon(Icons.confirmation_num_outlined,
                  size: 36, color: _kPrimary),
            ),
            const SizedBox(height: 20),
            const Text('No tickets yet',
                style: TextStyle(
                    color: _kTextDark,
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const Text(
              'Register for events to see your tickets here. Your confirmed registrations will appear as digital tickets.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _kTextMid, fontSize: 13, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _notLoggedIn() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                  color: _kPrimaryLight, shape: BoxShape.circle),
              child: const Icon(Icons.lock_outline,
                  size: 36, color: _kPrimary),
            ),
            const SizedBox(height: 20),
            const Text('Sign in to view tickets',
                style: TextStyle(
                    color: _kTextDark,
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const Text('Log in to access your registered event tickets.',
                textAlign: TextAlign.center,
                style:
                    TextStyle(color: _kTextMid, fontSize: 13, height: 1.5)),
          ],
        ),
      ),
    );
  }
}
