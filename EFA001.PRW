#INCLUDE "PROTHEUS.CH"
#DEFINE MAXGETDAD 99999
#Define GD_INSERT 1
#Define GD_UPDATE 2
#Define GD_DELETE 4

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณEFA001    บ Autor ณ AP6 IDE            บ Data ณ  11/04/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Codigo gerado pelo AP6 IDE.                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function EFA001
Local aPergs      := {}
Private cCadastro := "Controle de Cheques"
Private cDelFunc  := ".T." // Validacao para a exclusao. Pode-se utilizar
Private cString   := "SZ1"
Private bFiltraBrw:= {|| Nil}
Private aCores	  := {	{'Z1_STATUS $ "A/B"'    ,"BR_VERDE"   ,"Cheque Recebido"},;
{'Z1_STATUS $ "C"'        ,"BR_AMARELO" ,"Cheque Armazenado"},;
{'Z1_STATUS $ "D"'        ,"BR_VERMELHO","Cheque Baixado"},;
{'Z1_STATUS $ "E"'        ,"BR_LARANJA" ,"Cheque Repassado"},;
{'Z1_STATUS $ "F"'        ,"BR_PRETO"   ,"Cheque Devolvido"},;
{'Z1_STATUS $ "G"'        ,"BR_AZUL"    ,"Cheque Quitado"}}


Private aRotina   := { 	{"Pesquisar"   ,"U_EFPESQCHQ"   ,0,1} ,;
{"Consulta"	,"U_EFCONSULTACHQ",0,2} ,;
{"Receber"	,"U_EFRECEBECHQ",0,3} ,;
{"Alterar"	,"U_EFALTERACHQ",0,4} ,;
{"Excluir"	,"U_EFDELCHQ",0,5} ,;
{"Armazenar","U_EFARMAZENACHQ",0,6} ,;
{"Baixar"	,"U_EFBAIXACHQ",0,7} ,;
{"Repassar"	,"U_EFREPASSACHQ",0,8} ,;
{"Devolver"	,"U_EFDEVOLVECHQ",0,9} ,;
{"Quitacao" ,"U_EFPAGACHQ",0,10}}


