User Function OrcFat2()      // incluido pelo assistente de conversao do AP5 IDE em 13/11/00
#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 13/11/00
#include "font.ch"

#IFNDEF WINDOWS
	#DEFINE PSAY SAY
#ENDIF

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

SetPrvt("CBTXT,CBCONT,NORDEM,TAMANHO,LIMITE,CIMPRI")
SetPrvt("NTOTAL,TITULO,CDESC1,CDESC2,CDESC3,ARETURN")
SetPrvt("NOMEPROG,CPERG,NLASTKEY,LCONTINUA,NLIN,WNREL")
SetPrvt("CSTRING,NLINES,NLINHAS,NBRANCO,NL,NCURRENTLINE")
SetPrvt( "oFont>", "oFont2" )
#IFNDEF WINDOWS
// Movido para o inicio do arquivo pelo assistente de conversao do AP5 IDE em 13/11/00 ==> 	#DEFINE PSAY SAY
#ENDIF
/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿛rograma  � OrcFat2   � Autor � Eduardo Riera         � Data � 22/12/97 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇚o � Demonstrativo de Orcamento                                 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿢so       � Especifico para Clientes Microsiga                         낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Define Variaveis Ambientais                                  �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
cbTxt	:= ""
cbCont	:= ""
nOrdem 	:= 0
Tamanho	:= "M" 
Limite	:= 132
cImpri   := ""
nTotal   := 0
#IFDEF WINDOWS
	Titulo := PadC(OemToAnsi("Or�amento de Venda"),74)
#ELSE
	Titulo := PadC("Or�amento de Venda",74)
#ENDIF
#IFDEF WINDOWS
	cDesc1 := PadC(OemToAnsi("Este programa ira emitir o Or�amento de Venda, conforme"),74)
	cDesc2 := PadC(OemToAnsi("os parametros solicitados"),74)
	cDesc3 := PadC(OemToAnsi(""),74)
#ELSE
	cDesc1 := PadC("Este programa ira emitir o Or�amento de Venda, conforme",74)
	cDesc2 := PadC("os parametros solicitados",74)
	cDesc3 := PadC("",74)
#ENDIF

aReturn	  := { "Especial", 1,"Administra豫o", 1, 2, 1,"",0 }
NomeProg  := "ORCFAT2" 
cPerg	  := PadR("ORCFAT2",10)
nLastKey  := 0 
lContinua := .T.
nLin 	  := 99
wnrel 	  := "ORCFAT2"
oFont     := TFont():New("Courier New",12,12,,.F.,,,,.T.,.F.)
oFont14   := TFont():New( "Times New Roman",,14,,.t.,,,,,.f. )

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Verifica as perguntas selecionadas, busca o padrao da Nfiscal           �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
Pergunte(cPerg,.F.)
cString:="SCK"
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Envia controle para a funcao SETPRINT                        �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
wnrel:=SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.T.)
//wnrel:=SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.F.,,,,,.F.)
If ( nLastKey == 27 .Or. LastKey() == 27 )
   Return(.F.)
Endif
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Verifica Posicao do Formulario na Impressora                 �          
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
SetDefault(aReturn,cString)
If ( nLastKey == 27 .Or. LastKey() == 27 )
   Return(.F.)
Endif

RptDetail()

// Substituido pelo assistente de conversao do AP5 IDE em 13/11/00 ==> Function RptDetail
Static Function RptDetail()

dbSelectArea("SCJ")
dbSetOrder(1)
dbSeek(xFilial("SCJ")+MV_PAR01,.T.)

dbSelectArea("SE4")
dbSetOrder(1)
dbSeek(xFilial("SE4")+SCJ->CJ_CONDPAG)

dbSelectArea("SA3")
dbSetOrder(1)
dbSeek(xFilial()+SCJ->CJ_VEND1)

dbSelectArea("SA1")
dbSetOrder(1)
dbSeek(xFilial()+SCJ->CJ_CLIENTE+SCJ->CJ_LOJA)

dbSelectArea("SCJ")

nLin := 0
@ nLin,000 PSAY CHR(15)                                           
@ nLin,000 PSAY __PrtFatLine()

nLin ++
@ nLin,000 PSAY __PrtLogo()

nLin ++
@ nLin,000 PSAY __PrtLeft( "OR�AMENTO DE VENDA N."+SCJ->CJ_NUM+"/"+Str( Year( dDataBase ), 4 ) )
@ nLin,000 PSAY __PrtRight( "Fax-Nr : 0" + SCJ->CJ_TEL )

nLin ++
@ nLin,000 PSAY __PrtThinLine()

