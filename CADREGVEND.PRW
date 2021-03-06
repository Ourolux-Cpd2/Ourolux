
#Include "PROTHEUS.Ch"
#Include "rwmake.ch"
#INCLUDE "TBICONN.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CADREGVEN �Autor  �Andr� Bagatini 	 � Data �  28/04/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Importar do arquivo .CSV para o cadastro de vendedores, de  ���
���          �acordo com os crit�rios definidos por vendas.               ���
�������������������������������������������������������������������������͹��
���Uso       � Eletromega 			                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/


User Function CDREGVEN()


Local nLastKey  	:= 0
Local _cBuffer   	:= ""
Local _nPos      	:= 0
Local _cTemp   		:= ""
Local _cArqAdm 		:= "\System\ESTREGVEND.CSV"

//VARIAVEIS QUE REPRESENTAM CADA COLUNA DO ARQUIVO CSV

Private cVend		:= ""
Private cArea		:= ""
Private cRegiao		:= ""
Private lMsErroAuto	:= .F.

//
//PREPARE ENVIRONMENT EMPRESA "01" FILIAL "04" TABLES "SB7","SB1"
//
If !File(_cArqAdm)
	MsgAlert("Arquivo csv n�o encontrado","Importacao")
	Return
Endif

FT_FUSE(_cArqAdm)
FT_FGOTOP()

While !FT_FEOF()
	//
	_cBuffer := FT_FREADLN()
	//
	If Substr(_cBuffer,1,4) <> 'VEND' //Nao processa o cabecalho
		//
		If Substr(_cBuffer,1,4) <> ';;' //Nao Processa linhas sem vendedor
			//
			_cTemp    	:= _cBuffer
			_nPos     	:= At(";",_cTemp) //Definindo a colunna
			//
			If _nPos > 0    //Coluna inicial do arquivo
				cVend	:= Alltrim(SubsTr(_cTemp,1,_nPos-1))
				_cTemp 	:= SubsTr(_cTemp,_nPos+1)
				_nPos  	:= At(";",_cTemp)
				//
				If _nPos > 0
					cArea 	:= Alltrim(SubsTr(_cTemp,1,_nPos-1))
					_cTemp	:= SubsTr(_cTemp,_nPos+1)
					_nPos  	:= At(";",_cTemp)
					//
					If _nPos > 0
						cRegiao	:= Alltrim(SubsTr(_cTemp,1,_nPos-1))
						_cTemp	:= SubsTr(_cTemp,_nPos+1)
						_nPos  	:= At(";",_cTemp)
						
						dbSelectArea("SZD")
						DbGoTop()
						dbSETORDER(2)                              //FILIAL + REFERENCIA
						If !DbSeek(xFilial("SZD") + cArea)
							//
							RecLock("SZD",.T.)
							SZD->ZD_CODIGO := GETSXENUM("SZD","ZD_CODIGO")
							SZD->ZD_AREA   := cArea
							SZD->ZD_REGIAO := cRegiao
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
		//
	EndIf
	//
	FT_FSKIP()
EndDo
//

FT_FUSE()

Alert("Fim")

Return()
