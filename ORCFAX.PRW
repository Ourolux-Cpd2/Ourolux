#INCLUDE "TMKR3A.CH"          
#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณORCFAX    บAutor  ณELETROMEGA           บ Data ณ  06/28/05  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Enviar o or็amento pelo fax para o cliente.                บฑฑ
ฑฑบ          ณ Max items no or็amento : 27 items                          บฑฑ
ฑฑบ          ณ Max linhas de campo obs: 4 linhas                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function OrcFax()      
#include "rwmake.ch"        
#include "font.ch"

Local cFax		:= ""     
Local cObs 	 	:= ""
SetPrvt("CBTXT,CBCONT,NORDEM,TAMANHO,LIMITE,CIMPRI")
SetPrvt("NTOTAL,TITULO,CDESC1,CDESC2,CDESC3,ARETURN")
SetPrvt("NOMEPROG,CPERG,NLASTKEY,LCONTINUA,NLIN,WNREL")
SetPrvt("CSTRING,NLINES,NLINHAS,NCOL,NL,NCURRENTLINE")

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define Variaveis Ambientais                                  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cbTxt	:= ""
cbCont	:= ""
nOrdem 	:= 0
Tamanho	:= "M" 
Limite	:= 132
cImpri   := ""
nTotal   := 0
cTmp     := ""
cFigura := "eletromega.bmp"  //Logotipo Eletromega
nStartLine := 50
nUltLine := 2155
nMax		:= 58			// Maximo de linhas suportada pelo relatorio
cCabec1	:= "" 			// Label dos itens
cCabec2	:= "" 			// Label dos itens
nomeprog := "ORCFAX.PRW"
cPerg	 := PadR("ORCFAT",10)
Titulo 	:= STR0001 
nLin 	  := 0
nCol      := 60
m_pag:= 1
aReturn := { STR0005,;			// [1] Reservado para Formulario	//"Zebrado"
					 1,;				// [2] Reservado para Nง de Vias
					 STR0006,;			// [3] Destinatario					//"Administracao"
					 2,;				// [4] Formato => 1-Comprimido 2-Normal	
					 2,;	    		// [5] Midia   => 1-Disco 2-Impressora
					 1,;				// [6] Porta ou Arquivo 1-LPT1... 4-COM1...
					 "",;				// [7] Expressao do Filtro
					 1 } 				// [8] Ordem a ser selecionada
					 					// [9]..[10]..[n] Campos a Processar (se houver)


if !Pergunte(cPerg,.T.) 
	return
endif

cString:="SUB"

RptStatus({|| RunReport()})
return


Static Function RunReport()

oFont1 	  := TFont():New( "Times New Roman",,08,,.T.,,,,,.F.)
oFont12   := TFont():New("Courier New",,12,,.T.,,,,.T.,.F.) 
oFont14   := TFont():New("Courier New",,14,,.T.,,,,.T.,.F.)

oPrint	  := TMSPrinter():New("Eletromega - Orcamento")

If !oPrint:Setup() .or. !oPrint:IsPrinterActive()
     return
Endif 

oPrint:StartPage()      // Inicia uma nova pagina
oPrint:SetPortrait()    //Define que a impressao deve ser RETRATO//

cString:="SUB"

dbSelectArea("SUA")
dbSetOrder(1)
dbSeek(xFilial("SUA")+MV_PAR01,.T.)

dbSelectArea("SE4")
dbSetOrder(1)
dbSeek(xFilial("SE4")+SUA->UA_CONDPG)

dbSelectArea("SA3")
dbSetOrder(1)
dbSeek(xFilial("SA3")+SUA->UA_VEND)

dbSelectArea("SA1")
dbSetOrder(1)
dbSeek(xFilial("SA1")+SUA->UA_CLIENTE+SUA->UA_LOJA)

dbSelectArea("SUA")

If EMPTY(SUA->UA_TRANSP) .OR. EMPTY(SUA->UA_CONDPG) .OR. SUA->UA_TABELA = "900";
.OR. SUA->UA_OPER != "2" .OR. EMPTY(UA_FAX)  
	MsgAlert("Somente para o envio de or็amento!")
	RETURN(.F.)
ENDIF

//dbSelectArea("SU5")
//dbSetOrder(1)

cFax := AllTrim(SUA->UA_FAX)

If EMPTY(cFax)
	MsgAlert("Sem numero de fax!")
	RETURN(.F.)
EndIf

oPrint:Say(0, 0, " ",oFont1,100)

