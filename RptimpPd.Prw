/*

      Data ³07/05/2003
      Emissao do Pedido de Venda (automatico)

*/

User Function RptImpPd()  

#DEFINE K_ALT_A 286
#DEFINE K_ESC   27

#IFNDEF WINDOWS
        #DEFINE PSAY SAY
#ENDIF

#IFDEF WINDOWS
   cDesc1  :=OemToAnsi("Emiss„o da confirmac„o dos pedidos de venda, de acordo com")
   cDesc2  :=OemToAnsi("intervalo informado na op‡„o Parƒmetros.")
   cDesc3  :=OemToAnsi("Na emissao zera reserva no saldo de estoque.")
#ELSE
   cDesc1  :="Emiss„o da confirmac„o dos pedidos de venda, de acordo com"
   cDesc2  :="intervalo informado na op‡„o Parƒmetros."
   cDesc3  :="Na emissao zera reserva no saldo de estoque."
#ENDIF                          

PRIVATE ctitulo  :="Emissao da Pre-Nota"
PRIVATE tamanho :="M"
PRIVATE A := 1
PRIVATE nRegistro:= 0
PRIVATE  cKey    :=cCondicao:=""
PRIVATE  wnrel   :=" "
PRIVATE  cPerg   := PadR("IMPPED",10)
PRIVATE  aReturn := { "Zebrado", 1,"Administracao", 1, 2, 1, "",0 }
PRIVATE  nomeprog:="IMPPED"
PRIVATE  nLastKey:=nBegin:=nTotQtd:=nTotVal:=0
PRIVATE  aLinha  :={ }
PRIVATE  li      :=80
PRIVATE  limite  :=132
PRIVATE  lRodape :=.F.
PRIVATE  cPictQtd:=""
PRIVATE  aPedCli := {}
PRIVATE  wnrel   := "IMPPED"
PRIVATE  cString := "SC6"
PRIVATE  lEnd    :=.f.
PRIVATE  nPerRet := 0 
cDesc1 := cDesc2 := cDesc3 := ' '

Pergunte(cPerg,.F.)               // Pergunta no SX1

Wnrel := SetPrint(cString,wnRel,cPerg,cTitulo,cDesc1,cDesc2,cDesc3,.F.,,.T.,Tamanho)

If nLastKey == 27
   Return(.T.)
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
   Return(.T.)
Endif

aReturn[ 4 ] := 1

RptStatus({|| RptPota() })

Set Device To Screen
Set Printer To
MS_Flush()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ RptPota  ³ Autor ³ Claudinei M. Benzi    ³ Data ³ 05.11.92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Pre-Nota                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ RptPota()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PNOTA                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RptPota

/*

     Verifica as perguntas selecionadas
     Variaveis utilizadas para parametros
     mv_par01              Do Pedido
     mv_par02              Ate o Pedido
     mv_par03              Data de Emissao de
     mv_par04              Data de Emissao ate

*/

_fSC5 := xFilial( 'SC5' )
_fSC6 := xFilial( 'SC6' )
_fSC9 := xFilial( 'SC9' )
_fSA1 := xFilial( 'SA1' )
_fSA2 := xFilial( 'SA2' )
_fSA3 := xFilial( 'SA3' )
_fSE4 := xFilial( 'SE4' )
_fSA4 := xFilial( 'SA4' )
_fSX5 := xFilial( 'SX5' )
_fSF4 := xFilial( 'SF4' )
_fSB1 := xFilial( 'SB1' )
_fSDC := xFilial( 'SDC' )

SA1->( dbSetOrder( 1 ) )
SX5->( dbSetOrder( 1 ) )
SDC->( dbSetOrder( 1 ) )
_nKey := 0

