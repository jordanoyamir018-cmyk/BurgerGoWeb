/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */

package controlador;

import dao.PedidoDAO;
import dao.ProductoDAO;
import modelo.DetallePedido;
import modelo.Pedido;
import modelo.Producto;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(name = "CarritoServlet", urlPatterns = {"/CarritoServlet"})
public class CarritoServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        
        HttpSession session = request.getSession();
        String accion = request.getParameter("accion");
        
        // Obtener o inicializar el carrito en la sesión del usuario
        List<DetallePedido> carrito = (List<DetallePedido>) session.getAttribute("carrito");
        if (carrito == null) {
            carrito = new ArrayList<>();
        }
        
        if ("agregar".equals(accion)) {
            int idProducto = Integer.parseInt(request.getParameter("idProducto"));
            int cantidad = Integer.parseInt(request.getParameter("cantidad"));
            
            ProductoDAO prodDao = new ProductoDAO();
            Producto p = prodDao.obtenerPorId(idProducto);
            
            if (p != null) {
                // Verificar si el producto ya está en el carrito para sumar la cantidad
                boolean encontrado = false;
                for (DetallePedido item : carrito) {
                    if (item.getIdProducto() == idProducto) {
                        item.setCantidad(item.getCantidad() + cantidad);
                        encontrado = true;
                        break;
                    }
                }
                
                // Si no está, agregarlo como un nuevo ítem
                if (!encontrado) {
                    DetallePedido nuevoItem = new DetallePedido(p.getId(), p.getNombre(), cantidad, p.getPrecio());
                    carrito.add(nuevoItem);
                }
            }
            session.setAttribute("carrito", carrito);
            response.sendRedirect("index.jsp");
            
        } else if ("eliminar".equals(accion)) {
            int idProducto = Integer.parseInt(request.getParameter("idProducto"));
            carrito.removeIf(item -> item.getIdProducto() == idProducto);
            session.setAttribute("carrito", carrito);
            response.sendRedirect("index.jsp");
            
        } else if ("procesarCompra".equals(accion)) {
            if (carrito.isEmpty()) {
                response.sendRedirect("index.jsp?error=carritoVacio");
                return;
            }
            
            String cliente = request.getParameter("clienteNombre");
            String telefono = request.getParameter("telefono");
            String direccion = request.getParameter("direccion");
            
            double totalGeneral = 0;
            for (DetallePedido item : carrito) {
                totalGeneral += item.getSubtotal();
            }
            
            Pedido pedido = new Pedido(cliente, telefono, direccion, totalGeneral);
            PedidoDAO pedidoDao = new PedidoDAO();
            
            // Guardar el pedido maestro y sus detalles de forma transaccional
            boolean exito = pedidoDao.registrarPedidoConDetalle(pedido, carrito);
            
            if (exito) {
                session.removeAttribute("carrito"); // Limpiar el carrito tras una compra exitosa
                response.sendRedirect("index.jsp?exito=pedidoRegistrado");
            } else {
                response.sendRedirect("index.jsp?error=falloRegistro");
            }
        }
    }
}
