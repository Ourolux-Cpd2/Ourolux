#include "rwmake.ch"  
#include "Protheus.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFSEXFUN   บAutor  ณWilson Jorge Tedokonบ Data ณ  14/03/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcoes genericas para ELETROMEGA.                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Eletromega                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                                               



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFUNCTION  ณIsAdm     บAutor  ณMicrosiga           บ Data ณ  14/03/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica se o usuario e administrador                      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Eletromega                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function IsAdm()
Local lRet    := .F.  
Local aGrupos := {}

If ( __cUserID == "000000" )  
  lRet := .T.
Else	
// Para verificar se faz parte do grupo de administradores
  PswOrder(1)
  If (PswSeek(__cUserID) )
	aGrupos := Pswret(1)
	If ( Ascan(aGrupos[1][10],"000000") <> 0 )
	  lRet := .T.
	EndIf
  EndIf
EndIf

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFUNCTION  ณIsELE001  บAutor  ณWilson Jorge Tedokonบ Data ณ  14/03/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica se o usuario pertence ao grupo de usuario que foi บฑฑ
ฑฑบ          ณ informado no parametro FS_ELE001                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Eletromega                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function IsELE001()
Local lRet     := .F. 
Local cGrupo  := ""
// Parametro para informar o grupo.
cGrupo := GetMV("FS_ELE001")

lRet := IsGroup(cGrupo)

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFUNCTION  ณIsELE002  บAutor  ณWilson Jorge Tedokonบ Data ณ  14/03/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica se o usuario pertence ao grupo de usuario que foi บฑฑ
ฑฑบ          ณ informado no parametro FS_ELE002                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Eletromega                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function IsELE002()
Local lRet   := .F. 
Local cGrupo := ""
// Parametro para informar o grupo.
cGrupo  := GetMV("FS_ELE002")

lRet := IsGroup(cGrupo)

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFUNCTION  ณIsGroup   บAutor  ณWilson Jorge Tedokonบ Data ณ  14/03/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica se o usuario que esta logado no protheus pertence บฑฑ
ฑฑบ          ณ ao grupo                                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Eletromega                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function IsGroup(cGrupo)
Local lRet     := .F. 
Local aUser    := {}
Local aGrupo   := {}
Local nx       := 0

PswOrder(2)
//If (PswSeek(Subs(cUsuario,7,15))) 

If (PswSeek(cUserName))
	aUser    := Pswret(1)
	aGrupo   := aUser[1][10]
EndIf                

PswOrder(1)        

for nx := 1 to len(aGrupo)
  If PswSeek( aGrupo[nx], .F. )
    If (UPPER(AllTrim(cGrupo)) == UPPER(AllTrim(PswRet()[1][1])))  
      lRet := .T.
      Return lRet
    EndIF
  EndIf
next                

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFUNCTION  ณValidVal  บAutor  ณWilson Jorge Tedokonบ Data ณ  14/03/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida se o valor do produto pertence a faixa de valores   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณcTabela  - Tabela de Preco Atual                            บฑฑ
ฑฑบ          ณcProduto - Produto da linha Atual                           บฑฑ
ฑฑบ          ณnValor   - Valor do produto Atual                           บฑฑ
ฑฑบ          ณcFlag    - 'S' --> (chamado do UB->VRUNIT)Reset price to 0  บฑฑ 
ฑฑบ                      'N' --> (chamado do ponto TKGRPED)Do not reset   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ(.F.) se estiver abaixo da faixa                            บฑฑ
ฑฑบ          ณ(.T.) se o valor do produto estiver na faixa permitida      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Eletromega                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function ValidVal(cTabela, cFlag, cProduto, nValor)
Local lRet		:= .T. 
Local lUsaFai	:= .F.
Local cAlias	:= "TMP" 
Local aArea		:= GetArea()
Local aAreaDA0	:= DA0->(GetArea()) 
Local aAreaSA1	:= SA1->(GetArea())
Local aAreaSB1	:= SB1->(GetArea())
Local nValDA1	:= 0
Local nInt		:= TamSx3("UA2_VALMAX")[1]
Local nDecs		:= TamSx3("UA2_VALMAX")[2]
Local cQuery
Local nPrcMin   := 0
//Local cProduto  := ""
//Local nValor	:= 0

/*
Default cProduto  := aCols[n,aScan(aHeader,{|x|AllTrim(x[2])=="UB_PRODUTO"})]
Default nValor    := aCols[n,aScan(aHeader,{|x|AllTrim(x[2])=="UB_VRUNIT"})] 
*/

If (Empty(cProduto) .Or. nValor == 0)
	lRet := .F.
	Alert("Pre็o Invalido!","ValidVal")
	Return(lRet)
EndIf

DA0->(DbSetOrder(1))
DbSelectArea("SB1")
DbSetOrder(1)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica se o produto utiliza faixa de precoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If DbSeek(xFilial("SB1")+cProduto)
  lUsaFai := (SB1->B1_VERFAI == "S")
