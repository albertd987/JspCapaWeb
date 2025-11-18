package controller;

import java.io.IOException;

import dao.DAOFactory;
import dao.IDAOProducte;
import dao.reports.BOMReportJasper;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Producte;

/**
 * Servlet per generar BOM (Bill of Materials) en format PDF amb JasperReports
 *
 * Responsabilitats:
 * - Validar paràmetres d'entrada
 * - Verificar existència del producte
 * - Delegar generació del PDF al backend (BOMReportJasper)
 * - Gestionar errors i retornar PDF al client
 *
 * Flux:
 * 1. Rebre codi producte per GET
 * 2. Validar producte existeix
 * 3. Cridar BOMReportJasper.generarBOMPDF()
 * 4. Retornar PDF al navegador
 *
 * @author DomenechObiolAlbert
 * @version 2.0 (migrat a JasperReports)
 */
@WebServlet(name = "BOMServlet", urlPatterns = {"/BOMServlet"})
public class BOMServlet extends HttpServlet {

    private IDAOProducte daoProducte;
    private BOMReportJasper bomGenerator;

    @Override
    public void init() throws ServletException {
        try {
            this.daoProducte = DAOFactory.getDAOProducte();
            this.bomGenerator = new BOMReportJasper();
            log("✅ BOMServlet inicialitzat correctament amb JasperReports");
        } catch (Exception e) {
            log("❌ Error inicialitzant BOMServlet: " + e.getMessage());
            throw new ServletException("No es pot inicialitzar BOMServlet", e);
        }
    }

    /**
     * Gestiona peticions GET: genera PDF del BOM
     *
     * Paràmetres requerits:
     * - codi: Codi del producte
     * 
     * Exemple: /BOMServlet?codi=P001
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String codiProducte = request.getParameter("codi");

        // Validació 1: Paràmetre obligatori
        if (codiProducte == null || codiProducte.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST,
                    "Paràmetre 'codi' requerit");
            return;
        }

        try {
            // Validació 2: Producte existeix
            Producte producte = daoProducte.findById(codiProducte.trim());
            if (producte == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND,
                        "Producte no trobat: " + codiProducte);
                return;
            }

            // Configurar resposta HTTP per PDF
            response.setContentType("application/pdf");
            response.setHeader("Content-Disposition",
                    "inline; filename=BOM_" + codiProducte + ".pdf");

            // Generar PDF amb JasperReports (delegat al backend)
            bomGenerator.generarBOMPDF(codiProducte.trim(), response.getOutputStream());

            log("✅ BOM generat correctament per producte: " + codiProducte);

        } catch (IllegalStateException e) {
            // Producte sense components
            log("⚠️ Producte sense components: " + codiProducte);
            response.sendError(HttpServletResponse.SC_BAD_REQUEST,
                    "El producte no té components definits");
                    
        } catch (IllegalArgumentException e) {
            // Error de validació
            log("⚠️ Error de validació: " + e.getMessage());
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, e.getMessage());
            
        } catch (Exception e) {
            // Error inesperat
            log("❌ Error generant BOM: " + e.getMessage());
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Error generant BOM: " + e.getMessage());
        }
    }

    @Override
    public String getServletInfo() {
        return "BOM Servlet - Genera Bill of Materials en PDF amb JasperReports";
    }
}