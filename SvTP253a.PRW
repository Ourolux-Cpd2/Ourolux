#INCLUDE "PROTHEUS.CH"
#INCLUDE "AVPRINT.CH"

#xtranslate :TIMES_NEW_ROMAN_00_11   => \[1\]
#xtranslate :TIMES_NEW_ROMAN_01_10   => \[2\]
#xtranslate :COURIER_NEW_01_22       => \[3\]
#xtranslate :COURIER_NEW_01_17       => \[4\]
#xtranslate :TIMES_NEW_ROMAN_02_20   => \[5\]             
#xtranslate :TIMES_NEW_ROMAN_02_16   => \[6\]             


*----------------------*
USER FUNCTION SVTP253A()
*----------------------*
PRIVATE nPage:= 0

AVPRINT oPrn NAME "Desembolsos por Processos"

   oPrn:Rebuild()
   oPrn:SetLandscape(.t.)
   DEFINE FONT oFont1  NAME "Times New Roman"    SIZE 0,11          OF oPrn
   DEFINE FONT oFont2  NAME "Times New Roman"    SIZE 1,10          OF oPrn
   DEFINE FONT oFont3  NAME "Courier New"        SIZE 1,25  ITALIC  of oPrn  
   DEFINE FONT oFont4  NAME "Courier New"        SIZE 1,17  ITALIC  of oPrn
   DEFINE FONT oFont5  NAME "Times New Roman"    SIZE 2,20          OF oPrn
   DEFINE FONT oFont6  NAME "Times New Roman"    SIZE 2,16          OF oPrn
   
   aFontes := { oFont1, oFont2, oFont3, oFont4, oFont5, oFont6 }

   AVPAGE

        IncProc("Imprimindo...")

        nLinha:= 10

        SvCabGeral()
		
        *----- Dados Cambio  Inicio
        lpri:=.t.
        Work->(dbgotop())
        Do while ! Work->(eof())

           if Work->WKDESPESA <> "101"
              Work->(dbskip())
              LOOP
           endif

           if lpri .or. nLinha > 2000
              SvCabCambio() 
              lpri:=.f.
           endif

           oPrn:Say( nLinha,0100, Work->WKFORN_N    , aFontes:TIMES_NEW_ROMAN_01_10 )
           oPrn:Say( nLinha,1190, Work->WKMOEDA + " " + trans(Work->WKVL_MOEDA,"@E 999,999,999,999.99")  , aFontes:TIMES_NEW_ROMAN_01_10, , , ,1 )
           oPrn:Say( nLinha,1240, DTOC(Work->WKDT_VECTO)  , aFontes:TIMES_NEW_ROMAN_01_10 )
           oPrn:Say( nLinha,1550, trans(Work->WKTX_DI,"@E 999.9999999"  )       , aFontes:TIMES_NEW_ROMAN_01_10, , , ,1)
           oPrn:Say( nLinha,1880, trans(Work->WKVLREALDI,"@E 999,999,999.99") , aFontes:TIMES_NEW_ROMAN_01_10, , , ,1 )
           oPrn:Say( nLinha,2100, trans(Work->WKTX_HAWB,"@E 9,999.999999")        , aFontes:TIMES_NEW_ROMAN_01_10, , , ,1 )
           oPrn:Say( nLinha,2450, trans(Work->WKVLREALCA,"@E 999,999,999,999.99") , aFontes:TIMES_NEW_ROMAN_01_10, , , ,1 )
           oPrn:Say( nLinha,2600, Work->WKBANCO_NO  , aFontes:TIMES_NEW_ROMAN_01_10, , , ,3 ) 
           oPrn:Say( nLinha,3050, DTOC(Work->WKDT_PAGTO)  , aFontes:TIMES_NEW_ROMAN_01_10, , , ,3 ) 
           nLinha+= 50
           
           Work->(dbskip())
        Enddo

        if lpri
           oPrn:Say( nLinha,0100, "ATENÇÃO! NÃO HÁ PARCELAS DE CAMBIO CADASTRADAS PARA ESSE PROCESSO " , aFontes:COURIER_NEW_01_17,,CLR_RED)
           nLinha+=100
        endif

        *------ Dados Despesas Inicio
        lpri:=.t.
        nLinha+= 100
        Work->(dbgotop())
        Do while ! Work->(eof())
           if Work->WKDESPESA == "101"
              Work->(dbskip())
              LOOP
           endif
          if lpri .or. nLinha > 2000
             SvCabDespesa() 
              lpri:=.f.
           endif
           oPrn:Say( nLinha,0100, Work->WKFORN_N, aFontes:TIMES_NEW_ROMAN_01_10 )
           oPrn:Say( nLinha,0960, DTOC(Work->WKDT_VECTO), aFontes:TIMES_NEW_ROMAN_01_10)
           oPrn:Say( nLinha,1400, Work->WKDESPESA + " " + Work->WKDESPDESC, aFontes:TIMES_NEW_ROMAN_01_10)
           oPrn:Say( nLinha,2600, tran(Work->WKVL_MOEDA, "@E 999,999,999,999.99"), aFontes:TIMES_NEW_ROMAN_01_10, , , ,1 )
           nLinha+= 50
           Work->(dbskip())
        Enddo
        

        if lpri
           oPrn:Say( nLinha,0100, "ATENÇÃO! NÃO HÁ DESPESAS CADASTRADAS PARA ESSE PROCESSO " , aFontes:COURIER_NEW_01_17,,CLR_RED)
           nLinha+=100
        endif

        
        *------ Avarias
        nLinha+=90
		oPrn:Say( nLinha,0100, "Avarias ", aFontes:COURIER_NEW_01_17,,CLR_RED )
        oPrn:Say( nLinha+010,0330, SW6->W6_XAVARIA, aFontes:TIMES_NEW_ROMAN_01_10 )
		nLinha+=110
		        
        
        *------ Amostras
		oPrn:Say( nLinha,0100, "Amostras ", aFontes:COURIER_NEW_01_17,,CLR_RED )
        oPrn:Say( nLinha+010,0330, SW6->W6_XAMOS, aFontes:TIMES_NEW_ROMAN_01_10 )
		nLinha+=100
        
        
        

   AVENDPAGE

