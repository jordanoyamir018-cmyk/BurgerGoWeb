/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package conexion;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class Conexion {
    public static Connection conectar() throws SQLException, ClassNotFoundException {
        // Parámetros de conexión para PostgreSQL local
        String url = "jdbc:postgresql://localhost:5432/BD_BurgerGo";
        String user = "postgres"; // Usuario por defecto de PostgreSQL
        String pass = "admin"; // Tu contraseña de PostgreSQL (cámbiala si usaste otra)
        
        Class.forName("org.postgresql.Driver");
        return DriverManager.getConnection(url, user, pass);
    }
}