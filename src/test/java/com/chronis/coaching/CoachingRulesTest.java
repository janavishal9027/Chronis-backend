package com.chronis.coaching;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ObjectNode;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.io.TempDir;
import java.nio.file.Path;
import java.time.Instant;
import java.util.List;
import static org.junit.jupiter.api.Assertions.*;

class CoachingRulesTest {
    final ObjectMapper mapper=new ObjectMapper();
    @TempDir Path temp;
    @Test void plannedLeaveAndBreakOverlapDoesNotDoubleCountFocus(){
        assertEquals(360,StudyWorkspaceService.focusCapacity(540,1020,List.of()));
        assertEquals(315,StudyWorkspaceService.focusCapacity(540,1020,List.of(new int[]{600,660})));
        assertEquals(315,StudyWorkspaceService.focusCapacity(540,1020,List.of(new int[]{600,660},new int[]{610,650})));
        assertEquals(0,StudyWorkspaceService.focusCapacity(1020,1200,List.of()));
    }
    @Test void activePracticeStopsCountingAtSeventeen(){
        ObjectNode s=mapper.createObjectNode().put("status","ACTIVE").put("usedSeconds",0).put("activeSince","2026-11-06T11:20:00Z").put("lastSeenAt","2026-11-06T11:29:59Z");
        assertEquals(600,PracticeService.elapsed(s,Instant.parse("2026-11-06T12:00:00Z")));
    }
    @Test void closingTheAppCannotAccumulateUnattendedHours(){
        ObjectNode s=mapper.createObjectNode().put("status","ACTIVE").put("usedSeconds",120).put("activeSince","2026-11-06T09:00:00Z").put("lastSeenAt","2026-11-06T09:00:30Z");
        assertEquals(210,PracticeService.elapsed(s,Instant.parse("2026-11-06T10:00:00Z")));
    }
    @Test void confidenceNeedsActualEvaluatedAnswersAndMinimumActiveTime(){
        ObjectNode s=mapper.createObjectNode().put("status","PAUSED").put("usedSeconds",900);var questions=s.putArray("questions");
        assertEquals(0,PracticeService.confidence(s));assertFalse(PracticeService.canComplete(s,Instant.now()));
        for(int i=0;i<3;i++)questions.addObject().putObject("answer").putObject("evaluation").put("correctness",4).put("reasoning",4).put("clarity",4).put("coverage",4);
        assertEquals(100,PracticeService.confidence(s));assertTrue(PracticeService.canComplete(s,Instant.now()));
        s.put("usedSeconds",899);assertFalse(PracticeService.canComplete(s,Instant.now()));
    }
    @Test void providerSecretsAreAuthenticatedEncryptedAndNeverStoredAsPlaintext(){
        var vault=new CredentialVault(temp.resolve("master.key").toString());String secret="fixture-provider-key-not-a-real-secret";
        String first=vault.seal(secret),second=vault.seal(secret);assertNotEquals(first,second);assertFalse(first.contains(secret));assertEquals(secret,vault.open(first));
        String tampered=first.substring(0,first.length()-5)+"AAAAA";assertThrows(IllegalStateException.class,()->vault.open(tampered));
    }
    @Test void modelAndProjectSelectorsCannotBecomeArbitraryUrls(){
        assertThrows(IllegalArgumentException.class,()->CoachSettingsService.provider("http://other.example"));
        assertThrows(IllegalArgumentException.class,()->CoachSettingsService.model("../../secrets"));
        assertThrows(IllegalArgumentException.class,()->StudyWorkspaceService.project("P51"));
        assertEquals("P50",StudyWorkspaceService.project("P50"));
    }
}
