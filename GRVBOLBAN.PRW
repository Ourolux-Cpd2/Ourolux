#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GRVBOLBAN ºAutor  ³Microsiga           º Data ³  09/25/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Gera boleto bancario para Banco Bradesco                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function GrvBolBan()

Local cDirBol		:= GetMV("FS_ELE007")
Local nVlrDesc 		:= 0
Local cMensagem1 	:= "" 
Local cData     	:= ""
Local _cBanco 		:= ""
Local _aAreaSF2     := ""
Private cPerg 		:= PadR('GRVBOL',10)

If Empty (cDirBol)
	MsgInfo("Diretorio de boleto invalido")
	Return( NIL )
EndIf

If ! ( Pergunte( cPerg , .T. ) )
   Return( NIL )
EndIf

_aAreaSF2 := SF2->(GetArea())

dbSelectArea("SF2")
dbSetOrder(1)
 

DbSeek(xFilial("SF2")+MV_PAR01+MV_PAR03)

_cBanco := GetAdvFVal("SC5","C5_BANCO",xFilial("SC5")+SF2->F2_DOC+SF2->F2_SERIE,5,"")

While !EOF() .And. MV_PAR02+MV_PAR03 >= SF2->F2_DOC+SF2->F2_SERIE
	If U_IsBonif(SF2->F2_DOC,SF2->F2_SERIE) .Or.;
		_cBanco $ 'LIC.CAR'  
		//Return( NIL )
		SF2->(DbSkip())
	EndIf

	//SF2->(DbSkip())
	//End

	RptStatus( { || PsqBoleto(cDirBol) } )
	SF2->(DbSkip())
EndDo

RestArea(_aAreaSF2)
Return( NIL )



Static Function PsqBoleto(cDirBol)

Local nLenNota := len(alltrim(mv_par01))
	  _nNotIni := Val( MV_PAR01 )
      _nNotFim := Val( MV_PAR02 )
      _cNota   := _nNotIni

SetRegua( _nNotFim - _nNotIni )

_fSA1    := xFilial( 'SA1' )
_fSE1    := xFilial( 'SE1' )

/*
If cFilAnt == '01'

   _cSerie := '3  '

ElseIf cFilAnt == '02'

   _cSerie := '2  '

End
*/

_cSerie := MV_PAR03

_nMlt := { 2, 7, 6, 5, 4, 3, 2, 7, 6, 5, 4, 3, 2 }

While  .T.

	_cNota := StrZero( _cNota, nLenNota , 0 )

	SE1->( dbSeek( _fSE1 + _cSerie + _cNota + ' ', .T. ) )

	If (_cNota  = Alltrim(SE1->E1_NUM)) .And.;
 		( _cSerie = SE1->E1_PREFIXO )
		
		GrvBoleto(cDirBol)
	
	EndIf

   	_cNota := Val( _cNota )
   	_cNota ++
   	SF2->(DbSkip())
   	
   	IncRegua()
   	
	If _cNota > _nNotFim
		Exit
	EndIf

EndDo

Return( NIL )



Static Function GrvBoleto(cDirBol)

