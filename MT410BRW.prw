#INCLUDE "PROTHEUS.CH"

User Function MT410BRW()   

	FWMsgRun(,{|| CursorWait(),ApllyFil(),CursorArrow()},,"Aplicando Filtros..." )	

	//SetKey(VK_F2,{|| U_PrcXCom()})
	                          
Return
       

Static Function ApllyFil()

	Local aArea		:= GetArea()
	Local aRet		:= {}
	Local aIndexSC5 := {}
	Local cVends	:= ""
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Seleciona vendedores³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
	If !(U_IsAdm()) .And. !U_IsFree()  // membros deste grupo nao tem filtro
		
		U_ListaVnd(@cVends)
		
		cFiltro		:= "SC5->C5_VEND1 $ '"+cVends+"'"  
		
		bFiltraBrw	:= {|| FilBrowse("SC5",@aIndexSC5,@cFiltro)}
		Eval(bFiltraBrw)
	
	EndIf
	
	RestArea(aArea)
	
Return()
