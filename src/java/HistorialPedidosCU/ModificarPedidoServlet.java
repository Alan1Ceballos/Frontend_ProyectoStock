package HistorialPedidosCU;

import Persistencia.ConexionAPI;
import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.List;

@WebServlet("/modificarPedido")
public class ModificarPedidoServlet extends HttpServlet {

    private int pedidoId;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            // Obtener el idPedido de la solicitud
            int idPedido = Integer.parseInt(request.getParameter("idPedido"));
            this.pedidoId = idPedido;

            // Obtener los datos del pedido utilizando la API
            String pathPedido = "/pedidos/buscar/" + idPedido;
            JsonObject pedido = ConexionAPI.getRequestObj(pathPedido).getAsJsonObject();

            // Obtener las categorías utilizando la API
            String pathCategorias = "/categorias/";
            JsonArray categorias = ConexionAPI.getRequest(pathCategorias).getAsJsonArray();

            // Obtener los productos utilizando la API
            String pathProductos = "/productos/";
            JsonArray productos = ConexionAPI.getRequest(pathProductos).getAsJsonArray();

            // Obtener los detalles utilizando la API
            String pathDetalles = "/pedidos/" + idPedido + "/detalles";
            JsonArray detalles = ConexionAPI.getRequest(pathDetalles).getAsJsonArray();

            // Extraer los datos del pedido desde el objeto JSON
            String fechaPedido = pedido.get("fechaPedido").getAsString();
            String estado = pedido.get("estado").getAsString();
            float total = pedido.get("total").getAsFloat();
            int idVendedor = pedido.get("idVendedor").getAsInt();
            int idCliente = pedido.get("idCliente").getAsInt();

            // Crear un array con la información del pedido
            Object[] pedidoInfo = {fechaPedido, estado, total, idVendedor, idCliente};

            // Pasar los datos al JSP
            request.setAttribute("idPedido", idPedido);
            request.setAttribute("pedido", pedido);
            request.setAttribute("detalles", detalles);
            request.setAttribute("categorias", categorias);
            request.setAttribute("productos", productos);
            request.setAttribute("pedidoInfo", pedidoInfo);

            // Redirigir al JSP
            request.getRequestDispatcher("/Vistas/modificarPedido.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error al obtener los datos del pedido.");
        }
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            // Obtener y convertir parámetros obligatorios
            int idPedido = Integer.parseInt(request.getParameter("idPedido"));
            String estadoPedido = request.getParameter("estadoPedido");
            int idVendedor = Integer.parseInt(request.getParameter("idVendedor"));
            int idCliente = Integer.parseInt(request.getParameter("idCliente"));

            // Validar y capturar el total del pedido
            String totalPedidoStr = request.getParameter("totalPedido");
            float totalPedido = 0.0f; // Inicializa en 0.0f

            if (totalPedidoStr != null && !totalPedidoStr.isEmpty()) {
                totalPedido = Float.parseFloat(totalPedidoStr);
            }

            String[] idsProducto = request.getParameterValues("idProducto[]");
            String[] cantidadesProducto = request.getParameterValues("cantidadProducto[]");
            String[] preciosVenta = request.getParameterValues("precioVenta[]");

            // Verificar la longitud de los arrays
            if (idsProducto.length != cantidadesProducto.length || cantidadesProducto.length != preciosVenta.length) {
                throw new IllegalArgumentException("Error: Los arrays de productos, cantidades y precios no tienen la misma longitud.");
            }

            // Crear un nuevo objeto PedidoRequest que será enviado al endpoint
            JsonObject pedidoRequest = new JsonObject();
            pedidoRequest.addProperty("idPedido", idPedido);
            pedidoRequest.addProperty("estadoPedido", estadoPedido);
            pedidoRequest.addProperty("idVendedor", idVendedor);
            pedidoRequest.addProperty("idCliente", idCliente);
            pedidoRequest.addProperty("totalPedido", totalPedido);

            // Añadir directamente los arrays al JSON
            pedidoRequest.add("idsProducto", JsonParser.parseString(new Gson().toJson(idsProducto)));
            pedidoRequest.add("cantidadesProducto", JsonParser.parseString(new Gson().toJson(cantidadesProducto)));
            pedidoRequest.add("preciosVenta", JsonParser.parseString(new Gson().toJson(preciosVenta)));

            // Llamar al endpoint que maneja la actualización del pedido
            String pathActualizarPedido = "/pedidos/actualizar";  // La ruta del endpoint
            JsonObject responseApi = ConexionAPI.postRequest(pathActualizarPedido, pedidoRequest);

            // Verificar si la respuesta es HTTP_OK (código 200)
            if (responseApi != null && responseApi.get("statusCode").getAsInt() == 200) {
                // Si el código es 200, considerar la operación como exitosa
                // Redirigir a la página de historial de pedidos
                response.sendRedirect(request.getContextPath() + "/historialpedidos");
            } else {
                // Si la respuesta no es exitosa, obtener el mensaje de error
                String errorMessage = responseApi.has("error") ? responseApi.get("error").getAsString() : "Error desconocido";
                System.out.println("Error al modificar el pedido: " + errorMessage);
                request.setAttribute("mensaje", "Error al modificar el pedido: " + errorMessage);
                request.getRequestDispatcher("/errorPage.jsp").forward(request, response);
            }

        } catch (NumberFormatException e) {
            // Captura errores de formato de número
            request.setAttribute("mensaje", "Error: Formato de número incorrecto.");
            request.getRequestDispatcher("/errorPage.jsp").forward(request, response);
        } catch (IllegalArgumentException e) {
            // Captura errores relacionados con valores incorrectos del estado del pedido
            request.setAttribute("mensaje", "Error: Estado de pedido no válido.");
            request.getRequestDispatcher("/errorPage.jsp").forward(request, response);
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/historialpedidos");
        }
    }

}
