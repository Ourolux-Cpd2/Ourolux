/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MT103FIM  ºAutor  ³ELETROMEGA          º Data ³  02/11/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ O ponto de entrada MT103FIM encontra-se no final           º±±
±±º          ³ da função A103NFISCAL. Após o destravamento de             º±±
±±º          ³ todas as tabelas envolvidas na gravação do documento       º±±
±±º          ³ de entrada, depois de fechar a operação realizada neste,   º±±
±±º          ³ chamado após a gravação da NFE.                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 

#INCLUDE "PROTHEUS.CH"

User Function MT103FIM()

	Local 	nOpcao		:= PARAMIXB[1]      // Opção Escolhida pelo usuario no aRotina
	Local 	nConfirma 	:= PARAMIXB[2]      // Se o usuario confirmou a operação de gravação da NFE
	Local	cNome 		:= ""
	Local	cDesc 		:= ""
	Local   aAreaSD1  	:= SD1->(GetArea())
	Local   aAreaSA3    := SA3->(GetArea())
	Local   aAreaSF4  	:= SF4->(GetArea())
	Local   aAreaSF1  	:= SF1->(GetArea())
	Local   nCounter    := 0
	Local   cLote       := ''
	Local   cEmailVend  :=cEmailSuper:=cEmailGer:= ""
	Local 	oHTML,cLista:= space(10),cGeren := "",cSuper:= ""
	Local 	nPosCod,nPosDesc,nPosTes,nPosLocal,nLen
	Local 	nPosQtd,nPosTot,nPosAlmox,nPosSer,nPosNF
	Local   cQuery		:= ""
	Local   cCodVend    := ''
	Local   cNomVend    := ''
	Local   cCodSup     := ''
	Local   cNomSup     := ''
	Local   cCodGer     := ''
	Local   cNomGer     := ''
	Local   cDescSAG    := ''
	Local   cMotSAG     := ''
	Local	lAtvEIC     := SuperGetMV("ES_ATVEICD",.T.,.F.)
	
	Private cXclass		:= .F.
	
	If (nOpcao == 3 .And. nConfirma == 1) .Or.;
			(nOpcao == 4 .And. nConfirma == 1) 		 // Incluir/Classificar doc de entrada
		
		If FUNNAME() <> "EICDI154"
			If (SF1->F1_TIPO == 'N')
				oProcess:= TWFProcess():New("ENTREG","Recebimento de material")
				oProcess:NewTask("Inicio","\WORKFLOW\recebimento.htm")
				oProcess:cSubject := "Recebimento de Materiais: " + Alltrim(SM0->M0_NOME) + '/' +Alltrim(SM0->M0_FILIAL) // MOA - 25/04/2019 - Identificação de ambiente de testes
				oHtml := oProcess:oHTML
				oHTML:ValByName('DATA',dDataBase)
			
				SD1->(dbSetOrder(1))
				If SD1->( dbSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA, .T.))
					While SD1->D1_FILIAL  == xFilial("SD1")  .And.;
							SD1->D1_DOC     == SF1->F1_DOC     .And.;
							SD1->D1_SERIE   == SF1->F1_SERIE   .And.;
							SD1->D1_FORNECE == SF1->F1_FORNECE .And.;
							SD1->D1_LOJA    == SF1->F1_LOJA
	          		
						If SF4->(DbSeek(xFilial("SF4")+SD1->D1_TES))
							cXclass := .T. // Maurício Aureliano - 30/07/18 - Chamado: I1802-625
							If SF4->F4_ESTOQUE == 'S' .And. SF4->F4_WKFLOW == 'S'
								aAdd((oHTML:valByName( 'TB.Cod'  ) ), AllTrim(SD1->D1_COD))
								cDesc := GetAdvFVal("SB1","B1_DESC",xFilial("SB1")+SD1->D1_COD,1,"")
								aAdd( ( oHTML:valByName( 'TB.Desc' ) ), cDesc)
								aAdd((oHTML:valByName( 'TB.Doc' ) ), " ")
								aAdd((oHTML:valByName( 'TB.Almox' ) ), SD1->D1_LOCAL)
								aAdd((oHTML:valByName( 'TB.Qtd' ) ), " ")
								aAdd((oHTML:valByName( 'TB.Lote' ) ), SD1->D1_LOTECTL) // Alteração Claudino estava o campo D1_NUMLOTE - SUBLOTE agora esta o Lote.
								nCounter++
							EndIf
						EndIf
						SD1->(dbSkip())
					EndDo
					If nCounter != 0
						oProcess:cBCc := U_GrpEmail('WFENTRADA')+';'+U_GrpEmail('Vendas')+';'+U_GrpEmail('Contas')+';'+; //Retemails('WFENTRADA')+';'+Retemails('Vendas')+';'+Retemails('Contas')+';'+;
							U_GrpEmail('Repres')+';'+U_GrpEmail('Clientes')
						If !Empty(oProcess:cBCc)
							oProcess:Start()
							oProcess:Finish()
						EndIf
					EndIf
				EndIf
				// Enviar workflow para WFWDIR 
				oProcess:= TWFProcess():New("ENTREG","Recebimento de material")
				oProcess:NewTask("Inicio","\WORKFLOW\recebimento.htm")
				oProcess:cSubject := "Recebimento de Materiais: " + Alltrim(SM0->M0_NOME) + '/' +Alltrim(SM0->M0_FILIAL) // MOA - 25/04/2019 - Identificação de ambiente de testes
								
				oHtml := oProcess:oHTML
				oHTML:ValByName('DATA',dDataBase)
				nCounter := 0
				SD1->(dbSetOrder(1))
				If SD1->(dbSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA, .T.))
					While SD1->D1_FILIAL  == xFilial("SD1")  .And.;
							SD1->D1_DOC     == SF1->F1_DOC     .And.;
							SD1->D1_SERIE   == SF1->F1_SERIE   .And.;
							SD1->D1_FORNECE == SF1->F1_FORNECE .And.;
							SD1->D1_LOJA    == SF1->F1_LOJA
	          		
						If SF4->(DbSeek(xFilial("SF4")+SD1->D1_TES))
							cXclass := .T. // Maurício Aureliano - 30/07/18 - Chamado: I1802-625
							If SF4->F4_ESTOQUE == 'S' .And. SF4->F4_WKFLOW == 'S'
								aAdd((oHTML:valByName( 'TB.Cod'  ) ), AllTrim(SD1->D1_COD) )
								cDesc := GetAdvFVal("SB1","B1_DESC",xFilial("SB1")+SD1->D1_COD,1,"")
								aAdd((oHTML:valByName( 'TB.Desc' ) ), cDesc)
								aAdd((oHTML:valByName( 'TB.Doc' ) ), SD1->D1_DOC)
								aAdd((oHTML:valByName( 'TB.Almox' ) ), SD1->D1_LOCAL)
								aAdd((oHTML:valByName( 'TB.Qtd' ) ), SD1->D1_QUANT)
								aAdd((oHTML:valByName( 'TB.Lote' ) ), SD1->D1_LOTECTL) // Alteração Claudino estava o campo D1_NUMLOTE - SUBLOTE agora esta o Lote.
								nCounter++
							EndIf
						EndIf
						SD1->(dbSkip())
					EndDo
					If nCounter != 0
						oProcess:cBCc := U_GrpEmail('WFWDIR')
						If !Empty(oProcess:cBCc)
							oProcess:Start()
							oProcess:Finish()
						EndIf
					EndIf
				EndIf
			ElseIf (SF1->F1_TIPO == 'D')
				oProcess:= TWFProcess():New("Devol","Devolucao")
				oProcess:NewTask("Inicio","\WORKFLOW\devolucao.htm")
				oProcess:cSubject := "Devoluçao do Cliente: "  + Alltrim(SM0->M0_NOME) + '/' +Alltrim(SM0->M0_FILIAL)	// MOA - 25/04/2019 - Identificação de ambiente de testes
				oHtml := oProcess:oHTML
				oHTML:ValByName('DATA',dDataBase)
				oHTML:ValByName('DOC',SF1->F1_SERIE + ' / ' + SF1->F1_DOC)
				oHTML:ValByName('FORNECE',SF1->F1_FORNECE + ' / ' + SF1->F1_LOJA + ' - ' + SA1->A1_NOME)
				oHTML:ValByName('MOTIVO',GetMotivo())
				
				cDescSAG := Posicione("SAG",1,xFilial("SAG")+SF1->F1_MOTCANC,"AG_DESCPO") // Claudino 12/06/15
				cMotSAG := Alltrim(SF1->F1_MOTCANC) + " - " + Alltrim(cDescSAG) // Claudino 12/06/15
				
				oHTML:ValByName('MOTSAG', cMotSAG) // Claudino 12/06/15
				oHTML:ValByName('TOTAL', SF1->F1_VALBRUT)
					
				SD1->(dbSetOrder(1))
				If SD1->( dbSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA, .T.))
					While SD1->D1_FILIAL  == xFilial("SD1")  .And.;
							SD1->D1_DOC     == SF1->F1_DOC     .And.;
							SD1->D1_SERIE   == SF1->F1_SERIE   .And.;
							SD1->D1_FORNECE == SF1->F1_FORNECE .And.;
							SD1->D1_LOJA    == SF1->F1_LOJA
	           
						aAdd( ( oHTML:valByName( 'TB.Cod'  ) ), AllTrim(SD1->D1_COD))
						cDesc := GetAdvFVal("SB1","B1_DESC",xFilial("SB1")+SD1->D1_COD,1," ")
						aAdd( ( oHTML:valByName( 'TB.Desc' ) ), Rtrim(cDesc) )
						aAdd( ( oHTML:valByName( 'TB.Quant' ) ), SD1->D1_QUANT)
						aAdd( ( oHTML:valByName( 'TB.Almox' ) ), SD1->D1_LOCAL)
						aAdd( ( oHTML:valByName( 'TB.NFOri' ) ), AllTrim(SD1->D1_SERIORI);
							+ '/' + AllTrim(SD1->D1_NFORI))
									
						SD1->(dbSkip())
						nCounter++
					EndDo
			    
					// Get Email do vendedor/supervisor/gerente
					If (SA3->(dbSeek(xFilial("SA3") + SA1->A1_VEND, .F.))) .And. (nCounter != 0)
						cEmailVend := SA3->A3_EMAIL
						
						cCodVend := RTrim(GetAdvFVal("SA3","A3_COD",xFilial("SA3")+SA1->A1_VEND,1,""))
						cNomVend := RTrim(GetAdvFVal("SA3","A3_NOME",xFilial("SA3")+SA1->A1_VEND,1,""))
						oHTML:ValByName('VEND',cCodVend +" / "+ cNomVend)
					EndIf
					If !Empty(SA3->A3_SUPER)
						cEmailSuper := Alltrim(GetAdvFVal("SA3","A3_EMAIL",xFilial("SA3")+SA3->A3_SUPER,1,""))
			    	
						cCodSup := RTrim(GetAdvFVal("SA3","A3_SUPER",xFilial("SA3")+SA1->A1_VEND,1,""))
						cNomSup := RTrim(GetAdvFVal("SA3","A3_NOME",xFilial("SA3")+cCodSup,1,""))
						oHTML:ValByName('SUPERV',cCodSup +" / "+ cNomSup)
					EndIf
					If !Empty(SA3->A3_GEREN)
						cEmailGer := Alltrim(GetAdvFVal("SA3","A3_EMAIL",xFilial("SA3")+SA3->A3_GEREN,1,""))
			    	
						cCodGer := RTrim(GetAdvFVal("SA3","A3_GEREN",xFilial("SA3")+SA1->A1_VEND,1,""))
						cNomGer := RTrim(GetAdvFVal("SA3","A3_NOME",xFilial("SA3")+cCodGer,1,""))
						oHTML:ValByName('GEREN',cCodGer +" / "+ cNomGer)
					EndIf
					If !Empty(cEmailVend)
						cLista := cEmailVend
					EndIf
					If !Empty(cEmailSuper)
						cLista += ';' + cEmailSuper
					EndIf
					If !Empty(cEmailGer)
						cLista += ';' + cEmailGer
					EndIf
					oProcess:cBCc := cLista +';'+U_GrpEmail('Devolucao')
			
					If  !Empty(oProcess:cBCc)
						oProcess:Start()
						oProcess:Finish()
					EndIf
				EndIf
			EndIf
		Else
			If (SF1->F1_TIPO == 'N')
				oProcess:= TWFProcess():New("ENTREG","Recebimento de material")
				oProcess:NewTask("Inicio","\WORKFLOW\recebimento.htm")
				oProcess:cSubject := "Recebimento de Material no Controle de Qualidade: " + Alltrim(SM0->M0_NOME) + '/' +Alltrim(SM0->M0_FILIAL)				
				oHtml := oProcess:oHTML
				oHTML:ValByName('DATA',dDataBase)
				
				SD1->(dbSetOrder(1))
				If SD1->( dbSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA, .T.))
					While SD1->D1_FILIAL  == xFilial("SD1")  .And.;
							SD1->D1_DOC     == SF1->F1_DOC     .And.;
							SD1->D1_SERIE   == SF1->F1_SERIE   .And.;
							SD1->D1_FORNECE == SF1->F1_FORNECE .And.;
							SD1->D1_LOJA    == SF1->F1_LOJA
	          		
						If SF4->(DbSeek(xFilial("SF4")+SD1->D1_TES))
							If SF4->F4_ESTOQUE == 'S' .And. SF4->F4_WKFLOW == 'S'
								aAdd(( oHTML:valByName( 'TB.Cod'  ) ), AllTrim(SD1->D1_COD) )
								cDesc := GetAdvFVal("SB1","B1_DESC",xFilial("SB1")+SD1->D1_COD,1,"")
								cLote := GetAdvFVal("SWV","WV_LOTE",xFilial("SWV")+SD1->D1_CONHEC,1,"")
								aAdd(( oHTML:valByName( 'TB.Desc' ) ), cDesc)
								aAdd(( oHTML:valByName( 'TB.Doc' ) ), SD1->D1_DOC)
								aAdd(( oHTML:valByName( 'TB.Almox' ) ), SD1->D1_LOCAL)
								aAdd(( oHTML:valByName( 'TB.Qtd' ) ), SD1->D1_QUANT)
								aAdd(( oHTML:valByName( 'TB.Lote' ) ), cLote)
								nCounter++
							EndIf
						EndIf
						SD1->(dbSkip())
					EndDo
			
					If nCounter != 0
						oProcess:cBCc := U_GrpEmail('WFWCQ')
						If !Empty(oProcess:cBCc)
							oProcess:Start()
							oProcess:Finish()
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
	
	if nOpcao          == 3      .And. ; //inclusão
	   nConfirma       == 1      .And. ; //confirmado
	   SF1->F1_TIPO    == "D"    .And. ; //devolução
	   SF1->F1_ESPECIE == "SPED" .And. ; //não saiu
	   SF1->F1_FORMUL  == "S"    .And. ; //não saiu
	   SF1->F1_STATUS  == "A"            //classificado
		 
		GeraPR1()
	
	Endif 

	If lAtvEIC
		If  nOpcao == 5 .And. nConfirma == 1 .And. SubStr(SD1->D1_COD,1,3) == "EIC"
			cQuery := " SELECT R_E_C_N_O_ FROM " + RetSqlName("SWD")
			cQuery += " WHERE WD_FILIAL = '"+xFilial("SWD")+"' "
			cQuery += " AND WD_XPEDCOM = '"+SD1->D1_PEDIDO+"' "
			cQuery += " AND WD_DESPESA = '"+SubStr(SD1->D1_COD,4,3)+"' "
			cQuery += " AND D_E_L_E_T_ = '' "

			If Select("WXD") > 0
				WXD->(dbCloseArea())
			EndIf

			DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'WXD', .T., .F.)

			dbSelectArea("SWD")
		
			While WXD->(!EOF())
				SWD->(dbGoTo(WXD->R_E_C_N_O_))
					If Reclock("SWD",.F.)	
						SWD->WD_CTRFIN1 := ""
						SWD->WD_DOCTO 	:= ""
						SWD->WD_DTENVF	:= CTOD("  /  /    ")
						SWD->WD_PREFIXO	:= ""
						SWD->WD_TIPO	:= ""
						SWD->WD_PARCELA := ""
						SWD->WD_DT_VENC := CTOD("  /  /    ")
						SWD->(MsUnLock())
					EndIf
				WXD->(dbSkip())
			EndDo

		EndIf
	EndIf

	RestArea(aAreaSD1)
	RestArea(aAreaSF1)
	RestArea(aAreaSF4)
	RestArea(aAreaSA3)
	
