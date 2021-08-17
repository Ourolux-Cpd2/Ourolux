#Include "Totvs.Ch"
#Include "topconn.Ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} PartReserv
Realiza a integraÁao de participantes junto ao reserve.

@author By Wise

@since 30/09/2018
/*/
//-------------------------------------------------------------------

User Function PartReserv(lReprocess, cRegistros, lLote, cIdReg, cIdPZC, aRegistros, lPerfil, cPerfId, lAprov)

Local cQuery        := ""
Local cAlsRD0       := ""
Local aDados        := {}
Local nQtdReg       := 0
Local nX            := 0
Local aCriaServ     := {}
Local aExcecoes     := {}

Local cFirstName    := ""
Local cLastName     := ""
Local aEmpresas     := {}
Local nPosEmp       := 0
Local cDtNasc       := ""
Local aRequest      := {}
Local cIdPZB        := ""
Local cMenssagem    := ""
Local aHeader       := {}
Local cJsoRec       := ""
Local aLogin        := {}
Local cRegProc      := ""
Local oRet          := Nil
Local aErros        := {}
Local nPosErros     := 0
Local cIdReserv     := ""
Local cCodRD0       := ""
Local cCodigo       := ""
Local cPerfil       := ""
Local cPolitica     := ""
Local cVip          := ""
Local cNome         := ""
Local cLoginRes     := ""
Local cSexo         := ""
Local cIdRes        := ""
Local cCPF          := ""
Local cMatricula    := ""
Local cEmail        := ""
Local cFilAtu       := ""
Local cDataNasc     := ""
Local cTipoUser     := ""
Local nEmpTerc      := 0
Local nRecno        := 0
Local cTpLog        := ""
Local cBloqueado    := ""
Local cGrupos       := ""
Local cDepart       := ""
Local cPerPol       := ""
Local cNivelCar     := ""
Local cBanco        := ""
Local cConta        := ""
Local cAgencia      := ""
Local cDocInter     := ""
Local cPassaport    := ""
Local nY
Local aAusentes     := {}
Local aFornec       := {}
Local aRetForn      := {}
Local cPolInt       := ""
Local cPolExt       := ""
Local nA
Local aExcTrue      := {}
Local aExcFalse     := {}
Local lTemIDRes     := .F.
Local cPerExc		:= ""
Local lEmpTerc      := .F.
Local cPerfAut      := ""
Local lEncode       := .F.
Local cSemaforo     := ""
Local lIncRD0		:= ""

Private lIsAprov
Private lIsPerf

Default lReprocess  := .F.
Default cRegistros  := ""
Default lLote       := .F.
Default cIdReg      := ""
Default cIdPZC      := ""
Default aRegistros  := {}
Default lPerfil     := .F.
Default cPerfId     := ""
Default lAprov      := .F.
Default lJob        := .T.

cSemaforo := "U_PartReserv"

RpcSetEnv("00","00001000100")
RpcSetType(3)

If  !LockByName(cSemaforo) 

    If !lJob
        Aviso("Participantes", "Rotina j· est· em execuÁ„o, aguarde finalizaÁ„o", {"Ok"})
   	Else
   		ConOut( "U_PartReserv - Rotina j· est· em execuÁ„o, aguarde finalizaÁ„o.")
    Endif

Else

    lIsAprov    := lAprov
    lIsPerf     := lPerfil

    cAlsRD0     := CriaTrab(Nil,.F.)
    lEncode     := GetMv("TI_VENCODE",,.T.)
    lEmpTerc    := GetMv("TI_USEMTE",,.F.)
    nEmpTerc    := GetMv("TI_EMPTERC",,50)
    cTpLog      := GetMv("TI_TPLGRES",,"E") //E = Email L = Login
    cPerfAut    := GetMv("TI_IDPFAUT",,"3") //Id do perfil de autorizador.
    
    //AlteraÁ„o de perfil altera o perfil para o id passado, criando log no monitor.
    If lPerfil

        cRegProc    := "'" + Alltrim(cRegistros) + "'"

        cQuery := " SELECT RD0_LOGINR, RD0_NOME, RD0_SEXO, RD0_XCCPF, RD0_XMATRH, RD0_EMAIL, RD0_EMAILC, RD0_FILATU, "
        cQuery += " RD0_CODIGO, RD0_DTNASC, RD0_IDRESE, RD0_TIPO, RD0.R_E_C_N_O_ RECNO, "
        cQuery += " PS3_RESATB, PS1_CONATB, PS1_CODIGO, RD0_MSBLQL, PS3_PROP, RD0_XNCARG, RD0_XDCINT, RD0_XPASSP, "
        cQuery += " A2_BANCO, A2_AGENCIA, A2_DVAGE, A2_NUMCON, A2_DVCTA, A2_NOME, A2_CGC, A2_COD, A2_XIDRESE, RD0_DVIAGE, RD0_DTADEM, "
        cQuery += " PS1_CRPLAN, PS1_EDTPLA, PS1_EXCPLA, PS1_ADIANT, PS1_REGDES, PS1_SOLICI, PS1_FAVORE, PS1_SOLAUT, PS1_SOLPAG, "
        cQuery += " PS1_CONFAT, PS1_RESAER, PS1_RESHOT, PS1_RESCAR, PS1_RESROD, PS1_RESSEG, PS1_GRPEMP, PS1_PRPPLA, PS1_PLASOL, PS1_FINAN, PS1_PERFIL "
        cQuery += " FROM " + RetSqlName("RD0") + " RD0 "
        cQuery += " INNER JOIN " + RetSqlName("SA2") + " SA2 "
        cQuery += " ON A2_FILIAL = '" + xFilial("SA2") + "' AND "
        cQuery += " A2_COD = RD0_FORNEC AND A2_LOJA = RD0_LOJA "
        cQuery += " LEFT JOIN " + RetSqlName("PS2") + " PS2 "
        cQuery += " ON PS2_FILIAL = '" + xFilial("PS2") + "' AND "
        cQuery += " PS2_CODPAR = RD0_CODIGO AND PS2.D_E_L_E_T_ = ' ' "
        cQuery += " LEFT JOIN " + RetSqlName("PS1") + " PS1 "
        cQuery += " ON PS1_FILIAL = '" + xFilial("PS1") + "' AND "
        cQuery += " PS1_CODIGO = PS2_CODIGO AND PS1.D_E_L_E_T_ = ' ' "
        cQuery += " LEFT JOIN " + RetSqlName("PS3") + " PS3 "
        cQuery += " ON PS3_FILIAL = '" + xFilial("PS3") + "' AND "
        cQuery += " PS3_CODIGO = PS1_ATRIBU AND PS3.D_E_L_E_T_ = ' ' "
        cQuery += " LEFT JOIN " + RetSqlName("SX5") + " SX5 "
        cQuery += " ON X5_FILIAL = '" + xFilial("SX5") + "' AND "
        cQuery += " X5_TABELA = PS3_SXBX5 AND X5_CHAVE = PS1_CONATB "
        cQuery += " WHERE RD0_FILIAL = '" + xFilial("RD0") + "' AND "
        cQuery += " TRIM(RD0_IDRESE) IN (" + cRegProc + ") AND (RD0_DVIAGE <> '1' OR (RD0_DVIAGE = '1' AND RD0_IDRESE <> ' ')) "
        cQuery += " AND RD0.D_E_L_E_T_ = ' ' AND SA2.D_E_L_E_T_ = ' ' "
        cQuery += " ORDER BY RD0_CODIGO " 
    
    //Se nùo for reprocessamento
    ElseIf !lReprocess

        cQuery := " SELECT RD0_LOGINR, RD0_NOME, RD0_SEXO, RD0_XCCPF, RD0_XMATRH, RD0_EMAIL, RD0_EMAILC, RD0_FILATU, "
        cQuery += " RD0_CODIGO, RD0_DTNASC, RD0_IDRESE, RD0_TIPO, RD0.R_E_C_N_O_ RECNO, "
        cQuery += " PS3_RESATB, PS1_CONATB, PS1_CODIGO, RD0_MSBLQL, PS3_PROP, RD0_XNCARG, RD0_XDCINT, RD0_XPASSP, "
        cQuery += " A2_BANCO, A2_AGENCIA, A2_DVAGE, A2_NUMCON, A2_DVCTA, A2_NOME, A2_CGC, A2_COD, A2_XIDRESE, RD0_DVIAGE, RD0_DTADEM, "
        cQuery += " PS1_CRPLAN, PS1_EDTPLA, PS1_EXCPLA, PS1_ADIANT, PS1_REGDES, PS1_SOLICI, PS1_FAVORE, PS1_SOLAUT, PS1_SOLPAG, "
        cQuery += " PS1_CONFAT, PS1_RESAER, PS1_RESHOT, PS1_RESCAR, PS1_RESROD, PS1_RESSEG, PS1_GRPEMP, PS1_PRPPLA, PS1_PLASOL, PS1_FINAN, PS1_PERFIL "
        cQuery += " FROM " + RetSqlName("RD0") + " RD0 "
        cQuery += " INNER JOIN " + RetSqlName("SA2") + " SA2 "
        cQuery += " ON A2_FILIAL = '" + xFilial("SA2") + "' AND "
        cQuery += " A2_COD = RD0_FORNEC AND A2_LOJA = RD0_LOJA "
        cQuery += " LEFT JOIN " + RetSqlName("PS2") + " PS2 "
        cQuery += " ON PS2_FILIAL = '" + xFilial("PS2") + "' AND "
        cQuery += " PS2_CODPAR = RD0_CODIGO AND PS2.D_E_L_E_T_ = ' ' "
        cQuery += " LEFT JOIN " + RetSqlName("PS1") + " PS1 "
        cQuery += " ON PS1_FILIAL = '" + xFilial("PS1") + "' AND "
        cQuery += " PS1_CODIGO = PS2_CODIGO AND PS1.D_E_L_E_T_ = ' ' "
        cQuery += " LEFT JOIN " + RetSqlName("PS3") + " PS3 "
        cQuery += " ON PS3_FILIAL = '" + xFilial("PS3") + "' AND "
        cQuery += " PS3_CODIGO = PS1_ATRIBU AND PS3.D_E_L_E_T_ = ' ' "
        cQuery += " LEFT JOIN " + RetSqlName("SX5") + " SX5 "
        cQuery += " ON X5_FILIAL = '" + xFilial("SX5") + "' AND "
        cQuery += " X5_TABELA = PS3_SXBX5 AND X5_CHAVE = PS1_CONATB "
        cQuery += " WHERE RD0_FILIAL = '" + xFilial("RD0") + "' AND RD0_RESERV = ' ' AND (RD0_DVIAGE <> '1' OR (RD0_DVIAGE = '1' AND RD0_IDRESE <> ' ')) "
        cQuery += " AND RD0.D_E_L_E_T_ = ' ' AND SA2.D_E_L_E_T_ = ' ' "
        cQuery += " ORDER BY RD0_CODIGO " 
        
    Else

        //Se for processamento de um lote        
        If lLote
        
            For nX := 1 to len(aRegistros)

                cRegProc += "'" + Alltrim(aRegistros[nX][3]) + "',"

            Next nX

            cRegProc := Left(cRegProc, RAT(",", cRegProc) - 1)

        Else

            cRegProc    := "'" + cRegistros + "'"
            cIdPZB      := cIdReg

            //Por ser reprocessamento crio o array com os parametros necessarios
            aCriaServ       := {"",""}
            aCriaServ[1]    := .T.
        
        EndIf
    
        cQuery := " SELECT RD0_LOGINR, RD0_NOME, RD0_SEXO, RD0_XCCPF, RD0_XMATRH, RD0_EMAIL, RD0_EMAILC, RD0_FILATU, "
        cQuery += " RD0_CODIGO, RD0_DTNASC, RD0_IDRESE, RD0_TIPO, RD0.R_E_C_N_O_ RECNO, "
        cQuery += " PS3_RESATB, PS1_CONATB, PS1_CODIGO, RD0_MSBLQL, PS3_PROP, RD0_XNCARG, RD0_XDCINT, RD0_XPASSP, "
        cQuery += " A2_BANCO, A2_AGENCIA, A2_DVAGE, A2_NUMCON, A2_DVCTA, A2_NOME, A2_CGC, A2_COD, A2_XIDRESE, RD0_DVIAGE, RD0_DTADEM, "
        cQuery += " PS1_CRPLAN, PS1_EDTPLA, PS1_EXCPLA, PS1_ADIANT, PS1_REGDES, PS1_SOLICI, PS1_FAVORE, PS1_SOLAUT, PS1_SOLPAG, "
        cQuery += " PS1_CONFAT, PS1_RESAER, PS1_RESHOT, PS1_RESCAR, PS1_RESROD, PS1_RESSEG, PS1_GRPEMP, PS1_PRPPLA, PS1_PLASOL, PS1_FINAN, PS1_PERFIL "
        cQuery += " FROM " + RetSqlName("RD0") + " RD0 "
        cQuery += " LEFT JOIN " + RetSqlName("SA2") + " SA2 "
        cQuery += " ON A2_FILIAL = '" + xFilial("SA2") + "' AND "
        cQuery += " A2_COD = RD0_FORNEC AND A2_LOJA = RD0_LOJA "
        cQuery += " LEFT JOIN " + RetSqlName("PS2") + " PS2 "
        cQuery += " ON PS2_FILIAL = '" + xFilial("PS2") + "' AND "
        cQuery += " PS2_CODPAR = RD0_CODIGO AND PS2.D_E_L_E_T_ = ' ' "
        cQuery += " LEFT JOIN " + RetSqlName("PS1") + " PS1 "
        cQuery += " ON PS1_FILIAL = '" + xFilial("PS1") + "' AND "
        cQuery += " PS1_CODIGO = PS2_CODIGO AND PS1.D_E_L_E_T_ = ' ' "
        cQuery += " LEFT JOIN " + RetSqlName("PS3") + " PS3 "
        cQuery += " ON PS3_FILIAL = '" + xFilial("PS3") + "' AND "
        cQuery += " PS3_CODIGO = PS1_ATRIBU AND PS3.D_E_L_E_T_ = ' ' "
        cQuery += " LEFT JOIN " + RetSqlName("SX5") + " SX5 "
        cQuery += " ON X5_FILIAL = '" + xFilial("SX5") + "' AND "
        cQuery += " X5_TABELA = PS3_SXBX5 AND X5_CHAVE = PS1_CONATB "
        cQuery += " WHERE RD0_FILIAL = '" + xFilial("RD0") + "' AND "
        cQuery += " RD0_CODIGO IN (" + cRegProc + ") AND (RD0_DVIAGE <> '1' OR (RD0_DVIAGE = '1' AND RD0_IDRESE <> ' ')) " 
        cQuery += " AND RD0.D_E_L_E_T_ = ' ' AND SA2.D_E_L_E_T_ = ' ' " 
        cQuery += " ORDER BY RD0_CODIGO " 

    EndIf

    If Select(cAlsRD0) > 0; (cAlsRD0)->(dbCloseArea()); Endif  
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlsRD0,.T.,.T.)

    If !(cAlsRD0)->(Eof())
        
        While !(cAlsRD0)->(Eof())

            //Zera array de exceùùes.
            aExcecoes   := {}
            cLoginRes   := IIf(cTpLog == "E", (cAlsRD0)->RD0_EMAIL, (cAlsRD0)->RD0_LOGINR)
            cLoginRes   := Lower(cLoginRes)

            //Se o fornecedor nùo tiver sido integrado ainda.
            If Empty( (cAlsRD0)->A2_XIDRESE )
                
                //Monta array com os dados de fornecedores
                AADD(aFornec, { (cAlsRD0)->A2_NOME                  ,;
                                (cAlsRD0)->A2_CGC                   ,;
                                (cAlsRD0)->(A2_AGENCIA + A2_DVAGE)  ,;
                                (cAlsRD0)->(A2_NUMCON + A2_DVCTA)   ,;
                                (cAlsRD0)->A2_COD                   })

            EndIf

            //Se nùo tiver exceùùo cadastrada
            If Empty( (cAlsRD0)->PS1_CODIGO )
            
                AADD(aDados, {  cLoginRes                                               ,; //Login de acesso 01
                                (cAlsRD0)->RD0_NOME                                     ,; //Nome participante 02
                                (cAlsRD0)->RD0_SEXO                                     ,; //Sexo 03
                                Alltrim((cAlsRD0)->RD0_IDRESE)                          ,; //IDRESERV 04
                                (cAlsRD0)->RD0_XCCPF                                    ,; //CPF 05
                                (cAlsRD0)->RD0_CODIGO                                   ,; //Nùmero de matrùcula  RD0_XMATRH 06
                                Lower( (cAlsRD0)->RD0_EMAIL)                            ,; //Email 07
                                (cAlsRD0)->RD0_FILATU                                   ,; //Filial 08
                                (cAlsRD0)->RD0_DTNASC                                   ,; //Data de nascimento 09
                                (cAlsRD0)->RD0_CODIGO                                   ,; //Codigo RD0 10
                                (cAlsRD0)->RECNO                                        ,; //Recno RD0 11
                                {}                                                      ,; //Usuùrio com exceùùo?  12
                                (cAlsRD0)->RD0_TIPO                                     ,; //Tipo usuario - Interno, Externo. 13
                                (cAlsRD0)->RD0_MSBLQL                                   ,; //Usuario ativo - 1= Nao 2= Sim 14
                                (cAlsRD0)->RD0_XNCARG                                   ,; //Nivel de cargo 15
                                (cAlsRD0)->A2_BANCO                                     ,; //Codigo banco 16
                                Alltrim( (cAlsRD0)->A2_AGENCIA) + (cAlsRD0)->A2_DVAGE   ,; //Codigo agencia 17
                                Alltrim( (cAlsRD0)->A2_NUMCON)  + (cAlsRD0)->A2_DVCTA   ,; //Codigo conta 18
                                (cAlsRD0)->RD0_XDCINT                                   ,; //Doc internacional 19
                                (cAlsRD0)->RD0_XPASSP                                   ,; //Passaporte. 20
                                (cAlsRD0)->A2_XIDRESE                                   ,; //Id Reserve Fornecedor 21
                                (cAlsRD0)->A2_COD                                       ,; //Codigo fornecedor 22
                                (cAlsRD0)->RD0_DVIAGE                                   ,; //Indica se o participante viaja. 23
                                (cAlsRD0)->RD0_DTADEM                                   ,; //Data de demissùo. 24
                                Lower( (cAlsRD0)->RD0_EMAILC)                           }) //Email Comercial 25

                (cAlsRD0)->(DbSkip())

            //Se tiver faz um novo laùo por conta de trazer varias linhas nos casos de varias politicas.
            Else

                cCodRD0 := (cAlsRD0)->RD0_CODIGO 

                While !(cAlsRD0)->(Eof())

                    //Exceùùes inseridas para o usuùrio.
                    AADD(aExcecoes, {   (cAlsRD0)->PS3_RESATB   ,;
                                        (cAlsRD0)->PS1_CONATB   ,; 
                                        (cAlsRD0)->PS3_PROP     ,;
                                        {"PS1_CRPLAN", (cAlsRD0)->PS1_CRPLAN    },; 
                                        {"PS1_EDTPLA", (cAlsRD0)->PS1_EDTPLA    },; 
                                        {"PS1_EXCPLA", (cAlsRD0)->PS1_EXCPLA    },; 
                                        {"PS1_ADIANT", (cAlsRD0)->PS1_ADIANT    },; 
                                        {"PS1_REGDES", (cAlsRD0)->PS1_REGDES    },; 
                                        {"PS1_SOLICI", (cAlsRD0)->PS1_SOLICI    },; 
                                        {"PS1_FAVORE", (cAlsRD0)->PS1_FAVORE    },; 
                                        {"PS1_SOLAUT", (cAlsRD0)->PS1_SOLAUT    },; 
                                        {"PS1_SOLPAG", (cAlsRD0)->PS1_SOLPAG    },;
                                        {"PS1_CONFAT", (cAlsRD0)->PS1_CONFAT    },; 
                                        {"PS1_RESAER", (cAlsRD0)->PS1_RESAER    },; 
                                        {"PS1_RESHOT", (cAlsRD0)->PS1_RESHOT    },; 
                                        {"PS1_RESCAR", (cAlsRD0)->PS1_RESCAR    },; 
                                        {"PS1_RESROD", (cAlsRD0)->PS1_RESROD    },;  
                                        {"PS1_RESSEG", (cAlsRD0)->PS1_RESSEG    },; 
                                        {"PS1_GRPEMP", (cAlsRD0)->PS1_GRPEMP    },; 
                                        {"PS1_PRPPLA", (cAlsRD0)->PS1_PRPPLA    },; 
                                        {"PS1_PLASOL", (cAlsRD0)->PS1_PLASOL    },; 
                                        {"PS1_FINAN" , (cAlsRD0)->PS1_FINAN     },;
                                        {"PS1_PERFIL", (cAlsRD0)->PS1_PERFIL    } })

                    //Como o registro vai mudar guardo as informaùùes
                    cCodigo     := (cAlsRD0)->RD0_CODIGO
                    cNome       := (cAlsRD0)->RD0_NOME
                    cSexo       := (cAlsRD0)->RD0_SEXO
                    cIdRes      := Alltrim((cAlsRD0)->RD0_IDRESE)
                    cCPF        := (cAlsRD0)->RD0_XCCPF 
                    cMatricula  := (cAlsRD0)->RD0_CODIGO //(cAlsRD0)->RD0_XMATRH
                    cEmail      := Lower( (cAlsRD0)->RD0_EMAIL)
                    cFilAtu     := (cAlsRD0)->RD0_FILATU 
                    cDataNasc   := (cAlsRD0)->RD0_DTNASC
                    nRecno      := (cAlsRD0)->RECNO
                    cTipoUser   := (cAlsRD0)->RD0_TIPO
                    cBloqueado  := (cAlsRD0)->RD0_MSBLQL      
                    cNivelCar   := (cAlsRD0)->RD0_XNCARG
                    cBanco      := (cAlsRD0)->A2_BANCO    
                    cAgencia    := Alltrim( (cAlsRD0)->A2_AGENCIA) + (cAlsRD0)->A2_DVAGE
                    cConta      := Alltrim( (cAlsRD0)->A2_NUMCON) + (cAlsRD0)->A2_DVCTA
                    cDocInter   := (cAlsRD0)->RD0_XDCINT                                  
                    cPassaport  := (cAlsRD0)->RD0_XPASSP
                    cIdResFor   := (cAlsRD0)->A2_XIDRESE 
                    cCodFor     := (cAlsRD0)->A2_COD           
                    cDViag      := (cAlsRD0)->RD0_DVIAGE         
                    cDatDem     := (cAlsRD0)->RD0_DTADEM        
                    cEmailC     := Lower( (cAlsRD0)->RD0_EMAILC)           

                    (cAlsRD0)->(DbSkip())

                    //Se mudou o usuùrio sai do looping
                    If cCodRD0 <> (cAlsRD0)->RD0_CODIGO
                        
                        Exit

                    EndIf
                
                End

                AADD(aDados, {  cLoginRes   ,; //Login de acesso
                                cNome       ,; //Nome participante
                                cSexo       ,; //Sexo
                                cIdRes      ,; //IDRESERV
                                cCPF        ,; //CPF
                                cMatricula  ,; //Nùmero de matrùcula
                                cEmail      ,; //Email
                                cFilAtu     ,; //Filial
                                cDataNasc   ,; //Data de nascimento
                                cCodigo     ,; //Codigo RD0
                                nRecno      ,; //Recno
                                aExcecoes   ,; //Usuùrio com exceùùo? 
                                cTipoUser   ,; //Tipo usuario - Interno, Externo.
                                cBloqueado  ,; //Usuario ativo - 1= Nao 2= Sim
                                cNivelCar   ,; //Nivel do cargo
                                cBanco      ,; //Codigo banco
                                cAgencia    ,; //Codigo agencia
                                cConta      ,; //Codigo conta.
                                cDocInter   ,; //Documento internacional
                                cPassaport  ,; //Passaporte
                                cIdResFor   ,; //Id Reserve Fornecedor
                                cCodFor     ,; //Codigo fornecedor
                                cDViag      ,; //Indica se o participante viaja.
                                cDatDem     ,; //Data de demissùo.
                                cEmailC     }) //Email Comercial

            EndIf
                
        End

        //Se tiver fornecedores para integrar.
        If len(aFornec) > 0
            
            aRetForn := U_ResIntForn(aFornec)

        EndIf

        nQtdReg := Len(aDados)

        //Consumo a funùùo que gera o acesso com o reserve e retorna o token
        aLogin := U_GerAcessRes()
        
        //Cria o log do serviùo no monitor
        If !lReprocess .Or. (lReprocess .And. lLote)
            
            aCriaServ := U_MonitRes("000003", 1, nQtdReg)

            //Id gerado na criaùùo do serviùo
            cIdPZB := aCriaServ[2]

        EndIf

        //Requisiùùo de acesso ao reserve. 
        If !aLogin[1]
            //Finaliza o processo na PZB
            U_MonitRes("000003", 3, , cIdPZB, , .F.,,,,,,,,,.T.)
            Return()
        Else
            cToken := aLogin[2]
        EndIf       
                
        //Lista de empresas do reserve
        aEmpresas := U_GetEmpRes()

        If aEmpresas[1]

            DbSelectArea("RD0")
            
            //Se a linha do log foi criada com sucesso
            If aCriaServ[1]

                //Inicia o processo de integraùùo com o reserve
                For nX := 1 to len(aDados)
                    
                    //Como as variaveis de aprovadores sùo setadas agora, verifico se a chamada da funùùo ù para troca de perfil
                    //Se for volto o conteudo das variavel, caso contrario sempre fica falso.
                    If lPerfil
                        lIsAprov    := lAprov
                        lIsPerf     := lPerfil
                    Else
                        lIsAprov    := .F.
                        lIsPerf     := .F.
                    EndIf
                    
                    //Se for alteraùùo verifica se ù aprovador para setar as variaveis de autorizador.
                    If !Empty(aDados[nX][4])
                        
                        lVrfAut := fVrfAut(aDados[nX][4])

                        If lVrfAut
                            lIsPerf     := .T.
                            lIsAprov    := .T.
                        EndIf

                    EndIf

					// Variavel para controle de inclus„o. Setada com False para tratamento da regra de terceiro.
					lIncRD0		:= .F.
					
                    cFirstName  := Substr(aDados[nX][2], 1, At(" ", aDados[nX][2]) - 1 )
                        
                    cLastName   := Alltrim(Substr(aDados[nX][2], RAt(" ", Alltrim(aDados[nX][2])) + 1, 30  ))
                        
                    cDtNasc := Left( aDados[nX][9], 4) + "-" + Substr( aDados[nX][9], 5, 2) + "-" + Right( aDados[nX][9], 2)
                    cDtNasc += "T03:00:00.000Z"

                    //Fixando a matriz para o caso da filial estar em branco.
                    If Empty(aDados[nX][8])
                        aDados[nX][8] := "00001000100"
                    EndIf

                    nPosEmp := aScan(aEmpresas[2], {|x| Alltrim(x[4]) == aDados[nX][8]})
                    
                    //Chave da tabela
                    cChave  := aDados[nX][10] 
                    
                    //Verifica se tem ID Reserve
                    lTemIDRes := !Empty(aDados[nX][4]) 

                    //Zera o Header para nùo duplicar informaùùes
                    aHeader := {} 

                    //Posiciona no registro da RD0
                    RD0->(DbGoTo(aDados[nX][11]))

                    If (nPosEmp > 0 .And. aDados[nX][13] == "1") .Or. aDados[nX][13] == "2"

                        AADD(aHeader, "SecurityToken:" + cToken )
                        AADD(aHeader, "Content-Type: application/json")

                        cJson := '{'
                        
                        //Se for alteraùùo acrescenta o ID.
                        If !Empty(aDados[nX][4])
                            cJson += '"id":' + aDados[nX][4] + ','
                        Else
                            cJson += '"login":"'            + Alltrim(aDados[nX][1])                + '",'
                        EndIf

						// Caso seja terceiro e inclus„o 
						If aDados[nX][13] == "2" .And. Empty(aDados[nX][4])
                        	lIncRD0 := .T.
						Endif 

                        cJson += '"nome":"'             + Alltrim(aDados[nX][2])                + '",'
                        cJson += '"primeiroNome":"'     + cFirstName                            + '",'
                        cJson += '"sobrenome":"'        + cLastName                             + '",'
                        
						// trata o genero (sexo) do participantes
						If Alltrim(Upper(aDados[nX][3])) == "M"
							cJson += '"sexo":"Masculino",'
						Else
							cJson += '"sexo":"Feminino",'
						Endif                        
                        	
                        
                        //Se tiver documento internacional.
                        If !Empty(aDados[nX][19])
                            cJson += '"rg":"' + Alltrim(aDados[nX][19]) + '",'
                        Else
                            cJson += '"cpf":"' + Alltrim(aDados[nX][5]) + '",'
                        EndIf

                        //Se tiver passaporte
                        If !Empty(aDados[nX][20])
                            cJson += '"passaporte":"' + Alltrim(aDados[nX][20]) + '",'
                        EndIf

                        If !Empty(aDados[nX][25])
                            cEmailC := ';' + Alltrim(aDados[nX][25])
                        Else
                            cEmailC := ""
                        EndIf

                        cJson += '"matricula":"'        + Alltrim(aDados[nX][6])              + '",'                            
                        cJson += '"email":"'            + Alltrim(aDados[nX][7])              + '",'
                        cJson += '"empresa":{'
                        
                        //Se nùo for terceiro ou uso da epresa de terceiro estiver desativado.
                        If !aDados[nX][13] == "2" .Or. !lEmpTerc
                            cJson += '"id":'                + cValToChar(aEmpresas[2][nPosEmp][1])  + '},'
                        Else
                            cJson += '"id":' + cValToChar(nEmpTerc) + '},'
                        EndIf

                        cJson += '"dataNascimento":"'   + cDtNasc                               + '",'
                        cJson += '"nacionalidade": {'
                        cJson += '"codigo": "BR",'
                        cJson += '"nome": "Brasil"'
                        cJson += '}'

                        //Trata o departamento.
                        If aDados[nX][13] == "1"
                            cPerfId := "16"//"10"
                        Else
                            cPerfId := "11"//"11"
                        EndIf

                        cJson += ','
                        cJson += '"departamento":{'
                        cJson += '"id":' + cPerfId + '}'
                        
                        //Se for vazio acrescenta o campo do VIP.
                        If Empty(aDados[nX][12]) 
                            cJson += ',"tipoPax":0'
                        EndIf 

                        //Caso o cargo esteja preenchido busca a regra por nùvel de cargo
                        If !Empty(aDados[nX][15])
                            cJson += fNvlVsCarg(aDados[nX][15], aDados[nX][13])
                        Else
                            cJson += fPolDef(aDados[nX][13])
                        EndIf

                        //Forùa variaveis como vazio para o caso de nùo ter exceùùo vinculado
                        aExcTrue    := {}
                        aExcFalse   := {}
                        
                        //Se tiver exceùùes    
                        If !Empty(aDados[nX][12]) 

                            aExcecoes   := aDados[nX][12]
                            cGrupos     := ""
                            cVip        := ""
                            cDepart     := ""
                            cPerPol     := ""
                            aGrpBkp     := {}
                            aExcTrue    := {}
                            aExcFalse   := {}
                            oJsoAux     := Nil

                            //Adiciona os true.
                            For nA := 1 to len(aDados[nX][12])

                                //For para guardar todos itens que forem True.
                                For nY := 1 to len(aDados[nX][12][nA])

                                    If ValType(aDados[nX][12][nA][nY]) == "A"
                                        
                                        //Sù adicionar se o item ainda nùo existe no array de verdadeiros.
                                        If aDados[nX][12][nA][nY][2] == "T" .And. aScan(aExcTrue, {|x| Alltrim(x[1]) == aDados[nX][12][nA][nY][1] }) == 0
                                            AADD(aExcTrue, { aDados[nX][12][nA][nY][1], aDados[nX][12][nA][nY][2] } )
                                        EndIf

                                    EndIf

                                Next nY

                            Next nA

                            //Adiciona os falsos.
                            For nA := 1 to len(aDados[nX][12])
                            
                                //For para criar array dos itens false
                                For nY := 1 to len(aDados[nX][12][nA])

                                    If ValType(aDados[nX][12][nA][nY]) == "A"

                                        //Sù pode adicionar se o item nùo existir no array de verdadeiros e tambùm nùo existir no de falso para nùo duplicar.
                                        If aDados[nX][12][nA][nY][2] == "F" .And. aScan(aExcFalse, {|x| Alltrim(x[1]) == aDados[nX][12][nA][nY][1] }) == 0 ;
                                            .And. aScan(aExcTrue, {|x| Alltrim(x[1]) == aDados[nX][12][nA][nY][1] }) == 0
                                            
                                            AADD(aExcFalse, { aDados[nX][12][nA][nY][1], aDados[nX][12][nA][nY][2] } )

                                        EndIf

                                    EndIf

                                Next nY

                            Next nA

							// Caso n„o seja aprovador, define perfil conforme regra independentemente de exceÁıes cadastradas.
							If !lIsPerf
                  
	                            //Trata o perfil de acesso, fica valido a ultima exceùùo que possui perfil preenchido.
	                            For nA := 1 to len(aDados[nX][12])
	                            
	                                //For para criar array dos itens false
	                                For nY := 1 to len(aDados[nX][12][nA])
	
	                                    If ValType(aDados[nX][12][nA][nY]) == "A"
	
	                                        If Alltrim(aDados[nX][12][nA][nY][1]) == "PS1_PERFIL"
	
	                                            If !Empty(Alltrim(aDados[nX][12][nA][nY][2]))
	                                                cPerExc := ','
	                                                cPerExc += '"perfilAcesso":{'
	                                                cPerExc += '"id":' + Alltrim( aDados[nX][12][nA][nY][2] ) + '}    
	                                            EndIf
	
	                                        EndIf
	
	                                    EndIf
	
	                                Next nY
	
	                            Next nA
	                        
	                        Endif

                            FWJsonDeserialize(cJson + "}",@oJsoAux)

                            //Elimina todos campos que sùo tratados como flag quando for alteraùùo
                            If lTemIDRes
	                            If Len(aExcTrue) > 0 .Or. Len(aExcFalse) > 0
	                                oJsoAux := fExcFlags(oJsoAux)
	                            EndIf
	                        EndIf

                            //Guarda os grupos que estùo vinculados a niveis vs cargo.
                            If ValType(oJsoAux:Grupos) == "A"
                            
                                For nA := 1 to len(oJsoAux:Grupos)

                                    cIdSubs := fVrfSX5(cValToChar(oJsoAux:Grupos[nA]:Id))

                                    If !Empty(cIdSubs)
                                        
                                        nPosExc := aScan(aExcecoes, {|X| Alltrim(x[2]) == cIdSubs })

                                        If nPosExc > 0
                                            oJsoAux:Grupos[nA]:Id := Nil
                                        Else
                                            AADD(aGrpBkp, cValToChar(oJsoAux:Grupos[nA]:Id ))
                                        EndIf
                                    
                                    Else
                                        AADD(aGrpBkp, cValToChar(oJsoAux:Grupos[nA]:Id ))
                                    EndIf

                                Next nA

                            EndIf


                            For nY := 1 to len(aExcecoes)

                                If Alltrim(UPPER(aExcecoes[nY][1])) == "GRUPOS"
                                
                                    If Empty(cGrupos)
                                        
                                        oJsoAux:Grupos := Nil

                                        cRet := FWJsonSerialize(oJsoAux,.F.,.T.)
                                        cJson := Left(cRet, RAT("}", cRet) - 1)

                                        cGrupos := ','
                                        cGrupos += '"grupos":[{"id":' +  Alltrim(aExcecoes[nY][2]) + '}'

                                        For nA := 1 to len(aGrpBkp)

                                            cGrupos += ','
                                            cGrupos += '{"id":' +  aGrpBkp[nA] + '}'
                                        
                                        Next nA
                                        
                                    Else
                                        cGrupos += ','
                                        cGrupos += '{"id":' +  Alltrim(aExcecoes[nY][2]) + '}'
                                    EndIf

                                ElseIf Alltrim(UPPER(aExcecoes[nY][1])) == "TIPOPAX"

                                    cVip := ','
                                    cVip += '"tipoPax":' + Alltrim(aExcecoes[nY][2])

                                ElseIf Alltrim(UPPER(aExcecoes[nY][1])) == "DEPARTAMENTO"

                                    cDepart := ','
                                    cDepart += '"departamento":{"id":' + Alltrim(aExcecoes[nY][2]) + '}'

                                ElseIf Alltrim(UPPER(aExcecoes[nY][1])) == "PERFILPOLITICA"

                                    cPerPol := ','
                                    cPerPol += '"perfilPolitica":{"id":' + Alltrim(aExcecoes[nY][2]) + '}'

                                EndIf

                            Next nY

                            //Se tiver exceùo para grupos
                            If !Empty(cGrupos)
                                cGrupos += "]"
                                cJson   += cGrupos
                            EndIf

                            //Se tiver exceùo para VIP
                            If !Empty(cVip)
                                cJson += cVip
                            EndIf

                            //Se tiver exceùo para deparmaento
                            If !Empty(cDepart)
                                cJson += cDepart
                            EndIf

                            //Se tiver exceùo para perfil politica
                            If !Empty(cPerPol)
                                cJson += cPerPol
                            EndIf
                            
                            //Se tiver perfil de acesso
                            If !Empty(cPerExc)
                                cJson += cPerExc
                            EndIf
                            
                        EndIf

                        //Verifica se o ultimo caracter ficou na virgula e remove.
                        If Len(cJson) == RAT(",", cJson)
                            cJson := Left(cJson, RAT(",", cJson) - 1)
                        EndIf

                        //Dados bancarios
                        cJson += ','
                        cJson += '"contaBancaria": {'
                        cJson += '"tipo":"ContaCorrente",' 
                        cJson += '"banco":"' + aDados[nX][16] +'",' 
                        cJson += '"agencia":"' + aDados[nX][17] + '",' 
                        cJson += '"conta":"' + aDados[nX][18] + '"}'

                        //Tag de controle de terceiros.
                        cTerceiros := fCenTerc(aDados[nX][10],aDados[nX][13])

                        If !Empty(cTerceiros)
                            cJson += ','
                            cJson += cTerceiros
                        EndIf
                        
                        // Caso seja terceiro, garante que ser· o centralizador dele mesmo.
                        If !Empty(aDados[nX][4]) .And. Empty(cTerceiros) .And. aDados[nX][13] == "2"
                        	cJson += ','
                        	cJson += '"favorecidos": ['
				            cJson += '{'
				            cJson += '"item1":' + Alltrim(aDados[nX][4])
				            cJson += '}]'
				        EndIf
                        
                        //Se o ID do forncedor ja vir na query.
                        If !Empty(aDados[nX][21])
                            cIdFor := Alltrim(aDados[nX][21])
                        Else
                            
                            nPosFor := aScan(aRetForn, {|x| Alltrim(x[1]) == Alltrim(aDados[nX][22])})

                            If nPosFor > 0
                                cIdFor := Alltrim(aRetForn[nPosFor][6])
                            Else
                                cIdFor := ""
                            EndIf

                        EndIf

                        If !Empty(cIdFor)
                            cJson += ',"fornecedor":{'
                            cJson += '"id":' + cIdFor + '' 
                            /*cJson += '"nome":"sdfasdfs",
                            cJson += '"cnpj":"123412341234",
                            cJson += '"agencia":"123",
                            cJson += '"conta":"123421",
                            cJson += '"modelo":"FaturaEletronicaDeCartaoPCard"*/
                            cJson += '}'
                        EndIf

                        //Se for vazio a data de demissùo e estiver bloqueado.
                        If Empty(aDados[nX][24]) .And. aDados[nX][14] == "1"
                            cJson += ',"ausente":true'
                        Else
                            cJson += ',"ausente":false'
                        EndIf

                        cJson += '}'
                        
                        //Trata os parametros via flag
                        If Len(aExcTrue) > 0 .Or. Len(aExcFalse) > 0
                            
                            cJson := Left(cJson, RAT("}", cJson) - 1)
                            
                            cJson := fInclFlags(cJson, aExcTrue, aExcFalse)

                            cJson += '}'   

                        EndIf

                        //Se for alteraùùo trata via get para substituir dados.
                        If !Empty(aDados[nX][4])

                            aAuxReq := aRequest := U_ResInteg("000003", cJson, aHeader,, .T., "/" + aDados[nX][4], 2)

                            If aAuxReq[1]

                                oJson := aRequest[2]

                                //Remove as tags de array
                                cJsonAux    := fTratObj(oJson, aExcTrue, aExcFalse)

                                //cJsonAux    := aAuxReq[3]
                                cJsonAux    := Left(cJsonAux, RAT("}", cJsonAux) - 1)   
                                cJson       := Substr(cJson, AT("{", cJson) + 1, Len(cJson) )
                                
                                If lEncode
	                                If EncodeUTF8(cJson) <> Nil
	                                    cJson := EncodeUTF8(cJson)
	                                EndIf        
								Endif
								                                
                                cJsonAux    += ',' + cJson
                                cJson       := cJsonAux
                                
                            EndIf
						Else
							
							If lEncode
								If EncodeUTF8(cJson) <> Nil
	                                cJson := EncodeUTF8(cJson)
	                          	EndIf      
	                        Endif
	                        
                        EndIf

                        //Realiza requisiùùo para deletar usuùrio, incluir ou exlcuir.
                        If aDados[nX][14] == "2" .And. aDados[nX][23] <> "1" .Or. (Empty(aDados[nX][24]) .And. aDados[nX][14] == "1")
                            aRequest := U_ResInteg("000003", cJson, aHeader,, .T.)        
                        Else    
                            aRequest := U_ResInteg("000003", cJson, aHeader,, .T., "/" + aDados[nX][4], 3)
                        EndIf
                        
                        //Retorno em forma de objeto
                        oRet     := aRequest[2]

                        //Retorno em forma de string
                        cJsoRec := aRequest[3]

                        If aRequest[1]
                                
                            If Empty(aDados[nX][4])
                                cIdReserv   := cValToChar(oRet:Id)
                                cMenssagem  := "Incluido com sucesso."
                            Else
                                
                                If aDados[nX][14] == "2" .And. aDados[nX][23] <> "1" .Or. (Empty(aDados[nX][24]) .And. aDados[nX][14] == "1")
                                    cMenssagem  := "Alterado com sucesso."
                                Else
                                    cMenssagem  := "Suspenso com sucesso."
                                EndIf

                            EndIf
                                
                            U_MonitRes("000003", 2, , cIdPZB, cMenssagem, .T., cChave, cJson, cJsoRec, aDados[nX][2], lReprocess, lLote, cIdPZC)

                            RD0->(RecLock("RD0",.F.))

                                RD0->RD0_XSELFB := "4" //Sincronizado
                                
                                //Se for inclus„o de externo, n„o grava o flag de integrado. O flag somente ser· gravado caso seja alteraÁ„o
                                If !lIncRD0
                                	RD0->RD0_RESERV := "1" //Flag no campo do reserve
                                EndIf
                                
                                //Se for inclusùo de registro.
                                If Empty(aDados[nX][4])
                                    RD0->RD0_IDRESE := Alltrim(cIdReserv)
                                EndIf

                            RD0->(MsUnlock())

                        Else

                            //Inclusùo ou alteraùùo.
                            If aDados[nX][14] == "2"
                                
                                //Verficia se retornou o array de erros, caso contrario pega a primeira mensagem
                                If ValType(oRet) == "O"    
                                    
                                    aErros := ClassDataArr(oRet)
                                    
                                    nPosErros := aScan(aErros, {|x| UPPER(Alltrim(x[1])) == "ERRORS" })

                                    If nPosErros > 0
                                        cMenssagem  := oRet:ERRORS[1]:MESSAGE[1]
                                    Else
                                        cMenssagem  := oRet:MESSAGE
                                    EndIf
                                
                                Else
                                    cMenssagem := "Falha ao tratar retorno do erro."    
                                EndIf
                                
                            //Delete
                            Else

                                //Verficia se retornou o array de erros, caso contrario pega a primeira mensagem
                                If ValType(oRet) == "O"    
                                    
                                    aErros := ClassDataArr(oRet)
                                    
                                    nPosErros := aScan(aErros, {|x| UPPER(Alltrim(x[1])) == "ERRORS" })

                                    If nPosErros > 0
                                        cMenssagem  := oRet:ERRORS[1]:MESSAGE[1]
                                    Else
                                        cMenssagem  := oRet:MESSAGE
                                    EndIf
                                
                                Else
                                    cMenssagem := "Falha ao tratar retorno do erro."    
                                EndIf
								
                            EndIf

                            U_MonitRes("000003", 2, , cIdPZB, cMenssagem, .F., cChave, cJson, cJsoRec, aDados[nX][2], lReprocess, lLote, cIdPZC)

                            RD0->(RecLock("RD0",.F.))

                                RD0->RD0_XSELFB := "5" //Erro na sincronizaùùoa

                            RD0->(MsUnlock())
                        EndIf

                    Else
                        cMenssagem := "Nao foi encontrado id de empresa no reserve para o codigo da filial preenchida na RD0."
                        U_MonitRes("000003", 2, , cIdPZB, cMenssagem, .F., cChave, , , aDados[nX][2], lReprocess, lLote, cIdPZC)

                        RD0->(RecLock("RD0",.F.))

                            RD0->RD0_XSELFB := "5" //Erro na sincronizaùùoa

                        RD0->(MsUnlock())
                    EndIf

                Next nX

                //Finaliza o processo na PZB
                U_MonitRes("000003", 3, , cIdPZB, , .T.)

            EndIf

        Else
            cMenssagem := aEmpresas[2]
            //Finaliza o processo na PZB
            U_MonitRes("000003", 3, , cIdPZB, cMenssagem, .T.)
        EndIf
    
    //Cria log com dados zerados.
    Else

        aCriaServ := U_MonitRes("000003", 1, nQtdReg)

        //Id gerado na criaùùo do serviùo
        cIdPZB := aCriaServ[2]

        U_MonitRes("000003", 3, , cIdPZB, , .T.)

    EndIf

    (cAlsRD0)->(dbCloseArea())
    
