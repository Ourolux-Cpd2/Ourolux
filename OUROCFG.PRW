#Include "Protheus.ch"
#Include "RwMake.ch"
#Include "TopConn.ch"

User Function OUROCFG()        

Local _aEscolha := {"Menu X Usuarios","Usuarios X Acessos","Grupos"}
Local _cEscolha	:= ""
Local _nI		:= 0

oDlg := MSDialog():New(10,10,100,300,"Adar",,,,,,,,,.T.)

	oEsc  := tSay():New(05,03,{|| "Escolha: "},oDlg,,,,,,.T.,,,,)
	oCbo  := tComboBox():New(04,26,{|u|if(PCount()>0,_cEscolha:=u,_cEscolha)},_aEscolha,115,10,oDlg,,,,,,.T.,,,,,,,,,"_cEscolha")
    
	oBtn1 :=tButton():New(30,076,"Ok",oDlg,{|| TELA(oCbo:NAT,_cEscolha)},30,15,,,,.T.)
	oBtn2 :=tButton():New(30,111,"Sair",oDlg,{|| oDlg:End()},30,15,,,,.T.)
	
oDlg:Activate(,,,.T.,,,)

Return

Static Function TELA(_nOpc,_cEscolha)

Local _nTelaV 	:= 145
Local _nTelaH 	:= 300
Local _cName	:= Space(50)
Local _cSave	:= ""

oDlg1 := MSDialog():New(10,10,_nTelaV,_nTelaH,"Adar - " + AllTrim(_cEscolha),,,,,,,,,.T.)

	oSave := tSay():New(05,03,{|| "Salvar: "},oDlg1,,,,,,.T.,,,,)
	oSalv := TGet():New(04,26,{|u| if(PCount()>0,_cSave:=u,_cSave)},oDlg1,100,10,,,,,,,,.T.,,,{|| .F.},,,,,,,"_cSave")
	oBtn1 :=tButton():New(04,130,"...",oDlg1,{|| SAVE(@_cSave,.F.)},13,13,,,,.T.)
	
	oNome := tSay():New(25,03,{|| "Nome Arq: "},oDlg1,,,,,,.T.,,,,)
	oName := TGet():New(24,40,{|u| if(PCount()>0,_cName:=u,_cName)},oDlg1,103,10,"@!",,,,,,,.T.,,,,,,,,,,"_cName")
	    
	oBtn7 :=tButton():New(45,076,"Ok",oDlg1,{|| ADAR(_nOpc,_cSave,_cName)},30,15,,,,.T.)
	oBtn8 :=tButton():New(45,111,"Sair",oDlg1,{|| oDlg1:End()},30,15,,,,.T.)
	
oDlg1:Activate(,,,.T.,,,)

Return

Static Function SAVE(_cDir,_lOpc)

If _lOpc
	_cDir := AllTrim(Upper(cGetFile("RPO ( *.rpo ) |*.rpo|","Selecione o Diretorio",,,_lOpc,GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE)))
Else
	_cDir := AllTrim(Upper(cGetFile("Todos arquivos ( *.* ) |*.*|","Selecione o Diretorio",,,_lOpc,GETF_RETDIRECTORY+GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE)))
Endif

Return

Static Function ADAR(_nOpc,_cSave,_cName)

If !Empty(_cSave) .And. !Empty(_cName) .And. _nOpc <> 3
	oProcess := MsNewProcess():New({|| MONTAEXCEL(_nOpc,_cSave,_cName)},"Processando...","Lendo...",.T.)
	oProcess:Activate()
Elseif !Empty(_cSave) .And. !Empty(_cName) .And. _nOpc == 3
	Processa({|| MONTAEXCEL(_nOpc,_cSave,_cName)}, "Processando...")
Endif

Return

Static Function MONTAEXCEL(_nOpc,_cSave,_cName)

Local _aUsers	:= {}
Local _aMenus	:= {}
Local _aMenuUser:= {}
Local _aUserMenu:= {}
Local _aGrupos	:= {}
Local _aUsuarios:= {}
Local _aTodoGrp	:= {}
Local _cCaminho	:= AllTrim(Upper(GetSrvProfString("StartPath","")))
Local _nI		:= 0
Local _nX		:= 0
Local _nPos		:= 0

