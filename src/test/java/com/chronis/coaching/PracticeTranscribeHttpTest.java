package com.chronis.coaching;

import com.chronis.auth.domain.User;
import com.chronis.common.exception.GlobalExceptionHandler;
import com.chronis.common.security.AccessScope;
import java.util.Map;
import org.junit.jupiter.api.Test;
import org.springframework.mock.web.MockMultipartFile;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

class PracticeTranscribeHttpTest {
    @Test void rejectsWrongContentTypeAndAcceptsMultipartAudio() throws Exception {
        var access=mock(AccessScope.class);
        var user=mock(User.class);
        var practice=mock(PracticeService.class);
        when(access.currentUser()).thenReturn(user);
        when(user.getId()).thenReturn(42L);
        when(practice.transcribe(eq(42L),eq("session-1"),eq("question-1"),any(byte[].class),eq("audio/wav")))
                .thenReturn(Map.of("transcriptId","receipt-1","text","Sample"));
        var mvc=MockMvcBuilders.standaloneSetup(new PracticeController(access,practice))
                .setControllerAdvice(new GlobalExceptionHandler()).build();
        mvc.perform(post("/api/v1/coaching/practice/session-1/transcribe")
                .contentType("application/json").content("{}"))
                .andExpect(status().isUnsupportedMediaType());
        mvc.perform(multipart("/api/v1/coaching/practice/session-1/transcribe")
                .file(new MockMultipartFile("audio","sample.wav","audio/wav",new byte[]{1,2,3}))
                .param("questionId","question-1"))
                .andExpect(status().isOk()).andExpect(jsonPath("$.transcriptId").value("receipt-1"));
    }
}
