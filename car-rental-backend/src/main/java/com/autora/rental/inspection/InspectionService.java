package com.autora.rental.inspection;

import com.autora.rental.task.Task;
import com.autora.rental.task.TaskService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class InspectionService {

    private final InspectionRepository inspectionRepository;
    private final TaskService taskService;

    public Page<InspectionResponse> getAllInspections(Pageable pageable) {
        return inspectionRepository.findAll(pageable).map(InspectionResponse::fromEntity);
    }

    public InspectionResponse getInspectionById(Long id) {
        Inspection inspection = inspectionRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Inspection not found with id: " + id));
        return InspectionResponse.fromEntity(inspection);
    }

    public List<InspectionResponse> getInspectionsByTaskId(Long taskId) {
        return inspectionRepository.findByTaskId(taskId).stream()
                .map(InspectionResponse::fromEntity)
                .collect(Collectors.toList());
    }

    public InspectionResponse getInspectionByTaskIdAndType(Long taskId, InspectionType type) {
        Inspection inspection = inspectionRepository.findByTaskIdAndType(taskId, type)
                .orElseThrow(() -> new RuntimeException("Inspection not found for task " + taskId + " and type " + type));
        return InspectionResponse.fromEntity(inspection);
    }

    public List<InspectionResponse> getInspectionsByBookingId(Long bookingId) {
        return inspectionRepository.findByBookingId(bookingId).stream()
                .map(InspectionResponse::fromEntity)
                .collect(Collectors.toList());
    }

    public List<InspectionResponse> getInspectionsByCarId(Long carId) {
        return inspectionRepository.findByCarId(carId).stream()
                .map(InspectionResponse::fromEntity)
                .collect(Collectors.toList());
    }

    public Page<InspectionResponse> getInspectionsByEmployeeId(Long employeeId, Pageable pageable) {
        return inspectionRepository.findByEmployeeId(employeeId, pageable)
                .map(InspectionResponse::fromEntity);
    }

    @Transactional
    public InspectionResponse createInspection(InspectionRequest request) {
        Task task = taskService.getTaskEntityById(request.getTaskId());

        Inspection inspection = Inspection.builder()
                .task(task)
                .type(request.getType())
                .odometerReading(request.getOdometerReading())
                .fuelLevel(request.getFuelLevel())
                .exteriorCondition(request.getExteriorCondition())
                .interiorCondition(request.getInteriorCondition())
                .featuresCheck(request.getFeaturesCheck())
                .documentsVerified(request.getDocumentsVerified())
                .customerIdVerified(request.getCustomerIdVerified())
                .licenseVerified(request.getLicenseVerified())
                .customerSignature(request.getCustomerSignature())
                .photos(request.getPhotos() != null ? request.getPhotos() : new ArrayList<>())
                .notes(request.getNotes())
                .damageNotes(request.getDamageNotes())
                .build();

        inspection = inspectionRepository.save(inspection);
        return InspectionResponse.fromEntity(inspection);
    }

    @Transactional
    public InspectionResponse updateInspection(Long id, InspectionRequest request) {
        Inspection inspection = inspectionRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Inspection not found with id: " + id));

        if (request.getOdometerReading() != null) {
            inspection.setOdometerReading(request.getOdometerReading());
        }
        if (request.getFuelLevel() != null) {
            inspection.setFuelLevel(request.getFuelLevel());
        }
        if (request.getExteriorCondition() != null) {
            inspection.setExteriorCondition(request.getExteriorCondition());
        }
        if (request.getInteriorCondition() != null) {
            inspection.setInteriorCondition(request.getInteriorCondition());
        }
        if (request.getFeaturesCheck() != null) {
            inspection.setFeaturesCheck(request.getFeaturesCheck());
        }
        if (request.getDocumentsVerified() != null) {
            inspection.setDocumentsVerified(request.getDocumentsVerified());
        }
        if (request.getCustomerIdVerified() != null) {
            inspection.setCustomerIdVerified(request.getCustomerIdVerified());
        }
        if (request.getLicenseVerified() != null) {
            inspection.setLicenseVerified(request.getLicenseVerified());
        }
        if (request.getCustomerSignature() != null) {
            inspection.setCustomerSignature(request.getCustomerSignature());
        }
        if (request.getPhotos() != null) {
            inspection.setPhotos(request.getPhotos());
        }
        if (request.getNotes() != null) {
            inspection.setNotes(request.getNotes());
        }
        if (request.getDamageNotes() != null) {
            inspection.setDamageNotes(request.getDamageNotes());
        }

        inspection = inspectionRepository.save(inspection);
        return InspectionResponse.fromEntity(inspection);
    }

    @Transactional
    public InspectionResponse addPhoto(Long id, String photoUrl) {
        Inspection inspection = inspectionRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Inspection not found with id: " + id));

        inspection.addPhoto(photoUrl);
        inspection = inspectionRepository.save(inspection);
        return InspectionResponse.fromEntity(inspection);
    }

    @Transactional
    public InspectionResponse addPhotos(Long id, List<String> photoUrls) {
        Inspection inspection = inspectionRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Inspection not found with id: " + id));

        for (String url : photoUrls) {
            inspection.addPhoto(url);
        }
        inspection = inspectionRepository.save(inspection);
        return InspectionResponse.fromEntity(inspection);
    }

    @Transactional
    public InspectionResponse setSignature(Long id, String signatureUrl) {
        Inspection inspection = inspectionRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Inspection not found with id: " + id));

        inspection.setCustomerSignature(signatureUrl);
        inspection = inspectionRepository.save(inspection);
        return InspectionResponse.fromEntity(inspection);
    }

    @Transactional
    public void deleteInspection(Long id) {
        if (!inspectionRepository.existsById(id)) {
            throw new RuntimeException("Inspection not found with id: " + id);
        }
        inspectionRepository.deleteById(id);
    }

    // Stats
    public long countPickupInspections() {
        return inspectionRepository.countByType(InspectionType.PICKUP);
    }

    public long countReturnInspections() {
        return inspectionRepository.countByType(InspectionType.RETURN);
    }
}
