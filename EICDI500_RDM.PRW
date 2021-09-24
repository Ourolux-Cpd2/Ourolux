#include "RWMAKE.CH"
#Include "Average.ch"
#Include "DbInfo.ch"

*----------------------*
USER FUNCTION EICDI500()
*----------------------*
Local   cQuery      := ""
Local   lProces     := .T.
Local   cDespFrete  := SuperGetMV("ES_DESFRET",.T.,"416/417/426/411")
Local   aDesFrete   := StrTokArr(cDespFrete,"/")
Local   aPosFrete   := 0
Local   cDespFCIF   := SuperGetMV("ES_DESFCIF",.T.,"416/411")
Local   aDesFCIF    := StrTokArr(cDespFCIF,"/")
Local   aPosFCIF    := 0
Local   cNGFrete    := SuperGetMV("ES_NGERFRE",.T.,"437")
Local   aItens      := {}
Local   nNumDesp    := Len(aDesFrete)
Local   nNumDCIF    := Len(aDesFCIF)
Local   cItem       := "0000"
Local   aArea       := Nil
Local   cFunName    := ProcName(0)
Local   cNumPed     := ""
Local   lAtvEIC     := SuperGetMV("ES_ATVEICD",.T.,.F.)
Local   dDtVenc     := CTOD("  /  /    ")
Local   cCentoC     := ""
Local   nOk         := 0
Local   nQtdPC      := 0
Local   nVlUnit     := 0
Local   cDeptoEIC	  := SuperGetMV("ES_DPTOEIC",.F.,"000000027")
Local   cDptoImp	  := SuperGetMV("ES_DPTOIMP",.F.,"") //000000035
Local   cDespImp	  := SuperGetMV("ES_DESPIMP",.F.,"") //201/202/203/204/205/405/415
Local   cDespQtd	  := SuperGetMV("ES_DESQTD",.F.,"402|406|421|411|416|417|426")  //402|406|421 - 402|406|421|411|416|417|426
Private lMSHelpAuto := .T.
Private lMsErroAuto := .F.
Private cControle   := ""