EndIf 

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCaso POSITIVO, verifica a tabelaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lUsaFai
	If DA0->(DbSeek(xFilial("DA0")+cTabela))
		lUsaFai := (DA0->DA0_VERFAI == "S")
	EndIf
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCaso DIRETO, NAO TEM FAIXA DE PREวO   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
/*
If lUsaFai
	
	lUsaFai := ! (SA1->A1_SATIV1 $ 'DIRETO' )
	
EndIf
*/
If lUsaFai
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณA rotina foi desenvolvida exclusivamente para ambienteณ
//ณTOPCONNECT                                            ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
  #IFDEF TOP
    
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณEncerra area temporaria caso ja estivesse em usoณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If Select(cAlias) != 0
		TMP->(DbCloseArea())
	EndIf
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณMonta a queryณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤู
	//cQuery	:= "SELECT MIN(CAST(ISNULL((DA1.DA1_PRCVEN - ((DA1.DA1_PRCVEN * UA1.UA1_DESCAT)/100)),0)"
	//cQuery	+= " AS NUMERIC("+Str(nInt)+","+Str(nDecs)+"))) VALMIN  "
	
	cQuery	:= "SELECT MIN(ISNULL((DA1.DA1_PRCVEN - ((DA1.DA1_PRCVEN * UA1.UA1_DESCAT)/100)),0)"
	cQuery	+= " ) VALMIN  "
	cQuery	+= "FROM " +RetSqlName("DA1") + " DA1, " + RetSqlName("UA1") +" UA1, "
	cQuery	+= RetSqlName("DA0") + " DA0, " + RetSqlName("SB1") + " SB1 "
	cQuery	+= "WHERE "
	cQuery	+= "       DA1.DA1_CODTAB = '" + cTabela  + "' AND "
	cQuery	+= "       DA1.DA1_CODPRO = '" + cProduto + "' AND "
	cQuery	+= "       DA1.DA1_CODTAB = UA1.UA1_CODTAB AND "
	cQuery	+= "       DA0.DA0_CODTAB = DA1.DA1_CODTAB AND "
	cQuery	+= "       SB1.B1_COD = DA1.DA1_CODPRO AND "
	cQuery	+= "       DA0.D_E_L_E_T_ = ' ' AND "
	cQuery	+= "       SB1.D_E_L_E_T_ = ' ' AND "
	cQuery	+= "       DA1.D_E_L_E_T_ = ' ' AND "
	cQuery	+= "       UA1.D_E_L_E_T_ = ' '  "
	cQuery  += "       AND  DA0_FILIAL = '"+xFilial("DA0")+"' "  // 18-06-08
	cQuery  += "       AND  DA1_FILIAL = '"+xFilial("DA1")+"' "  // 18-06-08 
	cQuery  += "       AND  UA1_FILIAL = '"+xFilial("UA1")+"' "  // 18-06-08

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณPrepara e executa query no banco de dadosณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.T.)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณPercorre retorno, alimentando o array aComiss com os dados deณ
	//ณValores x Comissoes                                          ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	DbSelectArea("TMP")
	DbGoTop()

	If !TMP->(Eof())
		
		nPrcMin := IIf(SB1->B1_PR500X > TMP->VALMIN,SB1->B1_PR500X,TMP->VALMIN)  
	    
	    If (nValor >= NoRound(nPrcMin,nDecs ))
	    	lRet := .T.
	  	Else         
	       //	Alert("O valor informado ้ menor que o valor mํnimo (R$ " + Transform(nPrcMin, "@E 999,999,999.9999") + ").")
	    	Alert("Pre็o informado para o produto " + Alltrim(cProduto)+ " ้ menor que o valor mํnimo: (R$ " + ALLTRIM (STR (NoRound(nPrcMin,nDecs ))) + ").")
	    	lRet := .F.
	    	nValDA1 := GetAdvFVal("DA1","DA1_PRCVEN",xFilial("DA1")+cProduto+cTabela ,2,9999)   
	  	
	  	EndIf 
	   
	EndIf
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณFinaliza ambiente temporarioณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	TMP->(DbCloseArea())

  #ELSE

	ApMsgAlert("Funcใo nใo permitida em ambiente sem suporte a banco de dados")

  #ENDIF

Else   // No Faixa de pre็o
    
    nValDA1 := GetAdvFVal("DA1","DA1_PRCVEN",xFilial("DA1")+cProduto+cTabela ,2,9999)
	
	If nValor < NoRound(nValDA1,nDecs )
				
		lRet := .F.
	    
	    // Alert("O valor informado ้ menor que o valor mํnimo (R$ " + Transform(nValSb1, "@E 999,999,999.99") + ").")
		Alert("Pre็o informado para o produto " + Alltrim(cProduto)+ " ้ menor que o valor mํnimo: (R$ " + ALLTRIM (STR (NoRound(nValDA1,nDecs ))) + ").")
	
	EndIf
	
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRecupera o valor unitario originalณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !lRet .AND. ( cFlag == "S" )
	If IsInCallStack("TMKA271")
		M->UB_VRUNIT := nValDA1
		aCols[N,AScan(aHeader,{|x| AllTrim(x[2]) == "UB_VRUNIT"})] := nValDA1
		aCols[N,AScan(aHeader,{|x| AllTrim(x[2]) == "UB_PRCTAB"})] := nValDA1
		aCols[N,AScan(aHeader,{|x| AllTrim(x[2]) == "UB_VLRITEM"})] := ;
		aCols[N,AScan(aHeader,{|x| AllTrim(x[2]) == "UB_QUANT"})] * nValDA1
	ElseIf IsInCallStack("MATA410") 
		M->C6_PRCVEN := nValDA1
		aCols[N,AScan(aHeader,{|x| AllTrim(x[2]) == "C6_PRCVEN"})] := nValDA1
		aCols[N,AScan(aHeader,{|x| AllTrim(x[2]) == "C6_PRUNIT"})] := nValDA1
		aCols[N,AScan(aHeader,{|x| AllTrim(x[2]) == "C6_VALOR"})] := ;
		aCols[N,AScan(aHeader,{|x| AllTrim(x[2]) == "C6_QTDVEN"})] * nValDA1
	EndIf    
