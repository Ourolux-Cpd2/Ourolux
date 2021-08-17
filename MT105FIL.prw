#INCLUDE "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MT105FIL  �Autor  �Microsiga           � Data �  11/05/12   ���
�������������������������������������������������������������������������͹��
���Desc.     � Filtar o Mbrowse do SCP - Solicita�oes ao Armazem          ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function MT105FIL()

	Local cFiltro 	:= ''
	Local cLogUsr   := Upper(ALLTRIM(cUserName))
	Local cNameUser := Upper(ALLTRIM(SubString(cUsuario,7,15)))
		
	If cLogUsr $ "ADMINISTRADOR.ROBERTO.CARLOS.SUMAIA.ADMINISTRATIVO.ADMINISTRATIVO2.COMPRAS.COORDADM.GERENCIAADM" 
		cFiltro := " "
	Else
		cFiltro := " Upper(AllTrim(CP_SOLICIT)) $ '"+cNameUser+"' "
	EndIf	 

Return (cFiltro)