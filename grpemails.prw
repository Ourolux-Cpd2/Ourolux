/*/{Protheus.doc} GrpEmail
//TODO Envio de Workflows utilizando o agrupamento de usuário (Grupo de usuários)

@author Maurício Aureliano
@since 23/09/2019
@version 1.0
@return nil

@obs Codificação original encontra-se no final desse fonte, comentado!

@type function
/*/

User Function GrpEmail(_cGrupoMail)

	Local nx
	Local aAllusers := FWSFALLUSERS()
	Local aGrupos 	:= {}
	Local cRetEmail	:= "" 

	// Local t1 := Time()
	// Local t2 := 0

	// De - Para TEMPORÁRIO
	If _cGrupoMail == 'Administradores'
		_cGrupoMail := '000000'
	ElseIf _cGrupoMail == 'Vendas'	
		_cGrupoMail := '000001'
	ElseIf _cGrupoMail == 'Contas'	
		_cGrupoMail := '000002'
	ElseIf _cGrupoMail == 'Repres'	
		_cGrupoMail := '000003'
	ElseIf _cGrupoMail == 'Clientes'
		_cGrupoMail := '000004'
	ElseIf _cGrupoMail == 'Exclusao'	
		_cGrupoMail := '000005'
	ElseIf _cGrupoMail == 'Devolucao'	
		_cGrupoMail := '000006'
	ElseIf _cGrupoMail == 'AltTes'	
		_cGrupoMail := '000007'
	ElseIf _cGrupoMail == 'EstLim'	
		_cGrupoMail := '000008'
	ElseIf _cGrupoMail == 'Direto'	
		_cGrupoMail := '000009'
	ElseIf _cGrupoMail == 'NoFilter'	
		_cGrupoMail := '000010'
	ElseIf _cGrupoMail == 'NoFilterCondPgt'	
		_cGrupoMail := '000011'
	ElseIf _cGrupoMail == 'AltPed'	
		_cGrupoMail := '000012'
	ElseIf _cGrupoMail == 'ExcluirNFEntrada'	
		_cGrupoMail := '000013'
	ElseIf _cGrupoMail == 'Retira'	
		_cGrupoMail := '000014'
	ElseIf _cGrupoMail == 'WFENTRADA'	
		_cGrupoMail := '000015'
	ElseIf _cGrupoMail == 'ALTTESPED'	
		_cGrupoMail := '000016'
	ElseIf _cGrupoMail == 'NoVldEmb'	
		_cGrupoMail := '000017'
	ElseIf _cGrupoMail == 'Rejeitado'	
		_cGrupoMail := '000018'
	ElseIf _cGrupoMail == 'GRPEICPA'	
		_cGrupoMail := '000019'
	ElseIf _cGrupoMail == 'Transf2'	
		_cGrupoMail := '000020'
	ElseIf _cGrupoMail == 'WFWDIR'	
		_cGrupoMail := '000021'
	ElseIf _cGrupoMail == 'WFWCQ'	
		_cGrupoMail := '000022'
	ElseIf _cGrupoMail == 'RFATSCH'	
		_cGrupoMail := '000023'
	ElseIf _cGrupoMail == 'WFWREJIE'	
		_cGrupoMail := '000024'
	ElseIf _cGrupoMail == 'WFTST'	
		_cGrupoMail := '000025'
	ElseIf _cGrupoMail == 'ACD'	
		_cGrupoMail := '000030'
	ElseIf _cGrupoMail == 'Repres_01'	
		_cGrupoMail := '000031'
	ElseIf _cGrupoMail == 'Repres_02'	
		_cGrupoMail := '000032'
	ElseIf _cGrupoMail == 'Repres_03'	
		_cGrupoMail := '000033'
	ElseIf _cGrupoMail == 'Repres_04'	
		_cGrupoMail := '000034'
	ElseIf _cGrupoMail == 'Repres_05'	
		_cGrupoMail := '000035'
	ElseIf _cGrupoMail == 'Repres_06'	
		_cGrupoMail := '000036'
	ElseIf _cGrupoMail == 'Repres_07'	
		_cGrupoMail := '000037'
	ElseIf _cGrupoMail == 'Repres_08'	
		_cGrupoMail := '000038'
	ElseIf _cGrupoMail == 'Repres_09'	
		_cGrupoMail := '000039'
	ElseIf _cGrupoMail == 'Repres_10'	
		_cGrupoMail := '000040'
	ElseIf _cGrupoMail == 'WFTRANSF'	
		_cGrupoMail := '000042'
	ElseIf _cGrupoMail == 'ACD_SC'	
		_cGrupoMail := '000043'
	ElseIf _cGrupoMail == 'WFDEVFAT'	
		_cGrupoMail := '000044'
	ElseIf _cGrupoMail == 'REPRE_CLI_ESPELHO'	
		_cGrupoMail := '000045'
	EndIf


	For nx := 1 To Len(aAllusers)

		aGrupos := UsrRetGrp(,aAllusers[nx][2])

		If Ascan(aGrupos, {|x| Alltrim(Upper(x)) == Alltrim(upper(_cGrupoMail)) }) > 0
			If !Empty(Trim(aAllusers[nx][5]))
				cRetEmail := cRetEmail + Trim(aAllusers[nx][5]) + ";"
			EndIf
		Endif

	Next

	// t2 := Time()

	// MemoWrite("C:\Siga\leemail_time.txt",t1 + ' até ' + t2)

	// MemoWrite("C:\Siga\leemail.txt",cRetEmail)

Return cRetEmail


// ------------------------------------------------------------------------
// Codificação original
// ------------------------------------------------------------------------
// MOA - 23/09/2019 - 13:14hs
// Alterado devido substituição da função AllUsers()
//     pela função FWSFALLUSERS()
// ------------------------------------------------------------------------

/*
#include "protheus.ch"

User Function GrpEmail(cNomeGrupo)
Local t1 := Time(), t2 := 0, t3:= 0
Local aGroups := AllGroups(),aUsers  := AllUsers(.T.),i,j,cReturn := '' 	
Local aCodGrupo := {} 

    
//Codigo do Grupo
/*
For i:=1 To Len(aGroups)
   For j:= 1 To Len(aNomeGrupo)
   		if Upper(rTrim(aGroups[i][1][2])) == Upper(aNomeGrupo[j]) 
     		AADD(aCodGrupo,aGroups[i][1][1]) 
   		endif
   Next j
Next i
*/

/*
// Claudino 15/04/15
//Pego o Codigo do Grupo
For i:=1 To Len(aGroups)
	If Alltrim(Upper(aGroups[i][1][2])) == Alltrim(Upper(cNomeGrupo)) 
		AADD(aCodGrupo,aGroups[i][1][1]) 
	    Exit
	Endif
Next i
	
//Usuarios que pertencam ao grupo 
For i:=1 to Len(aUsers)
  If !aUsers[i][1][17]
  	For j:=1 to Len(aUsers[i][1][10])
     	For k:= 1 to Len(aCodGrupo) 
     		if aUsers[i][1][10][j] = rTrim(aCodGrupo[k]) .and. AllTrim(aUsers[i][1][14]) <> ''
		   		cReturn := cReturn + Alltrim(aUsers[i][1][14]) + ';'
     		endif
     	Next k
  	Next j   
  EndIf
Next i 
   
if cReturn <> '' 
	cReturn := Subs(cReturn,1,Len(cReturn)-1)
endif

t2 := Time()
MemoWrite("C:\Siga\grpemail_time.txt",t1 + ' até ' + t2)

MemoWrite("C:\Siga\grpemail.txt",cReturn)
	   
Return cReturn
*/