package com.autora.rental.upload;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Service
public class FileUploadService {

    @Value("${app.upload.dir:uploads}")
    private String uploadDir;

    @Value("${app.upload.max-size:10485760}")
    private long maxFileSize;

    private static final List<String> ALLOWED_IMAGE_TYPES = List.of(
            "image/jpeg", "image/png", "image/gif", "image/webp"
    );

    /**
     * Upload a single image file
     */
    public String uploadImage(MultipartFile file, String subDirectory) throws IOException {
        validateFile(file);
        return saveFile(file, subDirectory);
    }

    /**
     * Upload multiple image files
     */
    public List<String> uploadImages(List<MultipartFile> files, String subDirectory) throws IOException {
        List<String> urls = new ArrayList<>();
        for (MultipartFile file : files) {
            validateFile(file);
            urls.add(saveFile(file, subDirectory));
        }
        return urls;
    }

    /**
     * Upload a signature image (base64 or file)
     */
    public String uploadSignature(MultipartFile file) throws IOException {
        validateFile(file);
        return saveFile(file, "signatures");
    }

    /**
     * Upload inspection photo
     */
    public String uploadInspectionPhoto(MultipartFile file) throws IOException {
        validateFile(file);
        return saveFile(file, "inspections");
    }

    /**
     * Upload profile image
     */
    public String uploadProfileImage(MultipartFile file) throws IOException {
        validateFile(file);
        return saveFile(file, "profiles");
    }

    /**
     * Delete a file by its URL/path
     */
    public boolean deleteFile(String fileUrl) {
        try {
            // Extract filename from URL
            String filename = fileUrl.substring(fileUrl.lastIndexOf("/") + 1);

            // Try to find and delete the file in all subdirectories
            String[] subdirs = {"inspections", "signatures", "profiles"};
            for (String subdir : subdirs) {
                Path filePath = Paths.get(uploadDir, subdir, filename);
                if (Files.exists(filePath)) {
                    Files.delete(filePath);
                    return true;
                }
            }
            return false;
        } catch (IOException e) {
            return false;
        }
    }

    private void validateFile(MultipartFile file) {
        if (file == null || file.isEmpty()) {
            throw new RuntimeException("File is empty or null");
        }

        if (file.getSize() > maxFileSize) {
            throw new RuntimeException("File size exceeds maximum allowed size of " + (maxFileSize / 1024 / 1024) + "MB");
        }

        String contentType = file.getContentType();
        if (contentType == null || !ALLOWED_IMAGE_TYPES.contains(contentType)) {
            throw new RuntimeException("Invalid file type. Allowed types: JPEG, PNG, GIF, WebP");
        }
    }

    private String saveFile(MultipartFile file, String subDirectory) throws IOException {
        // Create directory if it doesn't exist
        Path dirPath = Paths.get(uploadDir, subDirectory);
        if (!Files.exists(dirPath)) {
            Files.createDirectories(dirPath);
        }

        // Generate unique filename
        String originalFilename = file.getOriginalFilename();
        String extension = "";
        if (originalFilename != null && originalFilename.contains(".")) {
            extension = originalFilename.substring(originalFilename.lastIndexOf("."));
        }
        String newFilename = UUID.randomUUID().toString() + extension;

        // Save file
        Path filePath = dirPath.resolve(newFilename);
        Files.copy(file.getInputStream(), filePath, StandardCopyOption.REPLACE_EXISTING);

        // Return the URL path that can be used to access the file
        return "/api/v1/files/" + subDirectory + "/" + newFilename;
    }

    /**
     * Get the full path for serving a file
     */
    public Path getFilePath(String subDirectory, String filename) {
        return Paths.get(uploadDir, subDirectory, filename);
    }
}
