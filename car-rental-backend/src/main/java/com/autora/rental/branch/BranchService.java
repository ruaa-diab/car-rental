package com.autora.rental.branch;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class BranchService {

    private final BranchRepository branchRepository;

    // Get all active branches
    public List<Branch> getAllActiveBranches() {
        return branchRepository.findByIsActiveTrue();
    }

    // Get all branches
    public List<Branch> getAllBranches() {
        return branchRepository.findAll();
    }

    // Get branch by ID
    public Branch getBranchById(Long id) {
        return branchRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Branch not found"));
    }

    // Get branches by city
    public List<Branch> getBranchesByCity(String city) {
        return branchRepository.findByCity(city);
    }

    // Add branch (admin)
    public Branch addBranch(Branch branch) {
        return branchRepository.save(branch);
    }

    // Update branch (admin)
    public Branch updateBranch(Long id, Branch branchDetails) {
        Branch branch = getBranchById(id);

        branch.setName(branchDetails.getName());
        branch.setAddress(branchDetails.getAddress());
        branch.setCity(branchDetails.getCity());
        branch.setCountry(branchDetails.getCountry());
        branch.setLatitude(branchDetails.getLatitude());
        branch.setLongitude(branchDetails.getLongitude());
        branch.setPhone(branchDetails.getPhone());
        branch.setEmail(branchDetails.getEmail());
        branch.setOpeningTime(branchDetails.getOpeningTime());
        branch.setClosingTime(branchDetails.getClosingTime());
        branch.setActive(branchDetails.isActive());

        return branchRepository.save(branch);
    }

    // Delete branch (soft delete)
    public void deleteBranch(Long id) {
        Branch branch = getBranchById(id);
        branch.setActive(false);
        branchRepository.save(branch);
    }
}
