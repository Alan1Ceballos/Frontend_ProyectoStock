package AccesosRapidos;

import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import com.itextpdf.text.Document;
import com.itextpdf.text.DocumentException;
import com.itextpdf.text.Paragraph;
import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfPCell;
import com.itextpdf.text.pdf.PdfWriter;
import logica.servicios.PedidosServicios;
import logica.Clases.DetallePedido;

@WebServlet(urlPatterns = {"/generarInformeProductos"})
public class GenerarInformeProductosServlet extends HttpServlet {

    private PedidosServicios pedidoServicios = new PedidosServicios();

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Obtener el ID del pedido desde la solicitud
        int idPedido = Integer.parseInt(request.getParameter("idPedido"));

        response.setContentType("application/pdf");
        response.setHeader("Content-Disposition", "attachment; filename=boleta_productos.pdf");

        Document document = new Document();
        try {
            PdfWriter.getInstance(document, response.getOutputStream());
            document.open();

            // Agregar título de la boleta
            document.add(new Paragraph("Boleta de Compra de Productos"));
            document.add(new Paragraph(" ")); // Espacio

            // Crear tabla de productos
            PdfPTable table = new PdfPTable(4); // Cambia a 4 columnas
            table.setWidthPercentage(100); // Opcional: establece el ancho de la tabla

            // Añadir encabezados
            addCell(table, "Nombre", true);
            addCell(table, "Cantidad", true);
            addCell(table, "Precio Unitario", true);
            addCell(table, "Subtotal", true); // Nueva columna para subtotal

            // Obtener los detalles del pedido (productos) usando el ID del pedido
            List<DetallePedido> detallesPedido = pedidoServicios.obtenerDetallesPedido(idPedido);
            float totalBoleta = 0; // Para calcular el total

            for (DetallePedido detalle : detallesPedido) {
                // Obtén los datos de cada producto
                String nombreProducto = detalle.getProducto().getNombre(); // Nombre del producto
                int cantidad = detalle.getCantidad(); // Cantidad comprada
                float precioUnitario = detalle.getPrecioVenta(); // Precio unitario
                float subtotal = cantidad * precioUnitario; // Cálculo del subtotal

                // Añadir celdas a la tabla con bordes
                addCell(table, nombreProducto, false); // Nombre del producto
                addCell(table, String.valueOf(cantidad), false); // Cantidad comprada
                addCell(table, "$" + String.format("%.2f", precioUnitario), false); // Precio unitario con símbolo de dólar
                addCell(table, "$" + String.format("%.2f", subtotal), false); // Subtotal con símbolo de dólar

                // Calcular el total para la boleta
                totalBoleta += subtotal; // Sumar el subtotal al total de la boleta
            }

            document.add(table);
            document.add(new Paragraph(" ")); // Espacio
            document.add(new Paragraph("Total de Productos: " + detallesPedido.size()));
            document.add(new Paragraph("Total a Pagar: $" + String.format("%.2f", totalBoleta))); // Total de la boleta con formato
            document.close();
        } catch (DocumentException e) {
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error al generar el PDF: " + e.getMessage());
        }
    }

    // Método para añadir celdas con bordes controlados
    private void addCell(PdfPTable table, String content, boolean isHeader) {
        PdfPCell cell = new PdfPCell(new Paragraph(content));
        if (isHeader) {
            cell.setBorderWidth(1); // Bordes para encabezados
        } else {
            cell.setBorderWidth(1); // Bordes para contenido
        }
        cell.setPadding(5); // Añadir algo de espacio dentro de las celdas
        table.addCell(cell);
    }

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
}
