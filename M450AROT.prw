#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} M450AROT
Ponto de entrada para adicionar funções no menu de Lib Ped por cliente.

@type 		function
@author 	Roberto Souza
@since 		08/05/2017
@version 	P11 
@params     Nenhum
						
@return lRet
/*/    
//-------------------------------------------------------------------------------------
User Function M450AROT
      
	Local aRet := {}
    Local lAcesso := .T.
    Local aButtons:= {}
    Local aRotSerasa := {}
    Local cUserCCB:= AllTrim(SuperGetMv("SE_CCBACES", .F., ""))
    
    If !Empty(cUserCCB)
    	lAcesso := AllTrim(Upper(cUserName)) $ Upper(cUserCCB)
    EndIf

    If lAcesso
		AADD(aRet,{"Consulta CCB"	 ,"U_xCallFcw( 'SEFINA03' )"	, 0 , 1,0,.F.})
		AADD(aRet,{"Risk Rating"	 ,"U_xCallFcw( 'VERISK' )" 		, 0 , 1,0,.F.})
    
    	//AADD(aRet, {'Consulta Serasa'    ,'U_SEFINA05() ',0,2,0,}) 
    	AADD(aRet,{"Consulta Serasa" ,"U_xCallFcw( 'SEFINA05' )"    , 0 , 1,0,.F.}) 
		//AADD(aRet, {'Buscar Cred.BUREAU' ,'U_FINA05AT(1)',0,2,0,}) 
		//AADD(aRet, {'Buscar CREDNET'     ,'U_FINA05AT(2)',0,2,0,})
		//AADD(aRet, {'Buscar RELATO'      ,'U_FINA05AT(3)',0,2,0,})		
    EndIf
	AADD(aRet,{"Ranking Pedidos" ,"U_OURO003()" 				, 0 , 1,0,.F.})
Return( aRet )    
 


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} xCallFcw
Funções no menu de Lib Ped por cliente.

@type 		function
@author 	Roberto Souza
@since 		08/05/2017
@version 	P11 
@params     cFunc	: Funcao
						
@return lRet
/*/    
//-------------------------------------------------------------------------------------
User Function xCallFcw( cFunc )
	Local lRet  := {}
	Local aArea := GetArea()
	
	If cFunc == "SEFINA03"       
		dbSelectArea("SA1")
		If SA1->(dbSeek(xFilial("SA1")+TRB->A1_COD+TRB->A1_LOJA))
			U_SEFINA03( SA1->A1_COD, SA1->A1_LOJA )
		EndIf
	EndIf
       
	If cFunc == "VERISK"
   		U_VERISK( TRB->A1_COD )
    EndIf
    
    If cFunc == "SEFINA05"
   		U_SEFINA05()
    EndIf

	RestArea(aArea)
Return( lRet )
