<%-- 
    Document   : admin
    Created on : 10 oct 2026, 14:52:50
    Author     : ACER
--%>

<%@page import="java.util.List" %>
<%@page import="modelo.Producto" %>
<%@page import="dao.ProductoDAO" %>
<%@page import="java.io.File" %>
<%@page import="javax.servlet.http.Part" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%!
    // Método auxiliar para obtener el nombre del archivo subido de manera segura
    private String getFileName(Part part) {
        if (part == null) return null;
        for (String content : part.getHeader("content-disposition").split(";")) {
            if (content.trim().startsWith("filename")) {
                return content.substring(content.indexOf('=') + 1).trim().replace("\"", "");
            }
        }
        return null;
    }
%>

<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");

    ProductoDAO dao = new ProductoDAO();
    
    // Procesar acciones enviadas por formulario multipart (Crear / Editar)
    String contentType = request.getContentType();
    if (contentType != null && contentType.toLowerCase().contains("multipart/form-data")) {
        try {
            String accion = request.getParameter("accion");
            if (accion != null && accion.equals("guardar")) {
                String idStr = request.getParameter("id");
                String nombre = request.getParameter("nombre");
                String descripcion = request.getParameter("descripcion");
                double precio = Double.parseDouble(request.getParameter("precio"));
                String categoria = request.getParameter("categoria");
                String imagenActual = request.getParameter("imagenActual");

                String nombreImagenFinal = (imagenActual != null && !imagenActual.trim().isEmpty()) ? imagenActual : "default.png";

                // Intento seguro de captura y guardado de imagen
                try {
                    Part filePart = request.getPart("imagenArchivo");
                    if (filePart != null) {
                        String fileName = getFileName(filePart);
                        if (fileName != null && !fileName.trim().isEmpty()) {
                            nombreImagenFinal = new File(fileName).getName();
                            String uploadPath = application.getRealPath("/") + "img";
                            File uploadDir = new File(uploadPath);
                            if (!uploadDir.exists()) {
                                uploadDir.mkdirs();
                            }
                            filePart.write(uploadPath + File.separator + nombreImagenFinal);
                        }
                    }
                } catch (Exception ex) {
                    System.out.println("Aviso al procesar la imagen: " + ex.getMessage());
                }

                if (idStr == null || idStr.trim().isEmpty()) {
                    // Crear nuevo producto
                    Producto p = new Producto(0, nombre, descripcion, precio, nombreImagenFinal, categoria);
                    dao.insertar(p);
                } else {
                    // Actualizar producto existente
                    int id = Integer.parseInt(idStr);
                    Producto p = new Producto(id, nombre, descripcion, precio, nombreImagenFinal, categoria);
                    dao.actualizar(p);
                }
                response.sendRedirect("admin.jsp");
                return;
            }
        } catch (Exception e) {
            System.out.println("Error procesando formulario: " + e.getMessage());
        }
    }

    // Procesar acción de eliminación
    String accionEliminar = request.getParameter("accion");
    if (accionEliminar != null && accionEliminar.equals("eliminar")) {
        int id = Integer.parseInt(request.getParameter("id"));
        dao.eliminar(id);
        response.sendRedirect("admin.jsp");
        return;
    }
    
    // Obtener producto si se va a editar
    Producto prodEdicion = null;
    String editId = request.getParameter("editId");
    if (editId != null && !editId.trim().isEmpty()) {
        prodEdicion = dao.buscarPorId(Integer.parseInt(editId));
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>BurgerGo - Panel de Administración</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        :root {
            --burger-red: #E63946;
            --burger-dark: #212529;
            --burger-yellow: #F4A261;
        }

        /* Personalizar la barra de navegación */
        .navbar {
            background-color: var(--burger-dark) !important;
            border-bottom: 3px solid var(--burger-red);
        }

        /* Botones de acción principales */
        .btn-primary, .btn-success {
            background-color: var(--burger-red) !important;
            border-color: var(--burger-red) !important;
        }
        
        .btn-primary:hover, .btn-success:hover {
            background-color: #d02e3b !important;
            border-color: #c52a36 !important;
        }

        .text-success {
            color: var(--burger-red) !important;
        }
    </style>
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
                        <form action="ProductoServlet" method="POST" enctype="multipart/form-data">
                            <input type="hidden" name="accion" value="guardar">
                            <input type="hidden" name="id" value="<%= prodEdicion != null ? prodEdicion.getId() : "" %>">
                            <input type="hidden" name="imagenActual" value="<%= (prodEdicion != null && prodEdicion.getImagen() != null) ? prodEdicion.getImagen() : "" %>">
                            
                            <div class="mb-3">
                                <label class="form-label">Nombre:</label>
                                <input type="text" class="form-control" name="nombre" value="<%= prodEdicion != null ? prodEdicion.getNombre() : "" %>" required>
                            </div>

                            <div class="mb-3">
                                <label class="form-label">Categoría:</label>
                                <select class="form-select" name="categoria" required>
                                    <option value="">-- Seleccione Categoría --</option>
                                    <option value="Hamburguesas" <%= (prodEdicion != null && "Hamburguesas".equals(prodEdicion.getCategoria())) ? "selected" : "" %>>Hamburguesas</option>
                                    <option value="Broaster" <%= (prodEdicion != null && "Broaster".equals(prodEdicion.getCategoria())) ? "selected" : "" %>>Broaster</option>
                                    <option value="Salchipapas" <%= (prodEdicion != null && "Salchipapas".equals(prodEdicion.getCategoria())) ? "selected" : "" %>>Salchipapas</option>
                                    <option value="Parrillas al Carbón" <%= (prodEdicion != null && "Parrillas al Carbón".equals(prodEdicion.getCategoria())) ? "selected" : "" %>>Parrillas al Carbón</option>
                                    <option value="Jugos y Bebidas" <%= (prodEdicion != null && "Jugos y Bebidas".equals(prodEdicion.getCategoria())) ? "selected" : "" %>>Jugos y Bebidas</option>
                                </select>
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
                                <label class="form-label">Suba imagen a seleccionar:</label>
                                <input type="file" class="form-control" name="imagenArchivo" accept="image/*">
                                <% if (prodEdicion != null && prodEdicion.getImagen() != null && !prodEdicion.getImagen().isEmpty()) { %>
                                    <small class="text-muted d-block mt-1">Actual: <code><%= prodEdicion.getImagen() %></code></small>
                                <% } %>
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
                                        <th>Categoría</th>
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
                                        <td>
                                            <span class="badge bg-dark"><%= (p.getCategoria() != null && !p.getCategoria().isEmpty()) ? p.getCategoria() : "Sin cat." %></span>
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