package GenerarInformeCU;

/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import logica.Clases.DetallePedido;
import logica.Clases.Pedido;
import logica.Clases.Proveedor;

import logica.Fabrica;
import logica.Interfaces.IControladorCategoria;
import logica.Interfaces.IControladorCliente;
import logica.Interfaces.IControladorDetallePedido;
import logica.Interfaces.IControladorPedido;
import logica.Interfaces.IControladorProducto;
import logica.Interfaces.IControladorProveedor;

/**
 *
 * @author AlanCeballos
 */
@WebServlet(urlPatterns = {"/verInforme"})
public class VerInformeServlet extends HttpServlet {

    private IControladorPedido ICP = Fabrica.getInstance().getIControladorPedido();
    private IControladorProducto ICPr = Fabrica.getInstance().getIControladorProducto();
    private IControladorProveedor ICPro = Fabrica.getInstance().getIControladorProveedor();
    private IControladorDetallePedido ICDP = Fabrica.getInstance().getIControladorDetallePedido();
    private IControladorCliente ICC = Fabrica.getInstance().getIControladorCliente();
    private IControladorCategoria ICCat = Fabrica.getInstance().getIControladorCategoria();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        Integer idVendedor = (Integer) session.getAttribute("idVendedor");

        if (idVendedor != null) {
            String nombreCliente = request.getParameter("nombreCliente");
            String nombreCategoria = request.getParameter("nombreCategoria");

            try {
                int mes = Integer.parseInt(request.getParameter("mes"));
                int anio = Integer.parseInt(request.getParameter("anio"));

                Integer clienteId = null;
                Integer categoriaId = null;

                if (nombreCliente != null && !nombreCliente.isEmpty()) {
                    clienteId = this.ICC.obtenerIdPorNombre(nombreCliente);
                }

                if (nombreCategoria != null && !nombreCategoria.isEmpty()) {
                    categoriaId = this.ICCat.obtenerIdPorNombre(nombreCategoria);
                }

                List<Pedido> pedidosVendedor;
                if (clienteId != null && categoriaId != null) {
                    // Filter by month, year, customer, and category
                    pedidosVendedor = this.ICP.getPedidosPorVendedorTodos(idVendedor, mes, anio, categoriaId, clienteId);
                } else if (clienteId != null) {
                    // Filter by month, year, and customer
                    pedidosVendedor = this.ICP.getPedidosPorVendedorClienteYFecha(idVendedor, mes, anio, clienteId);
                } else if (categoriaId != null) {
                    // Filter by month, year, and category
                    pedidosVendedor = this.ICP.getPedidosPorVendedorCategoriaYFecha(idVendedor, mes, anio, categoriaId);
                } else {
                    // Filter by month and year only
                    pedidosVendedor = this.ICP.getPedidosPorVendedorYFecha(idVendedor, mes, anio);
                }

                List<DetallePedido> todosDetalles = new ArrayList<>();

                for (Pedido pedido : pedidosVendedor) {
                    List<DetallePedido> detalles = this.ICDP.obtenerDetallesPedido(pedido.getIdentificador());
                    for (DetallePedido detalle : detalles) {
                        List<Integer> proveedorIDs = this.ICPr.obtenerProveedoresPorProductoID(detalle.getProducto().getId());
                        List<Proveedor> proveedores = new ArrayList<>();
                        for (Integer proveedorID : proveedorIDs) {
                            Proveedor proveedor = this.ICPro.getProveedor(proveedorID);
                            if (proveedor != null) {
                                proveedores.add(proveedor);
                            }
                        }
                        detalle.setProveedores(proveedores);
                        pedido.agregarDetalle(detalle);
                        todosDetalles.add(detalle);
                    }
                }

                // Agrupar los detalles por producto
                Map<Integer, DetallePedido> detalleMap = new HashMap<>();
                for (DetallePedido detalle : todosDetalles) {
                    int productoId = detalle.getProducto().getId();
                    if (detalleMap.containsKey(productoId)) {
                        DetallePedido existingDetalle = detalleMap.get(productoId);
                        existingDetalle.setCantidad(existingDetalle.getCantidad() + detalle.getCantidad());
                    } else {
                        detalleMap.put(productoId, detalle);
                    }
                }

                List<DetallePedido> detallesAgrupados = new ArrayList<>(detalleMap.values());

                // Ordenar pedidos por total
                Collections.sort(pedidosVendedor, new Comparator<Pedido>() {
                    @Override
                    public int compare(Pedido p1, Pedido p2) {
                        return Double.compare(p2.getTotal(), p1.getTotal());
                    }
                });

                // Ordenar detalles por subtotal
                Collections.sort(detallesAgrupados, new Comparator<DetallePedido>() {
                    @Override
                    public int compare(DetallePedido d1, DetallePedido d2) {
                        double subtotal1 = d1.getCantidad() * d1.getPrecioVenta();
                        double subtotal2 = d2.getCantidad() * d2.getPrecioVenta();
                        return Double.compare(subtotal2, subtotal1);
                    }
                });

                // Establecer atributos para el JSP
                request.setAttribute("pedidos", pedidosVendedor);
                request.setAttribute("detalles", detallesAgrupados);

                // Redirigir al JSP
                RequestDispatcher dispatcher = request.getRequestDispatcher("Vistas/verInforme.jsp");
                dispatcher.forward(request, response);
            } catch (NumberFormatException e) {
                request.setAttribute("error", "Mes y año deben ser válidos.");
                RequestDispatcher dispatcher = request.getRequestDispatcher("Vistas/verInforme.jsp");
                dispatcher.forward(request, response);
            }
        } else {
            response.sendRedirect("Login.jsp");
        }
    }
}
