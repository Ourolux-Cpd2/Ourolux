#Include 'Protheus.ch'

User Function MA020TOK()
	Local lRet := .T. 
	Local cMsgErro := ""
	
	cConta 		:= AllTrim(M->A2_CONTA)
	DbSelectArea("CT1")
	DbSetOrder(1)                             

	If CT1->(DbSeek(xFilial("CT1")+cConta))
		If CT1->CT1_BLOQ == "1"
			cMsgErro += "A conta contábil cadastrada ["+cConta+"] encontra-se bloqueada." + CRLF
		EndIf	
	Else
		cMsgErro += "A conta contábil cadastrada ["+cConta+"] não existe." + CRLF
	EndIf 	
    
	cNaturez 	:= AllTrim(M->A2_NATUREZ)
	DbSelectArea("SED")
	DbSetOrder(1)

	If SED->(DbSeek(xFilial("SED")+cNaturez))
		If SED->ED_MSBLQL == "1"
			cMsgErro += "A natureza cadastrada ["+cNaturez+"] encontra-se bloqueada." + CRLF
		EndIf	
	Else
		cMsgErro += "A natureza cadastrada ["+cNaturez+"] não existe." + CRLF		
	EndIf 	

	If !Empty( cMsgErro )
		lRet := .F.	
		Aviso("MA020TOK",cMsgErro,{"Ok"},2,"Atenção")
	EndIf

Return( lRet )

