<%-- 
    Document   : admin
    Created on : 10 oct 2026, 14:52:50
    Author     : ACER
--%>

<%@page import="java.util.List" %>
<%@page import="modelo.Producto" %>
<%@page import="dao.ProductoDAO" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");

    ProductoDAO dao = new ProductoDAO();
    
    // Procesar acciones enviadas por parámetro (Crear, Editar, Eliminar)
    String accion = request.getParameter("accion");
    if (accion != null) {
        if (accion.equals("guardar")) {
            String nombre = request.getParameter("nombre");
            String descripcion = request.getParameter("descripcion");
            double precio = Double.parseDouble(request.getParameter("precio"));
            
            String idStr = request.getParameter("id");
            if (idStr == null || idStr.isEmpty()) {
                // Crear
                Producto p = new Producto(0, nombre, descripcion, precio);
                dao.insertar(p);
            } else {
                // Actualizar
                int id = Integer.parseInt(idStr);
                Producto p = new Producto(id, nombre, descripcion, precio);
                dao.actualizar(p);
            }
            response.sendRedirect("admin.jsp");
            return;
        } else if (accion.equals("eliminar")) {
            int id = Integer.parseInt(request.getParameter("id"));
            dao.eliminar(id);
            response.sendRedirect("admin.jsp");
            return;
        }
    }
    
    // Obtener producto si se va a editar
    Producto prodEdicion = null;
    String editId = request.getParameter("editId");
    if (editId != null) {
        prodEdicion = dao.buscarPorId(Integer.parseInt(editId));
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>BurgerGo - Panel de Administración</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
    <nav class="navbar navbar-dark bg-dark mb-4">
        <div class="container-fluid">
            <a class="navbar-brand" href="#">🍔 BurgerGo - Panel Admin (CRUD)</a>
            <div>
                <a href="inventario.jsp" class="btn btn-outline-info btn-sm me-2">📦 Control de Inventario</a>
                <a href="reportes.jsp" class="btn btn-outline-success btn-sm me-2">📊 Reporte de Ventas</a>
                <a href="cocina.jsp" class="btn btn-outline-info btn-sm me-2">👨‍🍳 Panel de Cocina</a>
                <a href="index.jsp" class="btn btn-outline-light btn-sm">Ver Menú Público</a>
            </div>
        </div>
    </nav>

    <div class="container">
        <div class="row">
            <!-- Formulario de Registro / Edición -->
            <div class="col-md-4 mb-4">
                <div class="card shadow-sm">
                    <div class="card-header bg-primary text-white">
                        <h5 class="mb-0"><%= prodEdicion == null ? "Registrar Producto" : "Editar Producto" %></h5>
                    </div>
                    <div class="card-body">
                        <form action="admin.jsp" method="POST">
                            <input type="hidden" name="accion" value="guardar">
                            <input type="hidden" name="id" value="<%= prodEdicion != null ? prodEdicion.getId() : "" %>">
                            
                            <div class="mb-3">
                                <label class="form-label">Nombre:</label>
                                <input type="text" class="form-control" name="nombre" value="<%= prodEdicion != null ? prodEdicion.getNombre() : "" %>" required>
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Descripción:</label>
                                <textarea class="form-control" name="descripcion" rows="2" required><%= prodEdicion != null ? prodEdicion.getDescripcion() : "" %></textarea>
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Precio (S/):</label>
                                <input type="number" step="0.01" class="form-control" name="precio" value="<%= prodEdicion != null ? prodEdicion.getPrecio() : "" %>" required>
                            </div>
                            <button type="submit" class="btn btn-success w-100">Guardar</button>
                            <% if (prodEdicion != null) { %>
                                <a href="admin.jsp" class="btn btn-secondary w-100 mt-2">Cancelar Edición</a>
                            <% } %>
                        </form>
                    </div>
                </div>
            </div>

            <!-- Tabla de Listado -->
            <div class="col-md-8">
                <div class="card shadow-sm">
                    <div class="card-header bg-secondary text-white">
                        <h5 class="mb-0">Lista de Productos</h5>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table table-striped table-hover align-middle">
                                <thead>
                                    <tr>
                                        <th>ID</th>
                                        <th>Nombre</th>
                                        <th>Precio</th>
                                        <th>Acciones</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <%
                                        List<Producto> lista = dao.listar();
                                        for (Producto p : lista) {
                                    %>
                                    <tr>
                                        <td><%= p.getId() %></td>
                                        <td>
                                            <strong><%= p.getNombre() %></strong><br>
                                            <small class="text-muted"><%= p.getDescripcion() %></small>
                                        </td>
                                        <td class="fw-bold text-success">S/ <%= String.format("%.2f", p.getPrecio()) %></td>
                                        <td>
                                            <a href="admin.jsp?editId=<%= p.getId() %>" class="btn btn-warning btn-sm">Editar</a>
                                            <a href="admin.jsp?accion=eliminar&id=<%= p.getId() %>" class="btn btn-danger btn-sm" onclick="return confirm('¿Estás seguro de eliminar este producto?');">Eliminar</a>
                                        </td>
                                    </tr>
                                    <% } %>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>