package com.chronis.coaching;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import javax.crypto.Cipher;
import javax.crypto.spec.GCMParameterSpec;
import javax.crypto.spec.SecretKeySpec;
import java.nio.file.*;
import java.nio.charset.StandardCharsets;
import java.security.SecureRandom;
import java.util.*;

@Component
public class CredentialVault {
    private final Path path; private final SecureRandom random=new SecureRandom();
    public CredentialVault(@Value("${app.coaching.master-key-path:}") String configured){
        String local=System.getenv("LOCALAPPDATA");
        this.path=configured.isBlank()?(local==null?Path.of(System.getProperty("user.home"),".config","chronis","credential-master.key"):Path.of(local,"Chronis","credential-master.key")):Path.of(configured);
    }
    synchronized byte[] key() throws Exception {
        if(!Files.exists(path)){Files.createDirectories(path.getParent());byte[] value=new byte[32];random.nextBytes(value);try{Files.write(path,value,StandardOpenOption.CREATE_NEW);}catch(FileAlreadyExistsException ignored){} }
        byte[] key=Files.readAllBytes(path);if(key.length!=32)throw new IllegalStateException("Credential encryption key is invalid");return key;
    }
    public String seal(String secret){try{byte[] nonce=new byte[12];random.nextBytes(nonce);Cipher cipher=Cipher.getInstance("AES/GCM/NoPadding");cipher.init(Cipher.ENCRYPT_MODE,new SecretKeySpec(key(),"AES"),new GCMParameterSpec(128,nonce));return Base64.getEncoder().encodeToString(nonce)+"."+Base64.getEncoder().encodeToString(cipher.doFinal(secret.getBytes(StandardCharsets.UTF_8)));}catch(Exception ex){throw new IllegalStateException("Could not save the provider credential securely",ex);}}
    public String open(String encrypted){try{String[] parts=encrypted.split("\\.");Cipher cipher=Cipher.getInstance("AES/GCM/NoPadding");cipher.init(Cipher.DECRYPT_MODE,new SecretKeySpec(key(),"AES"),new GCMParameterSpec(128,Base64.getDecoder().decode(parts[0])));return new String(cipher.doFinal(Base64.getDecoder().decode(parts[1])),StandardCharsets.UTF_8);}catch(Exception ex){throw new IllegalStateException("Saved provider credential cannot be read; re-enter it in Settings",ex);}}
}