While ( _nKey <> 27 )


   If MV_PAR01 <> 1

      _cQry := 'SELECT  Count(*) As NroRec '
      _cQry += 'FROM ' + RetSqlName("SC5") + ' SC5 '
      _cQry += "WHERE     (D_E_L_E_T_ <> '*') AND (C5_LIBEROK <> ' ') AND (C5_NOTA = ' ') AND (C5_REIMP < 1) AND ( C5_TIPO <> 'T')  AND (C5_TIPENT = '1') "
	  _cQry += " AND C5_FILIAL = '" + xFilial("SC5") + "' "  // CURITIBA	     

   Else

      _cQry := 'SELECT  Count(*) As NroRec '
      _cQry += 'FROM ' + RetSqlName("SC5") + ' SC50 '
      _cQry += "WHERE  (D_E_L_E_T_ <> '*') AND (C5_LIBEROK <> ' ') AND (C5_NOTA = ' ') AND (C5_REIMP < 1) AND ( C5_TIPO <> 'T') "
	  _cQry += " AND C5_FILIAL = '" + xFilial("SC5") + "' "  // CURITIBA      

   End

   dbUseArea( .T., "TOPCONN", TCGENQRY(,,_cQry), 'Qry' )
   _nRegua := Qry->NroRec
   Qry->( dbCloseArea() )
   
   If _nRegua > 0
   
      If MV_PAR01 <> 1

        _cQry := 'SELECT  C5_NUM As Pedido '
        _cQry += 'FROM ' + RetSqlName("SC5") + ' SC5 '
        _cQry += "WHERE     (D_E_L_E_T_ <> '*') AND (C5_LIBEROK <> ' ') AND (C5_NOTA = ' ') AND (C5_REIMP < 1) AND ( C5_TIPO <> 'T' ) AND (C5_TIPENT = '1') "

      Else

        _cQry := 'SELECT  C5_NUM As Pedido '
        _cQry += 'FROM ' + RetSqlName("SC5") + ' SC5 '
        _cQry += "WHERE     (D_E_L_E_T_ <> '*') AND (C5_LIBEROK <> ' ') AND (C5_NOTA = ' ') AND (C5_REIMP < 1) AND ( C5_TIPO <> 'T' ) "

      End

      _cQry += "AND C5_FILIAL = '" + xFilial("SC5") + "' "  // CURITIBA      
      
      dbUseArea( .T., "TOPCONN", TCGENQRY(,,_cQry), 'Qry' )

      RptImprime()

      Qry->( dbCloseArea() )

   End

   If ( LastKey() == 27 ) .Or.;
      ( Inkey() == 27 )

      Exit

   End

   _nKey := nLastKey//Inkey( 15 )

End

/*

            Deleta Arquivo Temporario e Restaura os Indices Nativos.

*/

Return

Static Function RptImprime()
SetRegua( _nRegua )

While ! ( QRY->( Eof() ) )

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Verifica a data de Emissao                                   ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ        

   SC5->( dbSeek( _fSC5 + QRY->Pedido, .F. ) )

   If DtoS( SC5->C5_EMISSAO ) >  DtoS( dDataBase )

      Set Device To Screen
      Aviso("Aviso","PEDIDO PROGRAMADO ESTE PEDIDO DEVE SER IMPRESSO SOMENTE NO DIA",{"CONTINUAR"})
      Return

   End

   If ( LastKey() == 27 ) .Or.;
      ( Inkey() == 27 )

      @ 00,01 PSAY "** CANCELADO PELO OPERADOR **"
      Exit

   End

   cPedido   := SC5->C5_NUM
   
   SC6->( dbSeek( _fSC6 + cPedido, .F. ) )

   nRegistro := SC6->( RecNo() )
   cPictQtd  := PesqPictqt("C6_QTDVEN",10)