Endif 
    
UnlockByName(cSemaforo)

Return()


//------------------------------------------------------------------------
/*/{Protheus.doc} ChangePart
Realiza a consulta do perfil do participante, permitindo assim a mudanùa
do mesmo caso necessario.

@author By Wise

@since 30/09/2018
/*/
//-----------------------------------------------------------------------

User Function ChangePart(cIdRes, lChange, cIdPerf)

Local cQuery    := ""
Local cAlsRD0   := ""
Local aRet      := {"",""}
Local aLogin    := {}
Local aRequest  := {}
Local aHeader   := {}
Local cToken    := ""

Default cIdRes  := ""
Default lChange := .F.
Default lAdmin  := .F.
Default lUser   := .F.

    RpcSetEnv("00","00001000100")
    RpcSetType(3)

    cAlsRD0 := CriaTrab(Nil,.F.)

    cQuery := " SELECT RD0_LOGINR, RD0_NOME, RD0_SEXO, RD0_XCCPF, RD0_XMATRH, RD0_EMAIL, RD0_FILATU, "
    cQuery += " RD0_CODIGO, RD0_DTNASC, RD0_IDRESE, RD0_TIPO, RD0.R_E_C_N_O_ RECNO, "
    cQuery += " PS1_VIP, PS2_POLITI, PS3_GRUPO, PS1_CODIGO, PS1_PERFIL "
    cQuery += " FROM " + RetSqlName("RD0") + " RD0 "
    cQuery += " LEFT JOIN " + RetSqlName("PS1") + " PS1 "
    cQuery += " ON PS1_FILIAL = '" + xFilial("PS1") + "' AND "
    cQuery += " PS1_CODIGO = RD0_CODIGO AND PS1.D_E_L_E_T_ = ' ' "
    cQuery += " LEFT JOIN " + RetSqlName("PS2") + " PS2 "
    cQuery += " ON PS2_FILIAL = '" + xFilial("PS2") + "' AND "
    cQuery += " PS2_CODIGO = PS1_CODIGO AND PS2.D_E_L_E_T_ = ' ' "
    cQuery += " LEFT JOIN " + RetSqlName("PS3") + " PS3 "
    cQuery += " ON PS3_FILIAL = '" + xFilial("PS3") + "' AND "
    cQuery += " PS3_CODIGO = PS1_CODIGO AND PS3.D_E_L_E_T_ = ' ' "
    cQuery += " WHERE RD0_FILIAL = '" + xFilial("RD0") + "' AND "
    cQuery += " RD0_IDRESE = '" + cIdRes + "' AND RD0.D_E_L_E_T_ = ' ' " 

    If Select(cAlsRD0) > 0; (cAlsRD0)->(dbCloseArea()); Endif  
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlsRD0,.T.,.T.)

    If (cAlsRD0)->(Eof())
        aRet[1] := .F.
        aRet[2] := "Nao foi encontrado na base o id reserve passado."
    Else
        
        //Consumo a funùùo que gera o acesso com o reserve e retorna o token
        aLogin := U_GerAcessRes()
        
        //Requisiùùo de acesso ao reserve. 
        If !aLogin[1]
            aRet[1] := .F.
            aRet[2] := "Falha ao realizar login junto ao Reserve."
        Else 
            cToken := aLogin[2]
            AADD(aHeader, "Content-Type:application/json")
            AADD(aHeader, "SecurityToken:" + cToken )
        EndIf

        //Se mandar fazer a alteraùùo ja envia direto a alteraùao, caso contrario verifica os planos.
        If lChange
            U_PartReserv(, (cAlsRD0)->RD0_CODIGO, , , , , .T., cIdPerf)
            aRet[1] := .T.
            aRet[2] := "Registro solicitado com sucesso, conferir monitor de integracoes."
        Else
            aRequest := U_ResInteg("000003", , aHeader, , .T., "/" + cIdRes, 2)
            aRet[1] := .T.
            aRet[2] := aRequest[2]
        EndIf

    EndIf

    (cAlsRD0)->(dbCloseArea())
    
