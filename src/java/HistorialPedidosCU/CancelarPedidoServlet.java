package HistorialPedidosCU;

/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import logica.Fabrica;
import logica.Interfaces.IControladorPedido;

/**
 *
 * @author bande
 */
@WebServlet("/cancelarPedido")
public class CancelarPedidoServlet extends HttpServlet {

    private IControladorPedido ICP = Fabrica.getInstance().getIControladorPedido();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Obtener el ID del pedido desde el formulario
        int idPedido = Integer.parseInt(request.getParameter("idPedido"));

        // Cancelar el pedido
        boolean exito = this.ICP.cancelarPedido(idPedido);

        // Redirigir al historial de pedidos con un mensaje de éxito o error
        if (exito) {
            request.setAttribute("mensaje", "El pedido fue cancelado exitosamente.");
        } else {
            request.setAttribute("mensaje", "No se pudo cancelar el pedido. Ya está cancelado o no existe.");
        }

        // Volver a la página de historial de pedidos
        response.sendRedirect(request.getContextPath() + "/historialpedidos");
    }
}
