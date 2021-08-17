#INCLUDE "PROTHEUS.CH"

#DEFINE X3_USADO_EMUSO "€€€€€€€€€€€€€€ "
#DEFINE X3_USADO_NAOUSADO "€€€€€€€€€€€€€€€"   
#DEFINE X3_OBRIGAT "Á€" 
#DEFINE X3_RESER "þÀ"  
#DEFINE X3_RESER_NUMERICO "øÇ"    
 

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
/*/{Protheus.doc} UPDFST
Função de update de dicionários para compatibilização

@author TOTVS Protheus
@since  09/10/15
@obs    Gerado por EXPORDIC - V.5.0.0.0 EFS / Upd. V.4.20.15 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
User Function UPDX001( cEmpAmb, cFilAmb )

Local   aSay      := {}
Local   aButton   := {}
Local   aMarcadas := {}
Local   cTitulo   := "ATUALIZAÇÃO DE DICIONÁRIOS E TABELAS"
Local   cDesc1    := "Esta rotina tem como função fazer  a atualização  dos dicionários do Sistema ( SX?/SIX )"
Local   cDesc2    := "Este processo deve ser executado em modo EXCLUSIVO, ou seja não podem haver outros"
Local   cDesc3    := "usuários  ou  jobs utilizando  o sistema.  É EXTREMAMENTE recomendavél  que  se  faça um"
Local   cDesc4    := "BACKUP  dos DICIONÁRIOS  e da  BASE DE DADOS antes desta atualização, para que caso "
Local   cDesc5    := "ocorram eventuais falhas, esse backup possa ser restaurado."
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
		If lAuto .OR. MsgNoYes( "Confirma a atualização dos dicionários ?", cTitulo )
			oProcess := MsNewProcess():New( { | lEnd | lOk := FSTProc( @lEnd, aMarcadas, lAuto ) }, "Atualizando", "Aguarde, atualizando ...", .F. )
			oProcess:Activate()

			If lAuto
				If lOk
					MsgStop( "Atualização Realizada.", "UPDFST" )
				Else
					MsgStop( "Atualização não Realizada.", "UPDFST" )
				EndIf
				dbCloseAll()
			Else
				If lOk
					Final( "Atualização Concluída." )
				Else
					Final( "Atualização não Realizada." )
				EndIf
			EndIf

		Else
			MsgStop( "Atualização não Realizada.", "UPDFST" )

		EndIf

	Else
		MsgStop( "Atualização não Realizada.", "UPDFST" )

	EndIf

EndIf

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSTProc
Função de processamento da gravação dos arquivos

@author TOTVS Protheus
@since  09/10/15
@obs    Gerado por EXPORDIC - V.5.0.0.0 EFS / Upd. V.4.20.15 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSTProc( lEnd, aMarcadas, lAuto )
Local   aInfo     := {}
Local   aRecnoSM0 := {}
Local   cAux      := ""
Local   cFile     := ""
Local   cFileLog  := ""
Local   cMask     := "Arquivos Texto" + "(*.TXT)|*.txt|"
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
				MsgStop( "Atualização da empresa " + aRecnoSM0[nI][2] + " não efetuada." )
				Exit
			EndIf

			SM0->( dbGoTo( aRecnoSM0[nI][1] ) )

			RpcSetType( 3 )
			RpcSetEnv( SM0->M0_CODIGO, SM0->M0_CODFIL )

			lMsFinalAuto := .F.
			lMsHelpAuto  := .F.

			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( Replicate( " ", 128 ) )
			AutoGrLog( "LOG DA ATUALIZAÇÃO DOS DICIONÁRIOS" )
			AutoGrLog( Replicate( " ", 128 ) )
			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( " " )
			AutoGrLog( " Dados Ambiente" )
			AutoGrLog( " --------------------" )
			AutoGrLog( " Empresa / Filial...: " + cEmpAnt + "/" + cFilAnt )
			AutoGrLog( " Nome Empresa.......: " + Capital( AllTrim( GetAdvFVal( "SM0", "M0_NOMECOM", cEmpAnt + cFilAnt, 1, "" ) ) ) )
			AutoGrLog( " Nome Filial........: " + Capital( AllTrim( GetAdvFVal( "SM0", "M0_FILIAL" , cEmpAnt + cFilAnt, 1, "" ) ) ) )
			AutoGrLog( " DataBase...........: " + DtoC( dDataBase ) )
			AutoGrLog( " Data / Hora Ínicio.: " + DtoC( Date() )  + " / " + Time() )
			AutoGrLog( " Environment........: " + GetEnvServer()  )
			AutoGrLog( " StartPath..........: " + GetSrvProfString( "StartPath", "" ) )
			AutoGrLog( " RootPath...........: " + GetSrvProfString( "RootPath" , "" ) )
			AutoGrLog( " Versão.............: " + GetVersao(.T.) )
			AutoGrLog( " Usuário TOTVS .....: " + __cUserId + " " +  cUserName )
			AutoGrLog( " Computer Name......: " + GetComputerName() )

			aInfo   := GetUserInfo()
			If ( nPos    := aScan( aInfo,{ |x,y| x[3] == ThreadId() } ) ) > 0
				AutoGrLog( " " )
				AutoGrLog( " Dados Thread" )
				AutoGrLog( " --------------------" )
				AutoGrLog( " Usuário da Rede....: " + aInfo[nPos][1] )
				AutoGrLog( " Estação............: " + aInfo[nPos][2] )
				AutoGrLog( " Programa Inicial...: " + aInfo[nPos][5] )
				AutoGrLog( " Environment........: " + aInfo[nPos][6] )
				AutoGrLog( " Conexão............: " + AllTrim( StrTran( StrTran( aInfo[nPos][7], Chr( 13 ), "" ), Chr( 10 ), "" ) ) )
			EndIf
			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( " " )

			If !lAuto
				AutoGrLog( Replicate( "-", 128 ) )
				AutoGrLog( "Empresa : " + SM0->M0_CODIGO + "/" + SM0->M0_NOME + CRLF )
			EndIf

			oProcess:SetRegua1( 8 )

			//------------------------------------
			// Atualiza o dicionário SX2
			//------------------------------------
			oProcess:IncRegua1( "Dicionário de arquivos" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FSAtuSX2()

			//------------------------------------
			// Atualiza o dicionário SX3
			//------------------------------------
			FSAtuSX3()

			//------------------------------------
			// Atualiza o dicionário SIX
			//------------------------------------
			oProcess:IncRegua1( "Dicionário de índices" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FSAtuSIX()

			oProcess:IncRegua1( "Dicionário de dados" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			oProcess:IncRegua2( "Atualizando campos/índices" )

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
					MsgStop( "Ocorreu um erro desconhecido durante a atualização da tabela : " + aArqUpd[nX] + ". Verifique a integridade do dicionário e da tabela.", "ATENÇÃO" )
					AutoGrLog( "Ocorreu um erro desconhecido durante a atualização da estrutura da tabela : " + aArqUpd[nX] )
				EndIf

				If cTopBuild >= "20090811" .AND. TcInternal( 89 ) == "CLOB_SUPPORTED"
					TcInternal( 25, "OFF" )
				EndIf

			Next nX


			//------------------------------------
			// Atualiza o dicionário SX6
			//------------------------------------
			
			oProcess:IncRegua1( "Dicionário de parâmetros" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FSAtuSX6()

			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( " Data / Hora Final.: " + DtoC( Date() ) + " / " + Time() )
			AutoGrLog( Replicate( "-", 128 ) )

			//------------------------------------
			// Atualiza o dicionário SX7
			//------------------------------------
			oProcess:IncRegua1( "Dicionário de gatilhos" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FSAtuSX7()

			//------------------------------------
			// Atualiza os helps
			//------------------------------------
			oProcess:IncRegua1( "Helps de Campo" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FSAtuHlp()

			//------------------------------------
			// Executa funções de LOAD em tabelas
			//------------------------------------
			oProcess:IncRegua1( "Carga em tabelas" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			LoadTab()

			//------------------------------------
			// Executa funções de LOAD em tabelas
			//------------------------------------
			oProcess:IncRegua1( "Carga em tabela SX5" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			LoadSX5()


			//------------------------------------
			// Executa alterações em campos
			//------------------------------------

			oProcess:IncRegua1( "Alterações em campos" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
//			SetFld()

			//------------------------------------
			// Executa Update Externo
			//------------------------------------
//			If FindFunction("U_UPDEXT")
				oProcess:IncRegua1( "Update Externo" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
				AutoGrLog( "Executando Update Externo [U_UPDEXT()]." )
				xUPDEXT()
//        	EndIf
        	
			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( " Data / Hora Final.: " + DtoC( Date() ) + " / " + Time() )
			AutoGrLog( Replicate( "-", 128 ) )

			RpcClearEnv()

		Next nI

		
		If !lAuto

			cTexto := LeLog()

			Define Font oFont Name "Mono AS" Size 5, 12

			Define MsDialog oDlg Title "Atualização concluida." From 3, 0 to 340, 417 Pixel

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
@since  09/10/15
@obs    Gerado por EXPORDIC - V.5.0.0.0 EFS / Upd. V.4.20.15 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSX2()
Local aEstrut   := {}
Local aSX2      := {}
Local cAlias    := ""
Local cCpoUpd   := "X2_ROTINA /X2_UNICO  /X2_DISPLAY/X2_SYSOBJ /X2_USROBJ /X2_POSLGT /"
Local cEmpr     := ""
Local cPath     := ""
Local nI        := 0
Local nJ        := 0

AutoGrLog( "Ínicio da Atualização" + " SX2" + CRLF )

aEstrut := { "X2_CHAVE"  , "X2_PATH"   , "X2_ARQUIVO", "X2_NOME"   , "X2_NOMESPA", "X2_NOMEENG", "X2_MODO"   , ;
             "X2_TTS"    , "X2_ROTINA" , "X2_PYME"   , "X2_UNICO"  , "X2_DISPLAY", "X2_SYSOBJ" , "X2_USROBJ" , ;
             "X2_POSLGT" , "X2_MODOEMP", "X2_MODOUN" , "X2_MODULO" }


dbSelectArea( "SX2" )
SX2->( dbSetOrder( 1 ) )
SX2->( dbGoTop() )
cPath := SX2->X2_PATH
cPath := IIf( Right( AllTrim( cPath ), 1 ) <> "\", PadR( AllTrim( cPath ) + "\", Len( cPath ) ), cPath )
cEmpr := Substr( SX2->X2_ARQUIVO, 4 )
  
/*
//
// Tabela PNF
//
aAdd( aSX2, { ;
	'PNF'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'PNF'+cEmpr																, ; //X2_ARQUIVO
	'AMARRACAO CLIENTE/EMPRESA'												, ; //X2_NOME
	'AMARRACAO CLIENTE/EMPRESA'												, ; //X2_NOMESPA
	'AMARRACAO CLIENTE/EMPRESA'												, ; //X2_NOMEENG
	'C'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	''																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	''																		, ; //X2_DISPLAY
	''																		, ; //X2_SYSOBJ
	''																		, ; //X2_USROBJ
	''																		, ; //X2_POSLGT
	'E'																		, ; //X2_MODOEMP
	'E'																		, ; //X2_MODOUN
	5																		} ) //X2_MODULO
*/

