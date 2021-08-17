#IFNDEF WINDOWS
   #DEFINE PSAY SAY
#ENDIF

/*
  
Este modulo tem como finalidade gerar um relatorio de canhotos em aberto

Author: Sérgio Santana
Criado em: 13/12/2002

*/

User Function RptRelCan()
#Include "rwmake.ch"

PRIVATE CbTxt    := ""
PRIVATE CbCont   := ""
PRIVATE nOrdem   := 0
PRIVATE Alfa     := 0
PRIVATE Z        := 0
PRIVATE M        := 0
PRIVATE tamanho  := "M"
PRIVATE limite   := 96
PRIVATE titulo   := PADC("rptRelCan -Relação de Canhotos ",74)
PRIVATE cDesc1   := PADC("Este Programa tem a Finalidade de Emitir um relatório com a posição",74)
PRIVATE cDesc2   := PADC("do  canhotos  em  aberto. Para Uso  Exclusivo da Empresa EletroMega",74)
PRIVATE cDesc3   := PADC("                                                                    ",74)
PRIVATE aReturn  := { "Especial", 1,"Administracao", 1, 2, 1,"",1 }
PRIVATE nomeprog := "rptTrcCa"
PRIVATE cPerg    := PadR("RPTCAN",10)
PRIVATE nLastKey := 0
PRIVATE lContinua:= .T.
PRIVATE nLin     := 0
PRIVATE wnrel    := "rptRelCa"

Pergunte(cPerg,.F.)               // Pergunta no SX1

PRIVATE cString:="SF2"

Wnrel:=SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.F.)

If nLastKey == 27
   Return
Endif

SetDefault(aReturn,cString)
If nLastKey == 27
   Return
Endif

_iPer := Str( Year( MV_PAR01 ), 4 )
_iPer += StrZero( Month( MV_PAR01 ), 2 )

_fPer := Str( Year( MV_PAR02 ), 4 )
_fPer += StrZero( Month( MV_PAR02 ), 2 )

_cQry := 'SELECT Count(*) As Rec_No '
_cQry += 'FROM   dbo.SZA010 '
_cQry += "WHERE  (ZA_CANHOTO = ' ') AND (D_E_L_E_T_ <> '*') AND (ZA_EMISNF BETWEEN '" + DtoS( MV_PAR01 ) + "' "
_cQry += " AND '" + DtoS( MV_PAR02 ) + "') AND (ZA_TRANSP BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "') "
_cQry += " AND ZA_FILIAL = '" + xFilial("ZA") + "' "  // CURITIBA

dbUseArea( .T., "TOPCONN", TCGENQRY(,,_cQry), 'CAN' )
_nRegua := Rec_No

CAN->( dbCloseArea() )

_cQry := "SELECT ZA_NOTA As Nota, ZA_SERIE As Serie, Substring( ZA_DATA, 7, 2 ) + '/' + Substring( ZA_DATA, 5, 2 ) + '/' + Substring( ZA_DATA, 3, 2 ) As Emissao, ZA_CLIENTE As Cliente, ZA_NOMCLI As Nome, ZA_NOMETRA As Transp, ZA_MOTORIS As Motorista "
_cQry += 'FROM   SZA010 '
_cQry += "WHERE  (ZA_CANHOTO = ' ') AND (D_E_L_E_T_ <> '*') AND (ZA_EMISNF BETWEEN '" + DtoS( MV_PAR01 ) + "' "
_cQry += " AND '" + DtoS( MV_PAR02 ) + "') AND (ZA_TRANSP BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "') "
_cQry += " AND ZA_FILIAL = '" + xFilial("ZA") + "' "  // CURITIBA
_cQry += "ORDER BY ZA_TRANSP, ZA_EMISNF, ZA_NOTA"

dbUseArea( .T., "TOPCONN", TCGENQRY(,,_cQry), 'QRY' )

RptStatus({|| RptDetail() })
                                            
Return

Static Function RptDetail()

SetRegua( _nRegua )
cTitulo  := 'POSIÇÃO DE CANHOTOS DO PERIODO DE : ' + DtoC( MV_PAR01 ) + ' a ' + DtoC( MV_PAR02 )

Cabec1 := '  NOTA  SERIE  DATA    CLIENTE  NOME                 TRANSPORTADORA       MOTORISTA'
cabec2 := ""   

M_Pag := 1 

SetPrc( 0,0 )

@ 0,0 PSAY Chr( 15 )
nLin  := 61
QRY->( dbGoTop() )

While ! QRY->( Eof() )

    If nLin > 60

       nLin := Cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,15)
       nLin ++

    End

    @ nLin,00 PSAY QRY->Nota
    @ nLin,09 PSAY QRY->Serie
    @ nLin,13 PSAY QRY->Emissao
    @ nLin,22 PSAY QRY->Cliente
    @ nLin,32 PSAY QRY->Nome
    @ nLin,53 PSAY QRY->Transp
    @ nLin,74 PSAY QRY->Motorista

    nLin ++
    QRY->( dbSkip() )

    IncRegua()

End
QRY->( dbCloseArea() ) 
__Eject()

Ms_Flush()
Set Device To Screen
Set Printer To

If aReturn[5] == 1

   dbcommitAll()
   Ourspool(wnrel)

Endif
                                         
Return()
