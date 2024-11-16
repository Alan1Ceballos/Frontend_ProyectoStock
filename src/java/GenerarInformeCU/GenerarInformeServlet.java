package GenerarInformeCU;

import Persistencia.ConexionAPI;
import com.google.gson.JsonArray;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(urlPatterns = {"/generarInforme"})
public class GenerarInformeServlet extends HttpServlet {
   @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            // Realizar solicitud GET para obtener categorías
            JsonArray categorias = ConexionAPI.getRequest("/categorias/");

            // Realizar solicitud GET para obtener clientes
            JsonArray clientes = ConexionAPI.getRequest("/clientes/");

            // Agregar los resultados a la solicitud
            request.setAttribute("categorias", categorias);
            request.setAttribute("clientes", clientes);

            // Redirigir a la vista JSP
            request.getRequestDispatcher("Vistas/generarInforme.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Hubo un error al obtener los datos: " + e.getMessage());
            request.getRequestDispatcher("Vistas/error.jsp").forward(request, response);
        }
    }
}
