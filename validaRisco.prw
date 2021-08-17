#include 'Protheus.ch'

user function validaRisco()

local aArea := getArea()
local lRet  := .T.

if !M->C5_TIPO $ 'DB' .and. M->C5_TESINT = '03'
    
    lRet := IIF(posicione("SA1",1,xFilial("SA1")+M->C5_XCLIRCO+M->C5_XLOJRCO,"A1_RISCO") = "E",.F.,.T.)

    if !lRet
        MSgInfo('Cliente com Risco E não permitido.','Risco E')
    endif

endif

restArea(aArea)

return lRet
