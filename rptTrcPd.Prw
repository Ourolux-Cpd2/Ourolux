/*/                                    
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Mega02   ³ Autor ³S‚rgio Santana         ³ Data ³07/08/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Emissao da Pr‚-Nota (Transformacao do MATR730)             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³ zera sb2->b2_reserva -> aqui nao se trabalha com empenho   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Eletromega                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Atualizacoes sofridas apos a implantacao do programa        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Autor     ³  Data    ³       ³Descricao/alteracao                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³HAROLDO   ³27/02/02  ³       ³ INCLUIR LIBERACAO AUTOMATICA P/ TES=510 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³          ³       ³                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function rptTrcPd()
#DEFINE K_ALT_A 286
#DEFINE K_ESC   27      
#IFNDEF WINDOWS
        #DEFINE PSAY SAY
#ENDIF

#IFNDEF WINDOWS
   cDesc1  :=OemToAnsi("Emiss„o da confirmac„o dos pedidos de troca, de acordo com")
   cDesc2  :=OemToAnsi("intervalo informado na op‡„o Parƒmetros.")
   cDesc3  :=OemToAnsi("Na emissao zera reserva no saldo de estoque.")
#ELSE
   cDesc1  :="Emiss„o da confirmac„o dos pedidos de troca, de acordo com"
   cDesc2  :="intervalo informado na op‡„o Parƒmetros."
   cDesc3  :="Na emissao zera reserva no saldo de estoque."
#ENDIF                          

PRIVATE titulo  :="Emissao da Pre-Troca"
PRIVATE tamanho :="M"
PRIVATE A := 1
PRIVATE nRegistro:= 0
PRIVATE  cKey    :=cCondicao:=""
PRIVATE  wnrel   :=" "
PRIVATE  cPerg   :=PadR("RPTTRC",10)
PRIVATE  aReturn := { "Zebrado", 1,"Administracao", 1, 2, 1, "",0 }
PRIVATE  nomeprog:="rptTrcPd"
PRIVATE  nLastKey:=nBegin:=nTotQtd:=nTotVal:=0
PRIVATE  eTotQtd:=eTotLib:=eTotVal:=0
PRIVATE  aLinha  :={ }
PRIVATE  li      :=80
PRIVATE  limite  :=132
PRIVATE  lRodape :=.F.
PRIVATE  cPictQtd:=""
PRIVATE  aPedCli := {}
PRIVATE  wnrel   := "rptTrcPd"
PRIVATE  cString := "SC6"
PRIVATE  lEnd    :=.f.
PRIVATE  nPerRet := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                          ³
//³ Variaveis utilizadas para parametros                        ³
//³ mv_par01              Do Pedido                             ³
//³ mv_par02              Ate o Pedido                          ³
//³ mv_par03              Data de Emissao de                    ³
//³ mv_par04              Data de Emissao ate                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
pergunte(cPerg,.F.)

wnrel:=SetPrint(cString,wnrel,cPerg,@Titulo,cDesc1,cDesc2,cDesc3,.F.)

If ( LastKey() == K_ESC ) .Or.;
   ( nLastKey  == K_ESC )

   RestScreen(3,0,24,79,cSavScr1)
   Return

End

SetDefault(aReturn,cString)

If ( LastKey() == K_ESC ) .Or.;
   ( nLastKey  == K_ESC )

   RestScreen(3,0,24,79,cSavScr1)
   Return

Endif

PRIVATE adriver:=readDriver()
if areturn[4]==5
     cdriver:=adriver[1] // 080 colunas comprimido
//   cdriver:=adriver[3] // 132 colunas comprimido
//   cdriver:=adriver[5] // 220 colunas comprimido
else 
//   cdriver:=adriver[2] // 080 colunas normal
//   cdriver:=adriver[4] // 132 colunas normal
//   cdriver:=adriver[6] // 220 colunas normal
endif


PRIVATE xRet := aReturn[5]

RptStatus({|| RptPota() })

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ RptPota  ³ Autor ³ Claudinei M. Benzi    ³ Data ³ 05.11.92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Pre-Nota                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ RptPota()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PNOTA                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RptPota()

_nRegua := Val( MV_PAR02 )
_nRegua =- Val( MV_PAR01 )
_nRegua ++

SetRegua( _nRegua )

SetPrc(0,0)
dbSelectArea("SC5")
dbSeek(xFilial("SC5")+mv_par01,.T.)

While ! Eof() .And. C5_NUM >= mv_par01 .and. C5_NUM <= mv_par02 .And.;
		C5_FILIAL == xFilial("SC5") // CURITIBA

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Verifica a data de Emissao                                   ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ        
   If DTOS(SC5->C5_EMISSAO) >  DTOS(DATE())
      Set Device To Screen
      Aviso("Aviso","PEDIDO PROGRAMADO ESTE PEDIDO DEVE SER IMPRESSO SOMENTE NO DIA",{"CONTINUAR"})
      Return
   Endif

   IncRegua()
   PRIVATE  nTotQtd :=0
   PRIVATE  nTotVal :=0
   PRIVATE  nTotLib :=0
   PRIVATE  nTotRet :=0
   PRIVATE  nTotVen :=0
   PRIVATE  eTotVen :=0
   PRIVATE  cPedido :=C5_NUM
   PRIVATE  cCred :=""

   dbSelectArea("SA1")
   dbSetOrder(1)
   dbSeek(xFilial()+SC5->C5_CLIENTE+SC5->C5_LOJACLI)
   dbSelectArea("SA4")
   dbSeek(xFilial()+SC5->C5_TRANSP)
   dbSelectArea("SA3")
   dbSeek(xFilial()+SC5->C5_VEND1)
   dbSelectArea("SE4")
   dbSeek(xFilial()+SC5->C5_CONDPAG)
   
   dbSelectArea("SC6")
   dbSeek(xFilial()+cPedido)
   nRegistro:=Recno()
   cPictQtd :=PesqPictqt("C6_QTDVEN",10)
      IF ( LastKey() == 27 ) .or. ( Inkey() == 27 )
         @ 00,01 PSAY "** CANCELADO PELO OPERADOR **"
         Exit
      Endif
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Monta tabela de pedidos do cliente p/ o cabe‡alho            ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   aPedCli := {}
   dbGoTo( nRegistro )
   TESTES := 1    //CHECA SE O TES DO CABECA DO PEDIDO E IGUAL AO TES DO ITEM 
   CCCC   := 1    //CREDITO
   EEEE   := 1    //ESTOQUE
   PPPP   := 1    //PRECO ABAIXO
   DDDD   := 1    //CONDICAO PAGTO DDL
//   IF SC5->C5_TES<>SC6->C6_TES
//      TESTES := 2
//   ENDIF

   //If SA1->A1_ATIVIDA<> "DIRET"
      IF SA1->A1_COND <> SC5->C5_CONDPAG
         IF SC5->C5_TOTVEN < 250.01 .AND. SC5->C5_CONDPAG # "000" .AND. SC5->C5_LIBCP==" "
            DDDD := 2
         ENDIF
         IF SC5->C5_TOTVEN > 250.01 .AND. SC5->C5_TOTVEN < 600.01 .AND. SC5->C5_CONDPAG > "028" .AND. SC5->C5_LIBCP==" "
            DDDD := 2
         ENDIF
         IF SC5->C5_TOTVEN > 600.01 .AND. SC5->C5_CONDPAG > "028" .AND. SC5->C5_LIBCP==" "
            DDDD := 2
         ENDIF
         IF SC5->C5_TOTVEN > 1200.01 .AND.; 
            SC5->C5_CONDPAG > "028" .AND. !(SC5->C5_CONDPAG $ "108/109") .and.;
            SC5->C5_LIBCP == " " 
            DDDD := 2
         ENDIF 
      ENDIF
   //Endif

   While !Eof() .And. C6_NUM == SC5->C5_NUM .And.;
   		 C5_FILIAL == xFilial("SC5") .And.;    // CURITIBA
   		 C6_FILIAL == xFilial("SC6")          // CURITIBA
      
      dbSelectArea("SC9")
      dbSeek(xFilial()+cPedido+SC6->C6_ITEM)
      //CUIDADO COM ESTA ROTINA QUE CCCC E EEEE SOMENTE PODEM VIRAR PARA 2 
      //NUNCA VOLTAR PARA 1
      IF FOUND() 
         IF Empty(SC9->C9_BLCRED) .AND. Empty(SC9->C9_BLEST)
                                     //  xMENCRED := "APROVADO"
         ELSE
            IF !Empty(SC9->C9_BLCRED)
                                     //  xMENCRED := "REPROVADO CREDITO"
               CCCC := 2
            ENDIF
            IF !Empty(SC9->C9_BLEST)
                                     //  xMENCRED := "REPROVADO ESTOQUE"
               EEEE := 2
            ENDIF
            IF Empty(SC9->C9_BLEST) .AND. Empty(SC9->C9_BLCRED)
                                     //  xMENCRED := "REPROVADO EST.e CRED."
               CCCC := 2
               EEEE := 2
            ENDIF
         ENDIF
      ELSE
         xMENCRED := "NAO LIBERADO"
         CCCC := 99
         EEEE := 99
         PPPP := 99
         DDDD := 99
      ENDIF
      //ESTA ROTINA ZERA O CAMPO B2_RESERVA
      //PORQUE NA ELETROMEGA QUEM FATURAR PRIMEIRO LEVA O ESTOQUE
      //E RECALCULA O SALDO EM VALOR DO ESTOQUE
//      dbSelectArea("SB2")
//      Set Order To 1
//      dbSeek(xFilial()+SC6->C6_PRODUTO,.t.)
//      WHILE !EOF() .AND. B2_COD == SC6->C6_PRODUTO .AND. B2_LOCAL == SC6->C6_LOCAL
//          While !RLock()
//          EndDo
//          SB2->B2_VATU1   := SB2->B2_QATU * SB2->B2_CM1
//          SB2->B2_RESERVA := 0
//          UNLOCK
//          DBSKIP()
//      ENDDO
      dbSelectArea("SC6")
      //CUIDADO COM ESTA ROTINA QUE PPPP SOMENTE PODE VIRAR PARA 2 
      //NUNCA VOLTAR PARA 1
      
      IF !Empty(SC6->C6_PEDCLI) .and. Ascan(aPedCli,SC6->C6_PEDCLI) == 0
         AAdd(aPedCli,SC6->C6_PEDCLI)
      ENDIF
      /*If SC6->C6_PRCBX > 0 .AND. Empty(SC6->C6_LIBPBX)
         IF SC6->C6_TES<>"599" //LIBERA PRECO ABAIXO PARA NF RETORNO DE TROCA
            PPPP := 2
         ENDIF
      Endif*/
      dbSkip()
   Enddo
   
   IF EEEE == 1 .AND. CCCC == 1 .AND. PPPP == 1 .AND. DDDD == 1  //1
         xMENCRED := "A P R O V A D O"
   ENDIF
   IF EEEE == 1 .AND. CCCC == 1 .AND. PPPP == 1 .AND. DDDD == 2  //2
         xMENCRED := "REPROVADO NA COND.PAGTO"
   ENDIF
   IF EEEE == 1 .AND. CCCC == 1 .AND. PPPP == 2 .AND. DDDD == 1  //3 
         xMENCRED := "REPROVADO NO PRECO"
   ENDIF
   IF EEEE == 1 .AND. CCCC == 1 .AND. PPPP == 2 .AND. DDDD == 2  //4
         xMENCRED := "REPROVADO NO PRECO E COND.PAGTO"
   ENDIF
   IF EEEE == 1 .AND. CCCC == 2 .AND. PPPP == 1 .AND. DDDD == 1  //5
         xMENCRED := "REPROVADO NO CREDITO"
   ENDIF
   IF EEEE == 1 .AND. CCCC == 2 .AND. PPPP == 1 .AND. DDDD == 2  //6
         xMENCRED := "REPROVADO CREDITO E COND.PAGTO"
   ENDIF
   IF EEEE == 1 .AND. CCCC == 2 .AND. PPPP == 2 .AND. DDDD == 1  //7
         xMENCRED := "REPROVADO CREDITO E PRECO"
   ENDIF
   IF EEEE == 1 .AND. CCCC == 2 .AND. PPPP == 2 .AND. DDDD == 2  //8
         xMENCRED := "REPROVADO CREDITO, PRECO E COND.PAGTO"
   ENDIF
   IF EEEE == 2 .AND. CCCC == 1 .AND. PPPP == 1 .AND. DDDD == 1  //9
         xMENCRED := "REPROVADO ESTOQUE"
   ENDIF
   IF EEEE == 2 .AND. CCCC == 1 .AND. PPPP == 1 .AND. DDDD == 2  //10
         xMENCRED := "REPROVADO EST. E COND.PAGTO"
   ENDIF
   IF EEEE == 2 .AND. CCCC == 1 .AND. PPPP == 2 .AND. DDDD == 1  //11
         xMENCRED := "REPROVADO ESTOQUE E PRECO"
   ENDIF
   IF EEEE == 2 .AND. CCCC == 1 .AND. PPPP == 2 .AND. DDDD == 2  //12
         xMENCRED := "REPROVADO ESTOQUE, PRECO E COND.PAGTO"
   ENDIF
   IF EEEE == 2 .AND. CCCC == 2 .AND. PPPP == 1 .AND. DDDD == 1  //13
         xMENCRED := "REPROVADO EST.e CRED."
   ENDIF
   IF EEEE == 2 .AND. CCCC == 2 .AND. PPPP == 1 .AND. DDDD == 2  //14
         xMENCRED := "REPROVADO EST., CRED.E COND.PAGTO"
   ENDIF
   IF EEEE == 2 .AND. CCCC == 2 .AND. PPPP == 2 .AND. DDDD == 1  //15
         xMENCRED := "REPROVADO EST., CRED E PRECO"
   ENDIF
   IF EEEE == 2 .AND. CCCC == 2 .AND. PPPP == 2 .AND. DDDD == 2  //16
         xMENCRED := "REPROVADO EST.,CRED,PRECO E COND.PAGTO"
   ENDIF
   IF TESTES == 2    
      xMENCRED := "TES ERRADO NO CORPO OU NO ITEM DO PEDIDO"
      EEEE := 2
      CCCC := 2
      PPPP := 2
      DDDD := 2
   ENDIF

