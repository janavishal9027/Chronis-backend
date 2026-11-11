package com.chronis.project.dto;

import com.chronis.project.domain.Project;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ProjectDTO {
    private Long id;
    private String projectCode;
    private String name;
    private String description;
    private Long ownerId;
    private LocalDate startDate;
    private LocalDate targetCompletionDate;
    private Project.Status status;
    private String priority;
}
