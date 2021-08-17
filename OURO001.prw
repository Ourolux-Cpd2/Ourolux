#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
��� Programa  � OURO001                                � Data � 26/07/2019 ���
��������������������������������������������������������������������������͹��
��� Autor     � Marcelo - Ethosx                                           ���
��������������������������������������������������������������������������͹��
��� Descricao � Rotina para preenchimento do campo W6_XENTINI que foi cria-���
���           � do recentemente                                            ���
��������������������������������������������������������������������������͹��
��� Sintaxe   � OURO001()                                                  ���
��������������������������������������������������������������������������͹��
��� Retorno   � nil                                                        ���
��������������������������������������������������������������������������͹��
��� Uso       �                                                            ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/             

User Function OURO001()

Local aArea		:= GetArea()
Local cArq      := ""
Local lConv     := .F.

Private cArquivo := Space(150)
Private lOk      :=.F.
Private bOk      := { || If(ValidaDir(cArquivo), (lOk:=.T.,oDlg:End()) ,) }
Private bCancel  := { || lOk:=.F.,oDlg:End() }
Private lEnd     := .F.

Define MsDialog oDlg Title "Diret�rio" From 08,15 To 25,120 Of GetWndDefault()
      
@ 45,16  Say 	"Diretorio:" 	Size 050,10 Of oDlg Pixel
@ 45,40  MsGet 	cArquivo 		Size 230,08 Of oDlg Pixel
@ 45,275 Button "�" 			Size 010,10 Action Eval({|| cArquivo:=SelectFile() }) Of oDlg Pixel

Activate MsDialog oDlg Centered On Init (EnchoiceBar(oDlg,bOk,bCancel))

If lOk
	oProcess:=MsNewProcess():New( { |lEnd| lConv:=u_ImpW6XENT(cArquivo, @lEnd)}, "Preenchimento Campo W6_XENTINI", "Processando arquivo SW6", .T. )
	oProcess:Activate()	
	If lConv
		cArq := SUBSTR(cArquivo,RAT("\", cArquivo)+1,LEN(cArquivo))
	EndIf
EndIf

RestArea(aArea)

Return 

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
��� Programa  � ImpW6XENT                              � Data � 20/07/2015 ���
��������������������������������������������������������������������������͹��
��� Autor     � Microsiga                                                  ���
��������������������������������������������������������������������������͹��
��� Descricao � Rotina para a gravacao do campo W6_XENTINI criado recente- ���
���           � mente no sistema.                                          ���
��������������������������������������������������������������������������͹��
��� Sintaxe   � ImpW6XENT(cArq, lEnd)                                      ���
��������������������������������������������������������������������������͹��
��� Retorno   � Logico                                                     ���
��������������������������������������������������������������������������͹��
��� Uso       � Rede Dor S�o Luiz                                          ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
User Function ImpW6XENT(cArq, lEnd)

Local aTables	:= {}
Local aVetor    := {}
Local aDados    := {}
Local aArea		:= GetArea()
Local cLinha
Local nTot      := 0
Local nCont     := 1
Local nAtual    := 0
Local nTimeIni  := 0
Local nLinTit   := 1  // Total de linhas do Cabe�alho

Local aCampos 	:= {} 
Local aCoors 	:= MsAdvSize()

Private lMsErroAuto := .F.

If (nHandle := FT_FUse(AllTrim(cArq)))== -1
	Help(" ",1,"NOFILEIMPOR")
	RestInter()
	Return .T.
EndIf

nTot := FT_FLASTREC()

FT_FGOTOP()

// Tratamento do cabe�alho
While nLinTit > 0 .AND. !Ft_FEof()
   cLinha := FT_FREADLN()
   If LEN(cLinha) == 1023
		FT_FSKIP()
		cConLinha := FT_FREADLN()
		While LEN(cConLinha) == 1023
			cLinha += cConLinha
			FT_FSKIP()
			cConLinha := FT_FREADLN()
		EndDo
		cLinha += cConLinha
	EndIf

	If nLinTit == 1
		aCampos := SEPARA(cLinha,";",.T.)
		
		nPosHaw := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "W6_HAWB"	})
		
	EndIf

	cLinha := ""
	Ft_FSkip()
	nLinTit--
EndDo

oProcess:SetRegua1( nTot )
oProcess:SetRegua2( int(ntot/100) )

