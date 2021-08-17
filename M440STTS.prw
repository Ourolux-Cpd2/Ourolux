#include 'protheus.ch'
#include 'parmtype.ch'

//--------------------------------------------------------------------
/*/{Protheus.doc} M440STTS
//TODO Descrição auto-gerada.
@author Caio Menezes
@since 05/02/2020
@version 1.0
@type function
/*/
//--------------------------------------------------------------------

User Function M440STTS()

Local aArea  := GetArea() 

    If FindFunction("U_GeraPR1")
    	
    	U_GeraPR1("LIBERACAO")
    	
    Endif
	
	RestArea(aArea)
	
Return(.T.)