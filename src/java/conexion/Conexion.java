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
        // Parámetros de conexión para Neon.tech (PostgreSQL en la nube)
        String url = "jdbc:postgresql://ep-wild-glitter-b45ewofz-pooler.c-6.us-east-2.aws.neon.tech/neondb?sslmode=require";
        String user = "neondb_owner"; 
        String pass = "npg_WyJ39smMnafP"; // Pega aquí tu contraseña de Neon
        
        Class.forName("org.postgresql.Driver");
        return DriverManager.getConnection(url, user, pass);
    }
}