aPergs:= {}
aAdd(aPergs,{'Banco De ?'       ,	'Banco De ?'       , 'Banco De ?'      ,'mv_ch1',	'C', 3 , 0,	0,	'G',	'',	'mv_par01','','','',	'',		'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	''})
aAdd(aPergs,{'Banco Ate ?'      ,	'Banco  ?'         , 'Banco Ate ?'      , 'mv_ch2',	'C', 3 , 0,	0,	'G',	'',	'mv_par02','','','',	'',		'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	''})
aAdd(aPergs,{'Vencimento De  ?' ,	'Vencimento De  ?' , 'Vencimento De  ?' , 'mv_ch3',	'D', 8 , 0,	0,	'G',	'',	'mv_par03',	'',	'',	'',	'',		'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	''})
aAdd(aPergs,{'Vencimento Ate ?' ,	'Vencimento Ate ?' , 'Vencimento Ate ?' , 'mv_ch4',	'D', 8 , 0,	0,	'G',	'',	'mv_par04',	'',	'',	'',	'',		'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	''})
aAdd(aPergs,{'Traz Marcados   ?',	'Traz Marcados   ?', 'Traz Marcados   ?', 'mv_ch5',	'N', 1 , 0,	1,	'C',	'',	'mv_par05',	'Sim',	'Si',	'Yes',	'',		'',	'Nao',	'No',	'No',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',''})
//aAdd(aPergs,{'Banco Deposito  ?',	'Banco Deposito  ?', 'Banco Deposito  ?', 'mv_ch6',	'C', 3 , 0,	0,	'G',	'',	'mv_par06','','','',	'',		'',	'',	'',	'',	'',	'SA6',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	''})
//aAdd(aPergs,{'Ag. Deposito    ?',	'Ag. Deposito    ?', 'Ag. Deposito    ?', 'mv_ch7',	'C', 5 , 0,	0,	'G',	'',	'mv_par07','','','',	'',		'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	''})
//aAdd(aPergs,{'Conta Deposito  ?',	'Conta Deposito  ?', 'Conta Deposito  ?', 'mv_ch8',	'C', 10, 0,	0,	'G',	'',	'mv_par08','','','',	'',		'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	''})
//aAdd(aPergs,{'Baixa Titulos   ?',	'Baixa Titulos   ?', 'Baixa Titulos   ?', 'mv_ch9',	'C', 1 , 0,	2,	'C',    '', 'mv_par09', 'Sim','Si','Yes','',	'',	'Nao', 'No', 'No','','','',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	''})
A001SX1("EFA001",aPergs)

aPergs:= {}
aAdd(aPergs,{'Utiliza Leitora ?',	'Utiliza Leitora   ?', 'Utiliza Leitora   ?', 'mv_ch1',	'C', 1 , 0,	2,	'C', '', 'mv_par01', 'Sim','Si','Yes','',	'',	'Nao', 'No', 'No','','','',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	''})
A001SX1("EFA01A",aPergs)


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAtualiza os parametros.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
EFAtuSX6()

SetKey(VK_F4 ,{|| U_EFLEGENDA()})
SetKey(VK_F5 ,{|| U_EFFILTRO()})
SetKey(VK_F12,{|| Pergunte("EFA01A",.T.)})

dbSelectArea("SZ1")
dbSetOrder(1)

dbSelectArea(cString)
mBrowse( 6,1,22,75,cString,,,,,,aCores)

SetKey(VK_F4,Nil)
SetKey(VK_F5,Nil)
SetKey(VK_F12,Nil)

SZ1->(DbClearFilter())                                                               

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณEFLEGENDAณ Autor ณ  Fabio Rogerio Pereira ณ Data ณ 18-03-2002 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Programa de Exibicao de Legendas                             ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ EFLEGENDA                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function EFLEGENDA()
Local aLegenda:= {}
Local i       := 0

For i:= 1 To Len(aCores)
	Aadd(aLegenda,{aCores[i,2],aCores[i,3]})
Next i

aLegenda:= aSort(aLegenda,,,{|x,y| x[2] < y[2]})

BrwLegenda(cCadastro,"Legenda" ,aLegenda) //"Legenda"

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณEFPESQCHQ   บ Autor ณ AP6 IDE          บ Data ณ  11/04/04   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Pesquisa o cheque.                                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function EFPESQCHQ(cAlias,nReg,nOpc)
Local oDlg
Local oCmc7
Local oBtn
Local cCmc7  := Space(40)
Local cCheque:= ""
Local nTBco  := TamSX3("Z1_BANCO")[1]
Local nTAg   := TamSX3("Z1_AGENCIA")[1]
Local nTCC   := TamSX3("Z1_CONTA")[1]
Local nTChq  := TamSX3("Z1_CHEQUE")[1]

Pergunte("EFA01A",.F.)

If (Mv_Par01 == 1)
	DEFINE MSDIALOG oDlg FROM 0,0 TO 100,500 OF oMainWnd PIXEL
	@05,01 TO 35,250 LABEL "Leitura de Dados" OF oDlg PIXEL
	@15,05 SAY "Dados CMC7" SIZE 50,10 OF oDlg PIXEL
	@15,50 MSGET oCmc7 VAR cCmc7 SIZE 200,10 OF oDlg PIXEL
	DEFINE SBUTTON  FROM 38,220 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg PIXEL
	ACTIVATE MSDIALOG oDlg CENTERED
	
	cCheque:= Padr(SubStr(cCMC7,2,3),nTBco)+Padr(SubStr(cCMC7,5,4),nTAg)+Padr(SubStr(cCMC7,23,10),nTCC)+PadR(SubStr(cCMC7,14,6),nTChq)
	dbSelectArea("SZ1")
	dbSetOrder(1)
	If !dbSeek(xFilial("SZ1")+cCheque)
		Aviso("Atencao","O cheque nao esta cadastrado !!!",{"Ok"})
		Return
	EndIf
Else
	PesqBrw(cAlias,nReg,nOpc)
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณEFLeCmc7  บ Autor ณ AP6 IDE            บ Data ณ  11/04/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Le as informacoes do cheque.						          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function EFLECMC7(cAlias,cObj,oObj)
Local oDlg
Local oCmc7
Local oBtn
Local cCmc7    := Space(40)
Local cCheque  := ""
Local nPBanco  := 0
Local nPAgencia:= 0
Local nPConta  := 0
Local nPCheque := 0
Local nPComp   := 0
Local nPSerie  := 0
Local nPValor  := 0
Local nPVencto := 0
Local nPSacado := 0
Local nPos     := 0
Local nTBco    := TamSX3("Z1_BANCO")[1]
Local nTAg     := TamSX3("Z1_AGENCIA")[1]
Local nTCC     := TamSX3("Z1_CONTA")[1]
Local nTChq    := TamSX3("Z1_CHEQUE")[1]

DEFAULT oObj:= Nil

DEFINE MSDIALOG oDlg FROM 0,0 TO 100,500 OF oMainWnd PIXEL STYLE nOR(WS_VISIBLE,WS_POPUP)
@15,01 TO 45,250 LABEL "Leitura de Dados" OF oDlg PIXEL
@25,05 SAY "Dados CMC7" SIZE 50,10 OF oDlg PIXEL
@25,50 MSGET oCmc7 VAR cCmc7 SIZE 150,10 OF oDlg PIXEL
DEFINE SBUTTON  FROM 23,210 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg PIXEL
ACTIVATE MSDIALOG oDlg CENTERED

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ0ฟ
//ณValida o tamanho dos dados lidos.   ณ
//ณSomente aceita se for 34 caracteres.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ0ู
If (Len(AllTrim(cCmc7)) < 34)
	Aviso("Atencao","Os dados nao foram lidos corretamente !!! Passe o cheque novamente.",{"Ok"})
	Return()
EndIf

If (cAlias == "SZ1")
	If (cObj == "E") //Enchoice
		M->Z1_BANCO  := Padr(SubStr(cCMC7,2,3),nTBco)
		M->Z1_AGENCIA:= Padr(SubStr(cCMC7,5,4),nTAg)
		M->Z1_COMP   := SubStr(cCMC7,11,3)
		M->Z1_CHEQUE := Padr(SubStr(cCMC7,14,6),nTChq)
		M->Z1_SERIE  := SubStr(cCMC7,20,1)
		M->Z1_CONTA  := Padr(SubStr(cCMC7,23,10),nTCC)
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณValida se o cheque existe.ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		U_Z1VALCHQ()
		M->Z1_SACADO:= Posicione("SZ1",1,xFilial("SZ1")+M->(Z1_BANCO+Z1_AGENCIA+Z1_CONTA),"Z1_SACADO")
		
	ElseIf (cObj == "G")
		
		nPBanco  := aScan(oObj:aHeader,{|x| AllTrim(x[2]) == "Z1_BANCO"})
		nPAgencia:= aScan(oObj:aHeader,{|x| AllTrim(x[2]) == "Z1_AGENCIA"})
		nPComp   := aScan(oObj:aHeader,{|x| AllTrim(x[2]) == "Z1_COMP"})
		nPCheque := aScan(oObj:aHeader,{|x| AllTrim(x[2]) == "Z1_CHEQUE"})
		nPSerie  := aScan(oObj:aHeader,{|x| AllTrim(x[2]) == "Z1_SERIE"})
		nPConta  := aScan(oObj:aHeader,{|x| AllTrim(x[2]) == "Z1_CONTA"})
		nPValor  := aScan(oObj:aHeader,{|x| AllTrim(x[2]) == "Z1_VALOR"})
		nPVencto := aScan(oObj:aHeader,{|x| AllTrim(x[2]) == "Z1_VENCTO"})
		nPSacado := aScan(oObj:aHeader,{|x| AllTrim(x[2]) == "Z1_SACADO"})
		
		cCheque:= Padr(SubStr(cCMC7,2,3),nTBco)+Padr(SubStr(cCMC7,5,4),nTAg)+Padr(SubStr(cCMC7,23,10),nTCC)+PadR(SubStr(cCMC7,14,6),nTChq)
		dbSelectArea("SZ1")
		dbSetOrder(1)
		dbSeek(xFilial("SZ1")+cCheque)

		If (nPAgencia > 0)
			oObj:aCols[oObj:nAT,nPAgencia]:= SZ1->Z1_AGENCIA
		EndIf
		
		If (nPComp > 0)
			oObj:aCols[oObj:nAT,nPComp]:= SZ1->Z1_COMP
		EndIf
		
		If (nPCheque > 0)
			oObj:aCols[oObj:nAT,nPCheque]:= SZ1->Z1_CHEQUE
		EndIf
		
		If (nPSerie > 0)
			oObj:aCols[oObj:nAT,nPSerie]:= SZ1->Z1_SERIE
		EndIf
		
		If (nPConta > 0)
			oObj:aCols[oObj:nAT,nPConta]:= SZ1->Z1_CONTA
		EndIf
		
		If (nPValor > 0)
			oObj:aCols[oObj:nAT,nPValor]:= SZ1->Z1_VALOR
		EndIf
		
		If (nPVencto > 0)
			oObj:aCols[oObj:nAT,nPVencto]:= SZ1->Z1_VENCTO
		EndIf
		
		If (nPSacado > 0)
			oObj:aCols[oObj:nAT,nPSacado]:= SZ1->Z1_SACADO
		EndIf

		If (nPBanco > 0)
			oObj:aCols[oObj:nAT,nPBanco]:= SZ1->Z1_BANCO
		EndIf

		For nX:=1 To Len(oObj:aHeader)
			M->&(oObj:aHeader[nX,2]):= oObj:aCols[oObj:nAT,nX]
		Next nX

		oObj:ForceRefresh()
					
	ElseIf (cObj == "L")
		cCheque:= Padr(SubStr(cCMC7,2,3),nTBco)+Padr(SubStr(cCMC7,5,4),nTAg)+Padr(SubStr(cCMC7,23,10),nTCC)+PadR(SubStr(cCMC7,14,6),nTChq)
		
		nPos:= aScan(aChq,{|x| x[2]+x[3]+x[4]+x[5] == cCheque})
		If (nPos > 0)
			oLbx:nAt:= nPos
		EndIf
	EndIf
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณEFRECEBECHQ บ Autor ณ AP6 IDE          บ Data ณ  11/04/04   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Codigo gerado pelo AP6 IDE.                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function EFRECEBECHQ(cAlias,nReg,nOpc)
Local oDlg
Local nOpcA       := 0
Local nStyle      := 0
Local aSize	      := {}
Local aObjects    := {}
Local aInfo	      := {}
Local aPosObj     := {}
Local lArmazena   := .F.
Local lRet        := .F.
Private oGetChq
Private lDevolvido:= .F.
Private REPASSA   := .F.
Private aTELA[0][0],aGETS[0],aHeader[0],aCols[0]

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica qual opcao do menu chamou esta rotina.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If (nOpc == 3)
	nStyle := GD_INSERT+GD_UPDATE+GD_DELETE
	SetKey(VK_F4,{|| EFLeCMC7("SZ1","E")})
ElseIf(nOpc == 6)
	lArmazena:= .T.
	nOpc     := 4
	nStyle := GD_INSERT+GD_UPDATE+GD_DELETE
Else
	nStyle := 0
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Faz o calculo automatico de dimensoes de objetos     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aSize := MsAdvSize(,.F.,370)
aObjects := {}

AAdd( aObjects, { 100, 100, .T., .T. } )
AAdd( aObjects, { 100, 100, .T., .T. } )

aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects )

RegToMemory("SZ1",IIF(nOpc == 3,.T.,.F.))
EF001ACOLS("SZ3","Z3_FILIAL/Z3_BAIXA/Z3_DTCANC/Z3_VALPAG/Z3_DTPAG/Z3_BCOPAG/Z3_AGPAG/Z3_CONTPAG/Z3_CHQREC/Z3_CHQPAG",IIF(nOpc == 3,.T.,.F.))

DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL

EnChoice( cAlias, nReg, nOpc, , , , , aPosObj[1],, 3 )

oGetChq:= MsNewGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nStyle,"U_Z3LINOK(n)","U_Z3TUDOK",/*inicpos*/,Nil,/*freeze*/,MAXGETDAD,/*fieldok*/,/*superdel*/,/*delok*/,oDlg,@aHeader,@aCols)
oGetChq:lDelete:= .T.

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||IIf(Obrigatorio(aGets,aTela) .And. IIf(nOpc == 3,U_Z1VALCHQ(),.T.) .And. oGetChq:TudoOk(),(nOpcA:=1,oDlg:End()),"")},{||oDlg:End()})

If (nOpcA == 1)
	lRet:= A001GrvChq(IIf(nOpc == 5,.T.,.F.),lArmazena,lDevolvido)
EndIf

SetKey(VK_F4 ,{|| U_EFLEGENDA()})
SetKey(VK_F12,{|| Pergunte("EFA01A",.T.)})

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณEF001ACols บ Autor ณ AP6 IDE           บ Data ณ  11/04/04   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Codigo gerado pelo AP6 IDE.                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function EF001ACols(cAlias,cCampo,lInclui)
Local nUsado:= 0
Local nI    := 0
Local nReg  := 0
Local lCampo:= .F.

aCols  := {}
aHeader:= {}

dbSelectArea("SX3")
dbSetOrder(1)
dbSeek( cAlias )
While !Eof() .And. (X3_ARQUIVO == cAlias)
	If (cAlias == "SZ4")
		lCampo:= ((Trim(X3_CAMPO) $ cCampo) .Or. (cCampo == "*")) .And. (cNivel >= SX3->X3_NIVEL)
	Else
		lCampo:= X3USO(X3_USADO) .And. (cNivel >= SX3->X3_NIVEL) .And. !(Trim(X3_CAMPO) $ cCampo)
	EndIf
	
	If lCampo
		nUsado++
		AADD(aHeader,{ 	TRIM(X3TITULO()),;
		X3_CAMPO,;
		X3_PICTURE,;
		X3_TAMANHO,;
		X3_DECIMAL,;
		X3_VALID,;
		X3_USADO,;
		X3_TIPO,;
		X3_F3,;
		X3_CONTEXT,;
		X3_CBOX,;
		X3_RELACAO,;
		".T."})
	EndIf
	dbSkip()
End

aAdd(aCols,Array(Len(aHeader)+1))
For nI := 1 To Len(aHeader)
	aCols[Len(aCols),nI] := CriaVar(aHeader[nI,2],IIf(aHeader[nI,10] == "V",.T.,.F.))
Next nI
aCols[Len(aCols),Len(aHeader)+1] := .F.
nX  := 1
nReg:= 1

If !lInclui
	If (cAlias == "SZ2") //Movimentos do Cheques
		dbSelectArea("SZ2")
		dbSetOrder(1)
		dbSeek(xFilial("SZ2")+M->Z1_BANCO+M->Z1_AGENCIA+M->Z1_CONTA+M->Z1_CHEQUE,.T.)
		
		While !Eof() .And. (xFilial("SZ2")+M->Z1_BANCO+M->Z1_AGENCIA+M->Z1_CONTA+M->Z1_CHEQUE == SZ2->(Z2_FILIAL+Z2_BANCO+Z2_AGENCIA+Z2_CONTA+Z2_CHEQUE))
			
			If (nReg > 1)
				aAdd(aCols,Array(Len(aHeader)+1))
			EndIf
			
			For nI := 1 To Len(aHeader)
				If (aHeader[nI,10] == "V")
					aCols[Len(aCols),nI] := CriaVar(aHeader[nI,2])
				Else
					aCols[Len(aCols),nI] := FieldGet(FieldPos(aHeader[nI,2]))
				EndIf
			Next nI
			aCols[Len(aCols),Len(aHeader)+1] := .F.
			nReg++
			
			dbSkip()
		End
		
	ElseIf (cAlias == "SZ3") //Duplicatas a Receber
		dbSelectArea("SZ3")
		dbSetOrder(1)
		dbSeek(xFilial("SZ3")+M->Z1_BANCO+M->Z1_AGENCIA+M->Z1_CONTA+M->Z1_CHEQUE,.T.)
		
		While !Eof() .And. (xFilial("SZ3")+M->Z1_BANCO+M->Z1_AGENCIA+M->Z1_CONTA+M->Z1_CHEQUE == SZ3->(Z3_FILIAL+Z3_BANCO+Z3_AGENCIA+Z3_CONTA+Z3_CHEQUE))
			
			If (nReg > 1)
				aAdd(aCols,Array(Len(aHeader)+1))
			EndIf
			
			For nI := 1 To Len(aHeader)
				If (aHeader[nI,10] == "V")
					aCols[Len(aCols),nI] := CriaVar(aHeader[nI,2])
				Else
					aCols[Len(aCols),nI] := FieldGet(FieldPos(aHeader[nI,2]))
				EndIf
			Next nI
			aCols[Len(aCols),Len(aHeader)+1] := .F.
			nReg++
			
			dbSkip()
		End
		
	ElseIf (cAlias == "SZ4") //Duplicatas a Pagar
		dbSelectArea("SZ4")
		dbSetOrder(1)
		dbSeek(xFilial("SZ4")+M->Z1_BANCO+M->Z1_AGENCIA+M->Z1_CONTA+M->Z1_CHEQUE,.T.)
		
		While !Eof() .And. (xFilial("SZ4")+M->Z1_BANCO+M->Z1_AGENCIA+M->Z1_CONTA+M->Z1_CHEQUE == SZ4->(Z4_FILIAL+Z4_BANCO+Z4_AGENCIA+Z4_CONTA+Z4_CHEQUE))
			
			If (nReg > 1)
				aAdd(aCols,Array(Len(aHeader)+1))
			EndIf
			
			For nI := 1 To Len(aHeader)
				If (aHeader[nI,10] == "V")
					aCols[Len(aCols),nI] := CriaVar(aHeader[nI,2])
				Else
					aCols[Len(aCols),nI] := FieldGet(FieldPos(aHeader[nI,2]))
				EndIf
			Next nI
			aCols[Len(aCols),Len(aHeader)+1] := .F.
			nReg++
			
			dbSkip()
		End
	EndIf
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณZ1VALCHQ    บ Autor ณ AP6 IDE          บ Data ณ  11/04/04   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Codigo gerado pelo AP6 IDE.                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function Z1VALCHQ()
Local lRet   := .T.
Local aArea  := GetArea()
Local nPCheque:= aScan(oGetChq:aHeader,{|x| AllTrim(x[2]) == "Z1_CHEQUE"})

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSomente executa a validacao na inclusao de cheques.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If (nPCheque == 0)
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณVerifica se o cheque ja foi cadastrado anteriormente.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	dbSelectArea("SZ1")
	dbSetOrder(1)
	If dbSeek(xFilial("SZ1")+M->Z1_BANCO+M->Z1_AGENCIA+M->Z1_CONTA+M->Z1_CHEQUE)
		Aviso("Atencao","Este cheque ja esta cadastrado !!!",{"Ok"})
		lRet:= .F.
	EndIf
	
	If lRet
		lDevolvido:= .F.
		dbSelectArea("SZ2")
		dbSetOrder(2)
		If dbSeek(xFilial("SZ2")+"F"+M->Z1_BANCO+M->Z1_AGENCIA+M->Z1_CONTA,.T.)
			Aviso("Atencao","Existem cheques devolvidos para esta conta !!!",{"Ok"})
			lDevolvido:= .T.
		EndIf
	EndIf
EndIf

RestArea(aArea)
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณZ3LINOK    บ Autor ณ AP6 IDE           บ Data ณ  11/04/04   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Codigo gerado pelo AP6 IDE.                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function Z3LINOK(nItem)
Local lRet     := .T.
Local nPPrefixo:= aScan(oGetChq:aHeader,{|x| AllTrim(x[2]) == "Z3_PREFIXO" })
Local nPNum    := aScan(oGetChq:aHeader,{|x| AllTrim(x[2]) == "Z3_NUM" })
Local nPParcela:= aScan(oGetChq:aHeader,{|x| AllTrim(x[2]) == "Z3_PARCELA" })
Local nPTipo   := aScan(oGetChq:aHeader,{|x| AllTrim(x[2]) == "Z3_TIPO" })
Local nPSaldo  := aScan(oGetChq:aHeader,{|x| AllTrim(x[2]) == "Z3_SALDO" })
Local nI       := 0
Local nCount   := 0
Local nValComp := 0
Local cTitulo  := ""

DEFAULT nItem:= n

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSe deixou a linha em branco deleta-a.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If 	!oGetChq:aCols[nItem,Len(oGetChq:aHeader)+1] .And. (Empty(oGetChq:aCols[nItem,nPPrefixo]) .And.;
	Empty(oGetChq:aCols[nItem,nPNum]) .And. Empty(oGetChq:aCols[nItem,nPParcela]) .And. Empty(oGetChq:aCols[nItem,nPTipo]))
	oGetChq:aCols[nItem,Len(oGetChq:aHeader)+1]:= .T.
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica se nao foi lancado o titulo mais de uma vez.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !oGetChq:aCols[nItem,Len(oGetChq:aHeader)+1]
	cTitulo:= oGetChq:aCols[nItem,nPPrefixo]+oGetChq:aCols[nItem,nPNum]+oGetChq:aCols[nItem,nPParcela]+oGetChq:aCols[nItem,nPTipo]
	For nI:= 1 To Len(oGetChq:aCols)
		If !oGetChq:aCols[nI,Len(oGetChq:aHeader)+1]
			If (cTitulo == oGetChq:aCols[nI,nPPrefixo]+oGetChq:aCols[nI,nPNum]+oGetChq:aCols[nI,nPParcela]+oGetChq:aCols[nI,nPTipo])
				nCount++
			EndIf
		EndIf
	Next
	
	If nCount > 1
		Aviso("Atencao","Este titulo ja foi lancado !!!",{"Ok"})
		lRet:= .F.
	EndIf
	
	
	nValComp:= A001ValComp(cTitulo,M->(Z1_BANCO+Z1_AGENCIA+Z1_CONTA+Z1_CHEQUE))
	
	If (nValComp >= oGetChq:aCols[nItem,nPSaldo]) .And. (nValComp > 0)
		Aviso("Atencao","Este titulo ja esta com o saldo comprometido em outros cheques !!!",{"Ok"})
		lRet:= .F.
	EndIf
EndIf

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณZ3TUDOK    บ Autor ณ AP6 IDE           บ Data ณ  11/04/04   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Codigo gerado pelo AP6 IDE.                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function Z3TUDOK()
Local lRet      := .T.
Local nPPrefixo := aScan(oGetChq:aHeader,{|x| AllTrim(x[2]) == "Z3_PREFIXO" })
Local nPNum     := aScan(oGetChq:aHeader,{|x| AllTrim(x[2]) == "Z3_NUM" })
Local nPParcela := aScan(oGetChq:aHeader,{|x| AllTrim(x[2]) == "Z3_PARCELA" })
Local nPTipo    := aScan(oGetChq:aHeader,{|x| AllTrim(x[2]) == "Z3_TIPO" })
Local nPSaldo   := aScan(oGetChq:aHeader,{|x| AllTrim(x[2]) == "Z3_SALDO" })
Local nPValor   := aScan(oGetChq:aHeader,{|x| AllTrim(x[2]) == "Z3_VALOR" })
Local nValChq   := M->Z1_VALOR
Local nSaldo    := 0
Local nTotTit   := 0
Local nValComp  := 0
Local nI        := 0
Local nValAux   := 0
Local nTotBx    := 0
Local nTit      := 0
Local nPos      := 0
Local nDif      := 0

For nI:= 1 To Len(oGetChq:aCols)
	If !oGetChq:aCols[nI,Len(oGetChq:aHeader)+1]
		nTit++
		
		nValComp:= A001ValComp(oGetChq:aCols[nI,nPPrefixo]+oGetChq:aCols[nI,nPNum]+oGetChq:aCols[nI,nPParcela]+oGetChq:aCols[nI,nPTipo],M->(Z1_BANCO+Z1_AGENCIA+Z1_CONTA+Z1_CHEQUE))
		nTotTit+= oGetChq:aCols[nI,nPSaldo]-nValComp
	EndIf
	
	If !U_Z3LINOK(nI)
		lRet:= .F.
		Return(lRet)
	EndIf
Next

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณExecuta o calculo das baixas proporcionalmente.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aEval(oGetChq:aCols,{|x| nTotBX+= IIF(!x[Len(oGetChq:aHeader)+1],x[nPValor],0)})
nSaldo:= IIf(nTotBX == 0,M->Z1_VALOR,0)

For nI:= 1 To Len(oGetChq:aCols)
	If !oGetChq:aCols[nI,Len(oGetChq:aHeader)+1]
		nTotBx:= 0
		aEval(oGetChq:aCols,{|x| nTotBX+= IIF(!x[Len(oGetChq:aHeader)+1],x[nPValor],0)})
		nValComp:= A001ValComp(oGetChq:aCols[nI,nPPrefixo]+oGetChq:aCols[nI,nPNum]+oGetChq:aCols[nI,nPParcela]+oGetChq:aCols[nI,nPTipo],M->(Z1_BANCO+Z1_AGENCIA+Z1_CONTA+Z1_CHEQUE))
		If (oGetChq:aCols[nI,nPValor] == 0)
			If (nTotTit <= nValChq)
				nValAux:= nValChq * ((oGetChq:aCols[nI,nPSaldo]-nValComp)/nValChq)
			Else
				nValAux:= ((oGetChq:aCols[nI,nPSaldo]-nValComp)/nTotTit) * nValChq
				nValAux:= IIf(nValAux > (nValChq - nTotBX),(nValChq - nTotBX),nValAux)
			EndIf
			nSaldo -= nValAux
		Else
			nValAux:= oGetChq:aCols[nI,nPValor]
		EndIf
		
		oGetChq:aCols[nI,nPValor]:= nValAux
	EndIf
Next

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSe existir saldo coloca no ultimo titulo.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If (nSaldo > 0)
	For nPos:= 1 To Len(oGetChq:aCols)
		If !oGetChq:aCols[nPos,Len(oGetChq:aHeader)+1]
			nValComp:= A001ValComp(oGetChq:aCols[nPos,nPPrefixo]+oGetChq:aCols[nPos,nPNum]+oGetChq:aCols[nPos,nPParcela]+oGetChq:aCols[nPos,nPTipo],M->(Z1_BANCO+Z1_AGENCIA+Z1_CONTA+Z1_CHEQUE))
			nDif:= oGetChq:aCols[nPos,nPSaldo]-nValComp-oGetChq:aCols[nPos,nPValor]
			If (nDif > 0)
				If (nSaldo >= nDif)
					oGetChq:aCols[nPos,nPValor]+= nDif
					nSaldo-= nDif
				Else
					oGetChq:aCols[nPos,nPValor]+= nSaldo
					nSaldo:= 0
				EndIf
			EndIf
		EndIf
	Next
EndIf

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA001GrvChqบ Autor ณ AP6 IDE            บ Data ณ  11/04/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Grava as informacoes dos cheques e titulos.                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function A001GRVCHQ(lExclui,lArmazena,lDevolvido)
Local nI        := 0
Local nX        := 0
Local lTit      := .F.
Local lRet      := .T.
Local bCampo 	:= {|n| FieldName(n) }
Local nPNum     := aScan(oGetChq:aHeader,{|x| AllTrim(x[2]) == "Z3_NUM"})
Local nPValor   := aScan(oGetChq:aHeader,{|x| AllTrim(x[2]) == "Z3_VALOR"})
Local cStatus   := ""

Pergunte("EFA001",.F.)

If lArmazena
	If Aviso("Atencao","Confirma o armazenamento deste cheque ?",{"Ok","Cancela"}) == 2
		lRet:= .F.
		Return(lRet)
	EndIf
EndIf

If !lExclui
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Grava arquivo SZ1 (Cheques)                         ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	dbSelectArea("SZ1")
	If INCLUI
		RecLock("SZ1",.T.)
	Else
		RecLock("SZ1",.F.)
	EndIf
	
	For nI := 1 TO FCount()
		If "FILIAL"$Field(nI)
			FieldPut(nI,xFilial("SZ1"))
		Else
			FieldPut(nI,M->&(EVAL(bCampo,nI)))
		EndIf
	Next nI
	
	MsUnlock()
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณApaga os dados dos titulos atuais.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	dbSelectArea("SZ3")
	dbSetOrder(1)
	dbSeek(xFilial("SZ3")+M->Z1_BANCO+M->Z1_AGENCIA+M->Z1_CONTA+M->Z1_CHEQUE,.T.)
	While !Eof() .And. (xFilial("SZ3")+M->Z1_BANCO+M->Z1_AGENCIA+M->Z1_CONTA+M->Z1_CHEQUE ==;
		SZ3->(Z3_FILIAL+Z3_BANCO+Z3_AGENCIA+Z3_CONTA+Z3_CHEQUE))
		RecLock("SZ3",.F.,.T.)
		dbDelete()
		MsUnLock()
		
		dbSelectArea("SZ3")
		dbSkip()
	End
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Grava arquivo SZ3 (CR - Itens)                      ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	For nI:=1 To Len(oGetChq:aCols)
		If !oGetChq:aCols[nI,Len(oGetChq:aHeader)+1] .And. !Empty(oGetChq:aCols[nI,nPNum]) .And. (oGetChq:aCols[nI,nPValor] > 0)
			
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณGrava os dados dos titulos.ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			RecLock("SZ3",.T.)
			Replace Z3_FILIAL  With xFilial("SZ3")
			Replace Z3_BANCO   With M->Z1_BANCO
			Replace Z3_AGENCIA With M->Z1_AGENCIA
			Replace Z3_CONTA   With M->Z1_CONTA
			Replace Z3_CHEQUE  With M->Z1_CHEQUE
			
			For nX := 1 To Len(oGetChq:aHeader)
				If ( oGetChq:aHeader[nX,10] != "V" )
					SZ3->(FieldPut(FieldPos(oGetChq:aHeader[nX,2]),oGetChq:aCols[nI,nX]))
				EndIf
			Next nX
			MsUnLock()
			
			
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณAtualiza informaoes no titulo.ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			dbSelectArea("SE1")
			dbSetOrder(1)
			If dbSeek(xFilial("SE1")+SZ3->(Z3_PREFIXO+Z3_NUM+Z3_PARCELA+Z3_TIPO))
				RecLock("SE1",.F.)
				Replace E1_NUMBCO  With StrZero(Day(SZ1->Z1_VENCTO),2) + "/" + Right(StrZero(Month(SZ1->Z1_VENCTO),4),2) + " " + Alltrim(SZ1->Z1_CHEQUE) + "/" + AllTrim(SZ1->Z1_BANCO)
				Replace E1_PORTADO With PadR(GetMv("MV_EFA01BC"),3)
				Replace E1_AGEDEP  With PadR(GetMv("MV_EFA01AG"),5)
				Replace E1_CONTA   With PadR(GetMv("MV_EFA01CC"),10)
				Replace E1_SITUACA With "4"
				Replace E1_VENCTO  With IIf(SZ3->Z3_VENCREA > SE1->E1_VENCREA,SZ3->Z3_VENCREA,SE1->E1_VENCREA)
				Replace E1_VENCREA With DataValida(SE1->E1_VENCTO)
				MsUnLock()
			EndIf
			              
			lTit:= .T.
		EndIf
	Next nI
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณGrava a movimentacao do cheque.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	RecLock("SZ1",.F.)
	Replace Z1_CRINF  With IIf(lTit,"S","N")
	Replace Z1_CHQDEV With IIf(lDevolvido,"S","N")
	MsUnlock()
	
	If INCLUI
		cStatus:= IIf(Upper(AllTrim(UsrRetName(RetCodUsr())))== "FATURAMENTO","B",M->Z1_STATUS)
		A001GrvMov(cStatus,M->Z1_BANCO,M->Z1_AGENCIA,M->Z1_CONTA,M->Z1_CHEQUE,"")
	EndIf
Else
	If Aviso("Atencao","Confirma a exclusao do cheque ?",{"Ok","Cancela"}) == 1
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณApaga os dados dos titulos atuais.ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		dbSelectArea("SZ3")
		dbSetOrder(1)
		dbSeek(xFilial("SZ3")+M->Z1_BANCO+M->Z1_AGENCIA+M->Z1_CONTA+M->Z1_CHEQUE,.T.)
		While !Eof() .And. (xFilial("SZ3")+M->Z1_BANCO+M->Z1_AGENCIA+M->Z1_CONTA+M->Z1_CHEQUE ==;
			SZ3->(Z3_FILIAL+Z3_BANCO+Z3_AGENCIA+Z3_CONTA+Z3_CHEQUE))

			dbSelectArea("SE1")
			dbSetOrder(1)
			If dbSeek(xFilial("SE1")+SZ3->(Z3_PREFIXO+Z3_NUM+Z3_PARCELA+Z3_TIPO))
				RecLock("SE1",.F.)	
				Replace E1_NUMBCO  With ""
				Replace E1_PORTADO With ""
				Replace E1_AGEDEP  With ""
				Replace E1_CONTA   With ""
				Replace E1_SITUACA With "0"
				MsUnLock()
			EndIf

			RecLock("SZ3",.F.,.T.)
			dbDelete()
			MsUnLock()
			
			dbSelectArea("SZ3")
			dbSkip()
		End
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณExclui o cheque atual.ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		RecLock("SZ1",.F.,.T.)
		dbDelete()
		MsUnLock()
	EndIf
EndIf

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA001GrvMovบ Autor ณ AP6 IDE            บ Data ณ  11/04/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Grava as informacoes dos movimentos de cheques.            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function A001GRVMOV(cTipo,cBanco,cAgencia,cConta,cCheque,cObs)
Local aArea:= GetArea()

DEFAULT cObs   := ""

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณGrava a movimentacao do cheque.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
dbSelectArea("SZ2")
dbSetOrder(1)
RecLock("SZ2",.T.)
Replace Z2_FILIAL  With xFilial("SZ2")
Replace Z2_BANCO   With cBanco
Replace Z2_AGENCIA With cAgencia
Replace Z2_CONTA   With cConta
Replace Z2_CHEQUE  With cCheque
Replace Z2_STATUS  With cTipo
Replace Z2_DATA    With dDatabase
Replace Z2_HORA    With Time()
Replace Z2_USUARIO With UsrRetName(RetCodUsr())
Replace Z2_OBSERVA With cObs
MsUnLock()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAtualiza o ultimo status.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
dbSelectArea("SZ1")
dbSetOrder(1)
If dbSeek(xFilial("SZ1")+cBanco+cAgencia+cConta+cCheque)
	RecLock("SZ1",.F.)
	Replace Z1_STATUS With cTipo
	MsUnLock()
EndIf

RestArea(aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณEFVALBAIXA บ Autor ณ AP6 IDE           บ Data ณ  11/04/04   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Codigo gerado pelo AP6 IDE.                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function EFVALBAIXA(cTipo)
Local nValBaixa:= &(ReadVar())
Local nSaldo   := 0
Local nPSaldo  := 0
Local nPValor  := 0
Local nPValChq := 0
Local nTotBX   := 0
Local nTotTit  := 0
Local nValChq  := 0
Local cMens    := ""
Local lRet     := .T.

If (cTipo == "R")
	nPSaldo := aScan(oGetChq:aHeader,{|x| AllTrim(x[2]) == "Z3_SALDO"})
	nPValor := aScan(oGetChq:aHeader,{|x| AllTrim(x[2]) == "Z3_VALOR"})
	nValChq := M->Z1_VALOR
Else
	nPSaldo := aScan(oGetChq:aHeader,{|x| AllTrim(x[2]) == "Z4_SALDO"})
	nPValor := aScan(oGetChq:aHeader,{|x| AllTrim(x[2]) == "Z4_VALOR"})
	nPValChq:= aScan(oGetChq:aHeader2,{|x| AllTrim(x[2]) == "Z1_VALOR"})
	aEval(oGetChq:aCols,{|x| nValChq+= IIF(!x[Len(oGetChq:aHeader)+1],x[nPValChq],0)})
EndIf

If (nPSaldo > 0) .And. (nPValor > 0)
	aEval(oGetChq:aCols,{|x| nTotBX+= IIF(!x[Len(oGetChq:aHeader)+1],x[nPValor],0)})
	aEval(oGetChq:aCols,{|x| nTotTit+= IIF(!x[Len(oGetChq:aHeader)+1],x[nPSaldo],0)})
	
	nTotBX:= nTotBX - oGetChq:aCols[oGetChq:nAT,nPValor] + nValBaixa
	nSaldo:= oGetChq:aCols[oGetChq:nAT,nPSaldo]
	
	Do Case
		Case (nValBaixa > nValChq)
			cMens:= "O valor da baixa nao pode ser maior que valor do cheque !!!"
			
		Case (nTotBX > nValChq)
			cMens:= "O valor das baixas nao pode ser maior que valor do cheque !!!"
			
		Case (nValBaixa > nTotTit)
			cMens:= "O valor da baixa nao pode ser maior que os saldos dos titulos !!!"
			
		Case (nValBaixa > nSaldo)
			cMens:= "O valor da baixa nao pode ser maior que o saldo em aberto do titulo !!!"
	EndCase
	
	If !(Empty(cMens))
		Aviso("Atencao",cMens,{"Ok"})
		lRet:= .F.
	EndIf
EndIf

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณZ1ZERALVAL บ Autor ณ AP6 IDE           บ Data ณ  11/04/04   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Codigo gerado pelo AP6 IDE.                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function Z1ZERAVAL()
Local nI     := 0
Local nPValor:= aScan(oGetChq:aHeader,{|x| AllTrim(x[2]) == "Z3_VALOR"})

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณZera os valores de baixa para recalcula-los.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If (nPValor > 0)
	For nI:= 1 To Len(oGetChq:aCols)
		oGetChq:aCols[nI,nPValor]:= 0
	Next
EndIf

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณEFDELCHQ  บ Autor ณ AP6 IDE            บ Data ณ  11/04/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Deleta a operacao atual.                                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function EFDELCHQ(cAlias,nReg,nOpc)
Local aArea:= GetArea()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica qual o status atual, desfaz a opera็ใo e volta ao status anterior.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Do Case
	Case SZ1->Z1_STATUS $ "AB"
		U_EFRECEBECHQ(cAlias,nReg,nOpc)
		
	Case SZ1->Z1_STATUS == "C"
		If Aviso("Atencao","Confirma a exclusao do armazenamento de Banco "+SZ1->Z1_BANCO+" Agencia "+SZ1->Z1_AGENCIA+" Conta "+SZ1->Z1_CONTA+" Cheque "+SZ1->Z1_CHEQUE+" ?",{"Ok","Cancela"}) == 1
			A001GrvMov("A",SZ1->Z1_BANCO,SZ1->Z1_AGENCIA,SZ1->Z1_CONTA,SZ1->Z1_CHEQUE,"Exclusao do Armazenamento")
		EndIf
		
	Case SZ1->Z1_STATUS == "D"
		If Aviso("Atencao","Confirma o cancelamento da baixa de Banco "+SZ1->Z1_BANCO+" Agencia "+SZ1->Z1_AGENCIA+" Conta "+SZ1->Z1_CONTA+" Cheque "+SZ1->Z1_CHEQUE+" ?",{"Ok","Cancela"}) == 1
			A001DELBAIXA(SZ1->Z1_BANCO,SZ1->Z1_AGENCIA,SZ1->Z1_CONTA,SZ1->Z1_CHEQUE,.F.,.F.,.F.)
		EndIf
		
	Case SZ1->Z1_STATUS == "E"
		If Aviso("Atencao","Confirma o cancelamento do repasse de Banco "+SZ1->Z1_BANCO+" Agencia "+SZ1->Z1_AGENCIA+" Conta "+SZ1->Z1_CONTA+" Cheque "+SZ1->Z1_CHEQUE+" ?",{"Ok","Cancela"}) == 1
			A001DELREPASSE(SZ1->Z1_BANCO,SZ1->Z1_AGENCIA,SZ1->Z1_CONTA,SZ1->Z1_CHEQUE,.F.,.F.)
		EndIf
		
	Case SZ1->Z1_STATUS == "F"
		If Aviso("Atencao","Confirma o cancelamento da devolucao de Banco "+SZ1->Z1_BANCO+" Agencia "+SZ1->Z1_AGENCIA+" Conta "+SZ1->Z1_CONTA+" Cheque "+SZ1->Z1_CHEQUE+" ?",{"Ok","Cancela"}) == 1
			A001DELDEVOLUCAO(SZ1->Z1_BANCO,SZ1->Z1_AGENCIA,SZ1->Z1_CONTA,SZ1->Z1_CHEQUE)
		EndIf
		
	Case SZ1->Z1_STATUS == "G"
		If Aviso("Atencao","Confirma a exclusao da quitacao de Banco "+SZ1->Z1_BANCO+" Agencia "+SZ1->Z1_AGENCIA+" Conta "+SZ1->Z1_CONTA+" Cheque "+SZ1->Z1_CHEQUE+" ?",{"Ok","Cancela"}) == 1
//			A001DELBAIXA(SZ1->Z1_BANCO,SZ1->Z1_AGENCIA,SZ1->Z1_CONTA,SZ1->Z1_CHEQUE,.F.,.T.,.F.)
			A001GrvMov("F",SZ1->Z1_BANCO,SZ1->Z1_AGENCIA,SZ1->Z1_CONTA,SZ1->Z1_CHEQUE,"Exclusao da Quitacao")
		EndIf
		
	Case SZ1->Z1_STATUS == "H"
		If Aviso("Atencao","Confirma a exclusao do pagamento de Banco "+SZ1->Z1_BANCO+" Agencia "+SZ1->Z1_AGENCIA+" Conta "+SZ1->Z1_CONTA+" Cheque "+SZ1->Z1_CHEQUE+" ?",{"Ok","Cancela"}) == 1
			A001DELREPASSE(SZ1->Z1_BANCO,SZ1->Z1_AGENCIA,SZ1->Z1_CONTA,SZ1->Z1_CHEQUE,.T.,.F.)
		EndIf
EndCase

SetKey(VK_F4 ,{|| U_EFLEGENDA()})
RestArea(aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณEFARMAZENACHQบ Autor ณ AP6 IDE          บ Data ณ  11/04/04  บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricao ณ Confirma o armazenamento dos cheques.                      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function EFARMAZENACHQ(cAlias,nReg,nOpc)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSo Armazena os cheques recebidos. ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If SZ1->Z1_STATUS $ "AB"
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณExibe os dados do cheque para eventual alteracao e verificaณ
	//ณse foi confirmado o armazenamento do cheque.               ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	ALTERA:= .T.
	If U_EFRECEBECHQ(cAlias,nReg,nOpc)
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณGrava movimento do cheque.                                       ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		A001GrvMov("C",SZ1->Z1_BANCO,SZ1->Z1_AGENCIA,SZ1->Z1_CONTA,SZ1->Z1_CHEQUE,"")
		
	EndIf
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณEFALTERACHQ  บ Autor ณ AP6 IDE          บ Data ณ  11/04/04  บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricao ณ Executa a alteracao dos dados do cheque.                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function EFALTERACHQ(cAlias,nReg,nOpc)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSo Altera os cheques recebidos.   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If SZ1->Z1_STATUS $ "AB"
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณExibe os dados do cheque para eventual alteracao e verificaณ
	//ณse foi confirmado o armazenamento do cheque.               ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	U_EFRECEBECHQ(cAlias,nReg,nOpc)
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณEFBAIXACHQบ Autor ณ AP6 IDE            บ Data ณ  11/04/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Baixa o cheque e os titulos associados.                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function EFBAIXACHQ(cAlias,nReg,nOpc)
Local oDlg
Local oFont
Local oTitulo
Local oFolderChq
Local oFolderCR
Local oTotal
Local oBaixa
Local nTitulo   := 0
Local nOpcA     := 0
Local nI        := 0
Local nX        := 0
Local nPBanco   := 0
Local nPAgencia := 0
Local nPConta   := 0
Local nPCheque  := 0
Local nPVencto  := 0
Local nPValor   := 0
Local nPSacado  := 0
Local nGd1		:= 0
Local nGd2 		:= 0
Local nGd3 		:= 0
Local nGd4 		:= 0
Local nTotal    := 0
Local aCheques  := {}
Local aTitulos  := {}
Local aSize     := {}
Local aObjects  := {}
Local aInfo     := {}
Local aPosObj   := {}
Local cTotal    := "Valor Selecionado: " + GetMV("MV_SIMB1") + " 0,00"
Local cBaixa    := "Valor de Baixas: " + GetMV("MV_SIMB1") + " 0,00"
Private cTipo   := "D" //Variavel para controle de filtro no SXB
Private aTELA[0][0],aGETS[0],aHeader[0],aCols[0]
Private REPASSA := .T.
Private oGetChq


Pergunte("EFA001",.F.)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSeleciona os cheques para baixa.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !A001SelChq(@aCheques)
	Return(.F.)
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCria o acols em branco.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
EF001ACols("SZ1","Z1_FILIAL/Z1_COMP/Z1_SERIE/Z1_CNPJ/Z1_RG/Z1_MESCONT/Z1_ANOCONT/Z1_STATUS/Z1_EMISSAO/Z1_TELEFON/Z1_STATUS/Z1_DESCSTA/Z1_CRINF/Z1_CHQDEV",.T.)
nPBanco  := aScan(aHeader,{|x| AllTrim(x[2]) == "Z1_BANCO"})
nPAgencia:= aScan(aHeader,{|x| AllTrim(x[2]) == "Z1_AGENCIA"})
nPConta  := aScan(aHeader,{|x| AllTrim(x[2]) == "Z1_CONTA"})
nPCheque := aScan(aHeader,{|x| AllTrim(x[2]) == "Z1_CHEQUE"})
nPVencto := aScan(aHeader,{|x| AllTrim(x[2]) == "Z1_VENCTO"})
nPValor  := aScan(aHeader,{|x| AllTrim(x[2]) == "Z1_VALOR"})
nPSacado := aScan(aHeader,{|x| AllTrim(x[2]) == "Z1_SACADO"})

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAtualiza o acols com os cheques selecionados.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
For nI:= 1 To Len(aCheques)
	If aCheques[nI,1]
		If (nI > 1) .And. !Empty(aCols[Len(aCols),1])
			aAdd(aCols,Array(Len(aHeader)+1))
			For nX := 1 To Len(aHeader)
				aCols[Len(aCols),nX] := CriaVar(aHeader[nX,2],IIf(aHeader[nX,10] == "V",.T.,.F.))
			Next nX
			aCols[Len(aCols),Len(aHeader)+1] := .F.
		EndIf
		
		aCols[Len(aCols),nPBanco]  := aCheques[nI,2]
		aCols[Len(aCols),nPAgencia]:= aCheques[nI,3]
		aCols[Len(aCols),nPConta]  := aCheques[nI,4]
		aCols[Len(aCols),nPCheque] := aCheques[nI,5]
		aCols[Len(aCols),nPVencto] := aCheques[nI,6]
		aCols[Len(aCols),nPValor]  := aCheques[nI,7]
		aCols[Len(aCols),nPSacado] := aCheques[nI,8]
	EndIf
Next

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Faz o calculo automatico de dimensoes de objetos Folder    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aSize := MsAdvSize(,.F.,370)
aObjects := {}

aAdd( aObjects, { 100, 100, .T., .T. } )
aAdd( aObjects, { 100, 100, .T., .T. } )

aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects, .T. )

SetKey(VK_F4,{|| EFLeCMC7("SZ1","G",@oGetChq)})

DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL

DEFINE FONT oFont  NAME "Arial" SIZE 10,15 BOLD

oFolderChq := TFolder():New(aPosObj[1,1], aPosObj[1,2],{"Cheques a Baixar"} , {""},oDlg,,,,.T.,.F.,aPosObj[1,4]-aPosObj[1,2], aPosObj[1,3]-aPosObj[1,1])
oFolderCR  := TFolder():New(aPosObj[2,1], aPosObj[2,2],{"Duplicatas a Receber"}, {""},oDlg,,,,.T.,.F.,aPosObj[2,4]-aPosObj[2,2], aPosObj[2,3]-aPosObj[2,1]-20)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define as posicoes da Getdados a partir do folder    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nGd1 := 2
nGd2 := 2
nGd3 := aPosObj[1,3]-aPosObj[1,1]-15
nGd4 := aPosObj[1,4]-aPosObj[1,2]-4

oGetChq:= MsNewGetDados():New(nGd1,nGd2,nGd3-5,nGd4,3,"U_A001BXLINOK(oGetChq:nAT,'C')","U_A001BXTUDOK(oGetChq:nAT,'C')",/*inicpos*/,Nil,/*freeze*/,MAXGETDAD,/*fieldok*/,/*superdel*/,/*delok*/,oFolderChq:aDialogs[1],@aHeader,@aCols)
oGetChq:lDelete:= .T.
oGetChq:oBrowse:bChange:={ || A001Titulos("SZ3",oGetChq:aCols[oGetChq:nAT,nPBanco]+oGetChq:aCols[oGetChq:nAT,nPAgencia]+oGetChq:aCols[oGetChq:nAT,nPConta]+oGetChq:aCols[oGetChq:nAT,nPCheque],@aTitulos,@oTitulo,@cTotal,@oTotal,@cBaixa,@oBaixa,oGetChq)}

nGd1 := 2
nGd2 := 2
nGd3 := aPosObj[2,3]-aPosObj[2,1]-35
nGd4 := aPosObj[2,4]-aPosObj[2,2]-4
@nGd1,nGd2 LISTBOX oTitulo VAR nTitulo FIELDS HEADER "Prefixo","Numero","Parcela","Tipo","Valor Baixa";
SIZE nGd4,nGd3 OF oFolderCR:aDialogs[1] PIXEL

aEval(oGetChq:aCols,{|x| nTotal+= IIF(!x[Len(oGetChq:aHeader)+1],x[nPValor],0)})
cTotal:= "Valor Selecionado: " + GetMV("MV_SIMB1") + AllTrim(Transform(nTotal,PesqPict("SZ1","Z1_VALOR")))
@aPosObj[2,3]-10,aPosObj[2,2]  SAY oTotal VAR cTotal FONT oFont COLOR CLR_HBLUE SIZE 200,15  OF oDlg PIXEL

@aPosObj[2,3]-10,aPosObj[2,2]+200 SAY oBaixa VAR cBaixa FONT oFont COLOR CLR_HRED SIZE 200,15  OF oDlg PIXEL

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAtualiza o array com os titulos do 1 cheque.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
A001Titulos("SZ3",oGetChq:aCols[1,nPBanco]+oGetChq:aCols[1,nPAgencia]+oGetChq:aCols[1,nPConta]+oGetChq:aCols[1,nPCheque],@aTitulos,@oTitulo,@cTotal,@oTotal,@cBaixa,@oBaixa,oGetChq)
oTitulo:SetArray(aTitulos)
oTitulo:bLine:={|| {	aTitulos[oTitulo:nAt,1],;
aTitulos[oTitulo:nAt,2],;
aTitulos[oTitulo:nAt,3],;
aTitulos[oTitulo:nAt,4],;
Transform(aTitulos[oTitulo:nAt,5],PesqPict("SZ3","Z3_VALOR"))}}
oTitulo:Refresh()


ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||IIF(oGetChq:TudoOk(),(nOpcA:=1,oDlg:End()),"")},{||oDlg:End()})

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณExecuta a gravacao da baixa dos titulos.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
lBxTit  := GetMv("MV_EFA01BX")
cBanco  := PadR(GetMv("MV_EFA01BC"),3)
cAgencia:= PadR(GetMv("MV_EFA01AG"),5)
cConta  := PadR(GetMv("MV_EFA01CC"),10)

If (nOpcA == 1)
	Processa({||A001GrvBaixa(lBxTit,cBanco,cAgencia,cConta)},"Executando Baixa dos Cheques...")
EndIf

SetKey(VK_F4 ,{|| U_EFLEGENDA()})
SetKey(VK_F12,{|| Pergunte("EFA01A",.T.)})

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA001SELCHQบ Autor ณ AP6 IDE            บ Data ณ  11/04/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Seleciona cheques para baixa.                              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function A001SELCHQ(aCheques)
Local oDlg
Local oCheques
Local oFont
Local oFolder
Local oTotal
Local cTotal    := ""
Local nOpca     := 0
Local nLbx      := 0
Local nTotal    := 0
Local nGd1		:= 0
Local nGd2 		:= 0
Local nGd3 		:= 0
Local nGd4 		:= 0
Local oOk       := LoaDbitmap( GetResources(), "LBOK" )
Local oNo       := LoaDbitmap( GetResources(), "LBNO" )
Local aSize     := {}
Local aObjects  := {}
Local aInfo     := {}
Local aPosObj   := {}
Local lRet      := .F.
Private aChq
Private oLbx


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณExibe os parametros para a selecao dos cheques para baixa.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !Pergunte("EFA001",.T.)
	Return(.F.)
EndIf

SetKey(VK_F4,{|| (aChq:= aClone(aCheques), EFLeCMC7("SZ1","L"))})

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSeleciona os cheques conforme os parametros informados.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
dbSelectArea("SZ1")
dbSetOrder(1)
dbSeek(xFilial("SZ1")+Mv_Par01,.T.)
While !Eof() .And. (SZ1->Z1_FILIAL == xFilial("SZ1")) .And. (SZ1->Z1_BANCO <= Mv_Par02)
	If (SZ1->Z1_VENCTO < Mv_Par03) .Or. (SZ1->Z1_VENCTO > Mv_Par04) .Or. (SZ1->Z1_STATUS <> "C")
		dbSelectArea("SZ1")
		dbSkip()
		Loop
	EndIf
	
	aAdd(aCheques,{IIf(Mv_Par05 == 1,.T.,.F.),SZ1->Z1_BANCO,SZ1->Z1_AGENCIA,SZ1->Z1_CONTA,SZ1->Z1_CHEQUE,SZ1->Z1_VENCTO,SZ1->Z1_VALOR,SZ1->Z1_SACADO,SZ1->Z1_TELEFON})
	nTotal+= IIf(Mv_Par05 == 1,SZ1->Z1_VALOR,0)
	
	dbSelectArea("SZ1")
	dbSkip()
End

If (Len(aCheques) == 0)
	Aadd(aCheques,{.F.,"","","","",dDatabase,0,"",""})
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Faz o calculo automatico de dimensoes de objetos     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aSize := MsAdvSize(,.F.,370)
aObjects := {}

AAdd( aObjects, { 100, 100, .T., .T. } )

aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects )

DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL
DEFINE FONT oFont  NAME "Arial" SIZE 10,15 BOLD


oFolder:= TFolder():New(aPosObj[1,1], aPosObj[1,2],{"Selecao de Cheques"}, {""},oDlg,,,,.T.,.F.,aPosObj[1,4]-aPosObj[1,2], aPosObj[1,3]-aPosObj[1,1]-20)

nGd1 := 2
nGd2 := 2
nGd3 := aPosObj[1,3]-aPosObj[1,1]-35
nGd4 := aPosObj[1,4]-aPosObj[1,2]-4

@nGd1,nGd2 LISTBOX oLbx VAR nLbx FIELDS HEADER "","Banco","Agencia","Conta","Cheque","Vencimento","Valor","Sacado","Telefone" SIZE nGd4,nGd3;
ON DBLCLICK A001MarcaChq(@nTotal,@cTotal,@oTotal,@oLbx,@aCheques);
NOSCROLL OF oFolder:aDialogs[1] PIXEL

oLbx:SetArray(aCheques)
oLbx:bLine:={|| {IIf(	aCheques[oLbx:nAt,1],oOk,oNo),;
aCheques[oLbx:nAt,2],;
aCheques[oLbx:nAt,3],;
aCheques[oLbx:nAt,4],;
aCheques[oLbx:nAt,5],;
Dtoc(aCheques[oLbx:nAt,6]),;
Transform(aCheques[oLbx:nAt,7],PesqPict("SZ1","Z1_VALOR")),;
aCheques[oLbx:nAt,8],;
aCheques[oLbx:nAt,9]}}
oLbx:Refresh()

cTotal:= "Valor Selecionado: " + GetMV("MV_SIMB1") + AllTrim(Transform(nTotal,PesqPict("SZ1","Z1_VALOR")))
@aPosObj[1,3]-15,aPosObj[1,2]  SAY oTotal VAR cTotal FONT oFont COLOR CLR_HBLUE SIZE 200,15  OF oDlg PIXEL

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=1, oDlg:End()},{||oDlg:End()})

lRet:= IIf(nOpca == 1,.T.,.F.)

SetKey(VK_F4 ,{|| U_EFLEGENDA()})

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA001MARCACHQบ Autor ณ AP6 IDE          บ Data ณ  11/04/04   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Marca o cheque selecionado.                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function A001MarcaChq(nTotal,cTotal,oTotal,oLbx,aCheques)

aCheques[oLbx:nAt,1]:= !aCheques[oLbx:nAt,1]

nTotal:= 0
aEval(aCheques,{|x| nTotal+= IIF(x[1],x[7],0)})

cTotal:= "Valor Selecionado: " + GetMV("MV_SIMB1") + " " + AllTrim(Transform(nTotal,PesqPict("SZ1","Z1_VALOR")))
oTotal:Refresh()
oLbx:Refresh()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA001TITULOS บ Autor ณ AP6 IDE          บ Data ณ  11/04/04   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Retorna os titulos do cheque.                              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function A001TITULOS(cAlias,cCheque,aTitulos,oTitulo,cTotal,oTotal,cBaixa,oBaixa,oObj)
Local nBaixa:= 0

aTitulos:= {}

If (cAlias == "SZ3")
	dbSelectArea(cAlias)
	dbSetOrder(1)
	dbSeek(xFilial(cAlias)+cCheque)
	While !Eof() .And. (xFilial("SZ3")+cCheque == SZ3->(Z3_FILIAL+Z3_BANCO+Z3_AGENCIA+Z3_CONTA+Z3_CHEQUE))
		aAdd(aTitulos,{SZ3->Z3_PREFIXO,SZ3->Z3_NUM,SZ3->Z3_PARCELA,SZ3->Z3_TIPO,SZ3->Z3_VALOR})
		nBaixa+= SZ3->Z3_VALOR
		dbSkip()
	End
EndIf

If (Len(aTitulos) == 0)
	aAdd(aTitulos,{"","","","",0.00})
EndIf

A001CalcTotal(@cTotal,@oTotal,"Titulos","Z4_SALDO",oObj)

oTitulo:SetArray(aTitulos)
oTitulo:bLine:={|| {	aTitulos[oTitulo:nAt,1],;
aTitulos[oTitulo:nAt,2],;
aTitulos[oTitulo:nAt,3],;
aTitulos[oTitulo:nAt,4],;
Transform(aTitulos[oTitulo:nAt,5],PesqPict("SZ3","Z3_VALOR"))}}
oTitulo:Refresh()

cBaixa:= "Valor de Baixas: " + GetMV("MV_SIMB1") + " " + AllTrim(Transform(nBaixa,PesqPict("SZ3","Z3_VALOR")))
oBaixa:Refresh()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA001BXLINOKบ Autor ณ AP6 IDE           บ Data ณ  11/04/04   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Valida a linha dos cheques.                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function A001BXLINOK(nItem,cStatus)
Local aArea    := GetArea()
Local lRet     := .T.
Local nPBanco  := aScan(oGetChq:aHeader,{|x| AllTrim(x[2]) == "Z1_BANCO"})
Local nPAgencia:= aScan(oGetChq:aHeader,{|x| AllTrim(x[2]) == "Z1_AGENCIA"})
Local nPConta  := aScan(oGetChq:aHeader,{|x| AllTrim(x[2]) == "Z1_CONTA"})
Local nPCheque := aScan(oGetChq:aHeader,{|x| AllTrim(x[2]) == "Z1_CHEQUE"})
Local nPValor  := aScan(oGetChq:aHeader,{|x| AllTrim(x[2]) == "Z1_VALOR"})
Local nPVencto := aScan(oGetChq:aHeader,{|x| AllTrim(x[2]) == "Z1_VENCTO"})
Local nI       := 0
Local nCount   := 0

DEFAULT nItem:= n

If !oGetChq:aCols[nItem,Len(oGetChq:aHeader)+1]
	
	If (Empty(oGetChq:aCols[nItem,nPBanco]) .Or. Empty(oGetChq:aCols[nItem,nPAgencia]) .Or. Empty(oGetChq:aCols[nItem,nPConta]) .Or.;
		Empty(oGetChq:aCols[nItem,nPCheque]).Or. Empty(oGetChq:aCols[nItem,nPValor]).Or. Empty(oGetChq:aCols[nItem,nPVencto]))
		Aviso("Atencao","Existem campos que nao foram informados !!!",{"Ok"})
		lRet:= .F.
	Else
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณVerifica se o cheque foi colocado mais de uma vez.ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		nCount:= 0
		For nI:= 1 To Len(oGetChq:aCols)
			If !oGetChq:aCols[nI,Len(oGetChq:aHeader)+1]
				If oGetChq:aCols[nI,nPBanco]+oGetChq:aCols[nI,nPAgencia]+oGetChq:aCols[nI,nPConta]+oGetChq:aCols[nI,nPCheque] == ;
					oGetChq:aCols[nItem,nPBanco]+oGetChq:aCols[nItem,nPAgencia]+oGetChq:aCols[nItem,nPConta]+oGetChq:aCols[nItem,nPCheque] .And. !oGetChq:aCols[nI,Len(oGetChq:aHeader)+1]
					nCount++
				EndIf
			EndIf
		Next nI
		
		If (nCount > 1)
			Aviso("Atencao","O cheque nao pode ser informado mais de uma vez !!!",{"Ok"})
			lRet:= .F.
		Else
			dbSelectArea("SZ1")
			dbSetOrder(1)
			If dbSeek(xFilial("SZ1")+oGetChq:aCols[nItem,nPBanco]+oGetChq:aCols[nItem,nPAgencia]+oGetChq:aCols[nItem,nPConta]+oGetChq:aCols[nItem,nPCheque])
				If (SZ1->Z1_STATUS <> cStatus)
					Aviso("Atencao","O cheque nao esta liberado para esta operacao !!!",{"Ok"})
					lRet:= .F.
				EndIf
			Else
				Aviso("Atencao","O cheque informado nao existe !!!",{"Ok"})
				lRet:= .F.
			EndIf
		EndIf
	EndIf
EndIf

RestArea(aArea)
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA001BXTUDOKบ Autor ณ AP6 IDE           บ Data ณ  11/04/04   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Valida todas as linhas dos cheques.                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function A001BXTUDOK(nItem,cStatus)
Local nI  := 0
Local lRet:= .T.

For nI:= 1 To Len(oGetChq:aCols)
	If !oGetChq:aCols[nI,Len(oGetChq:aHeader)+1] .And. !U_A001BXLINOK(nI,cStatus)
		lRet:= .F.
		Exit
	EndIf
Next
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณEFFILTCHQ บ Autor ณ AP6 IDE            บ Data ณ  11/04/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Realiza filtro dos cheques nos F3.                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function EFFILTCHQ()
Local lRet   := .F.

If (Type("cTipo") == "U")
	cTipo:= ""
EndIf

If (cTipo == "D")
	lRet:= SZ1->Z1_STATUS == "C"
ElseIf (cTipo == "E")
	lRet:= SZ1->Z1_STATUS == "D"
EndIf

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA001GrvBaixaบ Autor ณ AP6 IDE          บ Data ณ  11/04/04   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Grava a baixa do cheque e dos titulos associados.          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function A001GRVBAIXA(lBxTit,cBcoDep,cAgDep,cCCDep)
Local nI           := 0
Local nPBanco      := aScan(oGetChq:aHeader,{|x| AllTrim(x[2]) == "Z1_BANCO"})
Local nPAgencia    := aScan(oGetChq:aHeader,{|x| AllTrim(x[2]) == "Z1_AGENCIA"})
Local nPConta      := aScan(oGetChq:aHeader,{|x| AllTrim(x[2]) == "Z1_CONTA"})
Local nPCheque     := aScan(oGetChq:aHeader,{|x| AllTrim(x[2]) == "Z1_CHEQUE"})
Local aBaixa       := {}

If lBxTit
	For nI:= 1 To Len(oGetChq:aCols)
		If !oGetChq:aCols[nI,Len(oGetChq:aHeader)+1]
			dbSelectArea("SZ3")
			dbSetOrder(1)
			dbSeek(xFilial("SZ3")+oGetChq:aCols[nI,nPBanco]+oGetChq:aCols[nI,nPAgencia]+oGetChq:aCols[nI,nPConta]+oGetChq:aCols[nI,nPCheque])
			While !Eof() .And. (xFilial("SZ3")+oGetChq:aCols[nI,nPBanco]+oGetChq:aCols[nI,nPAgencia]+oGetChq:aCols[nI,nPConta]+oGetChq:aCols[nI,nPCheque] == ;
				SZ3->(Z3_FILIAL+Z3_BANCO+Z3_AGENCIA+Z3_CONTA+Z3_CHEQUE))
				
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณVerifica se o titulo ja esta baixado.ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				If !Empty(SZ3->Z3_BAIXA)
					dbSelectArea("SZ3")
					dbSkip()
					Loop
				EndIf
				
				dbSelectArea("SE1")
				dbSetOrder(1)
				dbSeek(xFilial("SE1")+SZ3->Z3_PREFIXO+SZ3->Z3_NUM+SZ3->Z3_PARCELA+SZ3->Z3_TIPO)
				
				nPos:= aScan(aBaixa,{|x| x[1] == SZ3->(Z3_PREFIXO+Z3_NUM+Z3_PARCELA+Z3_TIPO+Z3_CLIENTE+Z3_LOJA)})
				If (nPos == 0)
					aAdd(aBaixa,{SZ3->(Z3_PREFIXO+Z3_NUM+Z3_PARCELA+Z3_TIPO+Z3_CLIENTE+Z3_LOJA),SE1->E1_ACRESC,SE1->E1_DECRESC,{{SZ3->Z3_BANCO,SZ3->Z3_AGENCIA,SZ3->Z3_CONTA,SZ3->Z3_CHEQUE,SZ3->Z3_VALOR,0}}})
				Else
					nBx:= aScan(aBaixa[nPos,4],{|x| x[1]+x[2]+x[3]+x[4] == SZ3->(Z3_BANCO+Z3_AGENCIA+Z3_CONTA+Z3_CHEQUE)})
					If (nBx == 0)
						aAdd(aBaixa[nPos,4],{SZ3->Z3_BANCO,SZ3->Z3_AGENCIA,SZ3->Z3_CONTA,SZ3->Z3_CHEQUE,SZ3->Z3_VALOR,0})
					EndIf
				EndIf
				
				dbSelectArea("SZ3")
				dbSkip()
			End
		EndIf
	Next nI
	
	A001CRBaixa(aBaixa,cBcoDep,cAgDep,cCCDep,"")
Else
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณAtualiza o status do cheque.ณ
	//ณBaixa apenas o cheque.      ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	For nI:= 1 To Len(oGetChq:aCols)
		If !oGetChq:aCols[nI,Len(oGetChq:aHeader)+1]
			A001GrvMov("D",oGetChq:aCols[nI,nPBanco],oGetChq:aCols[nI,nPAgencia],oGetChq:aCols[nI,nPConta],oGetChq:aCols[nI,nPCheque],"")
		EndIf
	Next
EndIf

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA001DELBAIXAบ Autor ณ AP6 IDE          บ Data ณ  11/04/04   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Deleta a baixa dos titulos.                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function A001DELBAIXA(cBanco,cAgencia,cConta,cCheque,lPortador,lExcRec,lDevolucao)
Local lRet   := .F.
Local lBxTit := .F.
Local cBcoDep:= ""
Local cAgDep := ""
Local cCCDep := ""
Local cChave := ""

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณExecuta a pergunte do EFA01B para saber se deve baixar   ณ
//ณos titulos.                                              ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Pergunte("EFA001",.F.)
lBxTit := GetMv("MV_EFA01BX")
cBcoDep:= PadR(GetMv("MV_EFA01BC"),3)
cAgDep := PadR(GetMv("MV_EFA01AG"),5)
cCCDep := PadR(GetMv("MV_EFA01CC"),10)

If lBxTit
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCancela a baixa dos titulos associados ao cheque.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	dbSelectArea("SZ3")
	dbSetOrder(1)
	dbSeek(xFilial("SZ3")+cBanco+cAgencia+cConta+cCheque,.T.)
	While !Eof() .And. (xFilial("SZ3")+cBanco+cAgencia+cConta+cCheque == SZ3->(Z3_FILIAL+Z3_BANCO+Z3_AGENCIA+Z3_CONTA+Z3_CHEQUE))
		
		If !Empty(SZ3->Z3_BAIXA) .Or. (!Empty(SZ3->Z3_DTPAG) .And. lExcRec)
			cChave:= IIf(lExcRec,SZ3->(Dtos(Z3_DTPAG)+Z3_BCOPAG+Z3_AGPAG+Z3_CONTPAG+Z3_CHQPAG),Dtos(SZ3->Z3_BAIXA)+cBcoDep+cAgDep+cCCDep+cCheque)
			
			If A001CanCR(SZ3->(Z3_PREFIXO+Z3_NUM+Z3_PARCELA+Z3_TIPO),cChave,lPortador,IIf(lExcRec,SZ3->Z3_VALPAG,SZ3->Z3_VALOR),SZ3->Z3_SEQUENC,lDevolucao)
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณLimpa a baixa do titulo.ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				RecLock("SZ3",.F.)
				If lExcRec
					Replace Z3_DTPAG   With Ctod("")
					Replace Z3_VALPAG  With 0
					Replace Z3_BCOPAG  With ""
					Replace Z3_AGPAG   With ""
					Replace Z3_CONTPAG With ""
					Replace Z3_CHQPAG  With ""
				Else
					Replace Z3_BAIXA  With Ctod("")
					Replace Z3_DTCANC With dDatabase
				EndIf
				
				lRet:= .T.
			Else
				Aviso("Atencao","A baixa nao foi encontrada. Verifique se nao foi realizado cancelamento manual !!!"+;
				Chr(10)+Chr(13)+"Cheque:"+cBanco+"-"+cAgencia+"-"+cConta+"-"+cCheque,{"Ok"})
			EndIf
		EndIf
		
		dbSelectArea("SZ3")
		dbSkip()
	End
	
	If lRet
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณRegistra os movimentos do cheque      ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If lExcRec
			A001GrvMov("F",cBanco,cAgencia,cConta,cCheque,"Cancelamento de Quitacao")
		Else
			A001GrvMov("C",cBanco,cAgencia,cConta,cCheque,"Cancelamento da Baixa")
		EndIf
	EndIf
Else
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณRegistra os movimentos do cheque      ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If lExcRec
		A001GrvMov("F",cBanco,cAgencia,cConta,cCheque,"Cancelamento de Quitacao")
	Else
		A001GrvMov("C",cBanco,cAgencia,cConta,cCheque,"Cancelamento da Baixa")
	EndIf
	
	lRet:= .T.
EndIf


Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณEFREPASSACHQบ Autor ณ AP6 IDE          บ Data ณ  11/04/04   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Codigo gerado pelo AP6 IDE.                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function EFREPASSACHQ(cAlias,nReg,nOpc)
Local oDlg
Local oFont
Local oTitulo
Local oFolder
Local nTitulo   := 0
Local nOpcA     := 0
Local nI        := 0
Local nX        := 0
Local nPBanco   := 0
Local nPAgencia := 0
Local nPConta   := 0
Local nPCheque  := 0
Local nPVencto  := 0
Local nPValor   := 0
Local nPSacado  := 0
Local nGd1		:= 0
Local nGd2 		:= 0
Local nGd3 		:= 0
Local nGd4 		:= 0
Local aCheques  := {}
Local aTitulos  := {}
Local aSize     := {}
Local aObjects  := {}
Local aInfo     := {}
Local aPosObj   := {}
Local oTotChq
Local oTotTit
Local oTotBaixa
Local cTotTit    := "Titulos " + GetMV("MV_SIMB1") + " 0,00"
Local cTotChq    := "Cheques " + GetMV("MV_SIMB1") + " 0,00"
Local cTotBaixa  := "Baixas  " + GetMV("MV_SIMB1") + " 0,00"
Local cRepasse   := GetSxeNum("SZ4","Z4_REPASSE")
Local oFornece
Local oLoja            
Private cFornece := CriaVar("F1_FORNECE")
Private cLoja    := CriaVar("F1_LOJA")
Private cSayForn := CriaVar("A2_NOME")
Private cTipo    := "E" //Variavel para controle de filtro no SXB
Private aHeader1 := {}
Private aCols1   := {}
Private aHeader2 := {}
Private aCols2   := {}
Private aHeader3 := {}
Private aCols3   := {}
Private nGetAtu  := 1
Private aTELA[0][0],aGETS[0],aHeader[0],aCols[0]
Private REPASSA  := .T.
Private oGetChq
Private oGetTit

SetKey(VK_F4,{|| EFLeCMC7("SZ1","G",@oGetChq)})

Pergunte("EFA001",.F.)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Faz o calculo automatico de dimensoes de objetos Folder    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aSize := MsAdvSize(,.F.,370)
aObjects := {}

aAdd( aObjects, { 100, 030, .T., .F. } )
aAdd( aObjects, { 100, 060, .T., .T. } )
aAdd( aObjects, { 100, 010, .T., .F. } )

aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects, .T. )


DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL

DEFINE FONT oFont  NAME "Arial" SIZE 10,15 BOLD

@aPosObj[1,1],aPosObj[1,2] TO aPosObj[1,3],aPosObj[1,4] LABEL "" OF oDlg PIXEL 
@aPosObj[1,1]+5,aPosObj[1,2]+5    SAY   "Documento: "+cRepasse OF oDlg PIXEL FONT oFont COLOR CLR_HRED
@aPosObj[1,1]+15,aPosObj[1,2]+5   SAY   "Fornecedor" OF oDlg PIXEL
@aPosObj[1,1]+15,aPosObj[1,2]+40  MSGET oFornece VAR cFornece  PICTURE PesqPict("SA2","A2_COD") F3 CpoRetF3("F1_FORNECE") VALID A001ValFor() OF oDlg PIXEL SIZE 41 ,9
//@aPosObj[1,1]+15,aPosObj[1,2]+90  SAY   "Loja" OF oDlg PIXEL
//@aPosObj[1,1]+15,aPosObj[1,2]+110 MSGET oLoja VAR cLoja  OF oDlg PIXEL SIZE 15 ,9
@aPosObj[1,1]+15,aPosObj[1,2]+140 SAY   cSayForn OF oDlg PIXEL

oFolder := TFolder():New(aPosObj[2,1], aPosObj[2,2],{"Duplicatas a Pagar","Cheques a Repassar"}, {"",""},oDlg,,,,.T.,.F.,aPosObj[2,4]-aPosObj[2,2], aPosObj[2,3]-aPosObj[2,1])

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define as posicoes da Getdados a partir do folder    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nGd1 := 2
nGd2 := 2
nGd3 := aPosObj[2,3]-aPosObj[2,1]-10
nGd4 := aPosObj[2,4]-aPosObj[2,2]-4

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCarrega o acols do SZ4     ณ
//ณNao aparece em Getdados eh ณ
//ณtratado escondido          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aHeader := {}
aCols   := {}
EF001ACOLS("SZ4","*",.T.)
aHeader3:= aClone(aHeader)
aCols3  := aClone(aCols)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCarrega o acols dos titulosณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aHeader := {}
aCols   := {}
EF001ACOLS("SZ4","Z4_PREFIXO/Z4_NUM/Z4_PARCELA/Z4_TIPO/Z4_FORNECE/Z4_LOJA/Z4_VENCREA/Z4_SALDO/Z4_VALTIT/Z4_VALOR",.T.)
aHeader1:= aClone(aHeader)
aCols1  := aClone(aCols)

oGetTit:= MsNewGetDados():New(nGd1,nGd2,nGd3-5,nGd4,3,"U_A001RPLINOK(n)","U_A001RPTUDOK",/*inicpos*/,Nil,/*freeze*/,MAXGETDAD,/*fieldok*/,/*superdel*/,/*delok*/,oFolder:aDialogs[1],@aHeader1,@aCols1)
oGetTit:oBrowse:bChange:={ || A001CalcTotal(@cTotTit,@oTotTit,"Titulos","Z4_SALDO",oGetTit)}
oGetTit:lDelete:= .T.

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณTotal dos Titulos Selecionados.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
@aPosObj[3,1],aPosObj[3,2] SAY oTotTit   VAR cTotTit   FONT oFont COLOR CLR_HGREEN SIZE 200,15 OF oDlg PIXEL

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณTotal dos Cheques Selecionados.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
@aPosObj[3,1],aPosObj[3,2]+200 SAY oTotChq VAR cTotChq FONT oFont COLOR CLR_HBLUE SIZE 200,15 OF oDlg PIXEL

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCarrega o acols do cheque.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aHeader := {}
aCols   := {}
EF001ACols("SZ1","Z1_FILIAL/Z1_COMP/Z1_SERIE/Z1_CNPJ/Z1_RG/Z1_MESCONT/Z1_ANOCONT/Z1_STATUS/Z1_EMISSAO/Z1_TELEFON/Z1_STATUS/Z1_DESCSTA/Z1_CRINF/Z1_CHQDEV/Z1_CLIENTE/Z1_LOJA/Z1_NOME",.T.)
aHeader2:= aClone(aHeader)
aCols2  := aClone(aCols)

oGetChq:= MsNewGetDados():New(nGd1,nGd2,nGd3-5,nGd4,3,"U_A001BXLINOK(oGetChq:nAT,'D')","U_A001BXTUDOK(oGetChq:nAT,'D')",/*inicpos*/,Nil,/*freeze*/,MAXGETDAD,/*fieldok*/,/*superdel*/,/*delok*/,oFolder:aDialogs[2],@aHeader2,@aCols2)
oGetChq:oBrowse:bChange:={ || A001CalcTotal(@cTotChq,@oTotChq,"Cheques","Z1_VALOR",oGetChq)}
oGetChq:lDelete:= .T.

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| IIf(oGetChq:TudoOk() .And. A001ValRep(),(A001CalcCP(),nOpcA:=1,oDlg:End()),"")},{||oDlg:End()})

