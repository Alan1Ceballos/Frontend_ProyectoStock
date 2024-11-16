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
