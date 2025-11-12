package controller;

import java.io.IOException;
import java.io.OutputStream;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

import com.itextpdf.kernel.colors.ColorConstants;
import com.itextpdf.kernel.colors.DeviceRgb;
import com.itextpdf.kernel.pdf.PdfDocument;
import com.itextpdf.kernel.pdf.PdfWriter;
import com.itextpdf.layout.Document;
import com.itextpdf.layout.borders.Border;
import com.itextpdf.layout.element.Cell;
import com.itextpdf.layout.element.Paragraph;
import com.itextpdf.layout.element.Table;
import com.itextpdf.layout.properties.TextAlignment;
import com.itextpdf.layout.properties.UnitValue;

import dao.DAOFactory;
import dao.IDAOComponent;
import dao.IDAOItem;
import dao.IDAOProdItem;
import dao.IDAOProducte;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Component;
import model.Item;
import model.ProdItem;
import model.Producte;

/**
 * Servlet per generar BOM (Bill of Materials) en format PDF
 * 
 * Responsabilitats:
 * - Generar PDF amb la llista de materials d'un producte
 * - Incloure informació de components amb quantitats i preus
 * - Calcular preu total del producte
 * 
 * Format PDF:
 * - Header: Informació producte + data
 * - Taula: Components amb codi, nom, UM, quantitat, preu unitari, subtotal
 * - Footer: Preu total
 * 
 * @author DomenechObiolAlbert
 * @version 1.0
 */
@WebServlet(name = "BOMServlet", urlPatterns = {"/BOMServlet"})
public class BOMServlet extends HttpServlet {

    private IDAOProducte daoProducte;
    private IDAOProdItem daoProdItem;
    private IDAOComponent daoComponent;
    private IDAOItem daoItem;

    @Override
    public void init() throws ServletException {
        try {
            this.daoProducte = DAOFactory.getDAOProducte();
            this.daoProdItem = DAOFactory.getDAOProdItem();
            this.daoComponent = DAOFactory.getDAOComponent();
            this.daoItem = DAOFactory.getDAOItem();
            log("✅ BOMServlet inicialitzat correctament");
        } catch (Exception e) {
            log("❌ Error inicialitzant BOMServlet: " + e.getMessage());
            throw new ServletException("No es pot inicialitzar els DAOs", e);
        }
    }

