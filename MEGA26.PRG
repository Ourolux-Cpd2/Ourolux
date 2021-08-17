#Include "rwmake.ch"
#IFNDEF WINDOWS
	#DEFINE PSAY SAY
#ENDIF

/*
Programa  ³  Nfiscal ³ Autor ³   MARCIO              ³ Data ³ 19/04/99
Descri‡…o ³ Nota Fiscal de Entrada/Saida
Uso       ³ Especifico para Clientes Microsiga
*/

/*
  Define Variaveis Ambientais
 Variaveis utilizadas para parametros
 mv_par01             // Da DATA
 mv_par02             // Ate a DATA
 mv_par03             // Da NOTA
 mv_par04             // ATE A Nota Fiscal de Entrada
*/

User Function MEGA26

PRIVATE CbTxt     :=""
PRIVATE CbCont    :=""
PRIVATE nOrdem    :=0
PRIVATE Alfa      := 0
PRIVATE Z         :=0
PRIVATE M         :=0
PRIVATE tamanho   :="G" 
PRIVATE limite    :=220
PRIVATE titulo    :=PADC("Nota Fiscal - Nfiscal",74)
PRIVATE cDesc1    :=PADC("Este programa ira emitir a Nota Fiscal de Entrada",74)
PRIVATE cDesc2    :=""
PRIVATE cDesc3    :=PADC("da ELETROMEGA",74)
PRIVATE cNatureza :="" 
PRIVATE  aReturn  := { "Especial", 1,"Administracao", 1, 2, 1,"",1 }
PRIVATE  nomeprog :="nfiscal" 
PRIVATE cPerg     :=PadR("MTR170",10)
PRIVATE nLastKey  := 0 
PRIVATE lContinua := .T.
PRIVATE nLin      :=0
PRIVATE wnrel     := "MEGA26"

/*
     Tamanho do Formulario de Nota Fiscal (em Linhas)
*/

PRIVATE nTamNf:=72     // Apenas Informativo 

/*
          Verifica as perguntas selecionadas, busca o padrao da Nfiscal
*/

Pergunte(cPerg,.F.)               // Pergunta no SX1

PRIVATE cString:="SF1"

/*
            Envia controle para a funcao SETPRINT
*/

wnrel:=SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.T.)

If nLastKey == 27
   Return
End

/*
     Verifica Posicao do Formulario na Impressora
*/

SetDefault(aReturn,cString)

If nLastKey == 27
   Return
End

RptStatus({|| RptDetail() })

Return

Static Function RptDetail()

/*

       Inicio do Processamento da Nota Fiscal

*/

SetRegua(  (Val( MV_PAR04 ) - Val( MV_PAR03 )) + 1 )
dbSelectArea("SF1")                // * Cabecalho da Nota Fiscal Entrada
DbSetOrder(1)

SetPrc( 0,0 )
_cFil := xFilial( 'SF1' )

dbSeek(_cFil+mv_par03,.t.)

/*
        Inicializa  regua de impressao
*/

