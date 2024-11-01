/* 
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/JavaScript.js to edit this template
 */


function filtrarTabla() {
    // Obtener el valor del filtro y la búsqueda
    const filtro = document.getElementById("filtro").value;
    const busqueda = document.getElementById("busqueda").value.toLowerCase();
    const tabla = document.getElementById("tablaClientes");
    const filas = tabla.getElementsByTagName("tbody")[0].getElementsByTagName("tr");

    // Iterar sobre las filas de la tabla y aplicar el filtro
    for (let i = 0; i < filas.length; i++) {
        const celdas = filas[i].getElementsByTagName("td");
        let coincide = false;

        // Aplicar el filtro seleccionado
        switch (filtro) {
            case "identificador":
                coincide = celdas[0].textContent.toLowerCase().includes(busqueda);
                break;
            case "nombre":
                coincide = celdas[1].textContent.toLowerCase().includes(busqueda);
                break;
            case "email":
                coincide = celdas[2].textContent.toLowerCase().includes(busqueda);
                break;
            case "telefono":
                coincide = celdas[3].textContent.toLowerCase().includes(busqueda);
                break;
            case "direccion":
                coincide = celdas[4].textContent.toLowerCase().includes(busqueda);
                break;
            case "fecha":
                coincide = celdas[5].textContent.toLowerCase().includes(busqueda);
                break;
            case "ninguno":
                // Verificar en todas las columnas si hay coincidencias
                for (let j = 0; j < celdas.length; j++) {
                    if (celdas[j].textContent.toLowerCase().includes(busqueda)) {
                        coincide = true;
                        break;
                    }
                }
                break;
        }

        // Mostrar u ocultar la fila dependiendo de si hay coincidencia
        filas[i].style.display = coincide ? "" : "none";
    }
}

let ordenEstado = 0; // 0: Normal, 1: Ascendente, 2: Descendente
let filasOriginales = []; // Array para guardar las filas originales

function cargarFilasOriginales() {
    const tabla = document.getElementById("tablaClientes");
    const tbody = tabla.querySelector("tbody");
    const filas = Array.from(tbody.querySelectorAll("tr"));
    filasOriginales = filas.slice(); // Hacemos una copia de las filas originales
}

function ordenarTabla(columnaIndex) {
    const tabla = document.getElementById("tablaClientes");
    const tbody = tabla.querySelector("tbody");
    const filas = Array.from(tbody.querySelectorAll("tr"));

    // Alternar el estado de ordenación
    ordenEstado = (ordenEstado + 1) % 3;

    // Limpiar los iconos
    limpiarIconos();

    if (ordenEstado === 1) {
        filas.sort((a, b) => compararFilas(a, b, columnaIndex, true));
        // Mostrar ícono ascendente
        mostrarIcono(columnaIndex, "↑");
    } else if (ordenEstado === 2) {
        filas.sort((a, b) => compararFilas(a, b, columnaIndex, false));
        // Mostrar ícono descendente
        mostrarIcono(columnaIndex, "↓");
    } else {
        // Volver a la tabla original
        resetearTabla(tbody);
        return;
    }

    // Limpiar el tbody y agregar las filas ordenadas
    tbody.innerHTML = '';
    filas.forEach(fila => tbody.appendChild(fila));
}

function compararFilas(a, b, columnaIndex, ascendente) {
    const celdaA = a.cells[columnaIndex].innerText;
    const celdaB = b.cells[columnaIndex].innerText;

    // Lógica de comparación según el tipo de dato
    if (columnaIndex === 0) { // Identificador
        return ascendente
            ? parseInt(celdaA) - parseInt(celdaB)
            : parseInt(celdaB) - parseInt(celdaA);
    } else if (columnaIndex === 5) { // Fecha de Registro
        return ascendente
            ? new Date(celdaA) - new Date(celdaB)
            : new Date(celdaB) - new Date(celdaA);
    } else { // Nombre, Email, Teléfono, Dirección
        return ascendente
            ? celdaA.localeCompare(celdaB)
            : celdaB.localeCompare(celdaA);
    }
}

function resetearTabla(tbody) {
    tbody.innerHTML = '';
    filasOriginales.forEach(fila => tbody.appendChild(fila.cloneNode(true))); // Clonamos las filas originales
    limpiarIconos(); // Limpiar los iconos al resetear
}

function mostrarIcono(columnaIndex, simbolo) {
    const icono = document.getElementById(`iconoOrden${columnaIndex}`);
    if (simbolo === "↑") {
        icono.innerHTML = "&#8593;"; // Flecha hacia arriba
    } else if (simbolo === "↓") {
        icono.innerHTML = "&#8595;"; // Flecha hacia abajo
    } else {
        icono.innerText = ''; // Limpiar símbolo
    }
}


function limpiarIconos() {
    for (let i = 0; i < 6; i++) { // Asumiendo que hay 6 columnas
        const icono = document.getElementById(`iconoOrden${i}`);
        icono.innerText = ''; // Limpiar el símbolo
    }
}

// Llama a cargarFilasOriginales al cargar la página para almacenar las filas originales
document.addEventListener('DOMContentLoaded', cargarFilasOriginales);