lBxTit   := GetMv("MV_EFA01BX")
cBanco   := PadR(GetMv("MV_EFA01BC"),3)
cAgencia := PadR(GetMv("MV_EFA01AG"),5)
cConta   := PadR(GetMv("MV_EFA01CC"),10)

If (nOpcA == 1)
	Processa({||A001GRVTITPAG(lBxTit,cBanco,cAgencia,cConta,cRepasse,oGetChq,oGetTit)},"Executando repasse de cheques...")
Else
	RollBackSX8()
EndIf

SetKey(VK_F4 ,{|| U_EFLEGENDA()})

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA001RPLINOKบ Autor ณ AP6 IDE           บ Data ณ  11/04/04   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Valida a linha dos titulos a pagar                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function A001RPLINOK(nItem)
Local nI       := 0    
Local nCount   := 0
Local aArea    := GetArea()
Local lRet     := .T.
Local nPPrefixo:= aScan(oGetTit:aHeader,{|x| AllTrim(x[2]) == "Z4_PREFIXO"})
Local nPNum    := aScan(oGetTit:aHeader,{|x| AllTrim(x[2]) == "Z4_NUM"})
Local nPParcela:= aScan(oGetTit:aHeader,{|x| AllTrim(x[2]) == "Z4_PARCELA"})
Local nPTipo   := aScan(oGetTit:aHeader,{|x| AllTrim(x[2]) == "Z4_TIPO"})

