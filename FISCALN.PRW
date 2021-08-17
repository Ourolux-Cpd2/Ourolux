#INCLUDE "protheus.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#include "vkey.ch"         
#include 'ap5mail.ch'


//_____________________________________________________________________________
/*/{Protheus.doc} Manunfs
Rotina de espelho da NF.

@author Juscelino Santos | Icaro Queiroz
@since 20 de Novembro de 2015
@owner FIT Gestao for Ourolux
/*/
//_____________________________________________________________________________

User Function Manunfs() 
Private _cCnpj:=Space(14)

@ 200,1 TO 270,450 DIALOG oLeTxt TITLE OemToAnsi("Informe o CNPJ")

@ 010,50 MsGet _cCnpj F3 "VS1" Size 057,10 Of oLeTxt PIXEL 
@ 010,162 BMPBUTTON TYPE 01 ACTION Processa({ || U_FISCALN(_cCnpj)},,'Aguarde Pesquisando Dados do Cliente : '+_cCnpj) //execNota(_cCnpj) 
@ 010,192 BMPBUTTON TYPE 02 ACTION Close(oLeTxt)
Activate Dialog oLeTxt Centered     

Return         

//_____________________________________________________________________________
/*/{Protheus.doc} Manunfs
Rotina de espelho da NF.

@author Juscelino Santos | Icaro Queiroz
@since 20 de Novembro de 2015
@owner FIT Gestao for Ourolux
/*/
//_____________________________________________________________________________

User Function FISCALN(_cCnpj)

// Posicao do elemento do vetor aRotina que a MsNewGetDados usara como referencia  

// = = = = = = = = = = = = = = = = 
// Maurício Aureliano - 13/04/2018
// Chamado: I1802-167 - TRAVAR O CAMPO DE PREÇO NO SIMULADOR DE ESPELHOS
// = = = = = = = = = = = = = = = =
//Local aAlter       	:= {"TRB_CODPRO","TRB_DOCORI","TRB_SERIE","TRB_QUANT","TRB_VLUNIT","TRB_CFOP","TRB_CFOP2"}

Local aAlter       	:= {"TRB_CODPRO","TRB_DOCORI","TRB_SERIE","TRB_QUANT"}
Local nSuperior    	:= 001           	// Distancia entre a MsNewGetDados e o extremidade superior do objeto que a contem
Local nEsquerda    	:= 001           	// Distancia entre a MsNewGetDados e o extremidade esquerda do objeto que a contem
Local nInferior    	:= 074          	// Distancia entre a MsNewGetDados e o extremidade inferior do objeto que a contem
Local nDireita     	:= 254           	// Distancia entre a MsNewGetDados e o extremidade direita  do objeto que a contem
Local nOpc         	:= NIL				// GD_INSERT+GD_DELETE+GD_UPDATE                                                                            
Local cLinhaOk     	:= "AllwaysTrue"    // Funcao executada para validar o contexto da linha atual do aCols                  
Local cTudoOk      	:= "AllwaysTrue"    // Funcao executada para validar o contexto geral da MsNewGetDados (todo aCols)      
Local cIniCpos     	:= ""               // Nome dos campos do tipo caracter que utilizarao incremento automatico.Este parametro deve ser no formato "+<nome do primeiro campo>+<nome do segundo campo>+..."                                                               
Local nFreeze      	:= 000              // Campos estaticos na GetDados.                                                               
Local nMax         	:= 999              // Numero maximo de linhas permitidas. Valor padrao 99                           
Local cCampoOk     	:= "AllwaysTrue"    // Funcao executada na validacao do campo                                           
Local cSuperApagar 	:= ""               // Funcao executada quando pressionada as teclas <Ctrl>+<Delete>                    
Local cApagaOk     	:= "AllwaysTrue"    // Funcao executada para validar a exclusao de uma linha do aCols                   
//Local aHead        	:= {}               // Array a ser tratado internamente na MsNewGetDados como aHeader                    
//Local aCol         	:= {}               // Array a ser tratado internamente na MsNewGetDados como aCols                      
Local _nTotReg		:= 000
Local aSizeAut	:= {}                
Local aButton 	:= {}          
Local _oFont2  := TFont():New('Arial',,-24,.T.,.T.) 
Local n 
Local oArea		   	:= FWLayer():New()

PRIVATE cCadastro	:= "Notas de Saida Devolução"
Private aHeader        	:= {}               // Array a ser tratado internamente na MsNewGetDados como aHeader                    
Private aCols         	:= {}               // Array a ser tratado internamente na MsNewGetDados como aCols                      

Private aHeader2       	:= {}               // Array a ser tratado internamente na MsNewGetDados como aHeader                    
Private aCols2         	:= {}               // Array a ser tratado internamente na MsNewGetDados como aCols                      

Private aHeader3       	:= {}               // Array a ser tratado internamente na MsNewGetDados como aHeader                    
Private aCols3         	:= {}               // Array a ser tratado internamente na MsNewGetDados como aCols                      

Private _cnpjm :=_cCnpj

Private oGDAProd            
Private oGet1,oGet2            
Private nGet1,nGet6               
                                     
aAdd(aButton,{"Relatorio",{	||	U_INV12(oGDAProd,oGet1,oGet2,nGet1,nGet6)},"Gerar Relatorio"}) 
aAdd(aButton,{"E-Mail   ",{	||	U_MailReq()},"Gerar E-Mail"}) 

aImpostos := {}
aTitles   := {"Nota Fiscal","Duplicatas"} //"Nota Fiscal"###"Duplicatas"
aDupl     := {}
aFlHead   := { "Vencimento","Valor" } //"Vencimento"###"Valor"


	aSizeAut := MsAdvSize(,.F.,345)
	aObjects := {}
	AAdd( aObjects, { 0,    41, .T., .F. } )
	AAdd( aObjects, { 100, 100, .T., .T. } )
	AAdd( aObjects, { 0,    75, .T., .F. } )

	aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }

	aPosObj := MsObjSize( aInfo, aObjects )
        
aPosGet := MsObjGetPos(aSizeAut[3]-aSizeAut[1],310,;
			{{8,23,78,128,163,200,250,270},;
			{8,32,95,130,170,204,260},;
			{7,32,68,95,135,165,227,250},;
			{8,32,75,200,250},;
			{5,70,160,205,295},;
			{6,34,200,215},;
			{6,34,106,139},;
			{6,34,245,268,220},;
			{5,50,150,190},;
			{277,130,190,293,205}})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega aHeader                                 			           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AADD(aHeader,{"Cod.Produto"	     	,"TRB_CODPRO"	,"@!"				   ,15,0,"","û","C","SB1","V"} )
AADD(aHeader,{"Descrição"		 	,"TRB_DESC"	   	,"@!"				   ,30,0,"","û","C",""   ,"V"} )
AADD(aHeader,{"Doc.Origem"	     	,"TRB_DOCORI"	,"@!"				   ,3,0 ,"","û","C",""   ,"V"} )
AADD(aHeader,{"Serie"	         	,"TRB_SERIE"	,"@!"				   ,3,0 ,"","û","C",""   ,"V"} )
AADD(aHeader,{"Saldo Disp.Devedor"	,"TRB_SALDEV"   ,"@E 999,999,999.99"    ,14,2,"","û","N",""   ,"V"} )
AADD(aHeader,{"Quantidade"         	,"TRB_QUANT"    ,"@E 999,999,999.99"    ,14,2,"","û","N",""   ,"V"} )
AADD(aHeader,{"Valor Unitario"     	,"TRB_VLUNIT"   ,"@E 999,999,999.99"    ,14,2,"","û","N",""   ,"V"} )
AADD(aHeader,{"Valor Total"        	,"TRB_VLTOT"    ,"@E 999,999,999.99"    ,14,2,"","û","N",""   ,"V"} )
AADD(aHeader,{"Tipo Entrada"	  	,"TRB_CFOP"	   	,"@!"				   ,3,0 ,"","û","C","SF4","V"} )
AADD(aHeader,{"Cod.Fiscal"	    	,"TRB_CFOP2"	,"@!"				   ,5,0 ,"","û","C","13","V"} )
AADD(aHeader,{"NCM"	    	     	,"TRB_NCM"	    ,"@!"   				   ,10,0 ,"","û","C",""   ,"V"} )
AADD(aHeader,{"Base ICMS"	   	    ,"TRB_BICMS"	,"@E  999,999,999.99"   ,14,2,"","û","N",""   ,"V"} )
AADD(aHeader,{"Valor de ICMS"		,"TRB_VICMS"	,"@E  999,999,999.99"   ,14,2,"","û","N",""   ,"V"} )
AADD(aHeader,{"Aliquota ICMS"		,"TRB_AICMS"	,"@ER 999,999,999.99%"  ,14,2,"","û","N",""   ,"V"} )
AADD(aHeader,{"Base STS"	   	    ,"TRB_BST"  	,"@E  999,999,999.99"   ,14,2,"","û","N",""   ,"V"} )
AADD(aHeader,{"Valor ST"		    ,"TRB_VST"	    ,"@E  999,999,999.99"   ,14,2,"","û","N",""   ,"V"} )
AADD(aHeader,{"Aliquota IPI"		,"TRB_AIPI"	   	,"@ER 999,999,999.99%"  ,14,2,"","û","N",""   ,"V"} )
AADD(aHeader,{"Valor IPI"		    ,"TRB_VIPI"	   	,"@E  999,999,999.99"   ,14,2,"","û","N",""   ,"V"} )
AADD(aHeader,{"Data Emissão Orig."  ,"TRB_DTEMORI"	,""                     ,08,0,"","û","D",""   ,"V"} )


// AHEADER2
AADD(aHeader2,{"Cod."	             ,"TRB2_COD"       ,"@!"				   ,05,0,"","û","C","","V"} )
AADD(aHeader2,{"Descrição"		     ,"TRB2_DESC"	   ,"@!"				   ,30,0,"","û","C",""   ,"V"} )
AADD(aHeader2,{"Base Imposto"	     ,"TRB2_BIMP"	   ,"@E 999,999,999.99"    ,14,2,"","û","N",""   ,"V"} )
AADD(aHeader2,{"Aliquota"	         ,"TRB2_AIMP"	   ,"@E 999,999,999.99"    ,14,2,"","û","N",""   ,"V"} )
AADD(aHeader2,{"Vlr.Imposto"	     ,"TRB2_VIMP"	   ,"@E 999,999,999.99"    ,14,2,"","û","N",""   ,"V"} ) 
                

