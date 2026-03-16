package com.ayrnow.controller;

import com.ayrnow.dto.DocumentResponse;
import com.ayrnow.dto.ReviewRequest;
import com.ayrnow.service.DocumentService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Path;
import java.util.List;

@RestController
@RequestMapping("/api/documents")
@RequiredArgsConstructor
public class DocumentController {

    private final DocumentService documentService;

    @PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @PreAuthorize("hasRole('TENANT')")
    public ResponseEntity<DocumentResponse> upload(Authentication auth,
                                                    @RequestParam("file") MultipartFile file,
                                                    @RequestParam("documentType") String documentType,
                                                    @RequestParam(value = "leaseId", required = false) Long leaseId) throws IOException {
        Long userId = (Long) auth.getPrincipal();
        return ResponseEntity.ok(documentService.uploadDocument(userId, leaseId, documentType, file));
    }

    @GetMapping("/tenant")
    @PreAuthorize("hasRole('TENANT')")
    public ResponseEntity<List<DocumentResponse>> getTenantDocs(Authentication auth) {
        Long userId = (Long) auth.getPrincipal();
        return ResponseEntity.ok(documentService.getDocumentsByTenant(userId));
    }

    @GetMapping("/lease/{leaseId}")
    public ResponseEntity<List<DocumentResponse>> getLeaseDocuments(@PathVariable Long leaseId) {
        return ResponseEntity.ok(documentService.getDocumentsByLease(leaseId));
    }

    @PutMapping("/{id}/review")
    @PreAuthorize("hasRole('LANDLORD')")
    public ResponseEntity<DocumentResponse> review(Authentication auth, @PathVariable Long id,
                                                    @Valid @RequestBody ReviewRequest request) {
        Long userId = (Long) auth.getPrincipal();
        return ResponseEntity.ok(documentService.reviewDocument(id, userId, request));
    }

    @GetMapping("/{id}/download")
    public ResponseEntity<Resource> download(Authentication auth, @PathVariable Long id) throws IOException {
        Long userId = (Long) auth.getPrincipal();
        Path path = documentService.getDocumentPath(id, userId);
        Resource resource = new UrlResource(path.toUri());
        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"" + path.getFileName() + "\"")
                .body(resource);
    }
}