While ! ( SF1->( Eof() ) )         .And.;
        SF1->F1_DOC    <= mv_par04 .And.;
        SF1->F1_FILIAL  = _cFil    .And.;
        lContinua

   If SF1->F1_EMISSAO < mv_par01 .Or.;
      SF1->F1_EMISSAO > mv_par02
      DbSkip()                    
      Loop
   End

   /*
     Inicializa  regua de impressao
   */

   If LastKey()==286
      @ 00,01 PSAY "** CANCELADO PELO OPERADOR **"
	  lContinua := .F.
	  Exit
   End

   nLinIni:=nLin                         // Linha Inicial da Impressao

   /*
     Inicio de Levantamento dos Dados da Nota Fiscal
   */

   xNUM_NF     :=SF1->F1_DOC             // Numero
   xSERIE      :=SF1->F1_SERIE           // Serie
   xFORNECE    :=SF1->F1_FORNECE         // Cliente/Fornecedor
   xEMISSAO    :=SF1->F1_EMISSAO         // Data de Emissao
   xTOT_FAT    :=SF1->F1_VALBRUT         // Valor Bruto da Compra
   xLOJA       :=SF1->F1_LOJA            // Loja do Cliente
   xFRETE      :=SF1->F1_FRETE           // Frete
   xSEGURO     :=SF1->F1_DESPESA         // Despesa
   xBASE_ICMS  :=SF1->F1_BASEICM         // Base   do ICMS
   xBASE_IPI   :=SF1->F1_BASEIPI         // Base   do IPI
   xBSICMRET   :=SF1->F1_BRICMS          // Base do ICMS Retido
   xVALOR_ICMS :=SF1->F1_VALICM          // Valor  do ICMS
   xICMS_RET   :=SF1->F1_ICMSRET         // Valor  do ICMS Retido
   xVALOR_IPI  :=SF1->F1_VALIPI          // Valor  do IPI
   xVALOR_MERC :=SF1->F1_VALMERC         // Valor  da Mercadoria
   xNUM_DUPLIC :=SF1->F1_DOC             // ERA SF1->F1_DUPL   Numero da Duplicata
   xCOND_PAG   :=SF1->F1_COND            // Condicao de Pagamento
   xTIPO       :=SF1->F1_TIPO            // Tipo do Cliente
   xNFORI      :=SF1->F1_NFORI           // NF Original
   xPREF_DV    :=SF1->F1_SERIORI         // Serie Original

   dbSelectArea("SD1")                   // * Itens da N.F. de Compra
   dbSetOrder(1)
   dbSeek(xFilial()+xNUM_NF+xSERIE+xFORNECE+xLOJA)

   cPedAtu := SD1->D1_PEDIDO
   cItemAtu:= SD1->D1_ITEMPC

   xPEDIDO  :={}                         // Numero do Pedido de Compra
   xITEM_PED:={}                         // Numero do Item do Pedido de Compra
   xNUM_NFDV:={}                         // Numero quando houver devolucao
   xPREF_DV :={}                         // Serie  quando houver devolucao
   xICMS    :={}                         // Porcentagem do ICMS
   xCOD_PRO :={}                         // Codigo  do Produto
   xQTD_PRO :={}                         // Peso/Quantidade do Produto
   xPRE_UNI :={}                         // Preco Unitario de Compra
   xIPI     :={}                         // Porcentagem do IPI
   xUNITxIPI:={}                         // PRECO UNITARIO COM IPI
   xPESOPROD:={}                         // Peso do Produto
   xVAL_IPI :={}                         // Valor do IPI
   xDESC    :={}                         // Desconto por Item
   xVAL_DESC:={}                         // Valor do Desconto
   xVAL_MERC:={}                         // Valor da Mercadoria
   xTES     :={}                         // TES
   xCF      :={}                         // Classificacao quanto natureza da Operacao
   xICMSOL  :={}                         // Base do ICMS Solidario
   xICM_PROD:={}                         // ICMS do Produto
   xLOCAL   :={}                         // Local PadrÆo

	While ! ( SD1->( Eof() ) )          .And.;
           SD1->D1_DOC     == xNUM_NF  .And.;
           SD1->D1_SERIE   == xSERIE   .And.;
           SD1->D1_FORNECE == xFORNECE .And.;
           SD1->D1_FILIAL == xFilial("SD1")   // CURITIBA
                                            // 14.04.2008 //
	If SD1->D1_EMISSAO < mv_par01 .Or.;
	   	SD1->D1_EMISSAO > mv_par02
      	DbSkip()                    
    	Loop
   	End										// 14.04.2008 //
   	 
      AADD(xPEDIDO ,SD1->D1_PEDIDO)           // Ordem de Compra
      AADD(xITEM_PED ,SD1->D1_ITEMPC)         // Item da O.C.
      AADD(xNUM_NFDV ,IIF(Empty(SD1->D1_NFORI),"",SD1->D1_NFORI))
      AADD(xPREF_DV  ,SD1->D1_SERIORI)        // Serie Original
      aADD(xICMS     ,IIf(Empty(SD1->D1_PICM),0,SD1->D1_PICM))
      aADD(xCOD_PRO  ,SD1->D1_COD)            // Produto
      AADD(xQTD_PRO  ,SD1->D1_QUANT)          // Guarda as quant. da NF
      AADD(xPRE_UNI  ,SD1->D1_VUNIT)          // Valor Unitario
      AADD(xIPI      ,SD1->D1_IPI)            // % IPI
      AADD(xUNITxIPI ,SD1->D1_VUNIT*((SD1->D1_IPI/100)+1) + SD1->D1_ICMSRET/SD1->D1_QUANT) //PRECO UNIT C/IPI
      AADD(xVAL_IPI  ,SD1->D1_VALIPI)         // Valor do IPI
      AADD(xPESOPROD ,SD1->D1_PESO)           // Peso do Produto
      AADD(xDESC     ,SD1->D1_DESC)           // % Desconto
      AADD(xVAL_MERC ,SD1->D1_TOTAL)          // Valor Total
      AADD(xTES      ,SD1->D1_TES)            // Tipo de Entrada/Saida
      AADD(xCF       ,SD1->D1_CF)             // Codigo Fiscal
      AADD(xLOCAL    ,SD1->D1_LOCAL)          // Local PadrÆo
      AADD(xICM_PROD ,IIf(Empty(SD1->D1_PICM),0,SD1->D1_PICM))
      dbskip()

   End

   dbSelectArea("SB1")                       // * Desc. Generica do Produto
   dbSetOrder(1)
   xUNID_PRO  :={}                           // Unidade do Produto
   xDESC_PRO  :={}                           // Descricao do Produto
   xMEN_POS   :={}                           // Mensagem da Posicao IPI
   xDESCRICAO :={}                           // Descricao do Produto
   xCOD_TRIB  :={}                           // Codigo de Tributacao
   xMEN_TRIB  :={}                           // Mensagens de Tributacao
   xCOD_FIS   :={}                           // Cogigo Fiscal
   xCLAS_FIS  :={}                           // Classificacao Fiscal
   xISS       :={}                           // Aliquota de ISS
   xTIPO_PRO  :={}                           // Tipo do Produto
   xLUCRO     :={}                           // Margem de Lucro p/ ICMS Solidario
   xCLFISCAL  :={}
   xSUFRAMA   :=""
   xCALCSUF   :=""

   I     := 1
   nLen  := Len(xCOD_PRO)

   For I := 1 To nLen

       dbSelectArea("SB1")
       dbSeek(xFilial()+xCOD_PRO[I])

       AADD(xDESC_PRO ,SB1->B1_DESC)
       AADD(xUNID_PRO ,SB1->B1_UM)
       AADD(xCOD_TRIB ,SB1->B1_ORIGEM)

       If Ascan(xMEN_TRIB, SB1->B1_ORIGEM)==0
          AADD(xMEN_TRIB ,SB1->B1_ORIGEM)
       End

       AADD(xDESCRICAO ,SB1->B1_DESC)
       AADD(xMEN_POS  ,SB1->B1_POSIPI)

       If SB1->B1_ALIQISS > 0
          AADD(xISS,SB1->B1_ALIQISS)
       End

       AADD(xTIPO_PRO ,SB1->B1_TIPO)
       AADD(xLUCRO    ,SB1->B1_PICMRET)

       npElem := ascan(xCLAS_FIS,SB1->B1_POSIPI)

       if npElem == 0
          AADD(xCLAS_FIS  ,SB1->B1_POSIPI)
       End

       npElem := ascan(xCLAS_FIS,SB1->B1_POSIPI)

       DO CASE
          CASE npElem == 1
               _CLASFIS := "A"
          CASE npElem == 2
               _CLASFIS := "B"
          CASE npElem == 3
               _CLASFIS := "C"
          CASE npElem == 4
               _CLASFIS := "D"
          CASE npElem == 5
               _CLASFIS := "E"
          CASE npElem == 6
               _CLASFIS := "F"
       EndCase

       nPteste := Ascan(xCLFISCAL,_CLASFIS)

       If nPteste == 0
          AADD(xCLFISCAL,_CLASFIS)
       End

       AADD(xCOD_FIS ,_CLASFIS)

   Next

   /*
            Pesquisa da Condicao de Pagto
   */

   dbSelectArea("SE4")                    // Condicao de Pagamento
   dbSetOrder(1)
   dbSeek(xFilial("SE4")+xCOND_PAG)
   xDESC_PAG := SE4->E4_DESCRI

   If xTIPO == "D"

      dbSelectArea("SA1")                // * Cadastro de Clientes
      dbSetOrder(1)
      dbSeek(xFilial()+xFORNECE)
      xCOD_CLI :=SA1->A1_COD             // Codigo do Cliente
      xNOME_CLI:=SA1->A1_NOME            // Nome
      xEND_CLI :=SA1->A1_END             // Endereco
      xBAIRRO  :=SA1->A1_BAIRRO          // Bairro
      xCEP_CLI :=SA1->A1_CEP             // CEP
      xCOB_CLI :=SA1->A1_ENDCOB          // Endereco de Cobranca
      xREC_CLI :=SA1->A1_ENDENT          // Endereco de Entrega
      xMUN_CLI :=SA1->A1_MUN             // Municipio
      xEST_CLI :=SA1->A1_EST             // Estado
      xCGC_CLI :=SA1->A1_CGC             // CGC
      xINSC_CLI:=SA1->A1_INSCR           // Inscricao estadual
      xTRAN_CLI:=SA1->A1_TRANSP          // Transportadora
      xTEL_CLI :=SA1->A1_TEL             // Telefone
      xFAX_CLI :=SA1->A1_FAX             // Fax

   Else

      dbSelectArea("SA2")                // * Cadastro de Fornecedores
      dbSetOrder(1)
      dbSeek(xFilial()+xFORNECE+xLOJA)
      xCOD_CLI :=SA2->A2_COD                // Codigo do Cliente
      xNOME_CLI:=SA2->A2_NOME               // Nome
      xEND_CLI :=SA2->A2_END                // Endereco
      xBAIRRO  :=SA2->A2_BAIRRO             // Bairro
      xCEP_CLI :=SA2->A2_CEP                // CEP
      xCOB_CLI :=""                         // Endereco de Cobranca
      xREC_CLI :=""                         // Endereco de Entrega
      xMUN_CLI :=SA2->A2_MUN                // Municipio
      xEST_CLI :=SA2->A2_EST                // Estado
      xCGC_CLI :=SA2->A2_CGC                // CGC
      xINSC_CLI:=SA2->A2_INSCR              // Inscricao estadual
      xTRAN_CLI:=SA2->A2_TRANSP             // Transportadora
      xTEL_CLI :=SA2->A2_TEL                // Telefone
      xFAX     :=SA2->A2_FAX                // Fax

   End

   dbSelectArea("SE2")                   // * Contas a PAGAR
   dbSetOrder(6)

   xPARC_DUP  :={}                       // Parcela
   xVENC_DUP  :={}                       // Vencimento
   xVALOR_DUP :={}                       // Valor
   xDUPLICATAS:=IIF(dbSeek(xFilial()+xFORNECE+xLOJA+xSERIE+xNUM_DUPLIC,.T.),.T.,.F.) // Flag p/Impressao de Duplicatas

   While ! ( SE2->( Eof() ) )         .And.;
           SE2->E2_NUM == xNUM_DUPLIC .And.;
           xDUPLICATAS == .T.         .And.;
           SE2->E2_FILIAL == xFilial("SE2") // CURITIBA
 
      AADD(xPARC_DUP ,SE2->E2_PARCELA)
      AADD(xVENC_DUP ,SE2->E2_VENCTO)
      AADD(xVALOR_DUP,SE2->E2_VALOR)
      dbSkip()
 
   End

   dbSelectArea("SF4")                   // * Tipos de Entrada e Saida
   dbSetOrder(1)
   dbSeek(xFilial()+xTES[1])             //SD1->D1_TES) dENILSON
   xNATUREZA:=SF4->F4_TEXTO              // Natureza da Operacao
   xNOME_TRANSP :=" "           // Nome Transportadora
   xEND_TRANSP  :=" "           // Endereco
   xMUN_TRANSP  :=" "           // Municipio
   xEST_TRANSP  :=" "           // Estado
   xVIA_TRANSP  :=" "           // Via de Transporte
   xCGC_TRANSP  :=" "           // CGC
   xTEL_TRANSP  :=" "           // Fone
   xTPFRETE     :=" "           // Tipo de Frete
   xVOLUME      := 0            // Volume
   xESPECIE     :=" "           // Especie
   xPESO_LIQ    := 0            // Peso Liquido
   xPESO_BRUTO  := 0            // Peso Bruto
   xCOD_MENS    :=" "           // Codigo da Mensagem
   xMENSAGEM    :=" "           // Mensagem da Nota
   xPESO_LIQUID :=" "

   Imprime()
   IncRegua()

   /*
              Termino da Impressao da Nota Fiscal
   */

   nLin:=0
   dbSelectArea("SF1")           
   dbSkip()                     // e passa para a proxima Nota Fiscal

