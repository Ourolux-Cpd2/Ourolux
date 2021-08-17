#INCLUDE "PROTHEUS.CH"


//--------------------------------------------------------------------
/*/{Protheus.doc} MT410ACE 
Ponto de entrada para definir se pode utilizar as funções

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
				cMsgAvis  := "Este pedido não pode ser manuseado por este usuário!"+CRLF			    	
				Aviso("MT410ACE",cMsgAvis,{"Ok"},2,"Atenção")
	            lRet := .F.	
			EndIf	
		EndIf 
	
	EndIf   

Return( lRet )