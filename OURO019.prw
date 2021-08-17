#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออออัออออออออออออออออออออออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑ?Programa  ?OUROR019                               ?Data ?20/07/2015 บฑ?
ฑฑฬอออออออออออุออออออออออออออออออออออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑ?Autor     ?Marcelo - Ethosx                                           บฑ?
ฑฑฬอออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑ?Descricao ?Rotina para a importa็ใo da  Tabela de Preco               บฑ?
ฑฑ?          ?                                                           บฑ?
ฑฑฬอออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑ?Sintaxe   ?OURO019()                                                 บฑ?
ฑฑฬอออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑ?Retorno   ?nil                                                        บฑ?
ฑฑฬอออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑ?Uso       ?                                                           บฑ?
ฑฑศอออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/                     

User Function OURO019()

Local aRet		:= {}                                
Local aArea		:= GetArea()
Local cArq      := ""
Local lConv     := .F.

Private aLog    := {}
Private cArquivo := Space(150)
Private lOk      :=.F.
Private bOk      := { || If(ValidaDir(cArquivo), (lOk:=.T.,oDlg:End()) ,) }
Private bCancel  := { || lOk:=.F.,oDlg:End() }
Private lEnd     := .F.

Define MsDialog oDlg Title "Diret๓rio" From 08,15 To 25,120 Of GetWndDefault()
      
@ 45,16  Say 	"Diretorio:" 	Size 050,10 Of oDlg Pixel
@ 45,40  MsGet 	cArquivo 		Size 230,08 Of oDlg Pixel
//@ 45,275 Button "? 			Size 010,10 Action Eval({|| cArquivo:= SelectFile() }) Of oDlg Pixel
@ 45,275 Button "…" 			Size 010,10 Action Eval({|| cArquivo:= SelectFile() }) Of oDlg Pixel
                  
Activate MsDialog oDlg Centered On Init (EnchoiceBar(oDlg,bOk,bCancel))

If lOk

	oProcess:=MsNewProcess():New( { |lEnd| lConv:=u_ImpDA1CSV(cArquivo, @lEnd)}, "Importa็ใo da Tabela de Pre็o DA1", "Processando arquivo DA1", .T. )
	oProcess:Activate()	

	If lConv
		Processa( {|| CRIALOG(aLog, SUBSTR(cArquivo,1,LEN(cArquivo)-4), 4)},"Gera็ใo do Log", "Aguarde")		
	EndIf

EndIf

RestArea(aArea)

Return 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออออัออออออออออออออออออออออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑ?Programa  ?ImpDA1CSV                              ?Data ?20/07/2015 บฑ?
ฑฑฬอออออออออออุออออออออออออออออออออออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑ?Autor     ?Microsiga                                                  บฑ?
ฑฑฬอออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑ?Descricao ?Rotina para a importa็ใo das Tabela de Preco.              บฑ?
ฑฑ?          ?                                                           บฑ?
ฑฑฬอออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑ?Sintaxe   ?ImpDA1CSV(cArq, lEnd)                                      บฑ?
ฑฑฬอออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑ?Retorno   ?Logico                                                     บฑ?
ฑฑฬอออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑ?Uso       ?OuroLux                                                    บฑ?
ฑฑศอออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function ImpDA1CSV(cArq, lEnd)

Local aDados    := {}
Local aArea		:= GetArea()
Local cLinha
Local nTot      := 0
Local nCont     := 1
Local nTimeIni  := 0
Local nLinTit   := 1  // Total de linhas do Cabe็alho
Local aCampos 	:= {} 

Local cCodTab	:= ""
Local cItem		:= ""
Local cCodProd	:= ""
Local nValAnt	:= 0

If (nHandle := FT_FUse(AllTrim(cArq)))== -1
	Help(" ",1,"NOFILEIMPOR")
	RestInter()
	Return .F.
EndIf

nTot := FT_FLASTREC()

FT_FGOTOP()

