/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */

import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import logica.Clases.DetallePedido;
import logica.Clases.Pedido;
import logica.Fabrica;
import logica.servicios.DetallePedidoServicios;

/**
 *
 * @author AlanCeballos
 */
@WebServlet(urlPatterns = {"/historialpedidos"})
public class HistorialPedidosServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        Integer idVendedor = (Integer) (session != null ? session.getAttribute("idVendedor") : null);

        if (idVendedor == null) {
            response.sendRedirect("Login.jsp");
            return;
        }

        Fabrica fabrica = Fabrica.getInstance();
        ArrayList<Pedido> pedidosVendedor = fabrica.getIControladorPedido().getPedidosPorVendedor(idVendedor);

        //obtenemos detalles para cada pedido
        DetallePedidoServicios detalleServicios = new DetallePedidoServicios();
        for (Pedido pedido : pedidosVendedor) {
            List<DetallePedido> detalles = detalleServicios.obtenerDetallesPedido(pedido.getIdentificador());
            for (DetallePedido detalle : detalles) {
                pedido.agregarDetalle(detalle);
            }
        }

        request.setAttribute("pedidos", pedidosVendedor);
        RequestDispatcher dispatcher = request.getRequestDispatcher("Vistas/historialPedidos.jsp");
        dispatcher.forward(request, response);
    }
}
