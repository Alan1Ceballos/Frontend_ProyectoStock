package Persistencia;

import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import java.io.IOException;
import java.io.InputStream;
import org.apache.tomcat.util.http.fileupload.ByteArrayOutputStream;
import org.json.JSONObject;

public class ConexionAPI {

    public static final String urlBase = "http://localhost:8080/rest/api";

    //método para solicitudes POST
    public static JsonObject postRequest(String path, JsonObject jsonBody) throws Exception {
        HttpURLConnection conexion = null;
        try {
            URL url = new URL(urlBase + path);
            conexion = (HttpURLConnection) url.openConnection();
            conexion.setRequestMethod("POST");
            conexion.setRequestProperty("Content-Type", "application/json");
            conexion.setDoOutput(true);
            
            System.out.println("Cuerpo enviado: " + jsonBody.toString());


            //enviamos cuerpo de la solicitud
            try (OutputStream os = conexion.getOutputStream()) {
                os.write(jsonBody.toString().getBytes());
                os.flush();
            }

            int responseCode = conexion.getResponseCode();
            if (responseCode == HttpURLConnection.HTTP_OK) {
                //leemos la respuesta
                try (BufferedReader reader = new BufferedReader(new InputStreamReader(conexion.getInputStream()))) {
                    StringBuilder responseBuilder = new StringBuilder();
                    String line;
                    while ((line = reader.readLine()) != null) {
                        responseBuilder.append(line);
                    }
                    return JsonParser.parseString(responseBuilder.toString()).getAsJsonObject();
                }
            } else {
                throw new Exception("Error en la solicitud POST: Código de respuesta " + responseCode);
            }
        } catch (MalformedURLException e) {
            throw new Exception("URL mal formada: " + e.getMessage(), e);
        } catch (IOException e) {
            throw new Exception("Error de conexión o lectura de respuesta: " + e.getMessage(), e);
        } finally {
            if (conexion != null) {
                conexion.disconnect(); //cerramos la conexión
            }
        }
    }

    public static JsonObject postRequestForm(String path, String formData) throws Exception {
        HttpURLConnection conexion = null;
        try {
            URL url = new URL(urlBase + path);
            conexion = (HttpURLConnection) url.openConnection();
            conexion.setRequestMethod("POST");
            conexion.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
            conexion.setDoOutput(true);

            // Enviamos el cuerpo de la solicitud con los datos codificados en URL
            try (OutputStream os = conexion.getOutputStream()) {
                os.write(formData.getBytes());
                os.flush();
            }

            int responseCode = conexion.getResponseCode();
            if (responseCode == HttpURLConnection.HTTP_OK) {
                // Leemos la respuesta
                try (BufferedReader reader = new BufferedReader(new InputStreamReader(conexion.getInputStream()))) {
                    StringBuilder responseBuilder = new StringBuilder();
                    String line;
                    while ((line = reader.readLine()) != null) {
                        responseBuilder.append(line);
                    }
                    return JsonParser.parseString(responseBuilder.toString()).getAsJsonObject();
                }
            } else {
                throw new Exception("Error en la solicitud POST: Código de respuesta " + responseCode);
            }
        } catch (MalformedURLException e) {
            throw new Exception("URL mal formada: " + e.getMessage(), e);
        } catch (IOException e) {
            throw new Exception("Error de conexión o lectura de respuesta: " + e.getMessage(), e);
        } finally {
            if (conexion != null) {
                conexion.disconnect(); // Cerramos la conexión
            }
        }
    }

    // Método para realizar solicitudes POST
    public static JsonObject postRequestCarrito(String path, JSONObject jsonBody) throws Exception {
        HttpURLConnection conexion = null;
        try {
            // Construir la URL completa
            URL url = new URL(urlBase + path);
            conexion = (HttpURLConnection) url.openConnection();
            conexion.setRequestMethod("POST");
            conexion.setRequestProperty("Content-Type", "application/json");
            conexion.setDoOutput(true);  // Indicar que vamos a enviar datos en el cuerpo de la solicitud

            // Enviar el cuerpo de la solicitud
            try (OutputStream os = conexion.getOutputStream()) {
                byte[] input = jsonBody.toString().getBytes("utf-8");  // Convertir el JSON a bytes en UTF-8
                os.write(input, 0, input.length);  // Escribir los bytes en el flujo de salida
                os.flush();  // Asegurarse de que los datos se envíen
            }

            // Obtener el código de respuesta
            int responseCode = conexion.getResponseCode();
            if (responseCode == HttpURLConnection.HTTP_OK) {
                // Leer la respuesta de la API
                try (BufferedReader reader = new BufferedReader(new InputStreamReader(conexion.getInputStream()))) {
                    StringBuilder responseBuilder = new StringBuilder();
                    String line;
                    while ((line = reader.readLine()) != null) {
                        responseBuilder.append(line);  // Acumular la respuesta
                    }
                    // Parsear la respuesta como un objeto JSON y devolverlo
                    return JsonParser.parseString(responseBuilder.toString()).getAsJsonObject();
                }
            } else {
                // Si la respuesta no es 200 OK, lanzar una excepción con el código de error
                throw new Exception("Error en la solicitud POST: Código de respuesta " + responseCode);
            }
        } catch (MalformedURLException e) {
            throw new Exception("URL mal formada: " + e.getMessage(), e);
        } catch (IOException e) {
            throw new Exception("Error de conexión o lectura de respuesta: " + e.getMessage(), e);
        } finally {
            if (conexion != null) {
                conexion.disconnect(); // Cerrar la conexión para liberar recursos
            }
        }
    }

