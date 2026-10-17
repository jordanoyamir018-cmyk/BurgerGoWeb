<%-- 
    Document   : reportes
    Created on : 10 oct 2026, 16:28:00
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

    // Procesar la acción de limpiar todos los pedidos
    String accion = request.getParameter("accion");
    if (accion != null && accion.equals("limpiarTodo")) {
        pedidoDAO.eliminarTodosLosPedidos();
        response.sendRedirect("reportes.jsp");
        return;
    }

    List<Pedido> listaPedidos = pedidoDAO.listarPedidos();

    double totalVentas = pedidoDAO.obtenerTotalVentas();
    int totalPedidos = listaPedidos.size();
    int pendientes = pedidoDAO.contarPedidosPorEstado("Pendiente");
    int enPreparacion = pedidoDAO.contarPedidosPorEstado("En Preparación");
    int preparados = pedidoDAO.contarPedidosPorEstado("Preparado");
    int enCamino = pedidoDAO.contarPedidosPorEstado("En Camino");
    int entregados = pedidoDAO.contarPedidosPorEstado("Entregado");

    double ticketPromedio = entregados > 0 ? (totalVentas / entregados) : 0.0;
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>BurgerGo - Reporte de Ventas (Caso 12)</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
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
            <a class="navbar-brand fw-bold d-flex align-items-center" href="reportes.jsp">
                <img src="img/logo_upn.png" alt="Logo UPN" height="100" class="d-inline-block me-2 rounded bg-white p-1">
                <img src="img/logo_BurgerGo.jpeg" alt="Logo BurgerGo" height="110" class="d-inline-block me-2 rounded p-1"> 
                📊 BurgerGo - Reportes de Ventas
            </a>
            <div class="d-flex align-items-center">
                <span class="text-white me-3 small">👤 Hola, <strong><%= userLog.getUsername() %></strong> (<%= userLog.getRol().toUpperCase() %>)</span>

                <!-- Botones de navegación -->
                <a href="admin.jsp" class="btn btn-outline-light btn-sm me-2">⚙️ Panel Admin (Platos)</a>
                <a href="inventario.jsp" class="btn btn-outline-info btn-sm me-2">📦 Control de inventario</a>

                <a href="LoginServlet?accion=logout" class="btn btn-outline-danger btn-sm">🚪 Salir</a>
            </div>
        </div>
    </nav>
    <div class="container mb-5">
        <h2 class="fw-bold mb-1">Resumen de Ventas y Operaciones</h2>
        <p class="text-muted mb-4">Métricas consolidadas del rendimiento del negocio.</p>

        <!-- Tarjetas de Métricas Principales -->
        <div class="row g-3 mb-4">
            <div class="col-md-4">
                <div class="card border-0 shadow-sm bg-success text-white">
                    <div class="card-body">
                        <h6 class="card-title text-white-50">Ingreso Total (Entregados)</h6>
                        <h2 class="fw-bold m-0">S/ <%= String.format("%.2f", totalVentas) %></h2>
                    </div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="card border-0 shadow-sm bg-primary text-white">
                    <div class="card-body">
                        <h6 class="card-title text-white-50">Pedidos Registrados</h6>
                        <h2 class="fw-bold m-0"><%= totalPedidos %></h2>
                    </div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="card border-0 shadow-sm bg-dark text-white">
                    <div class="card-body">
                        <h6 class="card-title text-white-50">Ticket Promedio por Entrega</h6>
                        <h2 class="fw-bold m-0">S/ <%= String.format("%.2f", ticketPromedio) %></h2>
                    </div>
                </div>
            </div>
        </div>

        <!-- Estados Operativos -->
        <div class="row g-3 mb-4 text-center">
            <div class="col">
                <div class="card border-0 shadow-sm">
                    <div class="card-body">
                        <span class="badge bg-warning text-dark fs-6">Pendientes</span>
                        <h4 class="fw-bold mt-2"><%= pendientes %></h4>
                    </div>
                </div>
            </div>
            <div class="col">
                <div class="card border-0 shadow-sm">
                    <div class="card-body">
                        <span class="badge bg-info text-dark fs-6">En Preparación</span>
                        <h4 class="fw-bold mt-2"><%= enPreparacion %></h4>
                    </div>
                </div>
            </div>
            <div class="col">
                <div class="card border-0 shadow-sm">
                    <div class="card-body">
                        <span class="badge bg-primary fs-6">Preparados</span>
                        <h4 class="fw-bold mt-2"><%= preparados %></h4>
                    </div>
                </div>
            </div>
            <div class="col">
                <div class="card border-0 shadow-sm">
                    <div class="card-body">
                        <span class="badge bg-secondary fs-6">En Camino</span>
                        <h4 class="fw-bold mt-2"><%= enCamino %></h4>
                    </div>
                </div>
            </div>
            <div class="col">
                <div class="card border-0 shadow-sm">
                    <div class="card-body">
                        <span class="badge bg-success fs-6">Entregados</span>
                        <h4 class="fw-bold mt-2"><%= entregados %></h4>
                    </div>
                </div>
            </div>
        </div>

        <!-- Tabla Histórica de Ventas -->
        <div class="card shadow-sm border-0">
            <div class="card-header bg-white py-3 d-flex justify-content-between align-items-center">
                <h5 class="fw-bold mb-0">Historial Detallado de Pedidos</h5>
                <a href="reportes.jsp?accion=limpiarTodo" class="btn btn-danger btn-sm fw-bold" onclick="return confirm('⚠️ ¿Estás COMPLETAMENTE SEGURO de eliminar TODOS los pedidos y el historial de ventas? Esta acción no se puede deshacer.');">🗑️ Limpiar Todos los Pedidos</a>
            </div>
            <div class="card-body">
                <div class="table-responsive">
                    <table class="table table-hover align-middle">
                        <thead class="table-dark">
                            <tr>
                                <th># Pedido</th>
                                <th>Fecha</th>
                                <th>Cliente</th>
                                <th>Repartidor</th>
                                <th>Estado</th>
                                <th>Monto Total</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                if (listaPedidos.isEmpty()) {
                            %>
                                <tr>
                                    <td colspan="6" class="text-center text-muted py-4">No hay ventas registradas aún.</td>
                                </tr>
                            <%
                                } else {
                                    for (Pedido p : listaPedidos) {
                            %>
                            <tr>
                                <td class="fw-bold">#<%= p.getId() %></td>
                                <td><small><%= p.getFecha() != null ? p.getFecha().toString() : "N/A" %></small></td>
                                <td><%= p.getClienteNombre() %></td>
                                <td><%= p.getRepartidor() != null ? p.getRepartidor() : "<span class='text-muted fst-italic'>N/A</span>" %></td>
                                <td><span class="badge bg-secondary"><%= p.getEstado() %></span></td>
                                <td class="fw-bold text-success">S/ <%= String.format("%.2f", p.getTotal()) %></td>
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