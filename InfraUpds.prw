#INCLUDE "Protheus.ch"
#define CRLF CHR(13)+CHR(10)

/*

   Função Generica para Atualizações em Dicionários

*/

User Function InfraUpds(bFunction, lExclusivo, lConfirma) 

Private cArqEmp := "SigaMat.Emp"
Private __cInterNet := Nil

Private cMessage
Private aArqUpd	 := {}
Private aREOPEN	 := {}
Private oMainWnd    

Default bFunction := {|| "Nenhuma atualização foi realizada. Função de atualização não definida."}
Default lExclusivo := .T.
Default lConfirma := .T.

Begin Sequence
   IF Type("lBatchRun") == "L"
      IF lBatchRun // Não Rodar Agora, apenas retornar o code-block para rodar em Batch depois.
         IF Valtype(bFunction) == "B"
            aAdd(aBatchUpd, bFunction)
         Endif

         Break
      Endif   
   Endif
   
   Set Dele On

   IF lConfirma 
      lHistorico 	:= MsgYesNo("Deseja efetuar a atualizacao do Dicionário? Esta rotina deve ser utilizada em modo exclusivo ! Faca um backup dos dicionários e da Base de Dados antes da atualização para eventuais falhas de atualização !", "Atenção")
   Else
      lHistorico := .T.
   Endif
   lEmpenho	:= .F.
   lAtuMnu		:= .F.

   Define Window oMainWnd From 0,0 To 01,30 Title "Atualização do Dicionário" 

   Activate Window oMainWnd MAXIMIZED ;
       On Init If(lHistorico,(Processa({|lEnd| MainProc(@lEnd, bFunction, lExclusivo)},"Processando","Aguarde , processando preparação dos arquivos",.F.), LogInfraUpds() , Final("Atualização efetuada!")),oMainWnd:End())

End Sequence    
	   
Return

Static Function MainProc(lEnd, bFunction, lExclusivo)
Local cTexto    := ''
Local cFile     :=""
Local cMask     := "Arquivos Texto (*.TXT) |*.txt|"
Local nRecno    := 0
Local nI        := 0
Local nX        :=0
Local aRecnoSM0 := {}     
Local lOpen     := .F.          
Local cMsg

Begin Sequence
   ProcRegua(1)
   IncProc("Verificando integridade dos dicionários....")
   If ( lOpen := MyOpenSm0Ex(lExclusivo) )

      dbSelectArea("SM0")
	  dbGotop()
	  While !Eof() 
  	     If Ascan(aRecnoSM0,{ |x| x[2] == M0_CODIGO}) == 0 //--So adiciona no aRecnoSM0 se a empresa for diferente
			Aadd(aRecnoSM0,{Recno(),M0_CODIGO})
		 EndIf			
		 dbSkip()
	  EndDo	
		
	  If lOpen
	     For nI := 1 To Len(aRecnoSM0)
		     SM0->(dbGoto(aRecnoSM0[nI,1]))
			 RpcSetType(2) 
			 RpcSetEnv(SM0->M0_CODIGO, SM0->M0_CODFIL)  //Abre ambiente em rotinas automáticas
			 nModulo := 17 //SIGAEIC
			 lMsFinalAuto := .F.
			 cTexto += Replicate("-",128)+CHR(13)+CHR(10)
			 cTexto += "Empresa : "+SM0->M0_CODIGO+SM0->M0_NOME+CHR(13)+CHR(10)
	  		 ProcRegua(1)
       		 // Atualiza o dicionario de dados.³
			 IncProc("Analisando Dicionario de Dados...")
			 
			 //aArqUpd := {"SW2","SW6","EE7", "EEC"} 
			 __cInterNet := Nil	 
			 cMsg := Eval(bFunction)
			 IF ValType(cMsg) == "C"
			    cTexto += cMsg
			 Endif
			
			 __SetX31Mode(.F.)
			 For nX := 1 To Len(aArqUpd)
			     IncProc("Atualizando estruturas. Aguarde... ["+aArqUpd[nx]+"]")
				 If Select(aArqUpd[nx])>0
					dbSelecTArea(aArqUpd[nx])
					dbCloseArea()
				 EndIf
				 X31UpdTable(aArqUpd[nx])
				 If __GetX31Error()
					Alert(__GetX31Trace())
					Aviso("Atencao!","Ocorreu um erro desconhecido durante a atualizacao da tabela : "+ aArqUpd[nx] + ". Verifique a integridade do dicionario e da tabela.",{"Continuar"},2)
					cTexto += "Ocorreu um erro desconhecido durante a atualizacao da estrutura da tabela : "+aArqUpd[nx] +CHR(13)+CHR(10)
				 EndIf
			 Next nX		
			 RpcClearEnv()
			 If !( lOpen := MyOpenSm0Ex(lExclusivo) )
				Exit 
			 EndIf 
		 Next nI 
		   
		 If lOpen
			
			cTexto := "Log da atualizacao "+CHR(13)+CHR(10)+cTexto
			__cFileLog := MemoWrite(Criatrab(,.f.)+".LOG",cTexto)
			
			Define FONT oFont NAME "Mono AS" Size 5,12   //6,15
			Define MsDialog oDlg Title "Atualizacao concluida." From 3,0 to 340,417 Pixel

			@ 5,5 Get oMemo  Var cTexto MEMO Size 200,145 Of oDlg Pixel
			oMemo:bRClicked := {||AllwaysTrue()}
			oMemo:oFont:=oFont

			Define SButton  From 153,175 Type 1 Action oDlg:End() Enable Of oDlg Pixel //Apaga
			Define SButton  From 153,145 Type 13 Action (cFile:=cGetFile(cMask,""),If(cFile="",.t.,MemoWrite(cFile,cTexto))) ENABLE OF oDlg PIXEL //Salva e Apaga //"Salvar Como..."
			Activate MsDialog oDlg Center	
		 EndIf 
		
	  EndIf
		
   EndIf 	
