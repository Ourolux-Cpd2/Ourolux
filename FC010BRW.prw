#Include "Protheus.ch"

/*/{Protheus.doc} FC010BRW
Ponto de entrada para adicionar funções nas ações relacionadas na rotina de posição de cliente
@author Sensus Tecnologia - Fabricio Eduardo Reche
@since  11/06/2015
@version 1.0
/*/
User Function FC010BRW()

	Local aRotSerasa := {}
	
	If Type("aRotina") == "A"
	
	
		AADD(aRotSerasa, {'Consulta*'          ,'U_SEFINA05() ',0,2,0,}) 
		AADD(aRotSerasa, {'Buscar Cred.BUREAU*','U_FINA05AT(1)',0,2,0,}) 
		AADD(aRotSerasa, {'Buscar CREDNET*'    ,'U_FINA05AT(2)',0,2,0,})
		AADD(aRotSerasa, {'Buscar RELATO*'     ,'U_FINA05AT(3)',0,2,0,})
							
		AADD(aRotina,{"SERASA*", aRotSerasa, 0, Len(aRotina)+1})
	
	EndIf

Return

//REVISAO 000 - FABRICIO EDUARDO RECHE - 11/06/2015 - 'Criação'