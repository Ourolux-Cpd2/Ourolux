#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"

/*苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北� Programa � FA290OKC() � Autor � Claudino P Domingues � Data � 10/03/14 罕�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北� Funcao Padrao � FINA290                                                罕�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北� Desc.    � Localizado no Ok do Cancelamento de Fatura a Pagar          罕�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌*/

User Function FA290OKC()
    
	Local __lRet      := .T. 
	Local _cMotCanc   := ""
	Local _cParc	  := ""
    Local _cTitSFat   := ""
    Local _nValTotFat := 0
    Local _nDayDif	  := 0
	Local _nDayNot	  := 0
	Local oHTML
	
	// Claudino 27/04/16 - Parametro que armazena o login dos diretores
	// Fun玢o UsrRetName esta retornando o nome completo na P12, foi substituida pela variavel cUserName - Claudino 26/07/2017
	//If !(Upper(UsrRetName(__cUserId)) $ GetMv("FS_DIRETOR"))
	If !(Upper(Alltrim(cUserName)) $ GetMv("FS_DIRETOR"))
		
		dbSelectArea("SE2")
   		SE2->(dbSetOrder(6))
    	SE2->(dbGoTop())
    
		If dbSeek(xFilial("SE2")+cFornCan+cLojaCan+cPrefCan+cFatCan)
			// Claudino 27/04/16 - Valida se o usuario logado esta nos parametros
			// Fun玢o UsrRetName esta retornando o nome completo na P12, foi substituida pela variavel cUserName - Claudino 26/07/2017
			//If Upper(UsrRetName(__cUserId)) $ GetMv("FS_EXCFIN1") .OR. Upper(UsrRetName(__cUserId)) $ GetMv("FS_EXCFIN2")
			If Upper(Alltrim(cUserName)) $ GetMv("FS_EXCFIN1") .OR. Upper(Alltrim(cUserName)) $ GetMv("FS_EXCFIN2")
				// Claudino 27/04/16 - Numero de dias de diferen鏰 entre emiss鉶 e database
				_nDayDif := DateDiffDay(SE2->E2_EMISSAO,dDataBase) 
				// Claudino 27/04/16 - � o mesmo dia
				If _nDayDif > 0
					// Claudino 27/04/16 - Valida entre a emiss鉶 e a database, quantos dias n鉶 s鉶 uteis
					For n := 1 to _nDayDif
						If DataValida(SE2->E2_EMISSAO + n) <> SE2->E2_EMISSAO + n
							_nDayNot++
						EndIf 
					Next n
								
					// Claudino 27/04/16 - Valida se a quantidade de dias uteis � maior 2
					If (_nDayDif - _nDayNot) > 2
						ApMsgStop("Usu醨io sem acesso, s� pode ser cancelado dentro de dois dias uteis. Favor verificar com o seu gestor.","FA290OKC")
						__lRet := .F.
					Else
						// Claudino 27/04/16 - Se for exatamente igual a 2 e valida se o usuario 
						// esta no parametro que pode digitar dois dias uteis
						If (_nDayDif - _nDayNot) == 2
							// Fun玢o UsrRetName esta retornando o nome completo na P12, foi substituida pela variavel cUserName - Claudino 26/07/2017
							//If !(Upper(UsrRetName(__cUserId)) $ GetMv("FS_EXCFIN2"))
							If !(Upper(Alltrim(cUserName)) $ GetMv("FS_EXCFIN2"))
								ApMsgStop("Usu醨io sem acesso, s� pode ser cancelado dentro de um dia 鷗il. Favor verificar com o seu gestor","FA290OKC")
								__lRet := .F.
							EndIf
						EndIf
					EndIf
				EndIf	
			Else
				ApMsgStop("Usuario sem permiss鉶 para executar essa opera玢o! Favor verificar com o seu gestor.","FA290OKC")
				__lRet := .F.
			EndIf
		Else
			__lRet := .F.
		EndIf
		
	EndIf	
	
	If __lRet
		_cMotCanc := MotCanc()
		
		If Empty(_cMotCanc)
			ApMsgStop("Por favor informar o motivo do cancelamento, sem o motivo n鉶 � possivel cancelar.","FA290OKC")
			__lRet := .F.
		EndIf
		
		If __lRet			
			
			dbSelectArea("SE2")
   			SE2->(dbSetOrder(6))
    		SE2->(dbGoTop())
    
			If dbSeek(xFilial("SE2")+cFornCan+cLojaCan+cPrefCan+cFatCan)
			
				oProcess:= TWFProcess():New("CancelaFTCP","Cancelamento Fatura a Pagar") 
				oProcess:NewTask("Inicio","\WORKFLOW\cancftcp.html")        
				oProcess:cSubject:="Cancelamento Fatura a Pagar"     
				oHtml := oProcess:oHTML
			    
			    oHTML:ValByName('PREFFAT',SE2->E2_PREFIXO)
				oHTML:ValByName('NUMFAT',SE2->E2_NUM)
				oHTML:ValByName('TIPOFAT',SE2->E2_TIPO)
				oHTML:ValByName('EMISFAT',SE2->E2_EMISSAO)
				oHTML:ValByName('VENCFAT',SE2->E2_VENCTO)
				oHTML:ValByName('FORNFAT',Alltrim(SE2->E2_FORNECE) +'/'+ SE2->E2_LOJA + ' / ' + SE2->E2_NOMFOR)
					
				While (xFilial("SE2")+cFornCan+cLojaCan+cPrefCan+cFatCan) == (SE2->E2_FILIAL+SE2->E2_FORNECE+SE2->E2_LOJA+SE2->E2_PREFIXO+SE2->E2_NUM)
					_cParc += SE2->E2_PARCELA+' '
					_nValTotFat += SE2->E2_VALOR
					SE2->(dbSkip())
				EndDo    
				
				oHTML:ValByName('PARCFAT',_cParc)	
				oHTML:ValByName('VLTOTFAT',"R$ " + Transform(_nValTotFat,"@E 99,999,999.99"))
				
				dbSelectArea("SE2")
   				SE2->(dbSetOrder(9))
    			SE2->(dbGoTop())
				
				If dbSeek(xFilial("SE2")+cFornCan+cLojaCan+cPrefCan+cFatCan)
					While (xFilial("SE2")+cFornCan+cLojaCan+cPrefCan+cFatCan) == (SE2->E2_FILIAL+SE2->E2_FORNECE+SE2->E2_LOJA+SE2->E2_FATPREF+SE2->E2_FATURA)
						_cTitSFat += '( '+Alltrim(SE2->E2_PREFIXO)+' / '+Alltrim(SE2->E2_NUM)+' / '+Alltrim(SE2->E2_PARCELA)+' / '+Alltrim(SE2->E2_TIPO)+' / ';
									+IIF(SE2->E2_MOEDA <> 1,'US$ ','R$ ')+Alltrim(Transform(SE2->E2_VALOR,"@E 99,999,999.99"))+') <br>' 
				        SE2->(dbSkip())
				  	EndDo
				EndIf
				
				_cTitSFat := SubString(Alltrim(_cTitSFat),1,Len(_cTitSFat)-1)
				
				oHTML:ValByName('TITS',_cTitSFat)
				oHTML:ValByName('MOTCANC',Alltrim(_cMotCanc))	
				// Fun玢o UsrRetName esta retornando o nome completo na P12, foi substituida pela variavel cUserName - Claudino 26/07/2017
				//oHTML:ValByName('USER',"Login: "+UsrRetName(__cUserId)+" - "+Rtrim(Substr(cUsuario,7,15)))
				oHTML:ValByName('USER',"Login: "+Upper(Alltrim(cUserName))+" - "+Rtrim(Substr(cUsuario,7,15)))
			
				oProcess:cBCc := "sumaia@ourolux.com.br"
				oProcess:Start()
				oProcess:Finish() 
			
			EndIf
			
		EndIf
	
	EndIf
	