/*

                       Monta tabela de pedidos do cliente p/ o cabe‡alho

*/

   aPedCli := {}

   _cBlq := ' '

   While ! ( SC6->( Eof() ) ) .And. SC6->C6_NUM == SC5->C5_NUM .And. SC6->C6_FILIAL == xFilial("SC6")  // CURITIBA      

      SC9->( dbSeek( _fSC9 + cPedido + SC6->C6_ITEM, .F. ) )

      If ( SC9->( dbSeek( _fSC9 + cPedido + SC6->C6_ITEM, .F. ) ) )

         If ! Empty(SC9->C9_BLCRED) .Or.;
            ! Empty(SC9->C9_BLEST)

            _cBlq := 'S'
            Exit

         End


      Else

         _cBlq := 'S'

         Exit
    
      End

      If ! Empty( SC6->C6_PEDCLI )    .And.;
         aScan(aPedCli,SC6->C6_PEDCLI) == 0
  
         aAdd( aPedCli, SC6->C6_PEDCLI )

      End

      SC6->( dbSkip() )

   End
   
   If _cBlq <> 'S'

      _cMsg := "A P R O V A D O"

      ImpPedido()

   End

   QRY->( dbSkip() )
   IncRegua()

End

Return

Static Function ImpPedido()

SA1->( dbSeek( _fSA1 + SC5->C5_CLIENTE + SC5->C5_LOJACLI, .F. ) )
SA4->( dbSeek( _fSA4 + SC5->C5_TRANSP , .F. ) )
SA3->( dbSeek( _fSA3 + SC5->C5_VEND1  , .F. ) )
SE4->( dbSeek( _fSE4 + SC5->C5_CONDPAG, .F. ) )
aSort( aPedCli )
SC6->( dbGoTo( nRegistro ) )

Li      := 50
nTotQtd := 0
nTotVal := 0
nTotLib := 0
nTotRet := 0
nTotVen := 0

While ! ( SC6->( Eof() )  ) .And. SC6->C6_NUM == SC5->C5_NUM .And. SC6->C6_FILIAL == xFilial("SC6")  // CURITIBA  

   If ( LastKey() == 27 ) .Or.;
      ( Inkey() == 27 )
      @ Prow()+1,001 PSAY "CANCELADO PELO OPERADOR"
      Exit
   End
                
   If li > 48

      If lRodape
         ImpRodape()
      End

      li := 0
      ImpCabec()
      lRodape := .T.

   End
                
   ImpItem()

   SC6->( dbSkip() )
   li ++

End
        
If lRodape

   ImpRodape()
   lRodape := .F.

End

Return


/*

                              Impressão de Cabeçalho

*/
Static Function ImpCabec

cHeader := nPed := cMoeda := cCampo := cComis := " "

//          0         1         2         3         4         5         6         7         8         9         0         1         2         3
//          0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
cHeader := "It Codigo     Desc. do Material                      Local    UM  Qtde.Ped."
//          99 xxxxxxxxxxxxxxx xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  XX   99999.99                    99999.99 999,999.99999 999,999,999.99

/*

                  Posiciona registro no cliente do pedido

*/

IF ! (SC5->C5_TIPO $ [DB] )

   SA1->( dbSeek( _fSA1 + SC5->C5_CLIENTE + SC5->C5_LOJACLI, .F. ) )

Else

   SA2->( dbSeek( _fSA2 + SC5->C5_CLIENTE + SC5->C5_LOJACLI, .F. ) )

End

@ 00,00 PSAY Chr( 27 )+'@'+CHR(15)
 
@ 01,000 PSAY Replicate( "-", limite )

If ! (SC5->C5_TIPO$"DB")

   @ 02,000 PSAY SA1->A1_COD+"/"+SA1->A1_LOJA+" "+SA1->A1_NOME

   If SC5->C5_ORCAM == "V" 
      @ 02,090 PSAY "| VALE - MERCADORIA     " 
   ElseIf SC5->C5_ORCAM == "O" 
      @ 02,090 PSAY "| ORCAMENTO             "
   Else                      
      @ 02,090 PSAY "| CONFIRMACAO DO PEDIDO "                
   End

   @ 03,000 PSAY AllTrim( SA1->A1_END ) + ' BAIRRO: ' + SA1->A1_BAIRRO
   @ 03,090 PSAY "| HORA      : " + Subs( Time(), 1, 5 )
   @ 04,000 PSAY SA1->A1_CEP
   @ 04,012 PSAY SA1->A1_MUN
   @ 04,036 PSAY SA1->A1_EST
   @ 04,090 PSAY "| EMISSAO   : "
   @ 04,104 PSAY SC5->C5_EMISSAO
   @ 05,000 PSAY SA1->A1_CGC    Picture "@R 99.999.999/9999-99"
   @ 05,021 PSAY "IE: " + SA1->A1_INSCR
   @ 05,090 PSAY "| NUMERO    : " + SC5->C5_NUM
   @ 06,000 PSAY "TEL: " + SA1->A1_TEL + "  FAX: " + SA1->A1_FAX          
   @ 06,050 PSAY "REGIAO: "
   SX5->( dbSeek( _fSX5 + "73" + Rtrim( SA1->A1_REGIAO ) ), .F. )
   @ 06,058 PSAY Alltrim( SX5->X5_DESCRI )
   @ 06,090 PSAY "| PEDIDO: "+_cMsg

