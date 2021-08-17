#INCLUDE "rwmake.ch" 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FAT003     º Autor ³ WAR               º Data ³  28/10/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Codigo gerado pelo AP8 IDE.                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function FAT003
//ProcRegua( (cArq)->( LastRec() ) )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := "de acordo com os parametros informados pelo usuario."
Local cDesc3         := "Titulo"
Local cPict          := ""
Local imprime        := .T.
Local aOrd := {}
Private Titulo 	     := "Faturamento Vendedor/Cliente/Mes"
Private lEnd         := .F.
Private lAbortPrint  := .F.
Private CbTxt        := ""
Private limite       := 220
Private tamanho      := "G"
Private nomeprog     := "FAT003" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo        := 15
Private aReturn      := { "Zebrado", 1, "Administracao", 1, 2, 1, "", 1}
Private nLastKey     := 0
Private cPerg        := PadR("FAT003",10)
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01
Private wnrel        := "FAT003" // Coloque aqui o nome do arquivo usado para impressao em disco
Private nLi          := 0
Private cString 	 := "SA3"

dbSelectArea("SA3")
dbSetOrder(1)

pergunte(cPerg,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a interface padrao com o usuario...                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
   Return
Endif

nTipo := If(aReturn[4]==1,15,18)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

RptStatus({|| RptDetail() })
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³RUNREPORT º Autor ³ AP6 IDE            º Data ³  28/10/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS º±±
±±º          ³ monta a janela com a regua de processamento.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RptDetail() 

Local cCabec1   := ""
Local cCabec2   := ""
Local nOrdem
Local cQryFat
Local cQryDev
Local cDateIni 	:= DtoS(mv_par01) 
Local cDateFim 	:= DtoS(mv_par02)
Local nRegua 	:= 0
Local cCodCli   := '' 
Local cCodVend  := ''
Local aPeriod   := {} //Header of realtorio
Local nMonths   := 0
Local dYear     := Year(mv_par01)
Local dMonth    := Month(mv_par01)
Local aMonthExt := {'JAN','FEV','MAR','ABR','MAI','JUN',;
					'JUL','AGO','SET','OUT','NOV','DEZ'}
Local aVendas   := {}
Local aClientes := {}
Local aDev      := {}
Local nMes
Local nMax      := 58
Local aTotVend  := {} // Total de venda do vendedor por mes
Local nTotCli   := 0  // Total de vendo do vendedor por cliente
Local nTotVend  := 0  // Total do Vendedor
Local nCol      := 0
Local nColTmp   := 0
Local cbText	:= SPACE(34)
Local cString01 := "TOTAL VENDEDOR : " 
Local cString02 := " ====> "	 
Local cString03 := "Subtotal Vendedor "
Local cString04 := "CLIENTE" 
Local cString05 := "Tot. Cliente"


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01             // Data Inicial                         ³
//³ mv_par02             // Data Final                           ³
//³ mv_par03             // Produto Inicial                      ³
//³ mv_par04             // Produto Final                        ³
//³ mv_par05             // Cliente Inicial                      ³ 
//³ mv_par06             // Cliente Final                        ³
//³ mv_par07             // Vendedor Inicial                     ³
//³ mv_par08             // Vendedor Final                       ³ 
//³ mv_par09             // Vendedor/Supervisor                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//³                                                                     ³

// # of meses between data inicial e final
nMonths	:= 1 + ((Year(mv_par02)*12) + Month(mv_par02)) - ((Year(mv_par01)*12) + Month(mv_par01))

If nMonths <= 0
	MsgInfo('Data final nao pode ser menor da data inicial!')
	Return()
ElseIf nMonths > 12 
	MsgInfo('Periodo nao pode ser superior a 12 meses!')
    Return()
EndIf

For i := 1 to If(nMonths > 1, nMonths, 1)	// Seguranca contra datas finais menores que datas iniciais
	aAdd(aPeriod, aMonthExt[dMonth] + '/' + StrZero(dYear,4,0) )
	aAdd(aTotVend, {StrZero(dYear,4,0) + '/' + StrZero(dMonth,2,0),0})
	dMonth++ 
	If dMonth > 12
		dYear++
		dMonth := 1
	EndIf
next

// Monta Cabec1 do Relatorio
cCabec1 := cString04 + Space(32)

For i := 1 to nMonths
	cCabec1 += aPeriod[i]
	cCabec1 += space(5) 
next

cCabec1 += cString05

FAT003Linha(@nLi,1+nMax,nMax,Titulo,cCabec1,cCabec2,NomeProg,Tamanho)
//SetRegua(550)

// Query Faturamento 
cQryFat := " SELECT D2_CLIENTE + '/' + D2_LOJA As Cliente,A1_NREDUZ AS CNome, "
cQryFat += " SUM(D2_TOTAL) As Vendas, F2_VEND1 AS Vend,A3_NREDUZ AS VNome, " 
cQryFat += " A3_SUPER AS Super,dbo.udf_GetSuper(F2_VEND1) AS SNome, "  
cQryFat += " SUBSTRING (D2_EMISSAO,1,4) + '/' + SUBSTRING (D2_EMISSAO,5,2) AS DateVend, "
cQryFat += " A1_TABELA AS Tabela "  
cQryFat += " FROM SD2010 INNER JOIN SF2010 ON D2_DOC = F2_DOC AND F2_SERIE = D2_SERIE "  
cQryFat += " AND F2_CLIENTE = D2_CLIENTE  AND D2_LOJA= F2_LOJA AND D2_FILIAL = F2_FILIAL  "  
cQryFat += " INNER JOIN SA3010 ON F2_VEND1 = A3_COD "  
cQryFat += " INNER JOIN SA1010 ON A1_COD = F2_CLIENTE AND A1_LOJA = F2_LOJA  "
cQryFat += " WHERE  SD2010.D2_TES IN ('501','623','624','625','626','627','628','900') " 
cQryFat += " AND D2_COD BETWEEN '" + Substr( MV_PAR03, 1, 5 ) + "' AND '" + Substr( MV_PAR04, 1, 5 ) + "' " 
cQryFat += " AND F2_VEND1 BETWEEN '" + GetMv("MV_PAR08") + "' AND '" + GetMv("MV_PAR09") + "' "
/*
If MV_PAR09 == 2 // Por Supervisor 
	cQryFat += " AND A3_SUPER BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "' " 
Else			// Por Supervisor 
	cQryFat += " AND F2_VEND1 BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "' "
EndIf
*/


If MV_PAR07 == 2 /* Por Supervisor */ 
	cQryFat += " AND A3_SUPER = '" + MV_PAR10 + "' "  
EndIf

cQryFat += " AND D2_TIPO = 'N' "  
cQryFat += " AND A1_COD BETWEEN '" + Substr( MV_PAR05, 1, 5 ) + "' AND '" + Substr( MV_PAR06, 1, 5 ) + "' "  
cQryFat += " AND F2_EMISSAO BETWEEN '" + cDateIni + "' AND '" + cDateFim + "' "
cQryFat += " AND SF2010.D_E_L_E_T_ = ' ' "  
cQryFat += " AND SD2010.D_E_L_E_T_ = ' ' " 
cQryFat += " AND SA3010.D_E_L_E_T_ = ' ' "
cQryFat += " AND SA1010.D_E_L_E_T_ = ' ' "  
cQryFat += " GROUP BY D2_CLIENTE + '/' + D2_LOJA, "  
cQryFat += " SUBSTRING (D2_EMISSAO,1,4) + '/' + SUBSTRING (D2_EMISSAO,5,2), " 
cQryFat += " F2_VEND1,A3_SUPER,A3_NREDUZ,A1_TABELA,A1_NREDUZ "    
cQryFat += " ORDER BY "
If MV_PAR07 == 2 /* Por Supervisor */ 
	cQryFat += " A3_SUPER, F2_VEND1, "
Else			/* Vendeodr */ 
	cQryFat += " F2_VEND1, A3_SUPER,  "
EndIf
cQryFat += " D2_CLIENTE + '/' + D2_LOJA, "
cQryFat += " SUBSTRING (D2_EMISSAO,1,4) + '/' + SUBSTRING (D2_EMISSAO,5,2) "    

dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQryFat), 'QryFat' )

