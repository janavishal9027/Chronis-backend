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
public class CarryoverController {
    private final AccessScope access; private final StudyWorkspaceService workspace;
    public CarryoverController(AccessScope access, StudyWorkspaceService workspace) { this.access=access; this.workspace=workspace; }
    private long user(){return access.currentUser().getId();}
    @PutMapping("/carryovers/{id}") public CoachingStore.Record carry(@PathVariable String id,@Valid @RequestBody CoachingRequests.SaveRequest body){return workspace.saveCarry(user(),id,body.expectedVersion(),body.data());}
    @PostMapping("/carryovers/unfinished") public List<CoachingStore.Record> unfinished(@Valid @RequestBody CoachingRequests.CarryRequest body){return workspace.carryUnfinished(user(),body.sourceDay(),body.targetDate(),body.cause());}
    @PutMapping("/leaves/{id}") public CoachingStore.Record leave(@PathVariable String id,@Valid @RequestBody CoachingRequests.SaveRequest body){return workspace.saveLeave(user(),id,body.expectedVersion(),body.data());}
}