End Sequence

Return(.T.)           

Static Function LogInfraUpds()
Local hFile      
Local cFile := "infraupds.log"
Local cMsg  := "", cProc

Begin Sequence
   IF File(cFile)
      hFile := FOpen(cFile,2)
      FSeek(hFile,0,2) // Posiciona no final do arquivo
   Else
      hFile := FCreate(cFile)
   Endif                     

   cProc := ProcName(4)
   IF Empty(cProc)
      cProc := "<<null>>"
   Endif
   
   cMsg += "Atualização executada em "+Dtoc(Date())+" às "+Time()+CRLF
   cMsg += "processo responsável pela atualização: "+cProc+CRLF
   
   FWrite(hFile, cMsg, Len(cMsg))
   FClose(hFile)

End Sequence

Return NIL

Static Function MyOpenSM0Ex(lExclusivo)

Local lOpen := .F. 
Local nLoop := 0 

Default lExclusivo := .T.

Begin Sequence
   For nLoop := 1 To 20
       dbUseArea( .T.,, "SIGAMAT.EMP", "SM0", !lExclusivo, .F. ) 
	   If !Empty( Select( "SM0" ) ) 
	      lOpen := .T. 
		  dbSetIndex("SIGAMAT.IND") 
		  Exit	
	   EndIf
	   Sleep( 500 ) 
   Next nLoop 

   If !lOpen
      IF lExclusivo
         Aviso( "Atencao !", "Nao foi possivel a abertura da tabela de empresas de forma exclusiva !", { "Ok" }, 2 ) 
      Else
         Aviso( "Atencao !", "Nao foi possivel a abertura da tabela de empresas !", { "Ok" }, 2 ) 
      Endif
   EndIf                                 
End Sequence

Return( lOpen )

//-------------------------------------------------------------------------
User Function ChangeDic(cDicPar,cKey,cCampo,xValue, bCond)
Local lRet := .f.
Local nOrdem := 1
Local cAlias
Local cDic := AllTrim(Upper(cDicPar)) 
Local lUpd := .f.                        
Local aOrd
Local nPos

Begin Sequence   
   IF Valtype(bCond) <> "B"
      bCond := {|| .t.}
   Endif
 
   IF Select(cDic) <= 0 
      cLog += "Dicionário "+cDic+" não está em uso."+CRLF
      Break
   Endif         
   
   IF cDic == "SX3"
      nOrdem := 2
   Endif
   
   (cDic)->(dbSetOrder(nOrdem))
   IF (cDic)->(dbSeek(cKey))                     
      (cDic)->(RecLock(cDic,.F.))
      IF (cDic)->(Eval(bCond))
         nPos := (cDic)->(FieldPos(cCampo))
         If (cDic)->(FieldGet(nPos)) <> xValue
            (cDic)->(FieldPut(nPos,xValue)) 
            lUpd := .t.
         Endif
      Endif
      (cDic)->(MsUnlock())                       
      
      IF lUpd
         IF Alltrim(Upper(cCampo)) $ "X3_TIPO/X3_TAMANHO/X3_DECIMAL/CHAVE/X2_UNICO/X3_ORDEM"
            IF cDic == "SX3"
               cAlias := u_ExtractAlias(cKey)
            Else
               cAlias := Substr(cKey,1,3)
            Endif
         
            IF !Empty(cAlias)    
               IF Alltrim(Upper(cCampo)) == "X3_ORDEM"
                  ReordenaX3(cAlias)
               Else
                  IF aScan(aArqUpd,{|x| x == cAlias}) == 0
                     aAdd(aArqUpd,cAlias) 
                  Endif
               Endif
            Else
               cLog += "cAlias = empty / chave = "+cKey+" / dic = "+cDic
            Endif
         Elseif Alltrim(Upper(cCampo)) == "XG_SIZE"       
            aOrd := SaveOrd("SX3",3)
            SX3->(dbSeek(SXG->XG_GRUPO))
            While SX3->(!Eof() .And. X3_GRPSXG == SXG->XG_GRUPO)
               IF SX3->X3_TAMANHO <> SXG->XG_SIZE
                  SX3->(RecLock("SX3",.F.))
                  SX3->X3_TAMANHO := SXG->XG_SIZE
                  SX3->(MsUnlock())
                  IF aScan(aArqUpd,{|x| x == SX3->X3_ARQUIVO}) == 0
                     aAdd(aArqUpd,SX3->X3_ARQUIVO) 
                  Endif
               Endif
               SX3->(dbSkip())
            Enddo       
            RestOrd(aOrd,.T.)
         Endif
         lRet := .t.
         cLog += "Chave "+cKey+" do dicionário "+cDic+" campo "+cCampo+" atualizado."+CRLF 
      Endif
   Else
      cLog += "Chave "+cKey+" não encontrada no dicionário "+cDic+" usando a ordem "+Ltrim(Str(nOrdem))+"."+CRLF
   Endif

