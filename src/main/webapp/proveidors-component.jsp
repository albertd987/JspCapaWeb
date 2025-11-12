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
                <strong>Codi:</strong> ${component.cmCodi}
            </div>
            <div class="info-item">
                <strong>Descripció:</strong> ${component.itDesc}
            </div>
            <div class="info-item">
                <strong>Unitat Mesura:</strong> ${component.cmUmCodi}
            </div>
            <div class="info-item preu-destacat">
                <strong>Preu Mitjà Actual:</strong> 
                <span class="preu-gran">
                    <fmt:formatNumber value="${component.cmPreuMig}" type="currency" currencySymbol="€" minFractionDigits="2"/>
                </span>
                <span class="info-icon" title="Calculat automàticament pels triggers Oracle">ℹ️</span>
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
                        <label for="proveidor">Proveïdor *</label>
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
                        <label for="preu">Preu (€) *</label>
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
                            ➕ Afegir Proveïdor
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
                                    <td><strong>${pc.pcPvCodi}</strong></td>
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
                                                💾
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
                                                🗑️
                                            </button>
                                        </form>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                    
                    <!-- Càlcul visible del preu mitjà -->
                    <div class="calculadora-preu">
                        <h4>📊 Càlcul del Preu Mitjà:</h4>
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
                                    <strong>Preu Mitjà: 
                                        <fmt:formatNumber value="${sumaPreu / proveidorsActuals.size()}" type="currency" currencySymbol="€" minFractionDigits="2"/>
                                    </strong>
                                </div>
                            </div>
                        </div>
                        <p class="text-help">
                            ⚡ Aquest càlcul s'actualitza automàticament a la base de dades mitjançant triggers Oracle.
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
        .info-component {
            background: #f8f9fa;
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
        
        .preu-destacat {
            background: #fff3cd;
            padding: 10px;
            border-radius: 4px;
            border: 2px solid #ffc107;
        }
        
        .preu-gran {
            font-size: 1.5em;
            color: #28a745;
            font-weight: bold;
        }
        
        .info-icon {
            cursor: help;
            color: #007bff;
        }
        
        .alert {
            padding: 15px;
            margin-bottom: 20px;
            border-radius: 4px;
            font-weight: 500;
        }
        
        .alert-success {
            background-color: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }
        
        .alert-error {
            background-color: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }
        
        .alert-info {
            background-color: #d1ecf1;
            color: #0c5460;
            border: 1px solid #bee5eb;
        }
        
        .formulari-afegir {
            background: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            margin-bottom: 30px;
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
        
        .camp, .camp-petit {
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 14px;
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
            font-weight: 600;
            text-decoration: none;
            display: inline-block;
            text-align: center;
        }
        
        .boto-afegir {
            background-color: #28a745;
            color: white;
        }
        
        .boto-afegir:hover {
            background-color: #218838;
        }
        
        .boto-primari {
            background-color: #007bff;
            color: white;
        }
        
        .boto-secundari {
            background-color: #6c757d;
            color: white;
        }
        
        .llista-proveidors {
            background: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            margin-bottom: 20px;
        }
        
        .empty-state {
            text-align: center;
            padding: 40px;
            color: #666;
        }
        
        .text-help {
            font-size: 0.9em;
            color: #666;
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
            border-bottom: 1px solid #ddd;
        }
        
        .taula th {
            background-color: #f8f9fa;
            font-weight: 600;
        }
        
        .text-center {
            text-align: center;
        }
        
        .text-preu {
            font-weight: bold;
            color: #28a745;
        }
        
        .btn-icon {
            background: none;
            border: none;
            font-size: 1.2em;
            cursor: pointer;
            padding: 5px;
        }
        
        .btn-update:hover {
            transform: scale(1.2);
        }
        
        .btn-delete:hover {
            transform: scale(1.2);
        }
        
        .calculadora-preu {
            background: #e7f3ff;
            padding: 20px;
            border-radius: 8px;
            margin-top: 20px;
        }
        
        .formula-explicacio {
            background: white;
            padding: 15px;
            border-radius: 4px;
            margin: 10px 0;
        }
        
        .linia-preu {
            padding: 5px 0;
            border-bottom: 1px dotted #ddd;
        }
        
        .linia-suma {
            padding: 10px 0;
            font-weight: bold;
            color: #007bff;
        }
        
        .linia-resultat {
            padding: 10px;
            background: #d4edda;
            border-radius: 4px;
            margin-top: 10px;
            font-size: 1.2em;
            color: #155724;
        }
        
        .fila-botons-final {
            display: flex;
            justify-content: space-between;
            gap: 15px;
            margin-top: 30px;
        }
    </style>
</body>
</html>
