package com.chronis.engineering;

import jakarta.validation.constraints.*;
import java.util.UUID;

public record StudyWorkRequest(
    @NotNull UUID mutationId,
    @Min(0) long expectedVersion,
    @NotNull Status status,
    @NotNull @Size(max=12000) String notes,
    @NotNull @Size(max=2048) String evidence,
    @NotNull @Size(max=20000) String code,
    @Min(0) @Max(1440) int actualMinutes,
    @NotNull @Size(max=2000) String skipReason,
    @Min(0) @Max(5) int confidence,
    @NotNull @Size(max=4000) String complexity,
    @NotNull @Size(max=4000) String edgeCases,
    @NotNull @Size(max=12000) String testOutput,
    @NotNull @Size(max=2048) String gitReference,
    @NotNull @Size(max=4000) String blockers,
    @NotNull @Size(max=4000) String nextSteps,
    @NotNull @Size(max=1000) String correctionReason
) {
    public enum Status { NOT_STARTED, IN_PROGRESS, PARTIAL, BLOCKED, DONE }
    public enum Domain { CONCEPT, BASIC_CODING, SCENARIO, PROJECT, INTERVIEW, REVIEW }
}