Return(aRet)


//------------------------------------------------------------------------
/*/{Protheus.doc} fCenTerc
Veriica se o usuùrio ù centralizador de terceiros, para poder montar
quem esta abaixo dele.

@author By Wise

@since 14/11/2018
/*/
//-----------------------------------------------------------------------
Static Function fCenTerc(cCodRD0,cTipoUser)

Local cQuery    := ""
Local cAlsTer   := CriaTrab(Nil,.F.)
Local cRet      := ""
Local nCount    := 1

Default cTipoUser := "1"

    cQuery := " SELECT"+CRLF
    cQuery += "     RD0_IDRESE,"+CRLF
    cQuery += "     RD0_CODIGO"+CRLF
    cQuery += " FROM"+CRLF
    cQuery += "     " + RetSqlName("PS6") + " PS6 "+CRLF
    cQuery += "     INNER JOIN " + RetSqlName("PS7") + " PS7  "+CRLF
    cQuery += "         ON  PS7_FILIAL = '" + xFilial("PS7") + "'"+CRLF
    cQuery += "         AND PS7_GRUPO = PS6_GRUPO"+CRLF
    cQuery += "         AND PS7.D_E_L_E_T_ = ' ' "+CRLF
    cQuery += "     INNER JOIN " + RetSqlName("RD0") + " RD0 "+CRLF
    cQuery += "         ON RD0_FILIAL = '" + xFilial("RD0") + "'"+CRLF
    cQuery += "         AND PS7_PARTIC = RD0_CODIGO"+CRLF
    cQuery += "         AND RD0.D_E_L_E_T_ = ' ' "+CRLF
    cQuery += " WHERE"+CRLF
    cQuery += "     PS6.PS6_FILIAL = '" + xFilial("PS6") + "'"+CRLF
    cQuery += "     AND PS6_RESPON = '" + cCodRd0 + "'"+CRLF
    cQuery += "     AND PS6.D_E_L_E_T_ = ' '"+CRLF

    If cTipoUser == "2" //Externo
        cQuery += " UNION"+CRLF

        cQuery += " SELECT"+CRLF
        cQuery += "     RD0_IDRESE,"+CRLF
        cQuery += "     RD0_CODIGO"+CRLF
        cQuery += " FROM"+CRLF
        cQuery += "     " + RetSqlName("PS6") + " PS6 "+CRLF
        cQuery += "     INNER JOIN " + RetSqlName("RD0") + " RD0 "+CRLF
        cQuery += "         ON RD0_FILIAL = '" + xFilial("RD0") + "'"+CRLF
        cQuery += "         AND PS6_RESPON = RD0_CODIGO"+CRLF
        cQuery += "         AND RD0.D_E_L_E_T_ = ' ' "+CRLF
        cQuery += " WHERE"+CRLF
        cQuery += "     PS6.PS6_FILIAL = '" + xFilial("PS6") + "'"+CRLF
        cQuery += "     AND PS6_RESPON = '" + cCodRd0 + "'"+CRLF
        cQuery += "     AND PS6.D_E_L_E_T_ = ' '"
    EndIf

    If Select(cAlsTer) > 0; (cAlsTer)->(dbCloseArea()); Endif  
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlsTer,.T.,.T.)

    While !(cAlsTer)->(Eof())

        If !Empty((cAlsTer)->RD0_IDRESE) .And. nCount == 1
        
            cRet += '"favorecidos": ['
            cRet += '{'
            cRet += '"item1":' + Alltrim((cAlsTer)->RD0_IDRESE)
            cRet += '},'

        ElseIf !Empty((cAlsTer)->RD0_IDRESE)

            cRet += '{'
            cRet += '"item1":' + Alltrim((cAlsTer)->RD0_IDRESE)
            cRet += '},'
        
        EndIf
    
        (cAlsTer)->(DbSkip())

        nCount++

    End

    //Remove a ultima virgula e fecha o array.
    If !Empty(cRet)
        cRet := Left(cRet, RAT(",", cRet) - 1)
        cRet += ']'
    EndIf

    (cAlsTer)->(dbCloseArea())

