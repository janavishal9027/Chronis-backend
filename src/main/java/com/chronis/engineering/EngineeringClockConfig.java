package com.chronis.engineering;

import java.time.Clock;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class EngineeringClockConfig {
    @Bean
    public Clock engineeringClock() { return Clock.systemUTC(); }
}
