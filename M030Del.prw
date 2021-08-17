#INCLUDE "PROTHEUS.CH"                          

User Function M030Del()
	Local lRet := .T.
	Local aInfo:= U_RetParAR( "FS_SACSA1","Sac;SAC;SAC;B;100;10" )
		/* Parametro de validacao - FS_SACSA1
			01 - Usuarios 
	        02 - Vendedor - A1_VEND
	        03 - Segmento - A1_SATIV1
	        04 - Risco - A1_RISCO   
	        05 - Valor maximo
			06 - Dias de prazo 
		*/  
		cUserI := FWLeUserlg("A1_USERLGI")
		
		If !Empty(aInfo) .And. Upper(UsrRetName(__cUserId)) $ Upper(aInfo[01])
	    	If Upper(cUserI) <> Upper(UsrRetName(__cUserId))				   
				cMsgAvis  := "Este cadastro não pode ser excluido por este usuário!"+CRLF			    	
				Aviso("M030Del",cMsgAvis,{"Ok"},2,"Atenção")
	            lRet := .F.	
			EndIf	
		EndIf 	

Return( lRet )