// Processa os dados do template
Do While !FT_FEOF()
	oProcess:IncRegua1("Registros processados : " + ALLTRIM(STR(nCont)) )
	cLinha := FT_FREADLN()
	
	If lEnd
		MsgInfo("Importa��o cancelada!","Fim")
		Return .T.
	Endif

	nAtual++
	If (nAtual % 100) = 1
		nTimeIni := Seconds()
	EndIf
	If (nAtual % 100) = 0
		oProcess:IncRegua2( "Tempo Restante - (" + EstTime(ntot,nAtual,(nAtual-100),nTimeIni) + ")" )
	EndIf
	
	If LEN(cLinha) == 1023
		FT_FSKIP()
		cConLinha := FT_FREADLN()
		While LEN(cConLinha) == 1023
			cLinha += cConLinha
			FT_FSKIP()
			cConLinha := FT_FREADLN()
		EndDo
		cLinha += cConLinha
	EndIf
	
	nAtual++
	If (nAtual % 100) = 1
		nTimeIni := Seconds()
	EndIf
	If (nAtual % 100) = 0
		oProcess:IncRegua2( "Tempo Restante - (" + EstTime(ntot,nAtual,(nAtual-100),nTimeIni) + ")" )
	EndIf
	
	//aDados := STRTOKARR(cLinha,";")   // A fun��o SEPARA e a fun��o STRTOKARR, converte uma string em um array, o SEPARA converte os espa�os em branco 
	aDados := SEPARA(cLinha,";",.T.)
			
	DbSelectArea("SW6")
	SW6->( DbSetOrder(1) )
	SW6->( DbGoTop() )
	
	//W6_FILIAL + W6_HAWB

	If SW6->( DbSeek(  xFilial("SW6") + AllTrim(aDados[nPosHaw]) ))
				
		SW6->(Reclock("SW6",.F.))

		For W:=1 To LEN(aCampos)

			If AllTrim(aDados[W]) <> "" .or. !Empty(aDados[W])			

				SX3->(dbSetOrder(2)) 
				SX3->(dbGoTop())

				If SX3->(dbSeek(aCampos[W]))
					cTipo := SX3->X3_TIPO
				EndIf

				Do Case
					Case cTipo == 'D' 
						aDados[W] := CTOD(aDados[W])
					Case cTipo == 'N' 
						aDados[W] := IIf(EMPTY(aDados[W]),0,VAL(STRTRAN(aDados[W],",",".")))
					Case cTipo == 'M' 
						aDados[W] := IIf(EMPTY(aDados[W]),"",MSMM(aDados[W]))
				EndCase
				
				DbSelectArea("SW6") 

				If AllTrim(aCampos[W]) == "W6_XENTINI" .And.  Empty(SW6->W6_XENTINI)

					SW6->W6_XENTINI := aDados[W]
					
				EndIf
	
			EndIf	
			
		Next W
		SW6->(Msunlock())
		
	EndIf

	FT_FSKIP()
	nCont++
EndDo

FT_FUSE()

Aviso("Finalizado","Importacao finalizada com sucesso",{"Fechar"})

RestArea(aArea)

Return .F.

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
��� Programa  � SELECTFILE                             � Data � 10/07/2015 ���
��������������������������������������������������������������������������͹��
��� Autor     � Microsiga                                                  ���
��������������������������������������������������������������������������͹��
��� Descricao � Rotina para selecao de arquivos CSV para importacao        ���
���           �                                                            ���
��������������������������������������������������������������������������͹��
��� Sintaxe   � SELECTFILE()                                               ���
��������������������������������������������������������������������������͹��
��� Retorno   � cArquivo                                                   ���
��������������������������������������������������������������������������͹��
��� Uso       � Rede Dor S�o Luiz                                          ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/

Static Function SelectFile()

Local cMaskDir := "Arquivos .CSV (*.CSV) |*.CSV|"
Local cTitTela := "Arquivo para a integracao"
Local lInfoOpen := .T.
Local lDirServidor := .F.
Local cOldFile := cArquivo

cArquivo := cGetFile(cMaskDir,cTitTela,,cArquivo,lInfoOpen, (GETF_LOCALHARD+GETF_NETWORKDRIVE) ,lDirServidor)

If !File(cArquivo)
	MsgStop("Arquivo N�o Existe!")
	cArquivo := cOldFile
Return .F.
EndIf

Return cArquivo

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
��� Programa  � VALIDADIR                              � Data � 10/07/2015 ���
��������������������������������������������������������������������������͹��
��� Autor     � Microsiga                                                  ���
��������������������������������������������������������������������������͹��
��� Descricao � Rotina para validacao do diretorio do arquivos CSV a ser   ���
���           � importado.                                                 ���
��������������������������������������������������������������������������͹��
��� Sintaxe   � VALIDADIR(cArquivo)                                        ���
��������������������������������������������������������������������������͹��
��� Retorno   � Logico                                                     ���
��������������������������������������������������������������������������͹��
��� Uso       � Rede Dor S�o Luiz                                          ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Static Function ValidaDir(cArquivo)
Local lRet := .T.

If Empty(cArquivo)
	MsgStop("Selecione um arquivo","Aten��o")
	lRet := .F.
ElseIf !File(cArquivo)
	MsgStop("Selecione um arquivo v�lido!","Aten��o")
	lRet := .F.
EndIf

Return lRet


// ###########################################################################################
// Projeto:
// Modulo :
// Fun��o : 
// -----------+-------------------+-----------------------------------------------------------
// Data       | Autor             | Descricao
// -----------+-------------------+-----------------------------------------------------------
// 20/03/2015 | Miqueias Dernier  | Estima tempo para terminar o processamento
//            |                   |
// -----------+-------------------+-----------------------------------------------------------

Static Function EstTime(nTotal,nAtual,nIni,nTimeIni,nTimeZero)

Local cRet := ""
Local nTimeAtu := Seconds()
Local nHora , nMinutos, nSegundos

If (nAtual-nIni)>0
	nSegundos := (nTotal-nAtual)*(nTimeAtu-nTimeIni)/(nAtual-nIni)
Else
	nSegundos := 0
EndIf

nHora := Int(nSegundos/(60*60))
nSegundos := Mod(nSegundos,(60*60))
nMinutos := Int(nSegundos/(60))
nSegundos := Mod(nSegundos,(60))

If nTotal>0
	cRet := Str(nAtual/nTotal*100,3) + " % - "
Else
	cRet := Str(100,3) + " % - "
EndIf
	

cRet += ""+If(nHora>0,Str(nHora,3,0)+" horas, ","")+If(nMinutos>0,Str(nMinutos,3,0)+" minutos e ","")+If(nSegundos>0,Str(nSegundos,3,0)+" segundos ","")

Return cRet