Return(cRet)

//------------------------------------------------------------------------
/*/{Protheus.doc} fNvlVsCarg
Veriica politica vs cargo.

@author By Wise

@since 14/11/2018
/*/
//-----------------------------------------------------------------------

Static Function fNvlVsCarg(cCodCarg, cTipoUsr)

Local cRet      := ""
Local cAlsNvl   := CriaTrab(Nil,.F.)
Local cQuery    := ""
Local cPolInt   := GetMv("TI_IDPOLINT",,"13")
Local cPolExt   := GetMv("TI_IDPOLEXT",,"17")
Local cTpInter  := GetMv("TI_POLINT",,"000002")
Local cPerfAut  := GetMv("TI_IDPFAUT",,"3") //Id do perfil de autorizador.
Local cIdPol    := IIf(cTipoUsr == "1", cPolInt, cPolExt)
Local aPadrao   := {}
Local aCargo    := {}
Local aFinal    := {}
Local aGrupos   := {}
Local nY
Local nA
Local nPosCargo        

    //Se usuùrio interno busca sempre a politica default e apenas soma a de grupos caso exista.
    If cTipoUsr == "1"

        cQuery := " SELECT PS4_CODCAR, PS5_POLITI, PS3_RESATB, PS4_CRPLAN, PS4_EDTPLA, PS4_EXCPLA, PS4_REGDES, PS4_ADIANT, "
        cQuery += " PS4_SOLICI, PS4_FAVORE, PS4_FINAN,PS4_SOLAUT, PS4_SOLPAG, PS4_CONFAT, PS4_RESAER, PS4_RESHOT, PS4_RESCAR, PS4_RESROD, "
        cQuery += " PS4_RESSEG, PS4_GRPEMP, PS4_PRPPLA, PS4_PLASOL, PS4_PERFIL, 'P' TIPO "
        cQuery += " FROM " + RetSqlName("PS4") + " PS4 "
        cQuery += " INNER JOIN " + RetSqlName("PS5") + " PS5 "
        cQuery += " ON PS5_FILIAL = '" + xFilial("PS5") + "' AND "
        cQuery += " PS5_CODIGO = PS4_CODIGO "
        cQuery += " INNER JOIN " + RetSqlName("PS3") + " PS3 "
        cQuery += " ON PS3_FILIAL = '" + xFilial("PS3") + "' AND "
        cQuery += " PS3_CODIGO = PS4_ATRIBU "
        cQuery += " WHERE PS4_CODIGO = '" + cTpInter + "' "
        cQuery += " AND PS4.D_E_L_E_T_ = ' ' AND PS5.D_E_L_E_T_ = ' ' AND PS3.D_E_L_E_T_ = ' ' "

        cQuery += " UNION ALL "
    
    EndIf
    
    cQuery += " SELECT PS4_CODCAR, PS5_POLITI, PS3_RESATB, PS4_CRPLAN, PS4_EDTPLA, PS4_EXCPLA, PS4_REGDES, PS4_ADIANT, "
    cQuery += " PS4_SOLICI, PS4_FAVORE, PS4_FINAN,PS4_SOLAUT, PS4_SOLPAG, PS4_CONFAT, PS4_RESAER, PS4_RESHOT, PS4_RESCAR, PS4_RESROD, "
    cQuery += " PS4_RESSEG, PS4_GRPEMP, PS4_PRPPLA, PS4_PLASOL, PS4_PERFIL, 'C' TIPO "
    cQuery += " FROM " + RetSqlName("PS4") + " PS4 "
    cQuery += " INNER JOIN " + RetSqlName("PS5") + " PS5 "
    cQuery += " ON PS5_FILIAL = '" + xFilial("PS5") + "' AND "
    cQuery += " PS5_CODIGO = PS4_CODIGO "
    cQuery += " INNER JOIN " + RetSqlName("PS3") + " PS3 "
    cQuery += " ON PS3_FILIAL = '" + xFilial("PS3") + "' AND "
    cQuery += " PS3_CODIGO = PS4_ATRIBU "
    cQuery += " WHERE PS4_CODCAR = '" + cCodCarg + "' AND PS4.D_E_L_E_T_ = ' ' AND PS5.D_E_L_E_T_ = ' ' AND PS3.D_E_L_E_T_ = ' ' "

    If Select(cAlsNvl) > 0; (cAlsNvl)->(dbCloseArea()); Endif  
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlsNvl,.T.,.T.)

    //Para externo vai sempre na politica default.
    If cTipoUsr == "2"

        cRet := fPolDef(cTipoUsr)

    Else

        //Primeiro varre a query para poder tratar regras de relevancia.
        While !(cAlsNvl)->(Eof())

            If (cAlsNvl)->TIPO == "P"
                
                AADD(aPadrao,  {{"PS4_CODCAR"   , (cAlsNvl)->PS4_CODCAR },;
                                {"PS5_POLITI"   , (cAlsNvl)->PS5_POLITI },;
                                {"PS3_RESATB"   , (cAlsNvl)->PS3_RESATB },;
                                {"PS4_CRPLAN"   , (cAlsNvl)->PS4_CRPLAN },;
                                {"PS4_EDTPLA"   , (cAlsNvl)->PS4_EDTPLA },;
                                {"PS4_EXCPLA"   , (cAlsNvl)->PS4_EXCPLA },;
                                {"PS4_REGDES"   , (cAlsNvl)->PS4_REGDES },;
                                {"PS4_RESAER"   , (cAlsNvl)->PS4_RESAER },;
                                {"PS4_RESHOT"   , (cAlsNvl)->PS4_RESHOT },;
                                {"PS4_RESCAR"   , (cAlsNvl)->PS4_RESCAR },;
                                {"PS4_RESROD"   , (cAlsNvl)->PS4_RESROD },;
                                {"PS4_RESSEG"   , (cAlsNvl)->PS4_RESSEG },;
                                {"PS4_GRPEMP"   , (cAlsNvl)->PS4_GRPEMP },;
                                {"PS4_PRPPLA"   , (cAlsNvl)->PS4_PRPPLA },;
                                {"PS4_PLASOL"   , (cAlsNvl)->PS4_PLASOL },;
                                {"PS4_PERFIL"   , (cAlsNvl)->PS4_PERFIL },;
                                {"PS4_ADIANT"   , (cAlsNvl)->PS4_ADIANT },;
                                {"PS4_FAVORE"   , (cAlsNvl)->PS4_FAVORE },;
                                {"PS4_SOLICI"   , (cAlsNvl)->PS4_SOLICI },;
                                {"PS4_FINAN"    , (cAlsNvl)->PS4_FINAN  } })
            Else

                AADD(aCargo,   {{"PS4_CODCAR"   , (cAlsNvl)->PS4_CODCAR },;
                                {"PS5_POLITI"   , (cAlsNvl)->PS5_POLITI },;
                                {"PS3_RESATB"   , (cAlsNvl)->PS3_RESATB },;
                                {"PS4_CRPLAN"   , (cAlsNvl)->PS4_CRPLAN },;
                                {"PS4_EDTPLA"   , (cAlsNvl)->PS4_EDTPLA },;
                                {"PS4_EXCPLA"   , (cAlsNvl)->PS4_EXCPLA },;
                                {"PS4_REGDES"   , (cAlsNvl)->PS4_REGDES },;
                                {"PS4_RESAER"   , (cAlsNvl)->PS4_RESAER },;
                                {"PS4_RESHOT"   , (cAlsNvl)->PS4_RESHOT },;
                                {"PS4_RESCAR"   , (cAlsNvl)->PS4_RESCAR },;
                                {"PS4_RESROD"   , (cAlsNvl)->PS4_RESROD },;
                                {"PS4_RESSEG"   , (cAlsNvl)->PS4_RESSEG },;
                                {"PS4_GRPEMP"   , (cAlsNvl)->PS4_GRPEMP },;
                                {"PS4_PRPPLA"   , (cAlsNvl)->PS4_PRPPLA },;
                                {"PS4_PLASOL"   , (cAlsNvl)->PS4_PLASOL },;
                                {"PS4_PERFIL"   , (cAlsNvl)->PS4_PERFIL },;
                                {"PS4_ADIANT"   , (cAlsNvl)->PS4_ADIANT },;
                                {"PS4_FAVORE"   , (cAlsNvl)->PS4_FAVORE },;
                                {"PS4_SOLICI"   , (cAlsNvl)->PS4_SOLICI },;
                                {"PS4_FINAN"    , (cAlsNvl)->PS4_FINAN  } })

            EndIf
            
            (cAlsNvl)->(DbSkip())

        End

        //Compara os arrays.
        If Len(aCargo) > 0

            //For para montar array final a ser lido.
            For nY := 1 to len(aCargo)

                If nY == 1

                    For nA := 1 to len(aCargo[nY])
                    
                        //Flags
                        If aCargo[1][nA][2] == "T"

                            AADD(aFinal, {aCargo[1][nA][1], aCargo[1][nA][2]})
                        
                        ElseIf aPadrao[1][nA][2] == "T"

                            AADD(aFinal, {aCargo[1][nA][1], aCargo[1][nA][2]})

                        Else

                            AADD(aFinal, {aCargo[1][nA][1], aCargo[1][nA][2]})

                        EndIf

                    Next nA

                EndIf

                //Grupos
                AADD(aGrupos, Alltrim(aCargo[nY][2][2]) )

            Next nY

            //Depois de preenchido os grupos do grupo de acesso verifica quais da politica do interno posso manter ainda.
            For nY := 1 to len(aPadrao)

                cIdSubs := fVrfSX5(aPadrao[nY][2][2])

                If !Empty(cIdSubs)
                    
                    nPosCargo := aScan(aGrupos, cIdSubs )

                    If nPosCargo == 0
                        AADD(aGrupos, Alltrim(aPadrao[nY][2][2]) )
                    EndIf
                
                Else
                    AADD(aGrupos, Alltrim(aPadrao[nY][2][2]) )
                EndIf


            Next nY

        EndIf

        (cAlsNvl)->(DbGoTop())
        
        //Se tiver politica para cargo trato todos campos de flag com os dados dela e depois somo os grupos.
        If Len(aFinal) > 0

            //Cria planos
            If aFinal[4][2] = 'T'
                cRet += ","
                cRet += '"criaPlano":true'
            Else
                cRet += ","
                cRet += '"criaPlano":false'
            EndIf

            //Edita planos
            If aFinal[5][2] = 'T'
                cRet += ","
                cRet += '"editaPlano":true'
            Else
                cRet += ","
                cRet += '"editaPlano":false'
            EndIf

            //Exclui planos
            If aFinal[6][2] = 'T'
                cRet += ","
                cRet += '"excluiPlano":true'
            Else
                cRet += ","
                cRet += '"excluiPlano":false'
            EndIf

            //Registra despesas
            If aFinal[7][2] = 'T'
                cRet += ","
                cRet += '"registraDespesa":true'
            Else
                cRet += ","
                cRet += '"registraDespesa":false'
            EndIf

            //Solicitante
            If aFinal[8][2] = 'T'
                cRet += ','
                cRet += '"preferencias": {'
                cRet += '"restricaoServicos": {'
                cRet += '"aereo":true
            Else
                cRet += ','
                cRet += '"preferencias": {'
                cRet += '"restricaoServicos": {'
                cRet += '"aereo":false
            EndIf

            //Solicitante
            If aFinal[9][2] = 'T'
                cRet += ","
                cRet += '"hotel":true
            Else
                cRet += ","
                cRet += '"hotel":false
            EndIf

            //Solicitante
            If aFinal[10][2]= 'T'
                cRet += ","
                cRet += '"carro":true
            Else
                cRet += ","
                cRet += '"carro":false
            EndIf

            //Solicitante
            If aFinal[11][2] = 'T'
                cRet += ","
                cRet += '"rodoviario":true
            Else
                cRet += ","
                cRet += '"rodoviario":false
            EndIf

            //Solicitante
            If aFinal[12][2] = 'T'
                cRet += ","
                cRet += '"seguro":true
                cRet += '}}
            Else
                cRet += ","
                cRet += '"seguro":false
                cRet += '}}
            EndIf

            //Perfil de acesso
            If !Empty(aFinal[16][2])
                cRet += ','
                cRet += '"perfilAcesso":{'
                
                If lIsPerf .And. lIsAprov
                    cRet += '"id":' + Alltrim(cPerfAut) + '}'
                Else
                    cRet += '"id":' + Alltrim( (cAlsNvl)->PS4_PERFIL ) + '}'
                EndIf

            Endif

            //Solicita Adiantamentos
            If aFinal[17][2] = 'T'
                //Expense
                cRet += ','
                cRet += '"expense":{'
                
                If lIsPerf .And. !lIsAprov
                    cRet += '"autorizador":false,'
                ElseIf lIsPerf .And. lIsAprov
                    cRet += '"autorizador":true,'
                Else
                 	cRet += '"autorizador":false,'
                EndIf

                //Autoriza grupo
                If aFinal[13][2] = 'T' .Or. (lIsPerf .And. lIsAprov)
                    cRet += '"autorizaGrupoEmpresa":true,'
                Else
                    cRet += '"autorizaGrupoEmpresa":false,'
                EndIf
                
                cRet += '"recebeSolicitacaoAutorizacao":true,'
                cRet += '"recebeSolicitacaoPagamento":true,'
                cRet += '"recebeConfirmacaoAutorizacao":true,'
                cRet += '"registraDespesa":true,'
                cRet += '"solicitaAdiantamentos":true'
                
                //Favorecidos
                If aFinal[18][2] = 'T'
                    cRet += ","
                    cRet += '"favorecido":true'
                Else
                    cRet += ","
                    cRet += '"favorecido":false'
                EndIf

                //Solicitante
                If aFinal[19][2] = 'T'
                    cRet += ","
                    cRet += '"solicitante":true'
                Else
                    cRet += ","
                    cRet += '"solicitante":false'
                EndIf

                //Financeiro
                If aFinal[20][2] = 'T'
                    cRet += ","
                    cRet += '"financeiro":true'
                Else
                    cRet += ","
                    cRet += '"financeiro":false'
                EndIf
                
	            //Solicitante
	            If aFinal[14][2] = 'T'
	                cRet += ","
	                cRet += '"autorizaPropriosPlanos":true'
	            Else
	                cRet += ","
	                cRet += '"autorizaPropriosPlanos":false'
	            EndIf
	
		        If aFinal[15][2] = 'T'
	                cRet += ","
	                cRet += '"autorizaPlanosSolicitados":true'
	            Else
	                cRet += ","
	                cRet += '"autorizaPlanosSolicitados":false'
	            EndIf
                
	            cRet += '}'
                
            Else
                cRet += ','
                cRet += '"expense":{'
                
                If lIsPerf .And. !lIsAprov
                    cRet += '"autorizador":false,'
                ElseIf lIsPerf .And. lIsAprov
                    cRet += '"autorizador":true,'
                Else
                 	cRet += '"autorizador":false,'
                EndIf

                //Autoriza grupo
                If aFinal[13][2] = 'T' .Or. (lIsPerf .And. lIsAprov)
                    cRet += '"autorizaGrupoEmpresa":true,'
                Else
                    cRet += '"autorizaGrupoEmpresa":false,'
                EndIf
                
                cRet += '"recebeSolicitacaoAutorizacao":true,'
                cRet += '"recebeSolicitacaoPagamento":true,'
                cRet += '"recebeConfirmacaoAutorizacao":true,'
                cRet += '"registraDespesa":true,'
                cRet += '"solicitaAdiantamentos":false'

                //Favorecidos
                If aFinal[18][2] = 'T'
                    cRet += ","
                    cRet += '"favorecido":true'
                Else
                    cRet += ","
                    cRet += '"favorecido":false'
                EndIf

                //Solicitante
                If aFinal[19][2] = 'T'
                    cRet += ","
                    cRet += '"solicitante":true'
                Else
                    cRet += ","
                    cRet += '"solicitante":false'
                EndIf

                //Financeiro
                If aFinal[20][2] = 'T'
                    cRet += ","
                    cRet += '"financeiro":true'
                Else
                    cRet += ","
                    cRet += '"financeiro":false'
                EndIf

	            //Solicitante
	            If aFinal[14][2] = 'T'
	                cRet += ","
	                cRet += '"autorizaPropriosPlanos":true'
	            Else
	                cRet += ","
	                cRet += '"autorizaPropriosPlanos":false'
	            EndIf
	
		        If aFinal[15][2] = 'T'
	                cRet += ","
	                cRet += '"autorizaPlanosSolicitados":true'
	            Else
	                cRet += ","
	                cRet += '"autorizaPlanosSolicitados":false'
	            EndIf
	
                cRet += '}'

            EndIf

            //Por conta do atributo ser generico faz o case.
            Do Case
                
                Case Alltrim( UPPER( aFinal[3][2] )) == "GRUPOS"

                    cRet += ','
                    cRet += '"grupos":[ 

                                            
                    For nA := 1 to len(aGrupos)
                        cRet += '{"id":' + Alltrim( aGrupos[nA] ) + '},'
                    Next nA

                Case Alltrim( UPPER((cAlsNvl)->PS3_RESATB)) ==  "PERFILPOLITICA"

                    cRet += ','
                    cRet += '"perfilPolitica":[
                    cRet += '{"id":' + Alltrim( cIdPol ) + '},'
                
            EndCase

        //Se nùo tiver politica por cargo segue via query.
        Else

            //Cria planos
            If (cAlsNvl)->PS4_CRPLAN = 'T'
                cRet += ","
                cRet += '"criaPlano":true'
            Else
                cRet += ","
                cRet += '"criaPlano":false'
            EndIf

            //Edita planos
            If (cAlsNvl)->PS4_EDTPLA = 'T'
                cRet += ","
                cRet += '"editaPlano":true'
            Else
                cRet += ","
                cRet += '"editaPlano":false'
            EndIf

            //Exclui planos
            If (cAlsNvl)->PS4_EXCPLA = 'T'
                cRet += ","
                cRet += '"excluiPlano":true'
            Else
                cRet += ","
                cRet += '"excluiPlano":false'
            EndIf

            //Registra despesas
            If (cAlsNvl)->PS4_REGDES = 'T'
                cRet += ","
                cRet += '"registraDespesa":true'
            Else
                cRet += ","
                cRet += '"registraDespesa":false'
            EndIf

            //Solicitante
            If (cAlsNvl)->PS4_RESAER = 'T'
                cRet += ','
                cRet += '"preferencias": {'
                cRet += '"restricaoServicos": {'
                cRet += '"aereo":true
            Else
                cRet += ','
                cRet += '"preferencias": {'
                cRet += '"restricaoServicos": {'
                cRet += '"aereo":false
            EndIf

            //Solicitante
            If (cAlsNvl)->PS4_RESHOT = 'T'
                cRet += ","
                cRet += '"hotel":true
            Else
                cRet += ","
                cRet += '"hotel":false
            EndIf

            //Solicitante
            If (cAlsNvl)->PS4_RESCAR = 'T'
                cRet += ","
                cRet += '"carro":true
            Else
                cRet += ","
                cRet += '"carro":false
            EndIf

            //Solicitante
            If (cAlsNvl)->PS4_RESROD = 'T'
                cRet += ","
                cRet += '"rodoviario":true
            Else
                cRet += ","
                cRet += '"rodoviario":false
            EndIf

            //Solicitante
            If (cAlsNvl)->PS4_RESSEG = 'T'
                cRet += ","
                cRet += '"seguro":true
                cRet += '}}
            Else
                cRet += ","
                cRet += '"seguro":false
                cRet += '}}
            EndIf

            //Perfil de acesso
            If !Empty((cAlsNvl)->PS4_PERFIL)
                cRet += ','
                cRet += '"perfilAcesso":{'
                
                If lIsPerf .And. lIsAprov
                    cRet += '"id":' + Alltrim(cPerfAut) + '}'
                Else
                    cRet += '"id":' + Alltrim( (cAlsNvl)->PS4_PERFIL ) + '}'
                EndIf

            Endif

            //Solicita Adiantamentos
            If (cAlsNvl)->PS4_ADIANT = 'T'
                //Expense
                cRet += ','
                cRet += '"expense":{'
                
                If lIsPerf .And. !lIsAprov
                    cRet += '"autorizador":false,'
                ElseIf lIsPerf .And. lIsAprov
                    cRet += '"autorizador":true,'
                Else
                 	cRet += '"autorizador":false,'
                EndIf

                //Solicitante
                If (cAlsNvl)->PS4_GRPEMP = 'T' .Or. (lIsPerf .And. lIsAprov)
                    cRet += '"autorizaGrupoEmpresa":true,'
                Else
                    cRet += '"autorizaGrupoEmpresa":false,'
                EndIf
                
                cRet += '"recebeSolicitacaoAutorizacao":true,'
                cRet += '"recebeSolicitacaoPagamento":true,'
                cRet += '"recebeConfirmacaoAutorizacao":true,'
                cRet += '"registraDespesa":true,'
                cRet += '"solicitaAdiantamentos":true'
                
                //Favorecidos
                If (cAlsNvl)->PS4_FAVORE = 'T'
                    cRet += ","
                    cRet += '"favorecido":true'
                Else
                    cRet += ","
                    cRet += '"favorecido":false'
                EndIf

                //Solicitante
                If (cAlsNvl)->PS4_SOLICI = 'T'
                    cRet += ","
                    cRet += '"solicitante":true'
                Else
                    cRet += ","
                    cRet += '"solicitante":false'
                EndIf

                //Financeiro
                If (cAlsNvl)->PS4_FINAN = 'T'
                    cRet += ","
                    cRet += '"financeiro":true'
                Else
                    cRet += ","
                    cRet += '"financeiro":false'
                EndIf
                
                If (cAlsNvl)->PS4_PRPPLA = 'T'
	                cRet += ","
	                cRet += '"autorizaPropriosPlanos":true'
	            Else
	                cRet += ","
	                cRet += '"autorizaPropriosPlanos":false'
	            EndIf
	
	            //Solicitante
	            If (cAlsNvl)->PS4_PLASOL = 'T'
	                cRet += ","
	                cRet += '"autorizaPlanosSolicitados":true'
	            Else
	                cRet += ","
	                cRet += '"autorizaPlanosSolicitados":false'
	            EndIf
                
                cRet += '}'
                
            Else
                cRet += ','
                cRet += '"expense":{'
                
                If lIsPerf .And. !lIsAprov
                    cRet += '"autorizador":false,'
                ElseIf lIsPerf .And. lIsAprov
                    cRet += '"autorizador":true,'
                Else
                 	cRet += '"autorizador":false,'
                EndIf

                //Solicitante
                If (cAlsNvl)->PS4_GRPEMP = 'T' .Or. (lIsPerf .And. lIsAprov)
                    cRet += '"autorizaGrupoEmpresa":true,'
                Else
                    cRet += '"autorizaGrupoEmpresa":false,'
                EndIf
                
                cRet += '"recebeSolicitacaoAutorizacao":true,'
                cRet += '"recebeSolicitacaoPagamento":true,'
                cRet += '"recebeConfirmacaoAutorizacao":true,'
                cRet += '"registraDespesa":true,'
                cRet += '"solicitaAdiantamentos":false'

                //Favorecidos
                If (cAlsNvl)->PS4_FAVORE = 'T'
                    cRet += ","
                    cRet += '"favorecido":true'
                Else
                    cRet += ","
                    cRet += '"favorecido":false'
                EndIf

                //Solicitante
                If (cAlsNvl)->PS4_SOLICI = 'T'
                    cRet += ","
                    cRet += '"solicitante":true'
                Else
                    cRet += ","
                    cRet += '"solicitante":false'
                EndIf

                //Financeiro
                If (cAlsNvl)->PS4_FINAN = 'T'
                    cRet += ","
                    cRet += '"financeiro":true'
                Else
                    cRet += ","
                    cRet += '"financeiro":false'
                EndIf

   				//Solicitante
	            If (cAlsNvl)->PS4_PRPPLA = 'T'
	                cRet += ","
	                cRet += '"autorizaPropriosPlanos":true'
	            Else
	                cRet += ","
	                cRet += '"autorizaPropriosPlanos":false'
	            EndIf
	
	            //Solicitante
	            If (cAlsNvl)->PS4_PLASOL = 'T'
	                cRet += ","
	                cRet += '"autorizaPlanosSolicitados":true'
	            Else
	                cRet += ","
	                cRet += '"autorizaPlanosSolicitados":false'
	            EndIf

                cRet += '}'

            EndIf

            Do Case
                
                Case Alltrim( UPPER((cAlsNvl)->PS3_RESATB)) == "GRUPOS"
                                            
                    cRet += ','
                    cRet += '"grupos":[

                    While !(cAlsNvl)->(Eof())
                        cRet += '{"id":' + Alltrim( (cAlsNvl)->PS5_POLITI ) + '},'
                        (cAlsNvl)->(DbSkip())
                    End
            
                Case Alltrim( UPPER((cAlsNvl)->PS3_RESATB)) ==  "PERFILPOLITICA"

                    cRet += ','
                    cRet += '"perfilPolitica":[
                    cRet += '{"id":' + Alltrim( cIdPol ) + '},'
                
            EndCase

        EndIf

        If !Empty(cRet)
            cRet := Left(cRet, RAT(",", cRet) - 1)
            cRet += "]"
        EndIf
        
    EndIf

    (cAlsNvl)->(dbCloseArea())