End

/*

                         FIM DA IMPRESSAO

            Fechamento do Programa da Nota Fiscal
*/

dbSelectArea("SF2")
Retindex("SF2")
dbSelectArea("SF1")
Retindex("SF1")
dbSelectArea("SD2")
Retindex("SD2")
dbSelectArea("SD1")
Retindex("SD1")

Set Device To Screen
Set Printer To

If aReturn[5] == 1
   dbcommitAll()
   ourspool(wnrel)
End       

MS_FLUSH()

Return

/*
                               Fim do Programa

*/


/*
 
 Fun‡…o    ³ IMPDET   ³ Autor ³   Marcos Simidu       ³ Data ³ 20/12/95
 Descri‡…o ³ Impressao de Linhas de Detalhe da Nota Fiscal
 Uso       ³ Nfiscal

*/


/*
                     Inicio da Funcao
*/

Static Function IMPDET

nTamDet := Len( xCod_Pro )  // Tamanho da Area de Detalhe

I:=1
J:=1

xB_ICMS_SOL:=0          // Base  do ICMS Solidario
xV_ICMS_SOL:=0          // Valor do ICMS Solidario
nLin ++

@ nLin,000 PSAY 'CODIGO'
@ nLin,015 PSAY 'DESCRICAO'
@ nLin,064 PSAY 'LOCAL'
@ nLin,069 PSAY ' CT'
@ nLin,075 PSAY 'UN'
@ nLin,087 PSAY 'QDE'
@ nLin,097 PSAY 'PRECO UNIT'
@ nLin,119 PSAY 'VLR TOTAL'
@ nLin,130 PSAY 'IPI'
@ nLin,134 PSAY 'ICMS'
@ nLin,145 PSAY 'VLR IPI'
@ nLin,158 PSAY 'UNIT IPI'
@ nLin,170 PSAY 'PED COMPRA/NF ORI'

