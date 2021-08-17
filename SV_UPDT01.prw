#include "Protheus.ch"
#include "Topconn.ch"

*-----------------------*
User Function SV_UPDT01()
*-----------------------*
Local bFunc := {|| doUpdate() }

u_InfraUpds(bFunc)
	   
Return NIL

*------------------------*
Static Function DoUpdate()
*------------------------* 
Local lObrigat := .T.
Local lNotObgt := .F.

Local lUsado   := .t.
Local lNotUsd  := .f.

Local lD2_ZSld_R := .F.

Private cLog := ""                      
                                        
Begin Sequence
   SX3->(dbSetOrder(2))
   lD2_ZSld_R := SX3->(dbSeek("D2_ZSLD_R"))
   SX3->(dbSetOrder(1))


    ///////////////  Ajustes no SW2
	//SW2
	//           1     2        3          4     5     6     7              8                           9    
    //        cArq, cOrdPar, cCpo,      cTip, nTam, nDec, cTit,          cDsc,                       cPic, 
    //        10    11         12     13     14    15   16     17    18        19     20    21     22     23     24    
    //        cVld, lUsado,    cRlc, cF3,   cGat, cBrw, cVis, cCtx, lObrigat, cVldU, cBox, cWhen, cIniB, cGSxg, cFld


  	u_AddSX3("SA2", ""     ,"A2_XLOGO" , "C" , 20  , 0,   "Logo" ,"Sub-pasta e nome do logo","@!",;
  	          " ",  lUsado, "",   "" , "",   "N",  "R",  "R", lNotObgt,  "",   "",    ""  , "",     "",     "")


    ///////////////  Ajustes no SC1 
	//SC1
	//           1     2        3          4     5     6     7              8                           9    
    //        cArq, cOrdPar, cCpo,      cTip, nTam, nDec, cTit,          cDsc,                       cPic, 
    //        10    11         12     13     14    15   16     17    18        19     20    21     22     23     24    
    //        cVld, lUsado,    cRlc, cF3,   cGat, cBrw, cVis, cCtx, lObrigat, cVldU, cBox, cWhen, cIniB, cGSxg, cFld


  	u_AddSX3("SC1", ""     ,"C1_XQE1" , "N" , 05  , 0,   "Qtd por Emb" ,"Quantidade por embalagem","99999",;
  	          " ",  lUsado, "",   "" , "",   "N",  "V",  "R", lNotObgt,  "",   "",    ""  , "",     "",     "")

  	u_AddSX3("SC1", ""     ,"C1_XQTDEM1" , "N" , 10  , 0, "Qtd de Embal" ,"Quantidade de embalagem","9999999999",;
  	          " ",  lUsado, "",   "" , "",   "N",  "R",  "R", lNotObgt,  "",   "",    ""  , "",     "",     "")
                                                                                                               
  	u_AddSX3("SC1", ""     ,"C1_XCUBAGE" , "N" , 15  , 4, "Cubagem" ,"Cubagem do Item","@E 9,999,999,999.9999",;
  	          " ",  lUsado, "",   "" , "",   "N",  "R",  "R", lNotObgt,  "",   "",    ""  , "",     "",     "")

    // ChangeDic(cDicPar,cKey,cCampo,xValue, bCond)
     u_ChangeDic("SX3","C1_QUANT","X3_VLDUSER",'U_SvValQtd(M->C1_QUANT)', {|| .t.})      

    //  AddSX7(cCampo,        cSequenc,        cRegra,      cCDomin, cTipo, cSeek, cAlias, nOrdem, cChave, cCondic)
    u_AddSX7("C1_PRODUTO" ,/* cSequenc */, "SB5->B5_QE1", "C1_XQE1", "P", "S", "SB5", 1, "xfilial('SB5')+M->C1_PRODUTO")