DEFAULT nItem:= n

If !oGetTit:aCols[nItem,Len(oGetTit:aHeader)+1]
	If (Empty(oGetTit:aCols[nItem,nPPrefixo]) .And. Empty(oGetTit:aCols[nItem,nPNum]) .And. Empty(oGetTit:aCols[nItem,nPParcela]) .And.;
		Empty(oGetTit:aCols[nItem,nPtipo]))
		
		oGetTit:aCols[nItem,Len(oGetTit:aHeader)+1]:= .T.
		
	Else
		dbSelectArea("SE2")
		dbSetOrder(1)
		If !dbSeek(xFilial("SE2")+oGetTit:aCols[nItem,nPPrefixo]+oGetTit:aCols[nItem,nPNum]+oGetTit:aCols[nItem,nPParcela]+oGetTit:aCols[nItem,nPTipo])
			Aviso("Atencao","A duplicata informada nao existe !!!",{"Ok"})
			lRet:= .F.
		EndIf            
		
		nCount:= 0
		For nI:= 1 To Len(oGetTit:aCols)
			If !oGetTit:aCols[nI,Len(oGetTit:aHeader)+1]
				If oGetTit:aCols[nI,nPPrefixo]+oGetTit:aCols[nI,nPNum]+oGetTit:aCols[nI,nPParcela]+oGetTit:aCols[nI,nPTipo] == ;
					oGetTit:aCols[nItem,nPPrefixo]+oGetTit:aCols[nItem,nPNum]+oGetTit:aCols[nItem,nPParcela]+oGetTit:aCols[nItem,nPTipo] .And. !oGetTit:aCols[nI,Len(oGetTit:aHeader)+1]
					nCount++
				EndIf
			EndIf
		Next nI
		
		If (nCount > 1)
			Aviso("Atencao","O titulo nao pode ser informado mais de uma vez !!!",{"Ok"})
			lRet:= .F.
		EndIf

	EndIf
EndIf

RestArea(aArea)
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA001RPTUDOKบ Autor ณ AP6 IDE           บ Data ณ  11/04/04   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Valida todas as linhas dos titulos.                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function A001RPTUDOK(nItem)
Local nI  := 0
Local lRet:= .T.

For nI:= 1 To Len(oGetTit:aCols)
	If !oGetTit:aCols[nI,Len(oGetTit:aHeader)+1] .And. !U_A001RPLINOK(nI)
		lRet:= .F.
		Exit
	EndIf
Next
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA001CALCTOTALบ Autor ณ AP6 IDE         บ Data ณ  11/04/04   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Calcula o valor de cheques a ser repassado.                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function A001CalcTotal(cTotal,oTotal,cDesc,cCampo,oObj)
Local nTotal := 0
Local nPValor:= 0

nPValor:= aScan(oObj:aHeader,{|x| AllTrim(x[2]) == cCampo})
If (nPValor > 0)
	aEval(oObj:aCols,{|x| nTotal+= IIf(!x[Len(oObj:aHeader)+1],x[nPValor],0)})
	
	cTotal:= cDesc + " " + GetMV("MV_SIMB1") + " " + AllTrim(Transform(nTotal,PesqPict("SZ1","Z1_VALOR")))
	oTotal:Refresh()
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA001GrvTitPagบ Autor ณ AP6 IDE         บ Data ณ  11/04/04   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Grava as informacoes dos titulos a pagar.                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function A001GRVTITPAG(lBxTit,cBcoDep,cAgDep,cCCDep,cRepasse,oGetChq,oGetTit)
Local nI           := 0
Local nX           := 0
Local nTit         := 0
Local nPos         := 0
Local nPBanco      := aScan(oGetChq:aHeader,{|x| AllTrim(x[2]) == "Z1_BANCO"})
Local nPAgencia    := aScan(oGetChq:aHeader,{|x| AllTrim(x[2]) == "Z1_AGENCIA"})
Local nPConta      := aScan(oGetChq:aHeader,{|x| AllTrim(x[2]) == "Z1_CONTA"})
Local nPCheque     := aScan(oGetChq:aHeader,{|x| AllTrim(x[2]) == "Z1_CHEQUE"})
Local nPValor      := aScan(oGetChq:aHeader,{|x| AllTrim(x[2]) == "Z1_VALOR"})
Local nPPrefixo    := aScan(aHeader3,{|x| AllTrim(x[2]) == "Z4_PREFIXO"})
Local nPNum        := aScan(aHeader3,{|x| AllTrim(x[2]) == "Z4_NUM"})
Local nPParcela    := aScan(aHeader3,{|x| AllTrim(x[2]) == "Z4_PARCELA"})
Local nPTipo       := aScan(aHeader3,{|x| AllTrim(x[2]) == "Z4_TIPO"})
Local nPFornece    := aScan(aHeader3,{|x| AllTrim(x[2]) == "Z4_FORNECE"})
Local nPLoja       := aScan(aHeader3,{|x| AllTrim(x[2]) == "Z4_LOJA"})
Local nPValTitZ4   := aScan(aHeader3,{|x| AllTrim(x[2]) == "Z4_VALTIT"})
Local nPSaldo      := aScan(aHeader3,{|x| AllTrim(x[2]) == "Z4_SALDO"})
Local nPValBaixa   := aScan(aHeader3,{|x| AllTrim(x[2]) == "Z4_VALOR"})
Local nPBancoZ4    := aScan(aHeader3,{|x| AllTrim(x[2]) == "Z4_BANCO"})
Local nPAgenciaZ4  := aScan(aHeader3,{|x| AllTrim(x[2]) == "Z4_AGENCIA"})
Local nPContaZ4    := aScan(aHeader3,{|x| AllTrim(x[2]) == "Z4_CONTA"})
Local nPChequeZ4   := aScan(aHeader3,{|x| AllTrim(x[2]) == "Z4_CHEQUE"})
Local aBaixa       := {}
Local nCount       := 0

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณApaga todas as amarracoes dos cheques com os titulos se eles nao foram baixados.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
For nI:=1 To Len(oGetChq:aCols)
	If !oGetChq:aCols[nI,Len(oGetChq:aHeader)+1] .And. !Empty(oGetChq:aCols[nI,nPBanco])
		
		dbSelectArea("SZ4")
		dbSetOrder(2)
		dbSeek(xFilial("SZ4")+oGetChq:aCols[nI,nPBanco]+oGetChq:aCols[nI,nPAgencia]+oGetChq:aCols[nI,nPConta]+oGetChq:aCols[nI,nPCheque],.T.)
		While !Eof() .And. (xFilial("SZ4")+oGetChq:aCols[nI,nPBanco]+oGetChq:aCols[nI,nPAgencia]+oGetChq:aCols[nI,nPConta]+oGetChq:aCols[nI,nPCheque] ==;
			SZ4->(Z4_FILIAL+Z4_BANCO+Z4_AGENCIA+Z4_CONTA+Z4_CHEQUE))
			RecLock("SZ4",.F.,.T.)
			dbDelete()
			MsUnLock()
			
			dbSelectArea("SZ4")
			dbSkip()
		End
	EndIf
Next nI

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณGrava os dados dos titulos.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
For nTit:= 1 To Len(aCols3)
	If !aCols3[nTit,Len(aHeader3)+1]
		
		nCount++
		
		dbSelectArea("SZ4")
		dbSetOrder(1)
		If dbSeek(xFilial("SZ4")+aCols3[nTit,nPPrefixo]+aCols3[nTit,nPNum]+aCols3[nTit,nPParcela]+aCols3[nTit,nPTipo]+;
			aCols3[nTit,nPBancoZ4]+aCols3[nTit,nPAgenciaZ4]+aCols3[nTit,nPContaZ4]+aCols3[nTit,nPChequeZ4],.T.)
			RecLock("SZ4",.F.)
		Else
			RecLock("SZ4",.T.)
		EndIf
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณGrava os dados do acols SZ4.         ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		For nX := 1 To Len(aHeader3)
			If ( aHeader3[nX,10] != "V" )
				nPos:= SZ4->(FieldPos(aHeader3[nX,2]))
				If (nPos > 0)
					SZ4->(FieldPut(nPos,aCols3[nTit,nX]))
				EndIf
			EndIf
		Next nX

		Replace Z4_FILIAL  With xFilial("SZ4")
		Replace Z4_PREFIXO With aCols3[nTit,nPPrefixo]
		Replace Z4_NUM     With aCols3[nTit,nPNum]
		Replace Z4_PARCELA With aCols3[nTit,nPParcela]
		Replace Z4_TIPO    With aCols3[nTit,nPTipo]
		Replace Z4_VALTIT  With aCols3[nTit,nPValTitZ4]
		Replace Z4_VALOR   With aCols3[nTit,nPValBaixa]
		Replace Z4_FORNECE With aCols3[nTit,nPFornece]
		Replace Z4_LOJA    With aCols3[nTit,nPLoja]
		Replace Z4_REPASSE With cRepasse
		Replace Z4_ITEM    With StrZero(nCount,5) 
		MsUnLock()
	EndIf
Next nTit
ConfirmSX8()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณFaz a baixa do contas a pagar.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If (lBxTit)
	For nI:= 1 To Len(oGetChq:aCols)
		If !oGetChq:aCols[nI,Len(oGetChq:aHeader)+1]
			dbSelectArea("SZ4")
			dbSetOrder(2)
			dbSeek(xFilial("SZ4")+oGetChq:aCols[nI,nPBanco]+oGetChq:aCols[nI,nPAgencia]+oGetChq:aCols[nI,nPConta]+oGetChq:aCols[nI,nPCheque])
			While !Eof() .And. (xFilial("SZ4")+oGetChq:aCols[nI,nPBanco]+oGetChq:aCols[nI,nPAgencia]+oGetChq:aCols[nI,nPConta]+oGetChq:aCols[nI,nPCheque] == ;
				SZ4->(Z4_FILIAL+Z4_BANCO+Z4_AGENCIA+Z4_CONTA+Z4_CHEQUE))
				
				dbSelectArea("SE2")
				dbSetOrder(1)
				dbSeek(xFilial("SE2")+SZ4->(Z4_PREFIXO+Z4_NUM+Z4_PARCELA+Z4_TIPO+Z4_FORNECE+Z4_LOJA))
				
				nPos:= aScan(aBaixa,{|x| x[1] == SZ4->(Z4_PREFIXO+Z4_NUM+Z4_PARCELA+Z4_TIPO+Z4_FORNECE+Z4_LOJA)})
				If (nPos == 0)
					aAdd(aBaixa,{SZ4->(Z4_PREFIXO+Z4_NUM+Z4_PARCELA+Z4_TIPO+Z4_FORNECE+Z4_LOJA),SE2->E2_ACRESC,SE2->E2_DECRESC,{{SZ4->Z4_BANCO,SZ4->Z4_AGENCIA,SZ4->Z4_CONTA,SZ4->Z4_CHEQUE,SZ4->Z4_VALOR,0}}})
				Else
					nBx:= aScan(aBaixa[nPos,4],{|x| x[1]+x[2]+x[3]+x[4] == SZ4->(Z4_BANCO+Z4_AGENCIA+Z4_CONTA+Z4_CHEQUE)})
					If (nBx == 0)
						aAdd(aBaixa[nPos,4],{SZ4->Z4_BANCO,SZ4->Z4_AGENCIA,SZ4->Z4_CONTA,SZ4->Z4_CHEQUE,SZ4->Z4_VALOR,0})
					EndIf
				EndIf
				
				dbSelectArea("SZ4")
				dbSkip()
			End
		EndIf
	Next nI
	
	A001CPBaixa(aBaixa,cBcoDep,cAgDep,cCCDep,"")
Else
	For nI:= 1 To Len(oGetChq:aCols)
		If !oGetChq:aCols[nI,Len(oGetChq:aHeader)+1]
			A001GrvMov("E",oGetChq:aCols[nI,nPBanco],oGetChq:aCols[nI,nPAgencia],oGetChq:aCols[nI,nPConta],oGetChq:aCols[nI,nPCheque],"")
		EndIf
	Next
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA001DELREPASSEบ Autor ณ AP6 IDE        บ Data ณ  11/04/04   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Deleta o repasse do cheque e a baixa dos titulos.          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function A001DELREPASSE(cBanco,cAgencia,cConta,cCheque,lExcPag,lDevolucao)
Local lRet   := .F.
Local lBxTit := .F.
Local cBcoDep:= ""
Local cAgDep := ""
Local cCCDep := ""
Local cChave := ""
Private lMsErroAuto:= .F. // variavel interna da rotina automatica
Private lMsHelpAuto:= .T.

Pergunte("EFA001",.F.)
lBxTit := GetMv("MV_EFA01BX")
cBcoDep:= PadR(GetMv("MV_EFA01BC"),3)
cAgDep := PadR(GetMv("MV_EFA01AG"),5)
cCCDep := PadR(GetMv("MV_EFA01CC"),10)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณExecuta a pergunte do FINA080 para atualizar as variaveisณ
//ณpara cancelamento da baixa.                              ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Pergunte("FIN080",.F.)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCancela a baixa dos titulos associados ao cheque.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lBxTit
	dbSelectArea("SZ4")
	dbSetOrder(2)
	If dbSeek(xFilial("SZ4")+cBanco+cAgencia+cConta+cCheque,.T.)
		While !Eof() .And. (xFilial("SZ4")+cBanco+cAgencia+cConta+cCheque == SZ4->(Z4_FILIAL+Z4_BANCO+Z4_AGENCIA+Z4_CONTA+Z4_CHEQUE))
			If !Empty(SZ4->Z4_BAIXA) .Or. (!Empty(SZ4->Z4_DTPAG) .And. lExcPag)
				cChave:= IIf(lExcPag,SZ4->(Dtos(Z4_DTPAG)+Z4_BCOPAG+Z4_AGPAGTO+Z4_CONTPAG+Z4_CHQPAG),Dtos(SZ4->Z4_BAIXA)+cBcoDep+cAgDep+cCCDep+cCheque)
				If A001CanCP(SZ4->(Z4_PREFIXO+Z4_NUM+Z4_PARCELA+Z4_TIPO+Z4_FORNECE+Z4_LOJA),cChave,IIf(lExcPag,SZ4->Z4_VALPAG,SZ4->Z4_VALOR),SZ4->Z4_SEQUENC,lDevolucao)
					
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณLimpa a baixa do titulo.ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					RecLock("SZ4",.F.)
					If lExcPag
						Replace Z4_DTPAG   With Ctod("")
						Replace Z4_VALPAG  With 0
						Replace Z4_BCOPAG  With ""
						Replace Z4_AGPAGTO With ""
						Replace Z4_CONTPAG With ""
						Replace Z4_CHQPAG  With ""
					Else
						If lDevolucao
							Replace Z4_BAIXA  With Ctod("")
							Replace Z4_DTCANC With dDatabase
						Else
							RecLock("SZ4",.F.,.T.)
							dbDelete()
							MsUnlock()
						EndIf
					EndIf
					MsUnLock()
					
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณRegistra os movimentos do cheque      ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					If lExcPag
						A001GrvMov("F",cBanco,cAgencia,cConta,cCheque,"Cancelamento de Quitacao")
					Else
						A001GrvMov("D",cBanco,cAgencia,cConta,cCheque,"Exclusao de Repasse")
					EndIf
					lRet:= .T.
				Else
					Aviso("Atencao","A baixa nao foi encontrada. Verifique se nao foi realizado cancelamento manual !!!"+;
					Chr(10)+Chr(13)+"Cheque:"+cBanco+"-"+cAgencia+"-"+cConta+"-"+cCheque,{"Ok"})
				EndIf
			EndIf
			
			dbSelectArea("SZ4")
			dbSkip()
		End
	EndIf
Else
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณRegistra os movimentos do cheque.     ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If lExcPag
		A001GrvMov("F",cBanco,cAgencia,cConta,cCheque,"Cancelamento de Quitacao")
	Else
		A001GrvMov("D",cBanco,cAgencia,cConta,cCheque,"Exclusao de Repasse")
	EndIf
	
	lRet:= .T.
EndIf

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA001VALREP    บ Autor ณ AP6 IDE        บ Data ณ  11/04/04   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Valida os valores a serem repassados.                      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function A001VALREP()
Local lRet     := .T.
Local nPNum    := aScan(oGetTit:aHeader,{|x| AllTrim(x[2]) == "Z4_NUM"})
Local nPValChq := aScan(oGetChq:aHeader,{|x| AllTrim(x[2]) == "Z1_VALOR"})
Local nPValBx  := aScan(oGetTit:aHeader,{|x| AllTrim(x[2]) == "Z4_SALDO"})
Local lExist   := .F.
Local nTotBx   := 0
Local nTotChq  := 0

For nTit:= 1 To Len(oGetTit:aCols)
	If !oGetTit:aCols[nTit,Len(oGetTit:aHeader)+1] .And. !Empty(oGetTit:aCols[nTit,nPNum])
		lExist:= .T.
		Exit
	EndIf
Next nTit

If !lExist
	Aviso("Atencao","Impossivel prosseguir sem a sele็ใo de um titulo !!!",{"Ok"})
	lRet := .F.
Else
	aEval(oGetTit:aCols,{|x| nTotBX += IIF(!x[Len(oGetTit:aHeader)+1],x[nPValBx],0)})
	aEval(oGetChq:aCols,{|x| nTotChq+= IIF(!x[Len(oGetChq:aHeader)+1],x[nPValChq],0)})

	If (nTotChq > nTotBx)
		Aviso("Atencao","O valor de cheques nao pode ser maior que o total de baixas !!!",{"Ok"})
		lRet := .F.
	EndIf
EndIf

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณEFDEVOLVECHQบ Autor ณ AP6 IDE          บ Data ณ  11/04/04   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Marca o cheque como devolvido e exclui as baixas.          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function EFDEVOLVCHQ(cAlias,nReg,nOpc)

If (SZ1->Z1_STATUS == "E")
	If Aviso("Atencao","Confirma a devolucao de Banco "+SZ1->Z1_BANCO+" Agencia "+SZ1->Z1_AGENCIA+" Conta "+SZ1->Z1_CONTA+" Cheque "+SZ1->Z1_CHEQUE+" ?",{"Ok","Cancela"}) == 1
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณDeleta a baixa dos titulos pagos e a baixa dos titulos recebidos.ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If A001DELREPASSE(SZ1->Z1_BANCO,SZ1->Z1_AGENCIA,SZ1->Z1_CONTA,SZ1->Z1_CHEQUE,.F.,.T.)
			If A001DELBAIXA(SZ1->Z1_BANCO,SZ1->Z1_AGENCIA,SZ1->Z1_CONTA,SZ1->Z1_CHEQUE,.T.,.F.,.T.)
				A001GrvMov("F",SZ1->Z1_BANCO,SZ1->Z1_AGENCIA,SZ1->Z1_CONTA,SZ1->Z1_CHEQUE,"")
			EndIf
		EndIf
	EndIf
EndIf

SetKey(VK_F4 ,{|| U_EFLEGENDA()})

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณEFPAGACHQ   บ Autor ณ AP6 IDE          บ Data ณ  11/04/04   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Confirma o pagamento dos cheques.                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function EFPAGACHQ(cAlias,nReg,nOpc)
Local aRet      	:= {}

Local lBxTit    	:= .F.
Local lStatus       := .F.
Local lPagFor       := .F.
Local lRecCli       := .F.
Local cBanco 		:= CriaVar("E1_PORTADO")
Local cAgencia		:= CriaVar("E1_AGEDEP")
Local cConta		:= CriaVar("E1_CONTA")
Local cCheque 		:= CriaVar("E5_NUMCHEQ")                
Local nValor        := 0

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSomente atualiza o status do cheque.ณ
//ณA baixa devera ser manual.          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If (SZ1->Z1_STATUS == "F")
	If (Aviso("Atencao","Confirma a quitacao de Banco "+SZ1->Z1_BANCO+" Agencia "+SZ1->Z1_AGENCIA+" Conta "+SZ1->Z1_CONTA+" Cheque "+SZ1->Z1_CHEQUE+" ?",{"Ok","Cancela"}) == 1)
		A001GrvMov("G",SZ1->Z1_BANCO,SZ1->Z1_AGENCIA,SZ1->Z1_CONTA,SZ1->Z1_CHEQUE,"")
	EndIf
Else
	Aviso("Atencao","Opcao valida somente para cheques devolvidos !!!",{"Ok"})
EndIf

SetKey(VK_F4 ,{|| U_EFLEGENDA()})

/*
Pergunte("EFA001",.F.)
lBxTit  := IIf(Mv_Par09 == 1,.T.,.F.)

Do Case
	Case (SZ1->Z1_STATUS == "F") //Devolvido
		If 	ParamBox( {	{2,"Tipo de Pagamento","1",{ "1=Fornecedor", "2=Cliente" },50,"",.F.},;
			{2,"Cheque Devolvido ","S",{ "S=Sim", "N=Nao" },50,"",.F.}}, cCadastro,@aRet)
			
			If (aRet[1] == "1") //Pagamento a Fornecedor
				lPagFor:= IIf(Aviso("Atencao","Confirma o pagamento de Banco "+SZ1->Z1_BANCO+" Agencia "+SZ1->Z1_AGENCIA+" Conta "+SZ1->Z1_CONTA+" Cheque "+SZ1->Z1_CHEQUE+" ?",{"Ok","Cancela"}) == 1,.T.,.F.)
			Else
				lRecCli:= IIf(Aviso("Atencao","Confirma a quitacao do cliente de Banco "+SZ1->Z1_BANCO+" Agencia "+SZ1->Z1_AGENCIA+" Conta "+SZ1->Z1_CONTA+" Cheque "+SZ1->Z1_CHEQUE+" ?",{"Ok","Cancela"}) == 1,.T.,.F.)
			EndIf
		EndIf
		
		
	Case (SZ1->Z1_STATUS $ "H") //Pago ou Pago Sem Documento
		lRecCli:= IIf(Aviso("Atencao","Confirma a quitacao do cliente de Banco "+SZ1->Z1_BANCO+" Agencia "+SZ1->Z1_AGENCIA+" Conta "+SZ1->Z1_CONTA+" Cheque "+SZ1->Z1_CHEQUE+" ?",{"Ok","Cancela"}) == 1,.T.,.F.)
EndCase

If lPagFor
	If lBxTit
		dbSelectArea("SZ4")
		dbSetOrder(2)
		dbSeek(xFilial("SZ4")+SZ1->(Z1_BANCO+Z1_AGENCIA+Z1_CONTA+Z1_CHEQUE),.T.)
		While !Eof() .And. (xFilial("SZ4")+SZ1->(Z1_BANCO+Z1_AGENCIA+Z1_CONTA+Z1_CHEQUE) == SZ4->(Z4_FILIAL+Z4_BANCO+Z4_AGENCIA+Z4_CONTA+Z4_CHEQUE))
			dbSelectArea("SE2")
			dbSetOrder(1)
			If dbSeek(xFilial("SE2")+SZ4->(Z4_PREFIXO+Z4_NUM+Z4_PARCELA+Z4_TIPO+Z4_FORNECE+Z4_LOJA))
				If (SE2->E2_SALDO > 0)
					nValor := SZ4->Z4_VALOR
					If U_EF2BXPAGTitW(@nValor,@cBanco,@cAgencia,@cConta,@cCheque)
						RecLock("SZ4",.F.)
						Replace Z4_VALPAG  With nValor
						Replace Z4_DTPAG   With dDatabase
						Replace Z4_BCOPAG  With cBanco
						Replace Z4_AGPAGTO With cAgencia
						Replace Z4_CONTPAG With cConta
						Replace Z4_CHQPAG  With cCheque
						Replace Z4_SEQUENC With SE5->E5_SEQ
						MsUnLock()
						
						lStatus:= .T.
					EndIf
				EndIf
			EndIf
			dbSelectArea("SZ4")
			dbSkip()
		End
	Else
		lStatus:= .T.
	EndIf
	
	If lStatus
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณVerifica se o cheque foi devolvido e atualiza status.            ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		RecLock("SZ1",.F.)
		Replace Z1_CHQDEV With aRet[2]
		MsUnLock()
		
		A001GrvMov("H",SZ1->Z1_BANCO,SZ1->Z1_AGENCIA,SZ1->Z1_CONTA,SZ1->Z1_CHEQUE,"")
	EndIf
	
ElseIf lRecCli
	If lBxTit
		dbSelectArea("SZ3")
		dbSetOrder(1)
		dbSeek(xFilial("SZ3")+SZ1->(Z1_BANCO+Z1_AGENCIA+Z1_CONTA+Z1_CHEQUE),.T.)
		While !Eof() .And. (xFilial("SZ3")+SZ1->(Z1_BANCO+Z1_AGENCIA+Z1_CONTA+Z1_CHEQUE) == SZ3->(Z3_FILIAL+Z3_BANCO+Z3_AGENCIA+Z3_CONTA+Z3_CHEQUE))
			dbSelectArea("SE1")
			dbSetOrder(1)
			If dbSeek(xFilial("SE1")+SZ3->(Z3_PREFIXO+Z3_NUM+Z3_PARCELA+Z3_TIPO))
				If (SE1->E1_SALDO > 0)
					nValor:= SZ3->Z3_VALOR
					If U_EF2BXRECTitW(@nValor,@cBanco,@cAgencia,@cConta)
						RecLock("SZ3",.F.)
						Replace Z3_VALPAG  With nValor
						Replace Z3_DTPAG   With dDatabase
						Replace Z3_BCOPAG  With cBanco
						Replace Z3_AGPAG   With cAgencia
						Replace Z3_CONTPAG With cConta
						Replace Z3_CHQPAG  With cCheque
						Replace Z3_SEQUENC With SE5->E5_SEQ
						MsUnLock()
						
						lStatus:= .T.
					EndIf
				EndIf
			EndIf
			dbSelectArea("SZ3")
			dbSkip()
		End
	Else
		lStatus:= .T.
	EndIf
	
	If lStatus
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณAtualiza status.                                                 ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		A001GrvMov("G",SZ1->Z1_BANCO,SZ1->Z1_AGENCIA,SZ1->Z1_CONTA,SZ1->Z1_CHEQUE,"")
	EndIf
EndIf
*/

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณEFCONSULTCHQบ Autor ณ AP6 IDE          บ Data ณ  11/04/04   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Codigo gerado pelo AP6 IDE.                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function EFCONSULTACHQ(cAlias,nReg,nOpc)
Local oDlg
Local oFolder
Local oGetMov
Local oGetChq
Local oGetCP
Local aSize      := {}
Local aObjects   := {}
Local aInfo      := {}
Local aPosObj    := {}
Local aMov       := {}
Local aCR        := {}
Local aCP        := {}
Local nOpcA      := 0
Local nGd1       := 0
Local nGd2       := 0
Local nGd3       := 0
Local nGd4       := 0
Local nMov       := 0
Local nCR        := 0
Local nCP        := 0
Private REPASSA  := .F.

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Faz o calculo automatico de dimensoes de objetos Folder    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aSize := MsAdvSize(,.F.,370)
aObjects := {}

aAdd( aObjects, { 100, 100, .T., .T. } )
aAdd( aObjects, { 100, 100, .T., .T. } )

aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects, .T. )


DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL

Zero()
RegToMemory("SZ1",.F.)
EnChoice( "SZ1", nReg, nOpc, , , , , aPosObj[1],, 3 )

oFolder := TFolder():New(aPosObj[2,1], aPosObj[2,2],{"Movimentacao","Contas a Receber","Contas a Pagar"}, {"","",""},oDlg,,,,.T.,.F.,aPosObj[2,4]-aPosObj[2,2], aPosObj[2,3]-aPosObj[2,1])

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define as posicoes da Getdados a partir do folder    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nGd1 := 2
nGd2 := 2
nGd3 := aPosObj[2,3]-aPosObj[2,1]-15
nGd4 := aPosObj[2,4]-aPosObj[2,2]-4