// AHEADER3
AADD(aHeader3,{"Cod.Fiscal","TRB3_VLR01"	      ,"@!"				   ,05,0,"","û","C","","V"} )                
AADD(aHeader3,{"Aliq.ICMS","TRB3_VLR02"	   ,"@E 999,999,999.99"    ,14,2,"","û","N",""   ,"V"} )
AADD(aHeader3,{"Vlr.Contabil","TRB3_VLR03"	   ,"@E 999,999,999.99"    ,14,2,"","û","N",""   ,"V"} )
AADD(aHeader3,{"Base p/ICMS","TRB3_VLR04"	   ,"@E 999,999,999.99"    ,14,2,"","û","N",""   ,"V"} )
AADD(aHeader3,{"ICMS Tribut.","TRB3_VLR05"	   ,"@E 999,999,999.99"    ,14,2,"","û","N",""   ,"V"} )
AADD(aHeader3,{"ICMS Isento","TRB3_VLR06"	   ,"@E 999,999,999.99"    ,14,2,"","û","N",""   ,"V"} )
AADD(aHeader3,{"ICMS Outros","TRB3_VLR07"	   ,"@E 999,999,999.99"    ,14,2,"","û","N",""   ,"V"} )
AADD(aHeader3,{"Base de IPI","TRB3_VLR08"	   ,"@E 999,999,999.99"    ,14,2,"","û","N",""   ,"V"} )
AADD(aHeader3,{"IPI Tribit.","TRB3_VLR09"	   ,"@E 999,999,999.99"    ,14,2,"","û","N",""   ,"V"} )
AADD(aHeader3,{"IPI Isento","TRB3_VLR10"	   ,"@E 999,999,999.99"    ,14,2,"","û","N",""   ,"V"} )
AADD(aHeader3,{"IPI Outros","TRB3_VLR11"	   ,"@E 999,999,999.99"    ,14,2,"","û","N",""   ,"V"} )
AADD(aHeader3,{"Observaçõs","TRB3_VLR12"	   ,"@!"				   ,15,0,"","û","C","","V"} )                
AADD(aHeader3,{"Desconto","TRB3_VLR13"	   ,"@E 999,999,999.99"    ,14,2,"","û","N",""   ,"V"} )
AADD(aHeader3,{"ICMS Retido","TRB3_VLR14"	   ,"@E 999,999,999.99"    ,14,2,"","û","N",""   ,"V"} )
AADD(aHeader3,{"N. Lancam.","TRB3_VLR15"	   ,"@!"				   ,10,0,"","û","C","","V"} )                
AADD(aHeader3,{"Tipo","TRB3_VLR16"	          ,"@!"				   ,01,0,"","û","C","","V"} )                
AADD(aHeader3,{"ICMS Complerr","TRB3_VLR17"	   ,"@E 999,999,999.99"    ,14,2,"","û","N",""   ,"V"} )
AADD(aHeader3,{"Cod.Serv.ISS","TRB3_VLR18"	   ,"@!"				   ,05,0,"","û","C","","V"} )                
AADD(aHeader3,{"IPI na Obs","TRB3_VLR19"	   ,"@E 999,999,999.99"    ,14,2,"","û","N",""   ,"V"} )
AADD(aHeader3,{"Nr do Livro"   ,"TRB3_VLR20"      ,"@!"				   ,05,0,"","û","C","","V"} )                
AADD(aHeader3,{"ICMS Autonom","TRB3_VLR21"	   ,"@E 999,999,999.99"    ,14,2,"","û","N",""   ,"V"} )
AADD(aHeader3,{"Bs ICMS Ret","TRB3_VLR22"	   ,"@E 999,999,999.99"    ,14,2,"","û","N",""   ,"V"} )
AADD(aHeader3,{"Form.Proprio","TRB3_VLR23"	        ,"@!"				   ,05,0,"","û","C","","V"} )                
AADD(aHeader3,{"Formula" ,"TRB3_VLR24"	         ,"@!"				   ,05,0,"","û","C","","V"} )                
AADD(aHeader3,{"Desp.Acesso","TRB3_VLR25"	   ,"@E 999,999,999.99"    ,14,2,"","û","N",""   ,"V"} )
AADD(aHeader3,{"ICM Deferido","TRB3_VLR26"	   ,"@E 999,999,999.99"    ,14,2,"","û","N",""   ,"V"} )
AADD(aHeader3,{"Trf.Deb/Crd","TRB3_VLR27"	   ,"@E 999,999,999.99"    ,14,2,"","û","N",""   ,"V"} )
AADD(aHeader3,{"ICM Observ.","TRB3_VLR28"	   ,"@E 999,999,999.99"    ,14,2,"","û","N",""   ,"V"} )
AADD(aHeader3,{"Solid. Obs.","TRB3_VLR29"	   ,"@E 999,999,999.99"    ,14,2,"","û","N",""   ,"V"} )
AADD(aHeader3,{"ICM.Sol.Trib.","TRB3_VLR30"	   ,"@E 999,999,999.99"    ,14,2,"","û","N",""   ,"V"} )
AADD(aHeader3,{"CFOP Est." ,"TRB3_VLR31"	        ,"@!"				   ,05,0,"","û","C","","V"} )                
AADD(aHeader3,{"Pgto Imposto","TRB3_VLR32"	         ,"@!"				   ,05,0,"","û","C","","V"} )                
AADD(aHeader3,{"Recolhe ISS","TRB3_VLR33"	        ,"@!"				   ,05,0,"","û","C","","V"} )                
AADD(aHeader3,{"ISS Subempr.","TRB3_VLR34"	   ,"@E 999,999,999.99"    ,14,2,"","û","N",""   ,"V"} )
AADD(aHeader3,{"Cred/Deb ST","TRB3_VLR35"	   ,"@E 999,999,999.99"    ,14,2,"","û","N",""   ,"V"} )
AADD(aHeader3,{"Credito Est.","TRB3_VLR36"	         ,"@!"				   ,05,0,"","û","C","","V"} )                
AADD(aHeader3,{"Crd.Pres.","TRB3_VLR37"	   ,"@E 999,999,999.99"    ,14,2,"","û","N",""   ,"V"} )
AADD(aHeader3,{"Simples","TRB3_VLR38"	   ,"@E 999,999,999.99"    ,14,2,"","û","N",""   ,"V"} )
AADD(aHeader3,{"Crd.Transp.","TRB3_VLR39"	   ,"@E 999,999,999.99"    ,14,2,"","û","N",""   ,"V"} )
AADD(aHeader3,{"Cred.ZFM","TRB3_VLR40"	   ,"@E 999,999,999.99"    ,14,2,"","û","N",""   ,"V"} )
AADD(aHeader3,{"CNAE","TRB3_VLR41"	   ,"@E 999,999,999.99"    ,14,2,"","û","N",""   ,"V"} )
AADD(aHeader3,{"Ident.SFT","TRB3_VLR42"	   ,"@!"				   ,05,0,"","û","C","","V"} )                
AADD(aHeader3,{"Cod.CFPS","TRB3_VLR43"	         ,"@!"				   ,05,0,"","û","C","","V"} )                
AADD(aHeader3,{"Aliq. IPI","TRB3_VLR44"	         ,"@!"				   ,05,0,"","û","C","","V"} )                
AADD(aHeader3,{"Cr Pr ST","TRB3_VLR45"	         ,"@!"				   ,05,0,"","û","C","","V"} )                
AADD(aHeader3,{"Desc.ZFM"               ,"TRB3_VLR46"	      ,"@!"				   ,05,0,"","û","C","","V"} )                
AADD(aHeader3,{"Bs.Pis ST","TRB3_VLR47"	         ,"@!"				   ,05,0,"","û","C","","V"} )                
AADD(aHeader3,{"Al.Pis ST"                         ,"TRB3_VLR48"	      ,"@!"				   ,05,0,"","û","C","","V"} )                
AADD(aHeader3,{"Vl.Pis ST","TRB3_VLR49"	   ,"@E 999,999,999.99"    ,14,2,"","û","N",""   ,"V"} )
AADD(aHeader3,{"Bs.Cof ST","TRB3_VLR50"	   ,"@E 999,999,999.99"    ,14,2,"","û","N",""   ,"V"} )
AADD(aHeader3,{"Al.Cof ST","TRB3_VLR51"	         ,"@!"				   ,05,0,"","û","C","","V"} )                
AADD(aHeader3,{"Vl.Cof ST","TRB3_VLR52"	         ,"@!"				   ,05,0,"","û","C","","V"} )                
AADD(aHeader3,{"Vlr Cr Pr EI","TRB3_VLR53"	   ,"@E 999,999,999.99"    ,14,2,"","û","N",""   ,"V"} )
AADD(aHeader3,{"ISS Mat.","TRB3_VLR54"	   ,"@E 999,999,999.99"    ,14,2,"","û","N",""   ,"V"} )
AADD(aHeader3,{"Vl.Fundersul"         ,"TRB3_VLR55"	   ,"@E 999,999,999.99"    ,14,2,"","û","N",""   ,"V"} )
AADD(aHeader3,{"Vl.Es.Cr/Deb","TRB3_VLR56"	   ,"@E 999,999,999.99"    ,14,2,"","û","N",""   ,"V"} )
AADD(aHeader3,{"Cr Pres Simp","TRB3_VLR57"	   ,"@E 999,999,999.99"    ,14,2,"","û","N",""   ,"V"} )
AADD(aHeader3,{"Base ST Tran","TRB3_VLR58"	   ,"@E 999,999,999.99"    ,14,2,"","û","N",""   ,"V"} )
AADD(aHeader3,{"Antecip. ICMS","TRB3_VLR59"	   ,"@E 999,999,999.99"    ,14,2,"","û","N",""   ,"V"} )
AADD(aHeader3,{"Val.Ant.ICMS"   ,"TRB3_VLR60"	   ,"@E 999,999,999.99"    ,14,2,"","û","N",""   ,"V"} )
AADD(aHeader3,{"Crd Pres PR","TRB3_VLR61"	   ,"@E 999,999,999.99"    ,14,2,"","û","N",""   ,"V"} )
AADD(aHeader3,{"Valor FECP","TRB3_VLR62"	   ,"@E 999,999,999.99"    ,14,2,"","û","N",""   ,"V"} )
AADD(aHeader3,{"Vlr.FECP ST","TRB3_VLR63"	   ,"@E 999,999,999.99"    ,14,2,"","û","N",""   ,"V"} )
AADD(aHeader3,{"Cr Acum ICMS","TRB3_VLR64"	   ,"@E 999,999,999.99"    ,14,2,"","û","N",""   ,"V"} )
AADD(aHeader3,{"Crd Pres RO","TRB3_VLR65"	   ,"@E 999,999,999.99"    ,14,2,"","û","N",""   ,"V"} )
AADD(aHeader3,{"Crd Pres PE","TRB3_VLR66"	   ,"@E 999,999,999.99"    ,14,2,"","û","N",""   ,"V"} )
AADD(aHeader3,{"Sit.Trib.ISS","TRB3_VLR67"	   ,"@E 999,999,999.99"    ,14,2,"","û","N",""   ,"V"} )
AADD(aHeader3,{"Cr Pres PR","TRB3_VLR68"	   ,"@E 999,999,999.99"    ,14,2,"","û","N",""   ,"V"} )
AADD(aHeader3,{"Valor Fethab","TRB3_VLR69"	   ,"@E 999,999,999.99"    ,14,2,"","û","N",""   ,"V"} )
AADD(aHeader3,{"Valor Fabov","TRB3_VLR70"	        ,"@!"				   ,05,0,"","û","C","","V"} )                
AADD(aHeader3,{"Valor Facs","TRB3_VLR71"	   ,"@E 999,999,999.99"    ,14,2,"","û","N",""   ,"V"} )
AADD(aHeader3,{"Cr Pres SP","TRB3_VLR72"	   ,"@E 999,999,999.99"    ,14,2,"","û","N",""   ,"V"} )
AADD(aHeader3,{"Vlr FUMACOP","TRB3_VLR73"	   ,"@E 999,999,999.99"    ,14,2,"","û","N",""   ,"V"} )
AADD(aHeader3,{"Valor Senar","TRB3_VLR74"	   ,"@E 999,999,999.99"    ,14,2,"","û","N",""   ,"V"} )
AADD(aHeader3,{"Cr Out SP","TRB3_VLR75"	         ,"@!"				   ,05,0,"","û","C","","V"} )                
AADD(aHeader3,{"Desc.43080","TRB3_VLR76"	        ,"@!"				   ,05,0,"","û","C","","V"} )                
AADD(aHeader3,{"Vl.43080","TRB3_VLR77"	         ,"@!"				   ,05,0,"","û","C","","V"} )                
AADD(aHeader3,{"Crd.PRODEPE","TRB3_VLR78"	   ,"@E 999,999,999.99"    ,14,2,"","û","N",""   ,"V"} )
AADD(aHeader3,{"Tipo PRODEPE" ,"TRB3_VLR79"	   ,"@E 999,999,999.99"    ,14,2,"","û","N",""   ,"V"} )
AADD(aHeader3,{"Valor TPDP","TRB3_VLR80"	   ,"@E 999,999,999.99"    ,14,2,"","û","N",""   ,"V"} )
AADD(aHeader3,{"Vlr.FECOP-RN","TRB3_VLR81"	         ,"@!"				   ,05,0,"","û","C","","V"} )                
AADD(aHeader3,{"V.FECOP-ST/R","TRB3_VLR82"	   ,"@E 999,999,999.99"    ,14,2,"","û","N",""   ,"V"} )
AADD(aHeader3,{"Crd Out GO","TRB3_VLR83"	   ,"@E 999,999,999.99"    ,14,2,"","û","N",""   ,"V"} )
AADD(aHeader3,{"Crd.Pres.Car","TRB3_VLR84"	   ,"@E 999,999,999.99"    ,14,2,"","û","N",""   ,"V"} )
AADD(aHeader3,{"Cr Pre RS","TRB3_VLR85"	   ,"@E 999,999,999.99"    ,14,2,"","û","N",""   ,"V"} )
AADD(aHeader3,{"Vlr FECP-MG"                       ,"TRB3_VLR86"	   ,"@E 999,999,999.99"    ,14,2,"","û","N",""   ,"V"} )
AADD(aHeader3,{"V.FECP-ST/MG","TRB3_VLR87"	   ,"@E 999,999,999.99"    ,14,2,"","û","N",""   ,"V"} )
AADD(aHeader3,{"V.Reintegra","TRB3_VLR88"	        ,"@!"				   ,05,0,"","û","C","","V"} )                
AADD(aHeader3,{"B.C.Reinteg","TRB3_VLR89"	   ,"@E 999,999,999.99"    ,14,2,"","û","N",""   ,"V"} )
AADD(aHeader3,{"Vlr FECP-MT","TRB3_VLR90"	   ,"@E 999,999,999.99"    ,14,2,"","û","N",""   ,"V"} )
AADD(aHeader3,{"V.FECP-ST/MT","TRB3_VLR91"	   ,"@E 999,999,999.99"    ,14,2,"","û","N",""   ,"V"} )


cGet7:=Space(TamSX3("A1_NOME")[01])
cGet8:=Space(TamSX3("A1_END")[01])
cGet9:=Space(TamSX3("A1_TEL")[01])
cGet10:=Space(TamSX3("A1_EST")[01])
cGet11:=Space(TamSX3("A1_CGC")[01])
DbSelectArea("SA1")
dbSetOrder(3)
If SA1->(DbSeek(XFilial("SA1")+_cnpjm))
   cGet7    :=SA1->A1_NOME        
   cGet8    :=SA1->A1_END+" "+SA1->A1_BAIRRO
   cGet9    :="("+SA1->A1_DDD+")"+SA1->A1_TEL    
   cGet10   :=SA1->A1_EST
   cGet11   :=SA1->A1_CGC           
   _cEmail  :=SA1->A1_EMAIL
   _cTipoCli:=SA1->A1_TIPO
Else
   MsgAlert("Cliente não Encontrado ! Verifique.","Atencao!")   
   Return
EndIf                                                          

