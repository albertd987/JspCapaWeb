package filter;

import java.io.IOException;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * Filtre per protegir pàgines que requereixen autenticació
 * 
 * Responsabilitat única: Verificar que l'usuari està autenticat abans d'accedir a recursos protegits
 * 
 * Funcionalitat:
 * - Intercepta TOTES les peticions (urlPatterns = "/*")
 * - Comprova si hi ha sessió activa amb usuari autenticat
 * - Si NO està autenticat → redirigeix a LoginServlet
 * - Si SÍ està autenticat → permet accés
 * 
 * Excepcions (pàgines públiques):
 * - /LoginServlet (formulari de login)
 * - /css/* (arxius CSS)
 * - /js/* (arxius JavaScript)
 * - /images/* (imatges)
 * 
 * @author DomenechObiolAlbert
 * @version 1.0
 */
@WebFilter(filterName = "AuthenticationFilter", urlPatterns = {"/*"})
public class AuthenticationFilter implements Filter {
    
    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // No cal inicialitzar res
    }
    
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        
        String requestURI = httpRequest.getRequestURI();
        String contextPath = httpRequest.getContextPath();
        
        // Obtenir la ruta relativa (sense context path)
        String path = requestURI.substring(contextPath.length());
        
        // Pàgines públiques (sense autenticació requerida)
        boolean isPublicResource = path.equals("/LoginServlet") ||
                                    path.startsWith("/css/") ||
                                    path.startsWith("/js/") ||
                                    path.startsWith("/images/") ||
                                    path.startsWith("/fonts/") ||
                                    path.equals("/");
        
        // Si és recurs públic, deixar passar
        if (isPublicResource) {
            chain.doFilter(request, response);
            return;
        }
        
        // Comprovar si hi ha sessió activa
        HttpSession session = httpRequest.getSession(false);
        boolean isAuthenticated = (session != null && session.getAttribute("usuariAutenticat") != null);
        
        if (isAuthenticated) {
            // Usuari autenticat → permetre accés
            chain.doFilter(request, response);
        } else {
            // Usuari NO autenticat → redirigir a login
            httpResponse.sendRedirect(contextPath + "/LoginServlet");
        }
    }
    
    @Override
    public void destroy() {
        // No cal alliberar recursos
    }
}