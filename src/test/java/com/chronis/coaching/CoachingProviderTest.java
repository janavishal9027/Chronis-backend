package com.chronis.coaching;

import com.fasterxml.jackson.databind.*;
import org.junit.jupiter.api.Test;
import org.springframework.web.server.ResponseStatusException;
import java.net.URI;
import java.net.http.*;
import java.util.*;
import java.nio.ByteBuffer;
import java.nio.charset.StandardCharsets;
import java.io.ByteArrayOutputStream;
import java.util.concurrent.*;
import java.util.concurrent.Flow;
import javax.net.ssl.SSLSession;
import static org.junit.jupiter.api.Assertions.*;

class CoachingProviderTest {
    final ObjectMapper json=new ObjectMapper();
    record Reply(int statusCode,String body) implements HttpResponse<String> {
        public HttpRequest request(){return null;}public Optional<HttpResponse<String>> previousResponse(){return Optional.empty();}
        public HttpHeaders headers(){return HttpHeaders.of(Map.of(),(a,b)->true);}public Optional<SSLSession> sslSession(){return Optional.empty();}
        public URI uri(){return URI.create("https://api.openai.com/v1/responses");}public HttpClient.Version version(){return HttpClient.Version.HTTP_1_1;}
    }
    String turn(){return "{\"evaluation\":{\"correctness\":3,\"reasoning\":3,\"clarity\":2,\"coverage\":3,\"feedback\":\"Good trade-off\",\"improvement\":\"Discuss empty input\"},\"question\":{\"kind\":\"ORAL\",\"text\":\"When would you use a set?\",\"topic\":\"Collections\",\"language\":\"Python\",\"referenceAnswer\":\"Unique membership\"}}";}
    JsonNode body(HttpRequest request) throws Exception {
        var result=new CompletableFuture<byte[]>();var bytes=new ByteArrayOutputStream();
        request.bodyPublisher().orElseThrow().subscribe(new Flow.Subscriber<ByteBuffer>(){
            public void onSubscribe(Flow.Subscription subscription){subscription.request(Long.MAX_VALUE);}
            public void onNext(ByteBuffer data){byte[] chunk=new byte[data.remaining()];data.get(chunk);bytes.writeBytes(chunk);}
            public void onError(Throwable error){result.completeExceptionally(error);}
            public void onComplete(){result.complete(bytes.toByteArray());}
        });
        return json.readTree(new String(result.get(5,TimeUnit.SECONDS),StandardCharsets.UTF_8));
    }
    @Test void openRouterQuestionsUseOnlyFreeRouterWithZeroPriceCeilings() throws Exception {
        var payload=json.createObjectNode();payload.putArray("choices").addObject().putObject("message").put("content",turn());
        var client=new HttpCoachingProvider(json,request->{
            assertEquals("openrouter.ai",request.uri().getHost());
            assertEquals("/api/v1/chat/completions",request.uri().getPath());
            assertEquals("Bearer fixture-test-key",request.headers().firstValue("Authorization").orElseThrow());
            var sent=body(request);assertEquals(CoachSettingsService.FREE_MODEL,sent.path("model").asText());
            assertEquals(0,sent.path("provider").path("max_price").path("prompt").asInt(-1));
            assertEquals(0,sent.path("provider").path("max_price").path("completion").asInt(-1));
            assertEquals(0,sent.path("provider").path("max_price").path("request").asInt(-1));
            assertFalse(sent.toString().contains("fixture-test-key"));return new Reply(200,payload.toString());
        });
        assertEquals("Collections",client.turn("OPENROUTER",CoachSettingsService.FREE_MODEL,"fixture-test-key",json.createObjectNode(),"ORAL").path("question").path("topic").asText());
        assertThrows(IllegalArgumentException.class,()->client.turn("OPENROUTER","openai/paid","fixture-test-key",json.createObjectNode(),"ORAL"));
        assertThrows(ResponseStatusException.class,()->CoachSettingsService.requireFreeProvider("OPENAI"));
    }
    @Test void openRouterVoiceUploadIsBlockedBeforeAnyNetworkRequest(){
        var client=new HttpCoachingProvider(json,request->{fail("No voice recording should be sent");return null;});
        assertThrows(org.springframework.web.server.ResponseStatusException.class,()->client.transcribe("OPENROUTER",CoachSettingsService.FREE_AUDIO_MODEL,"fixture-test-key",new byte[]{1,2,3},"audio/wav"));
    }
    @Test void openAiResponsesAreParsedAndOnlyTheOfficialHostReceivesTheKey() throws Exception {
        var payload=json.createObjectNode().put("status","completed");payload.putArray("output").addObject().putArray("content").addObject().put("type","output_text").put("text",turn());
        var client=new HttpCoachingProvider(json,request->{assertEquals("api.openai.com",request.uri().getHost());assertEquals("/v1/responses",request.uri().getPath());assertEquals("Bearer fixture-test-key",request.headers().firstValue("Authorization").orElseThrow());assertFalse(request.uri().toString().contains("fixture-test-key"));return new Reply(200,payload.toString());});
        assertEquals("ORAL",client.turn("OPENAI","gpt-5-mini","fixture-test-key",json.createObjectNode(),"ORAL").path("question").path("kind").asText());
    }
    @Test void geminiQuestionsAndHeaderAuthenticationAreSupported() throws Exception {
        var payload=json.createObjectNode();payload.putArray("candidates").addObject().putObject("content").putArray("parts").addObject().put("text",turn());
        var client=new HttpCoachingProvider(json,request->{assertEquals("generativelanguage.googleapis.com",request.uri().getHost());assertEquals("fixture-test-key",request.headers().firstValue("x-goog-api-key").orElseThrow());assertFalse(request.uri().toString().contains("fixture-test-key"));return new Reply(200,payload.toString());});
        assertEquals("Collections",client.turn("GEMINI","gemini-2.5-flash","fixture-test-key",json.createObjectNode(),"ORAL").path("question").path("topic").asText());
    }
    @Test void providerFailuresDoNotEchoProviderErrorBodiesOrKeys(){
        var client=new HttpCoachingProvider(json,request->new Reply(401,"secret-fixture-key-should-not-be-echoed"));
        var error=assertThrows(ResponseStatusException.class,()->client.turn("OPENAI","gpt-5-mini","secret-fixture-key-should-not-be-echoed",json.createObjectNode(),"ORAL"));assertFalse(error.getReason().contains("secret-fixture"));
    }
    @Test void malformedOrOutOfRangeGradesAreRejected() throws Exception {
        var invalid=(com.fasterxml.jackson.databind.node.ObjectNode)json.readTree(turn());((com.fasterxml.jackson.databind.node.ObjectNode)invalid.path("evaluation")).put("correctness",99);
        assertThrows(IllegalArgumentException.class,()->HttpCoachingProvider.validateTurn(invalid,"ORAL"));
    }
    @Test void transcriptionUsesMultipartAndDoesNotPutCredentialsInTheUrl(){
        var client=new HttpCoachingProvider(json,request->{assertEquals("/v1/audio/transcriptions",request.uri().getPath());assertTrue(request.headers().firstValue("Content-Type").orElseThrow().startsWith("multipart/form-data; boundary="));return new Reply(200,"{\"text\":\"A set removes duplicates.\"}");});
        assertEquals("A set removes duplicates.",client.transcribe("OPENAI","gpt-4o-mini-transcribe","fixture-test-key",new byte[]{1,2,3},"audio/webm"));
    }
}
