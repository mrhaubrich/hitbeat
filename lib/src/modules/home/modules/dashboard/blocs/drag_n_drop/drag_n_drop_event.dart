part of 'drag_n_drop_bloc.dart';

/// {@template drag_n_drop_event}
/// An event that is triggered when a drag and drop event occurs.
/// {@endtemplate}
sealed class DragNDropEvent extends Equatable {
  const DragNDropEvent();

  @override
  List<Object> get props => [];
}

/// An event that is triggered when the user starts dragging an item.
class DragStartEvent extends DragNDropEvent {
  /// {@macro drag_n_drop_event}
  const DragStartEvent() : super();
}

/// An event that is triggered when the user stops dragging an item.
class DragEndEvent extends DragNDropEvent {
  /// {@macro drag_n_drop_event}
  const DragEndEvent() : super();
}
