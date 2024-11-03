package HistorialPedidosCU;

/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */


import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import logica.Clases.DetallePedido;
import logica.Clases.Pedido;
import logica.Clases.Proveedor;
import logica.servicios.DetallePedidoServicios;
import logica.servicios.PedidosServicios;
import logica.servicios.ProductoServicios;
import logica.servicios.ProveedorServicios;

/**
 *
 * @author AlanCeballos
 */
@WebServlet(name = "VerDetallesPedidoServlet", urlPatterns = {"/verdetalles"})
public class VerDetallesPedidoServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            //obtenemos el ID del pedido desde la solicitud
            int idPedido = Integer.parseInt(request.getParameter("idPedido"));
            PedidosServicios pedidosServicios = new PedidosServicios();
            DetallePedidoServicios detallePedidosServicios = new DetallePedidoServicios();

            //obtenemos el pedido y sus detalles
            Pedido pedido = pedidosServicios.obtenerPedidoPorId(idPedido);
            List<DetallePedido> detalles = detallePedidosServicios.obtenerDetallesPedido(idPedido);

            //obtenemos proveedores para cada detalle
            ProductoServicios productoServicios = new ProductoServicios();
            ProveedorServicios proveedorServicios = new ProveedorServicios();

            for (DetallePedido detalle : detalles) {
                //obtenemos proveedores por el ID del producto
                List<Integer> proveedorIDs = productoServicios.obtenerProveedoresPorProductoID(detalle.getProducto().getId());
                List<Proveedor> proveedores = new ArrayList<>();

                for (int proveedorID : proveedorIDs) {
                    //obtenbemos el proveedor correspondiente
                    Proveedor proveedor = proveedorServicios.getProveedor(proveedorID);
                    if (proveedor != null) {
                        proveedores.add(proveedor);
                    }
                }
                detalle.setProveedores(proveedores); //establecemos la lista de proveedores en el detalle
            }

            //establecemos el pedido y sus detalles en el request para ser utilizados en la vista
            request.setAttribute("pedido", pedido);
            request.setAttribute("detalles", detalles);
            request.getRequestDispatcher("/Vistas/verDetallesPedido.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID de pedido inválido.");
        } catch (Exception e) {
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Ocurrió un error al procesar el pedido.");
            e.printStackTrace();
        }
    }
}