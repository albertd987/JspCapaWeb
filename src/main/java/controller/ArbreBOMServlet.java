package controller;

import dao.DAOProdItem;
import dao.DAOItem;
import model.ProdItem;
import model.Item;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

/**
 * Servlet simple per mostrar l'arbre BOM en un popup
 */
@WebServlet("/arbreBOM")
public class ArbreBOMServlet extends HttpServlet {
    
    private DAOProdItem daoProdItem;
    private DAOItem daoItem;
    
    @Override
    public void init() throws ServletException {
        daoProdItem = new DAOProdItem();
        daoItem = new DAOItem();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String prCodi = request.getParameter("prCodi");
        
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();
        
        // HTML del popup
        out.println("<!DOCTYPE html>");
        out.println("<html>");
        out.println("<head>");
        out.println("<meta charset='UTF-8'>");
        out.println("<title>Arbre BOM</title>");
        out.println("<style>");
        out.println("body { font-family: Arial, sans-serif; margin: 20px; background: #f5f5f5; }");
        out.println("h2 { color: #333; border-bottom: 2px solid #667eea; padding-bottom: 10px; }");
        out.println("ul { list-style: none; padding-left: 20px; }");
        out.println("li { margin: 8px 0; }");
        out.println(".producte { color: #0066cc; font-weight: bold; font-size: 14px; }");
        out.println(".component { color: #666; font-size: 13px; }");
        out.println(".toggle { ");
        out.println("  cursor: pointer; ");
        out.println("  user-select: none; ");
        out.println("  padding: 5px 8px; ");
        out.println("  border-radius: 4px; ");
        out.println("  display: inline-block;");
        out.println("  transition: background 0.2s;");
        out.println("}");
        out.println(".toggle:hover { background: #e7f1ff; }");
        out.println(".toggle:active { background: #cfe2ff; }");
        out.println("</style>");
        out.println("</head>");
        out.println("<body>");
        
        // Generar arbre
        Item itemRoot = daoItem.findById(prCodi);
        if (itemRoot != null) {
            out.println("<h2><img src=\"media/tree.svg\">️ Arbre BOM: " + itemRoot.getItNom() + "</h2>");
            generarArbreHTML(out, prCodi, 0);
        } else {
            out.println("<h2>Producte no trobat</h2>");
        }
        
        // JavaScript per expand/collapse
        out.println("<script>");
        out.println("document.addEventListener('DOMContentLoaded', function() {");
        out.println("  document.querySelectorAll('.toggle').forEach(function(item) {");
        out.println("    item.addEventListener('click', function(e) {");
        out.println("      e.preventDefault();");
        out.println("      const ul = this.nextElementSibling;");
        out.println("      if (ul && ul.tagName === 'UL') {");
        out.println("        if (ul.style.display === 'none') {");
        out.println("          ul.style.display = 'block';");
        out.println("          this.innerHTML = this.innerHTML.replace('<img src=\"media/right_arrow.svg\">️', '<img src=\"media/down_arrow.svg\">️');");
        out.println("        } else {");
        out.println("          ul.style.display = 'none';");
        out.println("          this.innerHTML = this.innerHTML.replace('<img src=\"media/down_arrow.svg\">️', '<img src=\"media/right_arrow.svg\">️');");
        out.println("        }");
        out.println("      }");
        out.println("    });");
        out.println("  });");
        out.println("});");
        out.println("</script>");
        
        out.println("</body>");
        out.println("</html>");
    }
    
    /**
     * Genera l'arbre HTML recursivament
     */
    private void generarArbreHTML(PrintWriter out, String codi, int nivel) {
        // Protecció contra cicles
        if (nivel > 10) return;
        
        Item item = daoItem.findById(codi);
        if (item == null) return;
        
        List<ProdItem> fills = daoProdItem.getItemsDelProducte(codi);
        
        if (nivel == 0) {
            // Node arrel
            out.println("<ul>");
            if (!fills.isEmpty()) {
                out.println("<li><span class='toggle'><img src=\"media/down_arrow.svg\">️ <span class='producte'>" + codi + ": " + item.getItNom() + "</span></span>");
                out.println("<ul>");
                for (ProdItem pi : fills) {
                    generarArbreHTML(out, pi.getPiItCodi(), nivel + 1);
                }
                out.println("</ul>");
                out.println("</li>");
            } else {
                out.println("<li><span class='producte'>" + codi + ": " + item.getItNom() + " (sense components)</span></li>");
            }
            out.println("</ul>");
        } else {
            // Nodes fills
            if (!fills.isEmpty()) {
                // És un producte amb fills
                out.println("<li><span class='toggle'><img src=\"media/right_arrow.svg\">️<span class='producte'>" + codi + ": " + item.getItNom() + "</span></span>");
                out.println("<ul style='display:none'>");
                for (ProdItem pi : fills) {
                    generarArbreHTML(out, pi.getPiItCodi(), nivel + 1);
                }
                out.println("</ul>");
                out.println("</li>");
            } else {
                // És un component (fulla)
                out.println("<li><span class='component'><img src=\"media/package.svg\">️ " + codi + ": " + item.getItNom() + "</span></li>");
            }
        }
    }
}