//   IF EEEE == 1 .AND. CCCC == 1 .AND. PPPP == 1 .AND. DDDD == 1

      aSort(aPedCli)

      dbSelectArea( 'SD1' )
      dbSetOrder( 1 )
      dbSeek(xFilial()+SC5->C5_NUM+"TRC")

      While !( SD1->( Eof() ) ) .And. SD1->D1_DOC == SC5->C5_NUM .And.;
      		SD1->D1_FILIAL == xFilial("SD1") .And.;             // CURITIBA
      		SC5->C5_FILIAL == xFilial("SC5")                    // CURITIBA

         IF ( LastKey() == 27 ) .or. ( Inkey() == 27 )
            lEnd := .t.
         Endif

         IF lEnd
            @ Prow()+1,001 PSAY "CANCELADO PELO OPERADOR"
            Exit
         Endif
                
         IF li > 48
            IF lRodape
               ImpRodape()
            Endif
            li := 0
            ImpCabec()
            lRodape:=.T.
         Endif
                
         
         ImpItemEnt()
         SD1->( dbSkip() )

         If SD1->D1_SERIE <> 'TRC'

            Exit

         End

         li++

      Enddo

      @ li,118 PSAY "--------------"
      Li ++

      @ li,000 PSAY "TOTAIS ENTRADAS --------> "
      @ li,057 PSAY eTotVen Picture PesqPict("SC6","C6_VALOR",17)
      @ li,093 PSAY eTotQtd Picture cPictQtd
      @ li,118 PSAY eTotLib Picture "@E 999,999,999.99"
      Li ++

      @ li,000 PSAY Replicate("-",limite)
      Li ++

      dbSelectArea( 'SC6' )
      dbGoTo( nRegistro )
      While !Eof() .And. C6_NUM == SC5->C5_NUM

         IF ( LastKey() == 27 ) .Or.;
            ( Inkey() == 27 )
            lEnd := .T.
         Endif

         IF lEnd
            @ Prow()+1,001 PSAY "CANCELADO PELO OPERADOR"
            Exit
         Endif
                
         IF li > 48
            IF lRodape
               ImpRodape()
            Endif
            li := 0
            ImpCabec()
            lRodape:=.T.
         Endif
                
         ImpItem()
         dbSkip()
         li:=li+1

      Enddo


      @ li,118 PSAY '--------------'
      Li ++

      @ li,000 PSAY "TOTAIS SAIDAS ----------> "
      @ li,057 PSAY nTotVen Picture PesqPict("SC6","C6_VALOR",17)
      @ li,093 PSAY nTotQtd Picture cPictQtd
      @ li,118 PSAY nTotLib Picture "@E 999,999,999.99"
      Li ++
      @ li,118 PSAY "--------------"
      Li ++

      @ li,000 PSAY "TOTAL GERAL  -----------> "
      @ li,118 PSAY ( nTotLib - eTotLib ) Picture "@)E 999,999,999.99" 
      Li ++

      @ li,000 PSAY Replicate("-",limite)
      Li ++

      @ Li,000 PSAY 'SITUACAO DO PEDIDO: ' + xMENCRED
      Li ++

      IF lRodape
         ImpRodape()
         lRodape:=.F.
      Endif

      SET DEVICE TO SCREEN

      If SC5->C5_REIMP > 1
         Aviso("O Pedido Nº: "+SC5->C5_NUM,"Já Foi Impresso, VERIFIQUE!!!",{"OK"})
      Endif      
      SET DEVICE TO PRINTER

