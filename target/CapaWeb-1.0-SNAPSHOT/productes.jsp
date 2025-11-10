<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="ca">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gestió de productes - Tallers Manolo</title>
    <link rel="stylesheet" href="css\tallersmanolo.css">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@600;700&family=Roboto:wght@400;500;700&display=swap" rel="stylesheet">
</head>
<body>
    <header class="capsalera">
        <div class="logo">TALLERS MANOLO</div>
        <nav class="navegacio">
            <a href="productes.jsp" class="enllac-nav actiu">PRODUCTES</a>
            <a href="components.jsp" class="enllac-nav">COMPONENTS PRIMARIS</a>
        </nav>
    </header>

    <main class="contenidor">
        <h1>Gestió de productes</h1>
        
        <div class="barra-accions">
            <div class="caixa-cerca">
                <span class="icona-cerca">🔍</span>
                <input type="text" class="input-cerca" placeholder="filtrar per codi">
            </div>
            <a href="editar-producte.jsp" class="boto boto-primari">NOU PRODUCTE</a>
        </div>

        <div class="contenidor-taula">
            <table class="taula">
                <thead>
                    <tr>
                        <th>Codi</th>
                        <th>Nom del Producte</th>
                        <th>Descripció</th>
                        <th>Informe BOM</th>
                        <th>Accions</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td>PRD-001</td>
                        <td>Motor V8 Turbo</td>
                        <td>Motor de combustió interna de 8 cilindres amb turbocompressor</td>
                        <td><a href="#" class="text-destacat">📄</a></td>
                        <td class="accions-cel">
                            <a href="editar-producte.jsp?codi=PRD-001" class="boto-icona">✏️</a>
                            <a href="esborrar-producte.jsp?codi=PRD-001" class="boto-icona boto-esborrar">🗑️</a>
                        </td>
                    </tr>
                    <tr>
                        <td>PRD-002</td>
                        <td>Transmissió Automàtic</td>
                        <td>Sistema de transmissió automàtic de 8 velocitats</td>
                        <td><a href="#" class="text-destacat">📄</a></td>
                        <td class="accions-cel">
                            <a href="editar-producte.jsp?codi=PRD-002" class="boto-icona">✏️</a>
                            <a href="esborrar-producte.jsp?codi=PRD-002" class="boto-icona boto-esborrar">🗑️</a>
                        </td>
                    </tr>
                    <tr>
                        <td>PRD-003</td>
                        <td>Xassís Reforçat</td>
                        <td>Estructura de xassís reforçat per vehicles pesants</td>
                        <td><a href="#" class="text-destacat">📄</a></td>
                        <td class="accions-cel">
                            <a href="editar-producte.jsp?codi=PRD-003" class="boto-icona">✏️</a>
                            <a href="esborrar-producte.jsp?codi=PRD-003" class="boto-icona boto-esborrar">🗑️</a>
                        </td>
                    </tr>
                    <tr>
                        <td>PRD-004</td>
                        <td>Sistema Suspensió</td>
                        <td>Sistema complet de suspensió amb amortidors ajustables</td>
                        <td><a href="#" class="text-destacat">📄</a></td>
                        <td class="accions-cel">
                            <a href="editar-producte.jsp?codi=PRD-004" class="boto-icona">✏️</a>
                            <a href="esborrar-producte.jsp?codi=PRD-004" class="boto-icona boto-esborrar">🗑️</a>
                        </td>
                    </tr>
                    <tr>
                        <td>PRD-005</td>
                        <td>Unitat Control Motor</td>
                        <td>Unitat electrònica de control i gestió del motor</td>
                        <td><a href="#" class="text-destacat">📄</a></td>
                        <td class="accions-cel">
                            <a href="editar-producte.jsp?codi=PRD-005" class="boto-icona">✏️</a>
                            <a href="esborrar-producte.jsp?codi=PRD-005" class="boto-icona boto-esborrar">🗑️</a>
                        </td>
                    </tr>
                    <tr>
                        <td>PRD-006</td>
                        <td>Direcció Assistida</td>
                        <td>Conjunt de bomba i mecanisme de direcció assistida</td>
                        <td><a href="#" class="text-destacat">📄</a></td>
                        <td class="accions-cel">
                            <a href="editar-producte.jsp?codi=PRD-006" class="boto-icona">✏️</a>
                            <a href="esborrar-producte.jsp?codi=PRD-006" class="boto-icona boto-esborrar">🗑️</a>
                        </td>
                    </tr>
                    <tr>
                        <td>PRD-007</td>
                        <td>Alternador 150A</td>
                        <td>Generador elèctric per subministrar energia al vehicle</td>
                        <td><a href="#" class="text-destacat">📄</a></td>
                        <td class="accions-cel">
                            <a href="editar-producte.jsp?codi=PRD-007" class="boto-icona">✏️</a>
                            <a href="esborrar-producte.jsp?codi=PRD-007" class="boto-icona boto-esborrar">🗑️</a>
                        </td>
                    </tr>
                    <tr>
                        <td>PRD-008</td>
                        <td>Radiador Alta Eficiència</td>
                        <td>Sistema de refrigeració amb major dissipació tèrmica</td>
                        <td><a href="#" class="text-destacat">📄</a></td>
                        <td class="accions-cel">
                            <a href="editar-producte.jsp?codi=PRD-008" class="boto-icona">✏️</a>
                            <a href="esborrar-producte.jsp?codi=PRD-008" class="boto-icona boto-esborrar">🗑️</a>
                        </td>
                    </tr>
                    <tr>
                        <td>PRD-009</td>
                        <td>Injecció Electrònica</td>
                        <td>Conjunt d'injectors i rampa de combustible</td>
                        <td><a href="#" class="text-destacat">📄</a></td>
                        <td class="accions-cel">
                            <a href="editar-producte.jsp?codi=PRD-009" class="boto-icona">✏️</a>
                            <a href="esborrar-producte.jsp?codi=PRD-009" class="boto-icona boto-esborrar">🗑️</a>
                        </td>
                    </tr>
                    <tr>
                        <td>PRD-010</td>
                        <td>Frenada ABS</td>
                        <td>Conjunt de control electrònic i sensors per sistema antibloqueig</td>
                        <td><a href="#" class="text-destacat">📄</a></td>
                        <td class="accions-cel">
                            <a href="editar-producte.jsp?codi=PRD-010" class="boto-icona">✏️</a>
                            <a href="esborrar-producte.jsp?codi=PRD-010" class="boto-icona boto-esborrar">🗑️</a>
                        </td>
                    </tr>
                    <tr>
                        <td>PRD-011</td>
                        <td>Bateria 12V 95Ah</td>
                        <td>Font d'energia elèctrica per arrencada i electrònica</td>
                        <td><a href="#" class="text-destacat">📄</a></td>
                        <td class="accions-cel">
                            <a href="editar-producte.jsp?codi=PRD-011" class="boto-icona">✏️</a>
                            <a href="esborrar-producte.jsp?codi=PRD-011" class="boto-icona boto-esborrar">🗑️</a>
                        </td>
                    </tr>
                    <tr>
                        <td>PRD-012</td>
                        <td>Escape Esportiu</td>
                        <td>Línia d'escapament amb menor contrapressió</td>
                        <td><a href="#" class="text-destacat">📄</a></td>
                        <td class="accions-cel">
                            <a href="editar-producte.jsp?codi=PRD-012" class="boto-icona">✏️</a>
                            <a href="esborrar-producte.jsp?codi=PRD-012" class="boto-icona boto-esborrar">🗑️</a>
                        </td>
                    </tr>
                    <tr>
                        <td>PRD-013</td>
                        <td>Turbocompressor Dual</td>
                        <td>Dispositiu de sobrealimentació amb dues turbines</td>
                        <td><a href="#" class="text-destacat">📄</a></td>
                        <td class="accions-cel">
                            <a href="editar-producte.jsp?codi=PRD-013" class="boto-icona">✏️</a>
                            <a href="esborrar-producte.jsp?codi=PRD-013" class="boto-icona boto-esborrar">🗑️</a>
                        </td>
                    </tr>
                </tbody>
            </table>
        </div>

        <div class="paginacio">
            <a href="#" class="pagina-enllac actiu">1</a>
            <a href="#" class="pagina-enllac">2</a>
            <a href="#" class="pagina-enllac">3</a>
            <a href="#" class="pagina-enllac">4</a>
            <a href="#" class="pagina-enllac">5</a>
            <span>...</span>
            <a href="#" class="pagina-enllac">Final</a>
        </div>
    </main>
</body>
</html>
