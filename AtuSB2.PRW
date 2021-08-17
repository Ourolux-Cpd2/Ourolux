#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³  MEGA36  ³ Autor ³ Eduardo Lobato        ³ Data ³ 19/12/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ACERTO DE ACUMULADOS DE ESTOQUE - SCHEDULE	              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAEST                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Acertar B2_QPEDVEN e B2_RESERVA                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function AtuSB2()

LOCAL lLOG		:= .F.
LOCAL aCampos 	:= {}
LOCAL bCampos 	:= {}
LOCAL cFim		:= chr (13) + chr (10)
LOCAL aFILIAL	:= {}
Private cLOG 	:= ""                         

PREPARE ENVIRONMENT EMPRESA "01" FILIAL "01"

DBSELECTAREA("SM0")
DBSETORDER(1)
DBGOTOP()
WHILE !EOF()
	IF SM0->M0_CODIGO == "01"
		AADD(aFILIAL,SM0->M0_CODFIL)
    ENDIF
	DBSKIP()
END
            

FOR X:=1 TO LEN(aFILIAL)
	                                                       
	IF X > 1
  		PREPARE ENVIRONMENT EMPRESA "01" FILIAL aFILIAL[X]
 	ENDIF

	lLOG		:= .F.
	aCampos 	:= {}
	bCampos 	:= {}
	cLOG 		:= ""
	
	cFILIAL 	:= aFILIAL[X]

	
	 mv_par01 := " "  		         // Do Produto
	 mv_par02 := "ZZZZZZ"    	     // Ao Produto
	
		
	IF SELECT("TBR") >0
		DBSELECTAREA("TBR")
		DBCLOSEAREA()
	ENDIF
	
	AADD(aCampos,{ "BR_FILIAL" ,"C",02,0 } )
	AADD(aCampos,{ "BR_COD"    ,"C",15,0 } )
	AADD(aCampos,{ "BR_LOCAL"  ,"C",02,0 } )
	AADD(aCampos,{ "BR_RESEOLD","N",12,2 } )
	AADD(aCampos,{ "BR_QPEDOLD","N",12,2 } )
	AADD(aCampos,{ "BR_RESERVA","N",12,2 } )
	AADD(aCampos,{ "BR_QPEDVEN","N",12,2 } ) 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria arquivo de trabalho                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cNomArq 	:=  CriaTrab(aCampos)
	dbUseArea( .T.,, cNomArq,"TBR", .F. , .F. )
	
	cNomArq1 := Subs(cNomArq,1,7)+"A"
	IndRegua("TBR",cNomArq1,"BR_FILIAL+BR_COD+BR_LOCAL",,,)		//"Selecionando Registros..."
	dbClearIndex()
	
	
	dbSetIndex(cNomArq1+OrdBagExt())
	
	dbselectarea("TBR")
	DBSETORDER(1)
	
	
	IF SELECT("TCR") >0
		DBSELECTAREA("TCR")
		DBCLOSEAREA()
	ENDIF
	
	AADD(bCampos,{ "CR_FILIAL" ,"C",02,0 } )
	AADD(bCampos,{ "CR_COD"    ,"C",15,0 } )
	AADD(bCampos,{ "CR_LOCAL"  ,"C",02,0 } )
	AADD(bCampos,{ "CR_EMPEOLD","N",12,2 } )
	AADD(bCampos,{ "CR_EMPENHO","N",12,2 } )
	AADD(bCampos,{ "CR_LOTECTL","C",10,0 } )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria arquivo de trabalho                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cNomArqC 	:=  CriaTrab(bCampos)
	dbUseArea( .T.,, cNomArqC,"TCR", .F. , .F. )
	
	cNomArqC1 := Subs(cNomArqC,1,7)+"A"
	IndRegua("TCR",cNomArqC1,"CR_FILIAL+CR_COD+CR_LOCAL+CR_LOTECTL",,,)		//"Selecionando Registros..."
	dbClearIndex()
	
	
	dbSetIndex(cNomArqC1+OrdBagExt())
	
	dbselectarea("TCR")
	DBSETORDER(1)
	                                       
	/////// QUERY SB2 -> SOMENTE PRODUTOS QUE TENHAM O B2_RESERVA OU O B2_PEDVEN NEGATIVOS


	IF SELECT("TMP") >0
		DBSELECTAREA("TMP")
		DBCLOSEAREA()
	ENDIF

	
	cQUERY := "SELECT B2_FILIAL, B2_COD, B2_LOCAL "
	cQUERY += "FROM "+RetSqlName("SB2") + " AS SB2 "
	cQUERY += "WHERE SB2.D_E_L_E_T_ <> '*' AND "           
	cQUERY += "SB2.B2_FILIAL = '"+cFILIAL+"' AND "
	cQUERY += "(SB2.B2_RESERVA < 0 OR SB2.B2_QPEDVEN < 0) "
	cQUERY += "ORDER BY B2_FILIAL, B2_COD, B2_LOCAL "
	
	cQUERY := ChangeQuery(cQUERY)
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQUERY),"TMP",.T.,.F.)
	
	///////////////////// PROCESSAMENTO
	
	DBSELECTAREA("TMP")
	DBGOTOP()
	WHILE !EOF() 
		
		DBSELECTAREA("TBR")
		RECLOCK("TBR",.T.)
		FIELD->BR_FILIAL 	:= TMP->B2_FILIAL
		FIELD->BR_COD		:= TMP->B2_COD
		FIELD->BR_LOCAL		:= TMP->B2_LOCAL
		MSUNLOCK()
		
		/// PROCESSA QUERY DO SC6 PARA ACHAR QPEDVEN DE ITENS DE PEDIDOS NÃO LIBERADOS
		
		IF SELECT("TC6") > 0
			DBSELECTAREA("TC6")
			DBCLOSEAREA()
		ENDIF
		
		cQUERY := "	SELECT * "
		cQUERY += " FROM " + RetSqlName("SC6") + " SC6 "
		cQUERY += " WHERE C6_FILIAL = '" + aFILIAL[X] + "' "
		cQUERY += " AND C6_LOCAL = '"+TMP->B2_LOCAL+"' "
		cQUERY += " AND C6_PRODUTO = '"+TMP->B2_COD+"' "
		cQUERY += " AND C6_NOTA = '         ' "
		cQUERY += " AND C6_QTDEMP = 0 "
		cQUERY += " AND	C6_BLQ <> 'R ' "
		cQUERY += " AND C6_BLQ <> 'S ' "
		cQUERY += " AND SC6.D_E_L_E_T_ <> '*'	 "
		DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'TC6', .T., .F.)
		
		DBSELECTAREA("TC6")
		DBGOTOP()
		WHILE!EOF()
			
			DBSELECTAREA("TBR")
			DBSETORDER(1)
			DBGOTOP()
			IF DBSEEK(aFILIAL[X]+TC6->C6_PRODUTO+TC6->C6_LOCAL)
				DBSELECTAREA("TBR")
				RECLOCK("TBR",.F.)
				FIELD->BR_QPEDVEN	:= TBR->BR_QPEDVEN + (TC6->C6_QTDVEN - TC6->C6_QTDENT)
				MSUNLOCK()
			ENDIF
			
			DBSELECTAREA("TC6")
			DBSKIP()
		END
		
		
		/// PROCESSA QUERY DO SC9 PARA ACHAR QPEDVEN DE ITENS DE PEDIDOS LIBERADOS
		
		IF SELECT("TC9")  > 0
			DBSELECTAREA("TC9")
			DBCLOSEAREA()
		ENDIF
		
		cQUERY := "	SELECT * "
		cQUERY += " FROM " + RetSqlName("SC9") + " SC9 "
		cQUERY += " WHERE C9_FILIAL = '" + aFILIAL[X] + "' "
		cQUERY += " AND C9_LOCAL = '"+TMP->B2_LOCAL+"' "
		cQUERY += " AND C9_PRODUTO = '"+TMP->B2_COD+"' "
		cQUERY += " AND C9_OK = '    ' "
		cQUERY += " AND C9_NFISCAL = '         ' "
		cQUERY += " AND C9_BLEST <> '  ' "
		cQUERY += " AND SC9.D_E_L_E_T_ <> '*' "
		DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'TC9', .T., .F.)
		
		
		DBSELECTAREA("TC9")
		DBGOTOP()
		WHILE!EOF()
			
			DBSELECTAREA("TBR")
			DBSETORDER(1)
			DBGOTOP()
			IF DBSEEK(aFILIAL[X]+TC9->C9_PRODUTO+TC9->C9_LOCAL)
				DBSELECTAREA("TBR")
				RECLOCK("TBR",.F.)
				FIELD->BR_QPEDVEN	:= TBR->BR_QPEDVEN + TC9->C9_QTDLIB
				MSUNLOCK()
			ENDIF
			
			DBSELECTAREA("TC9")
			DBSKIP()
		END
		
		
		/// PROCESSA QUERY DO SC9 PARA ACHAR RESERVADOS DE ITENS DE PEDIDOS LIBERADOS
		
		IF SELECT("LC9")  > 0
			DBSELECTAREA("LC9")
			DBCLOSEAREA()
		ENDIF
		
		cQUERY := "	SELECT * "
		cQUERY += " FROM " + RetSqlName("SC9") + " SC9 "
		cQUERY += " WHERE C9_FILIAL = '" + aFILIAL[X] + "' "
		cQUERY += " AND C9_LOCAL = '"+TMP->B2_LOCAL+"' "
		cQUERY += " AND C9_PRODUTO = '"+TMP->B2_COD+"' "
		cQUERY += " AND C9_OK = '    ' "
		cQUERY += " AND C9_NFISCAL = '         ' "
		cQUERY += " AND C9_BLEST = '  ' "
		cQUERY += " AND SC9.D_E_L_E_T_ <> '*' "
		DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'LC9', .T., .F.)
		
		
		DBSELECTAREA("LC9")
		DBGOTOP()
		WHILE!EOF()
			
			DBSELECTAREA("TBR")
			DBSETORDER(1)
			DBGOTOP()
			IF DBSEEK(aFILIAL[X]+LC9->C9_PRODUTO+LC9->C9_LOCAL)
				DBSELECTAREA("TBR")
				RECLOCK("TBR",.F.)
				FIELD->BR_RESERVA	:= TBR->BR_RESERVA + LC9->C9_QTDLIB
				MSUNLOCK()
			ENDIF
			
			
			DBSELECTAREA("TCR")
			DBSETORDER(1)
			DBGOTOP()
			IF !DBSEEK(aFILIAL[X]+LC9->C9_PRODUTO+LC9->C9_LOCAL+LC9->C9_LOTECTL)
				DBSELECTAREA("TCR")
				RECLOCK("TCR",.T.)
				FIELD->CR_FILIAL	:= LC9->C9_FILIAL
				FIELD->CR_COD		:= LC9->C9_PRODUTO
				FIELD->CR_LOCAL		:= LC9->C9_LOCAL
				FIELD->CR_EMPENHO	:= LC9->C9_QTDLIB
				FIELD->CR_LOTECTL	:= LC9->C9_LOTECTL
			ELSE
				FIELD->CR_EMPENHO	:= TCR->CR_EMPENHO + LC9->C9_QTDLIB
			ENDIF
			
			DBSELECTAREA("LC9")
			DBSKIP()
		END
		
		DBSELECTAREA("TMP")
		DBSKIP()
	END
	
	
	DBSELECTAREA("TBR")
	DBGOTOP()
	WHILE !EOF()
		
		lLOG	:= .T.
		
		DBSELECTAREA("SB2")
		DBSETORDER(1)
		DBGOTOP()
		DBSEEK(aFILIAL[X]+TBR->BR_COD+TBR->BR_LOCAL)
		nRESERVA	:= SB2->B2_RESERVA
		nQPEDVEN	:= SB2->B2_QPEDVEN
		
		RECLOCK("SB2",.F.)
		FIELD->B2_RESERVA := TBR->BR_RESERVA
		FIELD->B2_QPEDVEN := TBR->BR_QPEDVEN
		MSUNLOCK()
		
		DBSELECTAREA("TBR")
		RECLOCK("TBR",.F.)
		FIELD->BR_RESEOLD	:= nRESERVA
		FIELD->BR_QPEDOLD	:= nQPEDVEN
		MSUNLOCK()
		
		DBSKIP()
	END
	
	/// SALDOS POR LOTE
	
	DBSELECTAREA("SB8")
	DBSETORDER(1)
	DBGOTOP()
	DBSEEK(aFILIAL[X]+MV_PAR01)
	WHILE !EOF() .AND. SB8->B8_PRODUTO >= MV_PAR01 .AND. SB8->B8_PRODUTO <= MV_PAR02 .AND. SB8->B8_FILIAL == XFILIAL("SB8")
		
		DBSELECTAREA("TCR")
		DBSETORDER(1)
		DBGOTOP()
		IF DBSEEK(aFILIAL[X]+SB8->B8_PRODUTO+SB8->B8_LOCAL+SB8->B8_LOTECTL)
			nEMPENHO := SB8->B8_EMPENHO
			
			RECLOCK("TCR",.F.)
			FIELD->CR_EMPEOLD := nEMPENHO
			MSUNLOCK()
			
			DBSELECTAREA("SB8")
			RECLOCK("SB8",.F.)
			FIELD->B8_EMPENHO := TCR->CR_EMPENHO
			MSUNLOCK()
			
		ELSE
			DBSELECTAREA("SB8")
			RECLOCK("SB8",.F.)
			FIELD->B8_EMPENHO := 0
			MSUNLOCK()
		ENDIF
		DBSELECTAREA("SB8")
		DBSKIP()
	END     
	
	// TESTE
	//lLOG := .T.
	
	IF lLOG
		cLOG += " FILIAL "+aFILIAL[X]
		cLOG += cFIM
		cLOG += ""
		cLOG += cFIM
		
		cLOG += " Acerto de Quantidades Acumuladas nas Tabelas de Saldos - SB2"
		cLOG += cFIM
		cLOG += ""
		cLOG += cFIM
		cLOG += "    CODIGO              ALM            RESERVA         PEDIDO DE VENDA"
		cLOG += cFIM
		cLOG += "                                  ANTIGA     ATUAL    ANTIGO      ATUAL"
		cLOG += cFIM
		cLOG += ""
		cLOG += cFIM
		
		XLIN := 80
		
		DBSELECTAREA("TBR")
		DBSETORDER(1)
		DBGOTOP()
		WHILE !EOF()
			
			cLOG += SPACE(5)+TBR->BR_COD    // 20
			cLOG += SPACE(5)+TBR->BR_LOCAL  // 27
			cLOG += SPACE(3)+TRANSFORM(TBR->BR_RESEOLD,"@E 999,999.99") // 40
			cLOG += TRANSFORM(TBR->BR_RESERVA,"@E 999,999.99") // 50
			cLOG += TRANSFORM(TBR->BR_QPEDOLD,"@E 999,999.99") // 60
			cLOG += TRANSFORM(TBR->BR_QPEDVEN,"@E 999,999.99") // 70
			cLOG += cFIM
			
			DBSKIP()
		END
		cLOG += ""
		cLOG += cFIM
		cLOG += ""
		cLOG += cFIM
		cLOG += "Acerto de Quantidades Acumuladas nas Tabelas de Saldos - SB8"
		cLOG += cFIM
		cLOG += ""
		cLOG += cFIM
		cLOG += "    CODIGO              ALM                  EMPENHO            NUM. LOTE"
		cLOG += cFIM
		cLOG += "                                       ANTIGO         ATUAL "
		cLOG += cFIM
		cLOG += ""
		cLOG += cFIM
		
		
		
		DBSELECTAREA("TCR")
		DBGOTOP()
		WHILE !EOF()
			
			cLOG += SPACE(5)+TCR->CR_COD    // 20
			cLOG += SPACE(5)+TCR->CR_LOCAL  // 27
			cLOG += SPACE(8)+TRANSFORM(TCR->CR_EMPEOLD,"@E 999,999.99") // 45
			cLOG += SPACE(5)+TRANSFORM(TCR->CR_EMPENHO,"@E 999,999.99") // 60
			cLOG += SPACE(5)+TCR->CR_LOTECTL
			cLOG += cFIM
			
			DBSKIP()
		END
		
		cLOG += ""
		cLOG += cFIM
		
		// TESTE
		//MErro() 
		cStartPath := GetSrvProfString("Startpath","")
		cFileLog   := Criatrab(,.f.)+".LOG"
		cNome      := cFileLog
		MemoWrite(cNome,cLOG)
		cLogName   := "M"+aFILIAL[X]+STRZERO(DAY(dDATAbASE),2)+STRZERO(MONTH(DDATABASE),2)+SUBS(STRZERO(YEAR(dDATAbASE),4),3,2)+".LOG"
		Copy File (cStartPath + cFileLog) To ("\INTRJ\" + cLOGNAME)
		
	ENDIF
	
	dbSelectArea( "TBR" )
	dbCloseArea()
	fErase(cNomArq+GetDBExtension())
	fErase(cNomArq1+OrdBagExt())
	
	dbSelectArea( "TCR" )
	dbCloseArea()
	fErase(cNomArqC+GetDBExtension())
	fErase(cNomArqC1+OrdBagExt())
	
	IF SELECT("TMP") > 0
		dbSelectArea( "TMP" )
		dbCloseArea()
	ENDIF

	IF SELECT("TC6") > 0
		dbSelectArea( "TC6" )
		dbCloseArea()
	ENDIF
	
	IF SELECT("TC9") > 0
		dbSelectArea( "TC9" )
		dbCloseArea()
	ENDIF
	
	IF SELECT("LC9") > 0
		dbSelectArea( "LC9" )
		dbCloseArea()
	ENDIF                       
	
	RESET ENVIRONMENT
	
NEXT


RETURN .T.

      
/// FUNCAO PARA USO EM TESTE
                            
/*
	@ 5,5 GET oMemo  VAR cMemo MEMO SIZE 300,145 OF oDlg PIXEL
	oMemo:bRClicked := {||AllwaysTrue()}
	oMemo:oFont:=oFont
	
	DEFINE SBUTTON  FROM 153,175 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg PIXEL //Apaga
	DEFINE SBUTTON  FROM 153,145 TYPE 13 ACTION (cFile:=cGetFile(cMask,OemToAnsi("Salvar Como...")),If(cFile="",.t.,MemoWrite(cFile,cMemo)),oDlg:End()) ENABLE OF oDlg PIXEL // //
	DEFINE SBUTTON  FROM 153,115 TYPE 6 ACTION (PrintAErr(__cFileLog,cMemo),oDlg:End()) ENABLE OF oDlg PIXEL //
	
	ACTIVATE MSDIALOG oDlg CENTER
Else
	ConOut("Processo nao concluido. Verificar arquivo " + cNome)
	//	Copy File (cStartPath + "\" + __cFileLog) To (cPath + "\" + cNome)
EndIf
Ferase(__cFileLog)
__cFileLog := Nil
Return(cMemo)
*/
