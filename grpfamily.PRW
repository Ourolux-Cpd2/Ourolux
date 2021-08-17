
#Include "PROTHEUS.Ch"
#Include "rwmake.ch"
#INCLUDE "TBICONN.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGRPFAMILY บAutor  ณAnDr้ Bagatini 	 บ Data ณ  21/07/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImportar do arquivo .CSV para o cadastro de Produtos, o codiบฑฑ
ฑฑบ          ณgo Familia de acordo com os crit้rios definidos por vendas  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Eletromega 			                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/


User Function GRPFAMILY()


Local nLastKey  	:= 0
Local _cBuffer   	:= ""
Local _nPos      	:= 0
Local _cTemp   		:= ""
Local _cArqAdm 		:= "\System\GRPFAMILY.CSV"

//VARIAVEIS QUE REPRESENTAM CADA COLUNA DO ARQUIVO CSV

Private cGrupo		:= ""
Private cFamilia	:= ""
Private lMsErroAuto	:= .F.

//
//PREPARE ENVIRONMENT EMPRESA "01" FILIAL "04" TABLES "SB7","SB1"
//
If !File(_cArqAdm)
	MsgAlert("Arquivo csv nใo encontrado","Importacao")
	Return
Endif

FT_FUSE(_cArqAdm)
FT_FGOTOP()

While !FT_FEOF()
	//
	_cBuffer := FT_FREADLN()
	//
	If Substr(_cBuffer,1,5) <> 'GRUPO' //Nao processa o cabecalho
		//
		If Substr(_cBuffer,1,4) <> ';;' //Nao Processa linhas sem vendedor
			//
			_cTemp    	:= _cBuffer
			_nPos     	:= At(";",_cTemp) //Definindo a colunna
			//
			If _nPos > 0    //Coluna inicial do arquivo
				cGrupo	:= Alltrim(SubsTr(_cTemp,1,_nPos-1))
				_cTemp 	:= SubsTr(_cTemp,_nPos+1)
				_nPos  	:= At(";",_cTemp)
				//
				If _nPos > 0 //GRUPO PRODUTOS
					//
					cFamilia:= Alltrim(SubsTr(_cTemp,1,_nPos-1))
					_cTemp	:= SubsTr(_cTemp,_nPos+1)
					_nPos  	:= At(";",_cTemp)

					dbSelectArea("SBM")
					DbGoTop()
					dbSETORDER(1)                              //FILIAL + REFERENCIA
						//
						If DbSeek(xFilial("SBM") + cGrupo )
							//
							RecLock("SBM",.F.)
							SBM->BM_TIPGRU   := cFamilia
							MSUNLOCK()
							//
						EndIf
					//
				EndIf
			    //
			EndIf
			//
		EndIf
		//
	EndIf
	FT_FSKIP()
EndDo
//

FT_FUSE()

Alert("Fim")

Return()