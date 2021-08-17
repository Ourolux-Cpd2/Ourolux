#include "Protheus.ch"
#include "Topconn.ch"
#INCLUDE "AP5MAIL.CH"
//----------------------------------------------------------------------
/*{Protheus.doc} B4BAVLOT - TRATA LOTE UNICO PARA CLIENTES DETERMINADOS
@author		Anderson Lima - B4B
@since		31/07/2016
@version	11
@param
*/
//----------------------------------------------------------------------

User Function B4BAVLOT(cFilSC5,cNumSC5)

Local aAreaAtu		:= GetArea()
Local aAreaSC5		:= SC5->(GetArea())
Local aAreaSC6		:= SC6->(GetArea())
Local lRet   	  	:= .T.
//Local cFilSC5		:= xFilial("SC5")
Local cFilSC6		:= xFilial("SC6")
Local cFilSB1		:= xFilial("SB1")
Local cFilSA1		:= xFilial("SA1")
Local cFilSA3		:= xFilial("SA3")
Local cLote			:= 'N'
Local aLoteSel		:= {}
Local cNoSaldo		:= ""
Local lAValLoja		:= SuperGetMV("MV_AVLOJ",.F.,.F.)

//GARANTO POSICIONAMETO NO PEDIDO CORRETO
DbSelectArea("SC5")
DbSetOrder(1)
DbSeek(cFilSC5+cNumSC5)

//VERIFICA SE O CLIENTE SO ACEITA LOTES INTEIROS... SEM QUEBRA
DbSelectArea("SA1")
DbSetOrder(1)
//VERIFICO SE DEVO OLHAR A LOJA OU NÃO
IF !lAValLoja
	
	DbSeek(cFilSA1+SC5->C5_CLIENTE)
	
Else
	
	DbSeek(cFilSA1+SC5->C5_CLIENTE+SC5->C5_LOJACLI)
	
EndIf

IF SA1->A1_XAVALOT == 'N'
	
	//POSICIONO NOS ITENS DO PEDIDO
	DbSelectArea("SC6")
	DbSetOrder(1)
	DbSeek(cFilSC5+SC5->C5_NUM)
	
	Do While SC6->(!Eof()) .And. (SC6->C6_FILIAL+SC6->C6_NUM == cFilSC5+SC5->C5_NUM)
		
		//	If Empty(SC6->C6_LOTECTL) //verifico se o campo de lote esta limpo e efetuo a validação
		
		DbSelectArea("SB1")
		DbSetOrder(1)
		DbSeek(cFilSB1+SC6->C6_PRODUTO)
		
		IF SB1->B1_RASTRO == 'L'
			
			aLoteSel:= GetSaldoSB8(SC6->C6_PRODUTO,SC6->C6_LOCAL,SC6->C6_QTDVEN)
			
			If !Empty(aLoteSel[5])
				//INDICO QUAL LOTE DEVERÁ SER EMPENHADO
				RecLock("SC6", .F.)
				
				SC6->C6_LOTECTL := aLoteSel[5]
				SC6->C6_DTVALID := STOD(aLoteSel[6])
				
				SC6->(MsUnlock())
				
			else
				
				cNoSaldo += ( AllTrim(SC6->C6_PRODUTO) +" | " )
				
			EndIf
			
			
		EndIf
		
		//	Else
		//se o campo lote estiver preenchido pulo
		//	   	SC6->(DbSkip())
		//		Loop
		
		//	EndIf
		
		
		SC6->(DbSkip())
		
	EndDo   
	
	If !Empty(cNoSaldo)
		
		//BLOQUEIO PEDIDO POR REGRA CONFORME SOLICITACAO
		DbSelectArea("SC5")
		DbSetOrder(1)
		DbSeek(cFilSC5+SC5->C5_NUM)
		             
		RecLock("SC5", .F.)
		SC5->C5_BLQ := '1'
		SC5->(MsUnlock())	
	
		//ENVIO E-MAIL PARA OS RESPONSAVEIS CONFORME REGRA DEFINIDA
		DbSelectArea("SA3")
		DbSetOrder(1)
		DbSeek(cFilSA3+SC5->C5_VEND1)
		
		cEmails := AllTrim(SA3->A3_EMAIL)    //PEGO E-MAIL DO VENDEDOR
		
		DbSelectArea("SA3")
		DbSetOrder(1)
		DbSeek(cFilSA3+SA3->A3_XASSIST)
		
		cEmails += ";"+ AllTrim(SA3->A3_EMAIL)
		
		//ENVIO E-MAIL
		EnviaMail(cNoSaldo,cEmails)
		
	Else
		
		If !U_xSac() .And. !IsInCallStack("U_INTPV")  
			If INCLUI .Or. ALTERA
			//DESBLOQUEIO PEDIDO POR REGRA CONFORME SOLICITACAO
				DbSelectArea("SC5")
				DbSetOrder(1)
				DbSeek(cFilSC5+SC5->C5_NUM)
			
				RecLock("SC5", .F.)
				SC5->C5_BLQ := ''
				SC5->(MsUnlock())	
					
			EndIf		
		EndIf
				
	EndIf	
		