// Tratamento do cabe็alho
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
		MsgInfo("Importa็ใo cancelada!","Fim")
		Return .F.
	Endif

	If (nCont % 100) = 1
		nTimeIni := Seconds()
	EndIf
	
	If (nCont % 100) = 0
		oProcess:IncRegua2( "Tempo Restante - (" + EstTime(ntot,nCont,(nCont-100),nTimeIni) + ")" )
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
	
	If (nCont % 100) = 1
		nTimeIni := Seconds()
	EndIf
	
	aDados := SEPARA(cLinha,";",.T.)
			
	DA1->( DbSetOrder(1) ) //DA1_FILIAL + DA1_CODTAB + DA1_CODPRO
	DA1->( DbGoTop() ) 

	For W:=1 To LEN(aCampos)

		If AllTrim(aDados[W]) <> "" .Or. !Empty(aDados[W])			

				
			If AllTrim(aCampos[W]) == "Cod Prod"

				cCodProd:= AllTrim(aDados[W])
					
			EndIf
								
			If W >= 3 .And. !Empty(cCodProd)//Campo contem o codigo da tabela
			
				cCodTab:= AllTrim(aCampos[W])
	
				DA1->( DbSetOrder(1) )
				
				If DA1->(DbSeek(xFilial("DA1") + cCodTab) )
				
      					DA1->(DbGoTop())
      					
      					aDados[W]:= IIf(EMPTY(aDados[W]),0,VAL(STRTRAN(aDados[W],",",".")))
      					
      					If DA1->(DbSeek(xFilial("DA1") + cCodTab + cCodProd) )
      					
      						If aDados[W] > 0
					
								DA1->(Reclock("DA1",.F.))	
								
								nValAnt := DA1->DA1_PRCVEN
								DA1->DA1_PRCVEN := aDados[W]
								DA1->DA1_MSEXP	:= ""
						
								DA1->(MsUnlock())
                                
                            	AADD(aLog,{"ALTERADO","Filial: " + xFilial("DA1") + " - Tabela: " + cCodTab + " - Codigo: " + cCodProd + Space(10-Len(cCodProd) ) + " Valor Antigo: " + TransForm(nValAnt,TM(nValAnt,TamSX3("DA1_PRCVEN")[1],TamSX3("DA1_PRCVEN")[2])) + " Valor Novo: " + TransForm(aDados[W],TM(aDados[W],TamSX3("DA1_PRCVEN")[1],TamSX3("DA1_PRCVEN")[2]))  ,Nil})
                            	                            	
							Else
							
								AADD(aLog,{"ERRO","Valor Menor que Zero nใo foi alterado - Filial: " + xFilial("DA1") + " - Tabela: " + cCodTab + " - Codigo: " + cCodProd + Space(10-Len(cCodProd) ) + " Valor: " + TransForm(aDados[W],TM(aDados[W],TamSX3("DA1_PRCVEN")[1],TamSX3("DA1_PRCVEN" 	)[2]))  ,Nil})
							
							EndIf
							
						Else
				            
				            If aDados[W] > 0
				            
					            cItem:= "0001"
							
								DA1->( DbSetOrder(3) )
								DA1->( DbGoTop() )

								While DA1->(DbSeek(xFilial("DA1") + cCodTab + cItem) )

									cItem:= StrZero((Val(DA1->DA1_ITEM) +1),4)
								
								End
							
								SB1->(DbSetOrder(1))

								If SB1->(DbSeek(xFilial("SB1") + cCodProd) ) .And. SB1->B1_MSBLQL = "2"
								
									DA1->(Reclock("DA1",.T.))	
					
									DA1->DA1_FILIAL	:= xFilial("DA1")
									DA1->DA1_ITEM	:= cItem
									DA1->DA1_CODTAB	:= cCodTab 
									DA1->DA1_CODPRO	:= cCodProd
									DA1->DA1_PRCVEN := aDados[W]
									DA1->DA1_ATIVO	:= "1"
									DA1->DA1_TPOPER	:= "4"
									DA1->DA1_QTDLOT	:= 999999.99
									DA1->DA1_INDLOT	:= "000000000999999.99  "
									DA1->DA1_MOEDA	:= 1
									DA1->DA1_DATVIG	:= dDatabase
									DA1->DA1_MSEXP	:= ""
									DA1->(MsUnlock())
								
									AADD(aLog,{"NOVO","Filial: " + xFilial("DA1") + " - Tabela: " + cCodTab + " - Codigo: " + cCodProd + Space(10-Len(cCodProd) ) + " Valor: " + TransForm(aDados[W],TM(aDados[W],TamSX3("DA1_PRCVEN")[1],TamSX3("DA1_PRCVEN")[2])) ,Nil})
									
								Else
								    If SB1->B1_MSBLQL = "1" .And. AllTrim(cCodProd) == AllTrim(SB1->B1_COD)
										AADD(aLog,{"ERRO" 	    ,"Produto Bloqueado: " + cCodProd ,Nil})
                                    Else
										AADD(aLog,{"ERRO" 	    ,"Produto nใo existe: " + cCodProd ,Nil})
									EndIf
							
								EndIf
								
							Else
								AADD(aLog,{"ERRO","Valor Menor que Zero nใo foi incluido - Filial: " + xFilial("DA1") + " - Tabela: " + cCodTab + " - Codigo: " + cCodProd + Space(10-Len(cCodProd) )  + " Valor: " + TransForm(aDados[W],TM(aDados[W],TamSX3("DA1_PRCVEN")[1],TamSX3("DA1_PRCVEN")[2]))  ,Nil})	
							EndIf
				
						EndIf
				
				EndIf
				
            EndIf
            
        EndIf
			
	Next W

	FT_FSKIP()
	nCont++
	
