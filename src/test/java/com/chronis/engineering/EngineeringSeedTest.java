package com.chronis.engineering;
import com.fasterxml.jackson.databind.*;
import org.junit.jupiter.api.Test;
import org.springframework.core.io.ClassPathResource;
import static org.junit.jupiter.api.Assertions.*;
class EngineeringSeedTest {
    @Test void fullWorkbookSeedIsConsecutiveAndOriginalProjectsRemain() throws Exception {
        JsonNode root;try(var in=new ClassPathResource("engineering-roadmap.json").getInputStream()){root=new ObjectMapper().readTree(in);}
        assertEquals(92,root.path("days").size());assertEquals(50,root.path("projects").size());assertEquals(8,root.path("phases").size());
        for(int i=0;i<92;i++){var d=root.path("days").get(i);assertEquals(EngineeringPolicy.dateForDay(i+1).toString(),d.path("date").asText());assertEquals(6,d.path("plannedHours").asInt());}
        assertTrue(root.path("days").get(0).path("projectId").isNull());assertEquals("Foundation lab",root.path("days").get(0).path("projectWorkstream").asText());
        assertEquals("Intelligent Data Analyzer",root.path("projects").get(0).path("title").asText());
        assertEquals(360,java.util.stream.StreamSupport.stream(root.path("studyBlocks").spliterator(),false).mapToInt(n->n.path("minutes").asInt()).sum());
        assertEquals(5,root.path("reminders").size());
    }
}