If _nOpc == 1 //Menu X Usuarios
	_aUsers	:= U_UserUnlock(AllUsers())
	
	_aMenus := Directory(_cCaminho+"\*.xnu")
	
	oProcess:SetRegua1(Len(_aMenus))
	
	For _nI := 1 To Len(_aMenus)
		oProcess:IncRegua1("Lendo Menu: " + AllTrim(_aMenus[_nI,1]))
		
		oProcess:SetRegua2(Len(_aUsers))
		
		For _nX := 1 To Len(_aUsers)
			oProcess:IncRegua2("Lendo Usuario: " + AllTrim(_aUsers[_nX,1,2]))
			
			_aMenuUser := u_MenuUser(_aUsers[_nX,3])
			
			If Len(_aMenuUser) > 0
				If aScan(_aMenuUser,{|x| x == AllTrim(Upper(_aMenus[_nI,1]))}) > 0
					_nPos := aScan(_aUserMenu,{|x| x[1] == AllTrim(Upper(_aMenus[_nI,1]))})
					If _nPos == 0
						aAdd(_aUserMenu,{AllTrim(Upper(_aMenus[_nI,1])),AllTrim(_aUsers[_nX,1,2])})
					Else
						_aUserMenu[_nPos,2] += "|"+	AllTrim(_aUsers[_nX,1,2])
					Endif
				Endif
			Endif
		Next _nX
	Next _nI
    
	If Len(_aUserMenu) > 0
		IMPRIMIEXC(_nOpc,_aUserMenu,_cSave,_cName)
	Endif
ElseIf _nOpc == 2
	_aUsers	:= U_UserUnlock(AllUsers())
	
	oProcess:SetRegua1(Len(_aUsers))
	
	For _nI := 2 To Len(_aUsers)
		oProcess:IncRegua1("Lendo Usuario: " + AllTrim(_aUsers[_nI,1,2]))
		
		_aMenuUser := u_MenuUser(_aUsers[_nI,3])
		
		oProcess:SetRegua2(Len(_aMenuUser))
		
		For _nX := 1 To Len(_aMenuUser)
			oProcess:IncRegua2("Lendo Menu: " + AllTrim(_aMenuUser[_nX]))
			
			If Len(_aUsuarios) == 0
				aAdd(_aUsuarios,{AllTrim(_aUsers[_nI,1,2]),AllTrim(_aMenuUser[_nX]),"",UsrRetName(AllTrim(_aUsers[_nI,1,11]))})
			Else
				_nPos := aScan(_aUsuarios,{|x| AllTrim(x[1]) == AllTrim(_aUsers[_nI,1,2])})
				If _nPos > 0
			   		_aUsuarios[_nPos,2] += "|" + AllTrim(_aMenuUser[_nX])
			 	Else
			 		aAdd(_aUsuarios,{AllTrim(_aUsers[_nI,1,2]),AllTrim(_aMenuUser[_nX]),"",UsrRetName(AllTrim(_aUsers[_nI,1,11]))})
				Endif
			Endif
		Next _nX
				
		_aGrupos := UsrRetGrp(_aUsers[_nI,1,2])
		
		oProcess:SetRegua2(Len(_aGrupos))
		
		For _nX := 1 To Len(_aGrupos)
			oProcess:IncRegua2("Lendo Grupo: " + AllTrim(_aGrupos[_nX]))
			
			_nPos := aScan(_aUsuarios,{|x| AllTrim(x[1]) == AllTrim(_aUsers[_nI,1,2])})
			If _nPos > 0
				If Empty(_aUsuarios[_nPos,3])
					_aUsuarios[_nPos,3] := AllTrim(_aGrupos[_nX]) + " - " + AllTrim(GrpRetName(_aGrupos[_nX]))
				Else
			   		_aUsuarios[_nPos,3] += "|" + AllTrim(_aGrupos[_nX]) + " - " + AllTrim(GrpRetName(_aGrupos[_nX]))
			 	Endif
			Endif	
		Next _nX
	Next _nI
	
	If Len(_aUsuarios) > 0
		IMPRIMIEXC(_nOpc,_aUsuarios,_cSave,_cName)
	Endif
Elseif _nOpc == 3
	_aGrupos := AllGroups()
	
	ProcRegua(Len(_aGrupos))
	For _nI := 1 To Len(_aGrupos)
		IncProc("Grupo: " + AllTrim(_aGrupos[_nI,1,1]) + " - " + AllTrim(_aGrupos[_nI,1,2]))
		
		aAdd(_aTodoGrp,{AllTrim(_aGrupos[_nI,1,1]),AllTrim(_aGrupos[_nI,1,2])})
	Next _nI
	
	If Len(_aTodoGrp) > 0
		IMPRIMIEXC(_nOpc,_aTodoGrp,_cSave,_cName)
	Endif
Endif

Return

Static Function IMPRIMIEXC(_nOpc,_aImprimi,_cSave,_cName)

Local _nHandle  := 0
Local _cArq	 	:= Upper(AllTrim(_cSave)+AllTrim(_cName)+".csv")
Local _cText	:= ""
Local _nI		:= 0
Local _nX		:= 0
Local _nMaiorM	:= 0
Local _nMaiorG	:= 0
Local _aUser	:= {}
Local _aMenu	:= {}
Local _aGrupo	:= {}

