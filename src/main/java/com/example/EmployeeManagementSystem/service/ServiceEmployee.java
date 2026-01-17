package com.example.EmployeeManagementSystem.service;

import java.util.List;
import java.util.stream.Collectors;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.example.EmployeeManagementSystem.dto.DtoEmployee;
import com.example.EmployeeManagementSystem.exception.ExceptionEmployee;
import com.example.EmployeeManagementSystem.mapper.MapperEmployee;
import com.example.EmployeeManagementSystem.model.Employee;
import com.example.EmployeeManagementSystem.repository.RepositoryEmployee;

@Service
public class ServiceEmployee implements ServiceEmployeeIn, MarkerInterface {
    @Autowired
    private RepositoryEmployee repositoryEmployee;


    @Override
    public DtoEmployee createEmployee(DtoEmployee dtoEmployee) {
        Employee employee = MapperEmployee.mapTOEmployee(dtoEmployee);
        Employee savedEmployee = repositoryEmployee.save(employee);
        return MapperEmployee.mapToDtoEmployee(savedEmployee);
    }

    @Override
    public DtoEmployee findById(int id) {
        Employee employee = repositoryEmployee.findById(id).orElseThrow(
                () -> new ExceptionEmployee("The Employee is not founded by this give Id" + id));
        return MapperEmployee.mapToDtoEmployee(employee);
    }

    @Override
    public List<DtoEmployee> findAllEmployee() {
        List<Employee> employees = repositoryEmployee.findAll();
        return employees.stream().map(
                (employee) -> MapperEmployee.mapToDtoEmployee(employee)).collect(Collectors.toList());

    }

    @Override
    public DtoEmployee updateEmployee(int id, DtoEmployee updatedemployee) {
        Employee employee = repositoryEmployee.findById(id).orElseThrow(
                () -> new ExceptionEmployee("The Employee is not exist or found by given id" + id));
        employee.setFirstname(updatedemployee.getFirstname());
        employee.setLastname(updatedemployee.getLastname());
        employee.setEmail(updatedemployee.getEmail());
        return MapperEmployee.mapToDtoEmployee(repositoryEmployee.save(employee));
    }

    @Override
    public void deleteEmployee(int id) {
        Employee employee = repositoryEmployee.findById(id).orElseThrow(() -> new ExceptionEmployee("The Employee is not exist or found by given id" + id));
        repositoryEmployee.delete(employee);
    }

    public static class SubEmployee {
        private String name = "Test Name";

        @Override
        public String toString() {
            return "name=" + this.name;
        }
    }
}
