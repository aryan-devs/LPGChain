package com.lpgchain.backend.controller;

import com.lpgchain.backend.model.Order;
import com.lpgchain.backend.repository.OrderRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/orders")
@CrossOrigin(origins = "*")
public class OrderController {

    @Autowired
    private OrderRepository orderRepository;

    // BOOK CYLINDER
    @PostMapping("/book")
    public String bookOrder(@RequestBody Order order) {
        order.setStatus("Booked");
        orderRepository.save(order);
        return "Cylinder booked successfully!";
    }

    // GET CUSTOMER ORDERS
    @GetMapping("/{email}")
    public List<Order> getOrders(@PathVariable String email) {
        return orderRepository.findByCustomerEmail(email);
    }

    // GET ALL ORDERS FOR DISTRIBUTOR
    @GetMapping("/all")
    public List<Order> getAllOrders() {
        return orderRepository.findAll();
    }

    // UPDATE ORDER STATUS
    @PutMapping("/update/{id}")
    public String updateOrderStatus(@PathVariable Long id, @RequestBody Order updatedOrder) {
        Optional<Order> optionalOrder = orderRepository.findById(id);

        if (optionalOrder.isPresent()) {
            Order order = optionalOrder.get();
            order.setStatus(updatedOrder.getStatus());
            orderRepository.save(order);
            return "Order status updated successfully!";
        } else {
            return "Order not found!";
        }
    }
}