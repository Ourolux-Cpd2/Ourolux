#INCLUDE "PROTHEUS.CH"
/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北谀哪哪哪哪哪哪履哪哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪哪哪目北
北?Fun噮o      ?SF1100I       ?Autor ?Marcos Gomes (TAGGS)     ?Data ? 22/06/2013  潮?
北媚哪哪哪哪哪哪拍哪哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪哪哪拇北
北?Descri噮o   ?Ponto de ENTRADA na Confirmacao da Nota Fiscal de Entrada.             潮?
北媚哪哪哪哪哪哪拍哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北?Uso         ?Clientes Protheus - OURO LUX                                           潮?
北媚哪哪哪哪哪哪拍哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪履哪哪哪哪哪拇北
北?Analista    ?Alteracao                                                 ?   Data    潮?
北媚哪哪哪哪哪哪拍哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拍哪哪哪哪哪拇北
北矼GOMES(TAGGS)?- Reestruturacao da rotina e insercao do tratamento de    ?23/07/2013 潮?
北?            ?  Comissao de Vendas.                                     ?23/07/2013 潮?
北滥哪哪哪哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪聊哪哪哪哪哪馁北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌
/*/
User Function SF1100I()

LOCAL _cAreaAtu := GETArea()
LOCAL _cAreaSE2 := SE2->(GETArea())
LOCAL _cArSE2 	:= SE2->(GETArea())
LOCAL _cAreaSF1 := SF1->(GETArea())
LOCAL _cAreaSE3 := SE3->(GETArea()) 
LOCAL _cAreaSA3 := SA3->(GETArea())

Local oMemo     := ''
Local _cKeySE3  := ""
Local cQuery	:= ""

LOCAL cDOCSF1	:= SF1->F1_DOC			// MGOMES 23/07/2013 - Numero do documento
LOCAL cSERSF1	:= SF1->F1_SERIE		// MGOMES 23/07/2013 - Serie do documento
LOCAL cFORSF1	:= SF1->F1_FORNECE		// MGOMES 23/07/2013 - Fornecedor
LOCAL cLOJSF1	:= SF1->F1_LOJA			// MGOMES 23/07/2013 - Loja
//LOCAL nValBrut	:= SF1->F1_VALBRUT		// MGOMES 23/07/2013 - Valor Bruto

LOCAL cTITPAI   := ""
LOCAL cQryUPD   := ""
LOCAL Xhy		:= 0
LOCAL cPedVez	:= ""
Local lPri		:= .T.

Local lAtvEIC     := SuperGetMV("ES_ATVEICD",.T.,.F.)

PRIVATE lGerPrDI 	:= IF(GetNewPar("MV_EASYFDI","S")="S",.T.,.F.)//ASR - 28/09/2005 - Integra玢o EIC x FIN
PRIVATE cControle	:= ""
PRIVATE nVlF1Total	:= SF1->F1_VALBRUT		// MGOMES 23/07/2013 - Valor Bruto

	If SF1->F1_TIPO == 'N' .And. ALLTRIM(SED->ED_CODIGO) $ GETMV("FS_SEDNAT")
		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
		//?Atualiza os dados do(s) titulo(s) a Pagar gerado(s) pela Comissao            ?
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
		If !EMPTY( len( aF4For ) )
			For Xhy := 1 to Len( aF4For )
				If aF4FOR[Xhy][1]										// Se estiver marcado, registra o recebimento 
					lFechou		:= .t.								// FLAG de fechamento da rotina
					lPendente	:= .F.								// FLAG que indica se ha ou nao pendencia no processo
	
					_cPrefixo	:= aF4For[Xhy][2]					// Prefixo do titulo gerado pela rotina de comissao
					_cNumero 	:= aF4For[Xhy][3]					// Numero do Titulo gerado pela rotina de comissao
					_cParcela	:= aF4For[Xhy][4]					// Parcela do Tiutlo gerado pela rotina de comissao
					_cTipo		:= aF4For[Xhy][5]					// TIPO do Tiutlo gerado pela rotina de comissao
					_cFornec	:= cForSF1							// Codigo do Fornecedor
					_cLjFor		:= cLojSF1							// Loja do Fornecedor

					//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
					//?(SE2) Posiciona o arquivo de CONTAS A PAGAR e Atualiza os flag's do Titulo			            ?
					//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
					DBSelectArea("SE2")
					DBSetOrder(1)
					If DBSeek( xFilial("SE2") + _cPrefixo + _cNumero + _cParcela + _cTipo + _cFornec + _cLjFor, .f. )
							
						DBSelectArea("SE2")
						RECLOCK( "SE2", .f. )
							SE2->E2_X_DTANF		:= dDataBase			// Marca a data de entrada da nota fisca
							SE2->E2_X_NUMNF		:= cDOCSF1				// Marca a NOTA DA ENTRADA
							SE2->E2_X_SERIE		:= cSERSF1				// Marca a SERIE DA ENTRADA
						MSUNLOCK()								
                                    
      					cTITPAI	:= PADR( SE2->( _cPrefixo + _cNumero + _cParcela + _cTipo + _cFornec + _cLjFor ), TAMSX3("E2_TITPAI")[1] )
												
						//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
						//| Query para gravar o FLAG no(s) titulo(s) de Impostos                        |
						//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?										
						cQryUPD	:= ""
						cQryUPD	+= " UPDATE " + RETSqlName("SE2") + " SET "
						cQryUPD	+= " E2_X_NUMNF = '" + cDOCSF1 + "', E2_X_DTANF = '" + DTOS( dDataBase ) + "' , E2_X_SERIE = + '" + cSERSF1 + "' "	
						cQryUPD	+= " WHERE 	E2_FILIAL = '" + xFilial("SE2") + "' "
						cQryUPD	+= "		AND E2_TITPAI = '" + cTITPAI + "' "
						cQryUPD	+= " 		AND D_E_L_E_T_ <> '*' "																						
																
						TCSQLExec( cQryUPD )

					EndIf
				EndIf
			Next Xhy
		EndIf
	EndIf	
		
	If SF1->F1_TIPO == 'N' .And. SF1->F1_formul == 'S'  // NFE normal com nosso formulario
			
		oMemo := GetDadosAds()
		
		If !Empty(oMemo)
			RecLock("SF1",.F.)
				SF1->F1_OBSNFE  := oMemo
			MsUnlock()
		EndIf
		
	EndIf
	
	// Claudino - 20/04/16    
	If SF1->F1_TIPO == 'D'
		
		If Alltrim(SF1->F1_MOTCANC) == "6003"
			If !Empty(_cAreaSE3)
				If SELECT("SE3") > 0
					SE3->(dbGoTo(_cAreaSE3[3]))
					RecLock("SE3",.F.)
					SE3->(dbDelete())
					SE3->(MsUnlock())
				EndIf
			EndIf
		Else

			If SELECT("SE3") > 0
				
				_cKeySE3 := SE3->E3_NUM+SE3->E3_SERIE+SE3->E3_CODCLI+SE3->E3_LOJA
				SE3->(DbSetOrder(1))
				
				If SE3->(MsSeek(xFilial("SE3")+SF1->F1_SERIE+SF1->F1_DOC))
					
					While !SE3->(Eof(	)) .And. SE3->E3_NUM+SE3->E3_SERIE+SE3->E3_CODCLI+SE3->E3_LOJA == _cKeySE3 ;
										.And. SE3->E3_ORIGEM == "D" ;
										.And. SE3->E3_BAIEMI == "E" ;
										.And. SE3->E3_TIPO == "NCC" 
					
						SA3->(DbSetOrder(1))
						If SA3->(MsSeek(xFilial("SA3")+SE3->E3_VEND))
							RecLock("SE3",.F.)
								SE3->E3_X_BLOQ := SA3->A3_X_BLOQ
							SE3->(MsUnLock())
						EndIf
						SE3->(DbSkip())
					EndDo
				
				EndIf
			
			EndIf
		EndIf
	EndIf

	If lAtvEIC
		conout("SF1100I - Rotina EIC - Ativada")
		conout("SF1100I - Pedido: " + Alltrim(SD1->D1_PEDIDO))
		
		cQuery := " SELECT D1_FILIAL,D1_DOC,D1_COD,D1_PEDIDO FROM " + RetSqlName("SD1")
		cQuery += " WHERE D1_FILIAL = '"+SD1->D1_FILIAL+"' "
		cQuery += " AND D1_DOC = '"+SD1->D1_DOC+"' "
		cQuery += " AND D1_SERIE = '"+SD1->D1_SERIE+"' "
		cQuery += " AND D1_FORNECE = '"+SD1->D1_FORNECE+"' "
		cQuery += " AND D1_LOJA = '"+SD1->D1_LOJA+"' "
		cQuery += " AND D1_PEDIDO <> '' "
		cQuery += " AND D_E_L_E_T_ = '' " 

		If Select("PEDEIC") > 0
			PEDEIC->(dbCloseArea())
		EndIf

		DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'PEDEIC', .T., .F.)
		
		If PEDEIC->(EOF())
			conout("SF1100I - Processo: " + Alltrim(SE2->E2_HAWBEIC) + " nao foi encontrado NF com pedido")
			ProcLogAtu("ERRO","SF1100I - Processo: " + Alltrim(SE2->E2_HAWBEIC) + " nao foi encontrado NF com pedido", "", "EICDESPESA" )
		EndIf

		While PEDEIC->(!EOF())
			If !Empty(PEDEIC->D1_PEDIDO)
				
				If cPedVez == PEDEIC->D1_PEDIDO
					PEDEIC->(dbSkip())
					Loop
				Else
					cPedVez := PEDEIC->D1_PEDIDO
				EndIf

				If GetAdvFVal("SC7","C7_ORIGEM",PEDEIC->D1_FILIAL+PEDEIC->D1_PEDIDO,1) == "EICPO400" .AND. !Empty(GetAdvFVal("SC7","C7_XHAWB",PEDEIC->D1_FILIAL+PEDEIC->D1_PEDIDO,1))
					If lPri
						If SE2->E2_NUM == SF1->F1_DOC
							dbSelectArea("SYB")
							SYB->(dbSetOrder(1))
							SYB->(dbSeek(xFilial()+SubStr(Alltrim(GetAdvFVal("SB1","B1_COD",xFilial("SB1")+PEDEIC->D1_COD,1)),4,3)))
							
							RecLock("SE2",.F.)
							SE2->E2_HIST    := "Proc."+Alltrim(GetAdvFVal("SC7","C7_XHAWB",PEDEIC->D1_FILIAL+PEDEIC->D1_PEDIDO,1))+" -"+Alltrim(SYB->YB_DESCR)
							SE2->E2_HAWBEIC := Alltrim(GetAdvFVal("SC7","C7_XHAWB",PEDEIC->D1_FILIAL+PEDEIC->D1_PEDIDO,1))
							SE2->(MsUnlock())

							lPri := .F.
						Else
							conout("SF1100I - Numero do titulo diferente do numero da NF")
							conout("SF1100I - Titulo: " + Alltrim(SE2->E2_NUM))
							conout("SF1100I - NF: " + Alltrim(SF1->F1_DOC))
							ProcLogAtu("ERRO","SF1100I - Numero do titulo diferente do numero da NF", "Titulo: " + Alltrim(SE2->E2_NUM) + " NF: " + Alltrim(SF1->F1_DOC), "EICDESPESA" )
						EndIf
					EndIf
					
					dbSelectArea("SWD")
					
					cQuery := " SELECT R_E_C_N_O_ FROM " + RetSqlName("SWD")
					cQuery += " WHERE WD_FILIAL = '"+xFilial("SWD")+"' "
					cQuery += " AND WD_HAWB = '"+Alltrim(GetAdvFVal("SC7","C7_XHAWB",PEDEIC->D1_FILIAL+PEDEIC->D1_PEDIDO,1))+"' "
					cQuery += " AND WD_XPEDCOM = '"+PEDEIC->D1_PEDIDO+"' "
					cQuery += " AND WD_DESPESA = '"+SubStr(PEDEIC->D1_COD,4,3)+"' "
					cQuery += " AND D_E_L_E_T_ = '' "
					
					If Select("ATWD") > 0
						ATWD->(dbCloseArea())
					EndIf
					
					conout("SF1100I - Query busca despesa")
					conout(cQuery)

					DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'ATWD', .T., .F.)

					While ATWD->(!EOF())
						SWD->(dbGoTo(ATWD->R_E_C_N_O_))
						RecLock("SWD",.F.)
						SWD->WD_CTRFIN1 := SE2->E2_NUM
						SWD->WD_DOCTO 	:= SE2->E2_NUM
						SWD->WD_DTENVF	:= dDataBase
						SWD->WD_PREFIXO	:= SE2->E2_PREFIXO
						SWD->WD_TIPO	:= SE2->E2_TIPO
						SWD->WD_PARCELA := SE2->E2_PARCELA
						SWD->WD_DT_VENC := SE2->E2_VENCREA
						SWD->(MsUnlock())
						ATWD->(dbSkip())
					EndDo

					_cArSE2 := SE2->(GETArea())
					dbSelectArea("SW6")
					If SW6->(dbSeek(xFilial("SW6")+SE2->E2_HAWBEIC))
						conout("SF1100I - Verifica se tipo ?diferente de DIN")
						conout("SF1100I - Tipo: " + SW6->W6_TIPOFEC)
						If SW6->W6_TIPOFEC <> "DIN"
							conout("SF1100I - Deleta os PRE")
							DeleImpDesp(SW6->W6_NUMDUP,"PRE","DI",.T.)
						Else
							conout("SF1100I - Nao deletou os PRE")
							ProcLogAtu("ERRO","SF1100I - Nao deletou os PRE - Processo: " + SW6->W6_HAWB, "", "EICDESPESA" )
						EndIf
						
						If SubStr(PEDEIC->D1_COD,4,3) == "102" .AND. SubStr(PEDEIC->D1_COD,1,3) == "EIC"
							U_xdelPRE(SE2->E2_HAWBEIC)
						EndIf

						//EICFI400("POS_GRV_DESP")

						//axFl2DelWork:={}
						//If SW6->W6_TIPOFEC <> "DIN"
						//	conout("SF1100I - Inclus鉶 dos PRE")
						//	cControle := "Inclusao"
						//	Processa({|| AVPOS_DI(SW6->W6_HAWB,lGerPrDI,,.T.) })//ASR - 28/09/2005 - Integra玢o EIC x FIN - antes testa a MV_EASYFDI - Processa({|| AVPOS_DI(SW6->W6_HAWB,.T.) })
						//EndIf
						RESTArea( _cArSE2 )
					Else
						conout("SF1100I - Processo: " + Alltrim(SE2->E2_HAWBEIC) + " nao localizado")
						ProcLogAtu("ERRO","SF1100I - Processo: " + Alltrim(SE2->E2_HAWBEIC) + " nao localizado", "", "EICDESPESA" )
					EndIf	

				Else
					conout("SF1100I - Origem diferente de EICPO400")
					ProcLogAtu("ERRO","SF1100I - Origem diferente de EICPO400", "Filial: " + PEDEIC->D1_FILIAL + " Pedido: " + PEDEIC->D1_PEDIDO, "EICDESPESA" )
				EndIf
			Else
				conout("SF1100I - Pedido em branco")
				ProcLogAtu("ERRO","SF1100I - Pedido em branco", "Filial: " + PEDEIC->D1_FILIAL + " NF: " + PEDEIC->D1_DOC, "EICDESPESA" )
			EndIf
			PEDEIC->(dbSkip())
		EndDo
	EndIf	
		
	aF4For	:= {}			// Zera o conteudo do array aF4For()

RESTArea( _cAreaSA3 )		
RESTArea( _cAreaSE3 )		
RESTArea( _cAreaSE2 )
RESTArea( _cAreaSF1 )
RESTArea( _cAreaAtu )

Return()

/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北谀哪哪哪哪哪哪履哪哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪哪哪目北
北?Fun噮o      ?GetDadosAds   ?Autor ?                         ?Data ?   /  /      潮?
北媚哪哪哪哪哪哪拍哪哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪哪哪拇北
北?Descri噮o   ?Get de dados adicionais.                                               潮?
北滥哪哪哪哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌
/*/
Static Function GetDadosAds()

