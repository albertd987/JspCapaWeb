<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%
    // Si s'accedeix directament sense passar pel servlet, redirigir
    if (request.getAttribute("productes") == null) {
        response.sendRedirect("ProducteServlet");
        return;
    }
%>
<!DOCTYPE html>
<html lang="ca">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Gestió de productes - Tallers Manolo</title>
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
            <h1>Gestió de productes</h1>

            <!-- Missatges d'èxit o error -->
            <c:if test="${not empty success}">
                <div class="alert alert-success">
                    ${success}
                </div>
            </c:if>

            <c:if test="${not empty error}">
                <div class="alert alert-error">
                    ${error}
                </div>
            </c:if>

            <div class="barra-accions">
                <!-- Formulari de cerca -->
                <form action="ProducteServlet" method="get" class="caixa-cerca">
                    <span class="icona-cerca"><img src="media/search.svg" alt="search"></span>
                    <input type="text" 
                           name="filtre" 
                           class="input-cerca" 
                           placeholder="filtrar per codi"
                           value="${filtre}">
                    <button type="submit" style="display:none;">Cercar</button>
                </form>

                <a href="editar-producte.jsp" class="boto boto-primari">NOU PRODUCTE</a>
            </div>

            <div class="contenidor-taula">
                <c:choose>
                    <c:when test="${empty productes}">
                        <p class="text-empty">No hi ha productes per mostrar.</p>
                    </c:when>

                    <c:otherwise>
                        <table class="taula">
                            <thead>
                                <tr>
                                    <th>Codi</th>
                                    <th>Nom del Producte</th>
                                    <th>Descripció</th>
                                    <th>Stock</th>
                                    <th>Informe BOM</th>
                                    <th>Accions</th>
                                </tr>
                            </thead>
                           <tbody>
                                <c:forEach var="producte" items="${productes}">
                                    <tr>
                                        <td>${producte.prCodi}</td>
                                        <td>${producte.itNom}</td>
                                        <td>${producte.itDesc}</td>
                                        <td>${producte.itStock}</td>
                                        <td>
                                            <!-- Botó PDF BOM -->
                                            <a href="BOMServlet?codi=${producte.prCodi}" 
                                               class="link-bom" 
                                               title="Generar BOM PDF"
                                               target="_blank">
                                                <img src="media/file.svg" alt="PDF BOM" class="delete-icon">
                                            </a>

                                            <!-- Botó arbre BOM -->
                                            <a href="javascript:void(0);" 
                                               onclick="window.open('${pageContext.request.contextPath}/arbreBOM?prCodi=${producte.prCodi}',
                                                               'ArbreBOM',
                                                               'width=800,height=600,scrollbars=yes,resizable=yes')" 
                                               class="link-bom" 
                                               title="Veure arbre BOM"
                                               style="margin-left: 10px;">
                                                <img src="media/tree.svg" alt="Arbre BOM" class="delete-icon">
                                            </a>
                                        </td>
                                        <td class="accions">
                                            <!-- Editar -->
                                            <a href="editar-producte.jsp?codi=${producte.prCodi}" 
                                               class="btn-icon btn-edit" 
                                               title="Editar">
                                                <img src="media/edit.svg" alt="Editar" class="delete-icon">
                                            </a>

                                            <!-- Eliminar amb confirmació -->
                                            <form action="ProducteServlet" 
                                                  method="post" 
                                                  style="display:inline;"
                                                  onsubmit="return confirm('Segur que vols eliminar ${producte.prCodi}?');">
                                                <input type="hidden" name="action" value="delete">
                                                <input type="hidden" name="codiProducte" value="${producte.prCodi}">
                                                <button type="submit" 
                                                        class="btn-icon btn-delete" 
                                                        title="Eliminar">
                                                    <img src="media/delete.svg" alt="Eliminar" class="delete-icon">
                                                </button>
                                            </form>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>

                        </table>

                        <!-- Resum -->
                        <div class="taula-footer">
                            <p>Total de productes: <strong>${productes.size()}</strong></p>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </main>

        <style>
            /* Estils per missatges */
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

            .text-empty {
                text-align: center;
                padding: 40px;
                color: #666;
                font-style: italic;
            }

            .accions {
                display: flex;
                gap: 10px;
                justify-content: center;
            }

            .btn-icon {
                background: none;
                border: none;
                font-size: 1.2em;
                cursor: pointer;
                padding: 5px;
            }

            .btn-edit:hover {
                transform: scale(1.2);
            }

            .btn-delete {
                background: none;
                border: none;
                font-size: 1.2em;
                cursor: pointer;
            }

            .btn-delete:hover {
                transform: scale(1.2);
            }

            .link-bom {
                color: #007bff;
                text-decoration: none;
            }

            .link-bom:hover {
                text-decoration: underline;
            }

            .taula-footer {
                margin-top: 15px;
                text-align: right;
                color: #666;
            }
        </style>
    </body>
</html>
