#INCLUDE "PROTHEUS.CH"

/*--------------------------------------------------------|
| Autor | Claudino Domingues              | Data 21/08/15 | 
|---------------------------------------------------------|
| Função: GFEA1104                                        |
|---------------------------------------------------------|
| Utilizada para alterar a quantidade de volumes da nota  |
| fiscal (registro 313 e 318 do arquivo de exportação de  |
| notas fiscais EDI).                                     |
----------------------------------------------------------*/

User Function GFEA1104()

	Local _nVolTot := 0
    Local _cChvBus := GW1->GW1_FILIAL+GW1->GW1_CDTPDC+GW1->GW1_EMISDC+GW1->GW1_SERDC+GW1->GW1_NRDC
    
    DbSelectArea("GW8")
    DbSetOrder(1)
    If DbSeek(_cChvBus)
		While GW8->(!Eof()) .And. _cChvBus == GW8->GW8_FILIAL+GW8->GW8_CDTPDC+GW8->GW8_EMISDC+GW8->GW8_SERDC+GW8->GW8_NRDC
			DbSelectArea("SB1")
			DbSetOrder(1)
			If DbSeek(xFilial("SB1")+GW8->GW8_ITEM)
				_nVolTot += GW8->GW8_QTDE / SB1->B1_CONV         	
			EndIf
    		GW8->(DbSkip())
    	EndDo
    EndIf

Return _nVolTot