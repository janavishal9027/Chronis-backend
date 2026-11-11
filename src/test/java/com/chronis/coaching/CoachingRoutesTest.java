package com.chronis.coaching;

import com.chronis.common.security.AccessScope;
import com.chronis.auth.domain.User;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ObjectNode;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.http.MediaType;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.web.servlet.mvc.method.annotation.RequestMappingHandlerMapping;
import java.util.Set;
import java.util.stream.Collectors;

import java.util.Map;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

class CoachingRoutesTest {
    private final AccessScope access = mock(AccessScope.class);
    private final User employee = mock(User.class);
    private final CoachSettingsService settings = mock(CoachSettingsService.class);
    private final CoachingStore store = mock(CoachingStore.class);
    private final CoachingProvider provider = mock(CoachingProvider.class);
    private final StudyWorkspaceService workspace = mock(StudyWorkspaceService.class);
    private final PracticeService practice = mock(PracticeService.class);
    private final ObjectMapper json = new ObjectMapper();
    private MockMvc mvc;

    @BeforeEach void setup() {
        when(access.currentUser()).thenReturn(employee);
        when(employee.getId()).thenReturn(42L);
        mvc = MockMvcBuilders.standaloneSetup(
            new CoachingController(access, settings, workspace, practice),
            new CoachingSettingsController(access, settings, store, provider),
            new ProjectWorkspaceController(access, workspace, store),
            new CarryoverController(access, workspace),
            new PracticeController(access, practice)).build();
    }

    @Test void projectWorkKeepsItsOriginalRequestAndResponse() throws Exception {
        ObjectNode input = json.createObjectNode().put("status", "DONE");
        when(workspace.saveProject(eq(42L), eq("P01"), eq("DESIGN"), eq(3L), any(ObjectNode.class)))
            .thenReturn(new CoachingStore.Record("P01:DESIGN", 4, input, "2026-11-09T00:00:00Z"));
        mvc.perform(put("/api/v1/coaching/projects/P01/sections/DESIGN")
                .contentType(MediaType.APPLICATION_JSON).content("{\"expectedVersion\":3,\"data\":{\"status\":\"DONE\"}}"))
            .andExpect(status().isOk()).andExpect(jsonPath("$.version").value(4))
            .andExpect(jsonPath("$.data.status").value("DONE"));
        verify(workspace).saveProject(eq(42L), eq("P01"), eq("DESIGN"), eq(3L), any(ObjectNode.class));
    }

    @Test void practiceUsesTheSignedInEmployeeAndAcceptsDeviceTranscript() throws Exception {
        when(practice.deviceTranscript(42L, "session-1", "question-1", "my answer"))
            .thenReturn(Map.of("transcriptId", "transcript-1"));
        mvc.perform(post("/api/v1/coaching/practice/session-1/device-transcript")
                .contentType(MediaType.APPLICATION_JSON).content("{\"questionId\":\"question-1\",\"text\":\"my answer\"}"))
            .andExpect(status().isOk()).andExpect(jsonPath("$.transcriptId").value("transcript-1"));
        verify(practice).deviceTranscript(42L, "session-1", "question-1", "my answer");
    }

    @Test void practiceRejectsInvalidStudyDayBeforeStarting() throws Exception {
        mvc.perform(post("/api/v1/coaching/practice/start").contentType(MediaType.APPLICATION_JSON)
                .content("{\"dayNumber\":93}"))
            .andExpect(status().isBadRequest());
        verifyNoInteractions(practice);
    }

    @Test void settingsAndCarryoverKeepTheirExistingRoutes() throws Exception {
        when(settings.config(42L)).thenReturn(json.createObjectNode().put("provider", "openrouter"));
        when(workspace.carryUnfinished(42L, 3, "2026-11-10", "LATE_LOGIN")).thenReturn(java.util.List.of());
        mvc.perform(get("/api/v1/coaching/settings")).andExpect(status().isOk())
            .andExpect(jsonPath("$.provider").value("openrouter"));
        mvc.perform(post("/api/v1/coaching/carryovers/unfinished").contentType(MediaType.APPLICATION_JSON)
                .content("{\"sourceDay\":3,\"targetDate\":\"2026-11-10\",\"cause\":\"LATE_LOGIN\"}"))
            .andExpect(status().isOk());
        verify(workspace).carryUnfinished(42L, 3, "2026-11-10", "LATE_LOGIN");
    }

    @Test void everyFrontendCoachingRouteRemainsRegistered() {
        var mapping = mvc.getDispatcherServlet().getWebApplicationContext()
                .getBean(RequestMappingHandlerMapping.class);
        Set<String> actual = mapping.getHandlerMethods().keySet().stream()
                .flatMap(info -> info.getPatternValues().stream().flatMap(path ->
                        info.getMethodsCondition().getMethods().stream().map(method -> method + " " + path)))
                .collect(Collectors.toSet());
        Set<String> expected = Set.of(
                "GET /api/v1/coaching/workspace", "GET /api/v1/coaching/settings",
                "PUT /api/v1/coaching/settings", "POST /api/v1/coaching/settings/test",
                "DELETE /api/v1/coaching/settings/keys/{provider}", "GET /api/v1/coaching/projects/{id}",
                "PUT /api/v1/coaching/projects/{id}/sections/{section}",
                "GET /api/v1/coaching/projects/{id}/sections/{section}/history",
                "PUT /api/v1/coaching/carryovers/{id}", "POST /api/v1/coaching/carryovers/unfinished",
                "PUT /api/v1/coaching/leaves/{id}", "POST /api/v1/coaching/practice/start",
                "GET /api/v1/coaching/practice/{id}", "POST /api/v1/coaching/practice/{id}/action",
                "POST /api/v1/coaching/practice/{id}/answer", "POST /api/v1/coaching/practice/{id}/device-transcript",
                "POST /api/v1/coaching/practice/{id}/transcribe");
        assertEquals(expected, actual);
    }

    @Test void allCoachingControllersRetainTheExistingRoleRestriction() {
        for (Class<?> controller : new Class<?>[]{CoachingController.class, CoachingSettingsController.class,
                ProjectWorkspaceController.class, CarryoverController.class, PracticeController.class}) {
            assertEquals("isAuthenticated()", controller.getAnnotation(PreAuthorize.class).value());
        }
    }
}