Return()

// Get motivo de devoluçao digitado pelo usuario cadastrando a devoluçao
Static Function GetMotivo()

	Local oDlg,oButton,oMemo,cMemo := space(50)
		
	oDlg := MSDialog():New(10,10,180,400,"Motivo",,,,,CLR_BLACK,CLR_WHITE,,,.T.)
	cBlKVld := "{|| .not. empty(cMemo)}"
	oMemo := TMultiget():New(10,8,bSetGet(cMemo), oDlg,;
		180,50,,,,,,.T.,,,,,,,&(cBlkVld),,,,.F.)
	oButton := tButton():New(65,150,"Enviar",oDlg,{||oDlg:End()},40,15,,,,.T.)
	
	/* Ativa diálogo centralizado */
	oDlg:Activate(,,,.T.,&(cBlkVld),,)
	
Return (cMemo)


/*
// Chamado I1801-2534 WORKFLOW REFERENTE A DEVOLUÇÃO - MOA 22/02/2019 - 09:00hs
oProcess:= TWFProcess():New("Devol","Devolucaocli")
oProcess:NewTask("Inicio","\WORKFLOW\devolucaocli.htm")
oProcess:cSubject := " * * TESTE * *  Crédito sobre Devolução - Fornecedor: "  + Alltrim(SM0->M0_NOME) + '/' +Alltrim(SM0->M0_FILIAL)
oHtml := oProcess:oHTML
oHTML:ValByName('DATA',dDataBase)
oHTML:ValByName('DOC',SF1->F1_SERIE + '/' + SF1->F1_DOC)
oHTML:ValByName('FORNECE',SF1->F1_FORNECE + '/' + SF1->F1_LOJA + ' ' + SA1->A1_NOME)
oHTML:ValByName('MOTIVO',GetMotivo())
				
cDescSAG := Posicione("SAG",1,xFilial("SAG")+SF1->F1_MOTCANC,"AG_DESCPO") // Claudino 12/06/15
cMotSAG := Alltrim(SF1->F1_MOTCANC) + " - " + Alltrim(cDescSAG) // Claudino 12/06/15
				
oHTML:ValByName('MOTSAG', cMotSAG) // Claudino 12/06/15
oHTML:ValByName('TOTAL', SF1->F1_VALBRUT)
					
SD1->(dbSetOrder(1))
If SD1->( dbSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA, .T.))
	While SD1->D1_FILIAL  == xFilial("SD1")  .And.;
			SD1->D1_DOC     == SF1->F1_DOC     .And.;
			SD1->D1_SERIE   == SF1->F1_SERIE   .And.;
			SD1->D1_FORNECE == SF1->F1_FORNECE .And.;
			SD1->D1_LOJA    == SF1->F1_LOJA
	           
		aAdd( ( oHTML:valByName( 'TB.Cod'  ) ), AllTrim(SD1->D1_COD))
		cDesc := GetAdvFVal("SB1","B1_DESC",xFilial("SB1")+SD1->D1_COD,1," ")
		aAdd( ( oHTML:valByName( 'TB.Desc' ) ), Rtrim(cDesc) )
		aAdd( ( oHTML:valByName( 'TB.Quant' ) ), SD1->D1_QUANT)
		aAdd( ( oHTML:valByName( 'TB.Almox' ) ), SD1->D1_LOCAL)
		aAdd( ( oHTML:valByName( 'TB.NFOri' ) ), AllTrim(SD1->D1_SERIORI);
			+ '/' + AllTrim(SD1->D1_NFORI))
									
		SD1->(dbSkip())
		nCounter++
	EndDo
			    
					// Get Email do vendedor/supervisor/gerente
	If (SA3->(dbSeek(xFilial("SA3") + SA1->A1_VEND, .F.))) .And. (nCounter != 0)
		cEmailVend := SA3->A3_EMAIL
						
		cCodVend := RTrim(GetAdvFVal("SA3","A3_COD",xFilial("SA3")+SA1->A1_VEND,1,""))
		cNomVend := RTrim(GetAdvFVal("SA3","A3_NOME",xFilial("SA3")+SA1->A1_VEND,1,""))
		oHTML:ValByName('VEND',cCodVend +" / "+ cNomVend)
	EndIf
	If !Empty(SA3->A3_SUPER)
		cEmailSuper := Alltrim(GetAdvFVal("SA3","A3_EMAIL",xFilial("SA3")+SA3->A3_SUPER,1,""))
			    	
		cCodSup := RTrim(GetAdvFVal("SA3","A3_SUPER",xFilial("SA3")+SA1->A1_VEND,1,""))
		cNomSup := RTrim(GetAdvFVal("SA3","A3_NOME",xFilial("SA3")+cCodSup,1,""))
		oHTML:ValByName('SUPERV',cCodSup +" / "+ cNomSup)
	EndIf
	If !Empty(SA3->A3_GEREN)
		cEmailGer := Alltrim(GetAdvFVal("SA3","A3_EMAIL",xFilial("SA3")+SA3->A3_GEREN,1,""))
			    	
		cCodGer := RTrim(GetAdvFVal("SA3","A3_GEREN",xFilial("SA3")+SA1->A1_VEND,1,""))
		cNomGer := RTrim(GetAdvFVal("SA3","A3_NOME",xFilial("SA3")+cCodGer,1,""))
		oHTML:ValByName('GEREN',cCodGer +" / "+ cNomGer)
	EndIf
					
	If !Empty(cEmailVend)
		cLista := cEmailVend
	EndIf
	If !Empty(cEmailSuper)
		cLista += ';' + cEmailSuper
	EndIf
	If !Empty(cEmailGer)
		cLista += ';' + cEmailGer
	EndIf
					//oProcess:cBCc := cLista +';'+U_GrpEmail('Devolucao')
					//oProcess:cBCc := "coordvendas@ourolux.com.br;cpd3@ourolux.com.br"
	oProcess:cBCc := cLista
		
	If  !Empty(oProcess:cBCc)
		oProcess:Start()
		oProcess:Finish()
	EndIf
EndIf
*/

