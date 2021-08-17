#IFNDEF WINDOWS
   #DEFINE PSAY SAY
#ENDIF
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³  Mega08  ³ Autor ³Airton Lira            ³ Data ³03/10/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Impressao do "Orcamento" - Uso Exclusivo da Eletromega     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01             // Do Orcamento                         ³
//³ mv_par02             // Ate o Orcamento                      ³
//³ mv_par03             // Da Serie                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

/* alterado em 05/07/05 para impressao na hp deskjet 840, com a troca do tamanho
para 80 colunas em fomato retrato, para se enviar orçamentos p/ clientes via fax*/

// versao final 25/10/05 por felipe trocando limite=132, tamanho=M e nLin=132  
// Para ser impresso no SPOOL
User Function IMPORC
#Include "rwmake.ch"
PRIVATE CbTxt:=""
PRIVATE CbCont:=""
PRIVATE nOrdem :=0
PRIVATE Alfa := 0
PRIVATE Z:=0
PRIVATE M:=0
PRIVATE tamanho:="M" // alterado por felipe
PRIVATE limite:=132 // alterado por felipe
PRIVATE titulo :=PADC("MEGA08 - Orcamento",74)
PRIVATE cDesc1 :=PADC("Este Programa tem a Finalidade de Emitir o(s) Or‡amento(s) Gerados  ",74)
PRIVATE cDesc2 :=PADC("pelo Sistema.Desenvolvido para Uso Exclusivo da Empresa EletroMega  ",74)
PRIVATE cDesc3 :=PADC("                                                                    ",74)
PRIVATE cNatureza:=""
PRIVATE aReturn := { "Especial", 1,"Administracao", 2, 2, 1,"",1 }
PRIVATE nomeprog:="IMPORC"
PRIVATE cPerg:="MEGA08"
PRIVATE nLastKey:= 0
PRIVATE lContinua := .T.
Private nLin:=132  // alterado por felipe
PRIVATE Wnrel := "IMPORC"

Pergunte(cPerg,.F.)               // Pergunta no SX1

PRIVATE cString:="SF2"

Wnrel:=SetPrint(cString,Wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.T.,,.F.,tamanho)

If nLastKey == 27
   Return
Endif

SetDefault(aReturn,cString)
If nLastKey == 27
        Return
Endif

//VerImp()
RptDetailorc()

Return

Static Function RptDetailorc

dbSelectArea("SF2")                // * Cabecalho da Nota Fiscal Saida
dbSetOrder(1)
dbSeek(xFilial()+mv_par01+mv_par03,.t.)
        
dbSelectArea("SD2")                // * Itens de Venda da Nota Fiscal
dbSetOrder(3)
dbSeek(xFilial()+mv_par01+mv_par03)
cPedant := SD2->D2_PEDIDO

IF SD2->D2_TES != "900"
   Set Device To Screen
   Aviso("Aviso","Voce esta tentando imprimir uma nf como orcamento",{"OK"})
   Return
Endif   

While !Eof() .And. D2_DOC == mv_par01 .And. D2_SERIE == mv_par03
   Select SC6
   Set Order To 1
   Seek xFilial()+SD2->D2_PEDIDO+SD2->D2_ITEMPV+SD2->D2_COD
   If C6_PRCVEN <> SD2->D2_PRCVEN
      Set Device To Screen
      Aviso("Aviso","Houve um erro na geracao do Orcamento confira o Pedido N." + SD2->D2_PEDIDO,{"OK"})
      Aviso("Aviso","Verifique o Produto : "+SD2->D2_COD+" Preco Ped. "+AllTrim(Transf(C6_PRCVEN,"@E 9,999.99999"))+" Preco nf. "+AllTrim(Transf(SD2->D2_PRCVEN,"@E 9,999.99999")),{"OK"})
      Return
   EndIf
   Select SD2
   Skip
EndDo

dbSelectArea("SD2")                // * Itens de Venda da Nota Fiscal
dbSetOrder(3)
dbSeek(xFilial()+mv_par01+mv_par03)
cPedant := SD2->D2_PEDIDO

