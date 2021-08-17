/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ºAutor  ³Eletromega             º Data ³  17/05/12            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Esse ponto de entrada é executado na validação 'TudoOk'        º±±
±±º 		  da interface. Ele permite inibir a inclusão e alteração        º±±
±±º           da manutenção de comissões.   								 º±±
±±º           Retorno: .T./.F.                  	                         º±±
±±º          ³  			                                    	         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Faturamento                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
#Include "rwmake.ch"

User Function A490TDOK()
Local lRet     := .T.
Local __cUsr   := Upper(Rtrim(cUserName))
Local cMVUsrCo := SuperGetMv("FS_USRCOMI")

//If !U_IsAdm()

If !(__cUsr $ cMVUsrCo) // Claudino 14/04/15

	If INCLUI
	
		If  M->E3_COMIS > 0 .Or. M->E3_BASE > 0 
	
			lRet := .F.
			ApMsgStop('Operacao nao e permitida! So pode incluir valores negativos.', 'A490TDOK')
	    
	    EndIf
	
	ElseIf ALTERA
	
		If  !(Substr(M->E3_TIPO, 1, 2) == 'VL')  
	
			lRet := .F.
			ApMsgStop('Operacao nao e permitida! So pode alterar titulos tipo VL.', 'A490TDOK')
	    
	    EndIf

	EndIf

EndIf

Return(lRet)