package CrearPedidoCU;

/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */

import Persistencia.ConexionAPI;
import com.google.gson.JsonObject;
import java.io.BufferedReader;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import org.json.JSONArray;
import org.json.JSONObject;

/**
 *
 * @author Mateo
 */
@WebServlet(urlPatterns = {"/verCarrito"})
public class verCarritoServlet extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();

        // Obtener el carrito de la sesión (como JSON)
        JSONArray carrito = (JSONArray) session.getAttribute("carrito");
        if (carrito == null) {
            carrito = new JSONArray();
            session.setAttribute("carrito", carrito);
        }

        // Comprobar si hay una solicitud de eliminar un producto
        String eliminarIndexStr = request.getParameter("eliminarIndex");
        if (eliminarIndexStr != null) {
            try {
                int eliminarIndex = Integer.parseInt(eliminarIndexStr);
                if (eliminarIndex >= 0 && eliminarIndex < carrito.length()) {
                    carrito.remove(eliminarIndex); // Eliminar el producto del carrito
                }
            } catch (NumberFormatException e) {
                response.getWriter().write("Índice de eliminación inválido.");
                return;
            }
        }

        // Verificar si la solicitud es para confirmar el pedido
        String confirmarPedido = request.getParameter("confirmarPedido");
        if (confirmarPedido != null && confirmarPedido.equals("true")) {
            confirmarYGuardarPedido(session, request, response);
            return;
        }

        // Pasar el carrito a la vista JSP como JSON
        request.setAttribute("carrito", carrito.toString());
        request.getRequestDispatcher("Vistas/verCarrito.jsp").forward(request, response);
    }

    private void confirmarYGuardarPedido(HttpSession session, HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        try {
            StringBuilder jsonBuffer = new StringBuilder();
            BufferedReader reader = request.getReader();
            String line;
            while ((line = reader.readLine()) != null) {
                jsonBuffer.append(line);
            }

            // Procesar el cuerpo JSON de la solicitud
            JSONObject jsonObject = new JSONObject(jsonBuffer.toString());
            String clienteId = jsonObject.getString("clienteId");
            JSONArray carritoArray = jsonObject.getJSONArray("carrito");

            if (carritoArray.length() == 0) {
                response.getWriter().write("El carrito está vacío. Añade productos antes de confirmar.");
                return;
            }

            // Crear el objeto JSON para el cuerpo de la solicitud POST
            JSONObject jsonPedido = new JSONObject();
            jsonPedido.put("clienteId", clienteId);
            jsonPedido.put("carrito", carritoArray);

            // Hacer la solicitud POST al API REST
            JsonObject result = ConexionAPI.postRequestCarrito("/carrito/confirmarPedido", jsonPedido);

            // Procesar la respuesta del API
            if (result != null && result.has("message")) {
                String mensaje = result.get("message").getAsString();
                response.getWriter().write(mensaje);
                if (mensaje.equals("Pedido añadido exitosamente.")) {
                    session.removeAttribute("carrito"); // Limpiar el carrito
                }
            } else {
                response.getWriter().write("Error al confirmar el pedido.");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("Ocurrió un error al confirmar el pedido: " + e.getMessage());
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    public String getServletInfo() {
        return "Servlet para gestionar el carrito de compras y la confirmación de pedidos";
    }
}
