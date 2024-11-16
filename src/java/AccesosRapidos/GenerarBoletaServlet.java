package AccesosRapidos;

import Persistencia.ConexionAPI;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.OutputStream;
import com.google.gson.JsonObject;

@WebServlet(urlPatterns = {"/generarBoleta"})
public class GenerarBoletaServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    public String getServletInfo() {
        return "Genera un informe de productos en PDF como boleta de compra a partir de un pedido.";
    }

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Obtener el idPedido de la solicitud
        String idPedidoStr = request.getParameter("idPedido");
        if (idPedidoStr == null || idPedidoStr.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "El parámetro idPedido es obligatorio");
            return;
        }

        int idPedido = Integer.parseInt(idPedidoStr);

        try {
            // Llamamos al servicio REST para generar la boleta (PDF)
            String path = "/ventas/boleta/" + idPedido;

            // Llamada correcta al método que devuelve el PDF como bytes
            byte[] pdfBytes = ConexionAPI.getPdfRequest(path);  // Usamos getPdfRequest aquí

            // Establecer los encabezados para la descarga del archivo PDF
            response.setContentType("application/pdf");
            response.setContentLength(pdfBytes.length);
            response.setHeader("Content-Disposition", "attachment; filename=boleta_productos.pdf");

            // Escribir el archivo PDF en la respuesta
            try (OutputStream out = response.getOutputStream()) {
                out.write(pdfBytes);
            }

        } catch (Exception e) {
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error al generar la boleta: " + e.getMessage());
        }
    }

}
