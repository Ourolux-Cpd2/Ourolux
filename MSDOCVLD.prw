#INCLUDE "TOTVS.CH"
                       

/*/{Protheus.doc} MSDOCVLD
Ponto de entrada para validar anexo no banco de conhecimento (Wizard)

@author Roberto Souza
@since 13/04/2017
@version 1
/*/
User Function MSDOCVLD()
	Local lRet 			:= .T.
	Local cArquivo  	:= PARAMIXB[1]         
	Local nLimArq   	:= Round( GetMV("FS_MSDOCTM",,5000000) / (1024 * 1000),4)   
	Local cTpExt        := AllTrim(GetMV("FS_MSDOCEX",,"pdf;jpg;png;xml;xlsx;docx;pptx"))
	Local cMsgErro 		:= ""                     
    Local cMed          := "MB"           
    Local cDrive		:= ""
    Local cDir			:= ""
    Local cNomeFile		:= ""   
	Local cExt          := ""
    
	SplitPath( cArquivo, @cDrive, @cDir, @cNomeFile, @cExt )
	
	If !( Substr(Lower(cExt),2) $ Lower( cTpExt ) )
		cMsgErro += "O arquivo possui uma extensão não permitida."+CRLF
		cMsgErro += "Seu Arquivo ..: "+Lower(cExt)+CRLF
		cMsgErro += "Permitidas ...: "+cTpExt+CRLF	
    EndIf

	nTamanho  	:= TamArq( cArquivo , cMed )

	If nTamanho > nLimArq                                     
		cMsgErro += "O arquivo excedeu o limite de tamanho permitido para anexos."+CRLF
		cMsgErro += "Seu Arquivo ..: "+cValToChar(nTamanho)+" "+cMed+CRLF
		cMsgErro += "Limite .......: "+cValToChar(nLimArq)+" "+cMed+CRLF
	EndIf

	If !Empty( cMsgErro )
		Aviso("Atenção",cMsgErro,{"Ok"},2)
		lRet := .F.
	EndIf
	
Return( lRet )   




/*/{Protheus.doc} TamArq
Funcao para calcular o tamanho do arquivo

@author Roberto Souza
@since 13/04/2017
@version 1
/*/
Static Function TamArq( cArquivo , cMt )
	Local nRet 			:= 0
	Local aInfo 		:= Directory( cArquivo )
	Local nTamanho  	:= aInfo[01][02] // Tamanho
	Local dData      	:= aInfo[01][03] // Data
	Local cHora      	:= aInfo[01][04] // Hora
	Local cAtributos 	:= aInfo[01][05] // Atributos
	             
    Default cMt 		:= "B"
	
	If Upper( cMt ) == "KB"                                   
		nRet := Round( nTamanho / 1024, 2 )           
	ElseIf Upper( cMt ) == "MB"                                   
		nRet := Round( nTamanho / ( 1024 * 1000 ), 4 )
	ElseIf Upper( cMt ) == "GB"                                   
		nRet := Round( nTamanho / ( 1024 * 1000000 ), 6 )	
	Else // Bytes
		nRet := nTamanho
	EndIf
	
Return( nRet )