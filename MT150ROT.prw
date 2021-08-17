
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} MT150ROT
Inclus�o de uma op��o de usu�rio no ToolBar. (Atualiza��o de Cota��o)

@type 		Function
@author 	Maur�cio Aureliano
@since 		28/03/2018
@version 	P12
		
@obs		Chamado: I1711-447	
 
@return nil
/*/    
//-------------------------------------------------------------------------------------
User Function MT150ROT()

//Define Array contendo as Rotinas a executar do programa     

// ----------- Elementos contidos por dimensao ------------    
// 1. Nome a aparecer no cabecalho                             
// 2. Nome da Rotina associada                                 
// 3. Usado pela rotina                                        
// 4. Tipo de Transa��o a ser efetuada                         
//    1 - Pesquisa e Posiciona em um Banco de Dados            
//    2 - Simplesmente Mostra os Campos                        
//    3 - Inclui registros no Bancos de Dados                  
//    4 - Altera o registro corrente                           
//    5 - Remove o registro corrente do Banco de Dados         
//    6 - Altera determinados campos sem incluir novos Regs 

	AAdd( aRotina, { 'Reenvia Cotacao', 'U_WFMAT150()', 0, 2 } )

Return aRotina