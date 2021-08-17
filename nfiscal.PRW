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
±±³Formulario serie 1 - Usado em Filial 02 (Parana)                       ³±±
±±³  					                                                  ³±± 
±±³  					                                                  ³±±
±±³  					                                                  ³±±
±±³  					                                                  ³±±
±±³  					                                                  ³±±                                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Eletromega                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

#Include "rwmake.ch"

User Function NFISCAL()

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
Local lSuf          := .F.
Local lImpZFRC		:= .F. 
Local nVlrIcmsDA    := 0  
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
_aObs        := ''
cPedCli 	 := ''
aTes         := {}
cCFDesc      := ""
cCFOP        := ""
nLine        := 0
_cObs        := ''
 

PRIVATE tamanho:= "G"
PRIVATE limite := 220
PRIVATE titulo := PADC("Nota Fiscal Saida/Entra",74)
PRIVATE cDesc1 := PADC("Este programa ira emitir a Nota Fiscal de Entrada/Saida",74)
PRIVATE cDesc2 := PADC("da EletroMega.                                         ",74)
PRIVATE cDesc3 := ""
PRIVATE aReturn := { "Especial", 1,"Administracao", 2, 2, 1,"",0 }
PRIVATE nomeprog :="NFISCAL"
PRIVATE cPerg :=PadR("NFSIGW",10)
PRIVATE nLastKey  := 0
PRIVATE lContinua := .T.
PRIVATE wnrel     := "NFISCAL"
PRIVATE cposipi := ""    // nº NCM
PRIVATE csigla := ""     // a sigla do cod NCM
PRIVATE aclassfis := {}  // array da classificacao fiscal
PRIVATE retclass := 0    // valor do ascan
private ncarac := 0
PRIVATE cDirBol := ''
Pergunte(cPerg,.F.)      // Pergunta no SX1
PRIVATE cString:="SF2"
PRIVATE nTxPis     	:= SuperGetMV("MV_TXPIS")
PRIVATE nTxCofin	:= SuperGetMV("MV_TXCOFIN")
Private nMaxChars   := 67  // Max numero de caracters por linha (campo dados adicionais da nossa NF)  



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
	
	ElseIf (cFilAnt == '01' .AND. MV_PAR03 <> '3  ') .Or.; 
		   (cFilAnt == '02' .AND. MV_PAR03 <> '2  ')		 
     	
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
         ApMsgStop( 'Voce esta tentando imprimir um orcamento como NF', 'ATENÇÃO' )
         
         Return
      
      End

   End

   // 1 = F1_FILIAL, F1_DOC, F1_SERIE, F1_FORNECE, F1_LOJA, F1_TIPO
   
   //SF1->( dbSeek( _fSF1 + MV_PAR01 + MV_PAR03 + SD1->D1_FORNECE + SD1->D1_LOJA + "D", .F. ))  23/05/07
	SF1->( dbSeek( _fSF1 + MV_PAR01 + MV_PAR03 + SD1->D1_FORNECE + SD1->D1_LOJA, .F. ))  
   
   
   //If ( SF1->( Eof() ) ) .OR. (SF1->F1_FORMUL == ' ' .AND. SF1->F1_TIPO == 'N') 23/05/07
   
   If ( SF1->( Eof() ) ) .OR. (SF1->F1_FORMUL == ' ' .AND. SF1->F1_TIPO == 'N')  

      Return

   End

   PesqNfCli()

End

Return( Nil )  // RptImpNot  

Static Function PesqNfCli()

aclassfis	:= {} 
lSuf		:= .F. 
       
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
nVlrIcmsDA  := 0
lCalcSuf	:= .F.
lIsentIPI	:= .F.  

