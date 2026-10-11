/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */

package modelo;

public class Insumo {
    private int id;
    private String nombre;
    private String unidadMedida;
    private double stockActual;
    private double stockMinimo;

    public Insumo() {}

    public Insumo(int id, String nombre, String unidadMedida, double stockActual, double stockMinimo) {
        this.id = id;
        this.nombre = nombre;
        this.unidadMedida = unidadMedida;
        this.stockActual = stockActual;
        this.stockMinimo = stockMinimo;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }
    public String getUnidadMedida() { return unidadMedida; }
    public void setUnidadMedida(String unidadMedida) { this.unidadMedida = unidadMedida; }
    public double getStockActual() { return stockActual; }
    public void setStockActual(double stockActual) { this.stockActual = stockActual; }
    public double getStockMinimo() { return stockMinimo; }
    public void setStockMinimo(double stockMinimo) { this.stockMinimo = stockMinimo; }
}
