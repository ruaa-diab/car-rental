package com.autora.rental.inspection;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/inspections")
@RequiredArgsConstructor
public class InspectionController {

    private final InspectionService inspectionService;

    @GetMapping
    @PreAuthorize("hasAnyRole('EMPLOYEE', 'MANAGER', 'ADMIN')")
    public ResponseEntity<Page<InspectionResponse>> getAllInspections(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(defaultValue = "createdAt") String sortBy,
            @RequestParam(defaultValue = "desc") String sortDir
    ) {
        Sort sort = sortDir.equalsIgnoreCase("asc")
                ? Sort.by(sortBy).ascending()
                : Sort.by(sortBy).descending();
        Pageable pageable = PageRequest.of(page, size, sort);
        return ResponseEntity.ok(inspectionService.getAllInspections(pageable));
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('EMPLOYEE', 'MANAGER', 'ADMIN')")
    public ResponseEntity<InspectionResponse> getInspectionById(@PathVariable Long id) {
        return ResponseEntity.ok(inspectionService.getInspectionById(id));
    }

    @GetMapping("/task/{taskId}")
    @PreAuthorize("hasAnyRole('EMPLOYEE', 'MANAGER', 'ADMIN')")
    public ResponseEntity<List<InspectionResponse>> getInspectionsByTaskId(@PathVariable Long taskId) {
        return ResponseEntity.ok(inspectionService.getInspectionsByTaskId(taskId));
    }

    @GetMapping("/task/{taskId}/type/{type}")
    @PreAuthorize("hasAnyRole('EMPLOYEE', 'MANAGER', 'ADMIN')")
    public ResponseEntity<InspectionResponse> getInspectionByTaskIdAndType(
            @PathVariable Long taskId,
            @PathVariable InspectionType type
    ) {
        return ResponseEntity.ok(inspectionService.getInspectionByTaskIdAndType(taskId, type));
    }

    @GetMapping("/booking/{bookingId}")
    @PreAuthorize("hasAnyRole('EMPLOYEE', 'MANAGER', 'ADMIN')")
    public ResponseEntity<List<InspectionResponse>> getInspectionsByBookingId(@PathVariable Long bookingId) {
        return ResponseEntity.ok(inspectionService.getInspectionsByBookingId(bookingId));
    }

    @GetMapping("/car/{carId}")
    @PreAuthorize("hasAnyRole('EMPLOYEE', 'MANAGER', 'ADMIN')")
    public ResponseEntity<List<InspectionResponse>> getInspectionsByCarId(@PathVariable Long carId) {
        return ResponseEntity.ok(inspectionService.getInspectionsByCarId(carId));
    }

    @GetMapping("/employee/{employeeId}")
    @PreAuthorize("hasAnyRole('EMPLOYEE', 'MANAGER', 'ADMIN')")
    public ResponseEntity<Page<InspectionResponse>> getInspectionsByEmployeeId(
            @PathVariable Long employeeId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size
    ) {
        Pageable pageable = PageRequest.of(page, size, Sort.by("createdAt").descending());
        return ResponseEntity.ok(inspectionService.getInspectionsByEmployeeId(employeeId, pageable));
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('EMPLOYEE', 'MANAGER', 'ADMIN')")
    public ResponseEntity<InspectionResponse> createInspection(@Valid @RequestBody InspectionRequest request) {
        return ResponseEntity.ok(inspectionService.createInspection(request));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('EMPLOYEE', 'MANAGER', 'ADMIN')")
    public ResponseEntity<InspectionResponse> updateInspection(
            @PathVariable Long id,
            @RequestBody InspectionRequest request
    ) {
        return ResponseEntity.ok(inspectionService.updateInspection(id, request));
    }

    @PostMapping("/{id}/photos")
    @PreAuthorize("hasAnyRole('EMPLOYEE', 'MANAGER', 'ADMIN')")
    public ResponseEntity<InspectionResponse> addPhotos(
            @PathVariable Long id,
            @RequestBody List<String> photoUrls
    ) {
        return ResponseEntity.ok(inspectionService.addPhotos(id, photoUrls));
    }

    @PostMapping("/{id}/signature")
    @PreAuthorize("hasAnyRole('EMPLOYEE', 'MANAGER', 'ADMIN')")
    public ResponseEntity<InspectionResponse> setSignature(
            @PathVariable Long id,
            @RequestBody Map<String, String> body
    ) {
        String signatureUrl = body.get("signatureUrl");
        if (signatureUrl == null || signatureUrl.isEmpty()) {
            throw new RuntimeException("Signature URL is required");
        }
        return ResponseEntity.ok(inspectionService.setSignature(id, signatureUrl));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasAnyRole('MANAGER', 'ADMIN')")
    public ResponseEntity<Map<String, String>> deleteInspection(@PathVariable Long id) {
        inspectionService.deleteInspection(id);
        Map<String, String> response = new HashMap<>();
        response.put("message", "Inspection deleted successfully");
        return ResponseEntity.ok(response);
    }

    @GetMapping("/stats")
    @PreAuthorize("hasAnyRole('MANAGER', 'ADMIN')")
    public ResponseEntity<Map<String, Object>> getInspectionStats() {
        Map<String, Object> stats = new HashMap<>();
        stats.put("pickupInspections", inspectionService.countPickupInspections());
        stats.put("returnInspections", inspectionService.countReturnInspections());
        return ResponseEntity.ok(stats);
    }
}
