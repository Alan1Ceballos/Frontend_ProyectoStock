/* 
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/JavaScript.js to edit this template
 */


document.addEventListener("DOMContentLoaded", function () {
    const carritoContainer = document.getElementById("carritoContainer");
    const carritoTotalElement = document.getElementById("carritoTotal");
    const clienteId = localStorage.getItem("clienteId"); // Recuperar el clienteId de localStorage

    const carrito = JSON.parse(localStorage.getItem(`carrito_${clienteId}`)) || [];
    console.log("Productos en el carrito:", carrito);

    // Agregar un console.log para verificar el clienteId
    console.log("Cliente ID:", clienteId);

    // Función para mostrar productos en el carrito
    function mostrarCarrito() {
        carritoContainer.innerHTML = ""; // Limpiar contenido previo

        if (carrito.length === 0) {
            carritoContainer.innerHTML = "<p>No hay productos en el carrito.</p>";
            carritoTotalElement.textContent = "0.00";
            return;
        }

        carrito.forEach((item, index) => {
            const productCard = document.createElement("div");
            productCard.classList.add("col-md-3", "mb-4");

            productCard.innerHTML = `
                <div class="product-card">
                    <div class="card">
                        <div class="card-body">
                            <h5 class="card-title">${item.name}</h5>
                            <p class="card-text">Precio Unitario: $${item.price.toFixed(2)}</p>
                            <p class="card-text">Cantidad: ${item.quantity}</p>
                            <p class="card-text">Subtotal: $${(item.price * item.quantity).toFixed(2)}</p>
                            <button class="btn btn-danger btn-remove" data-index="${index}">Quitar del Carrito</button>
                        </div>
                    </div>
                </div>
            `;
            carritoContainer.appendChild(productCard);
        });

        actualizarTotal();
    }

    // Función para actualizar el total del carrito
    function actualizarTotal() {
        const total = carrito.reduce((sum, item) => sum + item.price * item.quantity, 0);
        carritoTotalElement.textContent = total.toFixed(2);
    }

    // Evento para quitar productos del carrito
    carritoContainer.addEventListener("click", function (event) {
        if (event.target.classList.contains("btn-remove")) {
            const index = event.target.getAttribute("data-index");
            carrito.splice(index, 1);  // Eliminar el producto del carrito
            localStorage.setItem("carrito", JSON.stringify(carrito));  // Actualizar localStorage
            mostrarCarrito();  // Volver a mostrar el carrito
        }
    });

    // Evento para confirmar el pedido
    document.getElementById("confirmarPedido").addEventListener("click", function () {
        if (carrito.length === 0) {
            Swal.fire({
                icon: 'warning',
                title: 'Carrito vacio',
                text: 'El carrito está vacio. Añada productos antes de confirmar.',
            });
            return;
        }

        confirmarPedido(clienteId, carrito); // Llama a la función para confirmar el pedido
    });

    // Definición de la función confirmarPedido
    function confirmarPedido(clienteId, carrito) {
        console.log("Confirmando pedido con Cliente ID:", clienteId);

        // Verificar si clienteId es nulo, indefinido o vacío
        if (!clienteId || clienteId.trim() === "") {
            Swal.fire({
                icon: 'error',
                title: 'Error',
                text: 'Cliente ID no está disponible. Por favor, seleccione un cliente.',
            });
            return; // Salir de la función si el clienteId no es válido
        }

        var idVendedor = document.getElementById("data-vendedor").getAttribute("data-idVendedor");


        // Configurar la solicitud HTTP
        const xhr = new XMLHttpRequest();
        xhr.open("POST", "http://localhost:8080/rest/api/carrito/confirmarPedido", true);

        // Cambiar el tipo de contenido a JSON
        xhr.setRequestHeader("Content-Type", "application/json");

        // Crear el cuerpo de la solicitud
        const body = JSON.stringify({
            clienteId: clienteId, // Se envía como string
            carrito: carrito,      // Asegúrate de que `carrito` esté correctamente estructurado
            idVendedor: idVendedor
        });

        console.log("Enviando datos:", body); // Útil para depuración

        // Enviar la solicitud
        xhr.send(body);

        // Manejar la respuesta
        xhr.onreadystatechange = function () {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) { // Éxito
                    Swal.fire({
                        icon: 'success',
                        title: 'Pedido confirmado',
                        text: 'Tu pedido ha sido confirmado exitosamente.',
                    }).then(() => {
                        // Limpiar el carrito después de confirmar el pedido
                        localStorage.removeItem(`carrito_${clienteId}`); // Eliminar del almacenamiento local
                        carrito.length = 0; // Vaciar el carrito en memoria
                        mostrarCarrito(); // Actualizar la vista del carrito

                        // Redirigir al usuario a la página crearPedido
                        window.location.href = "crearPedido";
                    });
                } else {
                    let errorMsg = "Hubo un problema al confirmar tu pedido.";
                    try {
                        const response = JSON.parse(xhr.responseText);
                        errorMsg = response.message || errorMsg;
                    } catch (e) {
                        console.error("Error al parsear la respuesta del servidor:", e);
                    }
                    Swal.fire({
                        icon: 'error',
                        title: 'Error al confirmar el pedido',
                        text: errorMsg,
                    });
                }
            }
        };

        // Manejar posibles errores de red
        xhr.onerror = function () {
            Swal.fire({
                icon: 'error',
                title: 'Error',
                text: 'Hubo un error en la conexión. Por favor, intenta nuevamente.',
            });
        };
    }




// Evento para limpiar el carrito
    document.getElementById("limpiarCarrito").addEventListener("click", function () {
        Swal.fire({
            icon: 'warning',
            title: '¿Seguro que quieres limpiar el carrito?',
            text: 'Esto eliminará todos los productos del carrito.',
            showCancelButton: true,
            confirmButtonText: 'Sí, limpiar',
            cancelButtonText: 'Cancelar',
        }).then((result) => {
            if (result.isConfirmed) {
                // Aquí usamos el nombre correcto del carrito con clienteId
                localStorage.removeItem('clienteId');  // Eliminar carrito de localStorage
                localStorage.removeItem(`carrito_${clienteId}`);
                carrito.length = 0;  // Vaciar el carrito en memoria
                mostrarCarrito();  // Actualizar la vista del carrito
            }
        });
    });


    // Mostrar el carrito al cargar la página
    mostrarCarrito();
});