#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "RWMAKE.CH"
/*

+===========================================================================+
|Consultoria:                Q S   d o   B R A S I L                        |
+---------------------------------------------------------------------------+
|Programa   | WM330Cpo	|Autor  | Vitor Lopes        | Data |  25/06/14     |
+---------------------------------------------------------------------------+
|Descricao  | Ajuste no posicionamento da tela de monitor de serviço  		|
|           | 															    |
|           |															    |
+---------------------------------------------------------------------------+
|Uso        | MP11 - Cliente: OuroLux									    |
+---------------------------------------------------------------------------+
|Solicitante| 							       						        |
+---------------------------------------------------------------------------+
|Alteracoes | Descrição....:    											|
|           | Solicitante..:    	      									|
|           | Data.........: 			   							        |
|           | Consultor....:											    |
+===========================================================================+

*/    
User Function WM330Cpo()                                     
Local aRet := {}

AAdd(aRet,{"Cod.Serv.  "    ,"DB_SERVIC" })
AAdd(aRet,{"Desc.Tarefa"    ,'DB_DESTAR' })    
AAdd(aRet,{"Desc.Atividade" ,'DB_DESATI' }) //[Vitor Lopes 16/05/2017]
AAdd(aRet,{"Carga"          ,"DB_CARGA"  }) 
AAdd(aRet,{"Documento"      ,'DB_DOC'    }) 
AAdd(aRet,{"Produto"        ,'DB_PRODUTO'})
AAdd(aRet,{"Lote"           ,'DB_LOTECTL'})
AAdd(aRet,{"Qtde"           ,'DB_QUANT'  })
AAdd(aRet,{"End.Origem"     ,'DB_LOCALIZ'})
AAdd(aRet,{"End.Destino"    ,'DB_ENDDES' })
AAdd(aRet,{"Operador"       ,'DB_RECHUM'  }) 
AAdd(aRet,{"Recurso"        ,'DB_DESHUM' }) 
AAdd(aRet,{"Função WMS"     ,'DB_DESCFUN'})
AAdd(aRet,{"Prioridade"    	,'DB_PRIORI' }) 
AAdd(aRet,{"Data"           ,'DB_DATA'   })
AAdd(aRet,{"Hr.Ini"         ,'DB_HRINI'  })
AAdd(aRet,{"Dt.Fim"         ,'DB_DATAFIM'})
AAdd(aRet,{"Hr.Fim"         ,'DB_HRFIM'  }) 
AAdd(aRet,{"Desc.Serviço"   ,'DB_DESSER' })  


         
Return(aRet)