dbSelectArea("SF2")
While !eof() .and. SF2->F2_DOC    <= mv_par02 .and. lContinua
        
   If SF2->F2_SERIE # mv_par03    // Se a Serie do Arquivo for Diferente
      dbSkip()                    // do Parametro Informado !!!
      Loop
   Endif
        
   IF LastKey()==286
         @ 00,01 PSAY "** CANCELADO PELO OPERADOR **"
         lContinua := .F.
         Exit
   Endif
        
   xNum_Nf     :=SF2->F2_DOC             // Numero
   xSerie      :=SF2->F2_SERIE           // Serie
   xEmissao    :=SF2->F2_EMISSAO         // Data de Emissao
   xTot_Fat    :=SF2->F2_VALFAT          // Valor Total da Fatura
   If xTot_Fat == 0
      xTot_Fat := SF2->F2_Valmerc+SF2->F2_Valipi+SF2->F2_Seguro+SF2->F2_Frete
   Endif

   xLOJA       :=SF2->F2_LOJA            // Loja do Cliente
   xFRETE      :=SF2->F2_FRETE           // Frete
   xSEGURO     :=SF2->F2_SEGURO          // Seguro
   xBASE_ICMS  :=SF2->F2_BASEICM         // Base   do ICMS
   xBASE_IPI   :=SF2->F2_BASEIPI         // Base   do IPI
   xVALOR_ICMS :=SF2->F2_VALICM          // Valor  do ICMS
   xICMS_RET   :=SF2->F2_ICMSRET         // Valor  do ICMS Retido
   xVALOR_IPI  :=SF2->F2_VALIPI          // Valor  do IPI
   xVALOR_MERC :=SF2->F2_VALMERC         // Valor  da Mercadoria
   xNUM_DUPLIC :=SF2->F2_DUPL            // Numero da Duplicata
   xCOND_PAG   :=SF2->F2_COND            // Condicao de Pagamento
   xPBRUTO     :=SF2->F2_PBRUTO          // Peso Bruto
   xPLIQUI     :=SF2->F2_PLIQUI          // Peso Liquido
   xTIPO       :=SF2->F2_TIPO            // Tipo do Cliente
   xESPECIE    :=SF2->F2_ESPECI1         // Especie 1 no Pedido
   xVOLUME     :=SF2->F2_VOLUME1         // Volume 1 no Pedido
        
   dbSelectArea("SD2")                   // * Itens de Venda da N.F.
   dbSetOrder(3)
   dbSeek(xFilial()+xNUM_NF+xSERIE)
       
   cPedAtu  := SD2->D2_PEDIDO
   cItemAtu := SD2->D2_ITEMPV
        
   xPED_VEND:={}                         // Numero do Pedido de Venda
   xITEM_PED:={}                         // Numero do Item do Pedido de Venda
   xNUM_NFDV:={}                         // nUMERO QUANDO HOUVER DEVOLUCAO
   xPREF_DV :={}                         // Serie  quando houver devolucao
   xICMS    :={}                         // Porcentagem do ICMS
   xCOD_PRO :={}                         // Codigo  do Produto
   xQTD_PRO :={}                         // Peso/Quantidade do Produto
   xPRE_UNI :={}                         // Preco Unitario de Venda
   xPRE_TAB :={}                         // Preco Unitario de Tabela
   xIPI     :={}                         // Porcentagem do IPI
   xVAL_IPI :={}                         // Valor do IPI
   xDESC    :={}                         // Desconto por Item
   xVAL_DESC:={}                         // Valor do Desconto
   xVAL_MERC:={}                         // Valor da Mercadoria
   xTES     :={}                         // TES
   xCF      :={}                         // Classificacao quanto natureza da Operacao
   xICMSOL  :={}                         // Base do ICMS Solidario
   xICM_PROD:={}                         // ICMS do Produto
   xUNID_PRO:={}                           // Unidade do Produto        
   While !eof() .and. SD2->D2_DOC==xNUM_NF .and. SD2->D2_SERIE==xSERIE
      If SD2->D2_SERIE # mv_par03        // Se a Serie do Arquivo for Diferente
         dbSkip()                   // do Parametro Informado !!!
         Loop
      Endif
      AADD(xPED_VEND ,SD2->D2_PEDIDO)
      AADD(xITEM_PED ,SD2->D2_ITEMPV)
      AADD(xNUM_NFDV ,IIF(Empty(SD2->D2_NFORI),"",SD2->D2_NFORI))
      AADD(xPREF_DV  ,SD2->D2_SERIORI)
      AADD(xUNID_PRO ,SD2->D2_UM)
      AADD(xICMS     ,IIf(Empty(SD2->D2_PICM),0,SD2->D2_PICM))
      AADD(xCOD_PRO  ,SD2->D2_COD)
      AADD(xQTD_PRO  ,SD2->D2_QUANT)     // Guarda as quant. da NF
      AADD(xPRE_UNI  ,SD2->D2_PRCVEN)
      AADD(xPRE_TAB  ,SD2->D2_PRUNIT)
      AADD(xIPI      ,IIF(Empty(SD2->D2_IPI),0,SD2->D2_IPI))
      AADD(xVAL_IPI  ,SD2->D2_VALIPI)
      AADD(xDESC     ,SD2->D2_DESC)
      AADD(xVAL_MERC ,SD2->D2_TOTAL)
      AADD(xTES      ,SD2->D2_TES)
      AADD(xCF       ,SD2->D2_CF)
      AADD(xICM_PROD ,IIf(Empty(SD2->D2_PICM),0,SD2->D2_PICM))
      AADD(xVAl_DESC ,SD2->D2_DESCON)
      dbskip()
   End
        
   dbSelectArea("SB1")                     // * Desc. Generica do Produto
   dbSetOrder(1)
   xPESO_PRO:={}                           // Peso Liquido
   xPESO_UNIT :={}                         // Peso Unitario do Produto
   xCOD_TRIB:={}                           // Codigo de Tributacao
   xMEN_TRIB:={}                           // Mensagens de Tributacao
   xCOD_FIS :={}                           // Cogigo Fiscal
   xCLAS_FIS:={}                           // Classificacao Fiscal
   xMEN_POS :={}                           // Mensagem da Posicao IPI
   xISS     :={}                           // Aliquota de ISS
   xTIPO_PRO:={}                           // Tipo do Produto
   xLUCRO   :={}                           // Margem de Lucro p/ ICMS Solidario
   xCLFISCAL   :={}
   
   I:=1
        
   dbSelectArea("SB1")         
   dbsetOrder(1)
   For I:=1 to Len(xCOD_PRO)
      dbSeek(xFilial()+xCOD_PRO[I])
      AADD(xPESO_PRO ,SB1->B1_PESO * xQTD_PRO[I])
      AADD(xPESO_UNIT , SB1->B1_PESO)
      xPESO_LIQUID:= 0                                 // Peso Liquido da Nota Fiscal
      xPESO_LIQ   := 0
      For I:=1 to Len(xPESO_PRO)
	  xPESO_LIQ   := xPESO_LIQ   + xPESO_PRO[I]
      Next

      For I:=1 to Len(xPESO_PRO)
          xPESO_LIQUID:= xPESO_LIQUID+ xPESO_LIQ
      Next
   Next
        
   dbSelectArea("SC5")                            // * Pedidos de Venda
   dbSetOrder(1)
        
   xPED        := {}
   xPESO_BRUTO := 0
   xP_LIQ_PED  := 0
        
   For I:=1 to Len(xPED_VEND)
      dbSeek(xFilial()+xPED_VEND[I])
      If ASCAN(xPED,xPED_VEND[I])==0
         dbSeek(xFilial()+xPED_VEND[I])
         xCLIENTE    :=SC5->C5_CLIENTE            // Codigo do Cliente
         xTIPO_CLI   :=SC5->C5_TIPOCLI            // Tipo de Cliente
         xCOD_MENS   :=SC5->C5_MENPAD             // Codigo da Mensagem Padrao
         xMENSAGEM   :=SC5->C5_MENNOTA            // Mensagem para a Nota Fiscal
         xTPFRETE    :=SC5->C5_TPFRETE            // Tipo de Entrega
         xCONDPAG    :=SC5->C5_CONDPAG            // Condicao de Pagamento
         xPESO_BRUTO :=SC5->C5_PBRUTO             // Peso Bruto
         xPESO_LIQ   :=SC5->C5_PESOL              // Peso Liquido
         xCOD_VEND   := SC5->C5_VEND1             // Codigo do Vendedor 1
         xTipoPed    := SC5->C5_Orcam             // Verifica se ‚ Vale !
         xAVISOCRED  := SC5->C5_AVISO             // Aviso Sobre o Credito
         xDESC_NF    := {SC5->C5_DESC1,;          // Desconto Global 1
         SC5->C5_DESC2,;             // Desconto Global 2
         SC5->C5_DESC3,;             // Desconto Global 3
         SC5->C5_DESC4}              // Desconto Global 4
         AADD(xPED,xPED_VEND[I])
      Endif
                
   Next
        
   dbSelectArea("SE4")                    // Condicao de Pagamento
   dbSetOrder(1)
   dbSeek(xFilial("SE4")+xCONDPAG)
   xDESC_PAG := SE4->E4_DESCRI
        
   dbSelectArea("SC6")                    // * Itens de Pedido de Venda
   dbSetOrder(1)
   xPED_CLI :={}                          // Numero de Pedido
   xDESC_PRO:={}                          // Descricao aux do produto
   J:=Len(xPED_VEND)
   For I:=1 to J
      dbSeek(xFilial()+xPED_VEND[I]+xITEM_PED[I])
      AADD(xPED_CLI ,SC6->C6_PEDCLI)
      AADD(xDESC_PRO,SC6->C6_DESCRI)
   Next
        
   If xTIPO=='N' .OR. xTIPO=='C' .OR. xTIPO=='P' .OR. xTIPO=='I' .OR. xTIPO=='S' .OR. xTIPO=='T' .OR. xTIPO=='O'
      dbSelectArea("SA1")                // * Cadastro de Clientes
      dbSetOrder(1)
      dbSeek(xFilial()+xCLIENTE+xLOJA)
      xCOD_CLI :=SA1->A1_COD             // Codigo do Cliente
      xNOME_CLI:=SA1->A1_NOME            // Nome
      xEND_CLI :=SA1->A1_END             // Endereco
      xBAIRRO  :=SA1->A1_BAIRRO          // Bairro
      xCEP_CLI :=SA1->A1_CEP             // CEP
      xCOB_CLI :=SA1->A1_ENDCOB          // Endereco de Cobranca
      xCEP_COB :=SA1->A1_CEPC          // CEP de Cobranca
      xEST_COB :=SA1->A1_ESTC          // Estado  de Cobranca      
      xMUN_COB :=SA1->A1_MUNC          // Municipio  de Cobranca 
      xREC_CLI :=SA1->A1_ENDENT          // Endereco de Entrega
      xMUN_CLI :=SA1->A1_MUN             // Municipio
      xEST_CLI :=SA1->A1_EST             // Estado
      xCGC_CLI :=SA1->A1_CGC             // CGC
      xINSC_CLI:=SA1->A1_INSCR           // Inscricao estadual
      xTRAN_CLI:=SA1->A1_TRANSP          // Transportadora
      xTEL_CLI :=SA1->A1_TEL             // Telefone
      xFAX_CLI :=SA1->A1_FAX             // Fax
      xREGIAO  :=SA1->A1_REGIAO          // REGIAO DO CLIENTE
   Else
      dbSelectArea("SA2")                // * Cadastro de Fornecedores
      dbSetOrder(1)
      dbSeek(xFilial()+xCLIENTE+xLOJA)
      xCOD_CLI :=SA2->A2_COD             // Codigo do Fornecedor
      xNOME_CLI:=SA2->A2_NOME            // Nome Fornecedor
      xEND_CLI :=SA2->A2_END             // Endereco
      xBAIRRO  :=SA2->A2_BAIRRO          // Bairro
      xCEP_CLI :=SA2->A2_CEP             // CEP
      xCOB_CLI :=""                      // Endereco de Cobranca
      xCEP_COB :=""                      // CEP de Cobranca
      xEST_COB :=""                      // Estado  de Cobranca      
      xMUN_COB :=""                      // Municipio  de Cobranca                 
      xREC_CLI :=""                      // Endereco de Entrega
      xMUN_CLI :=SA2->A2_MUN             // Municipio
      xEST_CLI :=SA2->A2_EST             // Estado
      xCGC_CLI :=SA2->A2_CGC             // CGC
      xINSC_CLI:=SA2->A2_INSCR           // Inscricao estadual
      xTRAN_CLI:=SA2->A2_TRANSP          // Transportadora
      xTEL_CLI :=SA2->A2_TEL             // Telefone
      xFAX_CLI :=SA2->A2_FAX             // Fax
      xREGIAO  :='DEVOLUCAO'
   Endif

   dbSelectArea("SA3")                   // * Cadastro de Vendedores
   dbSetOrder(1)
   xVENDEDOR:={}                         // Nome do Vendedor
   I:=1
   dbSeek(xFilial()+xCOD_VEND)
   xNome_Vend := xCOD_VEND + ' ' + SA3->A3_NREDUZ
        
   dbSelectArea("SA4")                   // * Transportadoras
   dbSetOrder(1)
   dbSeek(xFilial()+SF2->F2_TRANSP)
   xNOME_TRANSP :=SA4->A4_NOME           // Nome Transportadora
   xEND_TRANSP  :=SA4->A4_END            // Endereco
   xMUN_TRANSP  :=SA4->A4_MUN            // Municipio
   xEST_TRANSP  :=SA4->A4_EST            // Estado
   xVIA_TRANSP  :=SA4->A4_VIA            // Via de Transporte
   xCGC_TRANSP  :=SA4->A4_CGC            // CGC
   xTEL_TRANSP  :=SA4->A4_TEL            // Fone
        
   dbSelectArea("SE1")                   // * Contas a Receber
   dbSetOrder(1)
   nQTDE_DUP  :=0                        // qtde de duplicatas  
   xPARC_DUP  :={}                       // Parcela
   xVENC_DUP  :={}                       // Vencimento
   xVALOR_DUP :={}                       // Valor
   xDUPLICATAS:=IIF(dbSeek(xFilial()+xSERIE+xNUM_DUPLIC,.T.),.T.,.F.) // Flag p/Impressao de Duplicatas
        
   while !eof() .and. SE1->E1_NUM==xNUM_DUPLIC .AND. SE1->E1_PREFIXO == XSERIE .and. xDUPLICATAS==.T.
      If !("NF" $ SE1->E1_TIPO)
         dbSkip()
         Loop
      Endif
      AADD(xPARC_DUP ,SE1->E1_PARCELA)
      AADD(xVENC_DUP ,SE1->E1_VENCTO)
      AADD(xVALOR_DUP,SE1->E1_VALOR)
      nQTDE_DUP := nQTDE_DUP + 1
      dbSkip()
   EndDo
        
   dbSelectArea("SF4")                   // * Tipos de Entrada e Saida
   dbSetOrder(1)
   dbSeek(xFilial()+xTES[1])
   xNATUREZA:=SF4->F4_TEXTO              // Natureza da Operacao
        
   Imprimeorc()
        
   nLin:=0
   dbSelectArea("SF2")
   dbSkip()                      // passa para a proxima Nota Fiscal
       