//--------------------------------------------------------------------
/*/{Protheus.doc} GeraPR1
Gera tabela PR1 para integração com a Transpofrete (cancelar pré nota)
@author Caio
@since 19/02/2020
@version 1.0 
@type function
/*/
//--------------------------------------------------------------------

Static Function GeraPR1()

Local aArea	   := GetArea() 

Local cQuery   := ""
Local cWa      := ""
Local cChave   := ""
 
	cQuery := CRLF + RTrim(" SELECT DISTINCT SD2.D2_FILIAL AS FILIAL                                                         ")
	cQuery += CRLF + RTrim("               , SD2.D2_PEDIDO AS PEDIDO                                                         ")
	cQuery += CRLF + RTrim("   FROM " + RetSqlName("SD1") + " SD1                                                            ")
	cQuery += CRLF + RTrim("  INNER JOIN " + RetSqlName("SD2") + " SD2 ON SD2.D2_FILIAL     = SD1.D1_FILIAL                  ")
	cQuery += CRLF + RTrim("                                          AND SD2.D2_DOC        = SD1.D1_NFORI                   ")
	cQuery += CRLF + RTrim("                                          AND SD2.D2_SERIE      = SD1.D1_SERIORI                 ")
	cQuery += CRLF + RTrim("                                          AND SD2.D2_CLIENTE    = SD1.D1_FORNECE                 ")
	cQuery += CRLF + RTrim("                                          AND SD2.D2_LOJA       = SD1.D1_LOJA                    ")
	cQuery += CRLF + RTrim("                                          AND SD2.D2_ITEM       = SD1.D1_ITEMORI                 ")
	cQuery += CRLF + RTrim("                                          AND SD2.D_E_L_E_T_    = ' '                            ")
	cQuery += CRLF + RTrim("  INNER JOIN " + RetSqlName("PR1") + " PR1 ON PR1.PR1_FILIAL    = ' '                            ")
	cQuery += CRLF + RTrim("                                          AND PR1.PR1_ALIAS     = 'SC5'                          ")
	cQuery += CRLF + RTrim("                                          AND PR1.PR1_CHAVE     = SD2.D2_FILIAL || SD2.D2_PEDIDO ")
	cQuery += CRLF + RTrim("                                          AND PR1.PR1_OBSERV   <> ' '                            ")
	cQuery += CRLF + RTrim("                                          AND PR1.D_E_L_E_T_    = ' '                            ")
	cQuery += CRLF + RTrim(" WHERE SD1.D1_FILIAL    = '" + SF1->F1_FILIAL        + "'                                        ")
	cQuery += CRLF + RTrim("   AND SD1.D1_DOC       = '" + SF1->F1_DOC           + "'                                        ")
	cQuery += CRLF + RTrim("   AND SD1.D1_SERIE     = '" + SF1->F1_SERIE         + "'                                        ")
	cQuery += CRLF + RTrim("   AND SD1.D1_FORNECE   = '" + SF1->F1_FORNECE       + "'                                        ")
	cQuery += CRLF + RTrim("   AND SD1.D1_LOJA      = '" + SF1->F1_LOJA          + "'                                        ")
	cQuery += CRLF + RTrim("   AND SD1.D1_EMISSAO   = '" + DToS(SF1->F1_EMISSAO) + "'                                        ")
	cQuery += CRLF + RTrim("   AND SD1.D1_DTDIGIT   = '" + DToS(SF1->F1_DTDIGIT) + "'                                        ")
	cQuery += CRLF + RTrim("   AND SD1.D1_TIPO      = 'D'                                                                    ")
	cQuery += CRLF + RTrim("   AND SD1.D1_NFORI    <> ' '                                                                    ")
	cQuery += CRLF + RTrim("   AND SD1.D_E_L_E_T_   = ' '                                                                    ")
	
	cQuery := CHANGEQUERY(cQuery)
	 
	dbUseArea(.T.,"TOPCONN", TCGenQry(,,cQuery),(cWa := GetNextAlias()), .F., .T.)
	 
	While (cWa)->(!Eof())
				
		If Select("PR1")
			DbSelectArea("PR1")
		Endif
		
		PR1->(dbSetOrder(2)) //PR1_FILIAL + PR1_ALIAS + PR1_CHAVE
		
		cChave := (cWa)->FILIAL+(cWa)->PEDIDO + "-" + SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO+DToS(F1_EMISSAO))
		 
		If RecLock("PR1",!PR1->(dbSeek(xFilial("PR1")+"SF1"+cChave))) 
		
			PR1->PR1_FILIAL := xFilial("PR1")
			PR1->PR1_ALIAS  := "SF1"
			PR1->PR1_RECNO  := SC5->(Recno())
			PR1->PR1_TIPREQ := "5"
			PR1->PR1_DATINT := Date()
			PR1->PR1_HRINT	:= Time()		
			PR1->PR1_STINT  := "P"
			PR1->PR1_CHAVE  := cChave
			
			PR1->(MsUnlock())
			
		Endif
		
		(cWa)->(dbSkip())
		
	EndDo
	
	dbCloseArea()
	
	RestArea(aArea)
	
Return(Nil)