Return(cRet)

//------------------------------------------------------------------------
/*/{Protheus.doc} fPolDef
Politica default para o tipo de participante.

@author By Wise

@since 14/11/2018
/*/
//-----------------------------------------------------------------------

Static Function fPolDef(cTipoUser)

Local cRet      := ""
Local cAlsDef   := CriaTrab(Nil,.F.)
Local cQuery    := ""
Local cTpInExt  := GetMv("TI_POLEXT",,"000003")
Local cTpInter  := GetMv("TI_POLINT",,"000002")
Local cPerfAut  := GetMv("TI_IDPFAUT",,"3") //Id do perfil de autorizador.
Local cFilQry   := IIf(cTipoUser == "1", cTpInter, cTpInExt)

    cQuery := " SELECT PS4_CODCAR, PS5_POLITI, PS3_RESATB, PS4_CRPLAN, PS4_EDTPLA, PS4_EXCPLA, PS4_REGDES, PS4_ADIANT, "
    cQuery += " PS4_SOLICI, PS4_FAVORE, PS4_SOLAUT, PS4_SOLPAG, PS4_CONFAT, PS4_RESAER, PS4_RESHOT, PS4_RESCAR, PS4_RESROD, "
    cQuery += " PS4_RESSEG, PS4_GRPEMP, PS4_PRPPLA, PS4_PLASOL, PS4_PERFIL, PS4_FINAN "
    cQuery += " FROM " + RetSqlName("PS4") + " PS4 "
    cQuery += " INNER JOIN " + RetSqlName("PS5") + " PS5 "
    cQuery += " ON PS5_FILIAL = '" + xFilial("PS5") + "' AND "
    cQuery += " PS5_CODIGO = PS4_CODIGO "
    cQuery += " INNER JOIN " + RetSqlName("PS3") + " PS3 "
    cQuery += " ON PS3_FILIAL = '" + xFilial("PS3") + "' AND "
    cQuery += " PS3_CODIGO = PS4_ATRIBU "
    cQuery += " WHERE PS4_CODIGO = '" + cFilQry + "' "
    cQuery += " AND PS4.D_E_L_E_T_ = ' ' AND PS5.D_E_L_E_T_ = ' ' AND PS3.D_E_L_E_T_ = ' ' "

    If Select(cAlsDef) > 0; (cAlsDef)->(dbCloseArea()); Endif  
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlsDef,.T.,.T.)

    If !(cAlsDef)->(Eof())
        
        Do Case
            
            Case Alltrim( UPPER((cAlsDef)->PS3_RESATB)) == "GRUPOS"

                //Cria planos
                If (cAlsDef)->PS4_CRPLAN = 'T'
                    cRet += ","
                    cRet += '"criaPlano":true'
                Else
                    cRet += ","
                    cRet += '"criaPlano":false'
                EndIf

                //Edita planos
                If (cAlsDef)->PS4_EDTPLA = 'T'
                    cRet += ","
                    cRet += '"editaPlano":true'
                Else
                    cRet += ","
                    cRet += '"editaPlano":false'
                EndIf

                //Exclui planos
                If (cAlsDef)->PS4_EXCPLA = 'T'
                    cRet += ","
                    cRet += '"excluiPlano":true'
                Else
                    cRet += ","
                    cRet += '"excluiPlano":false'
                EndIf

                //Registra despesas
                If (cAlsDef)->PS4_REGDES = 'T'
                    cRet += ","
                    cRet += '"registraDespesa":true'
                Else
                    cRet += ","
                    cRet += '"registraDespesa":false'
                EndIf

                //Solicitante
                If (cAlsDef)->PS4_FAVORE = 'T'
                    cRet += ","
                    cRet += '"favorecido":true'
                Else
                    cRet += ","
                    cRet += '"favorecido":false'
                EndIf

                //Solicitante
                /*If (cAlsDef)->PS4_SOLPAG = 'T'
                    cRet += ","
                    cRet += '"solicitante":true'
                Else
                    cRet += ","
                    cRet += '"solicitante":false'
                EndIf

                //Solicitante
                If (cAlsDef)->PS4_CONFAT = 'T'
                    cRet += ","
                    cRet += '"solicitante":true'
                Else
                    cRet += ","
                    cRet += '"solicitante":false'
                EndIf*/
                
                //Solicitante
                If (cAlsDef)->PS4_RESAER = 'T'
                    cRet += ','
                    cRet += '"preferencias": {'
                    cRet += '"restricaoServicos": {'
                    cRet += '"aereo":true
                Else
                    cRet += ','
                    cRet += '"preferencias": {'
                    cRet += '"restricaoServicos": {'
                    cRet += '"aereo":false
                EndIf

                //Solicitante
                If (cAlsDef)->PS4_RESHOT = 'T'
                    cRet += ","
                    cRet += '"hotel":true
                Else
                    cRet += ","
                    cRet += '"hotel":false
                EndIf

                //Solicitante
                If (cAlsDef)->PS4_RESCAR = 'T'
                    cRet += ","
                    cRet += '"carro":true
                Else
                    cRet += ","
                    cRet += '"carro":false
                EndIf

                //Solicitante
                If (cAlsDef)->PS4_RESROD = 'T'
                    cRet += ","
                    cRet += '"rodoviario":true
                Else
                    cRet += ","
                    cRet += '"rodoviario":false
                EndIf

                //Solicitante
                If (cAlsDef)->PS4_RESSEG = 'T'
                    cRet += ","
                    cRet += '"seguro":true
                    cRet += '}}
                Else
                    cRet += ","
                    cRet += '"seguro":false
                    cRet += '}}
                EndIf

                //Perfil de acesso
                If !Empty((cAlsDef)->PS4_PERFIL)
                    cRet += ','
                    cRet += '"perfilAcesso":{'
                    
                    If lIsPerf .And. lIsAprov
                        cRet += '"id":' + Alltrim(cPerfAut) + '}'
                    Else    
                        cRet += '"id":' + Alltrim( (cAlsDef)->PS4_PERFIL ) + '}'
                    EndIf

                Endif

                //Solicita Adiantamentos
                If (cAlsDef)->PS4_ADIANT = 'T'
                    //Expense
                    cRet += ','
                    cRet += '"expense":{'
                    
                    If lIsPerf .And. !lIsAprov
                        cRet += '"autorizador":false,'
                    ElseIf lIsPerf .And. lIsAprov
                        cRet += '"autorizador":true,'
                    Else
                 		cRet += '"autorizador":false,'
                    EndIf

                    //Solicitante
                    If (cAlsDef)->PS4_GRPEMP = 'T' .Or. (lIsPerf .And. lIsAprov)
                        cRet += '"autorizaGrupoEmpresa":true,'
                    Else
                        cRet += '"autorizaGrupoEmpresa":false,'
                    EndIf
                    
                    
					If (cAlsDef)->PS4_SOLAUT = 'T'
                    	cRet += '"recebeSolicitacaoAutorizacao":true,'
                    Else
                    	cRet += '"recebeSolicitacaoAutorizacao":false,'
                    Endif
                    
                    If (cAlsDef)->PS4_SOLPAG = 'T'
                    	cRet += '"recebeSolicitacaoPagamento":true,'
                    Else
                    	cRet += '"recebeSolicitacaoPagamento":false,'
                    Endif
                    
                    If (cAlsDef)->PS4_CONFAT = 'T'
                    	cRet += '"recebeConfirmacaoAutorizacao":true,'
                    Else
                    	cRet += '"recebeConfirmacaoAutorizacao":false,'
                    Endif
                    
                    cRet += '"registraDespesa":true,'
                    cRet += '"solicitaAdiantamentos":true'
                    
                    //Favorecidos
                    If (cAlsDef)->PS4_FAVORE = 'T'
                        cRet += ","
                        cRet += '"favorecido":true'
                    Else
                        cRet += ","
                        cRet += '"favorecido":false'
                    EndIf

                    //Solicitante
                    If (cAlsDef)->PS4_SOLICI = 'T'
                        cRet += ","
                        cRet += '"solicitante":true'
                    Else
                        cRet += ","
                        cRet += '"solicitante":false'
                    EndIf

                    //Financeiro
                    If (cAlsDef)->PS4_FINAN = 'T'
                        cRet += ","
                        cRet += '"financeiro":true'
                    Else
                        cRet += ","
                        cRet += '"financeiro":false'
                    EndIf
                    
                    //Solicitante
	                If (cAlsDef)->PS4_PRPPLA = 'T'
	                    cRet += ","
	                    cRet += '"autorizaPropriosPlanos":true'
	                Else
	                    cRet += ","
	                    cRet += '"autorizaPropriosPlanos":false'
	                EndIf
	
	                //Solicitante
	                If (cAlsDef)->PS4_PLASOL = 'T'
	                    cRet += ","
	                    cRet += '"autorizaPlanosSolicitados":true'
	                Else
	                    cRet += ","
	                    cRet += '"autorizaPlanosSolicitados":false'
	                EndIf
	                    
                    cRet += '}'
                    
                Else
                    cRet += ','
                    cRet += '"expense":{'
                    
                    If lIsPerf .And. !lIsAprov
                        cRet += '"autorizador":false,'
                    ElseIf lIsPerf .And. lIsAprov
                        cRet += '"autorizador":true,'
                    Else
                 		cRet += '"autorizador":false,'
                    EndIf

                    //Solicitante
                    If (cAlsDef)->PS4_GRPEMP = 'T' .Or. (lIsPerf .And. lIsAprov)
                        cRet += '"autorizaGrupoEmpresa":true,'
                    Else
                        cRet += '"autorizaGrupoEmpresa":false,'
                    EndIf
                    
                    
					If (cAlsDef)->PS4_SOLAUT = 'T'
                    	cRet += '"recebeSolicitacaoAutorizacao":true,'
                    Else
                    	cRet += '"recebeSolicitacaoAutorizacao":false,'
                    Endif
                    
                    If (cAlsDef)->PS4_SOLPAG = 'T'
                    	cRet += '"recebeSolicitacaoPagamento":true,'
                    Else
                    	cRet += '"recebeSolicitacaoPagamento":false,'
                    Endif
                    
                    If (cAlsDef)->PS4_CONFAT = 'T'
                    	cRet += '"recebeConfirmacaoAutorizacao":true,'
                    Else
                    	cRet += '"recebeConfirmacaoAutorizacao":false,'
                    Endif
                    
                    cRet += '"registraDespesa":true,'
                    cRet += '"solicitaAdiantamentos":false'

                    //Favorecidos
                    If (cAlsDef)->PS4_FAVORE = 'T'
                        cRet += ","
                        cRet += '"favorecido":true'
                    Else
                        cRet += ","
                        cRet += '"favorecido":false'
                    EndIf

                    //Solicitante
                    If (cAlsDef)->PS4_SOLICI = 'T'
                        cRet += ","
                        cRet += '"solicitante":true'
                    Else
                        cRet += ","
                        cRet += '"solicitante":false'
                    EndIf

                    //Financeiro
                    If (cAlsDef)->PS4_FINAN = 'T'
                        cRet += ","
                        cRet += '"financeiro":true'
                    Else
                        cRet += ","
                        cRet += '"financeiro":false'
                    EndIf

                    cRet += '}'

                EndIf
                                        
                cRet += ','
                cRet += '"grupos":[
        
            Case Alltrim((cAlsDef)->PS3_RESATB) ==  "PERFILPOLITICA"

                //Cria planos
                If (cAlsDef)->PS4_CRPLAN = 'T'
                    cRet += ","
                    cRet += '"criaPlano":true'
                Else
                    cRet += ","
                    cRet += '"criaPlano":false'
                EndIf

                //Edita planos
                If (cAlsDef)->PS4_EDTPLA = 'T'
                    cRet += ","
                    cRet += '"editaPlano":true'
                Else
                    cRet += ","
                    cRet += '"editaPlano":false'
                EndIf

                //Exclui planos
                If (cAlsDef)->PS4_EXCPLA = 'T'
                    cRet += ","
                    cRet += '"excluiPlano":true'
                Else
                    cRet += ","
                    cRet += '"excluiPlano":false'
                EndIf

                //Registra despesas
                If (cAlsDef)->PS4_REGDES = 'T'
                    cRet += ","
                    cRet += '"registraDespesa":true'
                Else
                    cRet += ","
                    cRet += '"registraDespesa":false'
                EndIf

                //Solicitante
                If (cAlsDef)->PS4_FAVORE = 'T'
                    cRet += ","
                    cRet += '"favorecido":true'
                Else
                    cRet += ","
                    cRet += '"favorecido":false'
                EndIf

                //Solicitante
                /*If (cAlsDef)->PS4_SOLPAG = 'T'
                    cRet += ","
                    cRet += '"solicitante":true'
                Else
                    cRet += ","
                    cRet += '"solicitante":false'
                EndIf

                //Solicitante
                If (cAlsDef)->PS4_CONFAT = 'T'
                    cRet += ","
                    cRet += '"solicitante":true'
                Else
                    cRet += ","
                    cRet += '"solicitante":false'
                EndIf*/
                
                //Solicitante
                If (cAlsDef)->PS4_RESAER = 'T'
                    cRet += ','
                    cRet += '"preferencias": {'
                    cRet += '"restricaoServicos": {'
                    cRet += '"aereo":true
                Else
                    cRet += ','
                    cRet += '"preferencias": {'
                    cRet += '"restricaoServicos": {'
                    cRet += '"aereo":false
                EndIf

                //Solicitante
                If (cAlsDef)->PS4_RESHOT = 'T'
                    cRet += ","
                    cRet += '"hotel":true
                Else
                    cRet += ","
                    cRet += '"hotel":false
                EndIf

                //Solicitante
                If (cAlsDef)->PS4_RESCAR = 'T'
                    cRet += ","
                    cRet += '"carro":true
                Else
                    cRet += ","
                    cRet += '"carro":false
                EndIf

                //Solicitante
                If (cAlsDef)->PS4_RESROD = 'T'
                    cRet += ","
                    cRet += '"rodoviario":true
                Else
                    cRet += ","
                    cRet += '"rodoviario":false
                EndIf

                //Solicitante
                If (cAlsDef)->PS4_RESSEG = 'T'
                    cRet += ","
                    cRet += '"seguro":true
                    cRet += '}}
                Else
                    cRet += ","
                    cRet += '"seguro":false
                    cRet += '}}
                EndIf

                //Perfil de acesso
                If !Empty((cAlsDef)->PS4_PERFIL)
                    cRet += ','
                    cRet += '"perfilAcesso":{'
                    
                    If lIsPerf .And. lIsAprov
                        cRet += '"id":' + Alltrim(cPerfAut) + '}'
                    Else    
                        cRet += '"id":' + Alltrim( (cAlsDef)->PS4_PERFIL ) + '}'
                    EndIf

                Endif

                //Solicita Adiantamentos
                If (cAlsDef)->PS4_ADIANT = 'T'
                    //Expense
                    cRet += ','
                    cRet += '"expense":{'
                    
                    If lIsPerf .And. !lIsAprov
                        cRet += '"autorizador":false,'
                    ElseIf lIsPerf .And. lIsAprov
                        cRet += '"autorizador":true,'
                    Else
                 		cRet += '"autorizador":false,'
                    EndIf

                    //Solicitante
                    If (cAlsDef)->PS4_GRPEMP = 'T' .Or. (lIsPerf .And. lIsAprov)
                        cRet += '"autorizaGrupoEmpresa":true,'
                    Else
                        cRet += '"autorizaGrupoEmpresa":false,'
                    EndIf
                    
                    If (cAlsDef)->PS4_SOLAUT = 'T'
                    cRet += '"recebeSolicitacaoAutorizacao":true,'
                    Else
                    cRet += '"recebeSolicitacaoAutorizacao":false,'
                    Endif
                    
                    If (cAlsDef)->PS4_SOLPAG = 'T'
                    cRet += '"recebeSolicitacaoPagamento":true,'
                    Else
                    cRet += '"recebeSolicitacaoPagamento":false,'
                    Endif
                    
                    If (cAlsDef)->PS4_CONFAT = 'T'
                    	cRet += '"recebeConfirmacaoAutorizacao":true,'
                    Else
                    	cRet += '"recebeConfirmacaoAutorizacao":false,'
                    Endif
                    
                    cRet += '"registraDespesa":true,'
                    cRet += '"solicitaAdiantamentos":true'
                    
                    //Favorecidos
                    If (cAlsDef)->PS4_FAVORE = 'T'
                        cRet += ","
                        cRet += '"favorecido":true'
                    Else
                        cRet += ","
                        cRet += '"favorecido":false'
                    EndIf

                    //Solicitante
                    If (cAlsDef)->PS4_SOLICI = 'T'
                        cRet += ","
                        cRet += '"solicitante":true'
                    Else
                        cRet += ","
                        cRet += '"solicitante":false'
                    EndIf

                    //Financeiro
                    If (cAlsDef)->PS4_FINAN = 'T'
                        cRet += ","
                        cRet += '"financeiro":true'
                    Else
                        cRet += ","
                        cRet += '"financeiro":false'
                    EndIf
                    
                    cRet += '}'
                    
                Else
                    cRet += ','
                    cRet += '"expense":{'
                    
                    If lIsPerf .And. !lIsAprov
                        cRet += '"autorizador":false,'
                    ElseIf lIsPerf .And. lIsAprov
                        cRet += '"autorizador":true,'
                    Else
                 		cRet += '"autorizador":false,'
                    EndIf

                    //Solicitante
                    If (cAlsDef)->PS4_GRPEMP = 'T' .Or. (lIsPerf .And. lIsAprov)
                        cRet += '"autorizaGrupoEmpresa":true,'
                    Else
                        cRet += '"autorizaGrupoEmpresa":false,'
                    EndIf

                    If (cAlsDef)->PS4_SOLAUT = 'T'
                    	cRet += '"recebeSolicitacaoAutorizacao":true,'
                    Else
                    	cRet += '"recebeSolicitacaoAutorizacao":false,'
                    Endif
                    
                    If (cAlsDef)->PS4_SOLPAG = 'T'
                    	cRet += '"recebeSolicitacaoPagamento":true,'
                    Else
                    	cRet += '"recebeSolicitacaoPagamento":false,'
                    Endif
                    
                    If (cAlsDef)->PS4_CONFAT = 'T'
                    	cRet += '"recebeConfirmacaoAutorizacao":true,'
                    Else
                    	cRet += '"recebeConfirmacaoAutorizacao":false,'
                    Endif
                    
                    cRet += '"registraDespesa":true,'
                    cRet += '"solicitaAdiantamentos":false'

                    //Favorecidos
                    If (cAlsDef)->PS4_FAVORE = 'T'
                        cRet += ","
                        cRet += '"favorecido":true'
                    Else
                        cRet += ","
                        cRet += '"favorecido":false'
                    EndIf

                    //Solicitante
                    If (cAlsDef)->PS4_SOLICI = 'T'
                        cRet += ","
                        cRet += '"solicitante":true'
                    Else
                        cRet += ","
                        cRet += '"solicitante":false'
                    EndIf

                    //Financeiro
                    If (cAlsDef)->PS4_FINAN = 'T'
                        cRet += ","
                        cRet += '"financeiro":true'
                    Else
                        cRet += ","
                        cRet += '"financeiro":false'
                    EndIf
                    
	                //Solicitante
	                If (cAlsDef)->PS4_PRPPLA = 'T'
	                    cRet += ","
	                    cRet += '"autorizaPropriosPlanos":true'
	                Else
	                    cRet += ","
	                    cRet += '"autorizaPropriosPlanos":false'
	                EndIf
	
	                //Solicitante
	                If (cAlsDef)->PS4_PLASOL = 'T'
	                    cRet += ","
	                    cRet += '"autorizaPlanosSolicitados":true'
	                Else
	                    cRet += ","
	                    cRet += '"autorizaPlanosSolicitados":false'
	                EndIf

                    cRet += '}'

                EndIf

                cRet += ','
  	            cRet += '"perfilPolitica":[

        EndCase

        While !(cAlsDef)->(Eof())

            cRet += '{"id":' + Alltrim( UPPER((cAlsDef)->PS5_POLITI )) + '},'
            
            (cAlsDef)->(DbSkip())

        End

        If !Empty(cRet)
            cRet := Left(cRet, RAT(",", cRet) - 1)
            cRet += "]"
        EndIf

    EndIf

    (cAlsDef)->(dbCloseArea())