EndDo

dbSelectArea("SF2")
Retindex("SF2")
dbSelectArea("SD2")
Retindex("SD2")
dbSelectArea("SD1")
Retindex("SD1")

//@ 0,0 PSAY Chr( 27 ) + '@'

SET DEVICE TO SCREEN
If aReturn[5] == 1
   dbcommitAll()
   SET PRINTER TO
   Ourspool(wnrel)

Endif

Ms_Flush()
/*Set Device To Screen
Set Printer TO */

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ VERIMP   ³ Autor ³   Marcos Simidu       ³ Data ³ 20/12/95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica posicionamento de papel na Impressora             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Nfiscal                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

/*Static Function VerImp

nLin:= 0                // Contador de Linhas
nLinIni:=0
If aReturn[5]==1
   nOpc       := 2
   #IFNDEF WINDOWS
   cCor       := "B/BG"
   #ENDIF
   While .T.
      SetPrc(0,0)
      dbCommitAll()
                
      @ nLin ,000 PSAY " "
      @ nLin ,004 PSAY "."
      @ nLin ,022 PSAY "."
      IF MsgYesNo("Fomulario esta posicionado ? ")
            nOpc := 1
      ElseIF MsgYesNo("Tenta Novamente ? ")
            nOpc := 2
      Else
            nOpc := 3
      Endif

      Do Case
         Case nOpc==1
            lContinua:=.T.
            Exit
         Case nOpc==2
            Loop
         Case nOpc==3
            lContinua:=.F.
            Return
      EndCase
   End
Endif

Return*/

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ IMPRIME  ³ Autor ³   Marcos Simidu       ³ Data ³ 20/12/95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime a Nota Fiscal de Entrada e de Saida                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico RDMAKE                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function Imprimeorc