// Count the number of records
While !Eof()
	QryFat->( dbSkip() )
   	nRegua++
EndDo

SetRegua(nRegua)

QryFat->(dbGoTop())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

IncRegua()

dbSelectArea("SA3")
dbSetOrder(1)
SA3->( dbSeek( xFilial('SA3') + MV_PAR08, .T. ) )

dbSelectArea("SA1")
dbSetOrder(1)


While !SA3->(Eof()) .And. SA3->A3_COD <= MV_PAR09 
	
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Verifica o cancelamento pelo usuario...                             ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If lAbortPrint
    	@nLi,00 PSAY "*** CANCELADO PELO OPERADOR ***"
      	Exit
   	Endif
   
   	If MV_PAR12 == 1 /*INCLUIR DEVOLUÇOES*/
   		cQryDev := " SELECT D1_FORNECE + '/' + D1_LOJA AS Cliente, "
		cQryDev += " SUM(D1_TOTAL) As DEV,F2_VEND1 AS Vend, "
		cQryDev += " SUBSTRING (D1_DTDIGIT,1,4) + '/' + SUBSTRING (D1_DTDIGIT,5,2) as DtDigit " 
		cQryDev += " FROM SD1010 INNER JOIN SF1010 ON D1_DOC = F1_DOC AND F1_SERIE = D1_SERIE " 
		cQryDev += " AND F1_FORNECE = D1_FORNECE "
		cQryDev += " AND D1_LOJA = F1_LOJA AND D1_FILIAL = F1_FILIAL "
		cQryDev += " INNER JOIN SF2010 ON F2_DOC = D1_NFORI AND F2_SERIE = D1_SERIORI " 
		cQryDev += " AND F2_CLIENTE = F1_FORNECE "
		cQryDev += " AND F2_LOJA = F1_LOJA AND F2_FILIAL = F1_FILIAL "   
		cQryDev += " INNER JOIN SA3010 ON F2_VEND1 = A3_COD "
		cQryDev += " WHERE " 
		cQryDev += " D1_COD BETWEEN '" + Substr( MV_PAR03, 1, 5 ) + "' AND '" + Substr( MV_PAR04, 1, 5 ) + "' "
		cQryDev += " AND D1_TIPO = 'D' "
		cQryDev += " AND D1_FORNECE BETWEEN '" + Substr( MV_PAR05, 1, 5 ) + "' AND '" + Substr( MV_PAR06, 1, 5 ) + "' "
		cQryDev += " AND F2_VEND1 BETWEEN '" + SA3->A3_COD + "' AND '" + SA3->A3_COD + "' "
		If MV_PAR07 == 2 /* Por Supervisor */ 
			cQryDev += " AND A3_SUPER = '" + MV_PAR10 + "' "
		EndIf
		cQryDev += " AND D1_DTDIGIT BETWEEN '" + cDateIni + "' AND '" + cDateFim + "' "
		cQryDev += " AND SD1010.D_E_L_E_T_ = ' '  "
		cQryDev += " AND SF1010.D_E_L_E_T_ = ' '  "
		cQryDev += " AND SF2010.D_E_L_E_T_ = ' '  "
		cQryDev += " AND SA3010.D_E_L_E_T_ = ' ' "
		cQryDev += " GROUP BY D1_FORNECE + '/' + D1_LOJA, "
		cQryDev += " SUBSTRING (D1_DTDIGIT,1,4) + '/' + SUBSTRING (D1_DTDIGIT,5,2) "
		cQryDev += " ,F2_VEND1 "
		cQryDev += " ORDER BY "
		cQryDev += " F2_VEND1, "
		cQryDev += " D1_FORNECE + '/' + D1_LOJA, "
		cQryDev += " SUBSTRING (D1_DTDIGIT,1,4) + '/' + SUBSTRING (D1_DTDIGIT,5,2) "
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQryDev), 'QryDev' )
	EndIf
	   
   If QryFat->Vend == SA3->A3_COD   
   		FAT003Linha(@nLi,1,nMax,Titulo,cCabec1,cCabec2,NomeProg,Tamanho)
   		@ nLi,000 PSAY "VENDEDOR : " + SA3->A3_COD + " " + Upper(SA3->A3_NREDUZ)
   		// Print a blank line
   		FAT003Linha(@nLi,1,nMax,Titulo,cCabec1,cCabec2,NomeProg,Tamanho)
   		
   		nTotVend := 0
   		
   		// Zera o valor de venda
		For i = 1 To nMonths
   	    	aTotVend[i][2] := 0 	
    	Next
   		
   		aClientes 	:= {}   		
   		cCodVend := QryFat->Vend 
   		   		   		  		
   		While cCodVend == QryFat->Vend 
			dYear   	:= Year(mv_par01)
			dMonth		:= Month(mv_par01)
   		    aVendas		:= {} 
			
			SA1->(dbSeek(xFilial('SA1') + Substr(QryFat->Cliente,1,6)+Substr(QryFat->Cliente,8,2) ,.T.))
   		    For i := 1 to nMonths
				aAdd(aVendas, {StrZero(dYear,4,0) + '/' + StrZero(dMonth,2,0),0})
				dMonth++ 
				If dMonth > 12
					dYear++
					dMonth := 1
				EndIf
			Next
   		    /* Vendas por periodo para o Cliente*/
   		    While QryFat->Cliente == SA1->A1_COD + '/' + SA1->A1_LOJA  
   				nCodCli := QryFat->Cliente 
   				nPos := aScan( aVendas, { |x| x[1] == QryFat->DateVend })
        		If nPos != 0 
        			aVendas[nPos][2] := QryFat->Vendas 
        		EndIf
   				QryFat->(dbSkip())
   				IncRegua()
   			EndDo
   			
   			/* Devoluçoes do Cliente no periodo caso o Cliente comprou material no periodo */   			
   			//QryDev->(dbGoTop())
   			
   			If MV_PAR12 == 1 /*INCLUIR DEVOLUÇOES*/
								     				
   				While !QryDev->(Eof()) .And. QryDev->Vend <= SA3->A3_COD 
   				
   					If QryDev->Vend == SA3->A3_COD
   					
   						If QryDev->Cliente == SA1->A1_COD + '/' + SA1->A1_LOJA  
   							While QryDev->Cliente == SA1->A1_COD + '/' + SA1->A1_LOJA  
   								nPos := aScan( aVendas, { |x| x[1] == QryDev->DtDigit })
        						If nPos != 0 
        							aVendas[nPos][2] -= QryDev->DEV 
        						EndIf
									        				
        						nPos := aScan( aClientes, { |x| x == SA1->A1_COD + '/' + SA1->A1_LOJA })
   								If nPos == 0 
        							aAdd(aClientes, SA1->A1_COD + '/' + SA1->A1_LOJA)		 
        						EndIf
                            	IncRegua()
   								QryDev->(dbSkip())
							EndDo
						Else
							QryDev->(dbSkip())
						EndIf
   					Else	
   						QryDev->(dbSkip())
   			    	EndIf
   			
   					IncRegua()
   				EndDo  /* QryDev */
   			EndIf
   			FAT003Linha(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
   			nCol := 0
   			@ nLi, nCol PSAY SA1->A1_COD + '/' + SA1->A1_LOJA + " "  + SA1->A1_NREDUZ
   			nCol := 30
   			@ nLi, nCol PSAY " " + SA1->A1_TABELA + " "
   			nCol += 5
   			nColTmp := nCol 
   			nTotCli := 0
   			
   			For i = 1 To nMonths
   	    		@ nLi, nCol PSAY aVendas[i][2] Picture '@E) 9,999,999.99'
    			nCol += 13
    			nTotCli        += aVendas[i][2] // Total do Cliente per Periodo
    			aTotVend[i][2] += aVendas[i][2]      
			Next
        	
        	nCol += 2
        	@ nLi, nCol PSAY nTotCli Picture '@E) 999,999,999.99'	   	   	
   		IncRegua()
   		EndDo  // Vendedor Fat 		
   
   		If MV_PAR12 == 1 /*INCLUIR DEVOLUÇOES*/
			
			QryDev->(dbGoTop()) /* Devoluçoes do Cliente no periodo sem vendas */
		
			While !QryDev->(Eof()) .And. QryDev->Vend <= SA3->A3_COD 
			
				If QryDev->Vend == SA3->A3_COD 
			
					nPos := aScan( aClientes, { |x| x == QryDev->Cliente })
			
					If nPos == 0 // did not find it--> Add to result
						dYear   := Year(mv_par01)
						dMonth	:= Month(mv_par01)
    					aVendas	:= {} 
						SA1->(dbSeek(xFilial('SA1') + Substr(QryDev->Cliente,1,6)+Substr(QryDev->Cliente,8,2) ,.T.))
    
    					For i := 1 to nMonths
							aAdd(aVendas, {StrZero(dYear,4,0) + '/' + StrZero(dMonth,2,0),0}   )
							dMonth++ 
							If dMonth > 12
								dYear++
								dMonth := 1
							EndIf
						next
				
						While QryDev->Cliente == SA1->A1_COD + '/' + SA1->A1_LOJA
							nPos := aScan( aVendas, { |x| x[1] == QryDev->DtDigit })
        					If nPos != 0 
        						aVendas[nPos][2] -= QryDev->DEV 
        					EndIf
   							QryDev->(dbSkip())
							IncRegua()
						EndDo
				
						FAT003Linha(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
   						nCol := 0
   						@ nLi, nCol PSAY SA1->A1_COD + '/' + SA1->A1_LOJA + " "  + SA1->A1_NREDUZ
   						nCol := 30
   						@ nLi, nCol PSAY " " + SA1->A1_TABELA + " "
   						nCol += 5
   						nTotCli := 0
   				
   						For i = 1 To nMonths
   							@ nLi, nCol PSAY aVendas[i][2] Picture '@E) 9,999,999.99'
    						nCol += 13
    						nTotCli        += aVendas[i][2] // Total do Cliente per Periodo      
							aTotVend[i][2] += aVendas[i][2]
						Next
				
						nCol += 2
						@ nLi, nCol PSAY nTotCli Picture '@E) 999,999,999.99'   	

					Else  /* npos */
						QryDev->(dbSkip())
					EndIf
		    	Else
		    		QryDev->(dbSkip())
		    	EndIf
				IncRegua()
			EndDo  /* FatDev vendedor */
		
		EndIf
		
		FAT003Linha(@nLi,1,nMax,Titulo,cCabec1,cCabec2,NomeProg,Tamanho) 
   		@ nLi,000 PSAY cString03 + cString02 + space(10)
   		nCol := len(cbText) + 1
   		For i = 1 To nMonths
   			@ nLi,nCol PSAY aTotVend[i][2] Picture '@E) 9,999,999.99'
    		nCol += 13
    		nTotVend += aTotVend[i][2] //Total do vendedor 
    	Next
    	
    	//Total do vendedor
		FAT003Linha(@nLi,1,nMax,Titulo,cCabec1,cCabec2,NomeProg,Tamanho)
		nCol := nColTmp - 2
		@ nLi,000 PSAY cString01 + SA3->A3_COD + cString02 
		@ nLi,nCol PSAY nTotVend Picture '@E) 999,999,999.99'
        
        // ULTIMO VENDEDOR ---> Nao imprime new page e thin line 
        If  SA3->A3_COD < MV_PAR09
   			FAT003Linha(@nLi,1,nMax,Titulo,cCabec1,cCabec2,NomeProg,Tamanho)
   			@ nLi,000 PSay __PrtThinLine()
   		EndIf
   		//FAT003Linha(@nLi,1,nMax,Titulo,cCabec1,cCabec2,NomeProg,Tamanho)
   		// Salta Pagina por Vendedor exceto quando e o ultimo vendedor
   		/*
   		If MV_PAR10 == 1 .And. QryFat->(!EOF())
   			FAT003Linha(@nLi,1+nMax,nMax,Titulo,cCabec1,cCabec2,NomeProg,Tamanho)
   		EndIf 
   		*/ 
   Else
		If MV_PAR12 == 1 /*INCLUIR DEVOLUÇOES*/
			
			If QryDev->Vend == SA3->A3_COD   
   				FAT003Linha(@nLi,1,nMax,Titulo,cCabec1,cCabec2,NomeProg,Tamanho)
   				@ nLi,000 PSAY "VENDEDOR : " + SA3->A3_COD + " " + Upper(SA3->A3_NREDUZ)
   				// Print a blank line
   				FAT003Linha(@nLi,1,nMax,Titulo,cCabec1,cCabec2,NomeProg,Tamanho)
   		
   				nTotVend := 0
   		
   				// Zera o valor de venda
				For i = 1 To nMonths
   	    			aTotVend[i][2] := 0 	
    			Next
			
			
				While !QryDev->(EOF())
		    		dYear   	:= Year(mv_par01)
					dMonth		:= Month(mv_par01)
		        	aDev        := {}
		        
					SA1->(dbSeek(xFilial('SA1') + Substr(QryDev->Cliente,1,6)+Substr(QryDev->Cliente,8,2) ,.T.))
				
					For i := 1 to nMonths
						aAdd(aDev, {StrZero(dYear,4,0) + '/' + StrZero(dMonth,2,0),0})
						dMonth++ 
						If dMonth > 12
							dYear++
							dMonth := 1
						EndIf
					Next
                
					If QryDev->Cliente == SA1->A1_COD + '/' + SA1->A1_LOJA  
   						While QryDev->Cliente == SA1->A1_COD + '/' + SA1->A1_LOJA  
   							nPos := aScan( aDev, { |x| x[1] == QryDev->DtDigit })
        					If nPos != 0 
        						aDev[nPos][2] -= QryDev->DEV 
        					EndIf
									        				
        					IncRegua()
   							QryDev->(dbSkip())
						EndDo
					Else
						QryDev->(dbSkip())
					EndIf
			
					IncRegua()
				
					FAT003Linha(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
   					nCol := 0
   					@ nLi, nCol PSAY SA1->A1_COD + '/' + SA1->A1_LOJA + " "  + SA1->A1_NREDUZ
   					nCol := 30
   					@ nLi, nCol PSAY " " + SA1->A1_TABELA + " "
   					nCol += 5
   					nColTmp := nCol 
   					nTotCli := 0
   			
   					For i = 1 To nMonths
   	    				@ nLi, nCol PSAY aDev[i][2] Picture '@E) 9,999,999.99'
    					nCol += 13
    					nTotCli        += aDev[i][2] // Total do Cliente per Periodo
    					aTotVend[i][2] += aDev[i][2]      
					Next
        	
        			nCol += 2
        			@ nLi, nCol PSAY nTotCli Picture '@E) 999,999,999.99'	   	   	
    			
				EndDo
				
				FAT003Linha(@nLi,1,nMax,Titulo,cCabec1,cCabec2,NomeProg,Tamanho) 
		   		@ nLi,000 PSAY cString03 + cString02 + space(10)
   				nCol := len(cbText) + 1
   				For i = 1 To nMonths
   					@ nLi,nCol PSAY aTotVend[i][2] Picture '@E) 9,999,999.99'
    				nCol += 13
    				nTotVend += aTotVend[i][2] //Total do vendedor 
    			Next
    	
    			//Total do vendedor
				FAT003Linha(@nLi,1,nMax,Titulo,cCabec1,cCabec2,NomeProg,Tamanho)
				nCol := nColTmp - 2
				@ nLi,000 PSAY cString01 + SA3->A3_COD + cString02 
				@ nLi,nCol PSAY nTotVend Picture '@E) 999,999,999.99'
				If  SA3->A3_COD < MV_PAR09
	   				FAT003Linha(@nLi,1,nMax,Titulo,cCabec1,cCabec2,NomeProg,Tamanho)
   					@ nLi,000 PSay __PrtThinLine()
   				EndIf
			EndIf
		EndIf   		
   EndIf
   IncRegua()  
   SA3->(dbSkip()) // Avanca o ponteiro do registro no arquivo
	
	If MV_PAR12 == 1 /*INCLUIR DEVOLUÇOES*/
		QryDev->(dbCloseArea())
	EndIf	

EndDo


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Finaliza a execucao do relatorio...                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SET DEVICE TO SCREEN

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se impressao em disco, chama o gerenciador de impressao...          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If aReturn[5]==1
   dbCommitAll()
   SET PRINTER TO
   OurSpool(wnrel)
Endif

QryFat->(dbCloseArea()) 

MS_FLUSH()

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FAT003Linha ºAutor  ³                  º Data ³  05/11/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³   Incrementa o contador de linhas para impressão nos relatoº±±
±±º          ³rios e verifica se uma nova pagina sera iniciada.           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ nLi      - Numero da linha em que sera impresso            º±±
±±º          ³ nInc     - Quantidade de linhas a serem incrementadas      º±±
±±º          ³ nMax     - Numero maximo de linhas por pagina              º±±
±±º          ³ Titulo   - Titulo do cabecalho do relatorio                º±±
±±º          ³ cCabec1  - Primeira linha do lalbel do relatorio           º±±
±±º          ³ cCabec2  - Segunda linha do label do relatorio             º±±
±±º          ³ NomeProg - Nome do programa que sera impresso no cabecalho º±±
±±º          ³ Tamanho  - Tamanho de colunas do relatorio                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ 				                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FAT003Linha(	nLi,		nInc,		nMax,		titulo,;
					cCabec1,	cCabec2,	nomeprog,	tamanho)

Local nChrComp	:= IIF(aReturn[4]==1,15,18)

nLi+=nInc
If nLi > nMax .or. nLi < 5
	nLi := Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nChrComp)
	nLi++
EndIf

Return(Nil)