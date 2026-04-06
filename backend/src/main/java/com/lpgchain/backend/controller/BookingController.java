package com.lpgchain.backend.controller;

import com.lpgchain.backend.model.Booking;
import com.lpgchain.backend.repository.BookingRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/bookings")
@CrossOrigin(origins = "*")
public class BookingController {

    @Autowired
    private BookingRepository bookingRepository;

    @PostMapping
    public String createBooking(@RequestBody Booking booking) {
        bookingRepository.save(booking);
        return "Booking created successfully!";
    }

    @GetMapping
    public List<Booking> getAllBookings() {
        return bookingRepository.findAll();
    }
}