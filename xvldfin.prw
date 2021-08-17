#INCLUDE "PROTHEUS.CH" 

#DEFINE COMP_DATE "01/05/2018"


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} XVLDFIN
Biblioteca de validacoes genericas do FINANCEIRO 

@type 		function
@author 	Roberto Souza
@since 		09/02/2017
@version 	P11 
 
@return nil
/*/    
//-------------------------------------------------------------------------------------
User Function XVLDFIN()
	MsgAlert("XVLDFIN "+COMP_DATE)
Return( .T. )


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ODescSa1
Valida��o para desconto maximo para cliente. Usada no campo A1_XDSCESP

@type 		function
@author 	Roberto Souza
@since 		09/02/2017
@version 	P11 
 
@return lRet
/*/    
//-------------------------------------------------------------------------------------
User Function ODescSa1()
	
	Local lRet 		:= .F.                    
	Local nDescPad  := GetMv("FS_A1DESCP",,0)
	Local cUsrDesc  := GetMv("FS_USDESCP",,"000000")
	Local cUsrDs20  := GetMv("FS_USDES20",,"000000")
	
	If __cUserID == "000079"  // Roberto
		lRet := .T. 
	ElseIf M->A1_XDSCESP <= 29.7 .And. __cUserID   == "001715" // Coordvendas
		lRet := .T. 
	/*ElseIf M->A1_XDSCESP <= 32.5 .And. __cUserID   == "001733" // Gerenciaadv
		lRet := .T.
	ElseIf M->A1_XDSCESP <= 26   .And. __cUserID   == "001853" // Trade
		lRet := .T.
	ElseIf M->A1_XDSCESP <= 20   .And. __cUserID   == "000620" // Pazetto	
		lRet := .T.
	ElseIf M->A1_XDSCESP <= 20   .And. __cUserID $ cUsrDs20  
		lRet := .T.*/
	ElseIf M->A1_XDSCESP <= nDescPad  .And. __cUserID $ cUsrDesc // Analistas e Assistentes    
		lRet := .T.	
	EndIf
	
Return( lRet ) 



//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ODtDMSa1
Valida��o para desconto maximo para cliente. Usada no campo A1_XDSCESP

@type 		function
@author 	Roberto Souza
@since 		09/02/2017
@version 	P11 
 
@return lRet
/*/    
//-------------------------------------------------------------------------------------
User Function ODtDMSa1()
	Local lRet := U_ODescSa1() 
	
	If !lRet	
		If M->A1_XDTDSCE <> SA1->A1_XDTDSCE
			lRet := .F.
		Else 
			lRet := .T.
		EndIf
	EndIf	              
	
Return( lRet )



//-------------------------------------------------------------------------------------
/*/{Protheus.doc} XMinPV
Valida��o para valor minimo de pedido de venda.

@type 		function
@author 	Roberto Souza
@since 		09/02/2017
@version 	P11 
 
@return lRet
/*/    
//-------------------------------------------------------------------------------------
User Function XMinPV( cFil, cTabela, cUfOrig, cUfDest )
	Local nRet := 0
	Local cTab := "U003"
	
	DbSelectArea("DA0")
	DbSetOrder(1)
	If DbSeek( cFil + cTabela )
		DA0->(FieldPos( "DA0_XVLMIN")) > 0
		nRet := DA0->DA0_XVLMIN		
	EndIf

	If nRet == 0
	
		nLinTab := U_XfPosTab(cTab, cUfOrig, "==", 4, cUfDest, "==", 5)
		
		If nLinTab > 0
			nRet 	:= fTabela( cTab,nLinTab, 6 )
		EndIf
		     
	EndIf
	
Return( nRet )          


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} RetParAR
Retorna oconteudo do parametro e formata para uso.

@type 		function
@author 	Roberto Souza
@since 		19/01/2017
@version 	P11 
 
@return nil
/*/    
//-------------------------------------------------------------------------------------
User Function RetParAR( cPar , cDefault )
    Local aRet 	:= {}
	Local cPar01:= ""
	         
	Default cDefault    := ""    
	
	cPar01  := GetMv( cPar,,cDefault )  
	
	cPar01 := Iif( Empty(cPar01),cDefault,cPar01 )
	
	If !Empty(cPar01)
	
		aRet   := Separa(cPar01,";") 
		
		If Empty(aRet) .Or. Len(aRet) < 3
			cPar01  := cDefault
			aRet    := Separa(cPar01,";") 
		EndIf
	EndIf
		
