#INCLUDE "PROTHEUS.CH"
#INCLUDE "UPDCISP.CH"

#DEFINE SIMPLES Char( 39 )
#DEFINE DUPLAS  Char( 34 )

#DEFINE CSSBOTAO	"QPushButton { color: #024670; "+;
"    border-image: url(rpo:fwstd_btn_nml.png) 3 3 3 3 stretch; "+;
"    border-top-width: 3px; "+;
"    border-left-width: 3px; "+;
"    border-right-width: 3px; "+;
"    border-bottom-width: 3px }"+;
"QPushButton:pressed {	color: #FFFFFF; "+;
"    border-image: url(rpo:fwstd_btn_prd.png) 3 3 3 3 stretch; "+;
"    border-top-width: 3px; "+;
"    border-left-width: 3px; "+;
"    border-right-width: 3px; "+;
"    border-bottom-width: 3px }"

//--------------------------------------------------------------------
/*/{Protheus.doc} UPDCISP
Função de update de dicionários para compatibilização

@author TOTVS Protheus
@since  02/05/2017
@obs    Gerado por EXPORDIC - V.5.4.1.2 EFS / Upd. V.4.21.17 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
User Function UPDCISP( cEmpAmb, cFilAmb )

Local   aSay      := {}
Local   aButton   := {}
Local   aMarcadas := {}
Local   cTitulo   := STR0001 //"ATUALIZAÇÃO DE DICIONÁRIOS E TABELAS"
Local   cDesc1    := STR0002 //"Esta rotina tem como função fazer  a atualização  dos dicionários do Sistema ( SX?/SIX )"
Local   cDesc2    := STR0003 //"Este processo deve ser executado em modo EXCLUSIVO, ou seja não podem haver outros"
Local   cDesc3    := STR0004 //"usuários  ou  jobs utilizando  o sistema.  É EXTREMAMENTE recomendavél  que  se  faça um"
Local   cDesc4    := STR0005 //"BACKUP  dos DICIONÁRIOS  e da  BASE DE DADOS antes desta atualização, para que caso "
Local   cDesc5    := STR0006 //"ocorram eventuais falhas, esse backup possa ser restaurado."
Local   cDesc6    := ""
Local   cDesc7    := ""
Local   lOk       := .F.
Local   lAuto     := ( cEmpAmb <> NIL .or. cFilAmb <> NIL )

Private oMainWnd  := NIL
Private oProcess  := NIL

#IFDEF TOP
	TCInternal( 5, "*OFF" ) // Desliga Refresh no Lock do Top
#ENDIF

__cInterNet := NIL
__lPYME     := .F.

Set Dele On

// Mensagens de Tela Inicial
aAdd( aSay, cDesc1 )
aAdd( aSay, cDesc2 )
aAdd( aSay, cDesc3 )
aAdd( aSay, cDesc4 )
aAdd( aSay, cDesc5 )
//aAdd( aSay, cDesc6 )
//aAdd( aSay, cDesc7 )

// Botoes Tela Inicial
aAdd(  aButton, {  1, .T., { || lOk := .T., FechaBatch() } } )
aAdd(  aButton, {  2, .T., { || lOk := .F., FechaBatch() } } )

If lAuto
	lOk := .T.
Else
	FormBatch(  cTitulo,  aSay,  aButton )
EndIf

If lOk
	If lAuto
		aMarcadas :={{ cEmpAmb, cFilAmb, "" }}
	Else
		
		aMarcadas := EscEmpresa()
	EndIf
	
	If !Empty( aMarcadas )
		If lAuto .OR. MsgNoYes( STR0007, cTitulo ) //"Confirma a atualização dos dicionários ?"
			oProcess := MsNewProcess():New( { | lEnd | lOk := FSTProc( @lEnd, aMarcadas, lAuto ) }, STR0008, STR0009, .F. ) //"Atualizando"###"Aguarde, atualizando ..."
			oProcess:Activate()
			
			If lAuto
				If lOk
					MsgStop( STR0010, "UPDCISP" ) //"Atualização Realizada."
				Else
					MsgStop( STR0011, "UPDCISP" ) //"Atualização não Realizada."
				EndIf
				dbCloseAll()
			Else
				If lOk
					Final( STR0010 ) //"Atualização Realizada."
				Else
					Final( STR0011 ) //"Atualização não Realizada."
				EndIf
			EndIf
			
		Else
			Final( STR0011 ) //"Atualização não Realizada."
			
		EndIf
		
	Else
		Final( STR0011 ) //"Atualização não Realizada."
		
	EndIf
	
EndIf

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSTProc
Função de processamento da gravação dos arquivos

@author TOTVS Protheus
@since  02/05/2017
@obs    Gerado por EXPORDIC - V.5.4.1.2 EFS / Upd. V.4.21.17 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSTProc( lEnd, aMarcadas, lAuto )
Local   aInfo     := {}
Local   aRecnoSM0 := {}
Local   cAux      := ""
Local   cFile     := ""
Local   cFileLog  := ""
Local   cMask     := STR0012 + "(*.TXT)|*.txt|" //"Arquivos Texto"
Local   cTCBuild  := "TCGetBuild"
Local   cTexto    := ""
Local   cTopBuild := ""
Local   lOpen     := .F.
Local   lRet      := .T.
Local   nI        := 0
Local   nPos      := 0
Local   nRecno    := 0
Local   nX        := 0
Local   oDlg      := NIL
Local   oFont     := NIL
Local   oMemo     := NIL

Private aArqUpd   := {}

If ( lOpen := MyOpenSm0(.T.) )
	
	dbSelectArea( "SM0" )
	dbGoTop()
	
	While !SM0->( EOF() )
		// Só adiciona no aRecnoSM0 se a empresa for diferente
		If aScan( aRecnoSM0, { |x| x[2] == SM0->M0_CODIGO } ) == 0 ;
			.AND. aScan( aMarcadas, { |x| x[1] == SM0->M0_CODIGO } ) > 0
			aAdd( aRecnoSM0, { Recno(), SM0->M0_CODIGO } )
		EndIf
		SM0->( dbSkip() )
	End
	
	SM0->( dbCloseArea() )
	
	If lOpen
		
		For nI := 1 To Len( aRecnoSM0 )
			
			If !( lOpen := MyOpenSm0(.F.) )
				MsgStop( STR0013 + aRecnoSM0[nI][2] + STR0014 ) //"Atualização da empresa "###" não efetuada."
				Exit
			EndIf
			
			SM0->( dbGoTo( aRecnoSM0[nI][1] ) )
			
			RpcSetType( 3 )
			RpcSetEnv( SM0->M0_CODIGO, SM0->M0_CODFIL )
			
			lMsFinalAuto := .F.
			lMsHelpAuto  := .F.
			
			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( Replicate( " ", 128 ) )
			AutoGrLog( STR0032 ) //"LOG DA ATUALIZAÇÃO DOS DICIONÁRIOS"
			AutoGrLog( Replicate( " ", 128 ) )
			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( " " )
			AutoGrLog( STR0033 ) //" Dados Ambiente"
			AutoGrLog( " --------------------" )
			AutoGrLog( STR0034 + cEmpAnt + "/" + cFilAnt ) //" Empresa / Filial...: "
			AutoGrLog( STR0035 + Capital( AllTrim( GetAdvFVal( "SM0", "M0_NOMECOM", cEmpAnt + cFilAnt, 1, "" ) ) ) ) //" Nome Empresa.......: "
			AutoGrLog( STR0036 + Capital( AllTrim( GetAdvFVal( "SM0", "M0_FILIAL" , cEmpAnt + cFilAnt, 1, "" ) ) ) ) //" Nome Filial........: "
			AutoGrLog( STR0037 + DtoC( dDataBase ) ) //" DataBase...........: "
			AutoGrLog( STR0038 + DtoC( Date() )  + " / " + Time() ) //" Data / Hora Ínicio.: "
			AutoGrLog( STR0039 + GetEnvServer()  ) //" Environment........: "
			AutoGrLog( STR0040 + GetSrvProfString( "StartPath", "" ) ) //" StartPath..........: "
			AutoGrLog( STR0041 + GetSrvProfString( "RootPath" , "" ) ) //" RootPath...........: "
			AutoGrLog( STR0042 + GetVersao(.T.) ) //" Versão.............: "
			AutoGrLog( STR0043 + __cUserId + " " +  cUserName ) //" Usuário TOTVS .....: "
			AutoGrLog( STR0044 + GetComputerName() ) //" Computer Name......: "
			
			aInfo   := GetUserInfo()
			If ( nPos    := aScan( aInfo,{ |x,y| x[3] == ThreadId() } ) ) > 0
				AutoGrLog( " " )
				AutoGrLog( STR0045 ) //" Dados Thread"
				AutoGrLog( " --------------------" )
				AutoGrLog( STR0046 + aInfo[nPos][1] ) //" Usuário da Rede....: "
				AutoGrLog( STR0047 + aInfo[nPos][2] ) //" Estação............: "
				AutoGrLog( STR0048 + aInfo[nPos][5] ) //" Programa Inicial...: "
				AutoGrLog( STR0039 + aInfo[nPos][6] ) //" Environment........: "
				AutoGrLog( STR0049 + AllTrim( StrTran( StrTran( aInfo[nPos][7], Chr( 13 ), "" ), Chr( 10 ), "" ) ) ) //" Conexão............: "
			EndIf
			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( " " )
			
			If !lAuto
				AutoGrLog( Replicate( "-", 128 ) )
				AutoGrLog( STR0015 + SM0->M0_CODIGO + "/" + SM0->M0_NOME + CRLF ) //"Empresa : "
			EndIf
			
			oProcess:SetRegua1( 8 )
			
			//------------------------------------
			// Atualiza o dicionário SX2
			//------------------------------------
			oProcess:IncRegua1( STR0016 + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." ) //"Dicionário de arquivos"
			FSAtuSX2()
			
			//------------------------------------
			// Atualiza o dicionário SX3
			//------------------------------------
			FSAtuSX3()
			
			//------------------------------------
			// Atualiza o dicionário SIX
			//------------------------------------
			oProcess:IncRegua1( STR0017 + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." ) //"Dicionário de índices"
			FSAtuSIX()
			
			oProcess:IncRegua1( STR0018 + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." ) //"Dicionário de dados"
			oProcess:IncRegua2( STR0019 ) //"Atualizando campos/índices"
			
			// Alteração física dos arquivos
			__SetX31Mode( .F. )
			
			If FindFunction(cTCBuild)
				cTopBuild := &cTCBuild.()
			EndIf
			
			For nX := 1 To Len( aArqUpd )
				
				If cTopBuild >= "20090811" .AND. TcInternal( 89 ) == "CLOB_SUPPORTED"
					If ( ( aArqUpd[nX] >= "NQ " .AND. aArqUpd[nX] <= "NZZ" ) .OR. ( aArqUpd[nX] >= "O0 " .AND. aArqUpd[nX] <= "NZZ" ) ) .AND.;
						!aArqUpd[nX] $ "NQD,NQF,NQP,NQT"
						TcInternal( 25, "CLOB" )
					EndIf
				EndIf
				
				If Select( aArqUpd[nX] ) > 0
					dbSelectArea( aArqUpd[nX] )
					dbCloseArea()
				EndIf
				
				X31UpdTable( aArqUpd[nX] )
				
				If __GetX31Error()
					Alert( __GetX31Trace() )
					MsgStop( STR0020 + aArqUpd[nX] + STR0021, STR0022 ) //"Ocorreu um erro desconhecido durante a atualização da tabela : "###". Verifique a integridade do dicionário e da tabela."###"ATENÇÃO"
					AutoGrLog( STR0023 + aArqUpd[nX] ) //"Ocorreu um erro desconhecido durante a atualização da estrutura da tabela : "
				EndIf
				
				If cTopBuild >= "20090811" .AND. TcInternal( 89 ) == "CLOB_SUPPORTED"
					TcInternal( 25, "OFF" )
				EndIf
				
			Next nX
			
			//------------------------------------
			// Atualiza o dicionário SX6
			//------------------------------------
			oProcess:IncRegua1( STR0024 + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." ) //"Dicionário de parâmetros"
			FSAtuSX6()
			
			//------------------------------------
			// Atualiza o dicionário SXB
			//------------------------------------
			oProcess:IncRegua1( STR0027 + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." ) //"Dicionário de consultas padrão"
			FSAtuSXB()
			
			//------------------------------------
			// Atualiza os helps
			//------------------------------------
			oProcess:IncRegua1( STR0031 + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." ) //"Helps de Campo"
			FSAtuHlp()
			
			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( STR0050 + DtoC( Date() ) + " / " + Time() ) //" Data / Hora Final.: "
			AutoGrLog( Replicate( "-", 128 ) )
			
			RpcClearEnv()
			
		Next nI
		
		If !lAuto
			
			cTexto := LeLog()
			
			Define Font oFont Name "Mono AS" Size 5, 12
			
			Define MsDialog oDlg Title STR0051 From 3, 0 to 340, 417 Pixel //"Atualização concluida."
			
			@ 5, 5 Get oMemo Var cTexto Memo Size 200, 145 Of oDlg Pixel
			oMemo:bRClicked := { || AllwaysTrue() }
			oMemo:oFont     := oFont
			
			Define SButton From 153, 175 Type  1 Action oDlg:End() Enable Of oDlg Pixel // Apaga
			Define SButton From 153, 145 Type 13 Action ( cFile := cGetFile( cMask, "" ), If( cFile == "", .T., ;
			MemoWrite( cFile, cTexto ) ) ) Enable Of oDlg Pixel
			
			Activate MsDialog oDlg Center
			
		EndIf
		
	EndIf
	
Else
	
	lRet := .F.
	
EndIf

Return lRet


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSX2
Função de processamento da gravação do SX2 - Arquivos

@author TOTVS Protheus
@since  02/05/2017
@obs    Gerado por EXPORDIC - V.5.4.1.2 EFS / Upd. V.4.21.17 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSX2()
Local aEstrut   := {}
Local aSX2      := {}
Local cAlias    := ""
Local cEmpr     := ""
Local cPath     := ""
Local nI        := 0
Local nJ        := 0

AutoGrLog( STR0055 + " SX2" + CRLF ) //"Ínicio da Atualização"

aEstrut := { "X2_CHAVE"  , "X2_PATH"   , "X2_ARQUIVO", "X2_NOME"   , "X2_NOMESPA", "X2_NOMEENG", "X2_MODO"   , ;
"X2_TTS"    , "X2_ROTINA" , "X2_PYME"   , "X2_UNICO"  , "X2_DISPLAY", "X2_SYSOBJ" , "X2_USROBJ" , ;
"X2_MODOEMP", "X2_MODOUN" , "X2_MODULO" }


dbSelectArea( "SX2" )
SX2->( dbSetOrder( 1 ) )
SX2->( dbGoTop() )
cPath := SX2->X2_PATH
cPath := IIf( Right( AllTrim( cPath ), 1 ) <> "\", PadR( AllTrim( cPath ) + "\", Len( cPath ) ), cPath )
cEmpr := Substr( SX2->X2_ARQUIVO, 4 )

//
// Tabela SZR
//
aAdd( aSX2, { ;
'SZR'																	, ; //X2_CHAVE
cPath																	, ; //X2_PATH
'SZR'+cEmpr																, ; //X2_ARQUIVO
'STATUS RECEITA FEDERAL R.RATIN'										, ; //X2_NOME
'STATUS RECEITA FEDERAL R.RATIN'										, ; //X2_NOMESPA
'STATUS RECEITA FEDERAL R.RATIN'										, ; //X2_NOMEENG
'C'																		, ; //X2_MODO
''																		, ; //X2_TTS
''																		, ; //X2_ROTINA
''																		, ; //X2_PYME
''																		, ; //X2_UNICO
''																		, ; //X2_DISPLAY
''																		, ; //X2_SYSOBJ
''																		, ; //X2_USROBJ
'C'																		, ; //X2_MODOEMP
'C'																		, ; //X2_MODOUN
0																		} ) //X2_MODULO

//
// Tabela SZS
//
aAdd( aSX2, { ;
'SZS'																	, ; //X2_CHAVE
cPath																	, ; //X2_PATH
'SZS'+cEmpr																, ; //X2_ARQUIVO
'STATUS SINTEGRA R.RATING'												, ; //X2_NOME
'STATUS SINTEGRA R.RATING'												, ; //X2_NOMESPA
'STATUS SINTEGRA R.RATING'												, ; //X2_NOMEENG
'C'																		, ; //X2_MODO
''																		, ; //X2_TTS
''																		, ; //X2_ROTINA
''																		, ; //X2_PYME
''																		, ; //X2_UNICO
''																		, ; //X2_DISPLAY
''																		, ; //X2_SYSOBJ
''																		, ; //X2_USROBJ
'C'																		, ; //X2_MODOEMP
'C'																		, ; //X2_MODOUN
0																		} ) //X2_MODULO

//
// Tabela SZU
//
aAdd( aSX2, { ;
'SZU'																	, ; //X2_CHAVE
cPath																	, ; //X2_PATH
'SZU'+cEmpr																, ; //X2_ARQUIVO
'TABELA DE RISK RATING CLIENTES'										, ; //X2_NOME
'TABELA DE RISK RATING CLIENTES'										, ; //X2_NOMESPA
'TABELA DE RISK RATING CLIENTES'										, ; //X2_NOMEENG
'C'																		, ; //X2_MODO
''																		, ; //X2_TTS
''																		, ; //X2_ROTINA
''																		, ; //X2_PYME
''																		, ; //X2_UNICO
''																		, ; //X2_DISPLAY
''																		, ; //X2_SYSOBJ
''																		, ; //X2_USROBJ
'C'																		, ; //X2_MODOEMP
'C'																		, ; //X2_MODOUN
0																		} ) //X2_MODULO

//
// Tabela SZV
//
aAdd( aSX2, { ;
'SZV'																	, ; //X2_CHAVE
cPath																	, ; //X2_PATH
'SZV'+cEmpr																, ; //X2_ARQUIVO
'VALIDACAO CREDITO RISK RATING'											, ; //X2_NOME
'VALIDACAO CREDITO RISK RATING'											, ; //X2_NOMESPA
'VALIDACAO CREDITO RISK RATING'											, ; //X2_NOMEENG
'E'																		, ; //X2_MODO
''																		, ; //X2_TTS
''																		, ; //X2_ROTINA
''																		, ; //X2_PYME
''																		, ; //X2_UNICO
''																		, ; //X2_DISPLAY
''																		, ; //X2_SYSOBJ
''																		, ; //X2_USROBJ
'E'																		, ; //X2_MODOEMP
'E'																		, ; //X2_MODOUN
0																		} ) //X2_MODULO

//
// Atualizando dicionário
//
oProcess:SetRegua2( Len( aSX2 ) )

dbSelectArea( "SX2" )
dbSetOrder( 1 )

For nI := 1 To Len( aSX2 )
	
	oProcess:IncRegua2( STR0056 ) //"Atualizando Arquivos (SX2)..."
	
	If !SX2->( dbSeek( aSX2[nI][1] ) )
		
		If !( aSX2[nI][1] $ cAlias )
			cAlias += aSX2[nI][1] + "/"
			AutoGrLog( STR0057 + aSX2[nI][1] ) //"Foi incluída a tabela "
		EndIf
		
		RecLock( "SX2", .T. )
		For nJ := 1 To Len( aSX2[nI] )
			If FieldPos( aEstrut[nJ] ) > 0
				If AllTrim( aEstrut[nJ] ) == "X2_ARQUIVO"
					FieldPut( FieldPos( aEstrut[nJ] ), SubStr( aSX2[nI][nJ], 1, 3 ) + cEmpAnt +  "0" )
				Else
					FieldPut( FieldPos( aEstrut[nJ] ), aSX2[nI][nJ] )
				EndIf
			EndIf
		Next nJ
		MsUnLock()
		
	EndIf
	
Next nI

AutoGrLog( CRLF + STR0060 + " SX2" + CRLF + Replicate( "-", 128 ) + CRLF ) //"Final da Atualização"

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSX3
Função de processamento da gravação do SX3 - Campos

@author TOTVS Protheus
@since  02/05/2017
@obs    Gerado por EXPORDIC - V.5.4.1.2 EFS / Upd. V.4.21.17 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSX3()
Local aEstrut   := {}
Local aSX3      := {}
Local cAlias    := ""
Local cAliasAtu := ""
Local cMsg      := ""
Local cSeqAtu   := ""
Local cX3Campo  := ""
Local cX3Dado   := ""
Local lTodosNao := .F.
Local lTodosSim := .F.
Local nI        := 0
Local nJ        := 0
Local nOpcA     := 0
Local nPosArq   := 0
Local nPosCpo   := 0
Local nPosOrd   := 0
Local nPosSXG   := 0
Local nPosTam   := 0
Local nPosVld   := 0
Local nSeqAtu   := 0
Local nTamSeek  := Len( SX3->X3_CAMPO )

AutoGrLog( STR0055 + " SX3" + CRLF ) //"Ínicio da Atualização"

aEstrut := { { "X3_ARQUIVO", 0 }, { "X3_ORDEM"  , 0 }, { "X3_CAMPO"  , 0 }, { "X3_TIPO"   , 0 }, { "X3_TAMANHO", 0 }, { "X3_DECIMAL", 0 }, { "X3_TITULO" , 0 }, ;
{ "X3_TITSPA" , 0 }, { "X3_TITENG" , 0 }, { "X3_DESCRIC", 0 }, { "X3_DESCSPA", 0 }, { "X3_DESCENG", 0 }, { "X3_PICTURE", 0 }, { "X3_VALID"  , 0 }, ;
{ "X3_USADO"  , 0 }, { "X3_RELACAO", 0 }, { "X3_F3"     , 0 }, { "X3_NIVEL"  , 0 }, { "X3_RESERV" , 0 }, { "X3_CHECK"  , 0 }, { "X3_TRIGGER", 0 }, ;
{ "X3_PROPRI" , 0 }, { "X3_BROWSE" , 0 }, { "X3_VISUAL" , 0 }, { "X3_CONTEXT", 0 }, { "X3_OBRIGAT", 0 }, { "X3_VLDUSER", 0 }, { "X3_CBOX"   , 0 }, ;
{ "X3_CBOXSPA", 0 }, { "X3_CBOXENG", 0 }, { "X3_PICTVAR", 0 }, { "X3_WHEN"   , 0 }, { "X3_INIBRW" , 0 }, { "X3_GRPSXG" , 0 }, { "X3_FOLDER" , 0 }, ;
{ "X3_CONDSQL", 0 }, { "X3_CHKSQL" , 0 }, { "X3_IDXSRV" , 0 }, { "X3_ORTOGRA", 0 }, { "X3_TELA"   , 0 }, { "X3_IDXFLD" , 0 }, { "X3_AGRUP"  , 0 }, ;
{ "X3_PYME"   , 0 } }

aEval( aEstrut, { |x| x[2] := SX3->( FieldPos( x[1] ) ) } )


//
// Campos Tabela SA1
//
aAdd( aSX3, { ;
'SA1'																	, ; //X3_ARQUIVO
'O1'																	, ; //X3_ORDEM
'A1_XMSGCIS'															, ; //X3_CAMPO
'C'																		, ; //X3_TIPO
35																		, ; //X3_TAMANHO
0																		, ; //X3_DECIMAL
'Msg.Atu.Risk'															, ; //X3_TITULO
'Msg.Atu.Risk'															, ; //X3_TITSPA
'Msg.Atu.Risk'															, ; //X3_TITENG
'Msg. Atualizacao Risk Rat'												, ; //X3_DESCRIC
'Msg. Atualizacao Risk Rat'												, ; //X3_DESCSPA
'Msg. Atualizacao Risk Rat'												, ; //X3_DESCENG
'@!'																	, ; //X3_PICTURE
''																		, ; //X3_VALID
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
''																		, ; //X3_RELACAO
''																		, ; //X3_F3
0																		, ; //X3_NIVEL
Chr(254) + Chr(192)														, ; //X3_RESERV
''																		, ; //X3_CHECK
''																		, ; //X3_TRIGGER
'U'																		, ; //X3_PROPRI
'S'																		, ; //X3_BROWSE
'V'																		, ; //X3_VISUAL
'R'																		, ; //X3_CONTEXT
''																		, ; //X3_OBRIGAT
''																		, ; //X3_VLDUSER
''																		, ; //X3_CBOX
''																		, ; //X3_CBOXSPA
''																		, ; //X3_CBOXENG
''																		, ; //X3_PICTVAR
''																		, ; //X3_WHEN
''																		, ; //X3_INIBRW
''																		, ; //X3_GRPSXG
''																		, ; //X3_FOLDER
''																		, ; //X3_CONDSQL
''																		, ; //X3_CHKSQL
''																		, ; //X3_IDXSRV
'N'																		, ; //X3_ORTOGRA
''																		, ; //X3_TELA
'N'																		, ; //X3_IDXFLD
''																		, ; //X3_AGRUP
''																		} ) //X3_PYME

//
// Campos Tabela SC5
//
aAdd( aSX3, { ;
'SC5'																	, ; //X3_ARQUIVO
'F1'																	, ; //X3_ORDEM
'C5_XAVISO'																, ; //X3_CAMPO
'C'																		, ; //X3_TIPO
35																		, ; //X3_TAMANHO
0																		, ; //X3_DECIMAL
'Sit.Cre.Risk'															, ; //X3_TITULO
'Sit.Cre.Risk'															, ; //X3_TITSPA
'Sit.Cre.Risk'															, ; //X3_TITENG
'Situacao Credito Risk'													, ; //X3_DESCRIC
'Situacao Credito Risk'													, ; //X3_DESCSPA
'Situacao Credito Risk'													, ; //X3_DESCENG
'@!'																	, ; //X3_PICTURE
''																		, ; //X3_VALID
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
''																		, ; //X3_RELACAO
''																		, ; //X3_F3
0																		, ; //X3_NIVEL
Chr(254) + Chr(192)														, ; //X3_RESERV
''																		, ; //X3_CHECK
''																		, ; //X3_TRIGGER
'U'																		, ; //X3_PROPRI
'S'																		, ; //X3_BROWSE
'V'																		, ; //X3_VISUAL
'R'																		, ; //X3_CONTEXT
''																		, ; //X3_OBRIGAT
''																		, ; //X3_VLDUSER
''																		, ; //X3_CBOX
''																		, ; //X3_CBOXSPA
''																		, ; //X3_CBOXENG
''																		, ; //X3_PICTVAR
''																		, ; //X3_WHEN
''																		, ; //X3_INIBRW
''																		, ; //X3_GRPSXG
''																		, ; //X3_FOLDER
''																		, ; //X3_CONDSQL
''																		, ; //X3_CHKSQL
''																		, ; //X3_IDXSRV
'N'																		, ; //X3_ORTOGRA
''																		, ; //X3_TELA
'N'																		, ; //X3_IDXFLD
''																		, ; //X3_AGRUP
''																		} ) //X3_PYME

//
// Campos Tabela SC9
//
aAdd( aSX3, { ;
'SC9'																	, ; //X3_ARQUIVO
'62'																	, ; //X3_ORDEM
'C9_XAVISO'																, ; //X3_CAMPO
'C'																		, ; //X3_TIPO
35																		, ; //X3_TAMANHO
0																		, ; //X3_DECIMAL
'Sit.Cre.Risk'															, ; //X3_TITULO
'Sit.Cre.Risk'															, ; //X3_TITSPA
'Sit.Cre.Risk'															, ; //X3_TITENG
'Situacao Credito Risk'													, ; //X3_DESCRIC
'Situacao Credito Risk'													, ; //X3_DESCSPA
'Situacao Credito Risk'													, ; //X3_DESCENG
'@!'																	, ; //X3_PICTURE
''																		, ; //X3_VALID
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
''																		, ; //X3_RELACAO
''																		, ; //X3_F3
0																		, ; //X3_NIVEL
Chr(254) + Chr(192)														, ; //X3_RESERV
''																		, ; //X3_CHECK
''																		, ; //X3_TRIGGER
'U'																		, ; //X3_PROPRI
'S'																		, ; //X3_BROWSE
'V'																		, ; //X3_VISUAL
'V'																		, ; //X3_CONTEXT
''																		, ; //X3_OBRIGAT
''																		, ; //X3_VLDUSER
''																		, ; //X3_CBOX
''																		, ; //X3_CBOXSPA
''																		, ; //X3_CBOXENG
''																		, ; //X3_PICTVAR
''																		, ; //X3_WHEN
"RetField('SC5',1,xFilial('SC5')+SC9->C9_PEDIDO,'SC5->C5_XAVISO')"		, ; //X3_INIBRW
''																		, ; //X3_GRPSXG
''																		, ; //X3_FOLDER
''																		, ; //X3_CONDSQL
''																		, ; //X3_CHKSQL
''																		, ; //X3_IDXSRV
'N'																		, ; //X3_ORTOGRA
''																		, ; //X3_TELA
'N'																		, ; //X3_IDXFLD
''																		, ; //X3_AGRUP
''																		} ) //X3_PYME

//
// Campos Tabela SZR
//
aAdd( aSX3, { ;
'SZR'																	, ; //X3_ARQUIVO
'01'																	, ; //X3_ORDEM
'ZR_FILIAL'																, ; //X3_CAMPO
'C'																		, ; //X3_TIPO
2																		, ; //X3_TAMANHO
0																		, ; //X3_DECIMAL
'Filial'																, ; //X3_TITULO
'Sucursal'																, ; //X3_TITSPA
'Branch'																, ; //X3_TITENG
'Filial do Sistema'														, ; //X3_DESCRIC
'Sucursal'																, ; //X3_DESCSPA
'Branch of the System'													, ; //X3_DESCENG
'@!'																	, ; //X3_PICTURE
''																		, ; //X3_VALID
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
''																		, ; //X3_RELACAO
''																		, ; //X3_F3
1																		, ; //X3_NIVEL
Chr(254) + Chr(192)														, ; //X3_RESERV
''																		, ; //X3_CHECK
''																		, ; //X3_TRIGGER
'U'																		, ; //X3_PROPRI
'N'																		, ; //X3_BROWSE
''																		, ; //X3_VISUAL
''																		, ; //X3_CONTEXT
''																		, ; //X3_OBRIGAT
''																		, ; //X3_VLDUSER
''																		, ; //X3_CBOX
''																		, ; //X3_CBOXSPA
''																		, ; //X3_CBOXENG
''																		, ; //X3_PICTVAR
''																		, ; //X3_WHEN
''																		, ; //X3_INIBRW
'033'																	, ; //X3_GRPSXG
''																		, ; //X3_FOLDER
''																		, ; //X3_CONDSQL
''																		, ; //X3_CHKSQL
''																		, ; //X3_IDXSRV
''																		, ; //X3_ORTOGRA
''																		, ; //X3_TELA
''																		, ; //X3_IDXFLD
''																		, ; //X3_AGRUP
''																		} ) //X3_PYME

aAdd( aSX3, { ;
'SZR'																	, ; //X3_ARQUIVO
'02'																	, ; //X3_ORDEM
'ZR_CODIGO'																, ; //X3_CAMPO
'C'																		, ; //X3_TIPO
2																		, ; //X3_TAMANHO
0																		, ; //X3_DECIMAL
'Cod. Status'															, ; //X3_TITULO
'Cod. Status'															, ; //X3_TITSPA
'Cod. Status'															, ; //X3_TITENG
'Codigo do Status'														, ; //X3_DESCRIC
'Codigo do Status'														, ; //X3_DESCSPA
'Codigo do Status'														, ; //X3_DESCENG
'@!'																	, ; //X3_PICTURE
''																		, ; //X3_VALID
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
'GETSX8NUM("SZR", "ZR_CODIGO")'											, ; //X3_RELACAO
''																		, ; //X3_F3
0																		, ; //X3_NIVEL
Chr(254) + Chr(192)														, ; //X3_RESERV
''																		, ; //X3_CHECK
''																		, ; //X3_TRIGGER
'U'																		, ; //X3_PROPRI
'S'																		, ; //X3_BROWSE
'A'																		, ; //X3_VISUAL
'R'																		, ; //X3_CONTEXT
'€'																		, ; //X3_OBRIGAT
''																		, ; //X3_VLDUSER
''																		, ; //X3_CBOX
''																		, ; //X3_CBOXSPA
''																		, ; //X3_CBOXENG
''																		, ; //X3_PICTVAR
''																		, ; //X3_WHEN
''																		, ; //X3_INIBRW
''																		, ; //X3_GRPSXG
''																		, ; //X3_FOLDER
''																		, ; //X3_CONDSQL
''																		, ; //X3_CHKSQL
''																		, ; //X3_IDXSRV
'N'																		, ; //X3_ORTOGRA
''																		, ; //X3_TELA
'N'																		, ; //X3_IDXFLD
''																		, ; //X3_AGRUP
''																		} ) //X3_PYME

aAdd( aSX3, { ;
'SZR'																	, ; //X3_ARQUIVO
'03'																	, ; //X3_ORDEM
'ZR_DESC'																, ; //X3_CAMPO
'C'																		, ; //X3_TIPO
30																		, ; //X3_TAMANHO
0																		, ; //X3_DECIMAL
'Desc.Status'															, ; //X3_TITULO
'Desc.Status'															, ; //X3_TITSPA
'Desc.Status'															, ; //X3_TITENG
'Descricao do Status'													, ; //X3_DESCRIC
'Descricao do Status'													, ; //X3_DESCSPA
'Descricao do Status'													, ; //X3_DESCENG
'@!'																	, ; //X3_PICTURE
''																		, ; //X3_VALID
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
''																		, ; //X3_RELACAO
''																		, ; //X3_F3
0																		, ; //X3_NIVEL
Chr(254) + Chr(192)														, ; //X3_RESERV
''																		, ; //X3_CHECK
''																		, ; //X3_TRIGGER
'U'																		, ; //X3_PROPRI
'S'																		, ; //X3_BROWSE
'A'																		, ; //X3_VISUAL
'R'																		, ; //X3_CONTEXT
'€'																		, ; //X3_OBRIGAT
'Existchav("SZR",M->ZR_CODIGO+M->ZR_DESC, ,"EXISTSTATUS")'				, ; //X3_VLDUSER
''																		, ; //X3_CBOX
''																		, ; //X3_CBOXSPA
''																		, ; //X3_CBOXENG
''																		, ; //X3_PICTVAR
''																		, ; //X3_WHEN
''																		, ; //X3_INIBRW
''																		, ; //X3_GRPSXG
''																		, ; //X3_FOLDER
''																		, ; //X3_CONDSQL
''																		, ; //X3_CHKSQL
''																		, ; //X3_IDXSRV
'N'																		, ; //X3_ORTOGRA
''																		, ; //X3_TELA
'N'																		, ; //X3_IDXFLD
''																		, ; //X3_AGRUP
''																		} ) //X3_PYME

aAdd( aSX3, { ;
'SZR'																	, ; //X3_ARQUIVO
'04'																	, ; //X3_ORDEM
'ZR_ACAO'																, ; //X3_CAMPO
'C'																		, ; //X3_TIPO
1																		, ; //X3_TAMANHO
0																		, ; //X3_DECIMAL
'Qual Acao?'															, ; //X3_TITULO
'Qual Acao?'															, ; //X3_TITSPA
'Qual Acao?'															, ; //X3_TITENG
'Qual Acao a ser tomada'												, ; //X3_DESCRIC
'Qual Acao a ser tomada'												, ; //X3_DESCSPA
'Qual Acao a ser tomada'												, ; //X3_DESCENG
'@!'																	, ; //X3_PICTURE
''																		, ; //X3_VALID
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
''																		, ; //X3_RELACAO
''																		, ; //X3_F3
0																		, ; //X3_NIVEL
Chr(254) + Chr(192)														, ; //X3_RESERV
''																		, ; //X3_CHECK
''																		, ; //X3_TRIGGER
'U'																		, ; //X3_PROPRI
'S'																		, ; //X3_BROWSE
'A'																		, ; //X3_VISUAL
'R'																		, ; //X3_CONTEXT
'€'																		, ; //X3_OBRIGAT
'Pertence("LB")'														, ; //X3_VLDUSER
'L=Libera;B=Bloqueia'													, ; //X3_CBOX
'L=Libera;B=Bloqueia'													, ; //X3_CBOXSPA
'L=Libera;B=Bloqueia'													, ; //X3_CBOXENG
''																		, ; //X3_PICTVAR
''																		, ; //X3_WHEN
''																		, ; //X3_INIBRW
''																		, ; //X3_GRPSXG
''																		, ; //X3_FOLDER
''																		, ; //X3_CONDSQL
''																		, ; //X3_CHKSQL
''																		, ; //X3_IDXSRV
'N'																		, ; //X3_ORTOGRA
''																		, ; //X3_TELA
'N'																		, ; //X3_IDXFLD
''																		, ; //X3_AGRUP
''																		} ) //X3_PYME

//
// Campos Tabela SZS
//
aAdd( aSX3, { ;
'SZS'																	, ; //X3_ARQUIVO
'01'																	, ; //X3_ORDEM
'ZS_FILIAL'																, ; //X3_CAMPO
'C'																		, ; //X3_TIPO
2																		, ; //X3_TAMANHO
0																		, ; //X3_DECIMAL
'Filial'																, ; //X3_TITULO
'Sucursal'																, ; //X3_TITSPA
'Branch'																, ; //X3_TITENG
'Filial do Sistema'														, ; //X3_DESCRIC
'Sucursal'																, ; //X3_DESCSPA
'Branch of the System'													, ; //X3_DESCENG
'@!'																	, ; //X3_PICTURE
''																		, ; //X3_VALID
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
''																		, ; //X3_RELACAO
''																		, ; //X3_F3
1																		, ; //X3_NIVEL
Chr(254) + Chr(192)														, ; //X3_RESERV
''																		, ; //X3_CHECK
''																		, ; //X3_TRIGGER
'U'																		, ; //X3_PROPRI
'N'																		, ; //X3_BROWSE
''																		, ; //X3_VISUAL
''																		, ; //X3_CONTEXT
''																		, ; //X3_OBRIGAT
''																		, ; //X3_VLDUSER
''																		, ; //X3_CBOX
''																		, ; //X3_CBOXSPA
''																		, ; //X3_CBOXENG
''																		, ; //X3_PICTVAR
''																		, ; //X3_WHEN
''																		, ; //X3_INIBRW
'033'																	, ; //X3_GRPSXG
''																		, ; //X3_FOLDER
''																		, ; //X3_CONDSQL
''																		, ; //X3_CHKSQL
''																		, ; //X3_IDXSRV
''																		, ; //X3_ORTOGRA
''																		, ; //X3_TELA
''																		, ; //X3_IDXFLD
''																		, ; //X3_AGRUP
''																		} ) //X3_PYME

aAdd( aSX3, { ;
'SZS'																	, ; //X3_ARQUIVO
'02'																	, ; //X3_ORDEM
'ZS_CODIGO'																, ; //X3_CAMPO
'C'																		, ; //X3_TIPO
2																		, ; //X3_TAMANHO
0																		, ; //X3_DECIMAL
'Cod. Status'															, ; //X3_TITULO
'Cod. Status'															, ; //X3_TITSPA
'Cod. Status'															, ; //X3_TITENG
'Codigo do Status Sintegra'												, ; //X3_DESCRIC
'Codigo do Status Sintegra'												, ; //X3_DESCSPA
'Codigo do Status Sintegra'												, ; //X3_DESCENG
'@!'																	, ; //X3_PICTURE
''																		, ; //X3_VALID
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
'GETSX8NUM("SZS", "ZS_CODIGO")'											, ; //X3_RELACAO
''																		, ; //X3_F3
0																		, ; //X3_NIVEL
Chr(254) + Chr(192)														, ; //X3_RESERV
''																		, ; //X3_CHECK
''																		, ; //X3_TRIGGER
'U'																		, ; //X3_PROPRI
'S'																		, ; //X3_BROWSE
'A'																		, ; //X3_VISUAL
'R'																		, ; //X3_CONTEXT
'€'																		, ; //X3_OBRIGAT
''																		, ; //X3_VLDUSER
''																		, ; //X3_CBOX
''																		, ; //X3_CBOXSPA
''																		, ; //X3_CBOXENG
''																		, ; //X3_PICTVAR
''																		, ; //X3_WHEN
''																		, ; //X3_INIBRW
''																		, ; //X3_GRPSXG
''																		, ; //X3_FOLDER
''																		, ; //X3_CONDSQL
''																		, ; //X3_CHKSQL
''																		, ; //X3_IDXSRV
'N'																		, ; //X3_ORTOGRA
''																		, ; //X3_TELA
'N'																		, ; //X3_IDXFLD
''																		, ; //X3_AGRUP
''																		} ) //X3_PYME

aAdd( aSX3, { ;
'SZS'																	, ; //X3_ARQUIVO
'03'																	, ; //X3_ORDEM
'ZS_DESC'																, ; //X3_CAMPO
'C'																		, ; //X3_TIPO
30																		, ; //X3_TAMANHO
0																		, ; //X3_DECIMAL
'Desc. Status'															, ; //X3_TITULO
'Desc. Status'															, ; //X3_TITSPA
'Desc. Status'															, ; //X3_TITENG
'Descricao do Status Sint.'												, ; //X3_DESCRIC
'Descricao do Status Sint.'												, ; //X3_DESCSPA
'Descricao do Status Sint.'												, ; //X3_DESCENG
'@!'																	, ; //X3_PICTURE
''																		, ; //X3_VALID
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
''																		, ; //X3_RELACAO
''																		, ; //X3_F3
0																		, ; //X3_NIVEL
Chr(254) + Chr(192)														, ; //X3_RESERV
''																		, ; //X3_CHECK
''																		, ; //X3_TRIGGER
'U'																		, ; //X3_PROPRI
'S'																		, ; //X3_BROWSE
'A'																		, ; //X3_VISUAL
'R'																		, ; //X3_CONTEXT
'€'																		, ; //X3_OBRIGAT
'Existchav("SZS",M->ZS_CODIGO+M->ZS_DESC, ,"EXISTSTATUS")'				, ; //X3_VLDUSER
''																		, ; //X3_CBOX
''																		, ; //X3_CBOXSPA
''																		, ; //X3_CBOXENG
''																		, ; //X3_PICTVAR
''																		, ; //X3_WHEN
''																		, ; //X3_INIBRW
''																		, ; //X3_GRPSXG
''																		, ; //X3_FOLDER
''																		, ; //X3_CONDSQL
''																		, ; //X3_CHKSQL
''																		, ; //X3_IDXSRV
'N'																		, ; //X3_ORTOGRA
''																		, ; //X3_TELA
'N'																		, ; //X3_IDXFLD
''																		, ; //X3_AGRUP
''																		} ) //X3_PYME

aAdd( aSX3, { ;
'SZS'																	, ; //X3_ARQUIVO
'04'																	, ; //X3_ORDEM
'ZS_ACAO'																, ; //X3_CAMPO
'C'																		, ; //X3_TIPO
1																		, ; //X3_TAMANHO
0																		, ; //X3_DECIMAL
'Qual Acao?'															, ; //X3_TITULO
'Qual Acao?'															, ; //X3_TITSPA
'Qual Acao?'															, ; //X3_TITENG
'Qual Acao a ser tomada?'												, ; //X3_DESCRIC
'Qual Acao a ser tomada?'												, ; //X3_DESCSPA
'Qual Acao a ser tomada?'												, ; //X3_DESCENG
'@!'																	, ; //X3_PICTURE
''																		, ; //X3_VALID
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
''																		, ; //X3_RELACAO
''																		, ; //X3_F3
0																		, ; //X3_NIVEL
Chr(254) + Chr(192)														, ; //X3_RESERV
''																		, ; //X3_CHECK
''																		, ; //X3_TRIGGER
'U'																		, ; //X3_PROPRI
'S'																		, ; //X3_BROWSE
'A'																		, ; //X3_VISUAL
'R'																		, ; //X3_CONTEXT
'€'																		, ; //X3_OBRIGAT
'Pertence("LB")'														, ; //X3_VLDUSER
'L=Libera;B=Bloqueia'													, ; //X3_CBOX
'L=Libera;B=Bloqueia'													, ; //X3_CBOXSPA
'L=Libera;B=Bloqueia'													, ; //X3_CBOXENG
''																		, ; //X3_PICTVAR
''																		, ; //X3_WHEN
''																		, ; //X3_INIBRW
''																		, ; //X3_GRPSXG
''																		, ; //X3_FOLDER
''																		, ; //X3_CONDSQL
''																		, ; //X3_CHKSQL
''																		, ; //X3_IDXSRV
'N'																		, ; //X3_ORTOGRA
''																		, ; //X3_TELA
'N'																		, ; //X3_IDXFLD
''																		, ; //X3_AGRUP
''																		} ) //X3_PYME

//
// Campos Tabela SZU
//
aAdd( aSX3, { ;
'SZU'																	, ; //X3_ARQUIVO
'01'																	, ; //X3_ORDEM
'ZU_FILIAL'																, ; //X3_CAMPO
'C'																		, ; //X3_TIPO
2																		, ; //X3_TAMANHO
0																		, ; //X3_DECIMAL
'Filial'																, ; //X3_TITULO
'Sucursal'																, ; //X3_TITSPA
'Branch'																, ; //X3_TITENG
'Filial do Sistema'														, ; //X3_DESCRIC
'Sucursal'																, ; //X3_DESCSPA
'Branch of the System'													, ; //X3_DESCENG
'@!'																	, ; //X3_PICTURE
''																		, ; //X3_VALID
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
''																		, ; //X3_RELACAO
''																		, ; //X3_F3
1																		, ; //X3_NIVEL
Chr(254) + Chr(192)														, ; //X3_RESERV
''																		, ; //X3_CHECK
''																		, ; //X3_TRIGGER
'U'																		, ; //X3_PROPRI
'N'																		, ; //X3_BROWSE
''																		, ; //X3_VISUAL
''																		, ; //X3_CONTEXT
''																		, ; //X3_OBRIGAT
''																		, ; //X3_VLDUSER
''																		, ; //X3_CBOX
''																		, ; //X3_CBOXSPA
''																		, ; //X3_CBOXENG
''																		, ; //X3_PICTVAR
''																		, ; //X3_WHEN
''																		, ; //X3_INIBRW
'033'																	, ; //X3_GRPSXG
''																		, ; //X3_FOLDER
''																		, ; //X3_CONDSQL
''																		, ; //X3_CHKSQL
''																		, ; //X3_IDXSRV
''																		, ; //X3_ORTOGRA
''																		, ; //X3_TELA
''																		, ; //X3_IDXFLD
''																		, ; //X3_AGRUP
''																		} ) //X3_PYME

aAdd( aSX3, { ;
'SZU'																	, ; //X3_ARQUIVO
'02'																	, ; //X3_ORDEM
'ZU_DTFUNCL'															, ; //X3_CAMPO
'D'																		, ; //X3_TIPO
8																		, ; //X3_TAMANHO
0																		, ; //X3_DECIMAL
'Dt.Fund.Cli.'															, ; //X3_TITULO
'Dt.Fund.Cli.'															, ; //X3_TITSPA
'Dt.Fund.Cli.'															, ; //X3_TITENG
'Dt. Fundacao Cliente'													, ; //X3_DESCRIC
'Dt. Fundacao Cliente'													, ; //X3_DESCSPA
'Dt. Fundacao Cliente'													, ; //X3_DESCENG
''																		, ; //X3_PICTURE
''																		, ; //X3_VALID
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
''																		, ; //X3_RELACAO
''																		, ; //X3_F3
0																		, ; //X3_NIVEL
Chr(254) + Chr(192)														, ; //X3_RESERV
''																		, ; //X3_CHECK
''																		, ; //X3_TRIGGER
'U'																		, ; //X3_PROPRI
'S'																		, ; //X3_BROWSE
'A'																		, ; //X3_VISUAL
'R'																		, ; //X3_CONTEXT
''																		, ; //X3_OBRIGAT
''																		, ; //X3_VLDUSER
''																		, ; //X3_CBOX
''																		, ; //X3_CBOXSPA
''																		, ; //X3_CBOXENG
''																		, ; //X3_PICTVAR
''																		, ; //X3_WHEN
''																		, ; //X3_INIBRW
''																		, ; //X3_GRPSXG
''																		, ; //X3_FOLDER
''																		, ; //X3_CONDSQL
''																		, ; //X3_CHKSQL
''																		, ; //X3_IDXSRV
'N'																		, ; //X3_ORTOGRA
''																		, ; //X3_TELA
'N'																		, ; //X3_IDXFLD
''																		, ; //X3_AGRUP
''																		} ) //X3_PYME

aAdd( aSX3, { ;
'SZU'																	, ; //X3_ARQUIVO
'03'																	, ; //X3_ORDEM
'ZU_DTCONRF'															, ; //X3_CAMPO
'D'																		, ; //X3_TIPO
8																		, ; //X3_TAMANHO
0																		, ; //X3_DECIMAL
'Dt.Cons. RF'															, ; //X3_TITULO
'Dt.Cons. RF'															, ; //X3_TITSPA
'Dt.Cons. RF'															, ; //X3_TITENG
'Dt. Cons. Receita Federal'												, ; //X3_DESCRIC
'Dt. Cons. Receita Federal'												, ; //X3_DESCSPA
'Dt. Cons. Receita Federal'												, ; //X3_DESCENG
''																		, ; //X3_PICTURE
''																		, ; //X3_VALID
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
''																		, ; //X3_RELACAO
''																		, ; //X3_F3
0																		, ; //X3_NIVEL
Chr(254) + Chr(192)														, ; //X3_RESERV
''																		, ; //X3_CHECK
''																		, ; //X3_TRIGGER
'U'																		, ; //X3_PROPRI
'S'																		, ; //X3_BROWSE
'A'																		, ; //X3_VISUAL
'R'																		, ; //X3_CONTEXT
''																		, ; //X3_OBRIGAT
''																		, ; //X3_VLDUSER
''																		, ; //X3_CBOX
''																		, ; //X3_CBOXSPA
''																		, ; //X3_CBOXENG
''																		, ; //X3_PICTVAR
''																		, ; //X3_WHEN
''																		, ; //X3_INIBRW
''																		, ; //X3_GRPSXG
''																		, ; //X3_FOLDER
''																		, ; //X3_CONDSQL
''																		, ; //X3_CHKSQL
''																		, ; //X3_IDXSRV
'N'																		, ; //X3_ORTOGRA
''																		, ; //X3_TELA
'N'																		, ; //X3_IDXFLD
''																		, ; //X3_AGRUP
''																		} ) //X3_PYME

aAdd( aSX3, { ;
'SZU'																	, ; //X3_ARQUIVO
'04'																	, ; //X3_ORDEM
'ZU_DTCONSI'															, ; //X3_CAMPO
'D'																		, ; //X3_TIPO
8																		, ; //X3_TAMANHO
0																		, ; //X3_DECIMAL
'Dt. Cons.Sin'															, ; //X3_TITULO
'Dt. Cons.Sin'															, ; //X3_TITSPA
'Dt. Cons.Sin'															, ; //X3_TITENG
'Dt. Consulta SINTEGRA'													, ; //X3_DESCRIC
'Dt. Consulta SINTEGRA'													, ; //X3_DESCSPA
'Dt. Consulta SINTEGRA'													, ; //X3_DESCENG
''																		, ; //X3_PICTURE
''																		, ; //X3_VALID
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
''																		, ; //X3_RELACAO
''																		, ; //X3_F3
0																		, ; //X3_NIVEL
Chr(254) + Chr(192)														, ; //X3_RESERV
''																		, ; //X3_CHECK
''																		, ; //X3_TRIGGER
'U'																		, ; //X3_PROPRI
'S'																		, ; //X3_BROWSE
'A'																		, ; //X3_VISUAL
'R'																		, ; //X3_CONTEXT
''																		, ; //X3_OBRIGAT
''																		, ; //X3_VLDUSER
''																		, ; //X3_CBOX
''																		, ; //X3_CBOXSPA
''																		, ; //X3_CBOXENG
''																		, ; //X3_PICTVAR
''																		, ; //X3_WHEN
''																		, ; //X3_INIBRW
''																		, ; //X3_GRPSXG
''																		, ; //X3_FOLDER
''																		, ; //X3_CONDSQL
''																		, ; //X3_CHKSQL
''																		, ; //X3_IDXSRV
'N'																		, ; //X3_ORTOGRA
''																		, ; //X3_TELA
'N'																		, ; //X3_IDXFLD
''																		, ; //X3_AGRUP
''																		} ) //X3_PYME

aAdd( aSX3, { ;
'SZU'																	, ; //X3_ARQUIVO
'05'																	, ; //X3_ORDEM
'ZU_SEGASS'																, ; //X3_CAMPO
'C'																		, ; //X3_TIPO
2																		, ; //X3_TAMANHO
0																		, ; //X3_DECIMAL
'Seg. Associa'															, ; //X3_TITULO
'Seg. Associa'															, ; //X3_TITSPA
'Seg. Associa'															, ; //X3_TITENG
'Segmento Associado'													, ; //X3_DESCRIC
'Segmento Associado'													, ; //X3_DESCSPA
'Segmento Associado'													, ; //X3_DESCENG
'@!'																	, ; //X3_PICTURE
''																		, ; //X3_VALID
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
''																		, ; //X3_RELACAO
''																		, ; //X3_F3
0																		, ; //X3_NIVEL
Chr(254) + Chr(192)														, ; //X3_RESERV
''																		, ; //X3_CHECK
''																		, ; //X3_TRIGGER
'U'																		, ; //X3_PROPRI
'S'																		, ; //X3_BROWSE
'A'																		, ; //X3_VISUAL
'R'																		, ; //X3_CONTEXT
''																		, ; //X3_OBRIGAT
''																		, ; //X3_VLDUSER
''																		, ; //X3_CBOX
''																		, ; //X3_CBOXSPA
''																		, ; //X3_CBOXENG
''																		, ; //X3_PICTVAR
''																		, ; //X3_WHEN
''																		, ; //X3_INIBRW
''																		, ; //X3_GRPSXG
''																		, ; //X3_FOLDER
''																		, ; //X3_CONDSQL
''																		, ; //X3_CHKSQL
''																		, ; //X3_IDXSRV
'N'																		, ; //X3_ORTOGRA
''																		, ; //X3_TELA
'N'																		, ; //X3_IDXFLD
''																		, ; //X3_AGRUP
''																		} ) //X3_PYME

aAdd( aSX3, { ;
'SZU'																	, ; //X3_ARQUIVO
'06'																	, ; //X3_ORDEM
'ZU_VLLIMCR'															, ; //X3_CAMPO
'N'																		, ; //X3_TIPO
15																		, ; //X3_TAMANHO
2																		, ; //X3_DECIMAL
'Vl. Lim.Cred'															, ; //X3_TITULO
'Vl. Lim.Cred'															, ; //X3_TITSPA
'Vl. Lim.Cred'															, ; //X3_TITENG
'Valor Limite Credito'													, ; //X3_DESCRIC
'Valor Limite Credito'													, ; //X3_DESCSPA
'Valor Limite Credito'													, ; //X3_DESCENG
'@E 999,999,999,999.99'													, ; //X3_PICTURE
''																		, ; //X3_VALID
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
''																		, ; //X3_RELACAO
''																		, ; //X3_F3
0																		, ; //X3_NIVEL
Chr(254) + Chr(192)														, ; //X3_RESERV
''																		, ; //X3_CHECK
''																		, ; //X3_TRIGGER
'U'																		, ; //X3_PROPRI
'S'																		, ; //X3_BROWSE
'A'																		, ; //X3_VISUAL
'R'																		, ; //X3_CONTEXT
''																		, ; //X3_OBRIGAT
''																		, ; //X3_VLDUSER
''																		, ; //X3_CBOX
''																		, ; //X3_CBOXSPA
''																		, ; //X3_CBOXENG
''																		, ; //X3_PICTVAR
''																		, ; //X3_WHEN
''																		, ; //X3_INIBRW
''																		, ; //X3_GRPSXG
''																		, ; //X3_FOLDER
''																		, ; //X3_CONDSQL
''																		, ; //X3_CHKSQL
''																		, ; //X3_IDXSRV
'N'																		, ; //X3_ORTOGRA
''																		, ; //X3_TELA
'N'																		, ; //X3_IDXFLD
''																		, ; //X3_AGRUP
''																		} ) //X3_PYME

aAdd( aSX3, { ;
'SZU'																	, ; //X3_ARQUIVO
'07'																	, ; //X3_ORDEM
'ZU_QTDASLC'															, ; //X3_CAMPO
'N'																		, ; //X3_TIPO
4																		, ; //X3_TAMANHO
0																		, ; //X3_DECIMAL
'Qtd. Ass. LC'															, ; //X3_TITULO
'Qtd. Ass. LC'															, ; //X3_TITSPA
'Qtd. Ass. LC'															, ; //X3_TITENG
'Qtd. Associado com LC'													, ; //X3_DESCRIC
'Qtd. Associado com LC'													, ; //X3_DESCSPA
'Qtd. Associado com LC'													, ; //X3_DESCENG
'@E 9,999'																, ; //X3_PICTURE
''																		, ; //X3_VALID
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
''																		, ; //X3_RELACAO
''																		, ; //X3_F3
0																		, ; //X3_NIVEL
Chr(254) + Chr(192)														, ; //X3_RESERV
''																		, ; //X3_CHECK
''																		, ; //X3_TRIGGER
'U'																		, ; //X3_PROPRI
'S'																		, ; //X3_BROWSE
'A'																		, ; //X3_VISUAL
'R'																		, ; //X3_CONTEXT
''																		, ; //X3_OBRIGAT
''																		, ; //X3_VLDUSER
''																		, ; //X3_CBOX
''																		, ; //X3_CBOXSPA
''																		, ; //X3_CBOXENG
''																		, ; //X3_PICTVAR
''																		, ; //X3_WHEN
''																		, ; //X3_INIBRW
''																		, ; //X3_GRPSXG
''																		, ; //X3_FOLDER
''																		, ; //X3_CONDSQL
''																		, ; //X3_CHKSQL
''																		, ; //X3_IDXSRV
'N'																		, ; //X3_ORTOGRA
''																		, ; //X3_TELA
'N'																		, ; //X3_IDXFLD
''																		, ; //X3_AGRUP
''																		} ) //X3_PYME

aAdd( aSX3, { ;
'SZU'																	, ; //X3_ARQUIVO
'08'																	, ; //X3_ORDEM
'ZU_QCHSCLI'															, ; //X3_CAMPO
'N'																		, ; //X3_TIPO
5																		, ; //X3_TAMANHO
0																		, ; //X3_DECIMAL
'Qtd.Ch.S/F S'															, ; //X3_TITULO
'Qtd.Ch.S/F S'															, ; //X3_TITSPA
'Qtd.Ch.S/F S'															, ; //X3_TITENG
'Qtd. Ch.S/F Socios do Cli'												, ; //X3_DESCRIC
'Qtd. Ch.S/F Socios do Cli'												, ; //X3_DESCSPA
'Qtd. Ch.S/F Socios do Cli'												, ; //X3_DESCENG
'@E 99,999'																, ; //X3_PICTURE
''																		, ; //X3_VALID
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
''																		, ; //X3_RELACAO
''																		, ; //X3_F3
0																		, ; //X3_NIVEL
Chr(254) + Chr(192)														, ; //X3_RESERV
''																		, ; //X3_CHECK
''																		, ; //X3_TRIGGER
'U'																		, ; //X3_PROPRI
'S'																		, ; //X3_BROWSE
'A'																		, ; //X3_VISUAL
'R'																		, ; //X3_CONTEXT
''																		, ; //X3_OBRIGAT
''																		, ; //X3_VLDUSER
''																		, ; //X3_CBOX
''																		, ; //X3_CBOXSPA
''																		, ; //X3_CBOXENG
''																		, ; //X3_PICTVAR
''																		, ; //X3_WHEN
''																		, ; //X3_INIBRW
''																		, ; //X3_GRPSXG
''																		, ; //X3_FOLDER
''																		, ; //X3_CONDSQL
''																		, ; //X3_CHKSQL
''																		, ; //X3_IDXSRV
'N'																		, ; //X3_ORTOGRA
''																		, ; //X3_TELA
'N'																		, ; //X3_IDXFLD
''																		, ; //X3_AGRUP
''																		} ) //X3_PYME

aAdd( aSX3, { ;
'SZU'																	, ; //X3_ARQUIVO
'09'																	, ; //X3_ORDEM
'ZU_VLMACU'																, ; //X3_CAMPO
'N'																		, ; //X3_TIPO
15																		, ; //X3_TAMANHO
2																		, ; //X3_DECIMAL
'T.Vl.Maior A'															, ; //X3_TITULO
'T.Vl.Maior A'															, ; //X3_TITSPA
'T.Vl.Maior A'															, ; //X3_TITENG
'Total Valor Maior Acumulo'												, ; //X3_DESCRIC
'Total Valor Maior Acumulo'												, ; //X3_DESCSPA
'Total Valor Maior Acumulo'												, ; //X3_DESCENG
'@E 999,999,999,999.99'													, ; //X3_PICTURE
''																		, ; //X3_VALID
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
''																		, ; //X3_RELACAO
''																		, ; //X3_F3
0																		, ; //X3_NIVEL
Chr(254) + Chr(192)														, ; //X3_RESERV
''																		, ; //X3_CHECK
''																		, ; //X3_TRIGGER
'U'																		, ; //X3_PROPRI
'S'																		, ; //X3_BROWSE
'A'																		, ; //X3_VISUAL
'R'																		, ; //X3_CONTEXT
''																		, ; //X3_OBRIGAT
''																		, ; //X3_VLDUSER
''																		, ; //X3_CBOX
''																		, ; //X3_CBOXSPA
''																		, ; //X3_CBOXENG
''																		, ; //X3_PICTVAR
''																		, ; //X3_WHEN
''																		, ; //X3_INIBRW
''																		, ; //X3_GRPSXG
''																		, ; //X3_FOLDER
''																		, ; //X3_CONDSQL
''																		, ; //X3_CHKSQL
''																		, ; //X3_IDXSRV
'N'																		, ; //X3_ORTOGRA
''																		, ; //X3_TELA
'N'																		, ; //X3_IDXFLD
''																		, ; //X3_AGRUP
''																		} ) //X3_PYME

aAdd( aSX3, { ;
'SZU'																	, ; //X3_ARQUIVO
'10'																	, ; //X3_ORDEM
'ZU_QASVLAC'															, ; //X3_CAMPO
'N'																		, ; //X3_TIPO
4																		, ; //X3_TAMANHO
0																		, ; //X3_DECIMAL
'Qtd. Ass.VMA'															, ; //X3_TITULO
'Qtd. Ass.VMA'															, ; //X3_TITSPA
'Qtd. Ass.VMA'															, ; //X3_TITENG
'Qtd. Associado Vl. M. AC'												, ; //X3_DESCRIC
'Qtd. Associado Vl. M. AC'												, ; //X3_DESCSPA
'Qtd. Associado Vl. M. AC'												, ; //X3_DESCENG
'@E 9,999'																, ; //X3_PICTURE
''																		, ; //X3_VALID
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
''																		, ; //X3_RELACAO
''																		, ; //X3_F3
0																		, ; //X3_NIVEL
Chr(254) + Chr(192)														, ; //X3_RESERV
''																		, ; //X3_CHECK
''																		, ; //X3_TRIGGER
'U'																		, ; //X3_PROPRI
'S'																		, ; //X3_BROWSE
'A'																		, ; //X3_VISUAL
'R'																		, ; //X3_CONTEXT
''																		, ; //X3_OBRIGAT
''																		, ; //X3_VLDUSER
''																		, ; //X3_CBOX
''																		, ; //X3_CBOXSPA
''																		, ; //X3_CBOXENG
''																		, ; //X3_PICTVAR
''																		, ; //X3_WHEN
''																		, ; //X3_INIBRW
''																		, ; //X3_GRPSXG
''																		, ; //X3_FOLDER
''																		, ; //X3_CONDSQL
''																		, ; //X3_CHKSQL
''																		, ; //X3_IDXSRV
'N'																		, ; //X3_ORTOGRA
''																		, ; //X3_TELA
'N'																		, ; //X3_IDXFLD
''																		, ; //X3_AGRUP
''																		} ) //X3_PYME

aAdd( aSX3, { ;
'SZU'																	, ; //X3_ARQUIVO
'11'																	, ; //X3_ORDEM
'ZU_MSGRISK'															, ; //X3_CAMPO
'C'																		, ; //X3_TIPO
28																		, ; //X3_TAMANHO
0																		, ; //X3_DECIMAL
'Cli. Nao Cad'															, ; //X3_TITULO
'Cli. Nao Cad'															, ; //X3_TITSPA
'Cli. Nao Cad'															, ; //X3_TITENG
'Cliente nao Cadastrado'												, ; //X3_DESCRIC
'Cliente nao Cadastrado'												, ; //X3_DESCSPA
'Cliente nao Cadastrado'												, ; //X3_DESCENG
'@!'																	, ; //X3_PICTURE
''																		, ; //X3_VALID
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
''																		, ; //X3_RELACAO
''																		, ; //X3_F3
0																		, ; //X3_NIVEL
Chr(254) + Chr(192)														, ; //X3_RESERV
''																		, ; //X3_CHECK
''																		, ; //X3_TRIGGER
'U'																		, ; //X3_PROPRI
'S'																		, ; //X3_BROWSE
'A'																		, ; //X3_VISUAL
'R'																		, ; //X3_CONTEXT
''																		, ; //X3_OBRIGAT
''																		, ; //X3_VLDUSER
''																		, ; //X3_CBOX
''																		, ; //X3_CBOXSPA
''																		, ; //X3_CBOXENG
''																		, ; //X3_PICTVAR
''																		, ; //X3_WHEN
''																		, ; //X3_INIBRW
''																		, ; //X3_GRPSXG
''																		, ; //X3_FOLDER
''																		, ; //X3_CONDSQL
''																		, ; //X3_CHKSQL
''																		, ; //X3_IDXSRV
'N'																		, ; //X3_ORTOGRA
''																		, ; //X3_TELA
'N'																		, ; //X3_IDXFLD
''																		, ; //X3_AGRUP
''																		} ) //X3_PYME

aAdd( aSX3, { ;
'SZU'																	, ; //X3_ARQUIVO
'12'																	, ; //X3_ORDEM
'ZU_ARQATUL'															, ; //X3_CAMPO
'C'																		, ; //X3_TIPO
1																		, ; //X3_TAMANHO
0																		, ; //X3_DECIMAL
'Atual. Por'															, ; //X3_TITULO
'Atual. Por'															, ; //X3_TITSPA
'Atual. Por'															, ; //X3_TITENG
'Atualizado por'														, ; //X3_DESCRIC
'Atualizado por'														, ; //X3_DESCSPA
'Atualizado por'														, ; //X3_DESCENG
'@!'																	, ; //X3_PICTURE
''																		, ; //X3_VALID
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
''																		, ; //X3_RELACAO
''																		, ; //X3_F3
0																		, ; //X3_NIVEL
Chr(254) + Chr(192)														, ; //X3_RESERV
''																		, ; //X3_CHECK
''																		, ; //X3_TRIGGER
'U'																		, ; //X3_PROPRI
'S'																		, ; //X3_BROWSE
'A'																		, ; //X3_VISUAL
'R'																		, ; //X3_CONTEXT
''																		, ; //X3_OBRIGAT
'Pertence("12")'														, ; //X3_VLDUSER
'1=Plus;2=Master'														, ; //X3_CBOX
'1=Plus;2=Master'														, ; //X3_CBOXSPA
'1=Plus;2=Master'														, ; //X3_CBOXENG
''																		, ; //X3_PICTVAR
''																		, ; //X3_WHEN
''																		, ; //X3_INIBRW
''																		, ; //X3_GRPSXG
''																		, ; //X3_FOLDER
''																		, ; //X3_CONDSQL
''																		, ; //X3_CHKSQL
''																		, ; //X3_IDXSRV
'N'																		, ; //X3_ORTOGRA
''																		, ; //X3_TELA
'N'																		, ; //X3_IDXFLD
''																		, ; //X3_AGRUP
''																		} ) //X3_PYME

aAdd( aSX3, { ;
'SZU'																	, ; //X3_ARQUIVO
'13'																	, ; //X3_ORDEM
'ZU_CSTATRF'															, ; //X3_CAMPO
'C'																		, ; //X3_TIPO
2																		, ; //X3_TAMANHO
0																		, ; //X3_DECIMAL
'Cod.Stats RF'															, ; //X3_TITULO
'Cod.Stats RF'															, ; //X3_TITSPA
'Cod.Stats RF'															, ; //X3_TITENG
'Codigo do Status Rec.Fed.'												, ; //X3_DESCRIC
'Codigo do Status Rec.Fed.'												, ; //X3_DESCSPA
'Codigo do Status Rec.Fed.'												, ; //X3_DESCENG
'@!'																	, ; //X3_PICTURE
''																		, ; //X3_VALID
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
''																		, ; //X3_RELACAO
'SZR'																	, ; //X3_F3
0																		, ; //X3_NIVEL
Chr(254) + Chr(192)														, ; //X3_RESERV
''																		, ; //X3_CHECK
''																		, ; //X3_TRIGGER
'U'																		, ; //X3_PROPRI
'S'																		, ; //X3_BROWSE
'A'																		, ; //X3_VISUAL
'R'																		, ; //X3_CONTEXT
'€'																		, ; //X3_OBRIGAT
''																		, ; //X3_VLDUSER
''																		, ; //X3_CBOX
''																		, ; //X3_CBOXSPA
''																		, ; //X3_CBOXENG
''																		, ; //X3_PICTVAR
''																		, ; //X3_WHEN
''																		, ; //X3_INIBRW
''																		, ; //X3_GRPSXG
''																		, ; //X3_FOLDER
''																		, ; //X3_CONDSQL
''																		, ; //X3_CHKSQL
''																		, ; //X3_IDXSRV
'N'																		, ; //X3_ORTOGRA
''																		, ; //X3_TELA
'N'																		, ; //X3_IDXFLD
''																		, ; //X3_AGRUP
''																		} ) //X3_PYME

aAdd( aSX3, { ;
'SZU'																	, ; //X3_ARQUIVO
'14'																	, ; //X3_ORDEM
'ZU_CSTATSI'															, ; //X3_CAMPO
'C'																		, ; //X3_TIPO
2																		, ; //X3_TAMANHO
0																		, ; //X3_DECIMAL
'Cod.Stats Si'															, ; //X3_TITULO
'Cod.Stats Si'															, ; //X3_TITSPA
'Cod.Stats Si'															, ; //X3_TITENG
'Codigo Status Sintegra'												, ; //X3_DESCRIC
'Codigo Status Sintegra'												, ; //X3_DESCSPA
'Codigo Status Sintegra'												, ; //X3_DESCENG
'@!'																	, ; //X3_PICTURE
''																		, ; //X3_VALID
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
''																		, ; //X3_RELACAO
'SZS'																	, ; //X3_F3
0																		, ; //X3_NIVEL
Chr(254) + Chr(192)														, ; //X3_RESERV
''																		, ; //X3_CHECK
''																		, ; //X3_TRIGGER
'U'																		, ; //X3_PROPRI
'S'																		, ; //X3_BROWSE
'A'																		, ; //X3_VISUAL
'R'																		, ; //X3_CONTEXT
'€'																		, ; //X3_OBRIGAT
''																		, ; //X3_VLDUSER
''																		, ; //X3_CBOX
''																		, ; //X3_CBOXSPA
''																		, ; //X3_CBOXENG
''																		, ; //X3_PICTVAR
''																		, ; //X3_WHEN
''																		, ; //X3_INIBRW
''																		, ; //X3_GRPSXG
''																		, ; //X3_FOLDER
''																		, ; //X3_CONDSQL
''																		, ; //X3_CHKSQL
''																		, ; //X3_IDXSRV
'N'																		, ; //X3_ORTOGRA
''																		, ; //X3_TELA
'N'																		, ; //X3_IDXFLD
''																		, ; //X3_AGRUP
''																		} ) //X3_PYME

//
// Campos Tabela SZV
//
aAdd( aSX3, { ;
'SZV'																	, ; //X3_ARQUIVO
'01'																	, ; //X3_ORDEM
'ZV_FILIAL'																, ; //X3_CAMPO
'C'																		, ; //X3_TIPO
2																		, ; //X3_TAMANHO
0																		, ; //X3_DECIMAL
'Filial'																, ; //X3_TITULO
'Sucursal'																, ; //X3_TITSPA
'Branch'																, ; //X3_TITENG
'Filial do Sistema'														, ; //X3_DESCRIC
'Sucursal'																, ; //X3_DESCSPA
'Branch of the System'													, ; //X3_DESCENG
'@!'																	, ; //X3_PICTURE
''																		, ; //X3_VALID
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
''																		, ; //X3_RELACAO
''																		, ; //X3_F3
1																		, ; //X3_NIVEL
Chr(254) + Chr(192)														, ; //X3_RESERV
''																		, ; //X3_CHECK
''																		, ; //X3_TRIGGER
'U'																		, ; //X3_PROPRI
'N'																		, ; //X3_BROWSE
''																		, ; //X3_VISUAL
''																		, ; //X3_CONTEXT
''																		, ; //X3_OBRIGAT
''																		, ; //X3_VLDUSER
''																		, ; //X3_CBOX
''																		, ; //X3_CBOXSPA
''																		, ; //X3_CBOXENG
''																		, ; //X3_PICTVAR
''																		, ; //X3_WHEN
''																		, ; //X3_INIBRW
'033'																	, ; //X3_GRPSXG
''																		, ; //X3_FOLDER
''																		, ; //X3_CONDSQL
''																		, ; //X3_CHKSQL
''																		, ; //X3_IDXSRV
''																		, ; //X3_ORTOGRA
''																		, ; //X3_TELA
''																		, ; //X3_IDXFLD
''																		, ; //X3_AGRUP
''																		} ) //X3_PYME

aAdd( aSX3, { ;
'SZV'																	, ; //X3_ARQUIVO
'02'																	, ; //X3_ORDEM
'ZV_RISCO'																, ; //X3_CAMPO
'C'																		, ; //X3_TIPO
1																		, ; //X3_TAMANHO
0																		, ; //X3_DECIMAL
'Risco Atual'															, ; //X3_TITULO
'Risco Atual'															, ; //X3_TITSPA
'Risco Atual'															, ; //X3_TITENG
'Risco Atual'															, ; //X3_DESCRIC
'Risco Atual'															, ; //X3_DESCSPA
'Risco Atual'															, ; //X3_DESCENG
'@!'																	, ; //X3_PICTURE
''																		, ; //X3_VALID
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
''																		, ; //X3_RELACAO
''																		, ; //X3_F3
0																		, ; //X3_NIVEL
Chr(254) + Chr(192)														, ; //X3_RESERV
''																		, ; //X3_CHECK
''																		, ; //X3_TRIGGER
'U'																		, ; //X3_PROPRI
'S'																		, ; //X3_BROWSE
'A'																		, ; //X3_VISUAL
'R'																		, ; //X3_CONTEXT
'€'																		, ; //X3_OBRIGAT
''																		, ; //X3_VLDUSER
''																		, ; //X3_CBOX
''																		, ; //X3_CBOXSPA
''																		, ; //X3_CBOXENG
''																		, ; //X3_PICTVAR
''																		, ; //X3_WHEN
''																		, ; //X3_INIBRW
''																		, ; //X3_GRPSXG
''																		, ; //X3_FOLDER
''																		, ; //X3_CONDSQL
''																		, ; //X3_CHKSQL
''																		, ; //X3_IDXSRV
'N'																		, ; //X3_ORTOGRA
''																		, ; //X3_TELA
'N'																		, ; //X3_IDXFLD
''																		, ; //X3_AGRUP
''																		} ) //X3_PYME

aAdd( aSX3, { ;
'SZV'																	, ; //X3_ARQUIVO
'03'																	, ; //X3_ORDEM
'ZV_PONTUAL'															, ; //X3_CAMPO
'C'																		, ; //X3_TIPO
1																		, ; //X3_TAMANHO
0																		, ; //X3_DECIMAL
'Pontualidade'															, ; //X3_TITULO
'Pontualidade'															, ; //X3_TITSPA
'Pontualidade'															, ; //X3_TITENG
'Pontualidade'															, ; //X3_DESCRIC
'Pontualidade'															, ; //X3_DESCSPA
'Pontualidade'															, ; //X3_DESCENG
'@!'																	, ; //X3_PICTURE
''																		, ; //X3_VALID
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
''																		, ; //X3_RELACAO
''																		, ; //X3_F3
0																		, ; //X3_NIVEL
Chr(254) + Chr(192)														, ; //X3_RESERV
''																		, ; //X3_CHECK
''																		, ; //X3_TRIGGER
'U'																		, ; //X3_PROPRI
'N'																		, ; //X3_BROWSE
'A'																		, ; //X3_VISUAL
'R'																		, ; //X3_CONTEXT
''																		, ; //X3_OBRIGAT
''																		, ; //X3_VLDUSER
''																		, ; //X3_CBOX
''																		, ; //X3_CBOXSPA
''																		, ; //X3_CBOXENG
''																		, ; //X3_PICTVAR
''																		, ; //X3_WHEN
''																		, ; //X3_INIBRW
''																		, ; //X3_GRPSXG
''																		, ; //X3_FOLDER
''																		, ; //X3_CONDSQL
''																		, ; //X3_CHKSQL
''																		, ; //X3_IDXSRV
'N'																		, ; //X3_ORTOGRA
''																		, ; //X3_TELA
'N'																		, ; //X3_IDXFLD
''																		, ; //X3_AGRUP
''																		} ) //X3_PYME

aAdd( aSX3, { ;
'SZV'																	, ; //X3_ARQUIVO
'04'																	, ; //X3_ORDEM
'ZV_RELMERC'															, ; //X3_CAMPO
'C'																		, ; //X3_TIPO
1																		, ; //X3_TAMANHO
0																		, ; //X3_DECIMAL
'Rel.Mercado'															, ; //X3_TITULO
'Rel.Mercado'															, ; //X3_TITSPA
'Rel.Mercado'															, ; //X3_TITENG
'Rel.Mercado'															, ; //X3_DESCRIC
'Rel.Mercado'															, ; //X3_DESCSPA
'Rel.Mercado'															, ; //X3_DESCENG
'@!'																	, ; //X3_PICTURE
''																		, ; //X3_VALID
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
''																		, ; //X3_RELACAO
''																		, ; //X3_F3
0																		, ; //X3_NIVEL
Chr(254) + Chr(192)														, ; //X3_RESERV
''																		, ; //X3_CHECK
''																		, ; //X3_TRIGGER
'U'																		, ; //X3_PROPRI
'N'																		, ; //X3_BROWSE
'A'																		, ; //X3_VISUAL
'R'																		, ; //X3_CONTEXT
''																		, ; //X3_OBRIGAT
''																		, ; //X3_VLDUSER
''																		, ; //X3_CBOX
''																		, ; //X3_CBOXSPA
''																		, ; //X3_CBOXENG
''																		, ; //X3_PICTVAR
''																		, ; //X3_WHEN
''																		, ; //X3_INIBRW
''																		, ; //X3_GRPSXG
''																		, ; //X3_FOLDER
''																		, ; //X3_CONDSQL
''																		, ; //X3_CHKSQL
''																		, ; //X3_IDXSRV
'N'																		, ; //X3_ORTOGRA
''																		, ; //X3_TELA
'N'																		, ; //X3_IDXFLD
''																		, ; //X3_AGRUP
''																		} ) //X3_PYME

aAdd( aSX3, { ;
'SZV'																	, ; //X3_ARQUIVO
'05'																	, ; //X3_ORDEM
'ZV_OCNEG'																, ; //X3_CAMPO
'C'																		, ; //X3_TIPO
1																		, ; //X3_TAMANHO
0																		, ; //X3_DECIMAL
'Oc.Negativa'															, ; //X3_TITULO
'Oc.Negativa'															, ; //X3_TITSPA
'Oc.Negativa'															, ; //X3_TITENG
'Ocorrencia Negativa'													, ; //X3_DESCRIC
'Ocorrencia Negativa'													, ; //X3_DESCSPA
'Ocorrencia Negativa'													, ; //X3_DESCENG
'@!'																	, ; //X3_PICTURE
''																		, ; //X3_VALID
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
''																		, ; //X3_RELACAO
''																		, ; //X3_F3
0																		, ; //X3_NIVEL
Chr(254) + Chr(192)														, ; //X3_RESERV
''																		, ; //X3_CHECK
''																		, ; //X3_TRIGGER
'U'																		, ; //X3_PROPRI
'N'																		, ; //X3_BROWSE
'A'																		, ; //X3_VISUAL
'R'																		, ; //X3_CONTEXT
''																		, ; //X3_OBRIGAT
''																		, ; //X3_VLDUSER
''																		, ; //X3_CBOX
''																		, ; //X3_CBOXSPA
''																		, ; //X3_CBOXENG
''																		, ; //X3_PICTVAR
''																		, ; //X3_WHEN
''																		, ; //X3_INIBRW
''																		, ; //X3_GRPSXG
''																		, ; //X3_FOLDER
''																		, ; //X3_CONDSQL
''																		, ; //X3_CHKSQL
''																		, ; //X3_IDXSRV
'N'																		, ; //X3_ORTOGRA
''																		, ; //X3_TELA
'N'																		, ; //X3_IDXFLD
''																		, ; //X3_AGRUP
''																		} ) //X3_PYME

aAdd( aSX3, { ;
'SZV'																	, ; //X3_ARQUIVO
'06'																	, ; //X3_ORDEM
'ZV_CREDPRC'															, ; //X3_CAMPO
'C'																		, ; //X3_TIPO
1																		, ; //X3_TAMANHO
0																		, ; //X3_DECIMAL
'Crd.Praca'																, ; //X3_TITULO
'Crd.Praca'																, ; //X3_TITSPA
'Crd.Praca'																, ; //X3_TITENG
'Credito na Praca'														, ; //X3_DESCRIC
'Credito na Praca'														, ; //X3_DESCSPA
'Credito na Praca'														, ; //X3_DESCENG
'@!'																	, ; //X3_PICTURE
''																		, ; //X3_VALID
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
''																		, ; //X3_RELACAO
''																		, ; //X3_F3
0																		, ; //X3_NIVEL
Chr(254) + Chr(192)														, ; //X3_RESERV
''																		, ; //X3_CHECK
''																		, ; //X3_TRIGGER
'U'																		, ; //X3_PROPRI
'N'																		, ; //X3_BROWSE
'A'																		, ; //X3_VISUAL
'R'																		, ; //X3_CONTEXT
''																		, ; //X3_OBRIGAT
''																		, ; //X3_VLDUSER
''																		, ; //X3_CBOX
''																		, ; //X3_CBOXSPA
''																		, ; //X3_CBOXENG
''																		, ; //X3_PICTVAR
''																		, ; //X3_WHEN
''																		, ; //X3_INIBRW
''																		, ; //X3_GRPSXG
''																		, ; //X3_FOLDER
''																		, ; //X3_CONDSQL
''																		, ; //X3_CHKSQL
''																		, ; //X3_IDXSRV
'N'																		, ; //X3_ORTOGRA
''																		, ; //X3_TELA
'N'																		, ; //X3_IDXFLD
''																		, ; //X3_AGRUP
''																		} ) //X3_PYME

aAdd( aSX3, { ;
'SZV'																	, ; //X3_ARQUIVO
'07'																	, ; //X3_ORDEM
'ZV_DENSCOM'															, ; //X3_CAMPO
'C'																		, ; //X3_TIPO
1																		, ; //X3_TAMANHO
0																		, ; //X3_DECIMAL
'Dens.Com.'																, ; //X3_TITULO
'Dens.Com.'																, ; //X3_TITSPA
'Dens.Com.'																, ; //X3_TITENG
'Densidade Comercial'													, ; //X3_DESCRIC
'Densidade Comercial'													, ; //X3_DESCSPA
'Densidade Comercial'													, ; //X3_DESCENG
'@!'																	, ; //X3_PICTURE
''																		, ; //X3_VALID
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
''																		, ; //X3_RELACAO
''																		, ; //X3_F3
0																		, ; //X3_NIVEL
Chr(254) + Chr(192)														, ; //X3_RESERV
''																		, ; //X3_CHECK
''																		, ; //X3_TRIGGER
'U'																		, ; //X3_PROPRI
'S'																		, ; //X3_BROWSE
'A'																		, ; //X3_VISUAL
'R'																		, ; //X3_CONTEXT
'€'																		, ; //X3_OBRIGAT
'Existchav("SZV",M->ZV_RISCO+M->ZV_DENSCOM,2,"EXISTREGRA")'				, ; //X3_VLDUSER
''																		, ; //X3_CBOX
''																		, ; //X3_CBOXSPA
''																		, ; //X3_CBOXENG
''																		, ; //X3_PICTVAR
''																		, ; //X3_WHEN
''																		, ; //X3_INIBRW
''																		, ; //X3_GRPSXG
''																		, ; //X3_FOLDER
''																		, ; //X3_CONDSQL
''																		, ; //X3_CHKSQL
''																		, ; //X3_IDXSRV
'N'																		, ; //X3_ORTOGRA
''																		, ; //X3_TELA
'N'																		, ; //X3_IDXFLD
''																		, ; //X3_AGRUP
''																		} ) //X3_PYME

aAdd( aSX3, { ;
'SZV'																	, ; //X3_ARQUIVO
'08'																	, ; //X3_ORDEM
'ZV_DIASATU'															, ; //X3_CAMPO
'N'																		, ; //X3_TIPO
2																		, ; //X3_TAMANHO
0																		, ; //X3_DECIMAL
'Dias LC Cli.'															, ; //X3_TITULO
'Dias LC Cli.'															, ; //X3_TITSPA
'Dias LC Cli.'															, ; //X3_TITENG
'Dias do Limite de Credito'												, ; //X3_DESCRIC
'Dias do Limite de Credito'												, ; //X3_DESCSPA
'Dias do Limite de Credito'												, ; //X3_DESCENG
'99'																	, ; //X3_PICTURE
''																		, ; //X3_VALID
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
''																		, ; //X3_RELACAO
''																		, ; //X3_F3
0																		, ; //X3_NIVEL
Chr(254) + Chr(192)														, ; //X3_RESERV
''																		, ; //X3_CHECK
''																		, ; //X3_TRIGGER
'U'																		, ; //X3_PROPRI
'S'																		, ; //X3_BROWSE
'A'																		, ; //X3_VISUAL
'R'																		, ; //X3_CONTEXT
'€'																		, ; //X3_OBRIGAT
''																		, ; //X3_VLDUSER
''																		, ; //X3_CBOX
''																		, ; //X3_CBOXSPA
''																		, ; //X3_CBOXENG
''																		, ; //X3_PICTVAR
''																		, ; //X3_WHEN
''																		, ; //X3_INIBRW
''																		, ; //X3_GRPSXG
''																		, ; //X3_FOLDER
''																		, ; //X3_CONDSQL
''																		, ; //X3_CHKSQL
''																		, ; //X3_IDXSRV
'N'																		, ; //X3_ORTOGRA
''																		, ; //X3_TELA
'N'																		, ; //X3_IDXFLD
''																		, ; //X3_AGRUP
''																		} ) //X3_PYME

aAdd( aSX3, { ;
'SZV'																	, ; //X3_ARQUIVO
'09'																	, ; //X3_ORDEM
'ZV_CALCDIA'															, ; //X3_CAMPO
'C'																		, ; //X3_TIPO
1																		, ; //X3_TAMANHO
0																		, ; //X3_DECIMAL
'Atu. Dt. LC'															, ; //X3_TITULO
'Atu. Dt. LC'															, ; //X3_TITSPA
'Atu. Dt. LC'															, ; //X3_TITENG
'Atualiza a data de LC Cli'												, ; //X3_DESCRIC
'Atualiza a data de LC Cli'												, ; //X3_DESCSPA
'Atualiza a data de LC Cli'												, ; //X3_DESCENG
'@!'																	, ; //X3_PICTURE
''																		, ; //X3_VALID
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
''																		, ; //X3_RELACAO
''																		, ; //X3_F3
0																		, ; //X3_NIVEL
Chr(254) + Chr(192)														, ; //X3_RESERV
''																		, ; //X3_CHECK
''																		, ; //X3_TRIGGER
'U'																		, ; //X3_PROPRI
'S'																		, ; //X3_BROWSE
'A'																		, ; //X3_VISUAL
'R'																		, ; //X3_CONTEXT
'€'																		, ; //X3_OBRIGAT
'Pertence("ASN")'														, ; //X3_VLDUSER
'A=Adiciona a DataBase;S=Subtrai da DataBase;N=Nao Altera'				, ; //X3_CBOX
'A=Adiciona a DataBase;S=Subtrai da DataBase;N=Nao Altera'				, ; //X3_CBOXSPA
'A=Adiciona a DataBase;S=Subtrai da DataBase;N=Nao Altera'				, ; //X3_CBOXENG
''																		, ; //X3_PICTVAR
''																		, ; //X3_WHEN
''																		, ; //X3_INIBRW
''																		, ; //X3_GRPSXG
''																		, ; //X3_FOLDER
''																		, ; //X3_CONDSQL
''																		, ; //X3_CHKSQL
''																		, ; //X3_IDXSRV
'N'																		, ; //X3_ORTOGRA
''																		, ; //X3_TELA
'N'																		, ; //X3_IDXFLD
''																		, ; //X3_AGRUP
''																		} ) //X3_PYME

aAdd( aSX3, { ;
'SZV'																	, ; //X3_ARQUIVO
'10'																	, ; //X3_ORDEM
'ZV_MSGRET'																, ; //X3_CAMPO
'C'																		, ; //X3_TIPO
35																		, ; //X3_TAMANHO
0																		, ; //X3_DECIMAL
'Msg.Ret.Regr'															, ; //X3_TITULO
'Msg.Ret.Regr'															, ; //X3_TITSPA
'Msg.Ret.Regr'															, ; //X3_TITENG
'Mensagem de Ret. da Regra'												, ; //X3_DESCRIC
'Mensagem de Ret. da Regra'												, ; //X3_DESCSPA
'Mensagem de Ret. da Regra'												, ; //X3_DESCENG
'@!'																	, ; //X3_PICTURE
''																		, ; //X3_VALID
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
''																		, ; //X3_RELACAO
''																		, ; //X3_F3
0																		, ; //X3_NIVEL
Chr(254) + Chr(192)														, ; //X3_RESERV
''																		, ; //X3_CHECK
''																		, ; //X3_TRIGGER
'U'																		, ; //X3_PROPRI
'S'																		, ; //X3_BROWSE
'A'																		, ; //X3_VISUAL
'R'																		, ; //X3_CONTEXT
'€'																		, ; //X3_OBRIGAT
''																		, ; //X3_VLDUSER
''																		, ; //X3_CBOX
''																		, ; //X3_CBOXSPA
''																		, ; //X3_CBOXENG
''																		, ; //X3_PICTVAR
''																		, ; //X3_WHEN
''																		, ; //X3_INIBRW
''																		, ; //X3_GRPSXG
''																		, ; //X3_FOLDER
''																		, ; //X3_CONDSQL
''																		, ; //X3_CHKSQL
''																		, ; //X3_IDXSRV
'N'																		, ; //X3_ORTOGRA
''																		, ; //X3_TELA
'N'																		, ; //X3_IDXFLD
''																		, ; //X3_AGRUP
''																		} ) //X3_PYME


//
// Atualizando dicionário
//
nPosArq := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_ARQUIVO" } )
nPosOrd := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_ORDEM"   } )
nPosCpo := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_CAMPO"   } )
nPosTam := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_TAMANHO" } )
nPosSXG := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_GRPSXG"  } )
nPosVld := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_VALID"   } )

aSort( aSX3,,, { |x,y| x[nPosArq]+x[nPosOrd]+x[nPosCpo] < y[nPosArq]+y[nPosOrd]+y[nPosCpo] } )

oProcess:SetRegua2( Len( aSX3 ) )

dbSelectArea( "SX3" )
dbSetOrder( 2 )
cAliasAtu := ""

For nI := 1 To Len( aSX3 )
	
	//
	// Verifica se o campo faz parte de um grupo e ajusta tamanho
	//
	If !Empty( aSX3[nI][nPosSXG] )
		SXG->( dbSetOrder( 1 ) )
		If SXG->( MSSeek( aSX3[nI][nPosSXG] ) )
			If aSX3[nI][nPosTam] <> SXG->XG_SIZE
				aSX3[nI][nPosTam] := SXG->XG_SIZE
				AutoGrLog( STR0061 + aSX3[nI][nPosCpo] + STR0062 + ; //"O tamanho do campo "###" NÃO atualizado e foi mantido em ["
				AllTrim( Str( SXG->XG_SIZE ) ) + "]" + CRLF + ;
				STR0063 + SXG->XG_GRUPO + "]" + CRLF ) //" por pertencer ao grupo de campos ["
			EndIf
		EndIf
	EndIf
	
	SX3->( dbSetOrder( 2 ) )
	
	If !( aSX3[nI][nPosArq] $ cAlias )
		cAlias += aSX3[nI][nPosArq] + "/"
		aAdd( aArqUpd, aSX3[nI][nPosArq] )
	EndIf
	
	If !SX3->( dbSeek( PadR( aSX3[nI][nPosCpo], nTamSeek ) ) )
		
		//
		// Busca ultima ocorrencia do alias
		//
		If ( aSX3[nI][nPosArq] <> cAliasAtu )
			cSeqAtu   := "00"
			cAliasAtu := aSX3[nI][nPosArq]
			
			dbSetOrder( 1 )
			SX3->( dbSeek( cAliasAtu + "ZZ", .T. ) )
			dbSkip( -1 )
			
			If ( SX3->X3_ARQUIVO == cAliasAtu )
				cSeqAtu := SX3->X3_ORDEM
			EndIf
			
			nSeqAtu := Val( RetAsc( cSeqAtu, 3, .F. ) )
		EndIf
		
		nSeqAtu++
		cSeqAtu := RetAsc( Str( nSeqAtu ), 2, .T. )
		
		RecLock( "SX3", .T. )
		For nJ := 1 To Len( aSX3[nI] )
			If     nJ == nPosOrd  // Ordem
				SX3->( FieldPut( FieldPos( aEstrut[nJ][1] ), cSeqAtu ) )
				
			ElseIf aEstrut[nJ][2] > 0
				SX3->( FieldPut( FieldPos( aEstrut[nJ][1] ), aSX3[nI][nJ] ) )
				
			EndIf
		Next nJ
		
		dbCommit()
		MsUnLock()
		
		AutoGrLog( STR0064 + aSX3[nI][nPosCpo] ) //"Criado campo "
		
	EndIf
	
	oProcess:IncRegua2( STR0082 ) //"Atualizando Campos de Tabelas (SX3)..."
	
Next nI

AutoGrLog( CRLF + STR0060 + " SX3" + CRLF + Replicate( "-", 128 ) + CRLF ) //"Final da Atualização"

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSIX
Função de processamento da gravação do SIX - Indices

@author TOTVS Protheus
@since  02/05/2017
@obs    Gerado por EXPORDIC - V.5.4.1.2 EFS / Upd. V.4.21.17 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSIX()
Local aEstrut   := {}
Local aSIX      := {}
Local lAlt      := .F.
Local lDelInd   := .F.
Local nI        := 0
Local nJ        := 0

AutoGrLog( STR0055 + " SIX" + CRLF ) //"Ínicio da Atualização"

aEstrut := { "INDICE" , "ORDEM" , "CHAVE", "DESCRICAO", "DESCSPA"  , ;
"DESCENG", "PROPRI", "F3"   , "NICKNAME" , "SHOWPESQ" }

//
// Tabela SZR
//
aAdd( aSIX, { ;
'SZR'																	, ; //INDICE
'1'																		, ; //ORDEM
'ZR_CODIGO+ZR_DESC'														, ; //CHAVE
'Cod. Status+Desc.Status'												, ; //DESCRICAO
'Cod. Status+Desc.Status'												, ; //DESCSPA
'Cod. Status+Desc.Status'												, ; //DESCENG
'U'																		, ; //PROPRI
''																		, ; //F3
''																		, ; //NICKNAME
'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
'SZR'																	, ; //INDICE
'2'																		, ; //ORDEM
'ZR_CODIGO'																, ; //CHAVE
'Cod. Status'															, ; //DESCRICAO
'Cod. Status'															, ; //DESCSPA
'Cod. Status'															, ; //DESCENG
'U'																		, ; //PROPRI
''																		, ; //F3
''																		, ; //NICKNAME
'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
'SZR'																	, ; //INDICE
'3'																		, ; //ORDEM
'ZR_DESC'																, ; //CHAVE
'Desc.Status'															, ; //DESCRICAO
'Desc.Status'															, ; //DESCSPA
'Desc.Status'															, ; //DESCENG
'U'																		, ; //PROPRI
''																		, ; //F3
''																		, ; //NICKNAME
'S'																		} ) //SHOWPESQ

//
// Tabela SZS
//
aAdd( aSIX, { ;
'SZS'																	, ; //INDICE
'1'																		, ; //ORDEM
'ZS_CODIGO+ZS_DESC'														, ; //CHAVE
'Cod. Status+Desc. Status'												, ; //DESCRICAO
'Cod. Status+Desc. Status'												, ; //DESCSPA
'Cod. Status+Desc. Status'												, ; //DESCENG
'U'																		, ; //PROPRI
''																		, ; //F3
''																		, ; //NICKNAME
'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
'SZS'																	, ; //INDICE
'2'																		, ; //ORDEM
'ZS_CODIGO'																, ; //CHAVE
'Cod. Status'															, ; //DESCRICAO
'Cod. Status'															, ; //DESCSPA
'Cod. Status'															, ; //DESCENG
'U'																		, ; //PROPRI
''																		, ; //F3
''																		, ; //NICKNAME
'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
'SZS'																	, ; //INDICE
'3'																		, ; //ORDEM
'ZS_DESC'																, ; //CHAVE
'Desc. Status'															, ; //DESCRICAO
'Desc. Status'															, ; //DESCSPA
'Desc. Status'															, ; //DESCENG
'U'																		, ; //PROPRI
''																		, ; //F3
''																		, ; //NICKNAME
'S'																		} ) //SHOWPESQ

//
// Tabela SZV
//
aAdd( aSIX, { ;
'SZV'																	, ; //INDICE
'1'																		, ; //ORDEM
'ZV_RISCO'																, ; //CHAVE
'Risco Atual'															, ; //DESCRICAO
'Risco Atual'															, ; //DESCSPA
'Risco Atual'															, ; //DESCENG
'U'																		, ; //PROPRI
''																		, ; //F3
''																		, ; //NICKNAME
'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
'SZV'																	, ; //INDICE
'2'																		, ; //ORDEM
'ZV_RISCO+ZV_DENSCOM'													, ; //CHAVE
'Risco Atual+Dens.Com.Min'												, ; //DESCRICAO
'Risco Atual+Dens.Com.Min'												, ; //DESCSPA
'Risco Atual+Dens.Com.Min'												, ; //DESCENG
'U'																		, ; //PROPRI
''																		, ; //F3
''																		, ; //NICKNAME
'S'																		} ) //SHOWPESQ

//
// Atualizando dicionário
//
oProcess:SetRegua2( Len( aSIX ) )

dbSelectArea( "SIX" )
SIX->( dbSetOrder( 1 ) )

For nI := 1 To Len( aSIX )
	
	lAlt    := .F.
	lDelInd := .F.
	
	If !SIX->( dbSeek( aSIX[nI][1] + aSIX[nI][2] ) )
		AutoGrLog( STR0083 + aSIX[nI][1] + "/" + aSIX[nI][2] + " - " + aSIX[nI][3] ) //"Índice criado "
	Else
		lAlt := .T.
		aAdd( aArqUpd, aSIX[nI][1] )
		If !StrTran( Upper( AllTrim( CHAVE )       ), " ", "" ) == ;
			StrTran( Upper( AllTrim( aSIX[nI][3] ) ), " ", "" )
			AutoGrLog( STR0143 + aSIX[nI][1] + "/" + aSIX[nI][2] + " - " + aSIX[nI][3] ) //"Chave do índice alterado "
			lDelInd := .T. // Se for alteração precisa apagar o indice do banco
		EndIf
	EndIf
	
	RecLock( "SIX", !lAlt )
	For nJ := 1 To Len( aSIX[nI] )
		If FieldPos( aEstrut[nJ] ) > 0
			FieldPut( FieldPos( aEstrut[nJ] ), aSIX[nI][nJ] )
		EndIf
	Next nJ
	MsUnLock()
	
	dbCommit()
	
	If lDelInd
		TcInternal( 60, RetSqlName( aSIX[nI][1] ) + "|" + RetSqlName( aSIX[nI][1] ) + aSIX[nI][2] )
	EndIf
	
	oProcess:IncRegua2( STR0085 ) //"Atualizando índices..."
	
Next nI

AutoGrLog( CRLF + STR0060 + " SIX" + CRLF + Replicate( "-", 128 ) + CRLF ) //"Final da Atualização"

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSX6
Função de processamento da gravação do SX6 - Parâmetros

@author TOTVS Protheus
@since  02/05/2017
@obs    Gerado por EXPORDIC - V.5.4.1.2 EFS / Upd. V.4.21.17 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSX6()
Local aEstrut   := {}
Local aSX6      := {}
Local cAlias    := ""
Local cMsg      := ""
Local lContinua := .T.
Local lReclock  := .T.
Local lTodosNao := .F.
Local lTodosSim := .F.
Local nI        := 0
Local nJ        := 0
Local nOpcA     := 0
Local nTamFil   := Len( SX6->X6_FIL )
Local nTamVar   := Len( SX6->X6_VAR )

AutoGrLog( STR0055 + " SX6" + CRLF ) //"Ínicio da Atualização"

aEstrut := { "X6_FIL"    , "X6_VAR"    , "X6_TIPO"   , "X6_DESCRIC", "X6_DSCSPA" , "X6_DSCENG" , "X6_DESC1"  , ;
"X6_DSCSPA1", "X6_DSCENG1", "X6_DESC2"  , "X6_DSCSPA2", "X6_DSCENG2", "X6_CONTEUD", "X6_CONTSPA", ;
"X6_CONTENG", "X6_PROPRI" , "X6_VALID"  , "X6_INIT"   , "X6_DEFPOR" , "X6_DEFSPA" , "X6_DEFENG" , ;
"X6_PYME"   }

aAdd( aSX6, { ;
'  '																	, ; //X6_FIL
'MV_XSTATRF'															, ; //X6_VAR
'C'																		, ; //X6_TIPO
'Acao referente ao controle de criacao do Status Re'					, ; //X6_DESCRIC
'Acao referente ao controle de criacao do Status Re'					, ; //X6_DSCSPA
'Acao referente ao controle de criacao do Status Re'					, ; //X6_DSCENG
'ceita Federal quanto a criacao automatica via TXT.'					, ; //X6_DESC1
'ceita Federal quanto a criacao automatica via TXT.'					, ; //X6_DSCSPA1
'ceita Federal quanto a criacao automatica via TXT.'					, ; //X6_DSCENG1
'L= Libera;B=Bloqueia'													, ; //X6_DESC2
'L= Libera;B=Bloqueia'													, ; //X6_DSCSPA2
'L= Libera;B=Bloqueia'													, ; //X6_DSCENG2
'L'																		, ; //X6_CONTEUD
'L'																		, ; //X6_CONTSPA
'L'																		, ; //X6_CONTENG
'U'																		, ; //X6_PROPRI
''																		, ; //X6_VALID
''																		, ; //X6_INIT
''																		, ; //X6_DEFPOR
''																		, ; //X6_DEFSPA
''																		, ; //X6_DEFENG
''																		} ) //X6_PYME

aAdd( aSX6, { ;
'  '																	, ; //X6_FIL
'MV_XSTATSI'															, ; //X6_VAR
'C'																		, ; //X6_TIPO
'Acao referente ao controle de criacao do Status Si'					, ; //X6_DESCRIC
'Acao referente ao controle de criacao do Status Si'					, ; //X6_DSCSPA
'Acao referente ao controle de criacao do Status Si'					, ; //X6_DSCENG
'ntegra quanto a criacao automatica via TXT.'							, ; //X6_DESC1
'ntegra quanto a criacao automatica via TXT.'							, ; //X6_DSCSPA1
'ntegra quanto a criacao automatica via TXT.'							, ; //X6_DSCENG1
'L= Libera;B=Bloqueia'													, ; //X6_DESC2
'L= Libera;B=Bloqueia'													, ; //X6_DSCSPA2
'L= Libera;B=Bloqueia'													, ; //X6_DSCENG2
'L'																		, ; //X6_CONTEUD
'L'																		, ; //X6_CONTSPA
'L'																		, ; //X6_CONTENG
'U'																		, ; //X6_PROPRI
''																		, ; //X6_VALID
''																		, ; //X6_INIT
''																		, ; //X6_DEFPOR
''																		, ; //X6_DEFSPA
''																		, ; //X6_DEFENG
''																		} ) //X6_PYME

//
// Atualizando dicionário
//
oProcess:SetRegua2( Len( aSX6 ) )

dbSelectArea( "SX6" )
dbSetOrder( 1 )

For nI := 1 To Len( aSX6 )
	lContinua := .F.
	lReclock  := .F.
	
	If !SX6->( dbSeek( PadR( aSX6[nI][1], nTamFil ) + PadR( aSX6[nI][2], nTamVar ) ) )
		lContinua := .T.
		lReclock  := .T.
		AutoGrLog( STR0099 + aSX6[nI][1] + aSX6[nI][2] + STR0100 + AllTrim( aSX6[nI][13] ) + "]" ) //"Foi incluído o parâmetro "###" Conteúdo ["
	EndIf
	
	If lContinua
		If !( aSX6[nI][1] $ cAlias )
			cAlias += aSX6[nI][1] + "/"
		EndIf
		
		RecLock( "SX6", lReclock )
		For nJ := 1 To Len( aSX6[nI] )
			If FieldPos( aEstrut[nJ] ) > 0
				FieldPut( FieldPos( aEstrut[nJ] ), aSX6[nI][nJ] )
			EndIf
		Next nJ
		dbCommit()
		MsUnLock()
	EndIf
	
	oProcess:IncRegua2( STR0109 ) //"Atualizando Arquivos (SX6)..."
	
Next nI

AutoGrLog( CRLF + STR0060 + " SX6" + CRLF + Replicate( "-", 128 ) + CRLF ) //"Final da Atualização"

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSXB
Função de processamento da gravação do SXB - Consultas Padrao

@author TOTVS Protheus
@since  02/05/2017
@obs    Gerado por EXPORDIC - V.5.4.1.2 EFS / Upd. V.4.21.17 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSXB()
Local aEstrut   := {}
Local aSXB      := {}
Local cAlias    := ""
Local cMsg      := ""
Local lTodosNao := .F.
Local lTodosSim := .F.
Local nI        := 0
Local nJ        := 0
Local nOpcA     := 0

AutoGrLog( STR0055 + " SXB" + CRLF ) //"Ínicio da Atualização"

aEstrut := { "XB_ALIAS"  , "XB_TIPO"   , "XB_SEQ"    , "XB_COLUNA" , "XB_DESCRI" , "XB_DESCSPA", "XB_DESCENG", ;
"XB_WCONTEM", "XB_CONTEM" }


//
// Consulta SZR
//
aAdd( aSXB, { ;
'SZR'																	, ; //XB_ALIAS
'1'																		, ; //XB_TIPO
'01'																	, ; //XB_SEQ
'DB'																	, ; //XB_COLUNA
'Status Receita Fed.'													, ; //XB_DESCRI
'Status Receita Fed.'													, ; //XB_DESCSPA
'Status Receita Fed.'													, ; //XB_DESCENG
''																		, ; //XB_WCONTEM
'SZR'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
'SZR'																	, ; //XB_ALIAS
'2'																		, ; //XB_TIPO
'01'																	, ; //XB_SEQ
'01'																	, ; //XB_COLUNA
'Cod. Status+desc.sta'													, ; //XB_DESCRI
'Cod. Status+desc.sta'													, ; //XB_DESCSPA
'Cod. Status+desc.sta'													, ; //XB_DESCENG
''																		, ; //XB_WCONTEM
''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
'SZR'																	, ; //XB_ALIAS
'2'																		, ; //XB_TIPO
'02'																	, ; //XB_SEQ
'02'																	, ; //XB_COLUNA
'Cod. Status'															, ; //XB_DESCRI
'Cod. Status'															, ; //XB_DESCSPA
'Cod. Status'															, ; //XB_DESCENG
''																		, ; //XB_WCONTEM
''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
'SZR'																	, ; //XB_ALIAS
'3'																		, ; //XB_TIPO
'01'																	, ; //XB_SEQ
'01'																	, ; //XB_COLUNA
'Cadastra Novo'															, ; //XB_DESCRI
'Incluye Nuevo'															, ; //XB_DESCSPA
'Add New'																, ; //XB_DESCENG
''																		, ; //XB_WCONTEM
'01'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
'SZR'																	, ; //XB_ALIAS
'4'																		, ; //XB_TIPO
'01'																	, ; //XB_SEQ
'01'																	, ; //XB_COLUNA
'Cod. Status'															, ; //XB_DESCRI
'Cod. Status'															, ; //XB_DESCSPA
'Cod. Status'															, ; //XB_DESCENG
''																		, ; //XB_WCONTEM
'ZR_CODIGO'																} ) //XB_CONTEM

aAdd( aSXB, { ;
'SZR'																	, ; //XB_ALIAS
'4'																		, ; //XB_TIPO
'01'																	, ; //XB_SEQ
'02'																	, ; //XB_COLUNA
'Desc.Status'															, ; //XB_DESCRI
'Desc.Status'															, ; //XB_DESCSPA
'Desc.Status'															, ; //XB_DESCENG
''																		, ; //XB_WCONTEM
'ZR_DESC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
'SZR'																	, ; //XB_ALIAS
'4'																		, ; //XB_TIPO
'01'																	, ; //XB_SEQ
'03'																	, ; //XB_COLUNA
'Qual Acao?'															, ; //XB_DESCRI
'Qual Acao?'															, ; //XB_DESCSPA
'Qual Acao?'															, ; //XB_DESCENG
''																		, ; //XB_WCONTEM
'ZR_ACAO'																} ) //XB_CONTEM

aAdd( aSXB, { ;
'SZR'																	, ; //XB_ALIAS
'4'																		, ; //XB_TIPO
'02'																	, ; //XB_SEQ
'01'																	, ; //XB_COLUNA
'Cod. Status'															, ; //XB_DESCRI
'Cod. Status'															, ; //XB_DESCSPA
'Cod. Status'															, ; //XB_DESCENG
''																		, ; //XB_WCONTEM
'ZR_CODIGO'																} ) //XB_CONTEM

aAdd( aSXB, { ;
'SZR'																	, ; //XB_ALIAS
'4'																		, ; //XB_TIPO
'02'																	, ; //XB_SEQ
'02'																	, ; //XB_COLUNA
'Desc.Status'															, ; //XB_DESCRI
'Desc.Status'															, ; //XB_DESCSPA
'Desc.Status'															, ; //XB_DESCENG
''																		, ; //XB_WCONTEM
'ZR_DESC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
'SZR'																	, ; //XB_ALIAS
'4'																		, ; //XB_TIPO
'02'																	, ; //XB_SEQ
'03'																	, ; //XB_COLUNA
'Qual Acao?'															, ; //XB_DESCRI
'Qual Acao?'															, ; //XB_DESCSPA
'Qual Acao?'															, ; //XB_DESCENG
''																		, ; //XB_WCONTEM
'ZR_ACAO'																} ) //XB_CONTEM

aAdd( aSXB, { ;
'SZR'																	, ; //XB_ALIAS
'5'																		, ; //XB_TIPO
'01'																	, ; //XB_SEQ
''																		, ; //XB_COLUNA
''																		, ; //XB_DESCRI
''																		, ; //XB_DESCSPA
''																		, ; //XB_DESCENG
''																		, ; //XB_WCONTEM
'SZR->ZR_CODIGO'														} ) //XB_CONTEM

//
// Consulta SZS
//
aAdd( aSXB, { ;
'SZS'																	, ; //XB_ALIAS
'1'																		, ; //XB_TIPO
'01'																	, ; //XB_SEQ
'DB'																	, ; //XB_COLUNA
'Status Sintegra'														, ; //XB_DESCRI
'Status Sintegra'														, ; //XB_DESCSPA
'Status Sintegra'														, ; //XB_DESCENG
''																		, ; //XB_WCONTEM
'SZS'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
'SZS'																	, ; //XB_ALIAS
'2'																		, ; //XB_TIPO
'01'																	, ; //XB_SEQ
'01'																	, ; //XB_COLUNA
'Cod. Status+desc. St'													, ; //XB_DESCRI
'Cod. Status+desc. St'													, ; //XB_DESCSPA
'Cod. Status+desc. St'													, ; //XB_DESCENG
''																		, ; //XB_WCONTEM
''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
'SZS'																	, ; //XB_ALIAS
'2'																		, ; //XB_TIPO
'02'																	, ; //XB_SEQ
'02'																	, ; //XB_COLUNA
'Cod. Status'															, ; //XB_DESCRI
'Cod. Status'															, ; //XB_DESCSPA
'Cod. Status'															, ; //XB_DESCENG
''																		, ; //XB_WCONTEM
''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
'SZS'																	, ; //XB_ALIAS
'3'																		, ; //XB_TIPO
'01'																	, ; //XB_SEQ
'01'																	, ; //XB_COLUNA
'Cadastra Novo'															, ; //XB_DESCRI
'Incluye Nuevo'															, ; //XB_DESCSPA
'Add New'																, ; //XB_DESCENG
''																		, ; //XB_WCONTEM
'01'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
'SZS'																	, ; //XB_ALIAS
'4'																		, ; //XB_TIPO
'01'																	, ; //XB_SEQ
'01'																	, ; //XB_COLUNA
'Cod. Status'															, ; //XB_DESCRI
'Cod. Status'															, ; //XB_DESCSPA
'Cod. Status'															, ; //XB_DESCENG
''																		, ; //XB_WCONTEM
'ZS_CODIGO'																} ) //XB_CONTEM

aAdd( aSXB, { ;
'SZS'																	, ; //XB_ALIAS
'4'																		, ; //XB_TIPO
'01'																	, ; //XB_SEQ
'02'																	, ; //XB_COLUNA
'Desc. Status'															, ; //XB_DESCRI
'Desc. Status'															, ; //XB_DESCSPA
'Desc. Status'															, ; //XB_DESCENG
''																		, ; //XB_WCONTEM
'ZS_DESC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
'SZS'																	, ; //XB_ALIAS
'4'																		, ; //XB_TIPO
'01'																	, ; //XB_SEQ
'03'																	, ; //XB_COLUNA
'Qual Acao?'															, ; //XB_DESCRI
'Qual Acao?'															, ; //XB_DESCSPA
'Qual Acao?'															, ; //XB_DESCENG
''																		, ; //XB_WCONTEM
'ZS_ACAO'																} ) //XB_CONTEM

aAdd( aSXB, { ;
'SZS'																	, ; //XB_ALIAS
'4'																		, ; //XB_TIPO
'02'																	, ; //XB_SEQ
'01'																	, ; //XB_COLUNA
'Cod. Status'															, ; //XB_DESCRI
'Cod. Status'															, ; //XB_DESCSPA
'Cod. Status'															, ; //XB_DESCENG
''																		, ; //XB_WCONTEM
'ZS_CODIGO'																} ) //XB_CONTEM

aAdd( aSXB, { ;
'SZS'																	, ; //XB_ALIAS
'4'																		, ; //XB_TIPO
'02'																	, ; //XB_SEQ
'02'																	, ; //XB_COLUNA
'Desc. Status'															, ; //XB_DESCRI
'Desc. Status'															, ; //XB_DESCSPA
'Desc. Status'															, ; //XB_DESCENG
''																		, ; //XB_WCONTEM
'ZS_DESC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
'SZS'																	, ; //XB_ALIAS
'4'																		, ; //XB_TIPO
'02'																	, ; //XB_SEQ
'03'																	, ; //XB_COLUNA
'Qual Acao?'															, ; //XB_DESCRI
'Qual Acao?'															, ; //XB_DESCSPA
'Qual Acao?'															, ; //XB_DESCENG
''																		, ; //XB_WCONTEM
'ZS_ACAO'																} ) //XB_CONTEM

aAdd( aSXB, { ;
'SZS'																	, ; //XB_ALIAS
'5'																		, ; //XB_TIPO
'01'																	, ; //XB_SEQ
''																		, ; //XB_COLUNA
''																		, ; //XB_DESCRI
''																		, ; //XB_DESCSPA
''																		, ; //XB_DESCENG
''																		, ; //XB_WCONTEM
'SZS->ZS_CODIGO'														} ) //XB_CONTEM

//
// Atualizando dicionário
//
oProcess:SetRegua2( Len( aSXB ) )

dbSelectArea( "SXB" )
dbSetOrder( 1 )

For nI := 1 To Len( aSXB )
	
	If !Empty( aSXB[nI][1] )
		
		If !SXB->( dbSeek( PadR( aSXB[nI][1], Len( SXB->XB_ALIAS ) ) + aSXB[nI][2] + aSXB[nI][3] + aSXB[nI][4] ) )
			
			If !( aSXB[nI][1] $ cAlias )
				cAlias += aSXB[nI][1] + "/"
				AutoGrLog( STR0089 + aSXB[nI][1] ) //"Foi incluída a consulta padrão "
			EndIf
			
			RecLock( "SXB", .T. )
			
			For nJ := 1 To Len( aSXB[nI] )
				If FieldPos( aEstrut[nJ] ) > 0
					FieldPut( FieldPos( aEstrut[nJ] ), aSXB[nI][nJ] )
				EndIf
			Next nJ
			
			dbCommit()
			MsUnLock()
			
		Else
			
			//
			// Verifica todos os campos
			//
			For nJ := 1 To Len( aSXB[nI] )
				
				//
				// Se o campo estiver diferente da estrutura
				//
				If aEstrut[nJ] == SXB->( FieldName( nJ ) ) .AND. ;
					!StrTran( AllToChar( SXB->( FieldGet( nJ ) ) ), " ", "" ) == ;
					StrTran( AllToChar( aSXB[nI][nJ]            ), " ", "" )
					
					cMsg := STR0090 + aSXB[nI][1] + STR0066 + SXB->( FieldName( nJ ) ) + ; //"A consulta padrão "###" está com o "
					STR0067 + CRLF + ; //" com o conteúdo"
					"[" + RTrim( AllToChar( SXB->( FieldGet( nJ ) ) ) ) + "]" + CRLF + ;
					STR0091 + CRLF + ; //", e este é diferente do conteúdo"
					"[" + RTrim( AllToChar( aSXB[nI][nJ] ) ) + "]" + CRLF +;
					STR0069 //"Deseja substituir ? "
					
					If      lTodosSim
						nOpcA := 1
					ElseIf  lTodosNao
						nOpcA := 2
					Else
						nOpcA := Aviso( STR0001, cMsg, { STR0070, STR0071, STR0072, STR0073 }, 3, STR0074 ) //"ATUALIZAÇÃO DE DICIONÁRIOS E TABELAS"###"Sim"###"Não"###"Sim p/Todos"###"Não p/Todos"###"Diferença de conteúdo - SXB"
						lTodosSim := ( nOpcA == 3 )
						lTodosNao := ( nOpcA == 4 )
						
						If lTodosSim
							nOpcA := 1
							lTodosSim := MsgNoYes( STR0093 + CRLF + STR0076 ) //"Foi selecionada a opção de REALIZAR TODAS alterações no SXB e NÃO MOSTRAR mais a tela de aviso."###"Confirma a ação [Sim p/Todos] ?"
						EndIf
						
						If lTodosNao
							nOpcA := 2
							lTodosNao := MsgNoYes( STR0094 + CRLF + STR0078 ) //"Foi selecionada a opção de NÃO REALIZAR nenhuma alteração no SXB que esteja diferente da base e NÃO MOSTRAR mais a tela de aviso."###"Confirma esta ação [Não p/Todos]?"
						EndIf
						
					EndIf
					
					If nOpcA == 1
						RecLock( "SXB", .F. )
						FieldPut( FieldPos( aEstrut[nJ] ), aSXB[nI][nJ] )
						dbCommit()
						MsUnLock()
						
						If !( aSXB[nI][1] $ cAlias )
							cAlias += aSXB[nI][1] + "/"
							AutoGrLog( STR0095 + aSXB[nI][1] ) //"Foi alterada a consulta padrão "
						EndIf
						
					EndIf
					
				EndIf
				
			Next
			
		EndIf
		
	EndIf
	
	oProcess:IncRegua2( STR0096 ) //"Atualizando Consultas Padrões (SXB)..."
	
Next nI

AutoGrLog( CRLF + STR0060 + " SXB" + CRLF + Replicate( "-", 128 ) + CRLF ) //"Final da Atualização"

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuHlp
Função de processamento da gravação dos Helps de Campos

@author TOTVS Protheus
@since  02/05/2017
@obs    Gerado por EXPORDIC - V.5.4.1.2 EFS / Upd. V.4.21.17 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuHlp()
Local aHlpPor   := {}
Local aHlpEng   := {}
Local aHlpSpa   := {}

AutoGrLog( STR0055 + " " + STR0137 + CRLF ) //"Ínicio da Atualização"###"Helps de Campos"


oProcess:IncRegua2( STR0115 ) //"Atualizando Helps de Campos ..."

//
// Helps Tabela SA1
//
aHlpPor := {}
aAdd( aHlpPor, 'Data da Inclusão do Cadasro' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PA1_XDTINCL", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( STR0116 + "A1_XDTINCL" ) //"Atualizado o Help do campo "

aHlpPor := {}
aAdd( aHlpPor, 'Msg. atualizada através da importação' )
aAdd( aHlpPor, 'dos arquivos Risk Rating.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PA1_XMSGCIS", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( STR0116 + "A1_XMSGCIS" ) //"Atualizado o Help do campo "

//
// Helps Tabela SC5
//
aHlpPor := {}
aAdd( aHlpPor, 'Aviso da situação da analise de Crédito' )
aAdd( aHlpPor, 'baseado nos dados referentes ao Risk' )
aAdd( aHlpPor, 'Rating.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PC5_XAVISO ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( STR0116 + "C5_XAVISO" ) //"Atualizado o Help do campo "

//
// Helps Tabela SC9
//
aHlpPor := {}
aAdd( aHlpPor, 'Aviso da situação da analise de Crédito' )
aAdd( aHlpPor, 'baseado nos dados referentes ao Risk' )
aAdd( aHlpPor, 'Rating.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PC9_XAVISO ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( STR0116 + "C9_XAVISO" ) //"Atualizado o Help do campo "

//
// Helps Tabela SZR
//
aHlpPor := {}
aAdd( aHlpPor, 'Codigo do Status.' )
aAdd( aHlpPor, 'Utilizado para validação dos status da' )
aAdd( aHlpPor, 'Receita Federal com base no arquivo' )
aAdd( aHlpPor, 'RiskRating - CISP.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PZR_CODIGO ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( STR0116 + "ZR_CODIGO" ) //"Atualizado o Help do campo "

aHlpPor := {}
aAdd( aHlpPor, 'Descricao do Status.' )
aAdd( aHlpPor, 'Esta mensagem devera ser EXATAMENTE' )
aAdd( aHlpPor, 'IGUAL a mensagem que e enviada dentro' )
aAdd( aHlpPor, 'doarquivo R.Rating - CISP.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PZR_DESC   ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( STR0116 + "ZR_DESC" ) //"Atualizado o Help do campo "

aHlpPor := {}
aAdd( aHlpPor, 'Qual a Acao que o status em questao' )
aAdd( aHlpPor, 'deve ter?' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PZR_ACAO   ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( STR0116 + "ZR_ACAO" ) //"Atualizado o Help do campo "

//
// Helps Tabela SZS
//
aHlpPor := {}
aAdd( aHlpPor, 'Codigo do Status Sintegra.' )
aAdd( aHlpPor, 'Devera ser criado um codigo para cada' )
aAdd( aHlpPor, 'Status encontrado no arquivo R.Rating -' )
aAdd( aHlpPor, 'CISP.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PZS_CODIGO ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( STR0116 + "ZS_CODIGO" ) //"Atualizado o Help do campo "

aHlpPor := {}
aAdd( aHlpPor, 'Descricao do Status.' )
aAdd( aHlpPor, 'Esta mensagem devera ser EXATAMENTE' )
aAdd( aHlpPor, 'IGUAL a mensagem que e enviada dentro' )
aAdd( aHlpPor, 'doarquivo R.Rating - CISP.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PZS_DESC   ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( STR0116 + "ZS_DESC" ) //"Atualizado o Help do campo "

aHlpPor := {}
aAdd( aHlpPor, 'Qual deve ser a Acao a ser tomada do' )
aAdd( aHlpPor, 'Status.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PZS_ACAO   ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( STR0116 + "ZS_ACAO" ) //"Atualizado o Help do campo "

//
// Helps Tabela SZU
//
aHlpPor := {}
aAdd( aHlpPor, 'Data da Fundaçao do Cliente.' )
aAdd( aHlpPor, 'Campo preenchido atraves da leitura do' )
aAdd( aHlpPor, 'arquivo Risk Rating Master' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PZU_DTFUNCL", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( STR0116 + "ZU_DTFUNCL" ) //"Atualizado o Help do campo "

aHlpPor := {}
aAdd( aHlpPor, 'Data da Consulta na Receita Federal.' )
aAdd( aHlpPor, 'Campo preenchido atraves da leitura do' )
aAdd( aHlpPor, 'arquivo Risk Rating Master' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PZU_DTCONRF", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( STR0116 + "ZU_DTCONRF" ) //"Atualizado o Help do campo "

aHlpPor := {}
aAdd( aHlpPor, 'Data da Consulta SINTEGRA (SEFAZ do' )
aAdd( aHlpPor, 'ESTADO)' )
aAdd( aHlpPor, 'Campo preenchido atraves da leitura do' )
aAdd( aHlpPor, 'arquivo Risk Rating Master' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PZU_DTCONSI", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( STR0116 + "ZU_DTCONSI" ) //"Atualizado o Help do campo "

aHlpPor := {}
aAdd( aHlpPor, 'Segmento Associado.' )
aAdd( aHlpPor, 'Campo preenchido atraves da leitura do' )
aAdd( aHlpPor, 'arquivo Risk Rating Master' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PZU_SEGASS ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( STR0116 + "ZU_SEGASS" ) //"Atualizado o Help do campo "

aHlpPor := {}
aAdd( aHlpPor, 'Valor Limite Credito.' )
aAdd( aHlpPor, 'Campo preenchido atraves da leitura do' )
aAdd( aHlpPor, 'arquivo Risk Rating Master' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PZU_VLLIMCR", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( STR0116 + "ZU_VLLIMCR" ) //"Atualizado o Help do campo "

aHlpPor := {}
aAdd( aHlpPor, 'Qtd. Associado com LC.' )
aAdd( aHlpPor, 'Campo preenchido atraves da leitura do' )
aAdd( aHlpPor, 'arquivo Risk Rating Master.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PZU_QTDASLC", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( STR0116 + "ZU_QTDASLC" ) //"Atualizado o Help do campo "

aHlpPor := {}
aAdd( aHlpPor, 'Quantidad de Cheques sem fundo de' )
aAdd( aHlpPor, 'Sóciosdo Cliente.' )
aAdd( aHlpPor, 'Campo preenchido atraves da leitura' )
aAdd( aHlpPor, 'do  arquivo Risk Rating Master.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PZU_QCHSCLI", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( STR0116 + "ZU_QCHSCLI" ) //"Atualizado o Help do campo "

aHlpPor := {}
aAdd( aHlpPor, 'Total Valor Maior Acumulo.' )
aAdd( aHlpPor, 'Campo preenchido atraves da leitura do' )
aAdd( aHlpPor, 'arquivo Risk Rating Master.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PZU_VLMACU ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( STR0116 + "ZU_VLMACU" ) //"Atualizado o Help do campo "

aHlpPor := {}
aAdd( aHlpPor, 'Quantidade Associado com Valor Maior' )
aAdd( aHlpPor, 'Acumulo.' )
aAdd( aHlpPor, 'Campo preenchido atraves da leitura do' )
aAdd( aHlpPor, 'arquivo Risk Rating Master.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PZU_QASVLAC", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( STR0116 + "ZU_QASVLAC" ) //"Atualizado o Help do campo "

aHlpPor := {}
aAdd( aHlpPor, 'Cliente nao Cadastrado.' )
aAdd( aHlpPor, 'Mensagem informada pelo arquivo Risk' )
aAdd( aHlpPor, 'Rating Master.' )
aAdd( aHlpPor, 'CLIENTE NÃO CADASTRA NA CISP' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PZU_MSGRISK", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( STR0116 + "ZU_MSGRISK" ) //"Atualizado o Help do campo "

aHlpPor := {}
aAdd( aHlpPor, 'Atualizado por.' )
aAdd( aHlpPor, '1 = Risk Rating Plus;' )
aAdd( aHlpPor, '2 = Risk Rating Master;' )
aAdd( aHlpPor, 'Campo preenchido atraves da leitura do' )
aAdd( aHlpPor, 'arquivo Risk Rating Plus / Master.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PZU_ARQATUL", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( STR0116 + "ZU_ARQATUL" ) //"Atualizado o Help do campo "

aHlpPor := {}
aAdd( aHlpPor, 'Codigo do Status da Receita Federal.' )
aAdd( aHlpPor, 'Campo utilizado para controle de regras.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PZU_CSTATRF", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( STR0116 + "ZU_CSTATRF" ) //"Atualizado o Help do campo "

aHlpPor := {}
aAdd( aHlpPor, 'Codigo do Status do Sintegra.' )
aAdd( aHlpPor, 'Campo utilizado para controle de regras.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PZU_CSTATSI", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( STR0116 + "ZU_CSTATSI" ) //"Atualizado o Help do campo "

//
// Helps Tabela SZV
//
aHlpPor := {}
aAdd( aHlpPor, 'Classificaçao do Risco Risk Rating.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PZV_RISCO  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( STR0116 + "ZV_RISCO" ) //"Atualizado o Help do campo "

aHlpPor := {}
aAdd( aHlpPor, 'Pontualidade aceita para' )
aAdd( aHlpPor, 'liberação da regra de Analise de' )
aAdd( aHlpPor, 'Credito Risk Rating.' )
aAdd( aHlpPor, 'Atualmente campo informativo.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PZV_PONTUAL", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( STR0116 + "ZV_PONTUAL" ) //"Atualizado o Help do campo "

aHlpPor := {}
aAdd( aHlpPor, 'Rel. Mercado aceito para regra' )
aAdd( aHlpPor, 'de Analise de Crédito Risk Rating.' )
aAdd( aHlpPor, 'Atualmente campo informativo.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PZV_RELMERC", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( STR0116 + "ZV_RELMERC" ) //"Atualizado o Help do campo "

aHlpPor := {}
aAdd( aHlpPor, 'Ocorrencia Negativa aceita para' )
aAdd( aHlpPor, 'regra de Analise de Crédito Risk' )
aAdd( aHlpPor, 'Rating.Atualmente campo informativo.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PZV_OCNEG  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( STR0116 + "ZV_OCNEG" ) //"Atualizado o Help do campo "

aHlpPor := {}
aAdd( aHlpPor, 'Credito na Praca aceita para' )
aAdd( aHlpPor, 'regra de Analise de Crédito Risk' )
aAdd( aHlpPor, 'Rating.Atualmente campo informativo.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PZV_CREDPRC", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( STR0116 + "ZV_CREDPRC" ) //"Atualizado o Help do campo "

aHlpPor := {}
aAdd( aHlpPor, 'Densidade Comercial aceito para regra' )
aAdd( aHlpPor, 'de Analise de Crédito Risk Rating.' )
aAdd( aHlpPor, 'Valida importação dos arquivos TXT,' )
aAdd( aHlpPor, 'regra de colocação de Pedidos de Vendas' )
aAdd( aHlpPor, 'para campo informativo e também regra' )
aAdd( aHlpPor, 'deliberacão de pedidos de vendas' )
aAdd( aHlpPor, '(Analise de Crédito CISP).' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PZV_DENSCOM", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( STR0116 + "ZV_DENSCOM" ) //"Atualizado o Help do campo "

aHlpPor := {}
aAdd( aHlpPor, 'Dias do Limite de Credito do Cliente.' )
aAdd( aHlpPor, 'Este campo informa a quantidade em dias' )
aAdd( aHlpPor, 'que a rotina devera atualizar o LC do' )
aAdd( aHlpPor, 'Cliente com base no campo Atu. Dt. LC.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PZV_DIASATU", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( STR0116 + "ZV_DIASATU" ) //"Atualizado o Help do campo "

aHlpPor := {}
aAdd( aHlpPor, 'Atualiza a Data de Limite de Credito do' )
aAdd( aHlpPor, 'Cliente.' )
aAdd( aHlpPor, 'A quantidade de dias informado deverá:' )
aAdd( aHlpPor, 'A=Adicionar a Data Base;' )
aAdd( aHlpPor, 'S=Subtrair da Data Base;' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PZV_CALCDIA", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( STR0116 + "ZV_CALCDIA" ) //"Atualizado o Help do campo "

aHlpPor := {}
aAdd( aHlpPor, 'Mensagem de Retorno da Regra.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PZV_MSGRET ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( STR0116 + "ZV_MSGRET" ) //"Atualizado o Help do campo "

AutoGrLog( CRLF + STR0060 + " " + STR0137 + CRLF + Replicate( "-", 128 ) + CRLF ) //"Final da Atualização"###"Helps de Campos"

Return {}


//--------------------------------------------------------------------
/*/{Protheus.doc} EscEmpresa
Função genérica para escolha de Empresa, montada pelo SM0

