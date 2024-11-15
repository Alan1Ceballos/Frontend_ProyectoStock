import logica.Clases.Producto;
import logica.servicios.ProductoServicios;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/BuscarProducto")
public class BuscarProductoServlet extends HttpServlet {
    private ProductoServicios productoServicios;

    @Override
    public void init() {
        productoServicios = new ProductoServicios(); // Inicializa tu servicio aquí
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String nombre = request.getParameter("nombre");
        String sku = request.getParameter("sku");
        Producto productos = null;

        // Verificar si se ha realizado una búsqueda válida
        if (nombre != null && !nombre.isEmpty()) {
            productos = productoServicios.buscarProductoPorNombre(nombre);
        } else if (sku != null && !sku.isEmpty()) {
            productos = productoServicios.buscarProductoPorSKU(sku);
        }

        // Si no se encontró el producto, no hacer el forward, sólo mostrar un mensaje de error
        if (productos == null) {
            request.setAttribute("error", "No se encontró el producto.");
            request.getRequestDispatcher("Vistas/crearPedido.jsp").forward(request, response);
        } else {
            // Si el producto se encontró, lo agregamos a los atributos de la solicitud
            request.setAttribute("producto", productos);
            // Redirigir a la página donde se muestra el resultado
            //request.getRequestDispatcher("Vistas/crearPedido.jsp").forward(request, response);
        }
    }
}