Return( aRet )


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} xGetFil
Pesquisa com Multisele��o de filial

@type 		function
@author 	Roberto Souza
@since 		09/02/2017
@version 	P11 
 
@return lRet
/*/    
//-------------------------------------------------------------------------------------
User Function xGetFil( cCpo, cPipe )

	Local oOk		:= Nil		// Imagem "Marcado"
	Local oNo		:= Nil		// Imagem "Desmarcado"
	Local aFil		:= {}		// Array com as filiais selecionadas
	Local cPreSel	:= ""		// Conteudo atual do campo 
	Local oButMarc	:=	Nil		// Objeto Botao Marca
	Local oButDmrc	:=	Nil		// Objeto Botao Desmarca
	Local oButInve	:=	Nil		// Objeto Botao Inverte selecao
	
	Private oDlg	:=	Nil		// Objeto Dialog
	Private oLbx	:=	Nil		// Objeto ListBox

	
	Default cPipe   := ";" 
	Default cCpo    := AllTrim(READVAR()) 
	
	If "A3_XFILVEN" $ cCpo
		cPipe := ","
	EndIf
	
	If !Empty(READVAR()) .And. ( AllTrim(READVAR()) == AllTrim( cCpo ) )
		
		Public xFGETFL  := AllTrim(&(READVAR()) ) // Publica criada para retorno da pesquisa via SXB
		
		cPreSel	:=	AllTrim(&(READVAR()) )
		oOk		:=	LoadBitmap( GetResources(), "LBOK" )
		oNo		:=	LoadBitmap( GetResources(), "LBNO" )
		
		// Carrega vetores
		LoadVet(@aFil,cPreSel)
		
		//�������������������������������Ŀ
		//�Aborta a rotina se nao ha dados�
		//���������������������������������
		If Len( aFil ) == 0
			Aviso( "Sem registros", "N�o h� filiais cadastradas", {"Ok"} )
			Return .F.
		Endif
		
		//���������������Ŀ
		//�Monta interface�
		//�����������������
		DEFINE MSDIALOG oDlg FROM 0,0 TO 280,500 PIXEL TITLE "Filiais" of oMainWnd STYLE DS_MODALFRAME STATUS
		
			// Botoes graficos
			DEFINE SBUTTON FROM 10,215 TYPE 1 OF oDlg ENABLE ONSTOP "Confirma" ACTION (RetFil(@aFil,cPipe,cCpo),oDlg:End())
			DEFINE SBUTTON FROM 30,215 TYPE 2 OF oDlg ENABLE ONSTOP "Sair" ACTION (oDlg:End())
		
			// Botoes texto
			@ 123,005 Button oButMarc Prompt "&Marcar Todos" 	Size 50,10 Pixel Action Marca(1,@aFil,@oLbx) Message "Selecionar todas as Filiais" Of oDlg
			@ 123,060 Button oButDmrc Prompt "&Desmarcar Todos"	Size 50,10 Pixel Action Marca(2,@aFil,@oLbx) Message "Desmarcar todas as Filiais" Of oDlg
			@ 123,115 Button oButInve Prompt "Inverter sele��o"	Size 50,10 Pixel Action Marca(3,@aFil,@oLbx) Message "Inverte a sele��o atual" Of oDlg
		
			// Labels
			@ 004,003 TO 135,210 LABEL "Filiais Dispon�veis:" OF oDlg PIXEL
		
			// ListBox
			@ 10,06 LISTBOX oLbx FIELDS HEADER " ","Cod Filial","Descricao Filial" SIZE 200,110 OF oDlg;
			PIXEL ON dblClick(aFil[oLbx:nAt,1] := !aFil[oLbx:nAt,1],oLbx:Refresh())
		
			// Metodos da ListBox
			oLbx:SetArray(aFil)
			oLbx:bLine 	:= {|| {Iif(aFil[oLbx:nAt,1],oOk,oNo),;
			aFil[oLbx:nAt,2],;
			aFil[oLbx:nAt,3]}}
		
		ACTIVATE MSDIALOG oDlg	CENTERED
	EndIf
	
Return .T.

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  � LoadVet  � Autor �                    � Data �              ���
��������������������������������������������������������������������������͹��
���Desc.     � Rotina responsavel pela carga dos arrays utilizados na get- ���
���          � dados e na listbox.                                         ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Static Function LoadVet(aVet,cPreSel)

	Local aArea		:= GetArea()
	Local aAreaSM0	:= SM0->(GetArea())
	
	DbSelectArea("SM0")
	SM0->(DbSetOrder(1))
	SM0->(DbGoTop())
	
	If Empty(cPreSel)
		cPreSel := padl(alltrim(cPresel),2,"0")
	EndIf
	                                            
	//������������������������������������������������������Ŀ
	//�Carrega vetor considerando o que ja estava selecionado�
	//��������������������������������������������������������
	While !SM0->(EOF())
		If SM0->M0_CODIGO == "01"
			aAdd(aVet,{(padl(AllTrim(SM0->M0_CODFIL),2,"0")$cPreSel),SM0->M0_CODFIL,SM0->M0_FILIAL})
		EndIf
		SM0->(DbSkip())
	EndDo
	          
	RestArea(aAreaSM0)
	RestArea(aArea)
	
Return Nil     
                       
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � Marca    � Autor �                    � Data �             ���
�������������������������������������������������������������������������͹��
���Desc.     � Rotina para marcar, desmarcar ou inverter a selecao das    ���
���          � filiais listadas no ListBox                                ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Marca(nOp,aVet,oObj)

	Local lMarca
	Local i
	
	If nOp == 1 		// Marca todos
		lMarca	:=	.T.
	ElseIf nOp == 2		// Desmarca Todos
		lMarca	:=	.F.
	Endif
	
	If lMarca != NIL
		For i := 1 To Len(aVet)
			aVet[i][1] := lMarca
		Next i
	Else	// Inverte Selecao
		For i := 1 To Len(aVet)
			aVet[i][1] := !aVet[i][1]
		Next i
	EndIf
	
	oObj:Refresh()	// Atualiza Listbox
	
Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � RetFil   � Autor �                    � Data �             ���
�������������������������������������������������������������������������͹��
���Desc.     � Grava as filiais selecionadas.                             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/ 
Static Function RetFil(aVet, cPipe, cCpo )

	Local cRet	:= ""
	Local cSep	:= ""
	Local nX
	
	//������������Ŀ
	//�Cria retorno�
	//��������������
	For nX := 1 to Len(aVet)
		If aVet[nX][1] == .T.
			cRet += cSep + AllTrim(aVet[nX][2])
			cSep := cPipe
		EndIf
	Next nX
	
	//����������������������Ŀ
	//�Grava retorno no campo�
	//������������������������
	&(cCpo) := cRet 
	xFGETFL := cRet 
	
Return( .T. )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � xGetFilb � Autor �                    � Data �             ���
�������������������������������������������������������������������������͹��
���Desc.     � Validacao as filiais informadas pelo usuario.              ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function xGetFilb()

	Local aArea		:=	GetArea()
	Local aAreaFIL	:=	SM0->(GetArea())
	Local aFilSel	:=	LeFil(AllTrim( &(READVAR()) ))
	Local nX		:=	1
	Local lRet		:=	.T.
	
	DbSelectArea("SM0")
	SM0->(DbSetOrder(1))
	SM0->(DbGoTop())
	
	//��������������������������Ŀ
	//�Testa os valores digitados�
	//����������������������������
	While (nX <= Len(aFilSel)) .And. lRet
		lRet := SM0->(DbSeek("01"+aFilSel[nX++]))
	EndDo
	
	If !lRet
		ApMsgStop("Filial " + aFilSel[--nX] + " n�o encontrada.","Aten��o")
	EndIf
	
	RestArea(aAreaFIL)
	RestArea(aArea)
	
Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � LeFil    � Autor �                    � Data �             ���
�������������������������������������������������������������������������͹��
���Desc.     � Le os valores contidos em uma string com separadores.      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function LeFil(cPar,cSep)

	Local aRet	:= {}
	Local nPos	:= 0
	Local cTmp	:= ""
	
	Default cSep := ","
	
	While Len(cPar) > 0
		
		//�������������������������������������������������������Ŀ
		//�Verifica se existem separadores ou se somente contem um�
		//�valor                                                  �
		//���������������������������������������������������������
		If (nPos := At(cSep,cPar)) == 0
			cTmp := SubStr(cPar,0,Len(cPar))
			cPar := ""
		Else
			cTmp := SubStr(cPar,0,nPos-1)
			cPar := SubStr(cPar,nPos+1,Len(cPar))
		EndIf
		
		//����������������Ŀ
		//�Alimenta retorno�
		//������������������
		If Len(cTmp) > 0
			AAdd(aRet,cTmp)
		EndIf
		
	EndDo
	
Return( aRet )            

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} xGetFilR
Retorno para Pesquisa com Multisele��o de filial

@type 		function
@author 	Roberto Souza
@since 		10/08/2017
@version 	P11 
 
@return lRet
/*/    
//-------------------------------------------------------------------------------------
User Function xGetFilR()

