#INCLUDE "PROTHEUS.CH"
*---------------------------------------------------*
USER FUNCTION SvValQtd(nQuantidade,__cAlias,_lAjusta)
*---------------------------------------------------*
local __aOrdem:= {}           
//Local cVar := Alltrim(ReadVar())
//Local lRet := .T.                   
Local __nQtdEmba:= 0      
// Roberto Souza - 07/07/2017     
// Validação para considerar Importação
Local lVldImp	:= .T. 
Local cDepVldImp:= GetMv("FS_VLSCIMP",,"000000025")
// ------

default __cAlias:= "SC1"
default _lAjusta:= .t.

if __cAlias == "SC1"
	nPRODUTO  := aScan(aHeader,{|x| AllTrim(x[2])=="C1_PRODUTO"})
	nQUANT    := aScan(aHeader,{|x| AllTrim(x[2])=="C1_QUANT"})
	nxQTDEM1  := aScan(aHeader,{|x| AllTrim(x[2])=="C1_XQTDEM1"})
	nxCUBAGE  := aScan(aHeader,{|x| AllTrim(x[2])=="C1_XCUBAGE"})
	nPosImp   := aScan(aHeader,{|x| AllTrim(x[2])=="C1_IMPORT"})
	nPosPB    := aScan(aHeader,{|x| AllTrim(x[2])=="C1_XPESBRU"})

    cProduto  := acols[n,nPRODUTO]
	
	// Verifica se o departamento da SC utiliza as validações de importação
	lVldImp   := (_cDepSC1 $ cDepVldImp )

elseif __cAlias == "SW3" 
    cProduto  := M->W3_COD_I
elseif __cAlias == "WK3"
    cProduto  :=Work->WKCOD_I
elseif __cAlias == "SW6"
    cProduto := Work->WKCOD_I
endif
__aOrdem:= SaveOrd("SB5")

If lVldImp

	SB1->(DBSETORDER(1)) 
	
	if ! SB1->(dbseek(xfilial("SB1")+cProduto))
	   msginfo("Atenção! Produto " + AllTrim(cProduto) + " não encontrado no cadastro de Produtos")
	   return .f.
	endif
