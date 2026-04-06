package com.lpgchain.backend.controller;

import com.lpgchain.backend.model.User;
import com.lpgchain.backend.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.Optional;

@RestController
@RequestMapping("/api/users")
@CrossOrigin(origins = "*")
public class UserController {

    @Autowired
    private UserRepository userRepository;

    // CUSTOMER REGISTER
    @PostMapping("/register")
    public String registerUser(@RequestBody User user) {
        user.setRole("CUSTOMER");
        userRepository.save(user);
        return "Customer account created successfully!";
    }

    // LOGIN
    @PostMapping("/login")
    public String loginUser(@RequestBody User loginData) {
        Optional<User> userOptional = userRepository.findByEmail(loginData.getEmail());

        if (userOptional.isPresent()) {
            User user = userOptional.get();

            if (user.getPassword().equals(loginData.getPassword())) {
                return "Login successful! Role: " + user.getRole();
            } else {
                return "Invalid password!";
            }
        } else {
            return "User not found!";
        }
    }

    // ADMIN ADDS DISTRIBUTOR
    @PostMapping("/add-distributor")
    public String addDistributor(@RequestBody User user) {
        user.setRole("DISTRIBUTOR");
        userRepository.save(user);
        return "Distributor added successfully!";
    }
}