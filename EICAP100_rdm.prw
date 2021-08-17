/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �EICAP100_RDM�Autor  �Eletromega        � Data �  12/10/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Rotina de Controle de Cambio                               ���
���          � Travar os acessos dos usuarios                             ���
�������������������������������������������������������������������������͹��
���Uso       � AP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
#INCLUDE "PROTHEUS.CH"

User Function EICAP100() 
Local lRet 		:= .T.
Local cParam 	:= PARAMIXB 


If !(U_IsAdm() .Or. U_InGroup(GetMV("FS_GPEICPA")))  

	If ValType(ParamIXB) == "C"
 		cParam := ParamIXB  
	EndIf

	Do Case
		Case cParam == "ANTES_ESTORNO_BAIXA"  // Inibir estorno da liquida�ao de titulo // 
    			lVolta  := .T.
    			ApMsgStop('Opera�ao nao permitida!','ATEN��O') 
		Case cParam == "ANTES_TELA_SWB"
    		If M->WB_TIPOTIT == 'PA' 
    			If Str(nManut,1) $ '45'  // Inibir Aletracao/Exclusao //  	
    		 		lVolta  := .T.
    		 		ApMsgStop('Opera�ao nao permitida!','ATEN��O')
    		 	EndIf
    		EndIf				
    EndCase 

EndIf

Return(lRet)