/*	                                         
	If SB1->B1_IMPORT <> "S"
	   msginfo("Atenção! Produto " + AllTrim(cProduto) + " não está cadastrado como produto importado")
	   RETURN .T.
	endif                  
*/
	// Tratamento para não alterar o Campo B1_IMPORT
	If SB1->B1_IMPORT <> "S" .And. !(SB1->B1_ORIGEM $ "1|2")
	   Msginfo("Atenção! Produto " + AllTrim(cProduto) + " não está cadastrado como produto importado.")
	   RETURN .T.
	ElseIf __cAlias == "SC1"
    	aCols[n][nPosImp] := "S"
	endif                  

	                  
	SB5->(DBSETORDER(1))
	if ! SB5->(dbseek(xfilial("SB5")+cProduto))
	   msginfo("Atenção! Dados complementares do Produto " + AllTrim(cProduto) + " não encontrado no cadastro de complemento de Produtos")
	   return .f.                                                                              
	endif
	
	if empty(SB5->B5_QE1)
	   msginfo("Atenção! A quantidade de itens por embalagem do produto " + AllTrim(cProduto) + " não informada no cadastro de complemento de Produtos")
	   return .f.
	endif
	
	EE5->(DBSETORDER(1))
	IF ! EE5->(DBSEEK(xfilial("EE5")+ SB5->B5_EMB1))
	   msginfo("Atenção! A unidade de medida.: " + SB5->B5_EMB1 + " não encontrado no cadastro de embalagens!")
	   return .f.
	ENDIF
	IF SB5->B5_QE1 == 0
	   msginfo("Atenção! A quantidade por embalagem do produto " + AllTrim(cProduto) + " é zero")
	ENDIF
	IF EE5->EE5_CCOM == 0
	   msginfo("Atenção! O comprimento da embalagem " + SB5->B5_EMB1 + " está zerado no cadstro")
	ENDIF
	IF EE5->EE5_LLARG == 0
	   msginfo("Atenção! A largura  da embalagem " + SB5->B5_EMB1 + " está zeradoa no cadstro")
	ENDIF
	IF EE5->EE5_HALT == 0
	   msginfo("Atenção! A altura da embalagem " + SB5->B5_EMB1 + " está zerada no cadstro")
	ENDIF
	
	__nQtdEmba:=nquantidade/SB5->B5_QE1
	lAjustouSW:=.F.
	if __nQtdEmba - INT(__nQtdEmba) > 0.and. __cAlias <> "WK3" .and. _lAjusta
	   if  MsgYesNo("A quantidade digitada não é multipla da quantidade por embalagem, deseja ajuste automático?","Validação Quantidade")
	       nquantidade:= (int(nquantidade/SB5->B5_QE1)+1) * SB5->B5_QE1 
	       /*
	       if __cAlias == "SW3" .and. nquantidade > (M->W3_SEM_PED + M->W3_QTDE)
	          msginfo("A quantidade ajustada.: " + tran(nquantidade,'@E 999,999,999.999999') + ' é maior que a quantidade disponivel para esse pedido.: ' +;
	          tran(M->W3_SEM_PED + M->W3_QTDE,'@E 999,999,999.999999'))
	          return .f.
	       endif
	       */
	
	       if __cAlias == "SW3" .or. __cAlias == "SW6"
	         lAjustouSw:=.t.
	       endif
	   endif
	endif
	__nQtdEmba:= int( nquantidade / SB5->B5_QE1 )
	__nCubagem:= __nQtdEmba * (EE5->EE5_CCOM * EE5->EE5_LLARG * EE5->EE5_HALT)

	
	IF __cAlias == "SC1"
		aCols[n,nQUANT]  := nquantidade
		aCols[n,nXQTDEM1]:= __nQtdEmba                        
		aCols[n,nXCUBAGE]:= __nCubagem
		aCols[n,nPosPB]  := nQuantidade * SB1->B1_PESBRU
	ELSEIF __cAlias == "SW3"
	    M->W3_XQTDEM1:= __nQtdEmba    // quantidade de embalagens
	    M->W3_XCUBAGE:= __nCubagem    // Cubagem do item   
	    M->W3_XQE1:= SB5->B5_QE1
	    if lAjustouSW
	       M->W3_QTDE:= nquantidade
	    endif
	ELSEIF __cAlias == "WK3"
	    Work->W3_XQE1    := SB5->B5_QE1
	    Work->W3_XQTDEM1 := __nQtdEmba
	    Work->W3_XCUBAGE := __nCubagem
	ELSEIF __cAlias == "SW6"
	    Work->WK_XQE1    := SB5->B5_QE1
	    Work->WK_XQTDEM1 := __nQtdEmba
	    Work->WK_XCUBAGE := __nCubagem
	    if lAjustouSW .or. ! _lAjusta
	       M->TSALDO_Q:= nquantidade
	    endif
	    __VeCubW7(_lAjusta,cProduto)
	ENDIF
	
EndIf

return .t.
     


*------------------------------*
USER FUNCTION SvCalCub(__cAlias)
*------------------------------*
//Local nQUANT    := if(__cAlias=="SC1",aScan(aHeader,{|x| AllTrim(x[2])=="C1_QUANT"}),NIL)
//Local nxQTDEM1  := if(__cAlias=="SC1",aScan(aHeader,{|x| AllTrim(x[2])=="C1_XQTDEM1"}),NIL)
Local nxCUBAGE  := if(__cAlias=="SC1",aScan(aHeader,{|x| AllTrim(x[2])=="C1_XCUBAGE"}),NIL)
Local __nTotal  := 0
Local wind		:= 0

Default __cAlias:= "SC1"

IF __cAlias == "SC1"
	For wind:= 1 to len(aCols)
	    __nTotal+= aCols[wind,nxCUBAGE] 
	next
	
	msginfo("Total de Volume Cubado.: " + transf(__nTotal,"@E 999,999,999.99999"))   
	                                
	_nVolCubado:= __nTotal
ELSEIF __cAlias == "SW2" .OR. __cAlias =="SW6" 
    CalcCubagem(__cAlias)        
ENDIF	                 

return


*-------------------------------------------*
Static Function __VeCubW7(_lAjusta,cProduto)
*------------------------------------------*
Local oDlgTotPO 
Local bOk :=     {||oDlgTotPO:End()}    
Local bCancel := {||oDlgTotPO:End()}      

