
#Include "PROTHEUS.Ch"
#Include "rwmake.ch"
#INCLUDE "TBICONN.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ImpVend   �Autor  �AnDr� Bagatini 	 � Data �  28/04/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Importar do arquivo .CSV para o cadastro de vendedores, de  ���
���          �acordo com os crit�rios definidos por vendas.               ���
�������������������������������������������������������������������������͹��
���Uso       � Eletromega 			                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/


User Function ImpVend()


Local nLastKey  	:= 0
Local _cBuffer   	:= ""
Local _nPos      	:= 0
Local _cTemp   		:= ""
Local _cArqAdm 		:= "\System\VENDOF.CSV"

//VARIAVEIS QUE REPRESENTAM CADA COLUNA DO ARQUIVO CSV

Private cVend		:= ""
Private cSuperv		:= ""
Private cGerent		:= ""
Private cDtSai		:= ""
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
	If Substr(_cBuffer,1,6) <> 'Codigo' //Nao processa o cabecalho
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
				If _nPos > 0 // Regiao de Vendas
					cRegiao := Alltrim(SubsTr(_cTemp,1,_nPos-1))
					_cTemp	:= SubsTr(_cTemp,_nPos+1)
					_nPos  	:= At(";",_cTemp)
					dbSelectArea("SA3")
					DbGoTop()
					dbSETORDER(1)                              //FILIAL + REFERENCIA
					//
					If DbSeek(xFilial("SA3") + cVend)
						//
						RecLock("SA3",.F.)
						SA3->A3_XREGIAO := cRegiao							
						MSUNLOCK()
						//
					EndIf
					//
				EndIf
			EndIf
		EndIf
		//
	EndIf
	FT_FSKIP()
EndDo
//

FT_FUSE()

Alert("Fim")

Return()