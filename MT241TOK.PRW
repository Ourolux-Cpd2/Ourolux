#INCLUDE "PROTHEUS.CH"
//-------------------------------------------------------------------------------------
/*/{Protheus.doc} MT241LOK
Ponto entrada de validação de confirmação no MATA241.

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

	// Validação para lancamentos internos do SAC
	aInfo   := U_RetParM2( "FS_MOVMOD2","SAC;510;10;SAC" )// Usuarios; TM ; Armazem ; Localização
        
	If !Empty(aInfo) .And. Upper(UsrRetName(__cUserId)) $ Upper(aInfo[01])
		
		cTmValid	:= aInfo[02]
		cArmazem 	:= aInfo[03]
		cLocaliz 	:= aInfo[04]

		// Valida o Tipo de movimentação
		If !(cTM $ cTmValid) 
			cMsgErro += "O Tipo de movimentação " +cTM+ " não é valido para esta movimentação." + CRLF		
		EndIf

		For Nx := 1 To Len(aCols)
		    
			If aCols[Nx][nPosLocal] <> cArmazem
				cMsgErro += "O armazém " +aCols[Nx][nPosLocal]+ " não é válido para esta movimentação. Linha: "+StrZero(Nx,2) + CRLF					   
			EndIf
			If aCols[Nx][nPosLocali]<> cLocaliz
				cMsgErro += "A localização " +aCols[Nx][nPosLocali]+ " não é válida para esta movimentação. Linha: "+StrZero(Nx,2) + CRLF					   
            EndIf                                          
            
 			cCod 		:= aCols[Nx][nPosCod]
			nCusto 		:= Posicione("SB1",1,xFilial("SB1")+cCod,"B1_CUSTD")
			nCustoFim   := aCols[Nx][nPosQuant] * nCusto
			
			If aCols[Nx][nPosCusto1] <> nCustoFim           
				cMsgErro += "O custo informado no produto é inválido. Linha: "+StrZero(Nx,2) + CRLF					                  
            EndIf
		Next
	 	
	 	If !Empty(cMsgErro)
			Aviso("MT241TOK",cMsgErro,{"Ok"},3,"Verifique o conteúdo do parâmetro [FS_MOVMOD2] ")
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
		
	cPar01  := GetNewPar( cPar, cDefault )  // TM ; Armazem ; Localização
	aRet   := Separa(cPar01,";") 
	
	If Empty(aRet) .Or. Len(aRet) < 3
		cPar01  := "SAC;510;10;SAC" 
		aRet    := Separa(cPar01,";") 
	EndIf

Return( aRet )