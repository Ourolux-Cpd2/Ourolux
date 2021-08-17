#Include "Protheus.ch"

//_________________________________________________________________________
/*/{Protheus.doc} FITMOur01
Disponibiliza e obriga o preenchimento dos campos de pedido de compras
na rotina padrao de NF Conhecimento de frete (D1_PEDIDO e D1_ITEMPC);

@author		Icaro Queiroz
@since		10 de Fevereiro de 2015
@version	P11
@owner		FIT Gestao & Tecnologia, solicitado por Ourolux
/*/
//_________________________________________________________________________
User Function FITMOur01()
Local aArea	:= GetArea()
Local nI	:= 0
Local aCpx	:= { "D1_PEDIDO" }

dbSelectArea( "SX3" )
SX3->( dbSetOrder( 2 ) )

For nI := 1 To Len( aCpx )
	If SX3->( MsSeek( aCpx[nI] ) )
		If SX3->X3_PROPRI <> "U"
			RecLock( "SX3", .F. )
				Replace X3_PROPRI With "U"
			SX3->( MsUnLock() )
		EndIf
	EndIf
Next nI

RestArea( aArea )

Return( Nil )


//_________________________________________________________________________
/*/{Protheus.doc} FITXOur01
Faz filtragem para a consulta padrao SC7;

@author		Icaro Queiroz
@since		10 de Fevereiro de 2015
@version	P11
@owner		FIT Gestao & Tecnologia, solicitado por Ourolux
/*/
//_________________________________________________________________________
User Function FITXOur01()
Local aArea		:= GetArea()
Local nPosCod	:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "D1_COD" })
Local cChave	:= ""

If FunName() == 'MATA116'
	cChave := "SC7->C7_CONAPRO == 'L' .And. SC7->C7_ENCER <> 'E' .And. SC7->C7_FORNECE == '" + cA100For + "' .And. SC7->C7_PRODUTO = '" + aCols[ n ][ nPosCod ] + "' "
EndIf

RestArea( aArea )

Return &( cChave )