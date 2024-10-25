/* 
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/JavaScript.js to edit this template
 */

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
        const categoria = producto.dataset.categoria.toLowerCase(); // Obtener la categoría del producto

        let mostrarProducto = true; // Por defecto, se muestra el producto

        // Filtrar por categoría
        if (categoriaSeleccionada !== "todos" && categoria !== categoriaSeleccionada.toLowerCase()) {
            mostrarProducto = false; // Ocultar si la categoría no coincide
        }

        // Filtrar según la opción seleccionada
        if (filtroSeleccionado !== "todos") {
            if (filtroSeleccionado === "nombre" && !nombre.includes(filter)) {
                mostrarProducto = false; // Ocultar si el nombre no coincide
            } else if (filtroSeleccionado === "descripcion" && !descripcion.includes(filter)) {
                mostrarProducto = false; // Ocultar si la descripción no coincide
            } 
            else if (filtroSeleccionado === "precio" && !precio.includes(filter)) {
                mostrarProducto = false; // Ocultar si el precio no coincide
            }
        } else {
            // Si el filtro es "todos", buscar en todos los campos
            if (!nombre.includes(filter) && !descripcion.includes(filter) && !precio.includes(filter)) {
                mostrarProducto = false; // Ocultar si no hay coincidencias en ninguno
            }
        }

        // Mostrar u ocultar el producto
        producto.style.display = mostrarProducto ? "block" : "none"; // Mostrar solo coincidencias
    });
}

document.addEventListener("DOMContentLoaded", function () {
    const carrito = JSON.parse(localStorage.getItem("carrito")) || [];
    updateTotalCarrito();

    // Actualizar el botón según el estado del producto en el carrito
    document.querySelectorAll(".btn-add-cart").forEach(button => {
        const productId = button.dataset.id;

        if (isProductInCart(productId)) {
            button.textContent = "Quitar del Carrito";
            button.classList.replace("btn-primary", "btn-danger");
        }

        // Evento para añadir o quitar del carrito
        button.addEventListener("click", function () {
            const quantityInput = document.querySelector(`.product-quantity[data-id="${productId}"]`);
            if (!quantityInput) {
                console.error(`Quantity input not found for product ID: ${productId}`);
                return; // Si no se encuentra el input, salir de la función
            }

            const quantity = parseInt(quantityInput.value);
            if (isNaN(quantity) || quantity < 1) {
                console.error(`Invalid quantity for product ID: ${productId}`);
                return; // Si la cantidad no es válida, salir de la función
            }

            console.log(`Product ID: ${productId}, Quantity: ${quantity}`); // Debugging log
            if (!isProductInCart(productId)) {
                addToCart(productId, quantity);
                console.log(`Added to cart: ${productId}`); // Debugging log
                button.textContent = "Quitar del Carrito";
                button.classList.replace("btn-primary", "btn-danger");
            } else {
                removeFromCart(productId);
                console.log(`Removed from cart: ${productId}`); // Debugging log
                button.textContent = "Añadir al Carrito";
                button.classList.replace("btn-danger", "btn-primary");
            }
            updateTotalCarrito();
        });
    });

    function addToCart(productId) {
        // Obtener el elemento del nombre y del precio del producto
        const nameElement = document.querySelector(`.product-card .btn-add-cart[data-id="${productId}"]`).closest('.product-card').querySelector('.card-title');
        const priceElement = document.querySelector(`.product-card .product-price[data-id="${productId}"]`);
        const quantityElement = document.querySelector(`.product-card .product-quantity[data-id="${productId}"]`);

        // Verificar que los elementos existan
        if (!nameElement || !priceElement || !quantityElement) {
            console.error(`Price or name element not found for product ID: ${productId}`);
            return; // Salir si no se encuentra
        }

        const nameText = nameElement.textContent.trim();
        const priceText = priceElement.textContent.trim();
        const priceValue = parseFloat(priceText.replace('$', '').replace(',', '').trim()); // Convertir a número

        const quantityValue = parseInt(quantityElement.value); // Obtener cantidad del input

        // Crear el objeto del producto
        const product = {
            id: productId,
            name: nameText,
            quantity: quantityValue,
            price: priceValue
        };

        // Obtener el carrito del localStorage o inicializar uno nuevo
        const carrito = JSON.parse(localStorage.getItem("carrito")) || [];

        // Comprobar si el producto ya existe en el carrito
        const existingProductIndex = carrito.findIndex(item => item.id === product.id);
        if (existingProductIndex >= 0) {
            // Si ya existe, actualizar la cantidad
            carrito[existingProductIndex].quantity += quantityValue;
        } else {
            // Si no existe, añadir el producto
            carrito.push(product);
        }

        // Guardar el carrito actualizado en localStorage
        localStorage.setItem("carrito", JSON.stringify(carrito));

        console.log(`Added to cart: ${product.id}`);
    }

    // Añadir el evento al botón de añadir al carrito
    document.querySelectorAll('.btn-add-cart').forEach(button => {
        button.addEventListener('click', function () {
            const productId = this.getAttribute('data-id');
            addToCart(productId);
        });
    });



    function removeFromCart(productId) {
        const index = carrito.findIndex(item => item.id === productId);
        if (index > -1) {
            carrito.splice(index, 1);
            localStorage.setItem("carrito", JSON.stringify(carrito));
        }
    }

    function isProductInCart(productId) {
        return carrito.some(item => item.id === productId);
    }

    function updateTotalCarrito() {
        const total = carrito.reduce((sum, item) => sum + item.price * item.quantity, 0);
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

    // Verifica si el botón "verCarrito" está presente antes de agregar el listener
    const verCarritoButton = document.getElementById("verCarrito");
    if (verCarritoButton) {
        verCarritoButton.addEventListener("click", () => {
            window.location.href = "verCarrito.jsp";
        });
    } else {
        console.warn("Ver Carrito button not found.");
    }
});
