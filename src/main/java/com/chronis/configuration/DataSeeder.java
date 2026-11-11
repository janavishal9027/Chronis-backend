package com.chronis.configuration;
import com.chronis.auth.domain.User;
import com.chronis.auth.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;
@Component @RequiredArgsConstructor
public class DataSeeder implements CommandLineRunner {
 private final UserRepository users; private final PasswordEncoder passwords;
 @org.springframework.beans.factory.annotation.Value("${app.bootstrap.username:admin}") private String username;
 @org.springframework.beans.factory.annotation.Value("${app.bootstrap.email:admin@chronis.local}") private String email;
 @org.springframework.beans.factory.annotation.Value("${app.bootstrap.password:}") private String password;
 @Override @Transactional public void run(String...args){
  if(users.findByUsername(username).isPresent() || password.isBlank())return;
  if(password.length()<12)throw new IllegalArgumentException("Bootstrap password must have at least 12 characters");
  User user=new User();user.setUsername(username);user.setEmail(email);user.setPassword(passwords.encode(password));user.setFirstName("Chronis");user.setLastName("Account");user.setEnabled(true);users.save(user);
 }
}