@nGd1,nGd2 LISTBOX oGetMov VAR nMov FIELDS HEADER "Status","Data","Hora","Usuario","Observacao";
SIZE nGd4,nGd3 OF oFolder:aDialogs[1] PIXEL

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAtualiza o array com os movimentos do chequeณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
A001MovTit("SZ2",M->Z1_BANCO+M->Z1_AGENCIA+M->Z1_CONTA+M->Z1_CHEQUE,@aMov,@oGetMov,,)
oGetMov:SetArray(aMov)
oGetMov:bLine:={|| {	aMov[oGetMov:nAt,1],;
aMov[oGetMov:nAt,2],;
aMov[oGetMov:nAt,3],;
aMov[oGetMov:nAt,4],;
aMov[oGetMov:nAt,5]}}
oGetMov:Refresh()


@nGd1,nGd2 LISTBOX oGetChq VAR nCR FIELDS HEADER "Prefixo","Numero","Parcela","Tipo","Cliente","Loja","Valor Titulo","Valor Baixa","Data Baixa";
SIZE nGd4,nGd3 OF oFolder:aDialogs[2] PIXEL
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAtualiza o array com os CR do cheque        ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
A001MovTit("SZ3",M->Z1_BANCO+M->Z1_AGENCIA+M->Z1_CONTA+M->Z1_CHEQUE,@aCR,@oGetChq,,)
oGetChq:SetArray(aCR)
oGetChq:bLine:={|| {	aCR[oGetChq:nAt,1],;
aCR[oGetChq:nAt,2],;
aCR[oGetChq:nAt,3],;
aCR[oGetChq:nAt,4],;
aCR[oGetChq:nAt,5],;
aCR[oGetChq:nAt,6],;
Transform(aCR[oGetChq:nAt,7],PesqPict("SZ3","Z3_VALTIT")),;
Transform(aCR[oGetChq:nAt,8],PesqPict("SZ3","Z3_VALOR")),;
Dtoc(aCR[oGetChq:nAt,9])}}
oGetChq:Refresh()

@nGd1,nGd2 LISTBOX oGetCP VAR nCP FIELDS HEADER "Prefixo","Numero","Parcela","Tipo","Fornecedor","Loja","Valor Titulo","Valor Baixa","Data Baixa","Documento Repasse","Item Repasse";
SIZE nGd4,nGd3 OF oFolder:aDialogs[3] PIXEL
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAtualiza o array com os CP do cheque        ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
A001MovTit("SZ4",M->Z1_BANCO+M->Z1_AGENCIA+M->Z1_CONTA+M->Z1_CHEQUE,@aCP,@oGetCP,,)
oGetCP:SetArray(aCP)
oGetCP:bLine:={|| {	aCP[oGetCP:nAt,1],;
					aCP[oGetCP:nAt,2],;
					aCP[oGetCP:nAt,3],;
					aCP[oGetCP:nAt,4],;
					aCP[oGetCP:nAt,5],;
					aCP[oGetCP:nAt,6],;
					Transform(aCP[oGetCP:nAt,7],PesqPict("SZ4","Z4_VALTIT")),;
					Transform(aCP[oGetCP:nAt,8],PesqPict("SZ4","Z4_VALOR")),;
					Dtoc(aCP[oGetCP:nAt,9]),;
					aCP[oGetCP:nAt,10],;
					aCP[oGetCP:nAt,11]}}
					
oGetCP:Refresh()


ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||oDlg:End()},{||oDlg:End()})

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA001MOVTIT  บ Autor ณ AP6 IDE          บ Data ณ  11/04/04   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Retorna os movimentos/titulos do cheque.                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function A001MOVTIT(cAlias,cCheque,aTitulos,oTitulo)

aTitulos:= {}


If (cAlias == "SZ2")
	dbSelectArea("SZ2")
	dbSetOrder(1)
	dbSeek(xFilial("SZ2")+cCheque)
	While !Eof() .And. (xFilial("SZ2")+cCheque == SZ2->(Z2_FILIAL+Z2_BANCO+Z2_AGENCIA+Z2_CONTA+Z2_CHEQUE))
		aAdd(aTitulos,{U_EFStatus(SZ2->Z2_STATUS),SZ2->Z2_DATA,SZ2->Z2_HORA,SZ2->Z2_USUARIO,SZ2->Z2_OBSERVA})
		dbSkip()
	End
	
	If (Len(aTitulos) == 0)
		aAdd(aTitulos,{"",Ctod(""),"","",""})
	EndIf
	
ElseIf (cAlias == "SZ3")
	dbSelectArea("SZ3")
	dbSetOrder(1)
	dbSeek(xFilial("SZ3")+cCheque)
	While !Eof() .And. (xFilial("SZ3")+cCheque == SZ3->(Z3_FILIAL+Z3_BANCO+Z3_AGENCIA+Z3_CONTA+Z3_CHEQUE))
		aAdd(aTitulos,{SZ3->Z3_PREFIXO,SZ3->Z3_NUM,SZ3->Z3_PARCELA,SZ3->Z3_TIPO,SZ3->Z3_CLIENTE,SZ3->Z3_LOJA,SZ3->Z3_VALTIT,SZ3->Z3_VALOR,SZ3->Z3_BAIXA})
		dbSkip()
	End
	
	If (Len(aTitulos) == 0)
		aAdd(aTitulos,{"","","","","","",0,0,Ctod("")})
	EndIf
ElseIf (cAlias == "SZ4")
	dbSelectArea("SZ4")
	dbSetOrder(2)
	dbSeek(xFilial("SZ4")+cCheque)
	While !Eof() .And. (xFilial("SZ4")+cCheque == SZ4->(Z4_FILIAL+Z4_BANCO+Z4_AGENCIA+Z4_CONTA+Z4_CHEQUE))
		aAdd(aTitulos,{SZ4->Z4_PREFIXO,SZ4->Z4_NUM,SZ4->Z4_PARCELA,SZ4->Z4_TIPO,SZ4->Z4_FORNECE,SZ4->Z4_LOJA,SZ4->Z4_VALTIT,SZ4->Z4_VALOR,SZ4->Z4_BAIXA,SZ4->Z4_REPASSE,SZ4->Z4_ITEM})
		dbSkip()
	End
	
	If (Len(aTitulos) == 0)
		aAdd(aTitulos,{"","","","","","",0,0,Ctod(""),"",""})
	EndIf                                                    
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณOrdena array por ordem de documento+item.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	aTitulos:= aSort(aTitulos,,,{|x,y| x[10]+x[11] < y[10]+y[11]})
EndIf

oTitulo:Refresh()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ A001SX1      ณ Autor ณ Fabio Rogerio Pereira ณ Data ณ 04/05/01 ณฑฑ                                                     ฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Verifica as perguntas incluกndo-as caso no existam            ณฑฑ                                                            ฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function A001SX1(cPerg,aPergs)
Local aArea 	:= GetArea()
Local aCposSX1	:= {}
Local nX := 0

aCposSX1:={"X1_PERGUNT","X1_PERSPA","X1_PERENG","X1_VARIAVL","X1_TIPO","X1_TAMANHO","X1_DECIMAL",;
"X1_PRESEL","X1_GSC","X1_VALID","X1_VAR01","X1_DEF01","X1_DEFSPA1","X1_DEFENG1",;
"X1_CNT01","X1_VAR02","X1_DEF02","X1_DEFSPA2","X1_DEFENG2","X1_CNT02","X1_F3" }

cPerg := PadR(cPerg,10) // Incluido por Denis-Symm em 22/04/2010 para compatibilizacao MP8/P10

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

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ EFSTATUS     ณ Autor ณ Fabio Rogerio Pereira ณ Data ณ 04/05/01 ณฑฑ                                                     ฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Verifica o status do cheque                                    ณฑฑ                                                            ฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function EFSTATUS(cStatus)
Local cDesc := ""

Do Case
	Case (cStatus == "A")
		cDesc:= "Paraiso"
		
	Case (cStatus == "B")
		cDesc:= "Guarulhos"
		
	Case (cStatus == "C")
		cDesc:= "Armazenado"
		
	Case (cStatus == "D")
		cDesc:= "Baixado"
		
	Case (cStatus == "E")
		cDesc:= "Repassado"
		
	Case (cStatus == "F")
		cDesc:= "Devolvido"
		
	Case (cStatus == "G")
		cDesc:= "Quitado"
		
EndCase

Return(PadR(cDesc,20))


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ A001CanCR    ณ Autor ณ Fabio Rogerio Pereira ณ Data ณ 04/05/01 ณฑฑ                                                     ฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Cancela a baixa do cheque                                      ณฑฑ                                                            ฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function A001CANCR(cTitulo,cBaixa,lPortador,nValorBx,cSeq,lDevolucao)
Local aArea     := GetArea()
Local aBaixaSE3 := {}
Local dDataAnt  := 0
Local nValor    := 0
Local nRegE5    := 0
Local nIndE5    := 0
Local cTitAnt   := ""
Local cBanco    := ""
Local cAgencia  := ""
Local cConta    := ""
Local cSequencia:= "01"
Local cBcoPort  := ""
Local cAgPort   := ""
Local cContaPort:= ""
Local dDtDispo  := dDatabase
Local lRet      := .F.
Local lExist    := .F.
Private nTotAbat:= 0

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤLฟ
//ณVerifica os parametros para os dados da portador de redeposito. ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤLู
cBcoPort  := GetMv("MV_EFA01BR")
cAgPort   := GetMv("MV_EFA01AR")
cContaPort:= GetMv("MV_EFA01CR")

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณExecuta a pergunte do FINA070 para atualizar as variaveisณ
//ณpara cancelamento da baixa.                              ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Pergunte("FIN070",.F.)

dbSelectArea("SE5")
dbSetOrder(1)
If dbSeek(xFilial("SE5")+cBaixa)
	While !Eof() .And. (xFilial("SE5")+cBaixa == SE5->E5_FILIAL+DTOS(SE5->E5_DATA)+SE5->E5_BANCO+SE5->E5_AGENCIA+SE5->E5_CONTA+SE5->E5_NUMCHEQ)
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณValida o valor.ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If (SE5->E5_VALOR <> nValorBx) .Or. (SE5->E5_SEQ <> cSeq) .Or. (cTitulo <> SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO))
			dbSkip()
			Loop
		EndIf
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Verifica se data do cancelamento  menor que a data da baixa ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If SE5->E5_DATA > dDataBase
			Help(" ",1,"DTBAIXA")
			Return
		EndIf
		
		lExist:= .T.
		Exit
	End
	
	If lExist
		
		SE1->(dbSetOrder(1))
		SE1->(dbSeek(xFilial("SE1")+cTitulo))
		
		aAdd(aBaixaSE3,{ SE5->E5_MOTBX , SE5->E5_SEQ , SE5->(Recno()) })
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Posiciona no registro do cliente e Estorna Atraso Medio.    ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If SA1->( dbSeek(xFilial("SA1")+SE5->E5_CLIFOR+SE5->E5_LOJA) )
			If !(SE5->E5_TIPO $ MVRECANT+"/"+MV_CRNEG)
				RecLock("SA1",.F.)
				If ( SE1->E1_BAIXA - SE1->E1_VENCREA) > 0
					SA1->A1_PAGATR := IiF(SA1->A1_PAGATR ==0,0,SA1->A1_PAGATR-SE1->E1_VALLIQ)   // Pagamentos Atrasados
					SA1->A1_ATR    := SA1->A1_ATR + SE1->E1_VALLIQ
				EndIf
				
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณ Atualiza o Cadastro de Clientes                             ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				SA1->A1_NROPAG := SA1->A1_NROPAG-1  //Numero de Duplicatas
				
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณ Atualiza media de atrasos                                   ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				SA1->A1_METR:=  (SA1->A1_METR * (SA1->A1_NROPAG+1) - (SE1->E1_BAIXA - SE1->E1_VENCREA)) / SA1->A1_NROPAG
				MsUnLock()
				
				AtuSalDup("+",(SE5->E5_VALOR),1,SE1->E1_TIPO,,SE1->E1_EMISSAO)
			Else
				AtuSalDup("-",(SE5->E5_VALOR),1,SE1->E1_TIPO,,SE1->E1_EMISSAO)
			EndIf
		EndIf
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณGrava novos valores do cancelamento da baixa parcial              ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		nTotAbat := SumAbatRec( SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_MOEDA, "V" )
		nTotAbat := IIf( SE1->E1_SALDO != 0,0,nTotAbat)
		dDataAnt := SE1->E1_BAIXA
		nValor   := SE1->E1_SALDO + SE5->E5_VALOR + nTotAbat + SE5->E5_VLDESCO
		
		RecLock("SE1")
		SE1->E1_BAIXA   := IIf(SE1->E1_SALDO >0.01,Ctod(" /  /  "),dDataAnt)
		SE1->E1_SALDO   := Iif(nValor<0,0,Min(SE1->E1_VALOR, nValor))
		SE1->E1_VALLIQ  := 0
		SE1->E1_LOTE    := Space(Len(E1_LOTE))
		SE1->E1_DATABOR := Ctod(" /  /  ")
		SE1->E1_DESCONT := 0
		SE1->E1_MULTA   := 0
		SE1->E1_JUROS   := 0
		SE1->E1_CORREC  := 0
		SE1->E1_STATUS  := IIf(SE1->E1_SALDO >0.01,"A","B")
		
		If (SE1->E1_SALDO == SE1->E1_VALOR .And. Empty(SE1->E1_BAIXA))
			SE1->E1_SDACRES :=SE1->E1_ACRESC
			SE1->E1_SDDECRE :=SE1->E1_DECRESC
		EndIf
		
		If lPortador
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณMuda o portador do titulo para o banco de re-deposito.ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			Replace E1_NUMBCO  With StrZero(Month(SZ1->Z1_VENCTO),2) + "/" + Right(StrZero(Year(SZ1->Z1_VENCTO),4),2) + " " + Alltrim(SZ1->Z1_CHEQUE) + "/" + AllTrim(SZ1->Z1_BANCO)
			Replace E1_PORTADO With cBcoPort
			Replace E1_AGEDEP  With cAgPort
			Replace E1_CONTA   With cContaPort
		EndIf
		
		MsUnLock()
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณVerifica se h  abatimentos para voltar a carteira                 ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		dbSelectArea("SE1")
		dbSetOrder(2)
		If dbSeek(xFilial("SE1")+SE1->E1_CLIENTE+SE1->E1_LOJA+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA)
			
			cTitAnt := (SE1->E1_FILIAL+SE1->E1_CLIENTE+SE1->E1_LOJA+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA)
			
			While !Eof() .And. cTitAnt == (SE1->E1_FILIAL+SE1->E1_CLIENTE+SE1->E1_LOJA+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA)
				If !SE1->E1_TIPO $ MVABATIM+"/"+MVINABT+"/"+MVIRABT
					dbSkip()
					Loop
				Endif
				
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณVolta tกtulo para carteira                                        ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				Reclock("SE1",.F.)
				SE1->E1_BAIXA   := Ctod(" /  /  ")
				SE1->E1_SALDO   := E1_VALOR
				SE1->E1_DESCONT := 0
				SE1->E1_JUROS   := 0
				SE1->E1_MULTA   := 0
				SE1->E1_CORREC  := 0
				SE1->E1_VARURV  := 0
				SE1->E1_VALLIQ  := 0
				SE1->E1_LOTE    := Space(Len(E1_LOTE))
				SE1->E1_DATABOR := Ctod(" /  /  ")
				SE1->E1_STATUS  := "A"
				MsUnLock()
				dbSkip()
			End
		EndIf
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Estorna Comissao                            ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		Fa440DeleB(aBaixaSE3,If(MV_PAR05==1,.T.,.F.),If(MV_PAR03==1,.T.,.F.),"FINA070")
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณGera o estorno da baixa.ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		SE1->(dbSetOrder(1))
		SE1->(dbSeek(xFilial("SE1")+cTitulo))
		
		cBanco    := SE5->E5_BANCO
		cAgencia  := SE5->E5_AGENCIA
		cConta    := SE5->E5_CONTA
		nValor    := SE5->E5_VALOR
		cSequencia:= SE5->E5_SEQ
		dDtDispo  := SE5->E5_DTDISPO
		
		RecLock("SE5",.T.)
		SE5->E5_FILIAL    := xFilial("SE5")
		SE5->E5_BANCO     := cBanco
		SE5->E5_AGENCIA   := cAgencia
		SE5->E5_CONTA     := cConta
		SE5->E5_DATA      := dDatabase
		SE5->E5_VALOR     := nValor
		SE5->E5_NATUREZ   := SE1->E1_NATUREZ
		SE5->E5_RECPAG    := Iif(SE1->E1_TIPO$MVRECANT+"/"+MV_CRNEG,"R","P")
		SE5->E5_TIPO      := SE1->E1_TIPO
		SE5->E5_LA        := "N"
		SE5->E5_TIPODOC   := "ES"
		SE5->E5_LOTE      := ""
		SE5->E5_PREFIXO   := SE1->E1_PREFIXO
		SE5->E5_NUMERO    := SE1->E1_NUM
		SE5->E5_PARCELA   := SE1->E1_PARCELA
		SE5->E5_CLIFOR    := SE1->E1_CLIENTE
		SE5->E5_LOJA      := SE1->E1_LOJA
		SE5->E5_BENEF     := SE1->E1_NOMCLI
		SE5->E5_DTDIGIT   := dDataBase
		SE5->E5_MOTBX     := IIf(lDevolucao,"CHD","CHQ")
		SE5->E5_VLMOED2   := nValor
		SE5->E5_SEQ       := cSequencia
		SE5->E5_DTDISPO   := IIF (dDtdispo > dDatabase, dDtDispo, dDataBase)
		SE5->E5_FILORIG   := SE1->E1_FILORIG
		SE5->E5_HISTOR    := "Cancelamento de baixa de cheque"
		MsUnLock()
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณAtualiza o saldo banc rio                                         ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If !(SE1->E1_TIPO $ MVRECANT+"/"+MV_CRNEG)
			AtuSalBco(cBanco,cAgencia,cConta,dDataBase,nValor,"-")
		Elseif SE1->E1_TIPO $ MVRECANT
			AtuSalBco(cBanco,cAgencia,cConta,dDataBase,nValor,"+")
		Endif
		
		lRet:= .T.
	EndIf
EndIf

RestArea(aArea)
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ A001CanCP    ณ Autor ณ Fabio Rogerio Pereira ณ Data ณ 04/05/01 ณฑฑ                                                     ฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Cancela a baixa do contas a pagar                              ณฑฑ                                                            ฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function A001CANCP(cTitulo,cBaixa,nValorBx,cSeq,lDevolucao)
Local aArea     := GetArea()
Local dDataAnt  := 0
Local nValor    := 0
Local nAtraso   := 0
Local nRegE5    := 0
Local nIndE5    := 0
Local cTitAnt   := ""
Local cBanco    := ""
Local cAgencia  := ""
Local cConta    := ""
Local cSequencia:= "01"
Local cBcoPort  := ""
Local cAgPort   := ""
Local cContaPort:= ""
Local dDtDispo  := dDatabase
Local lRet      := .F.
Local lExist    := .F.
Private nTotAbat:= 0


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณExecuta a pergunte do FINA080 para atualizar as variaveisณ
//ณpara cancelamento da baixa.                              ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Pergunte("FIN080",.F.)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤLฟ
//ณVerifica os parametros para os dados da portador de re-deposito.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤLู
cBcoPort  := GetMv("MV_EFA01BR")

dbSelectArea("SE5")
dbSetOrder(1)
If dbSeek(xFilial("SE5")+cBaixa)
	While !Eof() .And. (xFilial("SE5")+cBaixa == SE5->E5_FILIAL+DTOS(SE5->E5_DATA)+SE5->E5_BANCO+SE5->E5_AGENCIA+SE5->E5_CONTA+SE5->E5_NUMCHEQ)
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณValida o valor.ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If (SE5->E5_VALOR <> nValorBx) .Or. (SE5->E5_SEQ <> cSeq) .Or. (cTitulo <> SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA))
			dbSkip()
			Loop
		EndIf
		
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Verifica se data do cancelamento  menor que a data da baixa ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If SE5->E5_DATA > dDataBase
			Help(" ",1,"DTBAIXA")
			Return
		EndIf
		
		lExist:= .T.
		Exit
	End
	
	If lExist
		
		SE2->(dbSetOrder(1))
		SE2->(dbSeek(xFilial("SE2")+cTitulo))
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Posiciona no registro do fornecedor e Estorna Atraso Medio. ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If SA2->( dbSeek(xFilial("SA2")+SE5->E5_CLIFOR+SE5->E5_LOJA) )
			RecLock("SA2",.F.)
			
			If SE2->E2_TIPO $ MVPAGANT+"/"+MV_CPNEG
				SA2->A2_SALDUP	:= A2_SALDUP - SE5->E5_VALOR
				SA2->A2_SALDUPM	:= A2_SALDUPM-xMoeda(SE5->E5_VALOR,1,Val(GetMv("MV_MCUSTO")),SE2->E2_EMISSAO)
			Else
				SA2->A2_SALDUP	:= A2_SALDUP + SE5->E5_VALOR
				SA2->A2_SALDUPM	:= A2_SALDUPM+xMoeda(SE5->E5_VALOR,1,Val(GetMv("MV_MCUSTO")),SE2->E2_EMISSAO)
			EndIf
			
			nAtraso:= SE5->E5_DATA-SE2->E2_VENCTO
			If nAtraso > 1
				If Dow(SE2->E2_VENCTO) == 1 .Or. Dow(SE2->E2_VENCTO) == 7
					If Dow(dDatabase) == 2 .and. nAtraso <= 2
						nAtraso := 0
					EndIf
				EndIf
				
				nAtraso:= IIf(nAtraso < 0, 0, nAtraso)
				If SA2->A2_MATR < nAtraso
					Replace A2_MATR With nAtraso
				EndIf
			EndIf
			MsUnLock()
		EndIf
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณGrava novos valores do cancelamento da baixa parcial              ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		nTotAbat := SumAbatPag( SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_PARCELA, SE2->E2_FORNECE,SE2->E2_MOEDA, "V", SE5->E5_DATA, SE2->E2_LOJA)
		nTotAbat := IIf( SE2->E2_SALDO != 0,0,nTotAbat)
		dDataAnt := SE2->E2_BAIXA
		nValor   := SE2->E2_SALDO + SE5->E5_VALOR + nTotAbat + SE5->E5_VLDESCO
		
		RecLock("SE2")
		SE2->E2_BAIXA   := IIf(SE2->E2_SALDO >0.01,Ctod(" /  /  "),dDataAnt)
		SE2->E2_SALDO   := Iif(nValor<0,0,Min(SE2->E2_VALOR, nValor))
		SE2->E2_VALLIQ  := 0
		SE2->E2_LOTE    := Space(Len(E2_LOTE))
		SE2->E2_IMPCHEQ := " "
		SE2->E2_NUMBCO	:=	Space(Len(SE2->E2_NUMBCO))
		
		If (SE2->E2_SALDO == SE2->E2_VALOR .And. Empty(SE2->E2_BAIXA))
			SE2->E2_SDACRES := SE2->E2_ACRESC
			SE2->E2_SDDECRE := SE2->E2_DECRESC
		EndIf
		                 
		If lDevolucao
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณMuda o portador do titulo para o banco de re-deposito.ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			Replace E2_NUMBCO  With StrZero(Month(SZ1->Z1_VENCTO),2) + "/" + Right(StrZero(Year(SZ1->Z1_VENCTO),4),2) + " " + Alltrim(SZ1->Z1_CHEQUE) + "/" + AllTrim(SZ1->Z1_BANCO)
			Replace E2_PORTADO With cBcoPort
		EndIf
		
		MsUnLock()
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณVerifica se h  abatimentos para voltar a carteira                 ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		dbSelectArea("SE2")
		dbSetOrder(1)
		If dbSeek(xFilial("SE2")+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA)
			
			cTitAnt := (SE2->E2_FILIAL+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA)
			
			While !Eof() .And. cTitAnt == (SE2->E2_FILIAL+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA)
				If !SE2->E2_TIPO $ MVABATIM
					dbSkip()
					Loop
				EndIf
				
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณVolta tกtulo para carteira                                        ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				Reclock("SE2",.F.)
				SE2->E2_BAIXA   := Ctod(" /  /  ")
				SE2->E2_SALDO   := E2_VALOR
				SE2->E2_DESCONT := 0
				SE2->E2_JUROS   := 0
				SE2->E2_MULTA   := 0
				SE2->E2_CORREC  := 0
				SE2->E2_VARURV  := 0
				SE2->E2_VALLIQ  := 0
				SE2->E2_LOTE    := Space(Len(E2_LOTE))
				SE2->E2_NUMBCO	:= Space(Len(SE2->E2_NUMBCO))
				MsUnLock()
				dbSkip()
			End
		EndIf
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณGera o estorno da baixa.ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		SE2->(dbSetOrder(1))
		SE2->(dbSeek(xFilial("SE2")+cTitulo))
		
		cBanco    := SE5->E5_BANCO
		cAgencia  := SE5->E5_AGENCIA
		cConta    := SE5->E5_CONTA
		nValor    := SE5->E5_VALOR
		cSequencia:= SE5->E5_SEQ
		dDtDispo  := SE5->E5_DTDISPO
		
		RecLock("SE5",.T.)
		SE5->E5_FILIAL    := xFilial("SE5")
		SE5->E5_BANCO     := cBanco
		SE5->E5_AGENCIA   := cAgencia
		SE5->E5_CONTA     := cConta
		SE5->E5_DATA      := dDatabase
		SE5->E5_VALOR     := nValor
		SE5->E5_NATUREZ   := SE2->E2_NATUREZ
		SE5->E5_RECPAG    := IIf(SE2->E2_TIPO$MVPAGANT+"/"+MV_CPNEG,"P","R")
		SE5->E5_TIPO      := SE2->E2_TIPO
		SE5->E5_LA        := "N"
		SE5->E5_TIPODOC   := "ES"
		SE5->E5_LOTE      := ""
		SE5->E5_PREFIXO   := SE2->E2_PREFIXO
		SE5->E5_NUMERO    := SE2->E2_NUM
		SE5->E5_PARCELA   := SE2->E2_PARCELA
		SE5->E5_CLIFOR    := SE2->E2_FORNECE
		SE5->E5_LOJA      := SE2->E2_LOJA
		SE5->E5_BENEF     := SE2->E2_NOMFOR
		SE5->E5_DTDIGIT   := dDataBase
		SE5->E5_MOTBX     := IIf(lDevolucao,"CHD","CHQ")
		SE5->E5_VLMOED2   := nValor
		SE5->E5_SEQ       := cSequencia
		SE5->E5_DTDISPO   := IIF (dDtdispo > dDatabase, dDtDispo, dDataBase)
		SE5->E5_HISTOR    := "Cancelamento de repasse de cheque"
		MsUnLock()
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณAtualiza o saldo banc rio                                         ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If !(SE2->E2_TIPO $ MVPAGANT+"/"+MV_CPNEG)
			AtuSalBco(cBanco,cAgencia,cConta,dDataBase,nValor,"+")
		Elseif SE2->E2_TIPO $ MVPAGANT
			AtuSalBco(cBanco,cAgencia,cConta,dDataBase,nValor,"-")
		Endif
		
		lRet:= .T.
		
	EndIf
EndIf