@return aRet Vetor contendo as seleções feitas.
Se não for marcada nenhuma o vetor volta vazio

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function EscEmpresa()

//---------------------------------------------
// Parâmetro  nTipo
// 1 - Monta com Todas Empresas/Filiais
// 2 - Monta só com Empresas
// 3 - Monta só com Filiais de uma Empresa
//
// Parâmetro  aMarcadas
// Vetor com Empresas/Filiais pré marcadas
//
// Parâmetro  cEmpSel
// Empresa que será usada para montar seleção
//---------------------------------------------
Local   aRet      := {}
Local   aSalvAmb  := GetArea()
Local   aSalvSM0  := {}
Local   aVetor    := {}
Local   cMascEmp  := "??"
Local   cVar      := ""
Local   lChk      := .F.
Local   lOk       := .F.
Local   lTeveMarc := .F.
Local   oNo       := LoadBitmap( GetResources(), "LBNO" )
Local   oOk       := LoadBitmap( GetResources(), "LBOK" )
Local   oDlg, oChkMar, oLbx, oMascEmp, oSay
Local   oButDMar, oButInv, oButMarc, oButOk, oButCanc

Local   aMarcadas := {}


If !MyOpenSm0(.F.)
	Return aRet
EndIf


dbSelectArea( "SM0" )
aSalvSM0 := SM0->( GetArea() )
dbSetOrder( 1 )
dbGoTop()

