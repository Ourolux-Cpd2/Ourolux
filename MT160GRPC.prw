#INCLUDE "PROTHEUS.CH"

/*苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北? Programa ? MT160GRPC()? Autor ? Claudino P Domingues ? Data ? 14/10/13 罕?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北? Funcao Padrao ? MATA160                                                罕?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北? Desc.    ? Ponto de entrada disponibilizado para gravacao de valores   罕? 
北?          ? e campos especificos do Pedido de Compra (SC7).             罕?
北?          ? Executado durante a geracao do pedido de compra na analise  罕?
北?          ? da cotacao.                                                 罕?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌*/

User Function MT160GRPC()    
    
    Local _aAreaSC1 := SC1->(GetArea())
    Local _aAreaSC7 := SC7->(GetArea())
    
    If !Empty(ALLTRIM(SC1->C1_XDEPART))
   		RecLock("SC7",.F.)
			SC7->C7_XDEPART := SC1->C1_XDEPART
		SC7->(MSUnLock())
	EndIf  
    
	SC7->(RestArea(_aAreaSC7))
	SC1->(RestArea(_aAreaSC1))
   
Return Nil