//   ELSE

//      SET DEVICE TO SCREEN
//      Aviso("Situacao Pedido N. "+SC5->C5_NUM,xMENCRED,{"OK"})

//   ENDIF
   dbSelectArea("SC5")
   dbSkip()

Enddo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Deleta Arquivo Temporario e Restaura os Indices Nativos.     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SC5")
Set Filter to
dbGotop()

dbSelectArea("SC6")
Set Filter To
dbGotop()

If xRet == 1
   dbCommitAll()
   OurSpool(wnrel)
Endif

Ms_Flush()
Set device to screen
Set Printer To

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ImpCabec ³ Autor ³ Claudinei M. Benzi    ³ Data ³ 05.11.92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Emissao da Pr‚-Nota                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ ImpCabec(void)                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Matr730                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ImpCabec

SetPrc(0,0)

cHeader:=nPed:=cMoeda:=cCampo:=cComis:=" "

//          0         1         2         3         4         5         6         7         8         9         0         1         2         3
//          0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
cHeader := "It Codigo     Desc. do Material                      Local    UM  Qtde.Ped.                   Qtde.Lib.      R$ Unit.       R$ Total"
//          99 xxxxxxxxxxxxxxx xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  XX   99999.99                    99999.99 999,999.99999 999,999,999.99

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona registro no cliente do pedido                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