// PROJETO_P12
// Roberto Souza
If cVersao == "12"
	cCadastro := 'SIMULADOR IMPOSTOS - Nota de Devolução'
	nGet1	:=0  
   	nGet2	:=0  
   	nGet3	:=0 
   	nGet4	:=0 
   	nGet5	:=0 
   	nGet6	:=0 
   	nGet12	:=0 
   	nGet13	:=0 
   	nGet14	:=0 
   	nGet15	:=0 
   	nGet16	:=0    
	
	aLinS := { 05, 20, 35, 50 }    
   
	aCoord := { aSizeAut[7], 0, aSizeAut[6], aSizeAut[5] }    

	oDlg := tDialog():New(aCoord[1],aCoord[2],aCoord[3],aCoord[4],cCadastro,,,,,CLR_BLACK,CLR_WHITE,,,.T.)
	aWindow := {050,038}
	aColumn := {100,010}
	
	oArea:Init(oDlg,.F., .F. )
	//Mapeamento da area
	oArea:AddLine("L01",100,.T.)

	//ÚÄÄÄÄÄÄÄÄÄ¿
	//³Colunas  ³
	//ÀÄÄÄÄÄÄÄÄÄÙ
	oArea:AddCollumn("L01C01",aColumn[01],.F.,"L01") //dados

	//ÚÄÄÄÄÄÄÄÄÄ¿
	//³Paineis  ³
	//ÀÄÄÄÄÄÄÄÄÄÙ
 	oArea:AddWindow("L01C01","TEXT","Informações",aWindow[01],.F.,.F.,/*bAction*/,"L01",/*bGotFocus*/)
	oGrid1	:= oArea:GetWinPanel("L01C01","TEXT","L01")
   
	oArea:AddWindow("L01C01","LIST","Detalhes",aWindow[02],.F.,.F.,/*bAction*/,"L01",/*bGotFocus*/)
	oFolder	:= oArea:GetWinPanel("L01C01","LIST","L01")

	oGDAProd:= MsNewGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],GD_UPDATE+GD_INSERT+GD_DELETE,"U_lok","U_tok",cIniCpos,aAlter,nFreeze,nMax,"U_valcam",cSuperApagar,"u_apag",oGrid1,aHeader,aCols)
	oGDAProd:oBrowse:Align    	:= CONTROL_ALIGN_ALLCLIENT

	SetKey(VK_F7, { || (U_Pesorig(oGDAProd,oGDAProd:nAt)) } ) //Chamada F7 - Marcio Nunes - 19/10/2017 - I1710-1394         

	aTFolder := { "Totais", "Inf.Fornecedor/Cliente", "Descontos/Frete/Despesas","Livros Fiscais","Impostos" }
	oTFolder := tfolder():new( 190,0,aTFolder,,oFolder,,,,.t.,,655,080 ) //260,184   
	oTFolder:Align    	:= CONTROL_ALIGN_ALLCLIENT
    
   // "Totais"
	@ aLinS[01],10 Say "Vlr.Mercad." Pixel   Of oTFolder:aDialogs[1]
	@ aLinS[01],50 GET oGet1E VAR nGet1 SIZE 100,10 When .F. OF oTFolder:aDialogs[1] PIXEL PICTURE "@E 999,999,999.99"
   
   	@ aLinS[02],10 Say "Vlr.Frete" Pixel                                 Of oTFolder:aDialogs[1]
   	@ aLinS[02],50 GET oGet2E VAR nGet2 SIZE 100,10 When .F. OF oTFolder:aDialogs[1] PIXEL PICTURE "@E 999,999,999.99"
   
   	@ aLinS[01],170 Say "Descontos" Pixel                                 Of oTFolder:aDialogs[1]
   	@ aLinS[01],220 GET oGet3E VAR nGet3 SIZE 100,10 When .F. OF oTFolder:aDialogs[1] PIXEL PICTURE "@E 999,999,999.99"
   
   	@ aLinS[02],170 Say "Vlr.Seguro" Pixel                                 Of oTFolder:aDialogs[1]
   	@ aLinS[02],220 GET oGet4E VAR nGet4 SIZE 100,10 When .F. OF oTFolder:aDialogs[1] PIXEL PICTURE "@E 999,999,999.99"   
   
   	@ aLinS[03],170 Say "Vlr.Despesas" Pixel                                 Of oTFolder:aDialogs[1]
   	@ aLinS[03],220 GET oGet5E VAR nGet5 SIZE 100,10 When .F. OF oTFolder:aDialogs[1] PIXEL PICTURE "@E 999,999,999.99"
   
   	@ aLinS[04],170 Say "Vlr.Bruto" Pixel                                 Of oTFolder:aDialogs[1]
   	@ aLinS[04],220 GET oGet6E VAR nGet6 SIZE 100,10 When .F. OF oTFolder:aDialogs[1] PIXEL PICTURE "@E 999,999,999.99"
   
   	//  "Inf.Fornecedor/Cliente"         
   	@ aLinS[01],10 Say "Razão Social" Pixel                                 Of oTFolder:aDialogs[2]
   	@ aLinS[01],50 GET oGet7 VAR cGet7 SIZE 190,10 When .F. OF oTFolder:aDialogs[2] PIXEL 
   
   	@ aLinS[02],10 Say "Endereço" Pixel                                 Of oTFolder:aDialogs[2]
   	@ aLinS[02],50 GET oGet8 VAR cGet8 SIZE 200,10 When .F. OF oTFolder:aDialogs[2] PIXEL      
   
    @ aLinS[01],270 Say "Telefone" Pixel                                 Of oTFolder:aDialogs[2]
   	@ aLinS[01],320 GET oGet9 VAR cGet9 SIZE 100,10 When .F. OF oTFolder:aDialogs[2] PIXEL 
   
    @ aLinS[02],270 Say "Estado" Pixel                                 Of oTFolder:aDialogs[2]
   	@ aLinS[02],320 GET oGet10 VAR cGet10 SIZE 20,10 When .F. OF oTFolder:aDialogs[2] PIXEL    
   
    @ aLinS[03],270 Say "CNPJ" Pixel                                 Of oTFolder:aDialogs[2]
   	@ aLinS[03],320 GET oGet11 VAR cGet11 SIZE 50,10 When .F. OF oTFolder:aDialogs[2] PIXEL 
   
  // "Descontos/Frete/Despesas"     
   	@ aLinS[01],10 Say "Descontos" Pixel                                 Of oTFolder:aDialogs[3]
   	@ aLinS[01],50 GET oGet12 VAR nGet12 SIZE 100,10 OF oTFolder:aDialogs[3] Valid ExecImp() PIXEL PICTURE "@E 999,999,999.99"
   
   	@ aLinS[02],10 Say "Vlr.Despesas" Pixel                                 Of oTFolder:aDialogs[3]
   	@ aLinS[02],50 GET oGet13 VAR nGet13 SIZE 100,10 OF oTFolder:aDialogs[3] Valid ExecImp() PIXEL PICTURE "@E 999,999,999.99"
   
   	@ aLinS[01],170 Say "Vlr.Frete" Pixel                                 Of oTFolder:aDialogs[3]
   	@ aLinS[01],230 GET oGet14 VAR nGet14 SIZE 100,10 OF oTFolder:aDialogs[3] Valid ExecImp() PIXEL PICTURE "@E 999,999,999.99"
   
   	@ aLinS[02],170 Say "Vlr.Seguro" Pixel                                 Of oTFolder:aDialogs[3]
   	@ aLinS[02],230 GET oGet15 VAR nGet15 SIZE 100,10 OF oTFolder:aDialogs[3] Valid ExecImp() PIXEL PICTURE "@E 999,999,999.99"   
   
   	@ aLinS[03],170 Say "Total (Frete + Despesas)" Pixel                                 Of oTFolder:aDialogs[3]
   	@ aLinS[03],230 GET oGet16 VAR nGet16 SIZE 100,10 When .F. OF oTFolder:aDialogs[3] PIXEL PICTURE "@E 999,999,999.99"


	// "Livros Fiscais"
	oGet1  := MsNewGetDados():New(001,001,265,650,0,"","",,,,,,;
			    "","",oTFolder:aDialogs[5],aHeader2,aCols2)                                 
	oGet1:oBrowse:Align    	:= CONTROL_ALIGN_ALLCLIENT


	// "Impostos" 			    
	oGet2  := MsNewGetDados():New(001,001,265,650,0,"","",,,,,,;
			    "","",oTFolder:aDialogs[4],aHeader3,aCols3)     	
	oGet2:oBrowse:Align    	:= CONTROL_ALIGN_ALLCLIENT
	     
	
	oDlg:Activate(,,,.T.,/*valid*/,,{|| EnchoiceBar(oDlg,{||oDlg:End()},{||oDlg:End()},, aButton,,,,,,.F. ) }/*On Init*/)
   
Else		
	
	DEFINE MSDIALOG oDlg FROM aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] TITLE cCadastro Of oMainWnd PIXEL   
	SetKey(VK_F7, { || (U_Pesorig(oGDAProd,oGDAProd:nAt)) } )
	
	// Cria a Folder    
	   aTFolder := { "Totais", "Inf.Fornecedor/Cliente", "Descontos/Frete/Despesas","Livros Fiscais","Impostos" }
	   oTFolder := tfolder():new( 190,0,aTFolder,,oDlg,,,,.t.,,655,080 ) //260,184   
	   nGet1:=0  
	   nGet2:=0  
	   nGet3:=0 
	   nGet4:=0 
	   nGet5:=0 
	   nGet6:=0 
	   nGet12:=0 
	   nGet13:=0 
	   nGet14:=0 
	   nGet15:=0 
	   nGet16:=0         
	   
	
	   oSay    := TSay()  :New( 08 , 150,{|| 'SIMULADOR IMPOSTOS - Nota de Devolução' },oDlg,, _oFont2 ,,,, .T., , )    
	  
	   // ABA1
	   @10,10 Say "Vlr.Mercad." Pixel   Of oTFolder:aDialogs[1]
	   @ 10,50 GET oGet1E VAR nGet1 SIZE 100,10 When .F. OF oTFolder:aDialogs[1] PIXEL PICTURE "@E 999,999,999.99"
	   
	   @ 25,10 Say "Vlr.Frete" Pixel                                 Of oTFolder:aDialogs[1]
	   @ 25,50 GET oGet2E VAR nGet2 SIZE 100,10 When .F. OF oTFolder:aDialogs[1] PIXEL PICTURE "@E 999,999,999.99"
	   
	   @10,170 Say "Descontos" Pixel                                 Of oTFolder:aDialogs[1]
	   @ 10,220 GET oGet3E VAR nGet3 SIZE 100,10 When .F. OF oTFolder:aDialogs[1] PIXEL PICTURE "@E 999,999,999.99"
	   
	   @ 25,170 Say "Vlr.Seguro" Pixel                                 Of oTFolder:aDialogs[1]
	   @ 25,220 GET oGet4E VAR nGet4 SIZE 100,10 When .F. OF oTFolder:aDialogs[1] PIXEL PICTURE "@E 999,999,999.99"   
	   
	   @40,170 Say "Vlr.Despesas" Pixel                                 Of oTFolder:aDialogs[1]
	   @ 40,220 GET oGet5E VAR nGet5 SIZE 100,10 When .F. OF oTFolder:aDialogs[1] PIXEL PICTURE "@E 999,999,999.99"
	   
	   @ 55,170 Say "Vlr.Bruto" Pixel                                 Of oTFolder:aDialogs[1]
	   @ 55,220 GET oGet6E VAR nGet6 SIZE 100,10 When .F. OF oTFolder:aDialogs[1] PIXEL PICTURE "@E 999,999,999.99"
	   
	   // ABA2         
	   @10,10 Say "Razão Social" Pixel                                 Of oTFolder:aDialogs[2]
	   @ 10,50 GET oGet7 VAR cGet7 SIZE 190,10 When .F. OF oTFolder:aDialogs[2] PIXEL 
	   
	   @ 25,10 Say "Endereço" Pixel                                 Of oTFolder:aDialogs[2]
	   @ 25,50 GET oGet8 VAR cGet8 SIZE 200,10 When .F. OF oTFolder:aDialogs[2] PIXEL      
	   
	    @10,270 Say "Telefone" Pixel                                 Of oTFolder:aDialogs[2]
	   @ 10,320 GET oGet9 VAR cGet9 SIZE 100,10 When .F. OF oTFolder:aDialogs[2] PIXEL 
	   
	    @ 25,270 Say "Estado" Pixel                                 Of oTFolder:aDialogs[2]
	   @ 25,320 GET oGet10 VAR cGet10 SIZE 20,10 When .F. OF oTFolder:aDialogs[2] PIXEL    
	   
	    @ 40,270 Say "CNPJ" Pixel                                 Of oTFolder:aDialogs[2]
	   @ 40,320 GET oGet11 VAR cGet11 SIZE 50,10 When .F. OF oTFolder:aDialogs[2] PIXEL 
	   
	  // ABA3         
	  
	   @10,10 Say "Descontos" Pixel                                 Of oTFolder:aDialogs[3]
	   @ 10,50 GET oGet12 VAR nGet12 SIZE 100,10 OF oTFolder:aDialogs[3] Valid ExecImp() PIXEL PICTURE "@E 999,999,999.99"
	   
	   @ 25,10 Say "Vlr.Despesas" Pixel                                 Of oTFolder:aDialogs[3]
	   @ 25,50 GET oGet13 VAR nGet13 SIZE 100,10 OF oTFolder:aDialogs[3] Valid ExecImp() PIXEL PICTURE "@E 999,999,999.99"
	   
	   @10,170 Say "Vlr.Frete" Pixel                                 Of oTFolder:aDialogs[3]
	   @ 10,230 GET oGet14 VAR nGet14 SIZE 100,10 OF oTFolder:aDialogs[3] Valid ExecImp() PIXEL PICTURE "@E 999,999,999.99"
	   
	   @ 25,170 Say "Vlr.Seguro" Pixel                                 Of oTFolder:aDialogs[3]
	   @ 25,230 GET oGet15 VAR nGet15 SIZE 100,10 OF oTFolder:aDialogs[3] Valid ExecImp() PIXEL PICTURE "@E 999,999,999.99"   
	   
	   @40,170 Say "Total (Frete + Despesas)" Pixel                                 Of oTFolder:aDialogs[3]
	   @ 40,230 GET oGet16 VAR nGet16 SIZE 100,10 When .F. OF oTFolder:aDialogs[3] PIXEL PICTURE "@E 999,999,999.99"
	   
	
	oGDAProd:= MsNewGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],GD_UPDATE+GD_INSERT+GD_DELETE,"U_lok","U_tok",cIniCpos,aAlter,nFreeze,nMax,"U_valcam",cSuperApagar,"u_apag",,aHeader,aCols)
	
	oGet1  := MsNewGetDados():New(001,001,265,650,0,"","",,,,,,;
			    "","",oTFolder:aDialogs[5],aHeader2,aCols2)                                 
			    
	oGet2  := MsNewGetDados():New(001,001,265,650,0,"","",,,,,,;
			    "","",oTFolder:aDialogs[4],aHeader3,aCols3)     		    
	
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||oDlg:End()},{||oDlg:End()},, aButton,,,,,,.F. )

