#INCLUDE "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ _getFormula  ณ Autor ณ Eletromega        ณ Data ณ 10/11/92 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Interpreta formula cadastrada                              ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ xExp1:= Formula(cExp1,nExp2)                               ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ xExp1:= Retorna formula iterpretada                        ณฑฑ
ฑฑณ          ณ cExp1:= Codigo da formula previamente cadastrada em SM4    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ GENERICO                                                   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User FUNCTION getForml(cFormula)

Local aArea, cForm:=" ", xValor
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSalva a integridade dos dados                                         ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRetEmails บAutor  ณMarcelo Abve        บ Data ณ  12/06/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna informacoes sobre os usuarios do grupo              บฑฑ
ฑฑบ          ณParams : Nome do Grupo                                      บฑฑ
ฑฑบ          ณParams : Nome do Cargo(Filtro)                              บฑฑ
ฑฑบ          ณParams : Nome do Departamento(Filtro)                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณStrToArray  บAutor  ณEletromegaบ Data ณ  25/03/03           บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta o texto conforme foi digitado pelo operador e quebra  บฑฑ
ฑฑบ          ณas linhas no tamanho especificado sem cortar palavras e     บฑฑ
ฑฑบ          ณdevolve um array com os textos a serem impressos.           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cString - O String a ser quebrado                          บฑฑ
ฑฑบ          ณ nTaM    - Tamanho maximo de colunas do texto               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Generico                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
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
		// Enquanto nใo houve enter na digitacao e a linha nao atingiu o tamanho maximo
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
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณvldEmail   บAutor  ณEletromega          บ Data ณ  28/09/12  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ vldEmail (cEmail) --> URET                                 บฑฑ
ฑฑบ          ณ Retorno .T./.F.                                            บฑฑ 
ฑฑบ          ณ Verificar se o e-mail esta valido                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
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

  