package controller;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import dao.DAOFactory;
import dao.IDAOComponent;
import dao.IDAOProdItem;
import dao.IDAOProducte;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Component;
import model.ProdItem;
import model.Producte;

/**
 * Servlet per gestionar l'afegit de components a productes
 * 
 * Responsabilitats:
 * - Mostrar formulari per afegir components (GET)
 * - Afegir component a producte (POST action=add)
 * - Eliminar component de producte (POST action=remove)
 * - Finalitzar i validar producte complet (POST action=finalitzar)
 * 
 * @author DomenechObiolAlbert
 * @version 1.0
 */
@WebServlet(name = "ComponentProducteServlet", urlPatterns = {"/ComponentProducteServlet"})
public class ComponentProducteServlet extends HttpServlet {

    private IDAOProducte daoProducte;
    private IDAOComponent daoComponent;
    private IDAOProdItem daoProdItem;

    @Override
    public void init() throws ServletException {
        try {
            this.daoProducte = DAOFactory.getDAOProducte();
            this.daoComponent = DAOFactory.getDAOComponent();
            this.daoProdItem = DAOFactory.getDAOProdItem();
            log("ComponentProducteServlet inicialitzat correctament");
        } catch (Exception e) {
            log("Error inicialitzant ComponentProducteServlet: " + e.getMessage());
            throw new ServletException("No es pot inicialitzar els DAOs", e);
        }
    }

    /**
     * Gestiona peticions GET: carrega la pàgina d'afegir components
     * 
     * Paràmetres requerits:
     * - producte: Codi del producte
     * 
     * Paràmetres opcionals:
     * - nouProducte: "true" si és un producte acabat de crear
     */
@Override
protected void doGet(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
    
    String codiProducte = request.getParameter("producte");
    String nouProducteParam = request.getParameter("nouProducte");
    
    // Validació: codi de producte obligatori
    if (codiProducte == null || codiProducte.trim().isEmpty()) {
        response.sendRedirect("ProducteServlet?error=" + 
            java.net.URLEncoder.encode("Codi de producte requerit", "UTF-8"));
        return;
    }

    try {
        // Carregar dades del producte
        Producte producte = daoProducte.findById(codiProducte.trim());
        
        if (producte == null) {
            response.sendRedirect("ProducteServlet?error=" + 
                java.net.URLEncoder.encode("Producte " + codiProducte + " no trobat", "UTF-8"));
            return;
        }
        
        // Determinar el mode d'operació
        boolean esNouProducte = "true".equalsIgnoreCase(nouProducteParam);
        
        log("Carregant gestió de components per: " + codiProducte + 
            " (mode: " + (esNouProducte ? "NOU" : "EDICIÓ") + ")");

        // Carregar components actuals del producte
        List<ProdItem> componentsAfegits = daoProdItem.getItemsDelProducte(codiProducte.trim());
        log("   Components actuals: " + componentsAfegits.size());
        
        // Carregar llista de TOTS els components disponibles per afegir
        List<Component> componentsDisponibles = daoComponent.findAll();
        log("   Components disponibles totals: " + componentsDisponibles.size());
        
        // Carregar llista de TOTS els productes disponibles (per subproductes)
        List<Producte> productesDisponibles = daoProducte.findAll();
        // Filtrar: no pot contenir-se a si mateix
        productesDisponibles.removeIf(p -> p.getPrCodi().equals(codiProducte));
        log("   Subproductes disponibles: " + productesDisponibles.size());
        
        // Per cada component afegit, carregar el seu nom per mostrar a la taula
        for (ProdItem item : componentsAfegits) {
            // Intentar carregar com a Component
            Component comp = daoComponent.findById(item.getPiItCodi());
            if (comp != null) {
                request.setAttribute("nom_" + item.getPiItCodi(), comp.getItNom());
            } else {
                // Si no és component, és subproducte
                Producte subProd = daoProducte.findById(item.getPiItCodi());
                if (subProd != null) {
                    request.setAttribute("nom_" + item.getPiItCodi(), 
                        subProd.getItNom() + " (Subproducte)");
                }
            }
        }

        // Passar dades a la JSP
        request.setAttribute("producte", producte);
        request.setAttribute("componentsAfegits", componentsAfegits);
        request.setAttribute("componentsDisponibles", componentsDisponibles);
        request.setAttribute("productesDisponibles", productesDisponibles);
        request.setAttribute("esNouProducte", esNouProducte);
        
        // Missatges de feedback
        String success = request.getParameter("success");
        String error = request.getParameter("error");
        if (success != null) request.setAttribute("success", success);
        if (error != null) request.setAttribute("error", error);

        // Forward a la JSP
        request.getRequestDispatcher("/afegir-components.jsp").forward(request, response);

    } catch (Exception e) {
        log("Error carregant gestió de components: " + e.getMessage());
        e.printStackTrace();
        response.sendRedirect("ProducteServlet?error=" + 
            java.net.URLEncoder.encode("Error carregant components: " + e.getMessage(), "UTF-8"));
    }
}
    /**
     * Gestiona peticions POST: afegir, eliminar o finalitzar components
     * 
     * Paràmetres requerits:
     * - action: "add", "remove" o "finalitzar"
     * - producte: Codi del producte
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        
        String action = request.getParameter("action");
        String codiProducte = request.getParameter("producte");
        
        if (action == null || action.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Paràmetre 'action' requerit");
            return;
        }
        
        if (codiProducte == null || codiProducte.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Paràmetre 'producte' requerit");
            return;
        }

        try {
            switch (action.toLowerCase()) {
                case "add":
                    handleAdd(request, response, codiProducte.trim());
                    break;
                    
                case "remove":
                    handleRemove(request, response, codiProducte.trim());
                    break;
                    
                case "finalitzar":
                    handleFinalitzar(request, response, codiProducte.trim());
                    break;
                    
                default:
                    response.sendError(HttpServletResponse.SC_BAD_REQUEST, 
                        "Acció desconeguda: " + action);
            }
        } catch (Exception e) {
            log("Error en doPost [" + action + "]: " + e.getMessage());
            e.printStackTrace();
            
            // Redirect a doGet amb error
            response.sendRedirect("ComponentProducteServlet?producte=" + codiProducte + 
                                "&error=" + java.net.URLEncoder.encode(e.getMessage(), "UTF-8"));
        }
    }

    /**
     * Gestiona l'afegit d'un component al producte
     */
    private void handleAdd(HttpServletRequest request, HttpServletResponse response, 
                          String codiProducte) throws ServletException, IOException {
        
        String codiComponent = request.getParameter("component");
        String quantitatStr = request.getParameter("quantitat");
        
        // Validar paràmetres
        if (codiComponent == null || codiComponent.trim().isEmpty()) {
            response.sendRedirect("ComponentProducteServlet?producte=" + codiProducte + 
                                "&error=Selecciona+un+component");
            return;
        }
        
        if (quantitatStr == null || quantitatStr.trim().isEmpty()) {
            response.sendRedirect("ComponentProducteServlet?producte=" + codiProducte + 
                                "&error=Quantitat+requerida");
            return;
        }

        try {
            int quantitat = Integer.parseInt(quantitatStr);
            
            if (quantitat <= 0) {
                response.sendRedirect("ComponentProducteServlet?producte=" + codiProducte + 
                                    "&error=Quantitat+ha+de+ser+positiva");
                return;
            }

            // Verificar que el producte existeix
            Producte producte = daoProducte.findById(codiProducte);
            if (producte == null) {
                response.sendRedirect("ComponentProducteServlet?producte=" + codiProducte + 
                                    "&error=Producte+no+trobat");
                return;
            }

            // Verificar que el component existeix i és tipus 'C'
            Component component = daoComponent.findById(codiComponent.trim());
            if (component == null) {
                response.sendRedirect("ComponentProducteServlet?producte=" + codiProducte + 
                                    "&error=Component+no+trobat");
                return;
            }

            // Verificar que la relació no existeix ja
            ProdItem existent = daoProdItem.findById(codiProducte, codiComponent.trim());
            if (existent != null) {
                response.sendRedirect("ComponentProducteServlet?producte=" + codiProducte + 
                                    "&error=Component+ja+afegit");
                return;
            }

            // Afegir component al producte
            boolean exit = daoProdItem.afegirItemAProducte(codiProducte, 
                                                           codiComponent.trim(), 
                                                           quantitat);

            if (exit) {
                log("✅ Component " + codiComponent + " afegit a producte " + codiProducte + 
                    " (qty: " + quantitat + ")");
                response.sendRedirect("ComponentProducteServlet?producte=" + codiProducte + 
                                    "&success=Component+afegit+correctament");
            } else {
                response.sendRedirect("ComponentProducteServlet?producte=" + codiProducte + 
                                    "&error=No+s'ha+pogut+afegir+el+component");
            }

        } catch (NumberFormatException e) {
            response.sendRedirect("ComponentProducteServlet?producte=" + codiProducte + 
                                "&error=Quantitat+ha+de+ser+un+número");
        }
    }

