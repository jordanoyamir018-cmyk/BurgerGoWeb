/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */

package dao;

import conexion.Conexion;
import modelo.Insumo;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class InsumoDAO {

    public List<Insumo> listarInsumos() {
        List<Insumo> lista = new ArrayList<>();
        String sql = "SELECT * FROM INSUMO ORDER BY id ASC";
        try (Connection con = Conexion.conectar();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Insumo i = new Insumo();
                i.setId(rs.getInt("id"));
                i.setNombre(rs.getString("nombre"));
                i.setUnidadMedida(rs.getString("unidad_medida"));
                i.setStockActual(rs.getDouble("stock_actual"));
                i.setStockMinimo(rs.getDouble("stock_minimo"));
                lista.add(i);
            }
        } catch (Exception e) {
            System.out.println("Error al listar insumos: " + e.getMessage());
        }
        return lista;
    }

    public boolean agregarStock(int idInsumo, double cantidad) {
        String sql = "UPDATE INSUMO SET stock_actual = stock_actual + ? WHERE id = ?";
        try (Connection con = Conexion.conectar();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setDouble(1, cantidad);
            ps.setInt(2, idInsumo);
            ps.executeUpdate();
            return true;
        } catch (Exception e) {
            System.out.println("Error al reabastecer stock: " + e.getMessage());
            return false;
        }
    }
}
