<%-- 
    Document   : cocina
    Created on : 10 oct 2026, 15:43:15
    Author     : ACER
--%>

<%@page import="java.util.List" %>
<%@page import="modelo.Pedido" %>
<%@page import="dao.PedidoDAO" %>
<%@ page import="modelo.DetallePedido" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");

    PedidoDAO pedidoDAO = new PedidoDAO();
    String mensaje = "";
    
    // Procesar cambio de estado si se envía la acción
    String accion = request.getParameter("accion");
    if ("cambiarEstado".equals(accion)) {
    int idPedido = Integer.parseInt(request.getParameter("idPedido"));
    String nuevoEstado = request.getParameter("nuevoEstado");
    
    boolean actualizado = pedidoDAO.actualizarEstado(idPedido, nuevoEstado);
    if (actualizado) {
        mensaje = "<div class='alert alert-success alert-dismissible fade show' role='alert'>¡El estado del pedido #" + idPedido + " fue actualizado a <strong>" + nuevoEstado + "</strong>!</div>";
        
        // Verificación flexible para evitar problemas con tildes
        if (nuevoEstado != null && (nuevoEstado.toLowerCase().contains("preparación") || nuevoEstado.toLowerCase().contains("preparacion"))) {
            pedidoDAO.descontarInsumosPorPedido(idPedido);
        }
        
    } else {
        mensaje = "<div class='alert alert-danger'>Error al actualizar el estado del pedido.</div>";
    }
}
    
    List<Pedido> listaPedidos = pedidoDAO.listarPedidos();
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>BurgerGo - Gestión de Cocina y Pedidos</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
    <nav class="navbar navbar-dark bg-dark mb-4 shadow-sm">
        <div class="container-fluid">
            <a class="navbar-brand fw-bold" href="#">👨‍🍳 BurgerGo - Panel de Cocina y Pedidos</a>
            <div>
                <a href="delivery.jsp" class="btn btn-outline-primary btn-sm me-2">🛵 Panel de Delivery</a>
                <a href="index.jsp" class="btn btn-outline-light btn-sm me-2">Ver Menú Público</a>
                <a href="admin.jsp" class="btn btn-outline-warning btn-sm">Panel Admin (Productos)</a>
            </div>
        </div>
    </nav>

    <div class="container mb-5">
        <h2 class="fw-bold mb-1">Control de Pedidos Activos (Cocina)</h2>
        <p class="text-muted mb-4">Indica cuando los pedidos est&eacute;n listos para el área de delivery.</p>
        
        <%= mensaje %>

        <div class="card shadow-sm border-0">
            <div class="card-body">
                <div class="table-responsive">
                    <table class="table table-striped table-hover align-middle">
                        <thead class="table-dark">
                            <tr>
                                <th>N.° Pedido</th>
                                <th>Cliente</th>
                                <th>Teléfono / Dirección</th>
                                <th>Detalles del Pedido</th>
                                <th>Total</th>
                                <th>Estado Actual</th>
                                <th>Acciones de Cocina</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                if (listaPedidos.isEmpty()) {
                            %>
                                <tr>
                                    <td colspan="7" class="text-center text-muted py-4">No hay pedidos registrados todav&iacute;a.</td>
                                </tr>
                            <%
                                } else {
                                    for (Pedido p : listaPedidos) {
                                        String badgeColor = "secondary";
                                        if ("Pendiente".equalsIgnoreCase(p.getEstado())) badgeColor = "warning text-dark";
                                        else if ("En Preparación".equalsIgnoreCase(p.getEstado()) || "En Preparacion".equalsIgnoreCase(p.getEstado())) badgeColor = "info text-dark";
                                        else if ("Preparado".equalsIgnoreCase(p.getEstado())) badgeColor = "primary";
                                        else if ("Entregado".equalsIgnoreCase(p.getEstado())) badgeColor = "success";
                            %>
                            <tr>
                                <td class="fw-bold">#<%= p.getId() %></td>
                                <td><%= p.getClienteNombre() %></td>
                                <td>
                                    <small class="d-block text-muted">📞 <%= p.getTelefono() %></small>
                                    <small class="d-block text-muted">📍 <%= p.getDireccion() %></small>
                                </td>
                                <td>
                                    <ul class="list-unstyled mb-0 small">
                                        <% 
                                            if (p.getDetalles() != null && !p.getDetalles().isEmpty()) {
                                                for (DetallePedido d : p.getDetalles()) {
                                        %>
                                                    <li>• <strong><%= d.getCantidad() %>x</strong> <%= d.getNombreProducto() %></li>
                                        <% 
                                                }
                                            } else {
                                        %>
                                                <span class="text-muted fst-italic">Sin detalle</span>
                                        <%  } %>
                                    </ul>
                                </td>
                                <td class="fw-bold text-success">S/ <%= String.format("%.2f", p.getTotal()) %></td>
                                <td>
                                    <span class="badge bg-<%= badgeColor %> fs-6"><%= p.getEstado() != null ? p.getEstado() : "Pendiente" %></span>
                                </td>
                                <td>
                                    <form action="cocina.jsp" method="POST" class="d-inline-flex gap-1">
                                        <input type="hidden" name="accion" value="cambiarEstado">
                                        <input type="hidden" name="idPedido" value="<%= p.getId() %>">
                                        
                                        <button type="submit" name="nuevoEstado" value="En Preparación" class="btn btn-outline-info btn-sm">En Preparaci&oacute;n</button>
                                        <button type="submit" name="nuevoEstado" value="Preparado" class="btn btn-outline-primary btn-sm">Preparado</button>
                                    </form>
                                </td>
                            </tr>
                            <% 
                                    }
                                } 
                            %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>