Local oDlg,oButton,oMemo,cMemo := space(50)
Local oFont:= TFont():New('Courier New',,-11,.T.)
Local oSay,cSay := ''

cSay := "Digite o texto para ser impresso no campo Dados Adicionais da NFE. "
cSay += "Pode ser digitado ate 8 linhas de 70 carateres cada."

oDlg := MSDialog():New(10,10,290,540,"Dados Adicionais NFE",,,,,CLR_BLACK,CLR_WHITE,,,.T.)

/* <oDlg> = MsDialog():New( <nTop>, <nLeft>, <nBottom>, <nRight>,;
  <cTitle>, <cResName>, <hResources>, <.vbx.>, <nStyle>,;
  <nClrText>, <nClrBack>, <oBrush>, <oWnd>, <.pixel.>,;
  <oIco>, <oFont> , <.status.> )
*/

oSay:= tSay():New(10,10,,oDlg,,,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)
   
oSay:SetText(cSay)
 
/*   TSay():New( <nRow>, <nCol>, <{cText}>,[<oWnd>], [<cPict>], <oFont>, <.lCenter.>, <.lRight.>, <.lBorder.>,;
     <.lPixel.>, <nClrText>, <nClrBack>, <nWidth>, <nHeight>,;
     <.design.>, <.update.>, <.lShaded.>, <.lBox.>, <.lRaised.> 
*/