EndIf
		
Return Nil


//_____________________________________________________________________________
/*/{Protheus.doc} Manunfs
Rotina de espelho da NF.

@author Juscelino Santos | Icaro Queiroz
@since 20 de Novembro de 2015
@owner FIT Gestao for Ourolux
/*/
//_____________________________________________________________________________
User Function valcam(_cvarm,lCalST)
Local _ret:=.T.
Local nICMSRET, nBRICMS, nValIPI, nValICM
// Variaveis com seus valores
Private np_CODPRO :=  ASCAN(aHeader, { |x| AllTrim(x[2]) == "TRB_CODPRO"}) 
Private np_DOCORI :=  ASCAN(aHeader, { |x| AllTrim(x[2]) == "TRB_DOCORI"}) 
Private np_SERIE  :=  ASCAN(aHeader, { |x| AllTrim(x[2]) == "TRB_SERIE"}) 
Private np_QUANT  :=  ASCAN(aHeader, { |x| AllTrim(x[2]) == "TRB_QUANT"}) 
Private np_PRUNIT :=  ASCAN(aHeader, { |x| AllTrim(x[2]) == "TRB_VLUNIT"}) 
Private np_VLTOT  :=  ASCAN(aHeader, { |x| AllTrim(x[2]) == "TRB_VLTOT"}) 
Private np_BICMS  :=  ASCAN(aHeader, { |x| AllTrim(x[2]) == "TRB_BICMS"}) 
Private np_VICMS  :=  ASCAN(aHeader, { |x| AllTrim(x[2]) == "TRB_VICMS"}) 
Private np_AICMS  :=  ASCAN(aHeader, { |x| AllTrim(x[2]) == "TRB_AICMS"}) 
Private np_BST    :=  ASCAN(aHeader, { |x| AllTrim(x[2]) == "TRB_BST"}) 
Private np_VST    :=  ASCAN(aHeader, { |x| AllTrim(x[2]) == "TRB_VST"}) 
Private np_AIPI   :=  ASCAN(aHeader, { |x| AllTrim(x[2]) == "TRB_AIPI"}) 
Private np_VIPI   :=  ASCAN(aHeader, { |x| AllTrim(x[2]) == "TRB_VIPI"}) 
Private np_CFOP   :=  ASCAN(aHeader, { |x| AllTrim(x[2]) == "TRB_CFOP"}) 
Private np_CFOP2  :=  ASCAN(aHeader, { |x| AllTrim(x[2]) == "TRB_CFOP2"}) 

Default _cvarm   := ReadVar() ///=="M->D2_LOCAL",M->D2_LOCAL,aCols[n][_nPosLocal])
Default lCalST   := .F.

If _cvarm=="M->TRB_CODPRO" 
   If Empty(M->TRB_CODPRO) 
      MsgAlert("Preencha o Codigo do Produto ! Verifique.","Atencao!")
      Return .F.
   EndIf   
EndIf  

If _cvarm<>"M->TRB_CODPRO" .AND. !lCalST
   If Empty(oGDAProd:aCols[n][np_CODPRO])   //aCols[n][np_CODPRO]) 
      MsgAlert("Preencha o código do produto! Verifique.","Atencao!")
      Return .F.
   EndIf   
EndIf  

// Critica Campo Produto
If _cvarm=="M->TRB_CODPRO"          
   SB1->(dbSetOrder(1))
   If !SB1->(DbSeek(xFilial("SB1")+&_cvarm))
      _ret:=.F.                       
   Else
      oGDAProd:aCols[n][02]:=SB1->B1_DESC 
      oGDAProd:aCols[n][11]:=SB1->B1_POSIPI
   EndIf
   
   _CSF4:=""
   _CSF4:=GETMV("MV_SF4IMP")
   // Query de Pesquisa de Saldo do Produto 
   _cQuery    := "SELECT SD2.*,SD2.R_E_C_N_O_ SD2RECNO "
   If _CSF4="S"
      _cQuery    += "FROM "+RetSqlName("SD2")+" SD2,  "
      _cQuery    += RetSqlName("SF4")+" SF4 "
   Else
      _cQuery    += "FROM "+RetSqlName("SD2")+" SD2   "
   EndIf   
   _cQuery    += "WHERE SD2.D2_FILIAL='"+xFilial("SD2")+"' AND "
   _cQuery    += "SD2.D2_CLIENTE = '"+SA1->A1_COD+"' AND "
   _cQuery    += "SD2.D2_LOJA = '"+SA1->A1_LOJA+"' AND "
   _cQuery    += "SD2.D2_COD  = '"+M->TRB_CODPRO+"' AND "  
   _cQuery    += "SD2.D2_QTDEDEV < SD2.D2_QUANT AND "
   _cQuery    += "SD2.D2_CF NOT IN ('5910', '6910') AND "
   _cQuery    += "SD2.D_E_L_E_T_=' ' " 
   If _CSF4="S"
      _cQuery    += " AND SF4.F4_FILIAL='"+xFilial("SF4")+"' AND "
      _cQuery    += "SF4.F4_CODIGO=(SELECT F4_TESDV FROM "+RetSqlName("SF4")+" WHERE "
      _cQuery    += "F4_FILIAL='"+xFilial("SF4")+"' AND "
      _cQuery    += "F4_CODIGO=SD2.D2_TES AND "
      _cQuery    += "D_E_L_E_T_=' ' ) AND "
      _cQuery    += "SF4.D_E_L_E_T_=' ' "       
   EndIf   
      //_cQuery    += "ORDER BY D2_EMISSAO DESC"
   _cQuery    += "ORDER BY D2_DOC DESC"
   _cQuery    := ChangeQuery(_cQuery)

   If Select("_TMPDEV") > 0
      _TMPDEV->(DbCloseArea())
   EndIf

   DbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),"_TMPDEV",.T.,.T.)
   _TMPDEV->(dbGoTop())   
   If _TMPDEV->(!Eof())                   
      If _TMPDEV->D2_QUANT-_TMPDEV->D2_QTDEDEV>0
         TCSetField("_TMPDEV","D2_EMISSAO","D",8,0)
         oGDAProd:aCols[n][05] :=_TMPDEV->D2_QUANT-_TMPDEV->D2_QTDEDEV
         oGDAProd:aCols[n][03] :=_TMPDEV->D2_DOC
         oGDAProd:aCols[n][04] :=_TMPDEV->D2_SERIE     
         oGDAProd:aCols[n][19] :=_TMPDEV->D2_EMISSAO
         oGDAProd:aCols[n][06] :=_TMPDEV->D2_QUANT-_TMPDEV->D2_QTDEDEV   
         oGDAProd:aCols[n][07] :=_TMPDEV->D2_PRCVEN
         oGDAProd:aCols[n][08] := (_TMPDEV->D2_QUANT-_TMPDEV->D2_QTDEDEV)*_TMPDEV->D2_PRCVEN
         // Pesquisando a TES          
         SF4->(dbSetOrder(1))
         If SF4->(dbSeek(xFilial("SF4")+_TMPDEV->D2_TES))
            _ctestmp:=SF4->F4_TESDV
         Else
            _ctestmp:=Space(3)
         EndIf             
         oGDAProd:aCols[n][09] :=_ctestmp
      EndIf
   Else
		oGDAProd:aCols[n][05] := 0
		oGDAProd:aCols[n][03] :=Space(TamSX3("D2_DOC")[1])
		oGDAProd:aCols[n][04] :=Space(TamSX3("D2_SERIE")[1])
		oGDAProd:aCols[n][19] :=Space(TamSX3("D2_EMISSAO")[1])
		oGDAProd:aCols[n][06] :=0  
		oGDAProd:aCols[n][07] :=0
		oGDAProd:aCols[n][08] :=0
		oGDAProd:aCols[n][09] :=Space(3)
   EndIf
   
   Calimposto( n, _cvarm, _TMPDEV->D2_ICMSRET, _TMPDEV->D2_BRICMS, _TMPDEV->D2_IPI, _TMPDEV->D2_VALIPI, _TMPDEV->D2_PICM, _TMPDEV->D2_VALICM )
   
   If Select("_TMPDEV") > 0
      _TMPDEV->(DbCloseArea())
   EndIf

EndIf

nICMSRET:= oGDAProd:aCols[n][np_VST]
nBRICMS	:= oGDAProd:aCols[n][np_BST]


If _cvarm=="M->TRB_QUANT" .AND. !lCalST

	If M->TRB_QUANT > oGDAProd:aCols[n][5]
		MsgAlert( "A quantidade não pode ser maior que o saldo disponível para devolução!", "Atenção!")
		Return( .F. )
	EndIf

   oGDAProd:aCols[n][np_VLTOT]:=M->TRB_QUANT*oGDAProd:aCols[n][np_PRUNIT]    //aCols[n][np_VLTOT]:=M->TRB_QUANT*aCols[n][np_PRUNIT]   


   _CSF4:=""
   _CSF4:=GETMV("MV_SF4IMP")
   // Query de Pesquisa de Saldo do Produto 
   _cQuery    := "SELECT SD2.*,SD2.R_E_C_N_O_ SD2RECNO "
   If _CSF4="S"
      _cQuery    += "FROM "+RetSqlName("SD2")+" SD2,  "
      _cQuery    += RetSqlName("SF4")+" SF4 "
   Else
      _cQuery    += "FROM "+RetSqlName("SD2")+" SD2   "
   EndIf   
   _cQuery    += "WHERE SD2.D2_FILIAL='"+xFilial("SD2")+"' AND "
   _cQuery    += "SD2.D2_CLIENTE = '"+SA1->A1_COD+"' AND "
   _cQuery    += "SD2.D2_LOJA = '"+SA1->A1_LOJA+"' AND "
   _cQuery    += "SD2.D2_COD  = '"+oGDAProd:aCols[n][np_CODPRO]+"' AND "  
   _cQuery    += "SD2.D2_DOC  = '"+oGDAProd:aCols[n][np_DOCORI]+"' AND "  
   _cQuery    += "SD2.D2_SERIE  = '"+oGDAProd:aCols[n][np_SERIE]+"' AND "  
   _cQuery    += "SD2.D2_CF NOT IN ('5910', '6910') AND "
   _cQuery    += "SD2.D2_QTDEDEV < SD2.D2_QUANT AND "
   _cQuery    += "SD2.D_E_L_E_T_=' ' " 
   If _CSF4="S"
      _cQuery    += " AND SF4.F4_FILIAL='"+xFilial("SF4")+"' AND "
      _cQuery    += "SF4.F4_CODIGO=(SELECT F4_TESDV FROM "+RetSqlName("SF4")+" WHERE "
      _cQuery    += "F4_FILIAL='"+xFilial("SF4")+"' AND "
      _cQuery    += "F4_CODIGO=SD2.D2_TES AND "
      _cQuery    += "D_E_L_E_T_=' ' ) AND "
      _cQuery    += "SF4.D_E_L_E_T_=' ' "       
   EndIf   
   _cQuery    += "ORDER BY D2_DOC DESC"
   _cQuery    := ChangeQuery(_cQuery)

   If Select("_TMPDEV") > 0
      _TMPDEV->(DbCloseArea())
   EndIf

   dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),"_TMPDEV",.T.,.T.)

	nICMSRET	:= ( _TMPDEV->D2_ICMSRET * M->TRB_QUANT ) / _TMPDEV->D2_QUANT
	nBRICMS		:= ( _TMPDEV->D2_BRICMS  * M->TRB_QUANT ) / _TMPDEV->D2_QUANT
	nValIPI		:= ( _TMPDEV->D2_VALIPI  * M->TRB_QUANT ) / _TMPDEV->D2_QUANT
	nValICM		:= ( _TMPDEV->D2_VALICM  * M->TRB_QUANT ) / _TMPDEV->D2_QUANT
	
	oGDAProd:aCols[n][07] := _TMPDEV->D2_PRCVEN
	oGDAProd:aCols[n][16] := _TMPDEV->D2_BRICMS

	Calimposto(n,_cvarm, nICMSRET, nBRICMS, _TMPDEV->D2_IPI, nValIPI, _TMPDEV->D2_PICM, nValICM )

	If Select("_TMPDEV") > 0
      _TMPDEV->(DbCloseArea())
   EndIf
   //EndIf
