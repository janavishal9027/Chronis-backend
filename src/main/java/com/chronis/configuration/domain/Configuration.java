package com.chronis.configuration.domain;

import com.chronis.common.audit.BaseEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "configuration", uniqueConstraints = @UniqueConstraint(columnNames = "key"))
@Getter
@Setter
public class Configuration extends BaseEntity {

    @Column(name = "key", nullable = false, unique = true, length = 200)
    private String key;

    @Column(name = "value", length = 2000)
    private String value;

    @Column(name = "description", length = 500)
    private String description;
}
