package ListadoProductosCU;

import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import logica.Fabrica;
import logica.Interfaces.IControladorProducto;
import logica.Clases.Producto;

@WebServlet(urlPatterns = {"/listadoProductos"})
public class ListarProductosServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            // Obtenemos la instancia del controlador de productos
            IControladorProducto controladorProducto = Fabrica.getInstance().getIControladorProducto();
            List<Producto> productos = controladorProducto.listarProductosActivos();

            // Guardamos el listado de productos en el request
            request.setAttribute("productos", productos);

            // Redirigimos a la página JSP para mostrar el listado
            request.getRequestDispatcher("Vistas/listadoProductos.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Error al obtener los productos.");
            request.getRequestDispatcher("Vistas/listadoProductos.jsp").forward(request, response);
        }
    }

    @Override
    public String getServletInfo() {
        return "Servlet que maneja la gestión de productos.";
    }
}