End Sequence

Return lRet

//-------------------------------------------------------------------------
User Function DelDic(cDicPar,cKey)
Local lRet := .f.
Local nOrdem := 1
Local cAlias
Local cDic := AllTrim(Upper(cDicPar))

Begin Sequence   
   IF Select(cDic) <= 0 
      cLog += "Dicionário "+cDic+" não está em uso."+CRLF
      Break
   Endif         
   
   IF cDic == "SX3"
      nOrdem := 2
   Endif
   
   (cDic)->(dbSetOrder(nOrdem))
   IF (cDic)->(dbSeek(cKey))                     
      IF cDic $ "SX3, SIX, SX2"
         IF cDic <> "SX3" .Or. SX3->X3_CONTEXT <> "V"               
            IF cDic == "SX3"
               cAlias := u_ExtractAlias(cKey)
            Else
               cAlias := Substr(cKey,1,3)
            Endif
         
            IF !Empty(cAlias)    
               IF aScan(aArqUpd,{|x| x == cAlias}) == 0
                  aAdd(aArqUpd,cAlias) 
               Endif
            Else
               cLog += "cAlias = empty / chave = "+cKey+" / dic = "+cDic
            Endif
         Endif                
      Endif
      (cDic)->(RecLock(cDic,.F.))
      (cDic)->(dbDelete())
      (cDic)->(MsUnlock())           

      lRet := .t.
      cLog += "Chave "+cKey+" removida do dicionário "+cDic+"."+CRLF
   //Else
   //   cLog += "Chave "+cKey+" já foi removida do dicionário "+cDic+"."+CRLF
   Endif

End Sequence

Return lRet

//-------------------------------------------------------------------------
User Function AddSXA(cAlias,cOrd,cDsc)
Local lRet := .f.                
Local cPrp := "U"
Local lReplace := .F.

Begin Sequence
   SXA->(dbSetOrder(1))
   IF !SXA->(dbSeek(AvKey(cAlias,"XA_ALIAS")+AvKey(cOrd,"XA_ORDEM"))) 
      SXA->(RecLock("SXA",.T.))
      SXA->XA_ALIAS := cAlias
      SXA->XA_ORDEM := cOrd      
      cLog += "SXA: Alias '"+cAlias+"' ordem '"+cOrd+"' incluido." +CRLF
   Else
      SXA->(RecLock("SXA",.F.))
      lReplace := .T.
   Endif
   
   M->XA_DESCRIC := cDsc
   M->XA_DESCSPA := cDsc
   M->XA_DESCENG := cDsc   
   M->XA_PROPRI  := cPrp
   
   IF MyReplace("M","SXA")
      IF lReplace
         cLog += "SXA: Alias '"+cAlias+"' ordem '"+cOrd+"' atualizado."+CRLF
      Endif
   Endif  
   
   SXA->(MsUnlock())
End Sequence

Return lRet

//-------------------------------------------------------------------------
User Function AddSXB(cAlias, cTipo, cSeq, cCol, cDescr, cContem, cWContem)

Local lRet := .f.                
Local lReplace := .F.

