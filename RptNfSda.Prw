#IFNDEF WINDOWS
#DEFINE PSAY SAY
#ENDIF 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³  Nfiscal ³ Autor ³Eletromega             ³ Data ³02/06/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Impressao formulario de NFS Saida/Entrada                  ³±±
±±³                                                                       ³±±
±±³  					                                                  ³±±                                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Eletromega                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

#Include "rwmake.ch"

User Function RptNfSda()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ MV_PAR01             // Da Nota Fiscal                       ³
//³ MV_PAR02             // Ate a Nota Fiscal                    ³
//³ MV_PAR03             // Serie NF                             ³
//³ MV_PAR04             // 1 = Entrada, 2= Saida                ³
//³ MV_PAR05             // Boleto                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Local cUAObs 	 	:= ""
Local nTotSuf		:= 0
Local nTotICMS		:= 0
//Local lSuf          := .F. //sigaeic
Local lImpZFRC		:= .F. 
Local lCalcSuf      := .F.
Local lIsentIPI     := .F.
Local aLinhas		:= {}

_cNota       := ''
_cTes        := ''
_nTes        := ''
_cNome       := ''
_cCnpj       := ''
_cEnd        := ''
_cBro        := ''
_cCep        := ''
_cMun        := ''
_cDdd        := ''
_cTel        := ''
_cEst        := ''
_cInsE       := ''
_aDupl       := {}
_cPcaP       := ''
_cEndC       := ''
_nLin        := ''
_nItens      := ''
_aItens      := ''
_nBseIcms    := ''
_nVlrIcms    := ''
_nBseSubs    := ''
_nVlrSubs    := ''                                            
_nTotProd    := ''
_nVlrFret    := ''
_nVlrSeg     := ''
_nDespAce    := ''
_nVlrIpi     := ''
_nTotNot     := ''
_cTransp     := ''
_cEmtDst     := ''
_cPlaca      := ''
_cEndTransp  := ''
_cMunTransp  := ''
_cEstTransp  := ''
_nQde        := ''
_cEsp        := ''
_cDddTransp  := ''
_cFonTransp  := ''
_cEndRet     := ''
_nPsoBrt     := ''
_nPsoLqd     := ''
cEndEnt      := ''
cPedCli 	 := ''
aTes         := {}
cCFDesc      := ""
cCFOP        := ""
nLine        := 0
_aObs        := {}
_cObs        := ''
cInsTrib     := '816.003.590.110'

PRIVATE tamanho:= "G"
PRIVATE limite := 220
PRIVATE titulo := PADC("Nota Fiscal Saida/Entra",74)
PRIVATE cDesc1 := PADC("Este programa ira emitir a Nota Fiscal de Entrada/Saida",74)
PRIVATE cDesc2 := PADC("da EletroMega.                                         ",74)
PRIVATE cDesc3 := ""
PRIVATE aReturn := { "Especial", 1,"Administracao", 2, 2, 1,"",0 }
PRIVATE nomeprog :="RptNfSda"
PRIVATE cPerg :=PadR("NFSIGW",10)
PRIVATE nLastKey  := 0
PRIVATE lContinua := .T.
PRIVATE wnrel     := "RptNfSda"
private ncarac := 0
PRIVATE cDirBol := ''
Pergunte(cPerg,.F.)      // Pergunta no SX1
PRIVATE cString:="SF2"
PRIVATE nTxPis     	:= SuperGetMV("MV_TXPIS")
PRIVATE nTxCofin	:= SuperGetMV("MV_TXCOFIN")
Private nRow		:= 0 
Private nCol		:= 0
Private nMaxChars   := 67  // Max numero de caracters por linha (campo dados adicionais da nossa NF) 
Private lSuf        := .F.  // sigaeic
Private aImpEIC		:= {}

wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.T.)

If nLastKey == 27
   Return
Endif

SetDefault(aReturn,cString)
If nLastKey == 27
   Return
Endif

If MV_PAR04 == 2   /* NF SAIDA */

   SF2->( dbSetOrder(1) )   /* Index 1 = FILIAL, DOC, SERIE, CLIENTE, LOJA, FORMUL */
   SD2->( dbSetOrder(3) )   /* Index 3 = FILIAL, DOC, SERIE, CLIENTE, LOJA, COD, ITEM, */

Else

   SF1->( dbSetOrder(1) )   /* Index 1 = FILIAL, DOC, SERIE, FORNECE, LOJA, TIPO */
   SD1->( dbSetOrder(1) )   /* Index 1 = FILIAL, DOC, SERIE, FORNECE, LOJA, COD, ITEM */

End

_fSA1 := xFilial( "SA1" )
_fSA2 := xFilial( "SA2" )
_fSA3 := xFilial( "SA3" )
_fSA4 := xFilial( "SA4" )
_fSB1 := xFilial( "SB1" )
_fSC5 := xFilial( "SC5" )
_fSC6 := xFilial( "SC6" )
_fSC9 := xFilial( "SC9" )
_fSF1 := xFilial( "SF1" )
_fSF2 := xFilial( "SF2" )
_fSF4 := xFilial( "SF4" )
_fSD1 := xFilial( "SD1" )
_fSD2 := xFilial( "SD2" )
_fSE1 := xFilial( "SE1" )
_fSE2 := xFilial( "SE2" )
_fSE4 := xFilial( "SE4" )
_fSUA := xFilial( "SUA" )

Set Century On
RptStatus({|| RptImpNot() })
Set Century Off

__Eject()

Set Device To Screen
Set Printer To

If aReturn[ 5 ] == 1
   dbcommitAll()
   OurSpool( wnrel )
End

MS_FLUSH()

Return

Static Function RptImpNot

SetRegua( ( Val(MV_PAR02) - Val(MV_PAR01) ) + 1 )

If MV_PAR04 <> 1  /* Saida */

   SD2->(dbSeek( _fSD2 + MV_PAR01 + MV_PAR03,.T.)) 
        
	IF (SD2->D2_TES  == "900") 
		
		Set Device To Screen
      	ApMsgStop( 'Voce esta tentando imprimir um orcamento como NF!', 'ATENÇÃO' )
      	Return
	
	ElseIf (cFilAnt == '01' .AND. MV_PAR03 <> '5  ') .Or.;  //(cFilAnt == '01' .AND. MV_PAR03 <> '3  ') .Or.; - Victor Abreu - MP10 - 
		   (cFilAnt == '02' .AND. MV_PAR03 <> '4  ')     	 //(cFilAnt == '02' .AND. MV_PAR03 <> '2  ') .Or.;

 		Set Device To Screen
      	ApMsgStop( 'Serie da Nota Fiscal errada. Digite a serie correta!', 'ATENÇÃO' )
      	Return

   	End

   SF2->( dbSeek( _fSF2 + SD2->D2_DOC + SD2->D2_SERIE + SD2->D2_CLIENTE + SD2->D2_LOJA, .F. ))
        
   While ! SF2->( Eof() )        .And.;
         SF2->F2_DOC <= MV_PAR02 .And.;
         lContinua               .And.;
         SF2->F2_FILIAL = _fSF2
        
         If SF2->F2_SERIE <> MV_PAR03

            SF2->( dbSkip() )
            Loop

         End
        
         If LastKey()==286

            @ 00,01 PSAY "** CANCELADO PELO OPERADOR **"
            lContinua := .F.
            Exit

         End

         /*  
            Monta Nota Fiscal a ser impressa
         */

         PesqNfCli()
         
         SF2->( dbSkip() )

   End /* While */

