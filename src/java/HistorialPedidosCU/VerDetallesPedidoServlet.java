package HistorialPedidosCU;

import Persistencia.ConexionAPI;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "VerDetallesPedidoServlet", urlPatterns = {"/verdetalles"})
public class VerDetallesPedidoServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            //obtenemos el ID del pedido desde la solicitud
            int idPedido = Integer.parseInt(request.getParameter("idPedido"));

            //realizamos la llamada al web service para obtener los detalles del pedido
            JsonArray detalles = ConexionAPI.getRequest("/pedidos/" + idPedido + "/detalles");

            //obtenemos la información básica del pedido
            JsonObject pedido = ConexionAPI.getRequest("/pedidos/" + idPedido).get(0).getAsJsonObject();

            //almacenamos los datos en el request para la JSP
            request.setAttribute("pedido", pedido);
            request.setAttribute("detalles", detalles);

            //redirigimos a la página de detalles del pedido
            request.getRequestDispatcher("/Vistas/verDetallesPedido.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID de pedido inválido.");
        } catch (Exception e) {
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Ocurrió un error al procesar el pedido.");
            e.printStackTrace();
        }
    }
}
