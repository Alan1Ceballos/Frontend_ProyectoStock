package GenerarInformeCU;

import Persistencia.ConexionAPI;
import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.google.gson.JsonArray;
import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet(urlPatterns = {"/verInforme"})
public class VerInformeServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        Integer idVendedor = (Integer) session.getAttribute("idVendedor");

        if (idVendedor != null) {
            String mesParam = request.getParameter("mes");
            String anioParam = request.getParameter("anio");
            String nombreCliente = request.getParameter("nombreCliente");
            String nombreCategoria = request.getParameter("nombreCategoria");

            try {
                int mes = Integer.parseInt(mesParam);
                int anio = Integer.parseInt(anioParam);

                // Construir la URL del endpoint
                StringBuilder pathBuilder = new StringBuilder("/ventas/informe/"); // Ruta del endpoint "ventas"
                pathBuilder.append(idVendedor)
                        .append("?mes=").append(mes)
                        .append("&anio=").append(anio);

                if (nombreCliente != null && !nombreCliente.isEmpty()) {
                    pathBuilder.append("&nombreCliente=").append(nombreCliente);
                }
                if (nombreCategoria != null && !nombreCategoria.isEmpty()) {
                    pathBuilder.append("&nombreCategoria=").append(nombreCategoria);
                }

                // Realizar la solicitud GET
                String jsonResponse = ConexionAPI.getRequestAsString(pathBuilder.toString());  // Esta es la respuesta JSON como String

                // Si la respuesta es un JsonArray, conviértelo a un JsonObject
                JsonObject informeJson = new Gson().fromJson(jsonResponse, JsonObject.class);

                // Asegúrate de que los arrays existen en el JSON antes de obtenerlos
                JsonArray pedidosJson = informeJson.has("pedidos") ? informeJson.getAsJsonArray("pedidos") : new JsonArray();
                JsonArray detallesJson = informeJson.has("detalles") ? informeJson.getAsJsonArray("detalles") : new JsonArray();

                // Enviar los datos al JSP
                request.setAttribute("pedidos", pedidosJson);
                request.setAttribute("detalles", detallesJson);
                request.setAttribute("mes", mes);
                request.setAttribute("anio", anio);
                request.setAttribute("nombreCliente", nombreCliente);
                request.setAttribute("nombreCategoria", nombreCategoria);

                // Redirigir a la vista JSP
                RequestDispatcher dispatcher = request.getRequestDispatcher("Vistas/verInforme.jsp");
                dispatcher.forward(request, response);
            } catch (NumberFormatException e) {
                request.setAttribute("error", "Mes y año deben ser números válidos.");
                RequestDispatcher dispatcher = request.getRequestDispatcher("Vistas/verInforme.jsp");
                dispatcher.forward(request, response);
            } catch (Exception e) {
                e.printStackTrace();  // Esto imprimirá el stack trace completo
                request.setAttribute("error", "Error al obtener el informe: " + e.getMessage());
                RequestDispatcher dispatcher = request.getRequestDispatcher("Vistas/verInforme.jsp");
                dispatcher.forward(request, response);
            }

        } else {
            // Si no hay sesión activa, redirigir al login
            response.sendRedirect("Login.jsp");
        }
    }
}
