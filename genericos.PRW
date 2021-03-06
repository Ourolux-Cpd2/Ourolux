#INCLUDE "PROTHEUS.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � _getFormula  � Autor � Eletromega        � Data � 10/11/92 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Interpreta formula cadastrada                              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � xExp1:= Formula(cExp1,nExp2)                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� xExp1:= Retorna formula iterpretada                        ���
���          � cExp1:= Codigo da formula previamente cadastrada em SM4    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � GENERICO                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User FUNCTION getForml(cFormula)

Local aArea, cForm:=" ", xValor
//����������������������������������������������������������������������Ŀ
//�Salva a integridade dos dados                                         �
//������������������������������������������������������������������������
aArea := GetArea()

DbSelectArea("SM4") 
SM4->(DbSetOrder(1))
SM4->(DbSeek(xFilial("SM4")+cFormula))
If Found()
	cForm := AllTrim(M4_FORMULA)
	xValor := &cForm
Else
	xValor := NIL
EndIf

RestArea(aArea)

Return xValor

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RetEmails �Autor  �Marcelo Abve        � Data �  12/06/00   ���
�������������������������������������������������������������������������͹��
���Desc.     �Retorna informacoes sobre os usuarios do grupo              ���
���          �Params : Nome do Grupo                                      ���
���          �Params : Nome do Cargo(Filtro)                              ���
���          �Params : Nome do Departamento(Filtro)                       ���
�������������������������������������������������������������������������͹��
���Uso       � AP5                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function gEmails(cNomeGrupo,cCargo,cDepart)
Local aGroups  := AllGroups(),aUsers  := AllUsers(.T.),i,j,cCodGrupo,cReturn := '' 	

cNomeGrupo := Upper(cNomeGrupo)   
    
//Pego o Codigo do Grupo
For i:=1 To Len(aGroups)
	If Upper(aGroups[i][1][2]) = cNomeGrupo 
		cCodGrupo := aGroups[i][1][1] 
	    Exit
	Endif
Next i
	
//Procuro os usuarios que pertencam ao grupo 
For i:=1 to Len(aUsers)
  For j:=1 to Len(aUsers[i][1][10])
     If aUsers[i][1][10][j] = cCodGrupo .And.;
        Alltrim(GetAdvFVal("SA3","A3_EMAIL",xFilial("SA3")+Alltrim(aUsers[i][1][1]),7,"")) <> ''
       If (cCargo <> nil .and. cDepart <> Nil) 
         If Upper(AllTrim(aUsers[i][1][13])) = Upper(cCargo) .and.;
   	        Upper(AllTrim(aUsers[i][1][12])) = Upper(cDepart)
      		//cReturn := cReturn + Alltrim(aUsers[i][1][14]) + ';'
      		cReturn := cReturn +;
      				   Alltrim(GetAdvFVal("SA3","A3_EMAIL",xFilial("SA3")+Alltrim(aUsers[i][1][1]),7,"")) + ';'         
    	 EndIf
  	   ElseIf ( cCargo = Nil .and. cDepart = Nil ) .or. ( cCargo <> Nil .and. Upper(AllTrim(aUsers[i][1][13])) = Upper(cCargo) ) .or.; 
     	      ( cDepart <> Nil .and. Upper(AllTrim(aUsers[i][1][12])) = Upper(cDepart) )
    	       cReturn := cReturn +;
    	                  Alltrim(GetAdvFVal("SA3","A3_EMAIL",xFilial("SA3")+Alltrim(aUsers[i][1][1]),7,"")) + ';'
       EndIf    
  	 EndIf
  Next j   
Next i 
   
If cReturn <> '' 
	cReturn := Subs(cReturn,1,Len(cReturn)-1)
EndIf
	   
Return cReturn

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �StrToArray  �Autor  �Eletromega� Data �  25/03/03           ���
�������������������������������������������������������������������������͹��
���Desc.     �Monta o texto conforme foi digitado pelo operador e quebra  ���
���          �as linhas no tamanho especificado sem cortar palavras e     ���
���          �devolve um array com os textos a serem impressos.           ���
�������������������������������������������������������������������������͹��
���Parametros� cString - O String a ser quebrado                          ���
���          � nTaM    - Tamanho maximo de colunas do texto               ���
�������������������������������������������������������������������������͹��
���Uso       � Generico                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function StrArray(cString,nTam)

//Local cString	:= MSMM(cCodigo,nTam)		// Carrega o memo da base de dados
Local nI		:= 0    					// Contador dos caracteres	
Local nJ		:= 0    					// Contador dos caracteres	
Local nL		:= 0						// Contador das linhas 
Local nC        := 0						// Contador dos caracteres
Local cLinha	:= ""						// Guarda a linha editada no campo memo
Local aLinhas	:= {}						// Array com o memo dividido em linhas
Local cLine     := ""						// Line sem Line Feed
Local lAchou    := .F.                      // Flag
Local nII		:= 0                        // 
Local nLL		:= 0

// Remove Line Feed from string
For nC := 1 To Len(cString)

	If (MsAscii(SubStr(cString,nC,1)) <> 10)  // Line Feed
		cLine += SubStr(cString,nC,1)
	EndIf 

Next

cString := cLine

