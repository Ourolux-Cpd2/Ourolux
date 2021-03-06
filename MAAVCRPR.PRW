/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MAAVCRPR    �Autor  �Eletromega        � Data �  04/27/07   ���
�������������������������������������������������������������������������͹��
���Desc.     � Este ponto de entrada pertence � rotina de avaliza��o de   ���
���			 � cr�dito de clientes, MaAvalCred() � FATXFUN(). Ele permite ���
���			 � que, ap�s a avalia��o padr�o do sistema, o usu�rio possa   ���
���			 � fazer a sua pr�pria. (Chamado por item)                    ���
���          � Bloquear a libera�a de credito para pedidos com condi�ao   ���
���          � de pagamento: A VISTA E DEPOSITO BANCARIO                  ���
�������������������������������������������������������������������������͹��
��� Parametros� Argumento												  ���
��� PARAMIXB : Array 									                  ���
��� ParamIxb[1]=C�digo do cliente									      ���
��� ParamIxb[2]=C�digo da filial									      ���
��� ParamIxb[3]=Valor da venda									          ���
��� ParamIxb[4]=Moeda da venda									          ���
��� ParamIxb[5]=Considera acumulados de Pedido de Venda do SA1			  ���						 
��� ParamIxb[6]=Tipo de cr�dito (�L� - C�digo cliente + Filial;           ���
���								 �C� - c�digo do cliente)				  ���
��� ParamIxb[7]=Indica se o credito ser� liberado ( L�gico )              ���
��� ParamIxb[8]=Indica o c�digo de bloqueio do credito ( Caracter )		  ���							                         
���          �                            								  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
��� Retorno   � L�gico 													  ���
��� .T. - cr�dito aprovado                                                ���
��� .F. - cr�dito n�o aprovado.                                           ���
���                                                                       ���
�������������������������������������������������������������������������͹��
���Uso       � AP8                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
