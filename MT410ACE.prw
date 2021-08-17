#INCLUDE "PROTHEUS.CH"


//--------------------------------------------------------------------
/*/{Protheus.doc} MT410ACE 
Ponto de entrada para definir se pode utilizar as fun��es

@author TOTVS Protheus
@since  09/10/15

@version 1.0
/*/
//--------------------------------------------------------------------

User Function MT410ACE()   
	Local lRet := .T.             
	Local nOpc := PARAMIXB[01]
	
	If !INCLUI .And. nOpc <> 2
		aInfo:= U_RetParAR( "FS_SACSC5","Sac;" )
		cUserI := FWLeUserlg("C5_USERLGI")
		
		If !Empty(aInfo) .And. Upper(UsrRetName(__cUserId)) $ Upper(aInfo[01])
	    	If Upper(cUserI) <> Upper(UsrRetName(__cUserId)) 			   
				cMsgAvis  := "Este pedido n�o pode ser manuseado por este usu�rio!"+CRLF			    	
				Aviso("MT410ACE",cMsgAvis,{"Ok"},2,"Aten��o")
	            lRet := .F.	
			EndIf	
		EndIf 
	
	EndIf   

Return( lRet )