let currentPage = 1;
const productsPerPage = 10;

document.addEventListener('DOMContentLoaded', () => {
    // Inicializa la tabla al cargar el documento
    const tabla = document.getElementById("tablaProductos");
    const tr = tabla.getElementsByTagName("tr");

    // Obtiene las filas visibles al inicio
    const visibleRows = Array.from(tr).slice(1); // Excluye el encabezado
    console.log("Filas visibles al cargar:", visibleRows); // Depuración
    actualizarPaginacion(visibleRows);
});

function cargarProductos() {
    var select = document.getElementById("categoriaSelect");
    var categoriaNombre = select.options[select.selectedIndex].text; // Obtiene el nombre de la categoría seleccionada

    // Redirigir al servlet con el parámetro nombreCategoria
    window.location.href = "listarProductos?nombreCategoria=" + categoriaNombre;
}

// Script de filtrado de tabla
function filtrarTabla() {
    const input = document.getElementById('busqueda');
    const filter = input.value.toLowerCase();
    const filtroSeleccionado = document.getElementById('filtro').value;
    const tabla = document.getElementById("tablaProductos");
    const tr = tabla.getElementsByTagName("tr");

    let visibleRows = []; // Inicializa el arreglo de filas visibles

    for (let i = 1; i < tr.length; i++) { // Comenzamos desde 1 para evitar el encabezado
        const tds = tr[i].getElementsByTagName("td");
        let found = false;

        for (let j = 0; j < tds.length; j++) {
            if (tds[j]) {
                const textoValor = tds[j].textContent || tds[j].innerText;

                // Filtramos según la opción seleccionada
                if (filtroSeleccionado === "todos" ||
                    (filtroSeleccionado === "nombre" && j === 0) || // Nombre en columna 1
                    (filtroSeleccionado === "descripcion" && j === 1) || // Descripción en columna 2
                    (filtroSeleccionado === "sku" && j === 2)) { // SKU en columna 3
                    if (textoValor.toLowerCase().indexOf(filter) > -1) {
                        found = true;
                        break; // Salimos del bucle si se encuentra una coincidencia
                    }
                }
            }
        }

        tr[i].style.display = found ? "" : "none"; // Mostrar o ocultar la fila
        if (found) visibleRows.push(tr[i]); // Agregar a visibleRows si se encontró
    }

    console.log("Filas visibles después de filtrar:", visibleRows); // Depuración

    // Verifica si hay filas visibles antes de actualizar la paginación
    if (visibleRows.length > 0) {
        currentPage = 1; // Reiniciar a la primera página al filtrar
        actualizarPaginacion(visibleRows);
    } else {
        // Si no hay filas visibles, ocultar la paginación
        document.getElementById("paginacion").style.display = "none";
    }
}

// Función para actualizar la paginación
function actualizarPaginacion(visibleRows) {
    // Verifica que visibleRows no sea undefined
    if (!visibleRows || !Array.isArray(visibleRows)) {
        //console.error("visibleRows no es un arreglo válido", visibleRows); // Depuración
        return; // Termina la función si no es un arreglo
    }

    const totalRows = visibleRows.length; // Total de filas visibles después del filtrado
    const totalPages = Math.ceil(totalRows / productsPerPage);

    // Muestra u oculta la paginación según el número de filas
    document.getElementById("paginacion").style.display = totalRows > productsPerPage ? "block" : "none";

    // Generar los botones de paginación
    const paginacionDiv = document.getElementById("paginacion");
    paginacionDiv.innerHTML = "";
    for (let i = 1; i <= totalPages; i++) {
        const button = document.createElement("button");
        button.innerText = i;
        button.classList.add("btn", "btn-secondary", "me-1");
        button.onclick = () => {
            currentPage = i;
            mostrarProductos(visibleRows);
        };
        paginacionDiv.appendChild(button);
    }

    mostrarProductos(visibleRows); // Mostrar productos de la primera página
}

// Función para mostrar los productos de la página actual
function mostrarProductos(visibleRows) {
    const tabla = document.getElementById("tablaProductos");
    const tr = tabla.getElementsByTagName("tr");
    const start = (currentPage - 1) * productsPerPage;
    const end = start + productsPerPage;

    for (let i = 1; i < tr.length; i++) {
        tr[i].style.display = "none"; // Ocultar todas las filas
    }

    // Mostrar solo las filas visibles de la página actual
    for (let i = start; i < end; i++) {
        if (visibleRows[i]) {
            visibleRows[i].style.display = ""; // Mostrar la fila
        }
    }
}