DO CASE
   CASE PARAMIXB == "POS_GRAVA_TUDO"
   
      If SWD->WD_DESPESA == "102" .AND. (Empty(SWD->WD_XVENCTO) .OR. Empty(SWD->WD_XCC)) .AND. Empty(SWD->WD_XPEDCOM)
         If Empty(SWD->WD_XVENCTO)
            dDtVenc := CTOD("  /  /    ")
         Else
            dDtVenc := SWD->WD_XVENCTO
         EndIF

         If Empty(SWD->WD_XCC)
            cCentoC := Space(TAMSX3("WD_XCC")[1])
         Else
            cCentoC := SWD->WD_XCC
         EndIF

         DEFINE DIALOG oDlg TITLE "Dados para Despesa de Frete" FROM 000,000 TO 150,250 PIXEL
         
         @ 15,10  say "Vencimento:" of oDlg Pixel
         @ 14,55 MsGet oGet Var dDtVenc  of oDlg SIZE 50,10 Pixel //
         @ 35,10  say "Centro de Custo:" of oDlg Pixel
         @ 34,55 MsGet oGet Var cCentoC  of oDlg F3 "CTT" Picture "@!" VALID VldDados("CTT",cCentoC)  SIZE 50,10 Pixel //
         
         @ 55,10 BUTTON 'Salvar' SIZE 50,11 PIXEL OF oDlg ACTION {|| Iif(!Empty(dDtVenc) .AND. !Empty(cCentoC),nOk := 1,), Iif(nOk == 1,oDlg:End(),)}
         
         ACTIVATE DIALOG oDlg CENTERED

         If nOk == 1
            Reclock("SWD",.F.)
            SWD->WD_XVENCTO := dDtVenc
            SWD->WD_XCC     := cCentoC
            SWD->(MsUnlock())
         EndIf
      EndIf

      SW6->W6_HAWB
      SWD->(DBSETORDER(1))
      if SWD->(dbseek(xfilial("SWD")+SW6->W6_HAWB+"102")) .AND. !Empty(SWD->WD_CTRFIN1)
         U_xdelPRE(SW6->W6_HAWB)
      endif 
   CASE PARAMIXB == "DESPESA"
      If GetAdvFVal( "SYT","YT_X_FILIA",XFILIAL("SYT") + SW6->W6_IMPORT,1 ) <> cFilAnt
         Alert("A T E N « √ O" +CRLF+CRLF+ "Verifique se a filial logada È a mesma filial do processo!!!" +CRLF+CRLF+ "PE: EICDI500_RDM - DESPESA")
         lSair := .T.
      EndIf
   CASE PARAMIXB == "AROTINA"
         aAdd(aRotina,{"Ctas a Pagar","u_SV_EICCP('DI')",0,2})
   // Inicio - Projeto Jonato - 23/06/2017
   CASE PARAMIXB == "ANT_VALID_SW6"
        if cNomeCampo == 'TSALDO_Q'
           if ! u_SvValQtd(M->TSALDO_Q,"SW6")
              lSair:=.T.                       
              lRet:=.F.
           endif
        endif
   CASE PARAMIXB == "BROWSE_SELECIONA"
        AADD(aBotaoItem,{"CARGA"      ,{|| u_SvCalCub("SW6")  },"Calcula Cubagem","Calcula Cubagem"})
   CASE PARAMIXB == "STRU_WORKS"
		aadd(aSemSX3SW7, {"WK_XQE1"    ,"N",AVSX3("W7_QTDE" ,3),AVSX3("W7_QTDE" ,4)} )
		aadd(aSemSX3SW7, {"WK_XQTDEM1" ,"N",AVSX3("W7_QTDE" ,3),AVSX3("W7_QTDE" ,4)} )
		aadd(aSemSX3SW7, {"WK_XCUBAGE" ,"N",AVSX3("W7_QTDE" ,3),AVSX3("W7_QTDE" ,4)} )
   CASE PARAMIXB == "GRV_WORK_ITEM"
        Work->WK_XQE1:= SW7->W7_XQE1
        Work->WK_XQTDEM1:= SW7->W7_XQTDEM1
        Work->WK_XCUBAGE:= SW7->W7_XCUBAGE    
	CASE PARAMIXB == "GRAVA_INCLUI_SW7" .OR. PARAMIXB == "GRAVA_ALTERA_SW7"
        SW7->W7_XQE1    := Work->WK_XQE1
        SW7->W7_XQTDEM1 := Work->WK_XQTDEM1
        SW7->W7_XCUBAGE := Work->WK_XCUBAGE
	// Inicio - Claudino - I1805-177 - 29/06/2018
	CASE PARAMIXB == "ANTES_CONF_CAPA"   
		
		If M->W6_CONTA20 == 0 .AND. M->W6_CONTA40 == 0 .AND. M->W6_CON40HC == 0
			lSair:= .T.
			ApMsgStop("Os campos Conteiners ( 20', 40' e 40'HC ) est„o em branco, favor preencher um desses campos!",'EICCV100')
		EndIf  
   CASE PARAMIXB == "INCLUI_DESP"
      If lAtvEIC
         If !(SWD->WD_DESPESA $ cNGFrete)
            dbSelectArea("SW2")
            SW2->(dbSetOrder(1))
            SW2->(dbSeek(xFilial("SW2")+SW6->W6_PO_NUM))
            If SW2->W2_INCOTER <> "CIF"
               If !(SWD->WD_DESPESA $ cDespFrete) 
                  aArea := SWD->(GetArea())
                  dbSelectArea("SB1")
                  If SB1->(dbseek(xFilial("SB1")+"EIC"+SWD->WD_DESPESA))
                     If (SWD->WD_DESPESA $ cDespImp)
                        cDeptoEIC := cDptoImp
                     EndIf
                     _aCabPC	:=	{{"C7_FILIAL" ,GetAdvFVal( "SYT","YT_X_FILIA",XFILIAL("SYT") + SW6->W6_IMPORT,1 )	,Nil},;
                                 {"C7_EMISSAO" ,dDataBase                                                            ,Nil},; 
                                 {"C7_FORNECE" ,SWD->WD_FORN                                                         ,Nil},;
                                 {"C7_LOJA"	  ,SWD->WD_LOJA                                                         ,Nil},;
                                 {"C7_XDEPART" ,cDeptoEIC	                                                         ,Nil},;
                                 {"C7_COND"	  ,"005"                                                                ,Nil},;
                                 {"C7_CONTATO" ,"IMPORTACOES"                                                        ,Nil},;
                                 {"C7_NUMIMP"  ,SW6->W6_PO_NUM                                                       ,Nil},;
                                 {"C7_ORIGEM"  ,"EICPO400"	                                                         ,Nil}}
                     
                     If SWD->WD_DESPESA $ cDespQtd

                        nQtdPC  := (SW6->W6_CONTA20 + SW6->W6_CONTA40 + SW6->W6_CON40HC + SW6->W6_OUTROS)
                        nVlUnit := Round((SWD->WD_VALOR_R / nQtdPC),4)
                     
                        If nQtdPC == 0
                           Alert("Quantidade de Container n„o foi preenchido, pedido de compra n„o sera gerado.")
                           Return
                        EndIf
                     
                        _aItemPC :=	{{"C7_ITEM"	   ,"0001"	              ,Nil},;
                                    {"C7_PRODUTO"  ,"EIC"+SWD->WD_DESPESA ,Nil},;
                                    {"C7_UM"	      ,SB1->B1_UM		        ,Nil},;   
                                    {"C7_QUANT"	   ,nQtdPC          	     ,Nil},;
                                    {"C7_PRECO"	   ,nVlUnit	              ,Nil},;
                                    {"C7_CC"	      ,SWD->WD_XCC           ,Nil},;     
                                    {"C7_XHAWB"    ,Alltrim(SWD->WD_HAWB) ,Nil},;
                                    {"C7_NUMIMP"   ,SW6->W6_PO_NUM        ,Nil},;
                                    {"C7_OBS"	   ,SWD->WD_XOBS	        ,Nil}}
                     Else
                        _aItemPC :=	{{"C7_ITEM"	   ,"0001"	               ,Nil},;
                                    {"C7_PRODUTO"  ,"EIC"+SWD->WD_DESPESA  ,Nil},;
                                    {"C7_UM"	      ,SB1->B1_UM		         ,Nil},;   
                                    {"C7_QUANT"	   ,1             	      ,Nil},;
                                    {"C7_PRECO"	   ,SWD->WD_VALOR_R	      ,Nil},;
                                    {"C7_CC"	      ,SWD->WD_XCC            ,Nil},;     
                                    {"C7_XHAWB"    ,Alltrim(SWD->WD_HAWB)  ,Nil},;
                                    {"C7_NUMIMP"   ,SW6->W6_PO_NUM         ,Nil},;
                                    {"C7_OBS"	   ,SWD->WD_XOBS	         ,Nil}}
                     EndIf

                     Processa( {|| MsExecAuto( {|v,x,y,z| MATA120(v,x,y,z)},1,_aCabPC,{_aItemPC},3)  }, "Aguarde...", "Gerando pedido de compras...",.F.)
                     
                     RestArea(aArea)
                     
                     If lMsErroAuto
                        cDirArq := "\"
                        cNomArq := "\"+cFunName+"-"+DToS(Date())+"-"+StrTran(Time(),":","")+".log"
                                          
                        cErro := VerErro(MostraErro(cDirArq,cNomArq),cDirArq,cNomArq)

                        FErase(cDirArq+cNomArq)

                        Alert("A T E N « √ O !!!"+CRLF+CRLF+"Pedido n„o gerado"+CRLF+CRLF+cErro)

                        ProcLogAtu("ERRO","EICDI500 - Pedido de compra nao incluido - Processo: " + Alltrim(SW6->W6_HAWB) + " Despesa: " + Alltrim(SWD->WD_DESPESA), cErro, "EICDESPESA" )
                     else
                        M->WD_XPEDCOM := SC7->C7_NUM
                        If RecLock("SWD",.F.)
                           SWD->WD_XPEDCOM := SC7->C7_NUM
                           SWD->WD_XFILPC   := SC7->C7_FILIAL
                           SWD->(MsUnlock())
                        EndIf
                        If RecLock("SC7",.F.)
                           SC7->C7_ORIGEM := "EICPO400"
                           SC7->C7_NUMIMP := SW6->W6_PO_NUM
                           SC7->(MsUnlock())
                        EndIf
                     EndIf
                  else
                     alert("Pedido de compra n„o sera gerado, produto EIC" + SWD->WD_DESPESA + " n„o cadastrado no sistema!")
                  EndIf
               else
                  aPosFrete := aScan(aDesFrete, {|x| Alltrim(x) == SWD->WD_DESPESA})

                  If aPosFrete <> 0
                     aDel(aDesFrete,aPosFrete)
                     aSize(aDesFrete,nNumDesp-1)
                     nNumDesp := Len(aDesFrete)
                  EndIf

                  cQuery := " SELECT COUNT(DISTINCT(WD_DESPESA)) AS TOT_DESPESA FROM " + RetSqlName("SWD")
                  cQuery += " WHERE WD_FILIAL = '"+xFilial("SWD")+"' "
                  cQuery += " AND WD_HAWB = '"+Alltrim(SWD->WD_HAWB)+"' "
                  cQuery += " AND WD_DESPESA IN " + FormatIn(cDespFrete,"/")
                  cQuery += " AND WD_DESPESA <> '"+Alltrim(SWD->WD_DESPESA)+"' "
                  cQuery += " AND D_E_L_E_T_ = '' "

                  If Select("DESFRET") > 0
                     DESFRET->(dbCloseArea())
                  EndIf

                  DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'DESFRET', .T., .F.)

                  If DESFRET->(!EOF())
                     If DESFRET->TOT_DESPESA == nNumDesp
                        cQuery := " SELECT WD_DESPESA, WD_FORN, WD_LOJA, WD_VALOR_R, WD_XCC, WD_XOBS, R_E_C_N_O_ FROM " + RetSqlName("SWD")
                        cQuery += " WHERE WD_FILIAL = '"+xFilial("SWD")+"' "
                        cQuery += " AND WD_HAWB = '"+Alltrim(SWD->WD_HAWB)+"' "
                        cQuery += " AND WD_DESPESA IN " + FormatIn(cDespFrete,"/")
                        cQuery += " AND D_E_L_E_T_ = '' "
                        cQuery += " ORDER BY WD_XCC DESC "

                        If Select("AGLWD") > 0
                           AGLWD->(dbCloseArea())
                        EndIf

                        DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'AGLWD', .T., .F.)
                        
                        dbSelectArea("SB1")

                        While AGLWD->(!EOF())
                           If !SB1->(dbseek(xFilial("SB1")+"EIC"+AGLWD->WD_DESPESA))
                              lProces := .F.
                              Alert("Produto n„o cadastrado")
                              Exit
                           EndIf
                           AGLWD->(dbSkip())
                        EndDo

                        If lProces
                           AGLWD->(dbGoTop())
                           If (AGLWD->WD_DESPESA $ cDespImp)
                              cDeptoEIC := cDptoImp
                           EndIf
                           _aCabPC	:=	{{"C7_FILIAL" ,GetAdvFVal ( "SYT","YT_X_FILIA",XFILIAL("SYT") + SW6->W6_IMPORT,1 )	,Nil},;
                                       {"C7_EMISSAO" ,dDataBase                                                            ,Nil},; 
                                       {"C7_FORNECE" ,AGLWD->WD_FORN                                                       ,Nil},;
                                       {"C7_LOJA"	  ,AGLWD->WD_LOJA	                                                      ,Nil},;
                                       {"C7_XDEPART" ,cDeptoEIC	                                                         ,Nil},;
                                       {"C7_COND"	  ,"005"          	                                                   ,Nil},;
                                       {"C7_CONTATO" ,"IMPORTACOES"                                                        ,Nil},;
                                       {"C7_NUMIMP"  ,SW6->W6_PO_NUM                                                       ,Nil},;
                                       {"C7_ORIGEM"  ,"EICPO400"	                                                         ,Nil}}
                           
                           
                           While AGLWD->(!EOF())
                              cItem := SOMA1(cItem)

                              If AGLWD->WD_DESPESA $ cDespQtd

                                 nQtdPC  := (SW6->W6_CONTA20 + SW6->W6_CONTA40 + SW6->W6_CON40HC + SW6->W6_OUTROS)
                                 nVlUnit := Round((AGLWD->WD_VALOR_R / nQtdPC),4)
                              
                                 If nQtdPC == 0
                                    Alert("Quantidade de Container n„o foi preenchido, pedido de compra n„o sera gerado.")
                                    Return
                                 EndIf

                                 _aItemPC :=	{{"C7_ITEM"	   ,cItem	                  ,Nil},;
                                             {"C7_PRODUTO"  ,"EIC"+AGLWD->WD_DESPESA   ,Nil},;
                                             {"C7_UM"	      ,SB1->B1_UM		            ,Nil},;   
                                             {"C7_QUANT"	   ,nQtdPC          	         ,Nil},;
                                             {"C7_PRECO"	   ,nVlUnit          	      ,Nil},;
                                             {"C7_CC"	      ,AGLWD->WD_XCC             ,Nil},;     
                                             {"C7_XHAWB"    ,Alltrim(SWD->WD_HAWB)     ,Nil},;
                                             {"C7_NUMIMP"   ,SW6->W6_PO_NUM            ,Nil},;
                                             {"C7_OBS"	   ,AGLWD->WD_XOBS	         ,Nil}}
                              Else
                                 _aItemPC :=	{{"C7_ITEM"	   ,cItem	                  ,Nil},;
                                             {"C7_PRODUTO"  ,"EIC"+AGLWD->WD_DESPESA   ,Nil},;
                                             {"C7_UM"	      ,SB1->B1_UM		            ,Nil},;   
                                             {"C7_QUANT"	   ,1             	         ,Nil},;
                                             {"C7_PRECO"	   ,AGLWD->WD_VALOR_R	      ,Nil},;
                                             {"C7_CC"	      ,AGLWD->WD_XCC             ,Nil},;     
                                             {"C7_XHAWB"    ,Alltrim(SWD->WD_HAWB)     ,Nil},;
                                             {"C7_NUMIMP"   ,SW6->W6_PO_NUM            ,Nil},;
                                             {"C7_OBS"	   ,AGLWD->WD_XOBS	         ,Nil}}
                              EndIf

                              AADD(aItens,_aItemPC)
                              AGLWD->(dbSkip())
                           EndDo

                           cItem := SOMA1(cItem)

                           If SWD->WD_DESPESA $ cDespQtd

                                 nQtdPC  := (SW6->W6_CONTA20 + SW6->W6_CONTA40 + SW6->W6_CON40HC + SW6->W6_OUTROS)
                                 nVlUnit := Round((SWD->WD_VALOR_R / nQtdPC),4)
                              
                                 If nQtdPC == 0
                                    Alert("Quantidade de Container n„o foi preenchido, pedido de compra n„o sera gerado.")
                                    Return
                                 EndIf
                                 
                                 _aItemPC :=	{{"C7_ITEM"	   ,cItem	               ,Nil},;
                                             {"C7_PRODUTO"  ,"EIC"+SWD->WD_DESPESA  ,Nil},;
                                             {"C7_UM"	      ,SB1->B1_UM	      	   ,Nil},;   
                                             {"C7_QUANT"	   ,nQtdPC                	,Nil},;
                                             {"C7_PRECO"	   ,nVlUnit       	      ,Nil},;
                                             {"C7_CC"	      ,SWD->WD_XCC            ,Nil},;     
                                             {"C7_XHAWB"    ,Alltrim(SWD->WD_HAWB)  ,Nil},;
                                             {"C7_NUMIMP"   ,SW6->W6_PO_NUM         ,Nil},;
                                             {"C7_OBS"	   ,SWD->WD_XOBS	         ,Nil}}
                           Else
                              _aItemPC :=	{{"C7_ITEM"	   ,cItem	               ,Nil},;
                                          {"C7_PRODUTO"  ,"EIC"+SWD->WD_DESPESA  ,Nil},;
                                          {"C7_UM"	      ,SB1->B1_UM	      	   ,Nil},;   
                                          {"C7_QUANT"	   ,1                   	,Nil},;
                                          {"C7_PRECO"	   ,SWD->WD_VALOR_R	      ,Nil},;
                                          {"C7_CC"	      ,SWD->WD_XCC            ,Nil},;     
                                          {"C7_XHAWB"    ,Alltrim(SWD->WD_HAWB)  ,Nil},;
                                          {"C7_NUMIMP"   ,SW6->W6_PO_NUM         ,Nil},;
                                          {"C7_OBS"	   ,SWD->WD_XOBS	         ,Nil}}
                           EndIf  
                           AADD(aItens,_aItemPC)


                           Processa( {|| MsExecAuto( {|v,x,y,z| MATA120(v,x,y,z)},1,_aCabPC,aItens,3)  }, "Aguarde...", "Gerando pedido de compras...",.F.)
                  
                           If lMsErroAuto
                              cDirArq := "\"
                              cNomArq := "\"+cFunName+"-"+DToS(Date())+"-"+StrTran(Time(),":","")+".log"
                                                
                              cErro := VerErro(MostraErro(cDirArq,cNomArq),cDirArq,cNomArq)

                              FErase(cDirArq+cNomArq)

                              ProcLogAtu("ERRO","EICDI500 - Pedido de compra nao  incluido - Processo: " + Alltrim(SW6->W6_HAWB) + " Despesa: " + Alltrim(SWD->WD_DESPESA), cErro, "EICDESPESA" )

                              Alert(cErro)
                           else
                              M->WD_XPEDCOM := SC7->C7_NUM
                                                   
                              AGLWD->(dbGoTop())
                              
                              aArea := GetArea()
                              
                              While AGLWD->(!EOF())
                                 SWD->(dbGoTo(AGLWD->R_E_C_N_O_))
                                 Reclock("SWD",.F.)
                                 SWD->WD_XPEDCOM := SC7->C7_NUM
                                 SWD->WD_XFILPC   := SC7->C7_FILIAL
                                 SWD->(msUnlock())
                                 AGLWD->(dbSkip())
                              EndDo

                              cQuery := " SELECT R_E_C_N_O_ FROM " + RetSqlName("SC7")
                              cQuery += " WHERE C7_FILIAL = '"+SC7->C7_FILIAL+"' "
                              cQuery += " AND C7_NUM = '"+SC7->C7_NUM+"' "
                              cQuery += " AND C7_FORNECE = '"+SC7->C7_FORNECE+"' "
                              cQuery += " AND C7_LOJA = '"+SC7->C7_LOJA+"' "
                              cQuery += " AND D_E_L_E_T_ = '' "
                                                   
                              If Select("C7TP") > 0
                                 C7TP->(dbCloseArea())
                              EndIf

                              DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'C7TP', .T., .F.)

                              While C7TP->(!EOF())
                                 SC7->(dbGoTo(C7TP->R_E_C_N_O_))
                                 RecLock("SC7",.F.)
                                 SC7->C7_ORIGEM := "EICPO400"
                                 SC7->C7_NUMIMP := SW6->W6_PO_NUM
                                 SC7->(MsUnlock())
                                 C7TP->(dbSkip())
                              EndDo
                              
                              RestArea(aArea)
                           EndIf
                        EndIf
                     EndIf
                  EndIf
               Endif
            Else
               If !(SWD->WD_DESPESA $ cDespFCIF) 
                  aArea := SWD->(GetArea())
                  dbSelectArea("SB1")
                  If SB1->(dbseek(xFilial("SB1")+"EIC"+SWD->WD_DESPESA))
                     If (SWD->WD_DESPESA $ cDespImp)
                        cDeptoEIC := cDptoImp
                     EndIf
                     _aCabPC	:=	{{"C7_FILIAL" ,GetAdvFVal ( "SYT","YT_X_FILIA",XFILIAL("SYT") + SW6->W6_IMPORT,1 )	,Nil},;
                                 {"C7_EMISSAO" ,dDataBase                                                            ,Nil},; 
                                 {"C7_FORNECE" ,SWD->WD_FORN                                                         ,Nil},;
                                 {"C7_LOJA"	  ,SWD->WD_LOJA                                                         ,Nil},;
                                 {"C7_XDEPART" ,cDeptoEIC	                                                         ,Nil},;
                                 {"C7_COND"	  ,"005"    	                                                         ,Nil},;
                                 {"C7_CONTATO" ,"IMPORTACOES"                                                        ,Nil},;
                                 {"C7_NUMIMP"  ,SW6->W6_PO_NUM                                                       ,Nil},;
                                 {"C7_ORIGEM"  ,"EICPO400"	                                                         ,Nil}}
                     
                     If SWD->WD_DESPESA $ cDespQtd

                        nQtdPC  := (SW6->W6_CONTA20 + SW6->W6_CONTA40 + SW6->W6_CON40HC + SW6->W6_OUTROS)
                        nVlUnit := Round((SWD->WD_VALOR_R / nQtdPC),4)
                     
                        If nQtdPC == 0
                           Alert("Quantidade de Container n„o foi preenchido, pedido de compra n„o sera gerado.")
                           Return
                        EndIf
                     
                        _aItemPC :=	{{"C7_ITEM"	   ,"0001"	               ,Nil},;
                                    {"C7_PRODUTO"  ,"EIC"+SWD->WD_DESPESA  ,Nil},;
                                    {"C7_UM"	      ,SB1->B1_UM		         ,Nil},;   
                                    {"C7_QUANT"	   ,nQtdPC          	      ,Nil},;
                                    {"C7_PRECO"	   ,nVlUnit 	            ,Nil},;
                                    {"C7_CC"	      ,SWD->WD_XCC            ,Nil},;     
                                    {"C7_XHAWB"    ,Alltrim(SWD->WD_HAWB)  ,Nil},;
                                    {"C7_NUMIMP"   ,SW6->W6_PO_NUM         ,Nil},;
                                    {"C7_OBS"	   ,SWD->WD_XOBS	         ,Nil}}
                     Else
                        _aItemPC :=	{{"C7_ITEM"	   ,"0001"	               ,Nil},;
                                    {"C7_PRODUTO"  ,"EIC"+SWD->WD_DESPESA  ,Nil},;
                                    {"C7_UM"	      ,SB1->B1_UM		         ,Nil},;   
                                    {"C7_QUANT"	   ,1             	      ,Nil},;
                                    {"C7_PRECO"	   ,SWD->WD_VALOR_R	      ,Nil},;
                                    {"C7_CC"	      ,SWD->WD_XCC            ,Nil},;     
                                    {"C7_XHAWB"    ,Alltrim(SWD->WD_HAWB)  ,Nil},;
                                    {"C7_NUMIMP"   ,SW6->W6_PO_NUM         ,Nil},;
                                    {"C7_OBS"	   ,SWD->WD_XOBS	         ,Nil}}
                     EndIf

                     Processa( {|| MsExecAuto( {|v,x,y,z| MATA120(v,x,y,z)},1,_aCabPC,{_aItemPC},3)  }, "Aguarde...", "Gerando pedido de compras...",.F.)
                     
                     RestArea(aArea)
                     
                     If lMsErroAuto
                        cDirArq := "\"
                        cNomArq := "\"+cFunName+"-"+DToS(Date())+"-"+StrTran(Time(),":","")+".log"
                                          
                        cErro := VerErro(MostraErro(cDirArq,cNomArq),cDirArq,cNomArq)

                        FErase(cDirArq+cNomArq)

                        ProcLogAtu("ERRO","EICDI500 - Pedido de compra nao incluido - Processo: " + Alltrim(SW6->W6_HAWB) + " Despesa: " + Alltrim(SWD->WD_DESPESA), cErro, "EICDESPESA" )

                        Alert("A T E N « √ O !!!"+CRLF+CRLF+"Pedido n„o gerado"+CRLF+CRLF+cErro)
                  
                     else
                        M->WD_XPEDCOM := SC7->C7_NUM
                        If RecLock("SWD",.F.)
                           SWD->WD_XPEDCOM := SC7->C7_NUM
                           SWD->WD_XFILPC   := SC7->C7_FILIAL
                           SWD->(MsUnlock())
                        EndIf
                        If RecLock("SC7",.F.)
                           SC7->C7_ORIGEM := "EICPO400"
                           SC7->C7_NUMIMP := SW6->W6_PO_NUM
                           SC7->(MsUnlock())
                        EndIf
                     EndIf
                  else
                     alert("Pedido de compra n„o sera gerado, produto EIC" + SWD->WD_DESPESA + " n„o cadastrado no sistema!")
                  EndIf
               else
                  aPosFCIF := aScan(aDesFCIF, {|x| Alltrim(x) == SWD->WD_DESPESA})

                  If aPosFCIF <> 0
                     aDel(aDesFCIF,aPosFCIF)
                     aSize(aDesFCIF,nNumDCIF-1)
                     nNumDCIF := Len(aDesFCIF)
                  EndIf

                  cQuery := " SELECT COUNT(DISTINCT(WD_DESPESA)) AS TOT_DESPESA FROM " + RetSqlName("SWD")
                  cQuery += " WHERE WD_FILIAL = '"+xFilial("SWD")+"' "
                  cQuery += " AND WD_HAWB = '"+Alltrim(SWD->WD_HAWB)+"' "
                  cQuery += " AND WD_DESPESA IN " + FormatIn(cDespFCIF,"/")
                  cQuery += " AND WD_DESPESA <> '"+Alltrim(SWD->WD_DESPESA)+"' "
                  cQuery += " AND D_E_L_E_T_ = '' "

                  If Select("DESFRET") > 0
                     DESFRET->(dbCloseArea())
                  EndIf

                  DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'DESFRET', .T., .F.)

                  If DESFRET->(!EOF())
                     If DESFRET->TOT_DESPESA == nNumDCIF
                        cQuery := " SELECT WD_DESPESA, WD_FORN, WD_LOJA, WD_VALOR_R, WD_XCC, WD_XOBS, R_E_C_N_O_ FROM " + RetSqlName("SWD")
                        cQuery += " WHERE WD_FILIAL = '"+xFilial("SWD")+"' "
                        cQuery += " AND WD_HAWB = '"+Alltrim(SWD->WD_HAWB)+"' "
                        cQuery += " AND WD_DESPESA IN " + FormatIn(cDespFCIF,"/")
                        cQuery += " AND D_E_L_E_T_ = '' "
                        cQuery += " ORDER BY WD_XCC DESC "

                        If Select("AGLWD") > 0
                           AGLWD->(dbCloseArea())
                        EndIf

                        DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'AGLWD', .T., .F.)
                        
                        dbSelectArea("SB1")

                        While AGLWD->(!EOF())
                           If !SB1->(dbseek(xFilial("SB1")+"EIC"+AGLWD->WD_DESPESA))
                              lProces := .F.
                              Alert("Produto n„o cadastrado")
                              Exit
                           EndIf
                           AGLWD->(dbSkip())
                        EndDo

                        If lProces
                           AGLWD->(dbGoTop())
                           If (AGLWD->WD_DESPESA $ cDespImp)
                              cDeptoEIC := cDptoImp
                           EndIf
                           _aCabPC	:=	{{"C7_FILIAL" ,GetAdvFVal ( "SYT","YT_X_FILIA",XFILIAL("SYT") + SW6->W6_IMPORT,1 )	,Nil},;
                                       {"C7_EMISSAO" ,dDataBase                                                            ,Nil},; 
                                       {"C7_FORNECE" ,AGLWD->WD_FORN                                                       ,Nil},;
                                       {"C7_LOJA"	  ,AGLWD->WD_LOJA	                                                      ,Nil},;
                                       {"C7_XDEPART" ,cDeptoEIC	                                                         ,Nil},;
                                       {"C7_COND"	  ,"005"          	                                                   ,Nil},;
                                       {"C7_CONTATO" ,"IMPORTACOES"                                                        ,Nil},;
                                       {"C7_NUMIMP"  ,SW6->W6_PO_NUM                                                       ,Nil},;
                                       {"C7_ORIGEM"  ,"EICPO400"	                                                         ,Nil}}
                           
                           
                           While AGLWD->(!EOF())
                              cItem := SOMA1(cItem)

                              _aItemPC :=	{{"C7_ITEM"	   ,cItem	                  ,Nil},;
                                          {"C7_PRODUTO"  ,"EIC"+AGLWD->WD_DESPESA   ,Nil},;
                                          {"C7_UM"	      ,SB1->B1_UM		            ,Nil},;   
                                          {"C7_QUANT"	   ,1             	         ,Nil},;
                                          {"C7_PRECO"	   ,AGLWD->WD_VALOR_R	      ,Nil},;
                                          {"C7_CC"	      ,AGLWD->WD_XCC             ,Nil},;     
                                          {"C7_XHAWB"    ,Alltrim(SWD->WD_HAWB)     ,Nil},;
                                          {"C7_NUMIMP"   ,SW6->W6_PO_NUM            ,Nil},;
                                          {"C7_OBS"	   ,AGLWD->WD_XOBS	         ,Nil}}
                              
                              AADD(aItens,_aItemPC)
                              AGLWD->(dbSkip())
                           EndDo

                           cItem := SOMA1(cItem)

                           _aItemPC :=	{{"C7_ITEM"	   ,cItem	               ,Nil},;
                                       {"C7_PRODUTO"  ,"EIC"+SWD->WD_DESPESA  ,Nil},;
                                       {"C7_UM"	      ,SB1->B1_UM		         ,Nil},;   
                                       {"C7_QUANT"	   ,1             	      ,Nil},;
                                       {"C7_PRECO"	   ,SWD->WD_VALOR_R	      ,Nil},;
                                       {"C7_CC"	      ,SWD->WD_XCC            ,Nil},;     
                                       {"C7_XHAWB"    ,Alltrim(SWD->WD_HAWB)  ,Nil},;
                                       {"C7_NUMIMP"   ,SW6->W6_PO_NUM         ,Nil},;
                                       {"C7_OBS"	   ,SWD->WD_XOBS	         ,Nil}}
                           
                           AADD(aItens,_aItemPC)


                           Processa( {|| MsExecAuto( {|v,x,y,z| MATA120(v,x,y,z)},1,_aCabPC,aItens,3)  }, "Aguarde...", "Gerando pedido de compras...",.F.)
                  
                           If lMsErroAuto
                              cDirArq := "\"
                              cNomArq := "\"+cFunName+"-"+DToS(Date())+"-"+StrTran(Time(),":","")+".log"
                                                
                              cErro := VerErro(MostraErro(cDirArq,cNomArq),cDirArq,cNomArq)

                              FErase(cDirArq+cNomArq)

                              ProcLogAtu("ERRO","EICDI500 - Pedido de compra nao incluido - Processo: " + Alltrim(SW6->W6_HAWB) + " Despesa: " + Alltrim(SWD->WD_DESPESA), cErro, "EICDESPESA" )

                              Alert(cErro)
                           else
                              M->WD_XPEDCOM := SC7->C7_NUM
                                                   
                              AGLWD->(dbGoTop())
                              
                              aArea := GetArea()
                              
                              While AGLWD->(!EOF())
                                 SWD->(dbGoTo(AGLWD->R_E_C_N_O_))
                                 Reclock("SWD",.F.)
                                 SWD->WD_XPEDCOM := SC7->C7_NUM
                                 SWD->WD_XFILPC   := SC7->C7_FILIAL
                                 SWD->(msUnlock())
                                 AGLWD->(dbSkip())
                              EndDo

                              cQuery := " SELECT R_E_C_N_O_ FROM " + RetSqlName("SC7")
                              cQuery += " WHERE C7_FILIAL = '"+SC7->C7_FILIAL+"' "
                              cQuery += " AND C7_NUM = '"+SC7->C7_NUM+"' "
                              cQuery += " AND C7_FORNECE = '"+SC7->C7_FORNECE+"' "
                              cQuery += " AND C7_LOJA = '"+SC7->C7_LOJA+"' "
                              cQuery += " AND D_E_L_E_T_ = '' "
                                                   
                              If Select("C7TP") > 0
                                 C7TP->(dbCloseArea())
                              EndIf

                              DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'C7TP', .T., .F.)

                              While C7TP->(!EOF())
                                 SC7->(dbGoTo(C7TP->R_E_C_N_O_))
                                 RecLock("SC7",.F.)
                                 SC7->C7_ORIGEM := "EICPO400"
                                 SC7->C7_NUMIMP := SW6->W6_PO_NUM
                                 SC7->(MsUnlock())
                                 C7TP->(dbSkip())
                              EndDo
                              
                              RestArea(aArea)
                           EndIf
                        EndIf
                     EndIf
                  EndIf
               Endif
            EndIf
         EndIf
      EndIf
   CASE PARAMIXB == "ALTERA_DESP"
      If lAtvEIC
         If !(SWD->WD_DESPESA $ cNGFrete)
            dbSelectArea("SC7")
            SC7->(dbSetOrder(4))
            If SC7->(dbSeek(GetAdvFVal("SYT","YT_X_FILIA",XFILIAL("SYT")+SW6->W6_IMPORT,1) + PADR("EIC"+SWD->WD_DESPESA,TamSX3("C7_PRODUTO")[1]) + SWD->WD_XPEDCOM ))
               _aCabPC	:=	{{"C7_FILIAL" ,GetAdvFVal("SYT","YT_X_FILIA",XFILIAL("SYT")+SW6->W6_IMPORT,1)	,Nil},;
                           {"C7_NUM"     ,SC7->C7_NUM                                                    ,Nil},; 
                           {"C7_EMISSAO" ,SC7->C7_EMISSAO                                                ,Nil},; 
                           {"C7_FORNECE" ,SC7->C7_FORNECE                                                ,Nil},;
                           {"C7_LOJA"	  ,SC7->C7_LOJA                                                   ,Nil},;
                           {"C7_COND"	  ,SC7->C7_COND                                                   ,Nil},;
                           {"C7_XDEPART" ,SC7->C7_XDEPART                                                ,Nil},;
                           {"C7_FILENT"  ,SC7->C7_FILENT                                                 ,Nil}}
                           
               If SWD->WD_DESPESA $ cDespQtd
               
                  nQtdPC  := (SW6->W6_CONTA20 + SW6->W6_CONTA40 + SW6->W6_CON40HC + SW6->W6_OUTROS)
                  nVlUnit := Round((SWD->WD_VALOR_R / nQtdPC),4)
               
                  If nQtdPC == 0
                     Alert("Quantidade de Container n„o foi preenchido, pedido de compra n„o sera gerado.")
                     Return
                  EndIf               
               
                  _aItemPC :=	{{"C7_ITEM"	   ,SC7->C7_ITEM           ,Nil},;
                              {"C7_PRODUTO"  ,SC7->C7_PRODUTO        ,Nil},;
                              {"C7_UM"	      ,SC7->C7_UM		         ,Nil},;   
                              {"C7_QUANT"	   ,nQtdPC   	            ,Nil},;
                              {"C7_PRECO"	   ,nVlUnit	               ,Nil},;
                              {"C7_CC"	      ,SWD->WD_XCC            ,Nil},;
                              {"C7_XHAWB"    ,Alltrim(SWD->WD_HAWB)  ,Nil},;     
                              {"C7_OBS"	   ,SWD->WD_XOBS	         ,Nil}}
               Else
                  _aItemPC :=	{{"C7_ITEM"	   ,SC7->C7_ITEM           ,Nil},;
                              {"C7_PRODUTO"  ,SC7->C7_PRODUTO        ,Nil},;
                              {"C7_UM"	      ,SC7->C7_UM		         ,Nil},;   
                              {"C7_QUANT"	   ,SC7->C7_QUANT   	      ,Nil},;
                              {"C7_PRECO"	   ,SWD->WD_VALOR_R	      ,Nil},;
                              {"C7_TOTAL"	   ,SWD->WD_VALOR_R	      ,Nil},;
                              {"C7_CC"	      ,SWD->WD_XCC            ,Nil},;
                              {"C7_XHAWB"    ,Alltrim(SWD->WD_HAWB)  ,Nil},;     
                              {"C7_OBS"	   ,SWD->WD_XOBS	         ,Nil}}
               EndIf
                                 
               Processa( {|| MSExecAuto( {|a,b,c,d,e| MATA120(a,b,c,d,e)},1,_aCabPC,{_aItemPC},4,.F.)}, "Aguarde...", "Alterando pedido de compras...",.F.)
                  
               If lMsErroAuto
                  cDirArq := "\"
                  cNomArq := "\"+cFunName+"-"+DToS(Date())+"-"+StrTran(Time(),":","")+".log"
                                    
                  cErro := VerErro(MostraErro(cDirArq,cNomArq),cDirArq,cNomArq)

                  FErase(cDirArq+cNomArq)

                  ProcLogAtu("ERRO","EICDI500 - Pedido de compra nao alterado - Processo: " + Alltrim(SW6->W6_HAWB) + " Despesa: " + Alltrim(SWD->WD_DESPESA) + " Pedido: " + Alltrim(SWD->WD_XPEDCOM), cErro, "EICDESPESA" )

                  If "j· foi atendido" $ cErro  
                     Alert("A T E N « √ O ! ! !" + CRLF+CRLF+"Pedido de Compra " + SC7->C7_NUM + " j· foi faturado n„o È possivel alterar o mesmo"+CRLF+CRLF+"OBSERVA«√O:"+CRLF+"A despesa sera alterada mesmo sem alteraÁ„o do pedido de compra")
                  Else
                     Alert(cErro)
                  EndIf
               else
                  If RecLock("SWD",.F.)
                     SWD->WD_XPEDCOM := SC7->C7_NUM
                     SWD->WD_XFILPC   := SC7->C7_FILIAL
                     SWD->(MsUnlock())
                  EndIf
                  cQuery := " SELECT R_E_C_N_O_ FROM " + RetSqlName("SC7")
                  cQuery += " WHERE C7_FILIAL = '"+SC7->C7_FILIAL+"' "
                  cQuery += " AND C7_NUM = '"+SC7->C7_NUM+"' "
                  cQuery += " AND C7_FORNECE = '"+SC7->C7_FORNECE+"' "
                  cQuery += " AND C7_LOJA = '"+SC7->C7_LOJA+"' "
                  cQuery += " AND D_E_L_E_T_ = '' "
                                       
                  If Select("C7TP") > 0
                     C7TP->(dbCloseArea())
                  EndIf

                  DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'C7TP', .T., .F.)

                  aArea := GetArea(aArea)

                  While C7TP->(!EOF())
                     SC7->(dbGoTo(C7TP->R_E_C_N_O_))
                     RecLock("SC7",.F.)
                     SC7->C7_ORIGEM := "EICPO400"
                     SC7->C7_NUMIMP := SW6->W6_PO_NUM
                     SC7->(MsUnlock())
                     C7TP->(dbSkip())
                  EndDo
                  
                  RestArea(aArea)
                  
                  MsgInfo("Pedido " +Alltrim(SC7->C7_NUM)+" alterado com sucesso","Alteracao do Pedido de compra")
               EndIf
            Else
               dbSelectArea("SW2")
               SW2->(dbSetOrder(1))
               SW2->(dbSeek(xFilial("SW2")+SW6->W6_PO_NUM))
               If SW2->W2_INCOTER <> "CIF"
                  If !(SWD->WD_DESPESA $ cDespFrete) 
                     aArea := SWD->(GetArea())
                     dbSelectArea("SB1")
                     If SB1->(dbseek(xFilial("SB1")+"EIC"+SWD->WD_DESPESA))
                        If (SWD->WD_DESPESA $ cDespImp)
                           cDeptoEIC := cDptoImp
                        EndIf
                        _aCabPC	:=	{{"C7_FILIAL" ,GetAdvFVal( "SYT","YT_X_FILIA",XFILIAL("SYT") + SW6->W6_IMPORT,1 )	,Nil},;
                                    {"C7_EMISSAO" ,dDataBase                                                            ,Nil},; 
                                    {"C7_FORNECE" ,SWD->WD_FORN                                                         ,Nil},;
                                    {"C7_LOJA"	  ,SWD->WD_LOJA	                                                      ,Nil},;
                                    {"C7_XDEPART" ,cDeptoEIC	                                                         ,Nil},;
                                    {"C7_COND"	  ,"005"    	                                                         ,Nil},;
                                    {"C7_CONTATO" ,"IMPORTACOES"                                                        ,Nil},;
                                    {"C7_NUMIMP"  ,SW6->W6_PO_NUM                                                       ,Nil},;
                                    {"C7_ORIGEM"  ,"EICPO400"	                                                         ,Nil}}
                        
                        If SWD->WD_DESPESA $ cDespQtd

                           nQtdPC  := (SW6->W6_CONTA20 + SW6->W6_CONTA40 + SW6->W6_CON40HC + SW6->W6_OUTROS)
                           nVlUnit := Round((SWD->WD_VALOR_R / nQtdPC),4)
                        
                           If nQtdPC == 0
                              Alert("Quantidade de Container n„o foi preenchido, pedido de compra n„o sera gerado.")
                              Return
                           EndIf

                           _aItemPC :=	{{"C7_ITEM"	   ,"0001"	               ,Nil},;
                                       {"C7_PRODUTO"  ,"EIC"+SWD->WD_DESPESA  ,Nil},;
                                       {"C7_UM"	      ,SB1->B1_UM		         ,Nil},;   
                                       {"C7_QUANT"	   ,nQtdPC          	      ,Nil},;
                                       {"C7_PRECO"	   ,nVlUnit 	            ,Nil},;
                                       {"C7_CC"	      ,SWD->WD_XCC            ,Nil},;     
                                       {"C7_XHAWB"    ,Alltrim(SWD->WD_HAWB)  ,Nil},;
                                       {"C7_NUMIMP"   ,SW6->W6_PO_NUM         ,Nil},;
                                       {"C7_OBS"	   ,SWD->WD_XOBS	         ,Nil}}
                        Else
                           _aItemPC :=	{{"C7_ITEM"	   ,"0001"	               ,Nil},;
                                       {"C7_PRODUTO"  ,"EIC"+SWD->WD_DESPESA  ,Nil},;
                                       {"C7_UM"	      ,SB1->B1_UM		         ,Nil},;   
                                       {"C7_QUANT"	   ,1             	      ,Nil},;
                                       {"C7_PRECO"	   ,SWD->WD_VALOR_R	      ,Nil},;
                                       {"C7_CC"	      ,SWD->WD_XCC            ,Nil},;     
                                       {"C7_XHAWB"    ,Alltrim(SWD->WD_HAWB)  ,Nil},;
                                       {"C7_NUMIMP"   ,SW6->W6_PO_NUM         ,Nil},;
                                       {"C7_OBS"	   ,SWD->WD_XOBS	         ,Nil}}
                        EndIf
                                             
                        
                        Processa( {|| MsExecAuto( {|v,x,y,z| MATA120(v,x,y,z)},1,_aCabPC,{_aItemPC},3)  }, "Aguarde...", "Gerando pedido de compras...",.F.)
                        
                        RestArea(aArea)
                        
                        If lMsErroAuto
                           cDirArq := "\"
                           cNomArq := "\"+cFunName+"-"+DToS(Date())+"-"+StrTran(Time(),":","")+".log"
                                             
                           cErro := VerErro(MostraErro(cDirArq,cNomArq),cDirArq,cNomArq)
                           
                           FErase(cDirArq+cNomArq)

                           ProcLogAtu("ERRO","EICDI500 - Pedido de compra nao incluido - Processo: " + Alltrim(SW6->W6_HAWB) + " Despesa: " + Alltrim(SWD->WD_DESPESA), cErro, "EICDESPESA" )

                           Alert("A T E N « √ O !!!"+CRLF+CRLF+"Pedido n„o gerado"+CRLF+CRLF+cErro)
                     
                        else
                           M->WD_XPEDCOM := SC7->C7_NUM
                           If RecLock("SWD",.F.)
                              SWD->WD_XPEDCOM := SC7->C7_NUM
                              SWD->WD_XFILPC   := SC7->C7_FILIAL
                              SWD->(MsUnlock())
                           EndIf
                           If RecLock("SC7",.F.)
                              SC7->C7_ORIGEM := "EICPO400"
                              SC7->C7_NUMIMP := SW6->W6_PO_NUM
                              SC7->(MsUnlock())
                           EndIf
                        EndIf
                     else
                        alert("Pedido de compra n„o sera gerado, produto EIC" + SWD->WD_DESPESA + " n„o cadastrado no sistema!")
                     EndIf
                  else
                     aPosFrete := aScan(aDesFrete, {|x| Alltrim(x) == SWD->WD_DESPESA})

                     If aPosFrete <> 0
                        aDel(aDesFrete,aPosFrete)
                        aSize(aDesFrete,nNumDesp-1)
                        nNumDesp := Len(aDesFrete)
                     EndIf

                     cQuery := " SELECT COUNT(DISTINCT(WD_DESPESA)) AS TOT_DESPESA FROM " + RetSqlName("SWD")
                     cQuery += " WHERE WD_FILIAL = '"+xFilial("SWD")+"' "
                     cQuery += " AND WD_HAWB = '"+Alltrim(SWD->WD_HAWB)+"' "
                     cQuery += " AND WD_DESPESA IN " + FormatIn(cDespFrete,"/")
                     cQuery += " AND WD_DESPESA <> '"+Alltrim(SWD->WD_DESPESA)+"' "
                     cQuery += " AND D_E_L_E_T_ = '' "

                     If Select("DESFRET") > 0
                        DESFRET->(dbCloseArea())
                     EndIf

                     DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'DESFRET', .T., .F.)

                     If DESFRET->(!EOF())
                        If DESFRET->TOT_DESPESA == nNumDesp
                           cQuery := " SELECT WD_DESPESA, WD_FORN, WD_LOJA, WD_VALOR_R, WD_XCC, WD_XOBS, R_E_C_N_O_ FROM " + RetSqlName("SWD")
                           cQuery += " WHERE WD_FILIAL = '"+xFilial("SWD")+"' "
                           cQuery += " AND WD_HAWB = '"+Alltrim(SWD->WD_HAWB)+"' "
                           cQuery += " AND WD_DESPESA IN " + FormatIn(cDespFrete,"/")
                           cQuery += " AND D_E_L_E_T_ = '' "
                           cQuery += " ORDER BY WD_XCC DESC "

                           If Select("AGLWD") > 0
                              AGLWD->(dbCloseArea())
                           EndIf

                           DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'AGLWD', .T., .F.)
                           
                           dbSelectArea("SB1")

                           While AGLWD->(!EOF())
                              If !SB1->(dbseek(xFilial("SB1")+"EIC"+AGLWD->WD_DESPESA))
                                 lProces := .F.
                                 Alert("Produto n„o cadastrado")
                                 Exit
                              EndIf
                              AGLWD->(dbSkip())
                           EndDo

                           If lProces
                              AGLWD->(dbGoTop())
                              If (AGLWD->WD_DESPESA $ cDespImp)
                                 cDeptoEIC := cDptoImp
                              EndIf
                              _aCabPC	:=	{{"C7_FILIAL" ,GetAdvFVal( "SYT","YT_X_FILIA",XFILIAL("SYT") + SW6->W6_IMPORT,1 )	,Nil},;
                                          {"C7_EMISSAO" ,dDataBase                                                            ,Nil},; 
                                          {"C7_FORNECE" ,AGLWD->WD_FORN                                                       ,Nil},;
                                          {"C7_LOJA"	  ,AGLWD->WD_LOJA	                                                      ,Nil},;
                                          {"C7_XDEPART" ,cDeptoEIC	                                                         ,Nil},;
                                          {"C7_COND"	  ,"005"          	                                                   ,Nil},;
                                          {"C7_CONTATO" ,"IMPORTACOES"                                                        ,Nil},;
                                          {"C7_NUMIMP"  ,SW6->W6_PO_NUM                                                       ,Nil},;
                                          {"C7_ORIGEM"  ,"EICPO400"	                                                         ,Nil}}
                              
                              
                              While AGLWD->(!EOF())
                                 cItem := SOMA1(cItem)

                                 _aItemPC :=	{{"C7_ITEM"	   ,cItem	                  ,Nil},;
                                             {"C7_PRODUTO"  ,"EIC"+AGLWD->WD_DESPESA   ,Nil},;
                                             {"C7_UM"	      ,SB1->B1_UM		            ,Nil},;   
                                             {"C7_QUANT"	   ,1             	         ,Nil},;
                                             {"C7_PRECO"	   ,AGLWD->WD_VALOR_R	      ,Nil},;
                                             {"C7_CC"	      ,AGLWD->WD_XCC             ,Nil},;     
                                             {"C7_XHAWB"    ,Alltrim(SWD->WD_HAWB)     ,Nil},;
                                             {"C7_NUMIMP"   ,SW6->W6_PO_NUM            ,Nil},;
                                             {"C7_OBS"	   ,AGLWD->WD_XOBS	         ,Nil}}
                                 
                                 AADD(aItens,_aItemPC)
                                 AGLWD->(dbSkip())
                              EndDo

                              cItem := SOMA1(cItem)

                              _aItemPC :=	{{"C7_ITEM"	   ,cItem	               ,Nil},;
                                          {"C7_PRODUTO"  ,"EIC"+SWD->WD_DESPESA  ,Nil},;
                                          {"C7_UM"	      ,SB1->B1_UM		         ,Nil},;   
                                          {"C7_QUANT"	   ,1             	      ,Nil},;
                                          {"C7_PRECO"	   ,SWD->WD_VALOR_R	      ,Nil},;
                                          {"C7_CC"	      ,SWD->WD_XCC            ,Nil},;     
                                          {"C7_XHAWB"    ,Alltrim(SWD->WD_HAWB)  ,Nil},;
                                          {"C7_NUMIMP"   ,SW6->W6_PO_NUM         ,Nil},;
                                          {"C7_OBS"	   ,SWD->WD_XOBS	         ,Nil}}
                              
                              AADD(aItens,_aItemPC)


                              Processa( {|| MsExecAuto( {|v,x,y,z| MATA120(v,x,y,z)},1,_aCabPC,aItens,3)  }, "Aguarde...", "Gerando pedido de compras...",.F.)
                     
                              If lMsErroAuto
                                 cDirArq := "\"
                                 cNomArq := "\"+cFunName+"-"+DToS(Date())+"-"+StrTran(Time(),":","")+".log"
                                                   
                                 cErro := VerErro(MostraErro(cDirArq,cNomArq),cDirArq,cNomArq)

                                 FErase(cDirArq+cNomArq)

                                 ProcLogAtu("ERRO","EICDI500 - Pedido de compra nao incluido - Processo: " + Alltrim(SW6->W6_HAWB) + " Despesa: " + Alltrim(SWD->WD_DESPESA), cErro, "EICDESPESA" )

                                 Alert(cErro)
                              else
                                 M->WD_XPEDCOM := SC7->C7_NUM
                                                      
                                 AGLWD->(dbGoTop())
                                 
                                 aArea := GetArea()
                                 
                                 While AGLWD->(!EOF())
                                    SWD->(dbGoTo(AGLWD->R_E_C_N_O_))
                                    Reclock("SWD",.F.)
                                    SWD->WD_XPEDCOM := SC7->C7_NUM
                                    SWD->WD_XFILPC   := SC7->C7_FILIAL
                                    SWD->(msUnlock())
                                    AGLWD->(dbSkip())
                                 EndDo

                                 cQuery := " SELECT R_E_C_N_O_ FROM " + RetSqlName("SC7")
                                 cQuery += " WHERE C7_FILIAL = '"+SC7->C7_FILIAL+"' "
                                 cQuery += " AND C7_NUM = '"+SC7->C7_NUM+"' "
                                 cQuery += " AND C7_FORNECE = '"+SC7->C7_FORNECE+"' "
                                 cQuery += " AND C7_LOJA = '"+SC7->C7_LOJA+"' "
                                 cQuery += " AND D_E_L_E_T_ = '' "
                                                      
                                 If Select("C7TP") > 0
                                    C7TP->(dbCloseArea())
                                 EndIf

                                 DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'C7TP', .T., .F.)

                                 While C7TP->(!EOF())
                                    SC7->(dbGoTo(C7TP->R_E_C_N_O_))
                                    RecLock("SC7",.F.)
                                    SC7->C7_ORIGEM := "EICPO400"
                                    SC7->C7_NUMIMP := SW6->W6_PO_NUM
                                    SC7->(MsUnlock())
                                    C7TP->(dbSkip())
                                 EndDo
                                 
                                 RestArea(aArea)
                              EndIf
                           EndIf
                        EndIf
                     EndIf
                  Endif
               Else
                  If !(SWD->WD_DESPESA $ cDespFCIF) 
                     aArea := SWD->(GetArea())
                     dbSelectArea("SB1")
                     If SB1->(dbseek(xFilial("SB1")+"EIC"+SWD->WD_DESPESA))
                        If (SWD->WD_DESPESA $ cDespImp)
                           cDeptoEIC := cDptoImp
                        EndIf
                        _aCabPC	:=	{{"C7_FILIAL" ,GetAdvFVal( "SYT","YT_X_FILIA",XFILIAL("SYT") + SW6->W6_IMPORT,1 )	,Nil},;
                                    {"C7_EMISSAO" ,dDataBase                                                            ,Nil},; 
                                    {"C7_FORNECE" ,SWD->WD_FORN                                                         ,Nil},;
                                    {"C7_LOJA"	  ,SWD->WD_LOJA	                                                      ,Nil},;
                                    {"C7_XDEPART" ,cDeptoEIC	                                                         ,Nil},;
                                    {"C7_COND"	  ,"005"    	                                                         ,Nil},;
                                    {"C7_CONTATO" ,"IMPORTACOES"                                                        ,Nil},;
                                    {"C7_NUMIMP"  ,SW6->W6_PO_NUM                                                       ,Nil},;
                                    {"C7_ORIGEM"  ,"EICPO400"	                                                         ,Nil}}

                        If SWD->WD_DESPESA $ cDespQtd

                           nQtdPC  := (SW6->W6_CONTA20 + SW6->W6_CONTA40 + SW6->W6_CON40HC + SW6->W6_OUTROS)
                           nVlUnit := Round((SWD->WD_VALOR_R / nQtdPC),4)
                        
                           If nQtdPC == 0
                              Alert("Quantidade de Container n„o foi preenchido, pedido de compra n„o sera gerado.")
                              Return
                           EndIf         
                           _aItemPC :=	{{"C7_ITEM"	   ,"0001"	               ,Nil},;
                                       {"C7_PRODUTO"  ,"EIC"+SWD->WD_DESPESA  ,Nil},;
                                       {"C7_UM"	      ,SB1->B1_UM		         ,Nil},;   
                                       {"C7_QUANT"	   ,nQtdPC          	      ,Nil},;
                                       {"C7_PRECO"	   ,nVlUnit 	            ,Nil},;
                                       {"C7_CC"	      ,SWD->WD_XCC            ,Nil},;     
                                       {"C7_XHAWB"    ,Alltrim(SWD->WD_HAWB)  ,Nil},;
                                       {"C7_NUMIMP"   ,SW6->W6_PO_NUM         ,Nil},;
                                       {"C7_OBS"	   ,SWD->WD_XOBS	         ,Nil}}
                        Else
                           _aItemPC :=	{{"C7_ITEM"	   ,"0001"	               ,Nil},;
                                       {"C7_PRODUTO"  ,"EIC"+SWD->WD_DESPESA  ,Nil},;
                                       {"C7_UM"	      ,SB1->B1_UM		         ,Nil},;   
                                       {"C7_QUANT"	   ,1             	      ,Nil},;
                                       {"C7_PRECO"	   ,SWD->WD_VALOR_R	      ,Nil},;
                                       {"C7_CC"	      ,SWD->WD_XCC            ,Nil},;     
                                       {"C7_XHAWB"    ,Alltrim(SWD->WD_HAWB)  ,Nil},;
                                       {"C7_NUMIMP"   ,SW6->W6_PO_NUM         ,Nil},;
                                       {"C7_OBS"	   ,SWD->WD_XOBS	         ,Nil}}
                        EndIf
                                          
                        Processa( {|| MsExecAuto( {|v,x,y,z| MATA120(v,x,y,z)},1,_aCabPC,{_aItemPC},3)  }, "Aguarde...", "Gerando pedido de compras...",.F.)
                        
                        RestArea(aArea)
                        
                        If lMsErroAuto
                           cDirArq := "\"
                           cNomArq := "\"+cFunName+"-"+DToS(Date())+"-"+StrTran(Time(),":","")+".log"
                                             
                           cErro := VerErro(MostraErro(cDirArq,cNomArq),cDirArq,cNomArq)

                           FErase(cDirArq+cNomArq)

                           ProcLogAtu("ERRO","EICDI500 - Pedido de compra nao incluido - Processo: " + Alltrim(SW6->W6_HAWB) + " Despesa: " + Alltrim(SWD->WD_DESPESA), cErro, "EICDESPESA" )

                           Alert("A T E N « √ O !!!"+CRLF+CRLF+"Pedido n„o gerado"+CRLF+CRLF+cErro)
                     
                        else
                           M->WD_XPEDCOM := SC7->C7_NUM
                           If RecLock("SWD",.F.)
                              SWD->WD_XPEDCOM := SC7->C7_NUM
                              SWD->WD_XFILPC   := SC7->C7_FILIAL
                              SWD->(MsUnlock())
                           EndIf
                           If RecLock("SC7",.F.)
                              SC7->C7_ORIGEM := "EICPO400"
                              SC7->C7_NUMIMP := SW6->W6_PO_NUM
                              SC7->(MsUnlock())
                           EndIf
                        EndIf
                     else
                        alert("Pedido de compra n„o sera gerado, produto EIC" + SWD->WD_DESPESA + " n„o cadastrado no sistema!")
                     EndIf
                  else
                     aPosFCIF := aScan(aDesFCIF, {|x| Alltrim(x) == SWD->WD_DESPESA})

                     If aPosFCIF <> 0
                        aDel(aDesFCIF,aPosFCIF)
                        aSize(aDesFCIF,nNumDCIF-1)
                        nNumDCIF := Len(aDesFCIF)
                     EndIf

                     cQuery := " SELECT COUNT(DISTINCT(WD_DESPESA)) AS TOT_DESPESA FROM " + RetSqlName("SWD")
                     cQuery += " WHERE WD_FILIAL = '"+xFilial("SWD")+"' "
                     cQuery += " AND WD_HAWB = '"+Alltrim(SWD->WD_HAWB)+"' "
                     cQuery += " AND WD_DESPESA IN " + FormatIn(cDespFCIF,"/")
                     cQuery += " AND WD_DESPESA <> '"+Alltrim(SWD->WD_DESPESA)+"' "
                     cQuery += " AND D_E_L_E_T_ = '' "

                     If Select("DESFRET") > 0
                        DESFRET->(dbCloseArea())
                     EndIf

                     DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'DESFRET', .T., .F.)

                     If DESFRET->(!EOF())
                        If DESFRET->TOT_DESPESA == nNumDCIF
                           cQuery := " SELECT WD_DESPESA, WD_FORN, WD_LOJA, WD_VALOR_R, WD_XCC, WD_XOBS, R_E_C_N_O_ FROM " + RetSqlName("SWD")
                           cQuery += " WHERE WD_FILIAL = '"+xFilial("SWD")+"' "
                           cQuery += " AND WD_HAWB = '"+Alltrim(SWD->WD_HAWB)+"' "
                           cQuery += " AND WD_DESPESA IN " + FormatIn(cDespFCIF,"/")
                           cQuery += " AND D_E_L_E_T_ = '' "
                           cQuery += " ORDER BY WD_XCC DESC "

                           If Select("AGLWD") > 0
                              AGLWD->(dbCloseArea())
                           EndIf

                           DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'AGLWD', .T., .F.)
                           
                           dbSelectArea("SB1")

                           While AGLWD->(!EOF())
                              If !SB1->(dbseek(xFilial("SB1")+"EIC"+AGLWD->WD_DESPESA))
                                 lProces := .F.
                                 Alert("Produto n„o cadastrado")
                                 Exit
                              EndIf
                              AGLWD->(dbSkip())
                           EndDo

                           If lProces
                              AGLWD->(dbGoTop())
                              If (AGLWD->WD_DESPESA $ cDespImp)
                                 cDeptoEIC := cDptoImp
                              EndIf
                              _aCabPC	:=	{{"C7_FILIAL" ,GetAdvFVal( "SYT","YT_X_FILIA",XFILIAL("SYT") + SW6->W6_IMPORT,1 )	,Nil},;
                                          {"C7_EMISSAO" ,dDataBase                                                            ,Nil},; 
                                          {"C7_FORNECE" ,AGLWD->WD_FORN                                                       ,Nil},;
                                          {"C7_LOJA"	  ,AGLWD->WD_LOJA	                                                      ,Nil},;
                                          {"C7_XDEPART" ,cDeptoEIC	                                                         ,Nil},;
                                          {"C7_COND"	  ,"005"          	                                                   ,Nil},;
                                          {"C7_CONTATO" ,"IMPORTACOES"                                                        ,Nil},;
                                          {"C7_NUMIMP"  ,SW6->W6_PO_NUM                                                       ,Nil},;
                                          {"C7_ORIGEM"  ,"EICPO400"	                                                         ,Nil}}
                              
                              
                              While AGLWD->(!EOF())
                                 cItem := SOMA1(cItem)

                                 _aItemPC :=	{{"C7_ITEM"	   ,cItem	                  ,Nil},;
                                             {"C7_PRODUTO"  ,"EIC"+AGLWD->WD_DESPESA   ,Nil},;
                                             {"C7_UM"	      ,SB1->B1_UM		            ,Nil},;   
                                             {"C7_QUANT"	   ,1             	         ,Nil},;
                                             {"C7_PRECO"	   ,AGLWD->WD_VALOR_R	      ,Nil},;
                                             {"C7_CC"	      ,AGLWD->WD_XCC             ,Nil},;     
                                             {"C7_XHAWB"    ,Alltrim(SWD->WD_HAWB)     ,Nil},;
                                             {"C7_NUMIMP"   ,SW6->W6_PO_NUM            ,Nil},;
                                             {"C7_OBS"	   ,AGLWD->WD_XOBS	         ,Nil}}
                                 
                                 AADD(aItens,_aItemPC)
                                 AGLWD->(dbSkip())
                              EndDo

                              cItem := SOMA1(cItem)

                              _aItemPC :=	{{"C7_ITEM"	   ,cItem	               ,Nil},;
                                          {"C7_PRODUTO"  ,"EIC"+SWD->WD_DESPESA  ,Nil},;
                                          {"C7_UM"	      ,SB1->B1_UM		         ,Nil},;   
                                          {"C7_QUANT"	   ,1             	      ,Nil},;
                                          {"C7_PRECO"	   ,SWD->WD_VALOR_R	      ,Nil},;
                                          {"C7_CC"	      ,SWD->WD_XCC            ,Nil},;     
                                          {"C7_XHAWB"    ,Alltrim(SWD->WD_HAWB)  ,Nil},;
                                          {"C7_NUMIMP"   ,SW6->W6_PO_NUM         ,Nil},;
                                          {"C7_OBS"	   ,SWD->WD_XOBS	         ,Nil}}
                              
                              AADD(aItens,_aItemPC)


                              Processa( {|| MsExecAuto( {|v,x,y,z| MATA120(v,x,y,z)},1,_aCabPC,aItens,3)  }, "Aguarde...", "Gerando pedido de compras...",.F.)
                     
                              If lMsErroAuto
                                 cDirArq := "\"
                                 cNomArq := "\"+cFunName+"-"+DToS(Date())+"-"+StrTran(Time(),":","")+".log"
                                                   
                                 cErro := VerErro(MostraErro(cDirArq,cNomArq),cDirArq,cNomArq)
                              
                                 FErase(cDirArq+cNomArq)

                                 ProcLogAtu("ERRO","EICDI500 - Pedido de compra nao incluido - Processo: " + Alltrim(SW6->W6_HAWB) + " Despesa: " + Alltrim(SWD->WD_DESPESA), cErro, "EICDESPESA" )

                                 Alert(cErro)
                              else
                                 M->WD_XPEDCOM := SC7->C7_NUM
                                                      
                                 AGLWD->(dbGoTop())
                                 
                                 aArea := GetArea()
                                 
                                 While AGLWD->(!EOF())
                                    SWD->(dbGoTo(AGLWD->R_E_C_N_O_))
                                    Reclock("SWD",.F.)
                                    SWD->WD_XPEDCOM := SC7->C7_NUM
                                    SWD->WD_XFILPC   := SC7->C7_FILIAL
                                    SWD->(msUnlock())
                                    AGLWD->(dbSkip())
                                 EndDo

                                 cQuery := " SELECT R_E_C_N_O_ FROM " + RetSqlName("SC7")
                                 cQuery += " WHERE C7_FILIAL = '"+SC7->C7_FILIAL+"' "
                                 cQuery += " AND C7_NUM = '"+SC7->C7_NUM+"' "
                                 cQuery += " AND C7_FORNECE = '"+SC7->C7_FORNECE+"' "
                                 cQuery += " AND C7_LOJA = '"+SC7->C7_LOJA+"' "
                                 cQuery += " AND D_E_L_E_T_ = '' "
                                                      
                                 If Select("C7TP") > 0
                                    C7TP->(dbCloseArea())
                                 EndIf

                                 DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'C7TP', .T., .F.)

                                 While C7TP->(!EOF())
                                    SC7->(dbGoTo(C7TP->R_E_C_N_O_))
                                    RecLock("SC7",.F.)
                                    SC7->C7_ORIGEM := "EICPO400"
                                    SC7->C7_NUMIMP := SW6->W6_PO_NUM
                                    SC7->(MsUnlock())
                                    C7TP->(dbSkip())
                                 EndDo
                                 
                                 RestArea(aArea)
                              EndIf
                           EndIf
                        EndIf
                     EndIf
                  Endif
               EndIf
            EndIf
         EndIf
      EndIf
   CASE PARAMIXB == "DELETA_DESP"
      If lAtvEIC
         dbSelectArea("SC7")
         SC7->(dbSetOrder(1))
         If SC7->(dbSeek(GetAdvFVal("SYT","YT_X_FILIA",XFILIAL("SYT")+SW6->W6_IMPORT,1) + SWD->WD_XPEDCOM ))
            cNumPed := SC7->C7_NUM 
            _aCabPC	:=	{{"C7_FILIAL" ,GetAdvFVal("SYT","YT_X_FILIA",XFILIAL("SYT")+SW6->W6_IMPORT,1)	,Nil},;
                        {"C7_NUM"     ,SC7->C7_NUM                                                    ,Nil},; 
                        {"C7_EMISSAO" ,SC7->C7_EMISSAO                                                ,Nil},; 
                        {"C7_FORNECE" ,SC7->C7_FORNECE                                                ,Nil},;
                        {"C7_LOJA"	  ,SC7->C7_LOJA                                                   ,Nil},;
                        {"C7_COND"	  ,SC7->C7_COND                                                   ,Nil},;
                        {"C7_XDEPART" ,SC7->C7_XDEPART                                                ,Nil},;
                        {"C7_FILENT"  ,SC7->C7_FILENT                                                 ,Nil}}
                        
                           
            _aItemPC :=	{{"C7_ITEM"	   ,SC7->C7_ITEM     ,Nil},;
                        {"C7_PRODUTO"  ,SC7->C7_PRODUTO  ,Nil},;
                        {"C7_UM"	      ,SC7->C7_UM		   ,Nil},;   
                        {"C7_QUANT"	   ,SC7->C7_QUANT   	,Nil},;
                        {"C7_PRECO"	   ,SWD->WD_VALOR_R	,Nil},;
                        {"C7_TOTAL"	   ,SWD->WD_VALOR_R	,Nil},;
                        {"C7_CC"	      ,SWD->WD_XCC      ,Nil},;     
                        {"C7_OBS"	   ,SWD->WD_XOBS	   ,Nil}}
                              
            Processa( {|| MSExecAuto( {|a,b,c,d,e| MATA120(a,b,c,d,e)},1,_aCabPC,{_aItemPC},5,.F.)}, "Aguarde...", "Excluindo pedido de compras...",.F.)
               
            If lMsErroAuto
               cDirArq := "\"
               cNomArq := "\"+cFunName+"-"+DToS(Date())+"-"+StrTran(Time(),":","")+".log"
                                 
               cErro := VerErro(MostraErro(cDirArq,cNomArq),cDirArq,cNomArq)

               FErase(cDirArq+cNomArq)

               ProcLogAtu("ERRO","EICDI500 - Pedido de compra nao excluido - Processo: " + Alltrim(SW6->W6_HAWB) + " Despesa: " + Alltrim(SWD->WD_DESPESA) + " Pedido: " + Alltrim(SWD->WD_XPEDCOM), cErro, "EICDESPESA" )

               If "j· foi movimentado" $ cErro  
                  Alert("A T E N « √ O ! ! !" + CRLF+CRLF+"Pedido de Compra " + SC7->C7_NUM + " j· foi faturado n„o È possivel excluir o mesmo"+CRLF+CRLF+"OBSERVA«√O:"+CRLF+"A despesa sera excluida mesmo sem a exclus„o do pedido de compra")
               Else
                  Alert(cErro)
               EndIf
            else  
               MsgInfo("Pedido " +Alltrim(cNumPed)+" excluido com sucesso","Exclus„o do Pedido de compra")
            EndIf
         EndIf
      EndIf
   CASE PARAMIXB == "INI_DI500RETVAL"
      SetVarNameLen(10)