While !SM0->( EOF() )
	
	If aScan( aVetor, {|x| x[2] == SM0->M0_CODIGO} ) == 0
		aAdd(  aVetor, { aScan( aMarcadas, {|x| x[1] == SM0->M0_CODIGO .and. x[2] == SM0->M0_CODFIL} ) > 0, SM0->M0_CODIGO, SM0->M0_CODFIL, SM0->M0_NOME, SM0->M0_FILIAL } )
	EndIf
	
	dbSkip()
End

RestArea( aSalvSM0 )

Define MSDialog  oDlg Title "" From 0, 0 To 280, 395 Pixel

oDlg:cToolTip := STR0117 //"Tela para Múltiplas Seleções de Empresas/Filiais"

oDlg:cTitle   := STR0118 //"Selecione a(s) Empresa(s) para Atualização"

@ 10, 10 Listbox  oLbx Var  cVar Fields Header " ", " ", STR0119 Size 178, 095 Of oDlg Pixel //"Empresa"
oLbx:SetArray(  aVetor )
oLbx:bLine := {|| {IIf( aVetor[oLbx:nAt, 1], oOk, oNo ), ;
aVetor[oLbx:nAt, 2], ;
aVetor[oLbx:nAt, 4]}}
oLbx:BlDblClick := { || aVetor[oLbx:nAt, 1] := !aVetor[oLbx:nAt, 1], VerTodos( aVetor, @lChk, oChkMar ), oChkMar:Refresh(), oLbx:Refresh()}
oLbx:cToolTip   :=  oDlg:cTitle
oLbx:lHScroll   := .F. // NoScroll

