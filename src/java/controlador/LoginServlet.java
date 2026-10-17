/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controlador;

import dao.UsuarioDAO;
import modelo.Usuario;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(name = "LoginServlet", urlPatterns = {"/LoginServlet"})
public class LoginServlet extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String accion = request.getParameter("accion");

        if ("login".equals(accion)) {
            String user = request.getParameter("username");
            String pass = request.getParameter("password");

            UsuarioDAO dao = new UsuarioDAO();
            Usuario u = dao.validarLogin(user, pass);

            if (u != null) {
                HttpSession session = request.getSession();
                session.setAttribute("usuarioLogueado", u);
                session.setAttribute("rol", u.getRol());

                // Redirección según el rol
                switch (u.getRol()) {
                    case "cocina":
                        response.sendRedirect("cocina.jsp");
                        break;
                    case "delivery":
                        response.sendRedirect("delivery.jsp");
                        break;
                    case "admin":
                        response.sendRedirect("admin.jsp");
                        break;
                    case "cajero":
                        // El cajero entra al panel admin pero limitado en la vista
                        response.sendRedirect("admin.jsp");
                        break;
                    default:
                        response.sendRedirect("index.jsp?error=rolInvalido");
                        break;
                }
            } else {
                response.sendRedirect("index.jsp?error=datosIncorrectos");
            }
        } else if ("logout".equals(accion)) {
            HttpSession session = request.getSession();
            session.invalidate();
            response.sendRedirect("index.jsp");
        }
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
