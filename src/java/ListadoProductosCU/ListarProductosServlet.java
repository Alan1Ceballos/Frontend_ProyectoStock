package ListadoProductosCU;

import Persistencia.ConexionAPI;
import com.google.gson.JsonArray;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(urlPatterns = {"/listadoProductos"})
public class ListarProductosServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            //obtenemos el listado de productos desde el API
            JsonArray productos = ConexionAPI.getRequest("/productos/");

            //guardamos el listado de productos en el request
            request.setAttribute("productos", productos);

            //redirigmos a la página JSP para mostrar el listado
            request.getRequestDispatcher("Vistas/listadoProductos.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Error al obtener los productos.");
            request.getRequestDispatcher("Vistas/listadoProductos.jsp").forward(request, response);
        }
    }

    @Override
    public String getServletInfo() {
        return "Servlet que maneja la gestión de productos.";
    }
}