//
// Atualizando dicionário
//
oProcess:SetRegua2( Len( aSX2 ) )

dbSelectArea( "SX2" )
dbSetOrder( 1 )

For nI := 1 To Len( aSX2 )

	oProcess:IncRegua2( "Atualizando Arquivos (SX2)..." )

	If !SX2->( dbSeek( aSX2[nI][1] ) )

		If !( aSX2[nI][1] $ cAlias )
			cAlias += aSX2[nI][1] + "/"
			AutoGrLog( "Foi incluída a tabela " + aSX2[nI][1] )
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

	Else

		If  !( StrTran( Upper( AllTrim( SX2->X2_UNICO ) ), " ", "" ) == StrTran( Upper( AllTrim( aSX2[nI][12]  ) ), " ", "" ) )
			RecLock( "SX2", .F. )
			SX2->X2_UNICO := aSX2[nI][12]
			MsUnlock()

			If MSFILE( RetSqlName( aSX2[nI][1] ),RetSqlName( aSX2[nI][1] ) + "_UNQ"  )
				TcInternal( 60, RetSqlName( aSX2[nI][1] ) + "|" + RetSqlName( aSX2[nI][1] ) + "_UNQ" )
			EndIf

			AutoGrLog( "Foi alterada a chave única da tabela " + aSX2[nI][1] )
		EndIf

		RecLock( "SX2", .F. )
		For nJ := 1 To Len( aSX2[nI] )
			If FieldPos( aEstrut[nJ] ) > 0
				If PadR( aEstrut[nJ], 10 ) $ cCpoUpd
					FieldPut( FieldPos( aEstrut[nJ] ), aSX2[nI][nJ] )
				EndIf

			EndIf
		Next nJ
		MsUnLock()

	EndIf

Next nI

