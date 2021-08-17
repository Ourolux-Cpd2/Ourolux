#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"

#DEFINE ENTER chr(13)+chr(10)

//===========================================================================
//Programa....: CarMtas
//Autor.......: Anderson Goncalves   
//Data........: 16/04/19
//Descricao...: Função chamada para realizar a conversão de XLS para um array
//Uso.........: OurLux
////////////////////// - Parametros
//                       cArqE    - Nome do arquivo XLS a ser carregado
//                       cOrigemE - Local onde está o arquivo XLS
//                       nLinTitE - Quantas linhas de cabeçalho que não serão 
//                                  integradas possui o arquivo
//===========================================================================

User Function CarMtas(cArqE,cOrigemE,nLinTitE,lTela)   

//===========================================================================
//Variaveis da Rotina
//===========================================================================
Local lOk           := .F.
Local nLin          := 20
Local nCol1         := 15
Local nCol2         := nCol1+30
Local cMsg          := ""
Local oDlg          := Nil
Local oOrigem       := Nil
Local oMacro        := Nil 
Local nX			:= 0

Default lTela       := .T.

Private cArq        := If(ValType(cArqE)=="C",cArqE,"")
Private cArqMacro   := "XLS2DBF.XLA"
Private oArqMacro   := Nil
Private cTemp       := GetTempPath() //pega caminho do temp do client
Private cSystem     := Upper(GetSrvProfString("STARTPATH",""))//Pega o caminho do sistema
Private cOrigem     := If(ValType(cOrigemE)=="C",cOrigemE,"")
Private nLinTit     := If(ValType(nLinTitE)=="N",nLinTitE,0)
Private aArquivos   := {}
Private aRet        := {}
Private cArquivo    := Space(150)
Private oDoc        := Nil
Private cDoc        := ""
Private cDesc       := Space(TamSX3("CT_DESCRI")[1])
Private oDesc       := Nil
Private oOpcaoArq   := Nil
Private nOpcaoArq   := 1

Private cDocJan      := ""
Private cDocFev      := ""
Private cDocMar      := ""
Private cDocAbr      := ""
Private cDocMai      := ""
Private cDocJun      := ""
Private cDocJul      := ""
Private cDocAgo      := ""
Private cDocSet      := ""
Private cDocOut      := ""
Private cDocNov      := ""
Private cDocDez      := ""

Private nPosGer      := 1
Private nPosCod      := 2
Private nPosnre      := 3
Private nPos01v      := 0
Private nPos02v      := 0
Private nPos03v      := 0
Private nPos04v      := 0
Private nPos05v      := 0
Private nPos06v      := 0
Private nPos07v      := 0
Private nPos08v      := 0
Private nPos09v      := 0
Private nPos10v      := 0
Private nPos11v      := 0
Private nPos12v      := 0
Private nPos01q      := 0
Private nPos02q      := 0
Private nPos03q      := 0
Private nPos04q      := 0
Private nPos05q      := 0
Private nPos06q      := 0
Private nPos07q      := 0
Private nPos08q      := 0
Private nPos09q      := 0
Private nPos10q      := 0
Private nPos11q      := 0
Private nPos12q      := 0

cArq       += Space(20-(Len(cArq)))
cOrigem    += Space(99-(Len(cOrigem)))

