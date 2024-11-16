package GenerarInformeCU;

import Persistencia.ConexionAPI;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(urlPatterns = {"/descargarPDF"})
public class DescargarPDFServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        Integer idVendedor = (Integer) session.getAttribute("idVendedor");

        if (idVendedor != null) {
            String nombreCliente = request.getParameter("nombreCliente");
            String nombreCategoria = request.getParameter("nombreCategoria");

            try {
                // Recuperamos los parámetros de fecha
                int mes = Integer.parseInt(request.getParameter("mes"));
                int anio = Integer.parseInt(request.getParameter("anio"));

                // Construimos la URL del endpoint de la API con los parámetros
                StringBuilder path = new StringBuilder("/ventas/descargarPDF?");
                path.append("mes=").append(mes).append("&anio=").append(anio);

                // Agregar idVendedor a la URL
                path.append("&idVendedor=").append(idVendedor);

                if (nombreCliente != null && !nombreCliente.trim().isEmpty()) {
                    path.append("&nombreCliente=").append(nombreCliente);
                }
                if (nombreCategoria != null && !nombreCategoria.trim().isEmpty()) {
                    path.append("&nombreCategoria=").append(nombreCategoria);
                }

                try {
                    // Realizamos la solicitud GET a la API para obtener el PDF
                    byte[] pdfBytes = ConexionAPI.getPdfRequest(path.toString());

                    // Configuramos la respuesta para devolver el archivo PDF
                    response.setContentType("application/pdf");
                    response.setHeader("Content-Disposition", "attachment; filename=InformePedidos.pdf");
                    response.getOutputStream().write(pdfBytes);

                } catch (Exception e) {
                    // Captura de cualquier excepción que ocurra al llamar a la API
                    response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error al obtener el PDF: " + e.getMessage());
                }

            } catch (NumberFormatException | IOException e) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Error al generar el PDF: " + e.getMessage());
            }
        } else {
            response.sendRedirect("Login.jsp");
        }
    }
}