_nHnd := fCreate( cDirBol +'\' + cNumEmp +'\CB' + IF(Len(AllTrim(_cNota)) > 6, SubStr(_cNota,4,6),SubStr(_cNota,1,6)) + '.Rem', 0 ) // Victor Abreu - + _cNota + 
                                                                         

If _nHnd == -1
	MsgInfo("Nao gerou boleto. Error code: " + STR (FERROR()))
EndIf

_cReg := '0' 

If Substr(cNumEmp,1,2) == '01'
	
	If cFilAnt == '02'

		_cReg += '3381'			        /* --- Agencia sem o DV  ---*/
		_cAge := '3381'
	
		If MV_PAR04 == 1                /* Carteira 02 */
			_cReg += '0002149'			/* --- Conta sem o DV  ---*/
		ElseIf MV_PAR04 == 2            /* Carteira 09 */
			_cReg += '0135320'			/* --- Conta sem o DV  ---*/
		EndIf

	ElseIf cFilAnt $ '01.04.05'         /* Claudino - I1611-1024 - 14/11/16 adicionei a filial Pernambuco. */

		_cReg += '3381'	        	    /* --- Agencia sem o DV  ---*/
		_cAge := '3381'
	
		If MV_PAR04 == 1                /* Carteira 02 */
			_cReg += '0135310'  	    /* --- Conta sem o DV  ---*/
		ElseIf MV_PAR04 == 2            /* Carteira 09 */
			_cReg += '0135309'  	    /* --- Conta sem o DV  ---*/
		EndIf

	EndIf
	
ElseIf Substr(cNumEmp,1,2) == '02'  //Ourolux
	
	_cReg += '3381'			        /* --- Agencia sem o DV  ---*/
	_cAge := '3381'
	
	If MV_PAR04 == 1                /* Carteira 02 */
		_cReg += '0161605'  	    /* --- Conta sem o DV  ---*/
	ElseIf MV_PAR04 == 2            /* Carteira 09 */
		_cReg += '0001605'  	    /* --- Conta sem o DV  ---*/
	EndIf

EndIf

If MV_PAR04 == 1
	_cReg += '02'                   /* Numero da carteira com registro */
ElseIf MV_PAR04 == 2
	_cReg += '09'    				/* Numero da carteira com registro */
EndIf

_cReg += '0'     /* Dupl. Mercantil */
_cReg += '00'    /* Moeda Real */
_cReg += '0'     /* Tipo da papeleta, sem recibo de entregua */

If Substr(cNumEmp,1,2) == '01'
	If cFilAnt == '02'
		_cReg += '05393234000321'  /*--- CNPJ ---*/
		_cReg += 'OUROLUX COMERCIAL LTDA.                 '  	// 40 CHARS
	ElseIf cFilAnt == '04'
		_cReg += '05393234000402'								/*--- CNPJ 14 CHARS ---*/
		_cReg += 'OUROLUX COMERCIAL LTDA.                 '  	// 40 CHARS
	ElseIf cFilAnt == '01'
		_cReg += '05393234000160'								/*--- CNPJ 14 CHARS ---*/
		_cReg += 'OUROLUX COMERCIAL LTDA.                 '  	// 40 CHARS
	ElseIf cFilAnt == '05'                                      /* Claudino - I1611-1024 - 14/11/16 adicionei a filial Pernambuco. */
		_cReg += '05393234000593'								/*--- CNPJ 14 CHARS ---*/
		_cReg += 'OUROLUX COMERCIAL LTDA.                 '  	// 40 CHARS
	EndIf
ElseIf Substr(cNumEmp,1,2) == '02'
	_cReg += '68931419000109' 
	_cReg += 'OUROLUX COMERCIAL LTDA.                 '
EndIf

_cReg += Chr( 13 )
_cReg += Chr( 10 )

fWrite( _nHnd, _cReg, 074 )

While _cNota = Alltrim(SE1->E1_NUM)

	_cReg := '1'

	SA1->( dbSeek( _fSA1 + SE1->E1_CLIENTE + SE1->E1_LOJA, .F. ) ) 

	_cCNPJ := Val( SA1->A1_CGC )
 	_cCNPJ := StrZero( _cCNPJ, 14 )

   	_cReg += if( Substr( _cCNPJ, 1, 3 ) <> '000', '2', '1' )

   	_cReg += _cCNPJ

   	_cReg += SA1->A1_NOME
	_cReg += SA1->A1_ENDCOB
	_cReg += SA1->A1_MUNC   
   	_cReg += Space( 5 )

   	If SA1->A1_CEPC <> SA1->A1_CEP

		_cReg += Space( 20 )

   	Else

		_cReg += Substr(SA1->A1_BAIRRO,1,20)

	EndIf

   	_cReg += SA1->A1_ESTC
   	_cReg += SA1->A1_CEPC

   	_nNro := '09'

   	_cPrf := StrZero( Val( SE1->E1_PREFIXO ), 3, 0 )

   	If _cPrf <> '000'

		_nPrf := StrZero( Val( SE1->E1_PREFIXO ), 3 )

   	Else

		_cPrf := '001'

   	EndIf
   
   	_nNro += _cPrf
   	_nNro += IF(Len(AllTrim(_cNota)) > 6, SubStr(SE1->E1_NUM,4,6),SubStr(SE1->E1_NUM,1,6)) //Victor Abreu - SE1->E1_NUM
   
   	If SE1->E1_PARCELA <> ' '

		_nParc := Asc( SE1->E1_PARCELA )
  		_nParc -= 64
    	_nParc := StrZero( _nParc, 2 )
     	_nNro  += _nParc

   	Else

		_nNro += '00'

   	EndIf

   	_nBco := Substr( _nNro,  3, 9 )
   	_nBco += Substr( _nNro, 13, 1 )
   	_cReg += _nBco

   	_nDig := 0

   	For n := 1 To 13

		_nRst := Val( Substr( _nNro, n, 1 ) )
  		_nRst *= _nMlt[ n ]
    	_nDig += _nRst
   
   	Next

   	_nRst := Mod( _nDig, 11 )

   	If _nRst <> 0

		_nDig := 11
  		_nDig -= _nRst

      	If _nDig <> 10

         	_nDig := StrZero( _nDig, 1 )

      	Else

         	_nDig := 'P'

      	EndIf

   	Else

		_nDig := '0'

   	EndIf

   	_nNro += _nDig
   	_nNro := Substr( _nNro, 3 )

   	_cReg += _nNro
   	_cReg += 'N'

   	RecLock( "SE1", .F. )
   		SE1->E1_NUMBCO  := _nNro
   		SE1->E1_PORTADO := SA1->A1_BCO1
   		SE1->E1_AGEDEP  := _cAge
   		SE1->E1_SUPERVI := SA3->A3_SUPER
   	SE1->( MSUnLock() )

   	/* --- Data de Emissao --- */

   	_cDta := DtoS( SF2->F2_EMISSAO )
   	_cReg += Substr( _cDta, 7, 2 )
   	_cReg += Substr( _cDta, 5, 2 )
   	_cReg += Substr( _cDta, 3, 2 )

   	/*  --- Data de Vencimento - */
 
   	_cDta := DtoS( SE1->E1_VENCTO )
   	_cReg += Substr( _cDta, 7, 2 )
   	_cReg += Substr( _cDta, 5, 2 )
   	_cReg += Substr( _cDta, 3, 2 )

  	/*   --- Data de Proc. ---- */

   	_cDta := DtoS( dDataBase )
   	_cReg += Substr( _cDta, 7, 2 )
   	_cReg += Substr( _cDta, 5, 2 )
   	_cReg += Substr( _cDta, 3, 2 )

  	/*   --- Data limite Desconto - */

   	_cReg += '000000'

  	/*   --- Data limite recbimento --- */

   	_cReg += '000000'

  	/*   --- Data de Protesto  -- */

   	_cDta := SE1->E1_VENCTO
   	_cDta += 6
   	_cDta := DtoS( _cDta )
   	_cReg += Substr( _cDta, 7, 2 )
   	_cReg += Substr( _cDta, 5, 2 )
   	_cReg += Substr( _cDta, 3, 2 )

   	/* --- Valor do Titulo --- */

   	_nVlr := SE1->E1_VALOR
   	_nVlr *= 100
   	_nVlr := StrZero( _nVlr, 10 )
   	_cReg += _nVlr

   	/* --- Valor do Desconto - */

   	_cReg += '0000000000'

   	/* --- Valor do Abatimento - */

   	_cReg += '0000000000'

   	/* --- Valor da Multa - */

   	_cReg += '0000000000'

   	/* --- Valor do Juros      - */

   	_nVlr := SE1->E1_VALOR
   	_nVlr *= 0.004
   	_nVlr := Round( _nVlr, 2 )
   	_nVlr *= 100
   	_nVlr := StrZero( _nVlr, 10 )
   	_cReg += _nVlr

   	/* --- Mensagens ---- */

  	// Desconto Financeiro
   	If (SE1->E1_DESCFIN <> 0) 
   		
   		nVlrDesc := Round((SE1->E1_VALOR * SE1->E1_DESCFIN)/100,2)
   		
   		cData := SE1->E1_VENCTO - SE1->E1_DIADESC
   		cData := DtoS( cData )
   		
   		cData = Substr( cData, 7, 2 ) + '/' + Substr( cData, 5, 2 ) + '/' + Substr( cData, 1, 4 )
   				
		cMensagem1 := 'ATE ' + cData + ' DESCONTO DE R$: ' + TRANSFORM (nVlrDesc,"@E 999,999.99") 
           		 
   		_cReg += cMensagem1 + Space ( 80 - Len(cMensagem1))
   
   	EndIf
   
   	_cReg += Space( 80 )
   	_cReg += Space( 80 )
   	_cReg += Space( 80 )

   	/* --- Finalizador de registro */

   	_cReg += Chr( 13 )
   	_cReg += Chr( 10 )
 
   	fWrite( _nHnd, _cReg, 577 )
   	SE1->( dbSkip( 1 ) )

EndDo  

fClose( _nHnd )

Return( Nil )