Begin Sequence
   SXB->(dbSetOrder(1))
   IF !SXB->(dbSeek(AvKey(cAlias,"XB_ALIAS")+AvKey(cTipo,"XB_TIPO")+AvKey(cSeq,"XB_SEQ")+AvKey(cCol,"XB_COLUNA"))) 
      SXB->(RecLock("SXB",.T.))
      SXB->XB_ALIAS := cAlias
      SXB->XB_TIPO  := cTipo
      SXB->XB_SEQ   := cSeq
      SXB->XB_COLUNA:= cCol
      
      cLog += "SXB: Alias '"+cAlias+"' tipo '"+cTipo+"' incluido." +CRLF
   Else
      SXB->(RecLock("SXB",.F.))
      lReplace := .T.
   Endif
   
   M->XB_DESCRI  := cDescr
   M->XB_CONTEM  := cContem
   M->XB_WCONTEM := cWContem

   IF MyReplace("M","SXB")
      IF lReplace
         cLog += "SXB: Alias '"+cAlias+"' tipo '"+cTipo+"' atualizado."+CRLF
      Endif
   Endif  
   
   SXB->(MsUnlock())
End Sequence

Return lRet

//-------------------------------------------------------------------------
User Function AddSIX(cInd,cOrd,cChv,cDsc,cF3,cNick,cPsq)
Local lRet := .f.
Local lReplace := .F.

Begin Sequence
   SIX->(dbSetOrder(1))
   IF !SIX->(dbSeek(cInd+cOrd)) 
      SIX->(RecLock("SIX",.T.))
      SIX->INDICE := cInd
      SIX->ORDEM  := cOrd      
      cLog += "SIX: Indice '"+cInd+"' ordem '"+cOrd+"' incluido." +CRLF
   Else
      SIX->(RecLock("SIX",.F.))
      lReplace := .T.
   Endif
   
   M->CHAVE     := cChv
   M->DESCRICAO := cDsc
   M->DESCSPA   := cDsc
   M->DESCENG   := cDsc
   M->PROPRI    := "U"
   M->F3        := cF3
   M->NICKNAME  := cNick
   M->SHOWPESQ  := cPsq

   IF MyReplace("M","SIX")
      IF lReplace
         cLog += "SIX: Indice '"+cInd+"' ordem '"+cOrd+"' atualizado."+CRLF
      Endif
   Endif  
                         
   SIX->(MsUnlock())
   CheckArq(SIX->INDICE)
End SEquence

Return lREt
      
//-------------------------------------------------------------------------
User Function AddSX3(cArq, cOrdPar, cCpo, cTip, nTam, nDec, cTit, cDsc, cPic, cVld, lUsado, cRlc, cF3, cGat, cBrw, cVis, cCtx, lObrigat, cVldU, cBox, cWhen, cIniB, cGSxg, cFld)
Local lRet := .f. 
Local nRecOld       
Local cOrd := cOrdPar
Local lReplace := .F.
                    
Default cDsc := cTit

Begin Sequence   

   SX2->(dbSetOrder(1))
   IF !SX2->(dbSeek(AvKey(cArq,"X2_CHAVE"))) 
      cLog += "Não foi possivel criar o campo '"+cCpo+"' porque a tabela '"+cArq+"' não existe."+CRLF
      Break      
   Endif         
   
   IF Empty(cOrd)
      SX3->(dbSetOrder(2))
      IF SX3->(dbSeek(AvKey(cCpo,"X3_CAMPO")))
         cOrd := SX3->X3_ORDEM
      Else
         SX3->(dbSetOrder(1))
         SX3->(AvSeekLast(cArq)) 
         
         IF SX3->X3_ORDEM == "Z9"
            cOrd := ReordenaX3(cArq)
         Else 
            cOrd := MySoma(SX3->X3_ORDEM)
         Endif
      Endif      
   Endif

   SX3->(dbSetOrder(1))   
   IF SX3->(dbSeek(AvKey(cArq,"X3_ARQUIVO")+AvKey(cOrd,"X3_ORDEM")))   
      IF Alltrim(SX3->X3_CAMPO) <> Alltrim(cCpo)
         nRecOld := SX3->(Recno())
      Endif
   Endif

   SX3->(dbSetOrder(2))
   IF SX3->(dbSeek(AvKey(cCpo,"X3_CAMPO")))
      SX3->(RecLock("SX3",.F.))
      IF cArq+"_FILIAL" <> Alltrim(cCpo)
         lReplace := .T.
      Endif
   Else
      SX3->(RecLock("SX3",.T.))   
      SX3->X3_CAMPO   := cCpo
      SX3->X3_ARQUIVO := cArq
      cLog += "SX3: Arquivo '"+cArq+"' campo '"+cCpo+"' incluido."+CRLF
   Endif                      
   
   IF Valtype(lUsado) == "L"
      cUsado   := IF(lUsado,Replic(chr(128),14)+chr(160),Replic(chr(128),15))
      cReserv  := IF(lUsado,chr(254)+chr(192),Replic(chr(128),2))
   Else
      cUsado := lUsado
      IF Len(cUsado) >= 17 // USADO+RESERV
         cReserv := Substr(cUsado,16,2)
         cUsado  := Substr(cUsado,1,15)
      Else
         cUsado  := Substr(cUsado,1,15)
         cReserv := ""
      Endif
   Endif
   // cObrigat := IF(lObrigat,chr(128),space(1))
   
   IF Valtype(lObrigat) == "L"
      cObrigat := u_ObrgtStr(lObrigat)
   Else
      cObrigat := lObrigat
   Endif
   
   M->X3_ORDEM   := cOrd
   M->X3_TIPO    := cTip
   M->X3_TAMANHO := nTam
   M->X3_DECIMAL := nDec
   M->X3_TITULO  := cTit
   M->X3_TITSPA  := cTit
   M->X3_TITENG  := cTit
   M->X3_DESCRIC := cDsc
   M->X3_DESCSPA := cDsc
   M->X3_DESCENG := cDsc
   M->X3_PICTURE := cPic
   M->X3_VALID   := cVld
   M->X3_USADO   := cUsado
   M->X3_RELACAO := cRlc
   M->X3_F3      := cF3
   M->X3_RESERV  := cReserv
   M->X3_TRIGGER := cGat
   M->X3_BROWSE  := cBrw
   M->X3_VISUAL  := cVis
   M->X3_CONTEXT := cCtx
   M->X3_OBRIGAT := cObrigat
   M->X3_VLDUSER := cVldU
   M->X3_CBOX    := cBox
   M->X3_CBOXSPA := cBox
   M->X3_CBOXENG := cBox
   M->X3_WHEN    := cWhen
   M->X3_INIBRW  := cIniB
   M->X3_GRPSXG  := cGSxg
   M->X3_FOLDER  := cFld 
   
   M->X3_PROPRI  := "U"   
   M->X3_ORTOGRA := "N"
   M->X3_IDXFLD  := "N"  

   IF MyReplace("M","SX3")
      IF lReplace
         cLog += "SX3: Arquivo '"+cArq+"' campo '"+cCpo+"' atualizado."+CRLF
      Endif
   Endif  
   
   SX3->(MsUnlock())         
   CheckArq(SX3->X3_ARQUIVO)
   
   PutHelp("P"+cCpo,{cDsc},{cDsc},{cDsc},.T.)
   
   IF Empty(nRecOld)
      Break
   Endif        
   
   ReordenaX3(cArq)
      
   lRet := .t.
