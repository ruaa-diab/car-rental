package com.autora.rental.inspection;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface InspectionRepository extends JpaRepository<Inspection, Long> {

    List<Inspection> findByTaskId(Long taskId);

    Optional<Inspection> findByTaskIdAndType(Long taskId, InspectionType type);

    List<Inspection> findByType(InspectionType type);

    Page<Inspection> findByType(InspectionType type, Pageable pageable);

    @Query("SELECT i FROM Inspection i WHERE i.task.booking.id = :bookingId")
    List<Inspection> findByBookingId(@Param("bookingId") Long bookingId);

    @Query("SELECT i FROM Inspection i WHERE i.task.employee.id = :employeeId")
    List<Inspection> findByEmployeeId(@Param("employeeId") Long employeeId);

    @Query("SELECT i FROM Inspection i WHERE i.task.employee.id = :employeeId")
    Page<Inspection> findByEmployeeId(@Param("employeeId") Long employeeId, Pageable pageable);

    @Query("SELECT i FROM Inspection i WHERE i.createdAt BETWEEN :startDate AND :endDate")
    List<Inspection> findByDateRange(
            @Param("startDate") LocalDateTime startDate,
            @Param("endDate") LocalDateTime endDate
    );

    @Query("SELECT COUNT(i) FROM Inspection i WHERE i.type = :type")
    long countByType(@Param("type") InspectionType type);

    @Query("SELECT i FROM Inspection i WHERE i.task.booking.car.id = :carId ORDER BY i.createdAt DESC")
    List<Inspection> findByCarId(@Param("carId") Long carId);
}
