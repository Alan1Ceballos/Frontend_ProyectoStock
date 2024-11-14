package ListadoClientesCU;

import Persistencia.ConexionAPI;
import com.google.gson.JsonArray;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(urlPatterns = {"/clientes"})
public class ClientesServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            //obtenemos el listado de clientes desde el API
            JsonArray clientes = ConexionAPI.getRequest("/clientes/");

            //guardamos el listado de clientes en el request
            request.setAttribute("clientes", clientes);

            //redirigimos a la página JSP para mostrar el listado
            request.getRequestDispatcher("Vistas/listadoClientes.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Error al obtener los clientes.");
            request.getRequestDispatcher("Vistas/listadoClientes.jsp").forward(request, response);
        }
    }

    @Override
    public String getServletInfo() {
        return "Servlet que maneja la gestión de clientes.";
    }
}