Else	/* Entrada */

   SD1->( dbSeek( _fSD1 + MV_PAR01 + MV_PAR03 + Space( 8 ), .T. ))

   IF SD1->D1_TES 	== "900"  .Or.;
      SD1->D1_SERIE == 'ORC' .Or.;
      SD1->D1_DOC  	<> MV_PAR01
      // SD1->D1_TIPO 	<> 'D'   .Or.;   WAR 23/05/2007 
      

      If ! ( SD1->( Eof() ) )
         
         Set Device To Screen
         ApMsgStop( 'Voce esta tentando imprimir um orcamento como NF', 'STOP' )
         Return
      
      End

   End
   
   // 1 = F1_FILIAL, F1_DOC, F1_SERIE, F1_FORNECE, F1_LOJA, F1_TIPO
   SF1->( dbSeek( _fSF1 + MV_PAR01 + MV_PAR03 + SD1->D1_FORNECE + SD1->D1_LOJA, .F. ))  
   
   If ( SF1->( Eof() ) ) .OR. (SF1->F1_FORMUL == ' ' .AND. SF1->F1_TIPO == 'N')  

      Return

   End
   
   // SIGAEIC -- Nao imprime nota nao classificada 
   If Empty(SF1->F1_STATUS) 
		Set Device To Screen
        ApMsgStop( 'Nao pode imprimir Documento nao classificada!', 'STOP' )
        Return
   EndIf
   // SIGAEIC

   PesqNfCli()

End

Return( Nil )  // RptImpNot  

Static Function PesqNfCli()
//lSuf		:= .F. //sigaeic
Local		aGetValICMS := {}
Local       _lSigaEIC	:= .F.  
Local		nIcmDiff 	:= 0 	// SIGAEIC Importaçao
Local       nIcmPres	:= 0    // SIGAEIC Importaçao
       
/*

       Cabecalho da Nota Fiscal

*/

If MV_PAR04 <> 1 /* Saida */

    _cNota   := SF2->F2_DOC
    _cEmis   := SF2->F2_EMISSAO
    _nVlrIpi := 0

    If SF2->F2_TIPO <> 'D'
       
       LerCadCli( SF2->F2_CLIENTE, SF2->F2_LOJA )
       		
    Else
       LerCadFor( SF2->F2_CLIENTE, SF2->F2_LOJA )
    End

Else

    _cNota   := SF1->F1_DOC
    _cEmis   := SF1->F1_EMISSAO
    _nVlrIpi := 0

    If SF1->F1_TIPO <> 'D'
       LerCadFor( SF1->F1_FORNECE, SF1->F1_LOJA )
    Else
       LerCadCli( SF1->F1_FORNECE, SF1->F1_LOJA )
    End

End   

/*

               Desdobramento de Duplicatas


*/

SE1->( dbSeek( xFilial( "SE1" ) + MV_PAR03 + _cNota + " ", .T. ) ) 
						
_aDupl := {}

while ! SE1->( Eof() ) .And. SE1->E1_NUM = _cNota .And. SE1->E1_FILIAL == xFilial("SE1")  // CIRITIBA

   aAdd( _aDupl, { SE1->E1_VENCTO, SE1->E1_VALOR } )

   SE1->( dbSkip() )

End 

/*

    Itens da Nota Fiscal

*/

_aItens  	:= {}
_nItens  	:= 0
cPedCli  	:= ''
aTes     	:= {}
nTotSuf  	:= 0
nTotICMS    := 0
lImpZFRC    := .F.
lCalcSuf	:= .F.
lIsentIPI	:= .F.
aImpEIC		:= {}  

If MV_PAR04 <> 1   // NF SAIDA

   SD2->( dbSeek( _fSD2 + _cNota + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA, .T. )) 
   
   SC5->( dbSeek( _fSC5 + SD2->D2_PEDIDO, .F. ) )
   
   While ! ( SD2->( Eof() ) ) .And. ( SD2->D2_SERIE = SF2->F2_SERIE ) .And. ( SD2->D2_DOC   = SF2->F2_DOC ) .And.;
   			SD2->D2_FILIAL == xFilial("SD2") .And. SF2->F2_FILIAL == xFilial("SF2")	 // CURITIBA

      SC6->( dbSeek( _fSC6 + SD2->D2_PEDIDO + SD2->D2_ITEMPV, .F.) ) 
            
      SB1->( dbSeek( _fSB1 + SD2->D2_COD, .F. ) )  
       
	  lImpZFRC 	:= SB1->B1_IMPZFRC <> "S" // <> S Gera desconto de ICMS para Zona Franca
	  lCalcSuf	:= SA1->A1_CALCSUF <> "N" // <> N Gera desconto de ICMS para Zona Franca
	  
	  /* Grava o Numero do Atendimento*/
      
      If  SubStr( SC6->C6_PEDCLI,1,3 ) == 'TMK'  .And. Empty(cPedCli) 
 	  		
 	  		cPedCli := SubStr (SC6->C6_PEDCLI,4,6)
      
      EndIf

	  aAdd( _aItens, { SD2->D2_COD, SC6->C6_DESCRI, IIf (SB1->B1_TIPO == "PA",SD2->D2_CLASFIS,""), SD2->D2_UM,;
                       SD2->D2_QUANT, SD2->D2_PRCVEN, SD2->D2_TOTAL, SD2->D2_PICM,;
                       SD2->D2_NFORI, SD2->D2_IPI, SD2->D2_VALIPI,SB1->B1_POSIPI ,; 
                       1, SD2->D2_TES, SD2->D2_CF, SC6->C6_VALOR,; 
                       lImpZFRC, SD2->D2_VALICM, SB1->B1_OPPROP, SB1->B1_IPI })
      _nItens ++
              
      SD2->( dbSkip() )

   End  /* While */ 