//@ 0,0 PSAY Chr( 27 ) + 'C' + Chr( 70 )
Li := 002
//@ Li,000 PSAY Chr(15)+"  "
@ Li,001 PSAY "Dados Cadastrais."
Li := Li + 1
@ Li,001 PSAY "Cliente   : "+xCliente+"/"+xLoja+" "+xNome_Cli
@ Li,067 PSAY xNum_NF
Li := Li + 1
@ Li,001 PSAY "Endereco  : "+xEnd_Cli 
Li := Li + 1
@ Li,001 PSAY "Bairro    : "+xBairro
Li := Li + 1
@ Li,001 PSAY "Municipio : "+xMun_Cli+"      Estado  : "+xEst_Cli
If xTipoPed == "V"
   @ Li,066 PSAY "V A L E"
Endif
Li := Li + 1
@ Li,001 PSAY "Cep       : "+xCep_Cli + "             Tel.    : "+xTel_Cli+"         "+xREGIAO
Li := Li + 1
@ Li,001 PSAY "CGC / CPF : "+xCgc_Cli 
@ Li,036 PSAY "IE / RG : "+xInsc_Cli
Li := Li + 1
@ Li,001 PSAY "Transp.: "+xNome_Transp+" Emissao: "+Dtoc(xEmissao)
Li := Li + 1
@ Li,001 PSAY "Cond.Pagto: "+xCond_Pag+"  "+SC5->C5_CDPG
@ Li,065 PSAY "HORA: " + Substr( Time(), 1, 5 )

