/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controlador;

import dao.ProductoDAO;
import modelo.Producto;
import java.io.File;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;

@WebServlet(name = "ProductoServlet", urlPatterns = {"/ProductoServlet"})
@MultipartConfig(fileSizeThreshold = 1024 * 1024 * 2, // 2MB
                 maxFileSize = 1024 * 1024 * 10,      // 10MB
                 maxRequestSize = 1024 * 1024 * 50)   // 50MB
public class ProductoServlet extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        ProductoDAO dao = new ProductoDAO();
        String accion = request.getParameter("accion");

        if (accion != null) {
            if (accion.equals("guardar")) {
                String idStr = request.getParameter("id");
                String nombre = request.getParameter("nombre");
                String descripcion = request.getParameter("descripcion");
                double precio = Double.parseDouble(request.getParameter("precio"));
                String categoria = request.getParameter("categoria");
                String imagenActual = request.getParameter("imagenActual");

                String nombreImagenFinal = (imagenActual != null && !imagenActual.trim().isEmpty()) ? imagenActual : "default.png";

                try {
                    Part filePart = request.getPart("imagenArchivo");
                    if (filePart != null && filePart.getSize() > 0) {
                        String fileName = getFileName(filePart);
                        if (fileName != null && !fileName.trim().isEmpty()) {
                            nombreImagenFinal = new File(fileName).getName();
                            String uploadPath = getServletContext().getRealPath("/") + "img";
                            File uploadDir = new File(uploadPath);
                            if (!uploadDir.exists()) {
                                uploadDir.mkdirs();
                            }
                            filePart.write(uploadPath + File.separator + nombreImagenFinal);
                        }
                    }
                } catch (Exception e) {
                    System.out.println("Error al subir imagen: " + e.getMessage());
                }

                if (idStr == null || idStr.trim().isEmpty()) {
                    // Crear
                    Producto p = new Producto(0, nombre, descripcion, precio, nombreImagenFinal, categoria);
                    dao.insertar(p);
                } else {
                    // Actualizar
                    int id = Integer.parseInt(idStr);
                    Producto p = new Producto(id, nombre, descripcion, precio, nombreImagenFinal, categoria);
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
        response.sendRedirect("admin.jsp");
    }

    private String getFileName(Part part) {
        for (String content : part.getHeader("content-disposition").split(";")) {
            if (content.trim().startsWith("filename")) {
                return content.substring(content.indexOf('=') + 1).trim().replace("\"", "");
            }
        }
        return null;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }
}