IF !(SC5->C5_TIPO$"DB")
   dbSelectArea("SA1")
   dbSeek(xFilial()+SC5->C5_CLIENTE+SC5->C5_LOJACLI)
Else
   dbSelectArea("SA2")
   dbSeek(xFilial()+SC5->C5_CLIENTE+SC5->C5_LOJACLI)
Endif

@ Prow(),PCol() PSAY CHR(15)
 
@ 01,000 PSAY Replicate("-",limite)

IF !(SC5->C5_TIPO$"DB")
   @ 02,000 PSAY SA1->A1_COD+"/"+SA1->A1_LOJA+" "+SA1->A1_NOME
   IF SC5->C5_ORCAM == "V" 
      @ 02,090 PSAY "| VALE - MERCADORIA     " 
   ELSEIF SC5->C5_ORCAM == "O" 
      @ 02,090 PSAY "| ORCAMENTO             "
   ELSE                        
      @ 02,090 PSAY "| CONFIRMACAO DA TROCA  "                
   ENDIF                

   @ 03,000 PSAY SA1->A1_END
   @ 03,090 PSAY "| HORA      : "+Subs(Time(),1,5)
   @ 04,000 PSAY SA1->A1_CEP
   @ 04,012 PSAY SA1->A1_MUN
   @ 04,036 PSAY SA1->A1_EST
   @ 04,090 PSAY "| EMISSAO   : "
   @ 04,104 PSAY SC5->C5_EMISSAO
   @ 05,000 PSAY SA1->A1_CGC    Picture "@R 99.999.999/9999-99"
   @ 05,021 PSAY "IE: "+SA1->A1_INSCR
   @ 05,090 PSAY "| NUMERO    : "+SC5->C5_NUM
   @ 06,000 PSAY "TEL: "+SA1->A1_TEL + "  FAX: "+SA1->A1_FAX          
   @ 06,050 PSAY "REGIAO: "
   dbSelectArea("SX5")
   dbSetOrder(1)
   dbSeek(xFilial()+"73"+Rtrim(SA1->A1_REGIAO))
   @ 06,058 PSAY Alltrim(SX5->X5_DESCRI)
   @ 06,090 PSAY "| PEDIDO: "+xMENCRED
