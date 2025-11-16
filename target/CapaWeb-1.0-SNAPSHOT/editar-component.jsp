<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="dao.DAOFactory, dao.IDAOComponent, dao.IDAOUnitatMesura, model.Component, model.UnitatMesura, java.util.List" %>
<%
    // Preparar dades per al formulari
    Component component = null;
    String codiParam = request.getParameter("codi");
    boolean esNou = (codiParam == null || codiParam.trim().isEmpty());
    
    if (!esNou) {
        // Mode edició: carregar component existent
        try {
            IDAOComponent daoComponent = DAOFactory.getDAOComponent();
            component = daoComponent.findById(codiParam.trim());
        } catch (Exception e) {
            out.println("<p style='color:red;'>Error carregant component: " + e.getMessage() + "</p>");
        }
    }
    
    // Carregar llista d'unitats de mesura per al dropdown
    List<UnitatMesura> unitatsMesura = null;
    try {
        IDAOUnitatMesura daoUM = DAOFactory.getDAOUnitatMesura();
        unitatsMesura = daoUM.findAll();
    } catch (Exception e) {
        out.println("<p style='color:red;'>Error carregant unitats de mesura: " + e.getMessage() + "</p>");
    }
%>
<!DOCTYPE html>
<html lang="ca">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= esNou ? "Nou Component" : "Editar Component" %> - Tallers Manolo</title>
    <link rel="stylesheet" href="css/tallersmanolo.css">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@600;700&family=Roboto:wght@400;500;700&display=swap" rel="stylesheet">
