#Include 'Protheus.ch'
#include "Fileio.ch"

/*/{Protheus.doc} CBEXPTXT
(long_description)
@author thiago.reis
@since 25/09/2015
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/

User Function CBEXPTXT()

	Local _cTitulo 		:= "Exportação Prosoft"
	Local _aTexto		:= {}
	Local _cAlias 		:= GetNextAlias()
	Local _cEmpresa 	:= "99"
	Local _cFilial 		:= "01"
	Local aOpenTable    := {"SX1"}
	
	Private _lretBatch	:= .F.
	Private _cPerg01	:= "CBEXPTXT"
	Private _aButton	:= {}
		
	
//	RPCSetType(3)
//	RPCSetEnv(_cEmpresa,_cFilial,"","","","",aOpenTable) // Abre todas as tabelas.

//	Public __cInterNet := Nil

	CriaSx1(_cPerg01)

	aadd(_aTexto, 'Esse programa irá gerar arquivo texto para exportação ')
	aadd(_aTexto, 'dos lançamentos contábeis para o sistema Prosoft')

	aadd(_aButton, { 5, .T., {|| Pergunte(_cPerg01,.T.)			}})
	aadd(_aButton, { 1, .T., {|| _lretBatch := .T.,FechaBatch() }})
	aadd(_aButton, { 2, .T., {|| _lretBatch := .F.,FechaBatch() }})
	
	FormBatch( _cTitulo, _aTexto, _aButton)
	
	If _lretBatch
		Pergunte(_cPerg01,.F.)
		Processa({|| CBExp2Tx(_cAlias,_cPerg01) },"Aguarde...","Gerando arquivo texto...")
	End


//	RpcClearEnv()

Return


//Função para criar o arquivo Txt

/*/{Protheus.doc} FunctionCBExp2Tx
(long_description)
@author thiago.reis
@since 25/09/2015
@version 1.0
@param _cAlias, ${param_type}, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/

