#INCLUDE "PROTHEUS.CH"



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MA040TOK  �Autor  �Isaias Chipoch      � Data �  05/05/16   ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de entrada para verificar valor da comissao          ���
���          � preenchido no cadastro do vendedor                         ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

USER FUNCTION MA040TOK

Local lRetVen := .T.

IF ALTERA
	
	IF A3_CARGO == "000017"
		
		IF A3_COMIS == 0 .AND. 	M->A3_COMIS == 0
			
			_msg:="O campo comiss�o de vendedor n�o esta informado "+chr(13)+chr(10)+"Sem isso o sistema nao ira gerar comissao sobre as vendas "+chr(13)+chr(10)+"Quer proceder?"
			
			
			If !apMsgNoYes(_msg,"ATEN��O","MsgNoYes")
				lRetVen:=.F.
			EndIf
			
		ENDIF
		
	ENDIF
	
ELSEIF INCLUI
	
	IF M->A3_CARGO == "000017"
		
		IF M->A3_COMIS == 0
			
			_msg:="O campo comiss�o de vendedor n�o esta informado "+chr(13)+chr(10)+"Sem isso o sistema nao ira gerar comissao sobre as vendas "+chr(13)+chr(10)+"Quer proceder?"
			
			
			If !apMsgNoYes(_msg,"ATEN��O","MsgNoYes")
				lRetVen:=.F.
			EndIf
			
		ENDIF
		
	ENDIF
	
ENDIF 

RETURN (lRetVen)