    /**
     * Gestiona peticions GET: genera PDF del BOM
     * 
     * Paràmetres requerits:
     * - codi: Codi del producte
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String codiProducte = request.getParameter("codi");
        
        if (codiProducte == null || codiProducte.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, 
                "Paràmetre 'codi' requerit");
            return;
        }

        try {
            // 1. Buscar producte
            Producte producte = daoProducte.findById(codiProducte.trim());
            
            if (producte == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, 
                    "Producte no trobat: " + codiProducte);
                return;
            }

            // 2. Obtenir components del producte
            List<ProdItem> items = daoProdItem.getItemsDelProducte(codiProducte.trim());
            
            if (items == null || items.isEmpty()) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, 
                    "El producte no té components definits");
                return;
            }

            // 3. Configurar resposta HTTP per PDF
            response.setContentType("application/pdf");
            response.setHeader("Content-Disposition", 
                "inline; filename=BOM_" + codiProducte + ".pdf");

            // 4. Generar PDF
            generateBOMPDF(response.getOutputStream(), producte, items);

            log("✅ BOM generat per producte: " + codiProducte);

        } catch (Exception e) {
            log("❌ Error generant BOM: " + e.getMessage());
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, 
                "Error generant BOM: " + e.getMessage());
        }
    }

    /**
     * Genera el PDF del BOM
     */
    private void generateBOMPDF(OutputStream outputStream, Producte producte, List<ProdItem> items) 
            throws Exception {
        
        // Crear document PDF
        PdfWriter writer = new PdfWriter(outputStream);
        PdfDocument pdfDoc = new PdfDocument(writer);
        Document document = new Document(pdfDoc);
        
        // Colors corporatius
        DeviceRgb colorPrimari = new DeviceRgb(0, 123, 255);
        DeviceRgb colorSecundari = new DeviceRgb(108, 117, 125);
        
        // =======================
        // HEADER
        // =======================
        
        // Logo/Títol empresa
        Paragraph titulo = new Paragraph("TALLERS MANOLO")
                .setFontSize(24)
                .setBold()
                .setFontColor(colorPrimari)
                .setTextAlignment(TextAlignment.CENTER);
        document.add(titulo);
        
        Paragraph subtitulo = new Paragraph("Bill of Materials (BOM)")
                .setFontSize(16)
                .setFontColor(colorSecundari)
                .setTextAlignment(TextAlignment.CENTER)
                .setMarginBottom(20);
        document.add(subtitulo);
        
        // Informació del producte
        Table infoTable = new Table(UnitValue.createPercentArray(new float[]{30, 70}))
                .setWidth(UnitValue.createPercentValue(100))
                .setMarginBottom(20);
        
        addInfoRow(infoTable, "Codi Producte:", producte.getPrCodi(), colorPrimari);
        addInfoRow(infoTable, "Nom:", producte.getItNom(), colorPrimari);
        addInfoRow(infoTable, "Descripció:", producte.getItDesc() != null ? producte.getItDesc() : "-", colorPrimari);
        addInfoRow(infoTable, "Data Generació:", new SimpleDateFormat("dd/MM/yyyy HH:mm:ss").format(new Date()), colorPrimari);
        
        document.add(infoTable);
        
        // =======================
        // TAULA DE COMPONENTS
        // =======================
        
        Paragraph componentesTitle = new Paragraph("Components")
                .setFontSize(14)
                .setBold()
                .setMarginTop(10)
                .setMarginBottom(10);
        document.add(componentesTitle);
        
        // Taula amb 6 columnes
        Table componentTable = new Table(UnitValue.createPercentArray(
                new float[]{15, 30, 10, 10, 15, 20}))
                .setWidth(UnitValue.createPercentValue(100));
        
        // Header de la taula
        String[] headers = {"Codi", "Nom Component", "UM", "Quantitat", "Preu Unit.", "Subtotal"};
        for (String header : headers) {
            Cell cell = new Cell()
                    .add(new Paragraph(header).setBold().setFontColor(ColorConstants.WHITE))
                    .setBackgroundColor(colorPrimari)
                    .setTextAlignment(TextAlignment.CENTER)
                    .setPadding(8);
            componentTable.addHeaderCell(cell);
        }
        
        // Dades dels components
        double preuTotal = 0.0;
        
        for (ProdItem pi : items) {
            // Obtenir informació del component
            Item item = daoItem.findById(pi.getPiItCodi());
            
            if (item == null) {
                log("⚠️ Item no trobat: " + pi.getPiItCodi());
                continue;
            }
            
            String nom = item.getItNom();
            String um = "-";
            double preuUnitari = 0.0;
            
            // Si és component, obtenir unitat mesura i preu
            if ("C".equals(item.getItTipus())) {
                Component component = daoComponent.findById(item.getItCodi());
                if (component != null) {
                    um = component.getCmUmCodi();
                    preuUnitari = component.getCmPreuMig() != null ? component.getCmPreuMig() : 0.0;
                }
            }
            
            // Calcular subtotal
            int quantitat = pi.getQuantitat() != null ? pi.getQuantitat() : 0;
            double subtotal = preuUnitari * quantitat;
            preuTotal += subtotal;
            
            // Afegir fila
            componentTable.addCell(createCell(item.getItCodi(), TextAlignment.LEFT));
            componentTable.addCell(createCell(nom, TextAlignment.LEFT));
            componentTable.addCell(createCell(um, TextAlignment.CENTER));
            componentTable.addCell(createCell(String.valueOf(quantitat), TextAlignment.CENTER));
            componentTable.addCell(createCell(String.format("%.2f €", preuUnitari), TextAlignment.RIGHT));
            componentTable.addCell(createCell(String.format("%.2f €", subtotal), TextAlignment.RIGHT));
        }
        
        document.add(componentTable);
        
        // =======================
        // FOOTER - PREU TOTAL
        // =======================
        
        Table totalTable = new Table(UnitValue.createPercentArray(new float[]{80, 20}))
                .setWidth(UnitValue.createPercentValue(100))
                .setMarginTop(20);
        
        Cell labelCell = new Cell()
                .add(new Paragraph("PREU TOTAL").setBold().setFontSize(14))
                .setTextAlignment(TextAlignment.RIGHT)
                .setBorder(Border.NO_BORDER)
                .setPadding(5);
        
        Cell preuCell = new Cell()
                .add(new Paragraph(String.format("%.2f €", preuTotal))
                        .setBold()
                        .setFontSize(16)
                        .setFontColor(colorPrimari))
                .setTextAlignment(TextAlignment.RIGHT)
                .setBackgroundColor(new DeviceRgb(240, 240, 240))
                .setPadding(10);
        
        totalTable.addCell(labelCell);
        totalTable.addCell(preuCell);
        
        document.add(totalTable);
        
        // =======================
        // FOOTER - INFORMACIÓ ADICIONAL
        // =======================
        
        Paragraph footer = new Paragraph("Yeaaaah funciona!!")
                .setFontSize(8)
                .setFontColor(colorSecundari)
                .setTextAlignment(TextAlignment.CENTER)
                .setMarginTop(30);
        document.add(footer);
        
        // Tancar document
        document.close();
    }

    /**
     * Afegeix una fila d'informació a la taula
     */
    private void addInfoRow(Table table, String label, String value, DeviceRgb color) {
        Cell labelCell = new Cell()
                .add(new Paragraph(label).setBold().setFontColor(color))
                .setBorder(Border.NO_BORDER)
                .setPadding(5);
        
        Cell valueCell = new Cell()
                .add(new Paragraph(value))
                .setBorder(Border.NO_BORDER)
                .setPadding(5);
        
        table.addCell(labelCell);
        table.addCell(valueCell);
    }

    /**
     * Crea una cel·la de la taula de components
     */
    private Cell createCell(String text, TextAlignment alignment) {
        return new Cell()
                .add(new Paragraph(text))
                .setTextAlignment(alignment)
                .setPadding(5);
    }

    @Override
    public String getServletInfo() {
        return "Servlet per generar BOM (Bill of Materials) en PDF";
    }
}