Static Function	CBExp2Tx(_cAlias,_cPerg01)

	Local _cCodEmp		:= "9999"
	Local _cFileName 	:= "CTBLCTOS"+_cCodEmp+ dtos(MV_PAR01)+ dtos(MV_PAR02)+".txt"
	Local _cLocal		:= alltrim(MV_PAR03)
	Local _cLFile
	Local _cFile		:= ''
	Local _xVarTmp 		:= ""
	Local _cAlias 		:= GetNextAlias()
	Local _cAliasLin	:= GetNextAlias()
	Local _nHandle		:= 0
	Local _nCount		:= 0
	Local _cHist		:= ""
		
	if substr(_cLocal,len(_cLocal),1) <> '\'
		_cLocal += '\'
	Endif
	_cLFile  := _cLocal + _cFileName
	
	_nHandle :=	FCreate(_cLFile)

	if _nHandle == -1
		MsgAlert('Erro de gravação do arquivo no disco.')
	Else

 // GRAVA CAMPOS NO ARQUIVO TXT
	
		ExecQry(_cPerg01, _cAlias)

		ProcRegua((_cAlias)->(reccount() ) )

		(_cAlias)->(dbGotop())
		While ! (_cAlias)->(eof())

			IncProc()
			
			_cTipo := (_cAlias)->CT2_DC
			
			_cFile 	+= "LC1" 					 				 //01 - TIPO   									(tamanho:3)
			
			_nCount += 1
			_cOrdem := strzero(_nCount ,5)
			_cFile 	+= _cOrdem									 //02 - ORDEM 									(tamanho:5)
			_cFile 	+= SPACE(3)									 //03 - FILLER									(tamanho:3)
			_cFile 	+= iif(_cTipo == '3','1', '2') 									 	 //04 - MODO DE LANÇAMENTO (1 - SIMPLES  / 2-detalhado)	(tamanho:1)
			
			_xVarTmp := (_cAlias)->CT2_DATA					 	//05 - DATA DA ESCRITURAÇÃO						(tamanho:8)
			_xVarTmp := FormatDate(_xVarTmp,'DATA',8 )
			_cFile 	+= _xVarTmp
			
			_xVarTmp := (_cAlias)->DOC							 //06 - NÚMERO DO DOCUMENTO						(tamanho:10)
			_xVarTmp := FormatDate(_xVarTmp,'X',10)
			_cFile 	+= _xVarTmp
						
			_xVarTmp := substr((_cAlias)->LOTE,2,5)				 //07 - NÚMERO DO LOTE							(tamanho:5)
			_xVarTmp := FormatDate(_xVarTmp,'N',5)
			_cFile 	+= _xVarTmp
			
			_xVarTmp := (_cAlias)->ORIGEM						 //08 - ORIGEM DO LANÇAMENTO					(tamanho:30)
			_xVarTmp := FormatDate(_xVarTmp,'X',30)
			_cFile 	+= _xVarTmp


											 	 

			
			
			//___________________
			if _cTipo <> '3'
			
				_xVarTmp := somaContas(_cAlias)
				_xVarTmp := alltrim(str(_xVarTmp))			
				_cFile 	+= FormatDate(_xVarTmp,'N',3)					//09 - QUANTIDADE DE CONTA 					(tamanho:3)
			
			Else
			
				_cFile += space(3)										//09 - QUANTIDADE DE CONTA 					(tamanho:3)
				
				_xVarTmp := (_cAlias)->DB_CODPROS					 //10 - CONTA DÉBITO - CÓDIGO DE ACESSO			(tamanho:5)
				_xVarTmp := FormatDate(_xVarTmp,'N',5)
				_cFile 	+= _xVarTmp
			
				_cFile 	+= space(14)  //(_cAlias)->DB_TERCEIR				 	 //11 - CONTA DÉBITO - TERCEIRO					(tamanho:14)
			
				_xVarTmp := space(5) //(_cAlias)->CCD							 //12 - CONTA DÉBITO - CENTRO DE CUSTO			(tamanho:5)
				_xVarTmp := FormatDate(_xVarTmp,'N',5)
				_cFile 	+= _xVarTmp
						
				_xVarTmp := (_cAlias)->CR_CODPROS			  		 //13 - CONTA CRÉDITO - CÓDIGO DE ACESSO		(tamanho:5)
				_xVarTmp := FormatDate(_xVarTmp,'N',5)
				_cFile 	+= _xVarTmp
			
				_cFile 	+= space(14) //(_cAlias)->CR_TERCEIR							 	 //14 - CONTA CRÉDITO - TERCEIRO				(tamanho:14)
			
				_xVarTmp := space(5) //(_cAlias)->CCC							 //15 - CONTA CRÉDITO - CENTRO DE CUSTO			(tamanho:5)
				_xVarTmp := FormatDate(_xVarTmp,'N',5)
				_cFile 	+= _xVarTmp
			
				_xVarTmp := (_cAlias)->CT2_VALOR					 //16 - VALOR DO LANÇAMENTO						(tamanho:16)
				_xVarTmp := FormatDate(_xVarTmp,'R$',16)
				_cFile 	+= _xVarTmp
	
				
				_cData := (_cAlias)->CT2_FILIAL + dtos((_cAlias)->CT2_DATA) + ALLTRIM((_cAlias)->LOTE) + ALLTRIM((_cAlias)->SBLOTE) + ALLTRIM((_cAlias)->DOC)

				_xVarTmp := (_cAlias)->HIST				 //17 - HISTÓRICO DO LANÇAMENTO
				_xVarTmp := alltrim(_xVarTmp)
				_xVarTmp := FormatDate(_xVarTmp,'X',240)
				_cFile += _xVarTmp
			
			Endif
			
			//__________________________________
			
			 
			_cFile 	+= SPACE(1) 							 	 //18 - INDICADOR CONCILIAÇÃO - CRÉDITO									(tamanho:1)
			_cFile 	+= SPACE(1) 							 	 //19 - INDICADOR CONCILIAÇÃO - DÉBITO									(tamanho:1)
			_cFile 	+= SPACE(74)			 				 	 //20 - FILLER															(tamanho:74)
			_cFile  := LTrim(_cFile) + chr(13)+ chr(10)
			
			FWRITE(_nHandle,_cFile) // GRAVA TEXTO
			_cFile := ''
			
			if _cTipo <> '3'
			
			//______________ LC2
				_nSeq := 0
				_cChave := (_cAlias)->(CT2_FILIAL + dtos(CT2_DATA) + LOTE + SBLOTE + DOC)

				While ! (_cAlias)->(eof()) .and. ;
						(_cAlias)->(CT2_FILIAL + dtos(CT2_DATA) + LOTE + SBLOTE + DOC ) = _cChave  .and. ;
						(_cAlias)->(CT2_DC) <> '3'
			
				
					_cTipo := (_cAlias)->CT2_DC
					_cFile := ''
				
					_cFile 	+= "LC2" 					 				//01 - TIPO   									(tamanho:3)
					_cFile 	+= _cOrdem									//02 - ORDEM 									(tamanho:5)
			
					_nSeq 	+= 1
					_xVarTmp := alltrim(str(_nSeq))				 		//03 - Sequencial de 001 até 200				(tamanho:3)
					_xVarTmp := FormatDate(_xVarTmp,'N',3)
					_cFile 	 += _xVarTmp
	
					_cFile 	 += iif(_cTipo == '1','D','C')				//04 - Débito ou Crédito  1 "D" ou "C"			(tamanho: 1)

					_xVarTmp := iif(_ctipo == '1', (_cAlias)->DB_CODPROS , (_cAlias)->CR_CODPROS )					 //05 - CÓDIGO DE ACESSO			(tamanho:5)
					_xVarTmp := FormatDate(_xVarTmp,'N',5)
					_cFile 	 += _xVarTmp

					_cFile 	 += iif(_cTipo == '1', (_cAlias)->DB_TERCEIR , (_cAlias)->CR_TERCEIR  )				 	 //06 - TERCEIRO	ou CNPJ/CPF		(tamanho:14)

					_xVarTmp := iif(_cTipo == '1','' /*(_cAlias)->CCD */, '' /*(_cAlias)->CCC*/ )									 //07 -  CENTRO DE CUSTO			(tamanho:5)
					_xVarTmp := FormatDate(_xVarTmp,'N',5)
					_cFile 	+= _xVarTmp

					_xVarTmp := (_cAlias)->CT2_VALOR					 //08 - VALOR DO LANÇAMENTO						(tamanho:16)
					_xVarTmp := FormatDate(_xVarTmp,'R$',16)
					_cFile 	+= _xVarTmp

					_xVarTmp := (_cAlias)->HIST				 			//09 - HISTÓRICO DO LANÇAMENTO                  (tamanho; 240 )
					_xVarTmp := alltrim(_xVarTmp)
					_xVarTmp := FormatDate(_xVarTmp,'X',240)
					_cFile += _xVarTmp

					_cFile 	+= SPACE(1) 							 	 //10 - INDICADOR CONCILIAÇÃO - CRÉDITO			(tamanho:1)
					_cFile 	+= SPACE(49)			 				 	 //11 - FILLER									(tamanho:49)
					_cFile  := LTrim(_cFile) + chr(13)+ chr(10)
			
					FWRITE(_nHandle,_cFile) // GRAVA TEXTO
					_cFile := ''
			
					(_cAlias)-> (dbSkip())
			
			
				End
	
			Else
				(_cAlias)-> (dbSkip())
	
			Endif
			//____________________
			
		End

		FCLOSE(_nHandle)
		(_cAlias)->(dbCloseArea())
	Endif

