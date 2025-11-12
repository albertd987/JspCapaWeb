<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="ca">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Afegir Components - Tallers Manolo</title>
    <link rel="stylesheet" href="css/tallersmanolo.css">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@600;700&family=Roboto:wght@400;500;700&display=swap" rel="stylesheet">
</head>
<body>
    <header class="capsalera">
        <div class="logo">TALLERS MANOLO</div>
        <nav class="navegacio">
            <a href="ProducteServlet" class="enllac-nav actiu">PRODUCTES</a>
            <a href="components.jsp" class="enllac-nav">COMPONENTS PRIMARIS</a>
        </nav>
    </header>

    <main class="contenidor">
        <h1>Afegir components al producte ${producte.prCodi}</h1>
        
        <!-- Missatge informatiu si és producte nou -->
        <c:if test="${param.nouProducte == 'true'}">
            <div class="alert alert-info">
                <img src="media/warning.svg" alt="Informació" class="alert-icon">
️ <strong>Producte creat correctament.</strong> 
                Afegeix almenys 1 component per completar-lo.
            </div>
        </c:if>
        
        <!-- Missatges d'èxit o error -->
        <c:if test="${not empty param.success}">
            <div class="alert alert-success">
                ✅ ${param.success}
            </div>
        </c:if>
        
        <c:if test="${not empty param.error}">
            <div class="alert alert-error">
                ❌ ${param.error}
            </div>
        </c:if>

        <!-- Informació del producte -->
        <div class="formulari-contenidor">
            <fieldset class="fieldset">
                <legend class="llegenda">Informació del producte</legend>
                
                <div class="info-producte-grid">
                    <div class="info-item">
                        <span class="info-label">Codi:</span>
                        <span class="info-value">${producte.prCodi}</span>
                    </div>
                    <div class="info-item">
                        <span class="info-label">Nom:</span>
                        <span class="info-value">${producte.itNom}</span>
                    </div>
                    <div class="info-item">
                        <span class="info-label">Descripció:</span>
                        <span class="info-value">${producte.itDesc}</span>
                    </div>
                    <div class="info-item">
                        <span class="info-label">Stock:</span>
                        <span class="info-value">${producte.itStock}</span>
                    </div>
                </div>
            </fieldset>
        </div>

        <!-- Formulari per afegir component -->
        <div class="formulari-contenidor">
            <form method="post" action="ComponentProducteServlet">
                <input type="hidden" name="action" value="add">
                <input type="hidden" name="producte" value="${producte.prCodi}">
                
                <fieldset class="fieldset">
                    <legend class="llegenda">Afegir component</legend>
                    
                    <div class="fila-camps">
                        <div class="grup-camp" style="flex: 2;">
                            <label class="etiqueta" for="component">COMPONENT *</label>
                            <select id="component" 
                                    name="component" 
                                    class="camp" 
                                    required>
                                <option value="">Selecciona un component</option>
                                <c:forEach var="comp" items="${componentsDisponibles}">
                                    <option value="${comp.cmCodi}">
                                        ${comp.cmCodi} - ${comp.itNom}
                                    </option>
                                </c:forEach>
                            </select>
                        </div>
                        
                        <div class="grup-camp" style="flex: 1;">
                            <label class="etiqueta" for="quantitat">QUANTITAT *</label>
                            <input type="number" 
                                   id="quantitat" 
                                   name="quantitat" 
                                   class="camp" 
                                   min="1" 
                                   value="1" 
                                   required>
                        </div>
                    </div>
                    
                    <div class="grup-botons">
                        <button type="submit" class="boto boto-secundari">
                            AFEGIR COMPONENT
                        </button>
                    </div>
                </fieldset>
            </form>
        </div>

        <!-- Taula de components afegits -->
        <div class="contenidor-taula">
            <h2>Components afegits</h2>
            
            <c:choose>
                <c:when test="${empty componentsAfegits}">
                    <p class="text-empty">
                        No hi ha components afegits encara. 
                        Afegeix almenys 1 component per poder finalitzar.
                    </p>
                </c:when>
                
                <c:otherwise>
                    <table class="taula">
                        <thead>
                            <tr>
                                <th>Codi</th>
                                <th>Nom del Component</th>
                                <th>Quantitat</th>
                                <th>Accions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="item" items="${componentsAfegits}">
                                <tr>
                                    <td>${item.piItCodi}</td>
                                    <td>${requestScope['nom_'.concat(item.piItCodi)]}</td>
                                    <td>${item.quantitat}</td>
                                    <td class="accions">
                                        <form method="post" 
                                              action="ComponentProducteServlet" 
                                              style="display:inline;"
                                              onsubmit="return confirm('Segur que vols eliminar ${item.piItCodi}?');">
                                            <input type="hidden" name="action" value="remove">
                                            <input type="hidden" name="producte" value="${producte.prCodi}">
                                            <input type="hidden" name="component" value="${item.piItCodi}">
                                            <button type="submit" 
                                                    class="btn-icon btn-delete" 
                                                    title="Eliminar">
                                                🗑️
                                            </button>
                                        </form>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </c:otherwise>
            </c:choose>
        </div>

        <!-- Botons d'acció finals -->
        <div class="barra-accions-final">
            <a href="ProducteServlet" class="boto boto-secundari">
                CANCEL·LAR
            </a>
            
            <form method="post" 
                  action="ComponentProducteServlet" 
                  style="display:inline;">
                <input type="hidden" name="action" value="finalitzar">
                <input type="hidden" name="producte" value="${producte.prCodi}">
                <button type="submit" 
                        class="boto boto-primari"
                        ${empty componentsAfegits ? 'disabled' : ''}>
                    FINALITZAR
                </button>
            </form>
        </div>
    </main>
</body>
</html>
