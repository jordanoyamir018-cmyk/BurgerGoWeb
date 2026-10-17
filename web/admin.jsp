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
            String imagen = request.getParameter("imagen"); // Captura el archivo de imagen
            
            String idStr = request.getParameter("id");
            if (idStr == null || idStr.isEmpty()) {
                // Crear
                Producto p = new Producto(0, nombre, descripcion, precio, imagen);
                dao.insertar(p);
            } else {
                // Actualizar
                int id = Integer.parseInt(idStr);
                Producto p = new Producto(id, nombre, descripcion, precio, imagen);
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
            <a class="navbar-brand fw-bold d-flex align-items-center" href="admin.jsp">
                <img src="img/logo_upn.png" alt="Logo UPN" height="100" class="d-inline-block me-2 rounded bg-white p-1">
                <img src="img/logo_BurgerGo.jpeg" alt="Logo BurgerGo" height="110" class="d-inline-block me-2 rounded p-1"> 
                BurgerGo - Panel Admin
            </a>
            <div class="d-flex align-items-center">
                <span class="text-white me-3 small">👤 Hola, <strong><%= userLog.getUsername() %></strong> (ADMIN)</span>

                <a href="inventario.jsp" class="btn btn-outline-info btn-sm me-2">📦 Control de inventario</a>
                <a href="reportes.jsp" class="btn btn-outline-warning btn-sm me-2">📊 Reportes de ventas</a>

                <a href="LoginServlet?accion=logout" class="btn btn-outline-danger btn-sm">🚪 Salir</a>
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
                            <div class="mb-3">
                                <label class="form-label">Nombre de archivo de imagen:</label>
                                <input type="text" class="form-control" name="imagen" placeholder="ej: hamburguesa_royal.png" value="<%= (prodEdicion != null && prodEdicion.getImagen() != null) ? prodEdicion.getImagen() : "" %>">
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
                                        <th>Imagen</th>
                                        <th>Nombre</th>
                                        <th>Precio</th>
                                        <th>Acciones</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <%
                                        List<Producto> lista = dao.listar();
                                        for (Producto p : lista) {
                                            String imgFile = (p.getImagen() != null && !p.getImagen().trim().isEmpty()) ? p.getImagen() : "default.png";
                                    %>
                                    <tr>
                                        <td><%= p.getId() %></td>
                                        <td>
                                            <img src="img/<%= imgFile %>" alt="<%= p.getNombre() %>" style="width: 50px; height: 50px; object-fit: contain; background-color: #f8f9fa;" class="img-thumbnail">
                                        </td>
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