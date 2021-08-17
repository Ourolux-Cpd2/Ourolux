#INCLUDE 'rwmake.ch' 

User Function Canhotos()

Local aArea 	:= GetArea()
Local _aAreaSF2 := SF2->(GetArea())
Local cEmp  	:= SubStr(cNumEmp,1,2)
Local cFil  	:= SubStr(cNumEmp,3,2)


SZA->( dbSetOrder( 1 ) )
SC5->( dbSetOrder( 5 ) )

_fSC5   := xFilial( 'SC5' )
_fSZA   := xFilial( 'SZA' )
_dGet1  := dDataBase
_cGet2  := Space( 9 )
_cGet3  := Space( 3 )
oGet3   := ''
oGet2   := ''

@ 56,42 TO 270,400 DIALOG oDlg6 TITLE "Rotina de Canhotos"
@ 8,10 TO 84,170
@ 33,24 Say 'Data'
@ 33,62 Say 'Serie' 
@ 33,92 Say 'Nota Fiscal'
@ 43,24 Get _dGet1 Picture '@E 99/99/99' Size 35,8
@ 43,62 Get _cGet3 Picture '@R 999' Size 15,9  Object oGet3
@ 43,92 Get _cGet2 Picture '@R 999999999' Size 30,9 Object oGet2
@ 91,100 BMPBUTTON TYPE 1 ACTION Grava()
@ 91,139 BMPBUTTON TYPE 2 ACTION Close(oDlg6)

ACTIVATE DIALOG oDlg6 CENTERED

SZA->(dbSetOrder(1))
SC5->(dbSetOrder(5))
SF2->(dbSetOrder(1)) 

Restarea(aArea)
Restarea(_aAreaSF2)

Return()
                                 
Static Function Grava()

If !Empty(_cGet2) .And. !Empty(_cGet3)

	If (cNumEmp == '0101' .AND. !_cGet3 $ '5  .900') .Or.;
	   (cNumEmp == '0102' .AND. !_cGet3 $ '4  .900') .Or.; 
	   (cNumEmp == '0200' .AND. !_cGet3 $ '1  .900') .Or.;
	   (cNumEmp == '0104' .AND. !_cGet3 $ '7  .900')
		
		MsgInfo( 'Serie invalida!')
		
  	ElseIf ( SF2->( dbSeek( xFilial('SF2')+ _cGet2 + _cGet3, .F. ) ))
  	//ElseIf ( SC5->( dbSeek( _fSC5 + _cGet2 + _cGet3, .F. ) ) ) 
    	
    	If SF2->F2_XDTCANH <> CtoD( '  /  /  ' )
    	
    		MsgInfo( 'Canhoto já lançado!')
    	
    	ElseIf _dGet1 < SF2->F2_XDTCANH

        	MsgInfo( 'Data do canhoto menor que a emissão da nota fiscal!')

    	Else  // Grava Canhoto
    	    /*
    		If ( SZA->( dbSeek( _fSZA + SC5->C5_NUM, .F. ) ) )

      			SZA->( RecLock( "SZA", .F. ) )
      			SZA->ZA_CANHOTO := _dGet1
      			SZA->( MSUnLock() )

   			EndIf
            */
   			
   			
   			
   			//F2_FILIAL, F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA, F2_FORMUL, F2_TIPO
   			
   			If SF2->( RecLock( "SF2", .F. ) )
   				SF2->F2_XDTCANH := _dGet1
   				SF2->( MSUnLock() )
   			EndIf
   			
   			If ( SC5->( dbSeek( _fSC5 + _cGet2 + _cGet3, .F. ) ) )
   			   			
   				If SC5->( RecLock( "SC5", .F. ) )
   			
   					SC5->C5_CANHOTO := _dGet1
   					SC5->( MSUnLock() )
   				   			
   				EndIf
   				
   			EndIf
   			  			
   			_cGet2 := Space( 9 ) 
   			ObjectMethod( oGet2, "SetFocus()" )	
    	
    	EndIf
    
    Else
    
    	MsgInfo( 'Nota Fiscal não cadastrada!')
    
    EndIf

EndIf

ObjectMethod( oGet2, "SetFocus()" )

Return()