If MV_PAR04 <> 1   // NF SAIDA

   SD2->( dbSeek( _fSD2 + _cNota + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA, .T. )) 
   
   SC5->( dbSeek( _fSC5 + SD2->D2_PEDIDO, .F. ) )
   
   While ! ( SD2->( Eof() ) ) .And. ( SD2->D2_SERIE = SF2->F2_SERIE ) .And. ( SD2->D2_DOC   = SF2->F2_DOC ) .And.;
   			SD2->D2_FILIAL == xFilial("SD2") .And. SF2->F2_FILIAL == xFilial("SF2")	 // CURITIBA

      SC6->( dbSeek( _fSC6 + SD2->D2_PEDIDO + SD2->D2_ITEMPV, .F.) ) 
            
      SB1->( dbSeek( _fSB1 + SD2->D2_COD, .F. ) )  
      
		If SD2->D2_EST == "SP"
	  		
	  		cposipi := SB1->B1_POSIPI   // NCM ou NBM
	  	
	  		If (SYD->(dbseek(xFilial("SYD")+cposipi)))
	 
	 			csigla := SYD->YD_SIGLA
	 	
	 		Else
	 	
	 			csigla 	:= ""
	 			cposipi := ""
	 	
	 		EndIf
	 	
		Else  // Para fora do estado so vamos imprimir a class fisc quando o produto tem IPI
      
			If SB1->B1_IPI > 0  // Aliquota de IPI
			
				cposipi := SB1->B1_POSIPI   // NCM ou NBM
			    
				If (SYD->(dbseek(xFilial("SYD")+cposipi)))
	 
	 				csigla := SYD->YD_SIGLA
	 	
	 			Else
	 	
	 				csigla 	:= ""
	 				cposipi := ""
	 	
	 			EndIf

			
			Else  // Nao tem IPI nao vamos imprimir a class fisc
			
				csigla 	:= ""
				cposipi := ""
            
    		EndIf
    	
    	EndIf
	  
	  lImpZFRC 	:= SB1->B1_IMPZFRC <> "S" // <> S Gera desconto de ICMS para Zona Franca
	  lCalcSuf	:= SA1->A1_CALCSUF <> "N" // <> N Gera desconto de ICMS para Zona Franca
	  
	  /* Grava o Numero do Atendimento*/
      
      If  SubStr( SC6->C6_PEDCLI,1,3 ) == 'TMK'  .And. Empty(cPedCli) 
 	  		
 	  		cPedCli := SubStr (SC6->C6_PEDCLI,4,6)
      
      EndIf

	  aAdd( _aItens, { SD2->D2_COD, SC6->C6_DESCRI, IIf (SB1->B1_TIPO == "PA",SD2->D2_CLASFIS,""), SD2->D2_UM,;
                       SD2->D2_QUANT, SD2->D2_PRCVEN, SD2->D2_TOTAL, SD2->D2_PICM,;
                       SD2->D2_NFORI, SD2->D2_IPI, SD2->D2_VALIPI, csigla,; 
                       cposipi, SD2->D2_TES, SD2->D2_CF, SC6->C6_VALOR,; 
                       lImpZFRC, SD2->D2_VALICM, SB1->B1_OPPROP, SB1->B1_IPI } )
      
	  _nItens ++
              
      SD2->( dbSkip() )

   End  /* While */ 

Else   // NF ENTRADA 

   SC5->( dbSeek( _fSC5 + 'XXXXXX', .F. ) )
   		
   While ! ( SD1->( Eof() ) ) .And. ( SD1->D1_SERIE = SF1->F1_SERIE ) .And. ( SD1->D1_DOC   = SF1->F1_DOC ) .And.;
			SD1->D1_FILIAL == xFilial("SD1") .And. SF1->F1_FILIAL == xFilial("SF1")	 // CURITIBA
      
      SB1->( dbSeek( _fSB1 + SD1->D1_COD, .F. ) ) 

      cposipi := SB1->B1_POSIPI //05-06-06      
      _nUnit := SD1->D1_VALDESC
      _nUnit /= SD1->D1_QUANT
            
      _nUnit := Round( _nUnit, 4 ) 
     
      _nUnit := ( SD1->D1_VUNIT - _nUnit )
     
     // pega a sigla de acordo com o NCM  
     
	 If (SYD->(dbseek(xFilial("SYD")+cposipi)))
	 
	 	csigla := SYD->YD_SIGLA
	 	
	 Else
	 
	 	csigla := ""
	 	cposipi := ""
	 
	 EndIf
	  
     aAdd( _aItens, {  SD1->D1_COD    ,;
                       SB1->B1_DESC   ,;
                       SB1->B1_CLASFIS,;
                       SD1->D1_UM     ,;
                       SD1->D1_QUANT  ,;
                       _nUnit         ,;
                       SD1->D1_TOTAL  ,;
                       SD1->D1_PICM   ,;
                       SD1->D1_NFORI  ,;
                       SD1->D1_IPI	  ,;  
                       SD1->D1_VALIPI ,;  
                       csigla         ,; 
                       cposipi        ,; 
                       SD1->D1_TES    ,; 
                       SD1->D1_CF     ; 
                     };
          )

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
			_nBseSubs  	:= SF2->F2_BICMST  // 08-04-2009 BASE DE ICMS ST PARA NF COMPLEMENTAR DE ICMS ST
			_nTotNot  	:= SF2->F2_ICMSRET
		EndIf

	EndIf

