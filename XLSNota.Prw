#INCLUDE "PROTHEUS.CH"

#IFNDEF WINDOWS
   #DEFINE PSAY SAY
#ENDIF

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณXLSNOTA   บAutor  ณELETROMEGA          บ Data ณ  04/03/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Exportar as Notas Fiscias para Excel                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function XLSNota()
Local 	cQry
Local   nNextNum
Local   lFirst		:= .T. 

PRIVATE cPerg := "ELET10"

If ! Pergunte( cPerg,.T. )

   Return( NIL )

End

PRIVATE cstring:="SF2"

__SetCentury( "On" )

dIni := DtoS( MV_PAR01 )
dFim := DtoS( MV_PAR02 )

cQryEnt := " SELECT SF1.F1_DOC DOC, SF1.F1_SERIE SERIE, "
cQryEnt += " SUBSTRING (SF1.F1_DTDIGIT, 7, 2) + '/' + SUBSTRING(SF1.F1_DTDIGIT, 5, 2) + "
cQryEnt += " '/' + SUBSTRING(SF1.F1_DTDIGIT, 1, 4) AS DTDIGIT, "
cQryEnt += " SF1.F1_FORNECE   AS FORNECE, SF1.F1_LOJA AS LOJA, " 
cQryEnt += " SF1.F1_EST       AS ESTADO,	 "
cQryEnt += " SF1.F1_VALICM    AS ICM,		 "
cQryEnt += " SF1.F1_VALMERC   AS VALMERC,	 "
cQryEnt += " SF1.F1_ICMSRET   AS SUBST,		 " 
cQryEnt += " SF1.F1_VALIPI    AS IPI, 		 " 
cQryEnt += " SF1.F1_VALBRUT   AS TOTAL,      "
cQryEnt += " SF1.F1_TIPO      AS TIPO,       "
cQryEnt += " SF1.F1_FORMUL    AS FORMUL      "
cQryEnt += " FROM " + RetSqlName("SF1") + " SF1 " 
cQryEnt += " WHERE SF1.F1_DTDIGIT BETWEEN '" + dIni + "' AND '" + dFim + "' "  
cQryEnt += " AND SF1.F1_SERIE = '" + MV_PAR03  + "'  "
cQryEnt += " AND SF1.D_E_L_E_T_ <> '*' " 
cQryEnt += " AND F1_FILIAL = '" + xFilial("SF1") + "' "  // CURITIBA
cQryEnt += " ORDER BY SF1.F1_DOC " 

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryEnt),'QRYENT',.F.,.T.)

cQry := " SELECT SD2.D2_DOC   AS DOC, SD2.D2_SERIE AS SERIE, " 
cQry += " SUBSTRING (SD2.D2_EMISSAO, 7, 2) + '/' + SUBSTRING(SD2.D2_EMISSAO, 5, 2) + "
cQry += " '/' + SUBSTRING(SD2.D2_EMISSAO, 1, 4) AS EMISSAO, "
cQry += " SD2.D2_CLIENTE AS CLIFOR, SD2.D2_LOJA AS LOJA, SD2.D2_EST AS ESTADO, " 
cQry += " SUM(SD2.D2_VALICM)  AS ICMS, "
cQry += " SUM(SD2.D2_TOTAL)   AS MERCADORIA, "
cQry += " SUM(SD2.D2_ICMSRET) AS SUBST , " 
cQry += " SUM(SD2.D2_VALIPI)  AS IPI, " 
cQry += " SUM(SD2.D2_TOTAL + SD2.D2_ICMSRET + SD2.D2_VALIPI) AS TOTAL, "
cQry += " SF2.F2_TIPO         AS TIPO, "
cQry += " SE4.E4_COND         AS PAGAMENTO, " 
cQry += " SF4.F4_TEXTO        AS OPERATION, " 
cQry += " COUNT (DISTINCT SD2.D2_TES) AS NTES , SD2.D2_TES "   
cQry += " FROM " + RetSqlName("SD2") + " SD2 INNER JOIN " 
cQry += "      " + RetSqlName("SF2") + " SF2 ON SD2.D2_DOC = SF2.F2_DOC  "
cQry += " AND SF2.F2_SERIE = SD2.D2_SERIE INNER JOIN " 
cQry += "      " + RetSqlName("SE4") + " SE4 ON SF2.F2_COND = SE4.E4_CODIGO INNER JOIN " 
cQry += "      " + RetSqlName("SF4") + " SF4 ON SD2.D2_TES = SF4.F4_CODIGO "
cQry += " WHERE SD2.D2_EMISSAO BETWEEN '" + dIni + "' AND '" + dFim + "' "  
cQry += " AND SD2.D_E_L_E_T_ <> '*' AND SF2.D_E_L_E_T_ <> '*' " 
cQry += " AND SE4.D_E_L_E_T_ <> '*' AND SF4.D_E_L_E_T_ <> '*' "
cQry += " AND SD2.D2_SERIE = '" + MV_PAR03  + "' "
cQry += " AND F2_FILIAL = '" + xFilial("SF2") + "' "  // CURITIBA" 
cQry += " AND D2_FILIAL = '" + xFilial("SD2") + "' "  // CURITIBA"
cQry += " AND E4_FILIAL = '" + xFilial("SE4") + "' "  // CURITIBA" 
cQry += " AND F4_FILIAL = '" + xFilial("SF4") + "' "  // CURITIBA"
cQry += " GROUP BY SD2.D2_DOC, SD2.D2_SERIE, SD2.D2_EMISSAO, SD2.D2_CLIENTE, " 
cQry += " SD2.D2_LOJA, SD2.D2_EST, SE4.E4_COND, SF2.F2_TIPO, SD2.D2_TES, "
cQry += " SF4.F4_TEXTO "
cQry += " ORDER BY SD2.D2_DOC ,SD2.D2_TES " 

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),'Qry',.F.,.T.)

