package com.autora.rental.report;

import com.autora.rental.booking.BookingRepository;
import com.autora.rental.booking.BookingStatus;
import com.autora.rental.car.CarRepository;
import com.autora.rental.employee.EmployeeRepository;
import com.autora.rental.employee.EmployeeStatus;
import com.autora.rental.task.TaskRepository;
import com.autora.rental.task.TaskStatus;
import com.autora.rental.task.TaskType;
import com.autora.rental.user.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.YearMonth;
import java.util.HashMap;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class ReportService {

    private final BookingRepository bookingRepository;
    private final CarRepository carRepository;
    private final EmployeeRepository employeeRepository;
    private final TaskRepository taskRepository;
    private final UserRepository userRepository;

    /**
     * Get dashboard overview stats for manager
     */
    public Map<String, Object> getDashboardStats() {
        Map<String, Object> stats = new HashMap<>();

        // Total counts
        stats.put("totalCars", carRepository.count());
        stats.put("totalEmployees", employeeRepository.count());
        stats.put("totalCustomers", userRepository.count());
        stats.put("activeEmployees", employeeRepository.countByStatus(EmployeeStatus.ACTIVE));

        // Booking stats
        stats.put("activeBookings", bookingRepository.countByStatus(BookingStatus.ACTIVE));
        stats.put("upcomingBookings", bookingRepository.countByStatus(BookingStatus.UPCOMING));
        stats.put("completedBookings", bookingRepository.countByStatus(BookingStatus.COMPLETED));

        // Task stats
        stats.put("pendingTasks", taskRepository.countByStatus(TaskStatus.PENDING));
        stats.put("todaysPickups", taskRepository.countByDateAndType(LocalDate.now(), TaskType.PICKUP));
        stats.put("todaysReturns", taskRepository.countByDateAndType(LocalDate.now(), TaskType.RETURN));

        // Monthly revenue (current month)
        YearMonth currentMonth = YearMonth.now();
        LocalDateTime monthStart = currentMonth.atDay(1).atStartOfDay();
        LocalDateTime monthEnd = currentMonth.atEndOfMonth().atTime(23, 59, 59);
        Double monthlyRevenue = bookingRepository.calculateRevenueByDateRange(monthStart, monthEnd);
        stats.put("monthlyRevenue", monthlyRevenue != null ? monthlyRevenue : 0.0);

        return stats;
    }

    /**
     * Get revenue report by date range
     */
    public Map<String, Object> getRevenueReport(LocalDate startDate, LocalDate endDate) {
        Map<String, Object> report = new HashMap<>();

        LocalDateTime start = startDate.atStartOfDay();
        LocalDateTime end = endDate.atTime(23, 59, 59);

        Double totalRevenue = bookingRepository.calculateRevenueByDateRange(start, end);
        Long totalBookings = bookingRepository.countByDateRange(start, end);
        Long completedBookings = bookingRepository.countByStatusAndDateRange(BookingStatus.COMPLETED, start, end);
        Long cancelledBookings = bookingRepository.countByStatusAndDateRange(BookingStatus.CANCELLED, start, end);

        report.put("startDate", startDate);
        report.put("endDate", endDate);
        report.put("totalRevenue", totalRevenue != null ? totalRevenue : 0.0);
        report.put("totalBookings", totalBookings);
        report.put("completedBookings", completedBookings);
        report.put("cancelledBookings", cancelledBookings);

        // Calculate average booking value
        if (completedBookings != null && completedBookings > 0 && totalRevenue != null) {
            report.put("averageBookingValue", totalRevenue / completedBookings);
        } else {
            report.put("averageBookingValue", 0.0);
        }

        return report;
    }

    /**
     * Get booking statistics
     */
    public Map<String, Object> getBookingStats() {
        Map<String, Object> stats = new HashMap<>();

        stats.put("total", bookingRepository.count());
        stats.put("upcoming", bookingRepository.countByStatus(BookingStatus.UPCOMING));
        stats.put("active", bookingRepository.countByStatus(BookingStatus.ACTIVE));
        stats.put("completed", bookingRepository.countByStatus(BookingStatus.COMPLETED));
        stats.put("cancelled", bookingRepository.countByStatus(BookingStatus.CANCELLED));

        // This week's bookings
        LocalDateTime weekStart = LocalDate.now().minusDays(7).atStartOfDay();
        LocalDateTime weekEnd = LocalDateTime.now();
        stats.put("thisWeek", bookingRepository.countByDateRange(weekStart, weekEnd));

        // This month's bookings
        YearMonth currentMonth = YearMonth.now();
        LocalDateTime monthStart = currentMonth.atDay(1).atStartOfDay();
        LocalDateTime monthEnd = currentMonth.atEndOfMonth().atTime(23, 59, 59);
        stats.put("thisMonth", bookingRepository.countByDateRange(monthStart, monthEnd));

        return stats;
    }

    /**
     * Get fleet utilization report
     */
    public Map<String, Object> getFleetUtilization() {
        Map<String, Object> report = new HashMap<>();

        long totalCars = carRepository.count();
        long availableCars = carRepository.countAvailableCars();
        long rentedCars = totalCars - availableCars;

        report.put("totalCars", totalCars);
        report.put("availableCars", availableCars);
        report.put("rentedCars", rentedCars);

        if (totalCars > 0) {
            report.put("utilizationRate", (double) rentedCars / totalCars * 100);
        } else {
            report.put("utilizationRate", 0.0);
        }

        return report;
    }

    /**
     * Get employee performance report
     */
    public Map<String, Object> getEmployeePerformanceReport() {
        Map<String, Object> report = new HashMap<>();

        report.put("totalEmployees", employeeRepository.count());
        report.put("activeEmployees", employeeRepository.countByStatus(EmployeeStatus.ACTIVE));
        report.put("onLeaveEmployees", employeeRepository.countByStatus(EmployeeStatus.ON_LEAVE));

        // Task completion stats
        report.put("totalTasksCompleted", taskRepository.countByStatus(TaskStatus.COMPLETED));
        report.put("pendingTasks", taskRepository.countByStatus(TaskStatus.PENDING));
        report.put("inProgressTasks", taskRepository.countByStatus(TaskStatus.IN_PROGRESS));

        return report;
    }

    /**
     * Get individual employee performance
     */
    public Map<String, Object> getEmployeePerformance(Long employeeId) {
        Map<String, Object> performance = new HashMap<>();

        var employee = employeeRepository.findById(employeeId)
                .orElseThrow(() -> new RuntimeException("Employee not found"));

        performance.put("employeeId", employee.getId());
        performance.put("employeeName", employee.getFullName());
        performance.put("tasksCompleted", employee.getTasksCompleted());
        performance.put("rating", employee.getRating());
        performance.put("totalRatings", employee.getTotalRatings());

        // Task stats
        performance.put("completedTasks", taskRepository.countByEmployeeIdAndStatus(employeeId, TaskStatus.COMPLETED));
        performance.put("pendingTasks", taskRepository.countByEmployeeIdAndStatus(employeeId, TaskStatus.PENDING));
        performance.put("inProgressTasks", taskRepository.countByEmployeeIdAndStatus(employeeId, TaskStatus.IN_PROGRESS));

        return performance;
    }
}
