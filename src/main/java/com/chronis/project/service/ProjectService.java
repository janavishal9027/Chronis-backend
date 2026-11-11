package com.chronis.project.service;

import com.chronis.project.domain.Project;
import com.chronis.project.dto.ProjectDTO;
import com.chronis.project.repository.ProjectRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ProjectService {

    private final ProjectRepository projectRepository;
    private final com.chronis.common.security.AccessScope access;

    public List<ProjectDTO> getAll() {
        return projectRepository.findAll().stream().filter(access::canAccessProject).map(this::toDto).collect(Collectors.toList());
    }

    private ProjectDTO toDto(Project p) {
        return ProjectDTO.builder()
                .id(p.getId()).projectCode(p.getProjectCode()).name(p.getName())
                .description(p.getDescription()).ownerId(p.getOwner() != null ? p.getOwner().getId() : null)
                .startDate(p.getStartDate()).targetCompletionDate(p.getTargetCompletionDate())
                .status(p.getStatus()).priority(p.getPriority()).build();
    }
}
