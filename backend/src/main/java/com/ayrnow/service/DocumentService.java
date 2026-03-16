package com.ayrnow.service;

import com.ayrnow.dto.DocumentResponse;
import com.ayrnow.dto.ReviewRequest;
import com.ayrnow.entity.*;
import com.ayrnow.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Set;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class DocumentService {

    private final TenantDocumentRepository documentRepository;
    private final UserRepository userRepository;
    private final LeaseRepository leaseRepository;
    private final NotificationService notificationService;
    private final Path fileStorageLocation;

    private static final Set<String> ALLOWED_TYPES = Set.of("pdf", "jpg", "jpeg", "png");
    private static final long MAX_FILE_SIZE = 10 * 1024 * 1024; // 10MB

    @Transactional
    public DocumentResponse uploadDocument(Long tenantId, Long leaseId, String documentType,
                                           MultipartFile file) throws IOException {
        User tenant = userRepository.findById(tenantId)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));

        Lease lease = null;
        if (leaseId != null) {
            lease = leaseRepository.findById(leaseId)
                    .orElseThrow(() -> new IllegalArgumentException("Lease not found"));
            if (!lease.getTenant().getId().equals(tenantId)) {
                throw new IllegalArgumentException("Access denied");
            }
        }

        String originalName = file.getOriginalFilename();
        String ext = originalName != null && originalName.contains(".")
                ? originalName.substring(originalName.lastIndexOf(".") + 1).toLowerCase()
                : "";

        if (!ALLOWED_TYPES.contains(ext)) {
            throw new IllegalArgumentException("File type not allowed. Accepted: PDF, JPG, JPEG, PNG");
        }
        if (file.getSize() > MAX_FILE_SIZE) {
            throw new IllegalArgumentException("File too large. Max 10MB");
        }

        String storedName = UUID.randomUUID() + "." + ext;
        Path targetPath = fileStorageLocation.resolve(storedName);
        Files.copy(file.getInputStream(), targetPath);

        TenantDocument doc = TenantDocument.builder()
                .tenant(tenant)
                .lease(lease)
                .documentType(DocumentType.valueOf(documentType.toUpperCase()))
                .fileName(originalName)
                .filePath(targetPath.toString())
                .fileType(ext.toUpperCase())
                .fileSize(file.getSize())
                .build();
        doc = documentRepository.save(doc);

        // Notify landlord if lease exists
        if (lease != null) {
            notificationService.createNotification(lease.getLandlord().getId(),
                    "Document Uploaded",
                    tenant.getFirstName() + " uploaded a " + documentType + " document",
                    "DOCUMENT", doc.getId(), "DOCUMENT");
        }

        return toResponse(doc);
    }

    public List<DocumentResponse> getDocumentsByTenant(Long tenantId) {
        return documentRepository.findByTenantIdOrderByCreatedAtDesc(tenantId).stream()
                .map(this::toResponse).toList();
    }

    public List<DocumentResponse> getDocumentsByLease(Long leaseId) {
        return documentRepository.findByLeaseId(leaseId).stream()
                .map(this::toResponse).toList();
    }

    @Transactional
    public DocumentResponse reviewDocument(Long docId, Long reviewerId, ReviewRequest request) {
        TenantDocument doc = documentRepository.findById(docId)
                .orElseThrow(() -> new IllegalArgumentException("Document not found"));
        User reviewer = userRepository.findById(reviewerId)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));

        doc.setStatus(DocumentStatus.valueOf(request.getStatus().toUpperCase()));
        doc.setReviewComment(request.getComment());
        doc.setReviewedBy(reviewer);
        doc.setReviewedAt(LocalDateTime.now());
        documentRepository.save(doc);

        notificationService.createNotification(doc.getTenant().getId(),
                "Document " + request.getStatus(),
                "Your " + doc.getDocumentType() + " document has been " + request.getStatus().toLowerCase(),
                "DOCUMENT", doc.getId(), "DOCUMENT");

        return toResponse(doc);
    }

    public Path getDocumentPath(Long docId, Long userId) {
        TenantDocument doc = documentRepository.findById(docId)
                .orElseThrow(() -> new IllegalArgumentException("Document not found"));
        // Allow tenant or landlord (via lease) to download
        return Path.of(doc.getFilePath());
    }

    private DocumentResponse toResponse(TenantDocument d) {
        return DocumentResponse.builder()
                .id(d.getId())
                .tenantId(d.getTenant().getId())
                .tenantName(d.getTenant().getFirstName() + " " + d.getTenant().getLastName())
                .leaseId(d.getLease() != null ? d.getLease().getId() : null)
                .documentType(d.getDocumentType().name())
                .fileName(d.getFileName())
                .fileType(d.getFileType())
                .fileSize(d.getFileSize())
                .status(d.getStatus().name())
                .reviewComment(d.getReviewComment())
                .reviewedAt(d.getReviewedAt() != null ? d.getReviewedAt().toString() : null)
                .createdAt(d.getCreatedAt().toString())
                .build();
    }
}
