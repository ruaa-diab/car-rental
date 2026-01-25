package com.autora.rental.task;

import com.autora.rental.booking.Booking;
import com.autora.rental.booking.BookingRepository;
import com.autora.rental.employee.Employee;
import com.autora.rental.employee.EmployeeService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class TaskService {

    private final TaskRepository taskRepository;
    private final BookingRepository bookingRepository;
    private final EmployeeService employeeService;

    public Page<TaskResponse> getAllTasks(Pageable pageable) {
        return taskRepository.findAll(pageable).map(TaskResponse::fromEntity);
    }

    public Page<TaskResponse> getTasksWithFilters(
            Long employeeId,
            TaskStatus status,
            TaskType type,
            LocalDate date,
            Pageable pageable
    ) {
        return taskRepository.findWithFilters(employeeId, status, type, date, pageable)
                .map(TaskResponse::fromEntity);
    }

    public Page<TaskResponse> searchTasks(String search, Pageable pageable) {
        return taskRepository.searchTasks(search, pageable).map(TaskResponse::fromEntity);
    }

    public TaskResponse getTaskById(Long id) {
        Task task = taskRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Task not found with id: " + id));
        return TaskResponse.fromEntity(task);
    }

    public Task getTaskEntityById(Long id) {
        return taskRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Task not found with id: " + id));
    }

    public List<TaskResponse> getTasksByEmployeeId(Long employeeId) {
        return taskRepository.findByEmployeeId(employeeId).stream()
                .map(TaskResponse::fromEntity)
                .collect(Collectors.toList());
    }

    public Page<TaskResponse> getTasksByEmployeeId(Long employeeId, Pageable pageable) {
        return taskRepository.findByEmployeeId(employeeId, pageable)
                .map(TaskResponse::fromEntity);
    }

    public List<TaskResponse> getTodaysTasks() {
        return taskRepository.findByScheduledDate(LocalDate.now()).stream()
                .map(TaskResponse::fromEntity)
                .collect(Collectors.toList());
    }

    public List<TaskResponse> getTodaysTasksForEmployee(Long employeeId) {
        return taskRepository.findByEmployeeIdAndDate(employeeId, LocalDate.now()).stream()
                .map(TaskResponse::fromEntity)
                .collect(Collectors.toList());
    }

    public List<TaskResponse> getTasksByBookingId(Long bookingId) {
        return taskRepository.findByBookingId(bookingId).stream()
                .map(TaskResponse::fromEntity)
                .collect(Collectors.toList());
    }

    @Transactional
    public TaskResponse createTask(TaskRequest request) {
        Booking booking = bookingRepository.findById(request.getBookingId())
                .orElseThrow(() -> new RuntimeException("Booking not found with id: " + request.getBookingId()));

        Task task = Task.builder()
                .type(request.getType())
                .status(TaskStatus.PENDING)
                .priority(request.getPriority() != null ? request.getPriority() : TaskPriority.NORMAL)
                .booking(booking)
                .scheduledDate(request.getScheduledDate())
                .scheduledTime(request.getScheduledTime())
                .notes(request.getNotes())
                .location(request.getLocation())
                .locationType(request.getLocationType())
                .latitude(request.getLatitude())
                .longitude(request.getLongitude())
                .build();

        // Assign employee if provided
        if (request.getEmployeeId() != null) {
            Employee employee = employeeService.getEmployeeEntityById(request.getEmployeeId());
            task.setEmployee(employee);
        }

        task = taskRepository.save(task);
        return TaskResponse.fromEntity(task);
    }

    @Transactional
    public TaskResponse updateTask(Long id, TaskRequest request) {
        Task task = taskRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Task not found with id: " + id));

        if (request.getType() != null) {
            task.setType(request.getType());
        }
        if (request.getPriority() != null) {
            task.setPriority(request.getPriority());
        }
        if (request.getScheduledDate() != null) {
            task.setScheduledDate(request.getScheduledDate());
        }
        if (request.getScheduledTime() != null) {
            task.setScheduledTime(request.getScheduledTime());
        }
        if (request.getNotes() != null) {
            task.setNotes(request.getNotes());
        }
        if (request.getLocation() != null) {
            task.setLocation(request.getLocation());
        }
        if (request.getLocationType() != null) {
            task.setLocationType(request.getLocationType());
        }
        if (request.getLatitude() != null) {
            task.setLatitude(request.getLatitude());
        }
        if (request.getLongitude() != null) {
            task.setLongitude(request.getLongitude());
        }
        if (request.getEmployeeId() != null) {
            Employee employee = employeeService.getEmployeeEntityById(request.getEmployeeId());
            task.setEmployee(employee);
        }

        task = taskRepository.save(task);
        return TaskResponse.fromEntity(task);
    }

    @Transactional
    public TaskResponse assignEmployee(Long taskId, Long employeeId) {
        Task task = taskRepository.findById(taskId)
                .orElseThrow(() -> new RuntimeException("Task not found with id: " + taskId));

        Employee employee = employeeService.getEmployeeEntityById(employeeId);
        task.setEmployee(employee);

        task = taskRepository.save(task);
        return TaskResponse.fromEntity(task);
    }

    @Transactional
    public TaskResponse updateTaskStatus(Long id, TaskStatus status) {
        Task task = taskRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Task not found with id: " + id));

        switch (status) {
            case IN_PROGRESS:
                task.startTask();
                break;
            case COMPLETED:
                task.completeTask();
                // Increment employee's completed tasks count
                if (task.getEmployee() != null) {
                    employeeService.incrementTasksCompleted(task.getEmployee().getId());
                }
                break;
            case CANCELLED:
                task.cancelTask();
                break;
            default:
                task.setStatus(status);
        }

        task = taskRepository.save(task);
        return TaskResponse.fromEntity(task);
    }

    @Transactional
    public void deleteTask(Long id) {
        if (!taskRepository.existsById(id)) {
            throw new RuntimeException("Task not found with id: " + id);
        }
        taskRepository.deleteById(id);
    }

    // Stats methods
    public long countPendingTasks() {
        return taskRepository.countByStatus(TaskStatus.PENDING);
    }

    public long countTodaysPickups() {
        return taskRepository.countByDateAndType(LocalDate.now(), TaskType.PICKUP);
    }

    public long countTodaysReturns() {
        return taskRepository.countByDateAndType(LocalDate.now(), TaskType.RETURN);
    }

    public long countCompletedTasksForEmployee(Long employeeId) {
        return taskRepository.countByEmployeeIdAndStatus(employeeId, TaskStatus.COMPLETED);
    }

    public long countPendingTasksForEmployee(Long employeeId) {
        return taskRepository.countByEmployeeIdAndStatus(employeeId, TaskStatus.PENDING);
    }
}
