#INCLUDE "PROTHEUS.CH"

/*--------------------------------------------------------|
| Autor | Claudino Domingues              | Data 06/06/16 | 
|---------------------------------------------------------|
| Fun��o: FA040ALT	                                      |
|---------------------------------------------------------|
| O ponto de entrada FA040ALT sera executado na validacao |
| da alteracao dos dados do contas a receber.  	          |
|---------------------------------------------------------|
| Chamado TopDesk: I1605-2547                             |
----------------------------------------------------------*/

User Function FA040ALT()

	Local lRet 		:= .T.
	Local cErroAlt 	:= ""
	
	Private aArea := GetArea()
	
	// Claudino 04/07/16 - Tratamento para quando for diretoria, ignorar o tratamento NDC.
	If !(Upper(UsrRetName(__cUserId)) $ GetMv("FS_DIRETOR"))
		If (Upper(UsrRetName(__cUserId)) $ GetMv("FS_DEVNDC")) 
			If SE1->E1_TIPO <> 'NDC' 
				lRet := .F.
				ApMsgStop( 'Usuario s� pode alterar tipo NDC!', 'FA040ALT' )
			EndIf
		EndIf
	EndIf
	
	// Valida a altera��o de vencto
	If lRet	.And. M->E1_VENCTO <> SE1->E1_VENCTO
		
//		If SE1->E1_VENCTO <> SE1->E1_VENCORI
// 			cErroAlt += "O vencimento do t�tulo j� foi alterado previamente. Pela regra vigente um t�tulo s� pode ser alterado 1 vez."+CRLF
//		Else     
		
			nLinTab := U_XfPosTab("U001", __cUserId, "==", 4)
			
			If nLinTab > 0
				uInfo := fTabela( "U001",nLinTab, 6 )
				uAlt  := fTabela( "U001",nLinTab, 7 )                                         
   
				If SE1->E1_VENCTO <> SE1->E1_VENCORI .And. AllTrim(uAlt) <> "S"
					cErroAlt += "O vencimento do t�tulo j� foi alterado previamente."+CRLF+"Este usu�rio n�o pode mais alterar o vencimento deste t�tulo."+CRLF
				Else     
					nDiasMax 	:= Val(uInfo) //10 // Pega do Usuario
					nDif  		:= M->E1_VENCTO - SE1->E1_VENCTO
			        
					If nDif > nDiasMax
						cErroAlt += "O limite de altera��o de dias para vencimento ("+cValToChar(nDiasMax)+") foi excedido."+CRLF
					EndIf
				EndIf				    
	
			Else
				cErroAlt += "Usuario sem permiss�o para alterar vencimento."+CRLF+"Solicite ao gestor da �rea o cadastro na tabela Al�adas de Vencimento de T�tulos (U001) ."+CRLF			
			EndIf
//		EndIf			

		If !Empty(cErroAlt)
			lRet := .F.                                  
			M->E1_VENCTO 	:= SE1->E1_VENCTO
			M->E1_VENCREA 	:= SE1->E1_VENCREA
			Aviso('FA040ALT',cErroAlt,{"Ok"},2,"Aten��o")	
		EndIf		
	EndIf

		
	RestArea(aArea)

Return(lRet)                 