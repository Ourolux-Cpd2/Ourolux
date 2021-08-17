#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "SHELL.CH" 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ OUROR018 ณ Autor ณ MARCELO - ETHOSX      ณ Data ณ 06/06/19 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Importar Tabela Ct2 para DBF        		                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ SIGACTB                                                    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ PROGRAMADOR  ณ DATA   ณ BOPS ณ  MOTIVO DA ALTERACAO                   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤลฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ                                                                       ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function OUROR018()
	
	Local cPerg		:= PADR("OUROR018B",10)
	Local aArea		:= GetArea()
	Local oDlg

	Private cArquivo := Space(150)
	Private lOk      :=.F.
	Private bOk      := { || lOk:=.T.,oDlg:End() }
	Private bCancel  := { || lOk:=.F.,oDlg:End() }
	Private lEnd     := .F.
		
	ValidP1(cPerg)

	If Pergunte(cPerg,.t.)//CONFIRMACAO DOS PARAMETROS

		Define MsDialog oDlg Title "Local para Gerar Arquivo" From 08,15 To 25,120 Of GetWndDefault()
      
		@ 45,16  Say 	"Diretorio:" 	Size 050,10 Of oDlg Pixel
		@ 45,40  MsGet 	cArquivo 		Size 230,08 Of oDlg Pixel
		@ 45,275 Button "…" 			Size 010,10 Action Eval({|| cArquivo:= SelectFile() }) Of oDlg Pixel

		Activate MsDialog oDlg Centered On Init (EnchoiceBar(oDlg,bOk,bCancel))

		If lOk

			Processa( {|| GERADADOS()},"Processando", "Aguarde") //PROCESSAMENTO DOS CALCULOS
	
		EndIf

		RestArea(aArea)

	endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGERADADOS บAutor  ณMARCELO - ETHOSX    บ Data ณ  06/06/19   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function GERADADOS()

	Local cQuery
	Local cDtIni := Ctod( "01/" + StrZero(Val(MV_PAR01),2) + "/" + MV_PAR02 )
	Local cDtFim := LastDay(cDtIni)
	                
	If Empty(cArquivo)
		MsgInfo("Diret๓rio Nใo Selecionado!!!") 
		Return
	EndIf
	
	cQuery := " SELECT * "
	cQuery += " FROM " + RetSqlName("CT2") + " CT2 " 
	cQuery += " WHERE CT2.D_E_L_E_T_ <> '*' "
	cQuery += "        AND CT2_DATA >= '" + Dtos(cDtIni) + "' AND  CT2_DATA <= '" + Dtos(cDtFim) + "' "
	cQuery += " ORDER BY CT2.CT2_FILIAL, CT2.CT2_DATA, CT2.CT2_LOTE, CT2.CT2_SBLOTE "
	
	cQuery := ChangeQuery(cQuery)
	
	If Select("CT2CTB") > 0
		DbSelectArea("CT2CTB")
		CT2CTB->(DbCloseArea())
	EndIf
	
	ProcRegua(3)
	
	IncProc("Processando : Gerando Arquivo CT2"  )
	
	DbUseArea(.T.,"TOPCONN",TCGenqry(,,cQuery),"CT2CTB",.F.,.T.)

	TcSetField("CT2CTB","CT2_DATA"		,"D",08,00)	
	TcSetField("CT2CTB","CT2_DTVENC"	,"D",08,00)	
	TcSetField("CT2CTB","CT2_DTLP"		,"D",08,00)	
	TcSetField("CT2CTB","CT2_DATATX"	,"D",08,00)	
	TcSetField("CT2CTB","CT2_DTCV3"		,"D",08,00)	
	TcSetField("CT2CTB","CT2_DTCONF"	,"D",08,00)	
	
	TcSetField("CT2CTB","CT2_VLR01"		,"N",17,02)
	TcSetField("CT2CTB","CT2_VLR02"		,"N",17,02)
	TcSetField("CT2CTB","CT2_VLR03"		,"N",17,02)
	TcSetField("CT2CTB","CT2_VLR04"		,"N",17,02)
	TcSetField("CT2CTB","CT2_VLR05"		,"N",17,02)
	TcSetField("CT2CTB","CT2_VALOR"		,"N",17,02)
	TcSetField("CT2CTB","CT2_TAXA"		,"N",08,04)
	
	DbSelectArea("CT2CTB")
	CT2CTB->(DbGotop()) 
	
	IncProc("Processando : Prepara็ใo para Copiar"  )
  
 	If CT2CTB->(!EOF())	

		IncProc("Processando : Copiando Arquivo CT2"  )

		Copy to "CT2_" + AllTrim(MV_PAR02) + StrZero(Val(MV_PAR01),2) + ".DBF" VIA "DBFCDXADS"
 		CPYS2T ("CT2_" + AllTrim(MV_PAR02) + StrZero(Val(MV_PAR01),2) + ".DBF", cArquivo)
 		
		If File ("CT2_" + AllTrim(MV_PAR02) + StrZero(Val(MV_PAR01),2) + ".DBF")
		   Ferase("CT2_" + AllTrim(MV_PAR02) + StrZero(Val(MV_PAR01),2) + ".DBF")
		EndIf  
		
		MsgInfo("Arquivo Gerado com Sucesso. Na pasta: " + AllTrim(cArquivo) + "CT2_" + AllTrim(MV_PAR02) + StrZero(Val(MV_PAR01),2) + ".DBF")
	
	Else
	
		MsgInfo("Arquivo nใo foi gerado!!!")

 	EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออออัออออออออออออออออออออออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบ Programa  ณ SELECTFILE                             บ Data ณ 10/07/2015 บฑฑ
ฑฑฬอออออออออออุออออออออออออออออออออออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบ Autor     ณ Microsiga                                                  บฑฑ
ฑฑฬอออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Descricao ณ Rotina para selecao de arquivos CSV para importacao        บฑฑ
ฑฑบ           ณ                                                            บฑฑ
ฑฑฬอออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Sintaxe   ณ SELECTFILE()                                               บฑฑ
ฑฑฬอออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Retorno   ณ cArquivo                                                   บฑฑ
ฑฑฬอออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Uso       ณ Rede Dor Sใo Luiz                                          บฑฑ
ฑฑศอออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function SelectFile()

Local cMaskDir := "Arquivos .DBF (*.DBF) |*.DBF|"
Local cTitTela := "Local para Gerar Arquivo CT2"
Local lInfoOpen := .T.
Local lDirServidor := .T.
Local cOldFile := cArquivo

cArquivo := cGetFile(cMaskDir,cTitTela,,cArquivo,lInfoOpen, (GETF_LOCALHARD + GETF_NETWORKDRIVE + GETF_RETDIRECTORY ) ,lDirServidor)

Return cArquivo


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณValidP1   ณ Autor ณ Marcelo - Ethosx      ณ Data ณ 29.04.19  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Parametros da rotina.                			      	   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ValidP1(cPerg)

Local i:= 1
Local j:=1
Local aRegs:={}                
Local cPerg

DbSelectArea("SX1")
DbSetOrder(1)

aAdd(aRegs,{cPerg,"01","M๊s ?"	,"","","mv_ch1" ,"C", 2,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"02","Ano ?"	,"","","mv_ch2" ,"C", 4,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})

For i:=1 to Len(aRegs)
	If !DbSeek(cPerg + aRegs[i,2])
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			FieldPut(j,aRegs[i,j])
		Next
		SX1->(MsUnlock())
		dbCommit()
	Endif
Next
                          
Return(.T.)