Else /* Entrada */

   _nBseIcms  := SF1->F1_BASEICM
   _nVlrIcms  := SF1->F1_VALICM
   _nBseSubs  := SF1->F1_BRICMS
   _nVlrSubs  := SF1->F1_ICMSRET
   _nTotProd  := SF1->F1_VALMERC

   _nVlrFret  := SF1->F1_FRETE
   _nVlrSeg   := SF1->F1_SEGURO
   _nDespAce  := SF1->F1_DESPESA
   _nVlrIpi   := SF1->F1_VALIPI

   _nTotNot   := SF1->F1_VALMERC
   _nTotNot   += SF1->F1_VALIPI
   _nTotNot   += SF1->F1_SEGURO
   _nTotNot   += SF1->F1_FRETE
   _nTotNot   += SF1->F1_DESPESA
   _nTotNot   += SF1->F1_ICMSRET

End

/*

        Transportadora/Volumes Transportados da Nota Fiscal

*/

SA4->( dbSeek( _fSA4 + SC5->C5_TRANSP, .F. ) )

_cTransp := SA4->A4_NOME

If SC5->C5_TPFRETE <> "C"

   _cEmtDst    := '2'

Else

   _cEmtDst    := '1'

End

_cPlaca     :=  ''

_cEndTransp := Alltrim( SA4->A4_END )

If ! Empty( SA4->A4_BAIRRO )

   _cEndTransp += ' - '
   _cEndTransp += SA4->A4_BAIRRO

End

 _cMunTransp := SA4->A4_MUN
 _cEstTransp := SA4->A4_EST

_nQde       := SF2->F2_VOLUME1
_cEsp       := SF2->F2_ESPECI1

_cDddTransp := '('
_cDddTransp += AllTrim( SA4->A4_DDD )
_cDddTransp += ')'

 _cFonTransp := Alltrim( SA4->A4_TEL )

_nLen := Len( _cFonTransp )

If _nLen = 8

   _cFonTransp := Transform( _cFonTransp, "@R 9999-9999" )

ElseIf _nLen = 7

   _cFonTransp := Transform( _cFonTransp, "@R 999-9999" ) 

ElseIf _nLen = 0         // war
   
	_cFonTransp := " "  // war

End

_cEndRet := If( SC5->C5_TIPENT <> '1', '4', '3' )
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
      _cObs += SE4->E4_DESCRI

   Else  /* Devoluçao para fornecedor*/

      _cObs := "Devolucao conf. sua(s) nota(s) fiscal(is) de n§(s): "

      For i := 1 To _nItens

          _cObs += Transform( _aItens[ i ][ 9 ], '@R 999.999' )
          _cObs += ', '                                          

          If Len( _cObs ) >= 69
  
             aAdd( _aObs, _cObs )
             _cObs := ''

          End

      Next

   EndIf

Else	/* Entrada */
	
	If ( SF1->F1_TIPO == 'D')  // Devoluçao 23/05/2007 
   	
   		_cObs := "Conforme nossa nota de de n§: " 
   		_cObs += _aItens[ 1 ][ 9 ]
 	
 	ElseIf SF1->F1_TIPO == 'N' .And. SF1->F1_FORMUL == 'S'  // ENTRADA NOSSO FORMULARIO
 	
 		If ! Empty( SF1->F1_OBSNFE )  // Obs NFE

			For nInd := 1 to 8  // 8 Linhas no campo Dados Adicionais
    	
    			aAdd( _aObs, Trim(MemoLine(SF1->F1_OBSNFE,70,nInd)))
   	
   			Next nInd 

 	    EndIf
 	
 	EndIf

End

If !Empty(_cObs)
	aadd(_aObs,SUBSTR(_cObs,1,72))	 
EndIf

