/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */

import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import logica.Clases.DetallePedido;

/**
 *
 * @author Mateo
 */
@WebServlet(urlPatterns = {"/verCarrito"})
public class verCarrito extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();

        // Obtener el carrito de la sesión
        ArrayList<DetallePedido> carrito = (ArrayList<DetallePedido>) session.getAttribute("carrito");

        // Comprobar si hay una solicitud de eliminar un producto
        String eliminarIndexStr = request.getParameter("eliminarIndex");
        if (eliminarIndexStr != null) {
            try {
                int eliminarIndex = Integer.parseInt(eliminarIndexStr);
                if (carrito != null && eliminarIndex >= 0 && eliminarIndex < carrito.size()) {
                    carrito.remove(eliminarIndex); // Eliminar el producto del carrito
                }
            } catch (NumberFormatException e) {
                // Manejar el caso de que el índice no sea un número válido (opcional)
            }
        }
        
        // Pasar el carrito a la vista JSP
        request.setAttribute("carrito", carrito);

        // Redirigir a la vista del carrito
        request.getRequestDispatcher("Vistas/verCarrito.jsp").forward(request, response);
    }

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /**
     * Handles the HTTP <code>GET</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    /**
     * Handles the HTTP <code>POST</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
