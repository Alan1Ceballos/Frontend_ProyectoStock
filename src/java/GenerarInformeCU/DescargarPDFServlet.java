package GenerarInformeCU;

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
import javax.servlet.http.HttpSession;

import logica.Clases.DetallePedido;
import logica.Clases.Pedido;

import com.itextpdf.text.Document;
import com.itextpdf.text.DocumentException;
import com.itextpdf.text.Paragraph;
import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfWriter;
import java.text.SimpleDateFormat;
import java.util.stream.Collectors;

import logica.Fabrica;
import logica.Interfaces.IControladorCategoria;
import logica.Interfaces.IControladorCliente;
import logica.Interfaces.IControladorDetallePedido;
import logica.Interfaces.IControladorPedido;
import logica.Interfaces.IControladorProducto;

@WebServlet(urlPatterns = {"/descargarPDF"})
public class DescargarPDFServlet extends HttpServlet {

    private IControladorPedido ICP = Fabrica.getInstance().getIControladorPedido();
    private IControladorProducto ICPr = Fabrica.getInstance().getIControladorProducto();
    private IControladorDetallePedido ICDP = Fabrica.getInstance().getIControladorDetallePedido();
    private IControladorCliente ICC = Fabrica.getInstance().getIControladorCliente();
    private IControladorCategoria ICCat = Fabrica.getInstance().getIControladorCategoria();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        Integer idVendedor = (Integer) session.getAttribute("idVendedor");