Else   // NF ENTRADA 

   _lSigaEIC  := !Empty(SF1->F1_HAWB)
   // Importaçao
   
   SC5->( dbSeek( _fSC5 + 'XXXXXX', .F. ) )
   		
   While ! ( SD1->( Eof() ) ) .And. ( SD1->D1_SERIE = SF1->F1_SERIE ) .And. ( SD1->D1_DOC   = SF1->F1_DOC ) .And.;
			SD1->D1_FILIAL == xFilial("SD1") .And. SF1->F1_FILIAL == xFilial("SF1")	 // CURITIBA
      
      SB1->( dbSeek( _fSB1 + SD1->D1_COD, .F. ) ) 

      _nUnit := SD1->D1_VALDESC
      _nUnit /= SD1->D1_QUANT
            
      _nUnit := Round( _nUnit, 4 ) 
     
      _nUnit := ( SD1->D1_VUNIT - _nUnit )
     
    	/*BEGINDOC
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄx”[¿
		//³Function getvalICMS(Par1,Par2,Par3,Par4,Par5,Par6,Par7)				//                                                                                                       
		//³		Par1 : Número da nota fiscal                                    //                                                                                                                                                                                                                                               
		//³		Par2 : Série da nota fiscal                                     //                                                                                                                                                                                                                                               
		//³		Par3 : Fornecedor                                               //                                                                                                                                                                                                                                               
		//³		Par4 : Loja                                                     //                                                                                                                                                                                                                                               
		//³		Par5 : Tipo da nota fiscal                                      //                                                                                                                                                                                                                                               
		//³		Par6 : Número do pedido                                         //                                                                                                                                                                                                                                               
		//³		Par7 : Número do item                                           //                                                                                                                                                                                                                                               
		//³ Retorno : um array de 9 campos                                      //                                                                                                                                                                                                                                               
		//³		Par1 : Base de ICMS                                             //                                                                                                                                                                                                                                               
		//³		Par2 : Valor devido de ICMS                                     //                                                                                                                                                                                                                                               
		//³		Par3 : % de diferimento                                         //                                                                                                                                                                                                                                               
		//³		Par4 : Valor do diferimento                                     //                                                                                                                                                                                                                                               
		//³		Par5 : % de crédito presumido                                   //                                                                                                                                                                                                                                               
		//³		Par6 : % Máximo de crédito presumido                            //                                                                                                                                                                                                                                               
		//³		Par7 : Valor do crédito presumido                               //                                                                                                                                                                                                                                               
		//³		Par8 : % Mínimo de ICMS a recolher                              //                                                                                                                                                                                                                                               
		//³		Par9 : Valor do ICMS a recolher                                  //                                                                                                                                                                                                                                               
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄx”[Ù
		ENDDOC*/
    
    // SIGAEIC
    If	_lSigaEIC  //!Empty(SF1->F1_HAWB) !Empty(SF1->F1_TIPO_NF)
     	aGetValICMS := GetValICMS(SF1->F1_DOC,SF1->F1_SERIE,SF1->F1_FORNECE,SF1->F1_LOJA,SF1->F1_TIPO_NF,;
     			                  SD1->D1_PEDIDO,SD1->D1_ITEMPC)  // SD1->D1_ITEM
    EndIf
     	  
    aAdd( _aItens, {   SD1->D1_COD		,;
                       SB1->B1_DESC   	,;
                       SD1->D1_CLASFIS	,;
                       SD1->D1_UM     	,;
                       SD1->D1_QUANT  	,;
                       _nUnit         	,;
                       SD1->D1_TOTAL - SD1->D1_VALDESC ,;
                       SD1->D1_PICM   	,;
                       SD1->D1_NFORI  	,;
                       SD1->D1_IPI	  	,;  
                       SD1->D1_VALIPI 	,;  
                       SB1->B1_POSIPI 	,; 
                       1			  	,; 
                       SD1->D1_TES    	,; 
                       SD1->D1_CF     	,;
                       If(_lSigaEIC,aGetValICMS[1],0) ,;
                       If(_lSigaEIC,aGetValICMS[2],0) ,;
                       If(_lSigaEIC,aGetValICMS[3],0) ,;
                       If(_lSigaEIC,aGetValICMS[4],0) ,;
                       If(_lSigaEIC,aGetValICMS[5],0) ,;
                       If(_lSigaEIC,aGetValICMS[6],0) ,;
                       If(_lSigaEIC,aGetValICMS[7],0) ,;
                       If(_lSigaEIC,aGetValICMS[8],0) ,;
                       If(_lSigaEIC,aGetValICMS[9],0) })

      _nItens ++
      SD1->( dbSkip() )
   End

End

/*

          Calculo do Imposto da Nota Fiscal

*/

If MV_PAR04 <> 1  /* Saida */

   _nBseIcms  := SF2->F2_BASEICM
   _nVlrIcms  := SF2->F2_VALICM
   _nBseSubs  := SF2->F2_BRICMS
   _nVlrSubs  := SF2->F2_ICMSRET
   _nTotProd  := SF2->F2_VALMERC  
   _nVlrFret  := SF2->F2_FRETE
   _nVlrSeg   := SF2->F2_SEGURO
   _nDespAce  := SF2->F2_DESPESA
   _nVlrIpi   := SF2->F2_VALIPI
   _nTotNot   := SF2->F2_VALMERC 

   _nTotNot   += SF2->F2_VALIPI
   _nTotNot   += SF2->F2_SEGURO
   _nTotNot   += SF2->F2_FRETE
   _nTotNot   += SF2->F2_DESPESA
   _nTotNot   += SF2->F2_ICMSRET
   
   // Nota de complemento de ICMS
   	If (SF2->F2_TIPO == 'I') 
   		If _aItens[1][14] == '521' // TES 521 = COMPLEMENTO DE ICMS
			_nTotProd := 0
			_nTotNot  := 0
		EndIf
		If _aItens[1][14] == '514' // TES 514 = COMPLEMENTO DE ICMS ST
			_nTotProd 	:= 0
			_nTotNot  	:= SF2->F2_ICMSRET
			_nBseSubs  	:= SF2->F2_BICMST  // 08-04-2009 BASE DE ICMS ST PARA NF COMPLEMENTAR DE ICMS ST
		EndIf

	EndIf
 
Else /* Entrada */

   _nBseIcms  := SF1->F1_BASEICM
   _nVlrIcms  := SF1->F1_VALICM
   _nBseSubs  := SF1->F1_BRICMS
   _nVlrSubs  := SF1->F1_ICMSRET
   _nTotProd  := SF1->F1_VALMERC - SF1->F1_DESCONT

   _nVlrFret  := SF1->F1_FRETE
   _nVlrSeg   := SF1->F1_SEGURO
   _nDespAce  := SF1->F1_DESPESA
   _nVlrIpi   := SF1->F1_VALIPI

   _nTotNot   := SF1->F1_VALMERC - SF1->F1_DESCONT
   _nTotNot   += SF1->F1_VALIPI
   _nTotNot   += SF1->F1_SEGURO
   _nTotNot   += SF1->F1_FRETE
   _nTotNot   += SF1->F1_ICMSRET
   
   If !Empty(SF1->F1_HAWB) .And. (SM0->M0_CODFIL == '02')  // Nota Fiscal de Importaçao ---> SIGAEIC
   		_nDespAce += SF1->F1_VALIMP6 + SF1->F1_VALIMP5 // PIS + COFINS  
   		_nTotNot  += SF1->F1_VALICM  // ICMS Devido
   EndIf
   
   _nTotNot  += _nDespAce

