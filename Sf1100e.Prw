#Include "rwmake.ch"
#Include "Protheus.ch"
#Include "TopConn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSF1100E   บAutor  ณEletromega          บ Data ณ  03/05/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Ponto de entrada : Antes da delecao do SF1 na exclusa      บฑฑ 
ฑฑบ            da Nota da entrada                                         บฑฑ
ฑฑบ          ณ acerto da comissao                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP8                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function SF1100E()
		
	// Variaveis Customizacao Marcos TAGGS.
	LOCAL aAREA_SE2		:= SE2->( GetArea() )			
	LOCAL cQryUPD	
	Local  	cNome 			:= ""
	//Local	lRet 			:= .T.
	Local   cTpCanc         := ""
	Local   i			    := 0
	Public 	oHTML,cLista	:= space(10),cGeren := " ",cSuper:= " "
	Public 	nPosCod,nPosDesc,nPosTes,nPosLocal,nLen,nDel
	Public 	nPosQtd,nPosTot,nPosAlmox,nPosSer,nPosNF

	cQryUPD	:= " "
	cQryUPD	+= " UPDATE " + RETSqlName("SE2") + " SET E2_X_NUMNF = '" + SPACE( TAMSX3("E2_X_NUMNF")[1] ) + "', " 
	cQryUPD	+= " 		E2_X_SERIE = '" + SPACE( TAMSX3("E2_X_SERIE")[1] ) + "', E2_X_DTANF = '" + SPACE( TAMSX3("E2_X_DTANF")[1] ) + "' "
	cQryUPD	+= " WHERE 	E2_FILIAL = '" + xFilial("SE2") + "' "
	cQryUPD	+= "  		AND E2_X_NUMNF = '" + SF1->F1_DOC + "' " 
	cQryUPD	+= "  		AND E2_X_SERIE = '" + SF1->F1_SERIE + "' "
	cQryUPD	+= "  		AND E2_FORNECE = '" + SF1->F1_FORNECE + "' "
	cQryUPD	+= "  		AND E2_LOJA = '" + SF1->F1_LOJA + "' "
	cQryUPD	+= "  		AND E2_X_DTANF = '" + DTOS(SF1->F1_DTDIGIT) + "' " // Claudino 09/06/15
	cQryUPD	+= "  		AND E2_PREFIXO = 'COM' "
	//cQryUPD	+= "  		AND E2_NATUREZ = '" + ALLTRIM(GETMV("FS_SEDNAT")) + "' " // Claudino 09/06/15
	cQryUPD	+= "  		AND E2_NATUREZ IN (" + ALLTRIM(GETMV("FS_SEDNAT")) + ") "        // Claudino 09/06/15
	cQryUPD	+= " 		AND D_E_L_E_T_ <> '*' "
	TCSQLExec( cQryUPD )
	
	RESTAREA( aAREA_SE2 ) // Customizacao Marcos TAGGS.

	If (CTIPO == 'D')
		SA1->( dbSeek( xFilial("SA1") + CA100FOR + CLOJA, .F. ) )
		cNome	:= SA1->A1_NOME
		cTpCanc	:= "Exclusao NF de Devolucao: "
	Else
		SA2->( dbSeek( xFilial("SA2") + CA100FOR + CLOJA, .F. ) )
		cNome := SA2->A2_NOME
		cTpCanc	:= "Exclusao NF de Compras: "
	EndIf
	
	If CTIPO == "D" .AND. IsInCallStack("A140ESTCLA")
		cTpCanc	:= "Estorno de classifica็ใo NF de Devolucao: "
	EndIf

	oProcess:= TWFProcess():New("Entrada","Entrada")
	oProcess:NewTask("Inicio","\WORKFLOW\entrada.htm")
	oProcess:cSubject := cTpCanc + Alltrim(SM0->M0_NOME) + '/' +Alltrim(SM0->M0_FILIAL)
	oHtml := oProcess:oHTML
	StartUp()
	oHTML:ValByName('DATA',dDataBase)
	oHTML:ValByName('DOC',CSERIE + '/' + CNFISCAL)
	oHTML:ValByName('FORNECE',CA100FOR + '/' + CLOJA + ' ' + cNome)
	oHTML:ValByName('MOTIVO', GetMotivo())
	oHTML:ValByName('TOTAL', MAFISRET(,"NF_TOTAL"))
	
	For i := 1 To Len( aCols )
		If ( ! acols[i,len(aheader)+1]  ) 
			aAdd( ( oHTML:valByName( 'TB.Cod'  ) ), AllTrim (aCols[ i,nPosCod  ]) )
			aAdd( ( oHTML:valByName( 'TB.Desc' ) ), Rtrim(Substr ( aCols[ i,nPosDesc ],1,33 ) ) )
			aAdd( ( oHTML:valByName( 'TB.Almox' ) ), aCols[ i,nPosAlmox ] )
			aAdd( ( oHTML:valByName( 'TB.Quant' ) ), cValToChar(aCols[ i,nPosQtd ]) ) //Rodrigo Nunes - 14/07/2020
		EndIf
	Next
		
	// Email para mandar o workflow
	oProcess:cBCc := U_GrpEmail('ExcluirNFEntrada') //Retemails('ExcluirNFEntrada')
	
	If ! Empty(oProcess:cBCc)
		oProcess:Start()
		oProcess:Finish()
	EndIf

Return( .T. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSF1100E   บAutor  ณEletromega          บ Data ณ  03/05/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Ponto de entrada : Antes da delecao do SF1 na exclusa      บฑฑ 
ฑฑบ            da Nota da entrada                                         บฑฑ
ฑฑบ          ณ acerto da comissao                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP8                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function StartUp()
	nPosCod  	:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "D1_COD"   })
	nPosDesc 	:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "D1_DESCR" })
	nPosTes    	:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "D1_TES"   })
	nPosLocal  	:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "D1_LOCAL"  })
	nPosQtd  	:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "D1_QUANT"   })
	nPosTot 	:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "D1_TOTAL"   })
	nPosAlmox 	:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "D1_LOCAL"   })
	nPosSer 	:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "D1_SERIORI"   })
	nPosNF 		:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "D1_NFORI"   })
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSF1100E   บAutor  ณEletromega          บ Data ณ  03/05/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Ponto de entrada : Antes da delecao do SF1 na exclusa      บฑฑ 
ฑฑบ            da Nota da entrada                                         บฑฑ
ฑฑบ          ณ acerto da comissao                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP8                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
// Get motivo de devolu็ao digitado pelo usuario cadstrando a devolu็ao
Static Function GetMotivo()

	Local oDlg,oButton,oMemo,cMemo := space(50)

	oDlg := MSDialog():New(10,10,180,400,"Motivo",,,,,CLR_BLACK,CLR_WHITE,,,.T.)

	oDlg:lEscClose     := .F. //Nao permite sair ao se pressionar a tecla ESC.

	cBlKVld := "{|| .not. Empty(Alltrim(MemoLine(cmemo)))}"

	oMemo := TMultiget():New(10,8,bSetGet(cMemo), oDlg,;
	180,50,,,,,,.T.,,,,,,,&(cBlkVld),,,,.F.)

	oButton := tButton():New(65,150,"Enviar",oDlg,{||oDlg:End()},40,15,,,,.T.)

	// ativa diแlogo centralizado
	oDlg:Activate(,,,.T.,&(cBlkVld),,)

Return (cMemo)       
