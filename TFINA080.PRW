#Include "FWMVCDef.Ch"
#include 'protheus.ch'


//-------------------------------------------------------------------
/*/{Protheus.doc} TFINA080
Log de processamento integrações viagens

@author By Wise

@since 29/09/2018
/*/
//-------------------------------------------------------------------

User Function TFINA080()

Local oPanelPZA		:= Nil
Local oBrowsePZA	:= Nil

Private cCadastro	:= "Monitor Integracao"
Private bExecutar	:= ( {|| FwMsgRun(,{||U_fExecProc(PZA->PZA_ID)	},"Aguarde","Processando"		 ) } )
Private bAnalise	:= ( {|| FwMsgRun(,{||fAnalise() 				}, "Aguarde","Consultando dados" ) } )
Private bAltera		:= ( {|| FwMsgRun(,{||fAltera() 				}, "Aguarde","Consultando permissão para alteração de dados." 	 ) } )

	oBrowsePZA := FWMBrowse():New()
	
	oBrowsePZA:SetOwner(oPanelPZA)
	oBrowsePZA:SetDescription("Monitor Integracao")
	oBrowsePZA:SetAlias("PZA")
	oBrowsePZA:SetMenuDef("TFINA080")
	oBrowsePZA:SetProfileID("PZA")
	//oBrowsePZA:SetSeek(.t.,{})
	
	
	//Legenda
	oBrowsePZA:AddLegend( "PZA_STATUS == 'A'", "GREEN"	, "Ativado")
	oBrowsePZA:AddLegend( "PZA_STATUS == 'D'", "RED"	, "Desativado")

	oBrowsePZA:DisableDetails()
	oBrowsePZA:Activate()
	
	
Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Define as opções do menu do browser

@author By Wise

@since 29/09/2018
/*/
//-------------------------------------------------------------------

Static Function MenuDef()

Local aRotina	:= {}
Local bExecutar	:= ( {|| FwMsgRun(,{||U_fExecProc(PZA->PZA_ID)	}, "Aguarde","Procesando"		 ) } )
Local bAnalise	:= ( {|| FwMsgRun(,{||fAnalise() 				}, "Aguarde","Consultando dados" ) } )
Local bAltera	:= ( {|| FwMsgRun(,{||fAltera() 				}, "Aguarde","Consultando permissão para alteração de dados." 	 ) } )

	ADD OPTION aRotina Title 'Monitorar' 			Action 'VIEWDEF.TFINA080' 		OPERATION 2 ACCESS 0
	ADD OPTION aRotina Title 'Incluir'    			Action 'AxInclui("PZA")	' 		OPERATION 3 ACCESS 0
	ADD OPTION aRotina Title 'Executar Processo'	Action 'Eval(bExecutar)' 		OPERATION 3 ACCESS 0
	ADD OPTION aRotina Title 'Analise Resumida'		Action 'Eval(bAnalise)' 		OPERATION 2 ACCESS 0
	ADD OPTION aRotina Title 'Alterar'    			Action 'Eval(bAltera)'  		OPERATION 4 ACCESS 0
	ADD OPTION aRotina Title 'Excluir'    			Action 'VIEWDEF.TFINA080'	 	OPERATION 5 ACCESS 0
	ADD OPTION aRotina Title 'Imprimir'   			Action 'VIEWDEF.TFINA080' 		OPERATION 8 ACCESS 0

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Define o modelo da interface

@author By Wise

@since 29/09/2018
/*/
//-------------------------------------------------------------------

Static Function ModelDef()

