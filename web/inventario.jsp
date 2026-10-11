<%-- 
    Document   : inventario
    Created on : 11 oct 2026, 1:05:01
    Author     : ACER
--%>

<%@page import="java.util.List" %>
<%@page import="modelo.Insumo" %>
<%@page import="dao.InsumoDAO" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");

    InsumoDAO insumoDAO = new InsumoDAO();

    // Procesar Reabastecimiento
    String accion = request.getParameter("accion");
    if (accion != null && accion.equals("reabastecer")) {
        int idInsumo = Integer.parseInt(request.getParameter("idInsumo"));
        double cantidad = Double.parseDouble(request.getParameter("cantidad"));
        insumoDAO.agregarStock(idInsumo, cantidad);
        response.sendRedirect("inventario.jsp?exito=1");
        return;
    }

    List<Insumo> listaInsumos = insumoDAO.listarInsumos();
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>BurgerGo - Inventario y Proveedores</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
    <nav class="navbar navbar-dark bg-dark mb-4 shadow-sm">
        <div class="container-fluid">
            <a class="navbar-brand fw-bold" href="admin.jsp">📦 BurgerGo - Control de Inventario y Proveedores</a>
            <div>
                <a href="admin.jsp" class="btn btn-outline-warning btn-sm me-2">CRUD Productos</a>
                <a href="reportes.jsp" class="btn btn-outline-success btn-sm me-2">Reporte Ventas</a>
                <a href="index.jsp" class="btn btn-outline-light btn-sm">Ver Menú</a>
            </div>
        </div>
    </nav>

    <div class="container mb-5">
        <% if (request.getParameter("exito") != null) { %>
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                ¡Stock actualizado correctamente! La alerta ha sido procesada.
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        <% } %>

        <div class="row">
            <!-- TABLA DE INVENTARIO Y ALERTAS DE STOCK -->
            <div class="col-lg-8 mb-4">
                <div class="card shadow-sm border-0">
                    <div class="card-header bg-dark text-white fw-bold d-flex justify-content-between align-items-center">
                        <span>📋 Existencia Actual de Insumos</span>
                        <span class="badge bg-danger">Alertas de Bajo Stock</span>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table table-hover align-middle">
                                <thead class="table-light">
                                    <tr>
                                        <th>Insumo</th>
                                        <th>Unidad</th>
                                        <th class="text-center">Stock Actual</th>
                                        <th class="text-center">Stock Mínimo</th>
                                        <th class="text-center">Estado / Alerta</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% for (Insumo ins : listaInsumos) { 
                                        boolean alerta = ins.getStockActual() <= ins.getStockMinimo();
                                    %>
                                    <tr class="<%= alerta ? "table-danger" : "" %>">
                                        <td class="fw-bold"><%= ins.getNombre() %></td>
                                        <td><%= ins.getUnidadMedida() %></td>
                                        <td class="text-center fs-6 fw-bold"><%= String.format("%.2f", ins.getStockActual()) %></td>
                                        <td class="text-center text-muted"><%= String.format("%.2f", ins.getStockMinimo()) %></td>
                                        <td class="text-center">
                                            <% if (alerta) { %>
                                                <span class="badge bg-danger text-white">⚠️ ¡ALERTA! STOCK BAJO</span>
                                            <% } else { %>
                                                <span class="badge bg-success">Suficiente</span>
                                            <% } %>
                                        </td>
                                    </tr>
                                    <% } %>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>

            <!-- REGISTRO DE INGRESO DE STOCK Y SELECCIÓN DE PROVEEDORES -->
            <div class="col-lg-4">
                <!-- Tarjeta 1: Reabastecer Stock -->
                <div class="card shadow-sm border-0 mb-4">
                    <div class="card-header bg-primary text-white fw-bold">
                        ➕ Entrada de Nuevo Stock
                    </div>
                    <div class="card-body">
                        <form action="inventario.jsp" method="POST">
                            <input type="hidden" name="accion" value="reabastecer">
                            <div class="mb-3">
                                <label class="form-label small fw-bold">Seleccionar Insumo:</label>
                                <select name="idInsumo" class="form-select form-select-sm" required>
                                    <% for (Insumo ins : listaInsumos) { %>
                                        <option value="<%= ins.getId() %>"><%= ins.getNombre() %> (Actual: <%= ins.getStockActual() %>)</option>
                                    <% } %>
                                </select>
                            </div>
                            <div class="mb-3">
                                <label class="form-label small fw-bold">Cantidad de Ingreso:</label>
                                <input type="number" step="0.01" min="1" name="cantidad" class="form-control form-control-sm" required placeholder="Ej. 50">
                            </div>
                            <button type="submit" class="btn btn-primary btn-sm w-100 fw-bold">Ingresar Stock</button>
                        </form>
                    </div>
                </div>

                <!-- Tarjeta 2: Orden de Compra a Proveedores con Filtrado Dinámico -->
                <div class="card shadow-sm border-0">
                    <div class="card-header bg-secondary text-white fw-bold">
                        🏭 Comprar Insumos a Proveedor
                    </div>
                    <div class="card-body">
                        <form onsubmit="alert('✅ Orden de Compra enviada exitosamente al Proveedor.'); return false;">
                            <!-- Selección de Proveedor -->
                            <div class="mb-2">
                                <label class="form-label small fw-bold">Proveedor:</label>
                                <select id="selectProveedor" name="proveedorId" class="form-select form-select-sm" onchange="actualizarInsumosPorProveedor()" required>
                                    <option value="">-- Seleccionar Proveedor --</option>
                                    <option value="1">Distribuidora San Fernando</option>
                                    <option value="2">Panadería El Buen Pan</option>
                                    <option value="3">Proveedor General / Mercado</option>
                                </select>
                            </div>

                            <!-- Insumos Filtrados por Proveedor -->
                            <div class="mb-2">
                                <label class="form-label small fw-bold">Insumo a Comprar:</label>
                                <select id="selectInsumoProveedor" name="insumoId" class="form-select form-select-sm" required disabled>
                                    <option value="">-- Primero elige un Proveedor --</option>
                                </select>
                            </div>

                            <!-- Cantidad Requerida -->
                            <div class="mb-3">
                                <label class="form-label small fw-bold">Cantidad Requerida:</label>
                                <input type="number" step="0.01" min="1" name="cantidad" class="form-control form-control-sm" placeholder="Ej. 100" required>
                            </div>

                            <button type="submit" class="btn btn-dark btn-sm w-100 fw-bold">🛒 Generar Orden de Compra</button>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Script JavaScript para el comportamiento dinámico del selector de proveedores e insumos -->
    <script>
        const insumosPorProveedor = {
            "1": [ // Distribuidora San Fernando (Carnes, embutidos y aves)
                { id: "2", nombre: "Carne artesanal" },
                { id: "5", nombre: "Lámina de pechuga frita" },
                { id: "6", nombre: "Chorizo" },
                { id: "4", nombre: "Tocino" }
            ],
            "2": [ // Panadería El Buen Pan (Panes)
                { id: "1", nombre: "Pan de Hamburguesa" }
            ],
            "3": [ // Proveedor General / Mercado (Complementos, verduras, lácteos)
                { id: "3", nombre: "Queso Cheddar" },
                { id: "7", nombre: "Huevo" },
                { id: "8", nombre: "Plátano" },
                { id: "9", nombre: "Piña" },
                { id: "10", nombre: "Papa (Porción)" },
                { id: "11", nombre: "Ensalada (Porción)" }
            ]
        };

        function actualizarInsumosPorProveedor() {
            const proveedorSelect = document.getElementById("selectProveedor");
            const insumoSelect = document.getElementById("selectInsumoProveedor");
            const proveedorId = proveedorSelect.value;

            // Limpiar opciones actuales
            insumoSelect.innerHTML = "";

            if (proveedorId && insumosPorProveedor[proveedorId]) {
                insumoSelect.disabled = false;
                
                const defaultOpt = document.createElement("option");
                defaultOpt.value = "";
                defaultOpt.textContent = "-- Seleccionar Insumo --";
                insumoSelect.appendChild(defaultOpt);

                insumosPorProveedor[proveedorId].forEach(insumo => {
                    const opt = document.createElement("option");
                    opt.value = insumo.id;
                    opt.textContent = insumo.nombre;
                    insumoSelect.appendChild(opt);
                });
            } else {
                insumoSelect.disabled = true;
                const opt = document.createElement("option");
                opt.value = "";
                opt.textContent = "-- Primero elige un Proveedor --";
                insumoSelect.appendChild(opt);
            }
        }
    </script>
</body>
</html>