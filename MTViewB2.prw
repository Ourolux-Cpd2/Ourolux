/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MTVIEWB2  ºAutor  ³Microsiga           º Data ³  08/26/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Ponto de entrada especifico Eletromega para responder     º±±
±±º          ³  ao tecla F4.                                              º±±
±±º          ³  .T. -> Mostra tela padrao                                 º±±
±±º          ³  .F. -> Mostra tela Eletromega                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

#INCLUDE "rwmake.ch"

User Function MTViewB2()

Local lRet      := .F.
Local lEstLim	:= U_IsELE002()
Local aArea	:=	GetArea()
	
If lEstLim 
	SaldoMega()
End

RestArea(aArea)			

Return ( !lEstLim )
                  

Static Function SaldoMega()

Private nAtu   		:= 0
Private nPedVen 	:= 0
Private nPedCom 	:= 0
Private nEmp 		:= 0
Private nReserva	:= 0
Private nQtdLim		:= GetMv("MV_QTDLIM") 
Private cLocal 		:= '01'

If IsInCallStack("MATA410") 
	Private nPosLocal := aScan( aHeader,{|x| AllTrim(x[02]) == "C6_LOCAL" })
	If nPosLocal > 0
		cLocal := aCols[n][nPosLocal]
	EndIf
EndIf
           
SB2->( dbSetOrder( 1 ) )

If ( SB2->( dbSeek( xFilial( "SB2" ) + SB1->B1_COD + cLocal, .F. ) ) )

	nAtu   	:= SB2->B2_QATU
	nPedVen := SB2->B2_QPEDVEN
	nEmp    := SB2->B2_QEMP
	nPedCom := SB2->B2_SALPEDI
	nReserva:= SB2->B2_RESERVA

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Aglutina SB2 Filial 01 ao SB2 Filial 04 - Específico p/ Rio de Janeiro³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cFilAnt == "04"
		aAreaSB2 := SB2->(GetArea())
		DbSelectarea("SB2")
		DbSetorder(1)
		DbGoTop()
		If DbSeek("01" + SB1->B1_COD + cLocal)
			nAtu		:= nAtu + SB2->B2_QATU
			nPedVen		:= nPedVen + SB2->B2_QPEDVEN
			nEmp		:= nEmp + SB2->B2_QEMP
			nPedCom		:= nPedCom + SB2->B2_SALPEDI
			nReserva	:= nReserva + SB2->B2_RESERVA
		Else
			ApMsgStop( 'Produto ' + SB2->B2_COD + ' sem saldo!', 'MTVIEWB2' )		
		EndIf
		RestArea(aAreaSB2)
	EndIf


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Compatibilizacao com o SIGAFAT - Tecla F4 Visualizacao do estoque³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If cFilAnt == "04"
		nSaldo  := SaldoSb2(,GetNewPar("MV_QEMPV",.T.)) - ABS(nPedVen) - nEmp + SB2->B2_XINTEGR + SB2->B2_XINTEGR
		aAreaSB2 := SB2->(GetArea())
	 	cFilOrig	:= cFilAnt
		cFilAnt		:= "01"
		If (SB2->( dbSeek( xFilial( 'SB2' ) + SB2->B2_COD + GetMV('EX_ALXPDB',,'01') ))) 
			nSldSB201 := SaldoSB2(.F.,.T.,,.F.,.F.,,,,.T.) -  ABS(SB2->B2_QPEDVEN)
			nSaldo := nSaldo + nSldSB201
		EndIf
		cFilAnt	:= cFilOrig
		RestArea(aAreaSB2)
	Else
		//nSaldo  := SaldoSb2(,GetNewPar("MV_QEMPV",.T.)) - ABS(nPedVen) - nEmp        WAR 20-10-2015
		nSaldo  := SaldoSb2(,GetNewPar("MV_QEMPV",.T.)) - ABS(nPedVen) 
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se o saldo esta acima do valor permitido para³
	//³visualizacao do operador                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nAtu > nQtdLim
		nAtu := nQtdLim
	EndIf       
	If nSaldo > nQtdLim
		nSaldo := nQtdLim
	EndIf
	 		
   @ 62,1 TO 280,365 DIALOG oDlg TITLE 'Saldos em Estoque'
   @ 0, 2 TO 29, 181
   @ 31, 2 TO 91, 181
   
   @ 6,    5 SAY 'Produto:' SIZE 31, 7
   @ 6,   39 SAY AllTrim( SB1->B1_COD ) + " - " + Alltrim( SB1->B1_DESC ) SIZE 140, 7
   @ 13,   5 SAY 'Local:' SIZE 31, 7 
   @ 13,  39 SAY cLocal SIZE 13, 7
   @ 37,   9 SAY 'Pedido de Vendas em Aberto:' SIZE 92, 7
   @ 37, 118 SAY nPedVen  SIZE 53, 7
   @ 45,   9 SAY 'Quantidade Empenhada:' SIZE 88, 7
   @ 45, 118 SAY nEmp SIZE 53, 7
   @ 53,   9 SAY 'Qdt. Prevista p/Entrar:' SIZE 88, 7
   @ 53, 118 SAY nPedCom SIZE 53, 7
   @ 61,   9 SAY "Quantidade Reservada: " SIZE 88, 7 
   @ 61, 118 SAY nReserva SIZE 53, 7
   @ 69,   9 SAY "Saldo Atual: " SIZE 53, 7
   @ 69, 118 SAY nAtu SIZE 53, 7
   @ 78,   9 SAY "Saldo Disponivel: " SIZE 53, 7
   @ 78, 118 SAY nSaldo SIZE 53, 7
   @ 95, 149 BMPBUTTON TYPE 1 ACTION Close( oDlg )
   ACTIVATE DIALOG oDlg

End //dbseek
                
Return
