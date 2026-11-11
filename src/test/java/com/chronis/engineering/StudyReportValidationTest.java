package com.chronis.engineering;
import org.junit.jupiter.api.Test;
import com.fasterxml.jackson.databind.*;
import com.fasterxml.jackson.databind.node.*;
import java.util.*;
import static org.junit.jupiter.api.Assertions.*;
class StudyReportValidationTest {
    private List<Map<String,Object>> rows(){var list=new ArrayList<Map<String,Object>>();for(var d:List.of("CONCEPT","BASIC_CODING","SCENARIO","PROJECT","INTERVIEW")){ObjectNode n=JsonNodeFactory.instance.objectNode().put("status","NOT_STARTED").put("skipReason","Illness; recorded honestly");list.add(Map.of("domain",d,"data",n));}return list;}
    @Test void requiresAllFiveDomains(){assertEquals(5,StudyService.validateReport(List.of()).size());assertTrue(StudyService.validateReport(rows()).isEmpty());}
    @Test void notesAloneAreNotProofAndCodingNeedsTests(){var rows=rows();ObjectNode d=(ObjectNode)rows.get(1).get("data");d.put("status","DONE").put("skipReason","").put("notes","Solved");assertEquals(2,StudyService.validateReport(rows).size());d.put("evidence","CLI output captured").put("testOutput","3 passed");assertTrue(StudyService.validateReport(rows).isEmpty());}
    @Test void scenarioRequiresComplexityAndEdgeCases(){var rows=rows();ObjectNode d=(ObjectNode)rows.get(2).get("data");d.put("status","PARTIAL").put("evidence","Failing test fixture");assertFalse(StudyService.validateReport(rows).isEmpty());d.put("complexity","O(n) time, O(1) space").put("edgeCases","empty input and missing args");assertTrue(StudyService.validateReport(rows).isEmpty());}
}
