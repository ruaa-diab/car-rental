package com.autora.rental.branch;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/branches")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class BranchController {

    private final BranchService branchService;

    // ============ PUBLIC ENDPOINTS ============

    @GetMapping("/public")
    public ResponseEntity<List<Branch>> getAllActiveBranches() {
        return ResponseEntity.ok(branchService.getAllActiveBranches());
    }

    @GetMapping("/public/active")
    public ResponseEntity<List<Branch>> getActiveBranches() {
        return ResponseEntity.ok(branchService.getAllActiveBranches());
    }

    @GetMapping("/public/{id}")
    public ResponseEntity<Branch> getBranchById(@PathVariable Long id) {
        return ResponseEntity.ok(branchService.getBranchById(id));
    }

    @GetMapping("/public/city/{city}")
    public ResponseEntity<List<Branch>> getBranchesByCity(@PathVariable String city) {
        return ResponseEntity.ok(branchService.getBranchesByCity(city));
    }

    // ============ MANAGER ENDPOINTS ============

    @GetMapping
    @PreAuthorize("hasRole('MANAGER')")
    public ResponseEntity<List<Branch>> getAllBranches() {
        return ResponseEntity.ok(branchService.getAllBranches());
    }

    @PostMapping
    @PreAuthorize("hasRole('MANAGER')")
    public ResponseEntity<Branch> addBranch(@RequestBody Branch branch) {
        return ResponseEntity.ok(branchService.addBranch(branch));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('MANAGER')")
    public ResponseEntity<Branch> updateBranch(@PathVariable Long id, @RequestBody Branch branch) {
        return ResponseEntity.ok(branchService.updateBranch(id, branch));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('MANAGER')")
    public ResponseEntity<?> deleteBranch(@PathVariable Long id) {
        branchService.deleteBranch(id);
        return ResponseEntity.ok(Map.of("message", "Branch deleted successfully"));
    }
}