EndIf

/*

        Transportadora/Volumes Transportados da Nota Fiscal

*/

SA4->( dbSeek( _fSA4 + SC5->C5_TRANSP, .F. ) )

_cTransp := SA4->A4_NOME

If !Empty(_cTransp)

	_cEmtDst := IIf (SC5->C5_TPFRETE <> "C",'2','1')

EndIf

_cPlaca  :=  ''

_cEndTransp := Alltrim( SA4->A4_END )

If ! Empty( SA4->A4_BAIRRO )

   _cEndTransp += ' - '
   _cEndTransp += SA4->A4_BAIRRO

End

_cMunTransp := SA4->A4_MUN
_cEstTransp := SA4->A4_EST

_nQde       := SF2->F2_VOLUME1
_cEsp       := SF2->F2_ESPECI1

If !EMPTY(SA4->A4_DDD) 

	_cDddTransp := '('
	_cDddTransp += AllTrim( SA4->A4_DDD )
	_cDddTransp += ')'

Else
	
	_cDddTransp := SPACE(5)
	
EndIf

 _cFonTransp := Alltrim( SA4->A4_TEL )

_nLen := Len( _cFonTransp )

If _nLen = 8

   _cFonTransp := Transform( _cFonTransp, "@R 9999-9999" )

ElseIf _nLen = 7

   _cFonTransp := Transform( _cFonTransp, "@R 999-9999" ) 

ElseIf _nLen = 0         // war
   
	_cFonTransp := " "  // war

End

If !Empty(_cTransp)

	_cEndRet := If( SC5->C5_TIPENT <> '1', '4', '3' )

EndIf

_aObs := {}

If MV_PAR04 <> 1    // NF SAIDA

	If (! Empty (cPedCli))  // PEDIDO TMK
		
		Dbselectarea("SUA")
		
		If Dbseek(xFilial("SUA")+ cPedCli)
			
			cEndEnt := Alltrim( SUA->UA_ENDENT )          // Endereco de Entrega
	    	cEndEnt += ' - '
    		cEndEnt += AllTrim( SUA->UA_BAIRROE )
      		cEndEnt += ' - '          
      		cEndEnt += AllTrim( SUA->UA_MUNE )
      		cEndEnt += ' - '          
      		cEndEnt += AllTrim( SUA->UA_ESTE )
      		cEndEnt += ' - '          
      		cEndEnt += Transform( SUA->UA_CEPE, "@R 99999-999" )
		
		EndIf
    
    Else  // Pedido digitado no modulo faturamento
    	
    	If SF2->F2_TIPO <> 'D'
    	
    		cEndEnt := Alltrim( SA1->A1_ENDENT )          
    		cEndEnt += ' - '
      		cEndEnt += AllTrim( SA1->A1_BAIRROE )
      		cEndEnt += ' - '          
     		cEndEnt += AllTrim( SA1->A1_MUNE )
      		cEndEnt += ' - '          
     		cEndEnt += AllTrim( SA1->A1_ESTE )
      		cEndEnt += ' - '          
      		cEndEnt += Transform( SA1->A1_CEPE, "@R 99999-999" )
      	
      	Else /* Devoluçao para o Fornecedor */
      		
      		cEndEnt := Alltrim( SA2->A2_END )
   			cEndEnt += ' - '
   			cEndEnt += AllTrim( SA2->A2_BAIRRO )
   			cEndEnt += ' - '          
   			cEndEnt += AllTrim( SA2->A2_MUN )
   			cEndEnt += ' - '          
   			cEndEnt += AllTrim( SA2->A2_EST )
   			cEndEnt += ' - '          
   			cEndEnt += Transform( SA2->A2_CEP, "@R 99999-999" )

      	EndIf
      	
    /* NF SAIDA - PESO */
    
    _nPsoBrt    := SF2->F2_PBRUTO
	_nPsoLqd    := SF2->F2_PLIQUI

    EndIf  /* cPedCli TMK */

Else  // NF Entrada nosso Formulario - Devoluçao de Cliente

   cEndEnt := Alltrim( SA1->A1_END )
   cEndEnt += ' - '
   cEndEnt += AllTrim( SA1->A1_BAIRRO )
   cEndEnt += ' - '          
   cEndEnt += AllTrim( SA1->A1_MUN )
   cEndEnt += ' - '          
   cEndEnt += AllTrim( SA1->A1_EST )
   cEndEnt += ' - '          
   cEndEnt += Transform( SA1->A1_CEP, "@R 99999-999" )

End


/*

         Observacao nota fiscal

*/

If MV_PAR04 <> 1   /* Saida */

   If SF2->F2_TIPO <> "D"

      SA3->( dbSeek( _fSA3 + SC5->C5_VEND1, .F. ) )
      		
      _cObs := "Vend: "
      _cObs += SF2->F2_VEND1
      _cObs += "  "
      _cObs += rTrim( SA3->A3_NREDUZ )
      _cObs += " Pedido: "
      _cObs += SC5->C5_NUM
            
      SE4->(dbSeek( _fSE4 + SC5->C5_CONDPAG ,.F. )) 
              
      _cObs += " Cond. Pagto: "
      _cObs += SC5->C5_CDPG
      _cObs += " " 
      _cObs += SUBSTR(SE4->E4_DESCRI,1,nMaxChars-LEN(_cObs)) 

   Else  /* Devoluçao para fornecedor*/

      _cObs := "Devolucao conf. sua(s) nota(s) fiscal(is) de n§(s): "

      For i := 1 To _nItens

          _cObs += Transform( _aItens[ i ][ 9 ], '@R 999.999' )
          
          If !(i == _nItens)
          		_cObs += ', '
          EndIf     
          
      Next

   EndIf