Return(cRet)

//------------------------------------------------------------------------
/*/{Protheus.doc} fAusentes
Funùùo para atualizar usuùrios ausentes.

@author By Wise

@since 14/11/2018
/*/
//-----------------------------------------------------------------------

User Function ResPartAus(lReprocess, lLote, cIdPZC)

Local cQuery    := ""
Local cAlsAus   := ""
Local cToken    := ""
Local cIdPZB    := ""
Local cJson     := ""
Local cJsoRec   := ""
Local nQtdReg   := 0
Local aHeader   := {}
Local aCriaServ := {}
Local aLogin    := {}
Local aAuxReq   := {}

Default cIdPZC      := ""
Default lReprocess  := .F.
Default lLote       := .F.

    RpcSetEnv("00","00001000100")
    RpcSetType(3)
    
    cAlsAus := CriaTrab(Nil,.F.)
    cTpLog  := GetMv("TI_TPLGRES",,"E") //E = Email L = Login

    //Verifica se existe dados a processar
    cQuery := " SELECT COUNT(*) CONTADOR "
    cQuery += " FROM " + RetSqlName("PKB") + " PKB "
    cQuery += " INNER JOIN " + RetSqlName("RD0") + " RD0 "
    cQuery += " ON RD0_FILIAL = '" + xFilial("RD0") + "' AND "
    cQuery += " RD0_CODIGO = ( SELECT MAX(RD0_CODIGO) FROM " + RetSqlName("RD0") + " AUX "
    cQuery += " WHERE AUX.RD0_CIC = PKB.PKB_CPF AND AUX.D_E_L_E_T_ = ' ') "
    cQuery += " WHERE RD0_IDRESE <> ' ' AND ( (PKB_FERINI <= '" + DTOS(dDataBase) + "' AND "
    cQuery += " PKB_FERFIM >= '" + DTOS(dDataBase) + "') OR (PKB_AFAINI <= '" + DTOS(dDataBase) + "' AND "
    cQuery += " PKB_AFAFIM >= '" + DTOS(dDataBase) + "') )  AND PKB_RESERV = ' ' "
    cQuery += " AND PKB.D_E_L_E_T_ = ' ' AND RD0.D_E_L_E_T_ = ' ' "
    
    If Select(cAlsAus) > 0; (cAlsAus)->(dbCloseArea()); Endif  
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlsAus,.T.,.T.)

    nQtdReg := (cAlsAus)->CONTADOR

    (cAlsAus)->(dbCloseArea())

    //Se existir registros a processar.
    If nQtdReg > 0
    
        cQuery := " SELECT RD0_IDRESE, PKB_CPF, RD0_EMAIL, RD0_EMAILC, RD0_LOGINR, RD0_NOME, RD0_SEXO, RD0_XMATRH, "
        cQuery += " RD0_CODIGO, RD0_NOME, PKB.R_E_C_N_O_ RECNO, PKB_RESERV "
        cQuery += " FROM " + RetSqlName("PKB") + " PKB "
        cQuery += " INNER JOIN " + RetSqlName("RD0") + " RD0 "
        cQuery += " ON RD0_FILIAL = '" + xFilial("RD0") + "' AND "
        cQuery += " RD0_CODIGO = ( SELECT MAX(RD0_CODIGO) FROM " + RetSqlName("RD0") + " AUX "
        cQuery += " WHERE AUX.RD0_CIC = PKB.PKB_CPF AND AUX.D_E_L_E_T_ = ' ') "
        cQuery += " WHERE RD0_IDRESE <> ' ' AND ( (PKB_FERINI <= '" + DTOS(dDataBase) + "' AND "
        cQuery += " PKB_FERFIM >= '" + DTOS(dDataBase) + "') OR (PKB_AFAINI <= '" + DTOS(dDataBase) + "' AND "
        cQuery += " PKB_AFAFIM >= '" + DTOS(dDataBase) + "') )  AND PKB_RESERV = ' ' "
        cQuery += " AND PKB.D_E_L_E_T_ = ' ' AND RD0.D_E_L_E_T_ = ' ' "
        
        cQuery += " UNION ALL " 
        
        //Remoùùo do status de ausencia
        cQuery += " SELECT RD0_IDRESE, PKB_CPF, RD0_EMAIL, RD0_EMAILC, RD0_LOGINR, RD0_NOME, RD0_SEXO, RD0_XMATRH, "
        cQuery += " RD0_CODIGO, RD0_NOME, PKB.R_E_C_N_O_ RECNO, PKB_RESERV "
        cQuery += " FROM " + RetSqlName("PKB") + " PKB "
        cQuery += " INNER JOIN " + RetSqlName("RD0") + " RD0 "
        cQuery += " ON RD0_FILIAL = '" + xFilial("RD0") + "' AND "
        cQuery += " RD0_CODIGO = ( SELECT MAX(RD0_CODIGO) FROM " + RetSqlName("RD0") + " AUX "
        cQuery += " WHERE AUX.RD0_CIC = PKB.PKB_CPF AND AUX.D_E_L_E_T_ = ' ') "
        cQuery += " WHERE RD0_IDRESE <> ' ' AND ( PKB_FERFIM <= '" + DTOS(dDataBase) + "' OR PKB_AFAFIM <= '" + DTOS(dDataBase) + "')  
        cQuery += " AND PKB_RESERV <> ' ' AND PKB.D_E_L_E_T_ = ' ' AND RD0.D_E_L_E_T_ = ' ' "

        If Select(cAlsAus) > 0; (cAlsAus)->(dbCloseArea()); Endif  
        dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlsAus,.T.,.T.)

        //Criaùùo do log
        aCriaServ := U_MonitRes("000021", 1, nQtdReg)

        //Id gerado na criaùùo do serviùo
        cIdPZB := aCriaServ[2]

        //Consumo a funùùo que gera o acesso com o reserve e retorna o token
        aLogin := U_GerAcessRes()
        
        //Requisiùùo de acesso ao reserve. 
        If !aLogin[1]
            //Finaliza o processo na PZB
            U_MonitRes("000021", 3, , cIdPZB, , .F.)

            (cAlsAus)->(dbCloseArea())

            Return()

        Else
            cToken := aLogin[2]
            
            AADD(aHeader, "SecurityToken:" + cToken )
            AADD(aHeader, "Content-Type: application/json")

        EndIf

        DbSelectArea("PKB")

        While !(cAlsAus)->(Eof())

            cChave := (cAlsAus)->RD0_CODIGO
            
            aAuxReq := aRequest := U_ResInteg("000021", , aHeader,, .T., "/" + Alltrim( (cAlsAus)->RD0_IDRESE), 2)

            If aAuxReq[1]

                cJsonAux    := aAuxReq[3]
                cJsonAux    := Left(cJsonAux, RAT("}", cJsonAux) - 1) 
                
                If Empty( (cAlsAus)->PKB_RESERV ) 
                    cJson       := ',"ausente":true}'
                Else
                    cJson       := ',"ausente":false}'
                EndIf
                
                cJson := cJsonAux + cJson
                cJson := EncodeUTF8(cJson)
            
            Else

                cMenssagem  := "Erro ao realizar get para buscar cadastro atual do usuùrio."
                cJsoRec     := aAuxReq[3]
                
                (cAlsAus)->(DbSkip())
                
                U_MonitRes("000021", 2, , cIdPZB, cMenssagem, .F., cChave, , cJsoRec, (cAlsAus)->RD0_NOME, lReprocess, lLote, cIdPZC)

                Loop

            EndIf        

            //Realiza requisiùùo
            aRequest := U_ResInteg("000021", cJson, aHeader,, .T.)

            If aRequest[1]

                cMenssagem  := "Atualizado com sucesso."
                cJsoRec     := aRequest[3]
                                
                U_MonitRes("000021", 2, , cIdPZB, cMenssagem, .T., cChave, cJson, cJsoRec, (cAlsAus)->RD0_NOME, lReprocess, lLote, cIdPZC)

                PKB->(DbGoTo( (cAlsAus)->RECNO ))

                PKB->(RecLock("PKB",.F.))

                    PKB->PKB_RESERV := "1"
                
                PKB->(MsUnlock())

            Else

                cMenssagem  := "Falha na atualizaùùo."
                cJsoRec     := aRequest[3]

                U_MonitRes("000021", 2, , cIdPZB, cMenssagem, .F., cChave, cJson, cJsoRec, aDados[nX][2], lReprocess, lLote, cIdPZC)

            EndIf
            
            (cAlsAus)->(DbSkip())

        End

        //Finaliza o processo na PZB
        U_MonitRes("000021", 3, , cIdPZB, , .T.)
    
    EndIf

    (cAlsAus)->(dbCloseArea())

