package com.chronis.coaching;

import com.fasterxml.jackson.databind.node.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.http.HttpStatus;
import java.util.*;

@Service
@Transactional(readOnly=true)
public class CoachSettingsService {
    private final CoachingStore store; private final CredentialVault vault;
    public CoachSettingsService(CoachingStore store,CredentialVault vault){this.store=store;this.vault=vault;}
    public static final String FREE_MODEL="openrouter/free";
    public static final String FREE_AUDIO_MODEL="nvidia/nemotron-3-nano-omni-30b-a3b-reasoning:free";
    public static String provider(String value){if(!Set.of("OPENAI","GEMINI","OPENROUTER").contains(value))throw new IllegalArgumentException("Choose a supported provider");return value;}
    public static void requireFreeProvider(String value){if(!"OPENROUTER".equals(value))throw new ResponseStatusException(HttpStatus.PRECONDITION_REQUIRED,"Choose OpenRouter free in Settings before continuing. Existing credentials remain saved.");}
    public static String freeModel(String value){if(!FREE_MODEL.equals(value))throw new IllegalArgumentException("Only the OpenRouter free model router is allowed");return value;}
    public static String model(String value){if(value==null||!value.matches("[A-Za-z0-9][A-Za-z0-9._:-]{0,119}"))throw new IllegalArgumentException("Enter a valid model ID");return value;}
    public ObjectNode config(long user){
        ObjectNode settings=store.get(user,"SETTINGS","coach").map(r->r.data().deepCopy()).orElseGet(()->store.mapper().createObjectNode().put("provider","OPENROUTER").put("model",FREE_MODEL).put("durationMinutes",20).put("transcriptionModel",FREE_AUDIO_MODEL).put("autoPractice",true));
        ObjectNode keys=settings.putObject("savedKeys");for(String p:List.of("OPENAI","GEMINI","OPENROUTER"))keys.put(p,store.get(user,"PROVIDER_KEY",p).isPresent());
        settings.put("logoutPolicy","FIXED_17");return settings;
    }
    public String key(long user,String provider){return store.get(user,"PROVIDER_KEY",provider(provider)).map(r->vault.open(r.data().path("encrypted").asText())).orElseThrow(()->new ResponseStatusException(HttpStatus.PRECONDITION_REQUIRED,"Add your provider API key in Settings before starting AI practice."));}
    @Transactional public ObjectNode save(long user,ObjectNode request){
        String p=provider(request.path("provider").asText());String m=p.equals("OPENROUTER")?freeModel(request.path("model").asText()):model(request.path("model").asText());
        int minutes=request.path("durationMinutes").asInt(20);if(minutes<15||minutes>30)throw new IllegalArgumentException("Practice duration must be between 15 and 30 minutes");
        String speech=p.equals("OPENROUTER")?FREE_AUDIO_MODEL:request.path("transcriptionModel").asText("gpt-4o-mini-transcribe");if(p.equals("OPENAI"))model(speech);
        if(request.hasNonNull("apiKey")&&!request.path("apiKey").asText().isBlank()){
            String secret=request.path("apiKey").asText().trim().replaceFirst("(?i)^Bearer\\s+","");if(secret.length()<8||secret.length()>2000||secret.chars().anyMatch(c->c<33||c>126))throw new IllegalArgumentException("Enter a valid provider API key");
            store.replace(user,"PROVIDER_KEY",p,store.mapper().createObjectNode().put("encrypted",vault.seal(secret)));
        }
        ObjectNode clean=store.mapper().createObjectNode().put("provider",p).put("model",m).put("durationMinutes",minutes).put("transcriptionModel",speech).put("autoPractice",true);
        store.replace(user,"SETTINGS","coach",clean);return config(user);
    }
    @Transactional public ObjectNode remove(long user,String provider){store.removeSecret(user,provider(provider));return config(user);}
}
