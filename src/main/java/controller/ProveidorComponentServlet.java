package controller;

import java.io.IOException;
import java.util.List;

import dao.DAOFactory;
import dao.IDAOComponent;
import dao.IDAOProvComp;
import dao.IDAOProveidor;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Component;
import model.ProvComp;
import model.Proveidor;

/**
 * Servlet per gestionar la relació Proveïdor-Component i els seus preus
 * 
 * Responsabilitats:
 * - Mostrar formulari per afegir proveïdors a un component (GET)
 * - Afegir proveïdor amb preu (POST action=add)
 * - Actualitzar preu d'un proveïdor (POST action=update)
 * - Eliminar proveïdor (POST action=remove)
 * - Finalitzar configuració (POST action=finalitzar)
 * 
 * CRÍTICA: 
 * Cada INSERT/UPDATE/DELETE dispara el trigger Oracle que recalcula 
 * automàticament cm_preu_mig del component!
 * 
 * @author DomenechObiolAlbert
 * @version 1.0
 */
@WebServlet(name = "ProveidorComponentServlet", urlPatterns = {"/ProveidorComponentServlet"})
public class ProveidorComponentServlet extends HttpServlet {

    private IDAOComponent daoComponent;
    private IDAOProveidor daoProveidor;
    private IDAOProvComp daoProvComp;

    @Override
    public void init() throws ServletException {
        try {
            this.daoComponent = DAOFactory.getDAOComponent();
            this.daoProveidor = DAOFactory.getDAOProveidor();
            this.daoProvComp = DAOFactory.getDAOProvComp();
            log("✅ ProveidorComponentServlet inicialitzat correctament");
        } catch (Exception e) {
            log("❌ Error inicialitzant ProveidorComponentServlet: " + e.getMessage());
            throw new ServletException("No es pot inicialitzar els DAOs", e);
        }
    }

    /**
     * Gestiona peticions GET: carrega la pàgina de gestió de proveïdors
     * 
     * Paràmetres requerits:
     * - component: Codi del component
     * 
     * Paràmetres opcionals:
     * - nouComponent: "true" si és un component acabat de crear
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String codiComponent = request.getParameter("component");
        
        if (codiComponent == null || codiComponent.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, 
                "Paràmetre 'component' requerit");
            return;
        }

        try {
            // 1. Buscar component
            Component component = daoComponent.findById(codiComponent.trim());
            
            if (component == null) {
                request.setAttribute("error", "Component no trobat: " + codiComponent);
                request.getRequestDispatcher("/ComponentServlet").forward(request, response);
                return;
            }

            // 2. Buscar proveïdors disponibles (TOTS)
            List<Proveidor> proveidorsDisponibles = daoProveidor.findAll();
            
            // 3. Buscar proveïdors ja assignats a aquest component
            List<ProvComp> proveidorsActuals = daoProvComp.getProveidorsDelComponent(codiComponent.trim());

            // 4. Preparar dades per la JSP
            request.setAttribute("component", component);
            request.setAttribute("proveidorsDisponibles", proveidorsDisponibles);
            request.setAttribute("proveidorsActuals", proveidorsActuals);
            
            // 5. Indicar si és un component nou
            String nouComponent = request.getParameter("nouComponent");
            if ("true".equals(nouComponent)) {
                request.setAttribute("nouComponent", true);
                request.setAttribute("info", "Component creat! Ara pots afegir proveïdors i preus.");
            }

            log("📋 Carregant gestió de proveïdors per component: " + codiComponent);
            log("   → " + proveidorsActuals.size() + " proveïdors actuals");
            log("   → Preu mitjà actual: " + component.getCmPreuMig() + "€");

            // Forward a la JSP
            request.getRequestDispatcher("/proveidors-component.jsp").forward(request, response);

        } catch (Exception e) {
            log("❌ Error carregant dades: " + e.getMessage());
            request.setAttribute("error", "Error carregant dades: " + e.getMessage());
            request.getRequestDispatcher("/ComponentServlet").forward(request, response);
        }
    }

    /**
     * Gestiona peticions POST: afegir, actualitzar, eliminar proveïdors
     * 
     * Paràmetres requerits:
     * - component: Codi del component
     * - action: Tipus d'operació (add/update/remove/finalitzar)
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String codiComponent = request.getParameter("component");
        String action = request.getParameter("action");

        if (codiComponent == null || codiComponent.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Paràmetre 'component' requerit");
            return;
        }

        if (action == null || action.trim().isEmpty()) {
            response.sendRedirect("ProveidorComponentServlet?component=" + codiComponent + 
                                "&error=Acció+no+especificada");
            return;
        }

        // Dispatch segons l'acció
        switch (action.toLowerCase()) {
            case "add":
                handleAdd(request, response, codiComponent);
                break;
            case "update":
                handleUpdate(request, response, codiComponent);
                break;
            case "remove":
                handleRemove(request, response, codiComponent);
                break;
            case "finalitzar":
                handleFinalitzar(request, response, codiComponent);
                break;
            default:
                response.sendRedirect("ProveidorComponentServlet?component=" + codiComponent + 
                                    "&error=Acció+desconeguda");
        }
    }

    /**
     * Afegeix un proveïdor amb preu al component
     * ⚠️ DISPARA TRIGGER que recalcula cm_preu_mig
     */
    private void handleAdd(HttpServletRequest request, HttpServletResponse response, 
                          String codiComponent) throws ServletException, IOException {
        
        String codiProveidor = request.getParameter("proveidor");
        String preuStr = request.getParameter("preu");
        
        if (codiProveidor == null || codiProveidor.trim().isEmpty()) {
            response.sendRedirect("ProveidorComponentServlet?component=" + codiComponent + 
                                "&error=Proveïdor+requerit");
            return;
        }

        if (preuStr == null || preuStr.trim().isEmpty()) {
            response.sendRedirect("ProveidorComponentServlet?component=" + codiComponent + 
                                "&error=Preu+requerit");
            return;
        }

        try {
            double preu = Double.parseDouble(preuStr.trim());
            
            if (preu < 0) {
                response.sendRedirect("ProveidorComponentServlet?component=" + codiComponent + 
                                    "&error=El+preu+no+pot+ser+negatiu");
                return;
            }

            // Crear relació proveïdor-component
            ProvComp provComp = new ProvComp();
            provComp.setPcCmCodi(codiComponent.trim());
            provComp.setPcPvCodi(codiProveidor.trim());
            provComp.setPcPreu(preu);

            boolean exit = daoProvComp.insertar(provComp);

            if (exit) {
                log("✅ Proveïdor " + codiProveidor + " afegit a component " + codiComponent + 
                    " amb preu " + preu + "€");
                log("🔥 Trigger Oracle activat! cm_preu_mig recalculat automàticament");
                
                response.sendRedirect("ProveidorComponentServlet?component=" + codiComponent + 
                                    "&success=Proveïdor+afegit+correctament");
            } else {
                response.sendRedirect("ProveidorComponentServlet?component=" + codiComponent + 
                                    "&error=No+s'ha+pogut+afegir+el+proveïdor");
            }

        } catch (NumberFormatException e) {
            response.sendRedirect("ProveidorComponentServlet?component=" + codiComponent + 
                                "&error=El+preu+ha+de+ser+un+número");
        }
    }