Li := Li + 1
nColDup := 3
For nDup := 1 To Len(xVenc_Dup)
   If nDup == 3
       nColDup := 000
       Li := Li + 1
   Endif
   @ Li,nColDup PSAY AllTrim(Str(nDup))+"o. Vencto: "+Dtoc(xVenc_Dup[nDup]) 
   nColDup := nColDup + 21
   @ Li,nColDup PSAY "Valor : "
   @ Li,nColDup+6 PSAY xValor_Dup[nDup] Picture "999999.99"
   nColDup := nColDup + 16
Next

Li := Li + 1
//@ Li,079 PSAY Chr(15)+" "
Li := Li + 1
@ Li,001 PSAY Repl("-",104)
Li := Li + 1
@ Li,001 PSAY "It   Cod        Descricao do Material                               UN     Qtde      R$ Unit	    R$ Total"
Li := Li + 1
@ Li,001 PSAY Repl("-",104)
Li := Li + 1

nAc_Total := 0
    
For xNum:=1 to Len(xCod_Pro)
   @ Li,001 PSAY Alltrim(StrZero(xNum,2)) Picture "99"
   @ Li,006 PSAY Alltrim(xCod_Pro[xNum])
   @ Li,017 PSAY xDESC_PRO[xNum]
   @ Li,069 PSAY xUNID_PRO[xNum]
   @ Li,073 PSAY xQtd_Pro[xNum] Picture "@E 9,999.99"
   @ Li,083 PSAY xPre_Uni[xNum] Picture "@E 9,999.999"
   @ Li,095 PSAY xVal_Merc[xNum] Picture "@E 99,999.99"
   nAc_Total := nAc_Total + xVal_Merc[xNum]
   Li := Li + 1