End Sequence

Return lRet

//-------------------------------------------------------------------------
User Function SetUsd(cCampo,lUsado)
Local lRet := .f.
Local aOrd := SaveOrd("SX3",2)      
Local cUsado, cReserv

Begin Sequence
   Default lUsado := .t.
   
   IF !SX3->(dbSeek(cCampo))
      IF Type("cLog") == "C"
         cLog += "O campo "+cCampo+" não existe no dicionário SX3. O campo não foi colocado em uso."+CRLF
      Endif
      Break
   Endif 
   
   cUsado   := IF(lUsado,Replic(chr(128),14)+chr(160),Replic(chr(128),15))
   cReserv  := IF(lUsado,chr(254)+chr(192),Replic(chr(128),2))
   
   SX3->(RecLock("SX3",.F.))
   M->X3_USADO  := cUsado
   M->X3_RESERV := cReserv
   
   IF MyReplace("M","SX3")
      IF Type("cLog") == "C"
         cLog += "SX3: Arquivo 'SX3"+SM0->M0_CODIGO+"0' campo '"+cCampo+"' atualizado."+CRLF
      Endif
   Endif  
   
   SX3->(MsUnlock())
   lRet := .t.
End Sequence                 

RestOrd(aOrd,.t.)

Return lRet

//-------------------------------------------------------------------------
User Function ObrgtStr(lObrigat)

Default lObrigat := .t.

Return IF(lObrigat,chr(128),space(1))

//-------------------------------------------------------------------------
Static Function MySoma(cOldVal)
Local cNext
Local nVal

Begin Sequence
   IF cOldVal > "Z9"
      IF cOldVal == "ZZ"
         cNext := "ZZ"
      Else 
         cNext := Soma1(cOldVal)      
      Endif
      Break
   Endif

   nVal := Val(cOldVal)
   IF nVal == 0 .And. Len(Alltrim(cOldVal)) >= 2 
      nVal := Val(Substr(cOldVal,2,1))+1
      IF nVal < 10 
         cNext := Substr(cOldVal,1,1)+Str(nVal,1)
      Else
         cNext := Chr(Asc(Substr(cOldVal,1,1))+1)+"0"
      Endif      
   Else
      nVal := nVal + 1
      IF nVal == 100
         cNext := "A0"
      Else 
         cNext := StrZero(nVAl,2)
      Endif
   Endif
      
End Sequence

Return cNext

//-------------------------------------------------------------------------
Static Function ReordenaX3(cAlias)

Local aRecsX3 := {}
Local cNext   := "01"     
lOCAL I