Else
   @ 02,000 PSAY SA2->A2_COD+"/"+SA2->A2_LOJA+" "+SA2->A2_NOME
   IF SC5->C5_ORCAM#"S"
      @ 02,090 PSAY "| CONFIRMACAO DA TROCA  "
   ELSE
      @ 02,090 PSAY "| ORCAMENTO             "        
   ENDIF                        

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
Endif

li := 7

@ li,000 PSAY Replicate("-",limite)
li:=li+1

@ li,000 PSAY "TRANSP...: "+SC5->C5_TRANSP+"  "+SA4->A4_NOME
@ li,065 PSAY "TES......: "+SC6->C6_TES

aLiaTu := Alias()

*  ABAIXO O PROGRAMA MARCA O POSICIONAMENTO NOS ARQUIVOS !!!

PonteiroF2 := SF2->(Recno())
//PonteiroD2 := SD2->(Recno())
PonteiroE1 := SE1->(Recno())
PonteiroC5 := SC5->(Recno())
PonteiroC6 := SC6->(Recno())

PRIVATE aPedAbert := {}
While SC6->C6_Tes == "501" .AND. SA1->A1_COD # "999999"

   * ----- Analisa se o Cliente em Questao Possui Vales em Aberto ! ------ *

   PRIVATE xAliasAnt := Alias() 
   
   dbSelectArea("SF2")
   dbSetOrder(2)
   dbSeek(xFilial("SF2")+SA1->A1_COD)
   If Eof()
      dbSelectArea(xAliasAnt)
      Exit
   Else
      While .T.
         IF SF2->F2_Cliente # SA1->A1_Cod
            dbSelectArea(xAliasAnt)
            Exit
         Endif
         IF SF2->F2_Serie == "ORC" .Or. SF2->F2_Serie == "SN "
            dbSelectArea("SD2")
            dbSetOrder(3)
            dbSeek(xFilial("SD2")+SF2->F2_Doc+SF2->F2_Serie)

            dbSelectArea("SE1")
            dbSetOrder(1)
            dbSeek(xFilial("SE1")+SF2->F2_Serie+SF2->F2_Doc)
            If ! Empty(SE1->E1_Baixa) .Or. ! Empty(SE1->E1_Hist)
               dbSelectArea("SF2")
               dbSkip()
               Loop
            Endif

            dbSelectArea("SC5")
            dbSetOrder(1)
            dbSeek(xFilial("SC5")+SD2->D2_Pedido)
            If SC5->C5_ORCAM == "V"
               AADD(aPedAbert,{SF2->F2_Doc,SC5->C5_Num,SC5->C5_Emissao,SF2->F2_ValBrut,dDataBase-SE1->E1_Emissao,SF2->F2_Serie})
            Endif
         Endif
         dbSelectArea("SF2")
         dbSkip()
      Enddo
      dbSelectArea("SC6")
      dbSeek(xFilial()+cPedido)

   EndIf

   dbSelectArea(xAliasAnt)
   Exit

