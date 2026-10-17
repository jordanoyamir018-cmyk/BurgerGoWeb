<%-- 
    Document   : index
    Created on : 10 oct 2026, 0:37:11
    Author     : ACER
--%>

<%@page import="java.util.List" %>
<%@page import="modelo.Producto" %>
<%@page import="dao.ProductoDAO" %>
<%@page import="modelo.DetallePedido" %>
<%@page import="modelo.Pedido" %>
<%@page import="dao.PedidoDAO" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");

    ProductoDAO productoDAO = new ProductoDAO();
    List<Producto> listaProductos = productoDAO.listar();
    
    // Obtener carrito de la sesión
    List<DetallePedido> carrito = (List<DetallePedido>) session.getAttribute("carrito");
    if (carrito == null) {
        carrito = new java.util.ArrayList<>();
    }
    
    double totalCarrito = 0;
    for (DetallePedido item : carrito) {
        totalCarrito += item.getSubtotal();
    }
%>
<%@ page import="modelo.Usuario" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>BurgerGo - Menú y Carrito de Compras</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
    <!-- Barra de Navegación -->
    <nav class="navbar navbar-dark bg-dark mb-4 shadow-sm">
        <div class="container-fluid">
            <a class="navbar-brand fw-bold d-flex align-items-center" href="index.jsp">
                <img src="img/logo_upn.png" alt="Logo UPN" height="100" class="d-inline-block me-2 rounded bg-white p-1">
                <img src="img/logo_BurgerGo.jpeg" alt="Logo BurgerGo" height="110" class="d-inline-block me-2 rounded p-1"> 
                BurgerGo - Menú Principal
            </a>
            <div class="d-flex align-items-center">
                <% 
                    Usuario userLog = (Usuario) session.getAttribute("usuarioLogueado");
                    if (userLog != null) { 
                %>
                    <!-- Si ya inició sesión, mostramos acceso directo a su panel correspondiente y botón salir -->
                    <span class="text-white me-3 small">👤 Hola, <strong><%= userLog.getUsername() %></strong> (<%= userLog.getRol().toUpperCase() %>)</span>
                    
                    <% if ("cocina".equals(userLog.getRol())) { %>
                        <a href="cocina.jsp" class="btn btn-outline-info btn-sm me-2">👨‍🍳 Ir a Cocina</a>
                    <% } else if ("delivery".equals(userLog.getRol())) { %>
                        <a href="delivery.jsp" class="btn btn-outline-primary btn-sm me-2">🛵 Ir a Delivery</a>
                    <% } else if ("admin".equals(userLog.getRol()) || "cajero".equals(userLog.getRol())) { %>
                        <a href="admin.jsp" class="btn btn-outline-warning btn-sm me-2">⚙️ Panel Admin / CRUD</a>
                    <% } %>

                    <a href="LoginServlet?accion=logout" class="btn btn-outline-danger btn-sm">🚪 Salir</a>

                <% } else { %>
                    <!-- Si NO ha iniciado sesión, mostramos el botón para abrir el Modal de Login -->
                    <button type="button" class="btn btn-outline-light btn-sm" data-bs-toggle="modal" data-bs-target="#loginModal">
                        🔐 Iniciar Sesión (Personal)
                    </button>
                <% } %>
            </div>
        </div>
    </nav>
            
    <!-- VENTANA MODAL DE LOGIN -->
    <div class="modal fade" id="loginModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header bg-dark text-white">
                    <h5 class="modal-title">🔑 Acceso al Sistema - BurgerGo</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <form action="LoginServlet" method="POST">
                    <input type="hidden" name="accion" value="login">
                    <div class="modal-body">
                        <div class="mb-3">
                            <label class="form-label fw-bold">Usuario:</label>
                            <input type="text" class="form-control" name="username" required placeholder="Ej. chef, cajero1, jefe">
                        </div>
                        <div class="mb-3">
                            <label class="form-label fw-bold">Contraseña:</label>
                            <input type="password" class="form-control" name="password" required placeholder="••••">
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Cancelar</button>
                        <button type="submit" class="btn btn-primary btn-sm">Ingresar</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Script de Bootstrap (Necesario para que abra el Modal) -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    </body>
    </html>
            
    <div class="container mb-5">
        <!-- Alertas de éxito o error -->
        <% if (request.getParameter("exito") != null) { %>
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                ¡Pedido registrado con éxito! Pronto lo llevaremos a tu domicilio.
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        <% } %>

        <!-- Error específico para el Login -->
        <% if ("datosIncorrectos".equals(request.getParameter("error"))) { %>
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                ❌ <strong>Error de acceso:</strong> Usuario o contraseña incorrectos. Por favor, verifícalos e inténtalo de nuevo.
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        <% } else if ("rolInvalido".equals(request.getParameter("error"))) { %>
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                ⚠️ <strong>Error:</strong> El rol asignado a este usuario no es válido.
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        <% } else if (request.getParameter("error") != null) { %>
            <!-- Error genérico para el carrito o compras -->
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                Hubo un error al procesar tu compra o el carrito estaba vacío.
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        <% } %>

        <div class="row">
            <!-- SECCIÓN IZQUIERDA: MENÚ DE PRODUCTOS POR CATEGORÍAS -->
            <div class="col-lg-7">
                <%
                    String[] categorias = {"Hamburguesas", "Broaster", "Salchipapas", "Parrillas al Carbón", "Jugos y Bebidas"};

                    if (listaProductos == null || listaProductos.isEmpty()) {
                %>
                    <h3 class="fw-bold mb-3">Menú</h3>
                    <p class="text-muted">No hay productos disponibles por el momento.</p>
                <%
                    } else {
                        for (String cat : categorias) {
                %>
                    <!-- Título de cada categoría -->
                    <h3 class="fw-bold mt-4 mb-3 text-dark border-bottom pb-2"><%= cat %></h3>
                    <div class="row row-cols-1 row-cols-md-2 g-3">
                        <% 
                            boolean hayProductos = false;
                            for (Producto p : listaProductos) { 
                                String nombreLower = p.getNombre().toLowerCase();
                                String descLower = p.getDescripcion().toLowerCase();
                                boolean pertenece = false;

                                // Filtro por categoría según nombre o descripción
                                if (cat.equals("Broaster") && (nombreLower.contains("ala") || nombreLower.contains("pierna") || nombreLower.contains("encuentro") || nombreLower.contains("pecho"))) {
                                    pertenece = true;
                                } else if (cat.equals("Salchipapas") && (nombreLower.contains("salchi") || descLower.contains("hotdog"))) {
                                    pertenece = true;
                                } else if (cat.equals("Parrillas al Carbón") && (nombreLower.contains("anticucho") || nombreLower.contains("parrilla"))) {
                                    pertenece = true;
                                } else if (cat.equals("Jugos y Bebidas") && (nombreLower.contains("jugo") || nombreLower.contains("gaseosa") || nombreLower.contains("cola"))) {
                                    pertenece = true;
                                } else if (cat.equals("Hamburguesas") && !nombreLower.contains("ala") && !nombreLower.contains("pierna") && !nombreLower.contains("encuentro") && !nombreLower.contains("pecho") && !nombreLower.contains("salchi") && !descLower.contains("hotdog") && !nombreLower.contains("anticucho") && !nombreLower.contains("parrilla") && !nombreLower.contains("jugo") && !nombreLower.contains("gaseosa")) {
                                    pertenece = true;
                                }

                                if (pertenece) {
                                    hayProductos = true;
                        %>
                        <div class="col">
                            <div class="card h-100 shadow-sm border-0 overflow-hidden">
                                
                                <!-- IMAGEN DINÁMICA DEL PRODUCTO -->
                                <% 
                                    String imgPath = "img/default.png";
                                    if (p.getImagen() != null && !p.getImagen().trim().isEmpty()) {
                                        imgPath = "img/" + p.getImagen();
                                    }
                                %>
                                <img src="<%= imgPath %>" 
                                     class="card-img-top p-2" 
                                     alt="<%= p.getNombre() %>" 
                                     style="height: 160px; object-fit: contain; background-color: #ffffff;"> 

                                <div class="card-body d-flex flex-column">
                                    <h5 class="card-title fw-bold text-dark"><%= p.getNombre() %></h5>
                                    <p class="card-text text-muted small flex-grow-1"><%= p.getDescripcion() %></p>
                                    <div class="d-flex justify-content-between align-items-center mt-3">
                                        <span class="fs-5 fw-bold text-success">S/ <%= String.format("%.2f", p.getPrecio()) %></span>

                                        <!-- Formulario para agregar al carrito -->
                                        <form action="CarritoServlet" method="POST" class="d-flex align-items-center gap-1">
                                            <input type="hidden" name="accion" value="agregar">
                                            <input type="hidden" name="idProducto" value="<%= p.getId() %>">
                                            <input type="number" name="cantidad" value="1" min="1" max="10" class="form-control form-control-sm text-center" style="width: 55px;">
                                            <button type="submit" class="btn btn-dark btn-sm">🛒 Agregar</button>
                                        </form>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <% 
                                } 
                            } 
                            if (!hayProductos) {
                        %>
                            <div class="col-12"><p class="text-muted small fst-italic">No hay productos en esta sección.</p></div>
                        <%  } %>
                    </div>
                <% 
                        }
                    } 
                %>
            </div>
            
            <!-- SECCIÓN DERECHA: CARRITO DE COMPRAS Y CHECKOUT -->
            <div class="col-lg-5 mt-4 mt-lg-0">
                <div class="card shadow-sm border-0 sticky-top" style="top: 20px;">
                    <div class="card-header bg-dark text-white py-3">
                        <h5 class="mb-0 fw-bold">🛒 Tu Carrito de Compras</h5>
                    </div>
                    <div class="card-body">
                        <% if (carrito.isEmpty()) { %>
                            <p class="text-muted text-center py-4">Tu carrito está vacío. ¡Agrega productos del menú!</p>
                        <% } else { %>
                            <div class="table-responsive mb-3" style="max-height: 250px; overflow-y: auto;">
                                <table class="table table-sm align-middle">
                                    <thead>
                                        <tr>
                                            <th>Producto</th>
                                            <th>Cant.</th>
                                            <th>Subtotal</th>
                                            <th></th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <% for (DetallePedido item : carrito) { %>
                                        <tr>
                                            <td><%= item.getNombreProducto() %></td>
                                            <td><%= item.getCantidad() %></td>
                                            <td class="fw-bold text-success">S/ <%= String.format("%.2f", item.getSubtotal()) %></td>
                                            <td>
                                                <form action="CarritoServlet" method="POST">
                                                    <input type="hidden" name="accion" value="eliminar">
                                                    <input type="hidden" name="idProducto" value="<%= item.getIdProducto() %>">
                                                    <button type="submit" class="btn btn-outline-danger btn-sm py-0 px-1" style="font-size: 11px;">❌</button>
                                                </form>
                                            </td>
                                        </tr>
                                        <% } %>
                                    </tbody>
                                </table>
                            </div>

                            <hr>
                            <div class="d-flex justify-content-between mb-3">
                                <span class="fs-5 fw-bold">Total a Pagar:</span>
                                <span class="fs-4 fw-bold text-success">S/ <%= String.format("%.2f", totalCarrito) %></span>
                            </div>

                            <!-- Formulario de Datos y Procesar Compra -->
                            <form action="CarritoServlet" method="POST">
                                <input type="hidden" name="accion" value="procesarCompra">
                                
                                <div class="mb-2">
                                    <label class="form-label small fw-bold">Nombre del Cliente:</label>
                                    <input type="text" class="form-control form-control-sm" name="clienteNombre" required placeholder="Ej. Juan Pérez">
                                </div>

                                <!-- NUEVA OPCIÓN: Local o Delivery -->
                                <div class="mb-2">
                                    <label class="form-label small fw-bold">Tipo de Pedido:</label>
                                    <select class="form-select form-select-sm" name="tipoPedido" id="tipoPedido" required onchange="manejarTipoPedido()">
                                        <option value="" selected disabled>-- Seleccione modalidad --</option>
                                        <option value="Local">Local</option>
                                        <option value="Delivery">Delivery</option>
                                    </select>
                                </div>

                                <!-- SECCIÓN CONDICIONAL PARA DELIVERY (Teléfono y Dirección) -->
                                <div id="bloqueDelivery" style="display: none;">
                                    <div class="mb-2">
                                        <label class="form-label small fw-bold">Teléfono:</label>
                                        <input type="text" class="form-control form-control-sm" name="telefono" id="inputTelefono" placeholder="Ej. 999888777">
                                    </div>
                                    <div class="mb-2">
                                        <label class="form-label small fw-bold">Dirección de Entrega:</label>
                                        <textarea class="form-control form-control-sm" name="direccion" id="inputDireccion" rows="2" placeholder="Av. Principal 123"></textarea>
                                    </div>
                                </div>

                                <!-- SECCIÓN MÉTODO DE PAGO -->
                                <div class="mb-2" id="bloqueMetodoPago" style="display: none;">
                                    <label class="form-label small fw-bold">Método de Pago:</label>
                                    <select class="form-select form-select-sm" name="metodoPago" id="selectMetodoPago" required onchange="manejarMetodoPago()">
                                        <option value="" selected disabled>-- Seleccione pago --</option>
                                    </select>
                                </div>

                                <!-- SUB-SECCIÓN YAPE (Común si eligen Yape) -->
                                <div class="mb-2 p-2 bg-light border rounded small" id="bloqueYape" style="display: none;">
                                    <p class="mb-1 text-primary fw-bold">📱 Pago por Yape</p>
                                    <p class="mb-1 text-muted">Número a yapear: <strong class="text-dark">901977498</strong></p>
                                    <div class="form-check">
                                        <input class="form-check-input" type="checkbox" id="yapeConfirmado" required>
                                        <label class="form-check-label" for="yapeConfirmado">
                                            Ya realicé el pago por Yape
                                        </label>
                                    </div>
                                </div>

                                <!-- SUB-SECCIÓN TARJETA BCP (Solo Delivery) -->
                                <div class="mb-2 p-2 bg-light border rounded small" id="bloqueTarjeta" style="display: none;">
                                    <p class="mb-1 text-danger fw-bold">💳 Pago con Tarjeta BCP</p>
                                    <div class="mb-1">
                                        <label class="form-label small">Nro. de Tarjeta BCP:</label>
                                        <input type="text" class="form-control form-control-sm" name="nroTarjeta" id="inputTarjeta" placeholder="4152xxxxxxxxxxxx" maxlength="16">
                                    </div>
                                    <div>
                                        <label class="form-label small">Contraseña:</label>
                                        <input type="password" class="form-control form-control-sm" name="claveTarjeta" id="inputClave" placeholder="••••">
                                    </div>
                                </div>
                                
                                <button type="submit" class="btn btn-success w-100 fw-bold py-2 mt-2" id="btnEnviar" style="display: none;">🚀 Confirmar y Enviar Pedido</button>
                            </form>
                        <% } %>
                    </div>
                </div>
            </div>
        </div>

        <!-- SCRIPT DE CONTROL DINÁMICO -->
        <script>
        function manejarTipoPedido() {
            const tipo = document.getElementById("tipoPedido").value;
            const bloqueDelivery = document.getElementById("bloqueDelivery");
            const bloqueMetodoPago = document.getElementById("bloqueMetodoPago");
            const selectMetodo = document.getElementById("selectMetodoPago");
            const bloqueYape = document.getElementById("bloqueYape");
            const bloqueTarjeta = document.getElementById("bloqueTarjeta");
            const btnEnviar = document.getElementById("btnEnviar");

            // Resetear pagos y botones
            selectMetodo.innerHTML = '<option value="" selected disabled>-- Seleccione pago --</option>';
            bloqueYape.style.display = "none";
            bloqueTarjeta.style.display = "none";
            btnEnviar.style.display = "none";
            bloqueMetodoPago.style.display = "block";

            const inputTel = document.getElementById("inputTelefono");
            const inputDir = document.getElementById("inputDireccion");

            if (tipo === "Local") {
                bloqueDelivery.style.display = "none";
                inputTel.removeAttribute("required");
                inputDir.removeAttribute("required");
                inputTel.value = "";
                inputDir.value = "";

                // Opciones para Local: Yape o Efectivo
                selectMetodo.innerHTML += `
                    <option value="Yape">Yape</option>
                    <option value="Efectivo">Efectivo</option>
                `;
            } else if (tipo === "Delivery") {
                bloqueDelivery.style.display = "block";
                inputTel.setAttribute("required", "true");
                inputDir.setAttribute("required", "true");

                // Opciones para Delivery: Yape o Tarjeta
                selectMetodo.innerHTML += `
                    <option value="Yape">Yape</option>
                    <option value="Tarjeta">Tarjeta</option>
                `;
            }
        }

        function manejarMetodoPago() {
        const metodo = document.getElementById("selectMetodoPago").value;
        const bloqueYape = document.getElementById("bloqueYape");
        const bloqueTarjeta = document.getElementById("bloqueTarjeta");
        const btnEnviar = document.getElementById("btnEnviar");

        // Inputs específicos
        const checkYape = document.getElementById("yapeConfirmado");
        const inputTarjeta = document.getElementById("inputTarjeta");
        const inputClave = document.getElementById("inputClave");

        // Ocultar todo primero y limpiar requeridos
        bloqueYape.style.display = "none";
        bloqueTarjeta.style.display = "none";
        checkYape.removeAttribute("required");
        inputTarjeta.removeAttribute("required");
        inputClave.removeAttribute("required");

        btnEnviar.style.display = "block"; // Mostrar botón

        if (metodo === "Yape") {
            bloqueYape.style.display = "block";
            checkYape.setAttribute("required", "true"); // Exigir confirmación de yape
        } else if (metodo === "Tarjeta") {
            bloqueTarjeta.style.display = "block";
            inputTarjeta.setAttribute("required", "true"); // Exigir número de tarjeta
            inputClave.setAttribute("required", "true");  // Exigir contraseña
        } else if (metodo === "Efectivo") {
            // No requiere campos adicionales
        }
    }
        </script>

        <!-- SECCIÓN DE CONSULTA DE ESTADO Y DETALLE DE PEDIDOS -->
        <div class="row mt-5">
            <div class="col-12">
                <div class="card shadow-sm border-0">
                    <div class="card-header bg-dark text-white">
                        <h5 class="mb-0 fw-bold">🔍 Consultar Estado y Detalle de tus Pedidos</h5>
                    </div>
                    <div class="card-body">
                        <form action="index.jsp" method="GET" class="row g-3 align-items-center mb-4">
                            <div class="col-md-8">
                                <input type="text" class="form-control" name="buscarCliente" placeholder="Ingresa tu nombre o número de teléfono..." required>
                            </div>
                            <div class="col-md-4">
                                <button type="submit" class="btn btn-dark w-100 fw-bold">Buscar Mis Pedidos</button>
                            </div>
                        </form>

                        <%
                            String bCliente = request.getParameter("buscarCliente");
                            if (bCliente != null && !bCliente.trim().isEmpty()) {
                                PedidoDAO pDaoConsulta = new PedidoDAO();
                                List<Pedido> misPedidos = pDaoConsulta.listarPedidosPorCliente(bCliente);
                                
                                if (misPedidos.isEmpty()) {
                        %>
                                    <div class="alert alert-warning text-center" role="alert">
                                        No se encontraron pedidos registrados con ese nombre o teléfono.
                                    </div>
                        <%          
                                } else {
                                    for (Pedido ped : misPedidos) {
                                        // Definir color del badge según el estado del pedido en tiempo real
                                        String badgeColor = "bg-secondary";
                                        if ("Pendiente".equalsIgnoreCase(ped.getEstado())) badgeColor = "bg-warning text-dark";
                                        else if ("En Preparación".equalsIgnoreCase(ped.getEstado())) badgeColor = "bg-info text-dark";
                                        else if ("Preparado".equalsIgnoreCase(ped.getEstado())) badgeColor = "bg-primary";
                                        else if ("En Camino".equalsIgnoreCase(ped.getEstado())) badgeColor = "bg-primary";
                                        else if ("Entregado".equalsIgnoreCase(ped.getEstado())) badgeColor = "bg-success";
                        %>
                                        <div class="card mb-3 border">
                                            <div class="card-header bg-light d-flex justify-content-between align-items-center">
                                                <span class="fw-bold">Pedido #<%= ped.getId() %> - Cliente: <%= ped.getClienteNombre() %></span>
                                                <span class="badge <%= badgeColor %> px-3 py-2 fs-6">Estado: <%= ped.getEstado() %></span>
                                            </div>
                                            <div class="card-body">
                                                <div class="row mb-3 small text-muted">
                                                    <div class="col-md-4">📞 <strong>Teléfono:</strong> <%= ped.getTelefono() %></div>
                                                    <div class="col-md-4">📍 <strong>Dirección:</strong> <%= ped.getDireccion() %></div>
                                                    <div class="col-md-4">📅 <strong>Fecha:</strong> <%= ped.getFecha() %></div>
                                                </div>

                                                <h6 class="fw-bold text-dark mb-2">Productos del Pedido:</h6>
                                                <div class="table-responsive">
                                                    <table class="table table-sm table-bordered align-middle mb-2">
                                                        <thead class="table-light">
                                                            <tr>
                                                                <th>Producto</th>
                                                                <th class="text-center">Cantidad</th>
                                                                <th class="text-end">Subtotal</th>
                                                            </tr>
                                                        </thead>
                                                        <tbody>
                                                            <%
                                                                List<DetallePedido> detallesDelPedido = pDaoConsulta.listarDetallesPorPedido(ped.getId());
                                                                for (DetallePedido det : detallesDelPedido) {
                                                            %>
                                                            <tr>
                                                                <td><%= det.getNombreProducto() %></td>
                                                                <td class="text-center"><%= det.getCantidad() %></td>
                                                                <td class="text-end fw-bold text-success">S/ <%= String.format("%.2f", det.getSubtotal()) %></td>
                                                            </tr>
                                                            <% } %>
                                                        </tbody>
                                                    </table>
                                                </div>
                                                <div class="d-flex justify-content-end align-items-center">
                                                    <span class="fs-5 fw-bold me-2">Total Pagado:</span>
                                                    <span class="fs-4 fw-bold text-success">S/ <%= String.format("%.2f", ped.getTotal()) %></span>
                                                </div>
                                            </div>
                                        </div>
                        <%          
                                    }
                                } 
                            } 
                        %>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>