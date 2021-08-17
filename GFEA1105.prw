#INCLUDE "PROTHEUS.CH"

/*--------------------------------------------------------|
| Autor | Claudino Domingues              | Data 21/08/15 | 
|---------------------------------------------------------|
| Função: GFEA1105                                        |
|---------------------------------------------------------|
| Utilizada para alterar a quantidade de volumes dos      |
| itens da nota fiscal (registro 314 do arquivo de        |
| exportação de notas fiscais EDI).                       |
----------------------------------------------------------*/

User Function GFEA1105()

	Local _nVolIte := 0
	
	DbSelectArea("SB1")
	DbSetOrder(1)
	If DbSeek(xFilial("SB1")+GW8->GW8_ITEM)
		_nVolIte := GW8->GW8_QTDE / SB1->B1_CONV         	
	EndIf
	
Return _nVolIte