@ 112, 10 CheckBox oChkMar Var  lChk Prompt STR0120 Message STR0121 Size 40, 007 Pixel Of oDlg; //"Todos"###"Marca / Desmarca"+ CRLF + "Todos"
on Click MarcaTodos( lChk, @aVetor, oLbx )

// Marca/Desmarca por mascara
@ 113, 51 Say   oSay Prompt STR0119 Size  40, 08 Of oDlg Pixel //"Empresa"
@ 112, 80 MSGet oMascEmp Var  cMascEmp Size  05, 05 Pixel Picture "@!"  Valid (  cMascEmp := StrTran( cMascEmp, " ", "?" ), oMascEmp:Refresh(), .T. ) ;
Message STR0124  Of oDlg //"Máscara Empresa ( ?? )"
oSay:cToolTip := oMascEmp:cToolTip

@ 128, 10 Button oButInv    Prompt STR0122  Size 32, 12 Pixel Action ( InvSelecao( @aVetor, oLbx, @lChk, oChkMar ), VerTodos( aVetor, @lChk, oChkMar ) ) ; //"&Inverter"
Message STR0123 Of oDlg //"Inverter Seleção"
oButInv:SetCss( CSSBOTAO )
@ 128, 50 Button oButMarc   Prompt STR0125    Size 32, 12 Pixel Action ( MarcaMas( oLbx, aVetor, cMascEmp, .T. ), VerTodos( aVetor, @lChk, oChkMar ) ) ; //"&Marcar"
Message STR0126    Of oDlg //"Marcar usando" + CRLF + "máscara ( ?? )"
oButMarc:SetCss( CSSBOTAO )
@ 128, 80 Button oButDMar   Prompt STR0127 Size 32, 12 Pixel Action ( MarcaMas( oLbx, aVetor, cMascEmp, .F. ), VerTodos( aVetor, @lChk, oChkMar ) ) ; //"&Desmarcar"
Message STR0128 Of oDlg //"Desmarcar usando" + CRLF + "máscara ( ?? )"
oButDMar:SetCss( CSSBOTAO )
@ 112, 157  Button oButOk   Prompt STR0147  Size 32, 12 Pixel Action (  RetSelecao( @aRet, aVetor ), IIf( Len( aRet ) > 0, oDlg:End(), MsgStop( STR0151, "UPDCISP" ) ) ) ; //"Processar"###"Ao menos um grupo deve ser selecionado"
Message STR0145 Of oDlg //"Confirma a seleção e efetua" + CRLF + "o processamento"
oButOk:SetCss( CSSBOTAO )
@ 128, 157  Button oButCanc Prompt STR0148   Size 32, 12 Pixel Action ( IIf( lTeveMarc, aRet :=  aMarcadas, .T. ), oDlg:End() ) ; //"Cancelar"
Message STR0146 Of oDlg //"Cancela o processamento" + CRLF + "e abandona a aplicação"
oButCanc:SetCss( CSSBOTAO )

