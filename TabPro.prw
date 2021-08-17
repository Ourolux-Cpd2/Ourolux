
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TABPRO   ºAutor  ³ELETROMEGA          º Data ³  01/31/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ MOSTRAR A LISTA DE PROMOÇOES PARA TODOS                    º±±
±±º          ³ COM SLADOS NO ESTOQUE                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


#INCLUDE "rwmake.ch"

User Function TabPro()
	
	dbSelectArea( 'DA1' )

	_cFiltro := dbFilter()

	If Empty( _cFiltro )

   		_cCod  := RetCodUsr()

   		SA3->( dbSetOrder( 7 ) )

   		If ! ( SA3->( dbSeek( xFilial( 'SA3' ) + _cCod, .F. ) ) )

      		_cCod := '000000'

   		Else

      		_cCod := SA3->A3_COD
                                                                                                             
   		End
        
        SA3->( dbSetOrder( 1 ) )
   		SA1->( dbSetOrder( 6 ) )
   		SA1->( dbSeek( xFilial( 'SA1' ) + _cCod, .T. ) )
   		SA1->( dbSetOrder( 1 ) )
   		cQry := " DA1_CODTAB == 'PRO' "

   		dbSelectArea( 'DA1' )
   		Set filter to &cQry

	End

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Private cString
	Private cCadastro := "Consulta Produto, Pre‡os, Saldos"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ aRotina padrao. Utilizando a declaracao a seguir, a execucao da     ³
	//³ MBROWSE sera identica a da AXCADASTRO:                              ³
	//³                                                                     ³
	//³ cDelFunc  := ".F."                                                  ³
	//³ aRotina   := { { "Pesquisar"    ,"AxPesqui" , 0, 1},;               ³
	//³                { "Visualizar"   ,"AxVisual" , 0, 2},;               ³
	//³                { "Saldos"       ,"Saldo"    , 0, 2} }               ³
	//³                                                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta um aRotina proprio                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    
	Private aRotina := 	{ {"Pesquisar","AxPesqui",0,1} ,;
						{"Saldos" ,"U_SaldoEst",0,5} } 
    
	Private cDelFunc := .F.  // Validacao para a exclusao. Pode-se utilizar ExecBlock

	Private cString := "DA1"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa a funcao MBROWSE. Sintaxe:                                  ³
	//³                                                                     ³
	//³ mBrowse(<nLin1,nCol1,nLin2,nCol2,Alias,aCampos,cCampo)              ³
	//³ Onde: nLin1,...nCol2 - Coordenadas dos cantos aonde o browse sera   ³
	//³                        exibido. Para seguir o padrao da AXCADASTRO  ³
	//³                        use sempre 6,1,22,75 (o que nao impede de    ³
	//³                        criar o browse no lugar desejado da tela).   ³
	//³                        Obs.: Na versao Windows, o browse sera exibi-³
	//³                        do sempre na janela ativa. Caso nenhuma este-³
	//³                        ja ativa no momento, o browse sera exibido na³
	//³                        janela do proprio SIGAADV.                   ³
	//³ Alias                - Alias do arquivo a ser "Browseado".          ³
	//³ aCampos              - Array multidimensional com os campos a serem ³
	//³                        exibidos no browse. Se nao informado, os cam-³
	//³                        pos serao obtidos do dicionario de dados.    ³
	//³                        E util para o uso com arquivos de trabalho.  ³
	//³                        Segue o padrao:                              ³
	//³                        aCampos := { {<CAMPO>,<DESCRICAO>},;         ³
	//³                                     {<CAMPO>,<DESCRICAO>},;         ³
	//³                                     . . .                           ³
	//³                                     {<CAMPO>,<DESCRICAO>} }         ³
	//³                        Como por exemplo:                            ³
	//³                        aCampos := { {"TRB_DATA","Data  "},;         ³
	//³                                     {"TRB_COD" ,"Codigo"} }         ³
	//³ cCampo               - Nome de um campo (entre aspas) que sera usado³
	//³                        como "flag". Se o campo estiver vazio, o re- ³
	//³                        gistro ficara de uma cor no browse, senao fi-³
	//³                        cara de outra cor.                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	mBrowse( 6,1,22,75,cString)
Return( NIL )
