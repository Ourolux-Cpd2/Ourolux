#INCLUDE "PROTHEUS.CH"

User Function M030Inc()
	Local lRet 		:= .T.             
  	Local cMsgAvis 	:= ""
  	Local nOpcA     := PARAMIXB

	If nOpcA == 0
		aInfo     := U_RetParAR( "FS_SACSA1","Sac;SAC;SAC;B;100;10" )
		/* Parametro de validacao - FS_SACSA1
			01 - Usuarios 
	        02 - Vendedor - A1_VEND
	        03 - Segmento - A1_SATIV1
	        04 - Risco - A1_RISCO   
	        05 - Valor maximo
			06 - Dias de prazo 
		*/
		If !Empty(aInfo) .And. Upper(UsrRetName(__cUserId)) $ Upper(aInfo[01])
	
		    RecLock("SA1",.F.)
				SA1->A1_VLRCMP	:= Val(aInfo[05])
				SA1->A1_LC		:= Val(aInfo[05])
				SA1->A1_VENCLC	:= Ddatabase + Val(aInfo[06])
				SA1->A1_RISCO	:= aInfo[04]
				SA1->A1_MSBLQL	:= "2"
			MsUnlock()       
			
			cMsgAvis  += "O cliente foi salvo com algumas informações alteradas:"+CRLF			    	
			cMsgAvis  += "Sugestão de compra: "+ Transform(SA1->A1_VLRCMP,"@E 999,999,999.99")+" ."+CRLF			    	
			cMsgAvis  += "Limite de Crédito : "+ Transform(SA1->A1_LC,"@E 999,999,999.99")+" ."+CRLF			    	
			cMsgAvis  += "Vencto do Limite  : "+ Dtoc(SA1->A1_VENCLC)+" ."+CRLF			    	
			cMsgAvis  += "Risco             : "+ SA1->A1_RISCO+" ."+CRLF	

			Aviso("M030Inc",cMsgAvis,{"Ok"},3,"Atenção")

		EndIf 
		
		// Claudino - I1611-2393 - 12/04/17
		RecLock("SA1",.F.)
			SA1->A1_NOME    := StrTran(SA1->A1_NOME,chr(9)," ")
			SA1->A1_END     := StrTran(SA1->A1_END,chr(9)," ")
			SA1->A1_COMPLEM := StrTran(SA1->A1_COMPLEM,chr(9)," ")
			SA1->A1_BAIRRO  := StrTran(SA1->A1_BAIRRO,chr(9)," ")
			SA1->A1_MUN     := StrTran(SA1->A1_MUN,chr(9)," ")
			SA1->A1_OBS     := StrTran(SA1->A1_OBS,chr(9)," ")
		MsUnlock()
	
	EndIf

Return( lRet )