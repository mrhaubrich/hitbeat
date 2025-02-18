part of 'drag_n_drop_bloc.dart';

/// {@template drag_n_drop_state}
/// The state of the [DragNDropBloc].
/// {@endtemplate}
sealed class DragNDropState extends Equatable {
  const DragNDropState({
    required this.isDragging,
  });

  /// Whether an item is being dragged.
  final bool isDragging;

  @override
  List<Object> get props => [isDragging];
}

/// The initial state of the [DragNDropBloc].
final class DragNDropInitial extends DragNDropState {
  /// {@macro drag_n_drop_state}
  const DragNDropInitial() : super(isDragging: false);
}

/// The state of the [DragNDropBloc] when an item is being dragged.
final class DragNDropDragging extends DragNDropState {
  /// {@macro drag_n_drop_state}
  const DragNDropDragging() : super(isDragging: true);
}

/// The state of the [DragNDropBloc] when an item is not being dragged.
final class DragNDropNotDragging extends DragNDropState {
  /// {@macro drag_n_drop_state}
  const DragNDropNotDragging() : super(isDragging: false);
}
