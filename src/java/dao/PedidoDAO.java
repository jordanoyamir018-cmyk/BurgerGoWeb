/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import conexion.Conexion;
import modelo.Pedido;
import java.sql.*;
import java.util.ArrayList;   // <--- Importación necesaria para ArrayList
import java.util.List;        // <--- Importación necesaria para List
import modelo.DetallePedido;

public class PedidoDAO {

    public int insertarPedido(Pedido p) {
        int idGenerado = 0;
        String sql = "INSERT INTO PEDIDO (cliente_nombre, telefono, direccion, total, estado) VALUES (?, ?, ?, ?, 'Pendiente')";
        
        try (Connection con = Conexion.conectar();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            ps.setString(1, p.getClienteNombre());
            ps.setString(2, p.getTelefono());
            ps.setString(3, p.getDireccion());
            ps.setDouble(4, p.getTotal());
            
            ps.executeUpdate();
            
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    idGenerado = rs.getInt(1);
                }
            }
        } catch (Exception e) {
            System.out.println("Error al registrar pedido: " + e.getMessage());
        }
        return idGenerado;
    }
    
    // Buscar pedido por ID (para el Caso 4: Consultar estado del pedido)
    public Pedido buscarPorId(int id) {
        Pedido p = null;
        String sql = "SELECT * FROM PEDIDO WHERE id = ?";
        try (Connection con = Conexion.conectar();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    p = new Pedido();
                    p.setId(rs.getInt("id"));
                    p.setClienteNombre(rs.getString("cliente_nombre"));
                    p.setTelefono(rs.getString("telefono"));
                    p.setDireccion(rs.getString("direccion"));
                    p.setTotal(rs.getDouble("total"));
                    p.setEstado(rs.getString("estado"));
                    p.setFecha(rs.getTimestamp("fecha"));
                }
            }
        } catch (Exception e) {
            System.out.println("Error al buscar pedido: " + e.getMessage());
        }
        return p;
    }
    
    
    // Método para actualizar el estado de un pedido (Caso 7)
    public boolean actualizarEstado(int idPedido, String nuevoEstado) {
        String sql = "UPDATE PEDIDO SET estado = ? WHERE id = ?";
        try (Connection con = Conexion.conectar();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, nuevoEstado);
            ps.setInt(2, idPedido);
            ps.executeUpdate();
            return true;
        } catch (Exception e) {
            System.out.println("Error al actualizar estado del pedido: " + e.getMessage());
            return false;
        }
    }
    
    // Método para gestionar el delivery (Caso 8 y 9)
    public boolean asignarRepartidorYEstado(int idPedido, String repartidor, String estado) {
        String sql = "UPDATE PEDIDO SET repartidor = ?, estado = ? WHERE id = ?";
        try (Connection con = Conexion.conectar();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, repartidor);
            ps.setString(2, estado);
            ps.setInt(3, idPedido);
            ps.executeUpdate();
            return true;
        } catch (Exception e) {
            System.out.println("Error al asignar repartidor: " + e.getMessage());
            return false;
        }
    }
    
    // Método para obtener el total general acumulado en soles (S/)
    public double obtenerTotalVentas() {
        double total = 0.0;
        String sql = "SELECT SUM(total) FROM PEDIDO WHERE estado = 'Entregado'";
        try (Connection con = Conexion.conectar();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                total = rs.getDouble(1);
            }
        } catch (Exception e) {
            System.out.println("Error al calcular total ventas: " + e.getMessage());
        }
        return total;
    }

    // Método para contar pedidos según su estado
    public int contarPedidosPorEstado(String estado) {
        int cantidad = 0;
        String sql = "SELECT COUNT(*) FROM PEDIDO WHERE estado = ?";
        try (Connection con = Conexion.conectar();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, estado);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    cantidad = rs.getInt(1);
                }
            }
        } catch (Exception e) {
            System.out.println("Error al contar pedidos por estado: " + e.getMessage());
        }
        return cantidad;
    }
    
    // Método transaccional para registrar un Pedido con sus Detalles múltiples
    // Método transaccional adaptado a tu estructura exacta de base de datos
    public boolean registrarPedidoConDetalle(Pedido pedido, List<DetallePedido> detalles) {
        String sqlPedido = "INSERT INTO PEDIDO (cliente_nombre, telefono, direccion, total, estado, fecha) VALUES (?, ?, ?, ?, 'Pendiente', NOW())";
        String sqlDetalle = "INSERT INTO DETALLE_PEDIDO (id_pedido, id_producto, cantidad, subtotal) VALUES (?, ?, ?, ?)";
        
        try (Connection con = Conexion.conectar()) {
            con.setAutoCommit(false); // Iniciar transacción
            
            try (PreparedStatement psPedido = con.prepareStatement(sqlPedido, PreparedStatement.RETURN_GENERATED_KEYS)) {
                psPedido.setString(1, pedido.getClienteNombre());
                psPedido.setString(2, pedido.getTelefono());
                psPedido.setString(3, pedido.getDireccion());
                psPedido.setDouble(4, pedido.getTotal());
                psPedido.executeUpdate();
                
                int idPedidoGenerado = 0;
                try (ResultSet rsKeys = psPedido.getGeneratedKeys()) {
                    if (rsKeys.next()) {
                        idPedidoGenerado = rsKeys.getInt(1);
                    } else {
                        con.rollback();
                        return false;
                    }
                }
                
                try (PreparedStatement psDetalle = con.prepareStatement(sqlDetalle)) {
                    for (DetallePedido item : detalles) {
                        psDetalle.setInt(1, idPedidoGenerado);
                        psDetalle.setInt(2, item.getIdProducto());
                        psDetalle.setInt(3, item.getCantidad());
                        psDetalle.setDouble(4, item.getSubtotal()); // Guardamos el subtotal directamente
                        psDetalle.addBatch();
                    }
                    psDetalle.executeBatch();
                }
                
                con.commit(); // Confirmar transacción exitosa
                return true;
                
            } catch (Exception e) {
                con.rollback();
                System.out.println("Error en transacción de pedido: " + e.getMessage());
                return false;
            }
            
        } catch (Exception e) {
            System.out.println("Error de conexión al registrar pedido: " + e.getMessage());
            return false;
        }
    }
    
    
    // Método para listar TODOS los pedidos (Usado en Cocina, Delivery y Admin)
    public List<Pedido> listarPedidos() {
        List<Pedido> lista = new ArrayList<>();
        String sql = "SELECT * FROM PEDIDO ORDER BY id DESC";
        
        try (Connection con = Conexion.conectar();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                Pedido p = new Pedido();
                p.setId(rs.getInt("id"));
                p.setClienteNombre(rs.getString("cliente_nombre"));
                p.setTelefono(rs.getString("telefono"));
                p.setDireccion(rs.getString("direccion"));
                p.setTotal(rs.getDouble("total"));
                p.setEstado(rs.getString("estado"));
                p.setFecha(rs.getTimestamp("fecha"));
                p.setRepartidor(rs.getString("repartidor")); 
                
                // 👈 AQUÍ ASIGNAMOS LOS DETALLES AL PEDIDO
                p.setDetalles(listarDetallesPorPedido(p.getId()));
                
                lista.add(p);
            }
        } catch (Exception e) {
            System.out.println("Error al listar pedidos: " + e.getMessage());
        }
        return lista;
    }

    // Método para buscar pedidos FILTRADOS por cliente o teléfono (Usado en el buscador del index.jsp)
    public List<Pedido> listarPedidosPorCliente(String filtro) {
        List<Pedido> lista = new ArrayList<>();
        String sql = "SELECT * FROM PEDIDO WHERE cliente_nombre LIKE ? OR telefono LIKE ? ORDER BY id DESC";
        try (Connection con = Conexion.conectar();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, "%" + filtro + "%");
            ps.setString(2, "%" + filtro + "%");
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Pedido p = new Pedido();
                    p.setId(rs.getInt("id"));
                    p.setClienteNombre(rs.getString("cliente_nombre"));
                    p.setTelefono(rs.getString("telefono"));
                    p.setDireccion(rs.getString("direccion"));
                    p.setTotal(rs.getDouble("total"));
                    p.setEstado(rs.getString("estado"));
                    p.setFecha(rs.getTimestamp("fecha"));
                    p.setRepartidor(rs.getString("repartidor"));
                    
                    // 👈 AQUÍ TAMBIÉN ASIGNAMOS LOS DETALLES AL PEDIDO
                    p.setDetalles(listarDetallesPorPedido(p.getId()));
                    
                    lista.add(p);
                }
            }
        } catch (Exception e) {
            System.out.println("Error al buscar pedidos por cliente: " + e.getMessage());
        }
        return lista;
    }

    // Método para listar los DETALLES de un pedido específico (Usado junto al buscador para ver los productos)
    public List<DetallePedido> listarDetallesPorPedido(int idPedido) {
        List<DetallePedido> lista = new ArrayList<>();
        String sql = "SELECT d.id, d.id_producto, p.nombre AS nombreProducto, d.cantidad, d.subtotal " +
                     "FROM DETALLE_PEDIDO d INNER JOIN PRODUCTO p ON d.id_producto = p.id " +
                     "WHERE d.id_pedido = ?";
        try (Connection con = Conexion.conectar();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, idPedido);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    DetallePedido item = new DetallePedido();
                    item.setId(rs.getInt("id"));
                    item.setIdProducto(rs.getInt("id_producto"));
                    item.setNombreProducto(rs.getString("nombreProducto"));
                    item.setCantidad(rs.getInt("cantidad"));
                    item.setSubtotal(rs.getDouble("subtotal"));
                    lista.add(item);
                }
            }
        } catch (Exception e) {
            System.out.println("Error al listar detalles del pedido: " + e.getMessage());
        }
        return lista;
    }
    
    // Método para limpiar/eliminar todos los pedidos y sus detalles de la base de datos
    public boolean eliminarTodosLosPedidos() {
        String sqlDetalle = "DELETE FROM DETALLE_PEDIDO";
        String sqlPedido = "DELETE FROM PEDIDO";
        
        try (Connection con = Conexion.conectar()) {
            con.setAutoCommit(false); // Iniciar transacción
            
            try (PreparedStatement psDetalle = con.prepareStatement(sqlDetalle);
                 PreparedStatement psPedido = con.prepareStatement(sqlPedido)) {
                
                // Primero borramos los detalles por la llave foránea
                psDetalle.executeUpdate();
                // Luego borramos los pedidos principales
                psPedido.executeUpdate();
                
                con.commit();
                return true;
            } catch (Exception e) {
                con.rollback();
                System.out.println("Error en transacción al limpiar pedidos: " + e.getMessage());
                return false;
            }
        } catch (Exception e) {
            System.out.println("Error de conexión al limpiar pedidos: " + e.getMessage());
            return false;
        }
    }
    
    // Descuenta automáticamente los insumos al preparar un pedido
    public void descontarInsumosPorPedido(int idPedido) {
    String sql = "UPDATE insumo SET stock_actual = stock_actual - sub.total_usado " +
                 "FROM (" +
                 "    SELECT pi.id_insumo AS insumo_id, (pi.cantidad_requerida * dp.cantidad) AS total_usado " +
                 "    FROM detalle_pedido dp " +
                 "    JOIN producto_insumo pi ON dp.id_producto = pi.id_producto " +
                 "    WHERE dp.id_pedido = ?" +
                 ") sub " +
                 "WHERE insumo.id = sub.insumo_id";
                 
    try (Connection con = Conexion.conectar();
         PreparedStatement ps = con.prepareStatement(sql)) {
        ps.setInt(1, idPedido);
        ps.executeUpdate();
    } catch (Exception e) {
        System.out.println("Error al descontar insumos del inventario: " + e.getMessage());
    }
}
    
}