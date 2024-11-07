package HistorialPedidosCU;

/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */


import java.io.IOException;
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
import logica.Fabrica;
import logica.Interfaces.IControladorDetallePedido;
import logica.Interfaces.IControladorPedido;
import logica.Interfaces.IControladorProducto;
import logica.Interfaces.IControladorProveedor;

/**
 *
 * @author AlanCeballos
 */
@WebServlet(name = "VerDetallesPedidoServlet", urlPatterns = {"/verdetalles"})
public class VerDetallesPedidoServlet extends HttpServlet {
    
    private IControladorPedido ICPe = Fabrica.getInstance().getIControladorPedido();
    private IControladorDetallePedido ICDP = Fabrica.getInstance().getIControladorDetallePedido();
    private IControladorProducto ICP = Fabrica.getInstance().getIControladorProducto();
    private IControladorProveedor ICPro = Fabrica.getInstance().getIControladorProveedor();
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            //obtenemos el ID del pedido desde la solicitud
            int idPedido = Integer.parseInt(request.getParameter("idPedido"));

            //obtenemos el pedido y sus detalles
            Pedido pedido = this.ICPe.obtenerPedidoPorId(idPedido);
            List<DetallePedido> detalles = this.ICDP.obtenerDetallesPedido(idPedido);

            //obtenemos proveedores para cada detalle
            for (DetallePedido detalle : detalles) {
                //obtenemos proveedores por el ID del producto
                List<Integer> proveedorIDs = this.ICP.obtenerProveedoresPorProductoID(detalle.getProducto().getId());
                List<Proveedor> proveedores = new ArrayList<>();

                for (int proveedorID : proveedorIDs) {
                    //obtenbemos el proveedor correspondiente
                    Proveedor proveedor = this.ICPro.getProveedor(proveedorID);
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