Begin Sequence            
   
   SX3->(dbSetOrder(1))
   SX3->(dbSeek(cAlias))   
   
   While SX3->(!Eof() .And. X3_ARQUIVO == cAlias)
      aAdd(aRecsX3,SX3->(Recno()))
      SX3->(dbSkip())
   Enddo   
   
   For i:=1 To Len(aRecsX3)                        
      SX3->(dbGoTo(aRecsX3[i]))
      SX3->(RecLock("SX3",.F.))
      SX3->X3_ORDEM := cNext
      SX3->(MsUnlock())         
      
      IF cNext == "Z9"
         cNext := "ZA"
      Elseif cNext < "Z9"
         cNext := MySoma(cNext)
      Else
         IF cNext < "ZZ"
            cNext := Soma1(cNext)
         Endif
      Endif      
   Next i
End Sequence

Return cNext

//-------------------------------------------------------------------------
User Function AddSX2(cArq, cNome, cRotina, cCompart, cUnico)
Local lRet := .f.    
Local lReplace := .F.
Local cCompartUn, cCompartEmp

Begin Sequence
   SX2->(dbSetOrder(1))
   IF SX2->(dbSeek(AvKey(cArq,"X2_CHAVE")))
      SX2->(RecLock("SX2",.F.))           
      lReplace := .T.
   Else
      SX2->(RecLock("SX2",.T.))   
      SX2->X2_CHAVE  := cArq
      cLog += "SX2: Arquivo '"+cArq+"' incluido."+CRLF
      SX2->X2_ARQUIVO := cArq+SM0->M0_CODIGO+"0"
   Endif                      
   
   IF Len(cCompart) >= 3
      cCompartEmp := Substr(cCompart,1,1)
      cCompartUn  := Substr(cCompart,2,1)
      cCompart    := Substr(cCompart,3,1)
   Elseif Len(cCompart) = 2
      cCompartEmp := Substr(cCompart,1,1)
      cCompartUn  := Substr(cCompart,2,1)
      cCompart    := Substr(cCompart,2,1)
   Elseif Len(cCompart) = 1
      cCompartEmp := Substr(cCompart,1,1)
      cCompartUn  := Substr(cCompart,1,1)
      cCompart    := Substr(cCompart,1,1)
   Else
      cCompart := "E"
   Endif
   
   M->X2_NOME   := cNome
   M->X2_ROTINA := cRotina
   M->X2_MODO   := cCompart
   M->X2_MODOUN := cCompartUn
   M->X2_MODOEMP:= cCompartEmp
   
   M->X2_UNICO  := cUnico     

   IF MyReplace("M","SX2")
      IF lReplace
         cLog += "SX2: Arquivo '"+cArq+"' atualizado."+CRLF
      Endif
   Endif  
      
   SX2->(MsUnlock())
   
   CheckArq(SX2->X2_CHAVE)
   lRet := .t.
End Sequence

Return lRet

//-------------------------------------------------------------------------
User Function AddSX5(cFil, cTab, cChv, cDsc, cDscSpa, cDscEng)
Local lRet := .f.    
Local lReplace := .F.

Default cDscSpa := cDsc
Default cDscEng := cDsc

Begin Sequence 
   SX5->(dbSetOrder(1))
   IF SX5->(dbSeek(AvKey(cFil,"X5_FILIAL")+AvKey(cTab,"X5_TABELA")+Avkey(cChv,"X5_DESCRI")))
      SX5->(RecLock("SX5",.F.))
      lReplace := .T.
   Else
      SX5->(RecLock("SX5",.T.))   
      SX5->X5_FILIAL := cFil
      SX5->X5_TABELA := cTab
      SX5->X5_CHAVE  := cChv
      cLog += "SX5: Tabela '"+cTab+"' chave '"+cChv+"' incluido na filial '"+cFil+"'."+CRLF
   Endif                      
   
   M->X5_DESCRI  := cDsc
   M->X5_DESCSPA := cDscSpa 
   M->X5_DESCENG := cDscEng

   IF MyReplace("M","SX5")
      IF lReplace
         cLog += "SX5: Tabela '"+cTab+"' chave '"+cChv+"' atualizado na filial '"+cFil+"'."+CRLF
      Endif
   Endif  

   SX5->(MsUnlock())
   lRet := .t.
End Sequence

Return lRet

//-------------------------------------------------------------------------
User Function AddSX6(cFill, cVar, cTipo, cDescric, cDesc1, cDesc2, cConteud)
Local lRet := .f.
Local lReplace := .F.

Default cFill  := xFilial("SX6")
Default cDesc1 := ""
Default cDesc2 := ""

