/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */

import java.io.IOException;
import java.util.ArrayList;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import logica.Clases.Categoria;
import logica.Clases.Cliente;
import logica.Clases.DetallePedido;
import logica.Clases.Producto;
import logica.Fabrica;
import logica.Interfaces.IControladorCategoria;
import logica.Interfaces.IControladorCliente;
import logica.Interfaces.IControladorProducto;

/**
 *
 * @author Mateo
 */
@WebServlet(urlPatterns = {"/crearPedido"})
public class CrearPedidoServlet extends HttpServlet {

    Fabrica fabrica = Fabrica.getInstance();
    IControladorCliente controladorCliente = fabrica.getIControladorCliente();
    IControladorProducto controladorProducto = fabrica.getIControladorProducto();
    IControladorCategoria controladorCategoria = fabrica.getIControladorCategoria();

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Crear una instancia para obtener los clientes y servicios
        ArrayList<Cliente> listaDeClientes = controladorCliente.listarClientes();
        ArrayList<Producto> listaDeProductos = controladorProducto.listarProductosActivos();
        
        // Obtener las categorías activas
        ArrayList<Categoria> listaDeCategorias = controladorCategoria.listarCategoriasActivas();

        // Aquí llamamos a la función para obtener el ID del cliente por nombre
        ArrayList<Integer> idsClientes = new ArrayList<>();
        for (Cliente cliente : listaDeClientes) {
            int idCliente = controladorCliente.obtenerIdClientePorNombre(cliente.getNom_empresa());
            idsClientes.add(idCliente);
        }
        
        // Pasar la lista de clientes al JSP
        request.setAttribute("clientes", listaDeClientes);
        request.setAttribute("idsClientes", idsClientes);
        request.setAttribute("productos", listaDeProductos);
        
        // Pasar la lista de categorías al JSP
        request.setAttribute("categorias", listaDeCategorias);

        // Redirigir al JSP para mostrar el formulario
        request.getRequestDispatcher("Vistas/crearPedido.jsp").forward(request, response);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Obtener la cantidad del formulario
        String cantidadStr = request.getParameter("cantidad");

        int cantidad = 1; // Valor predeterminado
        if (cantidadStr != null && !cantidadStr.isEmpty()) {
            cantidad = Integer.parseInt(cantidadStr); 
        }

        // Obtener el cliente y los productos seleccionados
        String clienteId = request.getParameter("cliente");
        String[] productosSeleccionados = request.getParameterValues("productos[]");

        // Obtener el carrito de la sesión, o crear uno nuevo si no existe
        HttpSession session = request.getSession();
        ArrayList<DetallePedido> carrito = (ArrayList<DetallePedido>) session.getAttribute("carrito");
        if (carrito == null) {
            carrito = new ArrayList<>(); 
        }

        // Añadir los productos seleccionados al carrito
        if (productosSeleccionados != null) {
            for (String productoId : productosSeleccionados) {
                Producto producto = controladorProducto.buscarProducto(Integer.parseInt(productoId));

                // Crear un DetallePedido con el producto y la cantidad
                DetallePedido detalle = new DetallePedido(cantidad, producto.getPrecioVenta(), producto, 0);

                // Añadir al carrito
                carrito.add(detalle);
            }
        }

        // Guardar el carrito actualizado en la sesión
        session.setAttribute("carrito", carrito);

         // Responder al cliente sin redirigir, devolviendo un mensaje de éxito
        response.setContentType("application/json");
        response.getWriter().write("{\"status\":\"success\",\"message\":\"Producto añadido al carrito\"}");
    }

    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