/////AddSX3(cArq, cOrdPar, cCpo, cTip, nTam, nDec, cTit, cDsc, cPic, cVld, lUsado, cRlc, cF3, cGat, cBrw, cVis, cCtx, lObrigat, cVldU, cBox, cWhen, cIniB, cGSxg, cFld)

    ////////////  Ajustes no SW2
  	u_AddSX3("SW2", ""     ,"W2_XDT_ETD" , "D" , 08  , 0,   "ETD" ,"Data estimada partida","",;
  	          " ",  lUsado, "",   "" , "",   "N",  "A",  "R", lNotObgt,  "",   "",    ""  , "",     "",     "1")

  	u_AddSX3("SW2", ""     ,"W2_XDT_ETA" , "D" , 08  , 0,   "ETA" ,"Data estimada chegada","",;
  	          " ",  lUsado, "",   "" , "",   "N",  "A",  "R", lNotObgt,  "",   "",    ""  , "",     "",     "1")

 
    ////////////  Ajustes no SW3  
  	u_AddSX3("SW3", ""     ,"W3_XQE1" , "N" , 05  , 0,   "Qtd por Emb" ,"Quantidade por embalagem","99999",;
  	          " ",  lUsado, "",   "" , "",   "N",  "V",  "R", lNotObgt,  "",   "",    ""  , "",     "",     "")

  	u_AddSX3("SW3", ""     ,"W3_XQTDEM1" , "N" , 10  , 0, "Qtd de Embal" ,"Quantidade de embalagem","9999999999",;
  	          " ",  lUsado, "",   "" , "",   "N",  "R",  "R", lNotObgt,  "",   "",    ""  , "",     "",     "")
                                                                                                               
  	u_AddSX3("SW3", ""     ,"W3_XCUBAGE" , "N" , 15  , 4, "Cubagem" ,"Cubagem do Item","@E 9,999,999,999.9999",;
  	          " ",  lUsado, "",   "" , "",   "N",  "R",  "R", lNotObgt,  "",   "",    ""  , "",     "",     "")





    // ChangeDic(cDicPar,cKey,cCampo,xValue, bCond)
     u_ChangeDic("SX3","W3_QTDE","X3_VLDUSER",'U_SvValQtd(M->W3_QTDE,"SW3")', {|| .t.})      

    //  AddSX7(cCampo,        cSequenc,        cRegra,      cCDomin, cTipo, cSeek, cAlias, nOrdem, cChave, cCondic)
    u_AddSX7("W3_COD_I" ,/* cSequenc */, "SB5->B5_QE1", "W3_ZQE1", "P", "S", "SB5", 1, "xfilial('SB5')+M->W3_COD_I")



    ////////////  Ajustes no SW6
    //           1    2        3     4     5     6     7     8     9     10    11      12    13   14    15    16    17    18        19     20    21     22     23     24
    //   AddSX3       (cArq, cOrdPar, cCpo, cTip, nTam, nDec, cTit, cDsc, cPic, cVld, lUsado, cRlc, cF3, cGat, cBrw, cVis, cCtx, lObrigat, cVldU, cBox, cWhen, cIniB, cGSxg, cFld)

  	u_AddSX3("SW6", ""     ,"W6_XAVARIA" , "C" , 200  , 0,   "Avarias" ,"Avarias","@!",;
  	          " ",  lUsado, "",   "" , "",   "N",  "R",  "R", lNotObgt,  "",   "",    ""  , "",     "",     "1")

  	u_AddSX3("SW6", ""     ,"W6_XAMOS" , "C" , 200  , 0, "Amostras" ,"Amostras","@!",;
  	          " ",  lUsado, "",   "" , "",   "N",  "R",  "R", lNotObgt,  "",   "",    ""  , "",     "",     "1")


    ////////////  Ajustes no SW7
  	u_AddSX3("SW7", ""     ,"W7_XQE1" , "N" , 05  , 0,   "Qtd por Emb" ,"Quantidade por embalagem","99999",;
  	          " ",  lUsado, "",   "" , "",   "N",  "V",  "R", lNotObgt,  "",   "",    ""  , "",     "",     "")

  	u_AddSX3("SW7", ""     ,"W7_XQTDEM1" , "N" , 10  , 0, "Qtd de Embal" ,"Quantidade de embalagem","9999999999",;
  	          " ",  lUsado, "",   "" , "",   "N",  "R",  "R", lNotObgt,  "",   "",    ""  , "",     "",     "")
                                                                                                               
  	u_AddSX3("SW7", ""     ,"W7_XCUBAGE" , "N" , 15  , 4, "Cubagem" ,"Cubagem do Item","@E 9,999,999,999.9999",;
  	          " ",  lUsado, "",   "" , "",   "N",  "R",  "R", lNotObgt,  "",   "",    ""  , "",     "",     "")

    // ChangeDic(cDicPar,cKey,cCampo,xValue, bCond)
     u_ChangeDic("SX3","W7_QTDE","X3_VLDUSER",'U_SvValQtd(M->W7_QTDE,"SW7")', {|| .t.})      

    //  AddSX7(cCampo,        cSequenc,        cRegra,      cCDomin, cTipo, cSeek, cAlias, nOrdem, cChave, cCondic)
    u_AddSX7("W7_COD_I" ,/* cSequenc */, "SB5->B5_QE1", "W7_ZQE1", "P", "S", "SB5", 1, "xfilial('SB5')+M->W7_COD_I")



    /////////  PARA CONSULTA
                                                                                                       
    // AddSX7(cCampo, cSequenc, cRegra, cCDomin, cTipo, cSeek, cAlias, nOrdem, cChave, cCondic)
	// u_AddSX2("ZCO","Tabela de Vinculação Operações Casadas","","E","")    
	// u_AddSIX("ZCO","1","ZCO_FILIAL+ZCO_NFENT+ZCO_SEENT+ZCO_FOENT+ZCO_LOENT+ZCO_ITENT","","","Ord1")
	// u_AddSX6(, "MV_TESREMT", "C", "TES de remessa para armazem de","Terceiros",, "650")
	// u_AddSXB(cAlias, cTipo, cSeq, cCol, cDescr, cContem, cWContem)         
	// anterior.... u_ChangeDic("SX3","C5_NUM","X3_RELACAO", 'IF(Type("l410Auto") == "L" .And. l410Auto, "", GetSXENum("SC5"))')
	// não alterar mais... u_ChangeDic("SX3","C5_NUM","X3_RELACAO", 'IF(Type("l410Auto") == "L" .And. l410Auto .And. Type("lPV_Num") == "L" .And. lPV_Num, "", GetSXENum("SC5"))')

End Sequence

return cLog