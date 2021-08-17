#INCLUDE "PROTHEUS.CH"



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MA040TOK  ºAutor  ³Isaias Chipoch      º Data ³  05/05/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de entrada para verificar valor da comissao          º±±
±±º          ³ preenchido no cadastro do vendedor                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

USER FUNCTION MA040TOK

Local lRetVen := .T.

IF ALTERA
	
	IF A3_CARGO == "000017"
		
		IF A3_COMIS == 0 .AND. 	M->A3_COMIS == 0
			
			_msg:="O campo comissão de vendedor não esta informado "+chr(13)+chr(10)+"Sem isso o sistema nao ira gerar comissao sobre as vendas "+chr(13)+chr(10)+"Quer proceder?"
			
			
			If !apMsgNoYes(_msg,"ATENÇÃO","MsgNoYes")
				lRetVen:=.F.
			EndIf
			
		ENDIF
		
	ENDIF
	
ELSEIF INCLUI
	
	IF M->A3_CARGO == "000017"
		
		IF M->A3_COMIS == 0
			
			_msg:="O campo comissão de vendedor não esta informado "+chr(13)+chr(10)+"Sem isso o sistema nao ira gerar comissao sobre as vendas "+chr(13)+chr(10)+"Quer proceder?"
			
			
			If !apMsgNoYes(_msg,"ATENÇÃO","MsgNoYes")
				lRetVen:=.F.
			EndIf
			
		ENDIF
		
	ENDIF
	
ENDIF 

RETURN (lRetVen)