oPrint:SayBitmap(50,60,cFigura,250,350)

oPrint:Say( 150, nCol + 300, "ELETROMEGA COMERCIAL LTDA. " ,oFont14,,,,0 ) 
oPrint:Say( 200, nCol + 300, "Av. Guinle, 1120 - Cidade Industrial - CEP: 07221-070 - Guarulhos - SP " ,oFont12,,,,0 )
oPrint:Say( 250, nCol + 300, "Telefone: (11) 2172-1000 " ,oFont12,,,,0 )
oPrint:Say( 300, nCol + 300 , "ORวAMENTO DE VENDA N."+SUA->UA_NUM+"/"+Str( Year( dDataBase ), 4 ),oFont12,,,,0 )
nlin += 50
//oPrint:Say( nlin, 2100, "Fax-Nr : 0" + IIF(!Empty(cFax),cFax,SA1->A1_FAX),oFont12,,,,2 )
oPrint:Say( nlin, 2100, "Fax-Nr : " + cFax,oFont12,,,,2 )
nLin := 450
oPrint:Say( nlin, nCol,  "Empresa: " + SA1->A1_NOME,oFont12,,,,0 )
nlin += 50
oPrint:Say( nlin, nCol,  "CNPJ(MF): " + Transform( SA1->A1_CGC, "@R 99.999.999/9999-99" ),oFont12,,,,0)
nlin += 50
_cEnd := AllTrim( SA1->A1_END )
_cEnd += ' - '
_cEnd += AllTrim( SA1->A1_BAIRRO )
oPrint:Say( nlin, nCol,  _cEnd,oFont12,,,,0 )
nlin += 50
_cEnd := Transform( SA1->A1_CEP, "@R 99999-999" )
_cEnd += ' - '
_cEnd += AllTrim( SA1->A1_MUN )
_cEnd += ' - '
_cEnd += SA1->A1_EST

oPrint:Say( nlin, nCol,  _cEnd,oFont12,,,,0 )
nLin += 50
oPrint:Say( nlin, nCol,  " ",oFont12,,,,0 )
//oPrint:Say( nlin, nCol,  "Contato: " + SUA->UA_CONTATO,oFont12,,,,0 )
nlin += 100

_cDte := "Item"
_cDte += Space( 2 )
_cDte += "C๓digo"
_cDte += Space( 2 )
_cDte += "Descri็ใo"
_cDte += Space( 37 )
_cDte += "Qtd"
_cDte += Space( 5 )
_cDte += "Pr็ Unit"
_cDte += Space( 8 )
_cDte += "Total"


oPrint:Say( nlin, nCol, _cDte,oFont12,,,,0 ) 
nlin += 55
oPrint:Box (nLin,60,nLin+5,2320)

_fSUB := xFilial("SUB")
dbSelectArea( "SUB" )
dbSetOrder( 1 )
dbSeek( _fSUB+SUA->UA_NUM, .T. )

While ( ! ( SUB->( Eof() ) )       .And.;
          ( SUB->UB_FILIAL = _fSUB .And.;
            SUB->UB_NUM    = SUA->UA_NUM;
      )   )
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ                                                                     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	   
    If ( nLin >= nUltLine )
    	// Proxima pagina
    	
    	EndOfPage() 
    	
    	nLin := 50
    	nCol := 60

		_cDte := "Item"
		_cDte += Space( 2 )
		_cDte += "C๓digo"
		_cDte += Space( 2 )
		_cDte += "Descri็ใo"
		_cDte += Space( 37 )
		_cDte += "Qtd"
		_cDte += Space( 5 )
		_cDte += "Pr็ Unit"
		_cDte += Space( 8 )
		_cDte += "Total"

		oPrint:Say( nlin, nCol, _cDte,oFont12,,,,0 ) 
		nlin += 55
		oPrint:Box (nLin,60,nLin+5,2320)
    EndIf
       
   _cDet := SUB->UB_ITEM
   _cDet += Space( 4 )
   _cDet += Substr( SUB->UB_PRODUTO, 1, 6 )
   _cDet += Space( 2 )
   _cDet += Posicione( "SB1", 1, xFilial( "SB1" ) + SUB->UB_PRODUTO, "B1_DESC" )
   _cDet += Transform( SUB->UB_QUANT, "@E 999,999.9" )
   _cDet += Space( 1 )
   _cDet += Transform(SUB->UB_VRUNIT, "@E 999,999.9999" )
   _cDet += Transform(SUB->UB_VLRITEM, "@E 99,999,999.99" )
   nlin += 50
   oPrint:say(nLin,nCol, _cDet,oFont12,,,,0 ) 
   
   nTotal += SUB->UB_VLRITEM

   SUB->( dbSkip()	 )