Else
   oGDAProd:aCols[n][np_VLTOT]:=oGDAProd:aCols[n][6]*oGDAProd:aCols[n][np_PRUNIT]    //aCols[n][np_VLTOT]:=M->TRB_QUANT*aCols[n][np_PRUNIT]   

   _CSF4:=""
   _CSF4:=GETMV("MV_SF4IMP")
   // Query de Pesquisa de Saldo do Produto 
   _cQuery    := "SELECT SD2.*,SD2.R_E_C_N_O_ SD2RECNO "
   If _CSF4="S"
      _cQuery    += "FROM "+RetSqlName("SD2")+" SD2,  "
      _cQuery    += RetSqlName("SF4")+" SF4 "
   Else
      _cQuery    += "FROM "+RetSqlName("SD2")+" SD2   "
   EndIf   
   _cQuery    += "WHERE SD2.D2_FILIAL='"+xFilial("SD2")+"' AND "
   _cQuery    += "SD2.D2_CLIENTE = '"+SA1->A1_COD+"' AND "
   _cQuery    += "SD2.D2_LOJA = '"+SA1->A1_LOJA+"' AND "
   _cQuery    += "SD2.D2_COD  = '"+M->TRB_CODPRO+"' AND "  
   _cQuery    += "SD2.D2_DOC  = '"+oGDAProd:aCols[n][np_DOCORI]+"' AND "  
   _cQuery    += "SD2.D2_SERIE  = '"+oGDAProd:aCols[n][np_SERIE]+"' AND "  
   _cQuery    += "SD2.D2_CF NOT IN ('5910', '6910') AND "
   _cQuery    += "SD2.D2_QTDEDEV < SD2.D2_QUANT AND "
   _cQuery    += "SD2.D_E_L_E_T_=' ' " 
   If _CSF4="S"
      _cQuery    += " AND SF4.F4_FILIAL='"+xFilial("SF4")+"' AND "
      _cQuery    += "SF4.F4_CODIGO=(SELECT F4_TESDV FROM "+RetSqlName("SF4")+" WHERE "
      _cQuery    += "F4_FILIAL='"+xFilial("SF4")+"' AND "
      _cQuery    += "F4_CODIGO=SD2.D2_TES AND "
      _cQuery    += "D_E_L_E_T_=' ' ) AND "
      _cQuery    += "SF4.D_E_L_E_T_=' ' "       
   EndIf   
   _cQuery    += "ORDER BY D2_DOC DESC"
   _cQuery    := ChangeQuery(_cQuery)

   If Select("_TMPDEV") > 0
      _TMPDEV->(DbCloseArea())
   EndIf

   dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),"_TMPDEV",.T.,.T.)

	nICMSRET	:= ( _TMPDEV->D2_ICMSRET * oGDAProd:aCols[n][6] ) / _TMPDEV->D2_QUANT
	nBRICMS		:= ( _TMPDEV->D2_BRICMS  * oGDAProd:aCols[n][6] ) / _TMPDEV->D2_QUANT
	nValIPI		:= ( _TMPDEV->D2_VALIPI  * oGDAProd:aCols[n][6] ) / _TMPDEV->D2_QUANT
	nValICM		:= ( _TMPDEV->D2_VALICM  * oGDAProd:aCols[n][6] ) / _TMPDEV->D2_QUANT
	
	oGDAProd:aCols[n][07] := _TMPDEV->D2_PRCVEN
	oGDAProd:aCols[n][16] := _TMPDEV->D2_BRICMS

	Calimposto(n,_cvarm, nICMSRET, nBRICMS, _TMPDEV->D2_IPI, nValIPI, _TMPDEV->D2_PICM, nValICM )

	If Select("_TMPDEV") > 0
      _TMPDEV->(DbCloseArea())
   EndIf
EndIf
        
If _cvarm=="M->TRB_VLUNIT"
   oGDAProd:aCols[n][np_VLTOT]:=oGDAProd:aCols[n][np_QUANT]*_TMPDEV->D2_PRCVEN //aCols[n][np_VLTOT]:=aCols[n][np_QUANT]*M->TRB_VLUNIT
      Calimposto(n,_cvarm, nICMSRET, nBRICMS)
EndIf


If _cvarm=="M->TRB_CFOP"                   
   If oGDAProd:aCols[n][np_VLTOT] <>0 //If aCols[n][np_VLTOT] <>0
      Calimposto(n,_cvarm, nICMSRET, nBRICMS)
   EndIf
EndIf

If _cvarm=="M->TRB_DOCORI" .Or. _cvarm=="M->TRB_SERIE"
   If oGDAProd:aCols[n][np_VLTOT] <>0 //If aCols[n][np_VLTOT] <>0
      Calimposto(n,_cvarm, nICMSRET, nBRICMS)
   EndIf
EndIf

_ndesc:=0
_nFrete:=0
_nDesp:=0
_nSeg:=0    


Return _ret


//_____________________________________________________________________________
/*/{Protheus.doc} Manunfs
Rotina de espelho da NF.

@author Juscelino Santos | Icaro Queiroz
@since 20 de Novembro de 2015
@owner FIT Gestao for Ourolux
/*/
//_____________________________________________________________________________
User Function lok()
//Alert("clinhaok")
Return .t.



//_____________________________________________________________________________
/*/{Protheus.doc} Manunfs
Rotina de espelho da NF.

@author Juscelino Santos | Icaro Queiroz
@since 20 de Novembro de 2015
@owner FIT Gestao for Ourolux
/*/
//_____________________________________________________________________________
User Function tok()
//Alert("tudo ok")
Return .t.
                 

//_____________________________________________________________________________
/*/{Protheus.doc} Manunfs
Rotina de espelho da NF.

@author Juscelino Santos | Icaro Queiroz
@since 20 de Novembro de 2015
@owner FIT Gestao for Ourolux
/*/
//_____________________________________________________________________________
Static Function Calimposto(_nn,_cvarm, nICMSRet, nBRICMS, nIPI, nValIPI, nPICM, nValICM, lApag )
Local aImpostos	:= {}
Local nIPIAgl	:= 0
Local nICMAgl	:= 0
Local nProdAgl	:= 0
Local nICMSTAgl	:= 0
Local nBSTAgl	:= 0
Local nX		:= 0

Default nICMSRet	:= 0
Default nBRICMS		:= 0
Default nIPI		:= 0
Default nValIPI		:= 0
Default nPICM		:= 0
Default nValICM		:= 0
Default lApag		:= .F.

_nparam:=Pcount()
_Lpesfor:=.F.
_cTipoCli:="F"
DbSelectArea("SA1")
dbSetOrder(3)
If SA1->(DbSeek(XFilial("SA1")+_cnpjm))
   _Lpesfor:=.T.
   _codfor  :=SA1->A1_COD  
   _lojfor  :=SA1->A1_LOJA
   _cTipoCli:=SA1->A1_TIPO
EndIf                
_ndesc:=0
_nFrete:=0
_nDesp:=0
_nSeg:=0

If _cvarm=="M->TRB_CODPRO"          
   _cprodt:=M->TRB_CODPRO
Else   
   _cprodt:=oGDAProd:aCols[_nn][np_CODPRO]
EndIf                

If _cvarm=="M->TRB_QUANT" .AND. !Empty(M->TRB_QUANT) 
   _nquant:=M->TRB_QUANT
Else   
   _nquant:=oGDAProd:aCols[_nn][np_QUANT]
EndIf   

If _cvarm=="M->TRB_VLUNIT"
   _nprunit:=M->TRB_VLUNIT
Else   
   _nprunit:=oGDAProd:aCols[_nn][np_PRUNIT]   
EndIf   

If _cvarm=="M->TRB_DOCORI"
   _cdocori:=M->TRB_DOCORI
Else   
   _cdocori:=oGDAProd:aCols[_nn][np_DOCORI]   
EndIf   

If _cvarm=="M->TRB_SERIE"
   _cserie:=M->TRB_SERIE
Else   
   _cserie:=oGDAProd:aCols[_nn][np_SERIE]   
EndIf   

// Calculo da Linha
MaFisIni(SA1->A1_COD,SA1->A1_LOJA,"C","N",_cTipoCli,,,.F.,"SB1")   
MaFisClear()
MaFisEnd()
MaFisIni(SA1->A1_COD,SA1->A1_LOJA,"C","D",_cTipoCli,,,.F.,"SB1")   
SB1->(DbSeek(xFilial("SB1")+_cprodt))  
If _cvarm=="M->TRB_CFOP"
   _ctestmp:=M->TRB_CFOP
Else 
   _ctestmp:=oGDAProd:aCols[_nn][np_CFOP]
EndIf   
If !Empty(_ctestmp)              
  SF4->(dbSetOrder(1))
  SF4->(dbSeek(xFilial("SF4")+_ctestmp))
EndIf                     

/// Achando Nota de ORIGEM
_regori:=0

MaFisAdd(_cprodt, _ctestmp , _nquant, _nprunit, _ndesc, _cdocori ,_cserie,, _nFrete, nGet13, _nDesp, 0, _nquant*_nprunit , 0, SB1->(RecNo()))   

aadd(aImpostos,"IT_VALICM")
aadd(aImpostos,"IT_ALIQICM") //               03    //Aliquota de ICMS
aadd(aImpostos,"IT_ALIQIPI") //               05    //Aliquota de IPI
aadd(aImpostos,"IT_ALIQISS") //               24,01 //Aliquota de ISS do item
aadd(aImpostos,"IT_ALIQIRR") //       25,03 //Aliquota de Calculo do IR do Item
aadd(aImpostos,"IT_ALIQINS") //       26,03 //Aliquota de Calculo do INSS
aadd(aImpostos,"IT_ALIQIV1") //       29,01 //Aliquota de Impostos Variaveis 1
aadd(aImpostos,"IT_ALIQIV2") //       29,02 //Aliquota de Impostos Variaveis 2
aadd(aImpostos,"IT_ALIQIV3") //       29,03 //Aliquota de Impostos Variaveis 3
aadd(aImpostos,"IT_ALIQIV4") //       29,04 //Aliquota de Impostos Variaveis 4
aadd(aImpostos,"IT_ALIQIV5") //       29,05 //Aliquota de Impostos Variaveis 5
aadd(aImpostos,"IT_ALIQIV6") //       29,06 //Aliquota de Impostos Variaveis 6
aadd(aImpostos,"IT_ALIQIV7") //       29,07 //Aliquota de Impostos Variaveis 7
aadd(aImpostos,"IT_ALIQIV8") //       29,08 //Aliquota de Impostos Variaveis 8
aadd(aImpostos,"IT_ALIQIV9") //       29,09 //Aliquota de Impostos Variaveis 9
aadd(aImpostos,"IT_ALIQCOF") //       41    //Aliquota de calculo do COFINS
aadd(aImpostos,"IT_ALIQCSL") //       44    //Aliquota de calculo do CSLL
aadd(aImpostos,"IT_ALIQPIS") //       47    //Aliquota de calculo do PIS
aadd(aImpostos,"IT_ALIQPS2") //       55    //Aliquota de calculo do PIS 2
aadd(aImpostos,"IT_ALIQCF2") //       58    //Aliquota de calculo do COFINS 2
aadd(aImpostos,"IT_ALIQAFRMM") //     67 //Aliquota de calculo do AFRMM ( Item )
aadd(aImpostos,"IT_ALIQSES") //       74,02 //Aliquota de calculo do SEST          
aadd(aImpostos,"IT_VALSOL")                          
aadd(aImpostos,"NF_VALSOL")          
aadd(aImpostos,"LF_ICMSRET") 
aadd(aImpostos,"IT_BASEICM")  

//ICARO
oGDAProd:aCols[_nn][np_BICMS]	:= MaFisRet(1,'IT_BASEICM')
oGDAProd:aCols[_nn][np_VICMS]	:= IIf( nValICM > 0 .And. nValICM <> MaFisRet(1,'IT_VALICM'), nValICM, MaFisRet(1,'IT_VALICM') )
oGDAProd:aCols[_nn][np_AICMS]	:= IIf( nPICM > 0 .And. nPICM <> MaFisRet(1,'IT_ALIQICM'), nPICM, MaFisRet(1,'IT_ALIQICM') )
oGDAProd:aCols[_nn][np_AIPI]	:= IIf( nIPI > 0 .And. nIPI <> MaFisRet(1,'IT_ALIQIPI'), nIPI, MaFisRet(1,'IT_ALIQIPI') )
oGDAProd:aCols[_nn][np_VIPI]	:= IIf( nValIPI > 0 .And. nValIPI <> MaFisRet(1,'IT_VALIPI'), nValIPI, MaFisRet(1,'IT_VALIPI') )


If _cvarm <> "M->TRB_QUANT" .AND. !Empty(_cvarm)
   U_valcam("M->TRB_QUANT",.T.) 
EndIf
//oGDAProd:aCols[_nn][np_BST] 	:= IIf( nBRICMS > 0 .And. nBRICMS <> MaFisRet(1,'IT_BASESOL'), nBRICMS, MaFisRet(1,'IT_BASESOL') )
//oGDAProd:aCols[_nn][np_VST] 	:= IIf( nICMSRet > 0 .And. nICMSRet <> MaFisRet(1,'IT_VALSOL'), nICMSRet, MaFisRet(1,'IT_VALSOL') )

// Atualiando o Codigo Fiscal
_cfoptmp:=" "