Begin Sequence
   IF Empty(cVar)
      cLog += "SX6: Parametro vazio não atualizado."+CRLF
      Break
   Endif

   IF Valtype(cConteud) <> "C"
      cLog += "SX6: Parametro '"+cVar+"' não atualizado, o conteudo deve ser do tipo Caractere."+CRLF
      Break
   Endif

   SX6->(dbSetOrder(1))   
   IF SX6->(dbSeek(cFill+AvKey(cVar,"X6_VAR")))
      SX6->(RecLock("SX6",.F.))
      lReplace := .T.
   Else
      SX6->(RecLock("SX6",.T.))   
      SX6->X6_FIL     := cFill
      SX6->X6_VAR     := cVar
      cLog += "SX6: Parametro '"+cVar+"' incluido."+CRLF
   Endif                      
   
   M->X6_TIPO    := cTipo 
   M->X6_DESCRIC := cDescric
   M->X6_DSCSPA  := cDescric
   M->X6_DSCENG  := cDescric
   M->X6_DESC1   := cDesc1
   M->X6_DSCSPA1 := cDesc1
   M->X6_DSCENG1 := cDesc1
   M->X6_DESC2   := cDesc2
   M->X6_DSCSPA2 := cDesc2
   M->X6_DSCENG2 := cDesc2
   M->X6_CONTEUD := cConteud
   M->X6_CONTSPA := cConteud
   M->X6_CONTENG := cConteud
   M->X6_PROPRI  := "U"
   M->X6_PYME    := "N"

   IF MyReplace("M","SX6")
      IF lReplace
         cLog += "SX6: Parametro '"+cVar+"' atualizado."+CRLF
      Endif
   Endif  
   
   SX6->(MsUnlock())
   lRet := .t.
End Sequence

Return lRet

//-------------------------------------------------------------------------
User Function AddSX7(cCampo, cSequenc, cRegra, cCDomin, cTipo, cSeek, cAlias, nOrdem, cChave, cCondic)
Local lRet := .f.
Local lFound := .f.  
lOCAL lReplace := .F.     

Default cSeek   := ""
Default cAlias  := ""
Default cRegra  := ""

Begin Sequence
   IF Empty(cCampo)
      cLog += "SX7: Campo '"+cCampo+"' não atualizado."+CRLF
      Break
   Endif
  
   /* 
   IF Empty(cCDomin)
      cLog += "SX7: Campo '"+cCampo+"' não atualizado, contra-dominio não informado."+CRLF
      Break
   Endif
   */
      
   IF Empty(cRegra)
      cLog += "SX7: Campo '"+cCampo+"' não atualizado, regra não informada."+CRLF
      Break
   Endif

   SX7->(dbSetOrder(1))
   IF Empty(cSequenc)
      IF SX7->(dbSeek(AvKey(cCampo,"X7_CAMPO")))
         lFound := .f.
         While SX7->(!Eof() .And. X7_CAMPO == AvKey(cCampo,"X7_CAMPO"))        
            cSequenc := SX7->X7_SEQUENC
            IF SX7->X7_CDOMIN == AvKey(cCDomin,"X7_CDOMIN") 
               lFound := .t.
               exit
            Endif
            SX7->(dbSkip())
         Enddo             
         IF !lFound
            cSequenc := StrZero(Val(cSequenc)+1,Len(SX7->X7_SEQUENC))
         Endif
      Else
         cSequenc := StrZero(1,Len(SX7->X7_SEQUENC))
      Endif
   Endif
 
   IF SX7->(dbSeek(AvKey(cCampo,"X7_CAMPO")+AvKey(cSequenc,"X7_SEQUENC")))
      SX7->(RecLock("SX7",.F.))
      lReplace := .T.
      u_ChangeDic("SX3",cCampo, "X3_TRIGGER", "S")
   Else
      SX7->(RecLock("SX7",.T.))   
      SX7->X7_CAMPO   := cCampo
      SX7->X7_SEQUENC := cSequenc
      cLog += "SX7: Campo '"+cCampo+"' contra-dominio '"+cCDomin+"' incluido."+CRLF
      u_ChangeDic("SX3",cCampo, "X3_TRIGGER", "S")
   Endif                      
   
   M->X7_REGRA  := cRegra
   M->X7_CDOMIN := cCDomin
   M->X7_TIPO   := cTipo
   M->X7_SEEK   := cSeek
   M->X7_ALIAS  := cAlias
   M->X7_ORDEM  := nOrdem
   M->X7_CHAVE  := cChave
   M->X7_CONDIC := cCondic
   M->X7_PROPRI := "U"

   IF MyReplace("M","SX7")
      IF lReplace
         cLog += "SX7: Campo '"+cCampo+"' contra-dominio '"+cCDomin+"' atualizado."+CRLF
      Endif
   Endif  
   
   SX7->(MsUnlock())
   lRet := .t.
End Sequence

Return lRet

//------------------------------------------------------------------------------------
Static Function CheckArq(cArq)

IF aScan(aArqUpd, {|x| x==cArq}) == 0
   aAdd(aArqUpd,cArq)
Endif

Return

