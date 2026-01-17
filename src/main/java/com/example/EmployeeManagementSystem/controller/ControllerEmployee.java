package com.example.EmployeeManagementSystem.controller;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import com.example.EmployeeManagementSystem.dto.DtoEmployee;
import com.example.EmployeeManagementSystem.service.ServiceEmployeeIn;
import com.example.EmployeeManagementSystem.service.ServiceEmployee;
import com.example.EmployeeManagementSystem.service.ServiceEmployee.SubEmployee;

@RestController
@CrossOrigin("*")
@RequestMapping("api/employee")

public class ControllerEmployee {
    @Autowired
    private ServiceEmployeeIn serviceEmployee;
    private DtoEmployee updatedemployee;
    private ServiceEmployee employes;

    @PostMapping
    public ResponseEntity<DtoEmployee> createEmployee(@RequestBody DtoEmployee dtaEmployee) {
        DtoEmployee e = serviceEmployee.createEmployee(dtaEmployee);
        return new ResponseEntity<>(e, HttpStatus.CREATED);
    }

    @GetMapping("/{id}")
    public ResponseEntity<DtoEmployee> findById(@PathVariable("id") int id) {
        DtoEmployee e = serviceEmployee.findById(id);
        ServiceEmployee employee = this.employes;
        return new ResponseEntity<>(e, HttpStatus.OK);
    }

    @GetMapping
    public ResponseEntity<List<DtoEmployee>> findAllEmployee() {
        List<DtoEmployee> employes = serviceEmployee.findAllEmployee();
        return new ResponseEntity<>(employes, HttpStatus.OK);
    }

    @PutMapping("/{id}")
    public ResponseEntity<DtoEmployee> updateEmployee(@PathVariable("id") int id, @RequestBody DtoEmployee updatedemployee) {
        DtoEmployee updatedemp = serviceEmployee.updateEmployee(id, updatedemployee);
        return new ResponseEntity<>(updatedemp, HttpStatus.OK);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<String> deleteEmployee(@PathVariable("id") int id) {
        serviceEmployee.deleteEmployee(id);
        return ResponseEntity.ok("This Employee is Deleted successfully");
    }

    public void test() {
        SubEmployee employes = new SubEmployee();
        System.out.println(employes.toString());
    }

}