Activate MSDialog  oDlg Center

RestArea( aSalvAmb )
dbSelectArea( "SM0" )
dbCloseArea()

Return  aRet


//--------------------------------------------------------------------
/*/{Protheus.doc} MarcaTodos
Função auxiliar para marcar/desmarcar todos os ítens do ListBox ativo

@param lMarca  Contéudo para marca .T./.F.
@param aVetor  Vetor do ListBox
@param oLbx    Objeto do ListBox

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function MarcaTodos( lMarca, aVetor, oLbx )
Local  nI := 0

For nI := 1 To Len( aVetor )
	aVetor[nI][1] := lMarca
Next nI

oLbx:Refresh()

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} InvSelecao
Função auxiliar para inverter a seleção do ListBox ativo

@param aVetor  Vetor do ListBox
@param oLbx    Objeto do ListBox

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function InvSelecao( aVetor, oLbx )
Local  nI := 0

For nI := 1 To Len( aVetor )
	aVetor[nI][1] := !aVetor[nI][1]
Next nI

oLbx:Refresh()

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} RetSelecao
Função auxiliar que monta o retorno com as seleções

@param aRet    Array que terá o retorno das seleções (é alterado internamente)
@param aVetor  Vetor do ListBox

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function RetSelecao( aRet, aVetor )
Local  nI    := 0

aRet := {}
For nI := 1 To Len( aVetor )
	If aVetor[nI][1]
		aAdd( aRet, { aVetor[nI][2] , aVetor[nI][3], aVetor[nI][2] +  aVetor[nI][3] } )
	EndIf
Next nI

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} MarcaMas
Função para marcar/desmarcar usando máscaras

@param oLbx     Objeto do ListBox
@param aVetor   Vetor do ListBox
@param cMascEmp Campo com a máscara (???)
@param lMarDes  Marca a ser atribuída .T./.F.

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function MarcaMas( oLbx, aVetor, cMascEmp, lMarDes )
Local cPos1 := SubStr( cMascEmp, 1, 1 )
Local cPos2 := SubStr( cMascEmp, 2, 1 )
Local nPos  := oLbx:nAt
Local nZ    := 0

For nZ := 1 To Len( aVetor )
	If cPos1 == "?" .or. SubStr( aVetor[nZ][2], 1, 1 ) == cPos1
		If cPos2 == "?" .or. SubStr( aVetor[nZ][2], 2, 1 ) == cPos2
			aVetor[nZ][1] := lMarDes
		EndIf
	EndIf
Next

oLbx:nAt := nPos
oLbx:Refresh()

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} VerTodos
Função auxiliar para verificar se estão todos marcados ou não

@param aVetor   Vetor do ListBox
@param lChk     Marca do CheckBox do marca todos (referncia)
@param oChkMar  Objeto de CheckBox do marca todos

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function VerTodos( aVetor, lChk, oChkMar )
Local lTTrue := .T.
Local nI     := 0

For nI := 1 To Len( aVetor )
	lTTrue := IIf( !aVetor[nI][1], .F., lTTrue )
Next nI

lChk := IIf( lTTrue, .T., .F. )
oChkMar:Refresh()

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} MyOpenSM0
Função de processamento abertura do SM0 modo exclusivo

@author TOTVS Protheus
@since  02/05/2017
@obs    Gerado por EXPORDIC - V.5.4.1.2 EFS / Upd. V.4.21.17 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function MyOpenSM0(lShared)
Local lOpen := .F.
Local nLoop := 0

For nLoop := 1 To 20
	dbUseArea( .T., , "SIGAMAT.EMP", "SM0", lShared, .F. )
	
	If !Empty( Select( "SM0" ) )
		lOpen := .T.
		dbSetIndex( "SIGAMAT.IND" )
		Exit
	EndIf
	
	Sleep( 500 )
	
Next nLoop

If !lOpen
	MsgStop( STR0052 + ; //"Não foi possível a abertura da tabela "
	IIf( lShared, STR0053, STR0054 ), STR0022 ) //"de empresas (SM0)."###"de empresas (SM0) de forma exclusiva."###"ATENÇÃO"
EndIf

Return lOpen


//--------------------------------------------------------------------
/*/{Protheus.doc} LeLog
Função de leitura do LOG gerado com limitacao de string

@author TOTVS Protheus
@since  02/05/2017
@obs    Gerado por EXPORDIC - V.5.4.1.2 EFS / Upd. V.4.21.17 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function LeLog()
Local cRet  := ""
Local cFile := NomeAutoLog()
Local cAux  := ""

FT_FUSE( cFile )
FT_FGOTOP()

While !FT_FEOF()
	
	cAux := FT_FREADLN()
	
	If Len( cRet ) + Len( cAux ) < 1048000
		cRet += cAux + CRLF
	Else
		cRet += CRLF
		cRet += Replicate( "=" , 128 ) + CRLF
		cRet += "Tamanho de exibição maxima do LOG alcançado." + CRLF
		cRet += "LOG Completo no arquivo " + cFile + CRLF
		cRet += Replicate( "=" , 128 ) + CRLF
		Exit
	EndIf
	
	FT_FSKIP()
End

FT_FUSE()

Return cRet


/////////////////////////////////////////////////////////////////////////////
