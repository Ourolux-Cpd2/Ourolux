#INCLUDE "rwmake.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RELBON     � Autor � Eletromega        � Data �  27/01/06   ���
�������������������������������������������������������������������������͹��
���Descricao � relatorio que faz verifica�ao de nf bonificadas no SD2     ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP6 IDE                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function RELBON


//���������������������������������������������������������������������Ŀ
//� Declaracao de Variaveis                                             �
//�����������������������������������������������������������������������

Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := "de acordo com os parametros informados pelo usuario."
Local cDesc3         := "Relatorio de Bonifica��o"
Local cPict          := ""
Local titulo       := "Relatorio de Bonifica��o"
Local nLin         := 80

Local Cabec1       := " CODIGO   LOJA   CLIENTE                        NUMERO NF    SERIE      EMISSAO"
Local Cabec2       := ""
Local imprime      := .T.
Local aOrd := {}
Private lEnd         := .F.
Private lAbortPrint  := .F.
Private CbTxt        := ""
Private limite           := 80
Private tamanho          := "P"
Private nomeprog         := "RELBON" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo            := 18
Private aReturn          := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey        := 0
Private cbtxt      := Space(10)
Private cbcont     := 00
Private CONTFL     := 01
Private m_pag      := 01
Private wnrel      := "RELBON" // Coloque aqui o nome do arquivo usado para impressao em disco
Private cPerg      := PadR("RELBON",10)
Private cString := "SD2"
Private sql := ""

/*dbSelectArea("SD2")
dbSetOrder(1)*/
pergunte(cPerg,.F.)


//���������������������������������������������������������������������Ŀ
//� Monta a interface padrao com o usuario...                           �
//�����������������������������������������������������������������������

wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
   Return
Endif

nTipo := If(aReturn[4]==1,15,18)

//���������������������������������������������������������������������Ŀ
//� Processamento. RPTSTATUS monta janela com a regua de processamento. �
//�����������������������������������������������������������������������

RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Fun��o    �RUNREPORT � Autor � AP6 IDE            � Data �  27/01/06   ���
�������������������������������������������������������������������������͹��
���Descri��o � Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS ���
���          � monta a janela com a regua de processamento.               ���
�������������������������������������������������������������������������͹��
���Uso       � Programa principal                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

Local nOrdem

dbSelectArea(cString)
dbSetOrder(1)

//���������������������������������������������������������������������Ŀ
//� SETREGUA -> Indica quantos registros serao processados para a regua �
//�����������������������������������������������������������������������

SetRegua(RecCount())

//���������������������������������������������������������������������Ŀ
//� Posicionamento do primeiro registro e loop principal. Pode-se criar �
//� a logica da seguinte maneira: Posiciona-se na filial corrente e pro �
//� cessa enquanto a filial do registro for a filial corrente. Por exem �
//� plo, substitua o dbGoTop() e o While !EOF() abaixo pela sintaxe:    �
//�                                                                     �
//� dbSeek(xFilial())                                                   �
//� While !EOF() .And. xFilial() == A1_FILIAL                           �
//�����������������������������������������������������������������������

sql := "SELECT DISTINCT SD2010.D2_CLIENTE AS CLIENTE,SD2010.D2_LOJA AS LOJA,"
sql += "SA1010.A1_NREDUZ AS NOME," 
sql += "SD2010.D2_DOC AS DOC, SD2010.D2_SERIE AS SERIE," 
sql += "SUBSTRING(SD2010.D2_EMISSAO, 7, 2) + '/' + SUBSTRING(SD2010.D2_EMISSAO, 5, 2) + '/' +" 
sql += "SUBSTRING(SD2010.D2_EMISSAO, 1, 4) AS EMISSAO "
sql += "FROM SD2010 INNER JOIN SA1010 ON SA1010.A1_COD = SD2010.D2_CLIENTE "
sql += "AND SA1010.A1_LOJA = SD2010.D2_LOJA "
sql += "WHERE SD2010.D2_EMISSAO BETWEEN '" +DtoS(MV_PAR01)+ "' AND '" +DtoS(MV_PAR02) + "'" 
sql += "AND SD2010.D2_CLIENTE BETWEEN '" +MV_PAR03+ "' AND '" + MV_PAR04+ "'"
sql += "AND (SD2010.D_E_L_E_T_ <> '*') AND (SA1010.D_E_L_E_T_ <> '*')" 
sql += "AND (D2_TES = '504')"
sql += "ORDER BY CLIENTE,LOJA,EMISSAO,DOC,SERIE"

dbUseArea( .T., "TOPCONN", TCGENQRY(,,sql), 'sql' ) //SALVAR A QRY DENTRO DA VARIAVEL _cSq



   //���������������������������������������������������������������������Ŀ
   //� Verifica o cancelamento pelo usuario...                             �
   //�����������������������������������������������������������������������

   If lAbortPrint
      @nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
//      Exit
   Endif

   //���������������������������������������������������������������������Ŀ
   //� Impressao do cabecalho do relatorio. . .                            �
   //�����������������������������������������������������������������������
do while ! sql->( Eof() )

   If nLin > 55 // Salto de P�gina. Neste caso o formulario tem 55 linhas...
      Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
      nLin := 8
   Endif

   // Coloque aqui a logica da impressao do seu programa...
   // Utilize PSAY para saida na impressora. Por exemplo:
   // @nLin,00 PSAY SA1->A1_COD
   @nlin,01 PSAY sql->CLIENTE
   @nlin,10 PSAY sql->LOJA
   @nlin,17 PSAY sql->NOME
   @nlin,48 PSAY sql->DOC
   @nlin,63 PSAY sql->SERIE
   @nlin,69 PSAY sql->EMISSAO
   nLin := nLin + 1 // Avanca a linha de impressao

   dbSkip() // Avanca o ponteiro do registro no arquivo
EndDo
   DBCLOSEAREA()
//���������������������������������������������������������������������Ŀ
//� Finaliza a execucao do relatorio...                                 �
//�����������������������������������������������������������������������

SET DEVICE TO SCREEN

//���������������������������������������������������������������������Ŀ
//� Se impressao em disco, chama o gerenciador de impressao...          �
//�����������������������������������������������������������������������

If aReturn[5]==1
   dbCommitAll()
   SET PRINTER TO
   OurSpool(wnrel)
Endif

MS_FLUSH()

Return
