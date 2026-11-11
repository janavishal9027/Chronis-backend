package com.chronis.coaching;

import com.chronis.common.security.AccessScope;
import com.fasterxml.jackson.databind.node.ObjectNode;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import java.util.*;

@RestController
@RequestMapping("/api/v1/coaching")
@PreAuthorize("isAuthenticated()")
public class CoachingController {
    private final AccessScope access;
    private final CoachSettingsService settings;
    private final StudyWorkspaceService workspace;
    private final PracticeService practice;
    public CoachingController(AccessScope access, CoachSettingsService settings, StudyWorkspaceService workspace, PracticeService practice) {
        this.access=access; this.settings=settings; this.workspace=workspace; this.practice=practice;
    }
    private long user(){return access.currentUser().getId();}
    @GetMapping("/workspace") public Map<String,Object> workspace(@RequestParam(defaultValue="1") int day){long user=user();var sessions=practice.summaries(user);return Map.of("settings",settings.config(user),"projectSections",workspace.projectSummaries(user),"carryovers",workspace.carries(user),"leaves",workspace.leaves(user),"plan",workspace.plan(user,day),"practiceSessions",sessions);}
}
