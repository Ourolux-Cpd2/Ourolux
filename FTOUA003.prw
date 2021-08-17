// #########################################################################################
// Projeto: OUROLUX - PROJETO TRANSPOFRETE
// Modulo : AUTENTICACAO Integração API REST/JSON
// Fonte  : FTOUA003
// ---------+-------------------+-----------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+-----------------------------------------------------------
// 14/08/19 | Roberto Marques   | Classe para conexão à API TranspoFrete
// ---------+-------------------+-----------------------------------------------------------

#INCLUDE 	"PROTHEUS.CH"
#INCLUDE	"TOTVS.CH"
#INCLUDE 	"RWMAKE.CH"
#INCLUDE 	"AP5MAIL.CH"
#INCLUDE 	"TBICONN.CH"
#INCLUDE 	"TBICODE.CH"

#DEFINE 	cEOL			Chr(13) + Chr(10)

User Function TESTE003()

	If RpcSetEnv("01","01") 
	 	 	  
		//Requisicao do acesso
		oREST := FTOUA003():New()
		oREST:RESTConn() 
		lReturn := oRest:lRetorno
		cToken  := oREST:cToken
	
	Endif
	
Return(Nil)


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} FTOUA003
//Classe para conexão à API 
@author ROBERTO MARQUES - TRIYO 
@since 14/08/19
@version 1.00

@type class
/*/
//------------------------------------------------------------------------------------------
CLASS FTOUA003
	Data lRetorno
    Data cToken 
	METHOD New() CONSTRUCTOR
	METHOD RESTConn()
ENDCLASS



//------------------------------------------------------------------------------------------
/*/{Protheus.doc} New
//Método construtor.
@author ROBERTO MARQUES
@since 14/08/19
@version 1.00

@type method
/*/ 
//------------------------------------------------------------------------------------------
METHOD New() CLASS FTOUA003

::lRetorno		:= .F.
::cToken        := ""

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RESTConn
//Método para conexão à plataforma TRANSPFRETE via REST/JSON.
@author ROBERTO MARQUES
@since 14/08/19
@version 1.00
@type method
/*/
//------------------------------------------------------------------------------------------
METHOD RESTConn() CLASS FTOUA003

Local lREST			:= .F.
Local cHeaderRet	:= ''	
Local cRespJSON		:= ''
Local cJSon			:= ''
Local cLogin        := GetMv("TI_LOGRES",,"ourolux.ws")
Local cSenha        := GetMv("TI_PSWRES",,"Oo123456")	
Local aRet      	:= {}

	aHeadStr := {}
	AAdd(aHeadStr, "Content-Type: application/json")    
	
	cJSon := '{'
	cJSon += '"login":"'+cLogin+'",'	
	cJSon += '"senha":"'+cSenha+'"'
	cJSon += '}'
		
	aRet := U_ResInteg("000001", cJson, aHeadStr)
	
	If aRet[1]
	
	    If "USUARIO OU SENHA INVÁLIDOS" $ UPPER(ALLTRIM(aRet[3]))
	    
	    	ConOut("[EMP]  999 - Falha na autenticacao - Integração Protheus x TranspoFrete => " + StrTran(aRet[3],'"',''))
	    	ConOut(StrTran(aRet[3],'"',''))
	    	::cToken 	:= ""
	    	::lRetorno 	:= .F.
		
		Else
		    
	    	ConOut("[EMP]  200 - Autenticado com sucesso - Integração Protheus x TranspoFrete ")
	        ::cToken  	:= StrTran(aRet[3],'"','')
	        ::lRetorno 	:= aRet[1]
	    	
	    Endif
	    
	Else
	    ConOut("[EMP]  999 - Falha na autenticacao - Integração Protheus x TranspoFrete ")
		::cToken 	:= ""
		::lRetorno 	:= aRet[1]
	EndIf
    
Return(Nil)