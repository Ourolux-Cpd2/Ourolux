#INCLUDE "rwmake.ch"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AXTABELA  �Autor  �Eletromega          � Data �  02/03/06   ���
�������������������������������������������������������������������������͹��
���Desc.     � Filtrar DA1 - Tabela de pre�o                              ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP6                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

/*BEGINDOC
//����������������������������������������������������-F
//�Filrar tabela de pre�o (DA1) pelo tipo de Vendedor:�
//�Interno - tabelo revenda                           �
//�Repres - supermercado                              �
//�Cliente - supermercado                             �
//�                                                   �
//����������������������������������������������������-F�
ENDDOC*/

User Function AXTabela()
cFilDA1 := ""

dbSelectArea( 'DA1' )

cFiltro := dbFilter()

If Empty( cFiltro )

   cCod  := RetCodUsr()

   SA3->( dbSetOrder( 7 ) )

   If ! ( SA3->( dbSeek( xFilial( 'SA3' ) + cCod, .F. ) ) )
      cCod := '000000'
   Else
      cCod := SA3->A3_COD                                                                                            
   End

   IF (SA3->A3_TIPO $ 'I' )    // VENDEDOR INTERNO
   		cFilDA1 := "DA1_CODTAB=='1  '"   // TABELA 1  = REVENDA
        
   ELSEIF (SA3->A3_TIPO $ 'E' )// VENDEDOR EXTERNO  						       
   		
   		IF (SA3->A3_COD == "500002")  // CLIENTE/VENDEDOR NOVA SIRIUS
   			cFilDA1 := "DA1_CODTAB=='3  '"   // TABELA 3  = DIRETO
   		ELSE 
   			cFilDA1 := "DA1_CODTAB=='6  '"   // TABELA 6  = SUPERMERCADO
   		ENDIF
   		
   ELSEIF (SA3->A3_TIPO $ 'C' )
   		cFilDA1 = "DA1_CODTAB=='6  '"   // TABELA 6  = SUPERMERCADO "
   ENDIF
   
   SA3->( dbSetOrder( 1 ) )
   SA1->( dbSetOrder( 6 ) )
   SA1->( dbSeek( xFilial( 'SA1' ) + cCod, .T. ) )
   SA1->( dbSetOrder( 1 ) )
   
   dbSelectArea( 'DA1' )
   Set filter to &cFilDA1

End

//���������������������������������������������������������������������Ŀ
//� Declaracao de Variaveis                                             �
//�����������������������������������������������������������������������

Private cString
Private cCadastro := "Consulta Produto, Precos, Saldos"

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

Private aRotina := { {"Pesquisar","AxPesqui",0,1} ,;                         
                   		{"Saldos" ,"U_Saldo",0,5} } 
                   
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
