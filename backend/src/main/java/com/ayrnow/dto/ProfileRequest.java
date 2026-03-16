package com.ayrnow.dto;

import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDate;

@Data
public class ProfileRequest {
    // Common
    private String firstName;
    private String lastName;
    private String phone;
    // Landlord
    private String companyName;
    private String businessAddress;
    private String taxId;
    // Tenant
    private LocalDate dateOfBirth;
    private String ssnLastFour;
    private String employer;
    private BigDecimal annualIncome;
}
