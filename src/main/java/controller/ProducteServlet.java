package controller;

import java.io.IOException;
import java.util.List;

import dao.DAOFactory;
import dao.IDAOProducte;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Producte;

/**
 * Servlet controlador per gestionar operacions CRUD de Productes
 * 
 * Responsabilitats:
 * - Llistar productes (GET)
 * - Filtrar productes per codi (GET amb paràmetre)
 * - Crear nou producte (POST amb action=create)
 * - Actualitzar producte (POST amb action=update)
 * - Eliminar producte (POST amb action=delete)
 * 
 * @author DomenechObiolAlbert
 * @version 1.1 - Afegida validació de components en creació
 */
@WebServlet(name = "ProducteServlet", urlPatterns = {"/ProducteServlet"})
public class ProducteServlet extends HttpServlet {

    private IDAOProducte daoProducte;

    @Override
    public void init() throws ServletException {
        // Inicialitzar DAO a través del Factory
        try {
            this.daoProducte = DAOFactory.getDAOProducte();
            log("ProducteServlet inicialitzat correctament");
        } catch (Exception e) {
            log("Error inicialitzant ProducteServlet: " + e.getMessage());
            throw new ServletException("No es pot inicialitzar el DAO de Producte", e);
        }
    }

    /**
     * Gestiona peticions GET: llistar i filtrar productes
     * 
     * Paràmetres opcionals:
     * - filtre: Codi de producte per filtrar (LIKE case-insensitive)
     * 
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException
     * @throws IOException
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String filtre = request.getParameter("filtre");
        List<Producte> productes;

        try {
            if (filtre != null && !filtre.trim().isEmpty()) {
                // Filtrar per codi
                productes = daoProducte.filtrarPerCodi(filtre.trim());
                log("Filtrant productes per: " + filtre + " → " + productes.size() + " resultats");
            } else {
                // Llistar tots
                productes = daoProducte.findAll();
                log("Llistant tots els productes → " + productes.size() + " productes");
            }

            // Passar dades a la JSP
            request.setAttribute("productes", productes);
            request.setAttribute("filtre", filtre);
            
            // Forward a la pàgina JSP
            request.getRequestDispatcher("/productes.jsp").forward(request, response);

        } catch (Exception e) {
            log("❌ Error en doGet: " + e.getMessage());
            e.printStackTrace();
            
            // Mostrar error a la JSP
            request.setAttribute("error", "Error carregant productes: " + e.getMessage());
            request.getRequestDispatcher("/productes.jsp").forward(request, response);
        }
    }

    /**
     * Gestiona peticions POST: crear, actualitzar, eliminar productes
     * 
     * Paràmetres requerits:
     * - action: "create", "update" o "delete"
     * 
     * Per CREATE i UPDATE:
     * - codiProducte, nomProducte, descripcioProducte, estocInicial
     * 
     * Per DELETE:
     * - codiProducte
     * 
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException
     * @throws IOException
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Configurar encoding per caràcters especials
        request.setCharacterEncoding("UTF-8");
        
        String action = request.getParameter("action");
        
        if (action == null || action.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, 
                "Paràmetre 'action' requerit");
            return;
        }

        try {
            switch (action.toLowerCase()) {
                case "create":
                    handleCreate(request, response);
                    break;
                    
                case "update":
                    handleUpdate(request, response);
                    break;
                    
                case "delete":
                    handleDelete(request, response);
                    break;
                    
                default:
                    response.sendError(HttpServletResponse.SC_BAD_REQUEST, 
                        "Acció desconeguda: " + action);
            }
        } catch (Exception e) {
            log("Error en doPost [" + action + "]: " + e.getMessage());
            e.printStackTrace();
            
            request.setAttribute("error", "Error processant l'operació: " + e.getMessage());
            doGet(request, response);
        }
    }

    /**
     * Gestiona la creació d'un nou producte
     * 
     * MODIFICACIÓ v1.1: Afegida validació de components
     * - Si el producte no té components, redirigeix a afegir-components.jsp
     * - Si el producte té components, mostra missatge d'èxit
     */
    private void handleCreate(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Recollir paràmetres del formulari
        String codi = request.getParameter("codiProducte");
        String nom = request.getParameter("nomProducte");
        String descripcio = request.getParameter("descripcioProducte");
        String estocStr = request.getParameter("estocInicial");

        // Validar paràmetres
        if (codi == null || codi.trim().isEmpty() ||
            nom == null || nom.trim().isEmpty()) {
            
            request.setAttribute("error", "Codi i nom són obligatoris");
            doGet(request, response);
            return;
        }

        try {
            // Crear objecte Producte
            Producte producte = new Producte();
            producte.setPrCodi(codi.trim());
            producte.setItCodi(codi.trim()); // pr_codi == it_codi
            producte.setItNom(nom.trim());
            producte.setItDesc(descripcio != null ? descripcio.trim() : "");
            producte.setItTipus("P"); // Tipus: Producte
            
            // Parse estoc (per defecte 0)
            int estoc = 0;
            if (estocStr != null && !estocStr.trim().isEmpty()) {
                estoc = Integer.parseInt(estocStr);
            }
            producte.setItStock(estoc);

            // Inserir a la base de dades
            boolean exit = daoProducte.insertar(producte);

            if (exit) {
                log("Producte creat: " + codi);
                
                // 🔍 VALIDACIÓ DE COMPONENTS (NOU en v1.1)
                boolean teComponents = daoProducte.teComponents(codi.trim());
                
                if (teComponents) {
                    // Cas excepcional: producte ja té components (per exemple, si s'està recreant)
                    request.setAttribute("success", "Producte creat correctament");
                    doGet(request, response);
                } else {
                    // Cas normal: producte sense components → redirigir a afegir components
                    log("⚠️ Producte " + codi + " sense components. Redirigint a afegir-components.jsp");
                    response.sendRedirect("ComponentProducteServlet?producte=" + codi.trim() + 
                                        "&nouProducte=true");
                }
                
            } else {
                log("❌ No s'ha pogut crear el producte: " + codi);
                request.setAttribute("error", "No s'ha pogut crear el producte");
                doGet(request, response);
            }

        } catch (NumberFormatException e) {
            request.setAttribute("error", "L'estoc ha de ser un número enter");
            doGet(request, response);
        } catch (Exception e) {
            log("Error creant producte: " + e.getMessage());
            request.setAttribute("error", "Error creant producte: " + e.getMessage());
            doGet(request, response);
        }
    }

