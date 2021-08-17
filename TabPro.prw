
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �TABPRO   �Autor  �ELETROMEGA          � Data �  01/31/06   ���
�������������������������������������������������������������������������͹��
���Desc.     � MOSTRAR A LISTA DE PROMO�OES PARA TODOS                    ���
���          � COM SLADOS NO ESTOQUE                                      ���
�������������������������������������������������������������������������͹��
���Uso       � AP6                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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

	//���������������������������������������������������������������������Ŀ
	//� Declaracao de Variaveis                                             �
	//�����������������������������������������������������������������������

	Private cString
	Private cCadastro := "Consulta Produto, Pre�os, Saldos"

	//���������������������������������������������������������������������Ŀ
	//� aRotina padrao. Utilizando a declaracao a seguir, a execucao da     �
	//� MBROWSE sera identica a da AXCADASTRO:                              �
	//�                                                                     �
	//� cDelFunc  := ".F."                                                  �
	//� aRotina   := { { "Pesquisar"    ,"AxPesqui" , 0, 1},;               �
	//�                { "Visualizar"   ,"AxVisual" , 0, 2},;               �
	//�                { "Saldos"       ,"Saldo"    , 0, 2} }               �
	//�                                                                     �
	//�����������������������������������������������������������������������


	//���������������������������������������������������������������������Ŀ
	//� Monta um aRotina proprio                                            �
	//�����������������������������������������������������������������������
    
	Private aRotina := 	{ {"Pesquisar","AxPesqui",0,1} ,;
						{"Saldos" ,"U_SaldoEst",0,5} } 
    
	Private cDelFunc := .F.  // Validacao para a exclusao. Pode-se utilizar ExecBlock

	Private cString := "DA1"

	//���������������������������������������������������������������������Ŀ
	//� Executa a funcao MBROWSE. Sintaxe:                                  �
	//�                                                                     �
	//� mBrowse(<nLin1,nCol1,nLin2,nCol2,Alias,aCampos,cCampo)              �
	//� Onde: nLin1,...nCol2 - Coordenadas dos cantos aonde o browse sera   �
	//�                        exibido. Para seguir o padrao da AXCADASTRO  �
	//�                        use sempre 6,1,22,75 (o que nao impede de    �
	//�                        criar o browse no lugar desejado da tela).   �
	//�                        Obs.: Na versao Windows, o browse sera exibi-�
	//�                        do sempre na janela ativa. Caso nenhuma este-�
	//�                        ja ativa no momento, o browse sera exibido na�
	//�                        janela do proprio SIGAADV.                   �
	//� Alias                - Alias do arquivo a ser "Browseado".          �
	//� aCampos              - Array multidimensional com os campos a serem �
	//�                        exibidos no browse. Se nao informado, os cam-�
	//�                        pos serao obtidos do dicionario de dados.    �
	//�                        E util para o uso com arquivos de trabalho.  �
	//�                        Segue o padrao:                              �
	//�                        aCampos := { {<CAMPO>,<DESCRICAO>},;         �
	//�                                     {<CAMPO>,<DESCRICAO>},;         �
	//�                                     . . .                           �
	//�                                     {<CAMPO>,<DESCRICAO>} }         �
	//�                        Como por exemplo:                            �
	//�                        aCampos := { {"TRB_DATA","Data  "},;         �
	//�                                     {"TRB_COD" ,"Codigo"} }         �
	//� cCampo               - Nome de um campo (entre aspas) que sera usado�
	//�                        como "flag". Se o campo estiver vazio, o re- �
	//�                        gistro ficara de uma cor no browse, senao fi-�
	//�                        cara de outra cor.                           �
	//�����������������������������������������������������������������������

	mBrowse( 6,1,22,75,cString)
Return( NIL )
