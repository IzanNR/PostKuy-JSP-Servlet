package com.postkuy.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnector {

    // Konfigurasi database
    private static final String URL = "jdbc:mysql://localhost:3306/postkuy";
    private static final String USERNAME = "root";
    private static final String PASSWORD = "";

    // Static block untuk inisialisasi driver
    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            System.err.println("Error: MySQL Driver not found");
            e.printStackTrace();
        }
    }

    // Method untuk mendapatkan koneksi ke database
    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USERNAME, PASSWORD);
    }
}