AVENDPRINT


*--------------------------*
STATIC FUNCTION SvCabGeral()
*--------------------------*
//oPrn:SayBitmap(nLinha,0100,cLogo,0300,0250)       
//oPrn:Say( nLinha+020, 1950,"PROFORMA INVOICE", aFontes:COURIER_NEW_01_40 ) //"PROFORMA INVOICE"
//oPrn:Box( nLinha+300 , 110  , nLinha+600, 1030 )

//oPrn:Say( nLinha+300 , 125  , alltrim(SA2->A2_NOME) , aFontes:COURIER_NEW_01_17 )
//oPrn:Line( nLinha, 110, nLinha, 3600)
//           oPrn:Box( nLi_Ini , 110 , nLinha , 111  )
//           oPrn:Box( nLi_Ini , 670 , nLinha , 671  )
//           oPrn:Box( nLi_Ini , 1500, nLinha , 1501 )

local oPen:= TPEN():NEW(1,5,CLR_BLACK)


nPage++
                                        
SYT->(DBSETORDER(1))
if SYT->(dbseek(xfilial("SYT")+SW6->W6_IMPORT))
   cNomImport:= SYT->YT_NOME                                       
else
   cNomImport:= "IMPORTADOR NÃO ENCONTRADO NO CADASTRO.: " + SW6->W6_IMPORT 
endif                              

oPrn:Say( nLinha,0100, alltrim(cNomImport) , aFontes:COURIER_NEW_01_22 )

oPrn:Say( nLinha,1800, ctit, aFontes:TIMES_NEW_ROMAN_02_20 )

oPrn:Say( nLinha,3500, "DATA...: ", aFontes:TIMES_NEW_ROMAN_02_16 )
oPrn:Say( nLinha,3700, DTOC(DATE()), aFontes:TIMES_NEW_ROMAN_02_16 )     

