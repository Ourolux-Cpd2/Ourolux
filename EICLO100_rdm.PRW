/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �EICLO100_RDM�Autor  �Eletromega        � Data �  12/10/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Rotina de Manuten�ao de FFC                                ���
���          � Travar os acesso dos usuarios                              ���
�������������������������������������������������������������������������͹��
���Uso       � AP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
#INCLUDE "PROTHEUS.CH"

User Function EICLO100() 
Local lRet 		:= .T.
Local cParam 	:= PARAMIXB 

If !(U_IsAdm() .Or. U_InGroup(GetMV("FS_GPEICPA")))  

	If ValType(ParamIXB) == "C"
 		cParam := ParamIXB  
	EndIf

	Do Case
		Case cParam == "ATUALIZA"    
    		nOpca := IIf(nOpca == 4,0,nOpca)  // Inibir a estorno/exclusao do FFC //
    		ApMsgStop('Opera�ao nao permitida!','ATEN��O') 
		Case cParam == "VAL_SCPE2"   
    		//ApMsgStop(cParam,'ATEN��O')
    		//ApMsgStop(Str(nOpca,2),'ATEN��O') 
    		//lRet  := .F.
    		//ApMsgStop('Opera�ao nao permitida!','ATEN��O')					
    EndCase 

EndIf
Return(lRet)