nNotas := MV_PAR02 - MV_PAR01

If nNotas < 0
   
   dbCloseArea()
   Return

End

RptStatus({ || RptDetail() })

cRun := 'C:\Program Files (x86)\Microsoft Office\Office12\Excel.Exe "Z:\Excel.Csv"'

WinExec( cRun )

QRY->( dbCloseArea() ) 

QRYENT->( dbCloseArea() )

__SetCentury( "Off" )
                                            
Return

Static Function RptDetail()

Local nCounter := 0
Local nNotaAnt := ""
Local aNota    := {} 

fSA1 := xFilial( "SA1" )
fSA2 := xFilial( "SA2" )
fSE1 := xFilial( "SE1" )
fSF1 := xFilial( "SF1" )
fSF2 := xFilial( "SF2" )

SetRegua( nNotas )

nHnd := fCreate( 'Z:\Excel.Csv', 0 )

cCRLF := Chr( 13 ) 
cCRLF += Chr( 10 )

SF2->( dbSetOrder( 1 ) )
SF1->( dbSetOrder( 1 ) )

cTxt := 'NOTA;SERIE;EMISSAO;CLIFOR;NOME;ESTADO;ICMS;MERCADORIA;SUBST;IPI;TOTAL NOTA;OPERAวAO'

cTxt += cCRLF

nLen := Len( cTxt )

/* Write header of file */

fWrite( nHnd, cTxt, nLen )

QRY->( dbGoTop() )

If ( SF2->( dbSeek( fSF2 +	QRY->Doc + QRY->Serie + QRY->CliFor + QRY->Loja , .F. ) ) ) 

	SF2->( dbSkip( -1 ) )   // Go backward one record
    
	nNotaAnt := VAL (SF2->F2_DOC)
	
End   

nNextNum := VAL ( DOC )

If ! Empty(nNotaAnt)

	If ( nNextNum - nNotaAnt ) > 1 

		CanDev(nNotaAnt + 1, nNextNum - nNotaAnt -1)	

	EndIf
EndIf

While ! QRY->( Eof() )

	aNota := {}
	
	If ( nNextNum == VAL (QRY->DOC) )
		
		If QRY->TIPO == 'N'
		
			If (QRY->NTES == 1)
			
				WriteNota(1)
		
			Else  // Treatment for 2 CFOP //
		
				WriteNota(2)	
			
			EndIf
			
		
		ElseIf QRY->TIPO == 'D'
			
			WriteNota(3)
		
		
		ElseIf QRY->TIPO $ "CIP"
		
			WriteNota(8)
		
		Else
		
			WriteNota(9)
		
		EndIf
	
	Else      /* Out of sequence : Cancelada/Entrada/? */
			
		nCounter :=	VAL( QRY->DOC ) - nNextNum 
		
		CanDev(nNextNum, nCounter)
		
		/* Write DOC */
		
		If QRY->TIPO == 'N'
		  
			If QRY->NTES == 1
			
				WriteNota(1)
			
			Else
			
				WriteNota(1)
			
			EndIf
		
		ElseIf QRY->TIPO == 'D'
				
			WriteNota(3)
			
		ElseIf QRY->TIPO $ "CIP"
		
			WriteNota(8)
		
		Else
		
			WriteNota(9)
		
		EndIf

		nNextNum += nCounter 		
	
	EndIf

	nNextNum++
	
	AADD (aNota,QRY->Serie) 
	AADD (aNota,QRY->Doc)
	AADD (aNota,QRY->CliFor)
	AADD (aNota,QRY->Loja)
	
	Qry->( dbSkip() )
	
	IncRegua()

EndDo

/*BEGINDOC
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณTreat notas canceladas between last nota of current period ณ
//ณand the first nota of the next period                      ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
ENDDOC*/