//Acrescentado na condição abaixo:   .Or. ( SA1->A1_EST <> "SC" .And. AllTrim( cFilAnt ) == '06' ) //para tratamento do CFOP de SC fora do estado - Marcelo Ethosx - 31/05/2019
If ( SA1->A1_EST <> "SP" .And. ( AllTrim( cFilAnt ) == '01' .Or. AllTrim( cFilAnt ) == '03' ) ) .Or. ( SA1->A1_EST <> "PR" .And. AllTrim( cFilAnt ) == '02' ) .Or. ( SA1->A1_EST <> "RJ" .And. AllTrim( cFilAnt ) == '04' ) .Or. ( SA1->A1_EST <> "PE" .And. AllTrim( cFilAnt ) == '05' )  .Or. ( SA1->A1_EST <> "SC" .And. AllTrim( cFilAnt ) == '06' ) 
   If oGDAProd:aCols[_nn][16] <> 0   
      oGDAProd:aCols[_nn][10]:="6411"
      oGDAProd:aCols[_nn][np_BST] 	:= IIf( nBRICMS > 0 .And. nBRICMS <> MaFisRet(1,'IT_BASESOL'), nBRICMS, MaFisRet(1,'IT_BASESOL') )
      oGDAProd:aCols[_nn][np_VST] 	:= IIf( nICMSRet > 0 .And. nICMSRet <> MaFisRet(1,'IT_VALSOL'), nICMSRet, MaFisRet(1,'IT_VALSOL') )
   Else               
      oGDAProd:aCols[_nn][10]:="6202"
      oGDAProd:aCols[_nn][np_BST] 	:= 0
      oGDAProd:aCols[_nn][np_VST] 	:= 0
   EndIf
Else
   If oGDAProd:aCols[_nn][16] <> 0   
      oGDAProd:aCols[_nn][10]:= "5411"
      oGDAProd:aCols[_nn][np_BST] 	:= IIf( nBRICMS > 0 .And. nBRICMS <> MaFisRet(1,'IT_BASESOL'), nBRICMS, MaFisRet(1,'IT_BASESOL') )
      oGDAProd:aCols[_nn][np_VST] 	:= IIf( nICMSRet > 0 .And. nICMSRet <> MaFisRet(1,'IT_VALSOL'), nICMSRet, MaFisRet(1,'IT_VALSOL') )
   Else               
      oGDAProd:aCols[_nn][10]:= "5202"
      oGDAProd:aCols[_nn][np_BST] 	:= 0
      oGDAProd:aCols[_nn][np_VST] 	:= 0
   EndIf        
EndIf                    

MaFisEndLoad(01,03)
MaFisClear()
MaFisEnd()


// Recalcula Totais de Impostos recalculando todos os ITENS
If Len(oGDAProd:aCols)>0
   MaFisIni(SA1->A1_COD,SA1->A1_LOJA,"C","N",_cTipoCli,,,.F.,"SB1")   
   MaFisClear()
   MaFisEnd()
   MaFisIni(SA1->A1_COD,SA1->A1_LOJA,"C","D",_cTipoCli,,,.F.,"SB1")   

   For _ly := 1 to Len(oGDAProd:aCols)       
       /// Achando Nota de ORIGEM (INICIO)
       //_regori :=0    
       If _nparam=3          
          If oGDAProd:aCols[_ly][Len(aHeader)+1] .And. _ly=n
             Loop
          EndIf
       Else 
          If oGDAProd:aCols[_ly][Len(aHeader)+1] .Or. ( _ly == oGDAProd:nAt .And. !oGDAProd:aCols[_ly][Len(aHeader)+1] .And. lApag )
             Loop
          EndIf
       EndIf   
       
       If Empty(_cvarm)
          //If oGDAProd:aCols[_ly][np_CODPRO]
          SB1->(DbSeek(xFilial("SB1")+oGDAProd:aCols[_ly][np_CODPRO]))  
          MaFisAdd(oGDAProd:aCols[_ly][np_CODPRO], oGDAProd:aCols[_ly][np_CFOP] , oGDAProd:aCols[_ly][np_QUANT], oGDAProd:aCols[_ly][np_PRUNIT], _ndesc, oGDAProd:aCols[_ly][np_DOCORI] , oGDAProd:aCols[_ly][np_SERIE] , , _nFrete, _nDesp, _nSeg, 0, oGDAProd:aCols[_ly][np_VLTOT], 0, SB1->(RecNo()))   
       Else 
          If _ly==_nn   

             If _cvarm=="M->TRB_DOCORI"
                _cdocori:=M->TRB_DOCORI
             Else   
                _cdocori:=oGDAProd:aCols[_nn][np_DOCORI]   
             EndIf   
             
             If _cvarm=="M->TRB_SERIE"
                _cserie:=M->TRB_SERIE
             Else   
                _cserie:=oGDAProd:aCols[_nn][np_SERIE]   
             EndIf   

             If _cvarm=="M->TRB_CFOP"
                _ctestmp:=M->TRB_CFOP
             Else 
                _ctestmp:=oGDAProd:aCols[_nn][np_CFOP]
             EndIf   
             
             If _cvarm=="M->TRB_VLUNIT"
                _nprunit:=M->TRB_VLUNIT
             Else   
                _nprunit:=oGDAProd:aCols[_nn][np_PRUNIT]   
             EndIf   
             
             If _cvarm=="M->TRB_QUANT" .AND. !Empty(M->TRB_QUANT)
                _nquant:=M->TRB_QUANT
             Else   
               _nquant:=oGDAProd:aCols[_nn][np_QUANT]
             EndIf   
             
             If _cvarm=="M->TRB_CODPRO"          
                _cprodt:=M->TRB_CODPRO
             Else   
                _cprodt:=oGDAProd:aCols[_nn][np_CODPRO]
             Endif

             If Empty(_cprodt)
                _cprodt:=M->TRB_CODPRO
             EndIF             
             SB1->(DbSeek(xFilial("SB1")+_cprodt))  
             MaFisAdd(_cprodt, _ctestmp , _nquant, _nprunit, _ndesc, _cdocori, _cserie ,, _nFrete, _nDesp, _nSeg, 0,_nquant*_nprunit, 0, SB1->(RecNo()))   
          Else
             SB1->(DbSeek(xFilial("SB1")+oGDAProd:aCols[_ly][np_CODPRO]))  
             MaFisAdd(oGDAProd:aCols[_ly][np_CODPRO], oGDAProd:aCols[_ly][np_CFOP] , oGDAProd:aCols[_ly][np_QUANT], oGDAProd:aCols[_ly][np_PRUNIT], _ndesc, oGDAProd:aCols[_ly][np_DOCORI], oGDAProd:aCols[_ly][np_SERIE],, _nFrete, _nDesp, _nSeg, 0, oGDAProd:aCols[_ly][np_VLTOT], 0, SB1->(RecNo()))   
          EndIf
       EndIf   
   Next _ly                    

   MaFisAlt("NF_DESCONTO",nGet12)           
   MaFisAlt("NF_DESPESA",nGet13)           
   MaFisAlt("NF_FRETE",nGet14)           
   MaFisAlt("NF_SEGURO",nGet15) 
   
   nGet16:=(nGet13+nGet14+nGet15)-nGet12
   
   _aimpostos:= MaFisRet(,'NF_IMPOSTOS')  
   _alivfisc := MaFisRet(,'NF_LIVRO')
   
   oGet1:aCols := {} 

	For nX := 1 To Len( oGDAProd:aCols )
		If nX == oGDAProd:nAt .And. lApag .And. !oGDAProd:aCols[oGDAProd:nAt][Len(aHeader)+1]
			Loop
		Else
			nProdAgl	+= oGDAProd:aCols[nX][08]
			nICMAgl		+= oGDAProd:aCols[nX][13]
			nBSTAgl		+= oGDAProd:aCols[nX][15]
			nICMSTAgl	+= oGDAProd:aCols[nX][16]
			nIPIAgl		+= oGDAProd:aCols[nX][18]
		EndIf
	Next nX
	

   For _zz:=1 To Len(_aimpostos)
     If !Empty(_aimpostos[_zz][01])
        Aadd(oGet1:aCols, Array(Len(aHeader2) + 1))
	    For _nI := 1 to Len(aHeader2)
		   oGet1:aCols[Len(oGet1:aCols)][01] := _aimpostos[_zz][01]
		   oGet1:aCols[Len(oGet1:aCols)][02] := _aimpostos[_zz][02]
		   oGet1:aCols[Len(oGet1:aCols)][03] := If( _aimpostos[_zz][01] == "ICR" .And. nBSTAgl  > 0 .And. _aimpostos[_zz][03] <> nBSTAgl,  nBSTAgl,  _aimpostos[_zz][03] )
		   oGet1:aCols[Len(oGet1:aCols)][04] := If( _aimpostos[_zz][01] == "ICM" .And. nPICM > 0 .And. nPICM <> _aimpostos[_zz][04], nPICM, If( _aimpostos[_zz][01] == "IPI" .And. nIPI > 0 .And. nIPI <> _aimpostos[_zz][04], nIPI, _aimpostos[_zz][04] ) )
		   oGet1:aCols[Len(oGet1:aCols)][05] := If( _aimpostos[_zz][01] == "ICR" .And. nICMSTAgl > 0 .And. _aimpostos[_zz][05] <> nICMSTAgl, nICMSTAgl, If( _aimpostos[_zz][01] == "ICM" .And. nICMAgl > 0 .And. nICMAgl <> _aimpostos[_zz][05], nICMAgl, If( _aimpostos[_zz][01] == "IPI" .And. nValIPI > 0 .And. nValIPI <> _aimpostos[_zz][05], nIPIAgl, _aimpostos[_zz][05] ) ) )

		// I1710-1400 - Roberto Souza - Ajuste para mostrar o aglutinado de IPI
		// oGet1:aCols[Len(oGet1:aCols)][05] := If( _aimpostos[_zz][01] == "ICR" .And. nICMSTAgl > 0 .And. _aimpostos[_zz][05] <> nICMSTAgl, nICMSTAgl, If( _aimpostos[_zz][01] == "ICM" .And. nICMAgl > 0 .And. nICMAgl <> _aimpostos[_zz][05], nICMAgl, If( _aimpostos[_zz][01] == "IPI" .And. nValIPI > 0 .And. nValIPI <> _aimpostos[_zz][05], nValIPI, _aimpostos[_zz][05] ) ) )

	    Next _nI
	    oGet1:aCols[Len(oGet1:aCols)][len(aHeader2)+1] := .F.
	 EndIf  
	 oGet1:oBrowse:Refresh()
  Next _zz


   nGet1:=MaFisRet(,'NF_VALMERC')
   nGet2:=MaFisRet(,'NF_FRETE')
   nGet3:=MaFisRet(,'NF_DESCONTO')
   nGet4:=MaFisRet(,'NF_SEGURO')
   nGet5:=MaFisRet(,'NF_DESPESA') 
   //nGet6:=MaFisRet(,'NF_TOTAL') 
   
   If SA1->A1_EST $ "MG/RS/BA" 	//Alterado por Bia Ferreira - Ethosx  - 13/02/2020 / Retira ICMS-ST 
				//Alterado por Rogerio Silva- Introde - 19/11/2020 / Retira ICMS-ST 
         //msgalert('Rogerio - icms ST BA')
   		nGet6:=nProdAgl+nIPIAgl
   Else
   		nGet6:=nIPIAgl+nProdAgl+nICMSTAgl 
   EndIf
   
   OGet1E:Refresh()
   OGet2E:Refresh()
   OGet3E:Refresh()
   OGet4E:Refresh()
   OGet5E:Refresh()
   OGet6E:Refresh()
   OGet16:Refresh()

  _alivfisc := MaFisRet(,'NF_LIVRO')
  oGet2:aCols := {} 
  For _zz:=1 To Len(_alivfisc)
     If !Empty(_alivfisc[_zz][01])
        Aadd(oGet2:aCols, Array(Len(aHeader3) + 1))
	    For _nI := 1 to Len(aHeader3)
	       If _nI <> 35
		     oGet2:aCols[Len(oGet2:aCols)][_nI] := _alivfisc[_zz][_nI]
		   Else
		     oGet2:aCols[Len(oGet2:aCols)][_nI] := 0
		   EndIf  
	    Next _nI
	    oGet2:aCols[Len(oGet2:aCols)][len(aHeader3)+1] := .F.
	 EndIf  
	 oGet2:oBrowse:Refresh() 
  Next _zz 
   _yy:=0
EndIf       

Return .T.
                     
  
//_____________________________________________________________________________
/*/{Protheus.doc} Manunfs
Rotina de espelho da NF.

@author Juscelino Santos | Icaro Queiroz
@since 20 de Novembro de 2015
@owner FIT Gestao for Ourolux
/*/
//_____________________________________________________________________________
User Function apag()       
Local lRet 			:= .T.
Static lPrimeiraVez	:= .T.

