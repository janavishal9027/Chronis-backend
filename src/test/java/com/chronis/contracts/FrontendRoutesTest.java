package com.chronis.contracts;

import com.chronis.auth.repository.UserRepository;
import com.chronis.dailyreport.controller.DailyReportController;
import com.chronis.dailyreport.service.DailyReportService;
import com.chronis.auth.controller.UserProfileController;
import com.chronis.common.security.AccessScope;
import com.chronis.project.controller.ProjectController;
import com.chronis.project.service.ProjectService;
import com.chronis.task.controller.TaskController;
import com.chronis.task.service.TaskService;
import org.junit.jupiter.api.Test;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.web.servlet.mvc.method.annotation.RequestMappingHandlerMapping;
import java.util.Set;
import java.util.stream.Collectors;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.Mockito.mock;

class FrontendRoutesTest {
    @Test void onlyRoutesUsedByTheReachableScreensRemain() {
        var mvc = MockMvcBuilders.standaloneSetup(
            new UserProfileController(mock(AccessScope.class)),
            new ProjectController(mock(ProjectService.class)),
            new TaskController(mock(TaskService.class)),
            new DailyReportController(mock(DailyReportService.class))).build();
        var mapping = mvc.getDispatcherServlet().getWebApplicationContext().getBean(RequestMappingHandlerMapping.class);
        var actual = mapping.getHandlerMethods().keySet().stream().flatMap(info ->
                info.getPatternValues().stream().flatMap(path -> info.getMethodsCondition().getMethods().stream()
                    .map(method -> method + " " + path))).collect(Collectors.toSet());
        assertEquals(Set.of("GET /api/v1/users/me", "GET /api/v1/projects", "GET /api/v1/tasks/my-tasks",
                "PATCH /api/v1/tasks/{id}/status", "GET /api/v1/daily-reports/today", "POST /api/v1/daily-reports",
                "POST /api/v1/daily-reports/{id}/submit"), actual);
    }
}