End

*  ABAIXO RESTAURA O POSICIONAMENTO DOS ARQUIVOS !!!

SF2->(dbGoTo(PonteiroF2))
//SD2->(dbGoTo(PonteiroD2))
SE1->(dbGoTo(PonteiroE1))
SC5->(dbGoTo(PonteiroC5))
SC6->(dbGoTo(PonteiroC6))

li:=li+1

**dbSelectArea("SC6")
**dbSeek(xFilial()+cPedido)

**dbSelectArea("SC5")
**dbSeek(xFilial()+cPedido)

dbSelectArea("SA3")
dbSeek(xFilial()+SC5->C5_VEND1)
@ li,000 PSAY "VENDEDOR.: "+SC5->C5_VEND1 + ' ' + SA3->A3_NREDUZ
@ li,065 PSAY "COND.PGTO: "+SC5->C5_CONDPAG+" - "+SE4->E4_DESCRI+"  FORMA PGTO: "+SC5->C5_CDPG
li:=li+1

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
    _nDias ++
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
   @ li,PCol() PSay _aDtVct[ _iLen ] + ' Valor ' + Alltrim( Transform( _pParc, '@E 9,999,999.99' ) )
   @ li,PCol()+10 PSay ' '

Next

Li += 2

@ li,000 PSAY Replicate("-",limite)
li:=li+1

