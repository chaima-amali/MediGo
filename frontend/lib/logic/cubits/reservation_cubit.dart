import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/data/models/reservation.dart';
import 'package:frontend/data/repositories/reservation_repo.dart';

// States
abstract class ReservationState {}

class ReservationInitial extends ReservationState {}

class ReservationLoading extends ReservationState {}

class ReservationCreated extends ReservationState {
  final int reservationId;
  ReservationCreated(this.reservationId);
}

class ReservationLoaded extends ReservationState {
  final List<Reservation> reservations;
  ReservationLoaded(this.reservations);
}

class ReservationUpdated extends ReservationState {}

class ReservationDeleted extends ReservationState {}

class ReservationError extends ReservationState {
  final String message;
  ReservationError(this.message);
}

// Cubit
class ReservationCubit extends Cubit<ReservationState> {
  final ReservationRepository _repository;

  ReservationCubit(this._repository) : super(ReservationInitial());

  Future<void> createReservation({
    required int medicineFindId,
    required int userId,
    required int pharmacyId,
    required String medicineName,
    required String day,
    required String time,
    required int quantity,
  }) async {
    try {
      emit(ReservationLoading());

      final reservation = Reservation(
        medicineFindId: medicineFindId,
        userId: userId,
        pharmacyId: pharmacyId,
        medicineName: medicineName,
        day: day,
        time: time,
        quantity: quantity,
        status: 'pending',
        createdAt: DateTime.now().toIso8601String(),
      );

      final reservationId = await _repository.createReservation(reservation);
      emit(ReservationCreated(reservationId));
    } catch (e) {
      emit(ReservationError('Failed to create reservation: ${e.toString()}'));
    }
  }

  Future<void> loadUserReservations(int userId) async {
    try {
      emit(ReservationLoading());
      final reservations = await _repository.getUserReservations(userId);
      emit(ReservationLoaded(reservations));
    } catch (e) {
      emit(ReservationError('Failed to load reservations: ${e.toString()}'));
    }
  }

  Future<void> loadPendingReservations(int userId) async {
    try {
      emit(ReservationLoading());
      final reservations = await _repository.getPendingReservations(userId);
      emit(ReservationLoaded(reservations));
    } catch (e) {
      emit(
        ReservationError(
          'Failed to load pending reservations: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> updateReservationStatus(int reservationId, String status) async {
    try {
      emit(ReservationLoading());
      await _repository.updateReservationStatus(reservationId, status);
      emit(ReservationUpdated());
    } catch (e) {
      emit(ReservationError('Failed to update reservation: ${e.toString()}'));
    }
  }

  Future<void> cancelReservation(int reservationId) async {
    try {
      emit(ReservationLoading());
      await _repository.updateReservationStatus(reservationId, 'cancelled');
      emit(ReservationDeleted());
    } catch (e) {
      emit(ReservationError('Failed to cancel reservation: ${e.toString()}'));
    }
  }

  Future<void> deleteReservation(int reservationId) async {
    try {
      emit(ReservationLoading());
      await _repository.deleteReservation(reservationId);
      emit(ReservationDeleted());
    } catch (e) {
      emit(ReservationError('Failed to delete reservation: ${e.toString()}'));
    }
  }
}
