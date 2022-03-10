#include "rwmake.ch"
#include "tbiconn.ch"
#include "tbicode.ch"
#include "colors.ch"
#include "font.ch"
#include "ap5mail.ch"  

User Function DBFUSU()

	Local cPerg := PadR("XNU001",10)
	
	ValidPerg(cPerg)
	
	Pergunte(cPerg,.F.)

	@ 000,000 To 160,350 Dialog _WndMain TITLE "Auditoria de Usuários MWL"
	@ 005,005 To 040,165
	@ 015,010 Say OemToAnsi("Este programa ira gerar dois Arquivos DBF´s para ")
	@ 025,010 say OemToAnsi("Abertura no Excel, MENUS.DBF e ACESSOS.DBF" )
	@ 055,080 Bmpbutton Type 1 Action ProcMenus()
	@ 055,110 Bmpbutton Type 2 Action Close(_WndMain)
	@ 055,140 Bmpbutton Type 5 Action Pergunte(cPerg,.T.)
	Activate Dialog _WndMain Centered
	
Return

Static Function ProcMenus()
      
	Close(_WndMain)
	Processa({|| RunReport()},"Processando ..." )
	
Return

Static Function RunReport()
	
	Local cNomeArq	:= "MENUS.DBF"
	Local cNomeAce	:= "ACESSOS.DBF"
	Local cNomeRel	:= "MENUS.CSV"	
	Local cNomeRAc	:= "ACESSOS.CSV"	
	Local aUsuario	:= AllUsers()
	Local aMenuAll	:= {}
	Local aAdminXnu	:= { "SIGALOJA","SIGAFIS","SIGACOM","SIGACON","SIGAGPE","SIGAEST","SIGAFAT","SIGAFIN","SIGAPON" }
	
	Local aCampos	:= {{"COD","C",6,0},{"MENU","C",50,0},{"GRUPO","C",35,0},{"DESCRI","C",35,0},{"MODO","C",1,0},{"TIPO","C",15,0},;
	                    {"FUNCAO","C",12,0},{"ACS","C",10,0},{"MODULO","C",40,0},{"ARQS","C",255,0},{"PESQ","C",1,0},{"VISU","C",1,0},;
	                    {"INCLUIR","C",1,0},{"ALTERAR","C",1,0},{"EXCLUIR","C",1,0},{"A6","C",1,0},{"A7","C",1,0},{"A8","C",1,0},;
	                    {"A9","C",1,0},{"A0","C",1,0},{"LOGIN","C",20,0},{"NOME","C",35,0},{"DEPTO","C",30,0},{"CARGO","C",30,0},;
	                    {"EMAIL","C",35,0}}
	
	Local cRelTrb	:= CriaTrab(aCampos,.T.)
	Local aAcessos  := {}                   
	Local aModulos  := fModulos()
	Local aCampos2	:= {{"COD","C",6,0},{"ACESSO","C",40,0},{"LOGIN","C",20,0},{"NOME","C",35,0},{"DEPTO","C",30,0},{"CARGO","C",30,0},{"EMAIL","C",35,0}}
	Local cAceTrb	:= CriaTrab(aCampos2,.T.)

	Local cFile  	:= "C:\TEMP\Menus_"+DTOS(dDataBase)+"_"+Replace(Time(),":","-")+".csv" 
	Local nH     	:= fCreate(cFile) 
	Local cFile2  	:= "C:\TEMP\Acessos_"+DTOS(dDataBase)+"_"+Replace(Time(),":","-")+".csv" 
	Local nH2     	:= fCreate(cFile2) 
	Local s,x,a,b,c,z := 0

	If nH == -1 
		MsgStop("Falha ao criar arquivo - erro "+str(ferror())) 
		Return 
	Endif 

	If nH2 == -1 
		MsgStop("Falha ao criar arquivo - erro "+str(ferror())) 
		Return 
	Endif 
	
	AADD(aAcessos,'Excluir Produtos')
	AADD(aAcessos,'Alterar Produtos')
	AADD(aAcessos,'Excluir Cadastros')
	AADD(aAcessos,'Aletar Solicit.Compras')
	AADD(aAcessos,'Excluir Solicit.Compras')
	AADD(aAcessos,'Alterar Pedidos Compras')
	AADD(aAcessos,'Excluir Pedidos Compras')
	AADD(aAcessos,'Analisar Cotações')
	AADD(aAcessos,'Relat.Ficha Cadastral')
	AADD(aAcessos,'Relat Bancos')
	AADD(aAcessos,'Relacao Solicit.Compras')
	AADD(aAcessos,'Relacao de Pedidos Compra')
	AADD(aAcessos,'Alterar Estruturas')
	AADD(aAcessos,'Excluir Estruturas')
	AADD(aAcessos,'Alterar TES')
	AADD(aAcessos,'Excluir TES')
	AADD(aAcessos,'Inventario')
	AADD(aAcessos,'Fechamento Mensal')
	AADD(aAcessos,'Proc Diferenca Inventario')
	AADD(aAcessos,'Alterar Pedidos de Venda')
	AADD(aAcessos,'Excluir Pedidos de Venda')
	AADD(aAcessos,'Alterar Help´s')
	AADD(aAcessos,'Substituição de TItulos')
	AADD(aAcessos,'Inclusão do Dados Via F3')
	AADD(aAcessos,'Rotina de Atendimento')
	AADD(aAcessos,'Proc. Troco')
	AADD(aAcessos,'Proc. Sangria')
	AADD(aAcessos,'Borderô Chques Pré-Dat.')
	AADD(aAcessos,'Rotina de Pagamento')
	AADD(aAcessos,'Rotina de Recebimento')
	AADD(aAcessos,'Troca de Mercadorias')
	AADD(aAcessos,'Acesso Tabela de Preços')
	AADD(aAcessos,'Não Utilizado')
	AADD(aAcessos,'Não Utilizado')
	AADD(aAcessos,'Acesso COndicao Negociada')
	AADD(aAcessos,'Alterar Database do Sist.')
	AADD(aAcessos,'Alterar Empenhos de OPs.')
	AADD(aAcessos,'Não Utilizado')
	AADD(aAcessos,'Form.Preços Todos Niveis')
	AADD(aAcessos,'Configura Venda Rapida')
	AADD(aAcessos,'Abrir/Fechar Caixa')
	AADD(aAcessos,'Excluir Nota/Orç Loja')
	AADD(aAcessos,'Alterar Bem Ativo Fixo')
	AADD(aAcessos,'Excluir Bem Ativo Fixo')
	AADD(aAcessos,'Incluir Bem Via Copia')
	AADD(aAcessos,'Tx Juros Condic Negociada')
	AADD(aAcessos,'Liberacao Venda Forcad TEF')
	AADD(aAcessos,'Cancelamento Venda TEF')
	AADD(aAcessos,'Cadastra Moeda na Abertura')
	AADD(aAcessos,'Alterar Num. da NF')
	AADD(aAcessos,'Emitir NF Retorativa')
	AADD(aAcessos,'Excluir Baixa - Receber')
	AADD(aAcessos,'Excluir Baixa - Pagar')
	AADD(aAcessos,'Incluir Tabelas')
	AADD(aAcessos,'Alterar Tabelas')
	AADD(aAcessos,'Excluir Tabelas')
	AADD(aAcessos,'Incluir Contratos')
	AADD(aAcessos,'Alterar Contratos')
	AADD(aAcessos,'Excluir Contratos')
	AADD(aAcessos,'Uso Integração SIGAEIC')
	AADD(aAcessos,'Incluir Emprestimo')
	AADD(aAcessos,'Alterar Emprestimo')
	AADD(aAcessos,'Excluir Emprestimo')
	AADD(aAcessos,'Incluir Leasing')
	AADD(aAcessos,'Alterar Leasing')
	AADD(aAcessos,'Excluir Leasing')
	AADD(aAcessos,'Incluir Imp.Nao Financ.')
	AADD(aAcessos,'Alterar Imp.Nao Financ.')
	AADD(aAcessos,'Excluir Imp.Nao Financ.')
	AADD(aAcessos,'Incluir Imp.Financiada')
	AADD(aAcessos,'Alterar Imp.Financiada')
	AADD(aAcessos,'Excluir Imp.Financiada')
	AADD(aAcessos,'Incluir Imp.Fin.Export.')
	AADD(aAcessos,'ALterar Imp.Fin.Export.')
	AADD(aAcessos,'Excluir Imp.Fin.Export.')
	AADD(aAcessos,'Incluir Contrato')
	AADD(aAcessos,'Alterar Contrato')
	AADD(aAcessos,'Excluir Contrato')
	AADD(aAcessos,'Lancar Taxa Libor')
	AADD(aAcessos,'Consolidar Empresas')
	AADD(aAcessos,'Incluir Cadastros')
	AADD(aAcessos,'Alterar Cadastros')
	AADD(aAcessos,'Incluir Cotacao Moedas')
	AADD(aAcessos,'Alterar Cotacao Moedas')
	AADD(aAcessos,'Excluir Cotacao Moedas')
	AADD(aAcessos,'Incluir Corretoras')
	AADD(aAcessos,'Alterar Corretoras')
	AADD(aAcessos,'Excluir Corretoras')
	AADD(aAcessos,'Incluir Imp./Exp./Cons')
	AADD(aAcessos,'Alterar Imp./Exp./Cons')
	AADD(aAcessos,'Excluir Imp./Exp./Cons')
	AADD(aAcessos,'Baixar Solicitacoes')
	AADD(aAcessos,'Visualiza Arquivo Limite')
	AADD(aAcessos,'Imprime Doctos.Cancelados')
	AADD(aAcessos,'Reativa Doctos.Cancelados')
	AADD(aAcessos,'Consulta Doctos.Obsoletos')
	AADD(aAcessos,'Imprime Doctos.Obsoletos')
	AADD(aAcessos,'Consulta Doctos.Vencidos')
	AADD(aAcessos,'Imprime Doctos.Vencidos')
	AADD(aAcessos,'Def.Laudo Final Entrega')
	AADD(aAcessos,'Imprime Param Relatorios')
	AADD(aAcessos,'Transfere Pendencias')
	AADD(aAcessos,'Usa relatorio por e-mail')
	AADD(aAcessos,'Consulta posicao cliente')
	AADD(aAcessos,'Manuten. Aus Temp. Todos')
	AADD(aAcessos,'Manuten. Aus. Temp Usuario')
	AADD(aAcessos,'Formação de Preço')
	AADD(aAcessos,'Gravar Resposta Parametros')
	AADD(aAcessos,'Configurar Consulta F3')
	AADD(aAcessos,'Permite Alterar Configuração de Impres.')
	AADD(aAcessos,'Gerar Rel. em Disco Local')
	AADD(aAcessos,'Gerar Rel. no Servidor')
	AADD(aAcessos,'Incluir Solic. Compras')
	AADD(aAcessos,'MBrowse - Visualiza outras filiais')
	AADD(aAcessos,'MBrowse - Edita registros de outras filiais')
	AADD(aAcessos,'MBrowse - Permite o uso de filtro')
	AADD(aAcessos,'F3 - Permite o uso de filtro')
	AADD(aAcessos,'MBrowse - Permite a Configuração de Colunas')
	AADD(aAcessos,'Altera Orçamento Aprovado')
	AADD(aAcessos,'Revisa Orçamento Aprovado')
	AADD(aAcessos,'Usa Impressora no Server')
	AADD(aAcessos,'Usa Impressora no Client')
	AADD(aAcessos,'Agendar Processos/Relatórios')
	AADD(aAcessos,'Processos Identicos na MDI')
	AADD(aAcessos,'Datas diferentes na MDI')
	AADD(aAcessos,'Cad.Cli. no Catalogo E-mail')
	AADD(aAcessos,'Cad.For. no Catalogo E-mail')
	AADD(aAcessos,'Cad.Ven. no Catalogo E-mail')
	AADD(aAcessos,'Impr.informações personalizadas')
	AADD(aAcessos,'Respeita Parametro MV_WFMESSE')
	AADD(aAcessos,'Aprovar/Rejeitar Pre Estrutura')
	AADD(aAcessos,'Criar Estrutura com base em Pré Estrut')
	AADD(aAcessos,'Gerir Etapas')
	AADD(aAcessos,'Gerir Despesas')
	AADD(aAcessos,'Liberar Despesa para Faturamento')
	AADD(aAcessos,'Lib. Ped. Venda(Credito)')
	AADD(aAcessos,'LIb. Ped. Venda(Estoque)')
	AADD(aAcessos,'Habilitar opção Executar(Ctrl+R)')
	AADD(aAcessos,'Permite incluir Ordem de Produção')
	AADD(aAcessos,'Acesso via ActiveX')
	AADD(aAcessos,'Excluir Bens')
	AADD(aAcessos,'Rateio do item por centro de custo')
	AADD(aAcessos,'Alterar o cadastro de clientes')
	AADD(aAcessos,'Excluir Cadastro de clientes')
	AADD(aAcessos,'Habilitar Filtros nos relatórios')
	AADD(aAcessos,'Contatos no Catalogo E-mail')
	AADD(aAcessos,'Criar formulas nos relatorios')
	AADD(aAcessos,'Personalizar relatorios')
	AADD(aAcessos,'Acesso ao cadastro de lotes')
	AADD(aAcessos,'Gravar Resposta Parametros por Empresa')
	AADD(aAcessos,'Manutenção no Repositório de Imagens')
	AADD(aAcessos,'Criar Relatórios Personalizáveis')
	AADD(aAcessos,'Permissão para utilizar o TOII')
	AADD(aAcessos,'Acesso ao SigaRPM')
	AADD(aAcessos,'Maiúscula/Minúsculo na consulta padrão')
	AADD(aAcessos,'Valida acesso do grupo por Emp/Filial')
	AADD(aAcessos,'Acessa Base Instalada no Cad. Técnico')
	AADD(aAcessos,'Desabilita opção usuários do menu')
	AADD(aAcessos,'Impressão local p/ componente gráfico')
	AADD(aAcessos,'Impressão em planilha')
	AADD(aAcessos,'Acesso a scripts confidenciais')
	AADD(aAcessos,'Qualificação de Suspects')
	AADD(aAcessos,'Execução de scripts dinâmicos')
	AADD(aAcessos,'MDI - Permite encerrar ambiente pelo X')
	AADD(aAcessos,'Permite utilizar o WalkThru')
	AADD(aAcessos,'Geração de Forecast')
	AADD(aAcessos,'Execução de Mashups')
	AADD(aAcessos,'Permite Exportar Planilha PMS para Excel')
	AADD(aAcessos,'Gravar Filtro do Browse com Empresa/Filial')
	AADD(aAcessos,'Exportar telas para Excel (Mod1 e 3)')
	AADD(aAcessos,'Se Administrador, pode utilizar o SIGACFG')
	AADD(aAcessos,'Se Administrador, pode utilizar o APSDU')
	AADD(aAcessos,'Se acessa APSDU, é Read-Write')
	AADD(aAcessos,'Acesso a inscrição nos eventos do Eve')
	AADD(aAcessos,'MBrowse - Permite utilização do localiza')
	AADD(aAcessos,'Visualização via F3')
	AADD(aAcessos,'Excluir Purchase Order')
	AADD(aAcessos,'Alterar Purchase Order')
	AADD(aAcessos,'Excluir Solicitação de Importação')
	AADD(aAcessos,'Alterar Solicitação de Importação')
	AADD(aAcessos,'Excluir Desembaraço')
	AADD(aAcessos,'Alterar Desembaraço')
	AADD(aAcessos,'Incluir Agenda Médica')
	AADD(aAcessos,'Alterar Agenda Médica')
	AADD(aAcessos,'Excluir Agenda Médica')
	AADD(aAcessos,'Acesso a Fórmulas')

                                                                                                                  
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Abre arquivo de trabalho para gravar os dados do relatorio ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbUseArea(.T.,"DBFCDX",cAceTrb,"TAC",.T.,.F.)
	DbUseArea(.T.,"DBFCDX",cRelTrb,"TRB",.T.,.F.)


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o relatorio ja existe gerado em disco ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	If File(cNomeRel)
		Delete File &(cNomeRel)
	Endif
	If File(cNomeRAc)
		Delete File &(cNomeRAc)
	Endif
	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Obter lista de todos os menus utilizados pelos usuarios ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF MV_PAR01 == 1
		ProcRegua(Len(aUsuario))
		For x := 1 To Len(aUsuario)
			IncProc( "Analisando cadastro de usuarios" )
			aDados1 := aUsuario[x,1]
			aDados2 := aUsuario[x,2]
			aDados3 := aUsuario[x,3] // Menus
   	
			cCod		:= aDados1[1]
			cLogin	:= aDados1[2]
			cNome		:= AllTrim(aDados1[4])
			cDepto	:= AllTrim(aDados1[12])
			cCargo	:= AllTrim(aDados1[13])
			cEMail	:= AllTrim(aDados1[14])

         cAcessos := aUsuario[x,2,5]

			// Monta tabela de Acessos Por Usuario

			For s := 1 To Len(aAcessos)
				If SubStr(cAcessos,s,1) == 'S'
				   RecLock("TAC",.t.)
				   TAC->COD 	:= cCod
				   TAC->ACESSO := '|[S] '+Rtrim(aAcessos[s])
					TAC->LOGIN	:= cLogin
					TAC->NOME	:= RTrim(Capital(cNome))
					TAC->DEPTO	:= RTrim(Capital(cDepto))
					TAC->CARGO	:= RTrim(Capital(cCargo))
					TAC->EMAIL	:= RTrim(lower(cEMail))
				   TAC->(MsUnlock())
				   fWrite(nH2,	cCod+";"+;
								'|[S] '+Rtrim(aAcessos[s])+";"+;
								cLogin+";"+;
								RTrim(Capital(cNome))+";"+;
								RTrim(Capital(cDepto))+";"+;
								RTrim(Capital(cCargo))+";"+;
								RTrim(lower(cEMail))+chr(13)+chr(10))
				Endif
			Next

			For s := 1 To Len(aDados3)
				cMenu	:= AllTrim(Capital(AllTrim(Substr(aDados3[s],4,Len(aDados3[s])))))
				lUsado	:= IIF(Substr(aDados3[s],3,1)=="X",.F.,.T.)
				If lUsado
					If File(cMenu)
						aAdd( aMenuAll,{ cMenu,cLogin,cNome,cDepto,cCargo,cEMail,cCod } )
					Endif
				Endif
			Next
		Next
	Elseif MV_PAR01 == 2
		For x := 1 To Len(aAdminXnu)
			aAdd( aMenuAll,{ "\SIGAADV\" + aAdminXnu[x] + ".XNU" ,"Administrador","Administrador","Tecnologia","","",'' } )
		Next
	Else
		aAdd( aMenuAll,{ UPPER(AllTrim(MV_PAR02)) ,"Menu","Menu","Configurador","","",'' } )
	Endif
	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ A funcao XNULoad ira retornar para o      ³
	//³ vetor aEstrutura 4 elementos referente a: ³
	//³ aEstrutura[1] = Atualizacoes              ³
	//³ aEstrutura[2] = Consultas                 ³
	//³ aEstrutura[3] = Relatorios                ³
	//³ aEstrutura[4] = Miscelaneas               ³		
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
	ProcRegua(Len(aMenuAll))
    For z := 1 To Len(aMenuAll)
    
		IncProc( "Lendo " + Lower(AllTrim(aMenuAll[z,1])) )
		aEstrutura := XNULoad(aMenuAll[z,1])
	
		For a := 1 To Len(aEstrutura)
	
			If a == 1
				cTipo := "Atualizacoes"
			Elseif a == 2
				cTipo := "Consultas"
			Elseif a == 3
				cTipo := "Relatorios"
			Elseif a == 4
				cTipo := "Miscelaneas"
			Endif
		
			aParte    := aEstrutura[a]
			aGrupos   := aParte[3]
		
			For b := 1 To Len(aGrupos)
					
				If ValType(aGrupos[b][3]) == "A"
			
					aFuncoes  := aGrupos[b][3]
					cGrupo    := aGrupos[b][1][1]
			
					If ValType(aFuncoes) == "A"	
						For c := 1 To Len(aFuncoes)
							IF Len(aFuncoes[c]) >= 7
								aAlias		:= aFuncoes[c][4]
								cArquivo	:= ""
								aEval( aAlias,{ |h| cArquivo += h + " " },,)
								
								nModulo := aScan(aModulos,{|x| AllTrim(x[1]) == RTrim(aFuncoes[c][6])})
								If nModulo > 0
									cModulo := aModulos[nModulo,2]+' - '+aModulos[nModulo,3]
								Else                                                                 
									cModulo := RTrim(aFuncoes[c][6])
								Endif									
						
								DbSelectArea("TRB")
								RecLock("TRB",.T.)
									TRB->MENU	:= aMenuAll[z,1]
									TRB->DESCRI	:= RTrim(aFuncoes[c][1][1])
									TRB->MODO	:= aFuncoes[c][2]
									TRB->TIPO	:= cTipo
									TRB->FUNCAO	:= Upper(RTrim(aFuncoes[c][3]))
									TRB->ACS	:= Upper(aFuncoes[c][5])
									TRB->MODULO	:= cModulo
									TRB->ARQS	:= RTrim(cArquivo)
									TRB->GRUPO	:= RTrim(cGrupo)
									TRB->PESQ	:= Substr(Upper(aFuncoes[c][5]) ,1,1)
									TRB->VISU	:= Substr(Upper(aFuncoes[c][5]) ,2,1)						
									TRB->INCLUIR:= Substr(Upper(aFuncoes[c][5]) ,3,1)						
									TRB->ALTERAR:= Substr(Upper(aFuncoes[c][5]) ,4,1)
									TRB->EXCLUIR:= Substr(Upper(aFuncoes[c][5]) ,5,1)
									TRB->A6		:= Substr(Upper(aFuncoes[c][5]) ,6,1)												
									TRB->A7		:= Substr(Upper(aFuncoes[c][5]) ,7,1)
									TRB->A8		:= Substr(Upper(aFuncoes[c][5]) ,8,1)
									TRB->A9		:= Substr(Upper(aFuncoes[c][5]) ,9,1)
									TRB->A0		:= Substr(Upper(aFuncoes[c][5]) ,10,1)						
									TRB->LOGIN	:= RTrim(aMenuAll[z,2])
									TRB->NOME	:= RTrim(Capital(aMenuAll[z,3]))
									TRB->DEPTO	:= RTrim(Capital(aMenuAll[z,4]))
									TRB->CARGO	:= RTrim(Capital(aMenuAll[z,5]))
									TRB->EMAIL	:= RTrim(lower(aMenuAll[z,6]))
									TRB->COD	:= RTrim(aMenuAll[z,7])
								MsUnLock()								
								fWrite(nH,	aMenuAll[z,1]+";"+;
											RTrim(aFuncoes[c][1][1])+";"+;
											aFuncoes[c][2]+";"+;
											cTipo+";"+;
											Upper(RTrim(aFuncoes[c][3]))+";"+;
											Upper(aFuncoes[c][5])+";"+;
											cModulo+";"+;
											RTrim(cArquivo)+";"+;
											RTrim(cGrupo)+";"+;
											Substr(Upper(aFuncoes[c][5]) ,1,1)+";"+;
											Substr(Upper(aFuncoes[c][5]) ,2,1)+";"+;
											Substr(Upper(aFuncoes[c][5]) ,3,1)+";"+;
											Substr(Upper(aFuncoes[c][5]) ,4,1)+";"+;
											Substr(Upper(aFuncoes[c][5]) ,5,1)+";"+;
											Substr(Upper(aFuncoes[c][5]) ,6,1)+";"+;
											Substr(Upper(aFuncoes[c][5]) ,7,1)+";"+;
											Substr(Upper(aFuncoes[c][5]) ,8,1)+";"+;
											Substr(Upper(aFuncoes[c][5]) ,9,1)+";"+;
											Substr(Upper(aFuncoes[c][5]) ,10,1)+";"+;
											RTrim(aMenuAll[z,2])+";"+;
											RTrim(Capital(aMenuAll[z,3]))+";"+;
											RTrim(Capital(aMenuAll[z,4]))+";"+;
											RTrim(Capital(aMenuAll[z,5]))+";"+;
											RTrim(lower(aMenuAll[z,6]))+";"+;
											RTrim(aMenuAll[z,7])+;
								 			chr(13)+chr(10) ) 

							Endif
						Next
				    Endif
				Else
			    
					nModulo := aScan(aModulos,{|x| AllTrim(x[1]) == RTrim(aGrupos[b][6])})
					If nModulo > 0
						cModulo := aModulos[nModulo,2]+' - '+aModulos[nModulo,3]
					Else                                                                 
						cModulo := RTrim(aGrupos[b][6])
					Endif									

					DbSelectArea("TRB")
					RecLock("TRB",.T.)
						TRB->MENU	:= aMenuAll[z,1]
						TRB->DESCRI	:= RTrim(aGrupos[b][1][1])
						TRB->MODO	:= RTrim(aGrupos[b][2])
						TRB->TIPO	:= cTipo					
						TRB->FUNCAO	:= RTrim(Upper(RTrim(aGrupos[b][3])))
						TRB->ACS	:= RTrim(Upper(aGrupos[b][5]))
						TRB->MODULO	:= cModulo
						TRB->ARQS	:= RTrim(cArquivo)
						TRB->GRUPO	:= RTrim(cGrupo)
						TRB->PESQ	:= Substr(Upper(aGrupos[b][5]) ,1,1)
						TRB->VISU	:= Substr(Upper(aGrupos[b][5]) ,2,1)						
						TRB->INCLUIR:= Substr(Upper(aGrupos[b][5]) ,3,1)						
						TRB->ALTERAR:= Substr(Upper(aGrupos[b][5]) ,4,1)
						TRB->EXCLUIR:= Substr(Upper(aGrupos[b][5]) ,5,1)
						TRB->A6		:= Substr(Upper(aGrupos[b][5]) ,6,1)												
						TRB->A7		:= Substr(Upper(aGrupos[b][5]) ,7,1)
						TRB->A8		:= Substr(Upper(aGrupos[b][5]) ,8,1)
						TRB->A9		:= Substr(Upper(aGrupos[b][5]) ,9,1)
						TRB->A0		:= Substr(Upper(aGrupos[b][5]) ,10,1)
						TRB->LOGIN	:= RTrim(aMenuAll[z,2])
						TRB->NOME	:= RTrim(Capital(aMenuAll[z,3]))
						TRB->DEPTO	:= RTrim(Capital(aMenuAll[z,4]))
						TRB->CARGO	:= RTrim(Capital(aMenuAll[z,5]))
						TRB->EMAIL	:= RTrim(lower(aMenuAll[z,6]))
						TRB->COD	:= RTrim(aMenuAll[z,7])
 					   MsUnLock()
						fWrite(nH,	aMenuAll[z,1]+";"+;
									RTrim(aGrupos[b][1][1])+";"+;
									RTrim(aGrupos[b][2])+";"+;
									cTipo+";"+;
									RTrim(Upper(RTrim(aGrupos[b][3])))+";"+;
									RTrim(Upper(aGrupos[b][5]))+";"+;
									cModulo+";"+;
									RTrim(cArquivo)+";"+;
									RTrim(cGrupo)+";"+;
									Substr(Upper(aGrupos[b][5]) ,1,1)+";"+;
									Substr(Upper(aGrupos[b][5]) ,2,1)+";"+;
									Substr(Upper(aGrupos[b][5]) ,3,1)+";"+;
									Substr(Upper(aGrupos[b][5]) ,4,1)+";"+;
									Substr(Upper(aGrupos[b][5]) ,5,1)+";"+;
									Substr(Upper(aGrupos[b][5]) ,6,1)+";"+;
									Substr(Upper(aGrupos[b][5]) ,7,1)+";"+;
									Substr(Upper(aGrupos[b][5]) ,8,1)+";"+;
									Substr(Upper(aGrupos[b][5]) ,9,1)+";"+;
									Substr(Upper(aGrupos[b][5]) ,10,1)+";"+;
									RTrim(aMenuAll[z,2])+";"+;
									RTrim(Capital(aMenuAll[z,3]))+";"+;
									RTrim(Capital(aMenuAll[z,4]))+";"+;
									RTrim(Capital(aMenuAll[z,5]))+";"+;
									RTrim(lower(aMenuAll[z,6]))+";"+;
									RTrim(aMenuAll[z,7])+;
									chr(13)+chr(10) ) 
				Endif    
		
			Next	
	
		Next
	
	Next
	
	DbSelectArea("TRB")
	DbGoTop()
	Copy To &cNomeArq
	DbCloseArea()
		                
	DbSelectArea("TAC")
	DbGoTop()
	Copy To &cNomeAce
	DbCloseArea()

	fClose(nH) 
	fClose(nH2) 
	Msginfo("Processamento finalizado - Arquivo criado de Menus :" + cFile,"") 
	Msginfo("Processamento finalizado - Arquivo criado de Acessos :" + cFile2,"") 
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ValidPerg ºAutor  ³Microsiga           º Data ³  02/23/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Cria as perguntas do programa no dicionario de perguntas    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ValidPerg( cPerg )

	Local aArea  := GetArea()
	Local aPerg  := {}
	Local _nLaco := 0

	aAdd(aPerg,{cPerg,"01","Analisar quais menus ?","mv_ch1","N",01,0,1,"C","","mv_par01","Todos","","","Padrao","","","Especifico","","","","","","","","  ",})
	aAdd(aPerg,{cPerg,"02","Menu especíico       ?","mv_ch2","C",40,0,0,"G","","mv_par02","","","","","","","","","","","","","","","",})

	DbSelectArea("SX1")	                                                
	For _nLaco:=1 to LEN(aPerg)                                   
		If !dbSeek(aPerg[_nLaco,1]+aPerg[_nLaco,2])
	    	RecLock("SX1",.T.)
				SX1->X1_Grupo     := aPerg[_nLaco,01]
				SX1->X1_Ordem     := aPerg[_nLaco,02]
				SX1->X1_Pergunt   := aPerg[_nLaco,03]
				SX1->X1_PerSpa    := aPerg[_nLaco,03]
				SX1->X1_PerEng    := aPerg[_nLaco,03]				
				SX1->X1_Variavl   := aPerg[_nLaco,04]
				SX1->X1_Tipo      := aPerg[_nLaco,05]
				SX1->X1_Tamanho   := aPerg[_nLaco,06]
				SX1->X1_Decimal   := aPerg[_nLaco,07]
				SX1->X1_Presel    := aPerg[_nLaco,08]
				SX1->X1_Gsc       := aPerg[_nLaco,09]
				SX1->X1_Valid     := aPerg[_nLaco,10]
				SX1->X1_Var01     := aPerg[_nLaco,11]
				SX1->X1_Def01     := aPerg[_nLaco,12]
				SX1->X1_Cnt01     := aPerg[_nLaco,13]
				SX1->X1_Var02     := aPerg[_nLaco,14]
				SX1->X1_Def02     := aPerg[_nLaco,15]
				SX1->X1_Cnt02     := aPerg[_nLaco,16]
				SX1->X1_Var03     := aPerg[_nLaco,17]
				SX1->X1_Def03     := aPerg[_nLaco,18]
				SX1->X1_Cnt03     := aPerg[_nLaco,19]
				SX1->X1_Var04     := aPerg[_nLaco,20]
				SX1->X1_Def04     := aPerg[_nLaco,21]
				SX1->X1_Cnt04     := aPerg[_nLaco,22]
				SX1->X1_Var05     := aPerg[_nLaco,23]
				SX1->X1_Def05     := aPerg[_nLaco,24]
				SX1->X1_Cnt05     := aPerg[_nLaco,25]
				SX1->X1_F3        := aPerg[_nLaco,26]
			MsUnLock()
		EndIf
	Next
	RestArea( aArea )

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna Array com Codigos e Nomes dos Modulos              º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function fModulos()

Local aReturn

aReturn := {{"01","SIGAATF ","Ativo Fixo                       "},;
            {"02","SIGACOM ","Compras                           "},;
            {"03","SIGACON ","Contabilidade                     "},;
            {"04","SIGAEST ","Estoque/Custos                    "},;
            {"05","SIGAFAT ","Faturamento                       "},;
            {"06","SIGAFIN ","Financeiro                        "},;
            {"07","SIGAGPE ","Gestao de Pessoal                 "},;
            {"08","SIGAFAS ","Faturamento Servico               "},;
            {"09","SIGAFIS ","Livros Fiscais                    "},;
            {"10","SIGAPCP ","Planej.Contr.Producao             "},;
            {"11","SIGAVEI ","Veiculos                          "},;
            {"12","SIGALOJA","Controle de Lojas                 "},;
            {"13","SIGATMK ","Call Center                       "},;
            {"14","SIGAOFI ","Oficina                           "},;
            {"15","SIGARPM ","Gerador de Relatorios Beta1       "},;
            {"16","SIGAPON ","Ponto Eletronico                  "},;
            {"17","SIGAEIC ","Easy Import Control               "},;
            {"18","SIGAGRH ","Gestao de R.Humanos               "},;
            {"19","SIGAMNT ","Manutencao de Ativos              "},;
            {"20","SIGARSP ","Recrutamento e Selecao Pessoal    "},;
            {"21","SIGAQIE ","Inspecao de Entrada               "},;
            {"22","SIGAQMT ","Metrologia                        "},;
            {"23","SIGAFRT ","Front Loja                        "},;
            {"24","SIGAQDO ","Controle de Documentos            "},;
            {"25","SIGAQIP ","Inspecao de Projetos              "},;
            {"26","SIGATRM ","Treinamento                       "},;
            {"27","SIGAEIF ","Importacao - Financeiro           "},;
            {"28","SIGATEC ","Field Service                     "},;
            {"29","SIGAEEC ","Easy Export Control               "},;
            {"30","SIGAEFF ","Easy Financing                    "},;
            {"31","SIGAECO ","Easy Accounting                   "},;
            {"32","SIGAAFV ","Administracao de Forca de Vendas  "},;
            {"33","SIGAPLS ","Plano de Saude                    "},;
            {"34","SIGACTB ","Contabilidade Gerencial           "},;
            {"35","SIGAMDT ","Medicina e Seguranca no Trabalho  "},;
            {"36","SIGAQNC ","Controle de Nao-Conformidades     "},;
            {"37","SIGAQAD ","Controle de Auditoria             "},;
            {"38","SIGAQCP ","Controle Estatistico de Processos "},;
            {"39","SIGAOMS ","Gestao de Distribuicao            "},;
            {"40","SIGACSA ","Cargos e Salarios                 "},;
            {"41","SIGAPEC ","Auto Pecas                        "},;
            {"42","SIGAWMS ","Gestao de Armazenagem             "},;
            {"43","SIGATMS ","Gestao de Transporte              "},;
            {"44","SIGAPMS ","Gestao de Projetos                "},;
            {"45","SIGACDA ","Controle de Direitos Autorais     "},;
            {"46","SIGAACD ","Automacao Coleta de Dados         "},;
            {"47","SIGAPPAP","PPAP                              "},;
            {"48","SIGAREP ","Replica                           "},;
            {"49","SIGAGAC ","Gerenciamento Academico           "},;
            {"50","SIGAEDC ","Easy DrawBack Control             "},;
            {"97","SIGAESP ","Especificos                       "},;
            {"98","SIGAESP1","Especificos I                     "}}
               
Return(aReturn)
