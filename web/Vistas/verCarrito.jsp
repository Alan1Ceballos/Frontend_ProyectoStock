<%@page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Ver Carrito</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" type="text/css" href="Styles/verCarrito.css">
    <script src="Scripts/verCarrito.js"></script>
</head>
<body>
    <header class="d-flex align-items-center justify-content-between p-3 bg-dark text-white">
        <div class="encabezado">
            <h1>Carrito de Compras</h1>
        </div>
    </header>

    <div class="container mt-4 flex-grow-1">
        <div id="carritoContainer" class="row">
            <!-- Aquí se llenarán las cartas de productos con JavaScript -->
        </div>

        <div class="mt-4">
            <h5>Total del Carrito: $<span id="carritoTotal">0.00</span></h5>
            <button class="btn btn-danger" id="limpiarCarrito">Limpiar Carrito</button>
            <button class="btn btn-success" id="confirmarPedido" onclick="confirmarPedido(localStorage.getItem('clienteId'), JSON.parse(localStorage.getItem('carrito')) || [])">Confirmar Pedido</button>
            <a href="crearPedido" class="btn btn-secondary">Regresar</a>
        </div>
    </div>

    <footer class="text-center mt-4">
        <p>&copy; 2024 Programación de Aplicaciones</p>
    </footer>

    <!-- Bootstrap JavaScript -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