If ( len(aNota) > 1 )

	If ( SF2->( dbSeek( fSF2 +	aNota[2] + aNota[1] + aNota[3] + aNota[4] , .F. ) ) ) 

		SF2->( dbSkip( 1 ) )   // Go to the next record   

		If ( VAL (SF2->F2_DOC)  - VAL (aNota[2]) ) > 1 

			CanDev(VAL (aNota[2]) + 1, VAL ( SF2->F2_DOC ) - VAL (aNota[2]) -1)	

		EndIf

	EndIf

EndIf

nHnd := fClose( nHnd )

Return()


/*BEGINDOC
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณWrite documents information to the Excel fileณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
ENDDOC*/

Static Function WriteNota(nTipo)
	
	If nTipo == 1 .Or. nTipo == 2 .Or. nTipo == 3 .Or. nTipo == 8 /* Saida */
	
		If QRY->TIPO $ "N#C#I#P"

          SA1->( dbSeek( fSA1 + QRY->CLIFOR + QRY->LOJA, .T. ) )

    	Else

          SA2->( dbSeek( fSA2 + QRY->CLIFOR + QRY->LOJA, .T. ) )

    	End

  		cTxt := QRY->DOC
    
    	cTxt += ';'
    
    	cTxt += QRY->SERIE
    
    	cTxt += ';'
    
    	cTxt += QRY->Emissao
    
    	cTxt += ';'
    
    	cTxt += QRY->CLIFOR + '/' + QRY->LOJA
    
    	cTxt += ';'

    	If QRY->Tipo <> 'D'
    
			cTxt += SA1->A1_NREDUZ

    	Else
    		
    		cTxt += SA2->A2_NREDUZ
    
    	End

    	cTxt += ';'
     
    	cTxt += QRY->ESTADO
    	cTxt += ';'

    	cTxt += Transform( QRY->ICMS,       "@E 999,999.99" )
    	cTxt += ';'
       
    	cTxt += Transform( QRY->MERCADORIA, "@E 99,999,999.99" )
    	cTxt += ';' 
       
    	cTxt += Transform( QRY->SUBST,      "@E 999,999.99" )
    	cTxt += ';'
       
    	cTxt += Transform( QRY->IPI,        "@E 999,999.99" )
    	cTxt += ';'
       
    	cTxt += Transform( QRY->TOTAL,      "@E 99,999,999.99" )
    	cTxt += ';'
    	
    	DO CASE
     	
     	CASE nTipo == 1 
        	cTxt += "* " + RTRIM ( QRY->OPERATION ) + " *"
     	CASE nTipo == 2
        	cTxt += "* " + RTRIM ( QRY->OPERATION ) + " *"
     	CASE nTipo == 3
        	cTxt += '* DEVOLUCAO FORNECEDOR *'
        CASE nTipo == 8
        	cTxt += '* COMPLEMENTO DE '
        	
        	If QRY->TIPO == "C"
        	
        		cTxt += 'PREวO *  '
        	
        	ElseIf QRY->TIPO == "I"
        	
        		cTxt += 'ICMS *  '
        	
        	ElseIf QRY->TIPO == "P"
        	
        		cTxt += 'IPI *  '
        	
        	EndIf
     	/*
     	[OTHERWISE]
        	<statements>... */
     	
     	ENDCASE


    ElseIf ( nTipo == 4 .OR. nTipo == 7 )/* Entrada */
    	    	
    	cTxt := QRYENT->DOC
       	cTxt += ';'
       	cTxt += QRYENT->SERIE
       	cTxt += ';'
       	cTxt += Transform( QRYENT->DTDIGIT,      "@E 99/99/9999" )
       	cTxt += ';'
       	SA1->( dbSeek( fSA1 + QRYENT->FORNECE + QRYENT->LOJA, .F. ) )
       	cTxt += QRYENT->FORNECE + '/' + QRYENT->LOJA 
       	cTxt += ';'
       	cTxt += SA1->A1_NREDUZ
       	cTxt += ';'
       	cTxt += QRYENT->ESTADO
       	cTxt += ';'
       	cTxt += Transform( QRYENT->ICM,     "@ZE 999,999.99" )
       	cTxt += ';'
       	cTxt += Transform( QRYENT->VALMERC, "@E 99,999,999.99" )
       	cTxt += ';'
       	cTxt += Transform( QRYENT->SUBST,   "@E 999,999.99" )
       	cTxt += ';'
		cTxt += Transform( QRYENT->IPI,     "@E 999,999.99" )
       	cTxt += ';' 
       	cTxt += Transform( QRYENT->TOTAL,   "@E 99,999,999.99" )
       	cTxt += ';'
       	
       	If ( nTipo == 4)
       	
       		cTxt += '* DEVOLUCAO CLIENTE *' 
       	
       	ElseIf (nTipo == 7)
       	
       		cTxt += '* IMPORTAวAO *'
       		
       	EndIf
    	   
    ElseIf nTipo == 5 /* Cancelada */
    	
    	cTxt := cNota
       	cTxt += ';'
       	cTxt += ';'
       	cTxt += ';'
       	cTxt += ';'
       	cTxt += ';'
       	cTxt += ';'
       	cTxt += ';'
       	cTxt += ';'
       	cTxt += ';'
       	cTxt += ';'
       	cTxt += ';'
       	cTxt += '* C A N C E L A D A *'

    ElseIf ( nTipo == 6 ) /* Missing */          
    	
    	cTxt := cNota
       	cTxt += ';'
       	cTxt += ';'
       	cTxt += ';'
       	cTxt += ';'
       	cTxt += ';'
       	cTxt += ';'
       	cTxt += ';'
       	cTxt += ';'
       	cTxt += ';'
       	cTxt += ';'
       	cTxt += ';'
       	cTxt += '* F A L T A N D O *'
     
    ElseIf ( nTipo == 9 ) /* Missing */          
    	
    	cTxt := QRY->DOC
       	cTxt += ';'
       	cTxt += ';'
       	cTxt += ';'
       	cTxt += ';'
       	cTxt += ';'
       	cTxt += ';'
       	cTxt += ';'
       	cTxt += ';'
       	cTxt += ';'
       	cTxt += ';'
       	cTxt += ';'
       	cTxt += '* C O N S U L T E  O  S I S T E M A *'
 
    EndIf

		cTxt += cCRLF      
       
    	nLen := Len( cTxt )
       
    	fWrite( nHnd, cTxt, nLen )

