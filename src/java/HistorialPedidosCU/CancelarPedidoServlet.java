package HistorialPedidosCU;

import Persistencia.ConexionAPI;
import com.google.gson.JsonObject;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/cancelarPedido")
public class CancelarPedidoServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Obtener el ID del pedido desde el formulario
        int idPedido = Integer.parseInt(request.getParameter("idPedido"));

        try {
            // Crear el cuerpo de la solicitud (vacío, ya que solo estamos pasando el ID en la URL)
            JsonObject responseJson = ConexionAPI.postRequest("/pedidos/cancelar/" + idPedido, new JsonObject());

            // Verificamos la respuesta y redirigimos con el mensaje adecuado
            if (responseJson != null && responseJson.has("mensaje")) {
                String mensaje = responseJson.get("mensaje").getAsString();
                request.setAttribute("mensaje", mensaje);
            } else {
                request.setAttribute("mensaje", "No se pudo obtener una respuesta válida.");
            }

        } catch (Exception e) {
            // Si ocurre algún error en la comunicación con el servicio REST
            request.setAttribute("mensaje", "Error al cancelar el pedido: " + e.getMessage());
        }

        // Redirigir al historial de pedidos
        response.sendRedirect(request.getContextPath() + "/historialpedidos");
    }
}
