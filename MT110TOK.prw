#INCLUDE "PROTHEUS.CH"

/*苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北? Programa ? MT110TOK() ? Autor ? Claudino P Domingues ? Data ? 16/01/14 罕?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北? Funcao Padrao ? MATA110                                                罕?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北? Desc.    ? Ponto de entrada que valida se foi digitado o departamento  罕?
北?          ? na SC.                                                      罕?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌*/

User Function MT110TOK()

//Local _nPosDep := aScan(aHeader,{|x| AllTrim(x[2]) == "C1_XDEPART"})
Local _lRet    := .T.
Local nlx	   := 0
Local nPesBru  := 0
Local nCubTot  := 0
Local nxCUBAGE := aScan(aHeader,{|x| AllTrim(x[2])=="C1_XCUBAGE"})
Local nxPESBRU := aScan(aHeader,{|x| AllTrim(x[2])=="C1_XPESBRU"})
Local cDeptoSC := SuperGetMv("FS_VLSCIMP",.F.,"")

For nlx := 1 to Len(aCols)
	If !aCols[nlx][Len(aCols[nlx])]
		nPesBru += aCols[nlx][nxPESBRU]
		nCubTot += aCols[nlx][nxCUBAGE]
	EndIf
Next

_nVolCubado	:= nCubTot
_xPesBru	:= nPesBru

//U_OURO032(@_lRet)   // war 17/02/2020

//If Empty(aCols[n][_nPosDep])
If Empty(_cDepSC1)
	ApMsgStop("Por favor informar o departamento no cabe鏰lho da SC", "MT110TOK" )
	_lRet := .F.
EndIf

//Rodrigo Nunes
//Rotina para busca do melhor container
If _lRet .AND. _cDepSC1 $ cDeptoSC
	_lRet := U_OURO007(.T.)
EndIf

Return(_lRet)
