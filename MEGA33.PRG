#IFNDEF WINDOWS
   #DEFINE PSAY SAY
#ENDIF
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³Mega33    ³ Autor ³Airton Lira            ³ Data ³06/10/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Impressao da Nf Devolucao modelo orcamento                 ³±±
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
User Function MEGA33
#Include "rwmake.ch"
PRIVATE CbTxt:=""
PRIVATE CbCont:=""
PRIVATE nOrdem :=0
PRIVATE Alfa := 0
PRIVATE Z:=0
PRIVATE M:=0
PRIVATE tamanho:="G"
PRIVATE limite:=220
PRIVATE titulo :=PADC("MEGA33 - Nota fiscal de devolucao",74)
PRIVATE cDesc1 :=PADC("Este Programa tem a Finalidade de Emitir nota fiscal de devolucao",74)
PRIVATE cDesc2 :=PADC("(modelo orcamento) ",74)
PRIVATE cDesc3 :=PADC("                                                                    ",74)
PRIVATE cNatureza:=""
PRIVATE aReturn := { "Especial", 1,"Administracao", 1, 2, 1,"",1 }
PRIVATE nomeprog:="MEGA33"
PRIVATE cPerg:="MEGA08"
PRIVATE nLastKey:= 0
PRIVATE lContinua := .T.
PRIVATE nLin:=0
PRIVATE wnrel := "MEGA33"

Pergunte(cPerg,.F.)               // Pergunta no SX1

PRIVATE cString:="SF1"

Wnrel:=SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.T.)

If nLastKey == 27
   Return
Endif

SetDefault(aReturn,cString)
If nLastKey == 27
        Return
Endif

VerImp()

RptDetail()

Return

Static Function RptDetail

dbSelectArea("SF1")                // * Cabecalho da Nota Fiscal Saida
dbSetOrder(1)
dbSeek(xFilial()+mv_par01+mv_par03,.t.)
        
dbSelectArea("SD1")                // * Itens de Venda da Nota Fiscal
dbSetOrder(1)
dbSeek(xFilial()+mv_par01+mv_par03)
cPedant := SD1->D1_PEDIDO