RestArea(aArea)
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ EFFILTRO     ณ Autor ณ Fabio Rogerio Pereira ณ Data ณ 04/05/01 ณฑฑ                                                     ฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Filtra o browse                                                ณฑฑ                                                            ฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function EFFILTRO()
Local oDlgFil
Local oBusca
Local nOpca 	:= 0
Local aOpcFiltro:= {}
Local aIndSZ1   := {}
Local cBusca    := ""
Local cCondicao	:='Z1_FILIAL== "'+xFilial("SZ1")+'" '

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Carrega status do call center                      ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aOpcFiltro:= {"* - Todos","A - Paraiso","B - Guarulhos","C - Armazenado","D - Baixado","E - Repassado","F - Devolvido","G - Quitado"}

DEFINE MSDIALOG oDlgFil TITLE OemtoAnsi("Filtrar por ?")  FROM 00,0 TO 100,490 OF oMainWnd PIXEL

@ 05,05 MSCOMBOBOX oBusca VAR cBusca ITEMS aOpcFiltro SIZE 206, 36 OF oDlgFil PIXEL

DEFINE SBUTTON oBut1 FROM 05, 215 TYPE 1 ACTION ( nOpca := 1, oDlgFil:End() ) ENABLE of oDlgFil
DEFINE SBUTTON oBut1 FROM 20, 215 TYPE 2 ACTION ( nOpca := 0, oDlgFil:End() )  ENABLE of oDlgFil

ACTIVATE MSDIALOG oDlgFil CENTERED

dbSelectArea("SZ1")
dbSetOrder(1)

If nOpca == 1
	IF Left(cBusca,1) <> "*"
		cCondicao += ' .And. Z1_STATUS == "'+Left(cBusca,1)+'" '
		//		LjMsgRun("Por Favor Aguarde, filtrando informa็๕es...",, {|| Eval(bFiltraBrw) })
	EndIF
	SZ1->(DbClearFilter())
	SZ1->(DbSetFilter({||&(cCondicao)},cCondicao))
	
	//bFiltraBrw := {|| FilBrowse("SZ1",@aIndSZ1,@cCondicao) }
	//Eval(bFiltraBrw)
EndIF

DbGoTop()

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ A001CRBaixa  ณ Autor ณ Fabio Rogerio Pereira ณ Data ณ 04/05/01 ณฑฑ                                                     ฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Baixa o CR                                                     ณฑฑ                                                            ฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function A001CRBaixa(aBaixa,cBcoDep,cAgDep,cCCDep,cMotivo)
Local lRet         := .T.
Local cHist        := ""
Local nPos         := 0
Local nBx          := 0

For nPos:= 1 To Len(aBaixa)
	dbSelectArea("SE1")
	dbSetOrder(1)
	If dbSeek(xFilial("SE1")+aBaixa[nPos,1])
		If (SE1->E1_SALDO <= 0)
			Help(" ",1,"TITBAIXADO")
			Exit
		EndIf
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณBaixa o Juros somente se for a primeira baixa do titulo.ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If (aBaixa[nPos,2] > 0) .And. (SE1->E1_SALDO == SE1->E1_VLCRUZ )
			U_A001CRJuros(aBaixa[nPos,2],cBcoDep,cAgDep,cCCDep,"CHEQUE3")
		EndIf
		
		For nBx:= 1 To Len(aBaixa[nPos,4])
			cHist   := "Baixa Cheque " + aBaixa[nPos,4,nBx,1]+"/"+aBaixa[nPos,4,nBx,2]+"/"+aBaixa[nPos,4,nBx,3]+"/"+aBaixa[nPos,4,nBx,4]
			
			If !U_A001BXCR("CHEQUE3",cBcoDep,cAgDep,cCCDep,cHist,aBaixa[nPos,4,nBx])
				lRet:= .F.
				
				Aviso("Atencao","Problemas na baixa do cheque "+aBaixa[nPos,4,nBx,1]+"/"+aBaixa[nPos,4,nBx,2]+"/"+aBaixa[nPos,4,nBx,3]+"/"+aBaixa[nPos,4,nBx,4],{"Ok"})
			Else
				
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณAtualiza a data da baixa.ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				dbSelectArea("SZ3")
				dbSetOrder(1)
				If dbSeek(xFilial("SZ3")+aBaixa[nPos,4,nBx,1]+aBaixa[nPos,4,nBx,2]+aBaixa[nPos,4,nBx,3]+aBaixa[nPos,4,nBx,4]+aBaixa[nPos,1])
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณAtualiza a data da baixa.ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					RecLock("SZ3",.F.)
					Replace Z3_BAIXA   With dDatabase
					Replace Z3_SEQUENC With SE5->E5_SEQ
					MsUnLock()
					
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณGrava a movimentacao do cheque.ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					A001GrvMov("D",aBaixa[nPos,4,nBx,1],aBaixa[nPos,4,nBx,2],aBaixa[nPos,4,nBx,3],aBaixa[nPos,4,nBx,4],cMotivo)
				EndIf
			EndIf
		Next
	EndIf
Next

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA001DelDevolucaoบ Autor ณ AP6 IDE      บ Data ณ  11/04/04   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Grava a baixa do cheque e dos titulos associados.          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function A001DELDEVOLUCAO(cBanco,cAgencia,cConta,cCheque)
Local nI           := 0
Local lBxTit       := .F.
Local cBcoDep      := ""
Local cAgDep       := ""
Local cCCDep       := ""
Local aBaixa       := {}
Local nPos         := 0
Local nBx          := 0

Pergunte("EFA001",.F.)
lBxTit := GetMv("MV_EFA01BX")
cBcoDep:= PadR(GetMv("MV_EFA01BC"),3)
cAgDep := PadR(GetMv("MV_EFA01AG"),5)
cCCDep := PadR(GetMv("MV_EFA01CC"),10)

If lBxTit
	
	dbSelectArea("SZ3")
	dbSetOrder(1)
	dbSeek(xFilial("SZ3")+cBanco+cAgencia+cConta+cCheque)
	While !Eof() .And. (xFilial("SZ3")+cBanco+cAgencia+cConta+cCheque == ;
		SZ3->(Z3_FILIAL+Z3_BANCO+Z3_AGENCIA+Z3_CONTA+Z3_CHEQUE))
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณVerifica se o titulo ja esta baixado.ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If !Empty(SZ3->Z3_BAIXA)
			dbSelectArea("SZ3")
			dbSkip()
			Loop
		EndIf
		
		dbSelectArea("SE1")
		dbSetOrder(1)
		dbSeek(xFilial("SE1")+SZ3->Z3_PREFIXO+SZ3->Z3_NUM+SZ3->Z3_PARCELA+SZ3->Z3_TIPO)
		
		nPos:= aScan(aBaixa,{|x| x[1] == SZ3->(Z3_PREFIXO+Z3_NUM+Z3_PARCELA+Z3_TIPO+Z3_CLIENTE+Z3_LOJA)})
		If (nPos == 0)
			aAdd(aBaixa,{SZ3->(Z3_PREFIXO+Z3_NUM+Z3_PARCELA+Z3_TIPO+Z3_CLIENTE+Z3_LOJA),SE1->E1_ACRESC,SE1->E1_DECRESC,{{SZ3->Z3_BANCO,SZ3->Z3_AGENCIA,SZ3->Z3_CONTA,SZ3->Z3_CHEQUE,SZ3->Z3_VALOR,0}}})
		Else
			nBx:= aScan(aBaixa[nPos,4],{|x| x[1]+x[2]+x[3]+x[4] == SZ3->(Z3_BANCO+Z3_AGENCIA+Z3_CONTA+Z3_CHEQUE)})
			If (nBx == 0)
				aAdd(aBaixa[nPos,4],{SZ3->Z3_BANCO,SZ3->Z3_AGENCIA,SZ3->Z3_CONTA,SZ3->Z3_CHEQUE,SZ3->Z3_VALOR,0})
			EndIf
		EndIf
		
		dbSelectArea("SZ3")
		dbSkip()
	End
	
	A001CRBaixa(aBaixa,cBcoDep,cAgDep,cCCDep,"Exclusao da Devolucao de Cheque")
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณExecuta a baixa do CP.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	aBaixa:= {}
	dbSelectArea("SZ4")
	dbSetOrder(2)
	dbSeek(xFilial("SZ4")+cBanco+cAgencia+cConta+cCheque)
	While !Eof() .And. (xFilial("SZ4")+cBanco+cAgencia+cConta+cCheque == ;
		SZ4->(Z4_FILIAL+Z4_BANCO+Z4_AGENCIA+Z4_CONTA+Z4_CHEQUE))
		
		dbSelectArea("SE2")
		dbSetOrder(1)
		dbSeek(xFilial("SE2")+SZ4->(Z4_PREFIXO+Z4_NUM+Z4_PARCELA+Z4_TIPO+Z4_FORNECE+Z4_LOJA))
		
		nPos:= aScan(aBaixa,{|x| x[1] == SZ4->(Z4_PREFIXO+Z4_NUM+Z4_PARCELA+Z4_TIPO+Z4_FORNECE+Z4_LOJA)})
		If (nPos == 0)
			aAdd(aBaixa,{SZ4->(Z4_PREFIXO+Z4_NUM+Z4_PARCELA+Z4_TIPO+Z4_FORNECE+Z4_LOJA),SE2->E2_ACRESC,SE2->E2_DECRESC,{{SZ4->Z4_BANCO,SZ4->Z4_AGENCIA,SZ4->Z4_CONTA,SZ4->Z4_CHEQUE,SZ4->Z4_VALOR,0}}})
		Else
			nBx:= aScan(aBaixa[nPos,4],{|x| x[1]+x[2]+x[3]+x[4] == SZ4->(Z4_BANCO+Z4_AGENCIA+Z4_CONTA+Z4_CHEQUE)})
			If (nBx == 0)
				aAdd(aBaixa[nPos,4],{SZ4->Z4_BANCO,SZ4->Z4_AGENCIA,SZ4->Z4_CONTA,SZ4->Z4_CHEQUE,SZ4->Z4_VALOR,0})
			EndIf
		EndIf
		
		dbSelectArea("SZ4")
		dbSkip()
	End
	
	A001CPBaixa(aBaixa,cBcoDep,cAgDep,cCCDep,"Exclusao da Devolucao de Cheque")
Else
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณAtualiza o status do cheque.ณ
	//ณBaixa apenas o cheque.      ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	A001GrvMov("E",cBanco,cAgencia,cConta,cCheque,"Exclusao da Devolucao de Cheque")
EndIf

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ A001CPBaixa  ณ Autor ณ Fabio Rogerio Pereira ณ Data ณ 04/05/01 ณฑฑ                                                     ฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Baixa o CP                                                     ณฑฑ                                                            ฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A001CPBaixa(aBaixa,cBcoDep,cAgDep,cCCDep,cMotivo)
Local lRet         := .T.
Local cHist        := ""
Local nPos         := 0
Local nBx          := 0
Local nValBx       := 0
Local aAreaSE5     := {}

For nPos:= 1 To Len(aBaixa)
	dbSelectArea("SE2")
	dbSetOrder(1)
	If dbSeek(xFilial("SE2")+aBaixa[nPos,1])
		If (SE2->E2_SALDO <= 0)
			Help(" ",1,"TITBAIXADO")
			Exit
		EndIf
		
		For nBx:= 1 To Len(aBaixa[nPos,4])
			cHist   := "Baixa Cheque " + aBaixa[nPos,4,nBx,1]+"/"+aBaixa[nPos,4,nBx,2]+"/"+aBaixa[nPos,4,nBx,3]+"/"+aBaixa[nPos,4,nBx,4]
			
			If !U_A001BXRepasse("CHEQUE3",cBcoDep,cAgDep,cCCDep,cHist,aBaixa[nPos,4,nBx],.F.,@nValBx)
				lRet:= .F.
				
				Aviso("Atencao","Problemas no repasse do cheque "+aBaixa[nPos,4,nBx,1]+"/"+aBaixa[nPos,4,nBx,2]+"/"+aBaixa[nPos,4,nBx,3]+"/"+aBaixa[nPos,4,nBx,4],{"Ok"})
			Else
				
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณAtualiza a data da baixa.ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				dbSelectArea("SZ4")
				dbSetOrder(2)
				If dbSeek(xFilial("SZ4")+aBaixa[nPos,4,nBx,1]+aBaixa[nPos,4,nBx,2]+aBaixa[nPos,4,nBx,3]+aBaixa[nPos,4,nBx,4]+aBaixa[nPos,1])
					RecLock("SZ4",.F.)
					Replace Z4_BAIXA   With dDatabase
					Replace Z4_SEQUENC With SE5->E5_SEQ                                             
					Replace Z4_VALOR   With nValBx
					MsUnLock()
					
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณGrava a movimentacao do cheque.ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					A001GrvMov("E",aBaixa[nPos,4,nBx,1],aBaixa[nPos,4,nBx,2],aBaixa[nPos,4,nBx,3],aBaixa[nPos,4,nBx,4],cMotivo)
				EndIf
			EndIf
		Next
		                       
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณBaixa o Desconto somente uma vez.                     ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If (aBaixa[nPos,3] > 0)
			aAreaSE5:= SE5->(GetArea())
			dbSelectArea("SE5")
			SE5->(dbSetOrder(2))

			If !SE5->(dbSeek(xFilial("SE5") + "DC" + SE2->E2_PREFIXO + SE2->E2_NUM + SE2->E2_PARCELA + SE2->E2_TIPO) )
				U_A001CPDesconto(aBaixa[nPos,3],cBcoDep,cAgDep,cCCDep,"CHEQUE3")
			EndIf

			RestArea(aAreaSE5)
		Endif
			
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณBaixa o Juros somente uma vez.                        ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If (aBaixa[nPos,2] > 0) 
			aAreaSE5:= SE5->(GetArea())
			dbSelectArea("SE5")
			SE5->(dbSetOrder(2))
			If !SE5->(dbSeek(xFilial("SE5") + "JR" + SE2->E2_PREFIXO + SE2->E2_NUM + SE2->E2_PARCELA + SE2->E2_TIPO) )
				U_A001CPJuros(aBaixa[nPos,2],cBcoDep,cAgDep,cCCDep,"CHEQUE3")
			EndIf
			RestArea(aAreaSE5)
		EndIf
	EndIf
Next

Return(lRet)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ A001CalcCP   ณ Autor ณ Fabio Rogerio Pereira ณ Data ณ 04/05/01 ณฑฑ                                                     ฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Calcula a baixa do CP                                          ณฑฑ                                                            ฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function A001CalcCP()
Local nI          := 0
Local nTotChq     := 0
Local nTotTit     := 0
Local nValAux     := 0
Local nSaldo      := 0
Local nSaldoBx    := 0
Local nChq        := 0
Local nTotBx      := 0
Local nPBancoZ1   := aScan(oGetChq:aHeader,{|x| AllTrim(x[2]) == "Z1_BANCO"})
Local nPAgZ1      := aScan(oGetChq:aHeader,{|x| AllTrim(x[2]) == "Z1_AGENCIA"})
Local nPContaZ1   := aScan(oGetChq:aHeader,{|x| AllTrim(x[2]) == "Z1_CONTA"})
Local nPChequeZ1  := aScan(oGetChq:aHeader,{|x| AllTrim(x[2]) == "Z1_CHEQUE"})
Local nPValorZ1   := aScan(oGetChq:aHeader,{|x| AllTrim(x[2]) == "Z1_VALOR"})
Local nPPrefixoE2 := aScan(oGetTit:aHeader,{|x| AllTrim(x[2]) == "Z4_PREFIXO"})
Local nPNumE2     := aScan(oGetTit:aHeader,{|x| AllTrim(x[2]) == "Z4_NUM"})
Local nPParcelaE2 := aScan(oGetTit:aHeader,{|x| AllTrim(x[2]) == "Z4_PARCELA"})
Local nPTipoE2    := aScan(oGetTit:aHeader,{|x| AllTrim(x[2]) == "Z4_TIPO"})
Local nPValTitE2  := aScan(oGetTit:aHeader,{|x| AllTrim(x[2]) == "Z4_VALTIT"})
Local nPSaldoE2   := aScan(oGetTit:aHeader,{|x| AllTrim(x[2]) == "Z4_SALDO"})
Local nPVencReaE2 := aScan(oGetTit:aHeader,{|x| AllTrim(x[2]) == "Z4_VENCREA"})
Local nPValorE2   := aScan(oGetTit:aHeader,{|x| AllTrim(x[2]) == "Z4_VALOR"})
Local nPForneceE2 := aScan(oGetTit:aHeader,{|x| AllTrim(x[2]) == "Z4_FORNECE"})
Local nPLojaE2    := aScan(oGetTit:aHeader,{|x| AllTrim(x[2]) == "Z4_LOJA"})
Local nPBancoZ4   := aScan(aHeader3,{|x| AllTrim(x[2]) == "Z4_BANCO"})
Local nPAgenciaZ4 := aScan(aHeader3,{|x| AllTrim(x[2]) == "Z4_AGENCIA"})
Local nPContaZ4   := aScan(aHeader3,{|x| AllTrim(x[2]) == "Z4_CONTA"})
Local nPChequeZ4  := aScan(aHeader3,{|x| AllTrim(x[2]) == "Z4_CHEQUE"})
Local nPValorZ4   := aScan(aHeader3,{|x| AllTrim(x[2]) == "Z4_VALOR"})
Local nPPrefixoZ4 := aScan(aHeader3,{|x| AllTrim(x[2]) == "Z4_PREFIXO"})
Local nPNumZ4     := aScan(aHeader3,{|x| AllTrim(x[2]) == "Z4_NUM"})
Local nPParcelaZ4 := aScan(aHeader3,{|x| AllTrim(x[2]) == "Z4_PARCELA"})
Local nPTipoZ4    := aScan(aHeader3,{|x| AllTrim(x[2]) == "Z4_TIPO"})
Local nPSaldoZ4   := aScan(aHeader3,{|x| AllTrim(x[2]) == "Z4_SALDO"})
Local nPVencReaZ4 := aScan(aHeader3,{|x| AllTrim(x[2]) == "Z4_VENCREA"})
Local nPValTitZ4  := aScan(aHeader3,{|x| AllTrim(x[2]) == "Z4_VALTIT"})
Local nPForneceZ4 := aScan(aHeader3,{|x| AllTrim(x[2]) == "Z4_FORNECE"})
Local nPLojaZ4    := aScan(aHeader3,{|x| AllTrim(x[2]) == "Z4_LOJA"})

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica o valor total de cheques para fazer a proporcionalizacao.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nTotChq:= 0
aEval(oGetChq:aCols,{|x| nTotChq+= IIF(!x[Len(oGetChq:aHeader)+1],x[nPValorZ1],0)})

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica o valor total de titulos para fazer a proporcionalizacao.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nTotTit:= 0
aEval(oGetTit:aCols,{|x| nTotTit+= IIF(!x[Len(oGetTit:aHeader)+1],x[nPSaldoE2],0)})

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica a quantidade de titulos validos.                         ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nChq:= 0
aEval(oGetChq:aCols,{|x| nChq+= IIF(!x[Len(oGetChq:aHeader)+1],1,0)})
nSaldo:= IIf(nTotTit > nTotChq,nTotChq,nTotTit)


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณIndexa por valor para poder preencher as baixas corretamentes eณ
//ณdeixar saldo somente no ultimo titulo                          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oGetTit:aCols:= aSort(oGetTit:aCols,,,{|x,y| x[nPSaldoE2] < y[nPSaldoE2]})

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณExecuta o calculo das baixas.                  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
For nI:= 1 To Len(oGetTit:aCols)
	If !oGetTit:aCols[nI,Len(oGetTit:aHeader)+1]
		nValAux:= IIf(oGetTit:aCols[nI,nPSaldoE2] <= nSaldo,oGetTit:aCols[nI,nPSaldoE2],nSaldo)
		oGetTit:aCols[nI,nPValorE2]:= Round(nValAux,2)
		nSaldo-= nValAux
	EndIf
Next nI

aCols3:= {}
For nI:= 1 To Len(oGetTit:aCols)
	If !oGetTit:aCols[nI,Len(oGetTit:aHeader)+1]
		nSaldoBX:= oGetTit:aCols[nI,nPValorE2]
		For nX:= 1 To Len(oGetChq:aCols)
			If !oGetChq:aCols[nX,Len(oGetChq:aHeader)+1] .And. !Empty(oGetChq:aCols[nX,nPBancoZ1])
				
				aAdd(aCols3,Array(Len(aHeader3)+1))
				nZ:= Len(aCols3)
				For nY:= 1 To Len(aHeader3)
					aCols3[nZ,nY] := CriaVar(aHeader3[nY,2],IIf(aHeader3[nY,10] == "V",.T.,.F.))
				Next nY
				
				nValAux:= NoRound(oGetChq:aCols[nX,nPValorZ1] * ((oGetTit:aCols[nI,nPValorE2]*100)/nTotChq) / 100,2)
				nSaldoBX-= nValAux
				
				aCols3[nZ,nPValorZ4]  := nValAux
				aCols3[nZ,nPPrefixoZ4]:= oGetTit:aCols[nI,nPPrefixoE2]
				aCols3[nZ,nPNumZ4]    := oGetTit:aCols[nI,nPNumE2]
				aCols3[nZ,nPParcelaZ4]:= oGetTit:aCols[nI,nPParcelaE2]
				aCols3[nZ,nPTipoZ4]   := oGetTit:aCols[nI,nPTipoE2]
				aCols3[nZ,nPVencReaZ4]:= oGetTit:aCols[nI,nPVencReaE2]
				aCols3[nZ,nPValTitZ4] := oGetTit:aCols[nI,nPValTitE2]
				aCols3[nZ,nPSaldoZ4]  := oGetTit:aCols[nI,nPSaldoE2]
				aCols3[nZ,nPForneceZ4]:= oGetTit:aCols[nI,nPForneceE2]
				aCols3[nZ,nPLojaZ4]   := oGetTit:aCols[nI,nPLojaE2]
				aCols3[nZ,nPBancoZ4]  := oGetChq:aCols[nX,nPBancoZ1]
				aCols3[nZ,nPAgenciaZ4]:= oGetChq:aCols[nX,nPAgZ1]
				aCols3[nZ,nPContaZ4]  := oGetChq:aCols[nX,nPContaZ1]
				aCols3[nZ,nPChequeZ4] := oGetChq:aCols[nX,nPChequeZ1]
				aCols3[nZ,Len(aHeader3)+1] := .F.
				
			EndIf
		Next nX
		
		If (nSaldoBX <> 0)
			aCols3[nZ,nPValorZ4]+= nSaldoBX
		EndIf
	EndIf
Next nI

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ Get001Mark   ณ Autor ณ Fabio Rogerio Pereira ณ Data ณ 04/05/01 ณฑฑ                                                     ฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Marca o titulo que sera baixado                                ณฑฑ                                                            ฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function Get001Mark(cAlias)
Local cMarca

cMarca :=GetMark()
While cMarca == "xx"
	cMarca := Getmark()
Enddo

If (cAlias == "SE1")
	RecLock("SE1",.F.)
	Replace E1_OK With cMarca
	MsUnLock()
ElseIf (cAlias == "SE2")
	RecLock("SE2",.F.)
	Replace E2_OK With cMarca
	MsUnLock()
EndIf

Return(cMarca)


Static Function Get070Mark()
Local cMarca

cMarca :=GetMark()
While cMarca == "xx"
	cMarca := Getmark()
End
Return cMarca


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณA001ValCompบAutor  ณMicrosiga           บ Data ณ  08/02/04  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica o valor comprometido                               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function A001ValComp(cTitulo,cCheque)
Local aAreaZ3 := SZ3->(GetArea())
Local nValComp:= 0

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณValida se o saldo do titulo ja esta comprometido com outros cheques.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
dbSelectArea("SZ3")
dbSetOrder(2)
dbSeek(xFilial("SZ3")+cTitulo)
While !Eof() .And. (xFilial("SZ3")+cTitulo == SZ3->(Z3_FILIAL+Z3_PREFIXO+Z3_NUM+Z3_PARCELA+Z3_TIPO))
	If (SZ3->(Z3_BANCO+Z3_AGENCIA+Z3_CONTA+Z3_CHEQUE) == cCheque) .Or. A001TemDev(SZ3->(Z3_BANCO+Z3_AGENCIA+Z3_CONTA+Z3_CHEQUE))
		dbSkip()
		Loop
	EndIf
	
	If Empty(SZ3->Z3_BAIXA)
		nValComp+= SZ3->Z3_VALOR
	EndIf
	
	dbSelectArea("SZ3")
	dbSkip()
End

RestArea(aAreaZ3)
Return(nValComp)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณA001ValFor บAutor  ณMicrosiga           บ Data ณ  16/08/04  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณValida o fornecedor                                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function A001ValFor()

cLoja:= SA2->A2_LOJA
cSayForn:= SA2->A2_NOME

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno	 ณA001BXRepasseณ Autor ณ Wagner Xavier 		   ณ Data ณ 25/08/04 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Funo utilizada para Baixa de Titulos a Pagar				 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe	 ณ A001BXRepasse												 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso		 ณ Generico 													 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function A001BXRepasse(cMotBX,cBcoDep,cAgDep,cCCDep,cHist,aBaixa,l2Pag,nValBx)
Local cTpDoc    := ""
Local cMarca    := ""
Local cSequencia:= "01"
Local aTipoSeq  := {}
Local aArea     := GetArea()
Local nLaco     := 0
Local nAtraso   := 0
Local nSalDup   := 0
Local nRecNo    := 0
Local lFina390  := IIf(SE2->E2_IMPCHEQ == "S",.T.,.F.)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica o saldo do titulo.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nValBx:= aBaixa[5]
If (aBaixa[5] > SE2->E2_SALDO)
	If (SE2->E2_ACRESC > 0)
		nValBx   := aBaixa[5] - SE2->E2_ACRESC
		aBaixa[5]:= nValBx
	Else
		Return(.F.)
	EndIf
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Atualiza a baixa do titulo									 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cMarca  := Get001Mark("SE2")
If (aBaixa[5] > 0)
	RecLock("SE2",.F.)
	Replace E2_BAIXA	With IIf(SE2->E2_BAIXA <= dDatabase, dDatabase, SE2->E2_BAIXA)
	Replace E2_MOVIMEN  With dDatabase
	Replace E2_VALLIQ   With aBaixa[5]
	Replace E2_SDACRES  With 0
	Replace E2_SDDECRE  With 0
	Replace E2_BCOPAG   With cBcoDep
	Replace E2_OK		With Iif(E2_OK==cMarca,"xx" ,E2_OK)
	Replace E2_SALDO	With SE2->E2_SALDO - aBaixa[5]
	Replace E2_DESCONT	With 0
	MsUnLock()
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Para numerar as sequencias o sistema precisa procurar os   ณ
	//ณ registros com  tipodoc igual a vl ou ba.				   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	aTipoSeq := { "VL","BA","CP" }
	dbSelectArea("SE5")
	SE5->(dbSetOrder(2))
	For nLaco := 1 to len(aTipoSeq)
		SE5->(dbSeek(xFilial("SE5") + aTipoSeq[nLaco] + SE2->E2_PREFIXO + SE2->E2_NUM + ;
		SE2->E2_PARCELA + SE2->E2_TIPO) )
		
		While !SE5->(Eof()) .And. ;
			SE5->E5_FILIAL == xFilial("SE5") .And. ;
			SE5->E5_TIPODOC == aTipoSeq[nLaco] .And. ;
			SE5->E5_PREFIXO == SE2->E2_PREFIXO .And. ;
			SE5->E5_NUMERO == SE2->E2_NUM .And. ;
			SE5->E5_PARCELA == SE2->E2_PARCELA .And. ;
			SE5->E5_TIPO == SE2->E2_TIPO
			
			If SE5->E5_CLIFOR <> SE2->E2_FORNECE .or. ;
				SE5->E5_LOJA <> SE2->E2_LOJA
				dbskip()
				Loop
			EndIf

			cSequencia:= Soma1(AllTrim(SE5->E5_SEQ),2)
			SE5->( dbSkip() )
		Enddo
	Next         
	
	cTpDoc := Iif(MovBcoBx(cMotBx, .T.),"VL","BA")
	RecLock("SE5",.T.)
	SE5->E5_FILIAL 	:= xFilial("SE5")
	SE5->E5_BANCO	:= cBcoDep
	SE5->E5_AGENCIA	:= cAgDep
	SE5->E5_CONTA	:= cCCDep
	SE5->E5_DATA	:= dDatabase
	SE5->E5_HISTOR 	:= cHist
	SE5->E5_VALOR	:= aBaixa[5]
	SE5->E5_VLDESCO	:= 0
	SE5->E5_NATUREZ	:= SE2->E2_NATUREZ
	SE5->E5_RECPAG 	:= "P"
	SE5->E5_TIPO	:= SE2->E2_TIPO
	SE5->E5_LA		:= "N"
	SE5->E5_TIPODOC	:= cTpDoc
	SE5->E5_PREFIXO	:= SE2->E2_PREFIXO
	SE5->E5_NUMERO 	:= SE2->E2_NUM
	SE5->E5_PARCELA	:= SE2->E2_PARCELA
	SE5->E5_CLIFOR 	:= SE2->E2_FORNECE
	SE5->E5_LOJA	:= SE2->E2_LOJA
	SE5->E5_BENEF	:= SE2->E2_NOMFOR
	SE5->E5_DTDIGIT	:= dDataBase
	SE5->E5_MOTBX	:= TrazCodMot(cMotBx)
	SE5->E5_SEQ 	:= cSequencia
	SE5->E5_DTDISPO	:= E5_DATA
	SE5->E5_NUMCHEQ := aBaixa[4]
	MsUnLock()
	