</head>
<body>
    <header class="capsalera">
        <div class="logo">TALLERS MANOLO</div>
        <nav class="navegacio">
            <a href="ProducteServlet" class="enllac-nav">PRODUCTES</a>
            <a href="ComponentServlet" class="enllac-nav actiu">COMPONENTS PRIMARIS</a>
        </nav>
    </header>

    <main class="contenidor">
        <h1><%= esNou ? "Nou Component" : "Editar Component" %></h1>
        
        <div class="formulari-contenidor">
            <form method="post" action="ComponentServlet">
                <!-- Action: create o update segons si és nou -->
                <input type="hidden" 
                       name="action" 
                       value="<%= esNou ? "create" : "update" %>">
                
                <fieldset class="fieldset">
                    <legend class="llegenda">COMPONENT</legend>
                    
                    <div class="fila-camps">
                        <div class="grup-camp">
                            <label class="etiqueta" for="codiComponent">CODI_COMPONENT *</label>
                            <input type="text" 
                                   id="codiComponent" 
                                   name="codiComponent" 
                                   class="camp" 
                                   placeholder="CMP-XXX" 
                                   maxlength="20" 
                                   value="<%= component != null ? component.getCmCodi() : "" %>"
                                   <%= component != null ? "readonly" : "required" %>>
                        </div>
                        
                        <div class="grup-camp">
                            <label class="etiqueta" for="codiFabricant">CODI_FABRICANT</label>
                            <input type="text" 
                                   id="codiFabricant" 
                                   name="codiFabricant" 
                                   class="camp" 
                                   placeholder="FAB-XXX" 
                                   maxlength="20"
                                   value="<%= component != null ? (component.getCmCodiFabricant() != null ? component.getCmCodiFabricant() : "") : "" %>">
                        </div>
                    </div>

                    <div class="grup-camp">
                        <label class="etiqueta" for="nomComponent">NOM_DEL_COMPONENT *</label>
                        <input type="text" 
                               id="nomComponent" 
                               name="nomComponent" 
                               class="camp" 
                               placeholder="Nom descriptiu del component" 
                               maxlength="100" 
                               value="<%= component != null ? component.getItNom() : "" %>"
                               required>
                    </div>

                    <div class="grup-camp">
                        <label class="etiqueta" for="descripcioComponent">DESCRIPCIÓ_DEL_COMPONENT</label>
                        <textarea id="descripcioComponent" 
                                  name="descripcioComponent" 
                                  class="camp textarea" 
                                  rows="4" 
                                  placeholder="Descripció detallada del component..."><%= component != null && component.getItDesc() != null ? component.getItDesc() : "" %></textarea>
                    </div>

                    <div class="fila-camps">
                        <div class="grup-camp">
                            <label class="etiqueta" for="unitatMesura">UNITAT_DE_MESURA *</label>
                            <select id="unitatMesura" 
                                    name="unitatMesura" 
                                    class="camp" 
                                    required>
                                <option value="">-- Selecciona unitat --</option>
                                <%
                                    if (unitatsMesura != null) {
                                        String umSeleccionada = component != null ? component.getCmUmCodi() : "";
                                        for (UnitatMesura um : unitatsMesura) {
                                            String selected = um.getUmCodi().equals(umSeleccionada) ? "selected" : "";
                                %>
                                            <option value="<%= um.getUmCodi() %>" <%= selected %>>
                                                <%= um.getUmCodi() %> - <%= um.getUmNom() %>
                                            </option>
                                <%
                                        }
                                    }
                                %>
                            </select>
                        </div>

                        <div class="grup-camp">
                            <label class="etiqueta" for="estocInicial">ESTOC_INICIAL</label>
                            <input type="number" 
                                   id="estocInicial" 
                                   name="estocInicial" 
                                   class="camp" 
                                   placeholder="0" 
                                   min="0"
                                   value="<%= component != null && component.getItStock() != null ? component.getItStock() : "0" %>">
                        </div>

                        <div class="grup-camp">
                            <label class="etiqueta" for="preuMitja">
                                PREU_MITJÀ 
                                <span class="info-icon" title="Aquest preu es calcula automàticament pels triggers Oracle quan s'afegeixen proveïdors"><img src="media/info.svg" alt="Info">️</span>
                            </label>
                            <input type="text" 
                                   id="preuMitja" 
                                   name="preuMitja" 
                                   class="camp camp-readonly" 
                                   value="<%= component != null ? String.format("%.2f €", component.getCmPreuMig()) : "0.00 €" %>"
                                   readonly
                                   disabled>
                            <small class="text-help"><img src="media/warning.svg" alt="Informació" class="alert-icon">️ Aquest camp NO es pot editar. Es calcula automàticament.</small>
                        </div>
                    </div>
                </fieldset>

                <div class="grup-botons">
                    <a href="ComponentServlet" class="boto boto-secundari">CANCEL·LAR</a>
                    <button type="submit" class="boto boto-primari">ACCEPTAR</button>
                </div>
            </form>
        </div>
        
        <% if (!esNou && component != null) { %>
        <!-- Nota informativa per mode edició -->
        <div class="nota-info">
            <strong class="negreta"><img src="media/lightbulb.svg" alt="Info">️ Nota:</strong> Per modificar el preu mitjà, has de gestionar els proveïdors i els seus preus.
            <a href="ProveidorComponentServlet?component=<%= component.getCmCodi() %>" class="text-destacat">
                Gestionar proveïdors →
            </a>
        </div>
        <% } %>
    </main>
    
    <style>
        /* ESTILOS INLINE - Paleta Corporativa Tallers Manolo */
        
        .formulari-contenidor {
            background: #ffffff;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(26, 54, 93, 0.1);
            max-width: 800px;
            margin: 0 auto;
        }
        
        .fieldset {
            border: 1px solid #4a5568;
            border-radius: 4px;
            padding: 20px;
            margin-bottom: 20px;
        }
        
        .llegenda {
            font-family: 'Inter', sans-serif;
            font-weight: 600;
            color: #2c5282;
            padding: 0 10px;
        }
        
        .fila-camps {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 20px;
        }
        
        .grup-camp {
            display: flex;
            flex-direction: column;
        }
        
        .etiqueta {
            font-family: 'Inter', sans-serif;
            font-weight: 600;
            margin-bottom: 8px;
            color: #2c5282;
        }
        
        .camp {
            padding: 10px;
            border: 1px solid #4a5568;
            border-radius: 4px;
            font-size: 14px;
            font-family: 'Roboto', sans-serif;
            color: #000000;
        }
        
        .camp::placeholder {
            color: #4a5568;
            opacity: 0.6;
        }
        
        .camp:focus {
            outline: none;
            border-color: #0066cc;
            box-shadow: 0 0 0 2px rgba(0, 102, 204, 0.1);
        }
        
        .camp[readonly] {
            background-color: #f5f5f5;
            color: #4a5568;
            cursor: not-allowed;
        }
        
        .camp-readonly {
            background-color: #f0f0f0 !important;
            color: #2c5282 !important;
            font-weight: 500;
            cursor: not-allowed;
        }
        
        .textarea {
            resize: vertical;
            min-height: 100px;
        }
        
        select.camp {
            cursor: pointer;
        }
        
        .info-icon {
            font-size: 0.9em;
            cursor: help;
            color: #0066cc;
        }
        
        .text-help {
            font-size: 0.85em;
            color: #4a5568;
            margin-top: 5px;
            display: block;
        }
        
        .grup-botons {
            display: flex;
            justify-content: flex-end;
            gap: 15px;
            margin-top: 20px;
            padding-top: 20px;
            border-top: 1px solid #4a5568;
        }
        
        .boto {
            padding: 10px 25px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-family: 'Roboto', sans-serif;
            font-weight: 500;
            text-decoration: none;
            display: inline-block;
            transition: all 0.3s ease;
        }
        
        .boto-primari {
            background-color: #000000;
            color: #ffffff;
        }
        
        .boto-primari:hover {
            background-color: #1a365d;
        }
        
        .boto-secundari {
            background-color: #ffffff;
            color: #000000;
            border: 1px solid #000000;
        }
        
        .boto-secundari:hover {
            background-color: #4a5568;
            color: #ffffff;
            border-color: #4a5568;
        }
        
        .nota-info {
            background-color: rgba(0, 102, 204, 0.05);
            border: 1px solid #0066cc;
            padding: 15px;
            border-radius: 4px;
            margin-top: 20px;
            text-align: center;
        }
        
        .negreta {
            font-family: 'Roboto', sans-serif;
            font-weight: 700;
            color: #000000;
        }
        
        .text-destacat {
            color: #0066cc;
            font-weight: 500;
            text-decoration: underline;
        }
    </style>
</body>
</html>
