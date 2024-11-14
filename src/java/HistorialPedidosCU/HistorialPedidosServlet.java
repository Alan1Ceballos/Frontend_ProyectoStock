package HistorialPedidosCU;

import Persistencia.ConexionAPI;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet(urlPatterns = {"/historialpedidos"})
public class HistorialPedidosServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        Integer idVendedor = (Integer) (session != null ? session.getAttribute("idVendedor") : null);

        //redirige al login si no hay un vendedor en sesión
        if (idVendedor == null) {
            response.sendRedirect("Login.jsp");
            return;
        }

        try {
            //llama al servicio REST para obtener los pedidos del vendedor
            JsonArray pedidosVendedor = ConexionAPI.getRequest("/pedidos/vendedor/" + idVendedor);

            //paca cada pedido, obtenemos los detalles y los agregamos al pedido correspondiente
            for (int i = 0; i < pedidosVendedor.size(); i++) {
                JsonObject pedido = pedidosVendedor.get(i).getAsJsonObject();
                int idPedido = pedido.get("identificador").getAsInt();
                
                //obtener los detalles del pedido y añadirlos al objeto JsonObject del pedido
                JsonArray detalles = ConexionAPI.getRequest("/pedidos/" + idPedido + "/detalles");
                pedido.add("detalles", detalles);
            }

            //guarda el listado de pedidos en el request
            request.setAttribute("pedidos", pedidosVendedor);
            RequestDispatcher dispatcher = request.getRequestDispatcher("Vistas/historialPedidos.jsp");
            dispatcher.forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Error al obtener el historial de pedidos.");
            request.getRequestDispatcher("Vistas/historialPedidos.jsp").forward(request, response);
        }
    }

    @Override
    public String getServletInfo() {
        return "Servlet que maneja el historial de pedidos usando JsonArray.";
    }
}