nLin ++
nLin ++
_nLen := Len( xCod_Pro )

For I :=1 To nTamDet

    If I <= _nLen

        @ nLin, 000  PSAY xCOD_PRO[I]
        @ nLin, 015  PSAY xDESCRICAO[I]
        @ nLin, 066  PSAY xLOCAL[I]
        @ nLin, 069  PSAY xCOD_TRIB[I]
        @ nLin, 075  PSAY xUNID_PRO[I]
        @ nLin, 083  PSAY xQTD_PRO[I]               Picture"@E 999,999.99"
        @ nLin, 095  PSAY xPRE_UNI[I]               Picture"@E 99,999.99999"
        @ nLin, 116  PSAY xVAL_MERC[I]              Picture"@E 99,999,999.99"
        @ nLin, 130  PSAY xIPI[I]                   Picture"99"
        @ nLin, 135  PSAY xICM_PROD[I]              Picture"99"
        @ nLin, 140  PSAY xVAL_IPI[I]               Picture"@E 9,999,999.99"
        @ nLin, 155  PSAY xUNITxIPI[I]              PICTURE"@E 9,999.99999" 
        @ nLin, 170  PSAY If( ! Empty( xPedido[i] ), xPedido[i], xNum_NFDV[I] )
        J ++

    Endif

    nLin ++

    If nLin > 60

       Cabec()

    End

