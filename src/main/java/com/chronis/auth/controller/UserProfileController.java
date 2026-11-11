package com.chronis.auth.controller;
import com.chronis.common.dto.ApiResponse;
import com.chronis.common.security.AccessScope;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
@RestController @RequestMapping("/api/v1/users") @RequiredArgsConstructor
public class UserProfileController {
 private final AccessScope access;
 record Profile(Long id,String employeeId,String firstName,String lastName,String email,String designation,String status,String profilePictureUrl,String timezone){}
 @GetMapping("/me") @PreAuthorize("isAuthenticated()")
 public ApiResponse<Profile> me(){
  var u=access.currentUser();
  return ApiResponse.success(new Profile(u.getId(),u.getEmployeeId(),u.getFirstName(),u.getLastName(),u.getEmail(),null,u.isEnabled()?"ACTIVE":"INACTIVE",u.getProfilePictureUrl(),u.getTimezone()));
 }
}
