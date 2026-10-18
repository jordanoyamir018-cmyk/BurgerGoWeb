<%-- 
    Document   : delivery
    Created on : 10 oct 2026, 16:02:27
    Author     : ACER
--%>

<%@page import="java.util.List" %>
<%@page import="modelo.Pedido" %>
<%@page import="dao.PedidoDAO" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");

    PedidoDAO pedidoDAO = new PedidoDAO();
    String mensaje = "";
    
    // Procesar asignación de repartidor
    String accion = request.getParameter("accion");
    if ("asignarRepartidor".equals(accion)) {
        int idPedido = Integer.parseInt(request.getParameter("idPedido"));
        String repartidor = request.getParameter("repartidor");
        String estado = request.getParameter("estado");
        
        boolean ok = pedidoDAO.asignarRepartidorYEstado(idPedido, repartidor, estado);
        if (ok) {
            mensaje = "<div class='alert alert-success alert-dismissible fade show' role='alert'>¡Pedido #" + idPedido + " actualizado con éxito! Repartidor: <strong>" + repartidor + "</strong> | Estado: <strong>" + estado + "</strong></div>";
        } else {
            mensaje = "<div class='alert alert-danger'>Error al actualizar el delivery del pedido.</div>";
        }
    }
    
    List<Pedido> listaPedidos = pedidoDAO.listarPedidos();
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>BurgerGo - Gestión de Delivery (Casos 8 y 9)</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<style>
    :root {
        --burger-red: #E63946;
        --burger-dark: #212529;
        --burger-yellow: #F4A261;
    }

    /* Personalizar la barra de navegación con estilo UPN/BurgerGo */
    .navbar {
        background-color: var(--burger-dark) !important;
        border-bottom: 3px solid var(--burger-red);
    }

    /* Botones de acción principales (Agregar / Guardar) */
    .btn-primary, .btn-success {
        background-color: var(--burger-red) !important;
        border-color: var(--burger-red) !important;
    }
    
    .btn-primary:hover, .btn-success:hover {
        background-color: #d02e3b !important;
        border-color: #c52a36 !important;
    }

    /* Precios destacados con el tono cálido o rojo */
    .text-success {
        color: var(--burger-red) !important;
    }
</style>
<body class="bg-light">
    <%@ page import="modelo.Usuario" %>
    <%
        Usuario userLog = (Usuario) session.getAttribute("usuarioLogueado");
        if (userLog == null) {
            response.sendRedirect("index.jsp");
            return;
        }
    %>
    <nav class="navbar navbar-dark bg-dark mb-4 shadow-sm">
        <div class="container-fluid">
            <a class="navbar-brand fw-bold d-flex align-items-center" href="#">
                <img src="img/logo_upn.png" alt="Logo UPN" height="100" class="d-inline-block me-2 rounded bg-white p-1">
                <img src="img/logo_BurgerGo.jpeg" alt="Logo BurgerGo" height="110" class="d-inline-block me-2 rounded p-1"> 
                🛵 BurgerGo - Panel de Delivery y Reparto
            </a>
            <div class="d-flex align-items-center">
                <span class="text-white me-3 small">👤 Hola, <%= userLog.getUsername() %> (<%= userLog.getRol().toUpperCase() %>)</span>

                <!-- Cambiar de área (Cierra sesión para pedir credenciales nuevas) -->
                <div class="dropdown me-2">
                    <button class="btn btn-outline-light btn-sm dropdown-toggle" type="button" data-bs-toggle="dropdown" aria-expanded="false">
                        🔄 Cambiar de área
                    </button>
                    <ul class="dropdown-menu dropdown-menu-dark">
                        <li><a class="dropdown-item small" href="LoginServlet?accion=logout">🔐 Iniciar como Cocina</a></li>
                        <li><a class="dropdown-item small" href="LoginServlet?accion=logout">🔐 Iniciar como Admin</a></li>
                        <li><hr class="dropdown-divider"></li>
                        <li><a class="dropdown-item small" href="LoginServlet?accion=logout">🍔 Ir al Menú Público</a></li>
                    </ul>
                </div>

                <a href="LoginServlet?accion=logout" class="btn btn-outline-danger btn-sm">🚪 Salir</a>
            </div>
        </div>
    </nav>

    <div class="container mb-5">
        <h2 class="fw-bold mb-1">Control de Envíos y Delivery</h2>
        <p class="text-muted mb-4">Asigna repartidores y confirma la entrega final de los pedidos a domicilio.</p>
        
        <%= mensaje %>

        <div class="card shadow-sm border-0">
            <div class="card-body">
                <div class="table-responsive">
                    <table class="table table-striped table-hover align-middle">
                        <thead class="table-dark">
                            <tr>
                                <th>N.° Pedido</th>
                                <th>Cliente & Dirección</th>
                                <th>Total</th>
                                <th>Estado Actual</th>
                                <th>Repartidor</th>
                                <th>Acción de Delivery</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                if (listaPedidos.isEmpty()) {
                            %>
                                <tr>
                                    <td colspan="6" class="text-center text-muted py-4">No hay pedidos registrados todav&iacute;a.</td>
                                </tr>
                            <%
                                } else {
                                    for (Pedido p : listaPedidos) {
                                        String badgeColor = "secondary";
                                        if ("Pendiente".equalsIgnoreCase(p.getEstado())) badgeColor = "warning text-dark";
                                        else if ("En Preparación".equalsIgnoreCase(p.getEstado()) || "En Preparacion".equalsIgnoreCase(p.getEstado())) badgeColor = "info text-dark";
                                        else if ("En Camino".equalsIgnoreCase(p.getEstado())) badgeColor = "primary";
                                        else if ("Entregado".equalsIgnoreCase(p.getEstado())) badgeColor = "success";
                            %>
                            <tr>
                                <td class="fw-bold">#<%= p.getId() %></td>
                                <td>
                                    <strong><%= p.getClienteNombre() %></strong><br>
                                    <small class="text-muted">📍 <%= p.getDireccion() %> (📞 <%= p.getTelefono() %>)</small>
                                </td>
                                <td class="fw-bold text-success">S/ <%= String.format("%.2f", p.getTotal()) %></td>
                                <td>
                                    <span class="badge bg-<%= badgeColor %> fs-6"><%= p.getEstado() %></span>
                                </td>
                                <td>
                                    <%= (p.getRepartidor() != null && !p.getRepartidor().isEmpty()) ? p.getRepartidor() : "<span class='text-danger fst-italic'>Sin asignar</span>" %>
                                </td>
                                <td>
                                    <form action="delivery.jsp" method="POST" class="row g-1 align-items-center">
                                        <input type="hidden" name="accion" value="asignarRepartidor">
                                        <input type="hidden" name="idPedido" value="<%= p.getId() %>">
                                        
                                        <div class="col-12 mb-1">
                                            <input type="text" class="form-control form-control-sm" name="repartidor" placeholder="Nombre del Repartidor" value="<%= p.getRepartidor() != null ? p.getRepartidor() : "" %>" required>
                                        </div>
                                        <div class="col-12 d-flex gap-1">
                                            <button type="submit" name="estado" value="En Camino" class="btn btn-outline-primary btn-sm w-50">Despachar</button>
                                            <button type="submit" name="estado" value="Entregado" class="btn btn-outline-success btn-sm w-50">Confirmar</button>
                                        </div>
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