Next

Return

/*
        Fim da Funcao
*/


/*

Fun‡…o    ³ CLASFIS  ³ Autor ³   Marcos Simidu       ³ Data ³ 16/11/95
Descri‡…o ³ Impressao de Array com as Classificacoes Fiscais 
Uso       ³ Nfiscal                                                   

/*

/*
       Inicio da Funcao
*/

Static Function CLASFIS()

@ nLin,006 PSAY "Classificacao Fiscal"
nLin ++

For nCont := 1 To Len(xCLFISCAL) .And.;
    nCont <= 12

    nCol := If(Mod(nCont,2) != 0, 06, 33)
    @ nLin, nCol     PSAY xCLFISCAL[nCont] + "-"
    @ nLin, nCol+ 05 PSAY Transform(xCLAS_FIS[nCont],"@r 99.99.99.99.99")
    nLin += If(Mod(nCont,2) != 0, 0, 1)

Next

Return


/*

 Fun‡…o    ³ IMPMENP  ³ Autor ³   Marcos Simidu       ³ Data ³ 20/12/95
 Descri‡…o ³ Impressao Mensagem Padrao da Nota Fiscal
 Uso       ³ Nfiscal

*/

/*
        Inicio da Funcao
*/

Static Function IMPMENP

nCol:= 05

