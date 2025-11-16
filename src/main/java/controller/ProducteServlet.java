package controller;

import java.io.IOException;
import java.util.List;

import dao.DAOFactory;
import dao.IDAOProdItem;
import dao.IDAOProducte;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.ProdItem;
import model.Producte;

/**
 * Servlet controlador per gestionar operacions CRUD de Productes
 *
 * Responsabilitats: - Llistar productes (GET) - Filtrar productes per codi (GET
 * amb paràmetre) - Crear nou producte (POST amb action=create) - Actualitzar
 * producte (POST amb action=update) - Eliminar producte (POST amb
 * action=delete)
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
     * Paràmetres opcionals: - filtre: Codi de producte per filtrar (LIKE
     * case-insensitive)
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
     * Paràmetres requerits: - action: "create", "update" o "delete"
     *
     * Per CREATE i UPDATE: - codiProducte, nomProducte, descripcioProducte,
     * estocInicial
     *
     * Per DELETE: - codiProducte
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
     * MODIFICACIÓ v1.1: Afegida validació de components - Si el producte no té
     * components, redirigeix a afegir-components.jsp - Si el producte té
     * components, mostra missatge d'èxit
     */
    private void handleCreate(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Recollir paràmetres del formulari
        String codi = request.getParameter("codiProducte");
        String nom = request.getParameter("nomProducte");
        String descripcio = request.getParameter("descripcioProducte");
        String estocStr = request.getParameter("estocInicial");

        // Validar paràmetres
        if (codi == null || codi.trim().isEmpty()
                || nom == null || nom.trim().isEmpty()) {

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

                //VALIDACIÓ DE COMPONENTS (NOU en v1.1)
                boolean teComponents = daoProducte.teComponents(codi.trim());

                if (teComponents) {
                    // Cas excepcional: producte ja té components (per exemple, si s'està recreant)
                    request.setAttribute("success", "Producte creat correctament");
                    doGet(request, response);
                } else {
                    // Cas normal: producte sense components → redirigir a afegir components
                    log("Producte " + codi + " sense components. Redirigint a afegir-components.jsp");
                    response.sendRedirect("ComponentProducteServlet?producte=" + codi.trim()
                            + "&nouProducte=true");
                }

            } else {
                log("No s'ha pogut crear el producte: " + codi);
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
     *
     * IMPORTANT: Abans d'eliminar el producte, cal eliminar les seves relacions
     * a Prod_Item per evitar error de Foreign Key constraint
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
            IDAOProdItem daoProdItem = DAOFactory.getDAOProdItem();

            // ========================================
            // VALIDACIÓ 1: Verificar si està sent usat com a subproducte
            // ========================================
            log("Verificant si " + codi + " està sent usat com a subproducte...");
            List<ProdItem> productesQueElUsen = daoProdItem.getProductesQueUsenItem(codi.trim());

            if (!productesQueElUsen.isEmpty()) {
                // ❌ El producte està sent usat per altres productes
                log("️No es pot eliminar " + codi + " - està sent usat per "
                        + productesQueElUsen.size() + " producte(s)");

                // Construir missatge d'error detallat
                StringBuilder missatge = new StringBuilder();
                missatge.append("No pots eliminar el producte ").append(codi)
                        .append(" perquè està sent usat com a subproducte en:\n\n");

                // Llistar tots els productes que l'usen
                for (ProdItem uso : productesQueElUsen) {
                    missatge.append("• ").append(uso.getPiPrCodi())
                            .append(" (quantitat: ").append(uso.getQuantitat()).append(")\n");
                }

                missatge.append("\nPer eliminar-lo:\n")
                        .append("1. Ves a 'Gestionar Components' de cada producte\n")
                        .append("2. Elimina ").append(codi).append(" de cada producte\n")
                        .append("3. Després podràs eliminar el producte");

                request.setAttribute("error", missatge.toString());
                doGet(request, response);
                return;
            }

            log(codi + " NO està sent usat per cap altre producte");

            // ========================================
            // ELIMINACIÓ: El producte NO està sent usat
            // ========================================
            // PAS 1: Eliminar tots els components/subproductes d'aquest producte
            log("Eliminant components del producte: " + codi);
            List<ProdItem> items = daoProdItem.getItemsDelProducte(codi.trim());

            int componentsEliminats = 0;
            for (ProdItem item : items) {
                boolean eliminat = daoProdItem.eliminar(item.getPiPrCodi(), item.getPiItCodi());
                if (eliminat) {
                    componentsEliminats++;
                    log("Component eliminat: " + item.getPiItCodi());
                } else {
                    log("No s'ha pogut eliminar: " + item.getPiItCodi());
                }
            }

            log("✓ Components eliminats: " + componentsEliminats + "/" + items.size());

            // PAS 2: Eliminar el producte (també elimina de Item automàticament)
            log("Eliminant producte: " + codi);
            boolean exit = daoProducte.eliminar(codi.trim());

            if (exit) {
                log("Producte eliminat correctament: " + codi);
                request.setAttribute("success",
                        "Producte " + codi + " eliminat correctament "
                        + "(juntament amb " + componentsEliminats + " components)");
            } else {
                log("No s'ha pogut eliminar el producte: " + codi);
                request.setAttribute("error", "No s'ha pogut eliminar el producte");
            }

        } catch (Exception e) {
            log("Error eliminant producte: " + e.getMessage());
            e.printStackTrace();
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