EndDo

FT_FUSE()

RestArea(aArea)

If Len(aLog)>0
	Aviso("Finalizado","Importacao finalizada - Iniciar Gera็ใo do arquivo de Log",{"Iniciar"})
	Return .T.
Else
	Aviso("Finalizado","Importacao nใo realizada",{"Fechar"})
EndIf

Return .F.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออออัออออออออออออออออออออออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑ?Programa  ?SELECTFILE                             ?Data ?10/07/2015 บฑ?
ฑฑฬอออออออออออุออออออออออออออออออออออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑ?Autor     ?Microsiga                                                  บฑ?
ฑฑฬอออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑ?Descricao ?Rotina para selecao de arquivos CSV para importacao        บฑ?
ฑฑ?          ?                                                           บฑ?
ฑฑฬอออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑ?Sintaxe   ?SELECTFILE()                                               บฑ?
ฑฑฬอออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑ?Retorno   ?cArquivo                                                   บฑ?
ฑฑฬอออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑ?Uso       ?OuroLux                                                    บฑ?
ฑฑศอออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function SelectFile()

Local cMaskDir := "Arquivos .CSV (*.CSV) |*.CSV|"
Local cTitTela := "Arquivo para a integracao"
Local lInfoOpen := .T.
Local lDirServidor := .T.
Local cOldFile := cArquivo

cArquivo := cGetFile(cMaskDir,cTitTela,,cArquivo,lInfoOpen, (GETF_LOCALHARD + GETF_NETWORKDRIVE) ,lDirServidor)

If !File(cArquivo)
	MsgStop("Arquivo Nใo Existe!")
	cArquivo := cOldFile
Return .F.
EndIf

Return cArquivo

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออออัออออออออออออออออออออออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑ?Programa  ?VALIDADIR                              ?Data ?10/07/2015 บฑ?
ฑฑฬอออออออออออุออออออออออออออออออออออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑ?Autor     ?Microsiga                                                  บฑ?
ฑฑฬอออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑ?Descricao ?Rotina para validacao do diretorio do arquivos CSV a ser   บฑ?
ฑฑ?          ?importado.                                                 บฑ?
ฑฑฬอออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑ?Sintaxe   ?VALIDADIR(cArquivo)                                        บฑ?
ฑฑฬอออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑ?Retorno   ?Logico                                                     บฑ?
ฑฑฬอออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑ?Uso       ?OuroLux                                                    บฑ?
ฑฑศอออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ValidaDir(cArquivo)
Local lRet := .T.

If Empty(cArquivo)
	MsgStop("Selecione um arquivo","Aten็ใo")
	lRet := .F.
ElseIf !File(cArquivo)
	MsgStop("Selecione um arquivo vแlido!","Aten็ใo")
	lRet := .F.
EndIf

Return lRet


// ###########################################################################################
// Projeto:
// Modulo :
// Fun็ใo : 
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

nHora 		:= Int(nSegundos/(60*60))
nSegundos 	:= Mod(nSegundos,(60*60))
nMinutos 	:= Int(nSegundos/(60))
nSegundos 	:= Mod(nSegundos,(60))

