#include 'protheus.ch'
#include 'parmtype.ch'

//--------------------------------------------------------------------
/*/{Protheus.doc} FTOUA017
Enviar XML do documento de saída (nota fiscal de venda)
@author Caio
@since 07/02/2020
@version 1.0
/*/
//--------------------------------------------------------------------

User Function TESTE017()

	U_FTOUA017(.F.,.F.,"","","01","01")
	
Return(Nil)

User function FTOUA017(lReprocess, lLote, cIdReg, cIdPZC, cEmpPrep, cFilPrep)

Local aHeader       := {"Content-Type: application/json"}
Local cToken 		:= ""
Local cIdPZB    	:= ""
Local aCriaServ		:= {}
Local cQuery 		:= ""
Local aRequest		:= {}
Local cWa		    := ""
Local cCHAVE		:= ""
Local oRet			:= Nil  
Local nQtdReg		:= 0
Local cDirArq       := ""

Default lLote		:= .F.
Default lReprocess	:= .F.
Default cIdReg		:= ""
Default cIdPZC		:= ""	

Private cIdEnt      := ""
Private cError      := ""

	RpcSetEnv(cEmpPrep, cFilPrep)
       
	//Requisicao do acesso
	oREST := FTOUA003():New()
	oREST:RESTConn() 
	lReturn := oRest:lRetorno
	cToken  := oREST:cToken	
	
	If !lReturn
        
        Conout("Falha na autenticação Transpofrete")
        
    Else
		
		cDirArq := GetMv("FT_OUA017C",,"\TRANSPO\XML_OUT\")
		
		FwMakeDir(cDirArq)

		dbSelectArea("PR1")
		PR1->(dbSetOrder(2)) //PR1_FILIAL + PR1_ALIAS + PR1_CHAVE
		
		dbSelectArea("SF2")
		SF2->(dbSetOrder(1)) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
        
        //Verifica se existe dados a processar
        
        dbSelectArea("PR1")
        PR1->(dbSetOrder(1))
        
        cDtIniNF := GetMv("FT_OUA017A",,"20200201")
        
        cQuery += CRLF + RTrim("SELECT *                                                                               ") 
        cQuery += CRLF + RTrim("  FROM ( SELECT F2_FILIAL                                                              ")           
        cQuery += CRLF + RTrim("              , F2_DOC                                                                 ")
        cQuery += CRLF + RTrim("              , F2_SERIE                                                               ")
        cQuery += CRLF + RTrim("              , F2_CLIENTE                                                             ")
        cQuery += CRLF + RTrim("              , F2_LOJA                                                                ")
        cQuery += CRLF + RTrim("              , F2_EMISSAO                                                             ")
        cQuery += CRLF + RTrim("              , F3_CHVNFE                                                              ")
        cQuery += CRLF + RTrim("              , SF2.R_E_C_N_O_ AS RECNO_SF2                                            ")
        cQuery += CRLF + RTrim("              , PR1.R_E_C_N_O_ AS RECNO_PR1                                            ")
        cQuery += CRLF + RTrim("           FROM " + RetSqlName("SF2") + " SF2                                          ")
        cQuery += CRLF + RTrim("           INNER JOIN " + RetSqlName("SF3") + " SF3 ON SF3.D_E_L_E_T_    = ' '         ")
        cQuery += CRLF + RTrim("                                AND F3_FILIAL         = F2_FILIAL                      ")
        cQuery += CRLF + RTrim("                                AND F3_NFISCAL        = F2_DOC                         ")
        cQuery += CRLF + RTrim("                                AND F3_SERIE          = F2_SERIE                       ")
        cQuery += CRLF + RTrim("                                AND F3_CLIEFOR         = F2_CLIENTE                    ")
        cQuery += CRLF + RTrim("                                AND F3_LOJA           = F2_LOJA                        ")
        cQuery += CRLF + RTrim("                                AND F3_ENTRADA        = F2_EMISSAO                     ")
        cQuery += CRLF + RTrim("                                AND F3_ESPECIE        = F2_ESPECIE                     ")
        cQuery += CRLF + RTrim("                                AND UPPER(F3_DESCRET) = 'AUTORIZADO O USO DA NF-E'     ")
        cQuery += CRLF + RTrim("           LEFT OUTER JOIN " + RetSqlName("PR1") + " PR1 ON PR1.D_E_L_E_T_ = ' '       ")
        cQuery += CRLF + RTrim("                                AND PR1_FILIAL     = ' '                               ")
        cQuery += CRLF + RTrim("                                AND PR1_ALIAS      = 'SF2'                             ")
        cQuery += CRLF + RTrim("                                AND PR1_RECNO      = SF2.R_E_C_N_O_                    ")
        cQuery += CRLF + RTrim("                                AND PR1_TIPREQ     = '1'                               ")
        cQuery += CRLF + RTrim("                                AND PR1_CHAVE      = F2_FILIAL  +                      ")
        cQuery += CRLF + RTrim("                                                     F2_DOC     +                      ")
        cQuery += CRLF + RTrim("                                                     F2_SERIE   +                      ")
        cQuery += CRLF + RTrim("                                                     F2_CLIENTE +                      ")
        cQuery += CRLF + RTrim("                                                     F2_LOJA    +                      ")
        cQuery += CRLF + RTrim("                                                     F2_EMISSAO                        ")
        cQuery += CRLF + RTrim("          WHERE SF2.D_E_L_E_T_  = ' '                                                  ")
        
        cQuery += CRLF + RTrim("            AND SF2.F2_DOC = '900000001' ")
        
        cQuery += CRLF + RTrim("            AND SF2.F2_EMISSAO >= '" + cDtIniNF + "' ) TEMP                            ") 
        cQuery += CRLF + RTrim(" WHERE NVL(RECNO_PR1,0) = 0                                                            ")
        cQuery += CRLF + RTrim(" ORDER BY RECNO_SF2 ASC                                                                ")
                                    
        cQuery := ChangeQuery(cQuery)
          
        dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),(cWa := GetNextAlias()),.T.,.T.)
        
        While (cWa)->(!Eof())
        	
        	If RecLock("PR1",.T.)

				PR1->PR1_FILIAL := xFilial("PR1")
				PR1->PR1_ALIAS  := "SF2"
				PR1->PR1_RECNO  := (cWa)->RECNO_SF2
				PR1->PR1_TIPREQ := "1"
				PR1->PR1_DATINT := Date()
				PR1->PR1_HRINT	:= Time()		
				PR1->PR1_STINT  := "P"
				PR1->PR1_OBSERV := (cWa)->F3_CHVNFE
				PR1->PR1_CHAVE  := (cWa)->F2_FILIAL + (cWa)->F2_DOC + (cWa)->F2_SERIE + (cWa)->F2_CLIENTE + (cWa)->F2_LOJA + (cWa)->F2_EMISSAO
				
				PR1->(MsUnlock())
				
			Endif
			
        	(cWa)->(DbSkip())
        
        EndDo
        
        dbCloseArea()
        
        cQuery := CRLF + RTrim(" SELECT PR1.R_E_C_N_O_ AS RECNO_PR1                   ")
        cQuery += CRLF + RTrim("   FROM " + RetSqlName("PR1") + " PR1                 ")
        cQuery += CRLF + RTrim("  WHERE PR1.D_E_L_E_T_     = ' '                      ")
        cQuery += CRLF + RTrim("    AND PR1.PR1_FILIAL     = '" + xFilial("PR1") + "' ")
        cQuery += CRLF + RTrim("    AND PR1.PR1_ALIAS      = 'SF2'                    ")
        cQuery += CRLF + RTrim("    AND PR1.PR1_TIPREQ     = '1'                      ")
        cQuery += CRLF + RTrim("    AND PR1.PR1_STINT      = 'P'                      ")
                                            
        cQuery := ChangeQuery(cQuery)
          
        dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),(cWa := GetNextAlias()),.T.,.T.)
        
        Count to nQtdReg
        
        (cWa)->(DbGoTop())
		
		cIdEnt := getCfgEntidade(@cError)

        If (cWa)->(Eof())
        	
        	If GetMV("FT_CONOUTX",,.T.)
        		
        		Conout(ProcName(0) + " - " + DToC(Date()) + " - " + Time() + " - Não há dados para processamento.")
        		
        	Endif
        	
        Else
	        
	        aCriaServ := U_MonitRes("000017", 1, nQtdReg)
			cIdPZB 	  := aCriaServ[2]
	        
			While (cWa)->(!Eof())
				
				PR1->(DbGoTo((cWa)->RECNO_PR1))
				
				cChave   := Alltrim(PR1->PR1_CHAVE)
				cJson    := ""
				cJsoRec  := ""
				cNomeArq := Alltrim(PR1->PR1_OBSERV) + "-NFE.XML"
				
				SF2->(DbGoTo(PR1->PR1_RECNO))
				
				lFileOK := .F.
				
				If File(cArquivo := cDirArq+cNomeArq)
					
					lFileOK := .T.
				
				Elseif !Empty(cError)
				
					cMensagem := cError
					U_MonitRes("000017",2,,cIdPZB,PadR(cMensagem,TamSX3("PZD_DESC")[1]),.F.,cChave,cJson,cJsoRec,cChave,lReprocess,lLote,cIdPZC)
					
				Else
					
					StaticCall(SPEDNFE,SpedPExp,cIdEnt,SF2->F2_SERIE,SF2->F2_DOC,SF2->F2_DOC,cDirArq,.F.,,,"","",1)
				
					If !File(cArquivo)
				
						lFileOK := .F.
						
						cMensagem := "Falha na geração do arquivo " + cArquivo + "."
						U_MonitRes("000017",2,,cIdPZB,PadR(cMensagem,TamSX3("PZD_DESC")[1]),.F.,cChave,cJson,cJsoRec,cChave,lReprocess,lLote,cIdPZC)
						
					Else
						
						lFileOK := .T.
						
					Endif
					 
				Endif
				
				If lFileOK
				 	
				 	__CopyFile(cArquivo,(cArqSys := "\system\"+cNomeArq))
				 	
				 	If !File(cArqSys)
	
						cMensagem := "Falha ao copiar o arquivo " + cArquivo + " para \system\."
						U_MonitRes("000017",2,,cIdPZB,PadR(cMensagem,TamSX3("PZD_DESC")[1]),.F.,cChave,cJson,cJsoRec,cChave,lReprocess,lLote,cIdPZC)
						
					Else
					
						cEnvio := EnviaXML(cToken,cNomeArq,cArquivo,cArqSys)
						
						If !Empty(cEnvio)
		
							cMensagem := cEnvio
							U_MonitRes("000017",2,,cIdPZB,PadR(cMensagem,TamSX3("PZD_DESC")[1]),.F.,cChave,cJson,cJsoRec,cChave,lReprocess,lLote,cIdPZC)
							
						Else
		
							cMensagem := "Integrado" 
							U_MonitRes("000017",2,,cIdPZB,PadR(cMensagem,TamSX3("PZD_DESC")[1]),.T.,cChave,cJson,cJsoRec,cChave,lReprocess,lLote,cIdPZC)
							fErase(cArqSys) 
							fErase(cArquivo) 
							
						Endif
						
					Endif 
					
					fErase(cArqSys) 
					
				Endif	
			
				(cWa)->(dbSkip())
				
			EndDo
			 
			//Finaliza o processo na PZB
			U_MonitRes("000017",3,,cIdPZB,,.T.)
		
		Endif
		
		dbSelectArea(cWa)
		dbCloseArea()
		
	Endif 
	
	RpcClearEnv()
	
Return(Nil)

//--------------------------------------------------------------------
/*/{Protheus.doc} EnviaXML
Envia arquivo XML para Transpofrete por multipart/form-data (implementação)
@author Caio
@since 04/03/2020
@version 1.0
@type function
/*/
//--------------------------------------------------------------------

Static Function EnviaXML(cToken,cNomeArq,cArquivo,cArqSys)

Local cUrl       := "http://homolog.transpofrete.com.br/api"
Local cPath      := "/importacaoXML/upload?token="
Local cEndPoint  := cUrl+cPath+cToken
Local nTimeOut   := 120
Local aHeadOut   := {}
Local cHeadRet   := ""
Local sPostRet   := ""
Local cRet       := .F.

Default cToken   := ""
Default cNomeArq := ""
Default cArquivo := ""
Default cArqSys  := ""

	aadd(aHeadOut,'User-Agent: Mozilla/4.0 (compatible; Protheus '+GetBuild()+')')
	//aadd(Content-Type: multipart/form-data; boundary=TotvsBoundaryTest')                                      //Se desejar informar o boundary
	aadd(aHeadOut,'Content-Type: multipart/form-data; boundary=--------------------------123313543765056229941092')

	cPostParms := 'Content-Disposition: form-data; name="arquivo"; filename="' + cArqSys + '"' + CRLF     //Envio de Arquivo especificando o Content-Type
    
	sPostRet := HttpPost(cEndPoint,"",cPostParms,nTimeOut,aHeadOut,@cHeadRet)
	
	if !empty(sPostRet)
	    //conout("HttpPost Ok ")
	    //varinfo("WebPage", sPostRet)
	    cRet := ""
	else
	    //conout("HttpPost Failed.")
	    //varinfo("Header", cHeadRet)
	    cRet := cHeadRet
	Endif

Return(cRet)
			
//			If lFileOK
//				
//				
//			Endif
//			 
//			
//			If !SF3->(dbSeek(cChave))
//				
//				cMensagem := "Nota Fiscal não '" + cChave + "' encontrada na tabela SF3 - Livros Fiscais."
//				U_MonitRes("000017",2,,cIdPZB,PadR(cMensagem,TamSX3("PZD_DESC")[1]),.F.,cChave,cJson,cJsoRec,cChave,lReprocess,lLote,cIdPZC)
//				
//			Elseif !SA1->(dbSeek(xFilial("SA1")+SF3->F3_CLIEFOR+SF3->F3_LOJA))
//				
//				cMensagem := "Cliente " + cCliente + " não encontrado."
//				U_MonitRes("000017",2,,cIdPZB,PadR(cMensagem,TamSX3("PZD_DESC")[1]),.F.,cChave,cJson,cJsoRec,cChave,lReprocess,lLote,cIdPZC)
//			
//			Elseif Empty(SF3->F3_DTCANC)
//				
//				cMensagem := "Não consta cancelamento para a nota fiscal '" + cChave + "'."
//				U_MonitRes("000017",2,,cIdPZB,PadR(cMensagem,TamSX3("PZD_DESC")[1]),.F.,cChave,cJson,cJsoRec,cChave,lReprocess,lLote,cIdPZC)
//				
//			//Elseif Empty(SF3->F3_CHVNFE)
//			//	
//			//	cMensagem := "CHVNFE da nota fiscal '" + cChave + "' não preenchido."
//			//	U_MonitRes("000017",2,,cIdPZB,PadR(cMensagem,TamSX3("PZD_DESC")[1]),.F.,cChave,cJson,cJsoRec,cChave,lReprocess,lLote,cIdPZC)
//				
//			Elseif !Empty(SF3->F3_CHVNFE) .And. Alltrim(SF3->F3_CHVNFE) != Alltrim(PR1->PR1_OBSERV)
//				
//				cMensagem := "CHVNFE da nota fiscal '" + cChave + "' não preenchido."
//				U_MonitRes("000017",2,,cIdPZB,PadR(cMensagem,TamSX3("PZD_DESC")[1]),.F.,cChave,cJson,cJsoRec,cChave,lReprocess,lLote,cIdPZC)
//				
//			Elseif .Not. Alltrim(SF3->F3_CODRET) $ "TM" .Or. Empty(SF3->F3_DESCRET)
//				
//				cMensagem := "Retorno do cancelamento da nota fiscal '" + cChave + "' não obtido junto a Sefaz."
//				U_MonitRes("000017",2,,cIdPZB,PadR(cMensagem,TamSX3("PZD_DESC")[1]),.F.,cChave,cJson,cJsoRec,cChave,lReprocess,lLote,cIdPZC)
//			
//			Elseif Upper(Alltrim(SF3->F3_DESCRET)) != "CANCELAMENTO DE NF-E HOMOLOGADO" 
//				
//				cMensagem := "Cancelamento da nota fiscal '" + cChave + "' não homologado pela Sefaz."
//				U_MonitRes("000017",2,,cIdPZB,PadR(cMensagem,TamSX3("PZD_DESC")[1]),.F.,cChave,cJson,cJsoRec,cChave,lReprocess,lLote,cIdPZC)
//			
//			Else
//				
//				If !Empty(SF3->F3_CHVNFE)
//					
//					cChvNF := SF3->F3_CHVNFE
//					
//				Endif

//			        
//			Endif
