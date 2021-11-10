#INCLUDE "RWMAKE.CH"
#Include "AP5MAIL.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "Tbiconn.ch"
#INCLUDE "Tbicode.ch"

#DEFINE COMP_DATE  "20210817" 

//--------------------------------------------------------------------
/*/{Protheus.doc} WFAPPCN1
schedule para envio de email dos pedidos de compra nivel 1 
@author Rodrigo Nunes
@since 17/08/2021
@version 1.0 
@type function
/*/
//--------------------------------------------------------------------

User Function WFAPPCN1()   

Local Enter                		
Local aArea    
Local cAlias1  
Local cAlias2  
Local cAlias3  
Local cAlias4                       
Local _cHostWF   
Local _cHostREST 
local cFS_DIAPRPC
Local cLogName 
local nHist
Local lSched := .T. //Força inciar como schedule 

conout(" ")
conout("Iniciado processo WFAPPCN1 " + DtoC(Date()) + " - " + Time())
conout(" ")

if lSched
   PREPARE ENVIRONMENT EMPRESA "01" FILIAL "01" MODULO "COM"
endif
   
Enter    := CHR(13)+CHR(10)  
aArea    := GetArea()

cAlias1  := GetNextAlias()
cAlias2  := GetNextAlias()
cAlias3  := GetNextAlias()
cAlias4  := GetNextAlias()
cAlias5  := GetNextAlias()

_cHostWF   := SUPERGETMV("FS_WFURL01", .F.,"http://187.94.63.180:10615/wf/")	//URL configurado no ini para WF Link.
_cHostREST := SUPERGETMV("FS_REURL01", .F.,"http://187.94.63.180:10551/rest/") //URL configurado no ini para REST Link.
cFS_DIAPRPC:= SUPERGETMV('FS_DIAPRPC',.T.,"60") 

nHist      := GetMv("FS_NHISTPC", .F., 6 )

cLogName   := "WFAPPCN1"+STRZERO(DAY(dDATAbASE),2)+STRZERO(MONTH(DDATABASE),2)+STRZERO(YEAR(dDATAbASE),4)+".QRY"
            
cQuery	:= " SELECT DISTINCT CR_USER "
cQuery	+= Enter + "   FROM ( "
cQuery	+= Enter + "		SELECT * FROM "+RetSqlName("SCR")+" SCR1 "
cQuery	+= Enter + "		 WHERE SCR1.CR_FILIAL <> '99' "
cQuery	+= Enter + "		   AND SCR1.CR_NIVEL = '01' "
cQuery	+= Enter + "		   AND SCR1.CR_STATUS = '02' "
cQuery	+= Enter + "		   AND SCR1.CR_EMISSAO > CONVERT( VARCHAR, (GETDATE()-"+cFS_DIAPRPC+") , 112 ) "
cQuery	+= Enter + "		   AND SCR1.CR_NUM  IN (SELECT CR_NUM FROM "+RetSqlName("SCR")+" SCR2 "
cQuery	+= Enter + "								 WHERE SCR2.CR_FILIAL = SCR1.CR_FILIAL "
cQuery	+= Enter + "								   AND SCR2.CR_NIVEL = '02'  "
cQuery	+= Enter + "								   AND SCR2.CR_STATUS = '01' "
cQuery	+= Enter + "								   AND SCR2.CR_EMISSAO > CONVERT( VARCHAR, (GETDATE()-"+cFS_DIAPRPC+") , 112 ) "
cQuery	+= Enter + "								   AND SCR2.D_E_L_E_T_ <> '*') "
cQuery	+= Enter + "		   AND SCR1.D_E_L_E_T_ <> '*' "
cQuery	+= Enter + "		) TMP1 "
cQuery	+= Enter + " WHERE "
cQuery	+= Enter + "    TMP1.CR_NUM  NOT IN (SELECT CR_NUM FROM "+RetSqlName("SCR")+" SCR3 "
cQuery	+= Enter + "						  WHERE SCR3.CR_FILIAL = TMP1.CR_FILIAL "
cQuery	+= Enter + "						    AND SCR3.CR_NIVEL = '01' "
cQuery	+= Enter + "						    AND SCR3.CR_STATUS <> '02' "
cQuery	+= Enter + "						    AND SCR3.CR_EMISSAO > CONVERT( VARCHAR, (GETDATE()-"+cFS_DIAPRPC+") , 112 ) "
cQuery	+= Enter + "						    AND SCR3.D_E_L_E_T_ <> '*') "   
cQuery	+= Enter + " AND "	
cQuery	+= Enter + "    TMP1.CR_NUM IN (SELECT C7_NUM FROM "+RetSqlName("SC7")+" "
cQuery	+= Enter + "				     WHERE C7_FILIAL = TMP1.CR_FILIAL "
cQuery	+= Enter + "				       AND C7_NUM = TMP1.CR_NUM "
cQuery	+= Enter + "					   AND C7_QUANT-C7_QTDACLA-C7_QUJE > 0 "
cQuery	+= Enter + "					   AND C7_RESIDUO = '' "
cQuery	+= Enter + "					   AND D_E_L_E_T_ <> '*') "
cQuery	+= Enter + " ORDER BY CR_USER "

