package controller;

import java.io.IOException;

import org.mindrot.jbcrypt.BCrypt;

import dao.DAOFactory;
import dao.IDAOUsuari;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Usuari;

/**
 * Servlet per gestionar autenticació d'usuaris
 * 
 * Responsabilitat única: Processar login/logout amb verificació Bcrypt
 * 
 * Funcionalitats:
 * - GET: Mostrar formulari de login (login.jsp)
 * - POST action=login: Verificar credencials i crear sessió
 * - POST action=logout: Tancar sessió
 * 
 * Seguretat:
 * - Verificació Bcrypt del password
 * - Validació d'usuari actiu
 * - Registre d'últim accés
 * - Sessions HTTP segures
 * 
 * @author DomenechObiolAlbert
 * @version 1.0
 */
@WebServlet(name = "LoginServlet", urlPatterns = {"/LoginServlet"})
public class LoginServlet extends HttpServlet {
    
    private IDAOUsuari daoUsuari;
    
    @Override
    public void init() throws ServletException {
        try {
            this.daoUsuari = DAOFactory.getDAOUsuari();
            log(" LoginServlet inicialitzat correctament");
        } catch (Exception e) {
            log(" Error inicialitzant LoginServlet: " + e.getMessage());
            throw new ServletException("No es pot inicialitzar el DAO d'Usuari", e);
        }
    }
    
    /**
     * Gestiona peticions GET: mostra el formulari de login
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Si ja està autenticat, redirigir a pàgina principal
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("usuariAutenticat") != null) {
            response.sendRedirect("ProducteServlet");
            return;
        }
        
        // Mostrar formulari de login
        request.getRequestDispatcher("/login.jsp").forward(request, response);
    }
    
    /**
     * Gestiona peticions POST: login o logout
     * 
     * Accions:
     * - action=login: Verificar credencials
     * - action=logout: Tancar sessió
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        
        if (action == null) {
            action = "login";  // Per defecte: login
        }
        
        switch (action) {
            case "login":
                processarLogin(request, response);
                break;
            case "logout":
                processarLogout(request, response);
                break;
            default:
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Acció no reconeguda");
        }
    }
    
    /**
     * Processa el login d'un usuari
     * 
     * Flux:
     * 1. Validar entrada (username i password no buits)
     * 2. Buscar usuari a BD per username
     * 3. Verificar password amb BCrypt.checkpw()
     * 4. Crear sessió HTTP
     * 5. Actualitzar us_ultim_acces
     * 6. Redirigir a pàgina principal
     */
    private void processarLogin(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        
        // Validació d'entrada
        if (username == null || username.trim().isEmpty() || 
            password == null || password.trim().isEmpty()) {
            
            request.setAttribute("error", "Usuari i contrasenya són obligatoris");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
            return;
        }
        
        try {
            // Buscar usuari per username
            Usuari usuari = daoUsuari.findByUsername(username.trim());
            
            // Verificar si existeix
            if (usuari == null) {
                log("Intent de login fallit: usuari '" + username + "' no trobat");
                request.setAttribute("error", "Usuari o contrasenya incorrectes");
                request.getRequestDispatcher("/login.jsp").forward(request, response);
                return;
            }
            
            // Verificar si està actiu
            if (!usuari.isActiu()) {
                log("Intent de login fallit: usuari '" + username + "' desactivat");
                request.setAttribute("error", "Aquest usuari està desactivat");
                request.getRequestDispatcher("/login.jsp").forward(request, response);
                return;
            }
            
            // Verificar password amb Bcrypt
            boolean passwordCorrecte = BCrypt.checkpw(password, usuari.getUsPassword());
            
            if (!passwordCorrecte) {
                log("️Intent de login fallit: contrasenya incorrecta per usuari '" + username + "'");
                request.setAttribute("error", "Usuari o contrasenya incorrectes");
                request.getRequestDispatcher("/login.jsp").forward(request, response);
                return;
            }
            
            // ✅ LOGIN EXITÓS
            
            // Crear sessió HTTP
            HttpSession session = request.getSession(true);
            session.setAttribute("usuariAutenticat", usuari);
            session.setAttribute("usernameAutenticat", usuari.getUsUsername());
            session.setAttribute("nomUsuari", usuari.getUsNom());
            
            // Actualitzar timestamp últim accés
            try {
                daoUsuari.updateUltimAcces(usuari.getUsId());
            } catch (Exception e) {
                log("Error actualitzant últim accés: " + e.getMessage());
                // No fallem el login per això
            }
            
            log("Login exitós: " + usuari.getUsUsername());
            
            // Redirigir a pàgina principal
            response.sendRedirect("ProducteServlet");
            
        } catch (Exception e) {
            log("Error processant login: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Error del sistema. Contacti amb l'administrador.");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
        }
    }
    
    /**
     * Processa el logout d'un usuari
     * 
     * Flux:
     * 1. Invalidar sessió HTTP
     * 2. Redirigir a pàgina de login
     */
    private void processarLogout(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        
        if (session != null) {
            String username = (String) session.getAttribute("usernameAutenticat");
            session.invalidate();
            log("Logout exitós: " + username);
        }
        
        // Redirigir a login
        response.sendRedirect("LoginServlet");
    }
}