Return (.T.)


/*BEGINDOC
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifique se a nota se refere a ume nota de entrada (Devolu็ao)ณ
//ณou foi cancelada                                               ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
ENDDOC*/

Static Function CanDev(nStart,nCount)

Local lFound := .F.

For i := 0 To nCount - 1

    cNota := StrZero( nStart + i, 6 )
    
    QRYENT->( DbGoTop() )
    
    While ! QRYENT->( EOF() )
    
    	lFound := .F.
    	
    	If ( cNota == QRYENT->DOC )
        
    		If (QRYENT->TIPO == 'D')  /* DEV CLIENTE*/
    		
    			WriteNota(4)
    	
    		ElseIf QRYENT->TIPO == 'N' /* ENTRADA NORMAL */
    	
    			If QRYENT->ESTADO $ "EX" 
    				
    				WriteNota(7)
    			
    			EndIf
    	
    		EndIf

    		lFound := .T.
    		
    		Exit
    	
    	EndIf  
    
    	QRYENT->( DbSkip() )
    
    EndDo
    
    If (! lFound )/*  Verifique se a nota esta cancelada na Entrada ou Saida */
    	
    	If ( IsCancel(cNota) )
    	
    		WriteNota (5)  // Cancelada //
    	
    	Else
    	
    		WriteNota (6)  // Missing   //
    	
    	EndIf
    	    	
    EndIf
    
Next  

Return()

Static Function IsCancel (cNota)
	
Local lRet := .F.
Local cQryE, cQryS

cQryE := " SELECT DISTINCT SF1.F1_DOC CAN "
cQryE += " FROM " + RetSqlName("SF1") + " SF1 " 
cQryE += " WHERE SF1.F1_DTDIGIT BETWEEN '" + dIni + "' AND '" + dFim + "' "  
cQryE += " AND SF1.F1_DOC = '" + cNota  + "' AND SF1.F1_SERIE = '" + MV_PAR03  + "' "
cQryE += " AND SF1.D_E_L_E_T_ = '*' " 
 
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryE),'QRYE',.F.,.T.)

cQryS := " SELECT DISTINCT SF2.F2_DOC CAN "
cQryS += " FROM " + RetSqlName("SF2") + " SF2 " 
cQryS += " WHERE SF2.F2_EMISSAO BETWEEN '" + dIni + "' AND '" + dFim + "' "  
cQryS += " AND SF2.F2_DOC = '" + cNota  + "' AND SF2.F2_SERIE = '" + MV_PAR03  + "' "
cQryS += " AND SF2.D_E_L_E_T_ = '*' " 
 
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryS),'QRYS',.F.,.T.)


If ( VAL (QRYE->CAN) <> 0 .OR. VAL (QRYS->CAN) <> 0 )
	
	lRet := .T.
	  
EndIf

QRYS->( dbCloseArea() )
QRYE->( dbCloseArea() )

Return (lRet)


// NOTA  PARC CLIENTE                 VALOR    EMISSAO   VENCTO PORT    ICMS    BAIXAS      OBESERVACAO            NATUREZA