MemoWrite("\INTRJ\" + cLOGNAME,cQuery)

TcQuery cQuery New Alias (cAlias1)
(cAlias1)->(dbGoTop())
while !(cAlias1)->(EOF())   

	cHtml:= Enter + '<!DOCTYPE html>'
	cHtml+= Enter + '<html>'
	cHtml+= Enter + '<head>'
	cHtml+= Enter + '    <title>Relação Pedidos de Compra para Aprovação - Nivel 1</title>'
	cHtml+= Enter + '    <style type="text/css">'
	cHtml+= Enter + '        .separador {'
	cHtml+= Enter + '            width: 100%;'
	cHtml+= Enter + '            height: 12px;'
	cHtml+= Enter + '            background-color: #0041bbe1;'
	cHtml+= Enter + '        }'
        
	cHtml+= Enter + '        body {'
	cHtml+= Enter + '            font-family: sans-serif;'
	cHtml+= Enter + '        }'
        
	cHtml+= Enter + '        .tamanhotabela1 {'
	cHtml+= Enter + '            width: 100%;'
	cHtml+= Enter + '            border-spacing: 0;'
	cHtml+= Enter + '            margin-top: 50px;'
	cHtml+= Enter + '        }'
        
	cHtml+= Enter + '        .tamanhotabela2 {'
	cHtml+= Enter + '            width: 80%;'
	cHtml+= Enter + '            border-spacing: 0;'
	cHtml+= Enter + '            margin: 0 10% 20px 10%;'
	cHtml+= Enter + '        }'
        
	cHtml+= Enter + '        .ajustalogo {'
	cHtml+= Enter + '            margin: 0 auto;'
	cHtml+= Enter + '            justify-content: center;'
	cHtml+= Enter + '            display: flex;'
	cHtml+= Enter + '            padding: 25px;'
	cHtml+= Enter + '        }'
        
	cHtml+= Enter + '        .bordalogo {'
	cHtml+= Enter + '            border: 1px solid #8080805e;'
	cHtml+= Enter + '            padding: 7px;'
	cHtml+= Enter + '        }'
        
	cHtml+= Enter + '        .ajustacoluna {'
	cHtml+= Enter + '            margin: 0;'
	cHtml+= Enter + '            padding: 10px;'
	cHtml+= Enter + '            font-size: 14px;'
	cHtml+= Enter + '        }'

	cHtml+= Enter + '        .ajustatd {'
	cHtml+= Enter + '            border: 1px solid #8080805e;'
	cHtml+= Enter + '            padding: 10px;'
	cHtml+= Enter + '        }'
        
	cHtml+= Enter + '        .ajustaitem {'
	cHtml+= Enter + '            margin: 0;'
	cHtml+= Enter + '            padding: 10px;'
	cHtml+= Enter + '            font-size: 14px;'
	cHtml+= Enter + '        }'

	cHtml+= Enter + '        .aligncenter {'
	cHtml+= Enter + '            text-align: center;'
	cHtml+= Enter + '        }'
        
	cHtml+= Enter + '        .alignrigth {'
	cHtml+= Enter + '            text-align: right;'
	cHtml+= Enter + '        }'
        
	cHtml+= Enter + '        .alignleft {'
	cHtml+= Enter + '            text-align: left;'
	cHtml+= Enter + '        }'
        
	cHtml+= Enter + '        .titulo {'
	cHtml+= Enter + '            width: 80%;'
	cHtml+= Enter + '            display: inline-block;'
	cHtml+= Enter + '            top: 0;'
	cHtml+= Enter + '            text-align: left;'
	cHtml+= Enter + '            color: #0041bbe1;'
	cHtml+= Enter + '        }'
        
	cHtml+= Enter + '        .divlogo {'
	cHtml+= Enter + '            display: inline-block;'
	cHtml+= Enter + '            right: 0;'
	cHtml+= Enter + '            top: 0;'
	cHtml+= Enter + '            position: absolute;'
	cHtml+= Enter + '        }'
        
	cHtml+= Enter + '        .button {'
	cHtml+= Enter + '            font-size: 15px;'
	cHtml+= Enter + '            width: 100%;'
	cHtml+= Enter + '            margin-bottom: 5px;'
	cHtml+= Enter + '        }'
        
	cHtml+= Enter + '        span {'
	cHtml+= Enter + '            font-weight: 700;'
	cHtml+= Enter + '        }'
        
	cHtml+= Enter + '        .azul {'
	cHtml+= Enter + '            background-color: #0041bbe1;'
	cHtml+= Enter + '            color: white'
	cHtml+= Enter + '        }'
        
	cHtml+= Enter + '        .borda1 {'
	cHtml+= Enter + '            border: 1px solid white;'
	cHtml+= Enter + '        }'
        
	cHtml+= Enter + '        .borda2 {'
	cHtml+= Enter + '            border: 1px solid #8080805e;'
	cHtml+= Enter + '        }'
        
	cHtml+= Enter + '        .center {'
	cHtml+= Enter + '            text-align: center;'
	cHtml+= Enter + '        }'
        
	cHtml+= Enter + '        .textarea {'
	cHtml+= Enter + '            padding: 0.5%;'
	cHtml+= Enter + '        }'

	cHtml+= Enter + '    </style>'
	cHtml+= Enter + '    <script src="https://ajax.googleapis.com/ajax/libs/angularjs/1.4.5/angular.min.js"></script>'
	cHtml+= Enter + '</head>'

	cHtml+= Enter + '<body ng-app="rel" ng-controller="MainController as main">'
	cHtml+= Enter + '    <div class="bordalogo">'
	cHtml+= Enter + '        <div class="titulo">'
	cHtml+= Enter + '            <h1>Relacão de Pedido de Compra para Aprovação - Nivel 1</h1>'
	cHtml+= Enter + '        </div>'
	cHtml+= Enter + '        <div class="divlogo">'
	cHtml+= Enter + '            <img src="http://www.ourolux.com.br/Site/view/images/rodape/logo3.png" class="ajustalogo">'
	cHtml+= Enter + '        </div>'
	cHtml+= Enter + '    </div>'

	cHtml+= Enter + '    <table id="TOP" class="tamanhotabela1">'
	cHtml+= Enter + '        <thead>'
	cHtml+= Enter + '            <tr>'
	cHtml+= Enter + '                <th class="ajustacoluna aligncenter borda1 azul"></th>'
	cHtml+= Enter + '                <th class="ajustacoluna aligncenter borda1 azul">Filial</th>'
	cHtml+= Enter + '                <th class="ajustacoluna aligncenter borda1 azul">Emissão</th>'
	cHtml+= Enter + '                <th class="ajustacoluna aligncenter borda1 azul">Pedido</th>'
	cHtml+= Enter + '                <th class="ajustacoluna aligncenter borda1 azul">Condição</th>'
	cHtml+= Enter + '                <th class="ajustacoluna aligncenter borda1 azul">Fornecedor</th>'
	cHtml+= Enter + '                <th class="ajustacoluna aligncenter borda1 azul">Comprador</th>'
	cHtml+= Enter + '                <th class="ajustacoluna aligncenter borda1 azul">Líquido</th>'
	cHtml+= Enter + '                <th class="ajustacoluna aligncenter borda1 azul">Bruto</th>'
	cHtml+= Enter + '                <th class="ajustacoluna aligncenter borda1 azul">Ação</th>'
	cHtml+= Enter + '                <th class="ajustacoluna aligncenter borda1 azul">Status</th>'
	cHtml+= Enter + '            </tr>'
	cHtml+= Enter + '        </thead>'
     
    cHtml+= Enter + '        <tbody>'

	cQuery	:= " SELECT DISTINCT CR_FILIAL, CR_NUM "
	cQuery	+= Enter + "   FROM ( "
	cQuery	+= Enter + "		SELECT * FROM "+RetSqlName("SCR")+" SCR1 "
	cQuery	+= Enter + "		 WHERE SCR1.CR_FILIAL <> '99' "
	cQuery	+= Enter + "		   AND SCR1.CR_NIVEL = '01' "
	cQuery	+= Enter + "		   AND SCR1.CR_STATUS = '02' "
	cQuery	+= Enter + "		   AND SCR1.CR_EMISSAO > CONVERT( VARCHAR, (GETDATE()-"+cFS_DIAPRPC+") , 112 )
	cQuery	+= Enter + "		   AND SCR1.CR_NUM  IN (SELECT CR_NUM FROM "+RetSqlName("SCR")+" SCR2 "
	cQuery	+= Enter + "								 WHERE SCR2.CR_FILIAL = SCR1.CR_FILIAL "
	cQuery	+= Enter + "								   AND SCR2.CR_NIVEL = '02'  "
	cQuery	+= Enter + "								   AND SCR2.CR_STATUS = '01' " 
	cQuery	+= Enter + "								   AND SCR2.CR_EMISSAO > CONVERT( VARCHAR, (GETDATE()-"+cFS_DIAPRPC+") , 112 )
	cQuery	+= Enter + "								   AND SCR2.D_E_L_E_T_ <> '*') "
	cQuery	+= Enter + "		   AND SCR1.D_E_L_E_T_ <> '*' "
	cQuery	+= Enter + "		) TMP1 "
	cQuery	+= Enter + " WHERE "
	cQuery	+= Enter + "    TMP1.CR_NUM  NOT IN (SELECT CR_NUM FROM "+RetSqlName("SCR")+" SCR3 "
	cQuery	+= Enter + "						  WHERE SCR3.CR_FILIAL = TMP1.CR_FILIAL "
	cQuery	+= Enter + "						    AND SCR3.CR_NIVEL = '01' "
	cQuery	+= Enter + "						    AND SCR3.CR_STATUS <> '02' "
	cQuery	+= Enter + "						    AND SCR3.CR_EMISSAO > CONVERT( VARCHAR, (GETDATE()-"+cFS_DIAPRPC+") , 112 )
	cQuery	+= Enter + "						    AND SCR3.D_E_L_E_T_ <> '*') "   
	cQuery	+= Enter + " AND "	
	cQuery	+= Enter + "    TMP1.CR_NUM IN (SELECT C7_NUM FROM "+RetSqlName("SC7")+" "
	cQuery	+= Enter + "				     WHERE C7_FILIAL = TMP1.CR_FILIAL "
	cQuery	+= Enter + "				       AND C7_NUM = TMP1.CR_NUM "
	cQuery	+= Enter + "					   AND C7_QUANT-C7_QTDACLA-C7_QUJE > 0 "
	cQuery	+= Enter + "					   AND C7_RESIDUO = '' "
	cQuery	+= Enter + "					   AND D_E_L_E_T_ <> '*') "
	cQuery	+= Enter + " AND "
	cQuery	+= Enter + "  	TMP1.CR_USER = '"+(cAlias1)->CR_USER+"' " 
	cQuery	+= Enter + " ORDER BY CR_FILIAL, CR_NUM "

	cLogName := "WFAPPCN1_2"+STRZERO(DAY(dDATAbASE),2)+STRZERO(MONTH(DDATABASE),2)+STRZERO(YEAR(dDATAbASE),4)+".QRY"
	MemoWrite("\INTRJ\" + cLogName,cQuery)

	TcQuery cQuery New Alias (cAlias2)
	(cAlias2)->(dbGoTop())
	while !(cAlias2)->(EOF()) 
	
	    // --- INICIO TOTAL                         
		_nTotBRUTO	:= 0
		_nTotLIQ	:= 0
		cQuery	:= " SELECT SUM(C7_TOTAL - C7_VLDESC + C7_VALFRE + C7_VALIPI + C7_VALSOL) TOTBRUTO, SUM(C7_TOTAL) TOTLIQ FROM "+RetSqlName("SC7")+" "
		cQuery	+= Enter + "  WHERE C7_FILIAL = '"+(cAlias2)->CR_FILIAL+"' "
		cQuery	+= Enter + "    AND C7_NUM = '"+(cAlias2)->CR_NUM+"' "
		cQuery	+= Enter + "    AND C7_QUANT-C7_QTDACLA-C7_QUJE > 0 "
		cQuery	+= Enter + "    AND C7_RESIDUO = '' "
		cQuery	+= Enter + "    AND D_E_L_E_T_ <> '*' "             
		TcQuery cQuery New Alias (cAlias4)
		_nTotLIQ	:= (cAlias4)->TOTLIQ
		_nTotBRUTO	:= (cAlias4)->TOTBRUTO
		(cAlias4)->(DbCloseArea())                             
		// --- FIM TOTAL 
		
		cQuery	:= " SELECT * FROM "+RetSqlName("SC7")+" "
		cQuery	+= Enter + "  WHERE C7_FILIAL = '"+(cAlias2)->CR_FILIAL+"' "
		cQuery	+= Enter + "    AND C7_NUM = '"+(cAlias2)->CR_NUM+"' "
		cQuery	+= Enter + "    AND C7_QUANT-C7_QTDACLA-C7_QUJE > 0 "
		cQuery	+= Enter + "    AND C7_RESIDUO = '' "
		cQuery	+= Enter + "    AND D_E_L_E_T_ <> '*' "             
		TcQuery cQuery New Alias (cAlias3)
		(cAlias3)->(dbGoTop())

		cHtml+= Enter + '            <tr>'
		cHtml+= Enter + '                <td class="ajustatd aligncenter"><button ng-click="main.detalhesadd('+"'"+(cAlias3)->C7_NUM+"'"+')"> {{main.maisoumenos('+"'"+(cAlias3)->C7_NUM+"'"+',false)}} </button></td>'
		cHtml+= Enter + '                <td class="ajustatd aligncenter">'+(cAlias3)->C7_FILIAL+'</td>'
		cHtml+= Enter + '                <td class="ajustatd aligncenter">'+DTOC(STOD((cAlias3)->C7_EMISSAO))+'</td>'
		cHtml+= Enter + '                <td class="ajustatd aligncenter">'+(cAlias3)->C7_NUM+'</td>'
		cHtml+= Enter + '                <td class="ajustatd aligncenter">'+AllTrim(Posicione("SE4",1,xFilial("SE4")+(cAlias3)->C7_COND,"E4_DESCRI"))+'</td>'
		cHtml+= Enter + '                <td class="ajustatd alignleft">'+AllTrim(Posicione("SA2",1,xFilial("SA2")+(cAlias3)->C7_FORNECE+(cAlias3)->C7_LOJA,"A2_NOME"))+'</td>'
		cHtml+= Enter + '                <td class="ajustatd alignleft">'+upper(UsrFullName((cAlias3)->C7_USER))+'</td>'
		cHtml+= Enter + '                <td class="ajustatd alignrigth">'+AllTrim(Transform(_nTotLIQ ,"@E 999,999,999.99"))+'</td>'
		cHtml+= Enter + '                <td class="ajustatd alignrigth">'+AllTrim(Transform(_nTotBRUTO ,"@E 999,999,999.99"))+'</td>'
		cHtml+= Enter + '                <td class="ajustatd aligncenter">'

		cHtml+= Enter + '                    <div ng-show="main.resposta('+"'"+(cAlias3)->C7_NUM+"'"+')== '+"''"+' ||  main.show('+"'"+(cAlias3)->C7_NUM+"'"+') " >'
		cHtml+= Enter + '                        <button class="button" ng-click="main.zeramsg('+"'"+(cAlias3)->C7_FILIAL+"'"+','+"'"+(cAlias3)->C7_NUM+"'"+','+"'"+(cAlias1)->CR_USER+"'"+','+"'"+"SIM"+"','"+(cAlias3)->C7_NUM+"' )"+';main.aprova('+"'"+(cAlias3)->C7_FILIAL+"'"+','+"'"+(cAlias3)->C7_NUM+"'"+','+"'"+(cAlias1)->CR_USER+"'"+','+"'"+"SIM"+"','"+(cAlias3)->C7_NUM+"','01' )"+'">Aprovar</button>'
		cHtml+= Enter + '                        <button class="button" ng-click="main.aprova('+"'"+(cAlias3)->C7_FILIAL+"'"+','+"'"+(cAlias3)->C7_NUM+"'"+','+"'"+(cAlias1)->CR_USER+"'"+','+"'"+"NAO"+"','"+(cAlias3)->C7_NUM+"','01' )"+'">Bloquear</button>'
		cHtml+= Enter + '                    </div>' 
		cHtml+= Enter + '                </td>'
		cHtml+= Enter + '                <td ><label id="'+(cAlias3)->C7_NUM+'"></label></td>'
		cHtml+= Enter + '            </tr>'
		cHtml+= Enter + '            <tr>'
		cHtml+= Enter + '                <td colspan="2" class="ajustacoluna center azul">'
		cHtml+= Enter + '                    <Span>Motivo</Span>'
		cHtml+= Enter + '                </td>'
		cHtml+= Enter + '                <td colspan="09" class=" ajustacoluna center textarea azul">'
		cHtml+= Enter + '                    <textarea ng-model="main.md'+(cAlias3)->C7_NUM+'" style="width: 99.7%; border: 0;font-family: sans-serif; font-size: 15px;" rows="2"></textarea>'
		cHtml+= Enter + '                </td>'
		cHtml+= Enter + '            </tr>'
		cHtml+= Enter + '            <tr ng-show="main.detalhes == '+"'"+(cAlias3)->C7_NUM+"'"+'">'
		cHtml+= Enter + '                <td colspan="11">'
		cHtml+= Enter + '                    <table class="tamanhotabela2">'
		cHtml+= Enter + '                        <tbody>'
		cHtml+= Enter + '                            <tr>'
		cHtml+= Enter + '                                <th class="ajustaitem aligncenter borda1 azul"></th>'
		cHtml+= Enter + '                                <th class="ajustaitem aligncenter borda1 azul">Item</th>'
		cHtml+= Enter + '                                <th class="ajustaitem aligncenter borda1 azul">Entrega</th>'
		cHtml+= Enter + '                                <th class="ajustaitem aligncenter borda1 azul" colspan="4">Descrição</th>'
		cHtml+= Enter + '                                <th class="ajustaitem aligncenter borda1 azul">Qtde</th>'
		cHtml+= Enter + '                                <th class="ajustaitem aligncenter borda1 azul">Unitário</th>'
		cHtml+= Enter + '                                <th class="ajustaitem aligncenter borda1 azul">Total</th>'
		cHtml+= Enter + '                                <th class="ajustaitem aligncenter borda1 azul">Observação</th>'
		cHtml+= Enter + '                                <th class="ajustaitem aligncenter borda1 azul">Centro Custo</th>'
		cHtml+= Enter + '                            </tr>'

		while !(cAlias3)->(EOF())  

			CC_3Descr:= ""
			dbSelectArea("CTT")
			CTT->(dbSetOrder()) // CTT_FILIAL+CTT_CUSTO
			CTT->(dbGoTop())
			if CTT->(dbSeek(xFilial("CTT") + (cAlias3)->C7_CC ))
				CC_3Descr:= CTT->CTT_DESC01
			endif

			cHtml+= Enter + '                            <tr>'
			cHtml+= Enter + '                                <td class="aligncenter borda2"><button ng-click="main.detalhesadditem('+"'"+(cAlias3)->C7_NUM+(cAlias3)->C7_ITEM+"'"+')"> {{main.maisoumenos('+"'"+(cAlias3)->C7_NUM+(cAlias3)->C7_ITEM+"'"+',true)}} </button></td>'
			cHtml+= Enter + '                                <td class="aligncenter borda2">'+(cAlias3)->C7_ITEM+'</td>'
			cHtml+= Enter + '                                <td class="aligncenter borda2">'+DTOC(STOD((cAlias3)->C7_DATPRF))+'</td>'
			cHtml+= Enter + '                                <td class="alignleft   borda2" colspan="4">'+alltrim((cAlias3)->C7_PRODUTO)+'-'+alltrim((cAlias3)->C7_DESCRI)+'</td>'
			cHtml+= Enter + '                                <td class="alignrigth  borda2">'+AllTrim(Transform((cAlias3)->C7_QUANT-(cAlias3)->C7_QTDACLA-(cAlias3)->C7_QUJE,"@E 999,999,999.99"))+'</td>'
			cHtml+= Enter + '                                <td class="alignrigth  borda2">'+AllTrim(Transform((cAlias3)->C7_PRECO,"@E 999,999.999999"))+'</td>'
			cHtml+= Enter + '                                <td class="alignrigth  borda2">'+AllTrim(Transform(((cAlias3)->C7_QUANT-(cAlias3)->C7_QTDACLA-(cAlias3)->C7_QUJE)*(cAlias3)->C7_PRECO,"@E 999,999,999.99"))+'</td>'
			cHtml+= Enter + '                                <td class="alignleft   borda2">'+alltrim((cAlias3)->C7_OBS)+'</td>'
			cHtml+= Enter + '                                <td class="alignleft   borda2">'+alltrim(CC_3Descr)+'</td>'
			cHtml+= Enter + '                            </tr>

			cHtml+= Enter + '                            <tr ng-show="main.detalhesitem == '+"'"+(cAlias3)->C7_NUM+(cAlias3)->C7_ITEM+"'"+'">'
			cHtml+= Enter + '                                <th colspan="2"></td>'
			cHtml+= Enter + '                                <th class="ajustaitem aligncenter borda1 azul">Entrega</th>'
			cHtml+= Enter + '                                <th class="ajustaitem aligncenter borda1 azul">Emissão</th>'
			cHtml+= Enter + '                                <th class="ajustaitem aligncenter borda1 azul">Condição</th>'
			cHtml+= Enter + '                                <th class="ajustaitem aligncenter borda1 azul">Fornecedor</th>'
			cHtml+= Enter + '                                <th class="ajustaitem aligncenter borda1 azul">Pedido</th>'
			cHtml+= Enter + '                                <th class="ajustaitem aligncenter borda1 azul">Qtde</th>'
			cHtml+= Enter + '                                <th class="ajustaitem aligncenter borda1 azul">Unitário</th>'
			cHtml+= Enter + '                                <th class="ajustaitem aligncenter borda1 azul">Total</th>'
		    cHtml+= Enter + '                                <th class="ajustaitem aligncenter borda1 azul">Observação</th>'
		    cHtml+= Enter + '                                <th class="ajustaitem aligncenter borda1 azul">Centro Custo</th>'
			cHtml+= Enter + '                            </tr>'

			cQuery	:= " SELECT TOP "+cValToChar(nHist)+" * FROM "+RetSqlName("SC7")+" "
			cQuery	+= Enter + "  WHERE C7_FILIAL = '"+(cAlias3)->C7_FILIAL+"' "
			cQuery	+= Enter + "    AND C7_PRODUTO = '"+(cAlias3)->C7_PRODUTO+"' "
			cQuery	+= Enter + "    AND C7_NUM <> '"+(cAlias3)->C7_NUM+"'
			cQuery	+= Enter + "    AND D_E_L_E_T_ <> '*' "          
			cQuery	+= Enter + "    ORDER BY C7_EMISSAO DESC "          
			TcQuery cQuery New Alias (cAlias5)
			(cAlias5)->(dbGoTop())
			while !(cAlias5)->(EOF())  

				CC_5Descr:= ""
				dbSelectArea("CTT")
				CTT->(dbSetOrder()) // CTT_FILIAL+CTT_CUSTO
				CTT->(dbGoTop())
				if CTT->(dbSeek(xFilial("CTT") + (cAlias5)->C7_CC ))
					CC_5Descr:= CTT->CTT_DESC01
				endif

				cHtml+= Enter + '                            <tr ng-show="main.detalhesitem == '+"'"+(cAlias3)->C7_NUM+(cAlias3)->C7_ITEM+"'"+'">'
				cHtml+= Enter + '                                <td colspan="2"></td>'
				cHtml+= Enter + '                                <td class="aligncenter borda2">'+DTOC(STOD((cAlias5)->C7_DATPRF))+'</td>'
				cHtml+= Enter + '                                <td class="aligncenter borda2">'+DTOC(STOD((cAlias5)->C7_EMISSAO))+'</td>'
				cHtml+= Enter + '                                <td class="aligncenter borda2">'+AllTrim(Posicione("SE4",1,xFilial("SE4")+(cAlias5)->C7_COND,"E4_DESCRI"))+'</td>'
				cHtml+= Enter + '                                <td class="alignleft   borda2">'+AllTrim(Posicione("SA2",1,xFilial("SA2")+(cAlias5)->C7_FORNECE+(cAlias5)->C7_LOJA,"A2_NOME"))+'</td>'
				cHtml+= Enter + '                                <td class="aligncenter borda2">'+(cAlias5)->C7_NUM+'</td>'
				cHtml+= Enter + '                                <td class="alignrigth  borda2">'+AllTrim(Transform((cAlias5)->C7_QUANT,"@E 999,999,999.99"))+'</td>'
				cHtml+= Enter + '                                <td class="alignrigth  borda2">'+AllTrim(Transform((cAlias5)->C7_PRECO,"@E 999,999.999999"))+'</td>'
				cHtml+= Enter + '                                <td class="alignrigth  borda2">'+AllTrim(Transform((cAlias5)->C7_QUANT*(cAlias5)->C7_PRECO,"@E 999,999,999.99"))+'</td>'
  			    cHtml+= Enter + '                                <td class="alignleft   borda2">'+alltrim((cAlias5)->C7_OBS)+'</td>'
			    cHtml+= Enter + '                                <td class="alignleft   borda2">'+alltrim(CC_5Descr)+'</td>'
				cHtml+= Enter + '                            </tr>

				(cAlias5)->(DbSkip())
			Enddo
			(cAlias5)->(DbCloseArea())                             

			(cAlias3)->(DbSkip())
		Enddo
		(cAlias3)->(DbCloseArea())                             

		cHtml+= Enter + '                 	  </tbody>'
		cHtml+= Enter + '              	  </table>'
		cHtml+= Enter + '             </td>'
		cHtml+= Enter + '         </tr>'

		(cAlias2)->(DbSkip())
	Enddo       
	(cAlias2)->(DbCloseArea())          

	cHtml+= Enter + '        </tbody>'
	cHtml+= Enter + '    </table>'
	cHtml+= Enter + '</body>'
	cHtml+= Enter + '<script>'
	cHtml+= Enter + '    var login = angular.module('+"'"+'rel'+"'"+', [])'
	cHtml+= Enter + '    angular.module('+"'"+'rel'+"'"+').controller("MainController", function($http, $filter) {'
	cHtml+= Enter + '        var vm = this;'
	cHtml+= Enter + '        vm.arraypedidos = [];'
	cHtml+= Enter + '        vm.arraypedidosrec = [];'
	cHtml+= Enter + '        vm.detalhes = '+"''"+';'
	cHtml+= Enter + '        vm.resposta = function(par) {'
	cHtml+= Enter + '            var ret = '+"''"+';'
	cHtml+= Enter + '            for (var i = 0; i < vm.arraypedidos.length; i++) {'
	cHtml+= Enter + '                vm.arraypedidos[i]'
	cHtml+= Enter + '                if (vm.arraypedidos[i].pedido == par) {'
	cHtml+= Enter + '                    ret = vm.arraypedidos[i].msg;'
	cHtml+= Enter + '                    break'
	cHtml+= Enter + '                }'
	cHtml+= Enter + '            }'
	cHtml+= Enter + '            return ret;'
	cHtml+= Enter + '        };'

	cHtml+= Enter + '        vm.show = function(par) {'
	cHtml+= Enter + '            var ret = false ;'
	cHtml+= Enter + '            for (var i = 0; i < vm.arraypedidos.length; i++) {'
	cHtml+= Enter + '                vm.arraypedidos[i]'
	cHtml+= Enter + '                if (vm.arraypedidos[i].pedido == par) {'
	cHtml+= Enter + '                    ret = document.getElementById(par).innerHTML;'
	cHtml+= Enter + '            		 ret = ret.match(/aguarde/) != null
	cHtml+= Enter + '                    break'
	cHtml+= Enter + '                }'
	cHtml+= Enter + '            }'
	
	cHtml+= Enter + '            return ret;'
	cHtml+= Enter + '        };'

	cHtml+= Enter + '        vm.zeramsg = function(par1, pedido, par3, resposta, indice) {'
	cHtml+= Enter + '					 document.getElementById(indice).innerHTML = "";
	cHtml+= Enter + '        }'

	cHtml+= Enter + '        vm.aprova = function(par1, pedido, par3, resposta, indice, nivel) {'
	cHtml+= Enter + '            var motivo = eval("vm.md" + pedido)'
	cHtml+= Enter + '            console.log(motivo)'
	cHtml+= Enter + '            if ((motivo == "" || motivo == undefined) && resposta == "NAO") {'
	cHtml+= Enter + '                alert("motivo nao informado !")'
	cHtml+= Enter + '                return'
	cHtml+= Enter + '            }'

	cHtml+= Enter + '            $http.get('+"'"+_cHostREST+'WSAPRPC/'+"'+resposta+'/'+par1+'/'+pedido+'/'+par3+'/'+motivo+'/'+nivel)."

	cHtml+= Enter + '            success(function(data) {'
	cHtml+= Enter + '                if (data.status == '+"'"+'ok'+"'"+') {'
	cHtml+= Enter + '                    vm.arraypedidos.push(data);'
	cHtml+= Enter + '					 document.getElementById(indice).innerHTML = data.msg;
	cHtml+= Enter + '                }'
	cHtml+= Enter + '            }).'
	cHtml+= Enter + '            error(function(data) {'
	cHtml+= Enter + '                console.log('+"'"+'Tratar Error'+"'"+');'
	cHtml+= Enter + '            });'
	cHtml+= Enter + '        }'
	cHtml+= Enter + '        vm.detalhesadd = function(par) {'
	cHtml+= Enter + '            if (vm.detalhes !== par) {'
	cHtml+= Enter + '                vm.detalhes = par'
	cHtml+= Enter + '            } else {'
	cHtml+= Enter + '                vm.detalhes = '+"''"+';'
	cHtml+= Enter + '            }'
	cHtml+= Enter + '        }'
	cHtml+= Enter + '        vm.detalhesadditem = function(par) {'
	cHtml+= Enter + '            if (vm.detalhesitem !== par) {'
	cHtml+= Enter + '                vm.detalhesitem = par'
	cHtml+= Enter + '            } else {'
	cHtml+= Enter + '                vm.detalhesitem = '+"''"+';'
	cHtml+= Enter + '            }'
	cHtml+= Enter + '        }'

	cHtml+= Enter + '       vm.maisoumenos = function(numero, item) {'
	cHtml+= Enter + '             var ret = "+"'
	cHtml+= Enter + '             if (vm.detalhesitem == numero && item) {'
	cHtml+= Enter + '                 ret = "-"'
	cHtml+= Enter + '             }'
	cHtml+= Enter + '             if (vm.detalhes == numero && !item) {'
	cHtml+= Enter + '                 ret = "-"'
	cHtml+= Enter + '             }'
	cHtml+= Enter + '             return ret'
	cHtml+= Enter + '         }'

	cHtml+= Enter + '    })'
	cHtml+= Enter + '</script>'
	cHtml+= Enter + '</html>'

    //conout(cHtml)     

	cData := dtoc(ddatabase)                          
	cHora := TIME()
    
	xData := SUBSTR(dtoc(ddatabase),1,2)+SUBSTR(dtoc(ddatabase),4,2)+SUBSTR(dtoc(ddatabase),7,4)
	xHora := SUBSTR(TIME(),1,2)+SUBSTR(TIME(),4,2)+SUBSTR(TIME(),7,2)

   	cAnexo1:= "\web\messenger\emp01\wfaprov\"+"aprovpc"+xData+xHora+".html"
   	cAnexo2:= "aprovpc"+xData+xHora+".html"

	nHandle := FCREATE(cAnexo1)
    if nHandle = -1
  	    conout("Erro ao criar Arquivo - ferror " + Str(Ferror()))
    else
   	    conout("criado arquivo na pasta: " + cAnexo1 )

        FWrite(nHandle, cHtml)
        FClose(nHandle)
    endif 	  

	lSmtpSSL  := GetMV("MV_RELSSL")
	lSmtpTLS  := GetMV("MV_RELTLS")
	lAuteSMTP := GetNewPar("MV_RELAUTH",.F.)
	cServSMTP := GetMV("MV_RELSERV")
	cUserSMTP := GetMV("MV_RELACNT")
	cPassSMTP := GetMV("MV_RELPSW")
	cUserFrom := GetMV("MV_RELFROM")                     
                                                                                                                                
    cAssunto := "Aprovação Pedido de Compra"
     
	lResult := .f. 
	
	if lSmtpSSL .AND. lSmtpTLS
  		CONNECT SMTP SERVER cServSMTP ACCOUNT cUserSMTP PASSWORD cPassSMTP RESULT lResult SSL TLS
  	endif
  		
	if lSmtpSSL .AND. !lSmtpTLS
  		CONNECT SMTP SERVER cServSMTP ACCOUNT cUserSMTP PASSWORD cPassSMTP RESULT lResult SSL 
  	endif                                                                                     

	if !lSmtpSSL .AND. lSmtpTLS
  		CONNECT SMTP SERVER cServSMTP ACCOUNT cUserSMTP PASSWORD cPassSMTP RESULT lResult TLS
  	endif                                                                                     
                                     
	If lResult .And. lAuteSMTP
	    lResult := MailAuth( cUserSMTP, cPassSMTP )
	    If !lResult
	        lResult := QADGetMail() // funcao que abre uma janela perguntando o usuario e senha para fazer autenticacao
	    EndIf
	EndIf
	
	If !lResult
	    GET MAIL ERROR cError
	   	    conout('Erro de Autenticacao no Envio de e-mail antes do envio: '+cError)
	    Return
	EndIf                                  
	                                   
	PswOrder(1)
	PswSeek((cAlias1)->CR_USER,.T.)
	aUsuario := PswRet(1)

    cNome := UPPER(AllTrim(aUsuario[1,4]))
    cEmail := LOWER(AllTrim(aUsuario[1,14]))
    
    cPara:= cEmail
	conout("Nome Aprovador: " + cNome)
	conout("eMail Aprovador: " + cEmail)
    
    cMensagem := ' <p align="center"><font face="arial" color="#0000FF" size="4"><b>Mensagem Eletronica - WorkFlow</b></font></p> '
	cMensagem += ' <p align="left">Prezado, <strong>'+cNome+'</strong></p> '
	cMensagem += ' <p align="left">Segue link abaixo da relação de Pedidos de Compra para Aprovação - Nivel 1</p> '
	cMensagem += ' <p align="left">Data do Envio: <strong>' + cData + '.</strong></p> '
	cMensagem += ' <p align="left">Hora: <strong>' + cHora + '.</strong></p> ' 
	cMensagem += ' <p align="left">Salvo em: <strong>' + cAnexo1 + '.</strong></p> '         

    cMensagem += ' <p align="left">Para abrir a relação de Pedidos de Compra, <a href="'+_cHostWF+cAnexo2+'"> Click AQUI </a></p>'
    cMensagem += ' </body> '

	//cPara := "cpd2@ourolux.com.br"
	
	SEND MAIL FROM cUserFrom TO cPara CC "" SUBJECT cAssunto BODY cMensagem RESULT lResult  // ATTACHMENT cAnexo1 

	If !lResult
	    GET MAIL ERROR cError
   	    conout('Erro de Envio de e-mail: '+cError)
	else
	
		conout('eMail enviado!')
	
	EndIf

	DISCONNECT SMTP SERVER
		
	(cAlias1)->(DbSkip())
Enddo       
(cAlias1)->(DbCloseArea())                             
         

if lSched
	RESET ENVIRONMENT
endif                 

conout(" ")
conout("Finalizado processo WFAPPCN1 " + DtoC(Date()) + " - " + Time())
conout(" ")   

RestArea(aArea)

Return()