//-------------------------------------------------------------------------
User Function DelSXB(cAlias)
Local lRet := .f.
Local aOrdXB := SaveOrd("SXB",1)

Begin Sequence
   IF ! SXB->(dbSeek(AvKey(cAlias,"XB_ALIAS")))
      IF Type("cLog") == "C"
         cLog += "A consulta "+cAlias+" não foi removida."+CRLF
      Endif                                         
   Endif
   
   While SXB->(!Eof() .And. XB_ALIAS == AvKey(cAlias,"XB_ALIAS"))
      SXB->(RecLock("SXB",.F.))
      SXB->(dbDelete())
      SXB->(MsUnlock())
      lRet := .t.
      SXB->(dbSkip())
   Enddo

   IF lRet .And. Type("cLog") == "C"
      cLog += "A consulta "+cAlias+" foi removida."+CRLF
   Endif

End Sequence

RestOrd(aOrdXB)

Return lRet

//-------------------------------------------------------------------------
User Function BatchUpd(aUpds)

Local bBatch
Local i, xAux

Private lBatchRun := .t. 
Private aBatchUpd := {}

Begin Sequence
   For i:=1 To Len(aUpds)
       xAux := "{|| "+aUpds[i]+" }"
       xAux := &xAux
       IF Valtype(xAux) == "B"
          Eval(xAux)
       Endif
   Next i
   
   IF !Empty(aBatchUpd)
      bBatch := {|| xAux := "", aEval(aBatchUpd, {|x, y| y := Eval(x), xAux += if(Valtype(y) == "C",y,"") }), xAux } 
   
      lBatchRun := .f.   
      u_InfraUpds(bBatch)
   Endif
End Sequence

Return NIL

//---------------------------------------------------------------------------
User Function ExtractAlias(cCampo)
Local cAlias := ""
Local nPos := At("_",cCampo)

Begin Sequence
   IF (nPos == 0)
      Break
   Endif
   
   cAlias := AllTrim(Substr(cCampo,1,nPos-1))
   IF Len(cAlias) <> 3
      cAlias := "S"+cAlias
   Endif 
   
   IF Len(cAlias) <> 3
      cAlias := ""
      Break
   Endif
   
End Sequence

Return cAlias

User Function SV_Cad(cAlias)
Return AxCadastro(cAlias)

//--------------------------------------------------------------------------------------
Static Function MyReplace(cOrigem, cDestino)

Local lChanged := .F.
Local i, nFieldCount
Local cFieldO, bFieldO
Local cFieldD, bFieldD
Local cPrefixoD := Upper(IF(Left(cDestino,1) == "S",Right(cDestino,2),Right(cDestino,3)))

Local xValue
Local nTam

Default cOrigem  := "M"

Begin Sequence

   cOrigem  := Upper(AllTrim(cOrigem))
   cDestino := Upper(AllTrim(cDestino))
      
   IF cOrigem != "M"
      nFieldCount := (cOrigem)->(FCount())
   Else
      nFieldCount := (cDestino)->(FCount())
   Endif

   For i:=1 To nFieldCount
   
      cFieldO := cFieldD := bFieldO := bFieldD := Nil
      
      IF cOrigem != "M"
         cFieldO := (cOrigem)->(FieldName(i))
      Else
         cFieldD := (cDestino)->(FieldName(i))
      Endif
      
      IF Empty(cFieldO) .And. Empty(cFieldD)
         Loop
      Endif
      
      IF Empty(cFieldO)
         bFieldO := MemVarBlock(cFieldD)
         IF TYPE("M->"+cFieldD) = "U"
            Loop
         Endif
      Else
         bFieldO := FieldWBlock(cFieldO,Select(cOrigem))
      Endif
      
      IF Empty(cFieldD)
         IF cDestino == "M"
            bFieldD := MemVarBlock(cFieldO)
            IF ValType(bFieldD) != "B"
               Loop
            Endif
         Else
            IF (cDestino)->(FieldPos(cFieldO)) == 0
               Loop
            Else
               bFieldD := FieldWBlock(cFieldO,Select(cDestino))
            Endif
         Endif
      Else
         bFieldD := FieldWBlock(cFieldD,Select(cDestino))
      Endif
      
      IF Empty(cFieldD)
         cFieldD := cFieldO
      Endif
      
      If cPrefixoD+"_FILIAL" == Upper(AllTrim(cFieldD))
         Loop
      EndIf
      
      xValue := Eval(bFieldO)
      IF Valtype(xValue) == "C"
         nTam := Len(Eval(bFieldD))
         Eval(bFieldO, Substr(xValue+Space(nTam),1,nTam) )
      Endif
      
      IF Eval(bFieldD) <> Eval(bFieldO)
         Eval(bFieldD,Eval(bFieldO))
         lChanged := .T.
      Endif
   Next i

End Sequence
   
Return lChanged