Else

   @ 02,000 PSAY SA2->A2_COD+"/"+SA2->A2_LOJA+" "+SA2->A2_NOME

   If SC5->C5_ORCAM#"S"
      @ 02,090 PSAY "| CONFIRMACAO DO PEDIDO "
   Else
      @ 02,090 PSAY "| ORCAMENTO             "        
   End

   @ 03,000 PSAY SA2->A2_END
   @ 03,100 PSAY "|"
   @ 04,000 PSAY SA2->A2_CEP
   @ 04,012 PSAY SA2->A2_MUN
   @ 04,036 PSAY SA2->A2_EST
   @ 04,100 PSAY "| EMISSAO: "
   @ 04,111 PSAY SC5->C5_EMISSAO
   @ 05,000 PSAY SA2->A2_CGC    Picture "@R 99.999.999/9999-99"
   @ 05,021 PSAY "IE: "+SA2->A2_INSCR
   @ 05,100 PSAY "| NUMERO: "+SC5->C5_NUM
   @ 06,000 PSAY "TEL: "+SA1->A1_TEL + "  FAX: "+SA1->A1_FAX               


   @ 06,100 PSAY "|"
End

li := 7
@ li,000 PSAY Replicate("-",limite)
li ++

@ li,000 PSAY 'TRANSP...: '+ SC5->C5_TRANSP+'  '+ AllTrim( SA4->A4_NOME ) + ' Telefone: ' + AllTrim( SA4->A4_TEL ) + ' Bairro: ' + SA4->A4_BAIRRO
@ li,065 PSAY "TES......: "+SC6->C6_TES

RecLock( "SC5", .F. )

_nReImp := SC5->C5_REIMP

If _nReImp < 0
   _nReImp *= -1
End

_nReImp ++                                                                        

SC5->C5_REIMP := _nReImp

@ li,101 PSAY "Via: "
@ li,106 PSAY SC5->C5_REIMP Picture "9"
@ li,108 PSAY "§ Via(s)"

li ++

SA3->( dbSeek( _fSA3 + SC5->C5_VEND1, .F. ) )
//@ li,000 PSAY "VENDEDOR.: "+ iif( ! SC5->C5_TES $ [501.900], ' ', SC5->C5_VEND1 + ' ' + SA3->A3_NREDUZ )
@ li,065 PSAY "COND.PGTO: "+SC5->C5_CONDPAG+" - "+SE4->E4_DESCRI+Chr(18)+"  FORMA PGTO: "+Chr(27)+'G'+SC5->C5_CDPG

Li ++

_aPgto := {}
_cPgto := AllTrim( SE4->E4_COND )

While .T.

   _nVrg := At( ',', _cPgto )

   If _nVrg != 0
 
      aAdd( _aPgto, Substr( _cPgto, 1, _nVrg - 1 ) )
     _cPgto := Substr( _cPgto, _nVrg + 1 )

   Else

      aAdd( _aPgto, _cPgto )
      Exit

   End

End

_aDtVct := {}
_aLen   := Len( _aPgto )

For _iLen := 1 To _aLen

    _nDias := _aPgto[ _iLen ]
    _nDias := Val( _nDias )                         
    
    _nDias := SC5->C5_EMISSAO + _nDias
    Set Cent On
    _nDias := DtoC( _nDias )
    Set Cent Off

    aAdd( _aDtVct, _nDias )

