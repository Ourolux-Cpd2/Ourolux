#INCLUDE "rwmake.ch"
#INCLUDE "Totvs.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �EITVOL    � Autor � Andre Bagatini     � Data �  28/03/11   ���
�������������������������������������������������������������������������͹��
���Descricao � Programa para imprimir etiquetas de volumes ap�s impress�o ���
���          � das Notas Fiscais                                          ���
�������������������������������������������������������������������������͹��
���Uso       � Faturamento                                                ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function ETIVOLU()


//���������������������������������������������������������������������Ŀ
//� Declaracao de Variaveis                                             �
//�����������������������������������������������������������������������

Local cDesc1        := "Este programa tem como objetivo imprimir relatorio "
Local cDesc2        := "de acordo com os parametros informados pelo usuario."
Local cDesc3        := ""
Local cPict         := ""
Local titulo       	:= "Etiquetas Volumes"
Local nLin         	:= 80

Local Cabec1       	:= ""
Local Cabec2       	:= ""
Local imprime      	:= .T.
Local aOrd 			:= {}
Private lEnd        := .F.
Private lAbortPrint := .F.
Private CbTxt       := ""
Private limite      := 80
Private tamanho     := "P"
Private nomeprog    := "ETIVOL" 
Private nTipo       := 18
Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey    := 0
Private cPerg       := "ETIVOL"
Private cbtxt      	:= Space(10)
Private cbcont     	:= 00
Private CONTFL     	:= 01
Private m_pag      	:= 01
Private wnrel      	:= "ETIVOL" 
Private cString 	:= "SF2"
Private aPergs		:= {}


aAdd(aPergs,{'Da Nota Fiscal ?' ,	'Da Nota Fiscal ?', 'Da Nota Fiscal ?'  , 'mv_ch1',	'C', 9 , 0,	0,	'C', '', 'mv_par01', '','','','','','', '', '','SF2','','','',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	''})
aAdd(aPergs,{'At� Nota Fiscal ?' ,	'At� Nota Fiscal ?', 'At� Nota Fiscal ?', 'mv_ch2',	'C', 9 , 0,	0,	'C', '', 'mv_par02', '','','','','','', '', '','SF2','','','',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	''})
aAdd(aPergs,{'S�rie ?' , 'S�rie ?', 'S�rie ?', 								  'mv_ch3',	'C', 1 , 0,	0,	'C', '', 'mv_par03', '','','','','','', '', '','   ','','','','','',	'',	'',	'',	'',	'',	'',	'',	'',	'',	''})

ValidPerg(cPerg,aPergs)

dbSelectArea("SF2")
dbSetOrder(1)

pergunte(cPerg,.T.)

If MV_PAR01 > MV_PAR02
	ApMsgAlert("Nota Inicial maior do que Final " ,"Aten��o")
EndIf

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
���Fun��o    �RUNREPORT � Autor � AP6 IDE            � Data �  28/03/11   ���
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
dbSeek(xFilial("SF2")+MV_PAR01+MV_PAR03)

//���������������������������������������������������������������������Ŀ
//� SETREGUA -> Indica quantos registros serao processados para a regua �
//�����������������������������������������������������������������������

SetRegua(RecCount())

While !EOF() .And. ( SF2->F2_DOC >= MV_PAR01 .And. SF2->F2_DOC <= MV_PAR02 )

   //���������������������������������������������������������������������Ŀ
   //� Verifica o cancelamento pelo usuario...                             �
   //�����������������������������������������������������������������������

   If lAbortPrint
      @nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
      Exit
   Endif

   //���������������������������������������������������������������������Ŀ
   //� Impressao do cabecalho do relatorio. . .                            �
   //�����������������������������������������������������������������������

   If nLin > 55 // Salto de P�gina. Neste caso o formulario tem 55 linhas...
//      Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
      nLin := 0
   Endif
     For n:= 1 to SF2->F2_VOLUME1
             //
	    @nLin,00 Psay "NF: "+SF2->F2_DOC+ " Ser.: "+SF2->F2_SERIE
	    nLin := nLin+2
	    @nLin,00 Psay AllTrim(GetAdvFVal("SA1","A1_NOME",xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA,1,0))
	    nLin := nLin+4
		@nLin,26 Psay "VOL.: "+AllTrim( Transform(n,"@E 999"))+ " / "+ AllTrim(Transform(SF2->F2_VOLUME1,"@E 999")) 
	    nLin := nLin+3
    	//
    Next
   dbSkip() // Avanca o ponteiro do registro no arquivo
EndDo

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

Static Function ValidPerg(cPerg,aPergs)

Local aArea 	:= GetArea()
Local aCposSX1	:= {}
Local nX := 0

aCposSX1:={"X1_PERGUNT","X1_PERSPA","X1_PERENG","X1_VARIAVL","X1_TIPO","X1_TAMANHO","X1_DECIMAL",;
"X1_PRESEL","X1_GSC","X1_VALID","X1_VAR01","X1_DEF01","X1_DEFSPA1","X1_DEFENG1",;
"X1_CNT01","X1_VAR02","X1_DEF02","X1_DEFSPA2","X1_DEFENG2","X1_CNT02","X1_F3" }

cPerg := PadR(cPerg,10) 

dbSelectArea("SX1")
dbSetOrder(1)
For nX:=1 to Len(aPergs)
	If !(MsSeek(cPerg+StrZero(nx,2)))
		RecLock("SX1",.T.)
		Replace X1_GRUPO with cPerg
		Replace X1_ORDEM with StrZero(nx,2)
		For nj:=1 to Len(aCposSX1)
			FieldPut(FieldPos(ALLTRIM(aCposSX1[nJ])),aPergs[nx][nj])
		Next nj
		MsUnlock()
	Endif
Next

RestArea(aArea)

Return