nLin += 2
@ nLin,000 PSAY __PrtLeft( "Empresa: " + SA1->A1_NOME )

nLin ++
@ nLin,000 PSAY __PrtLeft( "CNPJ(MF): " + Transform( SA1->A1_CGC, "@R 99.999.999/9999-99" ) )

nLin ++
_cEnd := AllTrim( SA1->A1_END )
_cEnd += ' - '
_cEnd += AllTrim( SA1->A1_BAIRRO )
@ nLin,000 PSAY __PrtLeft( _cEnd )

nLin ++
_cEnd := Transform( SA1->A1_CEP, "@R 99999-999" )
_cEnd += ' - '
_cEnd += AllTrim( SA1->A1_MUN )
_cEnd += ' - '
_cEnd += SA1->A1_EST
@ nLin,000 PSAY __PrtLeft( _cEnd )

//nLin ++
//cImpri := "Fone : "+SCJ->CJ_TEL
//@ nLin,000 PSAY " "+PadR(cImpri,Limite-2)+" "

nLin += 2
@ nLin,000 PSAY __PrtLeft( "A/C Sr(ta).: " + SCJ->CJ_CONTATO )

nLin += 3
@ nLin,000 PSAY __PrtLeft( "REF: Cota豫o de pre�os" )

nLin += 3
@ nLin,010 PSAY __PrtLeft( "Conforme solicita豫o de V.Sas apresentamos a nossa proposta comercial como segue: " )

nLin += 2
@ nLin,000 PSAY __PrtThinLine()

nLin ++

_cDte := "Item"
_cDte += Space( 3 )
_cDte += "C�digo"
_cDte += Space( 6 )
_cDte += "Descri豫o"
_cDte += Space( 46 )
_cDte += "Quantidade"
_cDte += Space( 12 )
_cDte += "Pre�o de Venda"
_cDte += Space( 17 )
_cDte += "Total"

@ nLin,000 PSAY _cDte FONT oFont

nLin ++
@ nLin,000 PSAY __PrtThinLine()

_fSCK := xFilial("SCK")
dbSelectArea( "SCK" )
dbSetOrder( 1 )
dbSeek( _fSCK+SCJ->CJ_NUM, .T. )

While ( ! ( SCK->( Eof() ) )       .And.;
          ( SCK->CK_FILIAL = _fSCK .And.;
            SCK->CK_NUM    = SCJ->CJ_NUM;
      )   )

   If ( nLin > 45 )

      nLin := 0
      @ nLin,000 PSAY __PrtThinLine()
      nLin ++
      @ nLin,000 PSAY " "+PadC(OemToAnsi("Continua na proxima pagina."),Limite-2)+" "
      nLin ++
      @ nLin,000 PSAY __PrtThinLine()
      nLin ++

      _cDte := "Item"
      _cDte += Space( 3 )
      _cDte += "C�digo"
      _cDte += Space( 6 )
      _cDte += "Descri豫o"
      _cDte += Space( 46 )
      _cDte += "Quantidade"
      _cDte += Space( 12 )
      _cDte += "Pre�o de Venda"
      _cDte += Space( 17 )
      _cDte += "Total"

      @ nLin,000 PSAY _cDte FONT oFont
      nLin ++
      @ nLin,000 PSAY __PrtThinLine()
	  nLin ++

   End

   nLin ++

   _cDet := SCK->CK_ITEM
   _cDet += Space( 5 )
   _cDet += Substr( SCK->CK_PRODUTO, 1, 6 )
   _cDet += Space( 6 )
   _cDet += Posicione( "SB1", 1, xFilial( "SB1" ) + SCK->CK_PRODUTO, "B1_DESC" )
   _cDet += Space( 12 )
   _cDet += Transform( SCK->CK_QTDVEN, "@E 999,999,999.9" )
   _cDet += Space( 12 )
   _cDet += Transform( iif(SCK->CK_PRCBX>0,SCK->CK_PRCBX,SCK->CK_PRCVEN), "@E 9,999,999.9999" )
   _cDet += Space( 3 )
   _cDet += Transform( iif(SCK->CK_PRCBX>0,SCK->CK_QTDVEN*SCK->CK_PRCBX,SCK->CK_VALOR), "@E 9999999,999,999.99" )

   //@ nLin,000 PSAY _cDet FONT oFont 
   @ nLin,000 PSAY _cDet  FONT oFont14 // wadih
   nTotal += IF(SCK->CK_PRCBX>0,SCK->CK_QTDVEN*SCK->CK_PRCBX,SCK->CK_VALOR)

   SCK->( dbSkip()	 )

