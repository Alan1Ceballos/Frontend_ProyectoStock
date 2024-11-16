package CrearPedidoCU;

/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
import Persistencia.ConexionAPI;
import com.google.gson.JsonArray;
import logica.Clases.Producto;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 *
 * @author Mateo
 */
@WebServlet(urlPatterns = {"/crearPedido"})
public class CrearPedidoServlet extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            JsonArray clientesResponse = ConexionAPI.getRequest("/clientes/");
            JsonArray productosResponse = ConexionAPI.getRequest("/productos/");
            JsonArray categoriasResponse = ConexionAPI.getRequest("/categorias/");

            // Pasar las respuestas JsonObject al JSP
            request.setAttribute("clientes", clientesResponse);
            request.setAttribute("productos", productosResponse);
            request.setAttribute("categorias", categoriasResponse);

            // Redirigir al JSP para mostrar el formulario
            request.getRequestDispatcher("Vistas/crearPedido.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            // Manejar el error si ocurre alguno durante las solicitudes
            request.setAttribute("errorMessage", "Hubo un error al cargar los datos.");
            request.getRequestDispatcher("Vistas/error.jsp").forward(request, response);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
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