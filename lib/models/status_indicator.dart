enum StatusIndicator {
  operational,
  maintenance,
  degraded,
  partial,
  major,
  unknown;

  int get severity {
    switch (this) {
      case StatusIndicator.operational:
        return 0;
      case StatusIndicator.maintenance:
        return 1;
      case StatusIndicator.degraded:
        return 2;
      case StatusIndicator.partial:
        return 3;
      case StatusIndicator.major:
        return 4;
      case StatusIndicator.unknown:
        return -1;
    }
  }

  String get label {
    switch (this) {
      case StatusIndicator.operational:
        return 'Operational';
      case StatusIndicator.maintenance:
        return 'Under maintenance';
      case StatusIndicator.degraded:
        return 'Degraded performance';
      case StatusIndicator.partial:
        return 'Partial outage';
      case StatusIndicator.major:
        return 'Major outage';
      case StatusIndicator.unknown:
        return 'Unknown';
    }
  }

  String get trayAssetKey {
    switch (this) {
      case StatusIndicator.operational:
        return 'ok';
      case StatusIndicator.maintenance:
        return 'maintenance';
      case StatusIndicator.degraded:
        return 'minor';
      case StatusIndicator.partial:
        return 'partial';
      case StatusIndicator.major:
        return 'major';
      case StatusIndicator.unknown:
        return 'unknown';
    }
  }

  static StatusIndicator fromComponentStatus(String? raw) {
    switch (raw) {
      case 'operational':
        return StatusIndicator.operational;
      case 'under_maintenance':
        return StatusIndicator.maintenance;
      case 'degraded_performance':
        return StatusIndicator.degraded;
      case 'partial_outage':
        return StatusIndicator.partial;
      case 'major_outage':
        return StatusIndicator.major;
      default:
        return StatusIndicator.unknown;
    }
  }

  static StatusIndicator fromIncidentImpact(String? raw) {
    switch (raw) {
      case 'none':
        return StatusIndicator.operational;
      case 'maintenance':
        return StatusIndicator.maintenance;
      case 'minor':
        return StatusIndicator.degraded;
      case 'major':
        return StatusIndicator.partial;
      case 'critical':
        return StatusIndicator.major;
      default:
        return StatusIndicator.unknown;
    }
  }

  static StatusIndicator fromPageIndicator(String? raw) {
    switch (raw) {
      case 'none':
        return StatusIndicator.operational;
      case 'maintenance':
        return StatusIndicator.maintenance;
      case 'minor':
        return StatusIndicator.degraded;
      case 'major':
        return StatusIndicator.partial;
      case 'critical':
        return StatusIndicator.major;
      default:
        return StatusIndicator.unknown;
    }
  }

  static StatusIndicator worstOf(Iterable<StatusIndicator> values) {
    StatusIndicator worst = StatusIndicator.operational;
    for (final v in values) {
      if (v.severity > worst.severity) worst = v;
    }
    return worst;
  }
}
