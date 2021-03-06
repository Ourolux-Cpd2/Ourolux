#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FA050DEL     �Autor  �Isaias Chipoch   � Data �  31/03/16   ���
�������������������������������������������������������������������������͹��
���Desc.     �Ponto de Entrada para notificar no momento da exclusao de    ��
���          �titulo                                                      ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function FA050DEL()

	Local _lRet := .T.

	If !IsBlind()
		//�������������������������������������������������������������������������������������������������������������������Ŀ
		//� Verifica se o titulo a Pagar pode ou nao ser Excluso, caso tenha sido Selecionado pela rotina de COMISSAO.  	  �
		//���������������������������������������������������������������������������������������������������������������������
		If !EMPTY( SE2->E2_X_DTANF ) .OR. !EMPTY( SE2->E2_X_NUMNF ) .OR. !EMPTY( SE2->E2_X_SERIE )
			ALERT( "Este t�tulo N�O PODE ser excluso, favor consultar o DEPARTAMENTO DE INFORM�TICA. ")
			_lRet := .F.	// Bloqueia a exclusao do titulo a pagar
		EndIf

		If (FUNNAME() $ 'EICDI502.GFEA070') .And. _lRet 
			If !(Type("LF050AUTO")!="U" .And. LF050AUTO)
				_lRet := U_NotexSE2()
			EndIf
		Else
			If _lRet
				_lRet:=U_NotexSE2()	
			EndIf
		Endif 
	EndIf
Return(_lRet)	

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �NotexSE2  �Autor  �Microsiga           � Data �  04/12/16   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function NotexSE2 

Local _aAreaSE2 := SE2->(GetArea())
Local _lRet     := .T.
Local _cMotCanc := ""
Local oHTML

If _lRet
	_cMotCanc := MotCanc()
	
	If Empty(_cMotCanc)
		ApMsgStop("Por favor informar o motivo da exclusao do titulo, sem o motivo n�o � possivel excluir o Titulo.","FA050DEL")
		_lRet := .F.
	EndIf
	
	If _lRet
		oProcess:= TWFProcess():New("ExcluiTituloCP","Exclusao Titulo CP")
		oProcess:NewTask("Inicio","\WORKFLOW\exctitcp.html")
		oProcess:cSubject:="Exclusao Titulo CP"
		oHtml := oProcess:oHTML
		
		oHTML:ValByName('PREFIXO',SE2->E2_PREFIXO)
		oHTML:ValByName('NUMERO',SE2->E2_NUM)
		oHTML:ValByName('PARCELA',SE2->E2_PARCELA)
		oHTML:ValByName('TIPO',SE2->E2_TIPO)
		oHTML:ValByName('CLIENTE',SE2->E2_FORNECE +'/'+ SE2->E2_LOJA + ' ' + SE2->E2_NOMFOR)
		oHTML:ValByName('EMISSAO',SE2->E2_EMISSAO)
		oHTML:ValByName('VENCTO',SE2->E2_VENCREA)
		oHTML:ValByName('VALOR',"R$ " + Transform(SE2->E2_VALOR,"@E 99,999,999.99"))
		oHTML:ValByName('MOTCANC',Alltrim(_cMotCanc))
		// Fun��o UsrRetName esta retornando o nome completo na P12, foi substituida pela variavel cUserName - Claudino 26/07/2017
		//oHTML:ValByName('USER',"Login: "+UsrRetName(__cUserId)+" - "+Rtrim(Substr(cUsuario,7,15)))
		oHTML:ValByName('USER',"Login: "+Upper(Alltrim(cUserName))+" - "+Rtrim(Substr(cUsuario,7,15)))
		
		oProcess:cBCc := "sumaia@ourolux.com.br"
		oProcess:Start()
		oProcess:Finish()
	EndIf
	
EndIf

RestArea(_aAreaSE2)

Return(_lRet)

/*����������������������������������������������������������������������������
������������������������������������������������������������������������������
��� Programa � MotCanc() � Autor � Isaias Chipoch       � Data � 31/03/16  ���
������������������������������������������������������������������������������
��� Desc.    � Funcao que monta o get para que seja preenchido o motivo do ���
���          � cancelamento.     			   							   ���
������������������������������������������������������������������������������
����������������������������������������������������������������������������*/

Static Function MotCanc()

Local _oDlg
Local _oTMultiGet
Local _cTexto := SPACE(200)

DEFINE MSDIALOG _oDlg TITLE "Motivo da Exclusao" FROM 0,0 To 180,300 OF oMainWnd PIXEL

_oTMultiGet:=TMultiGet():New(003,003,{|U|If(Pcount()>0,_cTexto:=u,_cTexto)},_oDlg,145,070,,.T.,,,,.T.,,,{||.T.},,,,,,,.F.,.T.)
_oTMultiGet:lWordWrap := .F.	// Variavel que faz a quebra de linha no Objeto TMultiGet.
_oTMultiGet:EnableHScroll(.T.)	// Habilita/Desabilita a barra de rolagem horizontal.
_oTMultiGet:EnableVScroll(.T.)	// Habilita/Desabilita a barra de rolagem vertical.

DEFINE SBUTTON FROM 078,122 TYPE 1 ENABLE OF _oDlg ACTION (_oDlg:End())

ACTIVATE MSDIALOG _oDlg CENTERED

Return(_cTexto)
