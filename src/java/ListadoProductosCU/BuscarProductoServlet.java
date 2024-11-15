package ListadoProductosCU;

import com.google.gson.Gson;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import logica.Clases.Producto;
import logica.servicios.ProductoServicios;

/**
 *
 * @author bande
 */
@WebServlet("/buscarProducto")
public class BuscarProductoServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String sku = request.getParameter("sku");
        String nombre = request.getParameter("nombre");
        String clienteId = request.getParameter("clienteId");  // Obtener clienteId desde los parámetros

        // Lógica de búsqueda de productos
        ProductoServicios productoServicios = new ProductoServicios();
        ArrayList<Producto> productos = new ArrayList<>();

        // Si se pasa el sku, se busca por sku
        if (sku != null && !sku.isEmpty()) {
            Producto producto = productoServicios.buscarProductoPorSKU(sku);
            if (producto != null) {
                productos.add(producto);
            }
        }
        
        // Si se pasa el nombre, se busca por nombre
        if (nombre != null && !nombre.isEmpty()) {
            Producto producto = productoServicios.buscarProductoPorNombre(nombre);
            if (producto != null) {
                productos.add(producto);
            }
        }

        // Convertir los productos a formato JSON
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        // Crear un objeto JSON para cada producto
        Gson gson = new Gson();
        out.print(gson.toJson(productos));
        out.flush();
    }
}
