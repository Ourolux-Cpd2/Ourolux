#Include "Average.ch"
#Include "DbInfo.ch"

#Define DLG_LIN_INI 1
#Define DLG_COL_INI 1
#Define DLG_LIN_FIM 45
#Define DLG_COL_FIM 100

/*
Objetivos     : Atualizar/Comparar Dicionário/Base automaticamente, com base em arquivos .Dbf
Autor         : João Pedro Macimiano Trabbold
*/
*========================*
User Function AtuDicMain()
*========================*
Private oMainWnd
Private oProcess := NIL, lErro := .F., lExclusivo := .F.

   Define Window oMainWnd From 1,1 To 01,30 Title "Atualização de Dicionário"

      oProcess := MsNewProcess():New({|lEnd| U_AtuDicAux(lEnd,oProcess)},"Comparação/Atualização de Dicionários","Lendo...",.T.)

   Activate Window oMainWnd On Init (oProcess:Activate(),oMainWnd:End())

Return Nil

*====================================*
User Function AtuDicAux(lEnd,oProcess)
*====================================*
Local i, lRet := .F., cFilRpc, cEmpRpc, cMsg, aDir, bBlockAntigo
Private cFolder := "\backup_atu", aArquivos := {}, aDbfSel := {}, cPastaAtu := "\AtuDic"
Private aTables := {}
Private lTeveAtu := .F.
Private cMarca
Private cPasta
Private oProc := @oProcess
Private cPastaDBFAtu := "\DBFs_atu_" + AllTrim(DToS(Date())) + "__" + AllTrim(StrTran(Time(),":","_"))

Private lBackup := .F., lDocumentacao := .F., lTexto := .F., lExcel := .F., lPrevia := .F., lGeraDbf := .F., lApenasAlterados := .F.
Private lUsuario := .F., nOp

// ** Array para armazenar as alterações para fazer o "rollback" em caso de erros.
Private aBackup := {}
Private aAlterados := {}

bBlockAntigo := ErrorBlock({|e| TrataErroAtu(e)})

Begin Sequence

   SET DELETED ON

   nOp := Aviso( "Opção", "Você é usuário do sistema ou analista da Average?",{"Usuário","Analista"}, 2 )
   
   If nOp == 1
      lUsuario := .T.
   ElseIf nOp == 2
      lUsuario := .F.
   Else
      Break
   EndIf

   oProc:SetRegua1(5)
   
   // ** abre o SM0 exclusivo para ninguém entrar no sistema.
   DbUseArea(.T.,,"SIGAMAT.EMP","SM0",.F.,.F.)
   If Select("SM0") = 0
      If lUsuario
         MsgInfo("Não foi possível obter acesso exclusivo ao sistema.","Atenção")
         Break
      EndIf
      lExclusivo := .F.
      lPrevia    := .T.
      MsgInfo("Não foi possível obter acesso exclusivo ao sistema. Tudo será feito no modo 'Prévia'.","Atenção")
      DbUseArea(.T.,,"SIGAMAT.EMP","SM0",.T.,.F.)
   Else
      lExclusivo := .T.
   EndIf
   
   If Select("SM0") = 0
      MsgInfo("Não foi possível abrir o sigamat.emp.","Atenção")
      Break
   EndIf
   
   DbSetIndex("SIGAMAT.IND")

   AbreEnv(SM0->M0_CODIGO,SM0->M0_CODFIL)

   cPasta := cFolder + "_" + AllTrim(DToS(Date())) + "__" + AllTrim(StrTran(Time(),":","_"))
   
   // ** Cria pasta para armazenar os backups 
   While lIsDir(cPasta)
      cPasta := cFolder + "_" + AllTrim(DToS(Date())) + "__" + AllTrim(StrTran(Time(),":","_"))
   EndDo
   MakeDir(cPasta)
   
   oProc:IncRegua1("Inicializando o Ambiente...")
   
   // ** tela para seleção da empresa/filial
   If !TelaSM0(@cEmpRpc,@cFilRpc)
      Break
   EndIf
   
   // ** limpa e abre environment
   /*
   RpcClearEnv()
   RpcSetType(2)
   RpcSetEnv(cEmpRpc,cFilRpc)
   */
   AbreEnv(cEmpRpc,cFilRpc)
   
   /* para apagar as tabelas do banco.
   // ** ########################
   oProc:SetRegua1(SX2->(RecCount()))
   
   SX2->(DbGoTop())
   While SX2->(!EoF())
      oProc:IncRegua1("Apagando todas as tabelas...")
      If MsFile(AllTrim(SX2->X2_ARQUIVO),,"TOPCONN")
         TcDelFile(AllTrim(SX2->X2_ARQUIVO))
      EndIf
      If MsFile(AllTrim(SX2->X2_CHAVE+"990"),,"TOPCONN")
         TcDelFile(AllTrim(SX2->X2_CHAVE+"990"))
      EndIf
      SX2->(DbSkip())
   EndDo
   
   Break
   // ** ########################
   */                