Next

_nParc := SC5->C5_TOTVEN / _aLen
_nParc := Round( _nParc, 2 )

_nTot  := _nParc
_nTot  *= _aLen
_nTot  -= SC5->C5_TOTVEN
_pParc := _nParc
_pParc -= _nTot

Li ++

@ li,000 PSAY ' '

For _iLen := 1 To _aLen

   If _iLen != 1
      _pParc := _nParc
   End

   @ li,PCol() PSay 'Vencto : '
   @ li,PCol() PSay _aDtVct[ _iLen ]  // + ' Valor ' + Alltrim( Transform( _pParc, '@E 9,999,999.99' ) )
   @ li,PCol()+5 PSay ' '
   If PCol() > 60
      Li ++
      @ Li,00 PSay ' '
   End

Next

@ li,PCol() PSay Chr(27)+'H'
Li ++

@ li,000 PSAY Replicate("-",80)
li ++

@ li,000 PSAY cHeader
li ++

@ li,000 PSAY Replicate("-",80)
li ++

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ImpItem  ³ Autor ³ Claudinei M. Benzi    ³ Data ³ 05.11.92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Emissao da Pr‚-Nota                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ ImpItem(void)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Matr730                                                    ³±±
*/
Static Function ImpItem
nIPI     := 0
nVipi    := 0
nBaseIPI := 100

lIpiBruto:=IIF(GETMV("MV_IPIBRUT")=="S",.T.,.F.)

SB1->( dbSeek( _fSB1 + SC6->C6_PRODUTO, .F.) )
SF4->( dbSeek( _fSF4 + SC6->C6_TES, .F. ) )

IF SF4->F4_IPI == "S"
   nBaseIPI := IIF( SF4->F4_BASEIPI > 0, SF4->F4_BASEIPI, 100 )
   nIPI     := SB1->B1_IPI
   nVipi    := IIf(lIPIBruto .And. SC6->C6_PRUNIT > 0,SC6->C6_PRUNIT,SC6->C6_VALOR) * (nIPI/100)*(nBaseIPI/100)
End

@li,000 PSAY SC6->C6_ITEM

@li,003 PSAY SUBS(SC6->C6_PRODUTO,1,8)
@li,014 PSAY IIF(Empty(SC6->C6_DESCRI),SB1->B1_DESC,SC6->C6_DESCRI)

_aLoc := {}

If SC6->C6_LOCAL <> '09'

   If SC6->C6_RESERVA <> '      '

      SDC->( dbSeek( _fSDC           +;
                     SC6->C6_PRODUTO +;
                     SC6->C6_LOCAL   +;
                     'SC0'           +;
                     SC6->C6_RESERVA ,;
                     .T.              ;
           )       )

      While SC6->C6_PRODUTO = SDC->DC_PRODUTO .And. SC6->C6_RESERVA = SDC->DC_PEDIDO .And.;
      		SC6->C6_FILIAL == xFilial("SC6")  .And. SDC->DC_FILIAL == xFilial("SDC")  // CURITIBA    

            aAdd( _aLoc, { Substr( SDC->DC_LOCALIZ, 1, 4 ), SDC->DC_QTDORIG } )
            SDC->( dbSkip() )

      End

   Else

      SDC->( dbSeek( _fSDC +;
                     SC6->C6_PRODUTO +;
                     SC6->C6_LOCAL   +;
                     'SC6'           +;
                     SC6->C6_NUM     +;
                     SC6->C6_ITEM    ,;
                     .T.              ;
            )      )


      While SC6->C6_PRODUTO = SDC->DC_PRODUTO .And. SC6->C6_NUM     = SDC->DC_PEDIDO .And.;
      		SC6->C6_FILIAL == xFilial("SC6")  .And. SDC->DC_FILIAL == xFilial("SDC")  // CURITIBA  

            aAdd( _aLoc, { Substr( SDC->DC_LOCALIZ, 1, 4 ), SDC->DC_QTDORIG } )
            SDC->( dbSkip() )

      End

   End

   _nLen := Len( _aLoc )

   If _nLen > 0

      For i := 1 To _nLen

          @li,055 PSAY _aLoc[ i ][ 1 ] Picture "@ !!-!-'"
          @li,062 PSAY SC6->C6_UM
          @li,064 PSAY _aLoc[ i ][ 2 ] Picture "999,999.99"
          Li ++

      Next

   Else

      @li,062 PSAY SC6->C6_UM
      @li,064 PSAY SC6->C6_QTDVEN  Picture "999,999.99"


   End