ENDCASE                               

RETURN  

//-------------------------------------------------------------------
/*/{Protheus.doc} VerErro
Formata log obtido do retorno de ExecAuto
@author Rodrigo
@since 01/03/2021
@version 1.0
@return cErrRet, characters, erro ExecAuto formatado
@param cErroAuto, characters, erro ExecAuto n√£o formatado
@type function
/*/
//-------------------------------------------------------------------

Static Function VerErro(cErroAuto,cDirArq,cNomArq)

Local nLines      := MLCount(cErroAuto)
Local nErr        := 0
Local cErrRet     := ""
Local cConteudo   := "" 

Default cErroAuto := ""
Default cDirArq   := ""
Default cNomArq   := ""

	For nErr := 1 To nLines
	
		cConteudo := MemoLine(cErroAuto,,nErr)
		
		cErrRet += " " + cConteudo
		
		If Empty(cConteudo)
		
			Exit
			
		Endif
		
	Next 
	
	For nErr := 1 To nLines
		
		cConteudo := MemoLine(cErroAuto,,nErr)
		
		If At("< --",cConteudo) > 0
			
			cErrRet += " " + cConteudo
			
			Exit
			
		Endif
	
	Next
	
	While At("  ",cErrRet) > 0
	
		cErrRet := StrTran(cErrRet,"  "," ")
		
	EndDo
	
