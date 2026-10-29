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
        // Parámetros de conexión para SQL Server local con Autenticación de Windows
        String url = "jdbc:sqlserver://DESKTOP-N08OOH1\\SQLEXPRESS;databaseName=BurgerGo;integratedSecurity=true;trustServerCertificate=true;";
        
        // Cargar el driver JDBC de Microsoft para SQL Server
        Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
        
        // Al usar Autenticación de Windows, no se requieren usuario ni contraseña
        return DriverManager.getConnection(url);
    }
}