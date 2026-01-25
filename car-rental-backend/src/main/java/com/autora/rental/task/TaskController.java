package com.autora.rental.task;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/tasks")
@RequiredArgsConstructor
public class TaskController {

    private final TaskService taskService;

    @GetMapping
    @PreAuthorize("hasAnyRole('EMPLOYEE', 'MANAGER', 'ADMIN')")
    public ResponseEntity<Page<TaskResponse>> getAllTasks(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(required = false) Long employeeId,
            @RequestParam(required = false) TaskStatus status,
            @RequestParam(required = false) TaskType type,
            @RequestParam(required = false) LocalDate date,
            @RequestParam(required = false) String search,
            @RequestParam(defaultValue = "scheduledDate") String sortBy,
            @RequestParam(defaultValue = "desc") String sortDir
    ) {
        Sort sort = sortDir.equalsIgnoreCase("asc")
                ? Sort.by(sortBy).ascending()
                : Sort.by(sortBy).descending();
        Pageable pageable = PageRequest.of(page, size, sort);

        Page<TaskResponse> tasks;
        if (search != null && !search.isEmpty()) {
            tasks = taskService.searchTasks(search, pageable);
        } else {
            tasks = taskService.getTasksWithFilters(employeeId, status, type, date, pageable);
        }

        return ResponseEntity.ok(tasks);
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('EMPLOYEE', 'MANAGER', 'ADMIN')")
    public ResponseEntity<TaskResponse> getTaskById(@PathVariable Long id) {
        return ResponseEntity.ok(taskService.getTaskById(id));
    }

    @GetMapping("/employee/{employeeId}")
    @PreAuthorize("hasAnyRole('EMPLOYEE', 'MANAGER', 'ADMIN')")
    public ResponseEntity<List<TaskResponse>> getTasksByEmployeeId(@PathVariable Long employeeId) {
        return ResponseEntity.ok(taskService.getTasksByEmployeeId(employeeId));
    }

    @GetMapping("/today")
    @PreAuthorize("hasAnyRole('EMPLOYEE', 'MANAGER', 'ADMIN')")
    public ResponseEntity<List<TaskResponse>> getTodaysTasks() {
        return ResponseEntity.ok(taskService.getTodaysTasks());
    }

    @GetMapping("/today/employee/{employeeId}")
    @PreAuthorize("hasAnyRole('EMPLOYEE', 'MANAGER', 'ADMIN')")
    public ResponseEntity<List<TaskResponse>> getTodaysTasksForEmployee(@PathVariable Long employeeId) {
        return ResponseEntity.ok(taskService.getTodaysTasksForEmployee(employeeId));
    }

    @GetMapping("/booking/{bookingId}")
    @PreAuthorize("hasAnyRole('EMPLOYEE', 'MANAGER', 'ADMIN')")
    public ResponseEntity<List<TaskResponse>> getTasksByBookingId(@PathVariable Long bookingId) {
        return ResponseEntity.ok(taskService.getTasksByBookingId(bookingId));
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('MANAGER', 'ADMIN')")
    public ResponseEntity<TaskResponse> createTask(@Valid @RequestBody TaskRequest request) {
        return ResponseEntity.ok(taskService.createTask(request));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('MANAGER', 'ADMIN')")
    public ResponseEntity<TaskResponse> updateTask(
            @PathVariable Long id,
            @RequestBody TaskRequest request
    ) {
        return ResponseEntity.ok(taskService.updateTask(id, request));
    }

    @PutMapping("/{id}/assign/{employeeId}")
    @PreAuthorize("hasAnyRole('MANAGER', 'ADMIN')")
    public ResponseEntity<TaskResponse> assignEmployee(
            @PathVariable Long id,
            @PathVariable Long employeeId
    ) {
        return ResponseEntity.ok(taskService.assignEmployee(id, employeeId));
    }

    @PutMapping("/{id}/status")
    @PreAuthorize("hasAnyRole('EMPLOYEE', 'MANAGER', 'ADMIN')")
    public ResponseEntity<TaskResponse> updateTaskStatus(
            @PathVariable Long id,
            @RequestParam TaskStatus status
    ) {
        return ResponseEntity.ok(taskService.updateTaskStatus(id, status));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasAnyRole('MANAGER', 'ADMIN')")
    public ResponseEntity<Map<String, String>> deleteTask(@PathVariable Long id) {
        taskService.deleteTask(id);
        Map<String, String> response = new HashMap<>();
        response.put("message", "Task deleted successfully");
        return ResponseEntity.ok(response);
    }

    @GetMapping("/stats")
    @PreAuthorize("hasAnyRole('MANAGER', 'ADMIN')")
    public ResponseEntity<Map<String, Object>> getTaskStats() {
        Map<String, Object> stats = new HashMap<>();
        stats.put("pendingTasks", taskService.countPendingTasks());
        stats.put("todaysPickups", taskService.countTodaysPickups());
        stats.put("todaysReturns", taskService.countTodaysReturns());
        return ResponseEntity.ok(stats);
    }

    @GetMapping("/stats/employee/{employeeId}")
    @PreAuthorize("hasAnyRole('EMPLOYEE', 'MANAGER', 'ADMIN')")
    public ResponseEntity<Map<String, Object>> getEmployeeTaskStats(@PathVariable Long employeeId) {
        Map<String, Object> stats = new HashMap<>();
        stats.put("completedTasks", taskService.countCompletedTasksForEmployee(employeeId));
        stats.put("pendingTasks", taskService.countPendingTasksForEmployee(employeeId));
        return ResponseEntity.ok(stats);
    }
}