    /**
     * Gestiona l'actualització d'un producte existent
     */
    private void handleUpdate(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String codi = request.getParameter("codiProducte");
        String nom = request.getParameter("nomProducte");
        String descripcio = request.getParameter("descripcioProducte");
        String estocStr = request.getParameter("estocInicial");

        if (codi == null || codi.trim().isEmpty()) {
            request.setAttribute("error", "Codi de producte requerit");
            doGet(request, response);
            return;
        }

        try {
            Producte producte = daoProducte.findById(codi.trim());
            
            if (producte == null) {
                request.setAttribute("error", "Producte no trobat: " + codi);
                doGet(request, response);
                return;
            }

            // Actualitzar camps
            if (nom != null && !nom.trim().isEmpty()) {
                producte.setItNom(nom.trim());
            }
            if (descripcio != null) {
                producte.setItDesc(descripcio.trim());
            }
            if (estocStr != null && !estocStr.trim().isEmpty()) {
                producte.setItStock(Integer.parseInt(estocStr));
            }

            boolean exit = daoProducte.actualitzar(producte);

            if (exit) {
                log("Producte actualitzat: " + codi);
                request.setAttribute("success", "Producte actualitzat correctament");
            } else {
                log("No s'ha pogut actualitzar el producte: " + codi);
                request.setAttribute("error", "No s'ha pogut actualitzar el producte");
            }

        } catch (NumberFormatException e) {
            request.setAttribute("error", "L'estoc ha de ser un número enter");
        } catch (Exception e) {
            log("Error actualitzant producte: " + e.getMessage());
            request.setAttribute("error", "Error actualitzant producte: " + e.getMessage());
        }

        // Recarregar llista
        doGet(request, response);
    }

    /**
     * Gestiona l'eliminació d'un producte
     */
    private void handleDelete(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String codi = request.getParameter("codiProducte");

        if (codi == null || codi.trim().isEmpty()) {
            request.setAttribute("error", "Codi de producte requerit per eliminar");
            doGet(request, response);
            return;
        }

        try {
            boolean exit = daoProducte.eliminar(codi.trim());

            if (exit) {
                log("Producte eliminat: " + codi);
                request.setAttribute("success", "Producte eliminat correctament");
            } else {
                log("No s'ha pogut eliminar el producte: " + codi);
                request.setAttribute("error", "No s'ha pogut eliminar el producte");
            }

        } catch (Exception e) {
            log("Error eliminant producte: " + e.getMessage());
            request.setAttribute("error", "Error eliminant producte: " + e.getMessage());
        }

        // Recarregar llista
        doGet(request, response);
    }

    @Override
    public String getServletInfo() {
        return "Servlet per gestionar operacions CRUD de Productes";
    }
}