If nTotal > 0
	cRet := Str(nAtual/nTotal*100,3) + " % - "
Else
	cRet := Str(100,3) + " % - "
EndIf
	

cRet += ""+If(nHora>0,Str(nHora,3,0)+" horas, ","")+If(nMinutos>0,Str(nMinutos,3,0)+" minutos e ","")+If(nSegundos>0,Str(nSegundos,3,0)+" segundos ","")

Return cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออออัออออออออออออออออออออออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑ?Programa  ?CRIALOG                                ?Data ?08/07/2015 บฑ?
ฑฑฬอออออออออออุออออออออออออออออออออออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑ?Autor     ?Microsiga                                                  บฑ?
ฑฑฬอออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑ?Descricao ?Rotina para criar o arquivo de log de erros.               บฑ?
ฑฑ?          ?                                                           บฑ?
ฑฑฬอออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑ?Sintaxe   ?CRIALOG(aLog, cArq)                                        บฑ?
ฑฑฬอออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑ?Retorno   ?nil                                                        บฑ?
ฑฑฬอออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑ?Uso       ?OuroLux                                                    บฑ?
ฑฑศอออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CRIALOG(aLog, cArq, nQbrLin)

Local cFile := cArq + "_" + StrZero(Day(Date()),2,0) + "_" + StrZero(Month(Date()),2,0) + "_" + ALLTRIM(Str(Year(Date()))) + "_" + SubStr(Time(),1,2) + "_" + SubStr(Time(),4,2) + "_" + SubStr(Time(),7,2) + ".LOG"
Local nH
Local nCont := 1
Local nIntrj

nH := fCreate(cFile)

nIntrj:= FCREATE("\INTRJ\OURO019_" + StrZero(Day(Date()),2,0) + "_" + StrZero(Month(Date()),2,0) + "_" + ALLTRIM(Str(Year(Date()))) + "_" + SubStr(Time(),1,2) + "_" + SubStr(Time(),4,2) + "_" + SubStr(Time(),7,2) + ".log",0)

If nH == -1
   MsgStop("Falha ao criar arquivo - erro "+str(ferror()))
   Return
Endif

fWrite(nH,"DATA DA IMPORTACAO : "+StrZero(Day(Date()),2,0)+"/"+StrZero(Month(Date()),2,0)+"/"+ALLTRIM(Str(Year(Date())))+chr(13)+chr(10))
fWrite(nIntrj,"DATA DA IMPORTACAO : "+StrZero(Day(Date()),2,0)+"/"+StrZero(Month(Date()),2,0)+"/"+ALLTRIM(Str(Year(Date())))+chr(13)+chr(10))

fWrite(nH,REPLICATE("-",100) + chr(13)+chr(10))
fWrite(nIntrj,REPLICATE("-",100) + chr(13)+chr(10))


fWrite(nH,"Nome do Arquivo:  " + AllTrim(cArq) + " - Usuario: " + __cUserId + " - " + UsrRetName(__cUserId) +chr(13)+chr(10))
fWrite(nH,REPLICATE("-",100) + chr(13)+chr(10))

fWrite(nIntrj,"Nome do Arquivo:  " + AllTrim(cArq) + " - Usuario: " + __cUserId + " - " + UsrRetName(__cUserId) +chr(13)+chr(10))
fWrite(nIntrj,REPLICATE("-",100) + chr(13)+chr(10))

ProcRegua(LEN(aLog))

For X:=1 To LEN(aLog)
	IncProc("Gera็ใo do Log : " + AllTrim(Str(x)) + " de " + AllTrim(Str(LEN(aLog)))   )
	fWrite(nIntrj,PADR(aLog[X][1],8)+" : "+aLog[X][2]+chr(13)+chr(10) )
	fWrite(nH,PADR(aLog[X][1],8)+" : "+aLog[X][2]+chr(13)+chr(10) )
	If nCont = nQbrLin
		fWrite(nH,		REPLICATE("-",100) + chr(13)+chr(10))
		fWrite(nIntrj,	REPLICATE("-",100) + chr(13)+chr(10))
		nCont := 0
	EndIf
	nCont++
Next X

fClose(nH)

Return