Local oStruPZA 	:= FWFormStruct( 1, "PZA", /*bAvalCampo*/,/*lViewUsado*/ )
Local oStruPZB 	:= FWFormStruct( 1, "PZB", /*bAvalCampo*/,/*lViewUsado*/ )
Local oStruPZC 	:= FWFormStruct( 1, "PZC", /*bAvalCampo*/,/*lViewUsado*/ )
Local oStruPZD 	:= FWFormStruct( 1, "PZD", /*bAvalCampo*/,/*lViewUsado*/ )
Local oModel	:= Nil

	//Cria o objeto do Modelo de Dados.										 ³
	oModel := MPFormModel():New("TFINA80", /*bPreValidacao*/,  /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

	//Adiciona campos para controlar legenda dos grids
	oStruPZB:AddField(" ","","STSPZB","BT",10,0,{|| .T.},NIL,{},NIL,FwBuildFeature(STRUCT_FEATURE_INIPAD,"U_fStatus('PZB')"),NIL,NIL,.T.)
	oStruPZC:AddField(" ","","STSPZC","BT",10,0,{|| .T.},NIL,{},NIL,FwBuildFeature(STRUCT_FEATURE_INIPAD,"U_fStatus('PZC')"),NIL,NIL,.T.)
	oStruPZD:AddField(" ","","STSPZD","BT",10,0,{|| .T.},NIL,{},NIL,FwBuildFeature(STRUCT_FEATURE_INIPAD,"U_fStatus('PZD')"),NIL,NIL,.T.)

	oModel:SetDescription( "Log de integracoes." )

	//Adiciona model princiapal
	oModel:AddFields( "PZAMASTER", /*cOwner*/, oStruPZA, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

	//Adiciona os grids.
	oModel:AddGrid( "PZBDETAIL", "PZAMASTER" , oStruPZB, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
	oModel:AddGrid( "PZCDETAIL", "PZBDETAIL" , oStruPZC, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
	oModel:AddGrid( "PZDDETAIL", "PZCDETAIL" , oStruPZD, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

	//Relacionamento entre os modelos
	oModel:SetRelation( "PZBDETAIL" , { { "PZB_FILIAL" , "xFilial('PZB')" } , { "PZB_IDURL"  , "PZA_ID" }																			} , PZB->( IndexKey( 1 ) ) )
	oModel:SetRelation( "PZCDETAIL" , { { "PZC_FILIAL" , "xFilial('PZC')" } , { "PZC_IDURL"  , "PZB_IDURL"	}	, { "PZC_IDPROC" , "PZB_ID"		}									} , PZC->( IndexKey( 2 ) ) )
	oModel:SetRelation( "PZDDETAIL" , { { "PZD_FILIAL" , "xFilial('PZD')" } , { "PZD_IDURL"  , "PZB_IDURL"  } 	, { "PZD_IDPROC" , "PZB_ID" } , { "PZD_IDREG" , "PZC_ID" 	}		} , PZD->( IndexKey( 2 ) ) )

	//Chave unica os modelos
	oModel:GetModel("PZBDETAIL"):SetUniqueLine({"PZB_IDURL", "PZB_ID"})
	oModel:GetModel("PZCDETAIL"):SetUniqueLine({"PZC_IDURL", "PZC_IDPROC", "PZC_ID"})
	oModel:GetModel("PZDDETAIL"):SetUniqueLine({"PZD_IDURL", "PZD_IDPROC", "PZD_IDREG", "PZD_ID"})

	//Descrição dos componentes
	oModel:GetModel( "PZAMASTER" ):SetDescription( "Cadastro se servicos"				)
	oModel:GetModel( "PZBDETAIL" ):SetDescription( "Log de processamento servicos"		)
	oModel:GetModel( "PZCDETAIL" ):SetDescription( "Registros processados no servico"	)
	oModel:GetModel( "PZDDETAIL" ):SetDescription( "Log de processamento dos registros"	)

	//Liga o controle de não repetição de linha.	
	//oModel:GetModel( "PZBDETAIL" ):SetOptional(.T.)
	//oModel:GetModel( "PZCDETAIL" ):SetOptional(.T.)
	//oModel:GetModel( "PZDDETAIL" ):SetOptional(.T.)

	//Chave primaria do model
	oModel:SetPrimaryKey({"PZA_FILIAL", "PZA_ID"})

	//Modifica a ativação do model
	oModel:SetVldActivate({|oModel| FwPreValid(oModel)})

Return(oModel)

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Define o modelo da interface

@author By Wise

@since 29/09/2018
/*/
//-------------------------------------------------------------------

Static Function ViewDef()

Local oModel   	:= FWLoadModel("TFINA080")
Local oStruPZA 	:= FWFormStruct( 2, "PZA" )
Local oStruEnd	:= FWFormStruct( 2, "PZA" )
Local oStruSch	:= FWFormStruct( 2, "PZA" )
Local oStruPZB 	:= FWFormStruct( 2, "PZB" )
Local oStruPZC 	:= FWFormStruct( 2, "PZC" )
Local oStruPZD 	:= FWFormStruct( 2, "PZD" )
Local oView		:= Nil
Local oGreen   	:= LoadBitmap( GetResources(), "BR_VERDE")
Local oRed    	:= LoadBitmap( GetResources(), "BR_VERMELHO")
Local oYellow  	:= LoadBitmap( GetResources(), "BR_AMARELO")

	oView := FWFormView():New()

	oView:SetModel( oModel )

	//Deixa somente campos do cadastro
	oStruPZA:RemoveField('PZA_ENDPOI')
	oStruPZA:RemoveField('PZA_TIPMET')
	oStruPZA:RemoveField('PZA_SEGEND')
	oStruPZA:RemoveField('PZA_SEGTIP')
	oStruPZA:RemoveField('PZA_TEREND')
	oStruPZA:RemoveField('PZA_TERTIP')
	oStruPZA:RemoveField('PZA_QUAEND')
	oStruPZA:RemoveField('PZA_QUATIP')
	oStruPZA:RemoveField('PZA_QUIEND')
	oStruPZA:RemoveField('PZA_QUITIP')
	oStruPZA:RemoveField('PZA_HORA')
	oStruPZA:RemoveField('PZA_PERIOD')
	oStruPZA:RemoveField('PZA_QUANT')
	oStruPZA:RemoveField('PZA_INTERV')

	//Deixa somente os campos do endpoint
	oStruEnd:RemoveField('PZA_HORA')
	oStruEnd:RemoveField('PZA_PERIOD')
	oStruEnd:RemoveField('PZA_QUANT')
	oStruEnd:RemoveField('PZA_INTERV')
	oStruEnd:RemoveField('PZA_ID')
	oStruEnd:RemoveField('PZA_URL')
	oStruEnd:RemoveField('PZA_STATUS')
	oStruEnd:RemoveField('PZA_DESC')
	oStruEnd:RemoveField('PZA_PROG')
	oStruEnd:RemoveField('PZA_TIPSRV')

	//Deixa somente os campos do agendamento
	oStruSch:RemoveField('PZA_ID')
	oStruSch:RemoveField('PZA_URL')
	oStruSch:RemoveField('PZA_STATUS')
	oStruSch:RemoveField('PZA_DESC')
	oStruSch:RemoveField('PZA_PROG')
	oStruSch:RemoveField('PZA_ENDPOI')
	oStruSch:RemoveField('PZA_TIPMET')
	oStruSch:RemoveField('PZA_SEGEND')
	oStruSch:RemoveField('PZA_SEGTIP')
	oStruSch:RemoveField('PZA_TEREND')
	oStruSch:RemoveField('PZA_TERTIP')
	oStruSch:RemoveField('PZA_QUAEND')
	oStruSch:RemoveField('PZA_QUATIP')
	oStruSch:RemoveField('PZA_QUIEND')
	oStruSch:RemoveField('PZA_QUITIP')
	oStruEnd:RemoveField('PZA_TIPSRV')

	//Remove os campos que nao seram exibidos em tela
	oStruPZB:RemoveField('PZB_IDURL')
	oStruPZB:RemoveField('PZB_STATUS')
	
	oStruPZC:RemoveField('PZC_STATUS')
	oStruPZC:RemoveField('PZC_IDPROC')
	oStruPZC:RemoveField('PZC_IDURL')
	
	oStruPZD:RemoveField('PZD_IDREG')
	oStruPZD:RemoveField('PZD_STATUS')
	oStruPZD:RemoveField('PZD_IDURL')
	oStruPZD:RemoveField('PZD_IDPROC')

	//Cria campos virtuais para alimentar as legendas
	oStruPZB:AddField('STSPZB',   '01',             " "," ",{},'C','@BMP',NIL,'',.F.,NIL,NIL,{},NIL,'{|| "DISABLE"}',.T.,NIL)
	oStruPZC:AddField('STSPZC',   '01',             " "," ",{},'C','@BMP',NIL,'',.F.,NIL,NIL,{},NIL,'{|| "DISABLE"}',.T.,NIL)
	oStruPZD:AddField('STSPZD',   '01',             " "," ",{},'C','@BMP',NIL,'',.F.,NIL,NIL,{},NIL,'{|| "DISABLE"}',.T.,NIL)

	//Ajusta a ordem dos campos
	oStruPZB:SetProperty('STSPZB'		, MVC_VIEW_ORDEM, '01')
	oStruPZB:SetProperty('PZB_ID'		, MVC_VIEW_ORDEM, '02')
	oStruPZB:SetProperty('PZB_DATA'		, MVC_VIEW_ORDEM, '03')
	oStruPZB:SetProperty('PZB_HORA'		, MVC_VIEW_ORDEM, '04')
	oStruPZB:SetProperty('PZB_REGTOT'	, MVC_VIEW_ORDEM, '05')
	oStruPZB:SetProperty('PZB_REGPRO'	, MVC_VIEW_ORDEM, '06')
	oStruPZB:SetProperty('PZB_REGERR'	, MVC_VIEW_ORDEM, '07')
	oStruPZB:SetProperty('PZB_TEMPO'	, MVC_VIEW_ORDEM, '08')
	
	//View com model principal
	oView:AddField( "VIEW_PZA", oStruPZA, "PZAMASTER" )
	oView:AddField( "VIEW_END", oStruEnd, "PZAMASTER" )
	oView:AddField( "VIEW_SCH", oStruSch, "PZAMASTER" )
	
	//View's dos grids
	oView:AddGrid( "VIEW_PZB", oStruPZB, "PZBDETAIL" )
	oView:AddGrid( "VIEW_PZC", oStruPZC, "PZCDETAIL" )
	oView:AddGrid( "VIEW_PZD", oStruPZD, "PZDDETAIL" )

	//Criar um "box" horizontal para receber algum elemento da view.			
	oView:CreateHorizontalBox( 'BOX0101', 030)
	oView:CreateHorizontalBox( 'BOX0102', 030)
	oView:CreateHorizontalBox( 'BOX0103', 040)

	//Criar um "box" vertical para receber a criação do folder
	oView:CreateVerticalBox( 'BOX010101', 100, 'BOX0101')

	//Cria os folders para separar os campos
	oView:CreateFolder("ABAS" , "BOX010101")

	//Adiciona as abas
	oView:addSheet("ABAS" , "ABA01"	, "Cadastrais"	)
	oView:addSheet("ABAS" , "ABA02"	, "Metodos"		)
	oView:addSheet("ABAS" , "ABA03"	, "Agendamento"	)

	//BOX com os dados cadastrados do serviço
	oView:CreateVerticalBox( 'CADASTRO'	, 100, , , 'ABAS', 'ABA01')
	oView:CreateVerticalBox( 'ENDPOINT'	, 100, , , 'ABAS', 'ABA02')
	oView:CreateVerticalBox( 'SCHEDULE'	, 100, , , 'ABAS', 'ABA03')
	
	//BOX com os dados de execução do serviço.
	oView:CreateVerticalBox( 'BOX010102', 100, 'BOX0102')

	//BOX com os dados de registros
	oView:CreateVerticalBox( 'BOX010301', 050, 'BOX0103')
	
	//BOX com os logs do registro
	oView:CreateVerticalBox( 'BOX010302', 050, 'BOX0103')

	//Relaciona o ID da View com o "box" para exibicao.						 
	oView:SetOwnerView( "VIEW_PZA", "CADASTRO"	) 
	oView:SetOwnerView( "VIEW_END", "ENDPOINT"	) 
	oView:SetOwnerView( "VIEW_SCH", "SCHEDULE"	) 
	oView:SetOwnerView( "VIEW_PZB", "BOX010102"	) 
	oView:SetOwnerView( "VIEW_PZC", "BOX010301"	) 
	oView:SetOwnerView( "VIEW_PZD", "BOX010302"	) 

	//Liga a identificacao do componente.										 
	oView:EnableTitleView( "VIEW_PZA" )
	oView:EnableTitleView( "VIEW_PZB" )
	oView:EnableTitleView( "VIEW_PZC" )
	oView:EnableTitleView( "VIEW_PZD" )

	//Opçãod e filtro nos grids
	oView:SetViewProperty("VIEW_PZB", "GRIDFILTER", {.T.}) 
	oView:SetViewProperty("VIEW_PZC", "GRIDFILTER", {.T.})
	oView:SetViewProperty("VIEW_PZD", "GRIDFILTER", {.T.})

	//Opção de pesquisa nos grids
	oView:SetViewProperty("VIEW_PZB", "GRIDSEEK", {.T.}) 
	oView:SetViewProperty("VIEW_PZC", "GRIDSEEK", {.T.})
	oView:SetViewProperty("VIEW_PZD", "GRIDSEEK", {.T.})

	//Adiciona botões na view
	oView:AddUserButton( 'Atualizar browse'		, 'Browse'				, {|oView| fRefresh(oView)	} )
	oView:AddUserButton( 'Reprocessar Registro'	, 'Registro'			, {|oView| fRepReg(oView)	} )
	oView:AddUserButton( 'Reprocessar lote'		, 'Lote'				, {|oView| fRepLote(oView)	} )
	
Return(oView)

//-------------------------------------------------------------------
/*/{Protheus.doc} TF080LoadMod
Função para validar a ativação do model.

@author By Wise

@since 29/09/2018
/*/
//-------------------------------------------------------------------

Static Function FwPreValid(oModel)

Local oModelPZA	:= oModel:GetModel("PZAMASTER")
Local cQuery	:= ""
Local cAlsCount	:= CriaTrab(Nil,.F.)
Local lRet		:= .T.
Local oStruPZA	:= oModelPZA:GetStruct()
Local lFilDet   := .F.
Local nQtdMin   := SuperGetMV("ES_MINERRO",.F.,20)
Local cHora     := ""
Local cMin		:= ""
Local cTempo    := ""
Local cIDIN		:= ""

	//Altera campo de ID par aser somente visualização.
	oStruPZA:SetProperty( 'PZA_ID', MODEL_FIELD_WHEN, {||.F.} )
	
	If oModel:GetOperation() <> 1

		//Query para buscar usuários com permissões especiais.
		cQuery := " SELECT X5_CHAVE, X5_DESCRI "
		cQuery += " FROM " + RetSqlName("SX5") + " SX5 "
		cQuery += " WHERE X5_TABELA = 'JD' AND X5_CHAVE = '" + __cUserId + "' AND SX5.D_E_L_E_T_ = ' ' "

		If Select(cAlsCount) > 0; (cAlsCount)->(dbCloseArea()); Endif  
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlsCount,.T.,.T.)

		If (cAlsCount)->(Eof())
			lRet := .F.
			Help(" ",1, 'Help','TFINA080_ACT',"Usuário não possui permissão para esta ação." , 3, 0 )
		Endif

		(cAlsCount)->(dbCloseArea())

	Else
		
		cPerg := "TFINA080"
		
		CriaPerg(cPerg)
	
		If Pergunte(cPerg,.t.)
			//Filtra o model inicial
			While .T.	
				If Empty(MV_PAR01) .and. Empty(MV_PAR02) .and. Empty(Replace(MV_PAR03,":","")) .and. Empty(Replace(MV_PAR04,":",""))
					lFilDet := .F.
					Exit
				ElseIf Empty(MV_PAR01) .or. Empty(MV_PAR02) .or. Empty(MV_PAR03) .or. Empty(MV_PAR04)
					Alert("Para uma visualização detalhada preencha todos os parametros, para ver somente os ultimos erros, deixar todos os parametros em branco.")
				Else
					lFilDet := .T.
					Exit
				EndIf
				Pergunte(cPerg,.t.)
			EndDo
			
			If lFilDet
				cFilter := "PZB_DATA >= '" + DTOS(MV_PAR01) + "' AND PZB_DATA <= '" + DTOS(MV_PAR02) + "' AND PZB_HORA >= '" + MV_PAR03 + "' AND PZB_HORA <= '" + MV_PAR04 + "' "
			else
				cHora := SUBSTR(TIME(),1,2)
				cMin  := SUBSTR(TIME(),4,2)         
				cMin  := Val(cMin) - nQtdMin
				
				If cMin < 0
					cHora := Val(cHora) - 1
					cMin  := 60 - (cMin * -1)
					cTempo := Iif(Len(Alltrim(cValtoChar(cHora))) == 1,"0"+cValtoChar(cHora),cValtoChar(cHora)) + ":" + Iif(Len(Alltrim(cValtoChar(cMin))) == 1,"0"+cValtoChar(cMin),cValtoChar(cMin)) + ":00"
				Else
					cTempo := Iif(Len(Alltrim(cValtoChar(cHora))) == 1,"0"+cValtoChar(cHora),cValtoChar(cHora)) + ":" + Iif(Len(Alltrim(cValtoChar(cMin))) == 1,"0"+cValtoChar(cMin),cValtoChar(cMin)) + ":00"
				EndIf
				
				cFilter := "PZB_DATA = '" + DTOS(dDataBase) + "' AND PZB_HORA >= '" + cTempo + "' "
				
			EndIf

			If PZA->PZA_ID == "000006" .And. (!Empty(MV_PAR05) .OR. !Empty(MV_PAR06) .OR. !Empty(MV_PAR07) .OR. !Empty(MV_PAR08))
				Alert("Parametros de CTE, Pedido e NF Saida serão desconsiderados.")
				cQuery := " SELECT PZC_IDPROC FROM " + RetSqlName("PZC")
				cQuery += " WHERE PZC_IDURL = '000006' "
				cQuery += " AND PZC_CHAVE LIKE '%"+Alltrim(MV_PAR05)+"%'
				cQuery += " AND D_E_L_E_T_ = ''
				
				If Select("PZCX") > 0
					PZCX->(dbCloseArea())			
				EndIf

				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"PZCX",.T.,.T.)

				While PZCX->(!Eof())
					cIDIN += PZCX->PZC_IDPROC + ","
					PZCX->(dbSkip())
				EndDo

				If !Empty(cIDIN)
					cIDIN := SubStr(cIDIN,1,len(cIDIN)-1)

					cFilter += " AND PZB_ID IN "	+ FormatIn(cIDIN,",")
				EndIf
			ElseIf PZA->PZA_ID == "000009" .And. (!Empty(MV_PAR05) .OR. !Empty(MV_PAR06) .OR. !Empty(MV_PAR07) .OR. !Empty(MV_PAR08))
				Alert("Parametros de Fatura, Pedido e NF Saida serão desconsiderados.")
				cQuery := " SELECT TOP(30) PZC_IDPROC, PZB_DATA, PZB_HORA FROM " + RetSqlName("PZC") + " PZC "
				cQuery += " INNER JOIN " + RetSqlName("PZB") + " PZB "
				cQuery += " ON PZB.PZB_IDURL = PZC.PZC_IDURL "
				cQuery += " AND PZB.PZB_ID = PZC.PZC_IDPROC "
				cQuery += " WHERE PZC_IDURL = '000009' "
				cQuery += " AND PZC_CHAVE LIKE '%"+Alltrim(MV_PAR06)+"%' "
				If !Empty(MV_PAR01) .AND. !Empty(MV_PAR02)
					cQuery += " AND PZB.PZB_DATA BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' "
				Else
					cQuery += " AND PZB.PZB_DATA = '"+DTOS(dDataBase)+"' "
				EndIf
				If !Empty(Replace(MV_PAR03,":","")) .AND. !Empty(Replace(MV_PAR04,":",""))
					cQuery += " AND PZB.PZB_HORA >= '"+MV_PAR03+"' "
					cQuery += " AND PZB.PZB_HORA <= '"+MV_PAR04+"' "
				Else
					cQuery += " AND PZB.PZB_HORA >= '"+cTempo+"' "
				EndIf
				cQuery += " AND PZC.D_E_L_E_T_ = '' "
				cQuery += " AND PZB.D_E_L_E_T_ = '' "
				cQuery += " ORDER BY PZB.PZB_DATA DESC, PZB_HORA DESC "
				
				If Select("PZCX") > 0
					PZCX->(dbCloseArea())			
				EndIf

				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"PZCX",.T.,.T.)

				While PZCX->(!Eof())
					cIDIN += PZCX->PZC_IDPROC + ","
					PZCX->(dbSkip())
				EndDo

				If !Empty(cIDIN)
					cIDIN := SubStr(cIDIN,1,len(cIDIN)-1)

					cFilter += "AND PZB_ID IN "	+ FormatIn(cIDIN,",")
				EndIf
			ElseIf PZA->PZA_ID == "000002" .And. (!Empty(MV_PAR05) .OR. !Empty(MV_PAR06) .OR. !Empty(MV_PAR07) .OR. !Empty(MV_PAR08))
				Alert("Parametros de Fatura, CTE e NF Saida serão desconsiderados.")
				cQuery := " SELECT TOP(30) PZC_IDPROC, PZB_DATA, PZB_HORA FROM " + RetSqlName("PZC") + " PZC "
				cQuery += " INNER JOIN " + RetSqlName("PZB") + " PZB "
				cQuery += " ON PZB.PZB_IDURL = PZC.PZC_IDURL "
				cQuery += " AND PZB.PZB_ID = PZC.PZC_IDPROC "
				cQuery += " WHERE PZC_IDURL = '000002' "
				cQuery += " AND PZC_CHAVE LIKE '%"+Alltrim(MV_PAR07)+"%' "
				If !Empty(MV_PAR01) .AND. !Empty(MV_PAR02)
					cQuery += " AND PZB.PZB_DATA BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' "
				Else
					cQuery += " AND PZB.PZB_DATA = '"+DTOS(dDataBase)+"' "
				EndIf
				If !Empty(Replace(MV_PAR03,":","")) .AND. !Empty(Replace(MV_PAR04,":",""))
					cQuery += " AND PZB.PZB_HORA >= '"+MV_PAR03+"' "
					cQuery += " AND PZB.PZB_HORA <= '"+MV_PAR04+"' "
				Else
					cQuery += " AND PZB.PZB_HORA >= '"+cTempo+"' "
				EndIf
				cQuery += " AND PZC.D_E_L_E_T_ = '' "
				cQuery += " AND PZB.D_E_L_E_T_ = '' "
				cQuery += " ORDER BY PZB.PZB_DATA DESC, PZB_HORA DESC "
				
				If Select("PZCX") > 0
					PZCX->(dbCloseArea())			
				EndIf

				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"PZCX",.T.,.T.)

				While PZCX->(!Eof())
					cIDIN += PZCX->PZC_IDPROC + ","
					PZCX->(dbSkip())
				EndDo

				If !Empty(cIDIN)
					cIDIN := SubStr(cIDIN,1,len(cIDIN)-1)

					cFilter += "AND PZB_ID IN "	+ FormatIn(cIDIN,",")
				EndIf
			ElseIf PZA->PZA_ID == "000020" .And. (!Empty(MV_PAR05) .OR. !Empty(MV_PAR06) .OR. !Empty(MV_PAR07) .OR. !Empty(MV_PAR08))
				Alert("Parametros de Fatura, CTE e Pedido serão desconsiderados.")
				cQuery := " SELECT TOP(30) PZC_IDPROC, PZB_DATA, PZB_HORA FROM " + RetSqlName("PZC") + " PZC "
				cQuery += " INNER JOIN " + RetSqlName("PZB") + " PZB "
				cQuery += " ON PZB.PZB_IDURL = PZC.PZC_IDURL "
				cQuery += " AND PZB.PZB_ID = PZC.PZC_IDPROC "
				cQuery += " WHERE PZC_IDURL = '000020' "
				cQuery += " AND PZC_CHAVE LIKE '%"+Alltrim(MV_PAR08)+"%' "
				If !Empty(MV_PAR01) .AND. !Empty(MV_PAR02)
					cQuery += " AND PZB.PZB_DATA BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' "
				Else
					cQuery += " AND PZB.PZB_DATA = '"+DTOS(dDataBase)+"' "
				EndIf
				If !Empty(Replace(MV_PAR03,":","")) .AND. !Empty(Replace(MV_PAR04,":",""))
					cQuery += " AND PZB.PZB_HORA >= '"+MV_PAR03+"' "
					cQuery += " AND PZB.PZB_HORA <= '"+MV_PAR04+"' "
				Else
					cQuery += " AND PZB.PZB_HORA >= '"+cTempo+"' "
				EndIf
				cQuery += " AND PZC.D_E_L_E_T_ = '' "
				cQuery += " AND PZB.D_E_L_E_T_ = '' "
				cQuery += " ORDER BY PZB.PZB_DATA DESC, PZB_HORA DESC "
				
				If Select("PZCX") > 0
					PZCX->(dbCloseArea())			
				EndIf

				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"PZCX",.T.,.T.)

				While PZCX->(!Eof())
					cIDIN += PZCX->PZC_IDPROC + ","
					PZCX->(dbSkip())
				EndDo

				If !Empty(cIDIN)
					cIDIN := SubStr(cIDIN,1,len(cIDIN)-1)

					cFilter += "AND PZB_ID IN "	+ FormatIn(cIDIN,",")
				EndIf
			EndIf
			
			cIDIN := ""
			
			oModel:GetModel('PZBDETAIL'):SetLoadFilter( , cFilter )
		Else
			lRet := .F.
			Help(" ",1, 'Help','TFINA080_ACT',"Necessario informar o range de datas." , 3, 0 )
		EndIf	
		
	EndIf

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} fRepReg
função para reprocessar um unico registro

@author By Wise

@since 29/09/2018
/*/
//-------------------------------------------------------------------

Static Function fRepReg(oView)

Local oModel	:= oView:GetModel()
Local oModelPZB	:= oModel:GetModel("PZBDETAIL")
Local oModelPZC	:= oModel:GetModel("PZCDETAIL")
Local oModelPZD	:= oModel:GetModel("PZDDETAIL")
Local cIdPZB	:= oModelPZB:GetValue("PZB_ID")
Local cIdUrl	:= oModelPZB:GetValue("PZB_IDURL")
Local cIdPZC	:= oModelPZC:GetValue("PZC_ID")
Local cChave	:= Alltrim(oModelPZC:GetValue("PZC_CHAVE"))
Local cIdPZD	:= oModelPZD:GetValue("PZD_ID")
Local cQuery	:= ""
Local cAlsReg	:= CriaTrab(Nil,.F.)
Local cProgram	:= ""
Local cAlsCount	:= CriaTrab(Nil,.F.)

	//Query para buscar usuários com permissões especiais.
	cQuery := " SELECT X5_CHAVE, X5_DESCRI "
	cQuery += " FROM " + RetSqlName("SX5") + " SX5 "
	cQuery += " WHERE X5_TABELA = 'JD' AND X5_CHAVE = '" + __cUserId + "' AND SX5.D_E_L_E_T_ = ' ' "

	If Select(cAlsCount) > 0; (cAlsCount)->(dbCloseArea()); Endif  
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlsCount,.T.,.T.)

	If (cAlsCount)->(Eof())
		
		lRet := .F.
		Help(" ",1, 'Help','TFINA080_ACT',"Usuário não possui permissão para esta ação." , 3, 0 )

		(cAlsCount)->(dbCloseArea())

		Return(lRet)
		
	Endif

	(cAlsCount)->(dbCloseArea())

	//Pergunta ao usuário se deseja prosseguir com o reprocessamento.
	If MsgYesNo("Atenção, você solcitou para reprocessar o registro:  " + cIdPZC + " do log de serviço: " + cIdPZB + ", Deseja continuar? ")

		//Valida status do registro.
		If oModelPZC:GetValue("PZC_STATUS") <> "F"
			Help(" ",1, 'Help','TFINA081_REG',"Somente registros com status de falha podem ser reprocessados.", 3, 0 )	
			Return(.F.)
		EndIf

		//Valida se o registro existe em processo posterior.
		cQuery := " SELECT PZB_ID, PZB_IDURL FROM " + RetSqlName("PZB") + " PZB "
		cQuery += " INNER JOIN " + RetSqlName("PZC") + " PZC "
		cQuery += " ON PZC_FILIAL = '" + xFilial("PZC") + "' "
		cQuery += " AND PZB_ID = PZC_IDPROC "
		cQuery += " WHERE PZB_ID > '" + cIdPZB + "' AND PZB_IDURL = '" + cIdUrl + "' "
		cQuery += " AND PZB.D_E_L_E_T_ = ' ' AND PZC.D_E_L_E_T_ = ' ' "

		If Select(cAlsReg) > 0; (cAlsReg)->(dbCloseArea()); Endif  
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlsReg,.T.,.T.)

		If !(cAlsReg)->(Eof())
			Help(" ",1, 'Help','TFINA081_REG',"Este registro não pode ser reprocessado pois ele ja foi gerdo em um novo processo.", 3, 0 )	
			Return(.F.)
		EndIf

		//Query para trazer registro a ser reprocessado.
		cQuery := " SELECT PZB_ID, PZB_IDURL FROM " + RetSqlName("PZB") + " PZB "
		cQuery += " INNER JOIN " + RetSqlName("PZC") + " PZC "
		cQuery += " ON PZC_FILIAL = '" + xFilial("PZC") + "' "
		cQuery += " AND PZB_ID = PZC_IDPROC "
		cQuery += " WHERE PZB_ID = '" + cIdPZB + "' AND PZC_CHAVE = '" + Alltrim(oModelPZC:GetValue("PZC_CHAVE")) + "' "
		cQuery += " AND PZB.D_E_L_E_T_ = ' ' AND PZC.D_E_L_E_T_ = ' ' "

		If Select(cAlsReg) > 0; (cAlsReg)->(dbCloseArea()); Endif  
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlsReg,.T.,.T.)

		If !(cAlsReg)->(Eof())
			
			DbSelectArea("PZA")
			PZA->(DbSetOrder(1))
			
			If PZA->(MsSeek(xFilial("PZA") + cIdUrl ))
				
				cProgram	:= Alltrim(PZA->PZA_PROG)

				//Chama programa que esta no cadastro informando que é reprocessamento
				StartJob(cProgram, GetEnvServer(), .F., .T., cChave, .F., cIdPZB, cIdPZC )

				//&(cProgram+"(.T., cChave, .F., cIdPZB, cIdPZC )")

			Else

				Help(" ",1, 'Help','TFINA081_REG',"Id do serviço não encontrado na tabela PZA." , 3, 0 )
				Return(.F.)

			EndIf

		EndIf

		(cAlsReg)->(dbCloseArea())

	Else
		Help(" ",1, 'Help','TFINA081_REG',"Proccesso cancelado pelo usuário." , 3, 0 )
		Return(.F.)
	EndIf

Return(.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} fRepLote
função para reprocessar lote inteiro.

@author By Wise

@since 29/09/2018
/*/
//-------------------------------------------------------------------

Static Function fRepLote(oView)

Local oModel		:= oView:GetModel()
Local oModelPZB		:= oModel:GetModel("PZBDETAIL")
Local oModelPZC		:= oModel:GetModel("PZCDETAIL")
Local oModelPZD		:= oModel:GetModel("PZDDETAIL")
Local cIdPZB		:= oModelPZB:GetValue("PZB_ID")
Local cIdUrl		:= oModelPZB:GetValue("PZB_IDURL")
Local cIdPZC		:= oModelPZC:GetValue("PZC_ID")
Local cChave		:= Alltrim(oModelPZC:GetValue("PZC_CHAVE"))
Local cIdPZD		:= oModelPZD:GetValue("PZD_ID")
Local cQuery		:= ""
Local cAlsReg		:= CriaTrab(Nil,.F.)
Local cProgram		:= ""
Local aRegistros	:= {}
Local cAlsCount	:= CriaTrab(Nil,.F.)

	//Query para buscar usuários com permissões especiais.
	cQuery := " SELECT X5_CHAVE, X5_DESCRI "
	cQuery += " FROM " + RetSqlName("SX5") + " SX5 "
	cQuery += " WHERE X5_TABELA = 'JD' AND X5_CHAVE = '" + __cUserId + "' AND SX5.D_E_L_E_T_ = ' ' "

	If Select(cAlsCount) > 0; (cAlsCount)->(dbCloseArea()); Endif  
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlsCount,.T.,.T.)

	If (cAlsCount)->(Eof())
		
		lRet := .F.
		Help(" ",1, 'Help','TFINA080_ACT',"Usuário não possui permissão para esta ação." , 3, 0 )

		(cAlsCount)->(dbCloseArea())

		Return(lRet)
		
	Endif

	(cAlsCount)->(dbCloseArea())

	//Pergunta ao usuário se deseja prosseguir com o reprocessamento.
	If MsgYesNo("Atenção, você solcitou para reprocessar todos registros com falha do log de serviço: " + cIdPZB + ", Deseja continuar? ")
		
		//Valida se ja existem processamentos posterior ao ID selecionado
		cQuery := " SELECT PZB_ID, PZB_IDURL, PZC_CHAVE FROM " + RetSqlName("PZB") + " PZB "
		cQuery += " INNER JOIN " + RetSqlName("PZC") + " PZC "
		cQuery += " ON PZC_FILIAL = '" + xFilial("PZC") + "' "
		cQuery += " AND PZB_ID = PZC_IDPROC "
		cQuery += " WHERE PZB_ID > '" + cIdPZB + "' AND PZB_IDURL = '" + cIdUrl + "' "
		cQuery += " AND PZB.D_E_L_E_T_ = ' ' AND PZC.D_E_L_E_T_ = ' ' "

		If Select(cAlsReg) > 0; (cAlsReg)->(dbCloseArea()); Endif  
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlsReg,.T.,.T.)

		If !(cAlsReg)->(Eof())
			Help(" ",1, 'Help','TFINA081_LOTE',"Este lote não pode ser reprocessado pois ja existe um de id superior.", 3, 0 )
			Return(.F.)
		EndIf

		//Query para trazer os registros a serem procesados
		cQuery := " SELECT PZB_ID, PZB_IDURL, PZC_CHAVE FROM " + RetSqlName("PZB") + " PZB "
		cQuery += " INNER JOIN " + RetSqlName("PZC") + " PZC "
		cQuery += " ON PZC_FILIAL = '" + xFilial("PZC") + "' "
		cQuery += " AND PZB_ID = PZC_IDPROC "
		cQuery += " WHERE PZB_ID = '" + cIdPZB + "' AND PZB_STATUS = 'F' AND PZB.D_E_L_E_T_ = ' ' AND PZC.D_E_L_E_T_ = ' ' "

		If Select(cAlsReg) > 0; (cAlsReg)->(dbCloseArea()); Endif  
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlsReg,.T.,.T.)

		//Se foram encontrados registros a processar
		If !(cAlsReg)->(Eof())

			While !(cAlsReg)->(Eof())

				AADD(aRegistros, { (cAlsReg)->PZB_ID, (cAlsReg)->PZB_IDURL, (cAlsReg)->PZC_CHAVE })

				(cAlsReg)->(DbSkip())

			End

			DbSelectArea("PZA")
			PZA->(DbSetOrder(1))
			
			If PZA->(MsSeek(xFilial("PZA") + cIdUrl ))
				
				cProgram	:= Alltrim(PZA->PZA_PROG)

				//Chama programa que esta no cadastro informando que é reprocessamento
				StartJob(cProgram, GetEnvServer(), .F., .T., , .T., , , aRegistros)

			Else
				Help(" ",1, 'Help','TFINA081_LOTE',"Id do serviço não encontrado na tabela PZA." , 3, 0 )
				Return(.F.)
			EndIf
		Else
			Help(" ",1, 'Help','TFINA081_LOTE',"Não foi encontrado registros para precessar." , 3, 0 )
			Return(.F.)
		EndIf

		(cAlsReg)->(DbCloseArea())

	Else
		Help(" ",1, 'Help','TFINA081_LOTE',"Proccesso cancelado pelo usuário." , 3, 0 )
		Return(.F.)
	EndIf

Return(.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} fStatus
Inicializador do campo virtual de legenda

@author By Wise

@since 29/09/2018
/*/
//-------------------------------------------------------------------

User Function fStatus(cTabela)

Local cLegenda := ""

	Do Case
	
		Case cTabela == "PZB"
			
			If PZB->PZB_STATUS == "S"
			
				cLegenda := "BR_VERDE"	
			
			ElseIf PZB->PZB_STATUS == "F"

				cLegenda := "BR_VERMELHO"
			
			ElseIf PZB->PZB_STATUS == "E"

				cLegenda := "BR_AMARELO"
			
			EndIf
		
		Case cTabela == "PZC"

			If PZC->PZC_STATUS == "S"
			
				cLegenda := "BR_VERDE"	
			
			ElseIf PZC->PZC_STATUS == "F"

				cLegenda := "BR_VERMELHO"

			ElseIf PZC->PZC_STATUS == "E"

				cLegenda := "BR_LARANJA"
			
			EndIf
		
		Case cTabela == "PZD"

			If PZD->PZD_STATUS == "S"
			
				cLegenda := "BR_VERDE"	
			
			ElseIf PZD->PZD_STATUS == "F"

				cLegenda := "BR_VERMELHO"

			ElseIf PZD->PZD_STATUS == "E"

				cLegenda := "BR_LARANJA"
			
			EndIf

	EndCase

Return(cLegenda)


//-------------------------------------------------------------------
/*/{Protheus.doc} fRefresh
Atualiza o browse.

@author By Wise

@since 29/09/2018
/*/
//-------------------------------------------------------------------

Static Function fRefresh(oView)

Local oModel
Local oModelPZB	:= oView:GetModel("PZBDETAIL")   	 
Local nLinePZB	:= oModelPZB:GetLine()
Local oModelPZC	:= oView:GetModel("PZCDETAIL")   	 
Local nLinePZC	:= oModelPZC:GetLine()

	CursorWait()

	oModel := FWLoadModel("TFINA080")

	//Ativa novo modelo
	oModel:Activate()

	//Seta o novo model carregado
	oView:SetModel( oModel )

	//Refresh dos componentes
	oView:Refresh()

	//Volta para a linha que estava posicionado
	oModel:GetModel("PZBDETAIL"):GoLine(nLinePZB)
	oModel:GetModel("PZCDETAIL"):GoLine(nLinePZC)

	CursorArrow()

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} fExecProc
Executa processo do job de acordo com a linha selecionada no browse.

@author By Wise

@since 20/10/2018
/*/
//-------------------------------------------------------------------

User Function fExecProc(cIdPZA)

Local cProgram	:= ""
Local aParam	:= {}
Local cParam	:= ""
Local cQuery	:= ""
Local cAlsCount	:= CriaTrab(Nil,.F.)

If !U_IsSrvLck(cIdPZA)

	//Query para buscar usuários com permissões especiais.
	cQuery := " SELECT X5_CHAVE, X5_DESCRI "
	cQuery += " FROM " + RetSqlName("SX5") + " SX5 "
	cQuery += " WHERE X5_TABELA = 'JD' AND X5_CHAVE = '" + __cUserId + "' AND SX5.D_E_L_E_T_ = ' ' "

	If Select(cAlsCount) > 0; (cAlsCount)->(dbCloseArea()); Endif  
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlsCount,.T.,.T.)

	If (cAlsCount)->(Eof())
		
		lRet := .F.
		Help(" ",1, 'Help','TFINA080_ACT',"Usuário não possui permissão para esta ação." , 3, 0 )

		(cAlsCount)->(dbCloseArea())

		Return(lRet)
		
	Endif

	(cAlsCount)->(dbCloseArea())

	If MsgYesNo("Atenção: Você selecionou a opção Executar Processo para a integração: " + cIdPZA + " de forma imediata, deseja continuar?")

		DbSelectArea("PZA")
		PZA->(DbSetOrder(1))

		If PZA->(MsSeek(xFilial("PZA") + cIdPZA)) .And. PZA->PZA_TIPSRV == "S"

			cProgram := Alltrim(PZA->PZA_PROG)
			
			AaDD(aParam,PZA->PZA_URL)
			AaDD(aParam,PZA->PZA_ENDPOI)
			AaDD(aParam,PZA->PZA_SEGEND)
			
			StartJob(cProgram, GetEnvServer(), .F., .F., .F., , ,cEmpAnt, cFilAnt, dDataBase)

			//&(cProgram+"(.F., .F., , ,cEmpAnt, cFilAnt)")
			//&(cProgram+"()")
			
		Else
		
			cProgram := Alltrim(PZA->PZA_PROG)
			
			If "(" $ cProgram
				cParam := SubStr(cProgram, At("(", cProgram)+1)
				cParam := SubStr(cParam, 1, At(")", cParam)-1)
				// Obtem os parâmetros
				aParam := Strtokarr2( cParam, ",", .T.)
				// Obtem os valores absolutos dos parâmetros para enviar ao StarJob
				aEval(aParam, {|e, nX| aParam[nX] := &(e)})

				cProgram := SubStr(cProgram, 1, At("(", cProgram)-1)
			EndIf
			
			
			StartJob(cProgram, GetEnvServer(), .F., .F., .F., , ,cEmpAnt, cFilAnt, dDataBase)
			//&(cProgram+"(.F., .F., , ,cEmpAnt, cFilAnt)")
			//&(cProgram+"()")

		EndIf

	Else
		Help(" ",1, 'Help','TFINA080_REP',"Serviço cancelado pelo usuário." , 3, 0 )
	EndIf

Else
	Help(" ",1, 'Help','TFINA080_LCK',"O serviço já está em processamento por outro usuário." , 3, 0 )
EndIf

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} fAnalise
Exibe tea com analise resumida do contrato

@author By Wise

@since 20/10/2018
/*/
//-------------------------------------------------------------------

Static Function fAnalise()

Local cSql			:= ""
Local clAlias		:= CriaTrab(Nil,.F.)
Local oDlg			:= Nil
Local aHeader		:= {}
Local aCols			:= {}
Local alFields      := {}
Local oOK 			:= LoadBitmap( nil, "BTNOKSMALL_OCEAN"	)  
Local oNO 			:= LoadBitmap( nil, "BTNCANSMALL_OCEAN" )
Local nY
	
	cSql := " SELECT PZB_IDURL, PZB_ID, PZA_DESC, PZB_DATA, PZB_REGTOT, PZB_REGPRO, PZB_REGERR "
	cSql += " FROM " + RetSqlName("PZB") + " PZB "
	cSql += " INNER JOIN " + RetSqlName("PZA") + " PZA "
	cSql += " ON PZA_FILIAL = '" + xFilial("PZA") + "' AND PZB_IDURL = PZA_ID "
	cSql += " WHERE PZB_ID = (SELECT MAX(PZB_ID) FROM " + RetSqlName("PZB") + " AUX "
	cSql += " WHERE AUX.PZB_FILIAL = PZA.PZA_FILIAL AND AUX.PZB_IDURL = PZA.PZA_ID ) "
	cSql += " AND PZB.D_E_L_E_T_ = ' ' AND PZA.D_E_L_E_T_ = ' ' "

    If Select(clAlias) > 0; (clAlias)->(dbCloseArea()); Endif  
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),clAlias,.T.,.T.)

	TCSetField(clAlias, "PZB_DATA", "D")

    (clAlias)->(dbGoTop())
	
	If (clAlias)->(! Eof())
	
		dbSelectArea("SX3")
        SX3->(dbSetOrder(2)) 

        aadd(alFields, "PZB_IDURL" 	)
		aadd(alFields, "PZB_ID" 	)
        aadd(alFields, "PZA_DESC" 	)
        aadd(alFields, "PZB_DATA" 	)
        aadd(alFields, "PZB_REGTOT" )
        aadd(alFields, "PZB_REGPRO" )
        aadd(alFields, "PZB_REGERR" )

		//Criação do campo virtual para receber o bitmap.
		Aadd(aHeader, {	"OK",;
						"COR",;
						"@BMP",;
						1,;
						0,;
						.T.,;
						"",;
						"",;
						"",;
						"R",;
						"",;
						"",;
						.F.,;
						"V",;
						"",;
						"",;
						"",;
						"" })
        
        For nY := 1 To Len( alFields )
            If SX3->( dbSeek(alFields[ nY ] ) )
                Aadd( aHeader,{ TRIM(X3Titulo()), SX3->X3_CAMPO, SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_VALID, SX3->X3_USADO, SX3->X3_TIPO, , SX3->X3_CONTEXT })
            EndIf
        Next nY
        
        While (clAlias)->( !Eof() )
	
            Aadd( aCols, {} )

			//Adiciona bitmap
			If (clAlias)->PZB_REGERR > 0
				Aadd( aTail( aCols ), oNO )
			Else
				Aadd( aTail( aCols ), oOK )
			EndIf

            Aadd( aTail( aCols ), ( clAlias )->PZB_IDURL	)
			Aadd( aTail( aCols ), ( clAlias )->PZB_ID		)	
            Aadd( aTail( aCols ), ( clAlias )->PZA_DESC 	)
            Aadd( aTail( aCols ), ( clAlias )->PZB_DATA 	)	
            Aadd( aTail( aCols ), ( clAlias )->PZB_REGTOT 	)
            Aadd( aTail( aCols ), ( clAlias )->PZB_REGPRO 	)
            Aadd( aTail( aCols ), ( clAlias )->PZB_REGERR 	)

			Aadd( aTail( aCols ), .F.)

            ( clAlias )->( dbSkip() )

	    EndDo

		DEFINE MSDIALOG oDlg TITLE "Analise resumida" FROM 005,000 TO 040,150 OF oMainWnd 
	
		oGet := MsNewGetDados():New(005,005,100,232,0,,,,,,,,,,oDlg,aHeader,aCols)
		oGet:obrowse:align:= CONTROL_ALIGN_ALLCLIENT
		oGet:nAt := oGet:OBROWSE:NAT := 1
	
		EnchoiceBar(oDlg, {|| If(len(aCols)>0,lPosicio:=.T.,lPosicio:=.F.), oDlg:End() },{|| oDlg:End() },,{} )
 
		oDlg:aControls[Len(oDlg:aControls)]:cCaption    := "Analise resumida" 
		oDlg:aControls[Len(oDlg:aControls)]:cTitle 	    := "Analise resumida" 
	
		ACTIVATE MSDIALOG oDlg CENTERED
		
	Else
		Help(" ",1, 'Help','TFINA080_ANA', "Não há dados de log.", 3, 0 )
	EndIf
	
	(clAlias)->(dbCloseArea())

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fAltera
Valida controle de acessos para poder realizar alteração