If _nVlrSubs <> 0 .And. MV_PAR04 == 2

   Set Device To Screen
   _cMsg := 'Atenção, a Nota Fiscal nº ' + SF2->F2_DOC + ' contem ICMS a recolher (substituição tribut-' + Chr( 13 )
   _cMsg += 'aria), informe o Dpto. Financeiro para que seja emitida a GNRE - Guia' + Chr( 13 )
   _cMsg += 'Nacional de Recolhimento de Tributo Estadual,a mesma deverá ser recolhida na' + Chr( 13 )
   _cMsg += 'rede bancaria e anexada a Nota Fiscal'
   MsgInfo( _cMsg )    
   Set Device To Print

   aAdd( _aObs, "RECOLHIMENTO DO ICMS CONF. PROTOCOLO N§ 17 DE 25.07.85 DOU DE 29.07.85" )  // 70 Chars pode ate 72 Chars

End 

If MV_PAR04 == 2 

	cUAObs := SC5->C5_MSGNOTA

	If ! Empty( cUAObs )  // get MsgNot from sc5

		For nInd := 1 to 3
    	
    		aAdd( _aObs, Trim(MemoLine(cUAObs,64,nInd)))
   	
   		Next nInd 

	Else  // get OBS from SUA 
	
		If (! Empty (cPedCli))
		
			Dbselectarea("SUA")
		
			If Dbseek(Xfilial("SUA") + cPedCli)	
			
				If ! Empty(SUA->UA_CODOBS)
			
					cUAObs := MSMM(SUA->UA_CODOBS,64)
			
					FOR nInd := 1 TO 3 //MlCount(cObs,43)
					
						aAdd( _aObs, Trim(MemoLine(cUAObs,64,nInd)))
				
					Next nInd
			
				EndIf
	
			EndIf  // Dbseek	
	
		EndIf /* TMK cPedCli */      

	EndIf  /* Campo Obs */

	If ! Empty(SC5->C5_MENPAD)

   		aAdd( _aObs, U_getForml(SC5->C5_MENPAD) )
 
	End
	
	If !Empty(SC5->C5_MENNOTA)

   		aadd(_aObs,SUBSTR(SC5->C5_MENNOTA,1,nMaxChars))
   		
	EndIf 
	
EndIf
  
//       Impressão dos Titulos da Nota Fiscal

TrataTes()
CabecNota()
ItensNota()
CalcImpNota()
TranspNota()
DadAdiNota()
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


                        Cabecalho da Nota Fiscal


*/

Static Function CabecNota()

@ 00,00 PSAY CHR( 27 )+'@'+Chr( 27 )+"C"+Chr( 72 )+Chr( 15 )+Chr( 27 )+"l"+Chr( 4 )

If MV_PAR04 == 1  /* NF ENTRADA */

  
   @ 02,100 PSAY 'X' 
   @ 02,110 PSAY '' + _cNota
   @ 02,121 PSAY '' + _cNota 

Else  /* NF SAIDA */
                                                  
   
   @ 02,89 PSAY 'X' 
   @ 02,106 PSAY '' + _cNota
   @ 02,116 PSAY '' + _cNota 
                        
End

nLine := If( (len(aTes) == 1),7,6 )

For nI := 1 to len(aTes)
		
	If nI > 2  // Nao imprime mais de 2 CFOP
   		Exit
   	EndIf
		
	SF4->( dbSeek(Xfilial("SF4") + aTes[nI][1], .F. ) )
	cCFDesc := SF4->F4_TEXTO
			
	cCFOP := aTes[nI][2]
	cCFOP := substr(cCFOP,1,1) + '.' + substr(cCFOP,2,3)
		
	@ nLine ,00 PSAY cCFDesc
	@ nLine ,45  PSAY cCFOP 
	
   	nLine++
    	
Next nI 

@ 10,00  PSAY _cNome
@ 10,90  PSAY _cCnpj
@ 10,121 PSAY _cEmis Picture "@E 99/99/9999" // Data Emissao 05-01-2007
@ 12,00  PSAY _cEnd
@ 12,78  PSAY _cBro
@ 12,100 PSAY _cCep
//@ 12,121 PSAY dDataBase Picture "@E 99/99/9999" // Data Entrada/Saida na Nota 05-01-2007
@ 14,00  PSAY _cMun
@ 14,58  PSAY _cDdd
@ 14,64  PSAY _cTel
@ 14,83  PSAY _cEst
@ 14,90  PSAY _cInsE
@ 14,121 PSAY Substr( Time(), 1, 5 ) 

_nLen := Len( _aDupl )
_nCol := 36

