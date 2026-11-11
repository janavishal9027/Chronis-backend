package com.chronis.common.security;
import com.chronis.auth.domain.User;
import com.chronis.project.domain.Project;
import com.chronis.project.repository.ProjectMemberRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.Objects;
@Service @RequiredArgsConstructor @Transactional(readOnly=true)
public class AccessScope {
 private final ProjectMemberRepository projectMembers;
 public User currentUser(){var auth=SecurityContextHolder.getContext().getAuthentication();if(auth==null || !auth.isAuthenticated() || !(auth.getPrincipal() instanceof User user) || !user.isEnabled())throw new AccessDeniedException("An active account is required");return user;}
 public boolean canAccessUser(Long id){return Objects.equals(id,currentUser().getId());}
 public void requireUser(Long id){if(!canAccessUser(id))throw new AccessDeniedException("This record belongs to another account");}
 public void requireOwner(Long id){requireUser(id);}
 public boolean canAccessProject(Project project){Long id=currentUser().getId();return project.getOwner()!=null && Objects.equals(project.getOwner().getId(),id) || projectMembers.existsByProjectIdAndUserId(project.getId(),id);}
 public void requireProject(Project project){if(!canAccessProject(project))throw new AccessDeniedException("Project is outside your authorized scope");}
}