End  // while

 nlin += 70 
 oPrint:Box (nlin,60,nLin + 5 ,2310)

 _cDte := "VALOR TOTAL (R$):" + ( Transform ( nTotal,  "@E 99,999,999.99" ))
 
 nlin += 10
 oPrint:Say( nlin, 1600 ,_cDte ,oFont12,,,,0)
 nlin += 60
 oPrint:Box (nlin,60,nLin + 5 ,2310)
 nlin += 50
 oPrint:Say( nlin, nCol,"Condi็ใo Pagamento: " + SE4->E4_DESCRI ,oFont12,,,,0 )
 nlin += 50
 oPrint:Say( nlin, nCol,"Frete: CIF - Sao Paulo" ,oFont12,,,,0 )
 nlin += 50
// oPrint:Say( nlin, nCol,"Prazo de Entrega: "+Trim(SUA->UA_PRAZO) + " dia(s)" ,oFont12,,,,0 )
 nlin += 50
oPrint:Say( nlin, nCol,"Validade da Proposta: "+ Dtoc(SUA->UA_DTLIM) ,oFont12,,,,0 )
  
nlin += 50
oPrint:Say( nlin, nCol, " ",oFont12,,,,0)

// imprime testo 'Obervacoes'
If ! Empty(SUA->UA_CODOBS)
	nlin += 50
	oPrint:Say( nlin, nCol, "Observa็ใo: ",oFont12,,,,0)
	
	cObs := MSMM(SUA->UA_CODOBS,80)
	For nInd := 1 to 4 // MlCount(cObs,80)
		nlin += 50
		cImpri := Trim(MemoLine(cObs,50,nInd))
		oPrint:Say( nlin, nCol,cImpri,oFont12,,,,0)
	Next nInd
Endif

 oPrint:Say( 2845, nCol, " ",oFont12,,,,0)
 oPrint:Say( 2895, nCol,"Sao Paulo, " + LTrim(Str(Day(dDatabase))) + " de " + Lower ( MesExtenso( Month (dDatabase ))) + " de " + Str ( Year ( dDatabase ) , 4 )  + "." ,oFont12,,,,0 )
 oPrint:Say( 2945, nCol, " ",oFont12,,,,0)
 oPrint:Say( 2995, nCol,"Atenciosamente,",oFont12,,,,0)
 oPrint:Say( 3045, nCol, " ",oFont12,,,,0)
 oPrint:Say( 3095, nCol,UsrFullName( __cUserId ),oFont12,,,,0 )
 oPrint:Say( 3145, nCol,UsrRetMail( __cUserId ) ,oFont12,,,,0) 
 oPrint:Say( 3145, 1000,"Assinatura Do Cliente: " ,oFont12,,,,0) 
 oPrint:Say( 3245, nCol," " ,oFont12,,,,0)
 oPrint:Say( 3295, nCol," " ,oFont12,,,,0)
 oPrint:Say( 3345, nCol,"Este ้ um pedido padrใo de Eletromega, o mesmo estแ isento da assinatura." ,oFont12,,,,0 )

 dbCommitAll()
 DbSelectArea("SUA")
 DbSetOrder(1)
 DbSelectArea("SUB")
 DbSetOrder(1)
 DbSelectArea("SCL")
 DbSetOrder(1)

 if !oPrint:Preview()
	return
 endif	 
  
 oPrint:Print() 
 oPrint:End()
 MS_FLUSH() 
 
 Return(.T.) 

/*BEGINDOC
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณEndOfPage()                                           ณ
//ณImprime '**' na 1 pagina de or็amento se os items > 27ณ
//ณInitializar a Proxima Pagina                          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
ENDDOC*/

Static Function EndOfPage()
	
	nPos := 0
	
	while ( nLin <= 3295)
		oPrint:Say( nLin + 50, nCol + nPos ,"**" ,oFont12,,,,0 )
		nPos := nPos + 100
		nLin := nLin + 50
	End 
		
	oPrint:Say( 3345, nCol," Continua na proxima pagina: " ,oFont12,,,,0 )	
	oPrint:EndPage()
	oPrint:StartPage()      // Inicia uma nova pagina
	
return
