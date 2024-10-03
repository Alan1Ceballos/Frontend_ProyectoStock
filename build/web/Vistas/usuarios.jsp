<%-- 
    Document   : usuarios
    Created on : 3 oct 2024, 14:49:02
    Author     : AlanCeballos
--%>

<%@page import="logica.Clases.Vendedor"%>
<%@page import="java.util.ArrayList"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Lista de Vendedores</title>
    <link rel="stylesheet" type="text/css" href="../Styles/usuarios.css">
    <style>
        table { 
            width: 100%; 
            border-collapse: collapse; 
        }

        th, td { 
            padding: 10px; 
            border: 1px solid black; 
            text-align: left; 
        }

        th { 
            background-color: #f2f2f2; 
        }
    </style>
</head>
<body>
    <h1>Lista de Vendedores</h1>
    <%
        //obtenemos la lista de vendedores desde el request
        ArrayList<Vendedor> listaDeVendedores = (ArrayList<Vendedor>) request.getAttribute("listaDeVendedores");
        if (listaDeVendedores != null && !listaDeVendedores.isEmpty()) {
    %>
        <table>
            <tr>
                <th>ID</th>
                <th>Cedula</th>
                <th>Nombre</th>
                <th>Teléfono</th>
                <th>Dirección</th>
                <th>Correo Electrónico</th>
            </tr>
            <%
                for (Vendedor vendedor : listaDeVendedores) {
            %>
                <tr>
                    <td><%= vendedor.getId() %></td>
                    <td><%= vendedor.getCedula() %></td>
                    <td><%= vendedor.getNombre() %></td>
                    <td><%= vendedor.getTelefono() %></td>
                    <td><%= vendedor.getDireccion() %></td>
                    <td><%= vendedor.getCorreo() %></td>
                </tr>
            <%
                }
            %>
        </table>
    <%
        } else {
    %>
        <p>No hay vendedores disponibles.</p>
    <%
        }
    %>
</body>
</html>
