#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
//-----------------------------------------------------------------------------------------
/*/{Protheus.doc} MT140TOK
Ponto de entrada do MT140TOK, serve p/ tratar dados no "Tudo OK" no cabeçalho da pre-nota 

@type 		function
@author 	Maurício Aureliano
@since 		20/03/2018
@version 	P12

@obs		Chamado: I1711-545 - Gatilho UF Origem 
 
@return nil
/*/    
//-----------------------------------------------------------------------------------------

User Function MT140TOK

	Local lRetorno 	:= PARAMIXB[1]
	Local lRet		:= .T.
	Local cEst		:= ""
	
	//..Customização do cliente
	IF lRetorno
		If cTipo $ ("NIPC")
			cEst := Posicione("SA2",1,xFilial("SA2") + CA100FOR + CLOJA,"A2_EST")
			If Trim(CUFORIGP) <> Trim(cEst)
				CUFORIGP := Trim(cEst)
				ApMsgStop('O Estado do Fornecedor foi atualizado, favor verificar os dados digitados!','MT140TOK')
				lRet	:= .F.
			EndIf
		Else
			cEst := Posicione("SA1",1,xFilial("SA1") + CA100FOR + CLOJA,"A1_EST")
			If Trim(CUFORIGP) <> Trim(cEst)
				CUFORIGP := Trim(cEst)
				ApMsgStop('O Estado do Cliente foi atualizado, favor verificar os dados digitados!','MT140TOK')
				lRet	:= .F.
			EndIf
		EndIf
	EndIf

Return lRet 