For i := 1 To _nLen

    @ 16,_nCol PSAY _aDupl[ i ][ 1 ] Picture "@E 99/99/9999"

    If i <> 3

        _nCol += 30

    Else


      _nCol += 20

    End

Next

@ 17,00 PSAY _cNota
_nCol := 34

For i := 1 To _nLen

    @ 17,_nCol PSAY _aDupl[ i ][ 2 ] Picture "@E 9,999,999.99"

    If i <> 3

        _nCol += 30

    Else

      _nCol += 20

    End

Next

@ 19,00 PSAY _cPcaP
@ 19,43 PSAY _cEndC

Return( NIL )

/*

                        Itens da Nota Fiscal

*/

Static Function ItensNota()

_nLin := 22 

For i := 1 To _nItens

   	@ _nLin, 00 PSAY SUBSTR(_aItens[ i ][ 1 ],1,6)   /*  Cod Produto */
    @ _nLin, 10 PSAY RTRIM(_aItens[ i ][ 2 ])        /*  Descricao   */  
    
    If  (_aItens[ i ][ 12 ] != "")
    	retclass := ascan(aclassfis,_aItens[ i ][ 12 ]+"-"+_aItens[ i ][ 13 ])
    	
    	If (retclass == 0) //ascan retorna 0 caso nao encontra nada
    		aadd(aclassfis,_aItens[ i ][ 12 ]+"-"+_aItens[ i ][ 13 ])
    	EndIf 
    	
       	@ _nLin, 60 PSAY _aItens[ i ][ 12 ] /*  class. fis  */ 
        		
    EndIf 
    
    If !Empty (_aItens[ i ][ 3 ])
    	@ _nLin, 65 PSAY _aItens[ i ][ 3 ] Picture  "@ 999"    //  Sit. Trib.  //
    EndIf          
    
    @ _nLin, 71 PSAY _aItens[ i ][ 4 ]                              /*  Unidade     */ 
    @ _nLin, 75 PSAY _aItens[ i ][ 5 ] Picture   "@E 9,999,999.99"  /*  Quantidade  */  

       
    If  (SF2->F2_TIPO == 'I')  		// Pedido tipo I -> Zerar 
    	_aItens[ i ][ 6 ] := 0  	/*  Valor Unit. */
    	_aItens[ i ][ 7 ] := 0	    /*  Valor Total */ 
    	_aItens[ i ][ 8 ] := 0 		/*  Aliq. ICMS  */
    EndIf	
    
    @ _nLin, 90 PSAY _aItens[ i ][ 6 ]  Picture  "@E 99,999.9999"	/*  Valor Unit. */   
    @ _nLin,103 PSAY _aItens[ i ][ 7 ]  Picture  "@E 9,999,999.99"  /*  Valor Total */  
    @ _nLin,118 PSAY _aItens[ i ][ 10 ] Picture  "@E 99"            /*  Aliq. IPI  */ 
    @ _nLin,122 PSAY _aItens[ i ][ 8 ]  Picture  "@E 99"            /*  Aliq. ICMS  */ 
    @ _nLin,125 PSAY _aItens[ i ][ 11 ] Picture  "@E 9,999,999.99"  /*  Valor IPI  */ 
            
    //escreve o nº da nota no segundo canhoto se o nº itens > 16 e a linha = 38
    If (_nItens > 16 .AND. _nlin == 38) 
		@ _nlin,143 PSAY '' + _cNota 
	End
	
    _nLin ++

Next
    //se menor que 16 itens escreve diretamente na linha 38
	If (_nItens <= 16 ) 
		@ 38,143 PSAY '' + _cNota 
	End

Return( Nil )


/*

                     Calculo do Imposto da Nota Fiscal

*/

Static Function CalcImpNota()

@ 47, 16 PSAY _nBseIcms  Picture "@EZ 999,999,999.99" 
@ 47, 42 PSAY _nVlrIcms  Picture "@EZ 999,999,999.99"  
@ 47, 69 PSAY _nBseSubs  Picture "@EZ 999,999,999.99"  
@ 47, 94 PSAY _nVlrSubs  Picture "@EZ 999,999,999.99"   
@ 47,122 PSAY _nTotProd  Picture "@E 999,999,999.99" 
@ 49, 15 PSAY _nVlrFret  Picture "@EZ 999,999,999.99" 
@ 49, 38 PSAY _nVlrSeg   Picture "@EZ 999,999,999.99"  
@ 49, 65 PSAY _nDespAce  Picture "@EZ 999,999,999.99"  
@ 49, 94 PSAY _nVlrIpi   Picture "@EZ 999,999,999.99"  
@ 49,122 PSAY _nTotNot   Picture "@E 999,999,999.99" 

