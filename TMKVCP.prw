#INCLUDE "protheus.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMKVCP    ºAutor  ³Norbert Waage Juniorº Data ³  15/03/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³P.E. utilizado para validar a condicao de pgto selecionada. º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³cCodTransp - Codigo da Transportadora                       º±±
±±º          ³oCodTransp - Objeto a ser atualizado com o cod da transp.   º±±
±±º          ³cTransp - Descricão da transportadora                       º±±
±±º          ³oTransp - Objeto a ser atualizado com o cod da transp       º±±
±±º          ³cCob - Endereco de cobranca                                 º±±
±±º          ³oCob - Objeto que sera atualizado com o end. de Cobranca    º±±
±±º          ³cEnt - Endereco de entrega                                  º±±
±±º          ³oEnt - Objeto que sera atualizado com o endereco de entrega º±±
±±º          ³cCidadeC - Cidade para a cobranca                           º±±
±±º          ³oCidadeC - Objeto que sera atualizado com a cidade de cobr. º±±
±±º          ³cCepC - CEP para a cobranca                                 º±±
±±º          ³oCepC - Objeto que sera atualizado com o bairro de cobranca º±±
±±º          ³cUfC - Estado para a cobranca                               º±±
±±º          ³oUfC - Objeto que sera atualizado com o estado para a cobr. º±±
±±º          ³cBairroE - Bairro de entrega                                º±±
±±º          ³oBairroE - Objeto que sera atualizado com o bairro de entr. º±±
±±º          ³cBairroC - Bairro de cobranca                               º±±
±±º          ³oBairroC - Objeto que sera atualizado com o bairro de cobr. º±±
±±º          ³cCidadeE - Cidade de Entrega                                º±±
±±º          ³oCidadeE - Obj. a ser atualizado com a Cidade para a entregaº±±
±±º          ³cCepE - Cep para entrega                                    º±±
±±º          ³oCepE - Objeto que sera atualizado com o CEP para entrega   º±±
±±º          ³cUfE - Estado para a entrega                                º±±
±±º          ³oUfE - Objeto que sera atualizado com o estado de entrega   º±±
±±º          ³nOpc - Opcão selecionada                                    º±±
±±º          ³cNumTlv - Numero do atendimento Televendas                  º±±
±±º          ³cCliente - Codigo do Cliente                                º±±
±±º          ³cLoja - Loja do cliente                                     º±±
±±º          ³cCodPagto - Codigo da condicão de pagamento escolhida       º±±
±±º          ³aParcelas - Array com as parcelas montadas atraves da       º±±
±±º          ³            condicao de pagamento escolhida.                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Eletromega                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
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
	ApMsgInfo("Endreço da entrega invalido!","Entrega")
EndIf


/*

If Empty (cCodTransp)  
   
	lRet := .F.
	ApMsgInfo("Transportadora não permitida!","Vazio")

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
           

