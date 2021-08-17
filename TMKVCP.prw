#INCLUDE "protheus.ch"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �TMKVCP    �Autor  �Norbert Waage Junior� Data �  15/03/06   ���
�������������������������������������������������������������������������͹��
���Descricao �P.E. utilizado para validar a condicao de pgto selecionada. ���
�������������������������������������������������������������������������͹��
���Parametros�cCodTransp - Codigo da Transportadora                       ���
���          �oCodTransp - Objeto a ser atualizado com o cod da transp.   ���
���          �cTransp - Descric�o da transportadora                       ���
���          �oTransp - Objeto a ser atualizado com o cod da transp       ���
���          �cCob - Endereco de cobranca                                 ���
���          �oCob - Objeto que sera atualizado com o end. de Cobranca    ���
���          �cEnt - Endereco de entrega                                  ���
���          �oEnt - Objeto que sera atualizado com o endereco de entrega ���
���          �cCidadeC - Cidade para a cobranca                           ���
���          �oCidadeC - Objeto que sera atualizado com a cidade de cobr. ���
���          �cCepC - CEP para a cobranca                                 ���
���          �oCepC - Objeto que sera atualizado com o bairro de cobranca ���
���          �cUfC - Estado para a cobranca                               ���
���          �oUfC - Objeto que sera atualizado com o estado para a cobr. ���
���          �cBairroE - Bairro de entrega                                ���
���          �oBairroE - Objeto que sera atualizado com o bairro de entr. ���
���          �cBairroC - Bairro de cobranca                               ���
���          �oBairroC - Objeto que sera atualizado com o bairro de cobr. ���
���          �cCidadeE - Cidade de Entrega                                ���
���          �oCidadeE - Obj. a ser atualizado com a Cidade para a entrega���
���          �cCepE - Cep para entrega                                    ���
���          �oCepE - Objeto que sera atualizado com o CEP para entrega   ���
���          �cUfE - Estado para a entrega                                ���
���          �oUfE - Objeto que sera atualizado com o estado de entrega   ���
���          �nOpc - Opc�o selecionada                                    ���
���          �cNumTlv - Numero do atendimento Televendas                  ���
���          �cCliente - Codigo do Cliente                                ���
���          �cLoja - Loja do cliente                                     ���
���          �cCodPagto - Codigo da condic�o de pagamento escolhida       ���
���          �aParcelas - Array com as parcelas montadas atraves da       ���
���          �            condicao de pagamento escolhida.                ���
�������������������������������������������������������������������������͹��
���Uso       �Eletromega                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function TMKVCP(cCodTransp	,oCodTransp	,cTransp	,oTransp	,;
					cCob		,oCob		,cEnt		,oEnt		,;
					cCidadeC	,oCidadeC	,cCepC		,oCepC		,;
					cUfC		,oUfC		,cBairroE	,oBairroE	,;
					cBairroC	,oBairroC	,cCidadeE	,oCidadeE	,;
					cCepE		,oCepE		,cUfE		,oUfE		,;
					nOpc		,cNumTlv	,cCliente	,cLoja		,;
					cCodPagto	,aParcelas)

Local lRet 	   		:= .T.
Local lEnt			:= .T.

/*  Removed 07.08.09
If (cCodTransp $ '900000')
		M->UA_TIPOENT := '2'
ElseIf (cCodTransp $ '99    ')
		M->UA_TIPOENT := '1'
EndIf	
*/

M->UA_TIPOENT := '2'   // Added on 07.08.09

lEnt := VldEndEnt(cEnt,cBairroE,cCidadeE,cCepE,cUfE)

If !lEnt
	lRet := .F.
	ApMsgInfo("Endre�o da entrega invalido!","Entrega")
EndIf


/*

If Empty (cCodTransp)  
   
	lRet := .F.
	ApMsgInfo("Transportadora n�o permitida!","Vazio")

Else // If Empty(cCodPagto) .And. (INCLUI .Or. ALTERA)
	
	If (cCodTransp $ '900000')
		M->UA_TIPOENT := '2'
	ElseIf (cCodTransp $ '99    ')
		M->UA_TIPOENT := '1'
	EndIf	
	
EndIf

*/

Return lRet


Static Function VldEndEnt(cEnt,cBairroE,cCidadeE,cCepE,cUfE)
Local lRet:= .T.
	
	If 	Empty (cEnt)  		.OR. ;
	   	Empty (cBairroE)	.OR. ;
	   	Empty (cCidadeE)    .OR. ;
	   	Empty (cCepE)    	.OR. ;
	   	Empty (cUfE)
	
		lRet:= .F.
	ElseIf 	Substr( cEnt, 1, 1 ) 		$ '.'  .OR. ;
			Substr( cBairroE, 1, 1 )	$ '.'  .OR. ; 
			Substr( cCidadeE, 1, 1 )	$ '.'
			
		lRet:= .F.  
	EndIf 

Return(lRet)

/*
cCodTransp	,oCodTransp	,cTransp	,oTransp	,;
					cCob		,oCob		,cEnt		,oEnt		,;
					cCidadeC	,oCidadeC	,cCepC		,oCepC		,;
					cUfC		,oUfC		,cBairroE	,oBairroE	,;
					cBairroC	,oBairroC	,cCidadeE	,oCidadeE	,;
					cCepE		,oCepE		,cUfE		,oUfE		,;
					nOpc		,cNumTlv	,cCliente	,cLoja		,;
					cCodPagto	,aParcelas)
*/
           

