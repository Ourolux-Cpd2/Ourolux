/*
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????ͻ??
???Programa  ? MT261TDOK ?Autor  ?Eletromega         ? Data ?  07/01/05   ???
?????????????????????????????????????????????????????????????????????????͹??
???Desc.     ? Ponto de Entrada :  Dispara o Workflow naTransfer?ncia do  ???
???          ? Estoque 				                                      ???
?????????????????????????????????????????????????????????????????????????͹??
???Uso       ? AP6 														  ???
???Esse ponto de entrada est? localizado na fun??o A520Dele(). 			  ???
???? chamado Ap?s a grava??o dos Dados									  ???
?????????????????????????????????????????????????????????????????????????ͼ??
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????????
*/
#include 'rwmake.ch'
#include "TbiConn.ch"   

User Function MT261TDOK()   

Private _nTipo := 1

	U_HtmTrans(_nTipo)
	
Return

