/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */

import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import logica.Clases.Vendedor;
import logica.Fabrica;
import logica.Interfaces.IControladorVendedor;

/**
 *
 * @author AlanCeballos
 */
@WebServlet(urlPatterns = {"/usuarios"})
public class Usuarios extends HttpServlet {

    Fabrica fabrica = Fabrica.getInstance();
    IControladorVendedor controladorVendedor = fabrica.getIControladorVendedor();

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        //obtiene la lista de vendedores
        ArrayList<Vendedor> listaDeVendedores = controladorVendedor.listarVendedores();
        
        //guarda la lista de vendedores en el request
        request.setAttribute("listaDeVendedores", listaDeVendedores);
        
        //redigige a la JSP
        request.getRequestDispatcher("Vistas/usuarios.jsp").forward(request, response);
    }

    // Método GET
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    // Método POST
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    // Breve descripción del servlet
    @Override
    public String getServletInfo() {
        return "Servlet de Usuarios";
    }
}