EndIf

RestArea(aAreaSB1)
RestArea(aAreaDA0)
RestArea(aAreaSA1)
RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFUNCTION  ณGetComis  บAutor  ณWilson Jorge Tedokonบ Data ณ  20/03/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Pega o percentual de comissao se tiver a tabela de valores บฑฑ
ฑฑบ          ณ x comissao.                                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณcVend    - Tabela de Preco Atual                            บฑฑ
ฑฑบ          ณcTabela  - Tabela de Preco Atual                            บฑฑ
ฑฑบ          ณcProduto - Produto da linha Atual                           บฑฑ
ฑฑบ          ณnComis   - Valor do produto Atual                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ(.F.) se NAO tiver tabela de preco x comissao               บฑฑ
ฑฑบ          ณ(.T.) se tiver tabela de preco x comissao                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Eletromega                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function GetComis(cVend, cTabela, cProduto, nPrcVen, nComis)   

Local nFatext   := 0
Local cAlias    := "TMP"  
Local aArea		:=	GetArea()
Local cQuery
Local lRet      := .F.
Local nDecs		:= TamSx3("UA2_VALMAX")[2]
Local nPrcMax   := 0

DbSelectArea("SA3")                          
DbSetOrder(1)

If DbSeek(xFilial("SA3")+cVend)
  nFatext := Val(SA3->A3_FATEXT)
EndIf                      


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณA rotina foi desenvolvida exclusivamente para ambienteณ
//ณTOPCONNECT                                            ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
#IFDEF TOP
    
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณEncerra area temporaria caso ja estivesse em usoณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If Select(cAlias) != 0
		TMP->(DbCloseArea())
	EndIf
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณGet O pre็o da Tabela    ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	nPrcMax := GetAdvFVal("DA1","DA1_PRCVEN",xFilial("DA1")+cProduto+cTabela ,2,0)
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณMonta a queryณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cQuery	:= "SELECT ISNULL((DA1.DA1_PRCVEN - ((DA1.DA1_PRCVEN * UA1.UA1_DESCDE)/100)),0) VALMAX, "
	cQuery	+= "       ISNULL((DA1.DA1_PRCVEN - ((DA1.DA1_PRCVEN * UA1.UA1_DESCAT)/100)),0) VALMIN, "
	cQuery	+= "       UA1.UA1_CODINT CODINT, "
	cQuery	+= "       UA1.UA1_CODEXT CODEXT, "
	cQuery	+= "       UA1.UA1_COMISS COMISS "
	cQuery	+= "FROM " + RetSqlName("DA1") + " DA1, " + RetSqlName("UA1") +" UA1 "
	cQuery	+= "WHERE "
	cQuery	+= "       DA1.DA1_CODTAB = '" + cTabela  + "' AND "
	cQuery	+= "       DA1.DA1_CODPRO = '" + cProduto + "' AND "
	cQuery	+= "       DA1.DA1_CODTAB = UA1.UA1_CODTAB AND "
	cQuery	+= "       DA1.D_E_L_E_T_ <> '*' AND "
	cQuery	+= "       UA1.D_E_L_E_T_ <> '*'  "
	cQuery  += "       AND  DA1_FILIAL = '"+xFilial("DA1")+"' "  // 18-06-08 
	cQuery  += "       AND  UA1_FILIAL = '"+xFilial("UA1")+"' "  // 18-06-08
	cQuery	+= "ORDER BY UA1.UA1_COMISS DESC "

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณPrepara e executa query no banco de dadosณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.T.)

	DbSelectArea("TMP")
	DbGoTop()

	While !TMP->(Eof()) .and. !lRet
      
        // If (TMP->VALMAX >= nPrcVen) .and. (TMP->VALMIN <= nPrcVen) war 06-09-06
        If (nPrcVen >= NoRound(TMP->VALMIN ,nDecs))
        /*
        If ((NoRound(TMP->VALMAX,nDecs) >= nPrcVen) .AND.;
         	(NoRound(TMP->VALMIN,nDecs) <= nPrcVen))
        */           		
       		nComis := TMP->COMISS * nFatext 
       		lRet   := .T.
    	
    	EndIf
    	
    	// Caso o pre็o digitado > pre็o da tabela 
		If !lRet .And. (nPrcMax > 0) .And. (nPrcVen > nPrcMax) 
		
			nComis := TMP->COMISS * nFatext 
       		lRet   := .T.
		
		EndIf		
      
	  TMP->(DbSkip())
	End
	
		
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณFinaliza ambiente temporarioณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	TMP->(DbCloseArea())

