<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%
    // Si s'accedeix directament sense passar pel servlet, redirigir
    if (request.getAttribute("components") == null) {
        response.sendRedirect("ComponentServlet");
        return;
    }
%>
<!DOCTYPE html>
<html lang="ca">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gestió de components - Tallers Manolo</title>
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
        <h1>Gestió de components</h1>
        
        <!-- Missatges d'èxit o error -->
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
        
        <div class="barra-accions">
            <!-- Formulari de cerca -->
            <form action="ComponentServlet" method="get" class="caixa-cerca">
                <span class="icona-cerca"><img src="media/search.svg" alt="search"></span>
                <input type="text" 
                       name="filtre" 
                       class="input-cerca" 
                       placeholder="filtrar per codi"
                       value="${filtre}">
                <button type="submit" style="display:none;">Cercar</button>
            </form>
            
            <a href="editar-component.jsp" class="boto boto-primari">NOU COMPONENT</a>
        </div>

        <div class="contenidor-taula">
            <c:choose>
                <c:when test="${empty components}">
                    <p class="text-empty">No hi ha components per mostrar.</p>
                </c:when>
                
                <c:otherwise>
                    <table class="taula">
                        <thead>
                            <tr>
                                <th>Codi</th>
                                <th>Nom del Component</th>
                                <th>Descripció</th>
                                <th>Fabricant</th>
                                <th>Unitat</th>
                                <th>Stock</th>
                                <th>Preu Mitjà</th>
                                <th>Proveïdors</th>
                                <th>Accions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="component" items="${components}">
                                <tr>
                                    <td><strong>${component.itCodi}</strong></td>
                                    <td>${component.itNom}</td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${not empty component.itDesc && component.itDesc.length() > 50}">
                                                ${component.itDesc.substring(0, 50)}...
                                            </c:when>
                                            <c:otherwise>
                                                ${component.itDesc}
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>${component.cmCodiFabricant}</td>
                                    <td>${component.cmUmCodi}</td>
                                    <td class="text-center">${component.itStock != null ? component.itStock : 0}</td>
                                    <td class="text-preu-readonly">
                                        <fmt:formatNumber value="${component.cmPreuMig}" type="currency" currencySymbol="€" minFractionDigits="2"/>
                                        <span class="tooltip-icon" title="Preu calculat automàticament pels triggers Oracle">️<img src="media/info.svg" alt="Información" class="alert-icon">
</span>
                                    </td>
                                    <td class="text-center">
                                        <!-- Link a gestió de proveïdors -->
                                        <a href="ProveidorComponentServlet?component=${component.cmCodi}" 
                                           class="link-proveidors" 
                                           title="Gestionar proveïdors i preus">
                                            <img src="media/money.svg" alt="media">
                                        </a>
                                    </td>
                                    <td class="accions">
                                        <!-- Botó editar -->
                                        <a href="editar-component.jsp?codi=${component.cmCodi}" 
                                           class="btn-icon btn-edit" 
                                           title="Editar">
                                           <img src="media/edit.svg" alt="editar">
                                        </a>
                                        
                                        <!-- Botó eliminar -->
                                        <form action="ComponentServlet" 
                                              method="post" 
                                              style="display:inline;"
                                              onsubmit="return confirm('Segur que vols eliminar aquest component?');">
                                            <input type="hidden" name="action" value="delete">
                                            <input type="hidden" name="codiComponent" value="${component.cmCodi}">
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
                    
                    <!-- Resum -->
                    <div class="taula-footer">
                        <p>Total de components: <strong>${components.size()}</strong></p>
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
        
        .text-center {
            text-align: center;
        }
        
        /* Estil especial per preu readonly */
        .text-preu-readonly {
            background-color: #f0f0f0;
            color: #666;
            font-weight: bold;
            text-align: right;
            padding-right: 10px;
            position: relative;
        }
        
        .tooltip-icon {
            font-size: 0.8em;
            cursor: help;
            margin-left: 5px;
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
            text-decoration: none;
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
        
        .link-proveidors {
            font-size: 1.5em;
            text-decoration: none;
            transition: transform 0.2s;
            display: inline-block;
        }
        
        .link-proveidors:hover {
            transform: scale(1.3);
        }
        
        .taula-footer {
            margin-top: 15px;
            text-align: right;
            color: #666;
        }
    </style>
</body>
</html>