Return(AllTrim(cErrRet)) 

//-------------------------------------------------------------------
/*/{Protheus.doc} VldDados
Formata log obtido do retorno de ExecAuto
@author Rodrigo
@since 01/03/2021
@version 1.0
@return cErrRet, characters, erro ExecAuto formatado
@param cErroAuto, characters, erro ExecAuto n√£o formatado
@type function
/*/
//-------------------------------------------------------------------

Static Function VldDados(cTabela,cDado)
Local cQuery      := ""
Local lRet        := .F.
Default cTabela   := ""
Default cDado     := ""

If !Empty(cTabela) .and. !Empty(cDado)
   If cTabela == "CTT"
      cQuery := " SELECT COUNT(*) AS TOTAL FROM " + RetSqlName("CTT")
      cQuery += " WHERE CTT_FILIAL = '"+xFilial("CTT")+"' "
      cQuery += " AND CTT_CUSTO = '"+cDado+"' "
      cQuery += " AND D_E_L_E_T_ = '' "

      If Select("CTTX") > 0
         CTTX->(dbCloseArea())
      EndIf

      DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'CTTX', .T., .F.)

      If CTTX->TOTAL > 0
         lRet := .T.
      Else
         Alert("Centro de Custo n„o cadastrada no Sistema!")
      EndIf
   EndIF