Return()


//------------------------------------------------------------------------
/*/{Protheus.doc} ResIntForn
Funùùo para realizar integraùùo dos fornecedores.

@author By Wise

@since 22/11/2018
/*/
//-----------------------------------------------------------------------

User Function ResIntForn(aDados, lReprocess, lLote, cIdPZC)

Local aLogin    := {}
Local aCriaServ := {}
Local aHeader   := {}
Local aRequest  := {}
Local aRet      := {}
Local cIdPZB    := ""
Local cToken    := ""
Local cJson     := ""
Local cJsoRec   := ""
Local nX
Local nQtdReg
Local oRet

Default cIdPZC      := ""
Default lReprocess  := .F.
Default lLote       := .F.
Default aDados      := {}

    nQtdReg := Len(aDados)

    //Cria o log do serviùo no monitor
    If !lReprocess .Or. (lReprocess .And. lLote)
        
        aCriaServ := U_MonitRes("000022", 1, nQtdReg)

        //Id gerado na criaùùo do serviùo
        cIdPZB := aCriaServ[2]

    EndIf
    
    If nQtdReg == 0
        U_MonitRes("000022", 3, , cIdPZB, , .F.)
        Return()
    EndIf
    
    //Requisiùùo do acesso
    aLogin := U_GerAcessRes()
    
    //Requisiùùo de acesso ao reserve. 
    If !aLogin[1]
        
        //Finaliza o processo na PZB
        U_MonitRes("000022", 3, , cIdPZB, , .F.)

    Else
        cToken := aLogin[2]
        
        AADD(aHeader, "SecurityToken:" + cToken )
        AADD(aHeader, "Content-Type: application/json")

    EndIf
       
    For nX := 1 to len(aDados)

        cChave := aDados[nX][5]   
        
        cJson := '{'  
        cJson += '"nome":"'     + Alltrim(EncodeUTF8(aDados[nX][1])) + '",'
        cJson += '"cnpj":"'     + Alltrim(EncodeUTF8(aDados[nX][2])) + '",'
        cJson += '"agencia":"'  + Alltrim(EncodeUTF8(aDados[nX][3])) + '",'
        cJson += '"conta":"'    + Alltrim(EncodeUTF8(aDados[nX][4])) + '",'
        cJson += '"modelo":"FaturaEletronicaDeCartaoPCard",'
        cJson += '"tiposDeItem":[]'
        cJson += '}'

        aRequest := U_ResInteg("000022", cJson, aHeader,, .T.)     

        If aRequest[1]
            
            oRet := aRequest[2]

            cMenssagem  := "Incluso com sucesso."
            cJsoRec     := aRequest[3]

            AADD(aRet, {aDados[nX][5], aDados[nX][1], aDados[nX][2], aDados[nX][3], aDados[nX][4], Alltrim(cValToChar(oRet:Id)) })

            DbSelectArea("SA2")
            SA2->(DbSetOrder(1))
            
            If SA2->(MsSeek(xFilial("SA2") + cChave))

                SA2->(RecLock("SA2"),.F.)

                    SA2->A2_XIDRESE := Alltrim(cValToChar(oRet:Id))

                SA2->(MsUnlock())

            EndIf
            
            U_MonitRes("000022", 2, , cIdPZB, cMenssagem, .T., cChave, cJson, cJsoRec, aDados[nX][1], lReprocess, lLote, cIdPZC)

        Else
            
            cMenssagem  := "Falha na inclusùo."
            cJsoRec     := aRequest[3]

            U_MonitRes("000022", 2, , cIdPZB, cMenssagem, .F., cChave, cJson, cJsoRec, aDados[nX][1], lReprocess, lLote, cIdPZC)
        
        EndIf

    Next nX

    //Finaliza o processo na PZB
    U_MonitRes("000022", 3, , cIdPZB, , .T.)

Return(aRet)

//------------------------------------------------------------------------
/*/{Protheus.doc} fTratObj
Remove tags que ù array.

@author By Wise

@since 14/11/2018
/*/
//-----------------------------------------------------------------------

Static Function fTratObj(oObj, aVdds, aFalsos)

Local cRet := ""

    oObj:favorecidos    := Nil
    oObj:Grupos         := Nil
    oObj:Departamentos  := Nil

    //Nem sempre o reHEserve manda todos campos no JSON, exemplo proprieade solicitante.
    /*If Len(aVdds) > 0 .Or. Len(aFalsos) > 0
        oObj := fExcFlags(oObj, .T.)
    EndIf*/

    cRet := FWJsonSerialize(oObj,.F.,.T.)

    If EncodeUTF8(cRet) <> Nil
        cRet := EncodeUTF8(cRet)
    EndIf

Return(cRet)

//------------------------------------------------------------------------
/*/{Protheus.doc} fVrfSX5
Verifica se X5 informa que o item deve ser substituido

@author By Wise

@since 14/11/2018
/*/
//-----------------------------------------------------------------------

Static Function fVrfSX5(cIdSX5)

Local cQuery    := ""
Local cRet      := ""
Local cAlsSX5   := CriaTrab(Nil,.F.)

    cQuery := " SELECT X5_CHAVE, X5_DESCSPA "
    cQuery += " FROM " + RetSqlName("SX5") + " SX5 "
    cQuery += " WHERE X5_TABELA = '_U' AND X5_CHAVE = '" + cIdSX5 + "' AND "
    cQuery += " SX5.D_E_L_E_T_ = ' ' "

    If Select(cAlsSX5) > 0; (cAlsSX5)->(dbCloseArea()); Endif  
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlsSX5,.T.,.T.)

    If !Empty( (cAlsSX5)->X5_DESCSPA )
        cRet := Alltrim(  (cAlsSX5)->X5_DESCSPA )
    EndIf

    (cAlsSX5)->(dbCloseArea())

Return(cRet)

//------------------------------------------------------------------------
/*/{Protheus.doc} fVrfSX5
Remove do objeto os campos que sùo tratados como flag.

@author By Wise

@since 14/11/2018
/*/
//-----------------------------------------------------------------------

Static Function fExcFlags(oJsoAux, lAltera)

