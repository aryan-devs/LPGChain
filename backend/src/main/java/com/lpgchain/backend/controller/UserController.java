package com.lpgchain.backend.controller;

import com.lpgchain.backend.model.User;
import com.lpgchain.backend.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/users")
@CrossOrigin(origins = "*")
public class UserController {

    @Autowired
    private UserRepository userRepository;

    // =========================
    // REGISTER USER
    // =========================
    @PostMapping("/register")
    public String registerUser(@RequestBody User user) {

        // Check if user already exists
        User existingUser = userRepository.findByEmail(user.getEmail());
        if (existingUser != null) {
            return "Email already registered!";
        }

        // Save user
        userRepository.save(user);
        return "User registered successfully!";
    }

    // =========================
    // LOGIN USER
    // =========================
    @PostMapping("/login")
    public String loginUser(@RequestBody User user) {

        User existingUser = userRepository.findByEmail(user.getEmail());

        if (existingUser == null) {
            return "User not found!";
        }

        if (!existingUser.getPassword().equals(user.getPassword())) {
            return "Invalid password!";
        }

        if (!existingUser.getRole().equalsIgnoreCase(user.getRole())) {
            return "Invalid role!";
        }

        return "Login successful!";
    }
}