Else

   @li,055 PSAY '09'
   @li,062 PSAY SC6->C6_UM
   @li,064 PSAY SC6->C6_QTDVEN  Picture "999,999.99"


End


nTotVen := nTotVen + SC6->C6_QTDVEN
nTotQtd := nTotQtd + SC6->C6_QTDVEN
nTotRet += SC6->C6_PICMRET

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ImpRodape³ Autor ³ Claudinei M. Benzi    ³ Data ³ 05.11.92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Emissao da Pr‚-Nota                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ ImpRoadpe(void)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Matr730                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ImpRodape

@ li,000 PSAY Replicate("-",80)
li ++
@ Li,PCOL() PSAY Chr( 18 ) + Chr( 27 ) + 'P' + Chr( 15 )

If nTotRet != 0

   li ++
   @ Li,057 PSay 'ATENCAO CLIENTE COM ICMS SUBSTITUICAO TRIBUTARIA VALOR'
   @ Li,118 PSay Transform( nTotRet, '@E 999,999,999.99' )
//   li ++
//  @ Li,118 PSay '--------------'
//   li ++
//   @ Li,100 PSay 'TOTAL GERAL '
//   @ Li,118 PSay Transform( nTotRet + nTotLib, '@E 999,999,999.99' )

End

Li += 2

If ! SC5->C5_TRANSP $[900000.99    ]

   @ Li,000 PSAY Chr( 18 )

   If SC5->C5_TIPENT <> '2'

      @ Li,020 PSAY Chr( 14 ) + "TRANSPORTADORA RETIRA" 

   Else

      @ Li,016 PSAY Chr( 14 ) + "ENTRAGAR NA TRANSPORTADORA" 

   End

End


If SC5->C5_REIMP > 0

   _nLin := 52
   _nLin -= Li
   _nLin /= 2
   Li += _nLin

   @ Li,000 PSAY Chr( 18 )
   @ Li,016 PSAY Chr( 14 ) + "ATENCAO, PEDIDO ALTERADO" 
   Li ++
   @ Li,013 PSAY Chr( 14 ) + "FAVOR SUBSTITUIR O ANTERIOR" + Chr( 15 )

End

@ 52,000 PSAY "Separado Por ---->   _________________________ "
@ 54,000 PSAY "Conferido Por --->   _________________________ "
@ 56,000 PSAY "Data ------------>   ________/_______/________ "

_dDta := SC5->C5_EMISSAO
_dDta += 2
                                          
If DoW( _dDta ) = 7 

   _dDta += 2

ElseIf DoW( _dDta ) = 1

   _dDta ++

End

//_cObs := AllTrim( SC5->C5_MENNOTA ) 
_cObs := AllTrim( SC5->C5_MSGNOTA )
_cObs := Substr( _cObs, 1, 130 )

@ 58,000 PSAY Chr( 27 )+'G'+'ATENCAO ESTE PEDIDO TERA VALIDADE ' + DtoC( _dDta ) + ' APOS ESTA DATA O MESMO SERA EXCLUIDO'+Chr( 27 )+'H'
@ 59,000 PSAY "Mensagem Para Nota Fiscal : " + _cObs
@ 60,000 PSAY IIF (Empty(SA1->A1_OBSTRAN)," ", SA1->A1_OBSTRAN )
@ 61,000 PSAY IIF (Empty(_cMsg)," ", _cMsg )
@ 00,000 PSAY " "

SC5->( dbUnlock() )

Return

