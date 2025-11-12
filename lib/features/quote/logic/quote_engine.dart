import '../data/models/package_model.dart';
import 'normalizers.dart';

class QuoteInput {
  final String freezone; // 'RAKEZ' | 'SHAMS' | ...
  final int visas;
  final int activities;
  final int shareholders;
  final int tenure; // years
  const QuoteInput({
    required this.freezone,
    required this.visas,
    required this.activities,
    required this.shareholders,
    required this.tenure,
  });
}

class LineItem {
  final String label;
  final double amount;
  LineItem(this.label, this.amount);
}

class QuoteResult {
  final PackageRow? pkg;
  final List<LineItem> items;
  final double total;
  final bool activitiesExceeded;
  QuoteResult({
    this.pkg,
    required this.items,
    required this.total,
    required this.activitiesExceeded,
  });
}

QuoteResult compute(PackageRow? p, QuoteInput i) {
  if (p == null) {
    return QuoteResult(
      pkg: null,
      items: [],
      total: 0,
      activitiesExceeded: false,
    );
  }
  double total = 0;
  final items = <LineItem>[];

  double add(String label, double? v) {
    if (v == null) {
      return 0;
    }
    items.add(LineItem(label, v));
    return v;
  }

  // Base license cost
  total += add(
    'License (${p.packageName ?? "Package"})',
    parseMoney(p.priceAed),
  );

  // Visa costs (per visa requested)
  final visaCost = (parseMoney(p.visaCostAed) ?? 0) * i.visas;
  if (visaCost > 0) {
    total += add('Visa costs (× ${i.visas})', visaCost);
  }

  // Immigration card
  total += add(
    'Immigration/Establishment card',
    parseMoney(p.immigrationCardFee),
  );

  // E-Channel
  total += add('E-Channel registration', parseMoney(p.eChannelFee));

  // Change of status
  final changeStatus = (parseMoney(p.changeOfStatusFee) ?? 0) * i.visas;
  if (changeStatus > 0) {
    total += add('Change of status (× ${i.visas})', changeStatus);
  }

  // Medical + EID
  final med = parseMoney(p.medicalFee) ?? 0;
  final eid = parseMoney(p.emiratesIdFee) ?? 0;
  if (med + eid > 0) {
    total += add('Medical + EID (× ${i.visas})', (med + eid) * i.visas);
  }

  // Check if activities exceeded
  final allowed = parseActivitiesCount(p.noOfActivitiesAllowed);
  final exceeded = i.activities > allowed && allowed > 0;

  return QuoteResult(
    pkg: p,
    items: items,
    total: total,
    activitiesExceeded: exceeded,
  );
}