Else
   Alert("Campos obrigatorios de preenchimento")
EndIf

Return lRet

*---------------------------------------*
User FUNCTION xdelPRE(cHawb)
*---------------------------------------*
local cquery:= "" 
local _cAlias:= ""

cquery:= " SELECT E2_HIST,R_E_C_N_O_ Registro FROM " + RETSQLNAME("SE2") + " SE2 "
cquery+= " WHERE SE2.D_E_L_E_T_=''     "
cquery+= " AND E2_HIST LIKE '%" + ALLTRIM(cHawb) + "%'"
cquery+= " AND E2_PREFIXO = 'EIC' " 
cquery+= " AND E2_TIPO = 'PRE' "
cquery+= " AND E2_HIST LIKE '%FRETE%' "

_cAlias:= GetNextAlias() 	
If Select(_cAlias) > 0
   ( _cAlias )->( dbCloseArea() )
EndIf

cQuery := ChangeQuery(cQuery)
dbUseArea(.t., "TOPCONN", TCGenQry(,,cquery), _cAlias, .t., .t.)

(_cAlias)->(DbGoTop())
WHILE ! (_cAlias)->(EOF())

   //msginfo( "(_calias)->Registro " + strzero( (_cAlias)->Registro  , 6 ) 

   SE2->(dbgoto((_cAlias)->Registro))

   //msginfo( "registro do SE2 : " + STRZERO( SE2->(RECNO()) )  )

   Reclock("SE2",.f.)
   SE2->(DBDELETE())
   SE2->(MSUNLOCK())

   incproc("Atualizando o registro " + STRZERO( (_cAlias)->Registro )   ) 
   (_cAlias)->(dbskip())

ENDDO

return 
