#INCLUDE "PROTHEUS.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±º Programa ³ MSE3440() ³ Autor ³ Claudino Domingues    ³ Data ³ 17/04/14 º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±º Funcao Padrao ³ FINA070 ou FINA330                                     º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±º Desc.    ³ Sera utilizado para tratamento complementar na gravação da  º±±
±±º          ³ comissão (SE3). É executado na baixa a receber e na compen- º±±
±±º          ³ sação a receber.                                            º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function MSE3440()
    
    Local _AreaSE3 := SE3->(GetArea("SE3"))
    Local _AreaSF2 := SF2->(GetArea("SF2"))
    Local _AreaSA3 := SA3->(GetArea("SA3"))
    
    Local _cCodVen := ""
	Local _cCodCli := ""
	Local _cCliLoj := ""
	Local _cSerie  := ""
	Local _cNota   := ""
	Local _cParc   := ""
	Local _cTipo   := ""
	Local _cSeq    := ""
	Local _nValBas := ""
	Local _cFil    := ""
    
	If (IsInCallStack("FINA070") .OR. IsInCallStack("FINA200") .OR. IsInCallStack("FINA330") .OR. IsInCallStack("FINA440"))
		
		dbSelectArea("SA3")
		SA3->(dbSetOrder(1))
		If SA3->(dbSeek(xFilial("SA3")+SE3->E3_VEND))
			RecLock("SE3",.F.)
				SE3->E3_X_BLOQ	:= SA3->A3_X_BLOQ
			SE3->(MsUnLock())
		EndIf
	    
		dbSelectArea("SF2")
		SF2->(dbSetOrder(1))
		
		If Alltrim(SE3->E3_PREFIXO) == "5"
			_cFil := "01"
		ElseIf Alltrim(SE3->E3_PREFIXO) == "4"
			_cFil := "02"
		ElseIf Alltrim(SE3->E3_PREFIXO) == "7"
			_cFil := "04"
		ElseIf Alltrim(SE3->E3_PREFIXO) == "6"
			_cFil := "03"
		EndIf 
		
		If SF2->(dbSeek(_cFil+SE3->E3_NUM+SE3->E3_PREFIXO))
			If SF2->F2_EMISSAO <= CTOD("01/08/2014")
				
				_cCodVen := SE3->E3_VEND
				_cCodCli := SE3->E3_CODCLI
				_cCliLoj := SE3->E3_LOJA
				_cSerie  := SE3->E3_PREFIXO
				_cNota   := SE3->E3_NUM
				_cParc   := SE3->E3_PARCELA
				_cTipo   := SE3->E3_TIPO
				_cSeq    := SE3->E3_SEQ
				
				SE3->(dbSetOrder(2))
				If SE3->(dbSeek(xFilial("SE3")+_cCodVen+_cSerie+_cNota))
				   If SE3->E3_BAIEMI == "E"
						SE3->(dbSetOrder(3))
						If SE3->(dbSeek(xFilial("SE3")+_cCodVen+_cCodCli+_cCliLoj+_cSerie+_cNota+_cParc+_cTipo+_cSeq))
							RecLock("SE3",.F.)
								_nValBas := (SE3->E3_BASE / 2)
								SE3->E3_BASE  := _nValBas
								SE3->E3_COMIS := (_nValBas * (SE3->E3_PORC / 100))
							SE3->(MsUnLock())
						EndIf
				   EndIf
				EndIf
            EndIf
		EndIf   
	
	EndIf 
    
	RestArea(_AreaSE3)
	RestArea(_AreaSF2)
	RestArea(_AreaSA3)

Return