dbSelectArea("SF1")
While !eof() .and. SF1->F1_DOC    <= mv_par02 .and. lContinua .And.;
		SF1->F1_FILIAL == xFilial("SF1") // CURITIBA
        
   If SF1->F1_SERIE # mv_par03    // Se a Serie do Arquivo for Diferente
      dbSkip()                    // do Parametro Informado !!!
      Loop
   Endif
        
      IF LastKey()==286
         @ 00,01 PSAY "** CANCELADO PELO OPERADOR **"
         lContinua := .F.
         Exit
      Endif
        
   xNum_Nf     :=SF1->F1_DOC             // Numero
   xSerie      :=SF1->F1_SERIE           // Serie
   xEmissao    :=SF1->F1_EMISSAO         // Data de Emissao
   xTot_Fat    :=SF1->F1_VALBRUT         // Valor Total da Fatura
   If xTot_Fat == 0
      xTot_Fat := SF1->F1_Valmerc+SF1->F1_Valipi+SF1->F1_Seguro+SF1->F1_Frete
   Endif

   xLOJA       :=SF1->F1_LOJA            // Loja do Cliente
   xFRETE      :=SF1->F1_FRETE           // Frete
   xSEGURO     :=0
   xBASE_ICMS  :=SF1->F1_BASEICM         // Base   do ICMS
   xBASE_IPI   :=SF1->F1_BASEIPI         // Base   do IPI
   xVALOR_ICMS :=SF1->F1_VALICM          // Valor  do ICMS
   xICMS_RET   :=SF1->F1_ICMSRET         // Valor  do ICMS Retido
   xVALOR_IPI  :=SF1->F1_VALIPI          // Valor  do IPI
   xVALOR_MERC :=SF1->F1_VALMERC         // Valor  da Mercadoria
   xNUM_DUPLIC :=SF1->F1_DUPL            // Numero da Duplicata
   xCOND_PAG   :=SF1->F1_COND            // Condicao de Pagamento
   xPBRUTO     :=0
   xPLIQUI     :=0
   xTIPO       :=SF1->F1_TIPO            // Tipo do Cliente
   xESPECIE    :=" "
   xVOLUME     :=" "
   xNfOri      :=""
        
   dbSelectArea("SD1")                   // * Itens de Venda da N.F.
   dbSetOrder(1)
   dbSeek(xFilial()+xNUM_NF+xSERIE)

   cPedAtu  := SD1->D1_PEDIDO
   cItemAtu := SD1->D1_ITEMPV
        
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
        
   While !eof() .and. SD1->D1_DOC==xNUM_NF .and. SD1->D1_SERIE==xSERIE .And.;
   		SD1->D1_FILIAL == xFilial("SD1") // CURITIBA
      
      If SD1->D1_SERIE # mv_par03        // Se a Serie do Arquivo for Diferente
         dbSkip()                   // do Parametro Informado !!!
         Loop
      Endif
      
      If Vazio(xNfOri)
         xNfOri := D1_SERIORI+D1_NFORI
      Else
         xNfOri := ", "+D1_SERIORI+D1_NFORI
      EndIf
      
      AADD(xPED_VEND ,SD1->D1_PEDIDO)
      AADD(xITEM_PED ,SD1->D1_ITEMPV)
      AADD(xNUM_NFDV ,IIF(Empty(SD1->D1_NFORI),"",SD1->D1_NFORI))
      AADD(xPREF_DV  ,SD1->D1_SERIORI)
      AADD(xICMS     ,IIf(Empty(SD1->D1_PICM),0,SD1->D1_PICM))
      AADD(xCOD_PRO  ,SD1->D1_COD)
      AADD(xQTD_PRO  ,SD1->D1_QUANT)     // Guarda as quant. da NF
      AADD(xPRE_UNI  ,SD1->D1_VUNIT)
      AADD(xPRE_TAB  ,SD1->D1_VUNIT)
      AADD(xIPI      ,IIF(Empty(SD1->D1_IPI),0,SD1->D1_IPI))
      AADD(xVAL_IPI  ,SD1->D1_VALIPI)
      AADD(xDESC     ,SD1->D1_DESC)
      AADD(xVAL_MERC ,SD1->D1_TOTAL)
      AADD(xTES      ,SD1->D1_TES)
      AADD(xCF       ,SD1->D1_CF)
      AADD(xICM_PROD ,IIf(Empty(SD1->D1_PICM),0,SD1->D1_PICM))
      AADD(xVAl_DESC ,SD1->D1_DESC)
      dbskip()
   End
        
   dbSelectArea("SB1")                     // * Desc. Generica do Produto
   dbSetOrder(1)
   xPESO_PRO:={}                           // Peso Liquido
   xPESO_UNIT :={}                         // Peso Unitario do Produto
   xDESCRICAO :={}                         // Descricao do Produto
   xUNID_PRO:={}                           // Unidade do Produto
   xCOD_TRIB:={}                           // Codigo de Tributacao
   xMEN_TRIB:={}                           // Mensagens de Tributacao
   xCOD_FIS :={}                           // Cogigo Fiscal
   xCLAS_FIS:={}                           // Classificacao Fiscal
   xMEN_POS :={}                           // Mensagem da Posicao IPI
   xISS     :={}                           // Aliquota de ISS
   xTIPO_PRO:={}                           // Tipo do Produto
   xLUCRO   :={}                           // Margem de Lucro p/ ICMS Solidario
   xCLFISCAL   :={}
   xPESO_LIQ := 0
   I:=1
        
   dbSelectArea("SB1")         
   dbsetOrder(1)
   For I:=1 to Len(xCOD_PRO)
      dbSeek(xFilial()+xCOD_PRO[I])
      AADD(xPESO_PRO ,SB1->B1_PESO * xQTD_PRO[I])
      xPESO_LIQ  := xPESO_LIQ + xPESO_PRO[I]
      AADD(xPESO_UNIT , SB1->B1_PESO)
      AADD(xUNID_PRO ,SB1->B1_UM)
      AADD(xDESCRICAO ,SB1->B1_DESC)

      xPESO_LIQUID:=0                                 // Peso Liquido da Nota Fiscal
      For I:=1 to Len(xPESO_PRO)
          xPESO_LIQUID:=xPESO_LIQUID+xPESO_LIQ
      Next
   Next

   nLines := MLCount(SF1->F1_OBS,64,3,.t.)
   xPED        := {}
   xPESO_BRUTO := 0
   xP_LIQ_PED  := 0
   xCLIENTE    :=SF1->F1_FORNECE
   xTIPO_CLI   :=" "
   xCOD_MENS   :=" "
   xTPFRETE    :="C"
   xCONDPAG    :=SF1->F1_COND
   xPESO_BRUTO :=0
   xPESO_LIQ   :=0
   xCOD_VEND   :="000000"
   xTipoPed    :="N"
   xAVISOCRED  :=" "
   xDESC_NF    :={0,0,0,0}
   AADD(xPED,"000000")
   dbSelectArea("SE4")                    // Condicao de Pagamento
   dbSetOrder(1)
   dbSeek(xFilial("SE4")+xCONDPAG)
   If Found()
      xDESC_PAG := SE4->E4_DESCRI
   Else
      xDESC_PAG:=""
   EndIf 
   xPED_CLI :={""}                          // Numero de Pedido
   xDESC_PRO:={""}                          // Descricao aux do produto

   If xTIPO=='N' .OR. xTIPO=='C' .OR. xTIPO=='P' .OR. xTIPO=='I' .OR. xTIPO=='S' .OR. xTIPO=='T' .OR. xTIPO=='O' .OR.  xTIPO=='D'
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
   Endif

   dbSelectArea("SA3")                   // * Cadastro de Vendedores
   dbSetOrder(1)
   xVENDEDOR:={}                         // Nome do Vendedor
   I:=1
   dbSeek(xFilial()+xCOD_VEND)
   xNome_Vend := xCOD_VEND
        
   dbSelectArea("SA4")                   // * Transportadoras
   dbSetOrder(1)
   dbSeek(xFilial()+"900000")
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
        
   while !eof() .and. SE1->E1_NUM==xNUM_DUPLIC .AND. SE1->E1_PREFIXO == XSERIE .and. xDUPLICATAS==.T. .And.;
   		SE1->E1_FILIAL == xFilial("SE1")   // CURITIBA
   
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
        
   Imprime()
        
   nLin:=0
   dbSelectArea("SF1")
   dbSkip()                      // passa para a proxima Nota Fiscal
       
