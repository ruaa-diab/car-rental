package com.autora.rental.task;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;

@Repository
public interface TaskRepository extends JpaRepository<Task, Long> {

    List<Task> findByEmployeeId(Long employeeId);

    Page<Task> findByEmployeeId(Long employeeId, Pageable pageable);

    List<Task> findByStatus(TaskStatus status);

    Page<Task> findByStatus(TaskStatus status, Pageable pageable);

    List<Task> findByType(TaskType type);

    Page<Task> findByType(TaskType type, Pageable pageable);

    List<Task> findByScheduledDate(LocalDate date);

    Page<Task> findByScheduledDate(LocalDate date, Pageable pageable);

    @Query("SELECT t FROM Task t WHERE t.employee.id = :employeeId AND t.status = :status")
    List<Task> findByEmployeeIdAndStatus(@Param("employeeId") Long employeeId, @Param("status") TaskStatus status);

    @Query("SELECT t FROM Task t WHERE t.employee.id = :employeeId AND t.scheduledDate = :date")
    List<Task> findByEmployeeIdAndDate(@Param("employeeId") Long employeeId, @Param("date") LocalDate date);

    @Query("SELECT t FROM Task t WHERE t.employee.id = :employeeId AND t.scheduledDate = :date AND t.status = :status")
    List<Task> findByEmployeeIdAndDateAndStatus(
            @Param("employeeId") Long employeeId,
            @Param("date") LocalDate date,
            @Param("status") TaskStatus status
    );

    @Query("SELECT t FROM Task t WHERE t.scheduledDate = :date AND t.status IN :statuses")
    List<Task> findByDateAndStatuses(@Param("date") LocalDate date, @Param("statuses") List<TaskStatus> statuses);

    @Query("SELECT t FROM Task t WHERE t.booking.id = :bookingId")
    List<Task> findByBookingId(@Param("bookingId") Long bookingId);

    @Query("SELECT t FROM Task t WHERE t.booking.id = :bookingId AND t.type = :type")
    Task findByBookingIdAndType(@Param("bookingId") Long bookingId, @Param("type") TaskType type);

    @Query("SELECT COUNT(t) FROM Task t WHERE t.employee.id = :employeeId AND t.status = :status")
    long countByEmployeeIdAndStatus(@Param("employeeId") Long employeeId, @Param("status") TaskStatus status);

    @Query("SELECT COUNT(t) FROM Task t WHERE t.scheduledDate = :date AND t.type = :type")
    long countByDateAndType(@Param("date") LocalDate date, @Param("type") TaskType type);

    @Query("SELECT COUNT(t) FROM Task t WHERE t.status = :status")
    long countByStatus(@Param("status") TaskStatus status);

    // Search tasks
    @Query("SELECT t FROM Task t WHERE " +
           "LOWER(t.booking.user.fullName) LIKE LOWER(CONCAT('%', :search, '%')) OR " +
           "LOWER(t.booking.car.brand) LIKE LOWER(CONCAT('%', :search, '%')) OR " +
           "LOWER(t.booking.car.model) LIKE LOWER(CONCAT('%', :search, '%')) OR " +
           "LOWER(t.booking.car.licensePlate) LIKE LOWER(CONCAT('%', :search, '%'))")
    Page<Task> searchTasks(@Param("search") String search, Pageable pageable);

    // Find tasks with filters
    @Query("SELECT t FROM Task t WHERE " +
           "(:employeeId IS NULL OR t.employee.id = :employeeId) AND " +
           "(:status IS NULL OR t.status = :status) AND " +
           "(:type IS NULL OR t.type = :type) AND " +
           "(:date IS NULL OR t.scheduledDate = :date)")
    Page<Task> findWithFilters(
            @Param("employeeId") Long employeeId,
            @Param("status") TaskStatus status,
            @Param("type") TaskType type,
            @Param("date") LocalDate date,
            Pageable pageable
    );
}
