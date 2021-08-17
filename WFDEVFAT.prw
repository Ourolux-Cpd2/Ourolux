#include "Protheus.ch"
#include "Totvs.ch"
#include "Topconn.ch"
#include "TbiConn.ch"
#include "TbiCode.ch"
#include "rwmake.ch"

#DEFINE COMP_DATE  "20191209" 

/*/{Protheus.doc} WFDEVFAT
Workflow de Devoluções de vendas com anexo detalhado (link).

@author Maurício O. Aureliano
@since 26/08/2019

/*/

User Function WFDEVFAT()

	Local cReg
	Local cReg2
	Local cAliasQuery:= GetNextAlias()
	Local oProc
	Local nCount 		:= 0 
	Local nTotal 		:= 0

	//PREPARE ENVIRONMENT EMPRESA "01" FILIAL "01"  TABLES "SF1" MODULO "FAT"

	ConOut("Inicio da rotina WFDEVFAT - Data: " + DtoS(DDATABASE))

	If Select("TRB") > 0
		DbSelectArea("TRB")
		TRB->(DbCloseArea())
	EndIf

	cReg := ChangeQuery(Query())
	DbUseArea(.T.,"TOPCONN",TCGenQry(NIL,NIL,cReg),"TRB",.T.,.F.)

	DbSelectArea("TRB")
	TRB->(DbGoTop())

	While TRB->(!EOF())
		TRB->( dbSkip() )
		nCount++
	EndDo

	If nCount > 0

		CONOUT("nCount > 0")

		cSubject := "Relação de Devoluções"

		oProc:= TWFProcess():New( "WFDEVFAT", "Relação de Devoluções" )
		oProc:NewTask("Relação de Devoluções", "\workflow\WFDEVFAT.html")  // Html da mensagem

		oProc:oHtml:ValByName("DATA", DDATABASE) 

		TRB->(DbGoTop())

		While TRB->(!EOF())

			AAdd((oProc:oHtml:valbyname( "it.1" )), TRB->FILIAL)
			AAdd((oProc:oHtml:valbyname( "it.2" )), SToD(TRB->EMISSAO))
			AAdd((oProc:oHtml:valbyname( "it.3" )), TRB->DOC)
			AAdd((oProc:oHtml:valbyname( "it.4" )), Capital(TRB->CLI))
			AAdd((oProc:oHtml:valbyname( "it.5" )), Capital(TRB->VEN))
			AAdd((oProc:oHtml:valbyname( "it.6" )), Capital(TRB->GER))		
			AAdd((oProc:oHtml:valbyname( "it.7" )), Capital(TRB->MOTIVO))
			AAdd((oProc:oHtml:valbyname( "it.8" )), TRANSFORM(TRB->TOTAL,"@E 9,999,999.99"))

			nTotal := nTotal + TRB->TOTAL

			TRB->(DbSkip())

		EndDo

		AAdd((oProc:oHtml:valbyname( "tot.1" )), TRANSFORM(nTotal,"@E 9,999,999.99"))

		// cReg2 := Devlink()

		// AAdd((oProc:oHtml:valbyname( "link.1" )), cReg2)
		// ------------------------------------------------------------------------
		// MOA - 23/09/2019 - 13:14hs
		// Alterado devido substituição da função AllUsers()
		//     pela função FWSFALLUSERS()
		// ------------------------------------------------------------------------
		// oProc:cBCC  := U_GrpEmail('WFDEVFAT')
		oProc:cBCC  := U_GrpEmail('000044')

		oProc:csubject := cSubject

		oProc:start()      

		TRB->(DbCloseArea()) 
	Else

		CONOUT("nCount == 0")

	EndIf	

	ConOut("Fim da rotina WFDEVFAT")

	// RESET ENVIRONMENT

Return    

