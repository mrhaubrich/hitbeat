import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'drag_n_drop_event.dart';
part 'drag_n_drop_state.dart';

/// {@template drag_n_drop_bloc}
/// A BLoC that handles drag and drop events.
/// {@endtemplate}
class DragNDropBloc extends Bloc<DragNDropEvent, DragNDropState> {
  /// {@macro drag_n_drop_bloc}
  DragNDropBloc() : super(const DragNDropInitial()) {
    on<DragStartEvent>((event, emit) {
      emit(const DragNDropDragging());
    });
    on<DragEndEvent>((event, emit) {
      emit(const DragNDropNotDragging());
    });
  }
}