Else	/* Entrada */
	
	If ( SF1->F1_TIPO == 'D')  // Devoluçao do Cliente 
   	
   		_cObs := "Conforme nossa nota de de n§: " 
   		_cObs += _aItens[ 1 ][ 9 ]
 	
 	/* ElseIf SF1->F1_TIPO == 'N' .And. SF1->F1_FORMUL == 'S'  // ENTRADA NOSSO FORMULARIO Average*/
 	ElseIf !Empty(SF1->F1_HAWB) //!Empty(SF1->F1_TIPO_NF)  // Nota Fiscal de Importaçao ---> SIGAEIC
 		
 		If SM0->M0_CODFIL == '02' // // SIGAEIC Filial Parana 	
 	 		
 	 		If !Empty (U_getForml("010")) 			
				aAdd( _aObs, Substr(U_getForml("010"),1,nMaxChars))  // IMPORTAÇAO REALIZADO...
			EndIf	
 		
 			_cObs := "PIS: " + Alltrim(STR(SF1->F1_VALIMP6,,2))
			aAdd(_aObs, _cObs)
			_cObs := "COFINS: " + Alltrim(STR(SF1->F1_VALIMP5,,2)) 
			aAdd(_aObs, _cObs)
			_cObs := "II: " + Alltrim(STR(SF1->F1_II,,2))
			aAdd(_aObs, _cObs)
		
			For i := 1 To _nItens
				nIcmDiff +=	_aItens[i][19]  // ICMS DIFERIDO SIGAEIC
          		nIcmPres +=	_aItens[i][22]  // ICMS PRESUMIDO SIGAEIC
        	Next  
        
        	_cObs := "ICMS Diferido: " + Alltrim(STR(nIcmDiff,,2))
			aAdd(_aObs, _cObs)
			_cObs := "ICMS Presumido: " + Alltrim(STR(nIcmPres,,2)) 
        	aAdd(_aObs, _cObs)  
        	_cObs := "DI : "
        	_cObs += Transform(GetAdvFVal("SW6","W6_DI_NUM",xFilial("SW6")+SF1->F1_HAWB,1,""),;
        	                   PesqPict("SW6","W6_DI_NUM"))
        	aAdd(_aObs, _cObs)
        	_cObs := ""  
        
        	// SIGAEIC
 			If !Empty( SF1->F1_OBSNFE )  // importacao : Dados Adicionais Nota Fiscal de Entrada c/ Nosso Formulario
 				_cObs := SF1->F1_OBSNFE 
 			EndIf
 			 
        
 		EndIf
 	EndIf

End

If !Empty(_cObs)
	
	aLinhas:= StrToArray(_cObs,nMaxChars)
		
	For nCounter := 1 to Len (aLinhas)
		aadd(_aObs,aLinhas[nCounter])
	Next	 

EndIf

If _nVlrSubs <> 0 .And. MV_PAR04 == 2

   Set Device To Screen
   _cMsg := 'Atenção, a Nota Fiscal nº ' + SF2->F2_DOC + ' contem ICMS a recolher (substituição tribut-' + Chr( 13 )
   _cMsg += 'aria), informe o Dpto. Financeiro para que seja emitida a GNRE - Guia' + Chr( 13 )
   _cMsg += 'Nacional de Recolhimento de Tributo Estadual,a mesma deverá ser recolhida na' + Chr( 13 )
   _cMsg += 'rede bancaria e anexada a Nota Fiscal'
   MsgInfo( _cMsg )    
   Set Device To Print
   
   aAdd( _aObs, "RECOLHIMENTO DO ICMS CONF. PROTOCOLO N§ 17 DE 25.07.85 DOU 29.07.85" )  // 67 Chars 
End

If ( MV_PAR04 <> 1   .And. lSuf ) // NF SAIDA + Suframa

	For  S:= 1 TO _nItens
	
		If ( SF4->( dbSeek(xFilial("SF4") + _aItens[S][14], .F. ) ))
	   		If	SF4->F4_PISCRED <> "3" .And. SF4->F4_PISCOF $ "23" 
	   		
	   			// Base para calculo de desconto de PIS/COFINS precisa verificar se tem desconto? no Tes
				nTotSuf 	+=	_aItens[S][16]		// C6_VALOR : Total do pedido
				lImpZFRC	:= 	_aItens[S][17]  	// B1_IMPZFRC
		
	        EndIf
	        // Base para calculo de desconto de ICMS
			If lImpZFRC .And. lCalcSuf  // Os itens que tem Desconto de ICMS
				nTotICMS	+=	_aItens[S][16]		// C6_VALOR 
				If	SF4->F4_PISCRED <> "3" .And. SF4->F4_PISCOF $ "23"
					nTotSuf 	-= _aItens[S][16] * 0.07  // Base de cacluclo  de suframa sem o desconto de ICMS 
			    EndIf
			EndIf
	        
	        If	_aItens[S][11] == 0 .And. _aItens[S][20] <> 0  // 11 - D2_VALIPI, 20 - B1_IPI
	        	lIsentIPI := .T.
	        EndIf 
	    EndIf
	
	Next S
	
	// Desconto de PIS/COFINS para Zona Franca
	If nTotSuf <> 0
		_cObs := "Desc: "
		_cObs += Alltrim(STR(nTxPis,,2)) + "% PIS = " + Alltrim(STR((nTotSuf * nTxPis)/100,,2))
		_cObs += " | " + Alltrim(STR(nTxCofin,,2)) + "% Cofins = " + Alltrim(STR((nTotSuf * nTxCofin)/100,,2)) 	  
		aAdd( _aObs, _cObs )
	EndIf
	// Desconto de ICMS para Zona Franca
	If lImpZFRC .And. lCalcSuf   
	    
		_cObs := "Desc: "
		_cObs += "7% ICMS = " + Alltrim(STR(nTotICMS * 0.07,,2))
		aAdd( _aObs, _cObs ) 
		
		If !Empty (U_getForml("006")) 			
	
			aAdd( _aObs, Substr(U_getForml("006"),1,nMaxChars))  // Isencao de ICMS
	
		EndIf
		
	EndIf
		
	If	lIsentIPI .And. !Empty (U_getForml("007")) // Isento de IPI
	
		aAdd( _aObs, SUBSTR(U_getForml("007"),1,nMaxChars))  // Isencao de IPI
	
	EndIf
	
	If !Empty (U_getForml("008")) 
	
		aAdd( _aObs, SUBSTR(U_getForml("008"),1,nMaxChars))  // SUFRAMA
	
	EndIf