Return( Nil )

/*

        Transportadora/Volumes Transportados da Nota Fiscal

*/

Static Function TranspNota()

@ 52, 00 PSAY _cTransp 
@ 52,79  PSAY _cEmtDst 
@ 52,110 PSAY _cPlaca 
@ 54, 00 PSAY _cEndTransp 
@ 54, 89 PSAY _cMunTransp   
@ 54,103 PSAY _cEstTransp  
@ 56, 10 PSAY _nQde Picture "@EZ 99999" 
@ 56, 13 PSAY _cEsp 
@ 56, 46 PSAY _cDddTransp 
@ 56, 52 PSAY _cFonTransp 
@ 56, 95 PSAY _cEndRet 
@ 56,107 PSAY _nPsoBrt Picture "@EZ 999,999.9" 
@ 56,123 PSAY _nPsoLqd Picture "@EZ 999,999.9" 
@ 58,00  PSAY cEndEnt 

Return( Nil )

/*


                 Dados Adicionais da Nota Fiscal


*/

Static Function DadAdiNota()
Local nMaxLine	:= 67  // 8 lines 
Local nMaxChar	:= 72  // 72 Charcters
Local nPos		:= 0

_nLin := 60
_nLen := Len( _aObs )

@ _nLin,00 PSAY _aObs[1]  // Imprime Vendedor 
_nLin ++

If _nVlrSubs <> 0 .And. MV_PAR04 == 2 // Caso NF saida e tem solidario imprime linha 2 
	
	@ _nLin,00 PSAY _aObs[2]  // "RECOLHIMENTO DO ICMS CONF. PROTOCOLO N§ 17 DE 25.07.85 DOU DE 29.07.85" 
   	_nLin ++
	
EndIf

If ! Empty(aclassfis)
	
	aSort(aclassfis)
	_nLen := len(aclassfis)
	
	IIf (_nLen > 20,20,_nLen) //imprime 20 class fiscal por nota
		
	nPos := Len ("Cl. Fisc.: ")
	
	@ _nLin,00 PSAY "Cl. Fisc.: "
	
	For i := 1 to _nLen   // Numero de class. fiscais a serem impressos
		
		If (nMaxChar-nPos >  Len (Alltrim(aclassfis[i]) + " ")) // Cabe na linha?
		
			@ _nLin,nPos PSAY AllTrim(aclassfis[i]) + " "
			nPos += Len (Alltrim(aclassfis[i]) + " ")
		
		Else  
			
			If (_nLin < nMaxLine)
				
				_nLin++
				nPos := 0
				@ _nLin,nPos PSAY AllTrim(aclassfis[i]) + " "
				nPos := Len (Alltrim(aclassfis[i]) + " ")
					
			Else 
				Exit   // Run out of space !
			EndIf
		
		EndIf
	
	Next
		
_nLin++

End

