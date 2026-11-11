package com.chronis.coaching;

import com.chronis.common.security.AccessScope;
import com.fasterxml.jackson.databind.node.ObjectNode;
import jakarta.validation.Valid;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import java.util.*;

@RestController
@RequestMapping("/api/v1/coaching")
@PreAuthorize("isAuthenticated()")
public class ProjectWorkspaceController {
    private final AccessScope access; private final StudyWorkspaceService workspace; private final CoachingStore store;
    public ProjectWorkspaceController(AccessScope access, StudyWorkspaceService workspace, CoachingStore store) { this.access=access; this.workspace=workspace; this.store=store; }
    private long user(){return access.currentUser().getId();}
    @GetMapping("/projects/{id}") public List<CoachingStore.Record> project(@PathVariable String id){return workspace.project(user(),id);}
    @PutMapping("/projects/{id}/sections/{section}") public CoachingStore.Record project(@PathVariable String id,@PathVariable String section,@Valid @RequestBody CoachingRequests.SaveRequest body){return workspace.saveProject(user(),id,section,body.expectedVersion(),body.data());}
    @GetMapping("/projects/{id}/sections/{section}/history") public List<CoachingStore.Record> projectHistory(@PathVariable String id,@PathVariable String section){return store.history(user(),"PROJECT_SECTION",StudyWorkspaceService.project(id)+":"+StudyWorkspaceService.section(section));}
}
