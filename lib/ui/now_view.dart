import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/providers.dart';
import 'service_card.dart';
import 'tokens.dart';

class NowView extends ConsumerWidget {
  const NowView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(snapshotProvider);
    if (snapshot.services.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('Loading statuses…', style: AppText.bodyDim),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
      children: [for (final s in snapshot.services) ServiceCard(snapshot: s)],
    );
  }
}
