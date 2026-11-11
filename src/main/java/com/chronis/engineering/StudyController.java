package com.chronis.engineering;

import com.fasterxml.jackson.databind.JsonNode;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Size;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import java.util.*;
import io.swagger.v3.oas.annotations.tags.Tag;

@RestController
@RequestMapping("/api/v1/engineering")
@PreAuthorize("isAuthenticated()")
@Tag(name="AI Engineering Study",description="Workbook-backed lessons, per-user work updates and report history")
public class StudyController {
    private final StudyService study;
    public StudyController(StudyService study){this.study=study;}
    @GetMapping("/roadmap") public JsonNode roadmap(){return study.roadmap();}
    @GetMapping("/overview") public Map<String,Object> overview(){return study.overview();}
    @GetMapping("/days/{day}/progress") public Map<String,Object> progress(@PathVariable int day){return study.progress(day);}
    @PutMapping("/days/{day}/work/{domain}") public Map<String,Object> save(@PathVariable int day,@PathVariable StudyWorkRequest.Domain domain,@Valid @RequestBody StudyWorkRequest body){return study.save(day,domain,body);}
    public record SubmitRequest(@Size(max=1000) String correctionReason){}
    @PostMapping("/days/{day}/report") public Map<String,Object> submit(@PathVariable int day,@Valid @RequestBody(required=false) SubmitRequest body){return study.submit(day,body==null?null:body.correctionReason());}
    @GetMapping("/days/{day}/work/{domain}/history") public List<Map<String,Object>> history(@PathVariable int day,@PathVariable StudyWorkRequest.Domain domain){return study.history(day,domain);}
}