EndIf



RestArea(aAreaAtu)
RestArea(aAreaSC5)
RestArea(aAreaSC6)

Return(lRet)

//--------------------------------------------------------------------
/*{Protheus.doc} GetSaldoSB8
@				 FUNCAO PARA ELEICAO DO LOTE INTEIRO, OBDECENDO FIFO
@author		Anderson Lima - B4B
@since		02/08/2016
@version	11
@param      (PRODUTO,LOCAL,QUANTIDADE)
*/
//--------------------------------------------------------------------
Static Function GetSaldoSB8(cProd,cLocal,nQuant)
Local aArea      := GetArea()
Local cAliasTMP  := GetNextAlias()
Local cQuery     := ""
Local cAlias     := ""
Local aRet       := {}
Private aRetSel  := {}
Private nQtdok   := 0

cQuery := "	SELECT B8_PRODUTO,B8_LOCAL,(B8_SALDO - B8_EMPENHO) AS SALDO,B8_EMPENHO,B8_LOTECTL,B8_DTVALID "+CRLF
cQuery += " FROM "+RetSqlName("SB8")+" SB8" +CRLF
cQuery += " WHERE B8_PRODUTO ='"+cProd+"' "+CRLF
cQuery += " AND B8_LOCAL     ='"+cLocal+"' "+CRLF
cQuery += " AND B8_DTVALID  >='"+DTOS(dDataBase)+"' "+CRLF
cQuery += " AND B8_SALDO    > 0 "+CRLF
cQuery += " AND SB8.D_E_L_E_T_ = '' "+CRLF


IF SELECT(cAliasTMP) > 0
	(cAliasTMP)->(DBCLOSEAREA())
ENDIF

cQuery := ChangeQuery(cQuery)

TcQuery cQuery New Alias (cAliasTMP)
(cAliasTMP)->(DBGOTOP())

While (cAliasTMP)->(!EOF())
	
	If (cAliasTMP)->SALDO >= nQuant
		
		AADD(aRet,  {	(cAliasTMP)->B8_PRODUTO,;
		(cAliasTMP)->B8_LOCAL,;
		(cAliasTMP)->SALDO,;
		(cAliasTMP)->B8_EMPENHO,;
		(cAliasTMP)->B8_LOTECTL,;
		(cAliasTMP)->B8_DTVALID })
		
		
	EndIf
	
	(cAliasTMP)->(DbSkip())
	
EndDo

If !Empty(aRet)
	ASORT(aRet, , , { | x,y | x[6] < y[6] } )// ORDENO POR DATA
	
	For nX := 1 to Len(aRet)
		
		//ATRIBUO O LOTE ELEITO
		aRetSel := aRet[nX]
		
		//FUNCAO QUE VALIDA SE O ENDEREÇO ESTA BLOQUEADO AFETANDO O SALDO DISPONIVEL
		nQtdok := VALENDBLQ(aRetSel)
		
		if (nQtdok < nQuant)
			
			aRetSel := {'','',0,0,'',''}
			
			Loop
			
			
		Else
			
			Exit
			
		EndIf
		
		
	Next
	
	
Else
	//inicio o aray de retorno caso venha vazio para evitar erro.
	aRetSel := {'','',0,0,'',''}
	
EndIf

RestArea(aArea)

Return (aRetSel)


//--------------------------------------------------------------------
/*{Protheus.doc} VALENDBLQ
@				 FUNCAO PARA VERIFCAR ENDERECO BLOQUEADO
@author		Anderson Lima - B4B
@since		02/08/2016
@version	11
@param      (PRODUTO,LOCAL,QUANTIDADE)
*/
//--------------------------------------------------------------------
Static Function VALENDBLQ(aRetSel)

Local cAliasTMP2  := GetNextAlias()
Local cQry     	  := ""
Local cAlias      := ""
Local cRet2       := {}
Local nQtd		  := 0
Local nQtdBlq	  := 0
Local nQtdRes	  := 0


cQry := " SELECT BF_QUANT, BF_EMPENHO,(BF_QUANT - BF_EMPENHO)AS SALDO,BF_PRODUTO,BF_LOTECTL,BF_LOCALIZ, BF_LOCAL,BE_STATUS "+CRLF
cQry += " FROM "+RetSqlName("SBF")+" SBF" +CRLF
cQry += " JOIN SBE010 SBE ON ( BE_LOCALIZ = BF_LOCALIZ AND BE_LOCAL = BF_LOCAL AND BE_FILIAL = BF_FILIAL AND SBE.D_E_L_E_T_ ='' )"+CRLF
cQry += " WHERE BF_PRODUTO 	='"+aRetSel[1]+"' "+CRLF
cQry += " AND BF_LOCAL 		='"+aRetSel[2]+"' "+CRLF
cQry += " AND BF_LOTECTL 	='"+aRetSel[5]+"' "+CRLF
cQry += " AND BF_QUANT 		<> 0 "+CRLF
cQry += " AND BF_LOCALIZ 	<> 'DOCA' "+CRLF
cQry += " AND SBF.D_E_L_E_T_ = '' "+CRLF


