package controller;

import java.io.IOException;
import java.util.List;

import dao.DAOFactory;
import dao.IDAOComponent;
import dao.IDAOProdItem;
import dao.IDAOUnitatMesura;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Component;
import model.ProdItem;
import model.UnitatMesura;

/**
 * Servlet controlador per gestionar operacions CRUD de Components
 * 
 * Responsabilitats:
 * - Llistar components (GET)
 * - Filtrar components per codi (GET amb paràmetre)
 * - Crear nou component (POST amb action=create)
 * - Actualitzar component (POST amb action=update)
 * - Eliminar component (POST amb action=delete)
 * 
 * IMPORTANT:
 * - El camp cm_preu_mig NO es pot modificar manualment
 * - Es calcula automàticament pels triggers Oracle
 * - Només es pot gestionar via proveïdors (Prov_Comp)
 * 
 * @author DomenechObiolAlbert
 * @version 1.0
 */
@WebServlet(name = "ComponentServlet", urlPatterns = {"/ComponentServlet"})
public class ComponentServlet extends HttpServlet {

    private IDAOComponent daoComponent;
    private IDAOUnitatMesura daoUnitatMesura;

    @Override
    public void init() throws ServletException {
        try {
            this.daoComponent = DAOFactory.getDAOComponent();
            this.daoUnitatMesura = DAOFactory.getDAOUnitatMesura();
            log("✅ ComponentServlet inicialitzat correctament");
        } catch (Exception e) {
            log("❌ Error inicialitzant ComponentServlet: " + e.getMessage());
            throw new ServletException("No es pot inicialitzar els DAOs", e);
        }
    }

    /**
     * Gestiona peticions GET: llistar i filtrar components
     * 
     * Paràmetres opcionals:
     * - filtre: Codi de component per filtrar (LIKE case-insensitive)
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String filtre = request.getParameter("filtre");
        List<Component> components;

        try {
            // Si hi ha filtre, buscar components que coincideixin
            if (filtre != null && !filtre.trim().isEmpty()) {
                components = daoComponent.filtrarPerCodi(filtre.trim());
                request.setAttribute("filtre", filtre.trim());
                log("Filtrant components per codi: " + filtre);
            } else {
                // Llistar tots els components
                components = daoComponent.findAll();
                log("Llistant tots els components");
            }

            request.setAttribute("components", components);
            
            // Forward a la JSP
            request.getRequestDispatcher("/components.jsp").forward(request, response);

        } catch (Exception e) {
            log("Error carregant components: " + e.getMessage());
            request.setAttribute("error", "Error carregant components: " + e.getMessage());
            request.getRequestDispatcher("/components.jsp").forward(request, response);
        }
    }

    /**
     * Gestiona peticions POST: crear, actualitzar, eliminar components
     * 
     * Paràmetres requerits:
     * - action: Tipus d'operació (create/update/delete)
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = request.getParameter("action");

        if (action == null || action.trim().isEmpty()) {
            request.setAttribute("error", "Acció no especificada");
            doGet(request, response);
            return;
        }

        // Dispatch segons l'acció
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
                request.setAttribute("error", "Acció desconeguda: " + action);
                doGet(request, response);
        }
    }

    /**
     * Gestiona la creació d'un nou component
     * 
     * IMPORTANT: cm_preu_mig s'inicialitza automàticament a 0.0 pel trigger Oracle
     */
    private void handleCreate(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String codi = request.getParameter("codiComponent");
        String nom = request.getParameter("nomComponent");
        String descripcio = request.getParameter("descripcioComponent");
        String umCodi = request.getParameter("unitatMesura");
        String codiFabricant = request.getParameter("codiFabricant");
        String estocStr = request.getParameter("estocInicial");

        // Validació bàsica
        if (codi == null || codi.trim().isEmpty()) {
            request.setAttribute("error", "Codi de component requerit");
            doGet(request, response);
            return;
        }

        if (nom == null || nom.trim().isEmpty()) {
            request.setAttribute("error", "Nom de component requerit");
            doGet(request, response);
            return;
        }

        if (umCodi == null || umCodi.trim().isEmpty()) {
            request.setAttribute("error", "Unitat de mesura requerida");
            doGet(request, response);
            return;
        }

        try {
            // Crear objecte Component
            Component component = new Component();
            component.setItCodi(codi.trim().toUpperCase());
            component.setItNom(nom.trim());
            component.setItDesc(descripcio != null ? descripcio.trim() : "");
            component.setCmUmCodi(umCodi.trim());
            component.setCmCodiFabricant(codiFabricant != null ? codiFabricant.trim() : "");
            
            // Estoc inicial (per defecte 0)
            if (estocStr != null && !estocStr.trim().isEmpty()) {
                component.setItStock(Integer.parseInt(estocStr.trim()));
            } else {
                component.setItStock(0);
            }

            // cm_preu_mig s'inicialitza automàticament a 0.0 pel trigger
            component.setCmPreuMig(0.0);

            // Insertar component
            boolean exit = daoComponent.insertar(component);

            if (exit) {
                log("Component creat: " + codi);
                
                // Redirigir a gestió de proveïdors per afegir preus
                log("Redirigint a gestió de proveïdors");
                response.sendRedirect("ProveidorComponentServlet?component=" + codi.trim() + 
                                    "&nouComponent=true");
                
            } else {
                log("No s'ha pogut crear el component: " + codi);
                request.setAttribute("error", "No s'ha pogut crear el component");
                doGet(request, response);
            }

        } catch (NumberFormatException e) {
            request.setAttribute("error", "L'estoc ha de ser un número enter");
            doGet(request, response);
        } catch (Exception e) {
            log("Error creant component: " + e.getMessage());
            request.setAttribute("error", "Error creant component: " + e.getMessage());
            doGet(request, response);
        }
    }