Return

/*/{Protheus.doc} ExecQry
(long_description)
@author thiago.reis
@since 25/09/2015
@version 1.0
@param _cPerg01, ${param_type}, (Descrição do parâmetro)
@param _cAlias, ${param_type}, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/

Static Function ExecQry(_cPerg01,_cAlias)
Local _aQuery := {}


	Pergunte(_cPerg01,.F.)

	BeginSql Alias _cAlias

		column CT2_DATA as Date
		column CT2_VALOR as numeric(14,2)

		%noparser%

		SELECT *
		FROM(
		SELECT
		CT2_DATA	,
		CT2_FILIAL	,
		CT2_DC		,
		CT2_VALOR	,
		CT2_LINHA	AS LINHA,
		CT2_LOTE	AS LOTE,
		CT2_SBLOTE	AS SBLOTE,
		CT2_DOC		AS DOC,
		CT2_DEBITO	AS DEBITO,
		CT2_CREDIT	AS CREDITO,
		CT2_CCD		AS CCD,
		CT2_CCC		AS CCC,
		CT2_HIST	AS HIST,
		CT2_ORIGEM 	AS ORIGEM
				
		FROM %Table:CT2% (NOLOCK)
		WHERE %NotDel%
		AND CT2_FILIAL = %xfilial:CT2%
		AND CT2_DATA BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
		AND CT2_DOC BETWEEN %Exp:MV_PAR04% AND %Exp:MV_PAR05%
		AND CT2_DC <> '4'
		
		)CT2

		LEFT JOIN(
		SELECT	ZZ_PROTHEU	AS DB_PROTHEU,
		ZZ_CODPROS	AS DB_CODPROS,
		ZZ_TERCEIR	AS DB_TERCEIR
		FROM %Table:SZZ% (NOLOCK)
		WHERE %NotDel%

		)SZZ_DEB
		
		ON DEBITO = DB_PROTHEU
		
		LEFT JOIN(
		SELECT	ZZ_PROTHEU	AS CR_PROTHEU,
		ZZ_CODPROS	AS CR_CODPROS,
		ZZ_TERCEIR	AS CR_TERCEIR
		FROM %Table:SZZ% (NOLOCK)
		WHERE %NotDel%
		)SZZ_CRE
		
		ON CREDITO = CR_PROTHEU
		
		ORDER BY CT2_FILIAL, CT2_DATA, LOTE, SBLOTE, DOC, LINHA

	EndSql

	_aQuery := GetLastQuery()

Return


/*/{Protheus.doc} CriaSX1
(long_description)
@author thiago.reis
@since 25/09/2015
@version 1.0
@param _cPerg, ${param_type}, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/