#ELSE

	ApMsgAlert("Funcใo nใo permitida em ambiente sem suporte a banco de dados")

#ENDIF

RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGetToFile บAutor  ณNorbert Waage Juniorบ Data ณ  07/07/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณDescarrega o conteudo da GetDados em uma area de trabalho   บฑฑ
ฑฑบ          ณParametros:                                                 บฑฑ
ฑฑบ          ณcAlias   - Area de trabalho que recebera os campos          บฑฑ
ฑฑบ          ณnIndice  - Numero do indice a ser considerado               บฑฑ
ฑฑบ          ณaH       - aHeader da GetDados relacionada                  บฑฑ
ฑฑบ          ณaC       - aCols da GetDados relacionada                    บฑฑ
ฑฑบ          ณaRecnos  - Recnos dos itens da getdados                     บฑฑ
ฑฑบ          ณaCposChv --Campos a serem gravados alem dos campos do aCols บฑฑ
ฑฑบ          ณ         ภ-Estrutura aCposChv:  {{CAMPO,VALOR},...}         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณGenerico                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function GetToFile(cAlias,nIndice,aH,aC,aRecnos,aCposChv)

Local aArea		:=	GetArea()
Local nPosDel	:=	Len(aH) + 1
Local nRegs		:=	Len(aRecnos)
Local nPos,nCampo

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAbre area de trabalhoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DbSelectArea(cAlias)
DbSetOrder(nIndice)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPercorre os campos do aColsณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
For nPos := 1 to Len(aC)
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณSe o item nao estiver deletado e estiver preenchidoณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If !aC[nPos][nPosDel] .And. EmptyCols(nPos,aC)
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณVerifica se o item atual ja se encontrava no bancoณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If nPos > nRegs
			RecLock(cAlias,.T.)
		Else
			DbGoTo(aRecnos[nPos])
			RecLock(cAlias,.F.)
		EndIf
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณAtualizacao dos camposณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		(cAlias)->(&(cAlias+"_FILIAL")) := xFilial(cAlias)
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณGrava campos que nao estao no aHeaderณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		For nCampo := 1 to Len(aCposChv)
			(cAlias)->(&(aCposChv[nCampo][1]))	:= aCposChv[nCampo][2]
		Next nCampo
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณPercorre os campos do aHeaderณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		For nCampo := 1 to Len(aH)
			
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณGrava os campos de contexto realณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If aH[nCampo][10] == "R"
				(cAlias)->(&(aH[nCampo][2]))	:=	aC[nPos][nCampo]
			EndIf

		Next nCampo
		
		MsUnLock()

	Else

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณTrata a Delecaoณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If nPos <= nRegs

			DbGoTo(aRecnos[nPos])
			RecLock(cAlias,.F.)
			DbDelete()
			MsUnLock()

		EndIf
				
	EndIf
	
Next nPos

RestArea(aArea)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLoadGD    บAutor  ณNorbert Waage Juniorบ Data ณ  07/07/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para carga do aCols da GetDados                      บฑฑ
ฑฑบ          ณParametros:                                                 บฑฑ
ฑฑบ          ณcAlias  - Alias trabalhado                                  บฑฑ
ฑฑบ          ณaH      - Array do aHeader recebido por referencia          บฑฑ
ฑฑบ          ณaC      - Array do aCols recebido por referencia            บฑฑ
ฑฑบ          ณaRecnos - Array que armazena os Recnos receb. por referenciaบฑฑ
ฑฑบ          ณnIndChv - Chave do indice a ser considerada para filtro     บฑฑ
ฑฑบ          ณcChave  - Valor da chave de filtro do indice                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณGenerico                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function LoadGD(cAlias,aH,aC,aRecnos,nIndChv,cChave)

Local aArea		:=	GetArea()
Local cIndKey	:=	""
Local aLinha	:=	{}
Local nUsado	:=	Len(aH)
Local nPos		:=	0
Local nLin 		:=	0
Local nLenChave	:=	Len(cChave)
//ฺฤฤฤฤฤฤฤฤฤฟ
//ณAbre areaณ
//ภฤฤฤฤฤฤฤฤฤู
DbSelectArea(cAlias)
DbSetOrder(nIndChv)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณLe chave do indiceณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cIndKey := (cAlias)->(IndexKey())

If DbSeek(cChave)
	
	aC := {}

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณPercorre area, carregando os camposณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	While !(cAlias)->(Eof()) .And. SubStr((cAlias)->(&(cIndKey)),1,nLenChave) ==  cChave
	
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณIncrementa aColsณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		Aadd(aC,Array(nUsado+1))
		nLin++
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณInicializa camposณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		For nPos := 1 To nUsado
			If aH[nPos][10] == "V"
				aC[nLin][nPos] := CriaVar(aH[nPos][2])
			Else
				aC[nLin][nPos] := (cAlias)->(&(aH[nPos][2]))
				M->(&(aH[nPos][2])) := (cAlias)->(&(aH[nPos][2]))
			EndIf
		Next

		aC[nLin][nUsado+1] := .F.
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณArmazena Recnoณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		AAdd(aRecnos,(cAlias)->(Recno()))
	
		(cAlias)->(DbSkip())
		
	End
	
