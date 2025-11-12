/**
 * bom-tree.js - Gestió de l'arbre jeràrquic del BOM amb jsTree
 * 
 * @author Tallers Manolo
 * @version 1.0
 */

// Configuració global
const BOM_TREE_CONFIG = {
    servlet_url: 'bomtree',
    modal_id: '#bomTreeModal',
    container_id: '#bomTreeContainer',
    loading_class: 'bom-loading',
    error_class: 'alert-danger'
};

/**
 * Funció principal: obre el modal i carrega l'arbre BOM
 * 
 * @param {string} prCodi - Codi del producte
 * @param {string} prNom - Nom del producte (per mostrar al títol)
 */
function obrirBomTree(prCodi, prNom) {
    // Actualitzar títol del modal
    $('#bomTreeModalLabel').text('Arbre BOM: ' + prNom + ' (' + prCodi + ')');
    
    // Mostrar indicador de càrrega
    $(BOM_TREE_CONFIG.container_id).html(
        '<div class="text-center ' + BOM_TREE_CONFIG.loading_class + '">' +
        '<div class="spinner-border text-primary" role="status">' +
        '<span class="visually-hidden">Carregant...</span>' +
        '</div>' +
        '<p class="mt-3">Carregant arbre jeràrquic...</p>' +
        '</div>'
    );
    
    // Mostrar modal
    const modal = new bootstrap.Modal(document.querySelector(BOM_TREE_CONFIG.modal_id));
    modal.show();
    
    // Carregar dades del servlet
    carregarBomData(prCodi);
}

/**
 * Carrega les dades del BOM des del servlet
 * 
 * @param {string} prCodi - Codi del producte
 */
function carregarBomData(prCodi) {
    fetch(BOM_TREE_CONFIG.servlet_url + '?prCodi=' + encodeURIComponent(prCodi))
        .then(response => {
            if (!response.ok) {
                throw new Error('Error HTTP: ' + response.status);
            }
            return response.json();
        })
        .then(data => {
            // Si hi ha error a la resposta
            if (data.error) {
                mostrarError(data.error);
                return;
            }
            
            // Inicialitzar jsTree amb les dades
            inicialitzarJsTree(data);
        })
        .catch(error => {
            console.error('Error carregant BOM:', error);
            mostrarError('Error de connexió amb el servidor. Si us plau, torna-ho a intentar.');
        });
}

/**
 * Inicialitza jsTree amb les dades del BOM
 * 
 * @param {Array} treeData - Dades en format jsTree
 */
function inicialitzarJsTree(treeData) {
    // Destruir jsTree anterior si existeix
    $(BOM_TREE_CONFIG.container_id).jstree('destroy');
    
    // Crear nou jsTree
    $(BOM_TREE_CONFIG.container_id).jstree({
        'core': {
            'data': treeData,
            'themes': {
                'name': 'default',
                'responsive': true,
                'dots': true,
                'icons': true
            },
            'check_callback': false // Només lectura
        },
        'plugins': ['search', 'types'],
        'types': {
            'default': {
                'icon': 'fas fa-cube'
            }
        },
        'search': {
            'case_insensitive': true,
            'show_only_matches': true,
            'show_only_matches_children': true
        }
    });
    
    // Events de jsTree
    $(BOM_TREE_CONFIG.container_id)
        .on('ready.jstree', function() {
            console.log('✓ Arbre BOM carregat correctament');
            // Afegir funcionalitat de cerca
            activarCerca();
        })
        .on('select_node.jstree', function(e, data) {
            // Quan es fa click en un node
            console.log('Node seleccionat:', data.node.id);
        });
}

/**
 * Activa la funcionalitat de cerca dins l'arbre
 */
function activarCerca() {
    let searchTimeout = null;
    
    $('#bomTreeSearch').on('keyup', function() {
        clearTimeout(searchTimeout);
        const searchValue = $(this).val();
        
        searchTimeout = setTimeout(function() {
            $(BOM_TREE_CONFIG.container_id).jstree('search', searchValue);
        }, 250);
    });
}

/**
 * Mostra un missatge d'error al modal
 * 
 * @param {string} message - Missatge d'error
 */
function mostrarError(message) {
    $(BOM_TREE_CONFIG.container_id).html(
        '<div class="alert ' + BOM_TREE_CONFIG.error_class + ' m-3" role="alert">' +
        '<h5 class="alert-heading"><i class="fas fa-exclamation-triangle"></i> Error</h5>' +
        '<p>' + message + '</p>' +
        '</div>'
    );
}

/**
 * Expandeix tots els nodes de l'arbre
 */
function expandirTot() {
    $(BOM_TREE_CONFIG.container_id).jstree('open_all');
}

/**
 * Col·lapsa tots els nodes de l'arbre
 */
function col·lapsarTot() {
    $(BOM_TREE_CONFIG.container_id).jstree('close_all');
}

/**
 * Neteja la cerca
 */
function netejarCerca() {
    $('#bomTreeSearch').val('');
    $(BOM_TREE_CONFIG.container_id).jstree('clear_search');
}

// Event listener quan es tanca el modal
$(document).on('hidden.bs.modal', BOM_TREE_CONFIG.modal_id, function() {
    // Destruir jsTree per alliberar memòria
    $(BOM_TREE_CONFIG.container_id).jstree('destroy');
    // Netejar cerca
    $('#bomTreeSearch').val('');
});

// Inicialització quan el document estigui llest
$(document).ready(function() {
    console.log('✓ BOM Tree JS inicialitzat');
});