Return(__lRet)

/*苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北� Programa � MotCanc() � Autor � Claudino P Domingues � Data � 03/10/13  罕�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北� Desc.    � Funcao que monta o get para que seja preenchido o motivo do 罕�
北�          � cancelamento.     			   							   罕�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌*/

Static Function MotCanc()

	Local _oDlg
	Local _oTMultiGet
	Local _cTexto := SPACE(200)
	
	DEFINE MSDIALOG _oDlg TITLE "Motivo do Cancelamento/Exclusao" FROM 0,0 To 180,300 OF oMainWnd PIXEL
		               		                                  
		_oTMultiGet:=TMultiGet():New(003,003,{|U|If(Pcount()>0,_cTexto:=u,_cTexto)},_oDlg,145,070,,.T.,,,,.T.,,,{||.T.},,,,,,,.F.,.T.)	                
		_oTMultiGet:lWordWrap := .F.	// Variavel que faz a quebra de linha no Objeto TMultiGet.
		_oTMultiGet:EnableHScroll(.T.)	// Habilita/Desabilita a barra de rolagem horizontal.
		_oTMultiGet:EnableVScroll(.T.)	// Habilita/Desabilita a barra de rolagem vertical.
				                   
		DEFINE SBUTTON FROM 078,122 TYPE 1 ENABLE OF _oDlg ACTION (_oDlg:End()) 
		
	ACTIVATE MSDIALOG _oDlg CENTERED

Return(_cTexto) 