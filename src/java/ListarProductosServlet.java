
import logica.servicios.CategoriaServicios;
import logica.servicios.ProductoServicios;
import java.io.IOException;
import java.util.ArrayList;
import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import logica.Clases.Categoria;
import logica.Clases.Producto;

@WebServlet(urlPatterns = {"/listarProductos"})
public class ListarProductosServlet extends HttpServlet {

    private CategoriaServicios categoriaServicios = new CategoriaServicios();
    private ProductoServicios productoServicios = new ProductoServicios();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Obtener todas las categorías
        ArrayList<Categoria> categorias = categoriaServicios.listarCategorias();
        request.setAttribute("categorias", categorias);

        // Obtener el nombre de la categoría seleccionada
        String nombreCategoria = request.getParameter("nombreCategoria");
        System.out.println("Categoría seleccionada: " + nombreCategoria); // Debug

        // Listar productos dependiendo de la categoría seleccionada
        ArrayList<Producto> productos = new ArrayList<>();
        if (nombreCategoria != null && !nombreCategoria.isEmpty()) {
            if ("Todos".equals(nombreCategoria)) {
                // Si se selecciona "Todos", se obtienen todos los productos
                productos = productoServicios.listarProductos(); // Método para listar todos los productos
                System.out.println("Número total de productos encontrados: " + productos.size()); // Debug
            } else {
                // Listar productos por el nombre de la categoría
                productos = productoServicios.listarProductosPorCategoria(nombreCategoria);
                System.out.println("Número de productos encontrados para la categoría '" + nombreCategoria + "': " + productos.size()); // Debug
            }
        }

        request.setAttribute("productos", productos);
        request.setAttribute("nombreCategoriaSeleccionada", nombreCategoria);

        // Redirigir a la vista
        RequestDispatcher dispatcher = request.getRequestDispatcher("Vistas/listarProductos.jsp");
        dispatcher.forward(request, response);
    }
}
