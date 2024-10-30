/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */

import com.google.gson.JsonObject;
import java.io.BufferedReader;
import java.io.IOException;
import java.util.ArrayList;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import logica.Clases.DetallePedido;
import logica.Clases.Pedido;
import logica.Clases.Producto;
import logica.Fabrica;
import logica.Interfaces.IControladorPedido;
import org.json.JSONArray;
import org.json.JSONObject;

/**
 *
 * @author Mateo
 */
@WebServlet(urlPatterns = {"/verCarrito"})
public class verCarritoServlet extends HttpServlet {

    IControladorPedido controladorPedido = Fabrica.getInstance().getIControladorPedido();

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();

        // Obtener el carrito de la sesión
        ArrayList<DetallePedido> carrito = (ArrayList<DetallePedido>) session.getAttribute("carrito");
        if (carrito == null) {
            carrito = new ArrayList<>();
            session.setAttribute("carrito", carrito);
        }

        // Comprobar si hay una solicitud de eliminar un producto
        String eliminarIndexStr = request.getParameter("eliminarIndex");
        if (eliminarIndexStr != null) {
            try {
                int eliminarIndex = Integer.parseInt(eliminarIndexStr);
                if (eliminarIndex >= 0 && eliminarIndex < carrito.size()) {
                    carrito.remove(eliminarIndex); // Eliminar el producto del carrito
                }
            } catch (NumberFormatException e) {
                // Manejar el caso de que el índice no sea un número válido
            }
        }

        // Verificar si la solicitud es para confirmar el pedido
        String confirmarPedido = request.getParameter("confirmarPedido");
        if (confirmarPedido != null && confirmarPedido.equals("true")) {
            confirmarYGuardarPedido(session, request, response);
            return;
        }

        // Pasar el carrito a la vista JSP
        request.setAttribute("carrito", carrito);
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

            JSONObject jsonObject = new JSONObject(jsonBuffer.toString());
            int idCliente = jsonObject.getInt("clienteId");
            JSONArray carritoArray = jsonObject.getJSONArray("carrito");

            if (carritoArray.length() == 0) {
                response.getWriter().write("El carrito está vacío. Añade productos antes de confirmar.");
                return;
            }
            
            int idVendedor = (int) session.getAttribute("idVendedor");

            Pedido nuevoPedido = new Pedido();
            nuevoPedido.setFechaPedido(new java.util.Date());
            nuevoPedido.setEstado(Pedido.Estado.EN_PREPARACION);
            nuevoPedido.setIdVendedor(idVendedor);
            nuevoPedido.setIdCliente(idCliente);

            for (int i = 0; i < carritoArray.length(); i++) {
                JSONObject detalleObj = carritoArray.getJSONObject(i);
                Producto producto = new Producto();
                producto.setId(detalleObj.getInt("id"));

                DetallePedido detalle = new DetallePedido();
                detalle.setProducto(producto);
                detalle.setCantidad(detalleObj.getInt("quantity"));
                detalle.setPrecioVenta((float) detalleObj.getDouble("price"));

                nuevoPedido.agregarDetalle(detalle);
            }

            boolean resultado = controladorPedido.agregarPedido(nuevoPedido);
            if (resultado) {
                response.getWriter().write("Pedido añadido exitosamente.");
                session.removeAttribute("carrito");
            } else {
                response.getWriter().write("Error al añadir el pedido. Inténtelo de nuevo.");
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
        return "Short description";
    }
}