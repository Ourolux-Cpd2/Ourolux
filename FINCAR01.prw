#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "RWMAKE.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � FINCAR01  � Autor � Paulo Ferraz	     � Data � 20/04/2015  ���
�������������������������������������������������������������������������͹��
���Desc.     �Programa para preencher a SE1 a partir de um TXT            ���
�������������������������������������������������������������������������͹��
���Uso       � Espec�fico                                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function FINCAR01()

Local cArquivo:= cGetFile()

If Empty(cArquivo)
	MsgAlert("Aten��o, informe um arquivo v�lido antes de prosseguir com a importa��o.")
	Return(Nil)
EndIf

Processa({|| FINCAR001(cArquivo) })

Return(Nil)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � FINCAR001 �Autor  �Paulo Ferraz		 � Data �         ���
�������������������������������������������������������������������������͹��
���Desc.     �Processamento da importacao do TXT                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function FINCAR001(cArquivo)

Local aLinha    := {}
Local aConteudo := {}
Local nLinha    := 0
Local i

FT_FUse(cArquivo)
ProcRegua(FT_FLastRec())
FT_FGoTop()

While !FT_FEof()
	IncProc("Formatando Arquivo...")
	nLinha++
	aLinha    := {}
	
	aLinha:=Separa( FT_FReadLn(),";",.T.)
	
	AAdd(aConteudo,AClone(aLinha))
	
	FT_FSkip()
Enddo

For i := 1 To Len(aConteudo)
	
	dbSelectArea("SE1")
	dbSetOrder(2)
	dbSeek("  "+PADR(aConteudo[i,1],6)+PADR(aConteudo[i,2],2)+PADR(aConteudo[i,3],3)+PADR(aConteudo[i,4],9)+PADR(aConteudo[i,5],1)+PADR(aConteudo[i,6],3))
	
	IF FOUND()// Avalia o retorno da pesquisa realizada
		RecLock("SE1", .F.)
		
		SE1->E1_XCATCOB    := aConteudo[i,8]
		
		MSUNLOCK()     // Destrava o registro
	ENDIF
	
Next

Return
