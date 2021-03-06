
#Include "PROTHEUS.Ch"
#Include "rwmake.ch"
#INCLUDE "TBICONN.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ACGRUPR	�Autor  �Andr� Bagatini 	 � Data �  14/05/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Importar do arquivo .CSV para acertar o cadastro de grupo de���
���          �produtos de acordo com os crit�rios definidos por vendas.   ���
�������������������������������������������������������������������������͹��
���Uso       � Eletromega 			                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/


User Function ACGRUPRO()


Local nLastKey  	:= 0
Local _cBuffer   	:= ""
Local _nPos      	:= 0
Local _cTemp   		:= ""
Local _cArqAdm 		:= "\System\ACGRUPRO.CSV"

//VARIAVEIS QUE REPRESENTAM CADA COLUNA DO ARQUIVO CSV

Private cGrupo		:= ""
Private cDesc		:= ""
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
	If Substr(_cBuffer,1,4) <> 'GRUPO' //Nao processa o cabecalho
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
				If _nPos > 0
					cDesc 	:= Alltrim(SubsTr(_cTemp,1,_nPos-1))
					_cTemp	:= SubsTr(_cTemp,_nPos+1)
					_nPos  	:= At(";",_cTemp)
					//
					dbSelectArea("SBM")
					DbGoTop()
					DbSetOrder(1) //FILIAL + GRUPO
					If DbSeek(xFilial("SBM") + cGrupo)
						//
						RecLock("SBM",.F.)
							SBM->BM_DESC:= cDesc
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
	FT_FSKIP()
EndDo
//

FT_FUSE()

Alert("Fim")

Return()
