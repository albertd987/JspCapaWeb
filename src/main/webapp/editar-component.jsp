<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="ca">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Editar/Nou Component - Tallers Manolo</title>
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
        <h1>Editar/Nou Component</h1>
        
        <div class="formulari-contenidor">
            <form method="post" action="guardarComponent.jsp">
                <fieldset class="fieldset">
                    <legend class="llegenda">COMPONENT</legend>
                    
                    <div class="fila-camps">
                        <div class="grup-camp">
                            <label class="etiqueta" for="codiComponent">CODI_COMPONENT</label>
                            <input type="text" id="codiComponent" name="codiComponent" class="camp" 
                                   placeholder="CMP-XXX" maxlength="20" required>
                        </div>
                        
                        <div class="grup-camp">
                            <label class="etiqueta" for="codiFabricant">CODI_FABRICANT</label>
                            <input type="text" id="codiFabricant" name="codiFabricant" class="camp" 
                                   maxlength="50" required>
                        </div>
                    </div>
                    
                    <div class="grup-camp">
                        <label class="etiqueta" for="nomComponent">NOM_DEL_COMPONENT</label>
                        <input type="text" id="nomComponent" name="nomComponent" class="camp" 
                               maxlength="100" required>
                    </div>
                    
                    <div class="grup-camp">
                        <label class="etiqueta" for="proveidor">PROVEÏDOR</label>
                        <select id="proveidor" name="proveidor" class="camp" required>
                            <option value="">Selecciona un proveïdor</option>
                            <option value="PROV001">Acersa SA</option>
                            <option value="PROV002">Metalcorp SL</option>
                            <option value="PROV003">Alumetal SL</option>
                            <option value="PROV004">Cobresol SA</option>
                            <option value="PROV005">Metalls BCN</option>
                            <option value="PROV006">Poliplast SL</option>
                            <option value="PROV007">Elastomers BCN</option>
                            <option value="PROV008">Vidres Industrials</option>
                            <option value="PROV009">Siderúrgia CAT</option>
                            <option value="PROV010">Química Total</option>
                            <option value="PROV011">Plastics Global</option>
                            <option value="PROV012">Politech SL</option>
                            <option value="PROV013">AcerGalv SA</option>
                            <option value="PROV014">Lubricants Delta</option>
                            <option value="PROV015">QuimOil SL</option>
                            <option value="PROV016">Pintures Catalanes</option>
                            <option value="PROV017">Colorind SA</option>
                            <option value="PROV018">Silicate Iberia</option>
                            <option value="PROV019">Composites BCN</option>
                            <option value="PROV020">CarbonFiber SA</option>
                            <option value="PROV021">Insutape SL</option>
                            <option value="PROV022">TermoWrap SA</option>
                        </select>
                    </div>
                    
                    <div class="grup-camp">
                        <label class="etiqueta" for="descripcioComponent">DESCRIPCIÓ DEL COMPONENT</label>
                        <textarea id="descripcioComponent" name="descripcioComponent" 
                                  class="camp textarea" rows="4"></textarea>
                    </div>
                    
                    <div class="fila-camps">
                        <div class="grup-camp">
                            <label class="etiqueta" for="unitatMesura">UNITAT_DE_MESURA</label>
                            <select id="unitatMesura" name="unitatMesura" class="camp" required>
                                <option value="">Selecciona unitat</option>
                                <option value="kg">kg - Quilograms</option>
                                <option value="L">L - Litres</option>
                                <option value="m²">m² - Metres quadrats</option>
                                <option value="m">m - Metres</option>
                                <option value="U">U - Unitats</option>
                                <option value="rotlles">rotlles - Rotlles</option>
                            </select>
                        </div>
                        
                        <div class="grup-camp">
                            <label class="etiqueta" for="estocInicial">ESTOC_INICIAL</label>
                            <input type="number" id="estocInicial" name="estocInicial" class="camp" 
                                   min="0" value="0" required>
                        </div>
                        
                        <div class="grup-camp">
                            <label class="etiqueta" for="preuMitja">PREU_MITJÀ</label>
                            <input type="text" id="preuMitja" name="preuMitja" class="camp" 
                                   value="0.00 €" readonly disabled>
                            <p class="missatge-ajuda">Aquest camp es calcula automàticament pels triggers Oracle</p>
                        </div>
                    </div>
                </fieldset>
                
                <div class="grup-botons">
                    <a href="components.jsp" class="boto boto-secundari">CANCELAR</a>
                    <button type="submit" class="boto boto-primari">ACCEPTAR</button>
                </div>
            </form>
        </div>
    </main>
</body>
</html>