EndIf

RestArea(aArea)

Return Nil                         

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณEmptyCols บAutor  ณNorbert Waage Juniorบ Data ณ  07/07/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para verificar se o aCols foi preenchido             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณGenerico                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function EmptyCols(n,aCols)

Local lRet:=.T.,lVazio:=.T.

If n==Len(aCols)
	Aeval(aCols[n],{|x|If(lVazio,lVazio:=Empty(x),lVazio)})
	If lVazio
		lRet:=.F. 
	EndIf
EndIf

Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออออออปฑฑ
ฑฑบPrograma  ณVldCPG    บAutor  ณNorbert Waage Juniorบ Data ณ  15/03/06      บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica se o valor a ser faturado eh permitido pela condi-    บฑฑ
ฑฑบ          ณcao de pagamento selecionada                                   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPonto TKGRPED                                                  บฑฑ
ฑฑบUso       ณUser function FSEV050                                          บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno ณ                                                                 บฑฑ 
ฑฑบ 0 - Valida                                                               บฑฑ
ฑฑบ 1 - Invalida - Deve usar a cond da tabela do pre็o                       บฑฑ
ฑฑบ 2 - Invalida - Deve usar a cond do cadastro do cliente                   บฑฑ
ฑฑบ 3 - Invalida - Valor nao atingiu o minimo imposto pela cond de pag (DA1) บฑฑ                         
ฑฑบ 4 - Invalida - Valor nao atingiu o minimo imposto pela cond de pag (SA1) บฑฑ
ฑฑบ 5 - Invalida - Valor nao atingiu o minimo imposto pela cond de pag       บฑฑ
ฑฑบ 6 - Invalida - Usuario nao tem acesso para usar a condi็ao (E4_NIVEL)    บฑฑ
ฑฑบ 7 - Invalida - Nao pode usar a condi็ao                                  บฑฑ
ฑฑบ                                 									     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function VldCPG(nLiquido,cCondPgto)

Local nRet			:= 7
Local cTabela	    := ""
Local cCliente  	:= ""
Local cLoja      	:= ""
Local lInMata410 	:= IsInCallStack("MATA410")

If IsInCallStack("TMKA271")
	cTabela  := M->UA_TABELA 
	cCliente := M->UA_CLIENTE
	cLoja    := M->UA_LOJA
ElseIf lInMata410
	cTabela  := M->C5_TABELA 
	cCliente := M->C5_CLIENTE
	cLoja    := M->C5_LOJACLI
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSomente prepara ambiente caso a rotina tenha sido chamadaณ
//ณcom uma condicao que possivelmente nao eh a condicao     ณ
//ณposicionada no SE4                                       ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !Empty(cCondPgto)
	//aArea		:= GetArea()
	//aAreaSE4	:= SE4->(GetArea())
	SE4->(DbSetOrder(1))
	If !(SE4->(DbSeek(xFilial("SE4")+cCondPgto)))
		Return(7)
	EndIf
EndIf

DA0->(DbSetOrder(1))
SA1->(DbSetOrder(1))

If (U_IsAdm() .OR. U_IsFreeCondPgt())  
	nRet := 0

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณConsidera a condicao presente na tabela de precosณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
ElseIf !Empty(cTabela) .And. DA0->(DbSeek(xFilial("DA0")+cTabela)) .And.;
       !Empty(DA0->DA0_CONDPG)

	If (DA0->DA0_CONDPG == SE4->E4_CODIGO)
	
		If nLiquido > 0 
			If (nLiquido >= SE4->E4_INFER)
				nRet := 0
			Else
				nRet := 3
				nLimite := SE4->E4_INFER
			EndIf
		Else
			nRet := IIf ((DA0->DA0_CONDPG == SE4->E4_CODIGO),0,1)
		EndIf	
	Else
		nRet := 1	
	EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณConsidera condicao presente no cadastro do clienteณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
ElseIf !Empty(cCliente) .And. SA1->(DbSeek(xFilial("SA1")+cCliente+cLoja)) .And.;
	   !Empty(SA1->A1_COND)
	 
	If (SA1->A1_COND == SE4->E4_CODIGO)
	
		If nLiquido > 0 
			If (nLiquido >= SE4->E4_INFER)
				nRet := 0
			Else
				nRet := 4
				nLimite := SE4->E4_INFER
			EndIf
		Else
			nRet := IIf ((SA1->A1_COND == SE4->E4_CODIGO),0,2)
		EndIf	
	Else
		nRet := 2	
	EndIf
	
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณConsidera niveis de acesso e limites superior e inferiorณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Else
	If Val(SE4->E4_NIVEL) <= cNivel
	
	    If nLiquido > 0
	    	If (nLiquido >= SE4->E4_INFER)
	    		If (SE4->E4_CODIGO != 'XXX') 
	    			nRet := 0
	    		EndIf
	    	Else
	    		nLimite := SE4->E4_INFER
	    		nRet 	:= 5
	   		EndIf
		Else
			nRet := IIF((SE4->E4_CODIGO == 'XXX') .And. lInMata410,0,7)
		EndIf
	Else
		nRet := 6
	EndIf
