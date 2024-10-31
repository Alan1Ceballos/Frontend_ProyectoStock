<%-- 
    Document   : Home
    Created on : 24 oct 2024, 20:55:43
    Author     : AlanCeballos
--%>

<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="javax.servlet.http.HttpSession" %>
<%
    //verifica si hay una sesión activa
    if (session == null || session.getAttribute("usuario") == null) {
        //redirige a Login.jsp si el usuario no está autenticado
        response.sendRedirect("Login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Página Principal</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" type="text/css" href="Styles/home.css">
</head>
<body>
    <header class="p-3 bg-dark text-white d-flex justify-content-between align-items-center">
        <div class="encabezado">
            <h1 class="mb-1">Bienvenido a la página principal</h1>
            <%
                String usuario = (String) session.getAttribute("usuario");
            %>
            <p id="welcome-message" class="mb-0">
                <% if (usuario != null) { %>
                    ¡Hola, <%= usuario %>! Has iniciado sesión correctamente.
                <% } %>
            </p>
        </div>
        <form action="LogoutServlet" method="POST" class="mb-0">
            <button type="submit" class="btn btn-danger">Cerrar Sesión</button>
        </form>
    </header>

      <div class="contenido d-flex justify-content-center align-items-center vh-100"> <!-- Centrado verticalmente -->
        <div class="row justify-content-center mt-4">
            <div class="col-md-15">
                <div class="mb-4">
                    <div class="card text-center">
                        <div class="card-body d-flex justify-content-between align-items-center">
                            <h5 class="card-title mb-0">Crear Pedido</h5>
                            <a href="crearPedido" class="btn btn-primary ms-3">Ir</a>
                        </div>
                    </div>
                </div>


                <div class="mb-4">
                    <div class="card text-center">
                        <div class="card-body d-flex justify-content-between align-items-center">
                            <h5 class="card-title mb-0">Historial de Pedidos</h5>
                            <form action="historialpedidos" method="GET">
                                <button type="submit" class="btn btn-primary ms-3">Ir</button>
                            </form>
                        </div>
                    </div>
                </div>

                <div class="mb-4">
                    <div class="card text-center">
                        <div class="card-body d-flex justify-content-between align-items-center">
                            <h5 class="card-title mb-0">Listado de Clientes</h5>
                            <form action="clientes" method="GET">
                                <button type="submit" class="btn btn-primary ms-3">Ir</button>
                            </form>
                        </div>
                    </div>
                </div>

                <div class="mb-4">
                    <div class="card text-center">
                        <div class="card-body d-flex justify-content-between align-items-center">
                            <h5 class="card-title mb-0">Generar Informe</h5>
                            <form action="generarInforme" method="GET">
                                <button type="submit" class="btn btn-primary ms-3">Ir</button>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
            
    <footer class="text-center mt-4">
        <p>&copy; 2024 Programación de Aplicaciones</p>
    </footer>
</body>
</html>