For nI := 1 TO Len(cString)
	If (MsAscii(SubStr(cString,nI,1)) <> 13) .AND. (nL < nTam) // MsAscii
		// Enquanto n�o houve enter na digitacao e a linha nao atingiu o tamanho maximo
			cLinha+=SubStr(cString,nI,1)
			nL++
	Else    
		// Se a linha atingiu o tamanho maximo ela vai entrar no array
		If MsAscii(SubStr(cString,nI,1)) <> 13
			nI--
			nII := nI 
			nLL := nL
			For nJ := Len(cLinha) To 1 Step -1
				// Verifica se a ultima palavra da linha foi quebrada, entao retira e passa pra frente
				If SubStr(cLinha,nJ,1) <> " " //.And. nJ < 15  
					nII--
					nLL--
				Else
					lAchou := .T.
					Exit
				Endif
			Next nJ
			
			If lAchou
				nI := nII 
				nL := nLL
				lAchou := .F.
			EndIf
			// Se a palavra for maior que o tamanho maximo entao ela vai ser quebrada
			If nL <=0
				nL := Len(cLinha)
			Endif
		Endif
		
		// Testa o valor de nL para proteger o fonte e insere a linha no array
		If nL >= 0
			cLinha := SubStr(cLinha,1,nL)
			AAdd(aLinhas, Trim(cLinha))
			cLinha := ""
			nL := 0
		Endif	
	Endif
Next nI

// Se o nL > 0, e porque o usuario nao deu enter no fim do memo e eu adiciono a linha no array.
If nL >= 0
	cLinha := SubStr(cLinha,1,nL)
	AAdd(aLinhas, cLinha)
	cLinha := ""
	nL := 0
Endif	

Return(aLinhas)

// Get email vendedor/do seu suopervisor/de seu gerente

User FUNCTION getEmls(cCodVend)
Local cEmails 	:= ''
Local dDtSaida  := ''
Local _cEmlVend	:= ''
Local _cEmlSuper:= ''
Local _cEmlGer	:= ''
Local aAreaSA3  := SA3->(GetArea())

If SA3->(dbSeek(xFilial('SA3') + cCodVend))
	_cEmlVend  := IIF(Empty(SA3->A3_UDTSAID),Alltrim(SA3->A3_EMAIL),'') 
	dDtSaida := Alltrim(GetAdvFVal("SA3","A3_UDTSAID",xFilial("SA3")+SA3->A3_SUPER,1,""))
	If Empty(dDtSaida)
		_cEmlSuper := Alltrim(GetAdvFVal("SA3","A3_EMAIL",xFilial("SA3")+SA3->A3_SUPER,1,""))
	EndIf
	dDtSaida := Alltrim(GetAdvFVal("SA3","A3_UDTSAID",xFilial("SA3")+SA3->A3_SUPER,1,""))
	If Empty(dDtSaida)
		_cEmlGer := Alltrim(GetAdvFVal("SA3","A3_EMAIL",xFilial("SA3")+SA3->A3_GEREN,1,""))
	EndIf
EndIf

If !Empty(_cEmlVend)
	cEmails := _cEmlVend 
EndIf

If !Empty(_cEmlSuper)
	If Empty(cEmails)
		cEmails := _cEmlSuper
	Else
		cEmails += ';' + _cEmlSuper
	EndIf
EndIf
  
If !Empty(_cEmlGer)
	If Empty(cEmails)
		cEmails := _cEmlGer
	Else
		cEmails += ';' + _cEmlGer
	EndIf
EndIf

RestArea(aAreaSA3)
Return (cEmails)

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �vldEmail   �Autor  �Eletromega          � Data �  28/09/12  ���
�������������������������������������������������������������������������͹��
���Desc.     � vldEmail (cEmail) --> URET                                 ���
���          � Retorno .T./.F.                                            ��� 
���          � Verificar se o e-mail esta valido                          ���
���          �                                                            ���
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function vldEml(cEmail)
Local lRet	:= .F.
Local cTemp	:= ""
Local nAt   := 0

If !Empty(cEmail)
	While .T.
		cEmail := RTRIM(cEmail) 
		nAt := At(";",cEmail) 
	   	//cRet   := IF(nPoSep#0, LEFT(cString,nPoSep-If(nTam>0,0,1))+"','", cString)
	   	If nAt#0 
	   		cTemp := Left(cEmail,nAt-1) 	
	   		lRet := IsEmail(cTemp)
	   		If !lRet
	   			Exit
	   		EndIf 
		   	cEmail := SUBSTR(cEmail,nAt+1)
		Else
    		lRet := IsEmail(cEmail)
    		Exit
    	EndIf
	EndDo
EndIf 
Return (lRet)

// Get email vendedor/do seu suopervisor/de seu gerente
//
//
//
User FUNCTION gEmlVds()
Local _cLst 	:= ''
Local _cQuery   := ''

If Select("EML") > 0
	DbSelectArea("EML")
	EML->(DbCloseArea())
EndIf

_cQuery := " SELECT RTRIM(A3_EMAIL) As Email  "
_cQuery += " FROM " + RetSqlName("SA3") + " SA3 "
_cQuery += " WHERE SA3.D_E_L_E_T_ <> '*' " 
_cQuery += " AND A3_XWKFLW = 'S' AND A3_UDTSAID = ' ' "
_cQuery += " AND A3_EMAIL <> ' ' "
_cQuery += " AND SA3.A3_FILIAL = '" + xFilial("SA3") + "' "
_cQuery += " ORDER BY A3_COD "

//MEMOWRITE("E:\TESTESQL3.SQL",_cQuery)
      
dbUseArea( .T., "TOPCONN", TCGENQRY(,,_cQuery), 'EML' )
      
While EML->(!Eof())
	_cLst += EML->Email + ';'
   	EML->(dBSkip())
EndDo
      
EML->(DbCloseArea())

_cLst := SUBSTR(_cLst,1,LEN(_cLst)-1)

Return (_cLst)

  