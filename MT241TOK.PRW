#INCLUDE "PROTHEUS.CH"
//-------------------------------------------------------------------------------------
/*/{Protheus.doc} MT241LOK
Ponto entrada de valida��o de confirma��o no MATA241.

@type 		function
@author 	Roberto Souza
@since 		19/01/2017
@version 	P11 
 
@return nil
/*/    
//-------------------------------------------------------------------------------------
User Function MT241TOK()
	Local lRet 		:= .T.
	Local cTmValid  := "500"
	Local cMsgErro  := ""
	Local cPar01	:= ""
	Local Nx        := 0	

	// Valida��o para lancamentos internos do SAC
	aInfo   := U_RetParM2( "FS_MOVMOD2","SAC;510;10;SAC" )// Usuarios; TM ; Armazem ; Localiza��o
        
	If !Empty(aInfo) .And. Upper(UsrRetName(__cUserId)) $ Upper(aInfo[01])
		
		cTmValid	:= aInfo[02]
		cArmazem 	:= aInfo[03]
		cLocaliz 	:= aInfo[04]

		// Valida o Tipo de movimenta��o
		If !(cTM $ cTmValid) 
			cMsgErro += "O Tipo de movimenta��o " +cTM+ " n�o � valido para esta movimenta��o." + CRLF		
		EndIf

		For Nx := 1 To Len(aCols)
		    
			If aCols[Nx][nPosLocal] <> cArmazem
				cMsgErro += "O armaz�m " +aCols[Nx][nPosLocal]+ " n�o � v�lido para esta movimenta��o. Linha: "+StrZero(Nx,2) + CRLF					   
			EndIf
			If aCols[Nx][nPosLocali]<> cLocaliz
				cMsgErro += "A localiza��o " +aCols[Nx][nPosLocali]+ " n�o � v�lida para esta movimenta��o. Linha: "+StrZero(Nx,2) + CRLF					   
            EndIf                                          
            
 			cCod 		:= aCols[Nx][nPosCod]
			nCusto 		:= Posicione("SB1",1,xFilial("SB1")+cCod,"B1_CUSTD")
			nCustoFim   := aCols[Nx][nPosQuant] * nCusto
			
			If aCols[Nx][nPosCusto1] <> nCustoFim           
				cMsgErro += "O custo informado no produto � inv�lido. Linha: "+StrZero(Nx,2) + CRLF					                  
            EndIf
		Next
	 	
	 	If !Empty(cMsgErro)
			Aviso("MT241TOK",cMsgErro,{"Ok"},3,"Verifique o conte�do do par�metro [FS_MOVMOD2] ")
			lRet := .F.
		EndIf	
	EndIf

Return( lRet )

                                 
//-------------------------------------------------------------------------------------
/*/{Protheus.doc} RetParM2
Retorna oconteudo do parametro e formata para uso.

@type 		function
@author 	Roberto Souza
@since 		19/01/2017
@version 	P11 
 
@return nil
/*/    
//-------------------------------------------------------------------------------------
User Function RetParM2( cPar , cDefault )
    Local aRet 	:= {}
	Local cPar01:= ""
	         
	Default cPar 		:= "FS_MOVMOD2"
	Default cDefault    := "SAC;510;10;SAC"    

	cDefault    := "SAC/CPD3;510;10;SAC"   
		
	cPar01  := GetNewPar( cPar, cDefault )  // TM ; Armazem ; Localiza��o
	aRet   := Separa(cPar01,";") 
	
	If Empty(aRet) .Or. Len(aRet) < 3
		cPar01  := "SAC;510;10;SAC" 
		aRet    := Separa(cPar01,";") 
	EndIf

Return( aRet )