//cBlKVld := "{|| .not. empty(cMemo)}"
//{|u|if(Pcount()>0,cMemo:=u,cMemo)}

cBlKVld := "{|| mlcount(cMemo,70) <= 8}"

oMemo := TMultiget():New(41,8,bSetGet(cMemo), oDlg,250,65,oFont,.F.,,,,.T.,,,,,,,,,,,.F.)

oMemo:lWordWrap:= .T.

//oMemo:EnableHScroll( .T. )
//oMemo:EnableVScroll( .T. )
/*   TMultiGet():New( 
     <nRow>, <nCol>, bSETGET(<uVar>),;
     <oWnd>, <nWidth>, <nHeight>, <oFont>, <.hscroll.>,;
     <nClrFore>, <nClrBack>, <oCursor>, <.pixel.>,;
     <cMsg>, <.update.>, <{uWhen}>, <.lCenter.>,;
     <.lRight.>, <.readonly.>, <{uValid}>,;
     [\{|nKey, nFlags, Self| <uChange>\}], <.lDesign.>,;
     [<.lNoBorder.>], [<.lNoVScroll.>] )                                 
*/

oButton := tButton():New(115,218,"Ok",oDlg,{||oDlg:End()},40,15,,,,.T.) 

/*
[ <oBtn> := ] TButton():New( <nRow>, <nCol>, <cCaption>, <oWnd>,;
    <{uAction}>, <nWidth>, <nHeight>, <nHelpId>, <oFont>, <.default.>,;
    <.pixel.>, <.design.>, <cMsg>, <.update.>, <{WhenFunc}>,;
    <{uValid}>, <.lCancel.> )

anRow 	Num閞ico, opcional. Coordenada vertical em pixels ou carateres. 
anCol 	Num閞ico, opcional. Coordenada horizontal em pixels ou caracteres. 


*/

// ativa di醠ogo centralizado
oDlg:Activate(,,,.T.,&(cBlkVld),,)

Return (cMemo)
