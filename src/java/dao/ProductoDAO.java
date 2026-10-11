/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import conexion.Conexion;
import modelo.Producto;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ProductoDAO {

    // Listar todos los productos (Read)
    public List<Producto> listar() {
        List<Producto> lista = new ArrayList<>();
        String sql = "SELECT * FROM PRODUCTO";
        
        try (Connection con = Conexion.conectar();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                Producto p = new Producto();
                p.setId(rs.getInt("id"));
                p.setNombre(rs.getString("nombre"));
                p.setDescripcion(rs.getString("descripcion"));
                p.setPrecio(rs.getDouble("precio"));
                lista.add(p);
            }
        } catch (Exception e) {
            System.out.println("Error al listar: " + e.getMessage());
        }
        return lista;
    }

    // Insertar un nuevo producto (Create)
    public boolean insertar(Producto p) {
        String sql = "INSERT INTO PRODUCTO (nombre, descripcion, precio) VALUES (?, ?, ?)";
        try (Connection con = Conexion.conectar();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, p.getNombre());
            ps.setString(2, p.getDescripcion());
            ps.setDouble(3, p.getPrecio());
            ps.executeUpdate();
            return true;
        } catch (Exception e) {
            System.out.println("Error al insertar: " + e.getMessage());
            return false;
        }
    }

    // Buscar producto por ID (útil para la edición)
    public Producto buscarPorId(int id) {
        Producto p = null;
        String sql = "SELECT * FROM PRODUCTO WHERE id = ?";
        try (Connection con = Conexion.conectar();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    p = new Producto();
                    p.setId(rs.getInt("id"));
                    p.setNombre(rs.getString("nombre"));
                    p.setDescripcion(rs.getString("descripcion"));
                    p.setPrecio(rs.getDouble("precio"));
                }
            }
        } catch (Exception e) {
            System.out.println("Error al buscar: " + e.getMessage());
        }
        return p;
    }

    // Actualizar un producto existente (Update)
    public boolean actualizar(Producto p) {
        String sql = "UPDATE PRODUCTO SET nombre = ?, descripcion = ?, precio = ? WHERE id = ?";
        try (Connection con = Conexion.conectar();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, p.getNombre());
            ps.setString(2, p.getDescripcion());
            ps.setDouble(3, p.getPrecio());
            ps.setInt(4, p.getId());
            ps.executeUpdate();
            return true;
        } catch (Exception e) {
            System.out.println("Error al actualizar: " + e.getMessage());
            return false;
        }
    }

    // Eliminar un producto (Delete)
    public boolean eliminar(int id) {
        String sql = "DELETE FROM PRODUCTO WHERE id = ?";
        try (Connection con = Conexion.conectar();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
            return true;
        } catch (Exception e) {
            System.out.println("Error al eliminar: " + e.getMessage());
            return false;
        }
    }
    
    // Método para obtener un producto específico por su ID
    public Producto obtenerPorId(int id) {
        Producto p = null;
        String sql = "SELECT * FROM PRODUCTO WHERE id = ?";
        try (Connection con = Conexion.conectar();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    p = new Producto();
                    p.setId(rs.getInt("id"));
                    p.setNombre(rs.getString("nombre"));
                    p.setDescripcion(rs.getString("descripcion"));
                    p.setPrecio(rs.getDouble("precio"));
                }
            }
        } catch (Exception e) {
            System.out.println("Error al buscar producto por ID: " + e.getMessage());
        }
        return p;
    }
}