Static Function CriaSX1(_cPerg)

	Local _aArea := GetArea()
	Local _aPerg := {}

	_sAlias := Alias()
	dbSelectArea("SX1")
	dbSetOrder(1)
	_cPerg := padr(_cPerg,len(SX1->X1_GRUPO))

	Aadd(_aPerg, {_cPerg, "01",	"Da Data    	     			?", "mv_ch1",	"D", 08 , 0	, "G"		, "MV_PAR01", "" 	,"" ,"" ,""})
	Aadd(_aPerg, {_cPerg, "02",	"Ate Data  	        			?", "mv_ch2",	"D", 08 , 0	, "G"		, "MV_PAR02", "" 	,"" ,"" ,""})
	Aadd(_aPerg, {_cPerg, "03",	"Local para Gravar			 	?", "mv_ch3",	"C", 50 , 0	, "G"		, "MV_PAR03", "" 	,"" ,"" ,""})
	Aadd(_aPerg, {_cPerg, "04",	"Do Documento				 	?", "mv_ch4",	"C", 06 , 0	, "G"		, "MV_PAR04", "" 	,"" ,"" ,""})
	Aadd(_aPerg, {_cPerg, "05",	"Ate Documento				 	?", "mv_ch5",	"C", 06 , 0	, "G"		, "MV_PAR05", "" 	,"" ,"" ,""})

	DbSetOrder(1)

	For i := 1 To Len(_aPerg)
		IF  !DbSeek(_aPerg[i,1]+_aPerg[i,2])
			RecLock("SX1",.T.)
			Replace X1_GRUPO   with _aPerg[i,01]
			Replace X1_ORDEM   with _aPerg[i,02]
			Replace X1_PERGUNT with _aPerg[i,03]
			Replace X1_VARIAVL with _aPerg[i,04]
			Replace X1_TIPO	   with _aPerg[i,05]
			Replace X1_TAMANHO with _aPerg[i,06]
			Replace X1_PRESEL  with _aPerg[i,07]
			Replace X1_GSC	   with _aPerg[i,08]
			Replace X1_VAR01   with _aPerg[i,09]
			Replace X1_F3	   with _aPerg[i,10]
			Replace X1_DEF01   with _aPerg[i,11]
			Replace X1_DEF02   with _aPerg[i,12]
			Replace X1_DEF03   with _aPerg[i,13]
			MsUnlock()
		EndIF
	Next i

	RestArea(_aArea)

