
import com.google.gson.JsonObject;
import Persistencia.ConexionAPI;
import java.io.IOException;
import java.net.URLEncoder;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(urlPatterns = {"/login"})
public class LoginServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Redirige a Login.jsp si se accede con GET
        request.getRequestDispatcher("Login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String userName = request.getParameter("usuario");
        String password = request.getParameter("password");

        try {
            // Crear el cuerpo del formulario URL codificado
            StringBuilder postData = new StringBuilder();
            postData.append("usuario=").append(URLEncoder.encode(userName, "UTF-8"));
            postData.append("&password=").append(URLEncoder.encode(password, "UTF-8"));

            // Hacer la solicitud POST a la API de login
            JsonObject apiResponse = ConexionAPI.postRequestForm("/login/", postData.toString());

            // Verificamos si la respuesta es exitosa (código 200)
            if (apiResponse != null && apiResponse.has("id")) {
                // Si el login es exitoso, obtenemos el ID y nombre del vendedor
                Integer idVendedor = apiResponse.get("id").getAsInt();
                String nombre = apiResponse.get("nombre").getAsString();

                // Creamos la sesión y guardamos el usuario y el idVendedor
                HttpSession session = request.getSession();
                session.setAttribute("usuario", userName);
                session.setAttribute("idVendedor", idVendedor);
                session.setAttribute("nombre", nombre);  // Guardamos el nombre también en la sesión

                // Redirigimos al Home.jsp
                response.sendRedirect("Home.jsp");
            } else {
                // Si la respuesta no tiene el ID, fue un fallo en el login
                request.setAttribute("errorMessage", "Usuario o contraseña incorrectos.");
                request.getRequestDispatcher("Login.jsp").forward(request, response);
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Hubo un error al procesar el login.");
            request.getRequestDispatcher("Login.jsp").forward(request, response);
        }
    }

    @Override
    public String getServletInfo() {
        return "Servlet para validar credenciales y gestionar inicio de sesión";
    }
}