//===========================================================================
//Monta interface com o usuario
//===========================================================================
If lTela .Or. Empty(AllTrim(cArq)) .Or. Empty(AllTrim(cOrigem)) 

   DEFINE MSDIALOG oDlg TITLE OemtoAnsi("Importação de Metas") FROM 199,167 TO 418,703 PIXEL

	@ 050,003 TO 078,258 LABEL " Selecione o Arquivo " PIXEL OF oDlg

	@ 005,005 Say "Documento" Size 029,008 COLOR CLR_RED PIXEL OF oDlg 
	@ 005,082 Say "Macro" Size 017,008 COLOR CLR_BLACK PIXEL OF oDlg
	@ 006,205 TO 047,259 LABEL " Extensão " PIXEL OF oDlg
	@ 013,208 Radio oOpcaoArq Var nOpcaoArq Items ".xlsx",".xls" 3D Size 037,010 PIXEL OF oDlg
	@ 013,005 MsGet oDoc Var cDoc Size 060,009 COLOR CLR_BLACK PIXEL OF oDlg When .F.
	@ 013,083 MsGet oArqMacro Var cArqMacro Size 118,009 COLOR CLR_BLACK PIXEL OF oDlg When .F.
	@ 026,005 Say "Descrição" Size 026,008 COLOR CLR_RED PIXEL OF oDlg
	@ 035,005 MsGet oDesc Var cDesc Size 196,009 COLOR CLR_BLACK PIXEL OF oDlg
	@ 057,242 Button OemtoAnsi("...") Size 014,011 PIXEL OF oDlg Action(SelectFile())
	@ 058,008 MsGet oArquivo Var cArquivo Size 232,009 COLOR CLR_BLACK PIXEL OF oDlg
	@ 081,180 Button OemtoAnsi("&Ok") Size 037,012 PIXEL OF oDlg Action( lOk:=.T.,oDlg:End() )
	@ 081,220 Button OemtoAnsi("&Cancela") Size 037,012 PIXEL OF oDlg Action( lOk:=.F.,oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED

Else
   lOk := .T.
EndIf

If lOk 

    aDivide := Separa(cArquivo,"\")
    cOrigem := ""
    cArq := aDivide[Len(aDivide)] 
    For nX := 1 To Len(aDivide)-1
        cOrigem += aDivide[nX]+"\"
    Next nX

   cMsg := validaCpos()
   If Empty(cMsg) 
      aAdd(aArquivos, cArq)
      IntegraArq()
   Else
      MsgStop(cMSg)
      Return
   EndIf
EndIf

Return aRet

//===========================================================================
//Programa....: IntegraArq
//Autor.......: Anderson Goncalves   
//Data........: 16/04/19
//Descricao...: Faz a chamada das rotinas referentes a integração
//Uso.........: OurLux
//===========================================================================

Static Function IntegraArq()

//===========================================================================
//Variaveis da Rotina
//===========================================================================
Local lConv      := .F.

//===========================================================================
//converte arquivos xls para csv copiando para a pasta temp
//===========================================================================
ConOut("Começou conversão do arquivo "+cArq+ " - "+Time())
MsAguarde( {|| lConv := convArqs(aArquivos) }, "Convertendo arquivos", "Convertendo arquivos" )
If lConv
   //carrega do xls no array
   ConOut("Terminou conversão do arquivo "+cArq+ " - "+Time())   
   ConOut("Começou carregamento do arquivo "+cArq+ " - "+Time())
   Processa( {|| aRet:= CargaArray(AllTrim(cArq)) },"Aguarde, carregando planilha...") 
   ConOut("Terminou carregamento do arquivo "+cArq+ " - "+Time())

EndIf

Return

//===========================================================================
//Programa....: convArqs
//Autor.......: Anderson Goncalves   
//Data........: 16/04/19
//Descricao...: converte os arquivos .xls para .csv
//Uso.........: OurLux
//===========================================================================

Static Function convArqs(aArqs)

//===========================================================================
//Variaveis da Rotina
//===========================================================================
Local oExcelApp := Nil
Local cNomeXLS  := ""
Local cFile     := ""
Local cExtensao := ""
Local i         := 1
Local j         := 1
Local aExtensao := {}

cOrigem := AllTrim(cOrigem)

//===========================================================================
//Verifica se o caminho termina com "\"
//===========================================================================
If !Right(cOrigem,1) $ "\"
   cOrigem := AllTrim(cOrigem)+"\"
EndIf

For i := 1 To Len(aArqs)      

   If !"." $ AllTrim(aArqs[i])
      //===========================================================================
      //passa por aqui para verifica se a extensão do arquivo é .xls ou .xlsx
      //===========================================================================
      aExtensao := Directory(cOrigem+AllTrim(aArqs[i])+".*")
      For j := 1 To Len(aExtensao)
         If "XLS" $ Upper(aExtensao[j][1])
            cExtensao := SubStr(aExtensao[j][1],Rat(".",aExtensao[j][1]),Len(aExtensao[j][1])+1-Rat(".",aExtensao[j][1]))
            Exit
         EndIf
      Next j
   EndIf
   
   //===========================================================================
   //recebe o nome do arquivo corrente
   //===========================================================================
   cNomeXLS := AllTrim(aArqs[i])
   cFile    := cOrigem+cNomeXLS+cExtensao
   
   If !File(cFile)
      MsgInfo("O arquivo "+cFile+" não foi encontrado!" ,"Arquivo")      
      Return .F.
   EndIf

   //===========================================================================
   //verifica se existe o arquivo na pasta temporaria e apaga
   //===========================================================================  
   If File(cTemp+cNomeXLS+cExtensao)
      fErase(cTemp+cNomeXLS+cExtensao)
   EndIf                 
   
   //===========================================================================
   //Copia o arquivo XLS para o Temporario para ser executado
   //===========================================================================  
   If !AvCpyFile(cFile,cTemp+cNomeXLS+cExtensao,.F.) 
      MsgInfo("Problemas na copia do arquivo "+cFile+" para "+cTemp+cNomeXLS+cExtensao ,"AvCpyFile()")
      Return .F.
   EndIf    

   //===========================================================================
   //Copia o arquivo XLA dentro da system caso não existir
   //=========================================================================== 
   If !File("\system\"+cArqMacro)  
      CpyT2S( cOrigem+cArqMacro, "\system\" )
   EndIf                                  
   
   //===========================================================================
   //apaga macro da pasta temporária se existir
   //===========================================================================  
   If File(cTemp+cArqMacro)
      fErase(cTemp+cArqMacro)
   EndIf

   //===========================================================================
   //Copia o arquivo XLA para o Temporario para ser executado
   //===========================================================================  
   If !AvCpyFile(cSystem+cArqMacro,cTemp+cArqMacro,.F.) 
      MsgInfo("Problemas na copia do arquivo "+cSystem+cArqMacro+"para"+cTemp+cArqMacro ,"AvCpyFile()")
      Return .F.
   EndIf
   
   //===========================================================================
   //Exclui o arquivo antigo (se existir)
   //===========================================================================  
   If File(cTemp+cNomeXLS+".csv")
      fErase(cTemp+cNomeXLS+".csv")
   EndIf
   
   //===========================================================================
   //Inicializa o objeto para executar a macro
   //===========================================================================  
   oExcelApp := MsExcel():New() 

   //===========================================================================
   //define qual o caminho da macro a ser executada
   //===========================================================================              
   oExcelApp:WorkBooks:Open(cTemp+cArqMacro)  

   //===========================================================================
   //executa a macro passando como parametro da macro o caminho e o nome do 
   //excel corrente
   //===========================================================================       
   oExcelApp:Run(cArqMacro+'!XLS2DBF',cTemp,cNomeXLS)

   //===========================================================================
   //fecha a macro sem salvar
   //===========================================================================  
   oExcelApp:WorkBooks:Close('savechanges:=False')

   //===========================================================================
   //sai do arquivo e destrói o objeto
   //===========================================================================  
   oExcelApp:Quit()
   oExcelApp:Destroy()

   //===========================================================================
   //Exclui o Arquivo excel da temp
   //===========================================================================  
   fErase(cTemp+cNomeXLS+cExtensao)

   //===========================================================================
   //Exclui a Macro no diretorio temporario
   //===========================================================================  
   fErase(cTemp+cArqMacro) 
 
Next i

Return .T. 

//===========================================================================
//Programa....: CargaDados
//Autor.......: Anderson Goncalves   
//Data........: 16/04/19
//Descricao...: carrega dados do csv no array pra retorno
//Uso.........: OurLux
//===========================================================================

Static Function CargaArray(cArq)

//===========================================================================
//Variaveis da Rotina
//===========================================================================
Local cLinha   	:= ""
Local nLin     	:= 1 
Local nTotLin  	:= 0
Local aDados   	:= {}
Local cFile    	:= cTemp + SubStr(cArq,1,Len(cArq)-4) + ".csv"
Local nHandle  	:= 0
Local lGrava   	:= .F.

Local candress 	:= GetTempPath()
Local cArqLog  	:= "Log"+Replace(Time(),":","")+".txt"
Local nHdl    	:= fCreate(candress+cArqLog)
Local nY		:= 0
Local nX		:= 0

cFile := Replace(cFile,"..",".")

//===========================================================================
//abre o arquivo csv gerado na temp
//===========================================================================
nHandle := Ft_Fuse(cFile)
If nHandle == -1
   Return aDados
EndIf
Ft_FGoTop()                                                         
nLinTot := FT_FLastRec()-1
ProcRegua(nLinTot)

//===========================================================================
//Pula as linhas de cabeçalho
//===========================================================================
While nLinTit > 0 .AND. !Ft_FEof()
   Ft_FSkip()
   nLinTit--
EndDo

//===========================================================================
//percorre todas linhas do arquivo csv
//===========================================================================
Do While !Ft_FEof()

   //===========================================================================
   //exibe a linha a ser lida
   //===========================================================================
   IncProc("Carregando Linha "+AllTrim(Str(nLin))+" de "+AllTrim(Str(nLinTot)))
   nLin++

   //===========================================================================
   //Leitura da Linha
   //===========================================================================
   cLinha := Ft_FReadLn()

   //===========================================================================
   //verifica se a linha está em branco, se estiver pula
   //===========================================================================
   If Empty(AllTrim(StrTran(cLinha,';',''))) .or. SubStr(cLinha,1,2) == ";;"
      Ft_FSkip()
      Loop
   EndIf

   //===========================================================================
   //transforma as aspas duplas em aspas simples
   //===========================================================================
   cLinha := StrTran(cLinha,'"',"'")
   cLinha := '{"'+cLinha+'"}' 

   //===========================================================================
   //adiciona o cLinha no array trocando o delimitador ; por , para ser 
   //reconhecido como elementos de um array 
   //===========================================================================
   cLinha := StrTran(cLinha,';','","')
   aAdd(aDados, &cLinha)
 
   FT_FSkip()
 
EndDo

//===========================================================================
//Verifica o nome das celulas
//===========================================================================
For nX := 1 To 1
   For nY := 1 To Len(aDados[1])

      If Upper(Left(aDados[nX,nY],3)) == "JAN" .and. nPos01v == 0 
         nPos01v      := nY
      ElseIf Upper(Left(aDados[nX,nY],3)) == "FEV" .and. nPos02v == 0  
         nPos02v      := nY
      ElseIf Upper(Left(aDados[nX,nY],3)) == "MAR" .and. nPos03v == 0  
         nPos03v      := nY
      ElseIf Upper(Left(aDados[nX,nY],3)) == "ABR" .and. nPos04v == 0  
         nPos04v      := nY
      ElseIf Upper(Left(aDados[nX,nY],3)) == "MAI" .and. nPos05v == 0  
         nPos05v      := nY
      ElseIf Upper(Left(aDados[nX,nY],3)) == "JUN" .and. nPos06v == 0  
         nPos06v      := nY
      ElseIf Upper(Left(aDados[nX,nY],3)) == "JUL" .and. nPos07v == 0  
         nPos07v      := nY
      ElseIf Upper(Left(aDados[nX,nY],3)) == "AGO" .and. nPos08v == 0  
         nPos08v      := nY
      ElseIf Upper(Left(aDados[nX,nY],3)) == "SET" .and. nPos09v == 0  
         nPos09v      := nY
      ElseIf Upper(Left(aDados[nX,nY],3)) == "OUT" .and. nPos10v == 0  
         nPos10v      := nY
      ElseIf Upper(Left(aDados[nX,nY],3)) == "NOV" .and. nPos11v == 0  
         nPos11v      := nY
      ElseIf Upper(Left(aDados[nX,nY],3)) == "DEZ" .and. nPos12v == 0  
         nPos12v      := nY
      ElseIf Upper(Left(aDados[nX,nY],3)) == "JAN" .and. nPos01q == 0  
         nPos01q      := nY
      ElseIf Upper(Left(aDados[nX,nY],3)) == "FEV" .and. nPos02q == 0  
         nPos02q      := nY
      ElseIf Upper(Left(aDados[nX,nY],3)) == "MAR" .and. nPos03q == 0  
         nPos03q      := nY
      ElseIf Upper(Left(aDados[nX,nY],3)) == "ABR" .and. nPos04q == 0  
         nPos04q      := nY
      ElseIf Upper(Left(aDados[nX,nY],3)) == "MAI" .and. nPos05q == 0  
         nPos05q      := nY
      ElseIf Upper(Left(aDados[nX,nY],3)) == "JUN" .and. nPos06q == 0  
         nPos06q      := nY
      ElseIf Upper(Left(aDados[nX,nY],3)) == "JUL" .and. nPos07q == 0  
         nPos07q      := nY
      ElseIf Upper(Left(aDados[nX,nY],3)) == "AGO" .and. nPos08q == 0  
         nPos08q      := nY
      ElseIf Upper(Left(aDados[nX,nY],3)) == "SET" .and. nPos09q == 0  
         nPos09q      := nY
      ElseIf Upper(Left(aDados[nX,nY],3)) == "OUT" .and. nPos10q == 0  
         nPos10q      := nY
      ElseIf Upper(Left(aDados[nX,nY],3)) == "NOV" .and. nPos11q == 0  
         nPos11q      := nY
      ElseIf Upper(Left(aDados[nX,nY],3)) == "DEZ" .and. nPos12q == 0  
         nPos12q      := nY
      Endif

   Next nY
Next nX

//===========================================================================
//libera o arquivo CSV
//===========================================================================
FT_FUse()     

//===========================================================================
//Efetua a gravacao em SCT
//===========================================================================
dbSelectArea("SCT")
SCT->(dbSetOrder(1))

ProcRegua(Len(aDados))
For nX := 2 To Len(aDados)

   IncProc("Gavando linha "+ AllTrim(Str(nX))+" de "+AllTrim(Str(Len(aDados))))

   //Gravacao para Janeiro
   If nPos01v > 0
      If Val(aDados[nX,nPos01v]) > 0
         cValMeta := aDados[nX,nPos01v] 
         cValMeta := Replace(cValMeta,".","")
         cValMeta := Replace(cValMeta,",",".")
         dDataGrv := LastDay(stod("20"+Right(aDados[1,nPos01v],2)+"0101"))

         nRecnoSCT := ProcRecno(dDataGrv,aDados[nX,nPosCod])
         lGrava := .T.
         If nRecnoSCT > 0
            dbSelectArea("SCT")
            SCT->(dbSetOrder(1))
            SCT->(dbGoTo(nRecnoSCT))
            lGrava := .F.
         Endif

         RecLock("SCT",lGrava)
         If lGrava
            If Empty(cDocJan)
               cDocJan      := GetSXENum("SCT","CT_DOC")
               ConfirmSX8()
            EndIf
            SCT->CT_FILIAL := xFilial("SCT")
            SCT->CT_DATA   := dDataGrv
            SCT->CT_DESCRI := Upper(AllTrim(Str(Year(dDataGrv)))+" - JANEIRO "+AllTrim(cDesc))
            SCT->CT_DOC    := cDocJan
            SCT->CT_MOEDA  := 1
            SCT->CT_VEND   := aDados[nX,nPosCod]
         EndIf
         SCT->CT_VALOR  := Val(cValMeta)
         SCT->CT_QUANT  := Val(aDados[nX,nPos01q])
         If lGrava
            cQuery := "SELECT ISNULL(MAX(CT_SEQUEN),'000') CSEQ FROM "+RetSqlName("SCT")+" (NOLOCK) "
            cQuery += "WHERE CT_FILIAL = '" + xFilial("SCT") + "' "
            cQuery += "AND CT_DOC = '" + cDocJan + "' "
            cQuery += "AND D_E_L_E_T_ = ' ' "
            If Select("QUERY") > 0
               QUERY->(dbCloseArea())
            EndIf
            TcQuery cQuery New Alias "QUERY"
            SCT->CT_SEQUEN := Soma1(QUERY->CSEQ)
            QUERY->(dbCloseArea())
            SCT->CT_MSBLQL := "2"
         EndIf
         SCT->(msUnlock())

         If lGrava
            cTexto := "Status -> INCLUSAO *** Emissao: "+TransForm(dDataGrv,"@D")+" *** Vendedor: "+aDados[nX,nPosCod]+" *** Qtd: "+TransForm(Val(aDados[nX,nPos01q]),"@E 999,999,999.99")+" *** Valor: "+TransForm(Val(cValMeta),"@E 9,999,999,999.99")+Chr(13)+Chr(10)
            cTexto += Replicate("*",120)+Chr(13)+Chr(10)
            fWrite(nHdl,cTexto)
         Else
            cTexto := "Status -> ALTERACAO *** Emissao: "+TransForm(dDataGrv,"@D")+" *** Vendedor: "+aDados[nX,nPosCod]+" *** Qtd: "+TransForm(Val(aDados[nX,nPos01q]),"@E 999,999,999.99")+" *** Valor: "+TransForm(Val(cValMeta),"@E 9,999,999,999.99")+Chr(13)+Chr(10)
            cTexto += Replicate("*",120)+Chr(13)+Chr(10)
            fWrite(nHdl,cTexto)
         EndIf

      //Exclui o registro se o valor for 0
      ElseIf Val(aDados[nX,nPos01v]) <= 0
         dDataGrv := LastDay(stod("20"+Right(aDados[1,nPos01v],2)+"0101"))
         nRecnoSCT := ProcRecno(dDataGrv,aDados[nX,nPosCod])
         If nRecnoSCT > 0
            dbSelectArea("SCT")
            SCT->(dbSetOrder(1))
            SCT->(dbGoTo(nRecnoSCT))
            nQtdMt := SCT->CT_QUANT
            nValMt := SCT->CT_VALOR 
            cVend1 := SCT->CT_VEND
            RecLock("SCT",.F.)
            SCT->(dbDelete())
            SCT->(msUnlock())

            cTexto := "Status -> EXCLUSAO *** Emissao: "+TransForm(dDataGrv,"@D")+" *** Vendedor: "+cVend1+" *** Qtd: "+TransForm(nQtdMt,"@E 999,999,999.99")+" *** Valor: "+TransForm(nValMt,"@E 9,999,999,999.99")+Chr(13)+Chr(10)
            cTexto += Replicate("*",120)+Chr(13)+Chr(10)
            fWrite(nHdl,cTexto)

         EndIf
      Endif
   EndIf

   //Gravacao para Fevereiro
   If nPos02v > 0
      If Val(aDados[nX,nPos02v]) > 0
         cValMeta := aDados[nX,nPos02v] 
         cValMeta := Replace(cValMeta,".","")
         cValMeta := Replace(cValMeta,",",".")
         dDataGrv := LastDay(stod("20"+Right(aDados[1,nPos02v],2)+"0201"))

         nRecnoSCT := ProcRecno(dDataGrv,aDados[nX,nPosCod])
         lGrava := .T.
         If nRecnoSCT > 0
            dbSelectArea("SCT")
            SCT->(dbSetOrder(1))
            SCT->(dbGoTo(nRecnoSCT))
            lGrava := .F.
         Endif

         RecLock("SCT",lGrava)
         If lGrava
            If Empty(cDocFev)
               cDocFev      := GetSXENum("SCT","CT_DOC")
               ConfirmSX8()
            EndIf
            SCT->CT_FILIAL := xFilial("SCT")
            SCT->CT_DATA   := dDataGrv
            SCT->CT_DESCRI := Upper(AllTrim(Str(Year(dDataGrv)))+" - FEVEREIRO "+AllTrim(cDesc))
            SCT->CT_DOC    := cDocFev
            SCT->CT_MOEDA  := 1
            SCT->CT_VEND   := aDados[nX,nPosCod]
         EndIf
         SCT->CT_VALOR  := Val(cValMeta)
         SCT->CT_QUANT  := Val(aDados[nX,nPos02q])
         If lGrava
            cQuery := "SELECT ISNULL(MAX(CT_SEQUEN),'000') CSEQ FROM "+RetSqlName("SCT")+" (NOLOCK) "
            cQuery += "WHERE CT_FILIAL = '" + xFilial("SCT") + "' "
            cQuery += "AND CT_DOC = '" + cDocFev + "' "
            cQuery += "AND D_E_L_E_T_ = ' ' "
            If Select("QUERY") > 0
               QUERY->(dbCloseArea())
            EndIf
            TcQuery cQuery New Alias "QUERY"
            SCT->CT_SEQUEN := Soma1(QUERY->CSEQ)
            QUERY->(dbCloseArea())
            SCT->CT_MSBLQL := "2"
         EndIf
         SCT->(msUnlock())

         If lGrava
            cTexto := "Status -> INCLUSAO *** Emissao: "+TransForm(dDataGrv,"@D")+" *** Vendedor: "+aDados[nX,nPosCod]+" *** Qtd: "+TransForm(Val(aDados[nX,nPos02q]),"@E 999,999,999.99")+" *** Valor: "+TransForm(Val(cValMeta),"@E 9,999,999,999.99")+Chr(13)+Chr(10)
            cTexto += Replicate("*",120)+Chr(13)+Chr(10)
            fWrite(nHdl,cTexto)
         Else
            cTexto := "Status -> ALTERACAO *** Emissao: "+TransForm(dDataGrv,"@D")+" *** Vendedor: "+aDados[nX,nPosCod]+" *** Qtd: "+TransForm(Val(aDados[nX,nPos02q]),"@E 999,999,999.99")+" *** Valor: "+TransForm(Val(cValMeta),"@E 9,999,999,999.99")+Chr(13)+Chr(10)
            cTexto += Replicate("*",120)+Chr(13)+Chr(10)
            fWrite(nHdl,cTexto)
         EndIf

      //Exclui o registro se o valor for 0
      ElseIf Val(aDados[nX,nPos02v]) <= 0
         dDataGrv := LastDay(stod("20"+Right(aDados[1,nPos02v],2)+"0201"))
         nRecnoSCT := ProcRecno(dDataGrv,aDados[nX,nPosCod])
         If nRecnoSCT > 0
            dbSelectArea("SCT")
            SCT->(dbSetOrder(1))
            SCT->(dbGoTo(nRecnoSCT))
            nQtdMt := SCT->CT_QUANT
            nValMt := SCT->CT_VALOR 
            cVend1 := SCT->CT_VEND
            RecLock("SCT",.F.)
            SCT->(dbDelete())
            SCT->(msUnlock())

            cTexto := "Status -> EXCLUSAO *** Emissao: "+TransForm(dDataGrv,"@D")+" *** Vendedor: "+cVend1+" *** Qtd: "+TransForm(nQtdMt,"@E 999,999,999.99")+" *** Valor: "+TransForm(nValMt,"@E 9,999,999,999.99")+Chr(13)+Chr(10)
            cTexto += Replicate("*",120)+Chr(13)+Chr(10)
            fWrite(nHdl,cTexto)

         EndIf
      Endif
   EndIf

   //Gravacao para Marco
   If nPos03v > 0
      If Val(aDados[nX,nPos03v]) > 0
         cValMeta := aDados[nX,nPos03v] 
         cValMeta := Replace(cValMeta,".","")
         cValMeta := Replace(cValMeta,",",".")
         dDataGrv := LastDay(stod("20"+Right(aDados[1,nPos03v],2)+"0301"))
         
         nRecnoSCT := ProcRecno(dDataGrv,aDados[nX,nPosCod])
         lGrava := .T.
         If nRecnoSCT > 0
            dbSelectArea("SCT")
            SCT->(dbSetOrder(1))
            SCT->(dbGoTo(nRecnoSCT))
            lGrava := .F.
         Endif
         
         RecLock("SCT",lGrava)
         If lGrava
            If Empty(cDocMar)
               cDocMar      := GetSXENum("SCT","CT_DOC")
               ConfirmSX8()
            EndIf
            SCT->CT_FILIAL := xFilial("SCT")
            SCT->CT_DATA   := dDataGrv
            SCT->CT_DESCRI := Upper(AllTrim(Str(Year(dDataGrv)))+" - MARCO "+AllTrim(cDesc))
            SCT->CT_DOC    := cDocMar
            SCT->CT_MOEDA  := 1
            SCT->CT_VEND   := aDados[nX,nPosCod]
         EndIf
         SCT->CT_VALOR  := Val(cValmeta)
         SCT->CT_QUANT  := Val(aDados[nX,nPos03q])
         If lGrava
            cQuery := "SELECT ISNULL(MAX(CT_SEQUEN),'000') CSEQ FROM "+RetSqlName("SCT")+" (NOLOCK) "
            cQuery += "WHERE CT_FILIAL = '" + xFilial("SCT") + "' "
            cQuery += "AND CT_DOC = '" + cDocMar + "' "
            cQuery += "AND D_E_L_E_T_ = ' ' "
            If Select("QUERY") > 0
               QUERY->(dbCloseArea())
            EndIf
            TcQuery cQuery New Alias "QUERY"
            SCT->CT_SEQUEN := Soma1(QUERY->CSEQ)
            QUERY->(dbCloseArea())
            SCT->CT_MSBLQL := "2"
         EndIf
         SCT->(msUnlock())

         If lGrava
            cTexto := "Status -> INCLUSAO *** Emissao: "+TransForm(dDataGrv,"@D")+" *** Vendedor: "+aDados[nX,nPosCod]+" *** Qtd: "+TransForm(Val(aDados[nX,nPos03q]),"@E 999,999,999.99")+" *** Valor: "+TransForm(Val(cValMeta),"@E 9,999,999,999.99")+Chr(13)+Chr(10)
            cTexto += Replicate("*",120)+Chr(13)+Chr(10)
            fWrite(nHdl,cTexto)
         Else
            cTexto := "Status -> ALTERACAO *** Emissao: "+TransForm(dDataGrv,"@D")+" *** Vendedor: "+aDados[nX,nPosCod]+" *** Qtd: "+TransForm(Val(aDados[nX,nPos03q]),"@E 999,999,999.99")+" *** Valor: "+TransForm(Val(cValMeta),"@E 9,999,999,999.99")+Chr(13)+Chr(10)
            cTexto += Replicate("*",120)+Chr(13)+Chr(10)
            fWrite(nHdl,cTexto)
         EndIf

      //Exclui o registro se o valor for 0
      ElseIf Val(aDados[nX,nPos03v]) <= 0
         dDataGrv := LastDay(stod("20"+Right(aDados[1,nPos03v],2)+"0301"))
         nRecnoSCT := ProcRecno(dDataGrv,aDados[nX,nPosCod])
         If nRecnoSCT > 0
            dbSelectArea("SCT")
            SCT->(dbSetOrder(1))
            SCT->(dbGoTo(nRecnoSCT))
            nQtdMt := SCT->CT_QUANT
            nValMt := SCT->CT_VALOR 
            cVend1 := SCT->CT_VEND
            RecLock("SCT",.F.)
            SCT->(dbDelete())
            SCT->(msUnlock())

            cTexto := "Status -> EXCLUSAO *** Emissao: "+TransForm(dDataGrv,"@D")+" *** Vendedor: "+cVend1+" *** Qtd: "+TransForm(nQtdMt,"@E 999,999,999.99")+" *** Valor: "+TransForm(nValMt,"@E 9,999,999,999.99")+Chr(13)+Chr(10)
            cTexto += Replicate("*",120)+Chr(13)+Chr(10)
            fWrite(nHdl,cTexto)

         EndIf
      Endif
   Endif

   //Gravacao para Abril
   If nPos04v > 0
      If Val(aDados[nX,nPos04v]) > 0
         cValMeta := aDados[nX,nPos04v] 
         cValMeta := Replace(cValMeta,".","")
         cValMeta := Replace(cValMeta,",",".")
         dDataGrv := LastDay(stod("20"+Right(aDados[1,nPos04v],2)+"0401"))
         
         nRecnoSCT := ProcRecno(dDataGrv,aDados[nX,nPosCod])
         lGrava := .T.
         If nRecnoSCT > 0
            dbSelectArea("SCT")
            SCT->(dbSetOrder(1))
            SCT->(dbGoTo(nRecnoSCT))
            lGrava := .F.
         Endif
         
         RecLock("SCT",lGrava)
         If lGrava
            If Empty(cDocAbr)
               cDocAbr      := GetSXENum("SCT","CT_DOC")
               ConfirmSX8()
            EndIf
            SCT->CT_FILIAL := xFilial("SCT")
            SCT->CT_DATA   := dDataGrv
            SCT->CT_DESCRI := Upper(AllTrim(Str(Year(dDataGrv)))+" - ABRIL "+AllTrim(cDesc))
            SCT->CT_DOC    := cDocAbr
            SCT->CT_MOEDA  := 1
            SCT->CT_VEND   := aDados[nX,nPosCod]
         EndIf
         SCT->CT_VALOR  := Val(cValMeta)
         SCT->CT_QUANT  := Val(aDados[nX,nPos04q])
         If lGrava
            cQuery := "SELECT ISNULL(MAX(CT_SEQUEN),'000') CSEQ FROM "+RetSqlName("SCT")+" (NOLOCK) "
            cQuery += "WHERE CT_FILIAL = '" + xFilial("SCT") + "' "
            cQuery += "AND CT_DOC = '" + cDocAbr + "' "
            cQuery += "AND D_E_L_E_T_ = ' ' "
            If Select("QUERY") > 0
               QUERY->(dbCloseArea())
            EndIf
            TcQuery cQuery New Alias "QUERY"
            SCT->CT_SEQUEN := Soma1(QUERY->CSEQ)
            QUERY->(dbCloseArea())
            SCT->CT_MSBLQL := "2"
         EndIf
         SCT->(msUnlock())

         If lGrava
            cTexto := "Status -> INCLUSAO *** Emissao: "+TransForm(dDataGrv,"@D")+" *** Vendedor: "+aDados[nX,nPosCod]+" *** Qtd: "+TransForm(Val(aDados[nX,nPos04q]),"@E 999,999,999.99")+" *** Valor: "+TransForm(Val(cValMeta),"@E 9,999,999,999.99")+Chr(13)+Chr(10)
            cTexto += Replicate("*",120)+Chr(13)+Chr(10)
            fWrite(nHdl,cTexto)
         Else
            cTexto := "Status -> ALTERACAO *** Emissao: "+TransForm(dDataGrv,"@D")+" *** Vendedor: "+aDados[nX,nPosCod]+" *** Qtd: "+TransForm(Val(aDados[nX,nPos04q]),"@E 999,999,999.99")+" *** Valor: "+TransForm(Val(cValMeta),"@E 9,999,999,999.99")+Chr(13)+Chr(10)
            cTexto += Replicate("*",120)+Chr(13)+Chr(10)
            fWrite(nHdl,cTexto)
         EndIf

      //Exclui o registro se o valor for 0
      ElseIf Val(aDados[nX,nPos04v]) <= 0
         dDataGrv := LastDay(stod("20"+Right(aDados[1,nPos04v],2)+"0401"))
         nRecnoSCT := ProcRecno(dDataGrv,aDados[nX,nPosCod])
         If nRecnoSCT > 0
            dbSelectArea("SCT")
            SCT->(dbSetOrder(1))
            SCT->(dbGoTo(nRecnoSCT))
            nQtdMt := SCT->CT_QUANT
            nValMt := SCT->CT_VALOR 
            cVend1 := SCT->CT_VEND
            RecLock("SCT",.F.)
            SCT->(dbDelete())
            SCT->(msUnlock())

            cTexto := "Status -> EXCLUSAO *** Emissao: "+TransForm(dDataGrv,"@D")+" *** Vendedor: "+cVend1+" *** Qtd: "+TransForm(nQtdMt,"@E 999,999,999.99")+" *** Valor: "+TransForm(nValMt,"@E 9,999,999,999.99")+Chr(13)+Chr(10)
            cTexto += Replicate("*",120)+Chr(13)+Chr(10)
            fWrite(nHdl,cTexto)

         EndIf
      Endif
   Endif

   //Gravacao para Maio
   If nPos05v > 0
      If Val(aDados[nX,nPos05v]) > 0
         cValMeta := aDados[nX,nPos05v] 
         cValMeta := Replace(cValMeta,".","")
         cValMeta := Replace(cValMeta,",",".")
         dDataGrv := LastDay(stod("20"+Right(aDados[1,nPos05v],2)+"0501"))
         
         nRecnoSCT := ProcRecno(dDataGrv,aDados[nX,nPosCod])
         lGrava := .T.
         If nRecnoSCT > 0
            dbSelectArea("SCT")
            SCT->(dbSetOrder(1))
            SCT->(dbGoTo(nRecnoSCT))
            lGrava := .F.
         Endif
         
         RecLock("SCT",lGrava)
         If lGrava
            If Empty(cDocMai)
               cDocMai      := GetSXENum("SCT","CT_DOC")
               ConfirmSX8()
            EndIf
            SCT->CT_FILIAL := xFilial("SCT")
            SCT->CT_DATA   := dDataGrv
            SCT->CT_DESCRI := Upper(AllTrim(Str(Year(dDataGrv)))+" - MAIO "+AllTrim(cDesc))
            SCT->CT_DOC    := cDocMai
            SCT->CT_MOEDA  := 1
            SCT->CT_VEND   := aDados[nX,nPosCod]
         EndIf
         SCT->CT_VALOR  := Val(cValMeta)
         SCT->CT_QUANT  := Val(aDados[nX,nPos05q])
         If lGrava
            cQuery := "SELECT ISNULL(MAX(CT_SEQUEN),'000') CSEQ FROM "+RetSqlName("SCT")+" (NOLOCK) "
            cQuery += "WHERE CT_FILIAL = '" + xFilial("SCT") + "' "
            cQuery += "AND CT_DOC = '" + cDocMai + "' "
            cQuery += "AND D_E_L_E_T_ = ' ' "
            If Select("QUERY") > 0
               QUERY->(dbCloseArea())
            EndIf
            TcQuery cQuery New Alias "QUERY"
            SCT->CT_SEQUEN := Soma1(QUERY->CSEQ)
            QUERY->(dbCloseArea())
            SCT->CT_MSBLQL := "2"
         EndIf
         SCT->(msUnlock())

         If lGrava
            cTexto := "Status -> INCLUSAO *** Emissao: "+TransForm(dDataGrv,"@D")+" *** Vendedor: "+aDados[nX,nPosCod]+" *** Qtd: "+TransForm(Val(aDados[nX,nPos05q]),"@E 999,999,999.99")+" *** Valor: "+TransForm(Val(cValMeta),"@E 9,999,999,999.99")+Chr(13)+Chr(10)
            cTexto += Replicate("*",120)+Chr(13)+Chr(10)
            fWrite(nHdl,cTexto)
         Else
            cTexto := "Status -> ALTERACAO *** Emissao: "+TransForm(dDataGrv,"@D")+" *** Vendedor: "+aDados[nX,nPosCod]+" *** Qtd: "+TransForm(Val(aDados[nX,nPos05q]),"@E 999,999,999.99")+" *** Valor: "+TransForm(Val(cValMeta),"@E 9,999,999,999.99")+Chr(13)+Chr(10)
            cTexto += Replicate("*",120)+Chr(13)+Chr(10)
            fWrite(nHdl,cTexto)
         EndIf

      //Exclui o registro se o valor for 0
      ElseIf Val(aDados[nX,nPos05v]) <= 0
         dDataGrv := LastDay(stod("20"+Right(aDados[1,nPos05v],2)+"0501"))
         nRecnoSCT := ProcRecno(dDataGrv,aDados[nX,nPosCod])
         If nRecnoSCT > 0
            dbSelectArea("SCT")
            SCT->(dbSetOrder(1))
            SCT->(dbGoTo(nRecnoSCT))
            nQtdMt := SCT->CT_QUANT
            nValMt := SCT->CT_VALOR 
            cVend1 := SCT->CT_VEND
            RecLock("SCT",.F.)
            SCT->(dbDelete())
            SCT->(msUnlock())

            cTexto := "Status -> EXCLUSAO *** Emissao: "+TransForm(dDataGrv,"@D")+" *** Vendedor: "+cVend1+" *** Qtd: "+TransForm(nQtdMt,"@E 999,999,999.99")+" *** Valor: "+TransForm(nValMt,"@E 9,999,999,999.99")+Chr(13)+Chr(10)
            cTexto += Replicate("*",120)+Chr(13)+Chr(10)
            fWrite(nHdl,cTexto)

         EndIf
      Endif
   EndIf

   //Gravacao para Junho
   If nPos06v > 0
      If Val(aDados[nX,nPos06v]) > 0
         cValMeta := aDados[nX,nPos06v] 
         cValMeta := Replace(cValMeta,".","")
         cValMeta := Replace(cValMeta,",",".")
         dDataGrv := LastDay(stod("20"+Right(aDados[1,nPos06v],2)+"0601"))
         
         nRecnoSCT := ProcRecno(dDataGrv,aDados[nX,nPosCod])
         lGrava := .T.
         If nRecnoSCT > 0
            dbSelectArea("SCT")
            SCT->(dbSetOrder(1))
            SCT->(dbGoTo(nRecnoSCT))
            lGrava := .F.
         Endif
         
         RecLock("SCT",lGrava)
         If lGrava
            If Empty(cDocJun)
               cDocJun      := GetSXENum("SCT","CT_DOC")
               ConfirmSX8()
            EndIf
            SCT->CT_FILIAL := xFilial("SCT")
            SCT->CT_DATA   := dDataGrv
            SCT->CT_DESCRI := Upper(AllTrim(Str(Year(dDataGrv)))+" - JUNHO "+AllTrim(cDesc))
            SCT->CT_DOC    := cDocJun
            SCT->CT_MOEDA  := 1
            SCT->CT_VEND   := aDados[nX,nPosCod]
         EndIf
         SCT->CT_VALOR  := Val(cValMeta)
         SCT->CT_QUANT  := Val(aDados[nX,nPos06q])
         If lGrava
            cQuery := "SELECT ISNULL(MAX(CT_SEQUEN),'000') CSEQ FROM "+RetSqlName("SCT")+" (NOLOCK) "
            cQuery += "WHERE CT_FILIAL = '" + xFilial("SCT") + "' "
            cQuery += "AND CT_DOC = '" + cDocJun + "' "
            cQuery += "AND D_E_L_E_T_ = ' ' "
            If Select("QUERY") > 0
               QUERY->(dbCloseArea())
            EndIf
            TcQuery cQuery New Alias "QUERY"
            SCT->CT_SEQUEN := Soma1(QUERY->CSEQ)
            QUERY->(dbCloseArea())
            SCT->CT_MSBLQL := "2"
         EndIf
         SCT->(msUnlock())

         If lGrava
            cTexto := "Status -> INCLUSAO *** Emissao: "+TransForm(dDataGrv,"@D")+" *** Vendedor: "+aDados[nX,nPosCod]+" *** Qtd: "+TransForm(Val(aDados[nX,nPos06q]),"@E 999,999,999.99")+" *** Valor: "+TransForm(Val(cValMeta),"@E 9,999,999,999.99")+Chr(13)+Chr(10)
            cTexto += Replicate("*",120)+Chr(13)+Chr(10)
            fWrite(nHdl,cTexto)
         Else
            cTexto := "Status -> ALTERACAO *** Emissao: "+TransForm(dDataGrv,"@D")+" *** Vendedor: "+aDados[nX,nPosCod]+" *** Qtd: "+TransForm(Val(aDados[nX,nPos06q]),"@E 999,999,999.99")+" *** Valor: "+TransForm(Val(cValMeta),"@E 9,999,999,999.99")+Chr(13)+Chr(10)
            cTexto += Replicate("*",120)+Chr(13)+Chr(10)
            fWrite(nHdl,cTexto)
         EndIf

      //Exclui o registro se o valor for 0
      ElseIf Val(aDados[nX,nPos06v]) <= 0
         dDataGrv := LastDay(stod("20"+Right(aDados[1,nPos06v],2)+"0601"))
         nRecnoSCT := ProcRecno(dDataGrv,aDados[nX,nPosCod])
         If nRecnoSCT > 0
            dbSelectArea("SCT")
            SCT->(dbSetOrder(1))
            SCT->(dbGoTo(nRecnoSCT))
            nQtdMt := SCT->CT_QUANT
            nValMt := SCT->CT_VALOR 
            cVend1 := SCT->CT_VEND
            RecLock("SCT",.F.)
            SCT->(dbDelete())
            SCT->(msUnlock())

            cTexto := "Status -> EXCLUSAO *** Emissao: "+TransForm(dDataGrv,"@D")+" *** Vendedor: "+cVend1+" *** Qtd: "+TransForm(nQtdMt,"@E 999,999,999.99")+" *** Valor: "+TransForm(nValMt,"@E 9,999,999,999.99")+Chr(13)+Chr(10)
            cTexto += Replicate("*",120)+Chr(13)+Chr(10)
            fWrite(nHdl,cTexto)

         EndIf
      Endif
   EndIf

   //Gravacao para Julho
   If nPos07v > 0
      If Val(aDados[nX,nPos07v]) > 0
         cValMeta := aDados[nX,nPos07v] 
         cValMeta := Replace(cValMeta,".","")
         cValMeta := Replace(cValMeta,",",".")
         dDataGrv := LastDay(stod("20"+Right(aDados[1,nPos07v],2)+"0701"))
         
         nRecnoSCT := ProcRecno(dDataGrv,aDados[nX,nPosCod])
         lGrava := .T.
         If nRecnoSCT > 0
            dbSelectArea("SCT")
            SCT->(dbSetOrder(1))
            SCT->(dbGoTo(nRecnoSCT))
            lGrava := .F.
         Endif
         
         RecLock("SCT",lGrava)
         If lGrava
            If Empty(cDocJul)
               cDocJul      := GetSXENum("SCT","CT_DOC")
               ConfirmSX8()
            EndIf
            SCT->CT_FILIAL := xFilial("SCT")
            SCT->CT_DATA   := dDataGrv
            SCT->CT_DESCRI := Upper(AllTrim(Str(Year(dDataGrv)))+" - JULHO "+AllTrim(cDesc))
            SCT->CT_DOC    := cDocJul
            SCT->CT_MOEDA  := 1
            SCT->CT_VEND   := aDados[nX,nPosCod]
         EndIf
         SCT->CT_VALOR  := Val(cValMeta)
         SCT->CT_QUANT  := Val(aDados[nX,nPos07q])
         If lGrava
            cQuery := "SELECT ISNULL(MAX(CT_SEQUEN),'000') CSEQ FROM "+RetSqlName("SCT")+" (NOLOCK) "
            cQuery += "WHERE CT_FILIAL = '" + xFilial("SCT") + "' "
            cQuery += "AND CT_DOC = '" + cDocJul + "' "
            cQuery += "AND D_E_L_E_T_ = ' ' "
            If Select("QUERY") > 0
               QUERY->(dbCloseArea())
            EndIf
            TcQuery cQuery New Alias "QUERY"
            SCT->CT_SEQUEN := Soma1(QUERY->CSEQ)
            QUERY->(dbCloseArea())
            SCT->CT_MSBLQL := "2"
         EndIf
         SCT->(msUnlock())

         If lGrava
            cTexto := "Status -> INCLUSAO *** Emissao: "+TransForm(dDataGrv,"@D")+" *** Vendedor: "+aDados[nX,nPosCod]+" *** Qtd: "+TransForm(Val(aDados[nX,nPos07q]),"@E 999,999,999.99")+" *** Valor: "+TransForm(Val(cValMeta),"@E 9,999,999,999.99")+Chr(13)+Chr(10)
            cTexto += Replicate("*",120)+Chr(13)+Chr(10)
            fWrite(nHdl,cTexto)
         Else
            cTexto := "Status -> ALTERACAO *** Emissao: "+TransForm(dDataGrv,"@D")+" *** Vendedor: "+aDados[nX,nPosCod]+" *** Qtd: "+TransForm(Val(aDados[nX,nPos07q]),"@E 999,999,999.99")+" *** Valor: "+TransForm(Val(cValMeta),"@E 9,999,999,999.99")+Chr(13)+Chr(10)
            cTexto += Replicate("*",120)+Chr(13)+Chr(10)
            fWrite(nHdl,cTexto)
         EndIf

      //Exclui o registro se o valor for 0
      ElseIf Val(aDados[nX,nPos07v]) <= 0
         dDataGrv := LastDay(stod("20"+Right(aDados[1,nPos07v],2)+"0701"))
         nRecnoSCT := ProcRecno(dDataGrv,aDados[nX,nPosCod])
         If nRecnoSCT > 0
            dbSelectArea("SCT")
            SCT->(dbSetOrder(1))
            SCT->(dbGoTo(nRecnoSCT))
            nQtdMt := SCT->CT_QUANT
            nValMt := SCT->CT_VALOR 
            cVend1 := SCT->CT_VEND
            RecLock("SCT",.F.)
            SCT->(dbDelete())
            SCT->(msUnlock())

            cTexto := "Status -> EXCLUSAO *** Emissao: "+TransForm(dDataGrv,"@D")+" *** Vendedor: "+cVend1+" *** Qtd: "+TransForm(nQtdMt,"@E 999,999,999.99")+" *** Valor: "+TransForm(nValMt,"@E 9,999,999,999.99")+Chr(13)+Chr(10)
            cTexto += Replicate("*",120)+Chr(13)+Chr(10)
            fWrite(nHdl,cTexto)

         EndIf
      Endif
   Endif

   //Gravacao para Agosto
   If nPos08v > 0
      If Val(aDados[nX,nPos08v]) > 0
         cValMeta := aDados[nX,nPos08v] 
         cValMeta := Replace(cValMeta,".","")
         cValMeta := Replace(cValMeta,",",".")
         dDataGrv := LastDay(stod("20"+Right(aDados[1,nPos08v],2)+"0801"))
         
         nRecnoSCT := ProcRecno(dDataGrv,aDados[nX,nPosCod])
         lGrava := .T.
         If nRecnoSCT > 0
            dbSelectArea("SCT")
            SCT->(dbSetOrder(1))
            SCT->(dbGoTo(nRecnoSCT))
            lGrava := .F.
         Endif
         
         RecLock("SCT",lGrava)
         If lGrava
            If Empty(cDocAgo)
               cDocAgo      := GetSXENum("SCT","CT_DOC")
               ConfirmSX8()
            EndIf
            SCT->CT_FILIAL := xFilial("SCT")
            SCT->CT_DATA   := dDataGrv
            SCT->CT_DESCRI := Upper(AllTrim(Str(Year(dDataGrv)))+" - AGOSTO "+AllTrim(cDesc))
            SCT->CT_DOC    := cDocAgo
            SCT->CT_MOEDA  := 1
            SCT->CT_VEND   := aDados[nX,nPosCod]
         EndIf
         SCT->CT_VALOR  := Val(cValmeta)
         SCT->CT_QUANT  := Val(aDados[nX,nPos08q])
         If lGrava
            cQuery := "SELECT ISNULL(MAX(CT_SEQUEN),'000') CSEQ FROM "+RetSqlName("SCT")+" (NOLOCK) "
            cQuery += "WHERE CT_FILIAL = '" + xFilial("SCT") + "' "
            cQuery += "AND CT_DOC = '" + cDocAgo + "' "
            cQuery += "AND D_E_L_E_T_ = ' ' "
            If Select("QUERY") > 0
               QUERY->(dbCloseArea())
            EndIf
            TcQuery cQuery New Alias "QUERY"
            SCT->CT_SEQUEN := Soma1(QUERY->CSEQ)
            QUERY->(dbCloseArea())
            SCT->CT_MSBLQL := "2"
         EndIf
         SCT->(msUnlock())

         If lGrava
            cTexto := "Status -> INCLUSAO *** Emissao: "+TransForm(dDataGrv,"@D")+" *** Vendedor: "+aDados[nX,nPosCod]+" *** Qtd: "+TransForm(Val(aDados[nX,nPos08q]),"@E 999,999,999.99")+" *** Valor: "+TransForm(Val(cValMeta),"@E 9,999,999,999.99")+Chr(13)+Chr(10)
            cTexto += Replicate("*",120)+Chr(13)+Chr(10)
            fWrite(nHdl,cTexto)
         Else
            cTexto := "Status -> ALTERACAO *** Emissao: "+TransForm(dDataGrv,"@D")+" *** Vendedor: "+aDados[nX,nPosCod]+" *** Qtd: "+TransForm(Val(aDados[nX,nPos08q]),"@E 999,999,999.99")+" *** Valor: "+TransForm(Val(cValMeta),"@E 9,999,999,999.99")+Chr(13)+Chr(10)
            cTexto += Replicate("*",120)+Chr(13)+Chr(10)
            fWrite(nHdl,cTexto)
         EndIf

      //Exclui o registro se o valor for 0
      ElseIf Val(aDados[nX,nPos08v]) <= 0
         dDataGrv := LastDay(stod("20"+Right(aDados[1,nPos08v],2)+"0801"))
         nRecnoSCT := ProcRecno(dDataGrv,aDados[nX,nPosCod])
         If nRecnoSCT > 0
            dbSelectArea("SCT")
            SCT->(dbSetOrder(1))
            SCT->(dbGoTo(nRecnoSCT))
            nQtdMt := SCT->CT_QUANT
            nValMt := SCT->CT_VALOR 
            cVend1 := SCT->CT_VEND
            RecLock("SCT",.F.)
            SCT->(dbDelete())
            SCT->(msUnlock())

            cTexto := "Status -> EXCLUSAO *** Emissao: "+TransForm(dDataGrv,"@D")+" *** Vendedor: "+cVend1+" *** Qtd: "+TransForm(nQtdMt,"@E 999,999,999.99")+" *** Valor: "+TransForm(nValMt,"@E 9,999,999,999.99")+Chr(13)+Chr(10)
            cTexto += Replicate("*",120)+Chr(13)+Chr(10)
            fWrite(nHdl,cTexto)

         EndIf
      Endif
   Endif

   //Gravacao para Setembro
   If nPos09v > 0
      If Val(aDados[nX,nPos09v]) > 0
         cValMeta := aDados[nX,nPos09v] 
         cValMeta := Replace(cValMeta,".","")
         cValMeta := Replace(cValMeta,",",".")
         dDataGrv := LastDay(stod("20"+Right(aDados[1,nPos09v],2)+"0901"))
         
         nRecnoSCT := ProcRecno(dDataGrv,aDados[nX,nPosCod])
         lGrava := .T.
         If nRecnoSCT > 0
            dbSelectArea("SCT")
            SCT->(dbSetOrder(1))
            SCT->(dbGoTo(nRecnoSCT))
            lGrava := .F.
         Endif
         
         RecLock("SCT",lGrava)
         If lGrava
            If Empty(cDocSet)
               cDocSet      := GetSXENum("SCT","CT_DOC")
               ConfirmSX8()
            EndIf
            SCT->CT_FILIAL := xFilial("SCT")
            SCT->CT_DATA   := dDataGrv
            SCT->CT_DESCRI := Upper(AllTrim(Str(Year(dDataGrv)))+" - SETEMBRO "+AllTrim(cDesc))
            SCT->CT_DOC    := cDocSet
            SCT->CT_MOEDA  := 1
            SCT->CT_VEND   := aDados[nX,nPosCod]
         EndIf
         SCT->CT_VALOR  := Val(cValmeta)
         SCT->CT_QUANT  := Val(aDados[nX,nPos09q])
         If lGrava
            cQuery := "SELECT ISNULL(MAX(CT_SEQUEN),'000') CSEQ FROM "+RetSqlName("SCT")+" (NOLOCK) "
            cQuery += "WHERE CT_FILIAL = '" + xFilial("SCT") + "' "
            cQuery += "AND CT_DOC = '" + cDocSet + "' "
            cQuery += "AND D_E_L_E_T_ = ' ' "
            If Select("QUERY") > 0
               QUERY->(dbCloseArea())
            EndIf
            TcQuery cQuery New Alias "QUERY"
            SCT->CT_SEQUEN := Soma1(QUERY->CSEQ)
            QUERY->(dbCloseArea())
            SCT->CT_MSBLQL := "2"
         EndIf
         SCT->(msUnlock())

         If lGrava
            cTexto := "Status -> INCLUSAO *** Emissao: "+TransForm(dDataGrv,"@D")+" *** Vendedor: "+aDados[nX,nPosCod]+" *** Qtd: "+TransForm(Val(aDados[nX,nPos09q]),"@E 999,999,999.99")+" *** Valor: "+TransForm(Val(cValMeta),"@E 9,999,999,999.99")+Chr(13)+Chr(10)
            cTexto += Replicate("*",120)+Chr(13)+Chr(10)
            fWrite(nHdl,cTexto)
         Else
            cTexto := "Status -> ALTERACAO *** Emissao: "+TransForm(dDataGrv,"@D")+" *** Vendedor: "+aDados[nX,nPosCod]+" *** Qtd: "+TransForm(Val(aDados[nX,nPos09q]),"@E 999,999,999.99")+" *** Valor: "+TransForm(Val(cValMeta),"@E 9,999,999,999.99")+Chr(13)+Chr(10)
            cTexto += Replicate("*",120)+Chr(13)+Chr(10)
            fWrite(nHdl,cTexto)
         EndIf

      //Exclui o registro se o valor for 0
      ElseIf Val(aDados[nX,nPos09v]) <= 0
         dDataGrv := LastDay(stod("20"+Right(aDados[1,nPos09v],2)+"0901"))
         nRecnoSCT := ProcRecno(dDataGrv,aDados[nX,nPosCod])
         If nRecnoSCT > 0
            dbSelectArea("SCT")
            SCT->(dbSetOrder(1))
            SCT->(dbGoTo(nRecnoSCT))
            nQtdMt := SCT->CT_QUANT
            nValMt := SCT->CT_VALOR 
            cVend1 := SCT->CT_VEND
            RecLock("SCT",.F.)
            SCT->(dbDelete())
            SCT->(msUnlock())

            cTexto := "Status -> EXCLUSAO *** Emissao: "+TransForm(dDataGrv,"@D")+" *** Vendedor: "+cvend1+" *** Qtd: "+TransForm(nQtdMt,"@E 999,999,999.99")+" *** Valor: "+TransForm(nValMt,"@E 9,999,999,999.99")+Chr(13)+Chr(10)
            cTexto += Replicate("*",120)+Chr(13)+Chr(10)
            fWrite(nHdl,cTexto)

         EndIf
      Endif
   EndIf

   //Gravacao para Outubro
   If nPos10v > 0
      If Val(aDados[nX,nPos10v]) > 0
         cValMeta := aDados[nX,nPos10v] 
         cValMeta := Replace(cValMeta,".","")
         cValMeta := Replace(cValMeta,",",".")
         dDataGrv := LastDay(stod("20"+Right(aDados[1,nPos10v],2)+"1001"))
         
         nRecnoSCT := ProcRecno(dDataGrv,aDados[nX,nPosCod])
         lGrava := .T.
         If nRecnoSCT > 0
            dbSelectArea("SCT")
            SCT->(dbSetOrder(1))
            SCT->(dbGoTo(nRecnoSCT))
            lGrava := .F.
         Endif
         
         RecLock("SCT",lGrava)
         If lGrava
            If Empty(cDocOut)
               cDocOut      := GetSXENum("SCT","CT_DOC")
               ConfirmSX8()
            EndIf
            SCT->CT_FILIAL := xFilial("SCT")
            SCT->CT_DATA   := dDataGrv
            SCT->CT_DESCRI := Upper(AllTrim(Str(Year(dDataGrv)))+" - OUTUBRO "+AllTrim(cDesc))
            SCT->CT_DOC    := cDocOut
            SCT->CT_MOEDA  := 1
            SCT->CT_VEND   := aDados[nX,nPosCod]
         EndIf
         SCT->CT_VALOR  := Val(cValMeta)
         SCT->CT_QUANT  := Val(aDados[nX,nPos10q])
         If lGrava
            cQuery := "SELECT ISNULL(MAX(CT_SEQUEN),'000') CSEQ FROM "+RetSqlName("SCT")+" (NOLOCK) "
            cQuery += "WHERE CT_FILIAL = '" + xFilial("SCT") + "' "
            cQuery += "AND CT_DOC = '" + cDocOut + "' "
            cQuery += "AND D_E_L_E_T_ = ' ' "
            If Select("QUERY") > 0
               QUERY->(dbCloseArea())
            EndIf
            TcQuery cQuery New Alias "QUERY"
            SCT->CT_SEQUEN := Soma1(QUERY->CSEQ)
            QUERY->(dbCloseArea())
            SCT->CT_MSBLQL := "2"
         EndIf
         SCT->(msUnlock())

         If lGrava
            cTexto := "Status -> INCLUSAO *** Emissao: "+TransForm(dDataGrv,"@D")+" *** Vendedor: "+aDados[nX,nPosCod]+" *** Qtd: "+TransForm(Val(aDados[nX,nPos10q]),"@E 999,999,999.99")+" *** Valor: "+TransForm(Val(cValMeta),"@E 9,999,999,999.99")+Chr(13)+Chr(10)
            cTexto += Replicate("*",120)+Chr(13)+Chr(10)
            fWrite(nHdl,cTexto)
         Else
            cTexto := "Status -> ALTERACAO *** Emissao: "+TransForm(dDataGrv,"@D")+" *** Vendedor: "+aDados[nX,nPosCod]+" *** Qtd: "+TransForm(Val(aDados[nX,nPos10q]),"@E 999,999,999.99")+" *** Valor: "+TransForm(Val(cValMeta),"@E 9,999,999,999.99")+Chr(13)+Chr(10)
            cTexto += Replicate("*",120)+Chr(13)+Chr(10)
            fWrite(nHdl,cTexto)
         EndIf

      //Exclui o registro se o valor for 0
      ElseIf Val(aDados[nX,nPos10v]) <= 0
         dDataGrv := LastDay(stod("20"+Right(aDados[1,nPos10v],2)+"1001"))
         nRecnoSCT := ProcRecno(dDataGrv,aDados[nX,nPosCod])
         If nRecnoSCT > 0
            dbSelectArea("SCT")
            SCT->(dbSetOrder(1))
            SCT->(dbGoTo(nRecnoSCT))
            nQtdMt := SCT->CT_QUANT
            nValMt := SCT->CT_VALOR 
            cVend1 := SCT->CT_VEND
            RecLock("SCT",.F.)
            SCT->(dbDelete())
            SCT->(msUnlock())

            cTexto := "Status -> EXCLUSAO *** Emissao: "+TransForm(dDataGrv,"@D")+" *** Vendedor: "+cvend1+" *** Qtd: "+TransForm(nQtdMt,"@E 999,999,999.99")+" *** Valor: "+TransForm(nValMt,"@E 9,999,999,999.99")+Chr(13)+Chr(10)
            cTexto += Replicate("*",120)+Chr(13)+Chr(10)
            fWrite(nHdl,cTexto)

         EndIf
      Endif
   Endif

   //Gravacao para Novembro
   If nPos11v > 0
      If Val(aDados[nX,nPos11v]) > 0
         cValMeta := aDados[nX,nPos11v] 
         cValMeta := Replace(cValMeta,".","")
         cValMeta := Replace(cValMeta,",",".")
         dDataGrv := LastDay(stod("20"+Right(aDados[1,nPos11v],2)+"1101"))
         
         nRecnoSCT := ProcRecno(dDataGrv,aDados[nX,nPosCod])
         lGrava := .T.
         If nRecnoSCT > 0
            dbSelectArea("SCT")
            SCT->(dbSetOrder(1))
            SCT->(dbGoTo(nRecnoSCT))
            lGrava := .F.
         Endif
         
         RecLock("SCT",lGrava)
         If lGrava
            If Empty(cDocNov)
               cDocNov      := GetSXENum("SCT","CT_DOC")
               ConfirmSX8()
            EndIf
            SCT->CT_FILIAL := xFilial("SCT")
            SCT->CT_DATA   := dDataGrv
            SCT->CT_DESCRI := Upper(AllTrim(Str(Year(dDataGrv)))+" - NOVEMBRO "+AllTrim(cDesc))
            SCT->CT_DOC    := cDocNov
            SCT->CT_MOEDA  := 1
            SCT->CT_VEND   := aDados[nX,nPosCod]
         EndIf
         SCT->CT_VALOR  := Val(cValMeta)
         SCT->CT_QUANT  := Val(aDados[nX,nPos11q])
         If lGrava
            cQuery := "SELECT ISNULL(MAX(CT_SEQUEN),'000') CSEQ FROM "+RetSqlName("SCT")+" (NOLOCK) "
            cQuery += "WHERE CT_FILIAL = '" + xFilial("SCT") + "' "
            cQuery += "AND CT_DOC = '" + cDocNov + "' "
            cQuery += "AND D_E_L_E_T_ = ' ' "
            If Select("QUERY") > 0
               QUERY->(dbCloseArea())
            EndIf
            TcQuery cQuery New Alias "QUERY"
            SCT->CT_SEQUEN := Soma1(QUERY->CSEQ)
            QUERY->(dbCloseArea())
            SCT->CT_MSBLQL := "2"
         EndIf
         SCT->(msUnlock())

         If lGrava
            cTexto := "Status -> INCLUSAO *** Emissao: "+TransForm(dDataGrv,"@D")+" *** Vendedor: "+aDados[nX,nPosCod]+" *** Qtd: "+TransForm(Val(aDados[nX,nPos11q]),"@E 999,999,999.99")+" *** Valor: "+TransForm(Val(cValMeta),"@E 9,999,999,999.99")+Chr(13)+Chr(10)
            cTexto += Replicate("*",120)+Chr(13)+Chr(10)
            fWrite(nHdl,cTexto)
         Else
            cTexto := "Status -> ALTERACAO *** Emissao: "+TransForm(dDataGrv,"@D")+" *** Vendedor: "+aDados[nX,nPosCod]+" *** Qtd: "+TransForm(Val(aDados[nX,nPos11q]),"@E 999,999,999.99")+" *** Valor: "+TransForm(Val(cValMeta),"@E 9,999,999,999.99")+Chr(13)+Chr(10)
            cTexto += Replicate("*",120)+Chr(13)+Chr(10)
            fWrite(nHdl,cTexto)
         EndIf

      //Exclui o registro se o valor for 0
      ElseIf Val(aDados[nX,nPos11v]) <= 0
         dDataGrv := LastDay(stod("20"+Right(aDados[1,nPos11v],2)+"1101"))
         nRecnoSCT := ProcRecno(dDataGrv,aDados[nX,nPosCod])
         If nRecnoSCT > 0
            dbSelectArea("SCT")
            SCT->(dbSetOrder(1))
            SCT->(dbGoTo(nRecnoSCT))
            nQtdMt := SCT->CT_QUANT
            nValMt := SCT->CT_VALOR 
            cVend1 := SCT->CT_VEND
            RecLock("SCT",.F.)
            SCT->(dbDelete())
            SCT->(msUnlock())

            cTexto := "Status -> EXCLUSAO *** Emissao: "+TransForm(dDataGrv,"@D")+" *** Vendedor: "+cvend1+" *** Qtd: "+TransForm(nQtdMt,"@E 999,999,999.99")+" *** Valor: "+TransForm(nValMt,"@E 9,999,999,999.99")+Chr(13)+Chr(10)
            cTexto += Replicate("*",120)+Chr(13)+Chr(10)
            fWrite(nHdl,cTexto)

         EndIf
      Endif
   Endif

   //Gravacao para Dezembro 
   If nPos12v > 0
      If Val(aDados[nX,nPos12v]) > 0
         cValMeta := aDados[nX,nPos12v] 
         cValMeta := Replace(cValMeta,".","")
         cValMeta := Replace(cValMeta,",",".")
         dDataGrv := LastDay(stod("20"+Right(aDados[1,nPos12v],2)+"1201"))
         
         nRecnoSCT := ProcRecno(dDataGrv,aDados[nX,nPosCod])
         lGrava := .T.
         If nRecnoSCT > 0
            dbSelectArea("SCT")
            SCT->(dbSetOrder(1))
            SCT->(dbGoTo(nRecnoSCT))
            lGrava := .F.
         Endif
         
         RecLock("SCT",lGrava)
         If lGrava
            If Empty(cDocDez)
               cDocDez      := GetSXENum("SCT","CT_DOC")
               ConfirmSX8()
            EndIf
            SCT->CT_FILIAL := xFilial("SCT")
            SCT->CT_DATA   := dDataGrv
            SCT->CT_DESCRI := Upper(AllTrim(Str(Year(dDataGrv)))+" - DEZEMBRO "+AllTrim(cDesc))
            SCT->CT_DOC    := cDocDez
            SCT->CT_MOEDA  := 1
            SCT->CT_VEND   := aDados[nX,nPosCod]
         EndIf
         SCT->CT_VALOR  := Val(cValMeta)
         SCT->CT_QUANT  := Val(aDados[nX,nPos12q])
         If lGrava
            cQuery := "SELECT ISNULL(MAX(CT_SEQUEN),'000') CSEQ FROM "+RetSqlName("SCT")+" (NOLOCK) "
            cQuery += "WHERE CT_FILIAL = '" + xFilial("SCT") + "' "
            cQuery += "AND CT_DOC = '" + cDocDez + "' "
            cQuery += "AND D_E_L_E_T_ = ' ' "
            If Select("QUERY") > 0
               QUERY->(dbCloseArea())
            EndIf
            TcQuery cQuery New Alias "QUERY"
            SCT->CT_SEQUEN := Soma1(QUERY->CSEQ)
            QUERY->(dbCloseArea())
            SCT->CT_MSBLQL := "2"
         EndIf
         SCT->(msUnlock())

         If lGrava
            cTexto := "Status -> INCLUSAO *** Emissao: "+TransForm(dDataGrv,"@D")+" *** Vendedor: "+aDados[nX,nPosCod]+" *** Qtd: "+TransForm(Val(aDados[nX,nPos12q]),"@E 999,999,999.99")+" *** Valor: "+TransForm(Val(cValMeta),"@E 9,999,999,999.99")+Chr(13)+Chr(10)
            cTexto += Replicate("*",120)+Chr(13)+Chr(10)
            fWrite(nHdl,cTexto)
         Else
            cTexto := "Status -> ALTERACAO *** Emissao: "+TransForm(dDataGrv,"@D")+" *** Vendedor: "+aDados[nX,nPosCod]+" *** Qtd: "+TransForm(Val(aDados[nX,nPos12q]),"@E 999,999,999.99")+" *** Valor: "+TransForm(Val(cValMeta),"@E 9,999,999,999.99")+Chr(13)+Chr(10)
            cTexto += Replicate("*",120)+Chr(13)+Chr(10)
            fWrite(nHdl,cTexto)
         EndIf 

      //Exclui o registro se o valor for 0 - Dezembro
      ElseIf Val(aDados[nX,nPos12v]) <= 0
         dDataGrv := LastDay(stod("20"+Right(aDados[1,nPos12v],2)+"1201"))
         nRecnoSCT := ProcRecno(dDataGrv,aDados[nX,nPosCod])
         If nRecnoSCT > 0
            dbSelectArea("SCT")
            SCT->(dbSetOrder(1))
            SCT->(dbGoTo(nRecnoSCT))
            nQtdMt := SCT->CT_QUANT
            nValMt := SCT->CT_VALOR
            cVend1 := SCT->CT_VEND 
            RecLock("SCT",.F.)
            SCT->(dbDelete())
            SCT->(msUnlock())

            cTexto := "Status -> EXCLUSAO *** Emissao: "+TransForm(dDataGrv,"@D")+" *** Vendedor: "+cVend1+" *** Qtd: "+TransForm(nQtdMt,"@E 999,999,999.99")+" *** Valor: "+TransForm(nValMt,"@E 9,999,999,999.99")+Chr(13)+Chr(10)
            cTexto += Replicate("*",120)+Chr(13)+Chr(10)
            fWrite(nHdl,cTexto)

         EndIf
      Endif
   Endif

Next nX

//===========================================================================
//Exclui o arquivo csv
//===========================================================================
If File(cFile)
   FErase(cFile)
EndIf

fClose(nHdl)

ShellExecute("OPEN", candress+cArqLog ,"","",5)

Return(aDados)

//===========================================================================
//Programa....: validaCpos
//Autor.......: Anderson Goncalves   
//Data........: 16/04/19
//Descricao...: faz a validação dos campos da tela de filtro
//Uso.........: OurLux
//===========================================================================

Static Function validaCpos()

//===========================================================================
// Variaveis da Rotina
//===========================================================================
Local cMsg := ""

//===========================================================================
//Verifica se o nome do arquivo foi preenchido
//===========================================================================
If Empty(cArq)
   cMsg += "Campo Arquivo deve ser preenchido!"+ENTER
EndIf                            

//===========================================================================
// Verifica o endereço do arquivo
//===========================================================================
If Empty(cOrigem)
   cMsg += "Campo Caminho do arquivo deve ser preenchido!"+ENTER
EndIf

//===========================================================================
// Verifica o nome da Macro
//===========================================================================
If Empty(cArqMacro)
   cMsg += "Campo Nome da Macro deve ser preenchido!"
EndIf

//===========================================================================
// Verifica a descricao do documento
//===========================================================================
If Empty(cDesc)
   cMsg += "Campo descrição deve ser preenchido!"
EndIf

Return(cMsg)

//===========================================================================
//Programa....: SelectFile
//Autor.......: Anderson Goncalves   
//Data........: 16/04/19
//Descricao...: GetFile para selecao do arquivo excel
//Uso.........: OurLux
//===========================================================================

Static Function SelectFile()

//===========================================================================
//Variaveis da Rotina
//===========================================================================
Local cMaskDir := "Arquivos Microsoft Excel (*.xlsx) |*.xlsx|"
Local cTitTela := "Arquivo para a integracao"
Local lInfoOpen := .T.
Local lDirServidor := .T.
Local cOldFile := cArquivo

//===========================================================================
//Verifica lista xlsx ou xls
//===========================================================================
If nOpcaoArq == 1
   cMaskDir := "Arquivos Microsoft Excel (*.xlsx) |*.xlsx|"
Else
   cMaskDir := "Arquivos Microsoft Excel (*.xls) |*.xls|"
EndIf

//===========================================================================
//Interface de selecao
//===========================================================================
cArquivo := cGetFile(cMaskDir,cTitTela,,cArquivo,lInfoOpen, (GETF_LOCALHARD+GETF_NETWORKDRIVE) ,lDirServidor)

If !File(cArquivo)
    MsgStop("Arquivo Não Existe!")
    cArquivo := cOldFile
    Return .F.
EndIf

Return Nil

//===========================================================================
//Programa....: ProcRecno
//Autor.......: Anderson Goncalves   
//Data........: 16/04/19
//Descricao...: Procura Recno no SCT
//Uso.........: OurLux
//===========================================================================

Static Function ProcRecno(dData,cVend)

//===========================================================================
//Variaveis da Rotina
//===========================================================================
Local cQuery   := Nil
Local nRet     := 0 

//===========================================================================
//Verifica se o registro existe
//===========================================================================
cQuery := "SELECT ISNULL(R_E_C_N_O_,0) RECSCT FROM " + RetSqlName("SCT") + " (NOLOCK) "
cQuery += "WHERE CT_FILIAL = '" + xFilial("SCT") + "' "
cQuery += "AND CT_DATA = '"+dtos(dData)+"' "
cQuery += "AND CT_VEND = '"+cVend+"' "
cQuery += "AND D_E_L_E_T_ = ' ' "
If Select("QUERY") > 0
   QUERY->(dbCloseArea())
EndIf
TcQuery cQuery New Alias "QUERY"
dbSelectArea("QUERY")
QUERY->(dbGoTop())
If QUERY->RECSCT > 0
   nRet := QUERY->RECSCT
EndIf 
QUERY->(dbCloseArea())
Return(nRet)


//CT_FILIAL+DTOS(CT_DATA)+CT_VEND   