/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dal;

import jakarta.servlet.*;
import jakarta.servlet.http.*;

import java.sql.Connection;
import java.sql.DriverManager;

public class DBContext {


    private static final String URL
            = "jdbc:mysql://localhost:3306/swp_mobile_warehouse"
            + "?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";

    private static final String USER = "root";
    private static final String PASS = "1234";

    public static Connection getConnection() throws Exception {
        Class.forName("com.mysql.cj.jdbc.Driver");
        return DriverManager.getConnection(URL, USER, PASS);
    }
        public static void main(String[] args) {
        try (Connection con = DBContext.getConnection()) {
            System.out.println("CONNECTED OK");
            System.out.println("DB = " + con.getCatalog());
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

}
