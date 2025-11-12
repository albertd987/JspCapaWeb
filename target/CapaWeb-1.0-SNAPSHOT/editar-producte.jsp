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
                                   placeholder="0"
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
                               placeholder="Nom descriptiu del producte"
                               maxlength="100" 
                               required>
                    </div>
                    
                    <div class="grup-camp">
                        <label class="etiqueta" for="descripcioProducte">DESCRIPCIÓ DEL PRODUCTE</label>
                        <textarea id="descripcioProducte" 
                                  name="descripcioProducte" 
                                  class="camp textarea" 
                                  placeholder="Descripció detallada del producte..."
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
    
    <style>
        /* ESTILOS INLINE - Paleta Corporativa Tallers Manolo */
        
        .formulari-contenidor {
            background: #ffffff;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(26, 54, 93, 0.1);
            max-width: 800px;
            margin: 0 auto;
        }
        
        .fieldset {
            border: 1px solid #4a5568;
            border-radius: 4px;
            padding: 20px;
            margin-bottom: 20px;
        }
        
        .llegenda {
            font-family: 'Inter', sans-serif;
            font-weight: 600;
            color: #2c5282;
            padding: 0 10px;
        }
        
        .fila-camps {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 20px;
        }
        
        .grup-camp {
            display: flex;
            flex-direction: column;
        }
        
        .etiqueta {
            font-family: 'Inter', sans-serif;
            font-weight: 600;
            margin-bottom: 8px;
            color: #2c5282;
        }
        
        .camp {
            padding: 10px;
            border: 1px solid #4a5568;
            border-radius: 4px;
            font-size: 14px;
            font-family: 'Roboto', sans-serif;
            color: #000000;
        }
        
        .camp::placeholder {
            color: #4a5568;
            opacity: 0.6;
        }
        
        .camp:focus {
            outline: none;
            border-color: #0066cc;
            box-shadow: 0 0 0 2px rgba(0, 102, 204, 0.1);
        }
        
        .camp[readonly] {
            background-color: #f5f5f5;
            color: #4a5568;
            cursor: not-allowed;
        }
        
        .textarea {
            resize: vertical;
            min-height: 100px;
        }
        
        .grup-botons {
            display: flex;
            justify-content: flex-end;
            gap: 15px;
            margin-top: 20px;
            padding-top: 20px;
            border-top: 1px solid #4a5568;
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
            transition: all 0.3s ease;
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
    </style>
</body>
</html>