Next
@ Li,001 PSAY Repl("-",104)
Li := Li + 1
@ Li,070 PSAY "T o t a i s   ----- >"
@ Li,094 PSAY nAc_Total Picture "999,999.99"

Li := 53

@ Li,002 PSAY "Mensagem  : "+xMensagem
Li := Li + 1
@ Li,002 PSAY "N/ Pedido : "+xPed_Vend[1]+"       Vendedor : "+xNome_Vend
Li := Li + 1
@ Li,002 PSAY "Hora : "+Alltrim(Subs(Time(),0)) 
Li := Li + 1
@ Li,002 PSAY " "
// Cod.Barra : "+Alltrim(STR((Day(SC5->C5_EMISSAO)*Month(SC5->C5_EMISSAO))+Year(SC5->C5_EMISSAO),0)+"9"+Subs(SC5->C5_Num,1,2)+Subs(SC5->C5_Num,5,2)+Subs(SC5->C5_Num,3,2)+Alltrim(StrZero(SC5->C5_TOTMAR,3)+"909"))
Li := Li + 1
@ Li,002 PSAY "Credito   : "+xAvisoCred
Li := Li + 1
@ Li,002 PSAY "ATENCAO   : DEVOLUCOES Somente Serao Aceitas Ate 48hs do Recebimento" 
Li := Li + 1
@ Li,0014 PSAY "do Material, Apos Previa Consulta ao Nosso Depto.Vendas"
Li := Li + 2
nColDup := 5
For nDup := 1 To Len(xVenc_Dup)
   @ Li,nColDup PSAY Dtoc(xVenc_Dup[nDup]) 
   nColDup := nColDup + 12
Next

Li := Li + 1

//@ Li,000 PSAY Chr(15)+" "
@ Li,005 PSAY "Valor Total : "+Alltrim(Str(nAc_Total))

If xTipoPed == "V"
   @ Li,066 PSAY "V A L E"
Endif

//SetPrc(0,0)                              // (Zera o Formulario)

Return (.T.)
