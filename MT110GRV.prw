#INCLUDE "PROTHEUS.CH"

/*苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北?Programa ?MT110GRV() ?Autor ?Claudino P Domingues ?Data ?01/11/13 罕?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北?Funcao Padrao ?MATA110                                                罕?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北?Desc.    ?Ponto de entrada chamado na gravacao de cada item da SC.    罕?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌*/

User Function MT110GRV()
    
	Local _aArea    := GetArea()
	Local _aAreaSC1 := SC1->(GetArea())
    
 	If !Empty(ALLTRIM(_cDepSC1))
		RecLock("SC1",.F.)
			SC1->C1_XDEPART := _cDepSC1
			//SC1->C1_XPEDPRG := _cPedPrg
			//SC1->C1_XDTPROG := _dDtProg
		MsUnlock("SC1")
	EndIf

	RecLock("SC1",.F.)
	SC1->C1_XDTLIB := CTOD("  /  /    ")
	MsUnlock("SC1")
	
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//矱nvia Workflow para aprovacao da Solicitacao de Compras ?
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	If ( SC1->C1_ITEM == aCols[Len(aCols)][Ascan(aHeader,{|x| Upper(Alltrim(x[2])) == "C1_ITEM" })] ) 
		MsgRun("Enviando Workflow para Aprovador da Solicita玢o, Aguarde...","",{|| CursorWait(), U_WFAPRVSC() ,CursorArrow()})
	EndIf
	    
	RestArea(_aAreaSC1)    
	RestArea(_aArea)

Return