AutoGrLog( CRLF + "Final da Atualização" + " SX2" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSX3
Função de processamento da gravação do SX3 - Campos

@author TOTVS Protheus
@since  09/10/15
@obs    Gerado por EXPORDIC - V.5.0.0.0 EFS / Upd. V.4.20.15 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSX3()
Local aEstrut   := {} 
Local aCmb      := {}
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

AutoGrLog( "Ínicio da Atualização" + " SX3" + CRLF )

aEstrut := { { "X3_ARQUIVO", 0 }, { "X3_ORDEM"  , 0 }, { "X3_CAMPO"  , 0 }, { "X3_TIPO"   , 0 }, { "X3_TAMANHO", 0 }, { "X3_DECIMAL", 0 }, { "X3_TITULO" , 0 }, ;
             { "X3_TITSPA" , 0 }, { "X3_TITENG" , 0 }, { "X3_DESCRIC", 0 }, { "X3_DESCSPA", 0 }, { "X3_DESCENG", 0 }, { "X3_PICTURE", 0 }, { "X3_VALID"  , 0 }, ;
             { "X3_USADO"  , 0 }, { "X3_RELACAO", 0 }, { "X3_F3"     , 0 }, { "X3_NIVEL"  , 0 }, { "X3_RESERV" , 0 }, { "X3_CHECK"  , 0 }, { "X3_TRIGGER", 0 }, ;
             { "X3_PROPRI" , 0 }, { "X3_BROWSE" , 0 }, { "X3_VISUAL" , 0 }, { "X3_CONTEXT", 0 }, { "X3_OBRIGAT", 0 }, { "X3_VLDUSER", 0 }, { "X3_CBOX"   , 0 }, ;
             { "X3_CBOXSPA", 0 }, { "X3_CBOXENG", 0 }, { "X3_PICTVAR", 0 }, { "X3_WHEN"   , 0 }, { "X3_INIBRW" , 0 }, { "X3_GRPSXG" , 0 }, { "X3_FOLDER" , 0 }, ;
             { "X3_CONDSQL", 0 }, { "X3_CHKSQL" , 0 }, { "X3_IDXSRV" , 0 }, { "X3_ORTOGRA", 0 }, { "X3_TELA"   , 0 }, { "X3_POSLGT" , 0 }, { "X3_IDXFLD" , 0 }, ;
             { "X3_AGRUP"  , 0 }, { "X3_PYME"   , 0 } }

aEval( aEstrut, { |x| x[2] := SX3->( FieldPos( x[1] ) ) } )



aAdd( aSX3, { ;
	'SE1'																	, ; //X3_ARQUIVO
	'99'																	, ; //X3_ORDEM
	'E1_XBOLETO'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Flag Boleto'															, ; //X3_TITULO
	'Flag Boleto'															, ; //X3_TITSPA
	'Flag Boleto'															, ; //X3_TITENG
	'Flag Boleto'															, ; //X3_DESCRIC
	'Flag Boleto'															, ; //X3_DESCSPA
	'Flag Boleto'															, ; //X3_DESCENG
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
	'1=Pendente Impressão;2=Impresso;3=Enviado E-mail'						, ; //X3_CBOX
	'1=Pendente Impressão;2=Impresso;3=Enviado E-mail'						, ; //X3_CBOXSPA
	'1=Pendente Impressão;2=Impresso;3=Enviado E-mail'						, ; //X3_CBOXENG
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
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		} ) //X3_PYME


aAdd( aSX3, { ;
	'DA0'																	, ; //X3_ARQUIVO
	'ZZ'																	, ; //X3_ORDEM
	'DA0_XVLMIN'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	17																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Vl Min PV'																, ; //X3_TITULO
	'Vl Min PV'																, ; //X3_TITSPA
	'Vl Min PV'																, ; //X3_TITENG
	'Vl Min PV'																, ; //X3_DESCRIC
	'Vl Min PV'																, ; //X3_DESCSPA
	'Vl Min PV'																, ; //X3_DESCENG
	'@E 999,999,999.99'														, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	'S'																		, ; //X3_TRIGGER
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
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		} ) //X3_PYME
	

aAdd( aSX3, { ;
	'SA1'																	, ; //X3_ARQUIVO
	'99'																	, ; //X3_ORDEM
	'A1_XAVALOT'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Lot.C.Quebra'															, ; //X3_TITULO
	'Lot.C.Quebra'															, ; //X3_TITSPA
	'Lot.C.Quebra'															, ; //X3_TITENG
	'Aceita Lote com Quebra?'												, ; //X3_DESCRIC
	'Aceita Lote com Quebra?'												, ; //X3_DESCSPA
	'Aceita Lote com Quebra?'												, ; //X3_DESCENG
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
	'S=Aceita lote com quebra;N=Nao aceita lote com quebra'					, ; //X3_CBOX
	'S=Aceita lote com quebra;N=Nao aceita lote com quebra'					, ; //X3_CBOXSPA
	'S=Aceita lote com quebra;N=Nao aceita lote com quebra'					, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	'Inclui .Or. (cNivel >= 4 .And. Altera)'								, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		} ) //X3_PYME
	

aAdd( aSX3, { ;
	'SC8'																	, ; //X3_ARQUIVO
	'99'																	, ; //X3_ORDEM
	'C8_XWFID'	 															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	15																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Workflow Id'															, ; //X3_TITULO
	'Workflow Id'															, ; //X3_TITSPA
	'Workflow Id'															, ; //X3_TITENG
	'Workflow Id'															, ; //X3_DESCRIC
	'Workflow Id'															, ; //X3_DESCSPA
	'Workflow Id'															, ; //X3_DESCENG
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
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		} ) //X3_PYME

 
aAdd( aSX3, { ;
	'SC8'																	, ; //X3_ARQUIVO
	'99'																	, ; //X3_ORDEM
	'C8_XWFPROC' 															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	30																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'WF Proc'																, ; //X3_TITULO
	'WF Proc'																, ; //X3_TITSPA
	'WF Proc'																, ; //X3_TITENG
	'Workflow Processo'														, ; //X3_DESCRIC
	'Workflow Processo'														, ; //X3_DESCSPA
	'Workflow Processo'														, ; //X3_DESCENG
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
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		} ) //X3_PYME 


aAdd( aSX3, { ;
	'SC8'																	, ; //X3_ARQUIVO
	'99'																	, ; //X3_ORDEM
	'C8_XWFCO'	 															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Cod Workflow'															, ; //X3_TITULO
	'Cod Workflow'															, ; //X3_TITSPA
	'Cod Workflow'															, ; //X3_TITENG
	'Cod Workflow'															, ; //X3_DESCRIC
	'Cod Workflow'															, ; //X3_DESCSPA
	'Cod Workflow'															, ; //X3_DESCENG
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
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		} ) //X3_PYME 
	
	
aAdd( aSX3, { ;
	'SC8'																	, ; //X3_ARQUIVO
	'99'																	, ; //X3_ORDEM
	'C8_XWFMAIL' 															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	60																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'E-mail WF'																, ; //X3_TITULO
	'E-mail WF'																, ; //X3_TITSPA
	'E-mail WF'																, ; //X3_TITENG
	'E-mail de Aviso WF'													, ; //X3_DESCRIC
	'E-mail de Aviso WF'													, ; //X3_DESCSPA
	'E-mail de Aviso WF'													, ; //X3_DESCENG
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
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		} ) //X3_PYME



aAdd( aSX3, { ;
	'SA6'																	, ; //X3_ARQUIVO
	'99'																	, ; //X3_ORDEM
	'A6_XBOLETO'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Bco Boleto'															, ; //X3_TITULO
	'Bco Boleto'															, ; //X3_TITSPA
	'Bco Boleto'															, ; //X3_TITENG
	'Bco Boleto'															, ; //X3_DESCRIC
	'Bco Boleto'															, ; //X3_DESCSPA
	'Bco Boleto'															, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	'N'																		, ; //X3_RELACAO
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
	'S=Sim;N=Não'															, ; //X3_CBOX
	'S=Sim;N=Não'															, ; //X3_CBOXSPA
	'S=Sim;N=Não'															, ; //X3_CBOXENG
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
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		} ) //X3_PYME


aAdd( aSX3, { ;
	'SA6'																	, ; //X3_ARQUIVO
	'99'																	, ; //X3_ORDEM
	'A6_XFILBOL' 															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	60																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Fil. x Bol.'															, ; //X3_TITULO
	'Fil. x Bol.'															, ; //X3_TITSPA
	'Fil. x Bol.'															, ; //X3_TITENG
	'Filial x Boleto'														, ; //X3_DESCRIC
	'Filial x Boleto'														, ; //X3_DESCSPA
	'Filial x Boleto'														, ; //X3_DESCENG
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
	'U_xGetFil("M->A6_XFILBOL")'											, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
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
				AutoGrLog( "O tamanho do campo " + aSX3[nI][nPosCpo] + " NÃO atualizado e foi mantido em [" + ;
				AllTrim( Str( SXG->XG_SIZE ) ) + "]" + CRLF + ;
				" por pertencer ao grupo de campos [" + SXG->XG_GRUPO + "]" + CRLF )
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

		AutoGrLog( "Criado campo "+ aSX3[nI][nPosCpo] )
        
		// Forçar a Ordem dos campos
		// Recomendado para tabelas customizadas
		
		If aSX3[nI][nPosArq] $ "PNF|Z49" .And. SX3->(!Eof())
			RecLock( "SX3", .F. )
			SX3->X3_ORDEM := aSX3[nI][nPosOrd]
			MsUnLock()
		EndIf

	EndIf


	oProcess:IncRegua2( "Atualizando Campos de Tabelas (SX3)..." )

Next nI

AutoGrLog( CRLF + "Final da Atualização" + " SX3" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSIX
Função de processamento da gravação do SIX - Indices

@author TOTVS Protheus
@since  09/10/15
@obs    Gerado por EXPORDIC - V.5.0.0.0 EFS / Upd. V.4.20.15 EFS
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

AutoGrLog( "Ínicio da Atualização" + " SIX" + CRLF )

aEstrut := { "INDICE" , "ORDEM" , "CHAVE", "DESCRICAO", "DESCSPA"  , ;
             "DESCENG", "PROPRI", "F3"   , "NICKNAME" , "SHOWPESQ" }
  
/*
//
// Tabela PNF
//
aAdd( aSIX, { ;
	'PNF'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'PNF_FILIAL+PNF_CLIENT+PNF_LOJA+PNF_EMP+PNF_FILEMP'						, ; //CHAVE
	'Cod Cliente+Loja+Empresa+Filial Emp'									, ; //DESCRICAO
	'Cod Cliente+Loja+Empresa+Filial Emp'									, ; //DESCSPA
	'Cod Cliente+Loja+Empresa+Filial Emp'									, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	'PNF001'																, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'PNF'																	, ; //INDICE
	'2'																		, ; //ORDEM
	'PNF_FILIAL+PNF_EMP+PNF_FILEMP+PNF_CLIENT+PNF_LOJA'						, ; //CHAVE
	'Empresa+Filial Emp+Cod Cliente+Loja'									, ; //DESCRICAO
	'Empresa+Filial Emp+Cod Cliente+Loja'									, ; //DESCSPA
	'Empresa+Filial Emp+Cod Cliente+Loja'									, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	'PNF002'																, ; //NICKNAME
	'S'																		} ) //SHOWPESQ
  				   															} ) //SHOWPESQ
*/
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
		AutoGrLog( "Índice criado " + aSIX[nI][1] + "/" + aSIX[nI][2] + " - " + aSIX[nI][3] )
	Else
		lAlt := .T.
		aAdd( aArqUpd, aSIX[nI][1] )
		If !StrTran( Upper( AllTrim( CHAVE )       ), " ", "" ) == ;
		    StrTran( Upper( AllTrim( aSIX[nI][3] ) ), " ", "" )
			AutoGrLog( "Chave do índice alterado " + aSIX[nI][1] + "/" + aSIX[nI][2] + " - " + aSIX[nI][3] )
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

	oProcess:IncRegua2( "Atualizando índices..." )

Next nI

AutoGrLog( CRLF + "Final da Atualização" + " SIX" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSX7
Função de processamento da gravação do SX7 - Gatilhos

@author TOTVS Protheus
@since  09/10/15
@obs    Gerado por EXPORDIC - V.5.0.0.0 EFS / Upd. V.4.20.15 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSX7()
Local aEstrut   := {}
Local aAreaSX3  := SX3->( GetArea() )
Local aSX7      := {}
Local cAlias    := ""
Local nI        := 0
Local nJ        := 0
Local nTamSeek  := Len( SX7->X7_CAMPO )

AutoGrLog( "Ínicio da Atualização" + " SX7" + CRLF )

aEstrut := { "X7_CAMPO", "X7_SEQUENC", "X7_REGRA", "X7_CDOMIN", "X7_TIPO", "X7_SEEK", ;
             "X7_ALIAS", "X7_ORDEM"  , "X7_CHAVE", "X7_PROPRI", "X7_CONDIC" }

//
// Campo 'D3_COD'
//
aAdd( aSX7, { ;
	'D3_COD'																, ; //X7_CAMPO
	'004'																	, ; //X7_SEQUENC
	'U_Ou241Lin()'															, ; //X7_REGRA
	'D3_COD'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	'SD3'																	, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''				 														} ) //X7_CONDIC

//
// Campo 'D3_QUANT'
//
aAdd( aSX7, { ;
	'D3_QUANT'																, ; //X7_CAMPO
	'001'																	, ; //X7_SEQUENC
	'U_Ou241Lin()'															, ; //X7_REGRA
	'D3_QUANT'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''				 														} ) //X7_CONDIC


//
// Campo 'D3_COD'
//
aAdd( aSX7, { ;
	'C6_PRODUTO'															, ; //X7_CAMPO
	'009'																	, ; //X7_SEQUENC
	'U_Ou410Lin()'															, ; //X7_REGRA
	'C6_PRODUTO'															, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	'SC6'																	, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''				 														} ) //X7_CONDIC

//
// Atualizando dicionário
//
oProcess:SetRegua2( Len( aSX7 ) )

dbSelectArea( "SX3" )
dbSetOrder( 2 )

dbSelectArea( "SX7" )
dbSetOrder( 1 )

For nI := 1 To Len( aSX7 )

	If !SX7->( dbSeek( PadR( aSX7[nI][1], nTamSeek ) + aSX7[nI][2] ) )

		If !( aSX7[nI][1] $ cAlias )
			cAlias += aSX7[nI][1] + "/"
			AutoGrLog( "Foi incluído o gatilho " + aSX7[nI][1] + "/" + aSX7[nI][2] )
		EndIf

		RecLock( "SX7", .T. )
		For nJ := 1 To Len( aSX7[nI] )
			If FieldPos( aEstrut[nJ] ) > 0
				FieldPut( FieldPos( aEstrut[nJ] ), aSX7[nI][nJ] )
			EndIf
		Next nJ

		dbCommit()
		MsUnLock()

		If SX3->( dbSeek( SX7->X7_CAMPO ) )
			RecLock( "SX3", .F. )
			SX3->X3_TRIGGER := "S"
			MsUnLock()
		EndIf

	EndIf
	oProcess:IncRegua2( "Atualizando Arquivos (SX7)..." )

Next nI

RestArea( aAreaSX3 )

AutoGrLog( CRLF + "Final da Atualização" + " SX7" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuHlp
Função de processamento da gravação dos Helps de Campos

@author TOTVS Protheus
@since  09/10/15
@obs    Gerado por EXPORDIC - V.5.0.0.0 EFS / Upd. V.4.20.15 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuHlp()
Local aHlpPor   := {}
Local aHlpEng   := {}
Local aHlpSpa   := {}

AutoGrLog( "Ínicio da Atualização" + " " + "Helps de Campos" + CRLF )


oProcess:IncRegua2( "Atualizando Helps de Campos ..." )

/*
//
// Helps Tabela SC5
//
aHlpPor := {}
aAdd( aHlpPor, 'Entidade de destino de Solicitação de' )
aAdd( aHlpPor, 'compra gerada pelo faturamento' )
aAdd( aHlpPor, 'automático.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PC5_XENTSCD", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "C5_XENTSCD" )
*/  


AutoGrLog( CRLF + "Final da Atualização" + " " + "Helps de Campos" + CRLF + Replicate( "-", 128 ) + CRLF )

Return {}


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSX6
Função de processamento da gravação do SX6 - Parâmetros

@author TOTVS Protheus
@since  08/12/2015
@obs    Gerado por EXPORDIC - V.5.1.0.0 EFS / Upd. V.4.20.15 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSX6()
Local aEstrut   := {}
Local aSX6      := {}
Local cAlias    := ""
Local lContinua := .T.
Local lReclock  := .T.
Local nI        := 0
Local nJ        := 0
Local nTamFil   := Len( SX6->X6_FIL )
Local nTamVar   := Len( SX6->X6_VAR )
Local aTodasFil := FWAllFilial()

AutoGrLog( "Ínicio da Atualização" + " SX6" + CRLF )

aEstrut := { "X6_FIL"    , "X6_VAR"    , "X6_TIPO"   , "X6_DESCRIC", "X6_DSCSPA" , "X6_DSCENG" , "X6_DESC1"  , ;
             "X6_DSCSPA1", "X6_DSCENG1", "X6_DESC2"  , "X6_DSCSPA2", "X6_DSCENG2", "X6_CONTEUD", "X6_CONTSPA", ;
             "X6_CONTENG", "X6_PROPRI" , "X6_VALID"  , "X6_INIT"   , "X6_DEFPOR" , "X6_DEFSPA" , "X6_DEFENG" , ;
             "X6_PYME"   }

// Parametros Exclusivos - Serao criados em todas as filiais
For Nx := 1 To Len(aTodasFil) 
	// Boleto PDF - Exclusivos
	aAdd( aSX6, {aTodasFil[Nx],"FS_BOLPDF"	,'C','Utiliza impressão de boleto PDF'		,'','','','','','','','','N'	,'N'	,'N'	,'U','','','','','',''} )
	aAdd( aSX6, {aTodasFil[Nx],"FS_BOLCART"	,'C','Carteira para boleto [M460FIM]'		,'','','','','','','','',''		,''		,''		,'U','','','','','',''} )
	aAdd( aSX6, {aTodasFil[Nx],"FS_BOLBCO"	,'C','banco para boleto [M460FIM]'			,'','','','','','','','',''		,''		,''		,'U','','','','','',''} )
	aAdd( aSX6, {aTodasFil[Nx],"FS_BOLAGEN"	,'C','Agencia para boleto [M460FIM]'		,'','','','','','','','',''		,''		,''		,'U','','','','','',''} )
	aAdd( aSX6, {aTodasFil[Nx],"FS_BOLCTA"	,'C','Conta para boleto [M460FIM]'			,'','','','','','','','',''		,''		,''		,'U','','','','','',''} )
Next	

aAdd( aSX6, {"","FS_SACSA1"	,'C','Validações de cliente para SAC.'			,'','','','','','','','',''		,''		,''		,'U','','','','','',''} )
aAdd( aSX6, {"","FS_SACSC5"	,'C','Validações de cabeçalho de PV para SAC.'	,'','','','','','','','',''		,''		,''		,'U','','','','','',''} )
aAdd( aSX6, {"","FS_SACSC6"	,'C','Validações de item de PV para SAC.'		,'','','','','','','','',''		,''		,''		,'U','','','','','',''} )

aAdd( aSX6, {"","FS_WFURL01",'C','URL de Workflow primario.'		 		,'','','','','','','','','http://ourolux.totvs.com.br:10510/wf/'		,''		,''		,'U','','','','','',''} )
aAdd( aSX6, {"","FS_NHISTPC",'N','Numero de itens de historico no WF do PC.','','','','','','','','','6'		,'6'		,'6'		,'U','','','','','',''} )
aAdd( aSX6, {"","FS_LIBCLI"	,'C','Habilita nova liberação de PV por cliente.','','','','','','','','','S'		,'S'		,'S'		,'U','','','','','',''} )

// Parametros De Uso de WebServices
aAdd( aSX6, {"","FS_WFSC8"	,'C','Habilita Workflow de Cotação de compra.'   ,'','','','','','','','','N'		,'N'		,'N'		,'U','','','','','',''} )

// Parametros De Uso de WebServices
aAdd( aSX6, {"","WS_OWS001" ,'C','Token para Serviço OWS001.'		  		,'','','','','','','','',''		,''		,''		,'U','','','','','',''} )

// Parametros De Uso do Banco de conhecimento
aAdd( aSX6, {"","FS_MSDOCTM" ,'N','Limite de tamanho de arquivo em Bytes.'	,'','','','','','','','','5000000'		,''		,''		,'U','','','','','',''} )
aAdd( aSX6, {"","FS_MSDOCEX" ,'C','Extensoes permitidas no Bco de Conhecimento.'	,'','','','','','','','','pdf;jpg;png;xml;xls;doc;ppt'		,''		,''		,'U','','','','','',''} )


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
		AutoGrLog( "Foi incluído o parâmetro " + aSX6[nI][1] +" "+ aSX6[nI][2] + " Conteúdo [" + AllTrim( aSX6[nI][13] ) + "]" )
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

	oProcess:IncRegua2( "Atualizando Arquivos (SX6)..." )
                                       	
Next nI

AutoGrLog( CRLF + "Final da Atualização" + " SX6" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL 


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

oDlg:cToolTip := "Tela para Múltiplas Seleções de Empresas/Filiais"

oDlg:cTitle   := "Selecione a(s) Empresa(s) para Atualização"

@ 10, 10 Listbox  oLbx Var  cVar Fields Header " ", " ", "Empresa" Size 178, 095 Of oDlg Pixel
oLbx:SetArray(  aVetor )
oLbx:bLine := {|| {IIf( aVetor[oLbx:nAt, 1], oOk, oNo ), ;
aVetor[oLbx:nAt, 2], ;
aVetor[oLbx:nAt, 4]}}           
oLbx:BlDblClick := { || aVetor[oLbx:nAt, 1] := !aVetor[oLbx:nAt, 1], VerTodos( aVetor, @lChk, oChkMar ), oChkMar:Refresh(), oLbx:Refresh()}
oLbx:cToolTip   :=  oDlg:cTitle
oLbx:lHScroll   := .F. // NoScroll

@ 112, 10 CheckBox oChkMar Var  lChk Prompt "Todos" Message "Marca / Desmarca"+ CRLF + "Todos" Size 40, 007 Pixel Of oDlg;
on Click MarcaTodos( lChk, @aVetor, oLbx )

// Marca/Desmarca por mascara
@ 113, 51 Say   oSay Prompt "Empresa" Size  40, 08 Of oDlg Pixel
@ 112, 80 MSGet oMascEmp Var  cMascEmp Size  05, 05 Pixel Picture "@!"  Valid (  cMascEmp := StrTran( cMascEmp, " ", "?" ), oMascEmp:Refresh(), .T. ) ;
Message "Máscara Empresa ( ?? )"  Of oDlg
oSay:cToolTip := oMascEmp:cToolTip

@ 128, 10 Button oButInv    Prompt "&Inverter"  Size 32, 12 Pixel Action ( InvSelecao( @aVetor, oLbx, @lChk, oChkMar ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
Message "Inverter Seleção" Of oDlg
oButInv:SetCss( CSSBOTAO )
@ 128, 50 Button oButMarc   Prompt "&Marcar"    Size 32, 12 Pixel Action ( MarcaMas( oLbx, aVetor, cMascEmp, .T. ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
Message "Marcar usando" + CRLF + "máscara ( ?? )"    Of oDlg
oButMarc:SetCss( CSSBOTAO )
@ 128, 80 Button oButDMar   Prompt "&Desmarcar" Size 32, 12 Pixel Action ( MarcaMas( oLbx, aVetor, cMascEmp, .F. ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
Message "Desmarcar usando" + CRLF + "máscara ( ?? )" Of oDlg
oButDMar:SetCss( CSSBOTAO )
@ 112, 157  Button oButOk   Prompt "Processar"  Size 32, 12 Pixel Action (  RetSelecao( @aRet, aVetor ), oDlg:End()  ) ;
Message "Confirma a seleção e efetua" + CRLF + "o processamento" Of oDlg
oButOk:SetCss( CSSBOTAO )
@ 128, 157  Button oButCanc Prompt "Cancelar"   Size 32, 12 Pixel Action ( IIf( lTeveMarc, aRet :=  aMarcadas, .T. ), oDlg:End() ) ;
Message "Cancela o processamento" + CRLF + "e abandona a aplicação" Of oDlg
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
@since  09/10/15
@obs    Gerado por EXPORDIC - V.5.0.0.0 EFS / Upd. V.4.20.15 EFS
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
	MsgStop( "Não foi possível a abertura da tabela " + ;
	IIf( lShared, "de empresas (SM0).", "de empresas (SM0) de forma exclusiva." ), "ATENÇÃO" )
EndIf

Return lOpen


//--------------------------------------------------------------------
/*/{Protheus.doc} LeLog
Função de leitura do LOG gerado com limitacao de string

@author TOTVS Protheus
@since  09/10/15
@obs    Gerado por EXPORDIC - V.5.0.0.0 EFS / Upd. V.4.20.15 EFS
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




Static Function LoadSX5()
	Local aEstrut := {}
	Local aSx5    := {}
	Local nTamFil := Len( SX5->X5_FILIAL )	

	aEstrut := { "X5_FILIAL", "X5_TABELA", "X5_CHAVE", "X5_DESCRI", "X5_DESCSPA", "X5_DESCENG" }
	
	AADD( aSx5, {"", "T3", "SAC", "SAC", "SAC", "SAC"} )
	AADD( aSx5, {"", "DJ", "09 ", "SAC", "SAC", "SAC"} )

	oProcess:SetRegua2( Len( aSX5 ) )
	
	DbSelectArea( "SX5" )
	DbSetOrder( 1 )
	
	For nI := 1 To Len( aSX5 )
		lContinua := .F.
		lReclock  := .F.
	
		If !SX5->( dbSeek( PadR( aSX5[nI][01], nTamFil ) + aSX5[nI][02] + aSX5[nI][03]   ) )
			lContinua := .T.
			lReclock  := .T.
			AutoGrLog( "Foi incluído o registro: Tabela:  " + aSX5[nI][02] +" Chave: " + AllTrim( aSX5[nI][03] ) + "]" )
		EndIf
	
		If lContinua
	
			RecLock( "SX5", lReclock )
			For nJ := 1 To Len( aSX5[nI] )
				If FieldPos( aEstrut[nJ] ) > 0
					FieldPut( FieldPos( aEstrut[nJ] ), aSX5[nI][nJ] )
				EndIf
			Next nJ
			dbCommit()
			MsUnLock()
		EndIf
	
		oProcess:IncRegua2( "Atualizando Arquivos (SX5)..." )
	                                       	
	Next nI
	
	AutoGrLog( CRLF + "Final da Atualização" + " SX5" + CRLF + Replicate( "-", 128 ) + CRLF )
	
Return()
                       


Static Function LoadTab()
	
	// Cliente SAC - Cadastro de Midia
	DbSelectarea("SUH")
	DbSetorder(1)
	If !DbSeek(xFilial("SUH")+"000015")
		RecLock("SUH",.T.)
		SUH->UH_FILIAL 	:= xFilial("SUH")         
		SUH->UH_MIDIA 	:= "000015"
		SUH->UH_DESC 	:= "CLIENTE SAC"
		SUH->UH_VALIDO 	:= "1"
		MsUnlock()	
	EndIf

Return()



Static Function SetFld()
	Local aEstrut   := {} 
	Local aCmb      := {}
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
	Local aUpdSX3 	:= {}
	
	AutoGrLog( "Ínicio das Alterações" + " SX3" + CRLF )

	// SA1                                                            
	AADD( aUpdSX3, {"A1_CBO"	, "X3_USADO", X3_USADO_NAOUSADO } )	                            

	AADD( aUpdSX3, {"A1_EMAIL"	, "X3_WHEN", "Inclui .Or. (cNivel >= 4 .And. Altera)" } )
	AADD( aUpdSX3, {"A1_TEL"	, "X3_WHEN", "Inclui .Or. (cNivel >= 4 .And. Altera)" } )
	AADD( aUpdSX3, {"A1_XAVALOT", "X3_WHEN", "Inclui .Or. (cNivel >= 4 .And. Altera)" } )

	// SC6
	AADD( aUpdSX3, {"C6_LOCALIZ"	, "X3_WHEN", 'U_xSac()'														} )	
	AADD( aUpdSX3, {"C6_LOTECTL"	, "X3_WHEN", 'IIF(Altera.And.RetCodUsr( )=="000750",.F.,.T.).And.U_xSac()' 	} )	

	// SC5
	AADD( aUpdSX3, {"C5_TESINT"	, "X3_CBOX", "01=Vendas;02=Devolucao;05=Transferencia;06=Bonificacao;09=SAC" } )	
	AADD( aUpdSX3, {"C5_TESINT"	, "X3_ORDEM", "25" } )	
 
	AADD( aUpdSX3, {"C5_XLOCEMB"	, "X3_WHEN", 'IIF(Altera.And.RetCodUsr( )=="000750",.F.,.T.).And.!U_xSac()' } )	
	AADD( aUpdSX3, {"C5_XUFEMB"		, "X3_WHEN", 'IIF(Altera.And.RetCodUsr( )=="000750",.F.,.T.).And.!U_xSac()' } )	
	AADD( aUpdSX3, {"C5_XPEDCOM"	, "X3_WHEN", 'IIF(Altera.And.RetCodUsr( )=="000750",.F.,.T.).And.!U_xSac()' } )	
	AADD( aUpdSX3, {"C5_SOLOPC"		, "X3_WHEN", 'IIF(Altera.And.RetCodUsr( )=="000750",.F.,.T.).And.!U_xSac()' } )	

	AADD( aUpdSX3, {"C5_CEPENT"	, "X3_USADO", X3_USADO_NAOUSADO } )
	AADD( aUpdSX3, {"C5_LOJAENT", "X3_USADO", X3_USADO_NAOUSADO } )
	AADD( aUpdSX3, {"C5_CLIENT"	, "X3_USADO", X3_USADO_NAOUSADO } )
	AADD( aUpdSX3, {"C5_FRETAUT", "X3_USADO", X3_USADO_NAOUSADO } )
	AADD( aUpdSX3, {"C5_INCISS ", "X3_USADO", X3_USADO_NAOUSADO } )
	AADD( aUpdSX3, {"C5_ESTPRES", "X3_USADO", X3_USADO_NAOUSADO } )
	AADD( aUpdSX3, {"C5_ACRSFIN", "X3_USADO", X3_USADO_NAOUSADO } )
	AADD( aUpdSX3, {"C5_VALBALL", "X3_USADO", X3_USADO_NAOUSADO } )
	AADD( aUpdSX3, {"C5_PDESCAB", "X3_USADO", X3_USADO_NAOUSADO } )
	AADD( aUpdSX3, {"C5_FORNISS", "X3_USADO", X3_USADO_NAOUSADO } )
	AADD( aUpdSX3, {"C5_RECISS"	, "X3_USADO", X3_USADO_NAOUSADO } )
	AADD( aUpdSX3, {"C5_RECFAUT", "X3_USADO", X3_USADO_NAOUSADO } )
	AADD( aUpdSX3, {"C5_KM"		, "X3_USADO", X3_USADO_NAOUSADO } )
	AADD( aUpdSX3, {"C5_VLR_FRT", "X3_USADO", X3_USADO_NAOUSADO } )
	AADD( aUpdSX3, {"C5_DESCMUN", "X3_USADO", X3_USADO_NAOUSADO } )
	AADD( aUpdSX3, {"C5_NFSUBST", "X3_USADO", X3_USADO_NAOUSADO } )
	AADD( aUpdSX3, {"C5_SERSUBS", "X3_USADO", X3_USADO_NAOUSADO } )
	AADD( aUpdSX3, {"C5_MUNPRES", "X3_USADO", X3_USADO_NAOUSADO } )
	AADD( aUpdSX3, {"C5_VEICULO", "X3_USADO", X3_USADO_NAOUSADO } )
	AADD( aUpdSX3, {"C5_FECENT"	, "X3_USADO", X3_USADO_NAOUSADO } )
	AADD( aUpdSX3, {"C5_OBRA"	, "X3_USADO", X3_USADO_NAOUSADO } )
	AADD( aUpdSX3, {"C5_NTEMPEN", "X3_USADO", X3_USADO_NAOUSADO } )
	AADD( aUpdSX3, {"C5_TIPOBRA", "X3_USADO", X3_USADO_NAOUSADO } )
	AADD( aUpdSX3, {"C5_DTESERV", "X3_USADO", X3_USADO_NAOUSADO } )

	AADD( aUpdSX3, {"C5_CLIINT"	, "X3_USADO", X3_USADO_NAOUSADO } )
	AADD( aUpdSX3, {"C5_CGCINT"	, "X3_USADO", X3_USADO_NAOUSADO } )
	AADD( aUpdSX3, {"C5_IMINT"	, "X3_USADO", X3_USADO_NAOUSADO } )
	AADD( aUpdSX3, {"C5_DESPACH", "X3_USADO", X3_USADO_NAOUSADO } )


	
	AADD( aUpdSX3, {"C5_CEPENT"	, "X3_VISUAL", "V" } )
	AADD( aUpdSX3, {"C5_LOJAENT", "X3_VISUAL", "V" } )
	AADD( aUpdSX3, {"C5_CLIENT"	, "X3_VISUAL", "V" } )
	AADD( aUpdSX3, {"C5_FRETAUT", "X3_VISUAL", "V" } )
	AADD( aUpdSX3, {"C5_INCISS ", "X3_VISUAL", "V" } )
	AADD( aUpdSX3, {"C5_ESTPRES", "X3_VISUAL", "V" } )
	AADD( aUpdSX3, {"C5_ACRSFIN", "X3_VISUAL", "V" } )
	AADD( aUpdSX3, {"C5_VALBALL", "X3_VISUAL", "V" } )
	AADD( aUpdSX3, {"C5_PDESCAB", "X3_VISUAL", "V" } )
	AADD( aUpdSX3, {"C5_FORNISS", "X3_VISUAL", "V" } )
	AADD( aUpdSX3, {"C5_RECISS"	, "X3_VISUAL", "V" } )
	AADD( aUpdSX3, {"C5_RECFAUT", "X3_VISUAL", "V" } )
	AADD( aUpdSX3, {"C5_KM"		, "X3_VISUAL", "V" } )
	AADD( aUpdSX3, {"C5_VLR_FRT", "X3_VISUAL", "V" } )
	AADD( aUpdSX3, {"C5_DESCMUN", "X3_VISUAL", "V" } )
	AADD( aUpdSX3, {"C5_NFSUBST", "X3_VISUAL", "V" } )
	AADD( aUpdSX3, {"C5_SERSUBS", "X3_VISUAL", "V" } )
	AADD( aUpdSX3, {"C5_MUNPRES", "X3_VISUAL", "V" } )
	AADD( aUpdSX3, {"C5_VEICULO", "X3_VISUAL", "V" } )
	AADD( aUpdSX3, {"C5_FECENT"	, "X3_VISUAL", "V" } )
	AADD( aUpdSX3, {"C5_OBRA"	, "X3_VISUAL", "V" } )
	AADD( aUpdSX3, {"C5_NTEMPEN", "X3_VISUAL", "V" } )
	AADD( aUpdSX3, {"C5_TIPOBRA", "X3_VISUAL", "V" } )
	AADD( aUpdSX3, {"C5_DTESERV", "X3_VISUAL", "V" } )
	AADD( aUpdSX3, {"C5_TRANSP"	, "X3_VISUAL", "V" } )
	AADD( aUpdSX3, {"C5_VEND1"	, "X3_VISUAL", "V" } )
	AADD( aUpdSX3, {"C5_BANCO"	, "X3_VISUAL", "V" } )
	AADD( aUpdSX3, {"C5_MENPAD"	, "X3_VISUAL", "V" } )
	AADD( aUpdSX3, {"C5_TPCARGA", "X3_VISUAL", "V" } )
	AADD( aUpdSX3, {"C5_MOEDTIT", "X3_VISUAL", "V" } )
	AADD( aUpdSX3, {"C5_XPVINT"	, "X3_VISUAL", "V" } )

	AADD( aUpdSX3, {"C5_CEPENT"	, "X3_ORDEM", "ZZ" } )
	AADD( aUpdSX3, {"C5_LOJAENT", "X3_ORDEM", "ZZ" } )
	AADD( aUpdSX3, {"C5_CLIENT"	, "X3_ORDEM", "ZZ" } )
	AADD( aUpdSX3, {"C5_FRETAUT", "X3_ORDEM", "ZZ" } )
	AADD( aUpdSX3, {"C5_INCISS ", "X3_ORDEM", "ZZ" } )
	AADD( aUpdSX3, {"C5_ESTPRES", "X3_ORDEM", "ZZ" } )
	AADD( aUpdSX3, {"C5_ACRSFIN", "X3_ORDEM", "ZZ" } )
	AADD( aUpdSX3, {"C5_VALBALL", "X3_ORDEM", "ZZ" } )
	AADD( aUpdSX3, {"C5_PDESCAB", "X3_ORDEM", "ZZ" } )
	AADD( aUpdSX3, {"C5_FORNISS", "X3_ORDEM", "ZZ" } )
	AADD( aUpdSX3, {"C5_RECISS"	, "X3_ORDEM", "ZZ" } )
	AADD( aUpdSX3, {"C5_RECFAUT", "X3_ORDEM", "ZZ" } )
	AADD( aUpdSX3, {"C5_KM"		, "X3_ORDEM", "ZZ" } )
	AADD( aUpdSX3, {"C5_VLR_FRT", "X3_ORDEM", "ZZ" } )
	AADD( aUpdSX3, {"C5_DESCMUN", "X3_ORDEM", "ZZ" } )
	AADD( aUpdSX3, {"C5_NFSUBST", "X3_ORDEM", "ZZ" } )
	AADD( aUpdSX3, {"C5_SERSUBS", "X3_ORDEM", "ZZ" } )
	AADD( aUpdSX3, {"C5_MUNPRES", "X3_ORDEM", "ZZ" } )
	AADD( aUpdSX3, {"C5_VEICULO", "X3_ORDEM", "ZZ" } )
	AADD( aUpdSX3, {"C5_FECENT"	, "X3_ORDEM", "ZZ" } )
	AADD( aUpdSX3, {"C5_OBRA"	, "X3_ORDEM", "ZZ" } )
	AADD( aUpdSX3, {"C5_NTEMPEN", "X3_ORDEM", "ZZ" } )
	AADD( aUpdSX3, {"C5_TIPOBRA", "X3_ORDEM", "ZZ" } )
	AADD( aUpdSX3, {"C5_DTESERV", "X3_ORDEM", "ZZ" } )
	AADD( aUpdSX3, {"C5_TRANSP"	, "X3_ORDEM", "ZZ" } )
	AADD( aUpdSX3, {"C5_VEND1"	, "X3_ORDEM", "ZZ" } )
	AADD( aUpdSX3, {"C5_BANCO"	, "X3_ORDEM", "ZZ" } )
	AADD( aUpdSX3, {"C5_MENPAD"	, "X3_ORDEM", "ZZ" } )
	AADD( aUpdSX3, {"C5_TPCARGA", "X3_ORDEM", "ZZ" } )
	AADD( aUpdSX3, {"C5_MOEDTIT", "X3_ORDEM", "ZZ" } )
	AADD( aUpdSX3, {"C5_XPVINT"	, "X3_ORDEM", "ZZ" } )

	oProcess:SetRegua2( Len( aUpdSX3 ) )
	
	nPosCpo := 1 
	nPosCpX3:= 2
	nPosInfo:= 3
	
	dbSelectArea( "SX3" )
	dbSetOrder( 2 )
	cAliasAtu := ""
	
	For nI := 1 To Len( aUpdSX3 )
	
		If SX3->( dbSeek( PadR( aUpdSX3[nI][nPosCpo], nTamSeek ) ) )
	
			RecLock( "SX3", .F. )

			SX3->( FieldPut( FieldPos( aUpdSX3[nI][nPosCpX3] ), aUpdSX3[nI][nPosInfo] ) )
			SX3->(aUpdSX3[nI][nPosCpX3])  := aUpdSX3[nI][nPosInfo]
			dbCommit()
			MsUnLock()
	
			AutoGrLog( "Campo Alterado "+ aUpdSX3[nI][nPosCpo] +" - "+aUpdSX3[nI][nPosCpX3])
        
		EndIf
	
		oProcess:IncRegua2( "Atualizando estrutura de Campos de Tabelas (SX3)..." )
	
	Next nI
	
	AutoGrLog( CRLF + "Final da Atualização" + " SX3" + CRLF + Replicate( "-", 128 ) + CRLF )      
	
Return                




/*
{Protheus.doc} UPDEXT()
<Function Description>
@Author     <Author>
@Since      01/03/17
@Version    P12.7
@Project    <project Number>
@Return
*/
Static Function xUPDEXT()
	Local Nx			:= 0
	Local Ny			:= 0
	Local aRC2			:= {}
	Local aRC3			:= {}
	Local aRCA			:= {}
	Local aRCB			:= {}
	Local lSharedRC2	:= Empty(xFilial('RC2'))
	Local lSharedRCA	:= Empty(xFilial('RCA'))
	Local lSharedRCB	:= Empty(xFilial('RCB'))
	Local aStruRC2 		:= {}
	Local aStruRC3 		:= {}
	Local nFil    		:= 0
	Local nTamFil   	:= Len(cFilAnt)
	Local nTamFilRC2 	:= Len(AllTrim(xFilial('RC2')))
	Local nTamFilRCA 	:= Len(AllTrim(xFilial('RCA')))
	Local nTamFilRCB 	:= Len(AllTrim(xFilial('RCA')))
	Local aTodasFil  	:= FWAllFilial(cEmpAnt,,,.F.)
	Local aFilRC2    	:= {}
	Local cFilRC2    	:= cFilAnt 
	Local aFilRCA    	:= {}
	Local cFilRCA    	:= cFilAnt 
	Local aFilRCB    	:= {}
	Local cFilRCB    	:= cFilAnt 

	Private lDelAnt		:= .F.



	If lSharedRCB 
		cFilRCB := xFilial('RCB')
		AAdd(aFilRCB,cFilRCB)
	Else
		For nFil := 1 To Len(aTodasFil)
			cFilRCB := PadR(Left(aTodasFil[nFil],nTamFilRCB),nTamFil)
			If ( AScan(aFilRCB,{|x| x == cFilRCB }) == 0 )
				AAdd(aFilRCB,cFilRCB)
			EndIf
		Next
	EndIf

	aStruRCB := {'RCB_CODIGO','RCB_DESC','RCB_ORDEM','RCB_CAMPOS','RCB_DESCPO','RCB_TIPO','RCB_TAMAN','RCB_DECIMA','RCB_PICTUR','RCB_VALID','RCB_PADRAO','RCB_VERSAO','RCB_PESQ'}

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³  RCB - U001                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AADD(aRCB,{'U001','ALCADAS FINANCEIRO - VENCTO   ','01','USER      ','USUARIO                  ','C',6,0,'@!                                           ','                                                                                                                        ','US2   ','   ','1'})
	AADD(aRCB,{'U001','ALCADAS FINANCEIRO - VENCTO   ','02','NOMUSR    ','NOME                     ','C',20,0,'@!                                           ','                                                                                                                        ','      ','   ','2'})
	AADD(aRCB,{'U001','ALCADAS FINANCEIRO - VENCTO   ','03','MAXDIAS   ','MAXIMO DE DIAS P/ VENCTO ','C',3,0,'@!                                           ','                                                                                                                        ','      ','   ','2'})
	AADD(aRCB,{'U001','ALCADAS FINANCEIRO - VENCTO   ','04','ALTX      ','ALTERA MAIS DE UMA VEZ?  ','C',1,0,'@!                                           ','                                                                                                                        ','      ','   ','2'})

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³  RCB - U002                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AADD(aRCB,{'U002','LIBERAÇÃO DE CREDITO          ','01','USER      ','USUARIO                  ','C',6,0,'@!                                           ','                                                                                                                        ','US2   ','   ','1'})
	AADD(aRCB,{'U002','LIBERAÇÃO DE CREDITO          ','02','NOMUSER   ','NOME USUARIO             ','C',20,0,'@!                                           ','                                                                                                                        ','      ','   ','2'})
	AADD(aRCB,{'U002','LIBERAÇÃO DE CREDITO          ','03','VALMAX    ','VALOR MAXIMO             ','N',17,2,'@E 999,999,999,999.99                        ','POSITIVO()                                                                                                              ','      ','   ','2'})

	lFormulas	:= !Empty(aRC2)
	lMnemonico	:= !Empty(aRCA)
	lTabelas	:= !Empty(aRCB)

	If lFormulas	
		// Processando Formulas	
		cKeyRC2 := ''
		cKeyRC3 := ''
		DbSelectArea('RC2')
		DbSetOrder(1)
		DbSelectArea('RC3')
		DbSetOrder(2)
		For nFil := 1 To Len(aFilRC2)
			// Grava os Campos passados RC2
			For Ny := 1 To Len( aRC2 )
				cKeyRC2 := aFilRC2[nFil]+aRC2[Ny][01]+aRC2[Ny][02]
				If lDelAnt
					ProcDel( 'RC2', cKeyRC2 )
				EndIf
				If 	!RC2->(DbSeek(cKeyRC2))
					RecLock('RC2', .T.)
					RC2->RC2_FILIAL := aFilRC2[nFil]
					For Nx := 1 To Len( aStruRC2 )
						nField := RC2->(FieldPos(aStruRC2[Nx]))
						RC2->(FieldPut( nField, aRC2[Ny][Nx]))
					Next Nx
					RC2->(MsUnlock())
				EndIf
			Next Ny
			// Grava os Campos passados RC3
			For Ny := 1 To Len( aRC3 )
				cKeyRC3 := aFilRC2[nFil]+aRC3[Ny][01]+aRC3[Ny][02]+aRC3[Ny][04]
				If 	!RC3->(DbSeek(cKeyRC3))
					RecLock('RC3', .T.)
					RC3->RC3_FILIAL := aFilRC2[nFil]
					For Nx := 1 To Len( aStruRC3 )
						nField := RC3->(FieldPos(aStruRC3[Nx]))
						RC3->(FieldPut( nField, aRC3[Ny][Nx] ))
					Next Nx
					RC3->(MsUnlock())
				EndIf
			Next Ny
		Next nFil
	EndIf

	If lMnemonico
		// Processando Mnemonicos	
		cKeyRCA := ''
		DbSelectArea('RCA')
		DbSelectArea(1)
		For nFil := 1 To Len(aFilRCA)
			// Grava os Campos passados RCA
			For Ny := 1 To Len( aRCA )
				cKeyRCA := aFilRCA[nFil]+aRCA[Ny][01]
				If lDelAnt
					ProcDel( 'RCA', cKeyRCA )
				EndIf
				If 	!RCA->(DbSeek(cKeyRCA))
					RecLock('RCA', .T.)
					RCA->RCA_FILIAL := aFilRCA[nFil]
					For Nx := 1 To Len( aStruRCA )
						nField := RCA->(FieldPos(aStruRCA[Nx]))
						RCA->(FieldPut( nField, aRCA[Ny][Nx] ))
					Next Nx
					RCA->(MsUnlock())
				EndIf
			Next Ny
		Next nFil
	EndIf

	If lTabelas
		// Processando Tabelas	
		cKeyRCB := ''
		DbSelectArea('RCB')
		DbSelectArea(1)
		For nFil := 1 To Len(aFilRCB)
			// Grava os Campos passados RCB
			cKeyRCB := aFilRCB[nFil]+aRCB[01][01]
			If !RCB->(DbSeek(cKeyRCB))
				For Ny := 1 To Len( aRCB )
					RecLock('RCB', .T.)
					RCB->RCB_FILIAL := aFilRCB[nFil]
					For Nx := 1 To Len( aStruRCB )
						nField := RCB->(FieldPos(aStruRCB[Nx]))
						RCB->(FieldPut( nField, aRCB[Ny][Nx] ))
					Next Nx
					RCB->(MsUnlock())
				Next Ny
			EndIf
		Next nFil
	EndIf

Return



/*
{Protheus.doc} ProcDel
<Function Description>
@Author     <Author>
@Since      01/03/17
@Version    P12.7
@Project    <project Number>
@Return
*/
Static Function ProcDel( cTab, cKey )
	Local nRet		:= .F.
	Local cQry		:= ""

	If cTab $ "RC2/RC3"
		DbSelectArea("RC2")
		RC2->(DbSetOrder(1))
		If RC2->(DbSeek( ckey ))
			RecLock("RC2",.F.)
			DbDelete()
			MsUnlock()	
		EndIf
		DbSelectArea("RC3")
		RC3->(DbSetOrder(1))
		If RC3->(DbSeek( ckey ))
			While RC3->(!Eof()) .And. ( RC3->RC3_FILIAL + RC3->RC3_ORIGEM + RC3->RC3_CODIGO == cFil + ckey )
				RecLock("RC3",.F.)
				DbDelete()
				MsUnlock()
				RC3->(DbSkip())
			EndDo
		EndIf
	ElseIf cTab == "RCA"

	ElseIf cTab == "RCB"

	EndIf

Return( lRet )