    /**
     * Actualitza el preu d'un proveïdor existent
     * ⚠️ DISPARA TRIGGER que recalcula cm_preu_mig
     */
    private void handleUpdate(HttpServletRequest request, HttpServletResponse response, 
                             String codiComponent) throws ServletException, IOException {
        
        String codiProveidor = request.getParameter("proveidor");
        String preuStr = request.getParameter("preu");
        
        if (codiProveidor == null || codiProveidor.trim().isEmpty()) {
            response.sendRedirect("ProveidorComponentServlet?component=" + codiComponent + 
                                "&error=Proveïdor+requerit");
            return;
        }

        if (preuStr == null || preuStr.trim().isEmpty()) {
            response.sendRedirect("ProveidorComponentServlet?component=" + codiComponent + 
                                "&error=Preu+requerit");
            return;
        }

        try {
            double preu = Double.parseDouble(preuStr.trim());
            
            if (preu < 0) {
                response.sendRedirect("ProveidorComponentServlet?component=" + codiComponent + 
                                    "&error=El+preu+no+pot+ser+negatiu");
                return;
            }

            // Buscar relació existent
            ProvComp provComp = daoProvComp.findById(codiComponent.trim(), codiProveidor.trim());
            
            if (provComp == null) {
                response.sendRedirect("ProveidorComponentServlet?component=" + codiComponent + 
                                    "&error=Relació+no+trobada");
                return;
            }

            // Actualitzar preu
            provComp.setPcPreu(preu);
            boolean exit = daoProvComp.actualitzar(provComp);

            if (exit) {
                log("✅ Preu actualitzat per proveïdor " + codiProveidor + 
                    " del component " + codiComponent + ": " + preu + "€");
                log("🔥 Trigger Oracle activat! cm_preu_mig recalculat automàticament");
                
                response.sendRedirect("ProveidorComponentServlet?component=" + codiComponent + 
                                    "&success=Preu+actualitzat+correctament");
            } else {
                response.sendRedirect("ProveidorComponentServlet?component=" + codiComponent + 
                                    "&error=No+s'ha+pogut+actualitzar+el+preu");
            }

        } catch (NumberFormatException e) {
            response.sendRedirect("ProveidorComponentServlet?component=" + codiComponent + 
                                "&error=El+preu+ha+de+ser+un+número");
        }
    }

    /**
     * Elimina un proveïdor del component
     * ⚠️ DISPARA TRIGGER que recalcula cm_preu_mig
     */
    private void handleRemove(HttpServletRequest request, HttpServletResponse response, 
                             String codiComponent) throws ServletException, IOException {
        
        String codiProveidor = request.getParameter("proveidor");
        
        if (codiProveidor == null || codiProveidor.trim().isEmpty()) {
            response.sendRedirect("ProveidorComponentServlet?component=" + codiComponent + 
                                "&error=Proveïdor+requerit");
            return;
        }

        boolean exit = daoProvComp.eliminar(codiComponent.trim(), codiProveidor.trim());

        if (exit) {
            log("🗑️ Proveïdor " + codiProveidor + " eliminat del component " + codiComponent);
            log("🔥 Trigger Oracle activat! cm_preu_mig recalculat automàticament");
            
            response.sendRedirect("ProveidorComponentServlet?component=" + codiComponent + 
                                "&success=Proveïdor+eliminat");
        } else {
            response.sendRedirect("ProveidorComponentServlet?component=" + codiComponent + 
                                "&error=No+s'ha+pogut+eliminar+el+proveïdor");
        }
    }

    /**
     * Finalitza la configuració de proveïdors i torna a la llista de components
     */
    private void handleFinalitzar(HttpServletRequest request, HttpServletResponse response, 
                                  String codiComponent) throws ServletException, IOException {
        
        log("✅ Component " + codiComponent + " finalitzat amb proveïdors configurats");
        
        response.sendRedirect("ComponentServlet?success=" + 
                            java.net.URLEncoder.encode(
                                "Component " + codiComponent + " creat i configurat correctament", 
                                "UTF-8"));
    }

    @Override
    public String getServletInfo() {
        return "Servlet per gestionar proveïdors i preus de components";
    }
}