//**********************************
// Montagem da Query - Devoluções
//**********************************
Static Function Query()

	// Local aArea       := GetArea()
	Local cQuery      := ""
	Local cAliasQuery := GetNextAlias()

	cQuery := " SELECT "
	cQuery += "    F1_FILIAL 'FILIAL'"
	cQuery += "   ,F1_DTDIGIT 'EMISSAO'"
	cQuery += "   ,F1_DOC 'DOC'"
	cQuery += "   ,A1_NREDUZ 'CLI'"
	cQuery += "   ,SA3.A3_NREDUZ 'VEN'"
	cQuery += "   ,SA3A.A3_NREDUZ 'GER'"
	cQuery += "   ,SUM(F1_VALBRUT) 'TOTAL'"
	cQuery += "   ,AG_DESCPO 'MOTIVO'"
	cQuery += " FROM " + RetSqlName("SF1") + " SF1"
	cQuery += "   LEFT JOIN " +  RetSqlName("SA1") + " SA1 ON (A1_COD = F1_FORNECE AND A1_LOJA = F1_LOJA AND SA1.D_E_L_E_T_ = '')"
	cQuery += "   LEFT JOIN " +  RetSqlName("SAG") + " SAG ON (AG_NAOCON = F1_MOTCANC AND SAG.D_E_L_E_T_ = '')"
	cQuery += "   LEFT JOIN " +  RetSqlName("SA3") + " SA3 ON (SA3.A3_COD = A1_VEND AND SA3.D_E_L_E_T_ = '')"
	cQuery += "   LEFT JOIN " +  RetSqlName("SA3") + " SA3A ON (SA3A.A3_COD = SA3.A3_GEREN AND SA3A.D_E_L_E_T_ = '')"
	cQuery += " WHERE "
	cQuery += "   F1_DTDIGIT = '" + DTOS(dDatabase) + "'"
	cQuery += "   AND AG_DESCPO IS NOT NULL"
	cQuery += "   AND SF1.D_E_L_E_T_ = '' "
	cQuery += " GROUP BY F1_FILIAL,F1_DTDIGIT,F1_DOC,A1_NREDUZ,SA3.A3_NREDUZ,SA3A.A3_NREDUZ,AG_DESCPO"
	cQuery += " ORDER BY F1_FILIAL,A1_NREDUZ"

	// RestArea(aArea)

Return cQuery