@author By Wise

@since 20/10/2018
/*/
//-------------------------------------------------------------------

Static Function fAltera()

Local cQuery 	:= ""
Local cAlsCount	:= CriaTrab(Nil,.F.)
Local lRet		:= .T.

	//Query para buscar usuários com permissões especiais.
	cQuery := " SELECT X5_CHAVE, X5_DESCRI "
	cQuery += " FROM " + RetSqlName("SX5") + " SX5 "
	cQuery += " WHERE X5_TABELA = 'JD' AND X5_CHAVE = '" + __cUserId + "' AND SX5.D_E_L_E_T_ = ' ' "

	If Select(cAlsCount) > 0; (cAlsCount)->(dbCloseArea()); Endif  
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlsCount,.T.,.T.)

	If (cAlsCount)->(Eof())
		lRet := .F.
		Help(" ",1, 'Help','TFINA080_ACT',"Usuário não possui permissão para esta ação." , 3, 0 )
	Endif

	(cAlsCount)->(dbCloseArea())

	If lRet
		AxAltera( "PZA", PZA->(Recno()), 4 )
	EndIf

Return(lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} fAnalise
Exibe tea com analise resumida do contrato

@author By Wise

@since 20/10/2018
/*/
//-------------------------------------------------------------------

Static Function CriaPerg(cPerg)

	PutSx1(cPerg,"01","Da Data ?"		,"Da Data ?"		,"Da Data ?"	,"mv_ch1","D",08,0,0,"G","",""		,""		,"S","mv_par01","","","","","","","","","","","","","","")
	PutSx1(cPerg,"02","Ate Data ?"		,"Ate Data ?"		,"Ate Data ?"	,"mv_ch2","D",08,0,0,"G	","",""		,""		,"S","mv_par02","","","","","","","","","","","","","","")

Return