EndDo

dbSelectArea("SF1")
Retindex("SF1")
dbSelectArea("SD1")
Retindex("SD1")
dbSelectArea("SD1")
Retindex("SD1")
Set Device To Screen

If aReturn[5] == 1
        Set Printer TO
        dbcommitAll()
        Ourspool(wnrel)
Endif

Ms_Flush()

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

Static Function VerImp

nLin:= 0                // Contador de Linhas
nLinIni:=0
If aReturn[5]==2
   nOpc       := 1
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

Return

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

Static Function Imprime

Li := 0
@ Li,005 PSAY Chr(14)+"TROCA DE MERCADORIAS / DEVOLUCAO ESTOQUE"+Chr(18)
Li := Li + 3
@ Li,004 PSAY "Dados Cadastrais."
Li := Li + 1
@ Li,003 PSAY "Cliente   : "+xCliente+"/"+xLoja+" "+xNome_Cli
@ Li,067 PSAY xNum_NF
Li := Li + 1
@ Li,003 PSAY "Endereco  : "+xEnd_Cli 
Li := Li + 1
@ Li,003 PSAY "Bairro    : "+xBairro
Li := Li + 1
@ Li,003 PSAY "Municipio : "+xMun_Cli+"      Estado  : "+xEst_Cli
Li := Li + 1
@ Li,003 PSAY "Cep       : "+xCep_Cli + "             Tel.    : "+xTel_Cli+"         "+xREGIAO
Li := Li + 1
@ Li,003 PSAY "CGC / CPF : "+xCgc_Cli 
@ Li,036 PSAY "IE / RG : "+xInsc_Cli
Li := Li + 1
@ Li,003 PSAY "Emissao : "+Dtoc(xEmissao)
Li := Li + 1
@ Li,003 PSAY "Cond.Pagto: "+xCond_Pag+"  "+SC5->C5_CDPG
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
@ Li,079 PSAY Chr(15)+" "
Li := Li + 1
@ Li,005 PSAY Repl("-",120)
Li := Li + 1
@ Li,005 PSAY "It Codigo          Descricao do Material                      UM          Qtde.         R$ Unit.        R$ Total"
Li := Li + 1
@ Li,005 PSAY Repl("-",120)
Li := Li + 1

nAc_Total := 0
    
For xNum:=1 to Len(xCod_Pro)
   @ Li,005 PSAY StrZero(xNum,2) Picture "99"
   @ Li,008 PSAY xCod_Pro[xNum]
   @ Li,024 PSAY xDescricao[xNum]
   @ Li,067 PSAY xUnid_Pro[xNum]
   @ Li,073 PSAY xQtd_Pro[xNum]    Picture "@E 99,999.99999"
   @ Li,087 PSAY xPre_Uni[xNum]    Picture "@E 9,999.99999"
   @ Li,107 PSAY xVal_Merc[xNum]   Picture "@E 999,999.99"
   nAc_Total := nAc_Total + xVal_Merc[xNum]
   Li := Li + 1
Next
@ Li,005 PSAY Repl("-",120)
Li := Li + 1
@ Li,075 PSAY "T o t a i s   ----- >"
@ Li,107 PSAY nAc_Total Picture "999,999.99"

Li := 53

If nLines > 0
   @ Li,005 PSAY "Observacao: "+AllTrim(MemoLine(SF1->F1_OBS,64,1,3,.t.))
   For nCurrentLine := 2 To nLines
       Li := Li + 1
       @ Li,005 PSAY MemoLine(SF1->F1_OBS,64,nCurrentLine,3,.t.)
   Next nCurrentLine
EndIf

lI := Li + 1
@ Li,005 PSAY "Ref. Nf "+xNfOri
LI := LI + 1
@ lI,005 PSAY "ATENCAO   : "+xNATUREZA
Li := Li + 7
nColDup := 5
For nDup := 1 To Len(xVenc_Dup)
   @ Li,nColDup PSAY Dtoc(xVenc_Dup[nDup]) 
   nColDup := nColDup + 12
Next

SetPrc(0,0)                              // (Zera o Formulario)

Eject

Return (.T.)
