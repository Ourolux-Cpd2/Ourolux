
#Include "PROTHEUS.Ch"
#Include "rwmake.ch"
#INCLUDE "TBICONN.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ImpProd   �Autor  �AnDr� Bagatini 	 � Data �  21/07/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Importar do arquivo .CSV para o cadastro de Produtos, o codi���
���          �go de Grupos de acordo com os crit�rios definidos por vendas���
�������������������������������������������������������������������������͹��
���Uso       � Eletromega 			                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/


User Function ImpProd()


Local nLastKey  	:= 0
Local _cBuffer   	:= ""
Local _nPos      	:= 0
Local _cTemp   		:= ""
Local _cArqAdm 		:= "\System\PRODGRUPO.CSV"

//VARIAVEIS QUE REPRESENTAM CADA COLUNA DO ARQUIVO CSV

Private cProd		:= ""
Private cGrupo		:= ""
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
				cProd	:= Alltrim(SubsTr(_cTemp,1,_nPos-1))
				_cTemp 	:= SubsTr(_cTemp,_nPos+1)
				_nPos  	:= At(";",_cTemp)
				//
				If _nPos > 0 //GRUPO PRODUTOS
					//
					cGrupo 	:= Alltrim(SubsTr(_cTemp,1,_nPos-1))
					_cTemp	:= SubsTr(_cTemp,_nPos+1)
					_nPos  	:= At(";",_cTemp)

					dbSelectArea("SB1")
					DbGoTop()
					dbSETORDER(1)                              //FILIAL + REFERENCIA
						//
						If DbSeek(xFilial("SB1") + cProd)
							//
							RecLock("SB1",.F.)
							SB1->B1_GRUPO   := cGrupo
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