    /**
     * Gestiona l'actualització d'un component existent
     * 
     * IMPORTANT: NO es pot modificar cm_preu_mig (es calcula automàticament)
     */
    private void handleUpdate(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String codi = request.getParameter("codiComponent");
        String nom = request.getParameter("nomComponent");
        String descripcio = request.getParameter("descripcioComponent");
        String umCodi = request.getParameter("unitatMesura");
        String codiFabricant = request.getParameter("codiFabricant");
        String estocStr = request.getParameter("estocInicial");

        if (codi == null || codi.trim().isEmpty()) {
            request.setAttribute("error", "Codi de component requerit");
            doGet(request, response);
            return;
        }

        try {
            Component component = daoComponent.findById(codi.trim());
            
            if (component == null) {
                request.setAttribute("error", "Component no trobat: " + codi);
                doGet(request, response);
                return;
            }

            // Actualitzar camps (EXCEPTE cm_preu_mig!)
            if (nom != null && !nom.trim().isEmpty()) {
                component.setItNom(nom.trim());
            }
            if (descripcio != null) {
                component.setItDesc(descripcio.trim());
            }
            if (umCodi != null && !umCodi.trim().isEmpty()) {
                component.setCmUmCodi(umCodi.trim());
            }
            if (codiFabricant != null) {
                component.setCmCodiFabricant(codiFabricant.trim());
            }
            if (estocStr != null && !estocStr.trim().isEmpty()) {
                component.setItStock(Integer.parseInt(estocStr));
            }

            // ⚠️ IMPORTANT: NO modificar cm_preu_mig!
            // Aquest camp es gestiona automàticament pels triggers Oracle

            boolean exit = daoComponent.actualitzar(component);

            if (exit) {
                log("Component actualitzat: " + codi);
                request.setAttribute("success", "Component actualitzat correctament");
            } else {
                log("No s'ha pogut actualitzar el component: " + codi);
                request.setAttribute("error", "No s'ha pogut actualitzar el component");
            }

        } catch (NumberFormatException e) {
            request.setAttribute("error", "L'estoc ha de ser un número enter");
        } catch (Exception e) {
            log("Error actualitzant component: " + e.getMessage());
            request.setAttribute("error", "Error actualitzant component: " + e.getMessage());
        }

        // Recarregar llista
        doGet(request, response);
    }

    /**
     * Gestiona l'eliminació d'un component
     */
private void handleDelete(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
    
    String codi = request.getParameter("codiComponent");

    if (codi == null || codi.trim().isEmpty()) {
        request.setAttribute("error", "Codi de component requerit per eliminar");
        doGet(request, response);
        return;
    }

    try {
        // ========================================
        // VALIDACIÓ: Verificar si està sent usat en productes
        // ========================================
        log("Verificant si " + codi + " està sent usat en productes...");
        
        IDAOProdItem daoProdItem = DAOFactory.getDAOProdItem();
        List<ProdItem> productesQueElUsen = daoProdItem.getProductesQueUsenItem(codi.trim());
        
        if (!productesQueElUsen.isEmpty()) {
            // ❌ El component està sent usat en productes
            log("⚠️ No es pot eliminar " + codi + " - està sent usat en " + 
                productesQueElUsen.size() + " producte(s)");
            
            // Construir missatge d'error detallat
            StringBuilder missatge = new StringBuilder();
            missatge.append("No pots eliminar el component ").append(codi)
                    .append(" perquè està sent usat en ").append(productesQueElUsen.size())
                    .append(" producte(s):\n\n");
            
            // Llistar fins a 10 productes (per no fer el missatge massa llarg)
            int maxMostrar = Math.min(10, productesQueElUsen.size());
            for (int i = 0; i < maxMostrar; i++) {
                ProdItem uso = productesQueElUsen.get(i);
                missatge.append("• ").append(uso.getPiPrCodi())
                        .append(" (quantitat: ").append(uso.getQuantitat()).append(")\n");
            }
            
            if (productesQueElUsen.size() > 10) {
                missatge.append("... i ").append(productesQueElUsen.size() - 10)
                        .append(" productes més\n");
            }
            
            missatge.append("\n Per eliminar aquest component:\n")
                    .append("1. Ves a la llista de Productes\n")
                    .append("2. Utilitza el botó 'Gestionar Components' de cada producte\n")
                    .append("3. Elimina ").append(codi).append(" de cada producte\n")
                    .append("4. Després podràs eliminar el component");
            
            request.setAttribute("error", missatge.toString());
            doGet(request, response);
            return;
        }
        
        log( codi + " NO està sent usat en cap producte");
        
        // ========================================
        // ELIMINACIÓ: El component NO està sent usat
        // ========================================
        
        log(" Eliminant component: " + codi);
        boolean exit = daoComponent.eliminar(codi.trim());

        if (exit) {
            log("Component eliminat correctament: " + codi);
            request.setAttribute("success", "Component " + codi + " eliminat correctament");
        } else {
            log("No s'ha pogut eliminar el component: " + codi);
            request.setAttribute("error", "No s'ha pogut eliminar el component");
        }

    } catch (Exception e) {
        log("Error eliminant component: " + e.getMessage());
        e.printStackTrace();
        request.setAttribute("error", "Error eliminant component: " + e.getMessage());
    }

    // Recarregar llista
    doGet(request, response);
}
    @Override
    public String getServletInfo() {
        return "Servlet per gestionar operacions CRUD de Components";
    }
}