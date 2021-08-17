#INCLUDE "PROTHEUS.CH"

/*--------------------------------------------------------|
| Autor | Claudino Domingues              | Data 04/07/16 | 
|---------------------------------------------------------|
| Função: FA040B01	                                      |
|---------------------------------------------------------|
| O ponto de entrada FA040B01 sera executado na validacao |
| da exclusão dos dados do contas a receber.  	          |
|---------------------------------------------------------|
| Chamado TopDesk: I1605-2547                             |
----------------------------------------------------------*/

User Function FA040B01()

	Local lRet := .T.
	
	Private aArea := GetArea()
	
	If !(Upper(UsrRetName(__cUserId)) $ GetMv("FS_DIRETOR"))
		If (Upper(UsrRetName(__cUserId)) $ GetMv("FS_DEVNDC")) 
			If SE1->E1_TIPO <> 'NDC' 
				lRet := .F.
				ApMsgStop( 'Usuario só pode excluir tipo NDC!', 'FA040B01' )
			EndIf
		EndIf
	EndIf
		
	RestArea(aArea)
	
Return lRet