/* 
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/JavaScript.js to edit this template
 */


document.addEventListener("DOMContentLoaded", function () {
    const carrito = obtenerCarritoCliente(); // Obtiene el carrito del cliente actual
    updateTotalCarrito();

    const haIdCliente = localStorage.getItem("clienteId");

    // Si existe un cliente seleccionado, puedes hacer algo con él, como marcarlo en un formulario o en la UI
    if (haIdCliente) {
        // Supón que tienes un select o algo similar para mostrar el cliente
        const clienteSelect = document.getElementById("cliente");
        if (clienteSelect) {
            clienteSelect.value = haIdCliente;  // Establecer el valor del cliente en el select
        }
    }

    // Mostrar clientes en la consola cuando se selecciona uno
    const clienteSelect = document.getElementById("cliente");
    if (clienteSelect) {
        clienteSelect.addEventListener("change", function () {
            const clienteId = this.value;
            console.log("Cliente ID almacenado:", clienteId);
            localStorage.setItem("clienteId", clienteId);
            carrito.length = 0;
            cargarCarritoPorCliente(clienteId); // Cargar el carrito cuando se cambia de cliente
        });
    }


    // Configurar los botones de añadir al carrito
    document.querySelector('.btn-add-cart').addEventListener('click', function () {
        // Obtenemos los datos del producto seleccionado
        const idProducto = document.querySelector('#selectProducto').value;
        const nombreProducto = document.querySelector('#selectProducto option:checked').textContent;
        const precioProducto = parseFloat(document.querySelector('#selectProducto option:checked').dataset.precio);
        const cantidadProducto = parseInt(document.querySelector('#cantidadProducto').value, 10);

        // Validamos entrada
        if (!idProducto || cantidadProducto <= 0) {
            Swal.fire("Error", "Por favor, selecciona un producto.", "error");
            return;
        }

        const clienteId = localStorage.getItem("clienteId");
        const carritoKey = "carrito_" + clienteId; // Cambia la clave según necesites
        let carrito = JSON.parse(localStorage.getItem(carritoKey)) || [];

        // Verificamos si el producto ya está en el carrito
        const indexProducto = carrito.findIndex(producto => producto.id === idProducto);

        if (indexProducto >= 0) {
            // Producto ya existe, actualizamos la cantidad
            carrito[indexProducto].quantity += cantidadProducto;
            // Recalculamos el precio total del producto
            carrito[indexProducto].price = precioProducto * carrito[indexProducto].quantity;
        } else {
            // Producto no existe, lo agregamos al carrito
            carrito.push({
                id: idProducto,
                name: nombreProducto,
                price: precioProducto,
                quantity: cantidadProducto
            });
        }

        // Guardamos el carrito actualizado en localStorage
        localStorage.setItem(carritoKey, JSON.stringify(carrito));
        updateTotalCarrito();

        function updateTotalCarrito() {
            const clienteId = localStorage.getItem("clienteId");
            const carrito = JSON.parse(localStorage.getItem("carrito_" + clienteId)) || [];

            const total = carrito.reduce((sum, item) => sum + (item.price * item.quantity), 0);
            document.getElementById("totalCarrito").textContent = `$${total.toFixed(2)}`;
        }

        // Opcional: Mostramos un mensaje de éxito o actualizamos la vista del carrito
        Swal.fire({
            icon: 'success',
            title: 'Producto añadido',
            timer: 2000,
            text: `${nombreProducto} ha sido añadido al carrito.`,
        }).then(() => {

        });
    });


    // Función para obtener el carrito del cliente actual
    function obtenerCarritoCliente() {
        const clienteId = localStorage.getItem("clienteId");
        if (!clienteId) {
            console.error("No se ha seleccionado un cliente.");
            return [];
        }

        const carritoCliente = JSON.parse(localStorage.getItem(`carrito_${clienteId}`)) || [];
        return carritoCliente;
    }

    // Cargar el carrito del cliente cuando se selecciona otro cliente
    function cargarCarritoPorCliente(clienteId) {
        // Verificar si ya existe un carrito para el cliente en localStorage
        const carritoExistente = localStorage.getItem(`carrito_${clienteId}`);
        if (carritoExistente) {
            const carritoCliente = JSON.parse(carritoExistente);
            if (carrito.length === 0) {
                carrito.push(...carritoCliente); // Copiar el carrito del cliente seleccionado
            }
        } else {
            // Si no existe, inicializa el carrito vacío en localStorage
            localStorage.setItem(`carrito_${clienteId}`, JSON.stringify([]));
        }
        updateTotalCarrito();
    }


    // Función para añadir productos al carrito
    function addToCart(productId, quantityValue) {
        const selectProducto = document.getElementById('selectProducto');
        const cantidadInput = document.getElementById('cantidadProducto');

        if (productId === "") {
            Swal.fire("Error", "Por favor, selecciona un producto.", "error");
            //alert("Por favor, selecciona un producto.");
            return;
        }

        if (quantityValue <= 0) {

            Swal.fire("Error", "Por favor, ingresa una cantidad válida.", "error");
            //alert("Por favor, ingresa una cantidad válida.");
            return;
        }

        const selectedOption = selectProducto.options[selectProducto.selectedIndex];
        const productName = selectedOption.textContent.trim();
        const productPrice = parseFloat(selectedOption.getAttribute('data-precio').replace('$', '').replace(',', '').trim());

        const existingProductIndex = carrito.findIndex(item => item.id === productId);

        if (existingProductIndex > -1) {
            carrito[existingProductIndex].quantity += quantityValue;
        } else {
            const product = {
                id: productId,
                name: productName,
                price: productPrice,
                quantity: quantityValue
            };
            carrito.push(product);
        }
        guardarCarritoCliente();
        cantidadInput.value = "";

        Swal.fire({
            icon: 'success',
            title: 'Producto añadido',
            timer: 2000,
            text: `${productName} ha sido añadido al carrito.`,
        }).then(() => {

        });

        console.log(`Producto añadido al carrito: ${productId}, Nombre: ${productName}, Cantidad: ${quantityValue}, Precio: ${productPrice}`);
    }

    // Función para eliminar un producto del carrito
    function removeFromCart(productId) {
        const index = carrito.findIndex(item => item.id === productId);
        if (index > -1) {
            carrito.splice(index, 1);
            guardarCarritoCliente();
            //console.log(`Producto eliminado del carrito: ${productId}`);
        } else {
            console.warn(`Producto no encontrado en el carrito: ${productId}`);
        }
    }

    // Función para actualizar el total del carrito
    function updateTotalCarrito() {
        const total = carrito.reduce((sum, item) => sum + (item.price * item.quantity), 0);
        document.getElementById("totalCarrito").textContent = `$${total.toFixed(2)}`;
    }

    // Función para guardar el carrito en localStorage
    function guardarCarritoCliente() {
        const clienteId = localStorage.getItem("clienteId");
        console.log("Carrito antes de guardar:", carrito);
        console.trace("Llamada a guardarCarritoCliente"); // Ver el stack de llamadas
        if (clienteId) {
            localStorage.setItem(`carrito_${clienteId}`, JSON.stringify(carrito));
        }
    }

// Limpiar el carrito cuando el cliente lo desea
    document.getElementById("limpiarCarrito").addEventListener("click", () => {
        Swal.fire({
            icon: 'warning',
            title: '¿Seguro que quieres limpiar el carrito?',
            text: 'Esto eliminará todos los productos del carrito.',
            showCancelButton: true,
            confirmButtonText: 'Sí, limpiar',
            cancelButtonText: 'Cancelar',
        }).then((result) => {
            if (result.isConfirmed) {
                const clienteId = localStorage.getItem("clienteId");
                if (clienteId) {
                    // Eliminar el carrito de localStorage
                    localStorage.removeItem(`carrito_${clienteId}`);
                    carrito.length = 0;  // Vaciar el carrito en memoria
                    updateTotalCarrito();  // Actualizar el total del carrito
                    Swal.fire({
                        icon: 'success',
                        title: 'Carrito Vacio',
                        timer: 2000,
                        text: 'El carrito se limpio correctamente.',
                    }).then(() => {

                    });
                }
            }
        });
    });

});

