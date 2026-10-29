/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package conexion;

import java.sql.Connection;
import java.sql.SQLException;

public class TestConexion {
    public static void main(String[] args) {
        try {
            System.out.println("Intentando conectar a SQL Server...");
            Connection conexion = Conexion.conectar();
            
            if (conexion != null) {
                System.out.println("¡CONEXIÓN EXITOSA! Tu base de datos BurgerGo ya está conectada.");
                conexion.close(); // Cerramos la prueba
            } else {
                System.out.println("La conexión devolvió nulo.");
            }
        } catch (ClassNotFoundException e) {
            System.out.println("Error: No se encontró el Driver JDBC -> " + e.getMessage());
        } catch (SQLException e) {
            System.out.println("Error de SQL -> " + e.getMessage());
        }
    }
}