Private np_CODPRO	:=  ASCAN(aHeader, { |x| AllTrim(x[2]) == "TRB_CODPRO"}) 
Private np_DOCORI	:=  ASCAN(aHeader, { |x| AllTrim(x[2]) == "TRB_DOCORI"}) 
Private np_SERIE	:=  ASCAN(aHeader, { |x| AllTrim(x[2]) == "TRB_SERIE"}) 
Private np_QUANT	:=  ASCAN(aHeader, { |x| AllTrim(x[2]) == "TRB_QUANT"}) 
Private np_PRUNIT	:=  ASCAN(aHeader, { |x| AllTrim(x[2]) == "TRB_VLUNIT"}) 
Private np_VLTOT	:=  ASCAN(aHeader, { |x| AllTrim(x[2]) == "TRB_VLTOT"}) 
Private np_BICMS	:=  ASCAN(aHeader, { |x| AllTrim(x[2]) == "TRB_BICMS"}) 
Private np_VICMS	:=  ASCAN(aHeader, { |x| AllTrim(x[2]) == "TRB_VICMS"}) 
Private np_AICMS	:=  ASCAN(aHeader, { |x| AllTrim(x[2]) == "TRB_AICMS"}) 
Private np_BST		:=  ASCAN(aHeader, { |x| AllTrim(x[2]) == "TRB_BST"}) 
Private np_VST		:=  ASCAN(aHeader, { |x| AllTrim(x[2]) == "TRB_VST"}) 
Private np_AIPI		:=  ASCAN(aHeader, { |x| AllTrim(x[2]) == "TRB_AIPI"}) 
Private np_VIPI		:=  ASCAN(aHeader, { |x| AllTrim(x[2]) == "TRB_VIPI"}) 
Private np_CFOP		:=  ASCAN(aHeader, { |x| AllTrim(x[2]) == "TRB_CFOP"})
Private np_CFOP2	:=  ASCAN(aHeader, { |x| AllTrim(x[2]) == "TRB_CFOP2"})  

/*If lPrimeiraVez
	If !oGetD:aCols[n][Len(oGetD:aHeader)+1]
		lRet := MsgYesNo("Confirma a exclusão da linha?")
		oGetD:aCols[n][Len(oGetD:aHeader)+1] := lRet
	EndIf
	lPrimeiraVez := .F.
Else
	lPrimeiraVez := .T.
EndIf

oGetD:refresh()*/

//oGDAProd:aCols[oGDAProd:nAt, Len(aHeader)+1] := !oGDAProd:aCols[oGDAProd:nAt, Len(aHeader)+1]
//oGDAProd:Refresh()


_ndesc:=0
_nFrete:=0
_nDesp:=0
_nSeg:=0             

MaFisEnd()
MaFisIni(SA1->A1_COD,SA1->A1_LOJA,"C","N",_cTipoCli,,,.F.,"SB1")   
MaFisClear()
MaFisEnd()
MaFisIni(SA1->A1_COD,SA1->A1_LOJA,"C","D",_cTipoCli,,,.F.,"SB1")   
For _lx := 1 to Len(oGDAProd:aCols)
    If !oGDAProd:aCols[_lx][Len(aHeader)+1]  .And. _lx=oGDAProd:nAt
       Loop                                                        
    Else
	    DbSeek(xFilial("SB1")+Acols[_lx][np_CODPRO])
	    MaFisAdd(oGDAProd:aCols[_lx][np_CODPRO], oGDAProd:aCols[_lx][np_CFOP] , oGDAProd:aCols[_lx][np_QUANT], oGDAProd:aCols[_lx][np_PRUNIT], _ndesc, oGDAProd:aCols[_lx][np_DOCORI],oGDAProd:aCols[_lx][np_SERIE]   , , _nFrete, _nDesp, _nSeg, 0, oGDAProd:aCols[_lx][np_VLTOT], 0, SB1->(RecNo()))   
    EndIf
Next _lx               

Calimposto( 01, "",,,,,,, .T. )

oGDAProd:Refresh()

Return( .t. )


//_____________________________________________________________________________
/*/{Protheus.doc} Manunfs
Rotina de espelho da NF.

@author Juscelino Santos | Icaro Queiroz
@since 20 de Novembro de 2015
@owner FIT Gestao for Ourolux
/*/
//_____________________________________________________________________________
Static Function ExecImp()
If Len(oGDAProd:aCols)>0 
   If !Empty(oGDAProd:aCols[01][01])       

// Variaveis com seus valores
      Private np_CODPRO :=  ASCAN(aHeader, { |x| AllTrim(x[2]) == "TRB_CODPRO"}) 
      Private np_DOCORI :=  ASCAN(aHeader, { |x| AllTrim(x[2]) == "TRB_DOCORI"}) 
      Private np_SERIE  :=  ASCAN(aHeader, { |x| AllTrim(x[2]) == "TRB_SERIE"}) 
      Private np_QUANT  :=  ASCAN(aHeader, { |x| AllTrim(x[2]) == "TRB_QUANT"}) 
      Private np_PRUNIT :=  ASCAN(aHeader, { |x| AllTrim(x[2]) == "TRB_VLUNIT"}) 
      Private np_VLTOT  :=  ASCAN(aHeader, { |x| AllTrim(x[2]) == "TRB_VLTOT"}) 
      Private np_BICMS  :=  ASCAN(aHeader, { |x| AllTrim(x[2]) == "TRB_BICMS"}) 
      Private np_VICMS  :=  ASCAN(aHeader, { |x| AllTrim(x[2]) == "TRB_VICMS"}) 
      Private np_AICMS  :=  ASCAN(aHeader, { |x| AllTrim(x[2]) == "TRB_AICMS"}) 
      Private np_BST    :=  ASCAN(aHeader, { |x| AllTrim(x[2]) == "TRB_BST"}) 
      Private np_VST    :=  ASCAN(aHeader, { |x| AllTrim(x[2]) == "TRB_VST"}) 
      Private np_VST    :=  ASCAN(aHeader, { |x| AllTrim(x[2]) == "TRB_VST"}) 
      Private np_AIPI   :=  ASCAN(aHeader, { |x| AllTrim(x[2]) == "TRB_AIPI"}) 
      Private np_VIPI   :=  ASCAN(aHeader, { |x| AllTrim(x[2]) == "TRB_VIPI"}) 
      Private np_CFOP   :=  ASCAN(aHeader, { |x| AllTrim(x[2]) == "TRB_CFOP"})
      Private np_CFOP2  :=  ASCAN(aHeader, { |x| AllTrim(x[2]) == "TRB_CFOP2"})  
      Calimposto(01,"")  
   EndIf
EndIf   


//_____________________________________________________________________________
/*/{Protheus.doc} Manunfs
Rotina de espelho da NF.

@author Juscelino Santos | Icaro Queiroz
@since 20 de Novembro de 2015
@owner FIT Gestao for Ourolux
/*/
//_____________________________________________________________________________
User Function PESORIG(oGDAProd,n)                          
Local nICMSRET, nBRICMS

aDados1:={}               

   // Query de Pesquisa de Saldo do Produto 
   _cQuery    := "SELECT SD2.*,SD2.R_E_C_N_O_ SD2RECNO "
   _cQuery    += "FROM "+RetSqlName("SD2")+" SD2,  "
   _cQuery    += RetSqlName("SF4")+" SF4 "
   _cQuery    += "WHERE SD2.D2_FILIAL='"+xFilial("SD2")+"' AND "
   _cQuery    += "SD2.D2_CLIENTE = '"+SA1->A1_COD+"' AND "
   _cQuery    += "SD2.D2_LOJA = '"+SA1->A1_LOJA+"' AND D2_CF NOT IN ('5910', '6910') AND "
   _cQuery    += "SD2.D2_COD  = '"+oGDAProd:aCols[oGDAProd:nat][1]+"' AND "  
   _cQuery    += "SD2.D2_QTDEDEV < SD2.D2_QUANT AND "
   _cQuery    += "SD2.D_E_L_E_T_=' ' AND " 
   _cQuery    += "SF4.F4_FILIAL='"+xFilial("SF4")+"' AND "
   _cQuery    += "SF4.F4_CODIGO=(SELECT F4_TESDV FROM "+RetSqlName("SF4")+" WHERE "
   _cQuery    += "F4_FILIAL='"+xFilial("SF4")+"' AND "
   _cQuery    += "F4_CODIGO=SD2.D2_TES AND "
   _cQuery    += "D_E_L_E_T_=' ' ) AND "
   _cQuery    += "SF4.D_E_L_E_T_=' ' "       
   _cQuery    += "ORDER BY D2_DOC DESC"
   _cQuery    := ChangeQuery(_cQuery)

   If Select("_TMPDEV") > 0
      _TMPDEV->(DbCloseArea())
   EndIf

   DbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),"_TMPDEV",.T.,.T.)     
   TCSetField("_TMPDEV","D2_EMISSAO","D",8,0)
   
   SF4->(dbSetOrder(1))
   _TMPDEV->(dbGoTop())              
   While _TMPDEV->(!Eof())                  
       If SF4->(dbSeek(xFilial("SF4")+_TMPDEV->D2_TES))
          _ctestmp:=SF4->F4_TESDV
       Else
          _ctestmp:=Space(3)
       EndIf
       aAdd(aDados1,{_TMPDEV->D2_DOC,_TMPDEV->D2_SERIE,_TMPDEV->D2_EMISSAO,_TMPDEV->D2_TES,_ctestmp,_TMPDEV->D2_QUANT,_TMPDEV->D2_QTDEDEV,_TMPDEV->D2_PRCVEN})
       nICMSRET := _TMPDEV->D2_ICMSRET
       nBRICMS	:= _TMPDEV->D2_BRICMS
		_TMPDEV->(DbSkip())
   Enddo  
   		
   If Select("_TMPDEV") > 0
      _TMPDEV->(DbCloseArea())
   EndIf
   
   If Len(aDados1)>=1
   
   DEFINE MSDIALOG oDlg2 TITLE "Notas de Saidas" From 00,00 To 250,690 OF oDlg PIXEL
   
   _oBrw := TCBrowse():New( 01,0,650,135,,{"Documento","Serie","Emissão","Tes Saida","Tes Dev.","Quant.","Quant.Dev.","Preço Unit.",""},;
		{34,30,60,45,45,45,45,38,1},oDlg2,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, ) 
		
   _oBrw:SetArray(aDados1)		
 
    _oBrw:bLDblClick   := {||(SELECBR(aDados1,oGDAProd,n, nICMSRET, nBRICMS ),_oBrw:End(),oDlg2:End())}
	_oBrw:bLine := {||{aDados1[_oBrw:nAt, 1],;
		aDados1[_oBrw:nAt, 2]				,;
		aDados1[_oBrw:nAt, 3]				,;
		aDados1[_oBrw:nAt, 4]				,;
		aDados1[_oBrw:nAt, 5]				,;
		aDados1[_oBrw:nAt, 6]				,;
		aDados1[_oBrw:nAt, 7]				,;
		aDados1[_oBrw:nAt, 8]               ,;
		""}}
     Activate Dialog oDlg2 Centered     		
  Else
     MsgAlert("Nenhuma Nota Encontrada ! Verifique.","Atencao!")
  EndIf   
		
Return


//_____________________________________________________________________________
/*/{Protheus.doc} Manunfs
Rotina de espelho da NF.

@author Juscelino Santos | Icaro Queiroz
@since 20 de Novembro de 2015
@owner FIT Gestao for Ourolux
/*/
//_____________________________________________________________________________
Static Function SELECBR( _adados, oGDAProd, n, nICMSRET, nBRICMS )

Default nICMSRet	:= 0
Default nBRICMS		:= 0

nLinha := _oBrw:nAt

oGDAProd:aCols[oGDAProd:nAt][05] :=aDados1[nLinha,6] - aDados1[nLinha,7]
oGDAProd:aCols[oGDAProd:nAt][03] :=aDados1[nLinha,1]
oGDAProd:aCols[oGDAProd:nAt][04] :=aDados1[nLinha,2]
oGDAProd:aCols[oGDAProd:nAt][19] :=aDados1[nLinha,3]                    
oGDAProd:aCols[oGDAProd:nAt][06] :=aDados1[nLinha,6]
oGDAProd:aCols[oGDAProd:nAt][07] :=aDados1[nLinha,8]
oGDAProd:aCols[oGDAProd:nAt][08] :=aDados1[nLinha,6]*aDados1[nLinha,8]
oGDAProd:aCols[oGDAProd:nAt][09] :=aDados1[nLinha,5]

