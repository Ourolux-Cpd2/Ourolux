#INCLUDE "PROTHEUS.CH"


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} MT241LOK
Ponto entrada de validação de linha no MATA241.

@type 		function
@author 	Roberto Souza
@since 		19/01/2017
@version 	P11 
 
@return nil
/*/    
//-------------------------------------------------------------------------------------
User Function MT241LOK()
	Local lRet := .T.
Return( lRet )      


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Ou241Lin
Função executada pelo gatilho na no campo D3_COD para preencher informações de digitação.

@type 		function
@author 	Roberto Souza
@since 		19/01/2017
@version 	P11 
 
@return nil
/*/    
//-------------------------------------------------------------------------------------
User Function Ou241Lin()
	Local uRet 	:= &(ReadVar()) 
	Local cCpo  := ReadVar() 
	Local cPar01:= ""      
	Local aArea := GetArea()

	aInfo   := U_RetParM2( "FS_MOVMOD2","SAC;510;10;SAC" )// Usuario; TM ; Armazem ; Localização
        
	If !Empty(aInfo) .And. Upper(UsrRetName(__cUserId)) $ Upper(aInfo[01])
	
		If "D3_COD" $ cCpo
			cArmazem 	:= aInfo[03]
			cLocaliz 	:= aInfo[04] 
			
			nCusto 		:= Posicione("SB1",1,xFilial("SB1")+uRet,"B1_CUSTD")
			nCustoFim   := aCols[oGet:OBROWSE:NAT][nPosQuant  ] * nCusto
			
			aCols[oGet:OBROWSE:NAT][nPosLocal] := cArmazem
			aCols[oGet:OBROWSE:NAT][nPosLocali]:= cLocaliz  
			aCols[oGet:OBROWSE:NAT][nPosCusto1]:= nCustoFim

		ElseIf "D3_QUANT" $ cCpo
			cCod 		:= aCols[oGet:OBROWSE:NAT][nPosCod]
			nCusto 		:= Posicione("SB1",1,xFilial("SB1")+cCod,"B1_CUSTD")
			nCustoFim   := uRet * nCusto
			
			aCols[oGet:OBROWSE:NAT][nPosCusto1]:= nCustoFim
		
		EndIf
   	EndIf

	RestArea( aArea )
	
Return( uRet )