Return( xFGETFL )


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} xVldBco
Valida��o para cadastro de Banco.

@type 		function
@author 	Roberto Souza
@since 		09/02/2017
@version 	P11 
 
@return lRet
/*/    
//-------------------------------------------------------------------------------------
User Function xVldBco( cCpo )
	Local lRet 		:= .T.
	Local aArea     := GetArea()
	Local nRecSA6 	:= 0                   
	Local cMsgErro  := "" 
	Local Nx 		:= 0
	
	
	If !Empty(READVAR()) .And. ( AllTrim(READVAR()) == AllTrim( cCpo ) )
		
		If "A6_XFILBOL" $ cCpo
			cInfo	:= AllTrim(&(READVAR()) )		    
		    If !Empty( cInfo )
			    nRecSA6 := SA6->(Recno())
			    aFils   := LeFil( cInfo, ";" )
                SA6->(DbGoTop())
				While SA6->(!Eof())
					If !Empty(SA6->A6_XFILBOL) .And. SA6->(Recno()) <> nRecSA6
						aPosFils   := LeFil( SA6->A6_XFILBOL, ";" )	
					    For Nx := 1 To Len(aFils)
							nScan := AScan( aPosFils, {|x| AllTrim(aFils[Nx]) == AllTrim(x) } )
							If nScan > 0
							    cMsgErro += "A filial '"+aFils[Nx]+"' j� est� associada ao seguinte banco para gera��o/impress�o de boleto:"+CRLF
							    cMsgErro += "Banco : "+SA6->A6_COD	+ CRLF
								cMsgErro += "Nome do Banco : "+SA6->A6_NOME	+ CRLF
								cMsgErro += "Ag�ncia : "+SA6->A6_AGENCIA	+ CRLF
								cMsgErro += "Conta Corrente : "+SA6->A6_NUMCON	+ CRLF
						  		cMsgErro += "Codigo da Carteira : "+SA6->A6_CARTEIR	+ CRLF
		
								Aviso("Aten��o",cMsgErro,{"Ok"},2)
								lRet := .F.              
								Exit
							EndIf					    
					    Next
					
					EndIf				     
					SA6->(DbSkip())
				EndDo	
	    			
    		EndIf
		EndIf	

	EndIf
			
	RestArea( aArea )	

	
Return( lRet )          