//   xTeste()
      
   cMarca := GetMark()

   // ** Digitação do caminho dos arquivos a serem importados
   If Empty(aArquivos := Tela())
      Break
   EndIf

   oProc:IncRegua1("Processando dados novos...")
   
   // ** Levanta as diferenças de cada dicionário e abre telas de opção ao usuário
   For i := 1 To Len(aArquivos)
      lRet := AtualizaDic(aArquivos[i])
      If !lRet .Or. lErro
         MsgInfo("Atualização Cancelada.","Aviso")
         Break
      EndIf
   Next
   
   If Len(aDbfSel) = 0
      MsgInfo("Atualização Cancelada.","Aviso")
      Break
   EndIf
   
   // ** Tela de configurações
   If !Configuracoes()
      Break
   EndIf
   
   If lGeraDbf
      MakeDir(cPastaDBFAtu)
   EndIf
   
   If !lPrevia
      If lExclusivo
         If !MsgYesNo("Antes de continuar, certifique-se que não há outros usuários utilizando o sistema. Deseja continuar?")
            Break
         EndIf
      Else
         If !MsgYesNo("Como não foi possível o acesso exclusivo, o sistema não efetuará alteração em estruturas de tabelas, "+;
                      "apenas alterações de dicionários e conteúdos de tabelas. Deseja continuar?","Atenção")
            Break
         EndIf
      EndIf
   EndIf
   
   /*
   lBackup := MsgYesNo("Fazer backup dos dicionários que serão alterados? (Nas primeiras execuções deste programa é aconselhável)","Configurações")

   If (lDocumentacao := MsgYesNo("Deseja documentar as alterações?"))
      lExcel := MsgYesNo("Documentar em excel(Sim) ou arquivo texto(não)?")
      lTexto := !lExcel
   EndIf
   */

   If lDocumentacao
      Private cDir := AllTrim(GetTempPath())
      If lExcel

         Private cNome  := "AtuDic_"+Dtos(dDatabase)+"_"+StrTran(Time(),":","")+".Dbf"
         Private aCmpArq := {{"TABELA","C",10 ,0};
                            ,{"TIPO"  ,"C",12 ,0};
                            ,{"CHAVE" ,"C",100,0};
                            ,{"CONT_CHAVE" ,"C",100,0};
                            ,{"CAMPO" ,"C",10 ,0};
                            ,{"CAMPO_DE"    ,"C",200,0};
                            ,{"CAMPO_PARA"  ,"C",200,0};
                            }
   
         If Right(cDir,1) <> "\"
            cDir += "\"
         EndIf
         
         If Select("LOG") > 0
            LOG->(dbCloseArea())
         EndIf
         
         DbCreate(cNome,aCmpArq)
         
         dbUseArea(.T.,"DBFCDX",cNome,"LOG")
      EndIf
      
      If lTexto
         Private cNomeTxt  := "AtuDic_"+Dtos(dDatabase)+"_"+StrTran(Time(),":","")+".txt"
         Private nCodTxt
         nCodTxt:=FCreate(cDir+cNomeTxt)
         If nCodTxt = -1
            lTexto := .F.
            If !MsgYesNo("Não foi possível criar o arquivo texto no diretório temporário do usuário. "+;
                         "Deseja continuar a atualização sem documentar em arquivo texto?","Atenção")
               Break
            EndIf
         Else
            Documenta("Dados alterados:"+Repl(ENTER,2))
         EndIf
      EndIf
      
   EndIf
   
   oProc:IncRegua1("Atualizando Dicionários...")
   
   oProc:SetRegua2(Len(aDbfSel)*2)

   // ** Atualiza todos os dicionários
   For i := 1 To Len(aDbfSel)
      lRet := AtuBase(aDbfSel[i][1],aDbfSel[i][2],aDbfSel[i][3],aDbfSel[i][4],aDbfSel[i][5])
      If !lRet .Or. lErro
         Break
      EndIf
   Next
   
   If !lPrevia
      If lExclusivo
         If !lUsuario
            If !MsgYesNo("Os dicionários/tabelas foram atualizados, agora serão alteradas as estruturas das tabelas se for necessário. Deseja continuar?")
               Break
            EndIf
         EndIf
      Else
         MsgInfo("Os dicionários/tabelas foram atualizados.","Atenção")
         Break
      EndIf

      RpcClearEnv()
   
      // ** apaga os índices dos dicionários alterados e recria.
      For i := 1 To Len(aAlterados)
         // ** fecha o dicionário
         If Select(aAlterados[i]) > 0
            (aAlterados[i])->(DbCloseArea())
         EndIf
            
         // ** apaga o índice do dicionário
         If !ApagaArquivo(aAlterados[i]+cEmpRpc+"0"+".cdx",;
                          "Não foi possível apagar o índice do dicionário " + aAlterados[i] +;
                          ", deve haver algum usuário no sistema ainda. Deseja tentar apagar de novo?")
            lRet := .F.
            Break
         EndIf
   
      Next

      /*
      RpcSetType(2)
      RpcSetEnv(cEmpRpc,cFilRpc)
      */
   
      AbreEnv(cEmpRpc,cFilRpc)
   EndIf
   
   /*
   EU NÃO USEI X31UPDTABLE POR QUE NO TESTE QUE FIZ NA BRASKEM, A FUNÇÃO ACERTOU A ESTRUTURA, PORÉM DEIXOU
   A TABELA SEM CONTEÚDO.
   */
   
   If lErro
      Break
   EndIf
   
   If !lPrevia
      oProc:IncRegua1("Atualizando Estrutura das Tabelas...")
   
      oProc:SetRegua2(Len(aTables)*2)
   
      // ** Atualiza a estrutura das tabelas afetadas
      For i := 1 To Len(aTables)
   
         // ** só vai fazer backup das tabelas que existem, é óbvio.
         If !MsFile(AllTrim(RetSqlName(aTables[i])),,"TOPCONN")
            oProc:IncRegua2("Atualizando Estrutura das Tabelas...")
            oProc:IncRegua2("Atualizando Estrutura das Tabelas...")
   
            Loop
         EndIf
         
         DbSelectArea(aTables[i])
         If Select(aTables[i]) > 0
   
            oProc:IncRegua2("Baixando tabela " + aTables[i])
   
            // ** faz backup do dicionário alterado.
            Copy To &(cPasta+"\"+aTables[i]+".dbf") Via "DBFCDX"
            If !File(cPasta+"\"+aTables[i]+".dbf")
               MsgInfo("Não foi possível realizar o backup da tabela " + aTables[i] + " que ia ser alterada no banco. Os backups armazenados até agora serão restaurados.","Atualização Cancelada")
               lRet := .F.
               Break
            EndIf
   
            /*
            (aTables[i])->(DbCloseArea())
            
            // ** apaga a tabela no banco
            TcDelFile(AllTrim(RetSqlName(aTables[i])))
            
            // ** verifica se apagou mesmo
            If MsFile(AllTrim(RetSqlName(aTables[i])),,"TOPCONN")
               MsgInfo("Não foi possível dropar a tabela " + aTables[i] + " que iria ser recriada no banco. Os backups armazenados até agora serão restaurados.","Atualização Cancelada")
               lRet := .F.
               Break
            EndIf
            */
            
            If !ApagaTabela(aTables[i])
               MsgInfo("Não foi possível dropar a tabela " + aTables[i] + " que iria ser recriada no banco. Os backups armazenados até agora serão restaurados.","Atualização Cancelada")
               lRet := .F.
               Break
            EndIf
            
            // ** adiciona na fila para restaurar backup em caso de erro
            AAdd(aBackup,{"ESTR",cPasta+"\"+aTables[i]+".dbf",aTables[i]})
            
            // ** recria a tabela
            //ChkFile(aTables[i])
            AbreRecriaTab(aTables[i])
            If Select(aTables[i]) = 0
               MsgInfo("Não foi possível recriar a tabela " + aTables[i] + ". Os backups armazenados até agora serão restaurados.","Atualização Cancelada")
               lRet := .F.
               Break
            EndIf
            DbSelectArea(aTables[i])
   
            oProc:IncRegua2("Subindo tabela " + aTables[i])
            
            /*
            // ** fecha a tabela e abre exclusivo
            (aTables[i])->(DbCloseArea())
            DbUseArea(.T.,"TOPCONN",RetSqlName(aTables[i]),aTables[i],.F.,.F.)
            
            If Select(aTables[i]) = 0
               MsgInfo("Não foi possível abrir a tabela " + aTables[i] + " em modo exclusivo. Os backups armazenados até agora serão restaurados.","Atualização Cancelada")
               lRet := .F.
               Break
            EndIf
            */
            
            If !AbreTabExc(aTables[i])
               MsgInfo("Não foi possível abrir a tabela " + aTables[i] + " em modo exclusivo. Os backups armazenados até agora serão restaurados.","Atualização Cancelada")
               lRet := .F.
               Break
            EndIf
            
            DbSelectArea(aTables[i])
            ZAP
            
            // ** sobe o conteúdo da pasta de backup
            Append From &(cPasta+"\"+aTables[i]+".dbf") Via "DBFCDX"
            
         Else
            oProc:IncRegua2("Atualizando Estrutura das Tabelas...")
            oProc:IncRegua2("Atualizando Estrutura das Tabelas...")
         EndIf
      Next

   EndIf
   
   oProc:IncRegua1("Finalizando...")
   
   If lTeveAtu
      
      MsgInfo(If(!lPrevia,"Atualização","Prévia")+" Realizada com Sucesso!","Atualizador de Dicionários")

      If lDocumentacao
         
         If lExcel
            If Select("LOG") > 0
               LOG->(dbCloseArea())
            EndIf
            CopiaArquivo(cNome,cDir+cNome)
            
            oExcelApp:= MsExcel():New()
            // Abrir 'Aquivo.dbf' diretamente no Excel
            // oExcelApp:WorkBooks:Open(cDiretorio+cNomeDbf)
            MsAguarde({||oExcelApp:WorkBooks:Open(cDir+cNome)},"Abrindo arquivo de dados no EXCEL")      
            oExcelApp:SetVisible(.T.)
            If !lUsuario
               MsgInfo("Caso o Excel não tenha sido executado, a documentação pode ser encontrada no diretório abaixo:"+;
                          Repl(ENTER,2) + AllTrim(cDir+cNome),"Arquivo gerado com sucesso!")
            EndIf
         EndIf

         If lTexto
            FClose(nCodTxt)
            If (nExec := WinExec('Notepad.exe "'+AllTrim(cDir+cNomeTxt)+'"')) <> 0
               MsgInfo("Caso o notepad não tenha sido executado, a documentação em texto pode ser encontrada no diretório abaixo:"+;
                        Repl(ENTER,2) + AllTrim(cDir+cNomeTxt),"Arquivo gerado com sucesso!")
               
            EndIf
         EndIf
         
      EndIf

   EndIf
   
End Sequence

ErrorBlock(bBlockAntigo)

// ** em caso de erro, restaura os backups automaticamente.
If !lRet
   cMsg := ""

   oProc:SetRegua1(Len(aBackup))

   For i := 1 To Len(aBackup)

      oProc:IncRegua1("Voltando Backups...")
      
      If Select("TAB") > 0
         TAB->(DbCloseArea())
      EndIf
      
      // ** se for backup de tabela que teve sua estrutura alterada
      If aBackup[i][1] == "ESTR"

         /*
         // ** fecha a tabela
         If Select(aBackup[i][3]) > 0
            (aBackup[i][3])->(DbCloseArea())
         EndIf
         // ** apaga a tabela no banco
         TcDelFile(AllTrim(RetSqlName(aBackup[i][3])))
         // ** verifica se apagou mesmo
         If MsFile(AllTrim(RetSqlName(aBackup[i][3])),,"TOPCONN")
            cMsg += " - " + aBackup[i][3] + " (não foi possível apagar a tabela do banco) " + ENTER
            Loop
         EndIf
         */
         
         If !ApagaTabela(aBackup[i][3])
            cMsg += " - " + aBackup[i][3] + " (não foi possível apagar a tabela do banco) " + ENTER
            Loop
         EndIf

         // ** abre o arquivo de backup
         DbUseArea(.T.,,aBackup[i][2],"TAB",.F.,.F.)
         // ** verifica se abriu mesmo
         If Select("TAB") = 0
            cMsg += " - " + aBackup[i][3] + " (Não foi possível abrir o backup) " + ENTER
            Loop
         EndIf
         
         DbSelectArea("TAB")
         // ** copia o arquivo de backup direto pro banco
         Copy To &(RetSqlName(aBackup[i][3])) Via "TOPCONN"
         // ** verifica se copiou
         If !MsFile(AllTrim(RetSqlName(aBackup[i][3])),,"TOPCONN")
            cMsg += " - " + aBackup[i][3] + " (não foi possível restaurar o backup no banco) " + ENTER
            Loop
         EndIf
         TAB->(DbCloseArea())

      // ** se for backup de tabela que teve seu conteúdo alterado
      ElseIf aBackup[i][1] == "TB"
         
         /*
         // ** fecha a tabela
         If Select(aBackup[i][3]) > 0
            (aBackup[i][3])->(DbCloseArea())
         EndIf

         // ** abre a tabela em modo exclusivo
         DbUseArea(.T.,"TOPCONN",RetSqlName(aBackup[i][3]),"TAB",.F.,.F.)
         If Select("TAB") = 0
            cMsg += " - " + aBackup[i][3] + " (Não foi possível abrir a tabela no banco) " + ENTER
            Loop
         EndIf
         */
         
         If !AbreTabExc(aBackup[i][3])
            cMsg += " - " + aBackup[i][3] + " (Não foi possível abrir a tabela no banco) " + ENTER
            Loop
         EndIf
         
         DbSelectArea("TAB")
         // ** apaga o conteúdo da tabela no banco
         Zap
         
         // ** puxa o conteúdo do backup
         Append From &(aBackup[i][2]) Via "DBFCDX"

      // ** se for backup de dicionário alterado
      ElseIf aBackup[i][1] == "DIC"

         // ** fecha o dicionário
         If Select(aBackup[i][3]) > 0
            (aBackup[i][3])->(DbCloseArea())
         EndIf
         
         /*
         // ** apaga o índice do dicionário
         If FErase(aBackup[i][3]+cEmpRpc+"0"+".cdx") == -1 .And. File(aBackup[i][3]+cEmpRpc+"0"+".cdx")
            cMsg += " - " + aBackup[i][3] + " (não foi possível apagar o índice do dicionário) " + ENTER
            Loop
         EndIf
         */
         
         // ** apaga o índice do dicionário
         If !ApagaArquivo(aBackup[i][3]+cEmpRpc+"0"+".cdx")
            cMsg += " - " + aBackup[i][3] + " (não foi possível apagar o índice do dicionário) " + ENTER
            Loop
         EndIf
         
         /*
         // ** apaga o dicionário em si
         If FErase(aBackup[i][3]+cEmpRpc+"0"+".dbf") == -1
            cMsg += " - " + aBackup[i][3] + " (não foi possível apagar o dicionário) " + ENTER
            Loop
         EndIf
         */

         If !ApagaArquivo(aBackup[i][3]+cEmpRpc+"0"+".dbf")
            cMsg += " - " + aBackup[i][3] + " (não foi possível apagar o dicionário) " + ENTER
            Loop
         EndIf
         
         // ** copia o dicionário da pasta de backup
//         If !AvCpyFile(aBackup[i][2],aBackup[i][3]+cEmpRpc+"0"+".dbf")
         If !CopiaArquivo(aBackup[i][2],aBackup[i][3]+cEmpRpc+"0"+".dbf")
            cMsg += " - " + aBackup[i][3] + " (Não foi possível copiar o backup do dicionário) " + ENTER
            Loop
         EndIf
      EndIf
   Next
   // ** mostra erro na restauração de backup
   If Len(cMsg) > 0
      U_EECView("Ocorreram erros na restauração do backup das tabelas: " + Repl(ENTER,2) + cMsg)
   ElseIf Len(aBackup) > 0
      MsgInfo("Restauração de Backup efetuada com sucesso.","Sistema não atualizado")
   EndIf
EndIf

// ** Verifica se o usuário deseja apagar os dados de backup
aDir := Directory(cPasta+"\*.*")
If Len(aDir) > 0
   If !MsgYesNo("Foram feitos backups das alterações na pasta '" + cPasta + "' do servidor da aplicação. Deseja manter este backup?","Atenção")
      AEval(aDir, { |aFile| FErase(cPasta+"\"+aFile[1]) })
      DirRemove(cPasta)
   EndIf
Else
   If lIsDir(cPasta)
      DirRemove(cPasta)
   EndIf
EndIf

If lTeveAtu .And. !lPrevia
   // ** inicaliza o environment para criar índices
   /*
   RpcClearEnv()
   RpcSetType(2)
   RpcSetEnv(cEmpRpc,cFilRpc)
   */
   AbreEnv(cEmpRpc,cFilRpc)
   
   RpcClearEnv()
EndIf

// ** apaga os arquivos criados no servidor
aDir := Directory(cPastaAtu+"\*.*")
AEval(aDir, { |aFile| FErase(cPastaAtu+"\"+aFile[1]) })
DirRemove(cPastaAtu+"\")

// ** apaga os DBFs utilizados para selecionar as atualizações
For i := 1 To Len(aDbfSel)
   FErase(aDbfSel[i][1])
Next

If Len(Directory(cPastaDbfAtu+"\*.*")) > 0
   MsgInfo("Os DBFs de atualização foram gerados na pasta '" +AllTrim(cPastaDbfAtu)+"' do servidor.","Atenção")
EndIf

Return Nil

/*
Objetivos   : Comparar os dicionários
Autor       : João Pedro Macimiano Trabbold
*/
*===================================*
Static Function AtualizaDic(cArquivo)
*===================================*
Local i, lRet := .T., aCpoIdx, cCpoIdx, nStr, cMsg
Local cNome
Private aStruct := {}, cWork, lExiste, cArqDest
Private lSix := .F., lSx2 := .F., lSx3 := .F., lSx5 := .F.,;
        lSx6 := .F., lSx7 := .F., lSxa := .F., lSxb := .F., lSx1 := .F.,;
        lOutros := .F.

Private aCompara     := {}      ,; // Campos que serão comparados
        aComparaStr  := {}      ,; // array q terá o mesmo número de elementos do aCompara, para definir se o campo é caracter ou não
        aCombo       := {}, cCombo := "", cAlias := "", lStruct := .F., cCpoTabela := ""

Private oMark, aCpos := {}, aBrowse := {}

Private nIndPadrao := 1 // Indice padrão para comparação

Begin Sequence
   
   /* Cria uma pasta no servidor para copiar o arquivo que será atualizado, pois o protheus
      só abre arquivos .dbf no caminho do servidor. */
   If !lIsDir(cPastaAtu+"\")
      MakeDir(cPastaAtu+"\")
   EndIf
   cArqDest := cPastaAtu+"\" + SubStr(cArquivo,RAt("\",cArquivo)+1, Len(cArquivo) )
   
   /* Copia o DBF para o servidor */
   oProc:SetRegua2(1)
   oProc:IncRegua2("Copiando arquivo para o servidor... (pode demorar um pouco)")
   
   If !CopiaArquivo(cArquivo,cArqDest)
      MsgInfo("Não foi possível copiar o arquivo " + AllTrim(cArquivo) + " para o servidor.","!")
      lRet := .F.
      Break
   EndIf
   
   // ** Abertura do arquivo
   DbUseArea(.T.,,cArqDest,"NEW",.F.,.F.)
   If Select("NEW") = 0
      If !MsgNoYes("Não foi possível abrir '" + AllTrim(cArquivo) + "'. Deseja continuar?","Atenção")
         lRet := .F.
      EndIf
      Break
   EndIf
   
   // ** Identifica qual tipo de dicionário está sendo importado (apenas são suportados os tipos abaixo)
   If NEW->(FieldPos("INDICE")) = 1
      lSix := .T.
      cAlias := "SIX"
      lStruct := .T.
      cCpoTabela := "INDICE"
   ElseIf NEW->(FieldPos("X2_CHAVE")) = 1
      lSx2 := .T.
      cAlias := "SX2"
      lStruct := .T.
      cCpoTabela := "X2_CHAVE"
   ElseIf NEW->(FieldPos("X3_ARQUIVO")) = 1
      lSx3 := .T.
      cAlias := "SX3"
      nIndPadrao := 2
      lStruct := .T.
      cCpoTabela := "X3_ARQUIVO"
   ElseIf NEW->(FieldPos("X5_FILIAL")) = 1
      lSx5 := .T.
      cAlias := "SX5"
   ElseIf NEW->(FieldPos("X6_FIL")) = 1
      lSx6 := .T.
      cAlias := "SX6"
   ElseIf NEW->(FieldPos("X7_CAMPO")) = 1
      lSx7 := .T.
      cAlias := "SX7"
   ElseIf NEW->(FieldPos("XA_ALIAS")) = 1
      lSxa := .T.
      cAlias := "SXA"
   ElseIf NEW->(FieldPos("XB_ALIAS")) = 1
      lSxb := .T.
      cAlias := "SXB"
   ElseIf NEW->(FieldPos("X1_GRUPO")) = 1
      lSx1 := .T.
      cAlias := "SX1"
   Else
      // ** tratamentos genéricos - pode ser usado para carga de tabelas no sistema
      cAlias := AllTrim(SubStr(NEW->(FieldName(1)),1,At("_",NEW->(FieldName(1)))-1))
      If Len(cAlias) = 2
         cAlias := "S" + cAlias
      EndIf
      If Len(cAlias) == 3 .And. SX2->(DbSetOrder(1),DbSeek(cAlias))
         //ChkFile(cAlias)
         AbreRecriaTab(cAlias)
         If Select(cAlias) > 0
            lOutros := .T.
         EndIf
      EndIf
      If !lOutros
         cNome := AllTrim(cArquivo)
         cNome := SubStr(cNome,RAt("\",cNome)+1,Len(cNome))
         If Right(Upper(cNome),4) = ".DBF"
            cNome := SubStr(cNome,1,Len(cNome)-4)
         EndIf
         cAlias := cNome
         DbUseArea(.T.,"TOPCONN",cNome,cAlias,.F.,.T.)
         If Select(cAlias) = 0
            MsgInfo("O formato do arquivo '" + AllTrim(cArquivo) + "' não é suportado.","Atenção")
            Break
         EndIf
         Set Index To (cNome+"1")

         lOutros := .T.
      EndIf
   EndIf

   oProc:SetRegua2(1)
   oProc:IncRegua2("Verificando campos a serem comparados...")
   
   // ** Adiciona os campos que poderão ser comparados
   For i := 1 To New->(FCount())
      If (cAlias)->(FieldPos(New->(FieldName(i)))) > 0 // se o campo existe no destino
         AAdd(aCompara,New->(FieldName(i)))
      EndIf
   Next
   
   // ** este array será utilizado na Tela3()
   aCpos := AClone(aCompara)
   
   // ** Armazena quantas ordens o dicionário possui, para que o usuário escolha com qual ordem deseja comparar
   DbSelectArea(cAlias)
   nQtdOrdens := 100
   
   /* Faz um error block, pois não se sabe qtas ordens o arquivo tem. Qdo dá erro, o IndexKey 
      fica em branco, e o processamento pára */
   bBlockAntigo := ErrorBlock({|e| nQtdOrdens := (i - 1), .T.})
   Begin Sequence

      For i := 1 To nQtdOrdens
         (cAlias)->(DbSetOrder(i))
         If Empty((cAlias)->(IndexKey()))
            Exit
         EndIf
         AAdd(aCombo,AllTrim(Str(i)) + "=" + (cAlias)->(IndexKey()))
      Next

   End Sequence
   ErrorBlock(bBlockAntigo)

   // ** Quando é Sx3, já traz como primeiro o índice por X3_CAMPO (troca o primeiro pelo segundo)
   If lSx3
      cCombo := aCombo[1]
      aCombo[1] := aCombo[2]
      aCombo[2] := cCombo
   EndIf

   If Len(aCombo) > 0
      cCombo := aCombo[1]
   EndIf

   oProc:SetRegua2(1)
   oProc:IncRegua2("Realizando comparação dos arquivos...")
   
   // ** Tela de Opções de Comparação
   If !Tela2()
      lRet := .F.
      Break
   EndIf

   (cAlias)->(DbSetOrder(nIndPadrao))
   
   // ** verifica se o tamanho dos campos chave bate.
   aCpoIdx := {}
   cCpoIdx := (cAlias)->(IndexKey())
   While !Empty(cCpoIdx)
      If (nStr := At("+",cCpoIdx)) = 0
         AAdd(aCpoIdx,AllTrim(cCpoIdx))
         cCpoIdx := ""
      Else
         AAdd(aCpoIdx,SubStr(cCpoIdx,1,nStr-1))
         cCpoIdx := SubStr(cCpoIdx,nStr+1,Len(cCpoIdx))
      EndIf
   EndDo

   cMsg := ""
   For i := 1 To Len(aCpoIdx)
      If Len(New->&(aCpoIdx[i])) <> Len((cAlias)->&(aCpoIdx[i]))
         cMsg += " - " + aCpoIdx[i] + ". Origem: " + AllTrim(Str(Len(New->&(aCpoIdx[i])))) + ", Destino: " + AllTrim(Str(Len((cAlias)->&(aCpoIdx[i]))))
      EndIf
   Next

   If !Empty(cMsg)
      cMsg := "Existem campos com tamanhos divergentes entre origem e destino na chave escolhida. Efetue o acerto. A comparação não será realizada." +;
              Repl(ENTER,2) + cMsg
      MsgInfo(cMsg,"Atenção")
      If MsgYesNo("Deseja continuar com as outras comparações?","Atenção")
         lRet := .T.
      Else
         lRet := .F.
      EndIf
      Break
   EndIf
   
   If !(lRet := Comparacao())
      Break
   EndIf

End Sequence

// ** apaga os arquivos temporários
If Select("NEW") > 0
   New->(E_EraseArq(cArqDest))
EndIf
If Select("SEL") > 0
   Sel->(DbCloseArea())
EndIf

Return lRet

/*
Objetivos    : Efetuar Comparação.
*/
*==========================*
Static Function Comparacao()
*==========================*
Local lRet := .T., cPosfixo := "010"

Begin Sequence

   nIndPadrao := Val(Left(cCombo,1))
   If nIndPadrao < 1 .Or. nIndPadrao > nQtdOrdens
      MsgInfo("O Índice escolhido não é valido","Atenção")
      lRet := .F.
      Break
   EndIf
   
   // ** Monta estrutura do arquivo para selecionar os dados a serem importados na msselect
   aStruct := NEW->(DbStruct())
   
   // ** Monta estrutura do browse
   // campo para marcar
   AAdd(aBrowse,{"OK",,""}) 
   // indica se o campo já existe no dicionário atual
   AAdd(aBrowse,{{|| If(Sel->EXISTE="S","Sim","Não")},,"Existe?"})
   // restante dos campos
   For i := 1 To Len(aStruct) // Monta estrutura do browse de seleção do usuário
      AAdd(aBrowse,{aStruct[i][1],,aStruct[i][1]})
   Next
   
   // ** campos adicionais na estrutura do arquivo
   AddStruct(aStruct,{"OK"    ,"C",2,0})
   AddStruct(aStruct,{"REC"   ,"N",7,0})
   AddStruct(aStruct,{"EXISTE","C",1,0})
   
   // ** Monta nome do arquivo de seleção
   cWork := "\Atu001"
   While File(cPastaAtu+cWork+".Dbf")
      cWork := "\Atu" + StrZero(Val(Right(cWork,3)) + 1,3)
   EndDo
   cWork := cPastaAtu+cWork
   
   // ** Cria o arquivo
   DbCreate(cWork+".Dbf",aStruct)
   DbUseArea(.T.,,cWork,"SEL",.F.,.F.)
   
   aComparaStr := {}
   // ** indica se o campo é caracter, para dar alltrim na comparação
   For i := 1 To Len(aCompara)
      AAdd(aComparaStr, (ValType((cAlias)->&(aCompara[i])) = "C") )
   Next

   oProc:SetRegua2(New->(RecCount()))
   
   // ** Carrega a work de seleção do usuário
   (cAlias)->(DbSetOrder(nIndPadrao))

   DbSelectArea("SEL")
   IndRegua("SEL",cWork+OrdBagExt(),(cAlias)->(IndexKey()))
   
   If lSx2
      If SX2->(!DbSeek("EEC")) .Or. Empty(cPosfixo := SubStr(SX2->X2_ARQUIVO,4,3))
         SX2->(DbGoTop())
         cPosfixo := SubStr(SX2->X2_ARQUIVO,4,3)
      EndIf
   EndIf
   
   While New->(!Eof())
      
      If lSx2
         If SubStr(New->X2_ARQUIVO,4,3) <> cPosfixo
            New->X2_ARQUIVO := New->X2_CHAVE + cPosfixo
         EndIf
      EndIf
      
      oProc:IncRegua2("Comparando dados... (pode demorar um pouco)")

      i := 0
      
      /* Otimizando... macro é bem mais rápido que fieldwblock, memvarblock ou new kids on the block.
      // ** se o registro já existe no dicionário atual, compara os campos
      If (lExiste := (cAlias)->(DbSeek(New->&((cAlias)->(IndexKey())))))
         For i := 1 To Len(aCompara)
            If If(aComparaStr[i],; // Se é string, dá alltrim pra comparar.
                  !(AllTrim(Eval(FieldWBlock(aCompara[i],Select("NEW")))) == AllTrim(Eval(FieldWBlock(aCompara[i],Select(cAlias))))),;
                  !(Eval(FieldWBlock(aCompara[i],Select("NEW"))) == Eval(FieldWBlock(aCompara[i],Select(cAlias)))) )


               Exit // se tiver alguma diferença entre os campos que devem ser comparados, sai do 'for' antes
               
            EndIf
         Next
      EndIf
      */
      
      // ** se o registro já existe no dicionário atual, compara os campos
      If (lExiste := (cAlias)->(DbSeek(New->&((cAlias)->(IndexKey())))))
         For i := 1 To Len(aCompara)
            If If(aComparaStr[i],; // Se é string, dá alltrim pra comparar.
                  !(AllTrim(Upper(New->&(aCompara[i]))) == AllTrim(Upper((cAlias)->&(aCompara[i])))),;
                  !(New->&(aCompara[i]) == (cAlias)->&(aCompara[i])) )

               Exit // se tiver alguma diferença entre os campos que devem ser comparados, sai do 'for' antes
               
            EndIf
         Next
      EndIf

      If i > Len(aCompara) // se não saiu do for antes, não tem diferença, então não entra na work
         New->(DbSkip())
         Loop
      EndIf
      
      // ** adiciona na work de seleção
      Sel->(DbAppend())
      DicReplace("NEW","SEL")
      If lExiste
         Sel->EXISTE := "S"
         Sel->REC := (cAlias)->(RecNo())
      Else
         Sel->EXISTE := "N"
      EndIf
      
      New->(DbSkip())
   EndDo
   
   // ** apaga o arquivo temporário de destino, pois todos os dados já estão na work de seleção.
   New->(E_EraseArq(cArqDest))
   
   If Sel->(RecCount()) = 0
      If !lUsuario
         MsgInfo("De acordo com os parâmetros de comparação, não há registros diferentes para o dicionário/tabela " + cAlias + ".","Aviso")
      EndIf
      Break
   EndIf
   
   // ** Tela de comparação
   If !Tela3()
      lRet := .F.
      Break
   EndIf
   
   // ** armazena os dbfs com as seleções do usuário para atualizar tudo de uma vez, ao final.
   AAdd(aDbfSel,{cWork,cAlias,lStruct,cCpoTabela,nIndPadrao})
   
End Sequence

Return lRet

/*
Objetivos   : Atualizar o dicionário
Autor       : João Pedro Macimiano Trabbold
*/
*==============================================================*
Static Function AtuBase(cWork,cAlias,lStruct,cCpoTabela,nIndice)
*==============================================================*
Local lRet := .T.
Local cBkp := cPasta+"\"+cAlias+".dbf"

Begin Sequence
   
   If lGeraDbf
      CopiaArquivo(cWork+".dbf",cPastaDbfAtu+"\"+cAlias+".dbf")
      DbUseArea(.T.,,cPastaDbfAtu+"\"+cAlias,"DBFSEL",.F.,.F.)
      If Select("DBFSEL") = 0
         MsgInfo("Não foi possível abrir o arquivo " +AllTrim(cPastaDbfAtu+"\"+cAlias)+ ".","Atenção")
      Else
         DBFSEL->(DbGoTop())
         While DBFSEL->(!Eof())
            If Empty(DBFSEL->OK)
               DBFSEL->(DbDelete())
            Else
               DBFSEL->OK     := ""
               DBFSEL->REC    := 0
               DBFSEL->EXISTE := ""
            EndIf
            
            DBFSEL->(DbSkip())
         EndDo
         DbSelectArea("DBFSEL")
         Pack
         DBFSEL->(DbCloseArea())
      EndIf
   EndIf

   oProc:IncRegua2("Fazendo backup de " + cAlias + "...")
   
   If !lPrevia
   
      // ** armazena o backup
      // ** verifica se já não foi feito o backup deste alias e se precisa
      DbSelectArea(cAlias)
      If Select(cAlias) > 0 .And. (cAlias)->(RecCount()) > 0 .And. AScan(aBackup,{|x| x[3] == cAlias}) = 0 .And. lBackup
         
         Copy To &(cBkp) Via "DBFCDX"
      
         If !File(cBkp)
            MsgInfo("Não foi possível fazer o backup do arquivo " + AllTrim(cAlias) + ". A atualização será cancelada. Se já houveram alterações, os backups serão restaurados.","Atenção")
            lRet := .F.
            Break
         EndIf
   
         // ** array de backups, para um possível rollback ao final
         AAdd(aBackup,{If(("SX" $ cAlias .Or. "SIX" $ cAlias),"DIC","TB"),;
                          cBkp,;
                          cAlias})
      EndIf
   
   EndIf
   
   If ("SX" $ cAlias .Or. "SIX" $ cAlias)
      AAdd(aAlterados,cAlias)
   EndIf
   
   oProc:IncRegua2("Atualizando " + cAlias + "...")
   
   DbUseArea(.T.,,cWork,"SEL",.F.,.F.)
   
   (cAlias)->(DbSetOrder(nIndice))
   
   Sel->(DbGoTop())
   
   If lDocumentacao
      If lTexto
         Documenta("Tabela " + AllTrim(cAlias) + Repl(ENTER,2))
      EndIf
      If lExcel
         LOG->(DbAppend())
         LOG->TABELA := cAlias
      EndIf
   EndIf
   
   // ** Atualiza a base
   While Sel->(!Eof())
      // ** desconsidera os marcados
      If Empty(Sel->OK)
         Sel->(DbSkip())
         Loop
      EndIf
      
      /* se é um tipo de dicionário que altera estrutura de tabelas no banco, adiciona no array 
         aTables, para rodar um X31UpdTable (ou semelhante) no fim do processamento */
      If lStruct
         If AScan(aTables,Sel->&(cCpoTabela)) = 0
            AAdd(aTables,Sel->&(cCpoTabela))
         EndIf
      EndIf
      
      // ** se já existe no dicionário atual, posiciona no registro
      If Sel->EXISTE = "S"
         (cAlias)->(DbGoTo(Sel->REC))
      Else
         (cAlias)->(DbGoBottom(),DbSkip())
      EndIf
      
      If !lTeveAtu
         lTeveAtu := .T.
      EndIf
      
      If !lPrevia
         // ** atualiza o dicionário
         (cAlias)->(RecLock(cAlias, (Sel->EXISTE <> "S") ))
      EndIf
      
      If lDocumentacao
         If Sel->EXISTE = "S"
            If lTexto
               Documenta(" - Alteração - ")
            EndIf
            
            If lExcel
               LOG->(DbAppend())
               LOG->TIPO := "Alteracao"
            EndIf
         Else
            If lTexto
               Documenta(" - Inclusão - ")
            EndIf
            
            If lExcel
               LOG->(DbAppend())
               LOG->TIPO := "Inclusao"
            EndIf
         EndIf
         
         If lTexto
            Documenta(AllTrim((cAlias)->(IndexKey())) + " = " + AllTrim(SEL->&((cAlias)->(IndexKey()))) + ENTER)
         EndIf
         
         If lExcel
            LOG->CHAVE      := AllTrim((cAlias)->(IndexKey()))
            LOG->CONT_CHAVE := AllTrim(SEL->&((cAlias)->(IndexKey())))
         EndIf
         
         DicReplace("SEL",cAlias,Sel->EXISTE <> "S",.T.)
         
         If lTexto
            Documenta(ENTER)
         EndIf
         
      Else
         DicReplace("SEL",cAlias,,.T.)
      EndIf
      
      If !lPrevia
         (cAlias)->(MsUnlock())
      EndIf
      
      Sel->(DbSkip())
   EndDo

End Sequence

If Select("SEL") > 0
   Sel->(E_EraseArq(cWork))
EndIf

Return lRet

/*
Objetivos    : Tela para escolha dos arquivos dbf a serem importados
Autor        : João Pedro Macimiano Trabbold
*/
*====================*
Static Function Tela()
*====================*
Local oDlg, aButtons
Local bOk     := {|| If( (Len(aCols) > 0 .And. !Empty(aCols[1][1]) ) ,(oDlg:End(),lOk := .t.),lOk := .f.) },;
      bCancel := {|| oDlg:End() }
Local lOk := .f.
Local x,n,i,j
Local cArq, aArquivos := {}
Local bAddFile := {|| If( (Len(aCols) > 0 .And. !Empty(aCols[1][1]) ) ,cLastArq := aCols[1][1],Nil), AddFile() }

Private cArquivo, aHeader := {}, aCols := {}, aColsAcento := {}//a MsGetDados pode tirar os acentos do aCols 
Private aRotina := { { "", "", 0, 2 } }
Private oMsGet, cLastPath := "C:\"

Private cLastArq

Begin Sequence
   aButtons := {{ "Adicionar_001",bAddFile, "Adicionar arquivo" + " <F3>", "Adicionar" }}
   
   aHeader := {{"Arquivo","ARQUIVO","@!",200,0,".t.",nil,"C",nil,nil } ,;
               {"Data"   ,"DATA"   ,"@!",8  ,0,".t.",nil,"C",nil,nil } ,;
               {"Hora"   ,"HORA"   ,"@!",10 ,0,".t.",nil,"C",nil,nil } }
   
   // escolha do arquivo a ser importado
   DEFINE MSDIALOG oDlg TITLE "Importação de dicionários/tabelas (F3 para selecionar arquivo)" FROM 1,1 To 300,470 Pixel
      
      oMSGet:= MSGetDados():New(1, 1, 1, 1, 1,,,"",.T.,{},,,500,,,,"U_DelImp")
      oMsGet:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

      oMSGet:ForceRefresh()

      SetKey(VK_F3,bAddFile)

   Activate MsDialog oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel,,aButtons) Centered

   SetKey(VK_F3,Nil)
   
   If !lOk
      Break
   EndIf
   
   For i := 1 to Len(aCols)
      aCols[i][1] := aColsAcento[i]
   Next
   
   /*
   // ordena por data e hora, para que os últimos (mais recentes) sobreponham os mais antigos
   aSort(aCols,,, {|x, y| DToS(x[2])+x[3] < DToS(y[2])+y[3] })
   */
   
   For j := 1 to Len(aCols)
      // desconsidera se estiver deletado
      If aCols[j][Len(aCols[j])]
         Loop
      EndIf
      
      cArquivo := AllTrim(aCols[j][1])
      AAdd(aArquivos,cArquivo)
   Next
   
End Sequence

SetKey(VK_F3,Nil)

Return aArquivos

/*
Funcao     : DelImp()
Parametros : Nenhum
Retorno    : Nil
Objetivos  : Validar UNDELETE da linha da msgetdados
Autor      : João Pedro Macimiano Trabbold
Data/Hora  : 29/08/05 - 15:10
Revisao    : 
Obs.       :
*/
*====================*
User Function DelImp()
*====================*
Local i

If !aCols[n][Len(aCols[n])]
   For i := 1 to Len(aCols)
      If !aCols[i][Len(aCols[i])] .And. Upper(aColsAcento[n]) == Upper(aColsAcento[i]) .And. i <> n
         MsgInfo("O arquivo já está especificado.","Aviso")
         aCols[n][Len(aCols[n])] := .t.
         oMsGet:oBrowse:Refresh()
         Return .f.
      EndIf
   Next
EndIf

Return .t.

/*
Funcao     : AddFile()
Parametros : Nenhum
Retorno    : Nil
Objetivos  : Escolha do arquivo .dbf pelo usuário
Autor      : João Pedro Macimiano Trabbold
Data/Hora  : 29/08/05 - 13:30
Revisao    : 
Obs.       :
*/
*=======================*
Static Function AddFile()
*=======================*
Local oDlg, oFont, oSay
Local lOk := .f.
Local bOk     := {|| If(DocImpValid(),(oDlg:End(),lOk := .t.),lOk := .f.) },;
      bCancel := {|| oDlg:End() }
Local aDir, i, j
Local bOld, oArquivo
Private bFileAction := {|| cArquivo := ChooseFile()}, cArquivo := Space(200)

Begin Sequence

   If Type("cLastArq") = "C" .And. !Empty(cLastArq)
      cArquivo := PadR(cLastArq,200)
   EndIf
      
   // escolha do arquivo a ser importado
   DEFINE MSDIALOG oDlg TITLE "Importação de dicionários" FROM 1,1 To 91,376 Pixel
      
      @ 14,4 to 43,185 Label "Escolha o arquivo a ser importado:" PIXEL
      
      @ 25,12 MsGet oArquivo Var cArquivo Size 150,07 Pixel Of oDlg
      
      @ 25,162 Button "..." Size 10,10 Pixel Action .t. Of oDlg

      oDlg:aControls[3]:bAction := bFileAction

      Define Font oFont Name "Arial" SIZE 0,-10 //BOLD
      @ 26,173 Say oSay Var "(F3)" Size 10,10 Pixel Of oDlg Color CLR_GRAY
      oSay:oFont := oFont
      
      bOld := SetKey(VK_F3)
      SetKey(VK_F3,bFileAction)

   Activate MsDialog oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel,,) Centered      

   SetKey(VK_F3,bOld)

   If !lOk
      Break
   EndIf
   
   If Type("aCols[1][1]") <> "U" .And. Empty(aCols[1][1])
      ADel(aCols,1)
      ASize(aCols,Len(aCols)-1)
   EndIf
   
   cArquivo := Upper(AllTrim(cArquivo))

   cFolder  := If(Right(cArquivo,1) = "\",cArquivo,SubStr(cArquivo,1,RAt("\",cArquivo)))

   cArquivo += If(!File(cArquivo),"*.DBF","")//caso o usuário informe apenas a pasta.
   
   aDir := Directory(cArquivo)

   Private cArq

   For i := 1 to Len(aDir)
      cArq := AllTrim(Upper(cFolder+aDir[i][1]))
      lLoop := .f.
      For j := 1 To Len(aColsAcento)
         If aColsAcento[j] == cArq .And. !aCols[j][Len(aCols[j])]
            lLoop := .t.
            Exit
         EndIf
      Next
      If lLoop
         Loop
      EndIf
      If Right(AllTrim(cArq),3) <> "DBF"
         Loop
      EndIf
      aAdd(aCols, Array( Len(aHeader)+1 ) )
      n := Len(aCols)
      aCols[n][Len(aCols[n])] := .f.
      aCols[n][1] := IncSpace(cArq,aHeader[1][4],.f.)       //nome do arquivo
      aCols[n][2] := aDir[i][3]                             //data
      aCols[n][3] := IncSpace(aDir[i][4],aHeader[1][4],.f.) //hora
      AAdd(aColsAcento,cArq)
   Next
   
   oMsGet:oBrowse:Refresh()
   
End Sequence

Return Nil

/*
Funcao     : DocImpValid()
Parametros : Nenhum
Retorno    : .t./.f.
Objetivos  : Validar o arquivo informado para importação de dados
Autor      : João Pedro Macimiano Trabbold
Data/Hora  : 17/06/05 - 14:40
Revisao    : 
Obs.       :
*/
*===========================*
Static Function DocImpValid()
*===========================*
Local i, cArq := AllTrim(Upper(cArquivo))

If Empty(cArq)
   MsgInfo("Informe o caminho e o nome do arquivo","Aviso")
   Return .f.
EndIf

If Right(cArq,4) <> ".DBF" .And. Right(cArq,1) <> "\" .And. Right(cArq,1) <> "*" .And. Right(cArq,1) <> "?"
   cArq += "\"
EndIf

If !File(cArq)
   
   If !lIsDir(cArq)
      MsgStop("O arquivo especificado não existe.","Aviso")
      Return .f.
   EndIf
   
   If Len(Directory(cArq+"*.DBF")) = 0
      MsgStop("Não há arquivos .DBF no diretório especificado.","Aviso")
      Return .f.
   EndIf
   
ElseIf (Len(aCols) <> 1 .Or. !Empty(aCols[1][1]) ) //A msgetdados inclui uma linha no acols automaticamente....
   For i := 1 to Len(aCols)
      If AllTrim(Upper(aColsAcento[i])) == cArq .And. !aCols[i][Len(aCols[i])]
         MsgStop("O arquivo especificado já foi escolhido.","Aviso")
         Return .f.
      EndIf
   Next
   
EndIf

cArquivo := cArq

Return .t.

/*
Funcao     : ChooseFile()
Parametros : Nenhum
Retorno    : cFile - Arquivo selecionado
Objetivos  : Abrir tela para escolha do arquivo a ser importado
Autor      : João Pedro Macimiano Trabbold
Data/Hora  : 17/06/05 - 14:41
Revisao    : 
Obs.       : Baseado na função ChoseFile()(ecsmp01_rdm.prw) - Customização S.Magalhães - por JBJ
*/

*==========================*
Static Function ChooseFile()
*==========================*
Local cTitle:= "Importação de dicionários"
Local cMask := "Formato DBF(Database File)|*.dbf"
Local cFile := ""
Local nDefaultMask := 0
Local cDefaultDir  := cLastPath
Local nOptions:= GETF_OVERWRITEPROMPT+GETF_LOCALHARD+GETF_NETWORKDRIVE

SetKey(VK_F3,Nil)

cFile := cGetFile(cMask,cTitle,nDefaultMask,cDefaultDir,,nOptions)

If Empty(cFile)
   SetKey(VK_F3,bFileAction)
   Return cArquivo
EndIf

cLastPath := SubStr(cFile,1,RAt("\",cFile))

SetKey(VK_F3,bFileAction)

Return IncSpace(cFile,200,.F.)

/*
Objetivos    : Apresentar ao usuário tela de opções de comparação
Autor        : João Pedro Macimiano Trabbold
*/
*=====================*
Static Function Tela2()
*=====================*
Local lRet := .F.
Local oDlg,oBox,oBox2,aItens2:={},;
      oButton,oButton2,oButton3,oButton4, oComboBox

Local aPos, bOk

Private cBox,cBox2

Begin Sequence
   
   // campos do listbox
   aItens := AClone(aCompara)
   
   Define MSDialog oDlg Title "Opções para Comparação do " + AllTrim(cAlias) From 1,1 To 350,360 Pixel
      
      @18,05  SAY "Campos a Comparar:" SIZE 100,07 FONT TFont():New("Verdana",07,14) OF oDlg PIXEL

      @28,05  LISTBOX oBox Var cBox ITEMS aItens SIZE 70,100 Of oDlg Pixel
      oBox:nAt := 1
      oBox:SetFocus()
   
      @28,105 LISTBOX oBox2 Var cBox2 ITEMS aItens2 SIZE 70,100 Of oDlg Pixel

      @33,80 Button oButton  PROMPT '>' Size 20,10 Of oDlg Pixel
      oButton:bAction :={||Adicionar(@oBox2,@oBox,"cBox")}
      @53,80 Button oButton  PROMPT '>>' Size 20,10 Of oDlg Pixel
      oButton:bAction :={||Adicionar(@oBox2,@oBox,"cBox",.T.)}
      
      @83 ,80 Button oButton2 PROMPT '<' Size 20,10 Of oDlg Pixel
      oButton2:bAction:={||Adicionar(@oBox,@oBox2,"cBox2")}
      @103,80 Button oButton2 PROMPT '<<' Size 20,10 Of oDlg Pixel
      oButton2:bAction:={||Adicionar(@oBox,@oBox2,"cBox2",.T.)}

      @137,005 SAY "Índice Utilizado para Comparação:" SIZE 165,07 FONT TFont():New("Verdana",07,14) OF oDlg PIXEL
      @150,006 ComboBox oComboBox Var cCombo Items aCombo size 165,08 of oDlg pixel
      oComboBox:bValid := {|| .T.}

      bOk := {|| If(ValidAll(oDlg),If(Len(aItens)>0,(oDlg:End(),lRet := .T.),;
                                      MsgInfo("Não há campos selecionados.","Atenção")),)}
   Activate MSDialog oDlg ;
      On Init (EnchoiceBar(oDlg,bOk,{||oDlg:End(),lRet := .F.}),If(lUsuario,Eval(bOk),Nil)) Centered
   
   If lRet
      aCompara := aClone(aItens)
   EndIf
   
End Sequence

Return lRet

/*
Função    : Adicionar()
Autor     : Leandro Diniz de Brito
            João Pedro - lTodos
*/
*================================================*
Static Function Adicionar(oBox,oBox2,cBoxx,lTodos)
*================================================*
Default lTodos := .F.
If lTodos
   While oBox2:Len()>0
      oBox:Add(oBox2:aItems[1])
      oBox2:Del(1)
   EndDo
Else
   If oBox2:Len()>0
      oBox:Add(&cBoxx)
      oBox2:Del(oBox2:nAt)
   EndIf
EndIf
oBox:Refresh()
oBox2:Refresh()
oBox2:Setfocus()
Return

/*
Objetivos    : Executar replace de um arquivo para outro
Autor        : João Pedro Macimiano Trabbold
*/
*===========================================================*
Static Function DicReplace(cOri,cDest,lInclusao,lTrataPrevia)
*===========================================================*
Local i

Default lInclusao := .F.
Default lTrataPrevia := .F.

/*
For i := 1 To (cOri)->(FCount())
   If (cDest)->(FieldPos( (cOri)->(FieldName(i)) )) > 0
      Eval(FieldWBlock((cOri)->(FieldName(i)),Select(cDest)), Eval(FieldWBlock((cOri)->(FieldName(i)),Select(cOri))) )
   EndIf
Next
*/

For i := 1 To (cOri)->(FCount())
   If (cDest)->(FieldPos( (cOri)->(FieldName(i)) )) > 0
      If lDocumentacao .And. ((cDest)->&((cOri)->(FieldName(i))) <> (cOri)->(FieldGet(i)) .Or. !lApenasAlterados)
         If lTexto
            Documenta(       "   - Campo '"+AllTrim((cOri)->(FieldName(i)))+"' "+ENTER+;
               If(!lInclusao,"     Alterado de : "+ConverteStr((cDest)->&((cOri)->(FieldName(i))))+ENTER,"")+;
               If(!lInclusao,"     Para        : ",;
                             "     Conteúdo    : ")+ConverteStr((cOri)->(FieldGet(i)))+ENTER)
         EndIf
         
         If lExcel
            LOG->(DbAppend())
            LOG->CAMPO       := (cOri)->(FieldName(i))
            LOG->CAMPO_DE    := ConverteStr((cDest)->&((cOri)->(FieldName(i))))
            LOG->CAMPO_PARA  := ConverteStr((cOri)->(FieldGet(i)))
         EndIf
      EndIf
      If !lPrevia .Or. !lTrataPrevia
         (cDest)->&((cOri)->(FieldName(i))) := (cOri)->(FieldGet(i))
      EndIf
   EndIf
Next

Return

/*
Objetivos   : Tela para selecionar os campos que serão atualizados.
Autor       : João Pedro Macimiano Trabbold
*/
*=====================*
Static Function Tela3()
*=====================*
Local lOk := .F., oDlg, lMarca := .F., nInd
Local aButtons := {}
Local bOk := {|| If(ValTela3(), (lOk := .T., oDlg:End()),) },;
      bCancel := {|| If(MsgNoYes("Deseja realmente sair?","Sair") ,(lOk := .F., oDlg:End()),) }
Local bMarcaTodos
Private aCampos:={}, aHeader:={}, lInverte := .F.
Private lRepete := .F.

Begin Sequence
   bMarcaTodos :=          {|| Sel->(DbGoTop()),;
                               lMarca := (Empty(Sel->OK)),;
                               Sel->(DbEval({|| Sel->OK := If(lMarca,cMarca,"")},;
                                            {|| If(lMarca,Empty(Sel->OK),!Empty(Sel->OK))}  )),;
                               Sel->(DbGoTop()) }
                               
   AAdd(aButtons,{"LBTIK", bMarcaTodos ,;
                  "Marca/Desmarca Todos","Marca Todos"})
                  
   AAdd(aButtons,{"LBTIK", {|| Sel->(DbGoTop()),;
                               Sel->(DbEval({|| Sel->OK := cMarca},;
                                            {|| Sel->EXISTE <> "S"})),;
                               Sel->(DbGoTop()) } ,;
                  "Marcar Registros Novos","Marca Novos"})
   
   AAdd(aButtons,{"LBTIK", {|| Sel->(DbGoTop()),;
                               Sel->(DbEval({|| Sel->OK := cMarca},;
                                            {|| Sel->EXISTE = "S"})),;
                               Sel->(DbGoTop()) } ,;
                  "Marcar Registros Já Existentes","Marca Exist."})

   AAdd(aButtons,{"AUTOM"   , {|| SetExpr("M") }, "Marcar por Expressão","Expressão"})
   AAdd(aButtons,{"PESQUISA", {|| SetExpr("P") }, "Pesquisar","Pesquisar"})
   AAdd(aButtons,{"FILTRO"  , {|| SetExpr("F") }, "Aplicar Filtro","Filtrar"})
   AAdd(aButtons,{"BMPTRG"  , {|| Sel->(DbClearFilter(),DbGoTop()) }, "Limpar Filtro","Limp.Filtro"})

   AAdd(aButtons,{"BMPTRG"  , {|| Sel->(If(IndexOrd()=1,DbSetOrder(0),DbSetOrder(1) ) ) }, "Ordenar/Desordenar","Ord.Desord."})

/* testando bmps
   aBmp:={"WEB","NORMAS","PRECO","TABPRICE","FOLDER6","PESQUISA","BMPCONS","BMPTABLE","CONTAINR","POSCLI","SIMULACA"}
   For i := 1 To Len(aBmp)
      AAdd(aButtons,{aBmp[i], {|| .T. }, aBmp[i],aBmp[i] })
   Next
*/

   Sel->(DbGoTop())
   
   AAdd(aBrowse,Nil)
   AIns(aBrowse,2)
   aBrowse[2] := {"OK",,""}
   
   DEFINE MSDIALOG oDlg TITLE "Marque os registros a serem atualizados (marque direto com F4)" FROM 1,1 TO 46,120

      aPos := PosDlg(oDlg)
      oMark := MsSelect():New("Sel","OK",,aBrowse,@lInverte,@cMarca,aPos)
      oMark:bAval := {|| MarcaDic(), If(lRepete,(Eval(oMark:bAval),lRepete := .F.),) } 

      oCol := oMark:oBrowse:aColumns[2]
      oCol           := TCColumn():New()
      oCol:lBitmap   := .T.
      oCol:lNoLite   := .T.
      oCol:nWidth    := 33
      oCol:bData     := {|| If(SEL->EXISTE="S", "BR_VERDE", "BR_VERMELHO")}
      oCol:cHeading  := ""
      
      oMark:oBrowse:aColumns[2] := oCol
      oDlg:lMaximized := .T.
      
      SetKey(VK_F4,{|| If(Empty(Sel->OK),Sel->OK := cMarca,Sel->OK := "") })

   ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,bOk,bCancel,,aButtons),If(lUsuario,(Eval(bMarcaTodos),Eval(bOk)),Nil)) CENTERED
   
   SetKey(VK_F4,Nil)
   
End Sequence

Return lOk

/*
Objetivos   : Grifar campos com conteúdos diferentes.
*/
/*
*==============================*
Static Function GrifaCampo(nInd)
*==============================*

If SEL->EXISTE="S" .And.;
   Type(cAlias+"->"+aBrowse[nInd][1]) = Type("SEL->"+aBrowse[nInd][1]) .And.;
   ((cAlias)->(DbGoTo(Sel->REC)) .And.;
   (cAlias)->&(aBrowse[nInd][1]) <> SEL->&(aBrowse[nInd][1]))
   Return 15132390
Else
   Return 16777215
EndIf
*/

/*
Objetivos  : Validar a tela de seleção de registros
Autor      : João Pedro Macimiano Trabbold
*/
*========================*
Static Function ValTela3()
*========================*
Local lRet := .T., lTem := .F.

Begin Sequence
   
   Sel->(DbGoTop())
   While Sel->(!EoF())
      If !Empty(Sel->OK)
         lTem := .T.
         Exit
      EndIf
      Sel->(DbSkip())
   EndDo
   Sel->(DbGoTop())
   
   If !lTem
      If !MsgNoYes("Não foi selecionado nenhum registro. Deseja continuar?","Dicionários")
         lRet := .F.
         Break
      EndIf
   EndIf
   
End Sequence

Return lRet
/*
Objetivos   : Marcar/Desmarcar item para atualização e apresentar tela de comparação
Autor       : João Pedro Macimiano Trabbold
*/
*========================*
Static Function MarcaDic()
*========================*
Local lOk := .F., oDlg, aPos, i, j, cVar, bGet, cPrefixo
Local bOk := {|| If(/*ValidaMarca()*/ .T., (lOk := .T., oDlg:End()), lOk := .F.) },;
      bCancel := {|| lOk := .F., oDlg:End() }

Begin Sequence
   
   If lRepete
      lRepete := .F.
   EndIf
   
   If !Empty(Sel->OK)
      Sel->OK := ""
      Break
   EndIf
   
   (cAlias)->(DbGoTo(Sel->REC))
   
   DEFINE MSDIALOG oDlg TITLE "Efetue as alterações necessárias antes da atualização" ;
      FROM 1,1 TO 46,120
      
      aPos := PosDlg(oDlg)
      oSbox := TScrollBox():New(oDlg,aPos[1],aPos[2],aPos[3]-13,aPos[4],.T.,.F.,.T. )
      
      @ 05,50  SAY "Dicionário Novo :" SIZE 165,07 FONT TFont():New("Verdana",07,14) OF oSbox PIXEL
      @ 05,220 SAY "Dicionário Atual :" SIZE 165,07 FONT TFont():New("Verdana",07,14) OF oSbox PIXEL
      
      For j := 1 To 2

         If j = 1
            cPrefixo := "X"
         Else
            cPrefixo := "Y"
         EndIf
         
         For i := 1 To Len(aCpos)
            bGet := &("{|u| If(pCount() > 0, " + cPrefixo + aCpos[i] + " := u, " +;
                                                 cPrefixo + aCpos[i] + ")}")
            cVar := cPrefixo + aCpos[i]
            
            If j = 1
               &(cVar) := Sel->&(aCpos[i])
            Else
               &(cVar) := (cAlias)->&(aCpos[i])
            EndIf
            
            If j = 1
               oSay                 := TSay():Create(oSBox)
               oSay:cName           := "S" + aCpos[i]
               oSay:cCaption        := aCpos[i]
               oSay:nLeft           := 5
               oSay:nTop            := (i * 30)+3
               oSay:nWidth          := 100
               oSay:nHeight         := 20
               oSay:lShowHint       := .F.
               oSay:lReadOnly       := .F.
               oSay:Align           := 0
               oSay:lVisibleControl := .T.
               oSay:lWordWrap       := .F.
               oSay:lTransparent    := .F.
      
               @ (i * 15)-1 , 200 Button oButton PROMPT '<<<' Size 19,14 Of oSBox Pixel
               oButton:bAction:= &(" {|| X" + aCpos[i] + " := Y" + aCpos[i] + ", B"+aCpos[i]+":cResName := 'BR_VERDE',B"+aCpos[i]+":Refresh() } ")
            Else
               &("B"+aCpos[i]) := TBitmap():New((i * 15)-1,390,7,7,If(&("X" + aCpos[i] + " <> Y" + aCpos[i])  ,"BR_VERMELHO","BR_VERDE") ,,.T.,oSBox,,,,,,,,,.T. )
            EndIf
            
            xx:= TGet():New(i * 15,If(j=1,50,220),bGet, oSbox,150,10,,,,,,,,.T.,,,If(j=1,{||.T.},{||/*.F.*/ .T.}),;
                            .F., .F.,,.F., .F.,,cVar)
            // ** somente leitura
            If j=2
               xx:lReadOnly := .T.
            EndIf
            
            xx:bValid := &("{|| B"+aCpos[i]+":cResName := If( X" + aCpos[i]+ " <> Y" + aCpos[i] + " ,'BR_VERMELHO','BR_VERDE'),B"+aCpos[i]+":Refresh() }")
         Next
      Next
      
      oDlg:lMaximized := .T.
      
   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel) CENTERED
   
   If lOk
      For i := 1 To Len(aCpos)
         Sel->&(aCpos[i]) := &("X"+aCpos[i])
      Next

      If (cAlias)->(DbSeek(Sel->&((cAlias)->(IndexKey()))))
         If (cAlias)->(RecNo()) <> Sel->REC
            MsgInfo("Você alterou um campo chave deste registro, e agora ele está comparado a outro registro do dicionário.","Aviso")
            Sel->REC    := (cAlias)->(RecNo())
            Sel->EXISTE := "S"
            lRepete := .T.
            Break
         EndIf
      ElseIf Sel->EXISTE = "S"
         MsgInfo("Você alterou um campo chave deste registro, e agora ele não está comparado a nenhum outro registro do dicionário.","Aviso")
         Sel->EXISTE := "N"
         Sel->REC := 0
      EndIf
      
      Sel->OK := cMarca
      
   EndIf
   
End Sequence

oMark:oBrowse:Refresh()

Return lOk

/*
Objetivos : cTipo   : "F" - Filtro
                      "P" - Pesquisa
                      "M" - Marcar
Autor     : João Pedro Macimiano Trabbold
*/
*============================*
Static Function SetExpr(cTipo)
*============================*
Local oDlg, bOk, bCancel, cExpr := Space(400)

Begin Sequence

   DEFINE MSDIALOG oDlg TITLE "Digite a expressão para " + If(cTipo="F","filtrar",If(cTipo="M","selecionar","pesquisar")) +;
                              " os registros:" FROM 1,1 To 91,376 Pixel
      
      @ 14,4 to 43,185 Label "Expressão:" PIXEL
      
      @ 25,12 MsGet oExpr Var cExpr Size 150,07 Pixel Of oDlg
      
      bCancel := {|| oDlg:End() }
      bOk     := {|| If(MarkExpr(cExpr,cTipo),oDlg:End(),) }
      
   Activate MsDialog oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel,,) Centered      

End Sequence

Return Nil

/*
Objetivos   : Aplicar o filtro/pesquisa/seleção a partir da expresão cExpr
Autor       : João Pedro Macimiano Trabbold
*/
*===================================*
Static Function MarkExpr(cExpr,cTipo)
*===================================*
Private lRet := .T.

Begin Sequence
   
   cExpr := "Sel->("+cExpr+")"
   bBlockAntigo := ErrorBlock({|e| CheckErro(E) })
   Begin Sequence
      // executa a expressão pra ver se não tem erro.
      &(cExpr)
   End Sequence
   ErrorBlock(bBlockAntigo)
   If !lRet
      Break
   EndIf
   
   If cTipo = "F"
      Sel->(DbSetFilter(&("{|| " + cExpr + "}"),cExpr ))
   ElseIf cTipo = "M"
      Sel->(DbGoTop(),DbEval({|| Sel->OK := cMarca},{|| &(cExpr)} ),DbGoTop())
   Else
      Sel->(DbGoTop())
      While Sel->(!EoF())
         If &(cExpr) ; Exit ; EndIf
         Sel->(DbSkip())
      EndDo
   EndIf

End Sequence
Return lRet

/*
Objetivos     : Tratar um possível erro na expressão digitada na função SetExpr()
Autor         : João Pedro Macimiano Trabbold
*/
*==========================*
Static Function CheckErro(E)
*==========================*
Begin Sequence
   cErro := "A fórmula digitada apresentou o erro abaixo:" + Repl(ENTER,2) + ;
            E:Description                                  + Repl(ENTER,2) + ;
            E:ErrorStack
   U_EECView(cErro,"Erro","Erro:")
   lRet := .F.
End Sequence
Return .T.

/*
Função     : TelaSM0
Objetivos  : Apresentar tela para que o usuário escolha a Empresa/Filial a ser atualizada
Autor      : João Pedro Macimiano Trabbold
*/
*================================*
Static Function TelaSM0(cEmp,cFil)
*================================*
Local lRet := .F., lInverte := .F., cVar := "", aVetor := {}
Local bOk     := {|| cEmp := aVetor[oLbx:nAt,1], cFil := aVetor[oLbx:nAt,2], lRet := .T., oDlg:End() },;
      bCancel := {|| lRet := .F., oDlg:End()}

Begin Sequence
   SM0->(DbGoTop())
   While SM0->(!EoF())
      AAdd(aVetor,{SM0->M0_CODIGO,SM0->M0_CODFIL})
      SM0->(DbSkip())
   EndDo
   
   aBrowse := {{{|| SM0->M0_CODIGO },,"Empresa"},;
               {{|| SM0->M0_CODFIL },,"Filial" }}
               
   DEFINE MSDIALOG oDlg TITLE "Escolha a Empresa/Filial desejada: " FROM 1,1 TO 22,60

      @ 11,01 LISTBOX oLbx VAR cVar FIELDS HEADER ;
         "Empresa", "Filial" ;
         SIZE 288,150 OF oDlg PIXEL ON dblClick(Eval(bOk))

      oLbx:SetArray( aVetor )
      oLbx:bLine := {|| {aVetor[oLbx:nAt,1],;
                         aVetor[oLbx:nAt,2]}}
      
   ACTIVATE MSDIALOG oDlg CENTERED
   
End Sequence

Return lRet

/*
Para tratar qualquer erro de processamento
*/
*=============================*
Static Function TrataErroAtu(e)
*=============================*
Local aDir
Begin Sequence
   cErro := "O sistema executou uma operação ilegal gerando o erro abaixo. "
   If Type("cPasta") = "C" .And. Len((aDir := Directory(cPasta+"\*.*"))) > 0
      cErro += ENTER + "Porém a rotina fez o backup de cada dicionário/tabela alterado na pasta " +;
                       AllTrim(cPasta) + " do servidor."
   EndIf
   cErro += Repl(ENTER,2) + ;
            E:Description                                  + Repl(ENTER,2) + ;
            E:ErrorStack
   
End Sequence

If !U_EECView(cErro,"Erro","Erro:")
   lErro := .T.
   Break
EndIf

If Select("TMPXXX") > 0
   TMPXXX->(DbCloseArea())
EndIf

Return .T.

/*
Apagar a tabela passada por parâmetro, e verificar se apagou mesmo, com tratamento de erros
*/
*==================================*
Static Function ApagaTabela(cTabela)
*==================================*
Local lRet := .F.
Local bBlock := ErrorBlock({|| .T.})

Begin Sequence
   
   While .T.

      // ** Fecha a tabela se estiver aberta
      If Select(cTabela) > 0
         (cTabela)->(DbCloseArea())
      EndIf
      
      Begin Sequence
         // ** apaga a tabela no banco
         TcDelFile(AllTrim(RetSqlName(cTabela)))
      End Sequence
      
      // ** verifica se apagou mesmo
      If !MsFile(AllTrim(RetSqlName(cTabela)),,"TOPCONN")
         lRet := .T.
         Break
      Else
         If !MsgYesNo("A tabela " + AllTrim(RetSqlName(cTabela)) + " não pode ser apagada do banco. Verifique se "+;
                      "não há outro usuário utilizando a mesma. Se desejar continuar a atualização, "+;
                      "clique em 'Sim', e o sistema tentará apagar de novo. Caso contrário, em 'Não'.")

            Break // sai, retornando .F., como erro.
            
         EndIf
      EndIf
      
   EndDo
   
End Sequence

ErrorBlock(bBlock)

Return lRet

/*
Fechar e abrir uma tabela em modo exclusivo, com tratamento de erros
*/
*=================================*
Static Function AbreTabExc(cTabela)
*=================================*
Local lRet := .F.
Local bBlock := ErrorBlock({|| .T.})

Begin Sequence
   
   While .T.
      
      If Select(cTabela) > 0
         // ** fecha a tabela e abre exclusivo
         (cTabela)->(DbCloseArea())
      EndIf
      
      Begin Sequence
         DbUseArea(.T.,"TOPCONN",RetSqlName(cTabela),cTabela,.F.,.F.)
      End Sequence
         
      If Select(cTabela) > 0
         lRet := .T.
         Break
      Else
         If !MsgYesNo("A tabela " + AllTrim(cTabela) + " não pode ser aberta em modo exclusivo. Verifique se "+;
                      "não há outro usuário utilizando a mesma. Se desejar continuar a atualização, "+;
                      "clique em 'Sim', e o sistema tentará abrir de novo. Caso contrário, em 'Não'.")

            Break // sai, retornando .F., como erro.
            
         EndIf
      EndIf
   EndDo
   
End Sequence

ErrorBlock(bBlock)

Return lRet

/*
apagar um arquivo, com tratamento de erros
*/
*=========================================*
Static Function ApagaArquivo(cArquivo,cMsg)
*=========================================*
Local lRet := .T.
Local bBlock := ErrorBlock({|| .T.})
Default cMsg := "Não foi possível apagar o arquivo '" + AllTrim(cArquivo) +;
                "', deve haver algum usuário no sistema ainda. Deseja tentar apagar de novo?"
                
Begin Sequence
   
   While File(cArquivo)
     
      If FErase(cArquivo) == -1
         If !MsgYesNo(cMsg,"Atenção")
            lRet := .F.
            Break
         EndIf
      Else
         Exit
      EndIf
         
   EndDo
   
End Sequence

ErrorBlock(bBlock)

Return lRet

/*
Copia arquivo, com tratamento de erros
*/
*============================================*
Static Function CopiaArquivo(cOrigem,cDestino)
*============================================*
Local lRet := .F., lCopiou, cOriAux, cDestAux, nAt
Local bBlock := ErrorBlock({|| .T.})
                
Begin Sequence
   
   While .T.
      lCopiou := .F.
      Begin Sequence

         AvCpyFile(cOrigem,cDestino)
         lCopiou := File(cDestino)
         
      End Sequence

      Begin Sequence
         If !lCopiou
            nAt := RAt("\",cDestino)
            cDestAux := SubStr(cDestino,1,nAt)
            CPYT2S(cOrigem,cDestAux,.F.) // Terminal To Server
            lCopiou := File(cDestino)
         EndIf
      End Sequence

      Begin Sequence
         If !lCopiou .And. At(":",cDestino) > 0
            nAt := RAt("\",cDestino)
            cDestAux := SubStr(cDestino,1,nAt)
            CPYS2T(cOrigem,cDestAux,.F.) // Server To Terminal
            lCopiou := File(cDestino)
         EndIf
      End Sequence
      
      If lCopiou
         lRet := .T.
         Break
      Else
         If !MsgYesNo("Não foi possível copiar o arquivo '"+AllTrim(cOrigem)+"' para o local '"+;
                      AllTrim(cDestino)+"', talvez porque haja alguma restrição no destino, "+;
                      "ou não haja espaço disponível no servidor. Deseja tentar novamente? "+;
                      "(Você pode tentar copiar manualmente e clicar em 'Sim', que será considerado)","Atenção")
            Break
         EndIf
      EndIf
   EndDo
   
End Sequence

ErrorBlock(bBlock)

Return lRet

/*
Copia arquivo, com tratamento de erros
*/
*======================================*
Static Function AbreEnv(cEmpRpc,cFilRpc)
*======================================*
Local lRet := .F.
Local bBlock

Private cErroAbre := ""

bBlock := ErrorBlock({|E| cErroAbre:= E:Description ,.T.})

Begin Sequence
   
   While .T.

      Begin Sequence
         RpcClearEnv()
         RpcSetType(2)
         RpcSetEnv(cEmpRpc,cFilRpc)
      End Sequence
      
      If Select("SX3") > 0
         // ** Abriu o environment
         lRet := .T.
         Break
      Else
         If !MsgYesNo("Não foi possível copiar o environment da empresa '"+AllTrim(cEmpRpc)+"', "+;
                      " filial '"+cFilRpc+"', foi dado o seguinte erro: "+ ENTER + ENTER + AllTrim(cErroAbra) + ENTER + ENTER+;
                      "Deseja tentar abrir o environment novamente?","Atenção")
            Break
         EndIf
      EndIf
   EndDo
   
End Sequence

ErrorBlock(bBlock)

If SX6->(DbSetOrder(1),DbSeek("  MV_ACENTO"))
   SX6->(RecLock("SX6",.F.),SX6->X6_CONTEUD := "S",MsUnlock())
EndIf
lAcento := .T.

Return lRet

/*
Copia arquivo, com tratamento de erros
*/
*====================================*
Static Function AbreRecriaTab(cTabela)
*====================================*
Local lRet := .F.
Local bBlock

Private cErroAbre := ""

bBlock := ErrorBlock({|E| cErroAbre:= E:Description ,.T.})

Begin Sequence
   
   While .T.

      Begin Sequence
         ChkFile(cTabela)
      End Sequence
      
      If Select(cTabela) > 0
         // ** Abriu a tabela
         lRet := .T.
         Break
      Else
         If !MsgYesNo("Não foi possível recriar a tabela '"+AllTrim(cTabela)+;
                      "', foi dado o seguinte erro: "+ ENTER + ENTER + cErroAbre + ENTER + ENTER+;
                      ". Deseja tentar recriar a tabela novamente?","Atenção")
            Break
         EndIf
      EndIf
   EndDo
   
End Sequence

ErrorBlock(bBlock)

Return lRet

/*
Converter qualquer tipo de valor para string
*/
*===============================*
Static Function ConverteStr(xVal)
*===============================*
Local cStr

Begin Sequence
   If ValType(xVal)="N"
      cStr := Str(xVal)
   ElseIf ValType(xVal)="D"
      cStr := DToC(xVal)
   ElseIf ValType(xVal)="L"
      cStr := If(xVal,".T.",".F.")
   Else
      cStr := xVal
   EndIf
End Sequence

Return AllTrim(cStr)

/*
Tela de configurações iniciais
*/
*=============================*
Static Function Configuracoes()
*=============================*
Local lRet := .F., oDlg, nLinha := 05, nPula := 13, nPula2 := 20, nCol1 := 05, nCol2 := 14, nCol3 := 40
Local nRadio1 := 1
Local bEnable, oPrevia, oGeraDBF

Begin Sequence
   /*
   lBackup := MsgYesNo("Fazer backup dos dicionários que serão alterados? (Nas primeiras execuções deste programa é aconselhável)","Configurações")

   If (lDocumentacao := MsgYesNo("Deseja documentar as alterações?"))
      lExcel := MsgYesNo("Documentar em excel(Sim) ou arquivo texto(não)?")
      lTexto := !lExcel
   EndIf

   lPrevia := .F.
   */
   If lUsuario
      lExcel := .F.
   Else
      lExcel := .T.
   EndIf
   
   lApenasAlterados := .T.
   lBackup := .T.
   
   Define MsDialog oDlg From 1,1 TO 220,300 Title "Configurações" Pixel
     
     AvBorda(oDlg)
     TCheckBox():New(nLinha,nCol1,"",{|u| If(pCount() > 0, lBackup := u, lBackup)},oDlg,100,07,,,,,,,,.T.)
     @ nLinha+2,nCol2 SAY "Faz backup de dicionários alterados" Pixel Of oDlg
     nLinha += nPula

     TCheckBox():New(nLinha,nCol1,"",{|u| If(pCount() > 0, (lExcel := u,Eval(bEnable)), lExcel)},oDlg,100,07,,,,,,,,.T.)
     @ nLinha+2,nCol2 SAY "Documentar as alterações em excel?" Pixel Of oDlg
     nLinha += nPula

     TCheckBox():New(nLinha,nCol1,"",{|u| If(pCount() > 0, (lTexto := u,Eval(bEnable)), lTexto)},oDlg,100,07,,,,,,,,.T.)
     @ nLinha+2,nCol2 SAY "Documentar as alterações em arquivo texto?" Pixel Of oDlg
     nLinha += nPula

     @ nLinha,nCol1 Radio nRadio1 Items " Documentar apenas campos alterados",;
                                        " Documentar todos os campos dos registros alterados"  ;
                                  Size 140,10 Of oDlg Pixel
     nLinha += nPula2

     oPrevia := TCheckBox():New(nLinha,nCol1,"",{|u| If(pCount() > 0, lPrevia := u, lPrevia)},oDlg,100,07,,,,,,,,.T.)
     @ nLinha+2,nCol2 SAY "Apenas prévia?" Pixel Of oDlg
     If lExclusivo
        oPrevia:Disable()
     EndIf
     nLinha += nPula

     oGeraDBF := TCheckBox():New(nLinha,nCol1,"",{|u| If(pCount() > 0, (lGeraDBF := u,Eval(bEnable)), lGeraDBF)},oDlg,100,07,,,,,,,,.T.)
     @ nLinha+2,nCol2 SAY "Gera DBF de Atualização?" Pixel Of oDlg
     nLinha += nPula

     @ nLinha,nCol1 Button "&Ok"     SIZE 35,15 ACTION (lRet := .T., oDlg:End()) Pixel Of oDlg
     @ nLinha,nCol3 Button "&Cancel" SIZE 35,15 ACTION (lRet := .F., oDlg:End()) Pixel Of oDlg
     
     bEnable := {|| If(lExcel .Or. lTexto .Or. lGeraDbf,(If(!lExclusivo,oPrevia:Enable(),Nil)),(oPrevia:Disable(),lPrevia := .F. ) )}
     
   Activate MsDialog oDlg On Init (If(lUsuario,(lRet := .T., oDlg:End()),Nil)) Centered

   If lRet
      If lExcel .Or. lTexto
         lDocumentacao := .T.
      EndIf

      If nRadio1 = 1
         lApenasAlterados := .T.
      ElseIf nRadio1 = 2
         lApenasAlterados := .F.
      EndIf
   EndIf
   
End Sequence

Return lRet

/*
Preencher documentação de texto
*/
*===============================*
Static Function Documenta(cTexto)
*===============================*

FWrite(nCodTxt,cTexto)

Return Nil

*============================*
Static Function AddStruct(a,b)
*============================*
If (nPos:=AScan(a,{|x| AllTrim(x[1])==AllTrim(b[1]) } ))=0
   AAdd(a,b)
Else
   a[nPos]:=b
EndIf
Return 

/*
Funcao      : EECView().
Parametros  : cMsg     - Msg a ser exibida na janela.
              cTitulo  - Titulo da janela.
              cLabel   - Texto para label que envolve o memo.
              aButtons - Array com botões a serem adicionados na enchoice bar
              bValid   - Bloco de código com validação a ser utilizada no botão OK
Retorno     : .t.
Objetivos   : Mostrar tela de msg ao usuário. Disponibilizar integração com o NotePad para que o usuário
              possa salvar/imprimir a msg.
Autor       : Jeferson Barros Jr.
Data/Hora   : 09/04/2004 14:45.
Revisao     :
Obs.        :
*/
*----------------------------------------------------------*
User Function EECView(xMsg,cTitulo,cLabel, aButtons, bValid)
*----------------------------------------------------------*
/*
AMS - 18/11/2004 às 11:08. Atribuição como .F. para variavel lRet para não retornar .T. quando o usuário
                           clicar no botão "X" (padrão do windows) para fechar a janela.
Local lRet := .t.
*/
Local lRet := .F., i, j
Local oDlg, oMemo, oFont := TFont():New("Courier New",09,15)

Local bOk      := {|| If( Eval(bValid), (EECNote(.t.,cMsg),lRet:=.T.,oDlg:End()), )},;
      bCancel  := {|| EECNote(.t.,cMsg),oDlg:End()}

Local cMsg := ""   // JPM - 06/10/05
Local nQuebra := 68// JPM - 06/10/05

Default xMsg     := ""
Default cTitulo  := ""
Default cLabel   := ""
Default aButtons := {}
Default bValid   := {|| .T. }

Begin Sequence
   
   aAdd(aButtons, {"NOTE" ,{||  EECNote(.f.,cMsg,"EECView.txt")},"NotePad",})

   // ** JPM - 06/10/05
   If ValType(xMsg) = "C"
      cMsg := xMsg
   ElseIf ValType(xMsg) = "A"
      For i := 1 To Len(xMsg)
         If xMsg[i][2] // Posição que define se fará quebra de linha
            For j := 1 To MLCount(xMsg[i][1],nQuebra)
               cMsg += MemoLine(xMsg[i][1], nQuebra, j) + ENTER
            Next
         Else
            cMsg += xMsg[i][1]
         EndIf
      Next
   EndIf
   // **

   Define MsDialog oDlg Title cTitulo From 9,0 To 35,85 of oDlg

      @ 15,05 To 190,330 Label cLabel Pixel Of oDlg
      @ 25,10 Get oMemo Var cMsg MEMO HSCROLL FONT oFont Size 315,160 READONLY Of oDlg  Pixel

      oMemo:lWordWrap := .F.
      oMemo:EnableVScroll(.t.)
      oMemo:EnableHScroll(.t.)

   Activate MsDialog oDlg On Init AvButtonBar(oDlg,bOk,bCancel,,,,,,aButtons,) Centered // BHF - 01/08/08 -> Trocado Enchoicebar por AvButtonBar

End Sequence

Return lRet

/*
Funcao      : EECNote().
Parametros  : lApaga -> .t. - Apaga arquivo temporário.
                        .f. - Abre o NotePad com a msg passada como parâmetro.
              cMsg   -> Texto a ser exibido no NotePad.
              cFile  -> Nome do arquivo a ser aberto no NotePad.
Retorno     : .t.
Objetivos   : Auxiliar a função EECView(). Abre o NotePad com o texto passado como parâmetro a fim de proporcionar 
              ao usuário imprimir ou salvar para futura conferência.
              Caso o parâmetro lApaga = .t., apaga o arquivo temporário "EECView.txt".
Autor       : Jeferson Barros Jr.
Data/Hora   : 09/04/2004 14:54.
Revisao     : 
Obs.        :
*/
*----------------------------------------*
Static Function EECNote(lApaga,cMsg,cFile)
*----------------------------------------*
Local lRet:=.t., cDir:=GetWinDir()+"\Temp\",hFile

Default lApaga := .f. // Se .t. apaga arquivo temporário.
Default cFile  := "EECView.txt"

Begin Sequence

   If !lApaga
      hFile := fCreate(cDir+cFile)

      fWrite(hFile,cMsg,Len(cMsg))

      fClose(hFile)

      WinExec("NotePad "+cDir+cFile)
   Else
      If File(cDir+cFile)
         fErase(cDir+cFile)
      EndIf
   EndIf

End Sequence

Return lRet
