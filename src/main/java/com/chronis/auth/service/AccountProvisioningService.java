package com.chronis.auth.service;
import com.chronis.auth.domain.User;
import com.chronis.auth.repository.UserRepository;
import java.security.SecureRandom;
import java.util.Locale;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
@Service
public class AccountProvisioningService {
 private static final SecureRandom RANDOM=new SecureRandom();
 private final UserRepository users; private final PasswordEncoder passwords;
 public AccountProvisioningService(UserRepository users,PasswordEncoder passwords){this.users=users;this.passwords=passwords;}
 @Transactional public User createAccount(String name,String email,String password,boolean verified,String googleSubject){
  String normalized=email.trim().toLowerCase(Locale.ROOT); String[] names=splitName(name);
  User user=new User(); user.setUsername(normalized);user.setEmail(normalized);user.setPassword(passwords.encode(password));
  user.setFirstName(names[0]);user.setLastName(names[1]);user.setEnabled(verified);user.setEmailVerified(verified);user.setGoogleSubject(googleSubject);
  return users.saveAndFlush(user);
 }
 public String randomPassword(){byte[] bytes=new byte[48];RANDOM.nextBytes(bytes);return java.util.Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);}
 public static String[] splitName(String name){String value=name==null?"":name.trim().replaceAll("\\s+"," ");if(value.isEmpty())return new String[]{"Chronis","User"};int i=value.indexOf(' ');return i<0?new String[]{value,""}:new String[]{value.substring(0,i),value.substring(i+1)};}
}
