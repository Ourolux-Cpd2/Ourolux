#INCLUDE "rwmake.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RPTMVEST     � Autor � Eletromega      � Data �  06/03/06   ���
�������������������������������������������������������������������������͹��
���Descricao � relatorio de transferencia de estoque                      ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP6 IDE                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function RPTMVEST


//���������������������������������������������������������������������Ŀ
//� Declaracao de Variaveis                                             �
//�����������������������������������������������������������������������

PRIVATE cDesc1         := "Este programa tem como objetivo imprimir relatorio "
PRIVATE cDesc2         := "de acordo com os parametros informados pelo usuario."
PRIVATE cDesc3         := "Transferencia de Estoque"
PRIVATE cPict          := ""
PRIVATE titulo       := "Rel. Transferencia de Estoque Eletromega"
PRIVATE nLin         := 132
PRIVATE Cabec1       := ""
PRIVATE Cabec2       := ""
PRIVATE imprime      := .T.
PRIVATE aOrd := {}
Private lEnd         := .F.
Private lAbortPrint  := .F.
Private CbTxt        := ""
Private limite           := 132
Private tamanho          := "M"
Private nomeprog         := "RPTMVE" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo            := 18
Private aReturn          := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey        := 0
Private cbtxt      := Space(10)
Private cPerg := PadR("RPTMVE",10)
Private cbcont     := 00
Private CONTFL     := 01
Private m_pag      := 01
Private wnrel      := "RPTMVEST" // Coloque aqui o nome do arquivo usado para impressao em disco
Private csql := ""
Private cString := "SD3"
PRIVATE csaida := '999'
PRIVATE centrada := '499'
PRIVATE corigem := ""
PRIVATE cdestino := ""

Cabec1 := "CODIGO   PROD            DESCRICAO                            UN        QUANT"
Cabec1 += "       ORIGEM   DESTINO       USUARIO           DATA"

dbSelectArea("SD3")
dbSetOrder(1)  

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
���Fun��o    �RUNREPORT � Autor � AP6 IDE            � Data �  06/03/06   ���
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

PRIVATE nOrdem

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

csql := "SELECT D3_DOC DOC, D3_COD CODIGO, B1_DESC DESCR, D3_UM UN, D3_QUANT QUANT, "
csql += "D3_LOCAL ARMAZEN, D3_TM, D3_USUARIO USUARIO, "
csql += "SUBSTRING(D3_EMISSAO,7,2) + '/' + SUBSTRING(D3_EMISSAO,5,2)  +'/'"
csql += "+ SUBSTRING(D3_EMISSAO,1,4)  DATAEM "
csql += "FROM " + RetSqlName("SD3") + " SD3 INNER JOIN " + RetSqlName("SB1") + " SB1 "
csql += "ON D3_COD = B1_COD "
csql += "WHERE D3_EMISSAO BETWEEN '"+DTOS(mv_par05)+"' AND '"+DTOS(mv_par06)+"' "
csql += "AND D3_COD BETWEEN '"+mv_par03+"' AND '"+mv_par04+"' "
csql += "AND D3_DOC BETWEEN '"+mv_par01+"' AND '"+mv_par02+"' "
csql += "AND D3_ESTORNO <> 'S' "
csql += "AND SD3.D_E_L_E_T_ = ' ' AND SB1.D_E_L_E_T_ = ' ' "
csql += "AND D3_FILIAL = '" + xFilial("SD3") + "' AND B1_FILIAL = '" + xFilial("SB1") + "' "  
csql += "ORDER BY DOC,CODIGO,DATAEM" 

dbUseArea(.T.,"TOPCONN",TCGENQRY(,,csql),'csql') 
csql->(dbgotop())

   //���������������������������������������������������������������������Ŀ
   //� Verifica o cancelamento pelo usuario...                             �
   //�����������������������������������������������������������������������

   If lAbortPrint
      @nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
      Return(nil)
   Endif

   //���������������������������������������������������������������������Ŀ
   //� Impressao do cabecalho do relatorio. . .                            �
   //�����������������������������������������������������������������������
while ! csql->(Eof())
 
      
   If nLin > 70 // Salto de P�gina. Neste caso o formulario tem 70 linhas...
      Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
      nLin := 8
   Endif

   // Coloque aqui a logica da impressao do seu programa...
   // Utilize PSAY para saida na impressora. Por exemplo:
   // @nLin,00 PSAY SA1->A1_COD   
      
   @nLin, 00 PSAY csql->DOC
   @nLin, 09 PSAY ALLTRIM(csql->CODIGO)
   @nLin, 18 PSAY csql->DESCR
   @nLin, 62 PSAY csql->UN
   @nLin, 74 PSAY csql->QUANT
      
   if (csql->D3_TM == csaida)  
   	   	corigem := csql->ARMAZEN
   		csql->(dbskip())
   		cdestino := csql->ARMAZEN
   else
   		cdestino := csql->ARMAZEN
   		csql->(dbskip())
   		corigem := csql->ARMAZEN
   end   
   @nLin, 86 PSAY corigem
   @nLin, 96 PSAY cdestino
   @nLin, 107 PSAY SUBSTR(csql->USUARIO,1,6)
   @nLin, 122 PSAY csql->DATAEM
   csql->(dbskip())
   nLin++ // Avanca a linha de impressao
   End
   csql->(DBCLOSEAREA())

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
