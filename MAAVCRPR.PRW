/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MAAVCRPR    ºAutor  ³Eletromega        º Data ³  04/27/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Este ponto de entrada pertence à rotina de avalização de   º±±
±±º			 ³ crédito de clientes, MaAvalCred() – FATXFUN(). Ele permite º±±
±±º			 ³ que, após a avaliação padrão do sistema, o usuário possa   º±±
±±º			 ³ fazer a sua própria. (Chamado por item)                    º±±
±±º          ³ Bloquear a liberaça de credito para pedidos com condiçao   º±±
±±º          ³ de pagamento: A VISTA E DEPOSITO BANCARIO                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Parametros³ Argumento												  º±±
±±º PARAMIXB : Array 									                  º±±
±±º ParamIxb[1]=Código do cliente									      º±±
±±º ParamIxb[2]=Código da filial									      º±±
±±º ParamIxb[3]=Valor da venda									          º±±
±±º ParamIxb[4]=Moeda da venda									          º±±
±±º ParamIxb[5]=Considera acumulados de Pedido de Venda do SA1			  º±±						 
±±º ParamIxb[6]=Tipo de crédito (“L” - Código cliente + Filial;           º±±
±±º								 “C” - código do cliente)				  º±±
±±º ParamIxb[7]=Indica se o credito será liberado ( Lógico )              º±±
±±º ParamIxb[8]=Indica o código de bloqueio do credito ( Caracter )		  º±±							                         
±±º          ³                            								  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Retorno   ³ Lógico 													  º±±
±±º .T. - crédito aprovado                                                º±±
±±º .F. - crédito não aprovado.                                           º±±
±±º                                                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User function MAAVCRPR()

Local lRet := ParamIxb[7]  

If IsInCallStack("U_INTRJ")
	lRet := .T.

ElseIf SC5->C5_TIPO == 'N' 
    
    If cFilAnt == "04"  
		
		If !Empty(SC5->C5_XNUMTRF)
			lRet := .T.
		EndIf
		
	Else
		 
		If SA1->A1_RISCO $ [DE] .Or.;
   			SA1->A1_SalDup > SA1->A1_LC
   		
   			lRet := .F.
   		
   		EndIf
   		
   		If lRet .And. !Empty (SA1->A1_ULTCOM)
   			
   			If (dDatabase - 180) > SA1->A1_ULTCOM  //If (dDatabase - 120) > SA1->A1_ULTCOM 
   				lRet := .F.
   			EndIf   		
   		
   		EndIf         		
	
		If lRet .And. ( SC5->C5_CONDPAG $ '000.001' .OR. !(ALLTRIM (SC5->C5_CDPG) $ 'BOLETO.BOL') )
	   
	   		lRet := .F. 
	
		EndIf
	
	EndIf  

EndIf

If !lRet
	Reclock("SC5",.F.)
	SC5->C5_XDTBLQ := dDatabase
	SC5->(MsUnlock())
EndIf

Return (lRet)