EndIf
/*  16-12-2008
// Valor de ICMS Operaçao Propria
If	nVlrIcmsDA > 0
	
	_cObs := "ICMS op. propria R$ "
	_cObs += Alltrim(STR(nVlrIcmsDA,,2))
	
		 
	If !Empty (U_getForml("009"))
		
	_cObs += " " + SUBSTR(U_getForml("009"),1,nMaxChars-LEN(_cObs))	 
		
	EndIf
	
	aAdd( _aObs,_cObs )  // ICMS op. propria / SP

EndIf
*/
If MV_PAR04 == 2 

	cUAObs := SC5->C5_MSGNOTA

	If ! Empty( cUAObs )  // get MsgNot from sc5

		aLinhas:= StrToArray(cUAObs,nMaxChars)
		
		For nCounter := 1 to Len (aLinhas)
			aadd(_aObs,aLinhas[nCounter])
		Next	 

	Else  // get OBS from SUA 
	
		If (! Empty (cPedCli))
		
			Dbselectarea("SUA")
		
			If Dbseek(xFilial("SUA") + cPedCli)	
			
				If ! Empty(SUA->UA_CODOBS)
			
					cUAObs := MSMM(SUA->UA_CODOBS,nMaxChars)
					aLinhas:= StrToArray(cUAObs,nMaxChars)
		
					For nCounter := 1 to Len (aLinhas)
						aadd(_aObs,aLinhas[nCounter])
					Next	 
			
				EndIf
	
			EndIf  // Dbseek	
	
		EndIf /* TMK cPedCli */      

	EndIf  /* Campo Obs */

	If ! Empty(SC5->C5_MENPAD)

   		aAdd(_aObs, SUBSTR(U_getForml(SC5->C5_MENPAD),1,nMaxChars))
 
	End
	
	If !Empty(SC5->C5_MENNOTA)

   		aLinhas:= StrToArray(SC5->C5_MENNOTA,nMaxChars)
		
		For nCounter := 1 to Len (aLinhas)
			aadd(_aObs,aLinhas[nCounter])
		Next	 
   	
   	EndIf

EndIf
  
//       Impressão dos Titulos da Nota Fiscal

TrataTes()
CabecNota()
ItensNota()
CalcImpNota()
TranspNota()
ImpBoleto()
Return ( .T. )   // End Function PesqNfCli()

// Save cada (tes,cfop) uma ves no array ates
Static Function TrataTes()
bFound := .F.
For nInd := 1 TO _nItens
	If (nInd == 1)
		aAdd( aTes,{_aItens[nInd][14],_aItens[nInd][15]} )
	Else
		For nI := 1 to len (aTes)
			If (_aItens[nInd][15] == aTes[nI][2])
				bFound := .T.
				Exit
			EndIf
		Next nI
		If (! bFound)
			aAdd( aTes,{_aItens[nInd][14],_aItens[nInd][15]} )
		EndIf
		bFound := .F. 
	EndIf
					
Next nInd
 
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Impressao de cabecalho do nota fiscal e dos Dados Adicionais da Nota   ³±±
±±³Dados Adicionas: Tamanho = 29 Linhas com 67 caracters por linha        ³±±
±±³Altura:  Cabe 1 caracter (Altura) num rectangelo                       ³±±
±±³Largura: Cabe ~ 1,7 characters no rectangelo (Largura: 68/40 ~ 1,7)    ³±±
±±³                                                                       ³±±
±±³                                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/

Static Function CabecNota()
Local nMaxLine 	:= 30 // Cabem 30 linhas no campo Dados Adicionais
Local iDup 		:= 0
nRow 			:= 1  // Global
nCol 			:= 0  // Global

@ 00,00 PSAY CHR( 27 )+'@'+Chr( 27 )+"C"+Chr( 72 )+Chr( 15 )+Chr( 27 )+"l"+Chr( 4 )

// Start printing Dados Adicionaisat Line 3
For i:= 1 to nMaxLine 
		
	// Imprime cada linha do campo Dados Adicionais
	If i <= len(_aObs) 
		If  ! Empty(_aObs[i])
			@ nRow,nCol PSAY _aObs[i]
		EndIf
	EndIf
		
	// Imprime o numero da nota no Canhoto de cima
  	If nRow == 3
		@ nRow,215 PSAY '' + _cNota
	
	// Imprime X Saida/Entrada
	ElseIf nRow == 5          
		If MV_PAR04 == 1  // NF ENTRADA 
        	@ nRow,172 PSAY 'X' 
   		Else              // NF SAIDA 
        	@ nRow,161 PSAY 'X'           
		EndIf
	
	// Imprime Nr da Nota
	ElseIf nRow == 8     
		@ nRow,194 PSAY '' + _cNota  
	
	// Imprime Natureza 1/CFOP
	ElseIf nRow == 16     
		SF4->( dbSeek(xFilial("SF4") + aTes[1][1], .F. ) )
		cCFDesc := SF4->F4_TEXTO
			
		cCFOP := aTes[1][2]
		cCFOP := substr(cCFOP,1,1) + '.' + substr(cCFOP,2,3)
		
		@ nRow ,72 PSAY cCFDesc
		@ nRow ,118  PSAY cCFOP
		
		If (SA1->A1_EST == "SP" .And. SA1->A1_TIPO == "S"  .And. SF2->F2_ICMSRET <> 0 .And. cFilAnt == '02')
			@ nRow ,130 PSAY cInsTrib // 27-10-2009
		EndIf 
  
	// Imprime Natureza 2/CFOP
	ElseIf nRow == 17 .And. len(aTes) > 1     
		SF4->( dbSeek(xFilial("SF4") + aTes[2][1], .F. ) )
		cCFDesc := SF4->F4_TEXTO
			
		cCFOP := aTes[2][2]
		cCFOP := substr(cCFOP,1,1) + '.' + substr(cCFOP,2,3)
		
		@ nRow ,72 PSAY cCFDesc
		@ nRow ,118 PSAY cCFOP 
    
    // Destinatario Linha 1: Nome/CNPJ/Data de Emissao 
    ElseIf nRow == 20     
    	@ nRow,72  PSAY _cNome
		@ nRow,165  PSAY _cCnpj
		@ nRow,196 PSAY _cEmis Picture "@E 99/99/9999" // Data Emissao
    
    // Destinatario Linha 2: Endereço/Bairro/Cep
    ElseIf nRow == 22      
    	@ nRow,72  PSAY _cEnd
		@ nRow,152  PSAY RTRIM(_cBro)
		@ nRow,172 PSAY _cCep
    
    // Destinatario Linha 3: Municipio/Fone/UF/IE/Time de Emissao
    ElseIf nRow == 24      
    	@ nRow,72   PSAY _cMun
		@ nRow,130  PSAY _cDdd
		@ nRow,136  PSAY _cTel
		@ nRow,155  PSAY _cEst
		@ nRow,166  PSAY _cInsE
		@ nRow,198  PSAY Substr( Time(), 1, 5 )
	
	// Data de Vencimento das Parcelas
    ElseIf nRow == 27     
		
		nCol := 110
		// Vencimento Das Parcelas        
    	For iDup := 1 To Len( _aDupl )

		    @ nRow,nCol PSAY _aDupl[ iDup ][ 1 ] Picture "@E 99/99/9999"
    		
    		If iDup < 4
    			nCol += 28
    		ElseIf iDup == 4
    			nCol += 14
    		Else
    			Exit
    		End

		Next
		iDup := 0
    
    // Valores das Duplicatas
    ElseIf nRow == 28     
    	
    	nCol := 72
    	@ nRow,nCol PSAY _cNota // Numero da Duplicata
    	nCol := 108
    	// Valores Das Duplicatas
    	For iDup := 1 To Len( _aDupl )

    		@ nRow,nCol PSAY _aDupl[ iDup ][ 2 ] Picture "@E 9,999,999.99"

    		If iDup < 4
    			nCol += 28
    		ElseIf iDup == 4
    			nCol += 14
    		Else
    			Exit
    		End

		Next
		iDup := 0
    
    // Endereço de Cobrança
    ElseIf nRow == 30
    
    	@ nRow,72 PSAY _cPcaP
		@ nRow,114 PSAY _cEndC
  
    EndIf

