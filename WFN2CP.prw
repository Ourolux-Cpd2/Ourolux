#INCLUDE "RWMAKE.CH"
#Include "AP5MAIL.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "Tbiconn.ch"
#INCLUDE "Tbicode.ch"

#DEFINE COMP_DATE  "20200206" 
/*/
___________________________________________________________________________
|  Programa:            | Autor: Rodrigo Dias Nunes  | Data ³  05/11/18     |
|_______________________|____________________________|______________________|
|  Descricao | schedule para envio de email dos titulos a pagar nivel 2     |
|____________|_____________________________________________________________ |
|  Uso       | OUROLUX.                                                     |
|____________|_____________________________________________________________ |
/*/
                                  
User Function WFN2CP()   

Local Enter                		
Local aArea    
Local cAlias1  
Local cAlias2  
Local cAlias3  
Local cAlias4                       
Local _cHostWF   
Local _cHostREST 
local cFS_DIAPRPC
//Local cStartPath.
Local cLogName 
Local nlx := 0
Local aAprova := {}
Local bloco1 := ""
Local bloco2 := ""
Local bloco3 := ""
local cChamada := ""
Local cHtml := ""

conout(" ")
conout("Iniciado processo WFN2CP " + DtoC(Date()) + " - " + Time())
conout(" ")   

PREPARE ENVIRONMENT EMPRESA "01" FILIAL "01" MODULO "COM"
   
Enter    := CHR(13)+CHR(10)  
aArea    := GetArea()

cAlias1  := GetNextAlias()
cAlias2  := GetNextAlias()
cAlias3  := GetNextAlias()
cAlias4  := GetNextAlias()

_cHostWF   := SUPERGETMV("FS_WFURL01", .F.,"http://187.94.63.180:10615/wf/")	//URL configurado no ini para WF Link.
_cHostREST := SUPERGETMV("FS_REURL01", .F.,"http://187.94.63.180:10551/rest/") //URL configurado no ini para REST Link
cFS_DIAPRPC:= SUPERGETMV('FS_DIAPRPC',.T.,"60") 

cLogName   := "WFN2CP"+STRZERO(DAY(dDATAbASE),2)+STRZERO(MONTH(DDATABASE),2)+STRZERO(YEAR(dDATAbASE),4)+".QRY"

cQuery := " SELECT DISTINCT(ZX_USUARIO) FROM " + RetSqlName("SZX")
cQuery += " WHERE D_E_L_E_T_ <> '*' "
cQuery += " AND ZX_STATUS = 'P' "

