#Include "rwmake.ch"

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Excmg01
Gera��o de planilha formato Excel do relat�rio MEGA001 - 

@type 		Function
@author 	Maur�cio Aureliano
@since 		09/04/2018
@version 	P12

@obs		Chamado: I1803-1805 - Op��o exportar excel - relat�rio Espec�fico	
@obs		Baseada na rotina "Excmg21.prw" - Autor: Andre Bagatini - Data: 08/07/2011 
 
@return nil
/*/    
//-------------------------------------------------------------------------------------
User Function Excmg01(cTexto,aCabec,aDados)

	Local aCabec1:= {}
	Local aDados2:= {}
	Local aTemp	 := {}

	If !ApOleClient("MSExcel") // testa a intera��o com o excel.
		MsgAlert("Microsoft Excel n�o instalado!")
		Return Nil
	EndIf

	For x:= 1 to Len(aCabec)

		AADD(aCabec1,aCabec[x][1])

	Next x

	y:= 1

	For x:= 1 to Len(aDados)

		While  x <= (11 * y)
			AADD(aTemp,aDados[x])
			x++
		End
		If x > (11 * y)
			AADD(aDados2,aTemp)
			aTemp := {}
			y++
		EndIf
    // 
		x--
	Next x
                                     
	DlgToExcel({ {"ARRAY", cTexto, aCabec1,aDados2} }) // utiliza a fun��o

Return Nil