    //método para solicitudes GET
    public static JsonArray getRequest(String path) throws Exception {
        HttpURLConnection conexion = null;
        try {
            URL url = new URL(urlBase + path);
            conexion = (HttpURLConnection) url.openConnection();
            conexion.setRequestMethod("GET");
            conexion.setRequestProperty("Content-Type", "application/json");

            int responseCode = conexion.getResponseCode();
            if (responseCode == HttpURLConnection.HTTP_OK) {
                //leemos la respuesta
                try (BufferedReader reader = new BufferedReader(new InputStreamReader(conexion.getInputStream()))) {
                    StringBuilder responseBuilder = new StringBuilder();
                    String line;
                    while ((line = reader.readLine()) != null) {
                        responseBuilder.append(line);
                    }
                    return JsonParser.parseString(responseBuilder.toString()).getAsJsonArray();
                }
            } else if (responseCode == HttpURLConnection.HTTP_NO_CONTENT) {
                //si no hay contenido, retornar un arreglo vacío
                return new JsonArray();
            } else {
                throw new Exception("Error en la solicitud GET: Código de respuesta " + responseCode);
            }
        } catch (MalformedURLException e) {
            throw new Exception("URL mal formada: " + e.getMessage(), e);
        } catch (IOException e) {
            throw new Exception("Error de conexión o lectura de respuesta: " + e.getMessage(), e);
        } finally {
            if (conexion != null) {
                conexion.disconnect(); //cerramos la conexión
            }
        }
    }

    public static JsonObject getRequestObj(String path) throws Exception {
        HttpURLConnection conexion = null;
        try {
            URL url = new URL(urlBase + path);
            conexion = (HttpURLConnection) url.openConnection();
            conexion.setRequestMethod("GET");
            conexion.setRequestProperty("Content-Type", "application/json");

            int responseCode = conexion.getResponseCode();
            if (responseCode == HttpURLConnection.HTTP_OK) {
                try (BufferedReader reader = new BufferedReader(new InputStreamReader(conexion.getInputStream()))) {
                    StringBuilder responseBuilder = new StringBuilder();
                    String line;
                    while ((line = reader.readLine()) != null) {
                        responseBuilder.append(line);
                    }
                    return JsonParser.parseString(responseBuilder.toString()).getAsJsonObject();
                }
            } else if (responseCode == HttpURLConnection.HTTP_NOT_FOUND) {
                // Manejar 404
                throw new Exception("Recurso no encontrado (404): " + path);
            } else {
                throw new Exception("Error en la solicitud GET: Código de respuesta " + responseCode);
            }
        } finally {
            if (conexion != null) {
                conexion.disconnect();
            }
        }
    }

    public static byte[] getPdfRequest(String path) throws Exception {
        HttpURLConnection conexion = null;
        try {
            URL url = new URL(urlBase + path);
            conexion = (HttpURLConnection) url.openConnection();
            conexion.setRequestMethod("GET");
            conexion.setRequestProperty("Content-Type", "application/json");

            int responseCode = conexion.getResponseCode();
            if (responseCode == HttpURLConnection.HTTP_OK) {
                // Leemos la respuesta como un flujo de bytes (PDF)
                try (InputStream inputStream = conexion.getInputStream(); ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream()) {

                    byte[] buffer = new byte[4096];
                    int bytesRead;
                    while ((bytesRead = inputStream.read(buffer)) != -1) {
                        byteArrayOutputStream.write(buffer, 0, bytesRead);
                    }
                    return byteArrayOutputStream.toByteArray();
                }
            } else {
                throw new Exception("Error en la solicitud GET: Código de respuesta " + responseCode);
            }
        } catch (MalformedURLException e) {
            throw new Exception("URL mal formada: " + e.getMessage(), e);
        } catch (IOException e) {
            throw new Exception("Error de conexión o lectura de respuesta: " + e.getMessage(), e);
        } finally {
            if (conexion != null) {
                conexion.disconnect(); // Cerramos la conexión
            }
        }
    }

    // Método nuevo: devuelve un String
    public static String getRequestAsString(String path) throws Exception {
        HttpURLConnection conexion = null;
        try {
            URL url = new URL(urlBase + path);
            conexion = (HttpURLConnection) url.openConnection();
            conexion.setRequestMethod("GET");
            conexion.setRequestProperty("Content-Type", "application/json");

            int responseCode = conexion.getResponseCode();
            if (responseCode == HttpURLConnection.HTTP_OK) {
                // Leemos la respuesta
                try (BufferedReader reader = new BufferedReader(new InputStreamReader(conexion.getInputStream()))) {
                    StringBuilder responseBuilder = new StringBuilder();
                    String line;
                    while ((line = reader.readLine()) != null) {
                        responseBuilder.append(line);
                    }
                    return responseBuilder.toString();  // Regresa como String
                }
            } else if (responseCode == HttpURLConnection.HTTP_NO_CONTENT) {
                // Si no hay contenido, retornar un String vacío
                return "";
            } else {
                throw new Exception("Error en la solicitud GET: Código de respuesta " + responseCode);
            }
        } catch (MalformedURLException e) {
            throw new Exception("URL mal formada: " + e.getMessage(), e);
        } catch (IOException e) {
            throw new Exception("Error de conexión o lectura de respuesta: " + e.getMessage(), e);
        } finally {
            if (conexion != null) {
                conexion.disconnect(); // Cerramos la conexión
            }
        }
    }

}
