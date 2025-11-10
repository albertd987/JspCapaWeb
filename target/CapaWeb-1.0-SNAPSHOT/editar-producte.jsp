<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="ca">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Editar/Nou Producte - Tallers Manolo</title>
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
        <h1>${empty param.codi ? 'Nou Producte' : 'Editar Producte'}</h1>
        
        <div class="formulari-contenidor">
            <form method="post" action="ProducteServlet">
                <!-- Action: create o update segons si existeix codi -->
                <input type="hidden" 
                       name="action" 
                       value="${empty param.codi ? 'create' : 'update'}">
                
                <fieldset class="fieldset">
                    <legend class="llegenda">PRODUCTE</legend>
                    
                    <div class="fila-camps">
                        <div class="grup-camp">
                            <label class="etiqueta" for="codiProducte">CODI_PRODUCTE *</label>
                            <input type="text" 
                                   id="codiProducte" 
                                   name="codiProducte" 
                                   class="camp" 
                                   placeholder="PRD-XXX" 
                                   maxlength="20" 
                                   value="${param.codi}"
                                   ${not empty param.codi ? 'readonly' : ''}
                                   required>
                        </div>
                        
                        <div class="grup-camp">
                            <label class="etiqueta" for="estocInicial">ESTOC_INICIAL</label>
                            <input type="number" 
                                   id="estocInicial" 
                                   name="estocInicial" 
                                   class="camp" 
                                   min="0" 
                                   value="0">
                        </div>
                    </div>
                    
                    <div class="grup-camp">
                        <label class="etiqueta" for="nomProducte">NOM_PRODUCTE *</label>
                        <input type="text" 
                               id="nomProducte" 
                               name="nomProducte" 
                               class="camp" 
                               maxlength="100" 
                               required>
                    </div>
                    
                    <div class="grup-camp">
                        <label class="etiqueta" for="descripcioProducte">DESCRIPCIÓ DEL PRODUCTE</label>
                        <textarea id="descripcioProducte" 
                                  name="descripcioProducte" 
                                  class="camp textarea" 
                                  rows="5"></textarea>
                    </div>
                </fieldset>
                
                <div class="grup-botons">
                    <a href="ProducteServlet" class="boto boto-secundari">CANCEL·LAR</a>
                    <button type="submit" class="boto boto-primari">ACCEPTAR</button>
                </div>
            </form>
        </div>
    </main>
</body>
</html>
