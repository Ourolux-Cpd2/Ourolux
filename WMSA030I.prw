#include "tbiconn.ch"
#include "PROTHEUS.CH"
#include "FWMVCDEF.CH"

//*****************************
/*/{Protheus.doc} WMSA030I
Sol. Sr.Wadih / Projeto - Automa��o do Processo Solar
Fun��o - Cadastrar o Abastecimento automaticamento  - MVC padr�o.
IMPORTANTE - Todas as Variaveis est�o FIXA no Programa

@author Andr� Salgado / INTRODE
@since 18/01/2021
@version 1.0
/*/
User Function WMSA030I(_CodProd)
Local oModel, oModelCab, oModelDet
Local _CodProd := _CodProd
 
SetFunName("WMSA030")

oModel    := FwLoadModel("WMSA030")
oModelCab := oModel:GetModel("MdFieldCDC3")
oModelDet := oModel:GetModel("MdGridIDC3")

oModel:SetOperation(MODEL_OPERATION_INSERT) // Seta opera��o de inclus�o
oModel:Activate() // Ativa o Modelo

oModelCab:SetValue("DC3_LOCAL",  "01")
oModelCab:SetValue("DC3_CODPRO", _CodProd)
oModelCab:SetValue("DC3_REABAS", "003")
oModelCab:SetValue("DC3_PRIEND", "1")

//Ordem - 01 - Picking
oModelDet:SetValue("DC3_ORDEM" , "01")
oModelDet:SetValue("DC3_TPESTR", "000002")
oModelDet:SetValue("DC3_CODNOR", "000908")
oModelDet:SetValue("DC3_DESPIC", "PICKING")
oModelDet:SetValue("DC3_TIPREP", "1")    // Tp Repos.
oModelDet:SetValue("DC3_PERREP", 100)    //Tx Reposi��o
oModelDet:SetValue("DC3_TIPSEP", "3")    // Quantidade Minina
oModelDet:SetValue("DC3_QTDUNI", 1)      // Minino Apanh
oModelDet:SetValue("DC3_NUNITI", 1)      //Unitilizadores
oModelDet:SetValue("DC3_EMBDES", "1")    // Abastecimento
oModelDet:SetValue("DC3_TIPEND", "1")    // Endere�os Vazios
//oModelDet:SetValue("DC3_UMMOV" , "1")    // Primeira UM

//Ordem - 02 - PULMAO
oModelDet:AddLine()
oModelDet:SetValue("DC3_ORDEM" , "02")
oModelDet:SetValue("DC3_TPESTR", "000003")
oModelDet:SetValue("DC3_CODNOR", "000908")
oModelDet:SetValue("DC3_DESPIC", "PULMAO")
oModelDet:SetValue("DC3_TIPSEP", "2")    // Saldo Restante
oModelDet:SetValue("DC3_NUNITI", 1)      // Unitizadores
oModelDet:SetValue("DC3_EMBDES", "1")    // Abastecimento
oModelDet:SetValue("DC3_TIPEND", "1")    // Endere�os Vazios

//Ordem - 03 - BLOCADO
oModelDet:AddLine()
oModelDet:SetValue("DC3_ORDEM" , "03")
oModelDet:SetValue("DC3_TPESTR", "000004")
oModelDet:SetValue("DC3_CODNOR", "000908")
oModelDet:SetValue("DC3_DESPIC", "BLOCADO")
oModelDet:SetValue("DC3_TIPSEP", "3")    // Quantidade Minina
oModelDet:SetValue("DC3_NUNITI", 6)      // Unitizadores
oModelDet:SetValue("DC3_EMBDES", "1")    // Abastecimento
oModelDet:SetValue("DC3_TIPEND", "1")    // Endere�os Vazios

//Ordem - 04 - DOCA
oModelDet:AddLine()
oModelDet:SetValue("DC3_ORDEM" , "04")
oModelDet:SetValue("DC3_TPESTR", "000001")
oModelDet:SetValue("DC3_CODNOR", "000908")
oModelDet:SetValue("DC3_DESPIC", "DOCA")
oModelDet:SetValue("DC3_TIPSEP", "3")    // Quantidade Minina
oModelDet:SetValue("DC3_NUNITI", 1)      // Unitizadores
oModelDet:SetValue("DC3_EMBDES", "2")    // Embarque / Desembarque
oModelDet:SetValue("DC3_TIPEND", "1")    // Endere�os Vazios


//Valida��o e Grava��o do Modelo
If oModel:VldData()
    oModel:CommitData()
Else
    VarInfo("Erro",oModel:GetErrorMessage())
EndIf
 
Return