nRow++

Next i

Return( NIL )

/* Itens da Nota Fiscal */

Static Function ItensNota()

nRow += 2 

For i := 1 To _nItens

   	@ nRow, 00 PSAY RTRIM(_aItens[ i ][ 1 ])        /*  Cod Produto */
    @ nRow, 24 PSAY RTRIM(_aItens[ i ][ 2 ])        /*  Descricao   */  
    @ nRow, 98 PSAY _aItens[ i ][ 12 ]              /*  class. fis  */ 
        		
    If !Empty (_aItens[ i ][ 3 ])
    	@ nRow, 112 PSAY _aItens[ i ][ 3 ] Picture  "@ 999"    //  Sit. Trib.  //
    EndIf          
    
    @ nRow, 118 PSAY _aItens[ i ][ 4 ]                              /*  Unidade     */ 
    @ nRow, 124 PSAY _aItens[ i ][ 5 ] Picture   "@E 9,999,999.99"  /*  Quantidade  */  

       
    If  (SF2->F2_TIPO == 'I')  		// Pedido tipo I -> Zerar 
    	_aItens[ i ][ 6 ] := 0  	/*  Valor Unit. */
    	_aItens[ i ][ 7 ] := 0	    /*  Valor Total */ 
    	_aItens[ i ][ 8 ] := 0 		/*  Aliq. ICMS  */
    EndIf	
    
    @ nRow,141 PSAY _aItens[ i ][ 6 ]  Picture  "@E 99,999.9999"	/*  Valor Unit. */   
    @ nRow,158 PSAY _aItens[ i ][ 7 ]  Picture  "@E 9,999,999.99"   /*  Valor Total */  
    @ nRow,173 PSAY _aItens[ i ][ 8 ]  Picture  "@E 99"             /*  Aliq. ICMS  */ 
    @ nRow,182 PSAY _aItens[ i ][ 10 ] Picture  "@E 99"             /*  Aliq. IPI   */
    @ nRow,196 PSAY _aItens[ i ][ 11 ] Picture  "@E 9,999,999.99"   /*  Valor IPI   */ 
            
    //escreve o nº da nota no segundo canhoto se o nº itens > 16 e a linha = 38
    If (_nItens > 6 .AND. nRow == 39) // 
		@ nRow,215 PSAY '' + _cNota 
	End
	
    nRow ++

Next
    //se menor que 16 itens escreve diretamente na linha 38
	If (_nItens <= 6 ) 
		@ 39,215 PSAY '' + _cNota 
	End

Return( Nil )


/* Calculo do Imposto da Nota Fiscal */

Static Function CalcImpNota()
nRow := 58 

@ nRow, 15 PSAY _nBseIcms  Picture "@EZ 999,999,999.99" 
@ nRow, 41 PSAY _nVlrIcms  Picture "@EZ 999,999,999.99"  
@ nRow, 69 PSAY _nBseSubs  Picture "@EZ 999,999,999.99"  
@ nRow, 94 PSAY _nVlrSubs  Picture "@EZ 999,999,999.99"   
@ nRow,122 PSAY _nTotProd  Picture "@E 999,999,999.99" 

nRow += 2

@ nRow, 15 PSAY _nVlrFret  Picture "@EZ 999,999,999.99" 
@ nRow, 38 PSAY _nVlrSeg   Picture "@EZ 999,999,999.99"  
@ nRow, 65 PSAY _nDespAce  Picture "@EZ 999,999,999.99"  
@ nRow, 94 PSAY _nVlrIpi   Picture "@EZ 999,999,999.99"  
@ nRow,122 PSAY _nTotNot   Picture "@E 999,999,999.99" 

Return( Nil )

/*

        Transportadora/Volumes Transportados da Nota Fiscal

*/

Static Function TranspNota()
nRow := 63

@ nRow,00 PSAY _cTransp 
@ nRow,80  PSAY _cEmtDst 
@ nRow,110 PSAY _cPlaca 

nRow += 2

@ nRow,00 PSAY _cEndTransp 
@ nRow,89 PSAY _cMunTransp   
@ nRow,103 PSAY _cEstTransp  

nRow += 2

@ nRow, 10 PSAY _nQde Picture "@EZ 99999" 
@ nRow, 13 PSAY _cEsp 
@ nRow, 46 PSAY _cDddTransp 
@ nRow, 52 PSAY _cFonTransp 
@ nRow, 96 PSAY _cEndRet 

If !EMPTY(_nPsoBrt)
	@ nRow,107 PSAY _nPsoBrt Picture "@EZ 999,999.9" 
EndIf

If !EMPTY(_nPsoLqd)
	@ nRow,123 PSAY _nPsoLqd Picture "@EZ 999,999.9"
EndIf 

nRow += 2
// Imprime Endereço da Entrega
@ nRow,00  PSAY cEndEnt 

Return( Nil )

/*   Imprime Boleto via Bradesco WSISLASER  */

Static Function ImpBoleto()

