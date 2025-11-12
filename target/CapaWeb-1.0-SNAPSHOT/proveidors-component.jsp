<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%
    // Si s'accedeix directament sense passar pel servlet, redirigir
    if (request.getAttribute("component") == null) {
        response.sendRedirect("ComponentServlet");
        return;
    }
%>
<!DOCTYPE html>
<html lang="ca">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gestionar Proveïdors - Tallers Manolo</title>
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
        <h1>Gestionar Proveïdors i Preus</h1>
        <h2>Component: ${component.cmCodi} - ${component.itNom}</h2>
        
        <!-- Informació del component -->
        <div class="info-component">
            <div class="info-item">
                <strong class="negreta">Codi:</strong> ${component.cmCodi}
            </div>
            <div class="info-item">
                <strong class="negreta">Descripció:</strong> ${component.itDesc}
            </div>
            <div class="info-item">
                <strong class="negreta">Unitat Mesura:</strong> ${component.cmUmCodi}
            </div>
            <div class="info-item preu-destacat">
                <strong class="negreta">Preu Mitjà Actual:</strong> 
                <span class="preu-gran">
                    <fmt:formatNumber value="${component.cmPreuMig}" type="currency" currencySymbol="€" minFractionDigits="2"/>
                </span>
                <span class="info-icon" title="Calculat automàticament pels triggers Oracle"><img src="media/info.svg" alt="Informació">️</span>
            </div>
        </div>

        <!-- Missatges -->
        <c:if test="${not empty success}">
            <div class="alert alert-success">
                ✅ ${success}
            </div>
        </c:if>
        
        <c:if test="${not empty error}">
            <div class="alert alert-error">
                ❌ ${error}
            </div>
        </c:if>
        
        <c:if test="${not empty info}">
            <div class="alert alert-info">
                💡 ${info}
            </div>
        </c:if>

        <!-- Formulari per afegir proveïdor -->
        <div class="formulari-afegir">
            <h3>Afegir Proveïdor amb Preu</h3>
            <form method="post" action="ProveidorComponentServlet">
                <input type="hidden" name="component" value="${component.cmCodi}">
                <input type="hidden" name="action" value="add">
                
                <div class="fila-formulari">
                    <div class="grup-camp">
                        <label for="proveidor" class="etiqueta">Proveïdor *</label>
                        <select id="proveidor" name="proveidor" class="camp" required>
                            <option value="">-- Selecciona proveïdor --</option>
                            <c:forEach var="prov" items="${proveidorsDisponibles}">
                                <option value="${prov.pvCodi}">
                                    ${prov.pvCodi} - ${prov.pvCodi}
                                </option>
                            </c:forEach>
                        </select>
                    </div>
                    
                    <div class="grup-camp">
                        <label for="preu" class="etiqueta">Preu (€) *</label>
                        <input type="number" 
                               id="preu" 
                               name="preu" 
                               class="camp" 
                               step="0.01" 
                               min="0" 
                               placeholder="0.00"
                               required>
                    </div>
                    
                    <div class="grup-camp">
                        <button type="submit" class="boto boto-afegir">
                            Afegir Proveïdor
                        </button>
                    </div>
                </div>
            </form>
        </div>

        <!-- Llista de proveïdors actuals -->
        <div class="llista-proveidors">
            <h3>Proveïdors Actuals (${proveidorsActuals.size()})</h3>
            
            <c:choose>
                <c:when test="${empty proveidorsActuals}">
                    <div class="empty-state">
                        <p>⚠️ Aquest component encara no té proveïdors assignats.</p>
                        <p class="text-help">Afegeix almenys un proveïdor amb el seu preu perquè el sistema calculi el preu mitjà.</p>
                    </div>
                </c:when>
                
                <c:otherwise>
                    <table class="taula">
                        <thead>
                            <tr>
                                <th>Codi Proveïdor</th>
                                <th>Nom Proveïdor</th>
                                <th>Preu Unitari</th>
                                <th>Accions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="pc" items="${proveidorsActuals}">
                                <tr>
                                    <td><strong class="negreta">${pc.pcPvCodi}</strong></td>
                                    <td>
                                        <c:set var="proveidor" value="${proveidorsDisponibles.stream().filter(p -> p.pvCodi.equals(pc.pcPvCodi)).findFirst().orElse(null)}"/>
                                        ${proveidor != null ? proveidor.pvCodi : pc.pcPvCodi}
                                    </td>
                                    <td class="text-preu">
                                        <!-- Formulari inline per editar preu -->
                                        <form method="post" 
                                              action="ProveidorComponentServlet" 
                                              style="display:inline-flex; gap:5px; align-items:center;">
                                            <input type="hidden" name="component" value="${component.cmCodi}">
                                            <input type="hidden" name="proveidor" value="${pc.pcPvCodi}">
                                            <input type="hidden" name="action" value="update">
                                            
                                            <input type="number" 
                                                   name="preu" 
                                                   value="${pc.pcPreu}" 
                                                   step="0.01" 
                                                   min="0"
                                                   class="camp-petit"
                                                   required>
                                            <span>€</span>
                                            <button type="submit" 
                                                    class="btn-icon btn-update" 
                                                    title="Actualitzar preu">
                                                <img src="media/save.svg"
                                            </button>
                                        </form>
                                    </td>
                                    <td class="text-center">
                                        <!-- Botó eliminar -->
                                        <form method="post" 
                                              action="ProveidorComponentServlet" 
                                              style="display:inline;"
                                              onsubmit="return confirm('Segur que vols eliminar aquest proveïdor?');">
                                            <input type="hidden" name="component" value="${component.cmCodi}">
                                            <input type="hidden" name="proveidor" value="${pc.pcPvCodi}">
                                            <input type="hidden" name="action" value="remove">
                                            <button type="submit" 
                                                    class="btn-icon btn-delete" 
                                                    title="Eliminar proveïdor">
                                                <img src="media/delete.svg"
                                            </button>
                                        </form>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                    
                    <!-- Càlcul visible del preu mitjà -->
                    <div class="calculadora-preu">
                        <h4><img src="media/stats.svg">Càlcul del Preu Mitjà:</h4>
                        <div class="formula">
                            <div class="formula-explicacio">
                                <c:set var="sumaPreu" value="0"/>
                                <c:forEach var="pc" items="${proveidorsActuals}">
                                    <c:set var="sumaPreu" value="${sumaPreu + pc.pcPreu}"/>
                                    <div class="linia-preu">
                                        ${pc.pcPvCodi}: 
                                        <fmt:formatNumber value="${pc.pcPreu}" type="currency" currencySymbol="€" minFractionDigits="2"/>
                                    </div>
                                </c:forEach>
                                <div class="linia-suma">
                                    = <fmt:formatNumber value="${sumaPreu}" type="currency" currencySymbol="€" minFractionDigits="2"/> 
                                    ÷ ${proveidorsActuals.size()} proveïdors
                                </div>
                                <div class="linia-resultat">
                                    <strong class="negreta">Preu Mitjà: 
                                        <fmt:formatNumber value="${sumaPreu / proveidorsActuals.size()}" type="currency" currencySymbol="€" minFractionDigits="2"/>
                                    </strong>
                                </div>
                            </div>
                        </div>
                        <p class="text-help">
                            Aquest càlcul s'actualitza automàticament a la base de dades mitjançant triggers Oracle.
                        </p>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>

        <!-- Botons d'acció final -->
        <div class="fila-botons-final">
            <a href="ComponentServlet" class="boto boto-secundari">
                ← Tornar a Components
            </a>
            
            <c:if test="${nouComponent}">
                <form method="post" action="ProveidorComponentServlet" style="display:inline;">
                    <input type="hidden" name="component" value="${component.cmCodi}">
                    <input type="hidden" name="action" value="finalitzar">
                    <button type="submit" class="boto boto-primari">
                        ✅ Finalitzar Component
                    </button>
                </form>
            </c:if>
        </div>
    </main>
    
    <style>
        /* PALETA CORPORATIVA TALLERS MANOLO */
        
        .info-component {
            background: #ffffff;
            border: 1px solid #4a5568;
            padding: 20px;
            border-radius: 8px;
            margin-bottom: 20px;
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
        }
        
        .info-item {
            display: flex;
            flex-direction: column;
            gap: 5px;
        }
        
        .info-item strong {
            font-family: 'Inter', sans-serif;
            font-weight: 600;
            color: #2c5282;
        }
        
        .preu-destacat {
            background: rgba(0, 102, 204, 0.05);
            padding: 10px;
            border-radius: 4px;
            border: 2px solid #0066cc;
        }
        
        .preu-gran {
            font-size: 1.5em;
            color: #1a365d;
            font-weight: 700;
            font-family: 'Roboto', sans-serif;
        }
        
        .info-icon {
            cursor: help;
            color: #0066cc;
        }
        
        .negreta {
            font-family: 'Roboto', sans-serif;
            font-weight: 700;
            color: #000000;
        }
        
        /* ALERTS amb paleta corporativa */
        .alert {
            padding: 15px;
            margin-bottom: 20px;
            border-radius: 4px;
            font-weight: 500;
            font-family: 'Roboto', sans-serif;
        }
        
        .alert-success {
            background-color: rgba(26, 54, 93, 0.1);
            color: #1a365d;
            border: 1px solid #2c5282;
        }
        
        .alert-error {
            background-color: rgba(220, 53, 69, 0.1);
            color: #721c24;
            border: 1px solid #dc3545;
        }
        
        .alert-info {
            background-color: rgba(0, 102, 204, 0.1);
            color: #0066cc;
            border: 1px solid #0066cc;
        }
        
        .formulari-afegir {
            background: #ffffff;
            padding: 20px;
            border-radius: 8px;
            border: 1px solid #4a5568;
            box-shadow: 0 2px 8px rgba(26, 54, 93, 0.1);
            margin-bottom: 30px;
        }
        
        .formulari-afegir h3 {
            font-family: 'Inter', sans-serif;
            font-weight: 600;
            color: #2c5282;
            margin-bottom: 15px;
        }
        
        .fila-formulari {
            display: grid;
            grid-template-columns: 2fr 1fr auto;
            gap: 15px;
            align-items: end;
        }
        
        .grup-camp {
            display: flex;
            flex-direction: column;
            gap: 5px;
        }
        
        .etiqueta {
            font-family: 'Inter', sans-serif;
            font-weight: 600;
            color: #2c5282;
            margin-bottom: 5px;
        }
        
        .camp, .camp-petit {
            padding: 10px;
            border: 1px solid #4a5568;
            border-radius: 4px;
            font-size: 14px;
            font-family: 'Roboto', sans-serif;
            color: #000000;
        }
        
        .camp:focus, .camp-petit:focus {
            outline: none;
            border-color: #0066cc;
            box-shadow: 0 0 0 2px rgba(0, 102, 204, 0.1);
        }
        
        .camp-petit {
            width: 100px;
            padding: 5px;
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
            text-align: center;
            transition: all 0.3s ease;
        }
        
        .boto-afegir {
            background-color: #1a365d;
            color: #ffffff;
        }
        
        .boto-afegir:hover {
            background-color: #2c5282;
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
        
        .llista-proveidors {
            background: #ffffff;
            padding: 20px;
            border-radius: 8px;
            border: 1px solid #4a5568;
            box-shadow: 0 2px 8px rgba(26, 54, 93, 0.1);
            margin-bottom: 20px;
        }
        
        .llista-proveidors h3 {
            font-family: 'Inter', sans-serif;
            font-weight: 600;
            color: #2c5282;
            margin-bottom: 15px;
        }
        
        .empty-state {
            text-align: center;
            padding: 40px;
            color: #4a5568;
        }
        
        .text-help {
            font-size: 0.9em;
            color: #4a5568;
            font-style: italic;
        }
        
        .taula {
            width: 100%;
            border-collapse: collapse;
            margin: 20px 0;
        }
        
        .taula th,
        .taula td {
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid #4a5568;
        }
        
        .taula th {
            background-color: #1a365d;
            color: #ffffff;
            font-family: 'Roboto', sans-serif;
            font-weight: 600;
        }
        
        .taula tbody tr:hover {
            background-color: rgba(0, 102, 204, 0.05);
        }
        
        .text-center {
            text-align: center;
        }
        
        .text-preu {
            font-weight: 500;
            color: #1a365d;
        }
        
        .btn-icon {
            background: none;
            border: none;
            font-size: 1.2em;
            cursor: pointer;
            padding: 5px;
            transition: transform 0.2s;
        }
        
        .btn-update:hover {
            transform: scale(1.2);
        }
        
        .btn-delete:hover {
            transform: scale(1.2);
            filter: hue-rotate(345deg);
        }
        
        .calculadora-preu {
            background: rgba(0, 102, 204, 0.05);
            padding: 20px;
            border-radius: 8px;
            border: 1px solid #0066cc;
            margin-top: 20px;
        }
        
        .calculadora-preu h4 {
            font-family: 'Inter', sans-serif;
            font-weight: 600;
            color: #2c5282;
            margin-bottom: 10px;
        }
        
        .formula-explicacio {
            background: #ffffff;
            padding: 15px;
            border-radius: 4px;
            border: 1px solid #4a5568;
            margin: 10px 0;
        }
        
        .linia-preu {
            padding: 5px 0;
            border-bottom: 1px dotted #4a5568;
            color: #000000;
        }
        
        .linia-suma {
            padding: 10px 0;
            font-weight: 500;
            color: #0066cc;
        }
        
        .linia-resultat {
            padding: 10px;
            background: rgba(26, 54, 93, 0.1);
            border: 1px solid #2c5282;
            border-radius: 4px;
            margin-top: 10px;
            font-size: 1.2em;
            color: #1a365d;
        }
        
        .fila-botons-final {
            display: flex;
            justify-content: space-between;
            gap: 15px;
            margin-top: 30px;
        }
        
        @media (max-width: 768px) {
            .fila-formulari {
                grid-template-columns: 1fr;
            }
            
            .info-component {
                grid-template-columns: 1fr;
            }
        }
    </style>
</body>
</html>
