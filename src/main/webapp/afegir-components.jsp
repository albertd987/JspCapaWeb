<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="ca">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Gestionar Components - Tallers Manolo</title>
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
            <!-- Títol dinàmic segons mode -->
            <h1>
                <c:choose>
                    <c:when test="${esNouProducte}">
                        Afegir components al nou producte ${producte.prCodi}
                    </c:when>
                    <c:otherwise>
                        Gestionar components del producte ${producte.prCodi}
                    </c:otherwise>
                </c:choose>
            </h1>

            <!-- Missatge informatiu si és producte nou -->
            <c:if test="${esNouProducte}">
                <div class="alert alert-info">
                    <img src="media/warning.svg" alt="Informació" class="alert-icon">
                    <img src="media/info.svg">️️ <strong>Producte creat correctament.</strong> 
                    Afegeix almenys 1 component per completar-lo.
                </div>
            </c:if>

            <!-- Missatge informatiu per mode edició -->
            <c:if test="${not esNouProducte}">
                <div class="alert alert-info">
                    <img src="media/info.svg">️ <strong>Mode d'edició:</strong> Pots afegir o eliminar components d'aquest producte. Els canvis es guarden automàticament.
                </div>
            </c:if>

            <!-- Missatges d'èxit o error -->
            <c:if test="${not empty param.success}">
                <div class="alert alert-success">
                    ${param.success}
                </div>
            </c:if>

            <c:if test="${not empty param.error}">
                <div class="alert alert-error">
                    ${param.error}
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

            <!-- Formulari per afegir component o subproducte -->
            <div class="formulari-contenidor">
                <form method="post" action="ComponentProducteServlet">
                    <input type="hidden" name="action" value="add">
                    <input type="hidden" name="producte" value="${producte.prCodi}">

                    <fieldset class="fieldset">
                        <legend class="llegenda">Afegir component o subproducte</legend>

                        <div class="fila-camps">
                            <!-- Dropdown amb COMPONENTS y SUBPRODUCTES -->
                            <div class="grup-camp" style="flex: 2;">
                                <label class="etiqueta" for="component">COMPONENT / SUBPRODUCTE *</label>
                                <select id="component" 
                                        name="component" 
                                        class="camp"
                                        required>
                                    <option value="">Selecciona un ítem</option>

                                    <!-- Components primaris -->
                                    <optgroup label="Components Primaris">
                                        <c:forEach var="comp" items="${componentsDisponibles}">
                                            <option value="${comp.cmCodi}">
                                                ${comp.cmCodi} - ${comp.itNom}
                                            </option>
                                        </c:forEach>
                                    </optgroup>

                                    <!-- Subproductes -->
                                    <optgroup label="Subproductes">
                                        <c:forEach var="prod" items="${productesDisponibles}">
                                            <option value="${prod.prCodi}">
                                                ${prod.prCodi} - ${prod.itNom}
                                            </option>
                                        </c:forEach>
                                    </optgroup>
                                </select>
                            </div>

                            <div class="grup-camp" style="flex: 1;">
                                <label class="etiqueta" for="quantitat">QUANTITAT *</label>
                                <input type="number" 
                                       id="quantitat" 
                                       name="quantitat" 
                                       class="camp" 
                                       min="0.01" 
                                       step="0.01"
                                       value="1" 
                                       required>
                            </div>
                        </div>

                        <div class="grup-botons">
                            <button type="submit" class="boto boto-secundari">
                                 <img src="media/add.svg">AFEGIR ÍTEM
                            </button>
                        </div>
                    </fieldset>
                </form>
            </div>

            <!-- Taula de components afegits -->
            <div class="contenidor-taula">
                <h2>Components i subproductes afegits</h2>

                <c:choose>
                    <c:when test="${empty componentsAfegits}">
                        <!-- Mensaje dinámico según modo -->
                        <p class="missatge-buit">
                            <c:choose>
                                <c:when test="${esNouProducte}">
                                    Aquest producte encara no té components.
                                    <br>Afegeix almenys 1 component per poder finalitzar.
                                </c:when>
                                <c:otherwise>
                                    Aquest producte no té components actualment.
                                    <br>Pots afegir components o subproductes utilitzant el formulari de dalt.
                                </c:otherwise>
                            </c:choose>
                        </p>
                    </c:when>

                    <c:otherwise>
                        <table class="taula">
                            <thead>
                                <tr>
                                    <th>Codi</th>
                                    <th>Nom del Component / Subproducte</th>
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
                                                     <img src="media/delete.svg">
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

            <!-- Botons d'acció dinàmics segons mode -->
            <div class="barra-accions-final">
                <c:choose>
                    <c:when test="${esNouProducte}">
                        <!-- Modo NOU: Cancel·lar NO elimina el producte -->
                        <a href="ProducteServlet" class="boto boto-secundari">
                            CANCEL·LAR
                        </a>
                    </c:when>
                    <c:otherwise>
                        <!-- Modo EDICIÓ: Tornar a la llista -->
                        <a href="ProducteServlet" class="boto boto-secundari">
                            TORNAR
                        </a>
                    </c:otherwise>
                </c:choose>

                <form method="post" 
                      action="ComponentProducteServlet" 
                      style="display:inline;">
                    <input type="hidden" name="action" value="finalitzar">
                    <input type="hidden" name="producte" value="${producte.prCodi}">
                    <button type="submit" 
                            class="boto boto-primari"
                            ${empty componentsAfegits ? 'disabled' : ''}>
                        <c:choose>
                            <c:when test="${esNouProducte}">
                                FINALITZAR
                            </c:when>
                            <c:otherwise>
                                GUARDAR CANVIS
                            </c:otherwise>
                        </c:choose>
                    </button>
                </form>
            </div>
        </main>

        <!-- Estils addicionals -->
        <style>
            .alert-info {
                background-color: #d1ecf1;
                color: #0c5460;
                border: 1px solid #bee5eb;
                padding: 12px 15px;
                margin-bottom: 20px;
                border-radius: 4px;
            }

            .missatge-buit {
                text-align: center;
                padding: 40px;
                color: #666;
                font-size: 1.1em;
                line-height: 1.6;
            }

            /* aparença d'optgroup */
            optgroup {
                font-weight: bold;
                font-style: normal;
                color: #333;
            }

            option {
                font-weight: normal;
                padding: 5px;
            }

            /* Efecte taula */
            .taula tbody tr:hover {
                background-color: #f8f9fa;
            }
        </style>
    </body>
</html>
