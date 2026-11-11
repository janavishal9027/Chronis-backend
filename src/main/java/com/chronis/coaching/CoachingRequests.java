package com.chronis.coaching;

import com.fasterxml.jackson.databind.node.ObjectNode;
import jakarta.validation.constraints.*;
import java.util.UUID;

/** Request shapes shared by the workspace endpoints. */
public final class CoachingRequests {
    private CoachingRequests() {}
    public record SaveRequest(@Min(0) long expectedVersion,@NotNull ObjectNode data){}
    public record StartRequest(@Min(1) @Max(92) int dayNumber){}
    public record ActionRequest(@NotBlank String action){}
    public record AnswerRequest(@NotNull UUID mutationId,@NotBlank String questionId,String transcriptId,@Size(max=20000) String code){}
    public record DeviceTranscriptRequest(@NotBlank String questionId,@NotBlank @Size(max=16000) String text){}
    public record CarryRequest(@Min(1) @Max(92) int sourceDay,@NotBlank String targetDate,@NotBlank String cause){}
}
