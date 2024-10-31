/* 
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/JavaScript.js to edit this template
 */


//script de filtrado de tabla
function filtrarTabla() {
    const input = document.getElementById('busqueda');
    const filter = input.value.toLowerCase();
    const filtroSeleccionado = document.getElementById('filtro').value;
    const tabla = document.getElementById("tablaPedidos");
    const tr = tabla.getElementsByTagName("tr");

    for (let i = 1; i < tr.length; i++) { // comenzamos desde 1 para evitar el encabezado
        const tds = tr[i].getElementsByTagName("td");
        let found = false;

        for (let j = 0; j < tds.length; j++) {
            if (tds[j]) {
                const textoValor = tds[j].textContent || tds[j].innerText;

                // Filtramos según la opción seleccionada
                if (filtroSeleccionado === "todos" || 
                    (filtroSeleccionado === "id" && j === 0) ||
                    (filtroSeleccionado === "fecha" && j === 1) ||
                    (filtroSeleccionado === "estado" && j === 2) ||
                    (filtroSeleccionado === "total" && j === 3) ||
                    (filtroSeleccionado === "cliente" && j === 4)) {
                    if (textoValor.toLowerCase().indexOf(filter) > -1) {
                        found = true;
                        break; // salimos del bucle si se encuentra una coincidencia
                    }
                }
            }
        }

        tr[i].style.display = found ? "" : "none"; // Mostrar o ocultar la fila
    }
}
