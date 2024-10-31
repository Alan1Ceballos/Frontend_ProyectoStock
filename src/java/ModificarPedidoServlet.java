import logica.Clases.Pedido;
import logica.Clases.DetallePedido;
import logica.Clases.Producto;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.HashMap;
import logica.servicios.DetallePedidoServicios;
import logica.servicios.PedidosServicios;
import logica.servicios.ProductoServicios;

@WebServlet("/modificarPedido")
public class ModificarPedidoServlet extends HttpServlet {

    private PedidosServicios pedidoServicios = new PedidosServicios();
    private DetallePedidoServicios detallesPedidos = new DetallePedidoServicios();
    private ProductoServicios productosDetalles = new ProductoServicios();

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            // Obtener y convertir parámetros obligatorios
            int idPedido = Integer.parseInt(request.getParameter("idPedido"));
            Pedido.Estado estadoPedido = Pedido.Estado.valueOf(request.getParameter("estadoPedido"));
            int idVendedor = Integer.parseInt(request.getParameter("idVendedor"));
            int idCliente = Integer.parseInt(request.getParameter("idCliente"));
            String fechaPedidoString = request.getParameter("fechaPedido"); // formato esperado: yyyy-MM-dd

// Conversión
            SimpleDateFormat formato = new SimpleDateFormat("yyyy-MM-dd");
            java.util.Date fechaUtil = formato.parse(fechaPedidoString); // Convierte a java.util.Date
            Date fechaPedido = new Date(fechaUtil.getTime()); // Convierte a java.sql.Date

            // Validar y capturar totalPedido
            String totalPedidoStr = request.getParameter("totalPedido");
            float totalPedido = 0.0f; // Inicializa en 0.0f

            if (totalPedidoStr != null && !totalPedidoStr.isEmpty()) {
                totalPedido = Float.parseFloat(totalPedidoStr);
            }

            // Validación de arrays
            String[] idsProducto = request.getParameterValues("idProducto[]");
            String[] cantidadesProducto = request.getParameterValues("cantidadProducto[]");
            String[] preciosVenta = request.getParameterValues("precioVenta[]");

            Pedido pedido = new Pedido(idPedido, fechaPedido, estadoPedido, totalPedido, idVendedor, idCliente);
            List<DetallePedido> detalles = new ArrayList<>();

            // Comprobación de longitud de arrays
            if (idsProducto != null && cantidadesProducto != null && preciosVenta != null) {
                for (int i = 0; i < idsProducto.length; i++) {
                    if (idsProducto[i] != null && !idsProducto[i].trim().isEmpty()
                            && cantidadesProducto[i] != null && !cantidadesProducto[i].trim().isEmpty()
                            && preciosVenta[i] != null && !preciosVenta[i].trim().isEmpty()) {

                        int idProducto = Integer.parseInt(idsProducto[i].trim());
                        int cantidad = Integer.parseInt(cantidadesProducto[i].trim());
                        float precioVenta = Float.parseFloat(preciosVenta[i].trim());

                        Producto producto = productosDetalles.buscarProducto(idProducto);
                        detalles.add(new DetallePedido(cantidad, precioVenta, producto, pedido.getIdentificador()));
                    }
                }
            } else {
                System.out.println("Error: Arrays de productos o cantidades son nulos.");
            }

            // Actualizar el pedido
            boolean resultadoPedido = pedidoServicios.actualizarPedido(pedido);
            boolean resultadoDetalles = detallesPedidos.actualizarDetallesPedido(pedido.getIdentificador(), detalles);

            if (resultadoPedido && resultadoDetalles) {
                // La actualización fue exitosa
                System.out.println("Pedido y detalles actualizados correctamente.");
            } else {
                System.out.println("Error al actualizar el pedido o los detalles.");
            }

        } catch (NumberFormatException e) {
            System.out.println("Error: Formato de número incorrecto - " + e.getMessage());
            request.setAttribute("mensaje", "Error: Formato de número incorrecto.");
        } catch (IllegalArgumentException e) {
            System.out.println("Error: Valor del estado no válido - " + e.getMessage());
            request.setAttribute("mensaje", "Error: Estado de pedido no válido.");
        } catch (Exception e) {
            System.out.println("Error general al modificar el pedido: " + e.getMessage());
            request.setAttribute("mensaje", "Error al modificar el pedido: " + e.getMessage());
        }

        // Redirigir a la página de historial de pedidos
        response.sendRedirect(request.getContextPath() + "/historialpedidos");
    }
}