Return

/*/{Protheus.doc} FormatDate
(long_description)
@author thiago.reis
@since 25/09/2015
@version 1.0
@param _xVariable, ${param_type}, (Descrição do parâmetro)
@param _cFormat, ${param_type}, (Descrição do parâmetro)
@param _nTam, ${param_type}, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/

Static Function FormatDate(_xVariable, _cFormat, _nTam)

	Local _nNumber := 0
	do case
		
	case _cFormat == 'R$'
		_nNumber := strzero(int(_xVariable),13) + "." + Substr(Transform(int(_xVariable)-_xVariable,"@E 9.99"),3,2)
			
		_xVariable := _nNumber
					
	case _cFormat == 'X'
		_xVariable := alltrim(_xVariable)
		_xVariable := _xVariable + space(_ntam - len(_xVariable))
			
	case _cFormat == 'N'
		_xVariable := val(alltrim(_xVariable))
		_xVariable := strzero(_xVariable,_nTam)
			
	case _cFormat == 'NZ'
		_xVariable := alltrim(str(_xVariable))
		_xVariable += replicate('0',_nTam - len(_xVariable))
			
	case _cFormat == 'DATA'
		_xVariable 	:= dtos(_xVariable)
		_cTmpAno 	:= substr(_xVariable,1,4)
		_cTmpMes 	:= substr(_xVariable,5,2)
		_xVariable 	:= substr(_xVariable,7,2) + alltrim(_cTmpMes) + alltrim(_cTmpAno)
	
	End case

Return (_xVariable)


User Function AxCadSZZ()


	AxCadastro("SZZ","Tabela DE / PARA ")

Return



Static Function SomaContas(_cAlias)
Local _nContas := 0

Local _cChave := (_cAlias)->(CT2_FILIAL + dtos(CT2_DATA) + LOTE + SBLOTE + DOC)
Local _cAliasTmp := GetNextAlias()

BeginSql Alias _cAliasTmp

		
		%noparser%
		SELECT COUNT(CT2_FILIAL) NCONTAS

		FROM(
		SELECT 
		CT2_DATA	,
		CT2_FILIAL	,
		CT2_DC		,
		CT2_VALOR	,
		CT2_LINHA	AS LINHA,
		CT2_LOTE	AS LOTE,
		CT2_SBLOTE	AS SBLOTE,
		CT2_DOC		AS DOC
				
		FROM %Table:CT2% (NOLOCK)
		WHERE %NotDel%
		AND CT2_FILIAL = %xfilial:CT2%
		AND CT2_DATA BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
		AND CT2_DOC BETWEEN %Exp:MV_PAR04% AND %Exp:MV_PAR05%
		AND CT2_DC <> '4'
		
		AND CT2_DC <> '3'
		AND CT2_FILIAL + CT2_DATA + CT2_LOTE + CT2_SBLOTE + CT2_DOC = %Exp:_cChave%
		
		)CT2
		
		GROUP BY CT2_FILIAL, CT2_DATA , LOTE , SBLOTE , DOC
	



EndSql

(_cAliasTmp)->(dbGotop())
if ! eof()
	_nContas := (_caliasTmp)->NCONTAS 
Endif

(_cAliasTmp)->(dbCloseArea())

Return(_nContas)