@ li,000 PSAY cHeader
li:=li+1

@ li,000 PSAY Replicate("-",limite)
li:=li+1

Return

/*/
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
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ImpItem
nIPI :=0
nVipi:=0
nBaseIPI :=100
lIpiBruto:=IIF(GETMV("MV_IPIBRUT")=="S",.T.,.F.)

dbSelectArea("SB1")
dbSeek(xFilial()+SC6->C6_PRODUTO)
dbSelectArea("SF4")
dbSeek(xFilial()+SC6->C6_TES)
IF SF4->F4_IPI == "S"
   nBaseIPI := IIF(SF4->F4_BASEIPI > 0,SF4->F4_BASEIPI,100)
   nIPI := SB1->B1_IPI
   nVipi:= IIf(lIPIBruto .And. SC6->C6_PRUNIT > 0,SC6->C6_PRUNIT,SC6->C6_VALOR) * (nIPI/100)*(nBaseIPI/100)
Endif

nItemLib:=(SC6->C6_PRCVEN*SC6->C6_QTDVEN)

@li,000 PSAY SC6->C6_ITEM
@li,003 PSAY SUBS(SC6->C6_PRODUTO,1,8)
@li,014 PSAY IIF(Empty(SC6->C6_DESCRI),SB1->B1_DESC,SC6->C6_DESCRI)
@li,055 PSAY SC6->C6_LOCAL  && denilson
@li,062 PSAY SC6->C6_UM

@li,064 PSAY SC6->C6_QTDVEN                        Picture "@E 999,999.99"
@li,092 PSAY SC6->C6_QTDVEN                        Picture "@E 999,999.99"
@li,105 PSAY SC6->C6_PRCVEN                        Picture PesqPict("SC6","C6_PRCVEN",12)
@li,118 PSAY nItemLib                              Picture "@E 999,999,999.99"

nTotVen := nTotVen + SC6->C6_QTDVEN
nTotQtd := nTotQtd + SC6->C6_QTDVEN
nTotLib := nTotLib + nItemLib
nTotRet += SC6->C6_PICMRET

dbSelectArea("SC6")
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
//li,000 PSAY Replicate("-",limite)
//:=li+1
//li,000 PSAY "T O T A I S   ----------> "

//li,057 PSAY nTotVen Picture PesqPict("SC6","C6_VALOR",17)
//li,093 PSAY nTotQtd Picture cPictQtd
//li,118 PSAY nTotLib Picture "999,999,999.99"

If nTotRet != 0

   li ++
   @ Li,057 PSay 'ATENCAO CLIENTE COM ICMS SUBSTITUICAO TRIBUTARIA VALOR'
   @ Li,118 PSay Transform( nTotRet, '@E 999,999,999.99' )
   li ++
   @ Li,118 PSay '--------------'
   li ++
   @ Li,100 PSay 'TOTAL GERAL '
   @ Li,118 PSay Transform( nTotRet + nTotLib, '@E 999,999,999.99' )

End

@ 52,000 PSAY "Separado Por ---->   _________________________ "
@ 54,000 PSAY "Conferido Por --->   _________________________ "
@ 56,000 PSAY "Data ------------>   ________/_______/________ "

@ 59,000 PSAY "Mensagem Para Nota Fiscal : "+AllTrim(SC5->C5_MSGNOTA)
//@ 59,000 PSAY "Mensagem Para Nota Fiscal : "+AllTrim(SC5->C5_MENNOTA)
@ 60,000 PSAY SA1->A1_OBSTRAN
@ 61,000 PSAY xMencred
dbSelectArea("SC5")
//RecLock("SC5")
//SC5->C5_REIMP := SC5->C5_REIMP + 1
//dbUnlock()

@ 61,118 PSAY "Via: "
@ 61,124 PSAY SC5->C5_REIMP Picture "9"
@ 61,125 PSAY "§ Via"

dbSelectArea("SC6")

@ 61,000 PSAY " "

@ 61,000 PSAY ""

__Eject()

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A730verIcm³ Autor ³ Claudinei M. Benzi    ³ Data ³ 11.02.92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rotina para verificar qual e o ICM do Estado               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA460                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function A730VerIcm
nPerRet:=0              // Percentual de retorno
cEstado:=GetMV("mv_estado")
tNorte:=GetMV("MV_NORTE")
cEstCli:=IIF(SC5->C5_TIPO$"DB",SA2->A2_EST,SA1->A1_EST)
cInscrCli:=IIF(SC5->C5_TIPO$"DB",SA2->A2_INSCR,SA1->A1_INSCR)

If SF4->F4_ICM == "S"
        IF !(SC5->C5_TIPO $ "D")
                If SC5->C5_TIPOCLI == "F" .and. Empty(cInscrCli)
                        nPerRet := iif(SB1->B1_PICM>0,SB1->B1_PICM,GetMV("MV_ICMPAD"))
                Elseif SB1->B1_PICM > 0 .And. cEstCli == cEstado
                        nPerRet := SB1->B1_PICM
                Elseif cEstCli == cEstado
                        nPerRet := GetMV("MV_ICMPAD")
                Elseif cEstCli $ tNorte .And. At(cEstado,tNorte) == 0
                        nPerRet := 7
                Elseif SC5->C5_TIPOCLI == "X"
                        nPerRet := 13
                Else
                        nPerRet := 12
                Endif
        Else
                If cEstCLI == GetMV("MV_ESTADO")
                        nPerRet := GetMV("MV_ICMPAD")
                Elseif !(cEstCli $ GetMV("MV_NORTE")) .And. ;
                                GetMv("mv_estado") $ GetMV("MV_NORTE")
                        nPerRet := 7
                Else
                        nPerRet := 12
                Endif
                If SB1->B1_PICM != 0 .And. (cEstCli==GetMv("MV_ESTADO"))
                        nPerRet := SB1->B1_PICM
                Endif
        Endif
Endif

Return
/*/
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
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ImpItemEnt
nIPI :=0
nVipi:=0
nBaseIPI :=100
lIpiBruto:=IIF(GETMV("MV_IPIBRUT")=="S",.T.,.F.)

