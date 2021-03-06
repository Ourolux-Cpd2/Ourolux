#Include "Topconn.ch"
#Include "Protheus.ch"
#Include "Tbiconn.ch"

/*/
���������������������������������������������������������������������������������������������������
���Fun��o    � BLOCKDP        � Autor �  Rodrigo Franco                 � Data �   26/10/2016   ���
�����������������������������������������������������������������������������������������������Ĵ��
���Descri��o � Bloqueia usuarios que mudem qualquer coluna de determinadas verbas (MV_BLOQDP1)  ���
�����������������������������������������������������������������������������������������������Ĵ��
���Sintaxe   � Tela de Lancamentos Mensais - Gestao Pessoal                                     ���
���������������������������������������������������������������������������������������������������
/*/

User Function BLOCKDP()      

Local aArea	   := GetArea()
Local lRet     := .T. 
Local _cMatri  := SRC->RC_MAT  
Local _nVez    := 1
Local _cVerba  := "" 
Local _cVerBlo := Alltrim(GetMV("MV_BLOQDP1"))   
nPOSPD := ASCAN(aHEADER,{ |X| UPPER(ALLTRIM(X[2])) == "RC_PD" })
_cPD   := aCOLS[n][nPOSPD]

DbSelectArea("SRC")
DbSetOrder(1)
IF DbSeeK(XFilial("SRC")+SRC->RC_MAT)    
	While !EOF().and. SRC->RC_MAT == _cMatri
		If _nVez == n
			_cVerba := SRC->RC_PD 
			If _cVerba $ _cVerBlo    //"101,401,405"
				lRet := .F.
			Endif
			exit
		Endif 
		_nVez += 1	
	DbSkip()
	End	                                                                        
ENDIF

IF _cPD $ _cVerBlo
	lRet := .F.
ENDIF

RestArea(aArea)
Return lRet