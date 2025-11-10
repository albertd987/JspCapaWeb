<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="ca">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gestió de components - Tallers Manolo</title>
    <link rel="stylesheet" href="css\tallersmanolo.css">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@600;700&family=Roboto:wght@400;500;700&display=swap" rel="stylesheet">
</head>
<body>
    <header class="capsalera">
        <div class="logo">TALLERS MANOLO</div>
        <nav class="navegacio">
            <a href="productes.jsp" class="enllac-nav">PRODUCTES</a>
            <a href="components.jsp" class="enllac-nav actiu">COMPONENTS PRIMARIS</a>
        </nav>
    </header>

    <main class="contenidor">
        <h1>Gestió de components</h1>
        
        <div class="barra-accions">
            <div class="caixa-cerca">
                <span class="icona-cerca">🔍</span>
                <input type="text" class="input-cerca" placeholder="filtrar per codi">
            </div>
            <a href="editar-component.jsp" class="boto boto-primari">NOU COMPONENT</a>
        </div>

        <div class="contenidor-taula">
            <table class="taula">
                <thead>
                    <tr>
                        <th>Codi</th>
                        <th>Nom del Component</th>
                        <th>Codi Fabricant</th>
                        <th>Estoc</th>
                        <th>Unitat</th>
                        <th>Preu Mitjà</th>
                        <th>Proveïdors</th>
                        <th>Accions</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td>CMP-101</td>
                        <td>Acer Inoxidable 316L</td>
                        <td>ACR316L-01</td>
                        <td>450</td>
                        <td>kg</td>
                        <td class="text-destacat">15.50 €</td>
                        <td class="llista-proveidors">Acersa SA (15.20 €); Metalcorp SL (15.80 €)</td>
                        <td class="accions-cel">
                            <a href="editar-component.jsp?codi=CMP-101" class="boto-icona">✏️</a>
                            <a href="esborrar-component.jsp?codi=CMP-101" class="boto-icona boto-esborrar">🗑️</a>
                        </td>
                    </tr>
                    <tr>
                        <td>CMP-205</td>
                        <td>Aliatge Alumini 7075</td>
                        <td>AL7075-02</td>
                        <td>320</td>
                        <td>kg</td>
                        <td class="text-destacat">22.30 €</td>
                        <td class="llista-proveidors">Alumetal SL (22.30 €)</td>
                        <td class="accions-cel">
                            <a href="editar-component.jsp?codi=CMP-205" class="boto-icona">✏️</a>
                            <a href="esborrar-component.jsp?codi=CMP-205" class="boto-icona boto-esborrar">🗑️</a>
                        </td>
                    </tr>
                    <tr>
                        <td>CMP-312</td>
                        <td>Coure Electrolític</td>
                        <td>CU-ELEC-03</td>
                        <td>180</td>
                        <td>kg</td>
                        <td class="text-destacat">8.75 €</td>
                        <td class="llista-proveidors">Cobresol SA (8.50 €); Metalls BCN (9.00 €)</td>
                        <td class="accions-cel">
                            <a href="editar-component.jsp?codi=CMP-312" class="boto-icona">✏️</a>
                            <a href="esborrar-component.jsp?codi=CMP-312" class="boto-icona boto-esborrar">🗑️</a>
                        </td>
                    </tr>
                    <tr>
                        <td>CMP-418</td>
                        <td>Polímer Reforçat Fibra</td>
                        <td>PRF-418</td>
                        <td>95</td>
                        <td>kg</td>
                        <td class="text-destacat">28.90 €</td>
                        <td class="llista-proveidors">Poliplast SL (28.90 €)</td>
                        <td class="accions-cel">
                            <a href="editar-component.jsp?codi=CMP-418" class="boto-icona">✏️</a>
                            <a href="esborrar-component.jsp?codi=CMP-418" class="boto-icona boto-esborrar">🗑️</a>
                        </td>
                    </tr>
                    <tr>
                        <td>CMP-523</td>
                        <td>Cautxú Sintètic</td>
                        <td>CS-523</td>
                        <td>210</td>
                        <td>kg</td>
                        <td class="text-destacat">12.40 €</td>
                        <td class="llista-proveidors">Elastomers BCN (12.40 €)</td>
                        <td class="accions-cel">
                            <a href="editar-component.jsp?codi=CMP-523" class="boto-icona">✏️</a>
                            <a href="esborrar-component.jsp?codi=CMP-523" class="boto-icona boto-esborrar">🗑️</a>
                        </td>
                    </tr>
                    <tr>
                        <td>CMP-634</td>
                        <td>Vidre Temperat</td>
                        <td>VT-634</td>
                        <td>85</td>
                        <td>m²</td>
                        <td class="text-destacat">45.00 €</td>
                        <td class="llista-proveidors">Vidres Industrials (45.00 €)</td>
                        <td class="accions-cel">
                            <a href="editar-component.jsp?codi=CMP-634" class="boto-icona">✏️</a>
                            <a href="esborrar-component.jsp?codi=CMP-634" class="boto-icona boto-esborrar">🗑️</a>
                        </td>
                    </tr>
                    <tr>
                        <td>CMP-741</td>
                        <td>Acer Carboní 1045</td>
                        <td>AC1045-07</td>
                        <td>520</td>
                        <td>kg</td>
                        <td class="text-destacat">3.20 €</td>
                        <td class="llista-proveidors">Acersa SA (3.15 €); Siderúrgia CAT (3.25 €)</td>
                        <td class="accions-cel">
                            <a href="editar-component.jsp?codi=CMP-741" class="boto-icona">✏️</a>
                            <a href="esborrar-component.jsp?codi=CMP-741" class="boto-icona boto-esborrar">🗑️</a>
                        </td>
                    </tr>
                    <tr>
                        <td>CMP-852</td>
                        <td>Lubricant Industrial</td>
                        <td>LUB-IND-852</td>
                        <td>340</td>
                        <td>L</td>
                        <td class="text-destacat">18.60 €</td>
                        <td class="llista-proveidors">Química Total (18.60 €)</td>
                        <td class="accions-cel">
                            <a href="editar-component.jsp?codi=CMP-852" class="boto-icona">✏️</a>
                            <a href="esborrar-component.jsp?codi=CMP-852" class="boto-icona boto-esborrar">🗑️</a>
                        </td>
                    </tr>
                    <tr>
                        <td>CMP-963</td>
                        <td>Plàstic ABS Alta Resistència</td>
                        <td>ABS-963</td>
                        <td>410</td>
                        <td>kg</td>
                        <td class="text-destacat">5.80 €</td>
                        <td class="llista-proveidors">Plastics Global (5.70 €); Politech SL (5.90 €)</td>
                        <td class="accions-cel">
                            <a href="editar-component.jsp?codi=CMP-963" class="boto-icona">✏️</a>
                            <a href="esborrar-component.jsp?codi=CMP-963" class="boto-icona boto-esborrar">🗑️</a>
                        </td>
                    </tr>
                    <tr>
                        <td>CMP-974</td>
                        <td>Filferro d'Acer Galvanitzat</td>
                        <td>FG-974</td>
                        <td>275</td>
                        <td>kg</td>
                        <td class="text-destacat">2.45 €</td>
                        <td class="llista-proveidors">Metalls BCN (2.40 €); AcerGalv SA (2.50 €)</td>
                        <td class="accions-cel">
                            <a href="editar-component.jsp?codi=CMP-974" class="boto-icona">✏️</a>
                            <a href="esborrar-component.jsp?codi=CMP-974" class="boto-icona boto-esborrar">🗑️</a>
                        </td>
                    </tr>
                    <tr>
                        <td>CMP-985</td>
                        <td>Oli Hidràulic 46</td>
                        <td>OH-985</td>
                        <td>600</td>
                        <td>L</td>
                        <td class="text-destacat">4.60 €</td>
                        <td class="llista-proveidors">Lubricants Delta (4.55 €); QuimOil SL (4.65 €)</td>
                        <td class="accions-cel">
                            <a href="editar-component.jsp?codi=CMP-985" class="boto-icona">✏️</a>
                            <a href="esborrar-component.jsp?codi=CMP-985" class="boto-icona boto-esborrar">🗑️</a>
                        </td>
                    </tr>
                    <tr>
                        <td>CMP-996</td>
                        <td>Pintura Epoxi Industrial</td>
                        <td>PE-996</td>
                        <td>150</td>
                        <td>L</td>
                        <td class="text-destacat">19.90 €</td>
                        <td class="llista-proveidors">Pintures Catalanes (19.80 €); Colorind SA (20.00 €)</td>
                        <td class="accions-cel">
                            <a href="editar-component.jsp?codi=CMP-996" class="boto-icona">✏️</a>
                            <a href="esborrar-component.jsp?codi=CMP-996" class="boto-icona boto-esborrar">🗑️</a>
                        </td>
                    </tr>
                    <tr>
                        <td>CMP-1007</td>
                        <td>Sílici Metalúrgic 99%</td>
                        <td>SM-1007</td>
                        <td>95</td>
                        <td>kg</td>
                        <td class="text-destacat">32.50 €</td>
                        <td class="llista-proveidors">Silicate Iberia (32.40 €)</td>
                        <td class="accions-cel">
                            <a href="editar-component.jsp?codi=CMP-1007" class="boto-icona">✏️</a>
                            <a href="esborrar-component.jsp?codi=CMP-1007" class="boto-icona boto-esborrar">🗑️</a>
                        </td>
                    </tr>
                    <tr>
                        <td>CMP-1018</td>
                        <td>Fibra de Carboní Teixida</td>
                        <td>FC-1018</td>
                        <td>70</td>
                        <td>m²</td>
                        <td class="text-destacat">120.00 €</td>
                        <td class="llista-proveidors">Composites BCN (119.50 €); CarbonFiber SA (120.50 €)</td>
                        <td class="accions-cel">
                            <a href="editar-component.jsp?codi=CMP-1018" class="boto-icona">✏️</a>
                            <a href="esborrar-component.jsp?codi=CMP-1018" class="boto-icona boto-esborrar">🗑️</a>
                        </td>
                    </tr>
                    <tr>
                        <td>CMP-1029</td>
                        <td>Cinta Aïllant Alta Temperatura</td>
                        <td>CA-1029</td>
                        <td>500</td>
                        <td>rotlles</td>
                        <td class="text-destacat">1.80 €</td>
                        <td class="llista-proveidors">Insutape SL (1.75 €); TermoWrap SA (1.85 €)</td>
                        <td class="accions-cel">
                            <a href="editar-component.jsp?codi=CMP-1029" class="boto-icona">✏️</a>
                            <a href="esborrar-component.jsp?codi=CMP-1029" class="boto-icona boto-esborrar">🗑️</a>
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
