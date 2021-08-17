/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณM410FIL   บAutor  ณMicrosiga           บ Data ณ  11/12/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Function usado no chamado do menu de pedidos de venda      บฑฑ
ฑฑบ          ณ Filtrar os pedidos de vendas                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP8                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function M410FIL()

Local cVends  := ""
Local cFilPed := ""

If !U_IsAdm() 

	If Alltrim(GetAdvFVal("SA3","A3_COD",xFilial("SA3")+Alltrim(RetCodUsr()),7,"")) $ '199998.199978' // SAC, PRODUTOS 
		cVends := '199998' + "/" + '199978'
		cFilPed := "C5_TIPO <> 'T' .And. SC5->C5_VEND1 $ '"+cVends+"'" "
	ElseIf !U_IsFree() 
		U_ListaVnd(@cVends)
		cFilPed := "C5_TIPO <> 'T' .And. SC5->C5_VEND1 $ '"+cVends+"'" "
    Else
		cFilPed := "C5_TIPO <> 'T' "
	EndIf
	
	SC5->(DbClearFilter())
	SC5->( dbSetFilter( { || &cFilPed }, cFilPed ) )
	
	/*
	SC5->(DbSetFilter({|| SC5->C5_VEND1 $ cVends },;
						  "SC5->C5_VEND1 $ '"+cVends+"'" ))
    */    

EndIf

MATA410()
Return(.T.)