If MV_PAR05 <> 2
	  // Para bonificaço nao imprimir boletos 
	
		cDirBol := GetMV("FS_ELE007")
	
		/* Nome do arquivo do boleto: cDirBol\cFilAnt\CBxxxxxx.rem */

		If ! Empty( cDirBol ) .And. !U_IsBonif(SF2->F2_DOC,SF2->F2_SERIE) 
   			
   			If File ( cDirBol + '\' + cFilAnt + '\CB' + Substr(SF2->F2_DOC,4,6) + '.Rem' )   // CURITIBA - Victor Abreu
   
      			_cRun := cDirBol + '\' + '\WSisLsr.Exe ' + cFilAnt + '\CB' + Substr(SF2->F2_DOC,4,6) + '.Rem 0' // CURITIBA  - Victor Abreu
                WinExec( _cRun )

   			EndIf  
   		
   		EndIf
    
EndIf

Return( Nil )

/* Pesquisa cadastro de clientes */

Static Function LerCadCli( vCliente, vLoja )

SA1->( dbSeek( _fSA1 + vCliente + vLoja, .F. ) )
	
_cNome := SA1->A1_NOME

_nLen := Len( AllTrim( SA1->A1_CGC ) )

If _nLen > 11

   _cCnpj := Transform( SA1->A1_CGC, "@R 99.999.999/9999-99" )

Else

   _cCnpj := Transform( SA1->A1_CGC, "@R 999.999.999-99" )

End

_cEnd := SA1->A1_END
_cBro := SA1->A1_BAIRRO
_cCep := Transform( SA1->A1_CEP, "@R 99999-999" )
_cMun := SA1->A1_MUN

If !EMPTY(SA1->A1_DDD)

	_cDdd := "("
	_cDdd +=  AllTrim( SA1->A1_DDD )
	_cDdd += ')'

Else

		_cDdd := SPACE(5)
	
EndIf

_cTel := Alltrim( SA1->A1_TEL )
_nLen := Len( _cTel )

If _nLen = 8

   _cTel := Transform( _cTel, "@R 9999-9999" )

ElseIf _nLen = 7

   _cTel := Transform( _cTel, "@R 999-9999" )

End

_cEst  := SA1->A1_EST
_cInsE := SA1->A1_INSCR

_cPcaP := Alltrim( SA1->A1_MUNC )
_cPcaP += " - "
_cPcaP += SA1->A1_ESTC

_cEndC := Alltrim( SA1->A1_ENDCOB )
_cEndC += " - "
_cEndC += Transform( SA1->A1_CEPC, "@R 99999-999" )
lSuf   := !Empty(SA1->A1_SUFRAMA) //.And. SA1->A1_CALCSUF <> "N"

Return( .T. ) // Function LerCadCli()

/* Ler cadastro de fornecedores */

Static Function LerCadFor( vCliente, vLoja )

SA2->( dbSeek( _fSA2 + vCliente + vLoja, .F. ) )

_cNome := SA2->A2_NOME

_nLen := Len( AllTrim( SA2->A2_CGC ) )

If _nLen > 11

   _cCnpj := Transform( SA2->A2_CGC, "@R 99.999.999/9999-99" )

Else

   _cCnpj := Transform( SA2->A2_CGC, "@R 999.999.999-99" )

End

_cEnd := SA2->A2_END
_cBro := SA2->A2_BAIRRO
_cCep := Transform( SA2->A2_CEP, "@R 99999-999" )
_cMun := SA2->A2_MUN

_cDdd := "("
_cDdd +=  AllTrim( SA2->A2_DDD )
_cDdd += ")"

_cTel := Alltrim( SA2->A2_TEL )

_nLen := Len( _cTel )

If _nLen = 8

   _cTel := Transform( _cTel, "@R 9999-9999" )

ElseIf _nLen = 7

   _cTel := Transform( _cTel, "@R 999-9999" )

End

_cEst  := SA2->A2_EST
_cInsE := SA2->A2_INSCR

_cPcaP := Alltrim( SA2->A2_MUN )
_cPcaP += " - "
_cPcaP += SA2->A2_EST

_cEndC := Alltrim( SA2->A2_END )
_cEndC += " - "
_cEndC += Transform( SA2->A2_CEP, "@R 99999-999" )

Return( NIL )

// Get os valores de ICMS para serem impresso nos Dados Adicionais da NF
// Para os itens onde o solidario e pagou pelo cliente (SP - Cliente Solidario) 
// O ICMS e destacado no campo dados adicionais
/*
Static Function getValICMS(aItensNF)

Local nValICMS	:= 0
Local nItms	:= Len(aItensNF)

For i := 1 To nItms

	If  aItensNF[i][19] == "S" // Campo B1_OPPROP
	
		nValICMS += aItensNF[i][18] // D2_VALICM  	
	
	EndIf

Next

Return (nValICMS)
*/
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³StrToArray  ºAutor  ³Eletromegaº Data ³  25/03/03           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Monta o texto conforme foi digitado pelo operador e quebra  º±±
±±º          ³as linhas no tamanho especificado sem cortar palavras e     º±±
±±º          ³devolve um array com os textos a serem impressos.           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ cString - O String a ser quebrado                          º±±
±±º          ³ nTaM    - Tamanho maximo de colunas do texto               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Generico                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function StrToArray(cString,nTam)

//Local cString	:= MSMM(cCodigo,nTam)		// Carrega o memo da base de dados
Local nI		:= 0    					// Contador dos caracteres	
Local nJ		:= 0    					// Contador dos caracteres	
Local nL		:= 0						// Contador das linhas 
Local nC        := 0						// Contador dos caracteres
Local cLinha	:= ""						// Guarda a linha editada no campo memo
Local aLinhas	:= {}						// Array com o memo dividido em linhas
Local cLine     := ""						// Line sem Line Feed
Local lAchou    := .F.                      // Flag
Local nII		:= 0                        // 
Local nLL		:= 0

// Remove Line Feed from string
For nC := 1 To Len(cString)

	If (MsAscii(SubStr(cString,nC,1)) <> 10)  // Line Feed
		cLine += SubStr(cString,nC,1)
	EndIf 

Next

cString := cLine

For nI := 1 TO Len(cString)
	If (MsAscii(SubStr(cString,nI,1)) <> 13) .AND. (nL < nTam) // MsAscii
		// Enquanto não houve enter na digitacao e a linha nao atingiu o tamanho maximo
			cLinha+=SubStr(cString,nI,1)
			nL++
	Else    
		// Se a linha atingiu o tamanho maximo ela vai entrar no array
		If MsAscii(SubStr(cString,nI,1)) <> 13
			nI--
			nII := nI 
			nLL := nL
			For nJ := Len(cLinha) To 1 Step -1
				// Verifica se a ultima palavra da linha foi quebrada, entao retira e passa pra frente
				If SubStr(cLinha,nJ,1) <> " " //.And. nJ < 15  
					nII--
					nLL--
				Else
					lAchou := .T.
					Exit
				Endif
			Next nJ
			
			If lAchou
				nI := nII 
				nL := nLL
				lAchou := .F.
			EndIf
			// Se a palavra for maior que o tamanho maximo entao ela vai ser quebrada
			If nL <=0
				nL := Len(cLinha)
			Endif
		Endif
		
		// Testa o valor de nL para proteger o fonte e insere a linha no array
		If nL >= 0
			cLinha := SubStr(cLinha,1,nL)
			AAdd(aLinhas, Trim(cLinha))
			cLinha := ""
			nL := 0
		Endif	
	Endif
Next nI

// Se o nL > 0, e porque o usuario nao deu enter no fim do memo e eu adiciono a linha no array.
If nL >= 0
	cLinha := SubStr(cLinha,1,nL)
	AAdd(aLinhas, cLinha)
	cLinha := ""
	nL := 0
Endif	

Return(aLinhas)