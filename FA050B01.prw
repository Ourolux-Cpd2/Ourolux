#INCLUDE "PROTHEUS.CH"

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±± FA050B01  ³ Autor: Claudino Pereira Domingues           ³ Data 21/10/14 ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±± Descricao ³ Ponto de entrada executado após a confirmação da exclusão e ±±
±±           ³ antes da própria exclusão de contabilização.                ±±  
±±           ³ Excluir o PC (SC7) na exclusao do CP do titulo da           ±±
±±           ³ comissao                                                    ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/

User Function FA050B01()
    
    Local _cQry    := ""
	Local _aCabPC  := {} 
	Local _aItemPC := {}
	Local _cTitPC  := SE2->E2_PREFIXO + SE2->E2_NUM + SE2->E2_PARCELA + SE2->E2_TIPO + SE2->E2_FORNECE + SE2->E2_LOJA
	
	Private lMSHelpAuto := .T.
	Private lMsErroAuto := .F.
	
	_cQry := " SELECT  
	_cQry += " 		* "
	_cQry += " FROM " 
	_cQry +=		RetSqlName("SC7") + " SC7 "
	_cQry += " WHERE "
	_cQry += "		SC7.D_E_L_E_T_ = ' ' "
	_cQry += "		AND SC7.C7_XTITPAI = '" + _cTitPC + "' "
	
	_cQry := ChangeQuery(_cQry)
	
	If Select("TITPC") > 0
		DbSelectArea("TITPC")
		TITPC->(DbCloseArea())
	EndIf
			
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),"TITPC",.T.,.T.)
	
	While TITPC->(!Eof())
		If Alltrim(TITPC->C7_PRODUTO) == "COMISSAO"
			_aCabPC	:=	{{"C7_NUM"	  ,TITPC->C7_NUM	 ,Nil},;
						{"C7_EMISSAO" ,TITPC->C7_EMISSAO ,Nil},; 
						{"C7_FORNECE" ,TITPC->C7_FORNECE ,Nil},;
						{"C7_LOJA"	  ,TITPC->C7_LOJA	 ,Nil},;
						{"C7_CC"	  ,TITPC->C7_CC      ,Nil},;     
						{"C7_COND"	  ,TITPC->C7_COND	 ,Nil},; 
						{"C7_CONTATO" ,TITPC->C7_CONTATO ,Nil},;
						{"C7_FILENT"  ,TITPC->C7_FILENT	 ,Nil}}
	
			_aItemPC :=	{{"C7_ITEM"	  ,TITPC->C7_ITEM	 ,Nil},;
						{"C7_PRODUTO" ,TITPC->C7_PRODUTO ,Nil},;
						{"C7_UM"	  ,TITPC->C7_UM		 ,Nil},;   
						{"C7_SEGUM"	  ,TITPC->C7_SEGUM	 ,Nil},;   
						{"C7_QUANT"	  ,TITPC->C7_QUANT 	 ,Nil},;
						{"C7_PRECO"	  ,TITPC->C7_PRECO	 ,Nil},;
						{"C7_OBS"	  ,TITPC->C7_OBS	 ,Nil},;
						{"C7_TES"	  ,TITPC->C7_TES	 ,Nil},;                     
						{"C7_FLUXO"	  ,TITPC->C7_FLUXO	 ,Nil},;
						{"C7_LOCAL"	  ,TITPC->C7_LOCAL	 ,Nil},;
						{"C7_DATPRF"  ,TITPC->C7_DATPRF	 ,Nil},;
						{"C7_XTITPAI" ,TITPC->C7_XTITPAI ,Nil}}                          
	                                                            
	        /*  Excluir o pedido de compras (SC7) ref o CP da comissao  */                                         
			MsExecAuto( {|v,x,y,z| MATA120(v,x,y,z)},1,_aCabPC,{_aItemPC},5)  
		
			If lMsErroAuto
				MostraErro()
	   			DisarmTransaction()
			EndIf
		EndIf
		
		TITPC->(dBSkip())		
	EndDo
	
	If Select("TITPC") > 0
		DbSelectArea("TITPC")
		TITPC->(DbCloseArea())
	EndIf
		    	    
Return