// Filtrar productos por categoría
function cargarProductos(categoriaId) {
    const selectProducto = document.getElementById('selectProducto');
    for (let option of selectProducto.options) {
        option.style.display = (categoriaId === "" || option.getAttribute('data-categoria') === categoriaId) ? "block" : "none";
    }
    selectProducto.value = "";
}

// Búsqueda de productos por SKU o Nombre
document.addEventListener("DOMContentLoaded", function () {
    const skuInput = document.getElementById("buscarPorSKU");
    const nombreInput = document.getElementById("buscarPorNombre");
    const resultadoBusqueda = document.getElementById("resultadoBusqueda");

    function toggleInputs() {
        const sku = skuInput.value.trim();
        const nombre = nombreInput.value.trim();

        if (sku) {
            nombreInput.disabled = true;
        } else {
            nombreInput.disabled = false;
        }

        if (nombre) {
            skuInput.disabled = true;
        } else {
            skuInput.disabled = false;
        }

        if (!sku && !nombre) {
            resultadoBusqueda.innerHTML = '';
        }
    }

    toggleInputs();

    skuInput.addEventListener("input", toggleInputs);
    nombreInput.addEventListener("input", toggleInputs);

    document.getElementById("btnBuscarProducto").addEventListener("click", function () {
        const sku = skuInput.value.trim();
        const nombre = nombreInput.value.trim();

        if (!sku && !nombre) {
            resultadoBusqueda.innerHTML = '';
            return;
        }

        // URL del endpoint con los parámetros SKU y nombre
        const url = `http://localhost:8080/rest/api/productos/buscarProducto?sku=${sku || ''}&nombre=${nombre || ''}`;

        fetch(url)
                .then(response => {
                    if (!response.ok) {
                        throw new Error("Error en la respuesta del servidor.");
                    }
                    return response.json();
                })
                .then(data => {
                    resultadoBusqueda.innerHTML = '';

                    if (data.length === 0) {
                        resultadoBusqueda.innerHTML = '<div class="alert alert-warning">No se encontraron productos.</div>';
                    } else {
                        const row = document.createElement("div");
                        row.classList.add("row", "justify-content-center");

                        data.forEach(producto => {
                            const card = document.createElement("div");
                            card.classList.add("col-md-3", "mb-4");

                            // Convertir byte[] a base64
                            //const byteArray = new Uint8Array(producto.imagen);
                            //const binaryString = byteArray.reduce((acc, byte) => acc + String.fromCharCode(byte), '');
                            //const base64Image = btoa(binaryString);

                            card.innerHTML = `
                            <div class="card h-100">
                                <div class="card-body">
                                    <h5 class="card-title">${producto.nombre}</h5>
                                    <p class="card-text">SKU: ${producto.sku}</p>
                                    <p class="card-text">Precio: $${producto.precioVenta}</p>
                                    <p class="card-text">Stock: ${producto.stock}</p>
                                    <input type="number" class="form-control mb-2" id="cantidad" value="1" min="1" max="${producto.stock}">
                                    <input type="hidden" class="form-control mb-2" id="productoId" value="${producto.id}" min="1">
                                    <button class="btn btn-primary" onclick="addToCart('${producto.id}', '${producto.nombre}', ${producto.precioVenta}, ${producto.stock})">Añadir al Carrito</button>
                                </div>
                            </div>
                        `;
                            row.appendChild(card);
                        });

                        resultadoBusqueda.appendChild(row);
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                    resultadoBusqueda.innerHTML = '<div class="alert alert-danger">Error al realizar la búsqueda.</div>';
                });

        // Función para añadir el producto al carrito
        window.addToCart = function (productId, productName, productPrice, stock) {
            const clienteLocalStorage = localStorage.getItem("clienteId");

            if (!clienteLocalStorage) {
                Swal.fire({
                    icon: 'error',
                    title: 'Cliente no seleccionado',
                    text: 'Por favor, seleccione un cliente antes de añadir productos al carrito.',
                });
                return;
            }

            const cantidadInput = document.getElementById('cantidad');
            let cantidad = parseInt(cantidadInput.value);

            if (cantidad < 1 || cantidad > stock) {
                Swal.fire("Error", "Cantidad no válida.", "error");
                return;
            }

            const clienteId = localStorage.getItem("clienteId");
            let carrito = JSON.parse(localStorage.getItem("carrito_" + clienteId)) || [];

            const producto = {
                id: productId,
                name: productName,
                price: productPrice,
                quantity: cantidad
            };

            const index = carrito.findIndex(item => item.id === productId);
            if (index > -1) {
                carrito[index].quantity += cantidad;
            } else {
                carrito.push(producto);
            }

            localStorage.setItem("carrito_" + clienteId, JSON.stringify(carrito));
            updateTotalCarrito();
            skuInput.value = '';
            nombreInput.value = '';
            skuInput.disabled = false;
            nombreInput.disabled = false;
            resultadoBusqueda.innerHTML = '';

            Swal.fire({
                icon: 'success',
                title: 'Producto añadido',
                timer: 2000,
                text: `${productName} ha sido añadido al carrito.`,
            });

            console.log(`Producto añadido al carrito: ${productId}, Nombre: ${productName}, Cantidad: ${cantidad}, Precio: ${productPrice}`);
        };

        function updateTotalCarrito() {
            const clienteId = localStorage.getItem("clienteId");
            const carrito = JSON.parse(localStorage.getItem("carrito_" + clienteId)) || [];

            const total = carrito.reduce((sum, item) => sum + (item.price * item.quantity), 0);
            document.getElementById("totalCarrito").textContent = `$${total.toFixed(2)}`;
        }

    });
});