MemoWrite("\INTRJ\" + cLOGNAME,cQuery)

If Select("N2A") > 0
	N2A->(dbCloseArea())
EndIf

TcQuery cQuery New Alias "N2A"
	
While N2A->(!Eof())
	bloco1:= ' <!DOCTYPE html> <html>'
	bloco1+= Enter +' <head>'
	bloco1+= Enter +'     <title>Relacao Titulos a Pagar</title>'
	bloco1+= Enter +'     <style type="text/css">'
	bloco1+= Enter +'     .separador {'
	bloco1+= Enter +'         width: 100%;'
	bloco1+= Enter +'         height: 12px;'
	bloco1+= Enter +'         background-color: #f36e2661;'
	bloco1+= Enter +'     }'
	bloco1+= Enter +'     body {'
	bloco1+= Enter +'         font-family: sans-serif;'
	bloco1+= Enter +'     }'
	bloco1+= Enter +'     .tamanhotabela {'
	bloco1+= Enter +'         width: 100%;'
	bloco1+= Enter +'         border-spacing: 0;'
	bloco1+= Enter +'         margin-top: 50px;'
	bloco1+= Enter +'     }'
	bloco1+= Enter +'     .tamanhotabela2 {'
	bloco1+= Enter +'         width: 80%;'
	bloco1+= Enter +'         border-spacing: 0;'
	bloco1+= Enter +'         margin: 0 10% 20px 10%;'
	bloco1+= Enter +'     }'
	bloco1+= Enter +'     .ajustalogo {'
	bloco1+= Enter +'         margin: 0 auto;'
	bloco1+= Enter +'         justify-content: center;'
	bloco1+= Enter +'         display: flex;'
	bloco1+= Enter +'         padding: 25px;'
	bloco1+= Enter +'     }'
	bloco1+= Enter +'     .bordalogo {'
	bloco1+= Enter +'         border: 1px solid #8080805e;'
	bloco1+= Enter +'         padding: 7px;'
	bloco1+= Enter +'     }'
	bloco1+= Enter +'     .ajustacoluna1 {'
	bloco1+= Enter +'         width: 1%;'
	bloco1+= Enter +'         border: 1px solid #8080805e;'
	bloco1+= Enter +'         margin: 0;'
	bloco1+= Enter +'         padding: 10px;'
	bloco1+= Enter +'         font-size: 1px;'
	bloco1+= Enter +'         background-color: #aba4a5;'
	bloco1+= Enter +'         color: #ecaaaa;'
	bloco1+= Enter +'         text-align: center;'
	bloco1+= Enter +'     }'
	bloco1+= Enter +'     .ajustacoluna2 {'
	bloco1+= Enter +'         width: 10%;'
	bloco1+= Enter +'         border: 1px solid #8080805e;'
	bloco1+= Enter +'         margin: 0;'
	bloco1+= Enter +'         padding: 10px;'
	bloco1+= Enter +'         font-size: 14px;'
	bloco1+= Enter +'         background-color: #4b01ff;'
	bloco1+= Enter +'         color: white;'
	bloco1+= Enter +'         text-align: center;'
	bloco1+= Enter +'     }'
	bloco1+= Enter +'     .ajustacoluna3 {'
	bloco1+= Enter +'         width: 5%;'
	bloco1+= Enter +'         border: 1px solid #8080805e;'
	bloco1+= Enter +'         margin: 0;'
	bloco1+= Enter +'         padding: 10px;'
	bloco1+= Enter +'         font-size: 14px;'
	bloco1+= Enter +'         background-color: #4b01ff;'
	bloco1+= Enter +'         color: white;'
	bloco1+= Enter +'         text-align: center;'
	bloco1+= Enter +'     }'
	bloco1+= Enter +'     .ajustacoluna4 {'
	bloco1+= Enter +'         width: 5%;'
	bloco1+= Enter +'         border: 1px solid #8080805e;'
	bloco1+= Enter +'         margin: 0;'
	bloco1+= Enter +'         padding: 10px;'
	bloco1+= Enter +'         font-size: 14px;'
	bloco1+= Enter +'         background-color: #4b01ff;'
	bloco1+= Enter +'         color: white;'
	bloco1+= Enter +'         text-align: center;'
	bloco1+= Enter +'     }'
	bloco1+= Enter +'     .ajustacoluna5 {'
	bloco1+= Enter +'         width: 20%;'
	bloco1+= Enter +'         border: 1px solid #8080805e;'
	bloco1+= Enter +'         margin: 0;'
	bloco1+= Enter +'         padding: 10px;'
	bloco1+= Enter +'         font-size: 14px;'
	bloco1+= Enter +'         background-color: #4b01ff;'
	bloco1+= Enter +'         color: white;'
	bloco1+= Enter +'         text-align: center;'
	bloco1+= Enter +'     }'
	bloco1+= Enter +'     .ajustacoluna6 {'
	bloco1+= Enter +'         width: 20%;'
	bloco1+= Enter +'         border: 1px solid #8080805e;'
	bloco1+= Enter +'         margin: 0;'
	bloco1+= Enter +'         padding: 10px;'
	bloco1+= Enter +'         font-size: 14px;'
	bloco1+= Enter +'         background-color: #4b01ff;'
	bloco1+= Enter +'         color: white;'
	bloco1+= Enter +'         text-align: center;'
	bloco1+= Enter +'     }'
	bloco1+= Enter +'     .ajustacoluna7 {'
	bloco1+= Enter +'         width: 10%;'
	bloco1+= Enter +'         border: 1px solid #8080805e;'
	bloco1+= Enter +'         margin: 0;'
	bloco1+= Enter +'         padding: 10px;'
	bloco1+= Enter +'         font-size: 14px;'
	bloco1+= Enter +'         background-color: #4b01ff;'
	bloco1+= Enter +'         color: white;'
	bloco1+= Enter +'         text-align: center;'
	bloco1+= Enter +'     }'
	bloco1+= Enter +'     .ajustacoluna8 {'
	bloco1+= Enter +'         width: 5%;'
	bloco1+= Enter +'         border: 1px solid #8080805e;'
	bloco1+= Enter +'         margin: 0;'
	bloco1+= Enter +'         padding: 10px;'
	bloco1+= Enter +'         font-size: 14px;'
	bloco1+= Enter +'         background-color: #4b01ff;'
	bloco1+= Enter +'         color: white;'
	bloco1+= Enter +'         text-align: center;'
	bloco1+= Enter +'     }'
	bloco1+= Enter +'     .ajustacoluna9 {'
	bloco1+= Enter +'         width: 10%;'
	bloco1+= Enter +'         border: 1px solid #8080805e;'
	bloco1+= Enter +'         margin: 0;'
	bloco1+= Enter +'         padding: 10px;'
	bloco1+= Enter +'         font-size: 14px;'
	bloco1+= Enter +'         background-color: #4b01ff;'
	bloco1+= Enter +'         color: white;'
	bloco1+= Enter +'         text-align: center;'
	bloco1+= Enter +'     }'
	bloco1+= Enter +'	 .ajustacoluna10 {'
	bloco1+= Enter +'         width: 5%;'
	bloco1+= Enter +'         border: 1px solid #8080805e;'
	bloco1+= Enter +'         margin: 0;'
	bloco1+= Enter +'         padding: 10px;'
	bloco1+= Enter +'         font-size: 14px;'
	bloco1+= Enter +'         background-color: #4b01ff;'
	bloco1+= Enter +'         color: white;'
	bloco1+= Enter +'         text-align: center;'
	bloco1+= Enter +'     }'
	bloco1+= Enter +'	 .ajustacoluna11 {'
	bloco1+= Enter +'         width: 10%;'
	bloco1+= Enter +'         border: 1px solid #8080805e;'
	bloco1+= Enter +'         margin: 0;'
	bloco1+= Enter +'         padding: 10px;'
	bloco1+= Enter +'         font-size: 14px;'
	bloco1+= Enter +'         background-color: #4b01ff;'
	bloco1+= Enter +'         color: white;'
	bloco1+= Enter +'         text-align: center;'
	bloco1+= Enter +'     }'
	bloco1+= Enter +'     .titulo {'
	bloco1+= Enter +'         width: 80%;'
	bloco1+= Enter +'         display: inline-block;'
	bloco1+= Enter +'         top: 0;'
	bloco1+= Enter +'         text-align: left;'
	bloco1+= Enter +'         color: #4b01ff;'
	bloco1+= Enter +'     }'
	bloco1+= Enter +'     .divlogo {'
	bloco1+= Enter +'         display: inline-block;'
	bloco1+= Enter +'         right: 0;'
	bloco1+= Enter +'         top: 0;'
	bloco1+= Enter +'         position: absolute;'
	bloco1+= Enter +'     }'
	bloco1+= Enter +'     .button{'
	bloco1+= Enter +'            font-size: 15px;'
	bloco1+= Enter +'     width: 100%;'
	bloco1+= Enter +'     margin-bottom: 5px;'
	bloco1+= Enter +'     }'
	bloco1+= Enter +'     span {'
	bloco1+= Enter +'         font-weight: 700;'
	bloco1+= Enter +'     }'
	bloco1+= Enter +'     .ajustatd1 {'
	bloco1+= Enter +'         border: 1px solid #8080805e;'
	bloco1+= Enter +'         padding: 10px;'
	bloco1+= Enter +'         text-align: center;'
	bloco1+= Enter +'     }'
	bloco1+= Enter +'     .ajustatd2 {'
	bloco1+= Enter +'         border: 1px solid #8080805e;'
	bloco1+= Enter +'         padding: 10px;'
	bloco1+= Enter +'         text-align: center;'
	bloco1+= Enter +'     }'
	bloco1+= Enter +'     .ajustatd3 {'
	bloco1+= Enter +'         border: 1px solid #8080805e;'
	bloco1+= Enter +'         padding: 10px;'
	bloco1+= Enter +'         text-align: center;'
	bloco1+= Enter +'     }'
	bloco1+= Enter +'     .ajustatd4 {'
	bloco1+= Enter +'         border: 1px solid #8080805e;'
	bloco1+= Enter +'         padding: 10px;'
	bloco1+= Enter +'         text-align: center;'
	bloco1+= Enter +'     }'
	bloco1+= Enter +'     .ajustatd5 {'
	bloco1+= Enter +'         border: 1px solid #8080805e;'
	bloco1+= Enter +'         padding: 10px;'
	bloco1+= Enter +'         text-align: center;'
	bloco1+= Enter +'     }'
	bloco1+= Enter +'     .ajustatd6 {'
	bloco1+= Enter +'         border: 1px solid #8080805e;'
	bloco1+= Enter +'         padding: 10px;'
	bloco1+= Enter +'         text-align: center;'
	bloco1+= Enter +'     }'
	bloco1+= Enter +'     .ajustatd7 {'
	bloco1+= Enter +'         border: 1px solid #8080805e;'
	bloco1+= Enter +'         padding: 10px;'
	bloco1+= Enter +'         text-align: center;'
	bloco1+= Enter +'     }'
	bloco1+= Enter +'     .ajustatd8 {'
	bloco1+= Enter +'         border: 1px solid #8080805e;'
	bloco1+= Enter +'         padding: 10px;'
	bloco1+= Enter +'         text-align: center;'
	bloco1+= Enter +'     }'
	bloco1+= Enter +'     .ajustatd9 {'
	bloco1+= Enter +'         border: 1px solid #8080805e;'
	bloco1+= Enter +'         padding: 10px;'
	bloco1+= Enter +'         text-align: center;'
	bloco1+= Enter +'     }'
	bloco1+= Enter +'	 .ajustatd10 {'
	bloco1+= Enter +'         border: 1px solid #8080805e;'
	bloco1+= Enter +'         padding: 10px;'
	bloco1+= Enter +'         text-align: center;'
	bloco1+= Enter +'     }'
	bloco1+= Enter +'	 .ajustatd11 {'
	bloco1+= Enter +'         border: 1px solid #8080805e;'
	bloco1+= Enter +'         padding: 10px;'
	bloco1+= Enter +'         text-align: center;'
	bloco1+= Enter +'     }'
	bloco1+= Enter +'     .ajustaitem1 {'
	bloco1+= Enter +'         width: 12%;'
	bloco1+= Enter +'         border: 1px solid #8080805e;'
	bloco1+= Enter +'         margin: 0;'
	bloco1+= Enter +'         padding: 10px;'
	bloco1+= Enter +'         font-size: 14px;'
	bloco1+= Enter +'         background-color: #aba4a5;'
	bloco1+= Enter +'         color: white;'
	bloco1+= Enter +'         text-align: center;'
	bloco1+= Enter +'     }'
	bloco1+= Enter +'     .ajustaitem2 {'
	bloco1+= Enter +'         width: 12%;'
	bloco1+= Enter +'         border: 1px solid #8080805e;'
	bloco1+= Enter +'         margin: 0;'
	bloco1+= Enter +'         padding: 10px;'
	bloco1+= Enter +'         font-size: 14px;'
	bloco1+= Enter +'         background-color: #aba4a5;'
	bloco1+= Enter +'         color: white;'
	bloco1+= Enter +'         text-align: center;'
	bloco1+= Enter +'     }'
	bloco1+= Enter +'     .ajustaitem3 {'
	bloco1+= Enter +'         width: 12%;'
	bloco1+= Enter +'         border: 1px solid #8080805e;'
	bloco1+= Enter +'         margin: 0;'
	bloco1+= Enter +'         padding: 10px;'
	bloco1+= Enter +'         font-size: 14px;'
	bloco1+= Enter +'         background-color: #aba4a5;'
	bloco1+= Enter +'         color: white;'
	bloco1+= Enter +'         text-align: center;'
	bloco1+= Enter +'     }'
	bloco1+= Enter +'     .ajustaitem4 {'
	bloco1+= Enter +'         width: 12%;'
	bloco1+= Enter +'         border: 1px solid #8080805e;'
	bloco1+= Enter +'         margin: 0;'
	bloco1+= Enter +'         padding: 10px;'
	bloco1+= Enter +'         font-size: 14px;'
	bloco1+= Enter +'         background-color: #aba4a5;'
	bloco1+= Enter +'         color: white;'
	bloco1+= Enter +'         text-align: center;'
	bloco1+= Enter +'     }'
	bloco1+= Enter +'     .ajustaitem5 {'
	bloco1+= Enter +'         width: 12%;'
	bloco1+= Enter +'         border: 1px solid #8080805e;'
	bloco1+= Enter +'         margin: 0;'
	bloco1+= Enter +'         padding: 10px;'
	bloco1+= Enter +'         font-size: 14px;'
	bloco1+= Enter +'         background-color: #aba4a5;'
	bloco1+= Enter +'         color: white;'
	bloco1+= Enter +'         text-align: center;'
	bloco1+= Enter +'     }'
	bloco1+= Enter +'	 .ajustaitem6 {'
	bloco1+= Enter +'         width: 12%;'
	bloco1+= Enter +'         border: 1px solid #8080805e;'
	bloco1+= Enter +'         margin: 0;'
	bloco1+= Enter +'         padding: 10px;'
	bloco1+= Enter +'         font-size: 14px;'
	bloco1+= Enter +'         background-color: #aba4a5;'
	bloco1+= Enter +'         color: white;'
	bloco1+= Enter +'         text-align: center;'
	bloco1+= Enter +'     }'
	bloco1+= Enter +'	 .ajustaitem7 {'
	bloco1+= Enter +'         width: 12%;'
	bloco1+= Enter +'         border: 1px solid #8080805e;'
	bloco1+= Enter +'         margin: 0;'
	bloco1+= Enter +'         padding: 10px;'
	bloco1+= Enter +'         font-size: 14px;'
	bloco1+= Enter +'         background-color: #aba4a5;'
	bloco1+= Enter +'         color: white;'
	bloco1+= Enter +'         text-align: center;'
	bloco1+= Enter +'     }'
	bloco1+= Enter +'	 .ajustaitem8 {'
	bloco1+= Enter +'         width: 12%;'
	bloco1+= Enter +'         border: 1px solid #8080805e;'
	bloco1+= Enter +'         margin: 0;'
	bloco1+= Enter +'         padding: 10px;'
	bloco1+= Enter +'         font-size: 14px;'
	bloco1+= Enter +'         background-color: #aba4a5;'
	bloco1+= Enter +'         color: white;'
	bloco1+= Enter +'         text-align: center;'
	bloco1+= Enter +'     }'
	bloco1+= Enter +'     .ajustait1 {'
	bloco1+= Enter +'         border: 1px solid #8080805e;'
	bloco1+= Enter +'         padding: 10px;'
	bloco1+= Enter +'         text-align: center;'
	bloco1+= Enter +'     }'
	bloco1+= Enter +'     .ajustait2 {'
	bloco1+= Enter +'         border: 1px solid #8080805e;'
	bloco1+= Enter +'         padding: 10px;'
	bloco1+= Enter +'         text-align: center;'
	bloco1+= Enter +'     }'
	bloco1+= Enter +'     .ajustait3 {'
	bloco1+= Enter +'         border: 1px solid #8080805e;'
	bloco1+= Enter +'         padding: 10px;'
	bloco1+= Enter +'         text-align: center;'
	bloco1+= Enter +'     }'
	bloco1+= Enter +'     .ajustait4 {'
	bloco1+= Enter +'         border: 1px solid #8080805e;'
	bloco1+= Enter +'         padding: 10px;'
	bloco1+= Enter +'         text-align: center;'
	bloco1+= Enter +'     }'
	bloco1+= Enter +'     .ajustait5 {'
	bloco1+= Enter +'         border: 1px solid #8080805e;'
	bloco1+= Enter +'         padding: 10px;'
	bloco1+= Enter +'         text-align: center;'
	bloco1+= Enter +'     }'
	bloco1+= Enter +'	 .ajustait6 {'
	bloco1+= Enter +'         border: 1px solid #8080805e;'
	bloco1+= Enter +'         padding: 10px;'
	bloco1+= Enter +'         text-align: center;'
	bloco1+= Enter +'     }'
	bloco1+= Enter +'	 .ajustait7 {'
	bloco1+= Enter +'         border: 1px solid #8080805e;'
	bloco1+= Enter +'         padding: 10px;'
	bloco1+= Enter +'         text-align: center;'
	bloco1+= Enter +'     }'
	bloco1+= Enter +'	 .ajustait8	{'
	bloco1+= Enter +'         border: 1px solid #8080805e;'
	bloco1+= Enter +'         padding: 10px;'
	bloco1+= Enter +'         text-align: center;'
	bloco1+= Enter +'     }'
	bloco1+= Enter +'     </style>'
	bloco1+= Enter +'     <script src="https://ajax.googleapis.com/ajax/libs/angularjs/1.4.5/angular.min.js"></script>'
	bloco1+= Enter +' </head>'
	bloco1+= Enter +' <body ng-app="rel" ng-controller="MainController as main">'
	bloco1+= Enter +'     <div class="bordalogo">'
	bloco1+= Enter +'         <div class="titulo">'
	bloco1+= Enter +'             <h1>Relacao de Titulos a Pagar para Aprovacao</h1>'
	bloco1+= Enter +'         </div>'
	bloco1+= Enter +'         <div class="divlogo">'
	bloco1+= Enter +'             <img src="http://www.ourolux.com.br/Site/view/images/rodape/logo3.png" class="ajustalogo">'
	bloco1+= Enter +'         </div>'
	bloco1+= Enter +'     </div>'
	bloco1+= Enter +'     <br>'
	
	bloco2+= Enter +'         <table id="TOP" class="tamanhotabela">'
	bloco2+= Enter +'             <thead>'
	bloco2+= Enter +'                 <tr>'
	bloco2+= Enter +'                    <th class="ajustacoluna1"></th>'
	bloco2+= Enter +'                     <th class="ajustacoluna2">Titulo</th>'
	bloco2+= Enter +'                     <th class="ajustacoluna3">Prefixo</th>'
	bloco2+= Enter +'                     <th class="ajustacoluna4">Parcela</th>'
	bloco2+= Enter +'                     <th class="ajustacoluna5">Fornecedor</th>'
	bloco2+= Enter +'                     <th class="ajustacoluna6">Historico</th>'
	bloco2+= Enter +'                     <th class="ajustacoluna7">Dt.Emissao</th>'
	bloco2+= Enter +'                     <th class="ajustacoluna8">Tipo</th>'
	bloco2+= Enter +'                     <th class="ajustacoluna9">Valor</th>'
	bloco2+= Enter +'                     <th class="ajustacoluna10">Acao</th>'
	bloco2+= Enter +'					 <th class="ajustacoluna11">Status</th>'
	bloco2+= Enter +'                 </tr>'
	bloco2+= Enter +'             </thead>'
	bloco2+= Enter +'             <tbody>'

	cQuery := " SELECT ZX_RECSE2, R_E_C_N_O_ FROM " + RetSqlName("SZX")
	cQuery += " WHERE D_E_L_E_T_ <> '*' "
	cQuery += " AND ZX_STATUS = 'P' "
	cQuery += " AND ZX_USUARIO = '"+N2A->ZX_USUARIO+"' "

	MemoWrite("\INTRJ\" + cLOGNAME,cQuery)

	If Select("N2B") > 0
		N2B->(dbCloseArea())
	EndIf

	TcQuery cQuery New Alias "N2B"
	
	DBSelectArea("SE2")
	
	While N2B->(!EOF())
 
		SE2->(dbGoTo(Val(N2B->ZX_RECSE2)))
		
		bloco2+= Enter + '<tr>'
		bloco2+= Enter + '     <td class="ajustatd1"><button ng-click="main.detalhesadd('+"'"+SE2->E2_NUM+"'"+')"> + </button></td>'
		bloco2+= Enter + '     <td class="ajustatd2">'+SE2->E2_NUM+'</td>'
		bloco2+= Enter + '     <td class="ajustatd3">'+SE2->E2_PREFIXO+'</td>'
		bloco2+= Enter + '     <td class="ajustatd4">'+SE2->E2_PARCELA+'</td>'
		bloco2+= Enter + '     <td class="ajustatd5">'+SE2->E2_NOMFOR+'</td>'
		bloco2+= Enter + '     <td class="ajustatd6">'+SE2->E2_HIST+'</td>'
		bloco2+= Enter + '     <td class="ajustatd7">'+DTOC(SE2->E2_EMISSAO)+'</td>'
		bloco2+= Enter + '     <td class="ajustatd8">'+SE2->E2_TIPO+'</td>'
		bloco2+= Enter + '     <td class="ajustatd9">'+AllTrim(Transform(SE2->E2_VALOR ,"@E 999,999,999,999.99"))+'</td>'
		bloco2+= Enter + '     <td class="ajustatd10"><div ng-show="main.resposta('+"'"+SE2->E2_NUM+"'"+')== '+"'"+"'"+'"><button class="button" ng-click="main.aprova('+"'"+Alltrim(N2A->ZX_USUARIO)+"'"+','+"'"+Alltrim(N2B->ZX_RECSE2)+"'"+','+"'"+cValToChar(N2B->R_E_C_N_O_)+"'"+','+"'"+"SIM"+"')"+'">aprovar</button> <button class="button" ng-click="main.aprova('+"'"+Alltrim(N2A->ZX_USUARIO)+"'"+','+"'"+Alltrim(N2B->ZX_RECSE2)+"'"+','+"'"+cValToChar(N2B->R_E_C_N_O_)+"'"+','+"'"+"NAO"+"')"+'">reprovar</button></div></td>'
		
		AADD(aAprova,'main.aprova('+"'"+Alltrim(N2A->ZX_USUARIO)+"'"+','+"'"+Alltrim(N2B->ZX_RECSE2)+"'"+','+"'"+cValToChar(N2B->R_E_C_N_O_)+"'"+','+"'"+"SIM"+"');")
				
		bloco2+= Enter + '	 <td class="ajustatd11">{{main.resposta('+"'"+SE2->E2_NUM+"'"+')}}</td>'
		bloco2+= Enter + '</tr>'
		bloco2+= Enter + '<tr ng-show="main.detalhes == '+"'"+SE2->E2_NUM+"'"+'">'
		bloco2+= Enter + '     <td colspan="10">'
		bloco2+= Enter + '         <table class="tamanhotabela2">'
		bloco2+= Enter + '             <tbody>'
		bloco2+= Enter + '                 <tr>'
		bloco2+= Enter + '                     <td class="ajustaitem1">Titulo</td>'
		bloco2+= Enter + '                     <td class="ajustaitem2">Prefixo</td>'
		bloco2+= Enter + '                     <td class="ajustaitem3">Parcela</td>'
		bloco2+= Enter + '                     <td class="ajustaitem4">Dt.Emissao</td>'
		bloco2+= Enter + '                     <td class="ajustaitem5">Tipo</td>'
		bloco2+= Enter + '					 <td class="ajustaitem6">Valor</td>'
		bloco2+= Enter + '					 <td class="ajustaitem7">Saldo</td>'
		bloco2+= Enter + '					 <td class="ajustaitem8">Situacao</td>'
		bloco2+= Enter + '                 </tr>'
		
		cQuery := " SELECT TOP 12 E2_NUM, E2_PREFIXO, E2_PARCELA, E2_EMISSAO, E2_TIPO, E2_VALOR, E2_SALDO , CASE  WHEN E2_SALDO > 0 THEN 'PENDENTE' ELSE 'PAGO' END AS SITUACAO "
		cQuery += " FROM " +RetSqlName("SE2") 
		cQuery += " WHERE D_E_L_E_T_ <> '*' "
		cQuery += " AND E2_FORNECE = '"+SE2->E2_FORNECE+"' "
		cQuery += " AND E2_LOJA = '"+SE2->E2_LOJA+"' " 
		cQuery += " ORDER BY E2_EMISSAO DESC "
		
		MemoWrite("\INTRJ\" + cLOGNAME,cQuery)

		If Select("N2C") > 0
			N2C->(dbCloseArea())
		EndIf

		TcQuery cQuery New Alias "N2C"
		
		while N2C->(!EOF())                              
			bloco2+= Enter + '<tr>'
			bloco2+= Enter + '	<td class="ajustait1">'+N2C->E2_NUM+'</td>'
			bloco2+= Enter + '	<td class="ajustait2">'+N2C->E2_PREFIXO+'</td>'
			bloco2+= Enter + '	<td class="ajustait3">'+N2C->E2_PARCELA+'</td>'
			bloco2+= Enter + '	<td class="ajustait4">'+N2C->E2_EMISSAO+'</td>'
			bloco2+= Enter + '	<td class="ajustait5">'+N2C->E2_TIPO+'</td>'
			bloco2+= Enter + '	<td class="ajustait6">'+AllTrim(Transform(N2C->E2_VALOR ,"@E 999,999,999,999.99"))+'</td>'
			bloco2+= Enter + '	<td class="ajustait7">'+AllTrim(Transform(N2C->E2_VALOR ,"@E 999,999,999,999.99"))+'</td>'
			bloco2+= Enter + '	<td class="ajustait8">'+N2C->SITUACAO+'</td>'
			bloco2+= Enter + '</tr>
			N2C->(DbSkip())
		Enddo
		N2C->(DbCloseArea())

		bloco2+= Enter + '			</tbody>'
		bloco2+= Enter + '		</table>'
		bloco2+= Enter + '	</td>'
		bloco2+= Enter + '</tr>'
		
		N2B->(DbSkip())
	Enddo                                    

	bloco2+= Enter + '   		  </tbody>'
	bloco2+= Enter + '		 </table>'
	bloco2+= Enter + '	</body>'
	bloco2+= Enter + '<script>'

	bloco2+= Enter + 'var login = angular.module('+"'"+'rel'+"'"+', [])'

	bloco2+= Enter + 'angular.module('+"'"+'rel'+"'"+').controller("MainController", function($http, $filter) {'

	bloco2+= Enter + '    var vm = this;'
		
	bloco2+= Enter + '    vm.arraypedidos = [];'
	bloco2+= Enter + '    vm.arraypedidosrec = [];'
	bloco2+= Enter + '    vm.detalhes = '+"'"+"'"+';'
											

	bloco2+= Enter + '    vm.resposta = function(par) {'
	bloco2+= Enter + '        var ret = '+"'"+''+"'"+';'
	bloco2+= Enter + '        for (var i = 0; i < vm.arraypedidos.length; i++) {'
	bloco2+= Enter + '            vm.arraypedidos[i]'
	bloco2+= Enter + '            if ( vm.arraypedidos[i].pedido == par) {'
	bloco2+= Enter + '                ret = vm.arraypedidos[i].msg;'
	bloco2+= Enter + '                break'
	bloco2+= Enter + '            }'
	bloco2+= Enter + '        }'
	bloco2+= Enter + '        return ret;'
	bloco2+= Enter + '    };'

	bloco2+= Enter + '    vm.aprova = function(par1, par2, par3, par4) {'

	bloco2+= Enter + '    $http.get('+"'"+_cHostREST+'WSAPRCP/'+"'+par1+'/'+par2+'/'+par3+'/'+par4)."
	bloco2+= Enter + '        success(function(data) {'
	bloco2+= Enter + '            if (data.status == '+"'"+'ok'+"'"+') {'
	bloco2+= Enter + '             vm.arraypedidos.push(data);'
	bloco2+= Enter + '            }'
	bloco2+= Enter + '        }).'
	bloco2+= Enter + '        error(function(data) {'
	bloco2+= Enter + '            console.log('+"'"+'Tratar Error'+"'"+');'
	bloco2+= Enter + '        });'
	bloco2+= Enter + '    }'

	bloco2+= Enter + '    vm.detalhesadd = function(par) {'
	bloco2+= Enter + '        if (vm.detalhes !== par) {'
	bloco2+= Enter + '            vm.detalhes = par '
	bloco2+= Enter + '        } else {'
	bloco2+= Enter + '            vm.detalhes = '+"'"+"'"+';'
	bloco2+= Enter + '        }'
	bloco2+= Enter + '    }'
	bloco2+= Enter + '})'
	bloco2+= Enter + '</script>'
	bloco2+= Enter + '</html>'
	
	For nlx := 1 to Len(aAprova)
		cChamada += aAprova[nlx] + ";"
	Next	
	
	bloco3+= Enter +'	<tr>'
    bloco3+= Enter +'    <td><font face="Arial">'
	bloco3+= Enter +'      <input type="button" name="B1"  span style="font-weight: bold" value="Aprovar Todos"'
	bloco3+= Enter +'		    ng-click="'+cChamada+'">'
	bloco3+= Enter +'    </font></td>'
    bloco3+= Enter +'    </tr>'

	cHtml := bloco1 + bloco3 + bloco2

	bloco1 := ""
	bloco2 := ""
	bloco3 := ""
	
	aAprova := {}
	cData := dtoc(ddatabase)                          
	cHora := TIME()
    
	xData := SUBSTR(dtoc(ddatabase),1,2)+SUBSTR(dtoc(ddatabase),4,2)+SUBSTR(dtoc(ddatabase),7,4)
	xHora := SUBSTR(TIME(),1,2)+SUBSTR(TIME(),4,2)+SUBSTR(TIME(),7,2)

   	cAnexo1:= "\web\messenger\emp01\wfaprov\"+"aprovcp"+xData+xHora+".html"
   	cAnexo2:= "aprovcp"+xData+xHora+".html"

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
                                                                                                                                
    cAssunto := "Aprovacao Titulos a Pagar"
    
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

	dbSelectArea("SAK")
	If SAK->(dbSeek(xFilial("SAK")+N2A->ZX_USUARIO))
		cUsrApr := AK_USER
	EndIf

	PswOrder(1)
	PswSeek(cUsrApr,.T.)
	aUsuario := PswRet(1)

    cNome := UPPER(AllTrim(aUsuario[1,4]))
    cEmail := LOWER(AllTrim(aUsuario[1,14]))
    
    cPara:= cEmail
	conout("Nome Aprovador: " + cNome)
	conout("eMail Aprovador: " + cEmail)
    
    cMensagem := ' <p align="center"><font face="arial" color="#0000FF" size="4"><b>Mensagem Eletrônica - WorkFlow</b></font></p> '
	cMensagem += ' <p align="left">Prezado, <strong>'+cNome+'.</strong></p> '
	cMensagem += ' <p align="left">Segue link abaixo da relacao de Titulos a Pagar para Aprovacao</p> '
	cMensagem += ' <p align="left">Data do Envio: <strong>' + cData + '.</strong></p> '
	cMensagem += ' <p align="left">Hora: <strong>' + cHora + '.</strong></p> ' 
	cMensagem += ' <p align="left">Salvo em: <strong>' + cAnexo1 + '.</strong></p> '         
	cMensagem += ' <p align="left">Para abrir a relacao de Titulos a Pagar, <a href="'+_cHostWF+cAnexo2+'"> Click AQUI </a></p>'
    cMensagem += ' </body> '
	
	SEND MAIL FROM cUserFrom TO cPara CC "" SUBJECT cAssunto BODY cMensagem RESULT lResult 

	If !lResult
	    GET MAIL ERROR cError
   	    conout('Erro de Envio de e-mail: '+cError)
	else
	
		conout('eMail enviado!')

		N2B->(dbGoTop())
		dbSelectArea("SZX")
		While N2B->(!EOF())
			SZX->(dbGoTo(N2B->R_E_C_N_O_))
			RecLock("SZX",.F.)
			SZX->ZX_STATUS := "E"
			SZX->(MsUnlock())
			N2B->(dbSkip())
		EndDo
		N2B->(DbCloseArea())
	EndIf

	DISCONNECT SMTP SERVER
		
	N2A->(DbSkip())
Enddo       
N2A->(DbCloseArea())                             
         
RESET ENVIRONMENT
         
conout(" ")
conout("Finalizado processo WFN2CP " + DtoC(Date()) + " - " + Time())
conout(" ")   

RestArea(aArea)

Return()