nItemLib := SD1->D1_VUNIT
nItemLib -= SD1->D1_VALDESC
nItemLib *= SD1->D1_QUANT

dbSelectArea("SB1")
dbSeek(xFilial()+SD1->D1_COD)
dbSelectArea("SF4")
dbSeek(xFilial()+SD1->D1_TES)
IF SF4->F4_IPI == "S"
   nBaseIPI := IIF(SF4->F4_BASEIPI > 0,SF4->F4_BASEIPI,100)
   nIPI := SB1->B1_IPI
   nVipi:= IIf(lIPIBruto .And. nItemLib > 0,nItemLib,nItemLib) * (nIPI/100)*(nBaseIPI/100)
Endif

@li,000 PSAY SD1->D1_ITEM
@li,003 PSAY SUBS(SD1->D1_COD,1,8)
@li,014 PSAY IIF(Empty(SB1->B1_DESC),SB1->B1_DESC,SB1->B1_DESC)
@li,055 PSAY SD1->D1_LOCAL  && denilson
@li,062 PSAY SD1->D1_UM

@li,065 PSAY SD1->D1_QUANT                         Picture "@E 999,999.99"
@li,093 PSAY SD1->D1_QUANT                         Picture "@E 999,999.99"
@li,105 PSAY ( SD1->D1_VUNIT - ( SD1->D1_VALDESC / SD1->D1_QUANT ) )   Picture PesqPict("SC6","C6_PRCVEN",13)
@li,119 PSAY nItemLib                              Picture "@E 999,999,999.99"

eTotVen += SD1->D1_QUANT
eTotQtd += SD1->D1_QUANT
eTotLib += nItemLib
//nTotRet += SD1->D1_VALICM

Return()
