#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FA050UPD     ºAutor  ³Isaias Chipoch     º Data ³  03/31/16 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de entrada para nao permitir exclusao de titulo PA,  º±±
±±º          ³ exceto para diretoria                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


User Function FA050UPD ()


Local _lRet := .T.
Local _cExcdir := getmv("FS_EXCEDIR")

If FunName() == "MATA121" // Pedido de Compra
	// Utilizei Empty(SC7->C7_CONAPRO) pois preciso saber
	// se esta incluindo ou alterando o PC, como esse ponto
	// de entrada ?no financeiro, n? consigo utilizar
	// as variaveis INCLUI / ALTERA referente ao PC, pois
	// essas variaveis v? estar com o conteudo referente
	// a FINA050 e n? ao MATA121.
	If Empty(SC7->C7_CONAPRO)
		_lRet := .F.
		ApMsgStop('S?sera poss?el incluir um PA quando o PC estiver liberado!', 'FA050UPD')
	Else
		If SC7->C7_CONAPRO == "B" // Se o PC estiver Bloqueado
			_lRet := .F.
			ApMsgStop('PC n? esta liberado. S?sera poss?el incluir um PA quando o PC estiver liberado!', 'FA050UPD')
		EndIf
	EndIf
EndIf


If !INCLUI .And. !ALTERA
	If !Upper(UsrRetName(__cUserId)) $ _cExcdir
		
		If SE2->E2_TIPO = 'PA' .AND. empty(SE2->E2_BAIXA)
			_lRet:=.F.
			ApMsgStop("Voce não pode excluir titulo de pagamento antecipado", "FA050UPD" )
		Endif
	Endif
Endif

//******************************************************
// Caio Menezes - 07/03/2020 - Transpofrete
//******************************************************
If _lRet
	If !INCLUI .And. !ALTERA
		
		If Alltrim(SE2->E2_ORIGEM) == "TRANSPO"
			
			dbSelectArea("PR1")
			PR1->(dbSetOrder(1)) //PR1_FILIAL+PR1_ALIAS+STR(PR1_RECNO)
			
			If PR1->(dbSeek(xFilial("PR1")+"SE2"+cValToChar(SE2->(RECNO()))))
				_lRet := .F.
				MsgStop("Não é possível excluir fatura Transpofrete.")
			Endif
		
		Endif
	
	Endif
	
EndIf

Return (_lRet)