If ( MV_PAR04 <> 1   .And. lSuf .And. _nLin < nMaxLine ) // NF SAIDA + Suframa

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
	
	If	nTotSuf <> 0 .Or. nTotICMS <> 0
		@ _nLin,00 PSAY "Desc: "
		nPos := Len ("Desc: ")
	EndIf
	
	If nTotSuf <> 0
		@ _nLin,nPos PSAY Alltrim(STR(nTxPis,,2)) + "% PIS = " 
		nPos += Len(Alltrim(STR(nTxPis,,2)) + "% PIS = ")
		@ _nLin,nPos PSAY Alltrim(STR((nTotSuf * nTxPis)/100,,2))//  	Picture  "@E 99,999.99"  /*  Desconto PIS   */ 
		nPos += Len(Alltrim(STR((nTotSuf * nTxPis)/100,,2)))
		@ _nLin,nPos PSAY " | " + Alltrim(STR(nTxCofin,,2)) + "% Cofins = "
		nPos += Len(" | " + Alltrim(STR(nTxCofin,,2)) + "% Cofins = ")
		@ _nLin,nPos PSAY Alltrim(STR((nTotSuf * nTxCofin)/100,,2)) //	Picture  "@E 99,999.99"  /*  Desconto Cofins */
		nPos += Len(Alltrim(STR((nTotSuf * nTxCofin)/100,,2)))
		@ _nLin,nPos PSAY " | "
		nPos += Len(" | ")  
	EndIf
	
	If lImpZFRC .And. lCalcSuf  // Desconto de ICMS para Zona Franca 
	
		_nLen := Len("7% ICMS = ") + Len(Alltrim(STR(nTotICMS * 0.07,,2)))
		
		If (_nLen < nMaxChar - nPos)
		
			@ _nLin,nPos PSAY "7% ICMS = "
			nPos += Len("7% ICMS = ")
			@ _nLin,nPos PSAY Alltrim(STR(nTotICMS * 0.07,,2))  //Picture  "@E 99,999.99"  /*  Desconto PIS   */ 
			nPos += Len(Alltrim(STR(nTotICMS * 0.07,,2)))
            
			_nLin++
			
			If ! Empty (U_getForml("006")) .And. _nLin < nMaxLine
				
				@ _nLin,00 PSAY U_getForml("006")  // Isencao de ICMS
				_nLin++
			
			EndIf
		
		EndIf
		
	Else  // Venda nao tem desconto de ICMS para Zona Franca
		_nLin++	
	EndIf

	If	lIsentIPI // Isento de IPI
		If ! Empty (U_getForml("007")) .And. _nLin < nMaxLine 
			@ _nLin,00 PSAY U_getForml("007")  // Isencao de IPI
			_nLin++
		EndIf
	EndIf
	If ! Empty (U_getForml("008")) .And. _nLin < nMaxLine
		@ _nLin,00 PSAY U_getForml("008")  // SUFRAMA
		_nLin++
	EndIf

EndIf

// Write o Valor de ICMS no Campo dados Adicionais
If	nVlrIcmsDA > 0
	If (_nLin < nMaxLine)

		nPos := 0
		@ _nLin,nPos PSAY "ICMS op. propria R$ " + Alltrim(STR(nVlrIcmsDA,,2))
		nPos += Len("ICMS op. propria R$ " + Alltrim(STR(nVlrIcmsDA,,2))) 
		If ! Empty (U_getForml("009"))
			nPos += 1
			@ _nLin,nPos PSAY U_getForml("009")  // ICMS op. propria / SP 
		EndIf

		_nLin ++
	EndIf
EndIf
// Write Mensagem p nota
If (_nLin <= nMaxLine)
	
	_nLen	:= Len( _aObs )

	For i := IIf (_nVlrSubs <> 0,3,2) To _nLen  //i := 3 To _nLen

		If !Empty(_aObs[ i ])
			@ _nLin,00 PSAY _aObs[ i ]   
   			_nLin ++
   		EndIf
    	
    	If _nLin > nMaxLine  // Out of space!
    		Exit
       	EndIf 
	Next

EndIf

If MV_PAR05 <> 2
	  // Para bonificaço nao imprimir boletos 
	
		cDirBol := GetMV("FS_ELE007")
	
		/* Nome do arquivo do boleto: cDirBol\cFilAnt\CBxxxxxx.rem */

		If ! Empty( cDirBol ) .And. !U_IsBonif(SF2->F2_DOC,SF2->F2_SERIE) 
   			
   			If File ( cDirBol + '\' + cFilAnt + '\CB' + SF2->F2_DOC + '.Rem' )   // CURITIBA
   
      			_cRun := cDirBol + '\' + '\WSisLsr.Exe ' + cFilAnt + '\CB' + SF2->F2_DOC + '.Rem 0' // CURITIBA 
                WinExec( _cRun )

   			EndIf  
   		
   		EndIf
    
EndIf

Return( Nil )

/*

   Pesquisa cadastro de clientes
   

*/
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

_cDdd := "("
_cDdd +=  AllTrim( SA1->A1_DDD )
_cDdd += ')'

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

Return( .T. )

/*

    Ler cadastro de fornecedores


*/


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
Static Function getValICMS (aItensNF)

Local nValICMS	:= 0
Local nItms	:= Len(aItensNF)

For i := 1 To nItms

	If  aItensNF[i][19] == "S" // Campo B1_OPPROP
	
		nValICMS += aItensNF[i][18] // D2_VALICM  	
	
	EndIf

Next

Return (nValICMS)