        if (idVendedor != null) {
            String nombreCliente = request.getParameter("nombreCliente");
            String nombreCategoria = request.getParameter("nombreCategoria");

            try {
                int mes = Integer.parseInt(request.getParameter("mes"));
                int anio = Integer.parseInt(request.getParameter("anio"));

                Integer clienteId = (nombreCliente != null && !nombreCliente.trim().isEmpty())
                        ? this.ICC.obtenerIdPorNombre(nombreCliente) : null;
                Integer categoriaId = (nombreCategoria != null && !nombreCategoria.trim().isEmpty())
                        ? this.ICCat.obtenerIdPorNombre(nombreCategoria) : null;

                List<Pedido> pedidosVendedor = obtenerPedidosFiltrados(idVendedor, mes, anio, clienteId, categoriaId);
                List<DetallePedido> detallesAgrupados = agruparDetallesPedidos(pedidosVendedor);

                if (pedidosVendedor.isEmpty() || detallesAgrupados.isEmpty()) {
                    // Manejar caso sin datos
                }

                generarPDF(response, pedidosVendedor, detallesAgrupados);
            } catch (NumberFormatException | DocumentException e) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Error al generar el PDF: " + e.getMessage());
            }
        } else {
            response.sendRedirect("Login.jsp");
        }
    }

    private List<Pedido> obtenerPedidosFiltrados(Integer idVendedor, int mes, int anio, Integer clienteId, Integer categoriaId) {
        List<Pedido> pedidosFiltrados = new ArrayList<>();

        if (clienteId != null && categoriaId != null) {
            pedidosFiltrados = this.ICP.getPedidosPorVendedorTodos(idVendedor, mes, anio, categoriaId, clienteId);
        } else if (clienteId != null) {
            pedidosFiltrados = this.ICP.getPedidosPorVendedorClienteYFecha(idVendedor, mes, anio, clienteId);
        } else if (categoriaId != null) {
            pedidosFiltrados = this.ICP.getPedidosPorVendedorCategoriaYFecha(idVendedor, mes, anio, categoriaId);
        } else {
            pedidosFiltrados = this.ICP.getPedidosPorVendedorYFecha(idVendedor, mes, anio);
        }

        // Filtrar solo los pedidos entregados
        return pedidosFiltrados;
    }

    private List<DetallePedido> agruparDetallesPedidos(List<Pedido> pedidosVendedor) {
        List<DetallePedido> todosDetalles = new ArrayList<>();
        for (Pedido pedido : pedidosVendedor) {
            List<DetallePedido> detalles = this.ICDP.obtenerDetallesPedido(pedido.getIdentificador());
            todosDetalles.addAll(detalles);
        }
        return todosDetalles;
    }

    private void generarPDF(HttpServletResponse response, List<Pedido> pedidos, List<DetallePedido> detalles) throws DocumentException, IOException {
        response.setContentType("application/pdf");
        response.setHeader("Content-Disposition", "attachment; filename=InformePedidos.pdf");

        Document document = new Document();
        PdfWriter.getInstance(document, response.getOutputStream());
        document.open();

        document.add(new Paragraph("Informe de Pedidos"));
        document.add(new Paragraph("Pedidos Hechos"));
        document.add(new Paragraph(" "));

        // Crear el formateador de fecha
        SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yy");

        // Calcular subtotales y ordenar pedidos de mayor a menor subtotal
        // Calcular subtotales y ordenar pedidos de mayor a menor subtotal
        List<Pedido> pedidosConSubtotal = pedidos.stream()
                .map(pedido -> {
                    float subtotalPedido = calcularSubtotalPedido(pedido);
                    pedido.setTotal(subtotalPedido); // Asegúrate de que Pedido tenga un método setTotal
                    return pedido;
                })
                .sorted((p1, p2) -> Float.compare(p2.getTotal(), p1.getTotal())) // Ordenar de mayor a menor
                .collect(Collectors.toList());

        // Tabla de pedidos
        PdfPTable tablePedidos = new PdfPTable(5);
        tablePedidos.addCell("ID");
        tablePedidos.addCell("Fecha");
        tablePedidos.addCell("Estado");
        tablePedidos.addCell("Subtotal");
        tablePedidos.addCell("Cliente");

        // Agregar datos de pedidos a la tabla
        for (Pedido pedido : pedidosConSubtotal) {
            tablePedidos.addCell(String.valueOf(pedido.getIdentificador()));
            String fechaFormateada = dateFormat.format(pedido.getFechaPedido());
            tablePedidos.addCell(fechaFormateada);
            tablePedidos.addCell(traducirEstado(pedido.getEstado().toString()));
            tablePedidos.addCell("$" + String.format("%.2f", pedido.getTotal())); // Formatear subtotal
            tablePedidos.addCell(this.ICC.getNombreClientePorId(pedido.getIdCliente()));
        }

        document.add(tablePedidos);
        document.add(new Paragraph(" "));

        document.add(new Paragraph("Productos Vendidos"));
        document.add(new Paragraph(" "));

        // Ordenar detalles de pedidos de mayor a menor precio de venta
        List<DetallePedido> detallesOrdenados = detalles.stream()
                .sorted((d1, d2) -> Double.compare(d2.getPrecioVenta(), d1.getPrecioVenta())) // Ordenar de mayor a menor
                .collect(Collectors.toList());

        // Tabla de detalles de pedidos
        PdfPTable tableDetalles = new PdfPTable(5);
        tableDetalles.addCell("Producto");
        tableDetalles.addCell("Nombre");
        tableDetalles.addCell("Descripción");
        tableDetalles.addCell("Cantidad");
        tableDetalles.addCell("Precio Venta");

        double ingresosGenerados = 0;

        // Agregar datos de detalles a la tabla y calcular ingresos generados
        for (DetallePedido detalle : detallesOrdenados) {
            tableDetalles.addCell(String.valueOf(detalle.getProducto().getId()));
            tableDetalles.addCell(detalle.getProducto().getNombre());
            tableDetalles.addCell(detalle.getProducto().getDescripcion());
            tableDetalles.addCell(String.valueOf(detalle.getCantidad()));
            tableDetalles.addCell("$" + String.format("%.2f", detalle.getPrecioVenta())); // Formatear precio venta

            double subtotal = detalle.getPrecioVenta() * detalle.getCantidad();
            ingresosGenerados += subtotal;
        }

        document.add(tableDetalles);
        document.add(new Paragraph(" "));

        document.add(new Paragraph("Ingresos Generados: $" + String.format("%.2f", ingresosGenerados))); // Formatear total
        document.close();
    }

// Método para calcular el subtotal del pedido
    private float calcularSubtotalPedido(Pedido pedido) {
        float subtotal = 0;
        List<DetallePedido> detallesPedido = this.ICDP.obtenerDetallesPedido(pedido.getIdentificador());
        for (DetallePedido detalle : detallesPedido) {
            subtotal += detalle.getPrecioVenta() * detalle.getCantidad();
        }
        return subtotal;
    }

    // Método para traducir el estado del pedido
    private String traducirEstado(String estado) {
        switch (estado) {
            case "EN_PREPARACION":
                return "En preparación";
            case "CANCELADO":
                return "Cancelado";
            case "ENTREGADO":
                return "Entregado";
            case "EN_VIAJE":
                return "En viaje";
            default:
                return estado;
        }
    }
}
