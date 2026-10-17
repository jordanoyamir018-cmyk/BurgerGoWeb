/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package modelo;

import java.util.Date;
import java.util.List;
import java.util.ArrayList;

public class Pedido {
    private int id;
    private String clienteNombre;
    private String telefono;
    private String direccion;
    private double total;
    private String estado;
    private Date fecha;
    private String repartidor;
    
    // 👈 NUEVO ATRIBUTO PARA ALMACENAR LOS PLATOS/DETALLES DEL PEDIDO
    private List<DetallePedido> detalles = new ArrayList<>();

    public Pedido() {}

    public Pedido(String clienteNombre, String telefono, String direccion, double total) {
        this.clienteNombre = clienteNombre;
        this.telefono = telefono;
        this.direccion = direccion;
        this.total = total;
        this.estado = "Pendiente";
    }

    // Getters y Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getClienteNombre() {
        return clienteNombre;
    }

    public void setClienteNombre(String clienteNombre) {
        this.clienteNombre = clienteNombre;
    }

    public String getTelefono() {
        return telefono;
    }

    public void setTelefono(String telefono) {
        this.telefono = telefono;
    }

    public String getDireccion() {
        return direccion;
    }

    public void setDireccion(String direccion) {
        this.direccion = direccion;
    }

    public double getTotal() {
        return total;
    }

    public void setTotal(double total) {
        this.total = total;
    }

    public String getEstado() {
        return estado;
    }

    public void setEstado(String estado) {
        this.estado = estado;
    }

    public Date getFecha() {
        return fecha;
    }

    public void setFecha(Date fecha) {
        this.fecha = fecha;
    }

    public String getRepartidor() {
        return repartidor;
    }

    public void setRepartidor(String repartidor) {
        this.repartidor = repartidor;
    }

    // 👈 NUEVOS GETTER Y SETTER PARA LOS DETALLES
    public List<DetallePedido> getDetalles() {
        return detalles;
    }

    public void setDetalles(List<DetallePedido> detalles) {
        this.detalles = detalles;
    }
}