EndIf

AtuSalBco( cBcoDep, cAgDep, cCCDep, dDatabase, aBaixa[5], "-" )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Atualiza o Cadastro de Fornecedores						     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
SED->( dbSeek ( cFilial + SE2 -> E2_NATUREZ ) )
IF SA2->( dbSeek(cFilial+SE2->E2_FORNECE+SE2->E2_LOJA) )
	RecLock("SA2")
	If SE2->E2_MOEDA > 1
		//Acho valor em dolares para converter para real na data de emissao
		nSalDup := Round(NoRound(xMoeda(aBaixa[5],1,SE2->E2_MOEDA,dDatabase,3),3),2)
		//Acho valor em reais na data da emissao
		nSalDup := Round(NoRound(xMoeda(nSalDup,SE2->E2_MOEDA,1,SE2->E2_EMISSAO,3),3),2)
	Else
		nSalDup := aBaixa[5]
	Endif
	If SE2->E2_TIPO $ MVPAGANT+"/"+MV_CPNEG
		SA2->A2_SALDUP	+= nSalDup
		SA2->A2_SALDUPM	+= xMoeda(nSaldup,1,Val(GetMv("MV_MCUSTO")),SE2->E2_EMISSAO)
	Else
		SA2->A2_SALDUP	-= nSalDup
		SA2->A2_SALDUPM	-= xMoeda(nSaldup,1,Val(GetMv("MV_MCUSTO")),SE2->E2_EMISSAO)
	Endif
	nAtraso:=dDatabase-SE2->E2_VENCTO
	If nAtraso > 1
		IF Dow(SE2->E2_VENCTO) == 1 .Or. Dow(SE2->E2_VENCTO) == 7
			IF Dow(dDatabase) == 2 .and. nAtraso <= 2
				nAtraso := 0
			EndIF
		EndIF
		nAtraso:=IIF(nAtraso<0,0,nAtraso)
		If SA2->A2_MATR < nAtraso
			Replace A2_MATR With nAtraso
		EndIf
	Endif
	SA2->(MSUnlock())	// Destrava SA2 apos alteracoes...
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Caso exista cheque j  relacionado anteriormente para este    ณ
//ณ titulo, atualiza sequencia .								 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lFina390	
	dbSelectArea("SEF")
	dbSetOrder(1)
	If dbSeek(xFilial("SEF")+cBcoDep+cAgDep+cCCDep+aBaixa[4])
		RecLock("SEF",.F.)
		SEF->EF_SEQUENC := cSequencia
		MsUnLock()
	Endif
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Atualiza o Cadastro de Cheques Emitidos, se for em Banco						ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If MovBcoBx(cMotBx, .T.) .And. l2Pag .And. TrazCodMot(cMotBx) != "DEB" .And. ChqMotBx(cMotBx)
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Se for cheque pre-datado, nao cria novo cheque, pois este ja'          ณ
	//ณ foi criado quando da emissao do pre'datado.                            ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If aBaixa[5] > 0 .And. SE2->E2_IMPCHEQ != "S" .And.;
			!cBcoDep $ Left(GetMv("MV_CXFIN"),3) .And. !cBcoDep $ GetMv("MV_CARTEIR")
		RecLock("SEF",.T.)
		SEF->EF_FILIAL 	:= xFilial("SEF")
		SEF->EF_NUM 	:= aBaixa[4]
		SEF->EF_BANCO	:= cBcoDep
		SEF->EF_AGENCIA	:= cAgDep
		SEF->EF_CONTA	:= cCCDep
		SEF->EF_VALOR	:= aBaixa[5]
		SEF->EF_DATA	:= dDatabase
		SEF->EF_BENEF	:= SE2->E2_NOMFOR
		SEF->EF_PORTADO := ""
		SEF->EF_HIST	:= "2. Pagamento a Fornecedor"
		SEF->EF_PREFIXO := SE2->E2_PREFIXO
		SEF->EF_TITULO  := SE2->E2_NUM
		SEF->EF_PARCELA := SE2->E2_PARCELA
		SEF->EF_FORNECE := SE2->E2_FORNECE
		SEF->EF_LOJA	:= SE2->E2_LOJA
		SEF->EF_TIPO	:= SE2->E2_TIPO
		SEF->EF_IMPRESS := IIf(Subs(aBaixa[4],1,1)="*","A"," ")
		SEF->EF_SEQUENC := cSequencia
		SEF->EF_ORIGEM  := "EFA001"
	Endif

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Atualiza o totalizador																 ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If SubStr(aBaixa[4],1,1) = "*" .And. aBaixa[5] > 0 .And. SE2->E2_IMPCHEQ != "S"
		dbSelectArea("SEF")
		SEF->( dbSeek(xFilial("SEF")+cBcoDep+cAgDep+cCCDep+aBaixa[4]+cSequencia) )
		nRecNo := 0
		While !SEF->( Eof() )	.And. SEF->EF_FILIAL	 =	 cFilial  ;
				.And. SEF->EF_BANCO	 	=  cBcoDep	 ;
				.And. SEF->EF_AGENCIA 	=  cAgDep ;
				.And. SEF->EF_CONTA		=  cCCDep	 ;
				.And. SEF->EF_NUM 	 	=  aBaixa[4]
			nRecNo := IIf(Empty(SEF->EF_TITULO),SEF->(RecNo()),nRecNo)
			dbSkip( )
		Enddo                
		
		If nRecNo == 0 .And. !cBcoDep $ Left(GetMv("MV_CXFIN"),3) .And. !cBcoDep $ GetMv("MV_CARTEIR")
			RecLock("SEF",.T.)
			SEF->EF_FILIAL  := xFilial("SEF")
			SEF->EF_NUM 	:= aBaixa[4]
			SEF->EF_BANCO	:= cBcoDep
			SEF->EF_AGENCIA := cAgDep
			SEF->EF_CONTA	:= cCCDep
			SEF->EF_VALOR	:= aBaixa[5]
			SEF->EF_DATA	:= dDatabase
			SEF->EF_BENEF	:= SA6->A6_NOME
			SEF->EF_SEQUENC := "01"
			SEF->EF_ORIGEM  := "EFA001"
		Else
			dbGoTo( nRecNo )
			RecLock("SEF")
			SEF->EF_VALOR	+= aBaixa[5]
			SEF->EF_DATA	:= dDatabase
		Endif
	Endif
Endif

RestArea(aArea)

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno	 ณA001CPJuros  ณ Autor ณ Wagner Xavier 		   ณ Data ณ 25/08/04 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Funo utilizada para Baixa de Titulos a Pagar				 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe	 ณ A001CPJuros  												 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso		 ณ Generico 													 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function A001CPJuros(nValor,cBcoDep,cAgDep,cCCDep,cMotBX)
Local aArea     := GetArea()
Local nSaldo    := 0
Local cSequencia:= "01"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica a sequencia correta. ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Para numerar as sequencias o sistema precisa procurar os   ณ
//ณ registros com  tipodoc igual a JR.      				   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
dbSelectArea("SE5")
SE5->(dbSetOrder(2))
SE5->(dbSeek(xFilial("SE5") + "JR" + SE2->E2_PREFIXO + SE2->E2_NUM + ;
SE2->E2_PARCELA + SE2->E2_TIPO) )

While !SE5->(Eof()) .And. ;
	SE5->E5_FILIAL  == xFilial("SE5") .And. ;
	SE5->E5_TIPODOC == "JR" .And. ;
	SE5->E5_PREFIXO == SE2->E2_PREFIXO .And. ;
	SE5->E5_NUMERO  == SE2->E2_NUM .And. ;
	SE5->E5_PARCELA == SE2->E2_PARCELA .And. ;
	SE5->E5_TIPO    == SE2->E2_TIPO
	
	If SE5->E5_CLIFOR <> SE2->E2_FORNECE .or. ;
		SE5->E5_LOJA <> SE2->E2_LOJA
		dbskip()
		Loop
	EndIf

	cSequencia:= Soma1(AllTrim(SE5->E5_SEQ),2)
	SE5->( dbSkip() )
Enddo

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Atualiza a baixa do titulo							         ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
RecLock("SE5",.T.)
SE5-> E5_FILIAL 	:= xFilial("SE5")
SE5-> E5_BANCO		:= cBcoDep
SE5-> E5_AGENCIA	:= cAgDep
SE5-> E5_CONTA		:= cCCDep
SE5-> E5_DATA		:= dDatabase
SE5-> E5_HISTOR 	:= "Juros Pagos S/ Titulo"
SE5-> E5_VALOR		:= nValor
SE5-> E5_NATUREZ	:= SE2->E2_NATUREZ
SE5-> E5_RECPAG 	:= "P"
SE5-> E5_TIPO		:= SE2->E2_TIPO
SE5-> E5_LA			:= "N"
SE5-> E5_TIPODOC	:= "JR"
SE5-> E5_PREFIXO	:= SE2->E2_PREFIXO
SE5-> E5_NUMERO 	:= SE2->E2_NUM
SE5-> E5_PARCELA	:= SE2->E2_PARCELA
SE5-> E5_CLIFOR 	:= SE2->E2_FORNECE
SE5-> E5_LOJA		:= SE2->E2_LOJA
SE5-> E5_BENEF		:= SE2->E2_NOMFOR
SE5-> E5_DTDIGIT	:= dDataBase
SE5-> E5_MOTBX		:= TrazCodMot(cMotBx)
SE5->E5_SEQ 		:= cSequencia
SE5->E5_DTDISPO	    := E5_DATA
MsUnLock()

RestArea(aArea)

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno	 ณA001BXCR     ณ Autor ณ Wagner Xavier 		   ณ Data ณ 25/08/04 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Funo utilizada para Baixa de Titulos a Receber				 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe	 ณ A001BXCR     												 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso		 ณ Generico 													 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function A001BXCR(cMotBX,cBcoDep,cAgDep,cCCDep,cHist,aBXCR)
Local lRet      := .F.
Local cTpDoc    := ""
Local cMarca    := ""
Local cSequencia:= "01"
Local aTipoDoc  := {}
Local aArea     := GetArea()
Local nLaco     := 0
Local nAtraso   := 0
Local nSalDup   := 0
Local nRetencao := 0
Local dDataDisp := 0
Local nCont     := 0
Local nSE1Rec   := 0
Local i         := 0
Local nSaldoTit := 0
Local aBaixas   := {}

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณValida o banco.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
dbSelectArea("SA6")
dbSetOrder(1)
If !dbSeek(xFilial("SA6")+cBcoDep+cAgDep+cCCDep)
	Return(.F.)
EndIf


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica o saldo do titulo.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If (aBXCR[5] > SE1->E1_SALDO)
	Return(.F.)
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Atualiza a baixa do titulo									 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cMarca  := Get001Mark("SE1")
If (aBXCR[5] > 0) .Or. (aBXCR[6] > 0)
	
	nSaldoTit:= SE1->E1_SALDO - aBXCR[5] - aBXCR[6]
	RecLock("SE1",.F.)
	nSE1Rec := Recno()
	Replace E1_BAIXA   With If(E1_BAIXA <= dDatabase, dDatabase, E1_BAIXA)
	Replace E1_MOVIMEN With dDatabase
	Replace E1_DESCONT With aBXCR[6]
	Replace E1_MULTA   With 0
	Replace E1_JUROS   With 0
	Replace E1_CORREC  With 0
	Replace E1_VALLIQ  With aBXCR[5]
	Replace E1_OK	   With Iif(E1_OK == cMarca,"xx",cMarca)
	Replace E1_SALDO   With IIf(nSaldoTit <= 0,0,nSaldoTit)
	Replace E1_SDACRES With 0
	Replace E1_SDDECRE With 0
	Replace E1_STATUS  With IIf(E1_SALDO>0.01,"A","B")
	MsUnLock()
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Para numerar as sequencias o sistema precisa procurar os   ณ
	//ณ registros com  tipodoc igual a vl ou ba.				   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Localiza a sequencia da baixa ( CP,BA,VL,V2,LJ )			 ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	aTipoDoc := {"CP","BA","VL","V2","LJ"}
	
	SE5->(dbSetOrder(2))
	For I:= 1 to len(aTipoDoc)
		SE5->(dbSeek(xFilial("SE5") + aTipoDoc[I] + SE1->E1_PREFIXO + SE1->E1_NUM + ;
		SE1->E1_PARCELA + SE1->E1_TIPO) )
		While !SE5->(Eof())						.And. ;
			SE5->E5_FILIAL  == xFilial("SE5")	.And. ;
			SE5->E5_TIPODOC == aTipoDoc[I]     .And. ;
			SE5->E5_PREFIXO == SE1->E1_PREFIXO .And. ;
			SE5->E5_NUMERO  == SE1->E1_NUM		.And. ;
			SE5->E5_PARCELA == SE1->E1_PARCELA .And. ;
			SE5->E5_TIPO	== SE1->E1_TIPO
		
			cSequencia:= Soma1(AllTrim(SE5->E5_SEQ),2)
		
			SE5->(dbSkip())
		EndDo
	Next I
	
	cTpDoc  :=Iif(SE1->E1_SITUACA$"27","V2","VL")
	If !MovBcoBx(cMotBx,.T.) .And. !SE1->E1_SITUACA$"27"
		cTpDoc := "BA"
	EndIf
	RecLock("SE5",.T.)
	SE5->E5_FILIAL	  	:= xFilial("SE5")
	SE5->E5_BANCO	  	:= cBcoDep
	SE5->E5_AGENCIA		:= cAgDep
	SE5->E5_CONTA		:= cCCDep
	SE5->E5_DATA 	  	:= SE1->E1_BAIXA
	SE5->E5_VALOR		:= aBXCR[5]
	SE5->E5_VLDESCO		:= aBXCR[6]
	SE5->E5_NATUREZ  	:= SE1->E1_NATUREZ
	SE5->E5_RECPAG	  	:= "R"
	SE5->E5_TIPO 	  	:= SE1->E1_TIPO
	SE5->E5_LA			:= "N"
	SE5->E5_TIPODOC  	:= cTpDoc
	SE5->E5_HISTOR	  	:= cHist
	SE5->E5_PREFIXO  	:= SE1->E1_PREFIXO
	SE5->E5_NUMERO	  	:= SE1->E1_NUM
	SE5->E5_PARCELA  	:= SE1->E1_PARCELA
	SE5->E5_CLIFOR	  	:= SE1->E1_CLIENTE
	SE5->E5_LOJA 	  	:= SE1->E1_LOJA
	SE5->E5_BENEF	  	:= SE1->E1_NOMCLI
	SE5->E5_DTDIGIT  	:= dDataBase
	SE5->E5_MOTBX	  	:= TrazCodMot( cMotBx )
	SE5->E5_VLMOED2  	:= Round(xMoeda(aBXCR[5],1,SE1->E1_MOEDA,dDatabase,4),2)
	SE5->E5_SEQ		  	:= cSequencia
	SE5->E5_NUMCHEQ     := aBXCR[4]
	
	//	Data de disponibilizacao -> considera dias de retencao
	nRetencao 		  	:= SA6->A6_RETENCAO
	dDataDisp 		  	:= SE5->E5_DATA
	If nRetencao > 0
		For nCont := 1 To nRetencao
			dDataDisp := DataValida(dDataDisp+1,.T.)
		Next nCont
	EndIf
	SE5->E5_DTDISPO := dDataDisp
	
	MsUnLock()
	aadd(aBaixas,{SE5->E5_MOTBX,SE5->E5_SEQ,SE5->(Recno())})
	
	IF (SE1->E1_SITUACA != "2" .And. SE1->E1_SITUACA != "7") .And. MovBcoBx(cMotBx, .T.)
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Gravar Saldo Banc rio 						  		         ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		AtuSalBco(cBcoDep,cAgDep,cCCDep,dDataDisp,aBXCR[5],"+")
	EndIf
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Posiciona no registro de natureza							 ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	dbSelectArea("SED")
	dbSeek(xFilial("SED")+SE1->E1_NATUREZ)
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Atualiza o Cadastro de Clientes 							 ณ
	//ณ A pesquisa pelo SL1 e' do Loja no caso de adm <> "R$/CH"     ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	dbSelectArea("SA1")
	DbSetOrder(1)
	If dbSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA)
		RecLock("SA1")
		AtuSalDup("-",aBXCR[5],1,SE1->E1_TIPO,,SE1->E1_EMISSAO)
		RecLock("SA1")
		Replace A1_NROPAG With A1_NROPAG+1  //Numero de Duplicatas
		
		nAtraso:= dDatabase-SE1->E1_VENCTO
		If nAtraso > 1
			IF Dow(SE1->E1_VENCTO) == 1 .Or. Dow(SE1->E1_VENCTO) == 7
				IF Dow(dDatabase) == 2 .And. nAtraso <= 2
					nAtraso := 0
				EndIF
			EndIF
			
			nAtraso:=IIF(nAtraso<0,0,nAtraso)
			If SA1->A1_MATR < nAtraso
				Replace A1_MATR With nAtraso
			EndIf
		Endif
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Atualiza Atraso Mdio.  Revisao em 07/12/95					     ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If (SE1->E1_BAIXA - SE1->E1_VENCREA) > 0
			SA1->A1_PAGATR := A1_PAGATR+SE1->E1_VALLIQ   // Pagamentos Atrasados
			SA1->A1_ATR	   := IIF(A1_ATR==0,0,IIF(A1_ATR < SE1->E1_VALLIQ,0,A1_ATR - SE1->E1_VALLIQ)) //  Titulos em Atraso
		Endif
		
		SA1->A1_METR	 :=	(A1_METR * (A1_NROPAG-1) + (SE1->E1_BAIXA - SE1->E1_VENCREA)) / (A1_NROPAG)
		
		If GETMV("MV_TPCOMIS") == "O"  .and. ComisBx( TrazCodMot(cMotBx) )
			Fa440CalcB(aBaixas,.F.,.F.,"FINA070",,,,.T.,nSE1Rec)
		Endif
		
		SA1->(MsUnlock())	// Destrava SA1 apos alteracoes...
	EndIf
	lRet:= .T.
EndIf


RestArea(aArea)

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno	 ณA001CRJuros  ณ Autor ณ Wagner Xavier 		   ณ Data ณ 25/08/04 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Funo utilizada para Juros de Titulos a Receber				 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe	 ณ A001CRJuros  												 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso		 ณ Generico 													 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function A001CRJuros(nValor,cBcoDep,cAgDep,cCCDep,cMotBX)
Local aArea     := GetArea()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAumenta saldo para nao ficar negativo.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
RecLock("SE1",.F.)
Replace E1_SALDO With SE1->E1_SALDO+nValor
MsUnLock()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Atualiza a baixa do titulo							         ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
RecLock("SE5",.T.)
SE5-> E5_FILIAL 	:= xFilial("SE5")
SE5-> E5_BANCO		:= cBcoDep
SE5-> E5_AGENCIA	:= cAgDep
SE5-> E5_CONTA		:= cCCDep
SE5-> E5_DATA		:= dDatabase
SE5-> E5_HISTOR 	:= "Juros Recebidos S/ Titulo"
SE5-> E5_VALOR		:= nValor
SE5-> E5_NATUREZ	:= SE1->E1_NATUREZ
SE5-> E5_RECPAG 	:= "R"
SE5-> E5_TIPO		:= SE1->E1_TIPO
SE5-> E5_LA			:= "N"
SE5-> E5_TIPODOC	:= "JR"
SE5-> E5_PREFIXO	:= SE1->E1_PREFIXO
SE5-> E5_NUMERO 	:= SE1->E1_NUM
SE5-> E5_PARCELA	:= SE1->E1_PARCELA
SE5-> E5_CLIFOR 	:= SE1->E1_CLIENTE
SE5-> E5_LOJA		:= SE1->E1_LOJA
SE5-> E5_BENEF		:= SE1->E1_NOMCLI
SE5-> E5_DTDIGIT	:= dDataBase
SE5-> E5_MOTBX		:= TrazCodMot(cMotBx)
SE5->E5_SEQ 		:= "01"
SE5->E5_DTDISPO	    := E5_DATA
MsUnLock()

RestArea(aArea)

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณEF2BXRECTitW Autorณ Wagner Xavier         ณ Data ณ 26/05/92 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Funo utilizada para Baixa de Titulos - Windows           ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ EF2BXRECTitW()                                             ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ Genrico                                                   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function EF2BXRECTitW(nValor,cBanco,cAgencia,cConta)

Local nOpca
Local lBaixou  	:= .F.
Local oDlgLote
Local oTitulo
Local oEmissao
Local oVencRea
Local oNomeCli
Local oHist
Local oSituacao
Local oBanco
Local oAgencia
Local oConta
Local oBaixa
Local oHistBx
Local oMotBx
Local oValRec
Local oPortado        
Local oSaldo
Local oDesconto
Local aMotBx     := ReadMotBx()
Local aDescMotBx := {}
Local dEmissao   := 0
Local dVencRea   := 0
Local cTitulo    := ""
Local cNomeCli   := ""
Local cHist	     := ""
Local cSituacao  := ""
Local cPortado   := ""
Local cHistBx    := ""
Local cMotBx	 := ""
Local nSaldo     := nValor
Local nDesconto  := 0

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Retorna o Array aDescMotbx contendo apenas a descricao do	ณ
//ณ motivo das Baixas. 						  								ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If Len( aDescMotbx ) ==0
	For NI := 1 to Len(aMotBx)
		If Substr(aMotBx[nI],34,01) == "A" .or. Substr(aMotBx[nI],34,01) =="R"
			AADD( aDescMotbx,Substr(aMotBx[nI],07,10))
		EndIf
	Next
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPosiciona Cliente no SA1 		                                    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
SA1->(dbSetOrder(1))
SA1->(dbSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA))

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCarrega Variaveis da Baixa                                           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
dBaixa    := CriaVar("E1_BAIXA")
cTitulo   := SE1->E1_PREFIXO + " " + SE1->E1_NUM + " " + SE1->E1_PARCELA
dEmissao  := SE1->E1_EMISSAO
dVencRea  := SE1->E1_VENCREA
cNomeCli  := SE1->E1_CLIENTE + " - " + Subst(SA1->A1_NOME,1,40)
cHist	  := SE1->E1_HIST
cSituacao := Transform( SE1->E1_SITUACA,"9" ) + " " + fa070situa()
cBanco	  := IIf( SE1->E1_SITUACA == "0", aCaixaFin[1], SE1->E1_PORTADO )
cAgencia  := IIf( SE1->E1_SITUACA == "0", aCaixaFin[2], SE1->E1_AGEDEP )
cConta	  := IIf( SE1->E1_SITUACA == "0", aCaixaFin[3], SE1->E1_CONTA )
cHistBx   := IIf(Empty(Criavar("E5_HISTOR")),OemToAnsi("Valor recebido s/ Tกtulo"),Criavar("E5_HISTOR"))		//Inicilizador padrao
cMotBx	  := aDescMotBx[1] 	//NORMAL


DEFINE MSDIALOG oDlgLote FROM	31,15 TO 350,574 TITLE OemToAnsi("Baixas a Receber")  PIXEL OF oMainWnd //
@ 01, 002 TO 035, 278 LABEL OemToAnsi("Principal") OF oDlgLote  PIXEL //
@ 37, 001 TO 155, 137 LABEL OemToAnsi("Dados Gerais") OF oDlgLote  PIXEL //
@ 38, 143 TO 155, 278 LABEL OemToAnsi("Valores da Baixa") OF oDlgLote  PIXEL //

@ 010, 010 SAY OemToAnsi("Tกtulo")		SIZE 18,07 OF oDlgLote PIXEL // 
@ 008, 030 MSGET oTitulo VAR cTitulo	SIZE 57,10 OF oDlgLote PIXEL When .F.

@ 010, 095 SAY OemToAnsi("Emisso")		SIZE 31,07 OF oDlgLote PIXEL //
@ 008, 127 MSGET oEmissao VAR dEmissao SIZE 35,10 OF oDlgLote PIXEL When .F.

@ 010, 169 SAY OemToAnsi("Vencto.Atual") SIZE 39,07 OF oDlgLote PIXEL //
@ 008, 210 MSGET oVencRea VAR dVencRea   SIZE 31,10 OF oDlgLote PIXEL When .F.

@ 022, 005 SAY OemToAnsi("Cliente")		SIZE 22,07 OF oDlgLote PIXEL //
@ 020, 030 MSGET oNomeCli VAR cNomeCli	SIZE 211,9 OF oDlgLote PIXEL When .F.

@ 046, 007 SAY OemToAnsi("Hist.Emisso")	SIZE 38,07 OF oDlgLote PIXEL //
@ 043, 050 MSGET oHist VAR cHist			SIZE 84,10 OF oDlgLote PIXEL When .F.

@ 057, 007 SAY OemToAnsi("Portador")	SIZE 39,07 OF oDlgLote PIXEL //
@ 056, 050 MSGET oPortado VAR cPortado	SIZE 84,10 OF oDlgLote PIXEL When .F.

@ 069, 007 SAY OemToAnsi("Mot.Baixa") SIZE 37,07 OF oDlgLote PIXEL //
@ 068, 050 COMBOBOX oMotBx VAR cMotBx ITEMS aDescMotbx SIZE 84,47 OF oDlgLote PIXEL

@ 081, 007 SAY OemToAnsi("Banco")		SIZE 40,07 OF oDlgLote PIXEL //
@ 080, 050 MSGET oBanco VAR cBanco 		SIZE 22,10 OF oDlgLote PIXEL F3 "SA6" When MovBcoBx( cMotBx, .T. ) Valid ;
	CarregaSA6(@cBanco,,,.T.)

@ 093, 007 SAY OemToAnsi("Agncia")		SIZE 39,07 OF oDlgLote PIXEL //
@ 092, 050 MSGET oAgencia VAR cAgencia	SIZE 35,09 OF oDlgLote PIXEL When MovBcoBx( cMotBx, .T. ) Valid ;
	CarregaSA6(@cBanco,@cAgencia,,.T.)

@ 105, 007 SAY OemToAnsi("Conta")		SIZE 41,07 OF oDlgLote PIXEL //
@ 104, 050 MSGET oConta VAR cConta 		SIZE 84,10 OF oDlgLote PIXEL When MovBcoBx( cMotBx, .T. ) Valid ;
	CarregaSA6(@cBanco,@cAgencia,@cConta,.T.)

@ 117, 007 SAY OemToAnsi("Data Recebto.")	SIZE 38,07 OF oDlgLote PIXEL //
@ 116, 050 MSGET oBaixa VAR dBaixa 		SIZE 39,09 OF oDlgLote PIXEL Valid dBaixa >= SE2->E2_EMISSAO .And. DtMovFin(dBaixa)

