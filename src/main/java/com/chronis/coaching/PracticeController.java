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
public class PracticeController {
    private final AccessScope access; private final PracticeService practice;
    public PracticeController(AccessScope access, PracticeService practice) { this.access=access; this.practice=practice; }
    private long user(){return access.currentUser().getId();}
    @PostMapping("/practice/start") public ObjectNode start(@Valid @RequestBody CoachingRequests.StartRequest body){return practice.start(user(),body.dayNumber());}
    @GetMapping("/practice/{id}") public ObjectNode practice(@PathVariable String id){return practice.get(user(),id);}
    @PostMapping("/practice/{id}/action") public ObjectNode action(@PathVariable String id,@Valid @RequestBody CoachingRequests.ActionRequest body){return practice.action(user(),id,body.action());}
    @PostMapping("/practice/{id}/answer") public ObjectNode answer(@PathVariable String id,@Valid @RequestBody CoachingRequests.AnswerRequest body){return practice.answer(user(),id,body.questionId(),body.transcriptId(),body.code(),body.mutationId());}
    @PostMapping("/practice/{id}/device-transcript") public Map<String,String> deviceTranscript(@PathVariable String id,@Valid @RequestBody CoachingRequests.DeviceTranscriptRequest body){return practice.deviceTranscript(user(),id,body.questionId(),body.text());}
    @PostMapping(value="/practice/{id}/transcribe",consumes="multipart/form-data") public Map<String,String> transcript(@PathVariable String id,@RequestParam String questionId,@RequestParam("audio") MultipartFile audio) throws java.io.IOException {if(audio.getContentType()==null)throw new IllegalArgumentException("Recording format is missing");return practice.transcribe(user(),id,questionId,audio.getBytes(),audio.getContentType());}
}
