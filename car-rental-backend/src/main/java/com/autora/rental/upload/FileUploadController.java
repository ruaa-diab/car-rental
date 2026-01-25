package com.autora.rental.upload;

import lombok.RequiredArgsConstructor;
import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.net.MalformedURLException;
import java.nio.file.Path;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/v1")
@RequiredArgsConstructor
public class FileUploadController {

    private final FileUploadService fileUploadService;

    @PostMapping("/upload/image")
    @PreAuthorize("hasAnyRole('EMPLOYEE', 'MANAGER', 'ADMIN')")
    public ResponseEntity<Map<String, String>> uploadImage(
            @RequestParam("file") MultipartFile file,
            @RequestParam(value = "type", defaultValue = "inspections") String type
    ) throws IOException {
        String url = fileUploadService.uploadImage(file, type);
        Map<String, String> response = new HashMap<>();
        response.put("url", url);
        response.put("message", "File uploaded successfully");
        return ResponseEntity.ok(response);
    }

    @PostMapping("/upload/images")
    @PreAuthorize("hasAnyRole('EMPLOYEE', 'MANAGER', 'ADMIN')")
    public ResponseEntity<Map<String, Object>> uploadImages(
            @RequestParam("files") List<MultipartFile> files,
            @RequestParam(value = "type", defaultValue = "inspections") String type
    ) throws IOException {
        List<String> urls = fileUploadService.uploadImages(files, type);
        Map<String, Object> response = new HashMap<>();
        response.put("urls", urls);
        response.put("count", urls.size());
        response.put("message", "Files uploaded successfully");
        return ResponseEntity.ok(response);
    }

    @PostMapping("/upload/signature")
    @PreAuthorize("hasAnyRole('EMPLOYEE', 'MANAGER', 'ADMIN')")
    public ResponseEntity<Map<String, String>> uploadSignature(
            @RequestParam("file") MultipartFile file
    ) throws IOException {
        String url = fileUploadService.uploadSignature(file);
        Map<String, String> response = new HashMap<>();
        response.put("url", url);
        response.put("message", "Signature uploaded successfully");
        return ResponseEntity.ok(response);
    }

    @PostMapping("/upload/inspection")
    @PreAuthorize("hasAnyRole('EMPLOYEE', 'MANAGER', 'ADMIN')")
    public ResponseEntity<Map<String, String>> uploadInspectionPhoto(
            @RequestParam("file") MultipartFile file
    ) throws IOException {
        String url = fileUploadService.uploadInspectionPhoto(file);
        Map<String, String> response = new HashMap<>();
        response.put("url", url);
        response.put("message", "Inspection photo uploaded successfully");
        return ResponseEntity.ok(response);
    }

    @PostMapping("/upload/profile")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<Map<String, String>> uploadProfileImage(
            @RequestParam("file") MultipartFile file
    ) throws IOException {
        String url = fileUploadService.uploadProfileImage(file);
        Map<String, String> response = new HashMap<>();
        response.put("url", url);
        response.put("message", "Profile image uploaded successfully");
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/upload")
    @PreAuthorize("hasAnyRole('MANAGER', 'ADMIN')")
    public ResponseEntity<Map<String, String>> deleteFile(@RequestParam("url") String fileUrl) {
        boolean deleted = fileUploadService.deleteFile(fileUrl);
        Map<String, String> response = new HashMap<>();
        if (deleted) {
            response.put("message", "File deleted successfully");
            return ResponseEntity.ok(response);
        } else {
            response.put("message", "File not found or could not be deleted");
            return ResponseEntity.notFound().build();
        }
    }

    // Serve uploaded files (public access)
    @GetMapping("/files/{subDirectory}/{filename}")
    public ResponseEntity<Resource> serveFile(
            @PathVariable String subDirectory,
            @PathVariable String filename
    ) throws MalformedURLException {
        Path filePath = fileUploadService.getFilePath(subDirectory, filename);
        Resource resource = new UrlResource(filePath.toUri());

        if (resource.exists() && resource.isReadable()) {
            // Determine content type
            String contentType = "application/octet-stream";
            if (filename.endsWith(".jpg") || filename.endsWith(".jpeg")) {
                contentType = "image/jpeg";
            } else if (filename.endsWith(".png")) {
                contentType = "image/png";
            } else if (filename.endsWith(".gif")) {
                contentType = "image/gif";
            } else if (filename.endsWith(".webp")) {
                contentType = "image/webp";
            }

            return ResponseEntity.ok()
                    .contentType(MediaType.parseMediaType(contentType))
                    .header(HttpHeaders.CONTENT_DISPOSITION, "inline; filename=\"" + filename + "\"")
                    .body(resource);
        } else {
            return ResponseEntity.notFound().build();
        }
    }
}