    /**
     * Gestiona l'eliminació d'un component del producte
     */
    private void handleRemove(HttpServletRequest request, HttpServletResponse response, 
                             String codiProducte) throws ServletException, IOException {
        
        String codiComponent = request.getParameter("component");
        
        if (codiComponent == null || codiComponent.trim().isEmpty()) {
            response.sendRedirect("ComponentProducteServlet?producte=" + codiProducte + 
                                "&error=Component+requerit");
            return;
        }

        boolean exit = daoProdItem.eliminar(codiProducte, codiComponent.trim());

        if (exit) {
            log("🗑️ Component " + codiComponent + " eliminat de producte " + codiProducte);
            response.sendRedirect("ComponentProducteServlet?producte=" + codiProducte + 
                                "&success=Component+eliminat");
        } else {
            response.sendRedirect("ComponentProducteServlet?producte=" + codiProducte + 
                                "&error=No+s'ha+pogut+eliminar+el+component");
        }
    }

    /**
     * Gestiona la finalització: valida que el producte tingui components i redirigeix
     */
    private void handleFinalitzar(HttpServletRequest request, HttpServletResponse response, 
                                  String codiProducte) throws ServletException, IOException {
        
        // Validar que el producte té almenys 1 component
        boolean teComponents = daoProducte.teComponents(codiProducte);
        
        if (!teComponents) {
            log("⚠️ Intent de finalitzar producte " + codiProducte + " sense components");
            response.sendRedirect("ComponentProducteServlet?producte=" + codiProducte + 
                                "&error=Cal+afegir+almenys+1+component");
            return;
        }

        // Producte complet! Redirigir a la llista amb missatge d'èxit
        log("✅ Producte " + codiProducte + " finalitzat correctament amb components");
        response.sendRedirect("ProducteServlet?success=" + 
                            java.net.URLEncoder.encode(
                                "Producte " + codiProducte + " creat i configurat correctament", 
                                "UTF-8"));
    }

    @Override
    public String getServletInfo() {
        return "Servlet per gestionar l'afegit de components a productes";
    }
}