If File(_cArq)
	fErase(_cArq)
Endif

_nHandle := FCREATE(_cArq,0)   

If FERROR() != 0
	Alert("Não foi possível abrir ou criar o arquivo: " + _cArq)
EndIf

If _nOpc == 1
	
	For _nI := 1 To Len(_aImprimi)
		_cText := " MENU:  " + AllTrim(Upper(_aImprimi[_nI,1]))
		
		_aUser := Separa(_aImprimi[_nI,2],"|")
		If Len(_aUser) > 0
			For _nX := 1 To Len(_aUser)
				If _nX == 1
					_cText += " ; USUARIOS" + CRLF + " ; " + AllTrim(Upper(_aUser[_nX]))
				Else
					_cText += CRLF + " ; " + AllTrim(Upper(_aUser[_nX]))
				Endif
			Next _nX
			_cText += CRLF + "-------------------------------------" + CRLF
		Else
			_cText += CRLF + "-------------------------------------" + CRLF
		Endif
		FWRITE(_nHandle,_cText)
	Next _nI
Elseif _nOpc == 2
	For _nI := 1 To Len(_aImprimi)
		_aMenu 	:= Separa(_aImprimi[_nI,2],"|")
		_aGrupo	:= Separa(_aImprimi[_nI,3],"|")
		
		_nMaiorM := Len(_aMenu)
		_nMaiorG := Len(_aGrupo)
		
		If _nMaiorM >= _nMaiorG
			For _nX := 1 To Len(_aMenu)
				If Empty(_cText)
					_cText := "USUARIO ; MENU ; GRUPOS ; SUPERIOR" + CRLF
					_cText += AllTrim(_aImprimi[_nI,1]) + " ; " + AllTrim(_aMenu[_nX]) + " ; " + Iif(_nX <= _nMaiorG,AllTrim(_aGrupo[_nX]),"") + " ; " + AllTrim(_aImprimi[_nI,4])
				Else
					_cText += CRLF + " ; " + AllTrim(_aMenu[_nX]) + " ; " + Iif(_nX <= _nMaiorG,AllTrim(_aGrupo[_nX]),"")
				Endif
			Next _nX
			_cText += CRLF
		Elseif _nMaiorG >= _nMaiorM
			For _nX := 1 To Len(_aGrupo)
				If Empty(_cText)
					_cText := "USUARIO ; MENU ; GRUPOS ; SUPERIOR" + CRLF
					_cText += AllTrim(_aImprimi[_nI,1]) + " ; " + Iif(_nX <= _nMaiorM,AllTrim(_aMenu[_nX]),"") + " ; " + AllTrim(_aGrupo[_nX]) + " ; " + AllTrim(_aImprimi[_nI,4])
				Else
					_cText += CRLF + " ; " + Iif(_nX <= _nMaiorM,AllTrim(_aMenu[_nX]),"") + " ; " + AllTrim(_aGrupo[_nX])
				Endif
			Next _nX
			_cText += CRLF
		Endif
		_cText += CRLF
		FWRITE(_nHandle,_cText)
		_cText := ""
	Next _nI
Elseif _nOpc == 3
	For _nI := 1 To Len(_aImprimi)
		If Empty(_cText)
			_cText := "GRUPO ; DESCRIÇÃO" + CRLF
			_cText += "'" + AllTrim(_aImprimi[_nI,1]) + " ; " + AllTrim(_aImprimi[_nI,2]) + CRLF
		Else
			_cText += "'" + AllTrim(_aImprimi[_nI,1]) + " ; " + AllTrim(_aImprimi[_nI,2]) + CRLF
		Endif
	Next _nI
	FWRITE(_nHandle,_cText)
Endif

fCLose(_nHandle)
	
ShellExecute("open",_cArq,"","",0)  
	
Return

User Function MenuUser(_aMenus)

Local _nI 		:= 0
Local _cMenu	:= ""
Local _aAux		:= {}

For _nI := 1 To Len(_aMenus)
	
	_cMenu := AllTrim(Upper(_aMenus[_nI]))
	
	If SubStr(_cMenu,3,1) <> "X" .And. "\SYSTEM\" $ _cMenu
		aAdd(_aAux,AllTrim(Upper(Separa(_cMenu,"\")[Len(Separa(_cMenu,"\"))])))
	Endif
Next _nI

Return _aAux

User Function UserUnlock(_aUsers) 

Local _nI		:= 0
Local _aAux1 	:= {}

For _nI := 1 To Len(_aUsers)
	If !_aUsers[_nI,1,17]
		aAdd(_aAux1,_aUsers[_nI])
	Endif
Next _nI

Return _aAux1