If !Empty(xCOD_MENS)

   @ nLin, NCol PSAY FORMULA(xCOD_MENS)

End

Return

/*
             Fim da Funcao 
*/

/*

 Fun‡…o    ³ MENSOBS  ³ Autor ³   Marcos Simidu       ³ Data ³ 20/12/95
 Descri‡…o ³ Impressao Mensagem no Campo Observacao
 Uso       ³ Nfiscal

*/

/*      
                             Inicio da Funcao
*/

Static Function MENSOBS

nTamObs:=150
nCol:=05
nlin ++
nlin ++
Return

/*
                            Fim da Funcao   
*/

/*

Fun‡…o    ³ DUPLIC   ³ Autor ³   Marcos Simidu       ³ Data ³ 20/12/95
Descri‡…o ³ Impressao do Parcelamento das Duplicacatas
Uso       ³ Nfiscal

*/

/*
         Inicio da Funcao
*/

Static Function DUPLIC
nCol := 7
nAjuste := 0
For BB := 1 To Len(xVALOR_DUP)
   If xDUPLICATAS==.T. .And. BB<=Len(xVALOR_DUP)
      @ nLin, nCol + nAjuste      PSAY xNUM_DUPLIC + " " + xPARC_DUP[BB]
      @ nLin, nCol + 16 + nAjuste PSAY xVENC_DUP[BB]
      @ nLin, nCol + 31 + nAjuste PSAY xVALOR_DUP[BB] Picture("@E 9,999,999.99")
      nAjuste += 50
   End
Next

Return

/*
                  Fim da Funcao 
*/

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
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                                                              ³
//³              IMPRESSAO DA N.F. DA Nfiscal                    ³
//³                                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Cabec()

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Impressao da Fatura/Duplicata       ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

nLin:=17
BB:=1
nCol := 10             //  duplicatas
DUPLIC()


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Dados dos Produtos Vendidos         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nLin := 20
ImpDet()                 // Detalhe da NF


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calculo dos Impostos                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

nLin ++

@ nLin, 035  PSAY 'BASE ICMS'
@ nLin, 064  PSAY 'VLR ICMS'
@ nLin, 087  PSAY 'SUBST. TRIB'
@ nLin, 116  PSAY 'ICMS SUBST'
@ nLin, 148  PSAY 'VLR MERCADORIA'

nLin += 2

@ nLin, 030  PSAY xBASE_ICMS  Picture"@E@Z 999,999,999.99"  // Base do ICMS
@ nLin, 058  PSAY xVALOR_ICMS Picture"@E@Z 999,999,999.99"  // Valor do ICMS
@ nLin, 087  PSAY xBSICMRET   Picture"@E@Z 999,999,999.99"  // Base ICMS Ret.
@ nLin, 116  PSAY xICMS_RET   Picture"@E@Z 999,999,999.99"  // Valor  ICMS Ret.
@ nLin, 148  PSAY xVALOR_MERC Picture"@E@Z 999,999,999.99"  // Valor Tot. Prod.