Private np_CODPRO :=  ASCAN(aHeader, { |x| AllTrim(x[2]) == "TRB_CODPRO"}) 
Private np_DOCORI :=  ASCAN(aHeader, { |x| AllTrim(x[2]) == "TRB_DOCORI"}) 
Private np_SERIE  :=  ASCAN(aHeader, { |x| AllTrim(x[2]) == "TRB_SERIE"}) 
Private np_QUANT  :=  ASCAN(aHeader, { |x| AllTrim(x[2]) == "TRB_QUANT"}) 
Private np_PRUNIT :=  ASCAN(aHeader, { |x| AllTrim(x[2]) == "TRB_VLUNIT"}) 
Private np_VLTOT  :=  ASCAN(aHeader, { |x| AllTrim(x[2]) == "TRB_VLTOT"}) 
Private np_BICMS  :=  ASCAN(aHeader, { |x| AllTrim(x[2]) == "TRB_BICMS"}) 
Private np_VICMS  :=  ASCAN(aHeader, { |x| AllTrim(x[2]) == "TRB_VICMS"}) 
Private np_AICMS  :=  ASCAN(aHeader, { |x| AllTrim(x[2]) == "TRB_AICMS"}) 
Private np_BST    :=  ASCAN(aHeader, { |x| AllTrim(x[2]) == "TRB_BST"}) 
Private np_VST    :=  ASCAN(aHeader, { |x| AllTrim(x[2]) == "TRB_VST"}) 
Private np_AIPI   :=  ASCAN(aHeader, { |x| AllTrim(x[2]) == "TRB_AIPI"}) 
Private np_VIPI   :=  ASCAN(aHeader, { |x| AllTrim(x[2]) == "TRB_VIPI"}) 
Private np_CFOP   :=  ASCAN(aHeader, { |x| AllTrim(x[2]) == "TRB_CFOP"})
Private np_CFOP2  :=  ASCAN(aHeader, { |x| AllTrim(x[2]) == "TRB_CFOP2"})       


   _CSF4:=""
   _CSF4:=GETMV("MV_SF4IMP")
   // Query de Pesquisa de Saldo do Produto 
   _cQuery    := "SELECT SD2.*,SD2.R_E_C_N_O_ SD2RECNO "
   If _CSF4="S"
      _cQuery    += "FROM "+RetSqlName("SD2")+" SD2,  "
      _cQuery    += RetSqlName("SF4")+" SF4 "
   Else
      _cQuery    += "FROM "+RetSqlName("SD2")+" SD2   "
   EndIf   
   _cQuery    += "WHERE SD2.D2_FILIAL='"+xFilial("SD2")+"' AND "
   _cQuery    += "SD2.D2_CLIENTE = '"+SA1->A1_COD+"' AND "
   _cQuery    += "SD2.D2_LOJA = '"+SA1->A1_LOJA+"' AND "
   _cQuery    += "SD2.D2_COD  = '"+oGDAProd:aCols[n][np_CODPRO]+"' AND "  
   _cQuery    += "SD2.D2_DOC  = '"+oGDAProd:aCols[n][np_DOCORI]+"' AND "  
   _cQuery    += "SD2.D2_SERIE  = '"+oGDAProd:aCols[n][np_SERIE]+"' AND "  
   _cQuery    += "SD2.D2_CF NOT IN ('5910', '6910') AND "
   _cQuery    += "SD2.D2_QTDEDEV < SD2.D2_QUANT AND "
   _cQuery    += "SD2.D_E_L_E_T_=' ' " 
   If _CSF4="S"
      _cQuery    += " AND SF4.F4_FILIAL='"+xFilial("SF4")+"' AND "
      _cQuery    += "SF4.F4_CODIGO=(SELECT F4_TESDV FROM "+RetSqlName("SF4")+" WHERE "
      _cQuery    += "F4_FILIAL='"+xFilial("SF4")+"' AND "
      _cQuery    += "F4_CODIGO=SD2.D2_TES AND "
      _cQuery    += "D_E_L_E_T_=' ' ) AND "
      _cQuery    += "SF4.D_E_L_E_T_=' ' "       
   EndIf   
   _cQuery    += "ORDER BY D2_DOC DESC"
   _cQuery    := ChangeQuery(_cQuery)

   If Select("_TMPDEV") > 0
      _TMPDEV->(DbCloseArea())
   EndIf

   dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),"_TMPDEV",.T.,.T.)
    //ICARO
	nBRICMS	 := _TMPDEV->D2_BRICMS
	nICMSRET := _TMPDEV->D2_ICMSRET


Calimposto( n, "", nICMSRET, nBRICMS, _TMPDEV->D2_IPI, _TMPDEV->D2_VALIPI, _TMPDEV->D2_PICM, _TMPDEV->D2_VALICM )

If Select("_TMPDEV") > 0
   _TMPDEV->(DbCloseArea())
EndIf

Return 

// Query de Pesquisa do Registro de ORIGEM
Static Function fnotaori(_prod,_notori,_serori,_regori)
_cQuery    := "SELECT SD2.*,SD2.R_E_C_N_O_ SD2RECNO "
_cQuery    += "FROM "+RetSqlName("SD2")+" SD2   "
_cQuery    += "WHERE SD2.D2_FILIAL='"+xFilial("SD2")+"' AND "
_cQuery    += "SD2.D2_CLIENTE = '"+SA1->A1_COD+"' AND "
_cQuery    += "SD2.D2_LOJA = '"+SA1->A1_LOJA+"' AND "
_cQuery    += "SD2.D2_COD  = '"+_prod+"' AND "  
_cQuery    += "SD2.D2_DOC  = '"+_notori+"' AND "
_cQuery    += "SD2.D2_SERIE  = '"+_serori+"' AND "
_cQuery    += "SD2.D2_CF NOT IN ('5910', '6910') AND "
_cQuery    += "SD2.D_E_L_E_T_=' ' " 
_cQuery    += "ORDER BY D2_DOC DESC"
_cQuery    := ChangeQuery(_cQuery)

If Select("_TMPDEV") > 0
   _TMPDEV->(DbCloseArea())
EndIf

DbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),"_TMPDEV",.T.,.T.)
_TMPDEV->(DbGotop())   
If _TMPDEV->(!Eof())
   _regori:=_TMPDEV->SD2RECNO
Else
   _regori:=0
EndIf
If Select("_TMPDEV") > 0
   _TMPDEV->(DbCloseArea())
EndIf
Return            


//_____________________________________________________________________________
/*/{Protheus.doc} Manunfs
Rotina de espelho da NF.

@author Juscelino Santos | Icaro Queiroz
@since 20 de Novembro de 2015
@owner FIT Gestao for Ourolux
/*/
//_____________________________________________________________________________
User Function MailReq()
Local oMsg
Local oDlg			:= NIL
Local cMask			:= "Todos os arquivos (*.*) |*.*|"
Local cEol			:= chr(13)+chr(10)
Private cServer	    := AllTrim(GetNewPar("MV_RELSERV"," "))
Private cAccount	:= AllTrim(GetNewPar("MV_RELACNT"," "))
Private cPassword	:= AllTrim(GetNewPar("MV_RELPSW" ," "))
Private lSmtpAuth	:= GetMv("MV_RELAUTH",,.F.)
Private cFrom		:= GetMv("MV_RELFROM")    
Private cAnexos	    := Space(200)
Private cTo			:= Alltrim(_cEmail)+Space(100)
Private cCC			:= space(200)
Private cSubject	:= "[Ourolux] Espelho de NF de devolução de venda"
Private cBody		:= "Segue em anexo o espelho referente a sua devolução, por gentileza emitir a NFD conforme espelho, destacando os impostos conforme abaixo:" + cEol + cEol
Private lOk			:= .T.
Private lAutOk		:= .F.
Private aFiles		:= {}
Private cTitulo	    := "Envio de e-mail Protheus"
Private cDirSpool := GetMv("MV_RELT")

cBody += "Posteriormente encaminhar a NFD com XML para o e-mail nfe@ourolux.com.br" + cEol + cEol

cBody += "Procedimento para emissão de NFD eletrônica:" + cEol
cBody += "1. Base e valor do ICMS destacar em campo próprio, cliente do simples deve seguir está mesma orientação de acordo com a resolução CGSN 94/11 artigo 57 parágrafo 7." + cEol
cBody += '2. ST e IPI destacar em dados adicionais e em outras despesas para somar no total da NF.' + cEol
cBody += '3. A CFOP deve ser conforme consta no espelho e a natureza de operação deve ser "Devolução".' + cEol
cBody += '4. Destacar os números das notas de origem em dados adicionais.' + cEol
cBody += '5. Colocar na NFD a quantidade de volumes considerando "caixa".' + cEol
cBody += '6. Informar nos dados adicionais o motivo da devolução.' + cEol
cBody += '7. No envio da NFD, por gentileza informar o responsável pela mesma na loja/estabelecimento.' + cEol
cBody += " " + cEol
cBody += "Caso sua NFD seja manual, por gentileza solicite o procedimento no e-mail: posvenda@ourolux.com.br" + cEol + cEol
cBody += "Atenciosamente," + cEol
cBody += " " + cEol
//cBody += AllTrim(aArray[1][4]) + cEol
cBody += "Departamento Comercial" + cEol
cBody += "Ourolux " + cEol

cDiretorio := AllTrim(GetNewPar("MV_RELT"," "))
If EMPTY(cDiretorio)
	cDiretorio := "\"
EndIf
  
DEFINE MSDIALOG oDlg TITLE cTitulo FROM 0,0 TO 350,570 OF oDlg PIXEL

@  3,3 SAY "De"		SIZE 30,7 PIXEL OF oDlg
@ 15,3 SAY "Para"		SIZE 30,7 PIXEL OF oDlg
@ 27,3 SAY "Cc"		SIZE 30,7 PIXEL OF oDlg
@ 39,3 SAY "Assunto"	SIZE 30,7 PIXEL OF oDlg
@ 51,3 SAY "Anexo"		SIZE 30,7 PIXEL OF oDlg
@ 63,3 SAY "Mensagem"	SIZE 30,7 PIXEL OF oDlg

@  2, 35 MSGET cFrom		PICTURE "@" SIZE 248, 7 PIXEL OF oDlg
@ 14, 35 MSGET cTo			PICTURE "@" SIZE 248, 7 PIXEL OF oDlg
@ 26, 35 MSGET cCC			PICTURE "@" SIZE 248, 8 PIXEL OF oDlg
@ 38, 35 MSGET cSubject	PICTURE "@" SIZE 248, 8 PIXEL OF oDlg
@ 50, 35 MSGET cAnexos	PICTURE "@" SIZE 233, 8 PIXEL OF oDlg
@ 49,269 BUTTON "..." SIZE 13,11 PIXEL OF oDlg ACTION cAnexos:=AllTrim(cGetFile(cMask, "Inserir anexo",,"H:\devolução - pós venda\espelhos de devolução [sistema]\", .T., GETF_NETWORKDRIVE + GETF_LOCALFLOPPY + GETF_LOCALHARD ))
@ 62, 35 GET oMsg VAR cBody MEMO SIZE 248,93 PIXEL OF oDlg

@ 160,210 BUTTON "&Enviar"		SIZE 36,13 PIXEL ACTION (lOpc:=Validar(),Iif(lOpc,Eval({||Enviar(),oDlg:End()}),NIL))
@ 160,248 BUTTON "&Cancelar"	SIZE 36,13 PIXEL ACTION oDlg:End()

ACTIVATE MSDIALOG oDlg CENTERED

RETURN


//_____________________________________________________________________________
/*/{Protheus.doc} Manunfs
Rotina de espelho da NF.

@author Juscelino Santos | Icaro Queiroz
@since 20 de Novembro de 2015
@owner FIT Gestao for Ourolux
/*/
//_____________________________________________________________________________
STATIC FUNCTION Enviar()
CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lOk

If !lAutOk
	If ( lSmtpAuth )
		lAutOk := MailAuth(cAccount,cPassword)
	Else
		lAutOk := .T.
	EndIf
EndIf
If lOk .and. lAutOk
    // copiar o anexo
    If !Empty(cAnexos)
       CpyT2S(cAnexos, "\SYSTEM")
       _arq:=""
       _nposbarA:=AT("\",cAnexos)
       _nposbar1:=AT("\",cAnexos)
       If _nposbar1>0            
          _arq:=SubStr(cAnexos,_nposbar1+1)
          _nposbar1:=AT("\",_arq)
          If _nposbar1>0         
             _nposbarA:=_nposbar1
             _arq:=SubStr(_arq,_nposbar1+1)
             _nposbar1:=AT("\",_arq)
             If _nposbar1>0         
                _arq:=Alltrim(SubStr(_arq,_nposbar1+1))
             ELSE 
                _arq:=Alltrim(_arq)
             EndIf
          Else 
             _arq:=Alltrim(_arq)
          EndIf   
       Else
          _arq:=Alltrim(cAnexos)
       EndIf         
       cAnexos:="\system\"+_arq
    EndIf    

	If !Empty(cCC)
		SEND MAIL FROM cFrom TO cTo CC cCC SUBJECT Alltrim(cSubject) BODY cBody ATTACHMENT cAnexos Result lOk
	Else
		SEND MAIL FROM cFrom TO cTo SUBJECT Alltrim(cSubject) BODY cBody ATTACHMENT cAnexos Result lOk
	EndIf
	If lOk
		MsgInfo("Email enviado com sucesso")
	Else
		GET MAIL ERROR cErro
		MsgStop("Não foi possível enviar o Email." +Chr(13)+Chr(10)+ cErro,"AVISO")
		Return .f.
	EndIf
	Ferase("\SYSTEM\"+cAnexos)
Else
	GET MAIL ERROR cErro
	MsgStop("Erro na conexão com o SMTP Server." +Chr(13)+Chr(10)+ cErro,"AVISO")
	Return .f.
	
EndIf


//_____________________________________________________________________________
/*/{Protheus.doc} Manunfs
Rotina de espelho da NF.

@author Juscelino Santos | Icaro Queiroz
@since 20 de Novembro de 2015
@owner FIT Gestao for Ourolux
/*/
//_____________________________________________________________________________
STATIC FUNCTION Validar()
Local lRet := .T.
If Empty(cFrom)
	MsgInfo("Campo 'De' preenchimento obrigatório",cTitulo)
	lRet:=.F.
Endif
If Empty(cTo) .And. lRet
	MsgInfo("Campo 'Para' preenchimento obrigatório",cTitulo)
	lRet:=.F.
Endif
If Empty(cSubject) .And. lRet
	MsgInfo("Campo 'Assunto' preenchimento obrigatório",cTitulo)
	lRet:=.F.
Endif

If lRet                
    If !Empty(cAnexos)
       CpyT2S( cAnexos, "\SYSTEM")
    EndIf   
	cTo      := AllTrim(cTo)
	cFrom    := AllTrim(cFrom)
	cCC      := AllTrim(cCC)
	cSubject := AllTrim(cSubject)
	cAnexos  := AllTrim(cAnexos)
Endif

RETURN(lRet)



                  