End

nLines  := MLCount(SCJ->CJ_OBSERVA,Limite,3,.t.)
nLinhas := (41 - nLin) - nLines
nCol := 0

For nL := 1 To nLinhas

   nLin ++

   @ nLin,000 PSAY " "

   If nCol == 0

      @ nLin,5 PSAY Repl(".",Limite-10)
      nCol := Limite - 10

   Else

      nCol -= 5

      If nCol < 2
         nCol := 2

      EndIf

      @ nLin,nCol PSAY "."

   EndIf

   @ nLin,Limite - 1 PSAY " "

Next nL

nLin ++

@ nLin,000 PSAY " "
@ nLin,5 PSAY Repl(".",Limite-10)
@ nLin,Limite - 1 PSAY " "
                  
If nLines > 0
   nLin := nLin + 1
   @ nLin,000 PSAY " "+PadC("",Limite-2)+" "
   nLin ++
   cImpri := "Observa豫o: " + AllTrim(MemoLine(SCJ->CJ_OBSERVA,Limite,1,3,.t.))
   @ nLin,000 PSAY __PrtLeft( cImpri )
   For nCurrentLine := 2 To nLines
       nLin ++
       cImpri := MemoLine(SCJ->CJ_OBSERVA,Limite,nCurrentLine,3,.t.)
       @ nLin,000 PSAY __PrtLeft( cImpri )
   Next nCurrentLine
End

nLin ++
@ nLin,000 PSAY __PrtThinLine()

nLin ++
_cDte := "VALOR TOTAL (R$)" + Transform( nTotal,  "@E 9999999,999,999.99" )
@ nLin,000 PSAY __PrtRight( _cDte )

nLin ++
@ nLin,000 PSAY __PrtThinLine()

nLin += 2
@ nLin,000 PSAY __PrtLeft( "Condi豫o Pagamento: " + SE4->E4_DESCRI )

nLin ++
@ nLin,000 PSAY __PrtLeft( "Frete: CIF - Sao Paulo" )

nLin ++
@ nLin,000 PSAY __PrtLeft( "Prazo de Entrega: "+Trim(SCJ->CJ_PRAZO) + " dia(s)" )

nLin ++
@ nLin,000 PSAY __PrtLeft( "Validade Proposta: "+Trim(SCJ->CJ_VALIDAD) + " dia(s)" )

nLin += 2
@ nLin,000 PSAY __PrtRight( "Sao Paulo, "+LTrim(Str(Day(dDatabase)))+" de "+Lower(MesExtenso(Month(dDatabase)))+" de "+Str(Year(dDatabase),4) ) + "."

nLin += 2
@ nLin,000 PSAY __PrtLeft( "Atenciosamente," )

nLin += 2
//@ nLin,000 PSAY __PrtLeft( Substr( SA3->A3_NREDUZ, 1, 1 ) + Lower( Substr( SA3->A3_NREDUZ, 2 ) ) )
@ nLin,000 PSAY __PrtLeft( UsrFullName( __cUserId ) )

nLin ++
@ nLin,000 PSAY __PrtLeft( UsrRetMail( __cUserId ) )
//  WADIH 15-04-05
/*
nLin ++
@ nLin,000 PSAY __PrtLeft( "Ramal:" + AllTrim( SA3->A3_FAX ) )
*/
//WADIH 15-04-05 
nLin ++
@ nLin,000 PSAY __PrtRight( "Este � um pedido padr�o da Eletromega, o mesmo est� isento da assinatura" )

nLin +=3
@ nLin,000 PSAY __PrtThinLine()

nLin ++
@ nLin,000 PSAY __PrtCenter( "Eletromega Comercial Ltda." )

nLin ++
@ nLin,000 PSAY __PrtCenter( "Av. Guinle, 1120 - Cidade Industrial - CEP: 07221-070 - Guarulhos - SP" )

nLin ++
@ nLin,000 PSAY __PrtCenter( "Telefone para contato: (11) 2172-1000" )

__Eject()
Set Device to Screen
Set Printer To
dbCommitAll()
DbSelectArea("SCJ")
DbSetOrder(1)
DbSelectArea("SCK")
DbSetOrder(1)
DbSelectArea("SCL")
DbSetOrder(1)
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Se impressao em Disco, chama Spool.                              �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸

If aReturn[5] == 1
   ourspool(wnrel)
   MS_FLUSH()
Else
   MS_FLUSH()
   Aviso("Aviso","Or�amento j� foi enviado ou impresso",{"OK"})
End

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Libera relatorio para Spool da Rede.                             �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸

Return(.T.)