nLin += 2

@ nLin, 030  PSAY 'FRETE'
@ nLin, 058  PSAY 'SEGURO'
@ nLin, 123  PSAY 'VLR IPI'
@ nLin, 153  PSAY 'VLR TOTAL'

nLin += 2

@ nLin, 030  PSAY xFRETE      Picture"@E@Z 999,999,999.99"  // Valor do Frete
@ nLin, 058  PSAY xSEGURO     Picture"@E@Z 999,999,999.99"  // Valor Seguro
@ nLin, 116  PSAY xVALOR_IPI  Picture"@E@Z 999,999,999.99"  // Valor do IPI
@ nLin, 148  PSAY xTOT_FAT    Picture"@E@Z 999,999,999.99"  // Valor Total NF

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Impressao Dados da Transportadora  ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

nLin ++
@ nLin, 006  PSAY xNOME_TRANSP                       // Nome da Transport.

nLin ++
If xTPFRETE=='C'                                   // Frete por conta do
   @ nLin, 113 PSAY "1"                              // Emitente (1)
Else                                               //     ou
   @ nLin, 113 PSAY "2"                              // Destinatario (2)
End

nLin ++

@ nLin, 008 PSAY xVOLUME  Picture"@E@Z 999,999.99"             // Quant. Volumes
@ nLin, 026 PSAY xESPECIE Picture"@!"                          // Especie
@ nLin, 052 PSAY " "                                           // Res para Marca
@ nLin, 075 PSAY " "                                           // Res para Numero
@ nLin, 109 PSAY xPESO_BRUTO     Picture"@E@Z 999,999.99"      // Res para Peso Bruto
@ nLin, 137 PSAY xPESO_LIQUID    Picture"@E@Z 999,999.99"      // Res para Peso Liquido

nLin ++
@ nLin, 000 PSAY chr(18)                   // Descompressao de Impressao
Eject

Return

Static Function Cabec()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Impressao do Cabecalho da N.F.      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 00, 00  PSAY Chr( 27 ) + 'C' + Chr( 66 )
@ 01, 120  PSAY if( _cFil <> '01' , 'FILIAL', 'MATRIZ' )
@ 02, 131 PSAY Chr(14)+Chr(15)+"X"
@ 05, 155 PSAY xNUM_NF               // Numero da Nota Fiscal
@ 08, 030 PSAY xNATUREZA               // Texto da Natureza de Operacao
@ 08, 075 PSAY xCF[1] Picture"@R 9.99" // Codigo da Natureza de Operacao
@ 08, 080 PSAY "TES: "
@ 08, 086 PSAY xTES[1]

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Impressao dos Dados do Cliente      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

@ 11, 030 PSAY xNOME_CLI              //Nome do Cliente
@ 11, 080 PSAY xCOD_CLI

If !EMPTY(xCGC_CLI)                   // Se o C.G.C. do Cli/Forn nao for Vazio
   @ 11, 117 PSAY xCGC_CLI Picture"@R 99.999.999/9999-99"
Else
   @ 11, 117 PSAY " "                // Caso seja vazio
End

@ 11, 150 PSAY xEMISSAO              // Data da Emissao do Documento

@ 13, 029 PSAY xEND_CLI                                 // Endereco
@ 13, 107 PSAY xBAIRRO                                  // Bairro
@ 13, 130 PSAY xCEP_CLI Picture"@R 99999-999"           // CEP
@ 13, 143 PSAY " "                                      // Reservado  p/Data Saida/Entrada

@ 15, 029 PSAY xMUN_CLI                               // Municipio
@ 15, 090 PSAY xTEL_CLI                               // Telefone/FAX
@ 15, 112 PSAY xEST_CLI                               // U.F.
@ 15, 122 PSAY xINSC_CLI                              // Insc. Estadual
@ 15, 143 PSAY " "                                    // Reservado p/Hora da Saida

nLin := 17

Return