Default lAltera := .F.

    If !lAltera 

        If ValType(oJsoAux:criaPlano) <> "U"
            oJsoAux:criaPlano := Nil
        EndIf

        If ValType(oJsoAux:editaPlano) <> "U"
            oJsoAux:editaPlano := Nil
        EndIf

        If ValType(oJsoAux:excluiPlano) <> "U"
            oJsoAux:excluiPlano := Nil
        EndIf

        If ValType(oJsoAux:registraDespesa) <> "U"
            oJsoAux:registraDespesa := Nil
        EndIf

        If ValType(oJsoAux:Expense:solicitante) <> "U"
            oJsoAux:Expense:solicitante := Nil
        EndIf

        If ValType(oJsoAux:Expense:Favorecido) <> "U"
            oJsoAux:Expense:Favorecido := Nil
        EndIf

        If ValType(oJsoAux:Expense:financeiro) <> "U"
            oJsoAux:Expense:financeiro := Nil
        EndIf

        If ValType(oJsoAux:preferencias:restricaoServicos:aereo) <> "U"
            oJsoAux:preferencias:restricaoServicos:aereo := Nil
        EndIf

        If ValType(oJsoAux:preferencias:restricaoServicos:hotel) <> "U"
            oJsoAux:preferencias:restricaoServicos:hotel := Nil
        EndIf

        If ValType(oJsoAux:preferencias:restricaoServicos:carro) <> "U"
            oJsoAux:preferencias:restricaoServicos:carro := Nil
        EndIf

        If ValType(oJsoAux:preferencias:restricaoServicos:rodoviario) <> "U"
            oJsoAux:preferencias:restricaoServicos:rodoviario := Nil
        EndIf

        If ValType(oJsoAux:preferencias:restricaoServicos:seguro) <> "U"
            oJsoAux:preferencias:restricaoServicos:seguro := Nil
        EndIf

        If ValType(oJsoAux:preferencias:restricaoServicos:seguro) <> "U"
            oJsoAux:preferencias:restricaoServicos:seguro := Nil
        EndIf

        If ValType(oJsoAux:Expense:autorizaGrupoEmpresa) <> "U"
            oJsoAux:Expense:autorizaGrupoEmpresa := Nil
        EndIf

        If ValType(oJsoAux:Expense:autorizaPropriosPlanos) <> "U"
            oJsoAux:Expense:autorizaPropriosPlanos := Nil
        EndIf

        If ValType(oJsoAux:Expense:autorizaPlanosSolicitados) <> "U"
            oJsoAux:Expense:autorizaPlanosSolicitados := Nil
        EndIf

        If ValType(oJsoAux:Expense:recebeSolicitacaoAutorizacao) <> "U"
            oJsoAux:Expense:recebeSolicitacaoAutorizacao := Nil
        EndIf

        If ValType(oJsoAux:Expense:recebeSolicitacaoPagamento) <> "U"
            oJsoAux:Expense:recebeSolicitacaoPagamento := Nil
        EndIf

        If ValType(oJsoAux:Expense:recebeConfirmacaoAutorizacao) <> "U"
            oJsoAux:Expense:recebeConfirmacaoAutorizacao := Nil
        EndIf

        If ValType(oJsoAux:Expense:registraDespesa) <> "U"
            oJsoAux:Expense:registraDespesa := Nil
        EndIf

        If ValType(oJsoAux:Expense:solicitaAdiantamentos) <> "U"
            oJsoAux:Expense:solicitaAdiantamentos := Nil
        EndIf

    EndIf


Return(oJsoAux)

//------------------------------------------------------------------------
/*/{Protheus.doc} fInclFlags
Inclui as flags pertinentes aos parametros

@author By Wise

@since 14/11/2018
/*/
//-----------------------------------------------------------------------

Static Function fInclFlags(cJsoAux, aExcTrue, aExcFalse)

Local nX := 1 
    
    //Adiciona as tags verdadeiras para os itens que nùo sùo array.
    For nX := 1 to len(aExcTrue)

        Do Case
            
            Case aExcTrue[nX][1] == "PS1_CRPLAN"
                cJsoAux += ","
                cJsoAux += '"criaPlano":true'

            Case aExcTrue[nX][1] == "PS1_EDTPLA"
                cJsoAux += ","
                cJsoAux += '"editaPlano":true'

            Case aExcTrue[nX][1] == "PS1_EXCPLA"
                cJsoAux += ","
                cJsoAux += '"excluiPlano":true'

            Case aExcTrue[nX][1] == "PS1_REGDES"
                cJsoAux += ","
                cJsoAux += '"registraDespesa":true'

            Case aExcTrue[nX][1] == "PS1_GRPEMP" .And. (lIsPerf .And. lIsAprov)
                cJsoAux += ","
                cJsoAux += '"autorizaGrupoEmpresa":true'
	
        EndCase

    Next nX

    //Adiciona as tags falsas para os itens que nùo sùo array.
    For nX := 1 to len(aExcFalse)

        Do Case
            
            Case aExcFalse[nX][1] == "PS1_CRPLAN"
                cJsoAux += ","
                cJsoAux += '"criaPlano":false'

            Case aExcFalse[nX][1] == "PS1_EDTPLA"
                cJsoAux += ","
                cJsoAux += '"editaPlano":false'

            Case aExcFalse[nX][1] == "PS1_EXCPLA"
                cJsoAux += ","
                cJsoAux += '"excluiPlano":false'

            Case aExcFalse[nX][1] == "PS1_REGDES"
                cJsoAux += ","
                cJsoAux += '"registraDespesa":false'

            Case aExcFalse[nX][1] == "PS1_GRPEMP"
                 If !lIsPerf .And. !lIsAprov
	                cJsoAux += ","
					cJsoAux += '"autorizaGrupoEmpresa":false'
				Endif
               
           EndCase

    Next nX
    
    //Para tratar as tags de restriùùes.
    cJsoAux += ','
    cJsoAux += '"preferencias": {'
    cJsoAux += '"restricaoServicos": {'
    
    If aScan(aExcTrue, {|x| Alltrim(x[1]) == "PS1_RESAER" }) > 0
        cJsoAux += '"aereo":true
    Else
        cJsoAux += '"aereo":false
    EndIf

    If aScan(aExcTrue, {|x| Alltrim(x[1]) == "PS1_RESHOT" }) > 0
        cJsoAux += ','
        cJsoAux += '"hotel":true
    Else
        cJsoAux += ','
        cJsoAux += '"hotel":false
    EndIf

    If aScan(aExcTrue, {|x| Alltrim(x[1]) == "PS1_RESCAR" }) > 0
        cJsoAux += ','
        cJsoAux += '"carro":true
    Else
        cJsoAux += ','
        cJsoAux += '"carro":false
    EndIf

    If aScan(aExcTrue, {|x| Alltrim(x[1]) == "PS1_RESROD" }) > 0
        cJsoAux += ','
        cJsoAux += '"rodoviario":true
    Else
        cJsoAux += ','
        cJsoAux += '"rodoviario":false
    EndIf

    If aScan(aExcTrue, {|x| Alltrim(x[1]) == "PS1_RESSEG" }) > 0
        cJsoAux += ','
        cJsoAux += '"seguro":true
        cJsoAux += '}}
    Else
        cJsoAux += ','
        cJsoAux += '"seguro":false
        cJsoAux += '}}
    EndIf

    //Para tratar as tags do expense
    cJsoAux += ','
    cJsoAux += '"expense":{'

    If aScan(aExcTrue, {|x| Alltrim(x[1]) == "PS1_ADIANT" }) > 0
        
        cJsoAux += '"registraDespesa":true,'
        cJsoAux += '"solicitaAdiantamentos":true,'

        If aScan(aExcTrue, {|x| Alltrim(x[1]) == "PS1_SOLAUT" }) > 0        
			cJsoAux += '"recebeSolicitacaoAutorizacao":true,'
		Else
			cJsoAux += '"recebeSolicitacaoAutorizacao":false,'
		Endif
        
        If aScan(aExcTrue, {|x| Alltrim(x[1]) == "PS1_SOLPAG" }) > 0        
			cJsoAux += '"recebeSolicitacaoPagamento":true,'
        Else
        	cJsoAux += '"recebeSolicitacaoPagamento":false,'
		Endif
        
        If aScan(aExcTrue, {|x| Alltrim(x[1]) == "PS1_CONFAT" }) > 0        
			cJsoAux += '"recebeConfirmacaoAutorizacao":true,'
        Else
        	cJsoAux += '"recebeConfirmacaoAutorizacao":false,'
        Endif
        
        cJsoAux += '"recebeSolicitacaoAutorizacao":true,'
        cJsoAux += '"recebeSolicitacaoPagamento":true,'
        cJsoAux += '"recebeConfirmacaoAutorizacao":true,'
        
        If aScan(aExcTrue, {|x| Alltrim(x[1]) == "PS1_FAVORE" }) > 0
            cJsoAux += '"favorecido":true,'
        Else
            cJsoAux += '"favorecido":false,'
        EndIf

        If aScan(aExcTrue, {|x| Alltrim(x[1]) == "PS1_SOLICI" }) > 0
            cJsoAux += '"solicitante":true,'
        Else
            cJsoAux += '"solicitante":false,'
        EndIf

        If aScan(aExcTrue, {|x| Alltrim(x[1]) == "PS1_FINAN" }) > 0
            cJsoAux += '"financeiro":true,'
        Else
            cJsoAux += '"financeiro":false,'
        EndIf

        If aScan(aExcTrue, {|x| Alltrim(x[1]) == "PS1_GRPEMP" }) > 0 .Or. (lIsPerf .And. lIsAprov)
            cJsoAux += '"autorizaGrupoEmpresa":true,'
        Else
            cJsoAux += '"autorizaGrupoEmpresa":false,'
        EndIf
        
        If aScan(aExcTrue, {|x| Alltrim(x[1]) == "PS1_PRPPLA" }) > 0
           cJsoAux += '"autorizaPropriosPlanos":true,'
       	Else
       	   cJsoAux += '"autorizaPropriosPlanos":false,'
       	Endif
       	
		If aScan(aExcTrue, {|x| Alltrim(x[1]) == "PS1_PLASOL" }) > 0
			cJsoAux += '"autorizaPlanosSolicitados":true'
       	Else
       	   	cJsoAux += '"autorizaPlanosSolicitados":false'
       	Endif
       	   
        cJsoAux += '}'
        
    Else
        
		cJsoAux += '"registraDespesa":true,'
        cJsoAux += '"solicitaAdiantamentos":false,'
        
        If aScan(aExcTrue, {|x| Alltrim(x[1]) == "PS1_SOLAUT" }) > 0        
			cJsoAux += '"recebeSolicitacaoAutorizacao":true,'
		Else
			cJsoAux += '"recebeSolicitacaoAutorizacao":false,'
		Endif
        
        If aScan(aExcTrue, {|x| Alltrim(x[1]) == "PS1_SOLPAG" }) > 0        
			cJsoAux += '"recebeSolicitacaoPagamento":true,'
        Else
        	cJsoAux += '"recebeSolicitacaoPagamento":false,'
		Endif
        
        If aScan(aExcTrue, {|x| Alltrim(x[1]) == "PS1_CONFAT" }) > 0        
			cJsoAux += '"recebeConfirmacaoAutorizacao":true,'
        Else
        	cJsoAux += '"recebeConfirmacaoAutorizacao":false,'
        Endif
        
        If aScan(aExcTrue, {|x| Alltrim(x[1]) == "PS1_FAVORE" }) > 0
            cJsoAux += '"favorecido":true,'
        Else
            cJsoAux += '"favorecido":false,'
        EndIf

        If aScan(aExcTrue, {|x| Alltrim(x[1]) == "PS1_SOLICI" }) > 0
            cJsoAux += '"solicitante":true,'
        Else
            cJsoAux += '"solicitante":false,'
        EndIf

        If aScan(aExcTrue, {|x| Alltrim(x[1]) == "PS1_FINAN" }) > 0
            cJsoAux += '"financeiro":true,'
        Else
            cJsoAux += '"financeiro":false,'
        EndIf

        If aScan(aExcTrue, {|x| Alltrim(x[1]) == "PS1_GRPEMP" }) > 0 .Or. (lIsPerf .And. lIsAprov)
            cJsoAux += '"autorizaGrupoEmpresa":true,'
        Else
            cJsoAux += '"autorizaGrupoEmpresa":false,'
        EndIf
        
        If aScan(aExcTrue, {|x| Alltrim(x[1]) == "PS1_PRPPLA" }) > 0
           cJsoAux += '"autorizaPropriosPlanos":true,'
       	Else
       	   cJsoAux += '"autorizaPropriosPlanos":false,'
       	Endif
       	
		If aScan(aExcTrue, {|x| Alltrim(x[1]) == "PS1_PLASOL" }) > 0
			cJsoAux += '"autorizaPlanosSolicitados":true'
       	Else
       	   	cJsoAux += '"autorizaPlanosSolicitados":false'
       	Endif

        cJsoAux += '}'


    EndIf

Return(cJsoAux)

//-------------------------------------------------------------------
/*/{Protheus.doc} ResVrfApr
Verifica os usuùrios da alùada de aprovaùùo.

@author By Wise

@since 30/09/2018
/*/
//-------------------------------------------------------------------

User Function ResVrfApr(aDados, lProjet, lDelet)

Local cQuery    := ""
Local cAlsTrb   := CriaTrab(Nil,.F.)
Local cAlsDel   := CriaTrab(Nil,.F.)
Local cProjet   := ""
Local cUsers    := ""
Local nX

Default aDados  := {}
Default lProjet := .F.
Default lDelet  := .F.

    //Se for projetos.
    If lProjet

        //Verifica se o usuùrio se encontra ainda em alguma alùada
        cQuery := " SELECT MAX(PS8_CODIGO), PS8_IDPROJ, PS8_IDAPRO "
        cQuery += " FROM " + RetSqlName("PS8") + " PS8 "
        cQuery += " WHERE PS8_IDPROJ = '" + aDados[2] + "' AND PS8_IDAPRO = '" + aDados[3] + "' "
        cQuery += " AND PS8.D_E_L_E_T_ = ' ' "
        cQuery += " GROUP BY PS8_IDPROJ, PS8_IDAPRO "

        If Select(cAlsTrb) > 0; (cAlsTrb)->(dbCloseArea()); Endif  
        dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlsTrb,.T.,.T.)

        //Se nùo for encontrado em nenhum alùada remove o perfil de aprovador caso contrario fixa como aprovador.
        If (cAlsTrb)->(Eof())
            U_PartReserv(.F.,aDados[3], .F., , , , .T., , .F.)
        Else
            U_PartReserv(.F.,aDados[3], .F., , , , .T., , .T.)
        EndIf

        (cAlsTrb)->(dbCloseArea())

    //Busca alùada de centro de custos.
    Else

        cQuery := " SELECT AL_DESC, AL_USER, AL_NIVEL, RD0_IDRESE, RD0_NOME, CTT_XWRID, SAL.R_E_C_N_O_ RECNO, SAL.D_E_L_E_T_ DELETADO "
        cQuery += " FROM " + RetSqlName("SAL") + " SAL "
        cQuery += " INNER JOIN " + RetSqlName("RD0") + " RD0 "
        cQuery += " ON RD0_FILIAL = '" + xFilial("RD0") + "' AND "
        cQuery += " RD0_USER = AL_USER AND RD0.D_E_L_E_T_ = ' ' "
        cQuery += " INNER JOIN " + RetSqlName("CTT") + " CTT "
        cQuery += " ON CTT_FILIAL = '" + xFilial("CTT") + "' AND "
        cQuery += " CTT_CUSTO = AL_DESC AND CTT.D_E_L_E_T_ = ' ' "
        cQuery += " WHERE AL_FILIAL = '" + xFilial("SAL") + "' AND SAL.R_E_C_N_O_ = " + cValToChar(aDados[5]) + " " 

        If Select(cAlsTrb) > 0; (cAlsTrb)->(dbCloseArea()); Endif  
        dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlsTrb,.T.,.T.)

        If !(cAlsTrb)->(Eof()) .And. !lDelet
            U_PartReserv(.F., (cAlsTrb)->RD0_IDRESE, .F., , , , .T., , .T.)
        ElseIf !(cAlsTrb)->(Eof()) .And. lDelet
            U_PartReserv(.F., (cAlsTrb)->RD0_IDRESE, .F., , , , .T., , .F.)
        EndIf

        (cAlsTrb)->(dbCloseArea())

    EndIf 

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fVrfAut
Verifica se o usuùrio ù autorizador.

@author By Wise

@since 30/09/2018
/*/
//-------------------------------------------------------------------

Static Function fVrfAut(cIdReserve)

Local lRet      := .F.
Local cQuery    := ""
Local cAlsAut   := CriaTrab(Nil,.F.)

    //Select de projetos
    cQuery := " SELECT PS8_IDAPRO IDRESERV "
    cQuery += " FROM " + RetSqlName("PS8") + " PS8 "
    cQuery += " WHERE PS8_FILIAL = '" + xFilial("PS8") + "' AND PS8_IDAPRO = '" + cIdReserve + "' AND PS8.D_E_L_E_T_ = ' ' "
    
    cQuery += " UNION ALL "
    
    //Select da SAL
    cQuery += " SELECT RD0_IDRESE IDRESERV "
    cQuery += " FROM " + RetSqlName("SAL") + " SAL "
    cQuery += " INNER JOIN " + RetSqlName("RD0") + " RD0 "
    cQuery += " ON RD0_FILIAL = '" + xFilial("RD0") + "' AND "
    cQuery += " RD0_USER = AL_USER AND RD0.D_E_L_E_T_ = ' ' "
    cQuery += " WHERE RD0_FILIAL = '" + xFilial("RD0") + "' AND TRIM(RD0_IDRESE) = '" + cIdReserve + "' AND RD0_USER <> ' ' AND RD0.D_E_L_E_T_ = ' ' "
    cQuery += " AND SAL.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery(cQuery)

    If Select(cAlsAut) > 0; (cAlsAut)->(dbCloseArea()); Endif  
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlsAut,.T.,.T.)

    If !(cAlsAut)->(Eof())
        lRet := .T.
    EndIf

    (cAlsAut)->(dbCloseArea())

Return(lRet)