EndIf

Return (nRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVLDTAB    บAutor  ณNorbert Waage Juniorบ Data ณ  16/03/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida a tabela de precos em uso para o vendedor            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณEletromega                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function VLDTAB()

Local aArea		:= GetArea()
//Local cCampo	:= AllTrim(ReadVar())
Local cTabCli	:= ""
Local lPertence	:= .F.
Local lRet		:= .T.
Local cCli 		:= ""
Local cLoj 		:= ""
Local cTabela   := ""
Local cVend     := ""

If IsInCallStack("TMKA271") .And. lTK271Auto
	RestArea(aArea)
	Return(lRet)
EndIf

If IsInCallStack("MATA410")
	cCli 	:= M->C5_CLIENTE
	cLoj 	:= M->C5_LOJACLI
	cTabela := M->C5_TABELA
	cVend 	:= M->C5_VEND1
ElseIf IsInCallStack("TMKA271")
	cCli 	:= M->UA_CLIENTE
	cLoj 	:= M->UA_LOJA
	cTabela := M->UA_TABELA
	cVend 	:= M->UA_VEND
EndIf

If !U_IsAdm()
	lRet := U_TabPert(cVend,cTabela,cCli,cLoj)
	If !lRet
		ApMsgStop("A tabela selecionada nใo ้ vแlida. Selecione outra tabela.","Aten็ao")
	EndIf
EndIf

RestArea(aArea)

Return lRet   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFUNCTION  ณTabPert   บAutor  ณNorbert Waage Juniorบ Data ณ  30/03/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida se a tabela de precos esta associada ao vendedor     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณcVend    - Vendedor                                         บฑฑ
ฑฑบ          ณcTabela  - Tabela de Preco                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ(.F.) Se nao existir associacao                             บฑฑ
ฑฑบ          ณ(.T.) Se a tabela estiver associada ao vendedor             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Eletromega                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function TabPert(cVend,cTab,cCli,cLoj)

Local aArea		:= GetArea()
Local aAreaSA3	:= SA3->(GetArea())
Local lRet		:= .F.
Local cTabCli	:= ""

cTabCli := GetAdvFVal("SA1","A1_TABELA",xFilial("SA1")+cCli+cLoj,1,"")

If !Empty(cTabCli)
	lRet := cTabCli == cTab
Else
	DbSelectArea("SA3")
	DbSetOrder(1)
	
	If DbSeek(xFilial("SA3")+cVend)
		lRet := U_Pert(AllTrim(cTab) ,AllTrim(SA3->A3_TABPREC))
	EndIf
EndIf 

Restarea(aAreaSA3)
Restarea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณListaVnd  บAutor  ณNorbert Waage Juniorบ Data ณ  03/04/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCria uma string com o codigo de vendedores cujo o vendedor  บฑฑ
ฑฑบ          ณatual pode assumir as permissoes de cadastros customizados  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณEletromega                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Foi acrescentado o tratamento de que se esta funcao  estiver ณ
//ณ sendo usada de uma consulta padrใo de SA3 ela nao pode       ณ
//ณ manipular  o SA3 diretamente (stack overflow), portanto      ณ
//ณ abrimos o SA3 com outro nome.                                ณ
//ณ                                   Ernani Forastieri 30/05/06 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
User Function ListaVnd(cRet, cVend, lConsulta, lConsult2 )
Local aArea		:= GetArea()
Local aAreaSA3	:= SA3->(GetArea())
Local aAreaSU7	:= SU7->(GetArea())
Local cFilSA3	:= xFilial("SA3")
Local cVendAtu	:= ""
Local cSep 		:= If(Empty(cRet),"","/")
Local cStrTmp	:= ""
Local cStrAux	:= ""
Local cAlias    := "SA3"
Local cAlias2   := "SU7"

lConsulta := IIf( lConsulta == NIL, .F., lConsulta )
lConsult2 := IIf( lConsult2 == NIL, .F., lConsult2 )

If lConsulta
   cAlias := 'NSA3'
   chkFile( 'SA3',,'NSA3')
EndIf            


If lConsult2
   cAlias2 := 'NSU7'
   chkFile( 'SU7',,'NSU7')
EndIf            


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCodigo do vendedorณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If cVend == Nil
	(cAlias2)->(DbSetOrder(4)) //U7_FILIAL+U7_CODUSU
	If (cAlias2)->(DbSeek(xFilial("SU7")+__cUserId))
		cVendAtu := (cAlias2)->U7_CODVEN
		cRet += cSep + cVendAtu
	EndIf
Else
	cVendAtu := cVend
	If !(AllTrim(cVendAtu) $ cRet)
		cRet += cSep + cVendAtu
	EndIf
EndIf

cSep := "/"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica se o vendedor eh auxiliarณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
(cAlias)->(DbSetOrder(1))
(cAlias)->(DbSeek(cFilSA3+cVendAtu))
cStrTmp := AllTrim((cAlias)->A3_AUXVEN)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta a lista de vendedores associadosณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !Empty(cVendAtu)
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณProcura vendedores como gerenteณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	(cAlias)->(DbSetOrder(4)) //A3_FILIAL+A3_GEREN
	(cAlias)->(DbSeek(cFilSA3+cVendAtu))

	While	!(cAlias)->(Eof()) .And.;
			(cAlias)->A3_FILIAL == cFilSA3 .And.;
			(cAlias)->A3_GEREN == cVendAtu

			If !(AllTrim((cAlias)->A3_COD) $ cRet)
				cRet += cSep + (cAlias)->A3_COD
			EndIf
			(cAlias)->(DbSkip())
			
	End
		
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณProcura vendedores como supervisorณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	(cAlias)->(DbSetOrder(5)) //A3_FILIAL+A3_SUPER
	(cAlias)->(DbSeek(cFilSA3+cVendAtu))
	
	While	!(cAlias)->(Eof()) .And.;
			(cAlias)->A3_FILIAL == cFilSA3 .And.;
			(cAlias)->A3_SUPER == cVendAtu
			
			If !(AllTrim((cAlias)->A3_COD) $ cRet)
				cRet += cSep + (cAlias)->A3_COD
			EndIf
			(cAlias)->(DbSkip())
						
	End

EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSe for um auxiliar, concatena os vendedores dos auxiliadosณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !Empty(cStrTmp) .And. !U_NaPilha("U_LISTAVND",2)
	
	cStrAux := ""

	While !Empty(cStrTmp)
	
		nAt 	:= At("/",cStrTmp)
		cVndAux := If(nAt == 0,SubStr(cStrTmp,1,Len(cStrTmp)),SubStr(cStrTmp,1,nAt-1))
		cStrTmp	:= If(nAt == 0,"",SubStr(cStrTmp,nAt+1,Len(cStrTmp)))
	
		U_ListaVnd(@cRet,cVndAux)
		
	End
	
EndIf

If lConsulta
   (cAlias)->(dbCloseArea())
EndIf

If lConsult2
   (cAlias2)->(dbCloseArea())
EndIf            

RestArea(aAreaSU7)
RestArea(aAreaSA3)
RestArea(aArea)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณNaPilha   บAutor  ณNorbert Waage Juniorบ Data ณ  15/07/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออุออออออออัอออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบLocacao   ณ Fab.Tradicional  ณContato ณ norbert@microsiga.com.br       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออฯออออออออฯออออออออออออออออออออออออออออออออนฑฑ
ฑฑบDescricao ณVarre a pilha de chamadas em busca do parametro recebido.   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณcFuncao - Nome da rotina a ser pesquisada                   บฑฑ
ฑฑบ          ณnStart  - Numero da camada da pilha de onde a funcao parte  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ lRet = .T. (Foi encontrada na pilha)                       บฑฑ
ฑฑบ          ณ        .F. (Nao foi encontrada)                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAplicacao ณ Generica                                                   บฑฑ
ฑฑฬออออออออออุออออออออัออออออัออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณData    ณBops  ณManutencao Efetuada                      	  บฑฑ
ฑฑบ          ณ        ณ      ณ                                         	  บฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function NaPilha(cFuncX,nStart)

Local lRet		:=	.F.
Local cProc		:=	""   

Default nStart	:=	0

cFuncX := AllTrim(Upper(cFuncX))

While !Empty(cProc := ProcName(nStart++)) .And. !lRet
	lRet :=	(Alltrim(Upper(cProc)) == cFuncX)
End

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFUNCTION  ณIsDireto  บAutor  ณNorbert Waage Juniorบ Data ณ  04/04/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica se o usuario pertence ao grupo 'Direto'           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Eletromega                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function IsDireto()

Local aArea	  := GetArea()
Local lRet    := U_IsELE001()
RestArea(aArea)

Return lRet

/////////////////////////////////////////////////////////////////////////////
User Function ListaVn2(cRet, cVend, lConsulta)
Local aArea		:= GetArea()
Local aAreaSA3	:= SA3->(GetArea())
Local aAreaSU7	:= SU7->(GetArea())
Local cFilSA3	:= xFilial("SA3")
Local cVendAtu	:= ""
Local cSep 		:= If(Empty(cRet),"","/")
Local cStrTmp	:= ""
Local cStrAux	:= ""
Local cAlias    := "SA3"

lConsulta := IIf( lConsulta == NIL, .F., lConsulta )

If lConsulta
   cAlias := 'NSA3'
   chkFile( 'SA3',,'NSA3')
EndIf            


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCodigo do vendedorณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If cVend == Nil
	SU7->(DbSetOrder(4)) //U7_FILIAL+U7_CODUSU
	If SU7->(DbSeek(xFilial("SU7")+__cUserId))
		cVendAtu := SU7->U7_CODVEN
		cRet += cSep + cVendAtu
	EndIf
Else
	cVendAtu := cVend
	If !(AllTrim(cVendAtu) $ cRet)
		cRet += cSep + cVendAtu
	EndIf
EndIf

cSep := "/"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica se o vendedor eh auxiliarณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
(cAlias)->(DbSetOrder(1))
(cAlias)->(DbSeek(cFilSA3+cVendAtu))
cStrTmp := AllTrim((cAlias)->A3_AUXVEN)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta a lista de vendedores associadosณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !Empty(cVendAtu)
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณProcura vendedores como gerenteณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	(cAlias)->(DbSetOrder(4)) //A3_FILIAL+A3_GEREN
	(cAlias)->(DbSeek(cFilSA3+cVendAtu))

	While	!(cAlias)->(Eof()) .And.;
			(cAlias)->A3_FILIAL == cFilSA3 .And.;
			(cAlias)->A3_GEREN == cVendAtu

			If !(AllTrim((cAlias)->A3_COD) $ cRet)
				cRet += cSep + (cAlias)->A3_COD
			EndIf
			(cAlias)->(DbSkip())
			
	End
		
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณProcura vendedores como supervisorณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	(cAlias)->(DbSetOrder(5)) //A3_FILIAL+A3_SUPER
	(cAlias)->(DbSeek(cFilSA3+cVendAtu))
	
	While	!(cAlias)->(Eof()) .And.;
			(cAlias)->A3_FILIAL == cFilSA3 .And.;
			(cAlias)->A3_SUPER == cVendAtu
			
			If !(AllTrim((cAlias)->A3_COD) $ cRet)
				cRet += cSep + (cAlias)->A3_COD
			EndIf
			(cAlias)->(DbSkip())
						
	End

EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSe for um auxiliar, concatena os vendedores dos auxiliadosณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !Empty(cStrTmp) .And. !U_NaPilha("U_LISTAVND",2)
	
	cStrAux := ""

	While !Empty(cStrTmp)
	
		nAt 	:= At("/",cStrTmp)
		cVndAux := If(nAt == 0,SubStr(cStrTmp,1,Len(cStrTmp)),SubStr(cStrTmp,1,nAt-1))
		cStrTmp	:= If(nAt == 0,"",SubStr(cStrTmp,nAt+1,Len(cStrTmp)))
	
		U_ListaVnd(@cRet,cVndAux)
		
	End
	
EndIf

If lConsulta
   (cAlias)->(dbCloseArea())
EndIf

RestArea(aAreaSU7)
RestArea(aAreaSA3)
RestArea(aArea)

Return Nil

////////////////////

User Function IsCliente()

Local lRet := .F.
Local aAreaSA3	:= SA3->(GetArea())
Local aArea		:= GetArea()

DbSelectArea("SA3")
DbSetOrder(7)  //A3_FILIAL + A3_CODUSR

If DbSeek(xFilial("SA3")+RetCodUsr())
	//lRet := (AllTrim(SA3->A3_TIPO) $ 'C') 
	lRet := (AllTrim(SA3->A3_FATEXT) $ '0')
EndIf

Restarea(aAreaSA3)
Restarea(aArea)

Return (lRet)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Function Pert() -- Return true if str2 contains str1   //ณ
//ณ str1 e str2 nao vazis e sem trailing spaces            //ณ
//ณ str1: 900  str2: 900/100/3							   //ณ
//ณ data: 26/10/2006                                       //ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
User Function Pert(cTabela,cLista)
Local lRet:= .F.
Local nStart := 1 
Local aList := {}
Local lFound := .F.

If Empty(cTabela) .OR. Empty(cLista)
	Return(.F.)	
EndIf 

If (substr(cLista,len(cLista),1) $ '/')
	Return(.F.)
EndIf

For i:= 1 to Len(cLista)
    If substr(cLista,i,1) $ '/'
    	AADD(aList, val(substr(cLista,nStart,i - nStart)))   
        lFound := .T.
        nStart := i + 1
    EndIf
Next

AADD(aList, val(substr(cLista,nStart)))

If (ASCAN(aList,val(cTabela)) <> 0 )
	lRet := .T.
EndIf

Return(lRet)


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Function PrdInTab -- Return true if produto is in      //ณ
//ณ tabela de pre็os                                       //ณ
//ณ                         							   //ณ
//ณ data: 02/04/2009                                       //ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
User Function PrdInTab(cProduto,cTabela)
Local aArea		:= GetArea()
Local aAreaDA1  := DA1->(GetArea())
Local lRet		:= .F.

If !Empty(cProduto) .And. !Empty(cTabela) 

	DA1->(DbSetOrder(1)) //DA1_FILIAL+DA1_CODTAB+DA1_CODPRO+DA1_INDLOT+DA1_ITEM
  	If !(lRet := DA1->(DbSeek(xFilial("DA1")+cTabela+cProduto)))
		ApMsgStop("Produto: " + Alltrim(cProduto) + " nใo existe na tabela de pre็os selecionada","Aten็ใo")
	EndIf
		
EndIf
     
Restarea(aAreaDA1)                   
Restarea(aArea)

Return lRet