@ 129, 007 SAY OemToAnsi("Hist.Baixa")	SIZE 39,07 OF oDlgLote PIXEL //
@ 128, 050 MSGET oHistBx VAR cHistBx	SIZE 84,10 OF oDlgLote PIXEL Picture "@!" When VisualSX3("E5_HISTOR")

@ 046, 150 SAY OemToAnsi("Saldo")	SIZE 53,07 OF oDlgLote PIXEL //
@ 043, 190 MSGET oSaldo VAR nSaldo SIZE 66,10 OF oDlgLote PIXEL Picture PesqPict("SE2","E2_VALLIQ") WHEN .F.

@ 057, 150 SAY OemToAnsi("Desconto")	SIZE 53,07 OF oDlgLote PIXEL //
@ 056, 190 MSGET oDesconto VAR nDesconto SIZE 66,10 OF oDlgLote PIXEL Picture PesqPict("SE2","E2_VALLIQ") VALID A001Desconto(nSaldo,@nValor,@nDesconto,@oValor,@oDesconto)

@ 069, 150 SAY OemToAnsi("Valor Recebido")	SIZE 53,07 OF oDlgLote PIXEL //
@ 068, 190 MSGET oValor VAR nValor	SIZE 66,10 OF oDlgLote PIXEL Picture PesqPict("SE2","E2_VALLIQ") VALID A001Valor(nSaldo,@nValor,@nDesconto,@oValor,@oDesconto)
	
DEFINE SBUTTON FROM 06, 246 TYPE 1 ENABLE OF oDlgLote ACTION ( IIf(A001ValBco(cMotBx,cBanco,cAgencia,cConta),(nOpca := 1, oDlgLote:End()),""))

DEFINE SBUTTON FROM 20, 246 TYPE 2 ENABLE OF oDlgLote ACTION ( nOpca := 0 ,oDlgLote:End())

ACTIVATE MSDIALOG oDlgLote CENTERED 

If (nOpca == 1)                                                                         
	lBaixou:= U_EF2RECGRV(cMotBx,cBanco,cAgencia,cConta,cHistBx,nValor,dBaixa,nDesconto)
EndIf

Return lBaixou


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณEF2RECGRV บAutor  ณMicrosiga           บ Data ณ  09/28/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGrava o segundo recebimento                                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function EF2RECGRV(cMotBx,cBanco,cAgencia,cConta,cHistBx,nValor,dBaixa,nDesconto)
Local lBaixou:= .F.

If !DtMovFin(dBaixa)
	Return .F.
EndIf

If Empty( cMotBx )
	cMotBx := aDescMotBx[1]  //"NORMAL"
Endif

Begin Transaction
	If (nDesconto> 0)
		U_A001CRDesconto(nDesconto,cBanco,cAgencia,cConta,cMotBX)
	EndIf
	
	lBaixou := U_A001BXCR(cMotBx,cBanco,cAgencia,cConta,cHistBx,{"","","","",nValor,nDesconto})

End Transaction

Return(lBaixou)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณEF2BXPAGTitW Autorณ Wagner Xavier         ณ Data ณ 26/05/92 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Funo utilizada para Baixa de Titulos - Windows           ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ EF2BXPAGTitW                                               ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ Genrico                                                   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function EF2BXPAGTitW(nValor,cBanco,cAgencia,cConta,cCheque)

LOCAL oDlgLote
LOCAL oTitulo
LOCAL oBaixa
LOCAL oHist	
LOCAL oHistBx	
LOCAL oMotBx	
LOCAL oValPgto
LOCAL oBenef
Local oPortado        
Local oBanco
Local oAgencia
Local oConta
Local oCheque
Local oDesconto
Local oSaldo
Local aMotBx	 := ReadMotBx()
Local aDescMotBx := {}
Local cBenef	 := CriaVar("E5_BENEF")
Local cNomeFor   := ""
Local cHist      := ""
Local cHistBx    := ""
Local cPortado   := ""        
Local cMotBx     := ""
Local nOpca	     := 0 
Local nI         := 0	
Local lBaixou  	 := .F.
Local dBaixa     := 0
Local dEmissao   := 0
Local dVencRea   := 0
Local nDesconto  := 0
Local nSaldo     := nValor

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Retorna o Array aDescMotbx contendo apenas a descricao do	ณ
//ณ motivo das Baixas. 						  								ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If Len( aDescMotbx ) ==0
	For nI := 1 to Len(aMotBx)
		If Substr(aMotBx[nI],34,01) == "A" .or. Substr(aMotBx[nI],34,01) =="P"
			AADD( aDescMotbx,Substr(aMotBx[nI],07,10))
		EndIf
	Next
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPosiciona Fornecedor no SA2                                          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
dbSelectArea("SA2")
SA2->(dbSeek(xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA))
dbSelectArea("SE2")

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCarrega Variaveis da Baixa                                           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
dBaixa      := CriaVar("E2_BAIXA")
cTitulo 	:= SE2->E2_PREFIXO + " " + SE2->E2_NUM + " " + SE2->E2_PARCELA
dEmissao	:= SE2->E2_EMISSAO
dVencRea	:= SE2->E2_VENCREA
cNomeFor 	:= SE2->E2_FORNECE + " - " + Subst(SA2->A2_NOME,1,40)
cHist		:= SE2->E2_HIST
cPortado	:= SE2->E2_PORTADO

cHistBx	:= Criavar("E5_HISTOR")		//Inicilizador padrao
If Empty(cHistBx)
	cHistBx:= OemToAnsi("Valor pago s/ Tกtulo")+Space(Len(cHistBx)-24)  // 
Endif

cMotBx		:= aDescMotBx[1] 	//NORMAL

If Empty(cBenef)
	dbSelectArea("SA2")
	SA2->(dbSeek(cFilial+SE2->E2_FORNECE+SE2->E2_LOJA))
	dbSelectArea("SE2")
	cBenef  := SA2->A2_NOME
Endif

DEFINE MSDIALOG oDlgLote FROM	31,15 TO 380,574 TITLE OemToAnsi("Baixas a Pagar")  PIXEL OF oMainWnd //
@ 01, 002 TO 035, 278 LABEL OemToAnsi("Principal") OF oDlgLote  PIXEL //
@ 37, 001 TO 170, 137 LABEL OemToAnsi("Dados Gerais") OF oDlgLote  PIXEL //
@ 38, 143 TO 170, 278 LABEL OemToAnsi("Valores da Baixa") OF oDlgLote  PIXEL //

@ 010, 010 SAY OemToAnsi("Tกtulo")		SIZE 18,07 OF oDlgLote PIXEL // 
@ 008, 030 MSGET oTitulo VAR cTitulo	SIZE 57,10 OF oDlgLote PIXEL When .F.

@ 010, 095 SAY OemToAnsi("Emisso")		SIZE 31,07 OF oDlgLote PIXEL //
@ 008, 127 MSGET oEmissao VAR dEmissao  SIZE 35,10 OF oDlgLote PIXEL When .F.

@ 010, 169 SAY OemToAnsi("Vencto.Atual") SIZE 39,07 OF oDlgLote PIXEL //
@ 008, 210 MSGET oVencRea VAR dVencRea   SIZE 31,10 OF oDlgLote PIXEL When .F.

@ 022, 005 SAY OemToAnsi("Fornec.")		SIZE 22,07 OF oDlgLote PIXEL //
@ 020, 030 MSGET oNomeFor VAR cNomeFor	SIZE 211,9 OF oDlgLote PIXEL When .F.

@ 046, 007 SAY OemToAnsi("Hist.Emisso")	SIZE 38,07 OF oDlgLote PIXEL //
@ 043, 050 MSGET oHist VAR cHist			SIZE 84,10 OF oDlgLote PIXEL When .F.

@ 057, 007 SAY OemToAnsi("Portador")	SIZE 39,07 OF oDlgLote PIXEL //
@ 056, 050 MSGET oPortado VAR cPortado	SIZE 84,10 OF oDlgLote PIXEL When .F.

@ 069, 007 SAY OemToAnsi("Mot.Baixa") SIZE 37,07 OF oDlgLote PIXEL //
@ 068, 050 COMBOBOX oMotBx VAR cMotBx ITEMS aDescMotbx SIZE 84,47 OF oDlgLote PIXEL;
	ON CHANGE A001VerChq(cMotBx,@cBanco,@cAgencia,@cConta,@cCheque,@oBanco,@oAgencia,@oConta,@oCheque)

@ 081, 007 SAY OemToAnsi("Banco")		SIZE 40,07 OF oDlgLote PIXEL //
@ 080, 050 MSGET oBanco VAR cBanco 		SIZE 22,10 OF oDlgLote PIXEL F3 "SA6" When MovBcoBx( cMotBx, .T. ) .And. Empty(cCheque) Valid CarregaSA6(@cBanco,,,.T.)

@ 093, 007 SAY OemToAnsi("Agncia")		SIZE 39,07 OF oDlgLote PIXEL //
@ 092, 050 MSGET oAgencia VAR cAgencia	SIZE 35,09 OF oDlgLote PIXEL When MovBcoBx( cMotBx, .T. )  .And. Empty(cCheque) Valid CarregaSA6(@cBanco,@cAgencia,,.T.)

@ 105, 007 SAY OemToAnsi("Conta")		SIZE 41,07 OF oDlgLote PIXEL //
@ 104, 050 MSGET oConta VAR cConta 		SIZE 84,10 OF oDlgLote PIXEL When MovBcoBx( cMotBx, .T. )  .And. Empty(cCheque) Valid CarregaSA6(@cBanco,@cAgencia,@cConta,.T.)

@ 117, 007 SAY OemToAnsi("Cheque No.")	SIZE 40,07 OF oDlgLote PIXEL //"Cheque No."
@ 116, 050 MSGET oCheque VAR cCheque	SIZE 38,10 OF oDlgLote PIXEL When A001DigiChq(cMotBx, cBanco, cCheque) Valid A001ValCheq(cBanco,cAgencia,cConta,cCheque)

@ 129, 007 SAY OemToAnsi("Data Pagto.")	SIZE 38,07 OF oDlgLote PIXEL //
@ 128, 050 MSGET oBaixa VAR dBaixa 		SIZE 39,09 OF oDlgLote PIXEL Valid dBaixa >= SE2->E2_EMISSAO .And. DtMovFin(dBaixa)

@ 141, 007 SAY OemToAnsi("Hist.Baixa")	SIZE 39,07 OF oDlgLote PIXEL //
@ 140, 050 MSGET oHistBx VAR cHistBx	SIZE 84,10 OF oDlgLote PIXEL Picture "@!" When VisualSX3("E5_HISTOR")

@ 153, 007 SAY OemToAnsi("Beneficiแrio") SIZE 36,07 OF oDlgLote PIXEL //
@ 152, 050 MSGET oBenef VAR cBenef		 SIZE 84,10 OF oDlgLote PIXEL Picture "@!" When cNivel>=SX3->X3_NIVEL

@ 046, 150 SAY OemToAnsi("Saldo")	SIZE 53,07 OF oDlgLote PIXEL //
@ 043, 190 MSGET oSaldo VAR nSaldo SIZE 66,10 OF oDlgLote PIXEL Picture PesqPict("SE2","E2_VALLIQ") WHEN .F.

@ 057, 150 SAY OemToAnsi("Desconto")	SIZE 53,07 OF oDlgLote PIXEL //
@ 056, 190 MSGET oDesconto VAR nDesconto SIZE 66,10 OF oDlgLote PIXEL Picture PesqPict("SE2","E2_VALLIQ") VALID A001Desconto(nSaldo,@nValor,@nDesconto,@oValor,@oDesconto)

@ 069, 150 SAY OemToAnsi("Valor Pago")	SIZE 53,07 OF oDlgLote PIXEL //
@ 068, 190 MSGET oValor VAR nValor	SIZE 66,10 OF oDlgLote PIXEL Picture PesqPict("SE2","E2_VALLIQ") VALID A001Valor(nSaldo,@nValor,@nDesconto,@oValor,@oDesconto)
	
DEFINE SBUTTON FROM 06, 246 TYPE 1 ENABLE OF oDlgLote ACTION ( IIf(A001ValBco(cMotBx,cBanco,cAgencia,cConta),(nOpca := 1, oDlgLote:End()),""))

DEFINE SBUTTON FROM 20, 246 TYPE 2 ENABLE OF oDlgLote ACTION ( nOpca := 0 ,oDlgLote:End())

ACTIVATE MSDIALOG oDlgLote CENTERED ON INIT A001VerChq(cMotBx,@cBanco,@cAgencia,@cConta,@cCheque,@oBanco,@oAgencia,@oConta,@oCheque)

If (nOpca == 1)
	lBaixou:= U_EF2PAGGRV(cBanco,cAgencia,cConta,cCheque,dBaixa,cMotBx,nValor,cHistBx,nDesconto)
EndIf

Return(lBaixou)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณEF2PAGGRV ณ Autor ณ Wagner Xavier         ณ Data ณ 26/05/92 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Recarrega Variaveis                                        ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ Fa080But()                                                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ Genrico                                                   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function EF2PAGGRV(cBanco,cAgencia,cConta,cCheque,dBaixa,cMotBx,nValor,cHistBx,nDesconto)
Local lBaixou  := .F.

If !CarregaSa6(cBanco,cAgencia,cConta,.T.)
	Return .F.
EndIf

If !DtMovFin(dBaixa)
	Return .F.
EndIf

If Empty( cMotBx )
	cMotBx := aDescMotBx[1]  //NORMAL
Endif

Begin Transaction
	If (nDesconto > 0)
		U_A001CPDesconto(nDesconto,cBanco,cAgencia,cConta,cMotBx)
	Endif
	lBaixou := U_A001BXRepasse(cMotBx,cBanco,cAgencia,cConta,cHistBx,{"","","",cCheque,nValor,nDesconto},.T.,@nValBx)
End Transaction

Return(lBaixou)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA001ValBcoบAutor  ณMicrosiga           บ Data ณ  10/01/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A001ValBco(cMotBx,cBanco,cAgencia,cConta)
Local lRet:= .T.

If MovBcoBx( cMotBx, .T. ) .And. Empty(cBanco+cAgencia+cConta)
	lRet:= .F.
EndIf	

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA001desconto AutorณMicrosiga           บ Data ณ  10/01/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A001Desconto(nSaldo,nValor,nDesconto,oValor,oDesconto)
Local lRet:= .T.

If (nDesconto < 0) .Or. (nDesconto > nSaldo)
	Aviso("Atencao","Valor de Desconto Invalido !!!",{"Ok"})
    Return(.F.)
Else
	nValor:= nSaldo - nDesconto
EndIf

oDesconto:Refresh()
oValor:Refresh()


Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA001Valor บAutor  ณMicrosiga           บ Data ณ  10/01/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A001Valor(nSaldo,nValor,nDesconto,oValor,oDesconto)
Local lRet:= .T.

If (nValor < 0) .Or. (nValor > nSaldo)
	Aviso("Atencao","Valor para Pagamento Invalido !!!",{"Ok"})
    Return(.F.)
ElseIf	(nValor == 0) 
	nDesconto:= nSaldo
Else
	nDesconto:= nSaldo - nValor
EndIf

oDesconto:Refresh()
oValor:Refresh()

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno	 ณA001CPDesconto Autor ณ Wagner Xavier 		   ณ Data ณ 25/08/04 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Funo utilizada para Baixa de Titulos a Pagar				 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe	 ณ A001CPDesconto 												 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso		 ณ Generico 													 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function A001CPDesconto(nValor,cBcoDep,cAgDep,cCCDep,cMotBX)
Local aArea     := GetArea()
Local cSequencia:= "01"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica a sequencia correta. ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Para numerar as sequencias o sistema precisa procurar os   ณ
//ณ registros com  tipodoc igual a DC.      				   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
RecLock("SE2",.F.)                            
Replace E2_SALDO	With SE2->E2_SALDO - nValor
Replace E2_DESCONT	With nValor
MsUnLock()

dbSelectArea("SE5")
SE5->(dbSetOrder(2))
SE5->(dbSeek(xFilial("SE5") + "DC" + SE2->E2_PREFIXO + SE2->E2_NUM + ;
SE2->E2_PARCELA + SE2->E2_TIPO) )

While !SE5->(Eof()) .And. ;
	SE5->E5_FILIAL  == xFilial("SE5") .And. ;
	SE5->E5_TIPODOC == "DC" .And. ;
	SE5->E5_PREFIXO == SE2->E2_PREFIXO .And. ;
	SE5->E5_NUMERO  == SE2->E2_NUM .And. ;
	SE5->E5_PARCELA == SE2->E2_PARCELA .And. ;
	SE5->E5_TIPO    == SE2->E2_TIPO
	
	If SE5->E5_CLIFOR <> SE2->E2_FORNECE .or. ;
		SE5->E5_LOJA <> SE2->E2_LOJA
		dbskip()
		Loop
	EndIf

	cSequencia:= Soma1(AllTrim(SE5->E5_SEQ),2)
	SE5->( dbSkip() )
Enddo

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Atualiza a baixa do titulo							         ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
RecLock("SE5",.T.)
SE5-> E5_FILIAL 	:= xFilial("SE5")
SE5-> E5_BANCO		:= cBcoDep
SE5-> E5_AGENCIA	:= cAgDep
SE5-> E5_CONTA		:= cCCDep
SE5-> E5_DATA		:= dDatabase
SE5-> E5_HISTOR 	:= "Desconto S/ Pagamento de Titulo"
SE5-> E5_VALOR		:= nValor
SE5-> E5_NATUREZ	:= SE2->E2_NATUREZ
SE5-> E5_RECPAG 	:= "P"
SE5-> E5_TIPO		:= SE2->E2_TIPO
SE5-> E5_LA			:= "N"
SE5-> E5_TIPODOC	:= "DC"
SE5-> E5_PREFIXO	:= SE2->E2_PREFIXO
SE5-> E5_NUMERO 	:= SE2->E2_NUM
SE5-> E5_PARCELA	:= SE2->E2_PARCELA
SE5-> E5_CLIFOR 	:= SE2->E2_FORNECE
SE5-> E5_LOJA		:= SE2->E2_LOJA
SE5-> E5_BENEF		:= SE2->E2_NOMFOR
SE5-> E5_DTDIGIT	:= dDataBase
SE5-> E5_MOTBX		:= TrazCodMot(cMotBx)
SE5->E5_SEQ 		:= cSequencia
SE5->E5_DTDISPO	    := E5_DATA
MsUnLock()

RestArea(aArea)

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno	 ณA001CRDesconto Autor ณ Wagner Xavier 		   ณ Data ณ 25/08/04 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Funo utilizada para Desconto Titulos a Receber				 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe	 ณ A001CRDesconto  												 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso		 ณ Generico 													 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function A001CRDesconto(nValor,cBcoDep,cAgDep,cCCDep,cMotBX)
Local aArea     := GetArea()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Atualiza a baixa do titulo							         ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
RecLock("SE5",.T.)
SE5-> E5_FILIAL 	:= xFilial("SE5")
SE5-> E5_BANCO		:= cBcoDep
SE5-> E5_AGENCIA	:= cAgDep
SE5-> E5_CONTA		:= cCCDep
SE5-> E5_DATA		:= dDatabase
SE5-> E5_HISTOR 	:= "Desconto Concedido S/ Titulo"
SE5-> E5_VALOR		:= nValor
SE5-> E5_NATUREZ	:= SE1->E1_NATUREZ
SE5-> E5_RECPAG 	:= "R"
SE5-> E5_TIPO		:= SE1->E1_TIPO
SE5-> E5_LA			:= "N"
SE5-> E5_TIPODOC	:= "DC"
SE5-> E5_PREFIXO	:= SE1->E1_PREFIXO
SE5-> E5_NUMERO 	:= SE1->E1_NUM
SE5-> E5_PARCELA	:= SE1->E1_PARCELA
SE5-> E5_CLIFOR 	:= SE1->E1_CLIENTE
SE5-> E5_LOJA		:= SE1->E1_LOJA
SE5-> E5_BENEF		:= SE1->E1_NOMCLI
SE5-> E5_DTDIGIT	:= dDataBase
SE5-> E5_MOTBX		:= TrazCodMot(cMotBx)
SE5->E5_SEQ 		:= "01"
SE5->E5_DTDISPO	    := E5_DATA
MsUnLock()

RestArea(aArea)

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno	 ณA001DigiChq Autor ณ Mauricio Pequim Jr.   ณ Data ณ 15/10/97 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Funcao que abre ou no o get do nง de cheque na baixa 	  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe	 ณ A001DigiChq()											  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso		 ณ FINA080													  ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A001DigiChq(cMotBx,cBanco,cCheque)
Local lRet := .T.

// Nao habilita o numero de cheque para :
// - Adiantamento, Banco Caixa, Carteira ou Motivo igual a Dbito em C/C
If (SE2->E2_TIPO $ MVPAGANT+"/"+MV_CPNEG) 	.Or. ;
	!Empty(cCheque)							.Or. ;
	!MovBcoBx( cMotBx, .T. ) 				.Or. ;
	SubStr(cBanco,1,2) == "CX"       		.Or. ;
	cBanco $ GetMv("MV_CARTEIR")     		.Or. ;
	TrazCodMot(cMotBx) $ "DEB/DAC"   		.Or. ;
	!ChqMotBx(cMotBx)				   		.Or. ;
	(GetMv("MV_CHQBOR") == "N" .And. !Empty(SE2->E2_NUMBOR))
	lRet := .F.
Endif

Return lRet

/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno	 ณA001ValCheq ณ Autor ณ Wagner Xavier		  ณ Data ณ 23/03/93 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Consistencia do numero do cheque 		    				ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe	 ณ A001ValCheq()												ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso		 ณ FINA080														ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A001ValCheq(cBanco,cAgencia,cConta,cCheque)
Local aArea := GetArea()
Local lRet  := .T.

IF Empty(cCheque)
	Return(.T.)
Endif

dbSelectArea("SEF")
dbSetOrder(1)
If SEF->( dbSeek(xFilial("SEF")+cBanco+cAgencia+cConta+cCheque) )
	If Subs(cCheque,1,1) != "*"
		Help(" ",1,"CHEQEXIST")
		lRet:=.F.
	Else
		lRet:=.T.
	Endif
Endif

RestArea(aArea)
Return lRet

/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno	 ณA001VerChqณ Autor ณ Mauricio Pequim Jr    ณ Data ณ 02/06/98 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Limpa conteudo de Bco/Age/Cta/N.Chque se baixa DEVOLUCAO   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe	 ณ A001VerChq()												  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso		 ณ FINA080													  ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A001VerChq(cMotBx,cBanco,cAgencia,cConta,cCheque,oBanco,oAgencia,oConta,oCheque)
Local cChave_EF:= ""
Local aArea    := GetArea()
Local aAreaSEF := SEF->(GetArea())

cBanco 	:= Space(3)
cAgencia:= Space(5)
cConta 	:= Space(10)
cCheque := Space(10)

If MovBcoBx(cMotBx, .T.)
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Se tem cheque relacionado ao Titulo, vasculha SEF c/ sequencia em  ณ
	//ณ branco (Gerado pelo Chq s/ Titulo) e carrega Bco/Ag/Conta e NงChq  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	dbSelectArea("SEF")
	dbSetOrder(3)
	If SE2->E2_IMPCHEQ=="S" .and. SEF->(dbseek(xFilial("SEF")+SE2->E2_PREFIXO+SE2->E2_NUM+;
			SE2->E2_PARCELA+SE2->E2_TIPO))
	
		cChave_EF := xFilial("SEF")+SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO)
		While !Eof() .And. (cChave_EF == SEF->(EF_FILIAL+EF_PREFIXO+EF_TITULO+EF_PARCELA+EF_TIPO))
			If Empty(SEF->EF_SEQUENC) .And. (SE2->(E2_FORNECE+E2_LOJA) == SEF->(EF_FORNECE+EF_LOJA))
				cBanco  := SEF->EF_BANCO
				cAgencia:= SEF->EF_AGENCIA
				cConta  := SEF->EF_CONTA
				cCheque := SEF->EF_NUM
				Exit
			EndIf
			SEF->(dbSkip())
		End
	EndIf

	SEF->(RestArea(aAreaSEF))
	RestArea(aArea)
EndIf                     

If (TrazCodMot(cMotBx) == "DEB")
	cCheque:= Space(10)
EndIf

oBanco  :Refresh()
oAgencia:Refresh()
oConta  :Refresh()
oCheque :Refresh()

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณPMSAtuSX6 ณ Autor ณFabio Rogerio Pereira  ณ Data ณ19/02/02  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Funcao de processamento da gravacao do SX6                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ Implantacao PMS                                            ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function EFAtuSX6()
//  X6_FIL   X6_VAR     X6_TIPO    X6_DESCRIC X6_DSCSPA  X6_DSCENG  X6_DESC1 X6_DSCSPA1 X6_DSCENG1
//  X6_DESC2 X6_DSCSPA2 X6_DSCENG2 X6_CONTEUD X6_CONTSPA X6_CONTENG X6_PROPRI

Local aSX6   := {}                                       
Local aEstrut:= {}
Local i      := 0
Local j      := 0
Local cAlias := ''

              
aEstrut:= { "X6_FIL","X6_VAR","X6_TIPO","X6_DESCRIC","X6_DSCSPA","X6_DSCENG","X6_DESC1","X6_DSCSPA1","X6_DSCENG1",;
			"X6_DESC2","X6_DSCSPA2","X6_DSCENG2","X6_CONTEUD","X6_CONTSPA","X6_CONTENG","X6_PROPRI"}
Aadd(aSX6, {"  ","MV_EFA01BX","L","Indica se a baixa os titulos ou nao","","","","","","","","","T","T","T","U"})
Aadd(aSX6, {"  ","MV_EFA01BC","C","Indica qual o banco para baixa","","","","","","","","","PRE","PRE","PRE","U"})
Aadd(aSX6, {"  ","MV_EFA01AG","C","Indica qual a agencia para baixa","","","","","","","","","0000","0000","0000","U"})
Aadd(aSX6, {"  ","MV_EFA01CC","C","Indica qual a conta para baixa","","","","","","","","","0000000000","0000000000","0000000000","U"})
Aadd(aSX6, {"  ","MV_EFA01BR","C","Indica qual o banco para redeposito","","","","","","","","","CHD","CHD","CHD","U"})
Aadd(aSX6, {"  ","MV_EFA01AR","C","Indica qual a agencia para redeposito","","","","","","","","","00000","00000","00000","U"})
Aadd(aSX6, {"  ","MV_EFA01CR","C","Indica qual a conta para redeposito","","","","","","","","","0000000000","0000000000","0000000000","U"})

dbSelectArea("SX6")
dbSetOrder(1)
For i:= 1 To Len(aSX6)
	If !Empty(aSX6[i][2])
		If !dbSeek(aSX6[i,1]+aSX6[i,2])
			If !(aSX6[i,2]$cAlias)
				cAlias += aSX6[i,2]+"/"
			EndIf
			RecLock("SX6",.T.)
			For j:=1 To Len(aSX6[i])
				If !Empty(FieldName(FieldPos(aEstrut[j])))
					FieldPut(FieldPos(aEstrut[j]),aSX6[i,j])
				EndIf
			Next j
	  
			dbCommit()        
			MsUnLock()
		EndIf
	EndIf
Next i

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณA001TemDev บAutor  ณMicrosiga           บ Data ณ  08/02/04  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica se o cheque foi devolvido                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function A001TemDev(cCheque)
Local aAreaZ3 := SZ3->(GetArea())
Local lRet    := .F.

dbSelectArea("SZ2")
dbSetOrder(2)
If dbSeek(xFilial("SZ2")+"F"+cCheque,.T.)
	lRet:= .T.
EndIf

RestArea(aAreaZ3)
Return(lRet)