nLinha+=80
oPrn:Say( nLinha,1800, "Processo nro.  " , aFontes:COURIER_NEW_01_17 )
oPrn:Say( nLinha,2300,trans( SW6->W6_HAWB, AVSX3("W6_HAWB",6)) , aFontes:COURIER_NEW_01_17 )

oPrn:Say( nLinha,3500, "PAGINA.: ", aFontes:TIMES_NEW_ROMAN_02_16 )
oPrn:Say( nLinha,3700, trans(nPage,'@e 99999'), aFontes:TIMES_NEW_ROMAN_02_16 )     
nLinha+=60

oPrn:Line( nLinha,0100, nLinha,3230,oPen)  
nLinha+=60
return


*---------------------------*
STATIC FUNCTION SvCabCambio()
*---------------------------*
local oPen:= TPEN():NEW(1,5,CLR_RED)

oPrn:Say( nLinha,0100, "FOB ", aFontes:COURIER_NEW_01_17,,CLR_RED)
nLinha+=100

oPrn:Say( nLinha,0100, "Fornecedor ", aFontes:TIMES_NEW_ROMAN_01_10 )
oPrn:Say( nLinha,0850, "Valor na Moeda", aFontes:TIMES_NEW_ROMAN_01_10 )
oPrn:Say( nLinha,1240, "Vencimento ", aFontes:TIMES_NEW_ROMAN_01_10 )
oPrn:Say( nLinha,1420, "Tx DI ", aFontes:TIMES_NEW_ROMAN_01_10 )
oPrn:Say( nLinha,1680, "Vlr Reais-DI ", aFontes:TIMES_NEW_ROMAN_01_10 )
oPrn:Say( nLinha,1930, "Tx Cambio ", aFontes:TIMES_NEW_ROMAN_01_10 )
oPrn:Say( nLinha,2200, "Vlr Reais-Cambio ", aFontes:TIMES_NEW_ROMAN_01_10 )
oPrn:Say( nLinha,2600, "Banco", aFontes:TIMES_NEW_ROMAN_01_10 )   
oPrn:Say( nLinha,3000, "Fech. Cambio ", aFontes:TIMES_NEW_ROMAN_01_10 )
nLinha+=45
oPrn:Line( nLinha,0100, nLinha,0100+660,oPen)  
oPrn:Line( nLinha,0850, nLinha,0850+340,oPen)
oPrn:Line( nLinha,1240, nLinha,1240+130,oPen)
oPrn:Line( nLinha,1420, nLinha,1420+180,oPen)
oPrn:Line( nLinha,1680, nLinha,1680+200,oPen)
oPrn:Line( nLinha,1930, nLinha,1930+180,oPen)
oPrn:Line( nLinha,2200, nLinha,2200+250,oPen)
oPrn:Line( nLinha,2600, nLinha,2600+350,oPen)
oPrn:Line( nLinha,3000, nLinha,3000+210,oPen)
nLinha+=15
RETURN
 
*----------------------------*
STATIC FUNCTION SvCabDespesa()
*----------------------------*
local oPen:= TPEN():NEW(1,5,CLR_BLACK)

oPrn:Say( nLinha,0100, "Demais Gastos ", aFontes:COURIER_NEW_01_17,,CLR_RED )
nLinha+=100

oPrn:Say( nLinha,0100, "Fornecedor ", aFontes:TIMES_NEW_ROMAN_01_10 )
oPrn:Say( nLinha,0960, "Data", aFontes:TIMES_NEW_ROMAN_01_10 )
oPrn:Say( nLinha,1400, "Despesa", aFontes:TIMES_NEW_ROMAN_01_10 )
oPrn:Say( nLinha,2360, "Valor", aFontes:TIMES_NEW_ROMAN_01_10 )
nLinha+=45
oPrn:Line( nLinha,0100, nLinha,0100+640,oPen)  
oPrn:Line( nLinha,0960, nLinha,0960+160,oPen)
oPrn:Line( nLinha,1400, nLinha,1400+750,oPen)
oPrn:Line( nLinha,2360, nLinha,2360+250,oPen)
nLinha+=15


RETURN
 

