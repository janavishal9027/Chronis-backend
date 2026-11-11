package com.chronis.common.security;
import com.chronis.auth.domain.User;
import com.chronis.project.domain.Project;
import com.chronis.project.repository.ProjectMemberRepository;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Test;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import java.util.List;
import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;
class AccessScopeTest {
 private final ProjectMemberRepository members=mock(ProjectMemberRepository.class);
 private final AccessScope scope=new AccessScope(members);
 @AfterEach void clear(){SecurityContextHolder.clearContext();}
 private User signIn(long id){User user=new User();user.setId(id);SecurityContextHolder.getContext().setAuthentication(new UsernamePasswordAuthenticationToken(user,null,List.of()));return user;}
 @Test void accountsCanOnlyAccessTheirOwnRecords(){signIn(10);assertTrue(scope.canAccessUser(10L));assertFalse(scope.canAccessUser(11L));assertThrows(AccessDeniedException.class,()->scope.requireUser(11L));}
 @Test void anonymousCannotAccessRecords(){assertThrows(AccessDeniedException.class,()->scope.requireOwner(10L));}
 @Test void onlyProjectOwnersOrMembersCanAccessAProject(){User owner=signIn(10);Project project=new Project();project.setId(42L);project.setOwner(owner);assertTrue(scope.canAccessProject(project));User other=new User();other.setId(11L);project.setOwner(other);assertFalse(scope.canAccessProject(project));when(members.existsByProjectIdAndUserId(42L,10L)).thenReturn(true);assertTrue(scope.canAccessProject(project));}
}
