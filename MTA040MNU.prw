#Include "Protheus.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MTA040MNU �Autor  �Isaias Chipoch      � Data �  04/14/16   ���
�������������������������������������������������������������������������͹��
���Desc.     � ponto de entrada para criar botoes na tela                 ���
���          � cadastro de vendedores                                     ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function MTA040MNU()

/* war 10-02-2020
Local _aUser     :={}
Local _cVisualiza :=""


PswSeek(__cUserId)
_aUser := PswRet()

If !Empty(_aUser[1][22])
	
	
	If !Empty(ALLTRIM(SRA->RA_DEPTO)) .And. ALLTRIM(SRA->RA_DEPTO) $ '000000023.000000008'
		_cVisualiza:=Upper(UsrRetName(__cUserId))
	Elseif !Empty(ALLTRIM(SRA->RA_DEPTO)) .And. ALLTRIM(SRA->RA_DEPTO) $ '000000018'
		_cVisualiza:=Upper(UsrRetName(__cUserId))
	EndIf
	
	
Endif

If Upper(UsrRetName(__cUserId)) $ _cVisualiza
	
	aadd(aRotina,{'IPRCQOA','U_INTWORD("0")' , 0 , 3,,})
	aadd(aRotina,{'APDRC','U_INTWORD("1")' , 0 , 3,,})
	
endif

war 10-02-2020 */

Return