//**********************************
// MOA - 16/08/2019 - 13:05hs
//**********************************
// Inicio - Anexo acessível via link
//**********************************
Static Function Devlink()

	//  Local aArea				:= GetArea()
	Local cHtml				:= ""
	Local cQuery      		:= ""

	Local cAlias4  			:= GetNextAlias()
	Local cAlias5  			:= GetNextAlias()
	Local cAlias6  			:= GetNextAlias()

	Local cEmailGer		:= ""
	Local cCodGer			:= ""
	Local cNomGer			:= ""

	Local Enter				:= CHR(13)+CHR(10)

	Local cData
	Local cHora
	Local xData
	Local xHora
	Local cAnexo1
	Local cAnexo2
	Local cLink

	Local _cHostWF   := SUPERGETMV("FS_WFURL01", .F.,"http://187.94.63.180:10615/wf/")	//URL configurado no ini para WF Link.

	cHtml:= ' <!DOCTYPE html>'
	cHtml+= ' <html>'

	cHtml+= Enter + ' <head>'
	cHtml+= Enter + '     <title>Relação Devoluções Diárias</title>'

	cHtml+= Enter + '     <style type="text/css">'
	cHtml+= Enter + '     .separador {'
	cHtml+= Enter + '         width: 100%;'
	cHtml+= Enter + '         height: 12px;'
	cHtml+= Enter + '         background-color: #f36e2661;'
	cHtml+= Enter + '     }'

	cHtml+= Enter + '     body {'
	cHtml+= Enter + '         font-family: sans-serif;'
	cHtml+= Enter + '     }'

	cHtml+= Enter + '     .tamanhotabela {'
	cHtml+= Enter + '         width: 100%;'
	cHtml+= Enter + '         border-spacing: 0;'
	cHtml+= Enter + '         margin-top: 50px;'
	cHtml+= Enter + '     }'

	cHtml+= Enter + '     .tamanhotabela2 {'
	cHtml+= Enter + '         width: 80%;'
	cHtml+= Enter + '         border-spacing: 0;'
	cHtml+= Enter + '         margin: 0 10% 20px 10%;'
	cHtml+= Enter + '     }'

	cHtml+= Enter + '     .ajustalogo {'
	cHtml+= Enter + '         margin: 0 auto;'
	cHtml+= Enter + '         justify-content: center;'
	cHtml+= Enter + '         display: flex;'
	cHtml+= Enter + '         padding: 25px;'
	cHtml+= Enter + '     }'

	cHtml+= Enter + '     .bordalogo {'
	cHtml+= Enter + '         border: 1px solid #8080805e;'
	cHtml+= Enter + '         padding: 7px;'
	cHtml+= Enter + '     }'

	cHtml+= Enter + '     .ajustacoluna1 {'
	cHtml+= Enter + '         width: 1%;'
	cHtml+= Enter + '         border: 1px solid #8080805e;'
	cHtml+= Enter + '         margin: 0;'
	cHtml+= Enter + '         padding: 10px;'
	cHtml+= Enter + '         font-size: 1px;'
	cHtml+= Enter + '         background-color: #aba4a5;'
	cHtml+= Enter + '         color: #ecaaaa;'
	cHtml+= Enter + '         text-align: center;'
	cHtml+= Enter + '     }'

	cHtml+= Enter + '     .ajustacoluna2 {'
	cHtml+= Enter + '         width: 5%;'
	cHtml+= Enter + '         border: 1px solid #8080805e;'
	cHtml+= Enter + '         margin: 0;'
	cHtml+= Enter + '         padding: 10px;'
	cHtml+= Enter + '         font-size: 14px;'
	cHtml+= Enter + '         background-color: #4b01ff;'
	cHtml+= Enter + '         color: white;'
	cHtml+= Enter + '         text-align: left;'
	cHtml+= Enter + '     }'

	cHtml+= Enter + '     .ajustacoluna3 {'
	cHtml+= Enter + '         width: 5%;'
	cHtml+= Enter + '         border: 1px solid #8080805e;'
	cHtml+= Enter + '         margin: 0;'
	cHtml+= Enter + '         padding: 10px;'
	cHtml+= Enter + '         font-size: 14px;'
	cHtml+= Enter + '         background-color: #4b01ff;'
	cHtml+= Enter + '         color: white;'
	cHtml+= Enter + '         text-align: left;'
	cHtml+= Enter + '     }'

	cHtml+= Enter + '     .ajustacoluna4 {'
	cHtml+= Enter + '         width: 1%;'
	cHtml+= Enter + '         border: 1px solid #8080805e;'
	cHtml+= Enter + '         margin: 0;'
	cHtml+= Enter + '         padding: 10px;'
	cHtml+= Enter + '         font-size: 14px;'
	cHtml+= Enter + '         background-color: #4b01ff;'
	cHtml+= Enter + '         color: white;'
	cHtml+= Enter + '         text-align: left;'
	cHtml+= Enter + '     }'

	cHtml+= Enter + '     .ajustacoluna5 {'
	cHtml+= Enter + '         width: 20%;'
	cHtml+= Enter + '         border: 1px solid #8080805e;'
	cHtml+= Enter + '         margin: 0;'
	cHtml+= Enter + '         padding: 10px;'
	cHtml+= Enter + '         font-size: 14px;'
	cHtml+= Enter + '         background-color: #4b01ff;'
	cHtml+= Enter + '         color: white;'
	cHtml+= Enter + '         text-align: left;'
	cHtml+= Enter + '     }'

	cHtml+= Enter + '     .ajustacoluna6 {'
	cHtml+= Enter + '         width: 20%;'
	cHtml+= Enter + '         border: 1px solid #8080805e;'
	cHtml+= Enter + '         margin: 0;'
	cHtml+= Enter + '         padding: 10px;'
	cHtml+= Enter + '         font-size: 14px;'
	cHtml+= Enter + '         background-color: #4b01ff;'
	cHtml+= Enter + '         color: white;'
	cHtml+= Enter + '         text-align: left;'
	cHtml+= Enter + '     }'

	cHtml+= Enter + '     .ajustacoluna7 {'
	cHtml+= Enter + '         width: 12%;'
	cHtml+= Enter + '         border: 1px solid #8080805e;'
	cHtml+= Enter + '         margin: 0;'
	cHtml+= Enter + '         padding: 10px;'
	cHtml+= Enter + '         font-size: 14px;'
	cHtml+= Enter + '         background-color: #4b01ff;'
	cHtml+= Enter + '         color: white;'
	cHtml+= Enter + '         text-align: right;'
	cHtml+= Enter + '     }'

	cHtml+= Enter + '     .ajustacoluna8 {'
	cHtml+= Enter + '         width: 15%;'
	cHtml+= Enter + '         border: 1px solid #8080805e;'
	cHtml+= Enter + '         margin: 0;'
	cHtml+= Enter + '         padding: 10px;'
	cHtml+= Enter + '         font-size: 14px;'
	cHtml+= Enter + '         background-color: #4b01ff;'
	cHtml+= Enter + '         color: white;'
	cHtml+= Enter + '         text-align: center;'
	cHtml+= Enter + '     }'

	cHtml+= Enter + '     .ajustacoluna9 {'
	cHtml+= Enter + '         width: 10%;'
	cHtml+= Enter + '         border: 1px solid #8080805e;'
	cHtml+= Enter + '         margin: 0;'
	cHtml+= Enter + '         padding: 10px;'
	cHtml+= Enter + '         font-size: 14px;'
	cHtml+= Enter + '         background-color: #4b01ff;'
	cHtml+= Enter + '         color: white;'
	cHtml+= Enter + '         text-align: left;'
	cHtml+= Enter + '     }'

	cHtml+= Enter + '     .titulo {'
	cHtml+= Enter + '         width: 80%;'
	cHtml+= Enter + '         display: inline-block;'
	cHtml+= Enter + '         top: 0;'
	cHtml+= Enter + '         text-align: left;'
	cHtml+= Enter + '         color: #4b01ff;'
	cHtml+= Enter + '     }'

	cHtml+= Enter + '     .divlogo {'
	cHtml+= Enter + '         display: inline-block;'
	cHtml+= Enter + '         right: 0;'
	cHtml+= Enter + '         top: 0;'
	cHtml+= Enter + '         position: absolute;'
	cHtml+= Enter + '     }'

	cHtml+= Enter + '     .button{'
	cHtml+= Enter + '            font-size: 15px;'
	cHtml+= Enter + '     width: 100%;'
	cHtml+= Enter + '     margin-bottom: 5px;'
	cHtml+= Enter + '     }'

	cHtml+= Enter + '     span {'
	cHtml+= Enter + '         font-weight: 700;'
	cHtml+= Enter + '     }'

	cHtml+= Enter + '     .ajustatd1 {'
	cHtml+= Enter + '         border: 1px solid #8080805e;'
	cHtml+= Enter + '         padding: 10px;'
	cHtml+= Enter + '         text-align: center;'
	cHtml+= Enter + '     }'

	cHtml+= Enter + '     .ajustatd2 {'
	cHtml+= Enter + '         border: 1px solid #8080805e;'
	cHtml+= Enter + '         padding: 10px;'
	cHtml+= Enter + '         text-align: left;'
	cHtml+= Enter + '     }'

	cHtml+= Enter + '     .ajustatd3 {'
	cHtml+= Enter + '         border: 1px solid #8080805e;'
	cHtml+= Enter + '         padding: 10px;'
	cHtml+= Enter + '         text-align: left;'
	cHtml+= Enter + '     }'

	cHtml+= Enter + '     .ajustatd4 {'
	cHtml+= Enter + '         border: 1px solid #8080805e;'
	cHtml+= Enter + '         padding: 10px;'
	cHtml+= Enter + '         text-align: left;'
	cHtml+= Enter + '     }'

	cHtml+= Enter + '     .ajustatd5 {'
	cHtml+= Enter + '         border: 1px solid #8080805e;'
	cHtml+= Enter + '         padding: 10px;'
	cHtml+= Enter + '         text-align: left;'
	cHtml+= Enter + '     }'

	cHtml+= Enter + '     .ajustatd6 {'
	cHtml+= Enter + '         border: 1px solid #8080805e;'
	cHtml+= Enter + '         padding: 10px;'
	cHtml+= Enter + '         text-align: left;'
	cHtml+= Enter + '     }'

	cHtml+= Enter + '     .ajustatd7 {'
	cHtml+= Enter + '         border: 1px solid #8080805e;'
	cHtml+= Enter + '         padding: 10px;'
	cHtml+= Enter + '         text-align: right;'
	cHtml+= Enter + '     }'

	cHtml+= Enter + '     .ajustatd8 {'
	cHtml+= Enter + '         border: 1px solid #8080805e;'
	cHtml+= Enter + '         padding: 10px;'
	cHtml+= Enter + '         text-align: center;'
	cHtml+= Enter + '     }'

	cHtml+= Enter + '     .ajustatd9 {'
	cHtml+= Enter + '         border: 1px solid #8080805e;'
	cHtml+= Enter + '         padding: 10px;'
	cHtml+= Enter + '         text-align: left;'
	cHtml+= Enter + '     }'

	cHtml+= Enter + '     .ajustaitem1 {'
	cHtml+= Enter + '         width: 5%;'
	cHtml+= Enter + '         border: 1px solid #8080805e;'
	cHtml+= Enter + '         margin: 0;'
	cHtml+= Enter + '         padding: 10px;'
	cHtml+= Enter + '         font-size: 14px;'
	cHtml+= Enter + '         background-color: #aba4a5;'
	cHtml+= Enter + '         color: white;'
	cHtml+= Enter + '         text-align: left;'
	cHtml+= Enter + '     }'

	cHtml+= Enter + '     .ajustaitem2 {'
	cHtml+= Enter + '         width: 35%;'
	cHtml+= Enter + '         border: 1px solid #8080805e;'
	cHtml+= Enter + '         margin: 0;'
	cHtml+= Enter + '         padding: 10px;'
	cHtml+= Enter + '         font-size: 14px;'
	cHtml+= Enter + '         background-color: #aba4a5;'
	cHtml+= Enter + '         color: white;'
	cHtml+= Enter + '         text-align: left;'
	cHtml+= Enter + '     }'

	cHtml+= Enter + '     .ajustaitem3 {'
	cHtml+= Enter + '         width: 10%;'
	cHtml+= Enter + '         border: 1px solid #8080805e;'
	cHtml+= Enter + '         margin: 0;'
	cHtml+= Enter + '         padding: 10px;'
	cHtml+= Enter + '         font-size: 14px;'
	cHtml+= Enter + '         background-color: #aba4a5;'
	cHtml+= Enter + '         color: white;'
	cHtml+= Enter + '         text-align: right;'
	cHtml+= Enter + '     }'

	cHtml+= Enter + '     .ajustaitem4 {'
	cHtml+= Enter + '         width: 20%;'
	cHtml+= Enter + '         border: 1px solid #8080805e;'
	cHtml+= Enter + '         margin: 0;'
	cHtml+= Enter + '         padding: 10px;'
	cHtml+= Enter + '         font-size: 14px;'
	cHtml+= Enter + '         background-color: #aba4a5;'
	cHtml+= Enter + '         color: white;'
	cHtml+= Enter + '         text-align: right;'
	cHtml+= Enter + '     }'

	cHtml+= Enter + '     .ajustaitem5 {'
	cHtml+= Enter + '         width: 25%;'
	cHtml+= Enter + '         border: 1px solid #8080805e;'
	cHtml+= Enter + '         margin: 0;'
	cHtml+= Enter + '         padding: 10px;'
	cHtml+= Enter + '         font-size: 14px;'
	cHtml+= Enter + '         background-color: #aba4a5;'
	cHtml+= Enter + '         color: white;'
	cHtml+= Enter + '         text-align: right;'
	cHtml+= Enter + '     }'

	cHtml+= Enter + '     .ajustait1 {'
	cHtml+= Enter + '         border: 1px solid #8080805e;'
	cHtml+= Enter + '         padding: 10px;'
	cHtml+= Enter + '         text-align: left;'
	cHtml+= Enter + '     }'

	cHtml+= Enter + '     .ajustait2 {'
	cHtml+= Enter + '         border: 1px solid #8080805e;'
	cHtml+= Enter + '         padding: 10px;'
	cHtml+= Enter + '         text-align: left;'
	cHtml+= Enter + '     }'

	cHtml+= Enter + '     .ajustait3 {'
	cHtml+= Enter + '         border: 1px solid #8080805e;'
	cHtml+= Enter + '         padding: 10px;'
	cHtml+= Enter + '         text-align: right;'
	cHtml+= Enter + '     }'

	cHtml+= Enter + '     .ajustait4 {'
	cHtml+= Enter + '         border: 1px solid #8080805e;'
	cHtml+= Enter + '         padding: 10px;'
	cHtml+= Enter + '         text-align: right;'
	cHtml+= Enter + '     }'

	cHtml+= Enter + '     .ajustait5 {'
	cHtml+= Enter + '         border: 1px solid #8080805e;'
	cHtml+= Enter + '         padding: 10px;'
	cHtml+= Enter + '         text-align: right;'
	cHtml+= Enter + '     }'
	cHtml+= Enter + '     </style>'
	cHtml+= Enter + '     <script src="https://ajax.googleapis.com/ajax/libs/angularjs/1.4.5/angular.min.js"></script>'
	cHtml+= Enter + ' </head>'

	cHtml+= Enter + ' <body ng-app="rel" ng-controller="MainController as main">'
	cHtml+= Enter + '     <div class="bordalogo">'
	cHtml+= Enter + '         <div class="titulo">'

	cHtml+= Enter + '             <h1>Relação de Devolução de Vendas</h1>'

	cHtml+= Enter + '         </div>'
	cHtml+= Enter + '         <div class="divlogo">'
	cHtml+= Enter + '             <img src="http://www.ourolux.com.br/Site/view/images/rodape/logo3.png" class="ajustalogo">'
	cHtml+= Enter + '         </div>'
	cHtml+= Enter + '     </div>'
	cHtml+= Enter + '         <table id="TOP" class="tamanhotabela">'

	cHtml+= Enter + '             <thead>'
	cHtml+= Enter + '                 <tr>'
	cHtml+= Enter + '                    <th class="ajustacoluna1"></th>'
	cHtml+= Enter + '                     <th class="ajustacoluna4">Filial</th>'
	cHtml+= Enter + '                     <th class="ajustacoluna2">Emissão</th>'
	cHtml+= Enter + '                     <th class="ajustacoluna3">Nota Fiscal</th>'
	cHtml+= Enter + '                     <th class="ajustacoluna5">Cliente</th>'
	cHtml+= Enter + '                     <th class="ajustacoluna6">Vendedor</th>'
	cHtml+= Enter + '                     <th class="ajustacoluna6">Gerente</th>'
	cHtml+= Enter + '                     <th class="ajustacoluna7">Total</th>'
	cHtml+= Enter + '                     <th class="ajustacoluna6">Motivo</th>'
	cHtml+= Enter + '                 </tr>'
	cHtml+= Enter + '             </thead>'
	cHtml+= Enter + '             <tbody>'

	cQuery	:= Enter + " SELECT"
	cQuery	+= Enter + " F1_FILIAL"
	cQuery	+= Enter + " ,F1_DOC"
	cQuery	+= Enter + " ,F1_SERIE"
	cQuery	+= Enter + " ,F1_FORNECE"
	cQuery	+= Enter + " ,F1_LOJA"
	cQuery	+= Enter + " FROM "+RetSqlName("SF1")+" SF1"
	cQuery	+= Enter + " WHERE"
	cQuery	+= Enter + " F1_TIPO = 'D'"
	cQuery	+= Enter + " AND F1_DTDIGIT = '" + Dtos(DDATABASE) + "'"
	cQuery	+= Enter + " AND SF1.D_E_L_E_T_ = ''"
	cQuery	+= Enter + " ORDER BY SF1.F1_FILIAL"

	TcQuery cQuery New Alias (cAlias4)
	(cAlias4)->(dbGoTop())
	while !(cAlias4)->(EOF())

		// --- INICIO TOTAL                         
		_nTotBRUTO	:= 0
		cQuery	:= " SELECT SUM(F1_VALBRUT) TOTBRUTO FROM "+RetSqlName("SF1")+" "
		cQuery	+= Enter + "  WHERE F1_FILIAL = '"+(cAlias4)->F1_FILIAL+"' "
		cQuery	+= Enter + "  AND F1_DOC = '"+(cAlias4)->F1_DOC+"' "
		cQuery	+= Enter + "  AND F1_SERIE = '"+(cAlias4)->F1_SERIE+"' "
		cQuery	+= Enter + "  AND F1_FORNECE = '"+(cAlias4)->F1_FORNECE+"' "
		cQuery	+= Enter + "  AND F1_LOJA = '"+(cAlias4)->F1_LOJA+"' "
		cQuery += Enter + "  AND F1_DTDIGIT = '" + DTOS(dDatabase) + "'"
		cQuery	+= Enter + "  AND D_E_L_E_T_ = '' "

		TcQuery cQuery New Alias (cAlias6)

		_nTotBRUTO	:= (cAlias6)->TOTBRUTO
		(cAlias6)->(DbCloseArea())
		// --- FIM TOTAL 

		cQuery	:= Enter + " SELECT"
		cQuery	+= Enter + " D1_FILIAL"
		cQuery	+= Enter + " ,D1_DOC"
		cQuery	+= Enter + " ,D1_SERIE"
		cQuery	+= Enter + " ,D1_FORNECE"
		cQuery	+= Enter + " ,D1_LOJA"
		cQuery	+= Enter + " ,D1_EMISSAO"		
		cQuery	+= Enter + " ,D1_ITEM"
		cQuery	+= Enter + " ,D1_COD"
		cQuery	+= Enter + " ,D1_QUANT"
		cQuery	+= Enter + " ,D1_VUNIT"
		cQuery	+= Enter + " ,D1_TOTAL"	
		cQuery	+= Enter + " ,D1_VALIPI"
		cQuery	+= Enter + " ,D1_ICMSRET"
		cQuery	+= Enter + " ,F1_VALBRUT"		
		cQuery	+= Enter + " ,A1_NREDUZ"
		cQuery	+= Enter + " ,A1_VEND"
		cQuery	+= Enter + " ,A3_NREDUZ"
		cQuery	+= Enter + " ,A3_SUPER"
		cQuery	+= Enter + " ,A3_GEREN"
		cQuery	+= Enter + " ,Isnull(AG_DESCPO,'NFe nao Classificada!') AG_DESCPO"
		cQuery	+= Enter + " ,B1_DESC"
		cQuery	+= Enter + " FROM "+RetSqlName("SD1")+" SD1"
		cQuery	+= Enter + " LEFT JOIN "+RetSqlName("SF1")+" SF1 ON (F1_FILIAL = D1_FILIAL AND F1_DOC = D1_DOC AND F1_SERIE = D1_SERIE AND F1_FORNECE = D1_FORNECE AND F1_LOJA = D1_LOJA AND SF1.D_E_L_E_T_ = '')"
		cQuery	+= Enter + " LEFT JOIN "+RetSqlName("SA1")+" SA1 ON (A1_COD = F1_FORNECE AND A1_LOJA = F1_LOJA AND SA1.D_E_L_E_T_ = '')"
		cQuery	+= Enter + " LEFT JOIN "+RetSqlName("SAG")+" SAG ON (AG_NAOCON = F1_MOTCANC AND SAG.D_E_L_E_T_ = '')"
		cQuery	+= Enter + " LEFT JOIN "+RetSqlName("SA3")+" SA3 ON (A3_COD = A1_VEND AND SA3.D_E_L_E_T_ = '')"
		cQuery	+= Enter + " LEFT JOIN "+RetSqlName("SB1")+" SB1 ON (B1_COD = D1_COD AND SB1.D_E_L_E_T_ = '')"
		cQuery	+= Enter + " WHERE"
		cQuery	+= Enter + " F1_TIPO = 'D'"
		cQuery	+= Enter + " AND D1_FILIAL = '"	+ (cAlias4)->F1_FILIAL	+ "' "
		cQuery	+= Enter + " AND D1_DOC = '"	+ (cAlias4)->F1_DOC		+ "' "
		cQuery	+= Enter + " AND D1_SERIE = '"	+ (cAlias4)->F1_SERIE	+ "' "
		cQuery	+= Enter + " AND D1_FORNECE = '"+ (cAlias4)->F1_FORNECE	+ "' "
		cQuery	+= Enter + " AND D1_LOJA = '"	+ (cAlias4)->F1_LOJA	+ "' "
		cQuery += Enter + " AND AG_DESCPO IS NOT NULL"
		cQuery += Enter + " AND F1_DTDIGIT = '" + DTOS(dDatabase) + "'"
		cQuery	+= Enter + " AND SD1.D_E_L_E_T_ = ''"
		cQuery	+= Enter + " ORDER BY SD1.D1_FILIAL,SA1.A1_NREDUZ"

		TcQuery cQuery New Alias (cAlias5)
		(cAlias5)->(dbGoTop())

		// cEmailSuper := Alltrim(GetAdvFVal("SA3","A3_EMAIL",xFilial("SA3")+(cAlias5)->A3_SUPER,1,""))
		// cCodSup 	:= RTrim(GetAdvFVal("SA3","A3_SUPER",xFilial("SA3")+SA1->A1_VEND,1,""))
		// cNomSup 	:= RTrim(GetAdvFVal("SA3","A3_NOME",xFilial("SA3")+cCodSup,1,""))

		cEmailGer 	:= Alltrim(GetAdvFVal("SA3","A3_EMAIL",xFilial("SA3")+SA3->A3_GEREN,1,""))
		cCodGer 	:= RTrim(GetAdvFVal("SA3","A3_GEREN",xFilial("SA3")+SA1->A1_VEND,1,""))
		cNomGer 	:= RTrim(GetAdvFVal("SA3","A3_NREDUZ",xFilial("SA3")+cCodGer,1,""))

		cHtml+= Enter + '         <tr>'
		cHtml+= Enter + '             <td class="ajustatd1"><button ng-click="main.detalhesadd('+"'"+(cAlias5)->D1_DOC+"'"+')"> + </button></td>'
		cHtml+= Enter + '             <td class="ajustatd4">'+(cAlias5)->D1_FILIAL+'</td>'
		cHtml+= Enter + '             <td class="ajustatd2">'+DTOC(STOD((cAlias5)->D1_EMISSAO))+'</td>'
		cHtml+= Enter + '             <td class="ajustatd3">'+(cAlias5)->D1_DOC+'</td>'
		cHtml+= Enter + '             <td class="ajustatd5">'+AllTrim((cAlias5)->A1_NREDUZ)+'</td>'
		cHtml+= Enter + '             <td class="ajustatd6">'+upper(AllTrim((cAlias5)->A3_NREDUZ))+'</td>'
		cHtml+= Enter + '             <td class="ajustatd8">'+upper(AllTrim(cNomGer))+'</td>'
		cHtml+= Enter + '             <td class="ajustatd7">'+AllTrim(Transform(_nTotBRUTO,"@E 9,999,999.99"))+'</td>'
		cHtml+= Enter + '             <td class="ajustatd5">'+AllTrim((cAlias5)->AG_DESCPO)+'</td>'		
		cHtml+= Enter + '         </tr>'

		cHtml+= Enter + '         <tr ng-show="main.detalhes == '+"'"+(cAlias5)->D1_DOC+"'"+'">'
		cHtml+= Enter + '             <td colspan="10">'
		cHtml+= Enter + '                 <table class="tamanhotabela2">'
		cHtml+= Enter + '                     <tbody>'
		cHtml+= Enter + '                         <tr>'
		cHtml+= Enter + '                             <td class="ajustaitem1">Item</td>'
		cHtml+= Enter + '                             <td class="ajustaitem2">Descrição</td>'
		cHtml+= Enter + '                             <td class="ajustaitem3">Qtde</td>'
		cHtml+= Enter + '                             <td class="ajustaitem4">Unitário</td>'
		cHtml+= Enter + '                             <td class="ajustaitem5">Total + Impostos</td>'
		cHtml+= Enter + '                         </tr>
		while !(cAlias5)->(EOF())
			cHtml+= Enter + ' 		              <tr>'
			cHtml+= Enter + '                          <td class="ajustait1">'+(cAlias5)->D1_ITEM+'</td>'
			cHtml+= Enter + '                          <td class="ajustait2">'+alltrim((cAlias5)->D1_COD)+'-'+alltrim((cAlias5)->B1_DESC)+'</td>'
			cHtml+= Enter + '                          <td class="ajustait3">'+AllTrim(Transform((cAlias5)->D1_QUANT,"@E 999,999,999,999.99"))+'</td>'
			cHtml+= Enter + '                          <td class="ajustait4">'+AllTrim(Transform((cAlias5)->D1_VUNIT,"@E 99,999,999.99"))+'</td>'
			cHtml+= Enter + '                          <td class="ajustait5">'+AllTrim(Transform((cAlias5)->(D1_TOTAL+D1_VALIPI+D1_ICMSRET),"@E 999,999,999,999.99"))+'</td>'
			cHtml+= Enter + '                     </tr>'
			(cAlias5)->(DbSkip())
		Enddo
		(cAlias5)->(DbCloseArea())
		cHtml+= Enter + '                 	  </tbody>'
		cHtml+= Enter + '              	  </table>'
		cHtml+= Enter + '             </td>'
		cHtml+= Enter + '         </tr>'

		(cAlias4)->(DbSkip())
	Enddo
	(cAlias4)->(DbCloseArea())

	cHtml+= Enter + '   		  </tbody>'
	cHtml+= Enter + '		 </table>'
	cHtml+= Enter + '	</body>'
	cHtml+= Enter + '<script>'

	cHtml+= Enter + 'var login = angular.module('+"'"+'rel'+"'"+', [])'

	cHtml+= Enter + 'angular.module('+"'"+'rel'+"'"+').controller("MainController", function($http, $filter) {'

	cHtml+= Enter + '    var vm = this;'

	cHtml+= Enter + '    vm.arraypedidos = [];'
	cHtml+= Enter + '    vm.arraypedidosrec = [];'
	cHtml+= Enter + '    vm.detalhes = '+"'"+"'"+';'


	cHtml+= Enter + '    vm.resposta = function(par) {'
	cHtml+= Enter + '        var ret = '+"'"+''+"'"+';'
	cHtml+= Enter + '        for (var i = 0; i < vm.arraypedidos.length; i++) {'
	cHtml+= Enter + '            vm.arraypedidos[i]'
	cHtml+= Enter + '            if ( vm.arraypedidos[i].pedido == par) {'
	cHtml+= Enter + '                ret = vm.arraypedidos[i].msg;'
	cHtml+= Enter + '                break'
	cHtml+= Enter + '            }'
	cHtml+= Enter + '        }'
	cHtml+= Enter + '        return ret;'
	cHtml+= Enter + '    };'
	cHtml+= Enter + '    vm.detalhesadd = function(par) {'
	cHtml+= Enter + '        if (vm.detalhes !== par) {'
	cHtml+= Enter + '            vm.detalhes = par '
	cHtml+= Enter + '        } else {'
	cHtml+= Enter + '            vm.detalhes = '+"'"+"'"+';'
	cHtml+= Enter + '        }'
	cHtml+= Enter + '    }'
	cHtml+= Enter + '})'
	cHtml+= Enter + '</script>'
	cHtml+= Enter + '</html>'

	//**********************************
	// Fim - Anexo acessível via link
	//**********************************

	cData := dtoc(ddatabase)
	cHora := TIME()

	xData := SUBSTR(dtoc(ddatabase),1,2)+SUBSTR(dtoc(ddatabase),4,2)+SUBSTR(dtoc(ddatabase),7,4)
	xHora := SUBSTR(TIME(),1,2)+SUBSTR(TIME(),4,2)+SUBSTR(TIME(),7,2)

	cAnexo1:= "\web\messenger\emp01\wfaprov\"+"devfat"+xData+xHora+".html"
	cAnexo2:= "devfat"+xData+xHora+".html"

	nHandle := FCREATE(cAnexo1)
	if nHandle = -1
		conout("Erro ao criar Arquivo - ferror " + Str(Ferror()))
	else
		conout("criado arquivo na pasta: " + cAnexo1 )

		FWrite(nHandle, cHtml)
		FClose(nHandle)
	endif

	cLink := _cHostWF+cAnexo2

	// RestArea(aArea)

Return cLink