IF SELECT(cAliasTMP2) > 0
	(cAliasTMP2)->(DBCLOSEAREA())
ENDIF

cQuery := ChangeQuery(cQry)

TcQuery cQuery New Alias (cAliasTMP2)
(cAliasTMP2)->(DBGOTOP())

While (cAliasTMP2)->(!EOF())
	
	If (cAliasTMP2)->BE_STATUS <> '3'
		
		nQtd += (cAliasTMP2)->SALDO
		/*
		AADD(aRet2,  {	(cAliasTMP2)->BF_PRODUTO,;
		(cAliasTMP2)->BF_LOCAL,;
		(cAliasTMP2)->SALDO,;
		(cAliasTMP2)->BF_QUANT,;
		(cAliasTMP2)->BF_EMPENHO,;
		(cAliasTMP2)->BF_LOTECTL,;
		(cAliasTMP2)->BF_LOCALIZ ,;
		(cAliasTMP2)->BE_STATUS	})
		*/
	Else
		
		nQtdBlq += (cAliasTMP2)->SALDO
		
	EndIf
	
	(cAliasTMP2)->(DbSkip())
	
EndDo


nQtdRes := (nQtd - nQtdBlq)   //sem utilidade no momento, apenas para validação do tipo de dado e posterior implementação de msgs.


Return (nQtd)

//--------------------------------------------------------------------
/*{Protheus.doc} EnviaMail
@				 FUNCAO PARA ENVIO DE NOTIFICAÇÃO DE PRODUTO SEM SALDO
@author		Anderson Lima - B4B
@since		02/08/2016
@version	11
@param      (STRING)
*/
//--------------------------------------------------------------------
Static Function EnviaMail(cNoSaldo,cEmails)

Local c_Html            := ""
Local l_Conexao	 	 	:= .F.
Local l_Envio			:= .F.
Local l_Desconexao 		:= .F.
Local c_As	  	  		:=  "Produto sem Lote único"
Local c_Erro_Conexao	:= ""
Local c_Erro_Envio		:= ""
Local c_Erro_Desconexao	:= ""
Local cMensagem			:= ""
Local c_Anex			:= ""
Private	c_Cad			:= "Envio de e-mail"
Private	l_Ret			:= .T.
Private	c_MailServer	:= AllTrim(GetMv("MV_RELSERV"))
Private	c_MailConta 	:= AllTrim(GetMv("MV_RELAUSR"))
Private l_Auth			:= GetMv("MV_RELAUTH")
Private c_MailAuth		:= AllTrim(GetMv("MV_RELACNT"))
Private	c_MailSenha		:= AllTrim(GetMv("MV_RELPSW"))
Private c_SenhaAuth		:= AllTrim(GetMv("MV_RELAPSW"))
Private	c_MailD 		:=  cEmails
Private	l_Men	   		:= .F.
Private c_Tex			:= ""

c_Html	:= '<table>'
c_Html	+= '<tr><td><strong>'+ " O cliente do pedido  " + SC5->C5_NUM + " esta configurado para não receber lotes quebrados, favor verificar!!!"+ '  </td></tr></strong>'
c_Html	+= '<tr><td><strong>'+ " O pedido foi bloqueado por regra."+ '  </td></tr></strong>'
c_Html	+= '<tr><td>'+ " ____________________________________________________________________________________________________" +'</td></tr>'
c_Html	+= '<tr><td>'+ " |Produto(s) sem saldo em lote único ......: "+'<b>'+cNoSaldo +'</b></td></tr>'
c_Html	+= '</table>'

c_Tex := c_Html

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executa conexao ao servidor mencionado no parametro. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Connect Smtp Server c_MailServer ACCOUNT c_MailConta PASSWORD c_MailSenha RESULT l_Conexao

If !l_Conexao
	GET MAIL ERROR c_Erro_Conexao
	If l_Men
		Aviso(	c_Cad, "Nao foi possível estabelecer conexão com o servidor - ";
		+c_Erro_Conexao,{"&Ok"},,"Sem Conexão" )
	EndIf
	c_msgerro := "Nao foi possível estabelecer conexão com o servidor - "+c_Erro_Conexao
	l_Ret := .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se deve fazer autenticacao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If l_Auth
	If !MailAuth(c_MailAuth, c_SenhaAuth)
		GET MAIL ERROR c_Erro_Conexao
		If l_Men
			Aviso(	c_Cad, "Nao foi possível autenticar a conexão com o servidor - ";
			+c_Erro_Conexao,{"&Ok"},,"Sem Conexão" )
		EndIf
		c_msgerro := "Nao foi possível autenticar a conexãao com o servidor - "+c_Erro_Conexao
		l_Ret := .F.
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executa envio da mensagem. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(c_Anex)
	Send Mail From c_MAILCONTA to c_MailD SubJect c_As BODY c_Tex FORMAT TEXT ATTACHMENT c_Anex RESULT l_Envio
Else
	Send Mail From c_MAILCONTA to c_MailD SubJect c_As BODY c_Tex FORMAT TEXT RESULT l_Envio
	
EndIf


Return()

