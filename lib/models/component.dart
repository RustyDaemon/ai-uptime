import 'status_indicator.dart';

class Component {
  final String id;
  final String name;
  final String? description;
  final StatusIndicator status;

  const Component({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
  });

  Component copyWith({StatusIndicator? status}) => Component(
    id: id,
    name: name,
    description: description,
    status: status ?? this.status,
  );
}
