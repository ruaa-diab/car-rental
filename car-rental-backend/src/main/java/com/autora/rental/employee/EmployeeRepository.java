package com.autora.rental.employee;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface EmployeeRepository extends JpaRepository<Employee, Long> {

    Optional<Employee> findByUserId(Long userId);

    Optional<Employee> findByUserEmail(String email);

    List<Employee> findByStatus(EmployeeStatus status);

    List<Employee> findByDepartment(String department);

    @Query("SELECT e FROM Employee e WHERE e.status = :status")
    Page<Employee> findByStatus(@Param("status") EmployeeStatus status, Pageable pageable);

    @Query("SELECT e FROM Employee e WHERE " +
           "LOWER(e.user.fullName) LIKE LOWER(CONCAT('%', :search, '%')) OR " +
           "LOWER(e.user.email) LIKE LOWER(CONCAT('%', :search, '%')) OR " +
           "LOWER(e.position) LIKE LOWER(CONCAT('%', :search, '%'))")
    Page<Employee> searchEmployees(@Param("search") String search, Pageable pageable);

    @Query("SELECT e FROM Employee e WHERE e.status = :status AND " +
           "(LOWER(e.user.fullName) LIKE LOWER(CONCAT('%', :search, '%')) OR " +
           "LOWER(e.user.email) LIKE LOWER(CONCAT('%', :search, '%')) OR " +
           "LOWER(e.position) LIKE LOWER(CONCAT('%', :search, '%')))")
    Page<Employee> searchEmployeesByStatus(@Param("search") String search,
                                           @Param("status") EmployeeStatus status,
                                           Pageable pageable);

    @Query("SELECT COUNT(e) FROM Employee e WHERE e.status = :status")
    long countByStatus(@Param("status") EmployeeStatus status);

    boolean existsByUserId(Long userId);
}
