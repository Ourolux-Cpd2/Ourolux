#include "Protheus.ch"
/*
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????ͻ??
???Programa  ?M103FILB  ?Autor  ?Eletromega          ? Data ?  05/06/15   ???
?????????????????????????????????????????????????????????????????????????͹??
???Desc.     ? Ponto de Entrada: M103FILB                                 ???
???          ? PROGRAMA: MATA103                                          ???
???          ? Permite filtrar os registros que ser?o exibidos na Mbrowse ???
???                         									          ???
?????????????????????????????????????????????????????????????????????????͹??
???Uso       ? MP                                                         ???
?????????????????????????????????????????????????????????????????????????ͼ??
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????????
*/
User Function M103FILB  

Local cRet:= ""
Local cNomeUsr  := Upper(Rtrim(cUserName))                             

If cNomeUsr $ 'HELPLOG' 
	cRet += " F1_TIPO = 'D' " 
EndIf

Return cRet