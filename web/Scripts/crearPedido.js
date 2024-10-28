function filtrarProductos() {
    const input = document.getElementById('busqueda');
    const filter = input.value.toLowerCase();
    const filtroSeleccionado = document.getElementById('filtro').value;
    const categoriaSeleccionada = document.getElementById('categoriaFiltro').value;
    const productos = document.querySelectorAll(".product-card");

    productos.forEach(producto => {
        const nombre = producto.querySelector('.card-title').textContent.toLowerCase();
        const descripcion = producto.querySelector('.card-text').textContent.toLowerCase();
        const precio = producto.querySelector('.product-price').textContent.toLowerCase();
        const categoria = producto.dataset.categoria.toLowerCase();

        let mostrarProducto = true;

        if (categoriaSeleccionada !== "todos" && categoria !== categoriaSeleccionada.toLowerCase()) {
            mostrarProducto = false;
        }

        if (filtroSeleccionado !== "todos") {
            if (filtroSeleccionado === "nombre" && !nombre.includes(filter)) {
                mostrarProducto = false;
            } else if (filtroSeleccionado === "descripcion" && !descripcion.includes(filter)) {
                mostrarProducto = false;
            } else if (filtroSeleccionado === "precio" && !precio.includes(filter)) {
                mostrarProducto = false;
            }
        } else {
            if (!nombre.includes(filter) && !descripcion.includes(filter) && !precio.includes(filter)) {
                mostrarProducto = false;
            }
        }

        producto.style.display = mostrarProducto ? "block" : "none";
    });
}

document.addEventListener("DOMContentLoaded", function () {
    const carrito = JSON.parse(localStorage.getItem("carrito")) || [];
    updateTotalCarrito();

    // Mostrar clientes en la consola cuando se selecciona uno
    const clienteSelect = document.getElementById("cliente");
    if (clienteSelect) {
        clienteSelect.addEventListener("change", function () {
            const clienteId = this.value; // Obtiene el valor del cliente seleccionado
            console.log("Cliente ID almacenado:", clienteId); // Muestra el ID del cliente
            localStorage.setItem("clienteId", clienteId);
            const opciones = Array.from(this.options).map(option => option.value);
            console.log("Clientes disponibles:", opciones); // Muestra todos los IDs de clientes
        });
    }

    // Configurar los botones de añadir al carrito
    document.querySelectorAll(".btn-add-cart").forEach(button => {
        const productId = button.dataset.id;
        const quantityInput = button.closest('.product-card').querySelector('.product-quantity');

        // Comprobar si el producto ya está en el carrito
        if (isProductInCart(productId)) {
            button.textContent = "Quitar del Carrito";
            button.classList.replace("btn-primary", "btn-danger");
        }

        button.addEventListener("click", function () {
            const quantityValue = parseInt(quantityInput.value) || 1; // Valor por defecto 1 si no se especifica

            if (!isProductInCart(productId)) {
                addToCart(productId, quantityValue);
                button.textContent = "Quitar del Carrito";
                button.classList.replace("btn-primary", "btn-danger");
            } else {
                removeFromCart(productId);
                button.textContent = "Añadir al Carrito";
                button.classList.replace("btn-danger", "btn-primary");
            }

            updateTotalCarrito(); // Actualizar el total
        });
    });

    // Llamada para filtrar productos al cambiar el input de búsqueda
    const busquedaInput = document.getElementById('busqueda');
    if (busquedaInput) {
        busquedaInput.addEventListener('input', filtrarProductos);
    }

    // Configurar el botón de "Ver Carrito"
    const verCarritoButton = document.getElementById("verCarrito");
    if (verCarritoButton) {
        verCarritoButton.addEventListener("click", () => {
            window.location.href = "verCarrito.jsp";
        });
    } else {
        console.warn("Ver Carrito button not found.");
    }

    // Funciones de carrito
    function addToCart(productId, quantity) {
        const nameElement = document.querySelector(`.product-card .btn-add-cart[data-id="${productId}"]`).closest('.product-card').querySelector('.card-title');
        const priceElement = document.querySelector(`.product-card .product-price[data-id="${productId}"]`);

        if (!nameElement || !priceElement) {
            console.error(`Element not found for product ID: ${productId}`);
            return;
        }

        const nameText = nameElement.textContent.trim();
        const priceText = priceElement.textContent.trim();
        const priceValue = parseFloat(priceText.replace('$', '').replace(',', '').trim());

        // Comprobar si el producto ya existe en el carrito
        const existingProductIndex = carrito.findIndex(item => item.id === productId);

        if (existingProductIndex > -1) {
            // Si el producto ya existe, solo actualizamos la cantidad
            carrito[existingProductIndex].quantity += quantity; // Incrementamos la cantidad
        } else {
            // Si es un producto nuevo, lo añadimos al carrito
            const product = {
                id: productId,
                name: nameText,
                price: priceValue,
                quantity: quantity // Guardar cantidad
            };
            carrito.push(product);
        }

        localStorage.setItem("carrito", JSON.stringify(carrito));
        console.log(`Added to cart: ${productId}, Quantity: ${quantity}`);
    }

    function removeFromCart(productId) {
        const index = carrito.findIndex(item => item.id === productId);
        if (index > -1) {
            carrito.splice(index, 1); // Eliminar producto
            localStorage.setItem("carrito", JSON.stringify(carrito));
            console.log(`Removed from cart: ${productId}`);
        } else {
            console.warn(`Product not found in cart: ${productId}`);
        }
    }

    function isProductInCart(productId) {
        return carrito.some(item => item.id === productId);
    }

    function updateTotalCarrito() {
        const total = carrito.reduce((sum, item) => sum + (item.price * item.quantity), 0);
        document.getElementById("totalCarrito").textContent = total.toFixed(2);
    }

    document.getElementById("limpiarCarrito").addEventListener("click", () => {
        localStorage.removeItem("carrito");
        carrito.length = 0;
        updateTotalCarrito();
        document.querySelectorAll(".btn-add-cart").forEach(button => {
            button.textContent = "Añadir al Carrito";
            button.classList.replace("btn-danger", "btn-primary");
        });
    });
});