Define MsDialog oDlgTotPO Title "Volume Cubado do Produto " + if(_lAjusta,SW7->W7_COD_I,cProduto) From 20,30 To 32,80 of oMainWnd 
    @01,10 Say "Quantidade ajustada......: " + trans(tsaldo_q        ,x3picture("W7_QTDE"))              of oDlgTotPO Pixel 
    @21,10 Say "Quantidade por embalagem.: " + trans(work->wk_xqe1   ,x3picture("W7_XQE1"))         of oDlgTotPO Pixel 
    @41,10 Say "Quantidade de embalagens.: " + trans(work->wk_xqtdem1,x3picture("W7_XQTDEM1"))   of oDlgTotPO Pixel 
    @61,10 Say "Cubagem do Item..........: " + trans(work->wk_xcubage,x3picture("W7_XCUBAGE"))   of oDlgTotPO Pixel 
Activate MsDialog oDlgTotPO on init EnchoiceBar(oDlgTotPO,bOk,bCancel) Centered

return



*------------------------------------*
Static Function CalcCubagem(__cAlias) 
*------------------------------------*
Local oDlgTotPO 

Local bOk :=     {||oDlgTotPO:End()}    
Local bCancel := {||oDlgTotPO:End()}

Local _PictVol := "@E 999,999,999.99999" 
Local _PictPO   := ALLTRIM(X3PICTURE("W2_PO_NUM")) 
//Local cPictFob    := ALLTRIM(X3Picture("W2_FOB_TOT"))
//Local cPictPeso   := ALLTRIM(X3Picture("W2_PESO_B"))
Local nTotalCubado:= 0
Local _PictHAWB   := ALLTRIM(X3PICTURE("W6_HAWB")) 
Local _nSalvaRecno:= 0                        

Work->(DbGoTop())    
While Work->(!EOF())
   If Work->WKFLAGWIN == cMarca                                                                  
      IF __cAlias=="SW3" .or. __cAlias=="SW2"
         If empty(Work->W3_XCUBAGE)
            u_SvValQtd(Work->WKQTDE,"WK3",.f.) 
         endif            
         _nSalvaRecno:= SW3->(RECNO())
         SW3->(DBGOTO(Work->WKREC_SW3))
         if EMPTY(SW3->W3_XCUBAGE)
            Work->WK_ALTEROU := .T.
         endif    
         SW3->(DBGOTO(_nSalvaRecno))
         nTotalCubado+= Work->W3_XCUBAGE
      ELSE   
         If empty(Work->WK_XCUBAGE)  
            u_SvValQtd(Work->WKQTDE,"SW6",.f.)            
         endif
         _nSalvaRecno:= SW7->(RECNO())
         SW7->(DBGOTO(Work->WKRECNO_ID))
         if EMPTY(SW7->W7_XCUBAGE)
            Work->WK_ALTEROU := .T.
         endif    
         SW7->(DBGOTO(_nSalvaRecno))
         nTotalCubado+= Work->WK_XCUBAGE
      ENDIF
   EndIf
   Work->(DbSkip())
EndDo
Work->(DbGoTop()) 


Define MsDialog oDlgTotPO Title "Volume Cubado Total" From 20,30 To 32,80 of oMainWnd 

 if __cAlias == "SW2" 
    @25,10 Say "Pedido"            of oDlgTotPO Pixel 
 elseif __cAlias == "SW6"
    @25,10 Say "Processo"            of oDlgTotPO Pixel 
 endif

 @45,10 Say "Cubagem Total"     of oDlgTotPO Pixel 

 if __cAlias == "SW2" 
    @25,48 MSGET M->W2_PO_NUM  WHEN .F.    PICT _PictPO    Size 60,8 of oDlgTotPO Pixel //"No. PO"
 elseif __cAlias == "SW6"
    @25,48 MSGET M->W6_HAWB    WHEN .F.   PICT _PictHAWB    Size 60,8 of oDlgTotPO Pixel //"No. Processo"
 endif 

 @45,48 MSGET nTotalCubagem   WHEN .F.   PICT _PictVol   Size 60,8 of oDlgTotPO Pixel //"Total PO"
                                      
Activate MsDialog oDlgTotPO on init EnchoiceBar(oDlgTotPO,bOk,bCancel) Centered

if __cAlias == "SW2"                   
   M->W2_MT3:= nTotalCubagem                                         
   
elseif __cAlias == "SW6"
   M->W6_MT3:= nTotalCubagem
endif 

Return Nil

