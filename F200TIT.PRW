/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³F200TIT   ºAutor  ³Microsiga           º Data ³  02/02/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ CNAB RECEBER                                               º±±
±±º          ³ Executado após a leitura da linha de detalhe, 			  º±±
±±º          ³ depois da gravação de todos os dados.                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function F200Tit()

Local	aAreaSE5:= SE5->(GetArea())
Local 	aAreaSE1:= SE1->(GetArea())

Private _nJrs 	 := 0
Private _cProc   := ' '
Private _nIdx 	 := ' '
Private _nDia 	 := 0
Private _cFil 	 := ' ' 
Private _cPrf 	 := ' '
Private _cNum    := ' '
Private _cPar 	 := ' '
Private _cNat 	 := ' '
Private _cCli 	 := ' '
Private _cNom    := ' '
Private _cVct 	 := ' '
Private _cPed 	 := ' '
Private _cIdCnab := ' ' // Claudino 19/05/14

For n := 1 To 8

    _cProc := AllTrim( ProcName( n ) )

    If _cProc = [FA200GER]

       Exit    

    End
       
Next


If _cProc <> [FA200GER] .Or. Empty(SE1->E1_NUM)  

   	RestArea(aAreaSE5) 
	RestArea(aAreaSE1)  

   	Return( NIL )

End

If (SEB->EB_OCORR $ [08.37.23.19.15]) 
	RecLock( 'SE1', .F. )
 	SE1->E1_HIST := SEB->EB_DESCRI
  	SE1->( msUnLock() )
End

_nIdx := SE5->( IndexOrd() )

SE5->( dbSetOrder( 7 ) )
          
If ( SE5->( dbSeek( xFilial( "SE5" ) +;
                    SE1->E1_PREFIXO  +;
                    SE1->E1_NUM      +;
                    SE1->E1_PARCELA  +;
                    SE1->E1_TIPO     +;
                    SE1->E1_CLIENTE  +;
                    SE1->E1_LOJA     +;
                    '01'             ,;
                    .T.               ;
                  )                   ;
          )                           ;
	   )

	If SE5->E5_CNABOC = '07'

    	RecLock( 'SE5', .F. )
    	SE5->E5_HISTOR := 'Pagto vinculado s/cheque'
      	SE5->( rLock() )

    ElseIf SE5->E5_CNABOC = '  '

    	
    	RestArea(aAreaSE5) 
		RestArea(aAreaSE1)  

    	Return( NIL )

   	End

Else
      
   	RestArea(aAreaSE5) 
	RestArea(aAreaSE1)  

	Return( NIL )   

End

_nDia := SE1->E1_BAIXA
_nDia := ( _nDia - SE1->E1_VENCREA )
_nDia ++

SE5->( dbSetOrder( _nIdx ) )

If SE5->E5_CNABOC $ [06.08.17.32.36.37.38.39]

   	If ! ( SE1->( Eof() ) )

      	If Empty( SE1->E1_HIST )

         	RecLock( 'SE1', .F. )
        	SE1->E1_HIST := 'Valor recebido via CNAB'
			SE1->( msUnLock() )

		End

	End

	If _nDia > 0 .And.;
      SE5->E5_CNABOC $ [08.37.] 

 		_nJrs := SE1->E1_VALJUR
      	_nJrs *= _nDia
      	_nJrs := Round( _nJrs, 2 )
      	_nJrs -= SE1->E1_JUROS
   		_cFil 	 := SE1->E1_FILIAL
	    _cPrf 	 := SE1->E1_PREFIXO
        _cNum 	 := SE1->E1_NUM 
        _cPar 	 := SE1->E1_PARCELA
        _cNat 	 := SE1->E1_NATUREZ
        _cCli 	 := SE1->E1_CLIENTE
        _cLoj 	 := SE1->E1_LOJA
        _cNom 	 := SE1->E1_NOMCLI
        _cVct 	 := SE1->E1_VENCTO
        _cPed 	 := SE1->E1_PEDIDO
        _cIdCnab := SE1->E1_IDCNAB // Claudino 19/05/14
         
		// add by felipe para resolver duplicidade sistema
		SE1->(dbSetOrder(1)) // Claudino 19/05/14
		If _nJrs > 0 .AND. !(SE1->(dbSeek(xFilial("SE1")+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+'JR ')))
         
  			RecLock( 'SE1', .T. )
           	
           	SE1->E1_FILIAL		:= xFilial( "SE1" )
         	SE1->E1_PREFIXO		:= _cPrf
         	SE1->E1_NUM			:= _cNum
         	SE1->E1_PARCELA		:= _cPar
         	SE1->E1_TIPO		:= 'JR '
         	SE1->E1_NATUREZ		:= _cNat
         	SE1->E1_CLIENTE		:= _cCli
         	SE1->E1_LOJA		:= _cLoj
         	SE1->E1_NOMCLI		:= _cNom
         	SE1->E1_EMISSAO		:= dDataBase
         	SE1->E1_EMIS1		:= dDataBase
         	SE1->E1_VENCTO		:= _cVct
         	SE1->E1_VENCREA		:= _cVct                                                       	
         	SE1->E1_VENCORI		:= _cVct
         	SE1->E1_VALOR		:= _nJrs
         	SE1->E1_SALDO		:= _nJrs
         	SE1->E1_VLCRUZ		:= _nJrs
         	SE1->E1_STATUS		:= 'A'
         	SE1->E1_ORIGEM		:= 'FINA040'
         	SE1->E1_FLUXO		:= 'S'
         	SE1->E1_HIST		:= 'Juros Devidos, gerado via CNAB'
         	SE1->E1_FILORIG		:= cEmpAnt
         	SE1->E1_MSFIL		:= cEmpAnt
         	SE1->E1_MSEMP		:= cEmpAnt
         	SE1->E1_SERIE		:= _cPrf
         	SE1->E1_SITUACA		:= '0'
         	SE1->E1_MOEDA		:= 1   // Claudino - 29/08/16 - I1608-1129

        	SE1->( msUnLock() ) 
        
		End
		
		SE1->(dbSetOrder(16))                  // Claudino 19/05/14
		SE1->(dbSeek(xFilial("SE1")+_cIdCnab)) // Claudino 19/05/14

	End   

End

If ! ( SE1->( Eof() ) ) .And.;
	SE5->E5_CNABOC = '07'

	If Empty( SE1->E1_HIST )
 		RecLock( 'SE1', .F. )
   		SE1->E1_HIST := 'Pagto vinculado s/cheque'
     	SE1->( msUnLock() )
   	End

End
   
RestArea(aAreaSE5) 
RestArea(aAreaSE1)  
   
Return( NIL )
