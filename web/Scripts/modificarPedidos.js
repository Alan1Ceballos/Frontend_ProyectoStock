/* 
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/ClientSide/javascript.js to edit this template
 */

function eliminarProducto(boton) {
    boton.closest('tr').remove();
    actualizarTotal(); // Actualiza el total al eliminar un producto
}

function cargarProductos(categoriaId) {
    const selectProducto = document.getElementById('selectProducto');

    // Iterar sobre las opciones del select
    for (let option of selectProducto.options) {
        // Si la categoría seleccionada es vacía (todas las categorías) o la opción tiene el mismo ID de categoría
        option.style.display = (categoriaId === "" || option.getAttribute('data-categoria') === categoriaId) ? "block" : "none";
    }

    // Resetea la selección del producto
    selectProducto.value = "";
}



function agregarProducto() {
    const productoId = document.getElementById('selectProducto').value;
    const cantidad = document.getElementById('cantidadProducto').value;

    if (productoId && cantidad) {
        const selectProducto = document.getElementById('selectProducto');
        const selectedIndex = selectProducto.selectedIndex;

        // Verificar si se ha seleccionado una opción válida
        if (selectedIndex > 0) {  // Ignorar la opción "Productos" (índice 0)
            const selectedOption = selectProducto.options[selectedIndex];
            const nombreProducto = selectedOption.text;
            const precioProducto = selectedOption.getAttribute('data-precio');

            if (!precioProducto) {
                alert("El producto no tiene precio definido.");
                return;
            }

            const productosTable = document.getElementById('productosTable').getElementsByTagName('tbody')[0];
            let productoExistente = false;

            // Recorre todas las filas para verificar si el producto ya existe en la tabla
            for (let fila of productosTable.rows) {
                // Verificar si la fila contiene el input con el idProducto
                const idProductoInput = fila.querySelector('input[name="idProducto[]"]');
                // Si no existe el input, saltamos a la siguiente fila
                if (!idProductoInput)
                    continue;

                const idProductoExistente = idProductoInput.value;

                // Si el producto ya existe, se suma la cantidad a la existente
                if (idProductoExistente === productoId) {
                    const cantidadExistenteInput = fila.querySelector('input[name="cantidadProducto[]"]');
                    const cantidadExistente = parseInt(cantidadExistenteInput.value) || 0;
                    cantidadExistenteInput.value = cantidadExistente + parseInt(cantidad);

                    // Actualiza el total
                    actualizarTotal();
                    productoExistente = true;
                    break;
                }
            }

            // Si el producto no existe, agregamos una nueva fila
            if (!productoExistente) {
                const row = productosTable.insertRow();
                row.innerHTML = `
                    <td><input type="hidden" name="idProducto[]" value="${productoId}">${nombreProducto}</td>
                    <td><input type="number" name="cantidadProducto[]" class="form-control" value="${cantidad}" oninput="actualizarTotal()"></td>
                    <td><input type="text" class="form-control" value="$${precioProducto}" disabled data-precio="${precioProducto}"></td>
                    <input type="hidden" name="precioVenta[]" value="${precioProducto}">
                    <td><button type="button" class="btn btn-danger" onclick="eliminarProducto(this)">Eliminar</button></td>
                `;
            }

            // Limpiar los campos de selección
            document.getElementById('cantidadProducto').value = '';
            document.getElementById('selectProducto').value = '';

            // Actualiza el total
            actualizarTotal();
        } else {
            alert("Por favor, selecciona un producto válido.");
        }
    } else {
        alert("Por favor, seleccione un producto y una cantidad.");
    }
}

function actualizarTotal() {
    let total = 0;
    const filas = document.querySelectorAll('#productosTable tbody tr');
    filas.forEach(fila => {
        const cantidad = parseInt(fila.querySelector('input[name="cantidadProducto[]"]').value) || 0;
        const precio = parseFloat(fila.querySelector('input[type="text"]').value.replace('$', '')) || 0;
        total += cantidad * precio;
    });
    document.getElementById('totalPedido').value = total; // Actualiza el campo visible
    document.getElementById('totalPedidoHidden').value = total; // Actualiza el campo oculto
    console.log("Total actualizado: ", total);
}


document.getElementById('formulario').onsubmit = function (e) {
    e.preventDefault(); // Prevenir el envío automático del formulario

    // Actualizar el total antes de enviar
    actualizarTotal();

    // Obtener todas las filas de la tabla de productos
    const filas = document.querySelectorAll('#productosTable tbody tr');
    
    // Arrays para almacenar los datos del formulario
    const idProductos = [];
    const cantidades = [];
    const preciosVenta = [];

    // Recorrer cada fila de la tabla para obtener los valores
    filas.forEach(fila => {
        const idProductoInput = fila.querySelector('input[name="idProducto[]"]'); // Obtener el id del producto
        const cantidadInput = fila.querySelector('input[name="cantidadProducto[]"]');
        const precioInput = fila.querySelector('input[name="precioVenta[]"]');
        const precioText = fila.querySelector('input[type="text"]');  // Para obtener el precio cuando el input es disabled

        if (cantidadInput && precioText) {
            // Si es una fila preexistente (con un input disabled para el precio), entonces no tiene un idProducto
            const idProducto = idProductoInput ? idProductoInput.value : "";
            const cantidad = cantidadInput.value;
            const precio = parseFloat(precioText.value.replace('$', '').trim());

            // Agregar los valores al arreglo
            idProductos.push(idProducto);
            cantidades.push(cantidad);
            preciosVenta.push(precio);
        }
    });

    // Verificar que los arrays tengan la misma longitud
    if (idProductos.length !== cantidades.length || cantidades.length !== preciosVenta.length) {
        alert("Error: Las listas de productos, cantidades y precios no son consistentes.");
        return false; // Prevenir el envío del formulario si hay inconsistencias
    }

    // Mostrar los datos en la consola antes de enviar
    console.log("Total antes de enviar: ", document.querySelector('input[name="totalPedido"]').value);
    console.log("idProducto:", idProductos);
    console.log("cantidadProducto:", cantidades);
    console.log("precioVenta:", preciosVenta);

    // Aquí podrías enviar el formulario si todo es correcto
    document.getElementById('formulario').submit();
};

function updateHiddenField() {
    // Obtiene el valor del campo visible y lo asigna al campo oculto
    var visibleField = document.getElementById('totalPedidoVisible');
    var hiddenField = document.getElementById('totalPedidoHidden');
    hiddenField.value = visibleField.value; // Actualiza el campo oculto con el nuevo valor
}


window.onload = function () {
    actualizarTotal();  // Asegurarse de que el total inicial se calcule al cargar la página
};