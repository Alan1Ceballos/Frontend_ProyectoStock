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
    for (let option of selectProducto.options) {
        option.style.display = (categoriaId === "" || option.getAttribute('data-categoria') === categoriaId) ? "block" : "none";
    }
    selectProducto.value = ""; // Resetea la selección del producto
}


// Función para agregar un producto
function agregarProducto() {
    const productoId = document.getElementById('selectProducto').value;
    const cantidad = document.getElementById('cantidadProducto').value;

    if (productoId && cantidad) {
        const selectProducto = document.getElementById('selectProducto');
        const nombreProducto = selectProducto.options[selectProducto.selectedIndex].text;
        const precioProducto = selectProducto.options[selectProducto.selectedIndex].getAttribute('data-precio');

        const productosTable = document.getElementById('productosTable').getElementsByTagName('tbody')[0];
        const row = productosTable.insertRow();
        row.innerHTML = `
            <td><input type="hidden" name="idProducto[]" value="${productoId}">${nombreProducto}</td>
            <td><input type="number" name="cantidadProducto[]" class="form-control" value="${cantidad}" oninput="actualizarTotal()"></td>
            <td><input type="text" class="form-control" value="$${precioProducto}" disabled data-precio="${precioProducto}"></td>
            <input type="hidden" name="precioVenta[]" value="${precioProducto}"> <!-- Campo oculto -->
            <td><button type="button" class="btn btn-danger" onclick="eliminarProducto(this)">Eliminar</button></td>
        `;

        // Limpiar los campos de selección
        document.getElementById('cantidadProducto').value = '';
        document.getElementById('selectProducto').value = '';

        actualizarTotal();
    } else {
        alert("Por favor, seleccione un producto y una cantidad.");
    }
}

function actualizarTotal() {
    let total = 0;
    const filas = document.querySelectorAll('#productosTable tbody tr');
    filas.forEach(fila => {
        const cantidad = parseInt(fila.querySelector('input[name="cantidadProducto[]"]').value) || 0;
        const precio = parseFloat(fila.querySelector('input[data-precio]').getAttribute('data-precio')) || 0;
        total += cantidad * precio;
    });
    document.getElementById('totalPedido').value = total; // Actualiza el campo oculto
    document.getElementById('totalPedidoHidden').value = total;
    console.log("Total actualizado: ", total);
}


// Evento onsubmit del formulario
document.getElementById('formulario').onsubmit = function () {
    actualizarTotal(); // Asegúrate de actualizar el total antes de enviar

    // Verificar que todos los arrays tengan la misma cantidad de elementos
    const idProductos = document.querySelectorAll('input[name="idProducto[]"]');
    const cantidades = document.querySelectorAll('input[name="cantidadProducto[]"]');
    const preciosVenta = document.querySelectorAll('input[name="precioVenta[]"]');

    if (idProductos.length !== cantidades.length || cantidades.length !== preciosVenta.length) {
        alert("Error: Las listas de productos, cantidades y precios no son consistentes.");
        return false; // Prevenir el envío del formulario si hay inconsistencias
    }

    console.log("Total antes de enviar: ", document.querySelector('input[name="totalPedido"]').value);
    console.log("idProducto:", Array.from(idProductos).map(el => el.value));
    console.log("cantidadProducto:", Array.from(cantidades).map(el => el.value));
    console.log("precioVenta:", Array.from(preciosVenta).map(el => el.value));
};


function updateHiddenField() {
    // Obtiene el valor del campo visible y lo asigna al campo oculto
    var visibleField = document.getElementById('totalPedidoVisible');
    var hiddenField = document.getElementById('totalPedidoHidden');
    hiddenField.value = visibleField.value; // Actualiza el campo oculto con el nuevo valor
}









