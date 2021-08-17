
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �VLDUSGRP  �Autor  �Microsiga           � Data �  12/22/06   ���
�������������������������������������������������������������������������͹��
���Desc.     � Verifique se o usuario pertence ao grupo especifico.       ���
���          � Retorno : True ou False                                    ���
�������������������������������������������������������������������������͹��
���Uso       � AP8                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function VLDUSGRP(cCodGrupo)
Local lRet := .F.
Local __cIdUsr := RetCodUsr()
Local aGrupos := UsrRetGrp(,__cIdUsr)

If !Empty( cCodGrupo )

	If Ascan(aGrupos, {|x| Alltrim(Upper(x)) == Alltrim(upper(cCodGrupo)) }) > 0
		lRet := .T.
	EndIf

EndIf

If __cUserId == "000000"
	lRet := .T.
EndIf

Return(lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �IsFree    �Autor  �Microsiga           � Data �  07/28/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Funcao para liberar o filtro para membros do grupo de       ���
���           usuario gravado no parametro FS_ELE005                      ���
���                                                                       ���
�������������������������������������������������������������������������͹��
���Uso       � AP - ELETROMEGA.                                           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function IsFree()
Local lRet := .F.
Local __cIdUsr := RetCodUsr()
Local aGrupos := UsrRetGrp(,__cIdUsr)
Local cGrupo  := ""     // mudar aqui o grupo de usuarios 

cGrupo := GetMV("FS_ELE005") // Filtro de cadastro de cliente

If Ascan(aGrupos, {|x| Alltrim(Upper(x)) == Alltrim(upper(cGrupo)) }) > 0
	lRet := .T.
EndIf

Return(lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �IsFreeCondPgt �Autor  �Microsiga       � Data �  12/05/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Funcao para liberar o filtro de cond de pagamentos para     ���
���           membros do grupo gravado no parametro FS_ELE006             ���
���                                                                       ���
�������������������������������������������������������������������������͹��
���Uso       � MP8 - ELETROMEGA.                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function IsFreeCondPgt()

Local lRet := .F.      
Local __cIdUsr := RetCodUsr()
Local aGrupos := UsrRetGrp(,__cIdUsr)
Local cGrupo  := ""     // mudar aqui o grupo de usuarios 

cGrupo := GetMV("FS_ELE006")

If Ascan(aGrupos, {|x| Alltrim(Upper(x)) == Alltrim(upper(cGrupo)) }) > 0
	lRet := .T.
EndIf

Return(lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �InGroup(cGrupo) �Autor  �WAR             � Data �  07/11/08 ���
�������������������������������������������������������������������������͹��
���Desc.     �Funcao para verificar se o usuario logado e membro do grupo ���
���           O grupo Deve ser cadastrado no configurador                 ���
���           Retorno : True/False                                        ���
�������������������������������������������������������������������������͹��
���Uso       � MP8 - ELETROMEGA.                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function InGroup(cGrupo)
Local lRet    := .F.
Local __cIdUsr := RetCodUsr()
Local aGrupos := UsrRetGrp(,__cIdUsr)

If Ascan(aGrupos, {|x| Alltrim(Upper(x)) == Alltrim(upper(cGrupo)) }) > 0
	lRet := .T.
EndIf

Return(lRet)
