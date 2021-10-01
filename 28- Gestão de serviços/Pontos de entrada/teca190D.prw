#INCLUDE 'protheus.ch'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "Fileio.ch"
#INCLUDE "SHELL.ch"
#INCLUDE "TECA190D.ch"

/* --------------------------------------------------------------------------

// -- ABA ATENDENTES -- //
[AA1] - AA1MASTER - Atendente - VIEW_MASTER

	//Aba Manuten��o
		[DTS] - DTSMASTER - Per�odo Manuten��o - VIEW_DTS
		[ABB] - ABBDETAIL - Agendas para manuten��o - DETAIL_ABB
		[MAN] - MANMASTER - Campos para inclus�o da Manuten��o - VIEW_MAN

	//Aba Aloca��o
		[TGY] - TGYMASTER - Configura��o de Aloca��o - VIEW_TGY
		[DTA] - DTAMASTER - Per�odo de Aloca��o - VIEW_DTA
		[ALC] - ALCDETAIL - Proje��o das agendas - DETAIL_ALC


	// -- ABA LOCAIS -- //
	[TFL] - TFLMASTER - Configura��o do Local - VIEW_TFL

	//Aba Agendas Projetadas
		[PRJ] - PRJMASTER - Per�odo (Dt.Ini / Dt.Fim) - VIEW_PRJ
		[LOC] - LOCDETAIL - Agendas do Local - DETAIL_LOC

	//Aba Controle de Aloca��o (vis�o por dia)
		[DTR] - DTRMASTER - Data de Refer�ncia - VIEW_DTR
		[HOJ] - HOJDETAIL - Agendas do dia por Local - DETAIL_HOJ

// -- ABA ALOCA��ES -- //
[LCA] - LCAMASTER - Buscar Atendentes - VIEW_LCA
[LGY] - LGYDETAIL - Atendentes (para aloca��o) - DETAIL_LGY
[LAC] - LACDETAIL - Proje��o das Agendas (lote) - DETAIL_LAC
 --------------------------------------------------------------------------*/
/* --------------------------------------------------------------------------

Estrutura do array aMarks
[n, 01] - ABB_CODIGO
[n, 02] - ABB_DTINI (D)
[n, 03] - ABB_HRINI 
[n, 04] - ABB_DTFIM
[n, 05] - ABB_HRFIM
[n, 06] - ABB_ATENDE
[n, 07] - ABB_CHEGOU
[n, 08] - ABB_IDCFAL
[n, 09] - ABB_DTREF
[n, 10] - lResTec (ABS_RESTEC)
[n, 11] - TFF_COD
[n, 12] - Filial
 --------------------------------------------------------------------------*/
Static aMarks 		:= {}
Static aValALC 		:= {}
Static aDels 		:= {}
Static aLineLGY 	:= {}
Static aAlocLGY 	:= {}
Static cRetF3 		:= ""
Static cRetF3_2		:= ""
Static cFiltro550	:= ""
Static cMultFil		:= ""
Static cCodLcItEx   := "" 

#DEFINE DEF_TITULO_DO_CAMPO		01	//Titulo do campo
#DEFINE DEF_TOOLTIP_DO_CAMPO	02	//ToolTip do campo
#DEFINE DEF_IDENTIFICADOR		03	//identificador (ID) do Field
#DEFINE DEF_TIPO_DO_CAMPO		04	//Tipo do campo
#DEFINE DEF_TAMANHO_DO_CAMPO	05	//Tamanho do campo
#DEFINE DEF_DECIMAL_DO_CAMPO	06	//Decimal do campo
#DEFINE DEF_CODEBLOCK_VALID		07	//Code-block de valida��o do campo
#DEFINE DEF_CODEBLOCK_WHEN		08	//Code-block de valida��o When do campo
#DEFINE DEF_LISTA_VAL			09	//Lista de valores permitido do campo
#DEFINE DEF_OBRIGAT				10	//Indica se o campo tem preenchimento obrigat�rio
#DEFINE DEF_CODEBLOCK_INIT		11	//Code-block de inicializacao do campo
#DEFINE DEF_CAMPO_CHAVE			12	//Indica se trata de um campo chave
#DEFINE DEF_RECEBE_VAL			13	//Indica se o campo pode receber valor em uma opera��o de update.
#DEFINE DEF_VIRTUAL				14	//Indica se o campo � virtual
#DEFINE DEF_VALID_USER			15	//Valid do usuario

#DEFINE DEF_ORDEM				16	//Ordem do campo
#DEFINE DEF_HELP				17	//Array com o Help dos campos
#DEFINE DEF_PICTURE				18	//Picture do campo
#DEFINE DEF_PICT_VAR			19	//Bloco de picture Var
#DEFINE DEF_LOOKUP				20	//Chave para ser usado no LooKUp
#DEFINE DEF_CAN_CHANGE			21	//Logico dizendo se o campo pode ser alterado
#DEFINE DEF_ID_FOLDER			22	//Id da Folder onde o field esta
#DEFINE DEF_ID_GROUP			23	//Id do Group onde o field esta
#DEFINE DEF_COMBO_VAL			24	//Array com os Valores do combo
#DEFINE DEF_TAM_MAX_COMBO		25	//Tamanho maximo da maior op��o do combo
#DEFINE DEF_INIC_BROWSE			26	//Inicializador do Browse
#DEFINE DEF_PICTURE_VARIAVEL	27	//Picture variavel
#DEFINE DEF_INSERT_LINE			28	//Se verdadeiro, indica pulo de linha ap�s o campo
#DEFINE DEF_WIDTH				29	//Largura fixa da apresenta��o do campo
#DEFINE DEF_TIPO_CAMPO_VIEW		30	//Tipo do campo

#DEFINE QUANTIDADE_DEFS			30	//Quantidade de DEFs

//------------------------------------------------------------------------------
/*/{Protheus.doc} TECA190D

@description Mesa Operacional

@author	boiani
@since	29/05/2019
/*/
//------------------------------------------------------------------------------
Function TECA190D()

	Local aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},;
		{.T.,STR0001},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} // "Fechar"

	ValidSXB()
	FWExecView("","VIEWDEF.TECA190D", MODEL_OPERATION_INSERT,,,,,aButtons)
	aMarks := {}
	cFiltro550 := ""
	aValALC := {}
	aDels := {}
	aAlocLGY := {}

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
	Defini��o do modelo de Dados

@author	boiani
@since 29/05/2019
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
	Local oModel
	Local oStrAA1	:= FWFormModelStruct():New()
	Local oStrABB	:= FWFormModelStruct():New()
	Local oStrDTS	:= FWFormModelStruct():New()
	Local oStrMAN	:= FWFormModelStruct():New()
	Local oStrTGY	:= FWFormModelStruct():New()
	Local oStrALC	:= FWFormModelStruct():New()
	Local oStrTFL	:= FWFormModelStruct():New()
	Local oStrLOC	:= FWFormModelStruct():New()
	Local oStrHOJ	:= FWFormModelStruct():New()
	Local oStrDTR	:= FWFormModelStruct():New()
	Local oStrDTA	:= FWFormModelStruct():New()
	Local oStrPRJ	:= FWFormModelStruct():New()
	Local oStrLCA	:= FWFormModelStruct():New()
	Local oStrLGY	:= FWFormModelStruct():New()
	Local oStrLAC	:= FWFormModelStruct():New()

	Local bValid	:= { |oModel| AT190dVldM( oModel ) }
	Local aFields	:= {}
	Local nX		:= 0
	Local nY		:= 0
	Local aTables 	:= {}
	Local xAux

	oStrAA1:AddTable("   ",{}, STR0002) //"Mesa Operacional"
	oStrABB:AddTable("   ",{}, "   ")
	oStrDTS:AddTable("   ",{}, "   ")
	oStrMAN:AddTable("   ",{}, "   ")
	oStrTGY:AddTable("   ",{}, "   ")
	oStrALC:AddTable("   ",{}, "   ")
	oStrTFL:AddTable("   ",{}, "   ")
	oStrLOC:AddTable("   ",{}, "   ")
	oStrHOJ:AddTable("   ",{}, "   ")
	oStrDTR:AddTable("   ",{}, "   ")
	oStrDTA:AddTable("   ",{}, "   ")
	oStrPRJ:AddTable("   ",{}, "   ")
	oStrLCA:AddTable("   ",{}, "   ")
	oStrLGY:AddTable("   ",{}, "   ")
	oStrLAC:AddTable("   ",{}, "   ")

	AADD(aTables, {oStrAA1, "AA1"})
	AADD(aTables, {oStrDTS, "DTS"})
	AADD(aTables, {oStrABB, "ABB"})
	AADD(aTables, {oStrMAN, "MAN"})
	AADD(aTables, {oStrTGY, "TGY"})
	AADD(aTables, {oStrALC, "ALC"})
	AADD(aTables, {oStrTFL, "TFL"})
	AADD(aTables, {oStrLOC, "LOC"})
	AADD(aTables, {oStrHOJ, "HOJ"})
	AADD(aTables, {oStrDTR, "DTR"})
	AADD(aTables, {oStrDTA, "DTA"})
	AADD(aTables, {oStrPRJ, "PRJ"})
	AADD(aTables, {oStrLCA, "LCA"})
	AADD(aTables, {oStrLGY, "LGY"})
	AADD(aTables, {oStrLAC, "LAC"})

	For nY := 1 To LEN(aTables)
		aFields := AT190DDef(aTables[nY][2])

		For nX := 1 TO LEN(aFields)
			aTables[nY][1]:AddField(aFields[nX][DEF_TITULO_DO_CAMPO],;
				aFields[nX][DEF_TOOLTIP_DO_CAMPO],;
				aFields[nX][DEF_IDENTIFICADOR	],;
				aFields[nX][DEF_TIPO_DO_CAMPO	],;
				aFields[nX][DEF_TAMANHO_DO_CAMPO],;
				aFields[nX][DEF_DECIMAL_DO_CAMPO],;
				aFields[nX][DEF_CODEBLOCK_VALID	],;
				aFields[nX][DEF_CODEBLOCK_WHEN	],;
				aFields[nX][DEF_LISTA_VAL		],;
				aFields[nX][DEF_OBRIGAT			],;
				aFields[nX][DEF_CODEBLOCK_INIT	],;
				aFields[nX][DEF_CAMPO_CHAVE		],;
				aFields[nX][DEF_RECEBE_VAL		],;
				aFields[nX][DEF_VIRTUAL			],;
				aFields[nX][DEF_VALID_USER		])
		Next nX
	Next nY

	If ExistBlock("AT19DCPO")
		ExecBlock("AT19DCPO",.F.,.F.,{@oModel, @aTables} )
	EndIf

	xAux := FwStruTrigger( 'AA1_CODTEC', 'AA1_NOMTEC',;
		'Posicione("AA1",1,xFilial("AA1") + FwFldGet("AA1_CODTEC"),"AA1_NOMTEC")', .F. )
	oStrAA1:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStruTrigger( 'AA1_CODTEC', 'AA1_FONE',;
		'Posicione("AA1",1,xFilial("AA1") + FwFldGet("AA1_CODTEC"),"AA1_FONE")', .F. )
	oStrAA1:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStruTrigger( 'AA1_CODTEC', 'AA1_CDFUNC',;
		'Posicione("AA1",1,xFilial("AA1") + FwFldGet("AA1_CODTEC"),"AA1_CDFUNC")', .F. )
	oStrAA1:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStruTrigger( 'AA1_CODTEC', 'AA1_FUNCAO',;
		'Posicione("AA1",1,xFilial("AA1") + FwFldGet("AA1_CODTEC"),"AA1_FUNCAO")', .F. )
	oStrAA1:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStruTrigger( 'AA1_CODTEC', 'RJ_DESC',;
		'Posicione("SRJ",1,xFilial("SRJ") + FwFldGet("AA1_FUNCAO"),"RJ_DESC")', .F. )
	oStrAA1:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStruTrigger( 'AA1_CODTEC', 'AA1_CODTEC','At190DLoad()', .F. )
	oStrAA1:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStruTrigger( 'AA1_CODTEC', 'AA1_CODTEC','At190DClr()', .F. )
	oStrAA1:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStruTrigger( 'DTS_DTINI', 'DTS_DTINI','At190DLoad()', .F. )
	oStrDTS:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStruTrigger( 'DTS_DTFIM', 'DTS_DTFIM','At190DLoad()', .F. )
	oStrDTS:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStruTrigger( 'ABB_MARK', 'ABB_MARK','At190WMan()', .F. )
	oStrABB:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStruTrigger( 'TGY_TIPALO', 'TGY_DESMOV',;
		'Posicione("TCU",1,xFilial("TCU", FwFldGet("TGY_FILIAL")) + FwFldGet("TGY_TIPALO"),"TCU_DESC")', .F. )
	oStrTGY:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStruTrigger( 'TGY_FILIAL', 'TGY_FILIAL','At190DClr("TGY_FILIAL")', .F. )
	oStrTGY:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStruTrigger( 'TGY_CONTRT', 'TGY_CONTRT','At190DClr("TGY_FILIAL|TGY_CONTRT")', .F. )
	oStrTGY:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStruTrigger( 'TGY_CODTFL', 'TGY_CODTFL','At190DClr("TGY_FILIAL|TGY_CONTRT|TGY_CODTFL")', .F. )
	oStrTGY:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStruTrigger( 'TGY_TFFCOD', 'TGY_TFFCOD','At190DClr("TGY_FILIAL|TGY_CONTRT|TGY_CODTFL|TGY_TFFCOD|TGY_TFFHRS","TGY_TFFCOD")', .F. )
	oStrTGY:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStruTrigger( 'TGY_ESCALA', 'TGY_ESCALA','At190DClr("TGY_FILIAL|TGY_CONTRT|TGY_CODTFL|TGY_TFFCOD|TGY_ESCALA|TGY_TIPALO|TGY_DESMOV")', .F. )
	oStrTGY:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStruTrigger( 'ABB_HRINI', 'ABB_HRINI','At190MHora("ABB_HRINI")', .F. )
	oStrABB:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStruTrigger( 'ABB_HRFIM', 'ABB_HRFIM','At190MHora("ABB_HRFIM")', .F. )
	oStrABB:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStruTrigger( 'ABB_OBSERV', 'ABB_OBSERV','AT190DDetA("ABB")', .F. )
	oStrABB:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStruTrigger( 'MAN_MOTIVO', 'MAN_MOTIVO', 'At190OpMan(!(isBlind()))', .F.)
	oStrMAN:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStruTrigger( 'MAN_HRINI', 'MAN_MODDT', 'At190MODDT("MAN_HRINI")', .F.)
	oStrMAN:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStruTrigger( 'MAN_HRFIM', 'MAN_MODDT', 'At190MODDT("MAN_HRFIM")', .F.)
	oStrMAN:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStruTrigger("TFL_LOJA","TFL_NOMENT","GetAdvFVal('SA1','A1_NOME',xFilial('SA1',IIF(Empty(FwFldGet('TFL_FILIAL')),cFilAnt,FwFldGet('TFL_FILIAL')))+FwFldGet('TFL_CODENT')+FwFldGet('TFL_LOJA'),1,'')",.F.,;
		"" ,0 ,"" ,"!Empty(FwFldGet('TFL_CODENT'))","01" )
	oStrTFL:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStruTrigger("TFL_LOCAL","TFL_DESLOC","GetAdvFVal('ABS','ABS_DESCRI',xFilial('ABS',IIF(Empty(FwFldGet('TFL_FILIAL')),cFilAnt,FwFldGet('TFL_FILIAL')))+FwFldGet('TFL_LOCAL'),1,'')",.F.)
	oStrTFL:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStruTrigger("TFL_TFFCOD","TFL_NOMESC",;
		"GetAdvFVal('TDW','TDW_DESC', xFilial('TDW',IIF(Empty(FwFldGet('TFL_FILIAL')),cFilAnt,FwFldGet('TFL_FILIAL')))+"+;
		"GetAdvFVal('TFF','TFF_ESCALA',xFilial('TFF',IIF(Empty(FwFldGet('TFL_FILIAL')),cFilAnt,FwFldGet('TFL_FILIAL')))+FwFldGet('TFL_TFFCOD'), 1,''), 1,'')",.F.)
	oStrTFL:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStruTrigger("TGY_CODTFL",;
		"TGY_DESLOC","GetAdvFVal( 'ABS', 'ABS_DESCRI', xFilial('ABS',IIF(Empty(FwFldGet('TGY_FILIAL')),cFilAnt,FwFldGet('TGY_FILIAL')))+GetAdvFVal('TFL','TFL_LOCAL',xFilial('TFL',IIF(Empty(FwFldGet('TGY_FILIAL')),cFilAnt,FwFldGet('TGY_FILIAL')))+FwFldGet('TGY_CODTFL'), 1,''), 1,'')",;
		.F.)
	oStrTGY:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStruTrigger( 'LGY_CODTFF', 'LGY_ESCALA', 'IIF(EMPTY(FwFldGet("LGY_CODTFF")),"", FwFldGet("LGY_ESCALA"))', .F.)
	oStrLGY:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStruTrigger( 'LGY_CODTFF', 'LGY_DSCTDW', 'IIF(EMPTY(FwFldGet("LGY_CODTFF")),"", FwFldGet("LGY_DSCTDW"))', .F.)
	oStrLGY:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStruTrigger( 'LGY_CODTEC', 'LGY_NOMTEC',;
		'Posicione("AA1",1,xFilial("AA1",FwFldGet("LGY_FILIAL")) + FwFldGet("LGY_CODTEC"),"AA1_NOMTEC")', .F. )
	oStrLGY:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStruTrigger( 'LGY_CODTFL', 'LGY_CONTRT',;
		'IIF(EMPTY(FwFldGet("LGY_CODTFL")),FwFldGet("LGY_CONTRT"),Posicione("TFL",1,xFilial("TFL",FwFldGet("LGY_FILIAL")) + FwFldGet("LGY_CODTFL"),"TFL_CONTRT"))', .F. )
	oStrLGY:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStruTrigger( 'LGY_CODTFF', 'LGY_CODTFL',;
		'IIF(EMPTY(FwFldGet("LGY_CODTFF")),FwFldGet("LGY_CODTFL"),Posicione("TFF",1,xFilial("TFF",FwFldGet("LGY_FILIAL")) + FwFldGet("LGY_CODTFF"),"TFF_CODPAI"))', .F. )
	oStrLGY:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStruTrigger( 'LGY_CODTFF', 'LGY_CONFAL', 'At190GTCNF(FwFldGet("LGY_CODTFF"),"LGY_CONFAL")', .F.)
	oStrLGY:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStruTrigger( 'LGY_CODTFF', 'LGY_GRUPO', 'At190GTCNF(FwFldGet("LGY_CODTFF"),"LGY_GRUPO")', .F.)
	oStrLGY:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStruTrigger( 'LGY_CODTFF', 'LGY_TIPTCU', 'At190GTCNF(FwFldGet("LGY_CODTFF"),"LGY_TIPTCU")', .F.)
	oStrLGY:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStruTrigger( 'LGY_CODTFF', 'LGY_SEQ', 'At190GTCNF(FwFldGet("LGY_CODTFF"),"LGY_SEQ")', .F.)
	oStrLGY:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStruTrigger( 'LGY_SEQ', 'LGY_CONFAL', 'At190GTCNF(FwFldGet("LGY_CODTFF"),"LGY_CONFAL", FwFldGet("LGY_SEQ"))', .F.)
	oStrLGY:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStruTrigger( 'LGY_ESCALA', 'LGY_DSCTDW',;
		'IIF(EMPTY(FwFldGet("LGY_ESCALA")), "", Posicione("TDW",1,xFilial("TDW",FwFldGet("LGY_FILIAL")) + FwFldGet("LGY_ESCALA"),"TDW_DESC") )', .F. )
	oStrLGY:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStruTrigger( 'LGY_ESCALA', 'LGY_SEQ',	'At190dGSeq(FwFldGet("LGY_ESCALA"))', .F. )
	oStrLGY:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStruTrigger( 'LGY_ESCALA', 'LGY_SEQ', 'IIF(EMPTY(FwFldGet("LGY_ESCALA")),"", FwFldGet("LGY_SEQ"))', .F.)
	oStrLGY:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStruTrigger( 'LGY_ESCALA', 'LGY_CONFAL', 'IIF(EMPTY(FwFldGet("LGY_ESCALA")),"", FwFldGet("LGY_CONFAL"))', .F.)
	oStrLGY:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStruTrigger( 'LGY_ESCALA', 'LGY_CONFAL', 'T190dEscCA(FwFldGet("LGY_ESCALA"))', .F.)
	oStrLGY:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStruTrigger( 'LGY_SEQ', 'LGY_CONFAL', 'IIF(EMPTY(FwFldGet("LGY_SEQ")),"", FwFldGet("LGY_CONFAL"))', .F.)
	oStrLGY:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStruTrigger( 'LGY_FILIAL', 'LGY_DSCFIL' , 'Alltrim(FWFilialName(,FwFldGet("LGY_FILIAL")))' ,.F.)
	oStrLGY:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStruTrigger( 'LCA_TFFCOD', 'LCA_CODTFL',;
		'Posicione("TFF",1,xFilial("TFF",FwFldGet("LCA_FILIAL")) + FwFldGet("LCA_TFFCOD"),"TFF_CODPAI")', .F. )
	oStrLCA:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStruTrigger( 'LCA_CODTFL', 'LCA_CONTRT',;
		'Posicione("TFL",1,xFilial("TFL",FwFldGet("LCA_FILIAL")) + FwFldGet("LCA_CODTFL"),"TFL_CONTRT")', .F. )
	oStrLCA:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStruTrigger( 'LOC_OBSERV', 'LOC_OBSERV','AT190DDetA("LOC")', .F. )
	oStrLOC:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	oModel := MPFormModel():New('TECA190D',/*bPreValidacao*/,bValid,/*bCommit*/,/*bCancel*/)
	oModel:SetDescription( STR0002) //"Mesa Operacional"

	oModel:addFields('AA1MASTER',,oStrAA1, {|oMdlAA1,cAction,cField,xValue| PreLinAA1(oMdlAA1,cAction,cField,xValue)})
	oModel:SetPrimaryKey({"AA1_FILIAL","AA1_CODTEC"})

	oModel:addFields('DTSMASTER','AA1MASTER',oStrDTS)
	oModel:addFields('TGYMASTER','AA1MASTER',oStrTGY, {|oMdlTGY,cAction,cField,xValue| PreLinTGY(oMdlTGY,cAction,cField,xValue)})
	oModel:addFields('DTRMASTER','AA1MASTER',oStrDTR)
	oModel:addFields('DTAMASTER','AA1MASTER',oStrDTA)
	oModel:addFields('TFLMASTER','AA1MASTER',oStrTFL, {|oMdlTFL,cAction,cField,xValue| At19dVlTFL(oMdlTFL,cAction,cField,xValue)})
	oModel:addGrid('LOCDETAIL','TFLMASTER', oStrLOC)
	oModel:addGrid('HOJDETAIL','TFLMASTER', oStrHOJ)
	oModel:addGrid('ALCDETAIL','TGYMASTER', oStrALC,{|oMdlG,nLine,cAcao,cCampo, xValue, xOldValue| PreLinAlc(oMdlG, nLine, cAcao, cCampo, xValue, xOldValue)})
	oModel:addGrid('ABBDETAIL','AA1MASTER', oStrABB)
	oModel:addFields('MANMASTER','DTSMASTER',oStrMAN)
	oModel:addFields('PRJMASTER','TFLMASTER',oStrPRJ)
	oModel:addFields('LCAMASTER','AA1MASTER',oStrLCA, {|oMdlLCA,cAction,cField,xValue| At19dVlLCA(oMdlLCA,cAction,cField,xValue)})
	oModel:addGrid('LGYDETAIL','LCAMASTER', oStrLGY, {|oMdlG,nLine,cAcao,cCampo, xValue, xOldValue| At19dVlLGY(oMdlG, nLine, cAcao, cCampo, xValue, xOldValue)})
	oModel:addGrid('LACDETAIL','LGYDETAIL',oStrLAC)

	oModel:GetModel('DTSMASTER'):SetOnlyQuery(.T.)
	oModel:GetModel('ABBDETAIL'):SetOnlyQuery(.T.)
	oModel:GetModel('MANMASTER'):SetOnlyQuery(.T.)
	oModel:GetModel('TGYMASTER'):SetOnlyQuery(.T.)
	oModel:GetModel('ALCDETAIL'):SetOnlyQuery(.T.)
	oModel:GetModel('LOCDETAIL'):SetOnlyQuery(.T.)
	oModel:GetModel('HOJDETAIL'):SetOnlyQuery(.T.)
	oModel:GetModel('TFLMASTER'):SetOnlyQuery(.T.)
	oModel:GetModel('DTRMASTER'):SetOnlyQuery(.T.)
	oModel:GetModel('DTAMASTER'):SetOnlyQuery(.T.)
	oModel:GetModel('PRJMASTER'):SetOnlyQuery(.T.)
	oModel:GetModel('LCAMASTER'):SetOnlyQuery(.T.)
	oModel:GetModel('LGYDETAIL'):SetOnlyQuery(.T.)
	oModel:GetModel('LACDETAIL'):SetOnlyQuery(.T.)

	oModel:GetModel('DTSMASTER'):SetOptional(.T.)
	oModel:GetModel('ABBDETAIL'):SetOptional(.T.)
	oModel:GetModel('MANMASTER'):SetOptional(.T.)
	oModel:GetModel('TGYMASTER'):SetOptional(.T.)
	oModel:GetModel('ALCDETAIL'):SetOptional(.T.)
	oModel:GetModel('LOCDETAIL'):SetOptional(.T.)
	oModel:GetModel('HOJDETAIL'):SetOptional(.T.)
	oModel:GetModel('TFLMASTER'):SetOptional(.T.)
	oModel:GetModel('DTRMASTER'):SetOptional(.T.)
	oModel:GetModel('DTAMASTER'):SetOptional(.T.)
	oModel:GetModel('PRJMASTER'):SetOptional(.T.)
	oModel:GetModel('LCAMASTER'):SetOptional(.T.)
	oModel:GetModel('LGYDETAIL'):SetOptional(.T.)
	oModel:GetModel('LACDETAIL'):SetOptional(.T.)

	oModel:GetModel('AA1MASTER'):SetDescription(STR0003)	//"Atendente"
	oModel:GetModel('DTSMASTER'):SetDescription(STR0004)	//"Per�odos"
	oModel:GetModel('ABBDETAIL'):SetDescription(STR0005)	//"Agendas"
	oModel:GetModel('MANMASTER'):SetDescription(STR0006)	//"Manuten��es"
	oModel:GetModel('TGYMASTER'):SetDescription(STR0007)	//"Configura��o de Aloca��o"
	oModel:GetModel('ALCDETAIL'):SetDescription(STR0008)	//"Proje��o de Aloca��o"
	oModel:GetModel('LOCDETAIL'):SetDescription(STR0009)	//"Agendas no Per�odo"
	oModel:GetModel('HOJDETAIL'):SetDescription(STR0010)	//"Situa��o de Aloca��o"
	oModel:GetModel('TFLMASTER'):SetDescription(STR0011)	//"Filtro dos Locais"
	oModel:GetModel('DTRMASTER'):SetDescription(STR0012)	//"Data de Refer�ncia"
	oModel:GetModel('DTAMASTER'):SetDescription(STR0013)	//"Data de Aloca��o"
	oModel:GetModel('PRJMASTER'):SetDescription(STR0014)	//"Datas de Busca"
	oModel:GetModel('LCAMASTER'):SetDescription(STR0397)//"Buscar Atendentes"
	oModel:GetModel('LGYDETAIL'):SetDescription(STR0398) //"Atendentes"
	oModel:GetModel('LACDETAIL'):SetDescription(STR0399)//"Aloca��es em lote"

	oModel:SetActivate( {|oModel| InitDados( oModel ) } )

	If ExistBlock("AT190DMODE")
		ExecBlock("AT190DMODE",.F.,.F.,{@oModel,@aTables} )
	EndIf
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
	Defini��o da interface

@author	boiani
@since 29/05/2019
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
	Local oView
	Local oModel := ModelDef()
	Local oStrAA1	:= FWFormViewStruct():New()
	Local oStrABB	:= FWFormViewStruct():New()
	Local oStrDTS	:= FWFormViewStruct():New()
	Local oStrMAN	:= FWFormViewStruct():New()
	Local oStrTGY	:= FWFormViewStruct():New()
	Local oStrALC	:= FWFormViewStruct():New()
	Local oStrTFL	:= FWFormViewStruct():New()
	Local oStrLOC	:= FWFormViewStruct():New()
	Local oStrHOJ	:= FWFormViewStruct():New()
	Local oStrDTR	:= FWFormViewStruct():New()
	Local oStrDTA	:= FWFormViewStruct():New()
	Local oStrPRJ	:= FWFormViewStruct():New()
	Local oStrLCA	:= FWFormViewStruct():New()
	Local oStrLGY	:= FWFormViewStruct():New()
	Local oStrLAC	:= FWFormViewStruct():New()
	Local lMonitor	:= IsBlind() .OR. ((GetScreenRes()[2] <= 800) .AND. (GetScreenRes()[1] <= 1400)) //786 x 1366
	Local aTables 	:= {}
	Local aTamanhoAM	:= {}
	Local aTamanhoAA	:= {}
	Local aTamanhoLA	:= {}
	Local aTamanhoLC	:= {}
	Local aTamanhoGY	:= {}
	Local aFields
	Local nX
	Local nY
	Local lMV_GSGEHOR := TecXHasEdH()
	Local lMV_MultFil := TecMultFil() //Indica se a Mesa considera multiplas filiais
	Local nC := 0

	AADD(aTables, {oStrAA1, "AA1"})
	AADD(aTables, {oStrDTS, "DTS"})
	AADD(aTables, {oStrABB, "ABB"})
	AADD(aTables, {oStrMAN, "MAN"})
	AADD(aTables, {oStrTGY, "TGY"})
	AADD(aTables, {oStrALC, "ALC"})
	AADD(aTables, {oStrTFL, "TFL"})
	AADD(aTables, {oStrLOC, "LOC"})
	AADD(aTables, {oStrHOJ, "HOJ"})
	AADD(aTables, {oStrDTR, "DTR"})
	AADD(aTables, {oStrDTA, "DTA"})
	AADD(aTables, {oStrPRJ, "PRJ"})
	AADD(aTables, {oStrLCA, "LCA"})
	AADD(aTables, {oStrLGY, "LGY"})
	AADD(aTables, {oStrLAC, "LAC"})

	For nY := 1 to LEN(aTables)
		aFields := AT190DDef(aTables[nY][2])

		For nX := 1 to LEN(aFields)
			aTables[nY][1]:AddField(aFields[nX][DEF_IDENTIFICADOR],;
				aFields[nX][DEF_ORDEM],;
				aFields[nX][DEF_TITULO_DO_CAMPO],;
				aFields[nX][DEF_TOOLTIP_DO_CAMPO],;
				aFields[nX][DEF_HELP],;
				aFields[nX][DEF_TIPO_CAMPO_VIEW],;
				aFields[nX][DEF_PICTURE],;
				aFields[nX][DEF_PICT_VAR],;
				aFields[nX][DEF_LOOKUP],;
				aFields[nX][DEF_CAN_CHANGE],;
				aFields[nX][DEF_ID_FOLDER],;
				aFields[nX][DEF_ID_GROUP],;
				aFields[nX][DEF_COMBO_VAL],;
				aFields[nX][DEF_TAM_MAX_COMBO],;
				aFields[nX][DEF_INIC_BROWSE],;
				aFields[nX][DEF_VIRTUAL],;
				aFields[nX][DEF_PICTURE_VARIAVEL],;
				aFields[nX][DEF_INSERT_LINE],;
				aFields[nX][DEF_WIDTH])
		Next nX
	Next nY

	oStrAA1:RemoveField("AA1_FILIAL")
	oStrABB:RemoveField("ABB_TIPOMV")
	oStrABB:RemoveField("ABB_ATIVO")
	oStrABB:RemoveField("ABB_CODIGO")
	oStrABB:RemoveField("ABB_DTFIM")
	oStrABB:RemoveField("ABB_DTINI")
	oStrABB:RemoveField("ABB_ATENDE")
	oStrABB:RemoveField("ABB_CHEGOU")
	oStrABB:RemoveField("ABB_IDCFAL")
	oStrABB:RemoveField("ABB_FILIAL")
	oStrABB:RemoveField("ABB_RECABB")
	If !lMV_MultFil
		oStrABB:RemoveField("ABB_DSCFIL")
		oStrLoc:RemoveField("LOC_DSCFIL")
		oStrTGY:RemoveField("TGY_FILIAL")
		oStrTFL:RemoveField("TFL_FILIAL")
		oStrLCA:RemoveField("LCA_FILIAL")
		oStrLGY:RemoveField("LGY_FILIAL")
		oStrLGY:RemoveField("LGY_DSCFIL")
	EndIf
	If !TecABBPRHR()
		oStrTGY:RemoveField("TGY_TFFHRS")
	EndIf
	oStrLOC:RemoveField("LOC_ATIVO")
	oStrLOC:RemoveField("LOC_TIPOMV")
	oStrLOC:RemoveField("LOC_CODABB")
	oStrLoc:RemoveField("LOC_LOCAL")
	oStrLoc:RemoveField("LOC_ABBDTI")
	oStrLoc:RemoveField("LOC_ABBDTF")
	oStrLoc:RemoveField("LOC_TFFCOD")
	oStrLoc:RemoveField("LOC_ATENDE")
	oStrLoc:RemoveField("LOC_IDCFAL")
	oStrLoc:RemoveField("LOC_RECABB")
	oStrLoc:RemoveField("LOC_CHEGOU")
	oStrLoc:RemoveField("LOC_FILIAL")
	oStrMAN:RemoveField("MAN_MODINI")
	oStrMAN:RemoveField("MAN_MODFIM")
	oStrTGY:RemoveField("TGY_RECNO")
	oStrALC:RemoveField("ALC_KEYTGY")
	oStrALC:RemoveField("ALC_ITTGY")
	oStrALC:RemoveField("ALC_TURNO")
	oStrALC:RemoveField("ALC_EXSABB")
	oStrALC:RemoveField("ALC_ITEM")
	oStrALC:RemoveField("ALC_GRUPO")
	oStrALC:RemoveField("ALC_SALHRS")
	oStrLGY:RemoveField("LGY_RECLGY")
	For nC := 1 to 4
		If !(HasPJEnSd(cValToChar(nC)))
			oStrLGY:RemoveField("LGY_ENTRA"+cValToChar(nC))
			oStrLGY:RemoveField("LGY_SAIDA"+cValToChar(nC))
		EndIf
	Next nC
	oStrLAC:RemoveField("LAC_KEYTGY")
	oStrLAC:RemoveField("LAC_ITTGY")
	oStrLAC:RemoveField("LAC_TURNO")
	oStrLAC:RemoveField("LAC_EXSABB")
	oStrLAC:RemoveField("LAC_ITEM")
	oStrLAC:RemoveField("LAC_GRUPO")
	For nC := 1 to 4
		oStrTGY:RemoveField("TGY_ENTRA"+ Str(nC, 1))
		oStrTGY:RemoveField("TGY_SAIDA"+ Str(nC, 1))
	Next
	oView := FWFormView():New()
	oView:SetModel(oModel)

	If lMonitor
		oView:SetContinuousForm()
		//Aba Atendentedes Manunte��o
		AADD(aTamanhoAM, 08.00)
		AADD(aTamanhoAM, 08.75)
		AADD(aTamanhoAM, 11.00)
		AADD(aTamanhoAM, 72.25)
		//Aba Atendentes Aloca��o
		AADD(aTamanhoAA, 08.50)
		AADD(aTamanhoAA, 08.00)
		AADD(aTamanhoAA, 08.00)
		AADD(aTamanhoAA, 67.00)
		AADD(aTamanhoAA, 08.50)
		//Aba Locais Agendas Projetadas
		AADD(aTamanhoLA, 08.00)
		AADD(aTamanhoLA, 08.00)
		AADD(aTamanhoLA, 08.00)
		AADD(aTamanhoLA, 08.00)
		AADD(aTamanhoLA, 68.00)
		//Aba Locais Controle de Aloca��o
		AADD(aTamanhoLC, 49.00)
		AADD(aTamanhoLC, 51.00)
		//Aba Aloca��es
		AADD(aTamanhoGY, 09.00)
		AADD(aTamanhoGY, 08.00)
		AADD(aTamanhoGY, 08.00)
		AADD(aTamanhoGY, 08.00)
		AADD(aTamanhoGY, 08.00)
		AADD(aTamanhoGY, 41.00)
		AADD(aTamanhoGY, 09.00)
		AADD(aTamanhoGY, 09.00)
	Else
		//Aba Atendentedes Manunte��o
		AADD(aTamanhoAM, 05.20)
		AADD(aTamanhoAM, 06.50)
		AADD(aTamanhoAM, 08.00)
		AADD(aTamanhoAM, 80.30)
		//Aba Atendentes Aloca��o
		AADD(aTamanhoAA, 06.00)
		AADD(aTamanhoAA, 05.50)
		AADD(aTamanhoAA, 06.00)
		AADD(aTamanhoAA, 77.50)
		AADD(aTamanhoAA, 05.00) //76.5
		//Aba Locais Agendas Projetadas
		AADD(aTamanhoLA, 05.50)
		AADD(aTamanhoLA, 05.50)
		AADD(aTamanhoLA, 05.50)
		AADD(aTamanhoLA, 05.50)
		AADD(aTamanhoLA, 78.00)
		//Aba Locais Controle de Aloca��o
		AADD(aTamanhoLC, 50.00)
		AADD(aTamanhoLC, 50.00)
		//Aba Aloca��es
		AADD(aTamanhoGY, 06.50)
		AADD(aTamanhoGY, 05.50)
		AADD(aTamanhoGY, 05.50)
		AADD(aTamanhoGY, 05.50)
		AADD(aTamanhoGY, 05.50)
		AADD(aTamanhoGY, 60.50)
		AADD(aTamanhoGY, 05.50)
		AADD(aTamanhoGY, 05.50)
	EndIf

	oView:AddField('VIEW_MASTER', oStrAA1, 'AA1MASTER')
	oView:AddField('VIEW_DTS',  oStrDTS, 'DTSMASTER')
	oView:AddGrid('DETAIL_ABB', oStrABB, 'ABBDETAIL')
	oView:AddField('VIEW_MAN',  oStrMAN, 'MANMASTER')
	oView:AddField('VIEW_TGY',  oStrTGY, 'TGYMASTER')
	oView:AddField('VIEW_DTR',  oStrDTR, 'DTRMASTER')
	oView:AddField('VIEW_DTA',  oStrDTA, 'DTAMASTER')
	oView:AddField('VIEW_PRJ',  oStrPRJ, 'PRJMASTER')
	oView:AddGrid('DETAIL_ALC', oStrALC, 'ALCDETAIL')
	oView:AddGrid('DETAIL_LOC', oStrLOC, 'LOCDETAIL')
	oView:AddGrid('DETAIL_HOJ', oStrHOJ, 'HOJDETAIL')
	oView:AddField('VIEW_TFL',  oStrTFL, 'TFLMASTER')
	oView:AddField('VIEW_LCA',  oStrLCA, 'LCAMASTER')
	oView:AddGrid('DETAIL_LGY', oStrLGY, 'LGYDETAIL')
	oView:AddGrid('DETAIL_LAC', oStrLAC, 'LACDETAIL')

	oView:CreateHorizontalBox( 'TELA' , 100 )

	oView:CreateFolder( 'TELA_ABAS', 'TELA')
	oView:AddSheet('TELA_ABAS','TELA_01', STR0398)//"Atendentes"
	oView:AddSheet('TELA_ABAS','TELA_02',STR0400) //"Locais"
	oView:AddSheet('TELA_ABAS','TELA_03',STR0493) //"Aloca��es em Lote"

	oView:CreateHorizontalBox('TOP_2'		, 30,,, 'TELA_ABAS', 'TELA_02' )
	oView:CreateHorizontalBox('BOTTOM_2'	, 70,,, 'TELA_ABAS', 'TELA_02' )

	oView:CreateHorizontalBox('TOP_3_CPOS'	, 12,,, 'TELA_ABAS', 'TELA_03' )
	oView:CreateHorizontalBox('TOP_3_BTNS'	, 9,,, 'TELA_ABAS', 'TELA_03' )
	oView:CreateHorizontalBox('MIDDLE_3'	, 47,,, 'TELA_ABAS', 'TELA_03' )
	oView:CreateHorizontalBox('BOTTOM_3'	, 32,,, 'TELA_ABAS', 'TELA_03' )

	oView:CreateVerticalBox( 'T3BT1', aTamanhoGY[1], 'TOP_3_BTNS', ,'TELA_ABAS', 'TELA_03' )
	oView:CreateVerticalBox( 'T3BT2', aTamanhoGY[2], 'TOP_3_BTNS', ,'TELA_ABAS', 'TELA_03' )
	oView:CreateVerticalBox( 'T3BT3', aTamanhoGY[3], 'TOP_3_BTNS', ,'TELA_ABAS', 'TELA_03' )
	oView:CreateVerticalBox( 'T3BT4', aTamanhoGY[4], 'TOP_3_BTNS', ,'TELA_ABAS', 'TELA_03' )
	oView:CreateVerticalBox( 'T3BT5', aTamanhoGY[5], 'TOP_3_BTNS', ,'TELA_ABAS', 'TELA_03' )
	oView:CreateVerticalBox( 'T3BT6', aTamanhoGY[6], 'TOP_3_BTNS', ,'TELA_ABAS', 'TELA_03' )
	oView:CreateVerticalBox( 'T3BT7', aTamanhoGY[7], 'TOP_3_BTNS', ,'TELA_ABAS', 'TELA_03' )
	oView:CreateVerticalBox( 'T3BT8', aTamanhoGY[8], 'TOP_3_BTNS', ,'TELA_ABAS', 'TELA_03' )

	oView:CreateFolder( 'ABAS_LOC', 'BOTTOM_2')

	oView:AddSheet('ABAS_LOC','ABA01_L',STR0015)	//"Agendas Projetadas"
	oView:AddSheet('ABAS_LOC','ABA02_L',STR0016)	//"Controle de Aloca��o"

	oView:CreateHorizontalBox( 'ID_ABAL_PRJ'	, 19, , ,'ABAS_LOC', 'ABA01_L' )
	oView:CreateHorizontalBox( 'ID_ABAL_PRBT'	, 9, , ,'ABAS_LOC', 'ABA01_L' )
	oView:CreateHorizontalBox( 'ID_ABAL_PROJ'	, 72, , ,'ABAS_LOC', 'ABA01_L' )

	oView:CreateHorizontalBox( 'ID_ABAL_CDTA'	, 19, , ,'ABAS_LOC', 'ABA02_L' )
	oView:CreateHorizontalBox( 'ID_ABAL_BTN'	, 9	, , ,'ABAS_LOC', 'ABA02_L' )
	oView:CreateHorizontalBox( 'ID_ABAL_ATT'	, 72, , ,'ABAS_LOC', 'ABA02_L' )

	oView:CreateVerticalBox( 'V_ABABTN_1', aTamanhoLC[1], 'ID_ABAL_BTN', ,'ABAS_LOC', 'ABA02_L' )
	oView:CreateVerticalBox( 'V_ABABTN_2', aTamanhoLC[2], 'ID_ABAL_BTN', ,'ABAS_LOC', 'ABA02_L' )

	oView:CreateVerticalBox( 'V_ABABTN_3', aTamanhoLA[1], 'ID_ABAL_PRBT', ,'ABAS_LOC', 'ABA01_L' )
	oView:CreateVerticalBox( 'V_ABABTN_4', aTamanhoLA[2], 'ID_ABAL_PRBT', ,'ABAS_LOC', 'ABA01_L' )
	oView:CreateVerticalBox( 'V_ABABTN_5', aTamanhoLA[3], 'ID_ABAL_PRBT', ,'ABAS_LOC', 'ABA01_L' )
	oView:CreateVerticalBox( 'V_ABABTN_6', aTamanhoLA[4], 'ID_ABAL_PRBT', ,'ABAS_LOC', 'ABA01_L' )
	oView:CreateVerticalBox( 'V_ABABTN_7', aTamanhoLA[5], 'ID_ABAL_PRBT', ,'ABAS_LOC', 'ABA01_L' )

	oView:CreateHorizontalBox('TOP_1'		, 20,,, 'TELA_ABAS', 'TELA_01' )
	oView:CreateHorizontalBox('BOTTOM_1'	, 80,,, 'TELA_ABAS', 'TELA_01' )

	oView:CreateFolder( 'ABAS', 'BOTTOM_1')

	oView:AddSheet('ABAS','ABA01',STR0017)	//"Manuten��o"
	oView:AddSheet('ABAS','ABA02',STR0018)	//"Aloca��o"

	oView:CreateHorizontalBox( 'ID_ABA01_DATAS'	, 16, , ,'ABAS', 'ABA01' )
	oView:CreateHorizontalBox( 'ID_ABA01_SELECT', 09, , ,'ABAS', 'ABA01' )
	oView:CreateHorizontalBox( 'ID_ABA01_AGENDA', 37, , ,'ABAS', 'ABA01' )
	oView:CreateHorizontalBox( 'ID_ABA01_MANUT' , 27, , ,'ABAS', 'ABA01' )
	oView:CreateHorizontalBox( 'ID_ABA01_BTNGRV', 11, , ,'ABAS', 'ABA01' )

	oView:CreateVerticalBox( 'V_ABA01_1', aTamanhoAM[1], 'ID_ABA01_SELECT', ,'ABAS', 'ABA01' )
	oView:CreateVerticalBox( 'V_ABA02_1', aTamanhoAM[2], 'ID_ABA01_SELECT', ,'ABAS', 'ABA01' )
	oView:CreateVerticalBox( 'V_ABA03_1', aTamanhoAM[3], 'ID_ABA01_SELECT', ,'ABAS', 'ABA01' )
	oView:CreateVerticalBox( 'V_ABA04_1', aTamanhoAM[4], 'ID_ABA01_SELECT', ,'ABAS', 'ABA01' )

	oView:CreateVerticalBox( 'V_ABAB1_1', 10,'ID_ABA01_BTNGRV', ,'ABAS', 'ABA01' )
	oView:CreateVerticalBox( 'V_ABAB2_1', 90,'ID_ABA01_BTNGRV', ,'ABAS', 'ABA01' )

	oView:CreateHorizontalBox( 'ID_ABA02_TGY'	, 34, , ,'ABAS', 'ABA02' )
	oView:CreateHorizontalBox( 'ID_ABA02_DTA'	, 16, , ,'ABAS', 'ABA02' )
	oView:CreateHorizontalBox( 'ID_ABA02_BTN'	, 9, ,  ,'ABAS', 'ABA02' )
	oView:CreateHorizontalBox( 'ID_ABA02_ALOC'	, 41, , ,'ABAS', 'ABA02' )

	oView:CreateVerticalBox( 'V_ABA01_2', aTamanhoAA[1], 'ID_ABA02_BTN', ,'ABAS', 'ABA02' )
	oView:CreateVerticalBox( 'V_ABA02_2', aTamanhoAA[2], 'ID_ABA02_BTN', ,'ABAS', 'ABA02' )
	oView:CreateVerticalBox( 'V_ABA03_2', aTamanhoAA[3], 'ID_ABA02_BTN', ,'ABAS','ABA02' )
	oView:CreateVerticalBox( 'V_ABA04_2', aTamanhoAA[4], 'ID_ABA02_BTN', ,'ABAS','ABA02' )
	oView:CreateVerticalBox( 'V_ABA05_2', aTamanhoAA[5], 'ID_ABA02_BTN', ,'ABAS','ABA02' )

	oView:AddOtherObject("MARK_ALL",{|oPanel| at190dSlct(oPanel) })
	oView:SetOwnerView("MARK_ALL","V_ABA01_1")

	oView:AddOtherObject("MANUT_REL",{|oPanel| at190dMntR(oPanel) })
	oView:SetOwnerView("MANUT_REL","V_ABA02_1")

	oView:AddOtherObject("MANUT_DEL",{|oPanel| at190dExAg(oPanel) })
	oView:SetOwnerView("MANUT_DEL","V_ABA03_1")

	oView:AddOtherObject("EXPORT_ATT",{|oPanel| at190dExpA(oPanel, STR0324) })//"Manuten��o"
	oView:SetOwnerView("EXPORT_ATT","V_ABA04_1")

	oView:AddOtherObject("GRV_MANUT",{|oPanel| at190dGvMt(oPanel) })
	oView:SetOwnerView("GRV_MANUT","V_ABAB1_1")

	oView:AddOtherObject("EXPORT_PROJ",{|oPanel| at190dExpA(oPanel, STR0325) })//"Agendas Projetadas"
	oView:SetOwnerView("EXPORT_PROJ","V_ABABTN_7")

	oView:AddOtherObject("ULTCONF",{|oPanel| at190dUConf(oPanel) })
	oView:SetOwnerView("ULTCONF","V_ABA01_2")

	oView:AddOtherObject("PROCONF",{|oPanel| at190dPConf(oPanel) })
	oView:SetOwnerView("PROCONF","V_ABA02_2")

	oView:AddOtherObject("GRAVALOC",{|oPanel| at190dGrava(oPanel) })
	oView:SetOwnerView("GRAVALOC","V_ABA03_2")

	oView:AddOtherObject("ADDATENDS",{|oPanel| at190dAddA(oPanel) })
	oView:SetOwnerView("ADDATENDS","T3BT1")

	oView:AddOtherObject("LGYAGENDA",{|oPanel| at190dYAgnd(oPanel) })
	oView:SetOwnerView("LGYAGENDA","T3BT2")

	oView:AddOtherObject("LGYGRAV",{|oPanel| at190dYGrv(oPanel) })
	oView:SetOwnerView("LGYGRAV","T3BT3")

	oView:AddOtherObject("LIMPLGY",{|oPanel| at190dClry(oPanel) })
	oView:SetOwnerView("LIMPLGY","T3BT7")

	oView:AddOtherObject("EXPTGY",{|oPanel| at190dExpC(oPanel) })
	oView:SetOwnerView("EXPTGY","T3BT8")

	If lMV_GSGEHOR
		oView:AddOtherObject("EDIT_HOR",{|oPanel| at190dEHr(oPanel) })
		oView:SetOwnerView("EDIT_HOR","V_ABA04_2")
	EndIf

	oView:AddOtherObject("EXPORT_ALC",{|oPanel| at190dExpA(oPanel, STR0326) })//"Aloca��o"
	oView:SetOwnerView("EXPORT_ALC","V_ABA05_2")

	oView:AddOtherObject("BUSCAGD",{|oPanel| at190dBscA(oPanel) })
	oView:SetOwnerView("BUSCAGD","V_ABABTN_3")

	oView:AddOtherObject("MARKALL",{|oPanel| at190dMLoc(oPanel) })
	oView:SetOwnerView("MARKALL","V_ABABTN_4")

	oView:AddOtherObject("MNTPRJ",{|oPanel| at190dMtPr(oPanel) })
	oView:SetOwnerView("MNTPRJ","V_ABABTN_5")

	oView:AddOtherObject("DELLOC",{|oPanel| at190dLOCd(oPanel) })
	oView:SetOwnerView("DELLOC","V_ABABTN_6")

	oView:AddOtherObject("BUSCSIT",{|oPanel| at190dBscB(oPanel) })
	oView:SetOwnerView("BUSCSIT","V_ABABTN_1")

	oView:AddOtherObject("GRAVAPRO",{|oPanel| at190dExpA(oPanel, STR0327) })//"Controle de Aloca��o"
	oView:SetOwnerView("GRAVAPRO","V_ABABTN_2")

	oView:AddUserButton(STR0402,"",{|oModel| AT190ClDta(oModel)},,,) //"Calendario"
	oView:AddUserButton(STR0591,"",{|oModel| AT190FacD(oModel)},,,) //"Alterar Datas"

	If TableInDic("TXI") .AND. AA1->(ColumnPos("AA1_SUPERV")) > 0
		oView:AddUserButton(STR0403,"",{|oView| AT190SupAT(oView)},,,) //"Atendentes Supervisionados"
	EndIf

	oView:AddUserButton(STR0494,"",{|| AT190UbCp()},,,) //"Copiar (F10)"
	oView:AddUserButton(STR0495,"",{|| AT190UbPt()},,,) //"Colar (F11)"

	If ExistFunc('TECA190E')//Fonte do Modelo de troca de efetivo
		oView:AddUserButton(STR0345,"",{|| At190TrEft() },,,)
	EndIf

	If At190dItOp() //Item extra operacional
		oView:AddUserButton(STR0538,"",{|| At190dGrOrc() },,,) //"Item Extra Operacional"
	Endif
	oView:SetOwnerView('VIEW_DTS','ID_ABA01_DATAS')
	oView:SetOwnerView('VIEW_MASTER','TOP_1')
	oView:SetOwnerView('DETAIL_ABB','ID_ABA01_AGENDA')
	oView:SetOwnerView('VIEW_MAN','ID_ABA01_MANUT')

	oView:SetOwnerView('VIEW_TGY','ID_ABA02_TGY')
	oView:SetOwnerView('VIEW_DTA','ID_ABA02_DTA')
	oView:SetOwnerView('DETAIL_ALC','ID_ABA02_ALOC')

	oView:SetOwnerView('VIEW_TFL','TOP_2')
	oView:SetOwnerView('VIEW_LCA','TOP_3_CPOS')
	oView:SetOwnerView('DETAIL_LGY','MIDDLE_3')
	oView:SetOwnerView('DETAIL_LAC','BOTTOM_3')
	oView:SetOwnerView('DETAIL_LOC','ID_ABAL_PROJ')
	oView:SetOwnerView('VIEW_DTR','ID_ABAL_CDTA')
	oView:SetOwnerView('DETAIL_HOJ','ID_ABAL_ATT')
	oView:SetOwnerView('VIEW_PRJ','ID_ABAL_PRJ')

	oView:EnableTitleView('VIEW_MASTER', 	STR0003) 		//"Atendente"
	oView:EnableTitleView('VIEW_DTS', 		STR0019)		//"Per�odo"
	oView:EnableTitleView('VIEW_MAN', 		STR0017)		//"Manuten��o"
	oView:EnableTitleView('VIEW_TGY', 		STR0007) 		//"Configura��o de Aloca��o"
	oView:EnableTitleView('VIEW_TFL', 		STR0020)		//"Agenda por Local"
	oView:EnableTitleView('VIEW_DTA', 		STR0021)		//"Per�odo de Aloca��o"
	oView:EnableTitleView('VIEW_PRJ', 		STR0015) 		//"Agendas Projetadas"
	oView:EnableTitleView('VIEW_DTR', 		STR0022)		//"Situa��o do Posto"
	oView:EnableTitleView('VIEW_LCA', 		STR0401) //"Busca de Atendentes"
	oView:EnableTitleView('DETAIL_LGY', 	STR0398) //"Atendentes"

	oView:SetDescription(STR0002) // "Mesa Operacional"

//Habilita o F10/F11 na pasta Locais
	SetKey( VK_F10, { || At190dF10() })
	SetKey( VK_F11, { || At190dF11() } )

	If ExistBlock("AT190DVIEW")
		ExecBlock("AT190DVIEW",.F.,.F.,{@oView,@aTables} )
	EndIf

Return oView

//------------------------------------------------------------------------------
/*/{Protheus.doc} AT190DDef

@description Retorna em forma de Array as defini��es dos campos
@param cTable, string, define de qual tabela devem ser os campos retornados
@return aRet, array, defini��o dos campos

@author	boiani
@since	29/05/2019
/*/
//------------------------------------------------------------------------------
Function AT190DDef(cTable)
	Local aRet		:= {}
	Local nAux 		:= 0
	Local cOrdem 	:= "01"
	Local nC 		:= 1
	Local cCampoE 	:= "TGY_ENTRA"
	Local cCampoS 	:= "TGY_SAIDA"
	Local cDescri	:= "X3_DESCRIC"
	Local lMV_MultFil := TecMultFil() //Indica se a Mesa considera multiplas filiais

	#IFDEF SPANISH
		cDescri	:= "X3_DESCSPA"
	#ELSE
		#IFDEF ENGLISH
			cDescri	:= "X3_DESCENG"
		#ENDIF
	#ENDIF

	If cTable == "AA1"

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := GetSX3Cache( "AA1_FILIAL", cDescri )  //"Filial do Atendente"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := GetSX3Cache( "AA1_FILIAL", cDescri ) //"Filial do Atendente"
		aRet[nAux][DEF_IDENTIFICADOR] := "AA1_FILIAL"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("AA1_FILIAL")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_CODEBLOCK_INIT] := {|| xFilial("AA1")}
		aRet[nAux][DEF_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "01"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .F.

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := GetSX3Cache( "AA1_CODTEC", cDescri )  //"Codigo do Atendente"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := GetSX3Cache( "AA1_CODTEC", cDescri ) //"Codigo do Atendente"
		aRet[nAux][DEF_IDENTIFICADOR] := "AA1_CODTEC"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("AA1_CODTEC")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "02"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_LOOKUP] := "T19AA1" //At190dCons("AA1")
		aRet[nAux][DEF_CAN_CHANGE] := .T.
		aRet[nAux][DEF_HELP] := {STR0023}	//"C�digo do atendente cadastrado no 'Gest�o de Servi�os'"

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := GetSX3Cache( "AA1_NOMTEC", cDescri )  //"Nome Atendente"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := GetSX3Cache( "AA1_NOMTEC", cDescri ) //"Nome Atendente"
		aRet[nAux][DEF_IDENTIFICADOR] := "AA1_NOMTEC"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("AA1_NOMTEC")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
		aRet[nAux][DEF_RECEBE_VAL] := .F.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "03"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .F.

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := GetSX3Cache( "AA1_FONE", cDescri )  //"Telefone p/ contato"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := GetSX3Cache( "AA1_FONE", cDescri ) //"Telefone p/ contato"
		aRet[nAux][DEF_IDENTIFICADOR] := "AA1_FONE"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("AA1_FONE")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
		aRet[nAux][DEF_RECEBE_VAL] := .F.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "04"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .F.

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0024	//"Matr�cula do Atendente"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0024	//"Matr�cula do Atendente"
		aRet[nAux][DEF_IDENTIFICADOR] := "AA1_CDFUNC"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("AA1_CDFUNC")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
		aRet[nAux][DEF_RECEBE_VAL] := .F.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "06"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .F.

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := GetSX3Cache( "AA1_FUNCAO", cDescri )  //"Fun��o do Atendente"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := GetSX3Cache( "AA1_FUNCAO", cDescri ) //"Fun��o do Atendente"
		aRet[nAux][DEF_IDENTIFICADOR] := "AA1_FUNCAO"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("AA1_FUNCAO")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
		aRet[nAux][DEF_RECEBE_VAL] := .F.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "07"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .F.

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := GetSX3Cache( "RJ_DESC", cDescri )  //"Descricao da Funcao"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := GetSX3Cache( "RJ_DESC", cDescri ) //"Descricao da Funcao"
		aRet[nAux][DEF_IDENTIFICADOR] := "RJ_DESC"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("RJ_DESC")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
		aRet[nAux][DEF_RECEBE_VAL] := .F.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "09"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .F.

	ElseIf cTable == "ABB"

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0025	//"Legenda"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0025	//"Legenda"
		aRet[nAux][DEF_IDENTIFICADOR] := "ABB_LEGEND"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "BT"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "BT"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 1
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_VALID] := {||At19DAGtLA("ABB_LEGEND")}
		aRet[nAux][DEF_CODEBLOCK_INIT] := {|| "BR_VERDE"}
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "01"
		aRet[nAux][DEF_PICTURE] := ""
		aRet[nAux][DEF_CAN_CHANGE] := .T.

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0026	//"Mark"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0026	//"Mark"
		aRet[nAux][DEF_IDENTIFICADOR] := "ABB_MARK"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "L"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "CHECK"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 1
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| !Empty( At190dGVal("ABBDETAIL", "ABB_DTREF"))}
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "02"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .T.

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0012		//"Data de Refer�ncia"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0012		//"Data de Refer�ncia"
		aRet[nAux][DEF_IDENTIFICADOR] := "ABB_DTREF"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "D"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "D"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 8
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_RECEBE_VAL] := .F.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "03"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .F.

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0027	//"Dia da Semana"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0027	//"Dia da Semana"
		aRet[nAux][DEF_IDENTIFICADOR] := "ABB_DOW"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 20
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
		aRet[nAux][DEF_RECEBE_VAL] := .F.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "04"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .F.

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := GetSX3Cache( "ABB_HRINI", cDescri )  //"Hora de Inicio"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := GetSX3Cache( "ABB_HRINI", cDescri ) //"Hora de Inicio"
		aRet[nAux][DEF_IDENTIFICADOR] := "ABB_HRINI"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("ABB_HRINI")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| FwFldGet("ABB_LEGEND") != "BR_MARROM" .AND. !Empty( At190dGVal("ABBDETAIL", "ABB_DTREF"))}
		aRet[nAux][DEF_CODEBLOCK_VALID] := {|| AtVldHora(At190dGVal("ABBDETAIL","ABB_HRINI"))}
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_RECEBE_VAL] := .F.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "05"
		aRet[nAux][DEF_PICTURE] := "99:99"
		aRet[nAux][DEF_CAN_CHANGE] := .T.
		aRet[nAux][DEF_HELP] := {STR0028} //"Hora de inicio do atendente."

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := GetSX3Cache( "ABB_HRFIM", cDescri )  //"Hora Final"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := GetSX3Cache( "ABB_HRFIM", cDescri ) //"Hora Final"
		aRet[nAux][DEF_IDENTIFICADOR] := "ABB_HRFIM"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("ABB_HRFIM")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| FwFldGet("ABB_LEGEND") != "BR_MARROM" .AND. !Empty( At190dGVal("ABBDETAIL", "ABB_DTREF"))}
		aRet[nAux][DEF_CODEBLOCK_VALID] := {|| AtVldHora(At190dGVal("ABBDETAIL","ABB_HRFIM"))}
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_RECEBE_VAL] := .F.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "06"
		aRet[nAux][DEF_PICTURE] := "99:99"
		aRet[nAux][DEF_CAN_CHANGE] := .T.
		aRet[nAux][DEF_HELP] := {STR0029} //"Hora final do atendente."

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0366 //"Observa��es"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0366 //"Observa��es"
		aRet[nAux][DEF_IDENTIFICADOR] := "ABB_OBSERV"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("ABB_OBSERV")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| GetSX3Cache( "ABB_OBSERV", "X3_VISUAL") == 'A' .AND. !Empty( At190dGVal("ABBDETAIL", "ABB_DTREF"))}
		aRet[nAux][DEF_RECEBE_VAL] := .F.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "07"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .T.
		aRet[nAux][DEF_HELP] := {STR0367} //"Observa��es na agenda"

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0031	//"Local de Atendimento"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0031	//"Local de Atendimento"
		aRet[nAux][DEF_IDENTIFICADOR] := "ABB_ABSDSC"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("ABS_DESCRI")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
		aRet[nAux][DEF_RECEBE_VAL] := .F.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "08"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .F.
		aRet[nAux][DEF_HELP] := {STR0031}	//"Local de Atendimento"

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0369 //"C�digo RH"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] :=  STR0369 //"C�digo RH"
		aRet[nAux][DEF_IDENTIFICADOR] := "ABB_ABQTFF"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("ABQ_CODTFF")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
		aRet[nAux][DEF_RECEBE_VAL] := .F.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "09"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .F.
		aRet[nAux][DEF_HELP] := {STR0370}	//"C�digo do Item de Recursos Humanos"

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0032	//"Item de Recursos Humanos"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0032	//"Item de Recursos Humanos"
		aRet[nAux][DEF_IDENTIFICADOR] := "ABB_B1DESC"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("B1_DESC")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
		aRet[nAux][DEF_RECEBE_VAL] := .F.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "10"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .F.
		aRet[nAux][DEF_HELP] := {STR0032}	//"Itens de Recursos Humanos"

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := GetSX3Cache( "ABB_TIPOMV", cDescri )  //"Tipo da Movimento"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := GetSX3Cache( "ABB_TIPOMV", cDescri ) //"Tipo da Movimento"
		aRet[nAux][DEF_IDENTIFICADOR] := "ABB_TIPOMV"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("ABB_TIPOMV")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
		aRet[nAux][DEF_RECEBE_VAL] := .F.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "11"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .F.

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := GetSX3Cache( "ABB_ATIVO", cDescri )  //"Agenda Ativa?"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := GetSX3Cache( "ABB_ATIVO", cDescri ) //"Agenda Ativa?"
		aRet[nAux][DEF_IDENTIFICADOR] := "ABB_ATIVO"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("ABB_ATIVO")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
		aRet[nAux][DEF_RECEBE_VAL] := .F.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "12"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .F.
		aRet[nAux][DEF_HELP] := {STR0035}	//"Indica se a agenda est� ativa ou n�o."

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := GetSX3Cache( "ABB_CODIGO", cDescri )  //"C�digo da Agenda"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := GetSX3Cache( "ABB_CODIGO", cDescri ) //"C�digo da Agenda"
		aRet[nAux][DEF_IDENTIFICADOR] := "ABB_CODIGO"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("ABB_CODIGO")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
		aRet[nAux][DEF_RECEBE_VAL] := .F.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "13"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .F.

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0404 //"Data de Inicio"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0404 //"Data de Inicio"
		aRet[nAux][DEF_IDENTIFICADOR] := "ABB_DTINI"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "D"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "D"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 8
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_RECEBE_VAL] := .F.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "14"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .F.

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0405 //"Data de T�rmino"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0405 //"Data de T�rmino"
		aRet[nAux][DEF_IDENTIFICADOR] := "ABB_DTFIM"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "D"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "D"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 8
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_RECEBE_VAL] := .F.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "15"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .F.

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0406 //"Atende"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0406 //"Atende"
		aRet[nAux][DEF_IDENTIFICADOR] := "ABB_ATENDE"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 1
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_RECEBE_VAL] := .F.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "16"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .F.

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0407 //"Chegou"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0407 //"Chegou"
		aRet[nAux][DEF_IDENTIFICADOR] := "ABB_CHEGOU"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 1
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_RECEBE_VAL] := .F.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "17"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .F.

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := GetSX3Cache( "ABB_IDCFAL", cDescri )  //"Id.Conf.Aloca��o"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := GetSX3Cache( "ABB_IDCFAL", cDescri )  //"Id.Conf.Aloca��o"
		aRet[nAux][DEF_IDENTIFICADOR] := "ABB_IDCFAL"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("ABB_IDCFAL")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_RECEBE_VAL] := .F.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "18"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .F.

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0030	//"Tp. Movimenta��o"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0030	//"Tp. Movimenta��o"
		aRet[nAux][DEF_IDENTIFICADOR] := "ABB_TCUDSC"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TCU_DESC")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
		aRet[nAux][DEF_RECEBE_VAL] := .F.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "19"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .F.

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := GetSX3Cache( "ABB_FILIAL", cDescri )
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := GetSX3Cache( "ABB_FILIAL", cDescri )
		aRet[nAux][DEF_IDENTIFICADOR] := "ABB_FILIAL"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("ABB_FILIAL")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
		aRet[nAux][DEF_RECEBE_VAL] := .F.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "20"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .F.
		aRet[nAux][DEF_HELP] := {"Filial da agenda"}

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := GetSX3Cache( "ABB_FILIAL", cDescri )
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := GetSX3Cache( "ABB_FILIAL", cDescri )
		aRet[nAux][DEF_IDENTIFICADOR] := "ABB_DSCFIL"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := (LEN(cFilAnt) + LEN(FWFilialName()) + 3)
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
		aRet[nAux][DEF_RECEBE_VAL] := .F.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "21"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .F.
		aRet[nAux][DEF_HELP] := {"Filial da agenda"}

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0073	//"RECNO"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0073	//"RECNO"
		aRet[nAux][DEF_IDENTIFICADOR] := "ABB_RECABB"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "N"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "N"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 16
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "22"
		aRet[nAux][DEF_CAN_CHANGE] := .T.

	ElseIf cTable == "DTS"
		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0266	//"Data Inicial"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0266	//"Data Inicial"
		aRet[nAux][DEF_IDENTIFICADOR] := "DTS_DTINI"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "D"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "D"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 8
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.T.}
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_CODEBLOCK_INIT] := {|| dDataBase}
		aRet[nAux][DEF_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "01"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .T.
		aRet[nAux][DEF_HELP] := {STR0267}	//"Data inicial do periodo. Baseado na data base do sistema."

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0268		//"Data Final"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0268	//"Data Final"
		aRet[nAux][DEF_IDENTIFICADOR] := "DTS_DTFIM"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "D"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "D"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 8
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.T.}
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_CODEBLOCK_INIT] := {|| dDataBase}
		aRet[nAux][DEF_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "02"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .T.
		aRet[nAux][DEF_HELP] := {STR0269}	//"Data final do periodo. Baseado na database do sistema."

	ElseIf cTable == "DTA"

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0270	//"Aloca��o de?"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0270	//"Aloca��o de?"
		aRet[nAux][DEF_IDENTIFICADOR] := "DTA_DTINI"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "D"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "D"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 8
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.T.}
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "01"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .T.
		aRet[nAux][DEF_HELP] := {STR0271}	//"Inicio do periodo de Aloca��o."

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0272	//"Aloca��o at�?"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0272	//"Aloca��o at�?"
		aRet[nAux][DEF_IDENTIFICADOR] := "DTA_DTFIM"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "D"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "D"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 8
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.T.}
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "02"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .T.
		aRet[nAux][DEF_HELP] := {STR0273}	//"Fim do periodo de aloca��o"

	ElseIf cTable == "PRJ"

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0266	//"Data Inicial"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0266	//"Data Inicial"
		aRet[nAux][DEF_IDENTIFICADOR] := "PRJ_DTINI"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "D"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "D"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 8
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.T.}
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_CODEBLOCK_INIT] := {|| dDataBase}
		aRet[nAux][DEF_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "01"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .T.
		aRet[nAux][DEF_HELP] := {STR0274}	//"Data inicial para visualiza��o do per�odo de aloca��o."

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0268		//"Data Final"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0268	//"Data Final"
		aRet[nAux][DEF_IDENTIFICADOR] := "PRJ_DTFIM"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "D"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "D"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 8
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.T.}
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_CODEBLOCK_INIT] := {|| dDataBase}
		aRet[nAux][DEF_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "02"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .T.
		aRet[nAux][DEF_HELP] := {STR0275}	//"Data final para visualiza��o do per�odo de aloca��o"

	ElseIf cTable == "MAN"

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := GetSX3Cache( "ABR_MOTIVO", cDescri )  //"Motivo da Manute��o"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := GetSX3Cache( "ABR_MOTIVO", cDescri ) //"Motivo da Manute��o"
		aRet[nAux][DEF_IDENTIFICADOR] := "MAN_MOTIVO"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("ABR_MOTIVO")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] :=  {|| .F. }
		aRet[nAux][DEF_CODEBLOCK_VALID] := {|a,b,c| At190dMark() .AND. At190dMntP(c)}
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "01"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_LOOKUP] := "T19DMN" //At190dCons("MANUT")
		aRet[nAux][DEF_CAN_CHANGE] := .T.
		aRet[nAux][DEF_HELP] := {STR0276}	//"C�digo do motivo da manuten��o na agenda."

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := GetSX3Cache( "ABR_HRINI", cDescri )  //"Hora Inicial"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := GetSX3Cache( "ABR_HRINI", cDescri ) //"Hora Inicial"
		aRet[nAux][DEF_IDENTIFICADOR] := "MAN_HRINI"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("ABB_HRINI")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .F. }
		aRet[nAux][DEF_CODEBLOCK_VALID] := {|| At190dMark() .AND. AtVldHora(At190dGVal("MANMASTER","MAN_HRINI"))}
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_RECEBE_VAL] := .F.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "03"
		aRet[nAux][DEF_PICTURE] := "99:99"
		aRet[nAux][DEF_CAN_CHANGE] := .T.
		aRet[nAux][DEF_HELP] := {STR0097}	//"Hora inicial para a manuten��o."

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := GetSX3Cache( "ABR_HRFIM", cDescri )  //"Hora Final"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := GetSX3Cache( "ABR_HRFIM", cDescri ) //"Hora Final"
		aRet[nAux][DEF_IDENTIFICADOR] := "MAN_HRFIM"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("ABB_HRFIM")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .F. }
		aRet[nAux][DEF_CODEBLOCK_VALID] := {||At190dMark() .AND. AtVldHora(At190dGVal("MANMASTER","MAN_HRFIM"))}
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_RECEBE_VAL] := .F.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "05"
		aRet[nAux][DEF_PICTURE] := "99:99"
		aRet[nAux][DEF_CAN_CHANGE] := .T.
		aRet[nAux][DEF_HELP] := {STR0098}	//"Hora final para a manuten��o."

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0277		//"Modifica Data?"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0277	//"Modifica Data?"
		aRet[nAux][DEF_IDENTIFICADOR] := "MAN_MODDT"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 90
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .F. }
		aRet[nAux][DEF_CODEBLOCK_VALID] := {|| .T. }
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "06"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .T.

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := GetSX3Cache( "ABR_CODSUB", cDescri )  //"Atendente Substituto"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := GetSX3Cache( "ABR_CODSUB", cDescri ) //"Atendente Substituto"
		aRet[nAux][DEF_IDENTIFICADOR] := "MAN_CODSUB"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("ABR_CODSUB")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .F. }
		aRet[nAux][DEF_CODEBLOCK_VALID] := {||At190dMark()}
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "07"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_LOOKUP] := "T19AA1"//At190dCons("AA1")
		aRet[nAux][DEF_CAN_CHANGE] := .T.
		aRet[nAux][DEF_HELP] := {STR0278}	//"C�digo do atendente que substituiu o atendente original do agendamento."

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := GetSX3Cache( "ABR_USASER", cDescri )  //"Usa Servi�o?"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := GetSX3Cache( "ABR_USASER", cDescri ) //"Usa Servi�o?"
		aRet[nAux][DEF_IDENTIFICADOR] := "MAN_USASER"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("ABR_USASER")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_INIT] := {||2}
		aRet[nAux][DEF_LISTA_VAL] := { "1="+STR0533, "2="+STR0534} // SIM ## N�O
		aRet[nAux][DEF_COMBO_VAL] := { "1="+STR0533, "2="+STR0534} // SIM ## N�O
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .F. }
		aRet[nAux][DEF_CODEBLOCK_VALID] := {||At190dMark()}
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "08"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .T.
		aRet[nAux][DEF_HELP] := {STR0279}	//"Indica se deve usar o servi�o definido no cadastro do motivo de manuten��o, na gera��o do atendimento da ordem de servi�o."

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := GetSX3Cache( "ABR_TIPDIA", cDescri )  //"Tipo do dia"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := GetSX3Cache( "ABR_TIPDIA", cDescri ) //"Tipo do dia"
		aRet[nAux][DEF_IDENTIFICADOR] := "MAN_TIPDIA"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("ABR_TIPDIA")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_INIT] := {||1}
		aRet[nAux][DEF_LISTA_VAL] := {" " ,"S="+STR0193,"N="+STR0197} //"S=Trabalhado"#"N=N�o Trabalhado"
		aRet[nAux][DEF_COMBO_VAL] := {" " ,"S="+STR0193,"N="+STR0197} //"S=Trabalhado"#"N=N�o Trabalhado"
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .F. }
		aRet[nAux][DEF_CODEBLOCK_VALID] := {||At190dMark()}
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "09"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .T.
		aRet[nAux][DEF_HELP] := {STR0280}	//"Preencher com o Tipo de Dia."

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0410 //"Mod.Dt.Ini"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0410 //"Mod.Dt.Ini"
		aRet[nAux][DEF_IDENTIFICADOR] := "MAN_MODINI"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "N"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "N"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 2
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "10"
		aRet[nAux][DEF_PICTURE] := "@E ##"
		aRet[nAux][DEF_CAN_CHANGE] := .T.

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0411 //"Mod.Dt.Fim"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0411 //"Mod.Dt.Fim"
		aRet[nAux][DEF_IDENTIFICADOR] := "MAN_MODFIM"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "N"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "N"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 2
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "11"
		aRet[nAux][DEF_PICTURE] := "@E ##"
		aRet[nAux][DEF_CAN_CHANGE] := .T.

	ElseIf cTable == "TGY"

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := GetSX3Cache( "CN9_FILIAL", cDescri )  //"Numero do Contrato"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := GetSX3Cache( "CN9_FILIAL", cDescri ) //"Numero do Contrato"
		aRet[nAux][DEF_IDENTIFICADOR] := "TGY_FILIAL"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := Len(cFilAnt)
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||!Empty(FwFldGet("AA1_CODTEC"))}
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "01"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_LOOKUP] := "SM0"
		aRet[nAux][DEF_CAN_CHANGE] := .T.
		aRet[nAux][DEF_CODEBLOCK_INIT] := {|| cFilAnt}
		aRet[nAux][DEF_HELP] := {"Filial utilizada para buscar o contrato"}

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := GetSX3Cache( "CN9_NUMERO", cDescri )  //"Numero do Contrato"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := GetSX3Cache( "CN9_NUMERO", cDescri ) //"Numero do Contrato"
		aRet[nAux][DEF_IDENTIFICADOR] := "TGY_CONTRT"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("CN9_NUMERO")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||!Empty(FwFldGet("AA1_CODTEC"))}
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "02"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_LOOKUP] := "T19DCN" //At190dCons("CONTRATO")
		aRet[nAux][DEF_CAN_CHANGE] := .T.
		aRet[nAux][DEF_HELP] := {STR0060}	//"N�mero do contrato."

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0031	//"Local de Atendimento"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0031	//"Local de Atendimento"
		aRet[nAux][DEF_IDENTIFICADOR] := "TGY_CODTFL"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TFL_CODIGO")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .F. }
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "03"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_LOOKUP] := "T19DYL" //At190dCons("LOCAL_TGY")
		aRet[nAux][DEF_CAN_CHANGE] := .T.
		aRet[nAux][DEF_HELP] := {STR0094}	//"C�digo do Local de Atendimento."

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := GetSX3Cache( "ABS_DESCRI", cDescri )  //"Descri��o do Local"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := GetSX3Cache( "ABS_DESCRI", cDescri ) //"Descri��o do Local"
		aRet[nAux][DEF_IDENTIFICADOR] := "TGY_DESLOC"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("ABS_DESCRI")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "04"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .F.
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0063	//"Posto"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0063	//"Posto"
		aRet[nAux][DEF_IDENTIFICADOR] := "TGY_TFFCOD"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TFF_COD")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .F. }
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "05"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_LOOKUP] := "T19DTF" //At190dCons("POSTO")
		aRet[nAux][DEF_CAN_CHANGE] := .T.
		aRet[nAux][DEF_HELP] := {STR0064}	//"C�digo de recursos humanos."

		If TecABBPRHR()
			AADD(aRet, ARRAY(QUANTIDADE_DEFS))
			nAux := LEN(aRet)
			aRet[nAux][DEF_TITULO_DO_CAMPO] := "Horas Totais"	//"Posto"
			aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := "Horas Totais"	//"Posto"
			aRet[nAux][DEF_IDENTIFICADOR] := "TGY_TFFHRS"
			aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
			aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
			aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TFF_QTDHRS")[1]
			aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
			aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .F. }
			aRet[nAux][DEF_OBRIGAT] := .F.
			aRet[nAux][DEF_RECEBE_VAL] := .T.
			aRet[nAux][DEF_VIRTUAL] := .T.
			aRet[nAux][DEF_ORDEM] := "06"
			aRet[nAux][DEF_PICTURE] := "99:99"
			aRet[nAux][DEF_CAN_CHANGE] := .T.
			aRet[nAux][DEF_HELP] := {STR0064}	//"C�digo de recursos humanos."
		EndIf

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := GetSX3Cache( "TFF_ESCALA", cDescri )  //"C�digo da Escala"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := GetSX3Cache( "TFF_ESCALA", cDescri ) //"C�digo da Escala"
		aRet[nAux][DEF_IDENTIFICADOR] := "TGY_ESCALA"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TFF_ESCALA")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .F. }
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "07"
		aRet[nAux][DEF_PICTURE] := "@!"
		If !lMV_MultFil
			aRet[nAux][DEF_LOOKUP] := "TDW"
		Else
			aRet[nAux][DEF_LOOKUP] := "T19TDW" //At190dCons("TDW")
		EndIf
		aRet[nAux][DEF_CAN_CHANGE] := .T.
		aRet[nAux][DEF_HELP] := {STR0065}	//"Preencher com C�digo da Escala."

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := GetSX3Cache( "TGY_TIPALO", cDescri )  //"Tipo Movimenta��o"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := GetSX3Cache( "TGY_TIPALO", cDescri ) //"Tipo Movimenta��o"
		aRet[nAux][DEF_IDENTIFICADOR] := "TGY_TIPALO"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TGY_TIPALO")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .F. }
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "08"
		aRet[nAux][DEF_PICTURE] := "@!"
		If !lMV_MultFil
			aRet[nAux][DEF_LOOKUP] := "TCUALC"
		Else
			aRet[nAux][DEF_LOOKUP] := "T19TCU" //At190dCons("TCU")
		EndIf
		aRet[nAux][DEF_CAN_CHANGE] := .T.
		aRet[nAux][DEF_HELP] := {STR0066}	//"Informe o tipo de movimenta��o."

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0067	//"Desc. Movim."
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0067	//"Desc. Movim."
		aRet[nAux][DEF_IDENTIFICADOR] := "TGY_DESMOV"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TCU_DESC")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
		aRet[nAux][DEF_RECEBE_VAL] := .F.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "09"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .F.
		aRet[nAux][DEF_HELP] := {STR0068}	//"Descri��o do tipo de movimenta��o."

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0069	//"Seq. Inicial"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0069	//"Seq. Inicial"
		aRet[nAux][DEF_IDENTIFICADOR] := "TGY_SEQ"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TGY_SEQ")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .F. }
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "10"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .T.
		aRet[nAux][DEF_LOOKUP] := "T19SEQ" //At190dCons("SEQ")
		aRet[nAux][DEF_HELP] := {STR0070}	//"Preencher com Sequencia do Turno."

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := GetSX3Cache( "TGY_GRUPO", cDescri )  //"Grupo"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := GetSX3Cache( "TGY_GRUPO", cDescri ) //"Grupo"
		aRet[nAux][DEF_IDENTIFICADOR] := "TGY_GRUPO"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "N"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "N"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TGY_GRUPO")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .F. }
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "11"
		aRet[nAux][DEF_PICTURE] := "@E 999"
		aRet[nAux][DEF_CAN_CHANGE] := .T.
		aRet[nAux][DEF_LOOKUP] := "T19GRP" //At190dCons("TGY_GRUPO")
		aRet[nAux][DEF_HELP] := {STR0071}	//"Preencher com grupo do atendente."

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0072	//"Dt. �ltima Aloca��o"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0072	//"Dt. �ltima Aloca��o"
		aRet[nAux][DEF_IDENTIFICADOR] := "TGY_ULTALO"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "D"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "D"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 8
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "12"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .T.

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0073	//"RECNO"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0073	//"RECNO"
		aRet[nAux][DEF_IDENTIFICADOR] := "TGY_RECNO"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "N"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "N"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 16
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "13"
		aRet[nAux][DEF_CAN_CHANGE] := .T.

		cOrdem := "13"
		For nC := 1 to 4
			cOrdem := Soma1(cOrdem)
			cCampoE := "TGY_ENTRA" + Str(nC,1)
			AADD(aRet, ARRAY(QUANTIDADE_DEFS))
			nAux := LEN(aRet)
			aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0074 + Str(nC,1)	//"Hora Ini "
			aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0075 + Str(nC,1)	//"Hor�rio de Entrada "
			aRet[nAux][DEF_IDENTIFICADOR] := cCampoE
			aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
			aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
			aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 5
			aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
			aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
			aRet[nAux][DEF_OBRIGAT] := .F.
			aRet[nAux][DEF_RECEBE_VAL] := .T.
			aRet[nAux][DEF_VIRTUAL] := .T.
			aRet[nAux][DEF_ORDEM] := cOrdem
			aRet[nAux][DEF_PICTURE] := "@!"
			aRet[nAux][DEF_CAN_CHANGE] := .T.

			cCampoS := "TGY_SAIDA" + Str(nC,1)
			cOrdem := Soma1(cOrdem)
			AADD(aRet, ARRAY(QUANTIDADE_DEFS))
			nAux := LEN(aRet)
			aRet[nAux][DEF_TITULO_DO_CAMPO] :=  STR0076 + Str(nC,1)	//"Hora Fim "
			aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0077 + Str(nC,1)	//"Hor�rio de Sa�da "
			aRet[nAux][DEF_IDENTIFICADOR] := cCampoS
			aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
			aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
			aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 5
			aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
			aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
			aRet[nAux][DEF_OBRIGAT] := .F.
			aRet[nAux][DEF_RECEBE_VAL] := .T.
			aRet[nAux][DEF_VIRTUAL] := .T.
			aRet[nAux][DEF_ORDEM] := cOrdem
			aRet[nAux][DEF_PICTURE] := "@!"
			aRet[nAux][DEF_CAN_CHANGE] := .T.
		Next nC

	ElseIf cTable == "ALC"

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0078		//"Agenda"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0078		//"Agenda"
		aRet[nAux][DEF_IDENTIFICADOR] := "ALC_SITABB"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "BT"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "BT"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 1
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_VALID] := {||At330AGtLA()}
		aRet[nAux][DEF_CODEBLOCK_INIT] := {|| "BR_VERDE"}
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "01"
		aRet[nAux][DEF_PICTURE] := ""
		aRet[nAux][DEF_CAN_CHANGE] := .T.

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0079	//"Status"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0079	//"Status"
		aRet[nAux][DEF_IDENTIFICADOR] := "ALC_SITALO"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "BT"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "BT"
		aRet[nAux][DEF_CODEBLOCK_INIT] := {|| "BR_VERDE"}
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 1
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_VALID] := {||At330AGtLS()}
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "02"
		aRet[nAux][DEF_PICTURE] := ""
		aRet[nAux][DEF_CAN_CHANGE] := .T.

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := GetSX3Cache( "TGY_GRUPO", cDescri )  //"Grupo"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := GetSX3Cache( "TGY_GRUPO", cDescri ) //"Grupo"
		aRet[nAux][DEF_IDENTIFICADOR] := "ALC_GRUPO"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "N"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "N"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TGY_GRUPO")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_RECEBE_VAL] := .F.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "03"
		aRet[nAux][DEF_PICTURE] := "@E 999"
		aRet[nAux][DEF_CAN_CHANGE] := .F.
		aRet[nAux][DEF_HELP] := {STR0071}	//"Preencher com grupo do atendente."

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0080	//"Dt. Refer�ncia"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0080	//"Dt. Refer�ncia"
		aRet[nAux][DEF_IDENTIFICADOR] := "ALC_DATREF"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "D"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "D"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 8
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "04"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .T.
		aRet[nAux][DEF_HELP] := {STR0081}	//"Data da aloca��o."

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0082	//"Data"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0082	//"Data"
		aRet[nAux][DEF_IDENTIFICADOR] := "ALC_DATA"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "D"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "D"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 8
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "05"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .T.
		aRet[nAux][DEF_HELP] := {STR0081}	//"Data da aloca��o."

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0027	//"Dia da Semana"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0027	//"Dia da Semana"
		aRet[nAux][DEF_IDENTIFICADOR] := "ALC_SEMANA"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 15
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_RECEBE_VAL] := .F.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "06"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .F.
		aRet[nAux][DEF_HELP] := {STR0083}	//"Dia da semana."

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0084	//"Hora de Entrada"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0084	//"Hora de Entrada"
		aRet[nAux][DEF_IDENTIFICADOR] := "ALC_ENTRADA"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 5
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| !Empty( At190dGVal("ALCDETAIL", "ALC_DATREF"))}
		aRet[nAux][DEF_CODEBLOCK_VALID] := {|oMdl,cField,xNewValue| At190dHora(oMdl,cField,xNewValue)}
		aRet[nAux][DEF_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "07"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .T.
		aRet[nAux][DEF_HELP] := {STR0084}	//"Hora de Entrada"

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0085	//"Hora de Sa�da"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0085	//"Hora de Sa�da"
		aRet[nAux][DEF_IDENTIFICADOR] := "ALC_SAIDA"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 5
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| !Empty( At190dGVal("ALCDETAIL", "ALC_DATREF"))}
		aRet[nAux][DEF_CODEBLOCK_VALID] := {|oMdl,cField,xNewValue| At190dHora(oMdl,cField,xNewValue)}
		aRet[nAux][DEF_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "08"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .T.
		aRet[nAux][DEF_HELP] := {STR0085}	//"Hora de Sa�da"

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0086	//"Sequencia"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0086	//"Sequencia"
		aRet[nAux][DEF_IDENTIFICADOR] := "ALC_SEQ"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 2
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "09"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .T.
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
		aRet[nAux][DEF_HELP] := {STR0070}	//"Preencher com Sequencia do Turno."

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0087	//"Tipo"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0087	//"Tipo"
		aRet[nAux][DEF_IDENTIFICADOR] := "ALC_TIPO"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 1
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| !Empty( At190dGVal("ALCDETAIL", "ALC_DATREF"))}
		aRet[nAux][DEF_LISTA_VAL] := { "S="+STR0193, "C="+STR0194, "D="+STR0195, "E="+STR0490,"I="+STR0196,"N="+STR0197} //"S=Trabalhado;C=Compensado;D=D.S.R.;E=Hora Extra;I=Intervalo;N=Nao Trabalhado"
		aRet[nAux][DEF_COMBO_VAL] := { "S="+STR0193, "C="+STR0194, "D="+STR0195, "E="+STR0490,"I="+STR0196,"N="+STR0197}  //"S=Trabalhado;C=Compensado;D=D.S.R.;E=Hora Extra;I=Intervalo;N=Nao Trabalhado"
		aRet[nAux][DEF_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "10"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .T.
		aRet[nAux][DEF_HELP] := {STR0088}	//"Tipo de dia: Trabalhado, n�o trabalhado, folga ou DSR."

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := "KeyTGY"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := "KeyTGY"
		aRet[nAux][DEF_IDENTIFICADOR] := "ALC_KEYTGY"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TGY_ESCALA")[1] + TamSX3("TGY_CODTDX")[1] + TamSX3("TGY_CODTFF")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "11"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .T.

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0413 //"ItemTGY"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0413 //"ItemTGY"
		aRet[nAux][DEF_IDENTIFICADOR] := "ALC_ITTGY"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TGY_ITEM")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "12"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .T.

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := "EXSABB"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := "EXSABB"
		aRet[nAux][DEF_IDENTIFICADOR] := "ALC_EXSABB"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 1
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "13"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .T.

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0089	//"Turno"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0089	//"Turno"
		aRet[nAux][DEF_IDENTIFICADOR] := "ALC_TURNO"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TFF_TURNO")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "14"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .T.
		aRet[nAux][DEF_HELP] := {STR0090}	//"Preencher com o C�digo do Turno."

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0414 //"Item"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0414 //"Item"
		aRet[nAux][DEF_IDENTIFICADOR] := "ALC_ITEM"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "N"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "N"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 6
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "15"
		aRet[nAux][DEF_CAN_CHANGE] := .T.

	ElseIf cTable == "TFL"

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := GetSX3Cache( "CN9_FILIAL", cDescri )  //"Numero do Contrato"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := GetSX3Cache( "CN9_FILIAL", cDescri ) //"Numero do Contrato"
		aRet[nAux][DEF_IDENTIFICADOR] := "TFL_FILIAL"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := Len(cFilAnt)
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "01"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_LOOKUP] := "SM0"
		aRet[nAux][DEF_CAN_CHANGE] := .T.
		aRet[nAux][DEF_CODEBLOCK_INIT] := {|| cFilAnt}
		aRet[nAux][DEF_HELP] := {"Filial utilizada para buscar os atendentes"}

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := GetSX3Cache( "A1_COD", cDescri )  //"Codigo do Cliente"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := GetSX3Cache( "A1_COD", cDescri ) //"Codigo do Cliente"
		aRet[nAux][DEF_IDENTIFICADOR] := "TFL_CODENT"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("A1_COD")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "02"
		aRet[nAux][DEF_PICTURE] := "@!"
		If !lMV_MultFil
			aRet[nAux][DEF_LOOKUP] := "SA1"
		Else
			aRet[nAux][DEF_LOOKUP] := "T19SA1" //At190dCons("CLIENTE_TFL")
		EndIf
		aRet[nAux][DEF_CAN_CHANGE] := .T.
		aRet[nAux][DEF_CODEBLOCK_VALID] := {|| At19OVlTFL("TFL_CODENT") }
		aRet[nAux][DEF_HELP] := {STR0091}	//"C�digo que individualiza  cada um dos clientes da empresa."

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := GetSX3Cache( "A1_LOJA", cDescri )  //"Loja do Cliente"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := GetSX3Cache( "A1_LOJA", cDescri ) //"Loja do Cliente"
		aRet[nAux][DEF_IDENTIFICADOR] := "TFL_LOJA"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("A1_LOJA")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "03"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .T.
		aRet[nAux][DEF_CODEBLOCK_VALID] := {||At19OVlTFL("TFL_LOJA")}
		aRet[nAux][DEF_HELP] := {STR0092}	//"C�digo que identifica a loja do Cliente."

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := GetSX3Cache( "A1_NOME", cDescri )  //"Nome do Cliente "
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := GetSX3Cache( "A1_NOME", cDescri ) //"Nome do Cliente"
		aRet[nAux][DEF_IDENTIFICADOR] := "TFL_NOMENT"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("A1_NOME")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "04"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .F.
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := GetSX3Cache( "TFL_CONTRT", cDescri )  //"Numero do Contrato"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := GetSX3Cache( "TFL_CONTRT", cDescri ) //"Numero do Contrato"
		aRet[nAux][DEF_IDENTIFICADOR] := "TFL_CONTRT"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TFL_CONTRT")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "05"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_LOOKUP] := "T19DCL" //At190dCons("CONTRATO_TFL")
		aRet[nAux][DEF_CAN_CHANGE] := .T.
		aRet[nAux][DEF_CODEBLOCK_VALID] := {||At19OVlTFL("TFL_CONTRT")}
		aRet[nAux][DEF_HELP] := {STR0093}	//"Numero do contrato do GCT."

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0031	//"Local de Atendimento"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0031	//"Local de Atendimento"
		aRet[nAux][DEF_IDENTIFICADOR] := "TFL_LOCAL"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("ABS_LOCAL")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "06"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_LOOKUP] := "T19DLL" //At190dCons("LOCAL_TFL")
		aRet[nAux][DEF_CAN_CHANGE] := .T.
		aRet[nAux][DEF_CODEBLOCK_VALID] := {||At19OVlTFL("TFL_LOCAL")}
		aRet[nAux][DEF_HELP] := {STR0094}	//"C�digo do Local de Atendimento."

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := GetSX3Cache( "ABS_DESCRI", cDescri )  //"Descri��o do Local"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := GetSX3Cache( "ABS_DESCRI", cDescri ) //"Descri��o do Local"
		aRet[nAux][DEF_IDENTIFICADOR] := "TFL_DESLOC"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("ABS_DESCRI")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "07"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .F.
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0032	//"Item de Recursos Humanos"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0032	//"Item de Recursos Humanos"
		aRet[nAux][DEF_IDENTIFICADOR] := "TFL_PROD"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("B1_COD")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "08"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_LOOKUP] := "T19DBL" //At190dCons("PROD_TFL")
		aRet[nAux][DEF_CAN_CHANGE] := .T.
		aRet[nAux][DEF_CODEBLOCK_VALID] := {||At19OVlTFL("TFL_PROD")}
		aRet[nAux][DEF_HELP] := {STR0062}	//"C�digo do produto de recursos humanos"

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0063	//"Posto"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0063	//"Posto"
		aRet[nAux][DEF_IDENTIFICADOR] := "TFL_TFFCOD"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TFF_COD")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "09"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_LOOKUP] := "T19DFL" //At190dCons("POSTO_TFL")
		aRet[nAux][DEF_CAN_CHANGE] := .T.
		aRet[nAux][DEF_CODEBLOCK_VALID] := {||At19OVlTFL("TFL_TFFCOD")}
		aRet[nAux][DEF_HELP] := {STR0061}	//"C�digo do Posto"

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := GetSX3Cache( "TFF_NOMESC", cDescri )  //"Descri��o da escala"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := GetSX3Cache( "TFF_NOMESC", cDescri ) //"Descri��o da escala"
		aRet[nAux][DEF_IDENTIFICADOR] := "TFL_NOMESC"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TFF_NOMESC")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "10"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .F.
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}

	ElseIf cTable == "HOJ"

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0087	//"Tipo"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0087	//"Tipo"
		aRet[nAux][DEF_IDENTIFICADOR] := "HOJ_LEGEND"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "BT"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "BT"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 1
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_VALID] := {||At19DLegHj()}
		aRet[nAux][DEF_CODEBLOCK_INIT] := {|| "BR_VERDE"}
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "01"
		aRet[nAux][DEF_PICTURE] := ""
		aRet[nAux][DEF_CAN_CHANGE] := .T.

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := GetSX3Cache( "AA1_CODTEC", cDescri )  //"C�digo do Atendente"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := GetSX3Cache( "AA1_CODTEC", cDescri ) //"C�digo do Atendente"
		aRet[nAux][DEF_IDENTIFICADOR] := "HOJ_CODTEC"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("AA1_CODTEC")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_RECEBE_VAL] := .F.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "02"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .F.
		aRet[nAux][DEF_HELP] := {STR0095}	//"C�digo do Atendente."

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := GetSX3Cache( "AA1_NOMTEC", cDescri )  //"Nome do Atendente"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := GetSX3Cache( "AA1_NOMTEC", cDescri ) //"Nome do Atendente"
		aRet[nAux][DEF_IDENTIFICADOR] := "HOJ_NOMTEC"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("AA1_NOMTEC")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
		aRet[nAux][DEF_RECEBE_VAL] := .F.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "03"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .F.
		aRet[nAux][DEF_HELP] := {STR0096}	//"Nome do Atendente."

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := GetSX3Cache( "ABR_HRINI", cDescri )  //"Hora Inicial"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := GetSX3Cache( "ABR_HRINI", cDescri ) //"Hora Inicial"
		aRet[nAux][DEF_IDENTIFICADOR] := "HOJ_HRINI"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("ABB_HRINI")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_RECEBE_VAL] := .F.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "04"
		aRet[nAux][DEF_CAN_CHANGE] := .F.

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := GetSX3Cache( "ABR_HRFIM", cDescri )  //"Hora Final"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := GetSX3Cache( "ABR_HRFIM", cDescri ) //"Hora Final"
		aRet[nAux][DEF_IDENTIFICADOR] := "HOJ_HRFIM"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("ABB_HRFIM")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_RECEBE_VAL] := .F.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "05"
		aRet[nAux][DEF_CAN_CHANGE] := .F.

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0415 //"Situa��o"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0415 //"Situa��o"
		aRet[nAux][DEF_IDENTIFICADOR] := "HOJ_SITUAC"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 35
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
		aRet[nAux][DEF_RECEBE_VAL] := .F.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "06"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .F.

	ElseIf cTable == "LOC"

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0026	//"Mark"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0026	//"Mark"
		aRet[nAux][DEF_IDENTIFICADOR] := "LOC_MARK"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "L"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "CHECK"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 1
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .T. }
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "01"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .T.

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0087	//"Tipo"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0087	//"Tipo"
		aRet[nAux][DEF_IDENTIFICADOR] := "LOC_LEGEND"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "BT"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "BT"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 1
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_VALID] := {||At19DAGtLA("LOC_LEGEND")}
		aRet[nAux][DEF_CODEBLOCK_INIT] := {|| "BR_VERDE"}
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "02"
		aRet[nAux][DEF_PICTURE] := ""
		aRet[nAux][DEF_CAN_CHANGE] := .T.

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := GetSX3Cache( "ABB_FILIAL", cDescri )
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := GetSX3Cache( "ABB_FILIAL", cDescri )
		aRet[nAux][DEF_IDENTIFICADOR] := "LOC_FILIAL"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("ABB_FILIAL")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
		aRet[nAux][DEF_RECEBE_VAL] := .F.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "03"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .F.
		aRet[nAux][DEF_HELP] := {STR0491} //"Filial da agenda"

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := GetSX3Cache( "AA1_CODTEC", cDescri )  //"C�digo do Atendente"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := GetSX3Cache( "AA1_CODTEC", cDescri )  //"C�digo do Atendente"
		aRet[nAux][DEF_IDENTIFICADOR] := "LOC_CODTEC"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("AA1_CODTEC")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_RECEBE_VAL] := .F.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "04"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .F.
		aRet[nAux][DEF_HELP] := {STR0095}	//"C�digo do Atendente."

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := GetSX3Cache( "AA1_NOMTEC", cDescri )  //"Nome do Atendente"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := GetSX3Cache( "AA1_NOMTEC", cDescri )  //"Nome do Atendente"
		aRet[nAux][DEF_IDENTIFICADOR] := "LOC_NOMTEC"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("AA1_NOMTEC")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
		aRet[nAux][DEF_RECEBE_VAL] := .F.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "05"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .F.
		aRet[nAux][DEF_HELP] := {STR0096}	//"Nome do Atendente."

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0012		//"Data de Refer�ncia"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0012		//"Data de Refer�ncia"
		aRet[nAux][DEF_IDENTIFICADOR] := "LOC_DTREF"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "D"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "D"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 8
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_RECEBE_VAL] := .F.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "06"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .F.
		aRet[nAux][DEF_HELP] := {STR0012}	//"Data de Refer�ncia"

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0027	//"Dia da Semana"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0027	//"Dia da Semana"
		aRet[nAux][DEF_IDENTIFICADOR] := "LOC_DOW"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 20
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
		aRet[nAux][DEF_RECEBE_VAL] := .F.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "07"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .F.
		aRet[nAux][DEF_HELP] := {STR0083}	//"Dia da semana."

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := GetSX3Cache( "ABR_HRINI", cDescri )  //"Hora Inicial"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := GetSX3Cache( "ABR_HRINI", cDescri ) //"Hora Inicial"
		aRet[nAux][DEF_IDENTIFICADOR] := "LOC_HRINI"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("ABB_HRINI")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_RECEBE_VAL] := .F.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "08"
		aRet[nAux][DEF_CAN_CHANGE] := .F.
		aRet[nAux][DEF_HELP] := {STR0097}	//"Hora inicial para a manuten��o."

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := GetSX3Cache( "ABR_HRFIM", cDescri )  //"Hora Final"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := GetSX3Cache( "ABR_HRFIM", cDescri ) //"Hora Final"
		aRet[nAux][DEF_IDENTIFICADOR] := "LOC_HRFIM"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("ABB_HRFIM")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_RECEBE_VAL] := .F.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "09"
		aRet[nAux][DEF_CAN_CHANGE] := .F.
		aRet[nAux][DEF_HELP] := {STR0098}	//"Hora final para a manuten��o."

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0366 //"Observa��es"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0366 //"Observa��es"
		aRet[nAux][DEF_IDENTIFICADOR] := "LOC_OBSERV"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("ABB_OBSERV")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| GetSX3Cache( "ABB_OBSERV", "X3_VISUAL") == 'A' .AND. !Empty( At190dGVal("LOCDETAIL", "LOC_DTREF"))}
		aRet[nAux][DEF_RECEBE_VAL] := .F.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "10"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .T.
		aRet[nAux][DEF_HELP] := {STR0367} //"Observa��es na agenda"

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0031	//"Local de Atendimento"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0031	//"Local de Atendimento"
		aRet[nAux][DEF_IDENTIFICADOR] := "LOC_ABSDSC"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("ABS_DESCRI")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
		aRet[nAux][DEF_RECEBE_VAL] := .F.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "11"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .F.
		aRet[nAux][DEF_HELP] := {STR0098}	//"Descri��o do Local de Atendimento."

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0032	//"Item de Recursos Humanos"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0032	//"Item de Recursos Humanos"
		aRet[nAux][DEF_IDENTIFICADOR] := "LOC_B1DESC"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("B1_DESC")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
		aRet[nAux][DEF_RECEBE_VAL] := .F.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "12"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .F.
		aRet[nAux][DEF_HELP] := {STR0032}	//"Itens de Recursos Humanos."

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := GetSX3Cache( "ABB_TIPOMV", cDescri )  //"Tipo da Movimento"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := GetSX3Cache( "ABB_TIPOMV", cDescri ) //"Tipo da Movimento"
		aRet[nAux][DEF_IDENTIFICADOR] := "LOC_TIPOMV"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("ABB_TIPOMV")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
		aRet[nAux][DEF_RECEBE_VAL] := .F.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "13"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .F.
		aRet[nAux][DEF_HELP] := {STR0034}	//"C�digo do tipo de movimenta��o."

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := GetSX3Cache( "ABB_ATIVO", cDescri )  //"Agenda Ativa?"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := GetSX3Cache( "ABB_ATIVO", cDescri ) //"Agenda Ativa?"
		aRet[nAux][DEF_IDENTIFICADOR] := "LOC_ATIVO"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("ABB_ATIVO")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
		aRet[nAux][DEF_RECEBE_VAL] := .F.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "14"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .F.
		aRet[nAux][DEF_HELP] := {STR0035}	//"Indica se a agenda est� ativa ou n�o."

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := GetSX3Cache( "ABB_CODIGO", cDescri )  //"C�digo da Agenda"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := GetSX3Cache( "ABB_CODIGO", cDescri ) //"C�digo da Agenda"
		aRet[nAux][DEF_IDENTIFICADOR] := "LOC_CODABB"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("ABB_CODIGO")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
		aRet[nAux][DEF_RECEBE_VAL] := .F.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "15"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .F.
		aRet[nAux][DEF_HELP] := {STR0036}	//"C�digo da agenda para relacionamento com as manuten��es(ABR)."

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := GetSX3Cache( "ABS_LOCAL", cDescri )  //"C�digo da Agenda"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := GetSX3Cache( "ABS_LOCAL", cDescri ) //"C�digo da Agenda"
		aRet[nAux][DEF_IDENTIFICADOR] := "LOC_LOCAL"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("ABS_LOCAL")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
		aRet[nAux][DEF_RECEBE_VAL] := .F.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "16"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .F.
		aRet[nAux][DEF_HELP] := {STR0036}	//"C�digo da agenda para relacionamento com as manuten��es(ABR)."

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := GetSX3Cache( "ABB_DTINI", cDescri )  //"C�digo da Agenda"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := GetSX3Cache( "ABB_DTINI", cDescri ) //"C�digo da Agenda"
		aRet[nAux][DEF_IDENTIFICADOR] := "LOC_ABBDTI"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "D"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "D"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("ABB_DTINI")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
		aRet[nAux][DEF_RECEBE_VAL] := .F.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "17"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .F.
		aRet[nAux][DEF_HELP] := {STR0036}	//"C�digo da agenda para relacionamento com as manuten��es(ABR)."

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := GetSX3Cache( "ABB_DTFIM", cDescri )  //"C�digo da Agenda"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := GetSX3Cache( "ABB_DTFIM", cDescri ) //"C�digo da Agenda"
		aRet[nAux][DEF_IDENTIFICADOR] := "LOC_ABBDTF"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "D"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "D"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("ABB_DTFIM")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
		aRet[nAux][DEF_RECEBE_VAL] := .F.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "18"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .F.
		aRet[nAux][DEF_HELP] := {STR0036}	//"C�digo da agenda para relacionamento com as manuten��es(ABR)."

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := GetSX3Cache( "TFF_COD", cDescri )  //"C�digo da Agenda"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := GetSX3Cache( "TFF_COD", cDescri ) //"C�digo da Agenda"
		aRet[nAux][DEF_IDENTIFICADOR] := "LOC_TFFCOD"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TFF_COD")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
		aRet[nAux][DEF_RECEBE_VAL] := .F.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "19"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .F.
		aRet[nAux][DEF_HELP] := {STR0036}	//"C�digo da agenda para relacionamento com as manuten��es(ABR)."

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0406 //"Atende"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0406 //"Atende"
		aRet[nAux][DEF_IDENTIFICADOR] := "LOC_ATENDE"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 1
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_RECEBE_VAL] := .F.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "20"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .F.

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0407 //"Chegou"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0407 //"Chegou"
		aRet[nAux][DEF_IDENTIFICADOR] := "LOC_CHEGOU"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 1
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_RECEBE_VAL] := .F.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "21"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .F.

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := GetSX3Cache( "ABB_IDCFAL", cDescri )  //"Id.Conf.Aloca��o"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := GetSX3Cache( "ABB_IDCFAL", cDescri )  //"Id.Conf.Aloca��o"
		aRet[nAux][DEF_IDENTIFICADOR] := "LOC_IDCFAL"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("ABB_IDCFAL")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_RECEBE_VAL] := .F.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "22"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .F.

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0073	//"RECNO"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0073	//"RECNO"
		aRet[nAux][DEF_IDENTIFICADOR] := "LOC_RECABB"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "N"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "N"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 16
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "23"
		aRet[nAux][DEF_CAN_CHANGE] := .T.

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := GetSX3Cache( "ABB_FILIAL", cDescri )
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := GetSX3Cache( "ABB_FILIAL", cDescri )
		aRet[nAux][DEF_IDENTIFICADOR] := "LOC_DSCFIL"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := (LEN(cFilAnt) + LEN(FWFilialName()) + 3)
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
		aRet[nAux][DEF_RECEBE_VAL] := .F.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "24"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .F.
		aRet[nAux][DEF_HELP] := {STR0491} //"Filial da agenda"

	ElseIf cTable == "DTR"

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0012	//"Data de Refer�ncia"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0012	//"Data de Refer�ncia"
		aRet[nAux][DEF_IDENTIFICADOR] := "DTR_DTREF"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "D"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "D"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 8
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.T.}
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_CODEBLOCK_INIT] := {|| dDataBase}
		aRet[nAux][DEF_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "01"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .T.
		aRet[nAux][DEF_HELP] := {STR0012}	//"Data de Refer�ncia"

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0037	//"N� de Atendentes"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0037	//"N� de Atendentes"
		aRet[nAux][DEF_IDENTIFICADOR] := "DTR_NUMATD"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 4
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_CODEBLOCK_INIT] := {|| "0"}
		aRet[nAux][DEF_RECEBE_VAL] := .F.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "02"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .T.

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0416 //"Atendentes Efetivos"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0416 //"Atendentes Efetivos"
		aRet[nAux][DEF_IDENTIFICADOR] := "DTR_NUMEFE"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 4
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_CODEBLOCK_INIT] := {|| "0"}
		aRet[nAux][DEF_RECEBE_VAL] := .F.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "03"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .T.

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0417 //"Atendes com Faltas"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0417 //"Atendes com Faltas"
		aRet[nAux][DEF_IDENTIFICADOR] := "DTR_NUMFAL"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 4
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_CODEBLOCK_INIT] := {|| "0"}
		aRet[nAux][DEF_RECEBE_VAL] := .F.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "04"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .T.

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0418 //"Atendentes de folga"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0418 //"Atendentes de folga"
		aRet[nAux][DEF_IDENTIFICADOR] := "DTR_NUMFOL"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 4
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_CODEBLOCK_INIT] := {|| "0"}
		aRet[nAux][DEF_RECEBE_VAL] := .F.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "04"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .T.

	ElseIf cTable == "LCA"

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := GetSX3Cache( "CN9_FILIAL", cDescri )  //"Numero do Contrato"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := GetSX3Cache( "CN9_FILIAL", cDescri ) //"Numero do Contrato"
		aRet[nAux][DEF_IDENTIFICADOR] := "LCA_FILIAL"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := Len(cFilAnt)
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "01"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_LOOKUP] := "SM0"
		aRet[nAux][DEF_CAN_CHANGE] := .T.
		aRet[nAux][DEF_CODEBLOCK_INIT] := {|| cFilAnt}
		aRet[nAux][DEF_HELP] := {STR0496} //"Filial utilizada para buscar o contrato"

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := GetSX3Cache( "CN9_NUMERO", cDescri )  //"Numero do Contrato"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := GetSX3Cache( "CN9_NUMERO", cDescri ) //"Numero do Contrato"
		aRet[nAux][DEF_IDENTIFICADOR] := "LCA_CONTRT"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("CN9_NUMERO")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.T.}
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "02"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_LOOKUP] := "T19DCA" //At190dCons("CONTRATO_LCA")
		aRet[nAux][DEF_CAN_CHANGE] := .T.
		aRet[nAux][DEF_HELP] := {STR0060}	//"N�mero do contrato."

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0031	//"Local de Atendimento"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0031	//"Local de Atendimento"
		aRet[nAux][DEF_IDENTIFICADOR] := "LCA_CODTFL"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TFL_CODIGO")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .T. }
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "03"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_LOOKUP] := "T19CAL" //At190dCons("LOCAL_LCA")
		aRet[nAux][DEF_CAN_CHANGE] := .T.
		aRet[nAux][DEF_HELP] := {STR0094}	//"C�digo do Local de Atendimento."

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0063	//"Posto"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0063	//"Posto"
		aRet[nAux][DEF_IDENTIFICADOR] := "LCA_TFFCOD"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TFF_COD")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .T. }
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "04"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_LOOKUP] := "T19CAP" //At190dCons("POSTO_LCA")
		aRet[nAux][DEF_CAN_CHANGE] := .T.
		aRet[nAux][DEF_HELP] := {STR0064}	//"C�digo de recursos humanos."

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := GetSX3Cache( "TGY_TIPALO", cDescri )  //"Tipo Movimenta��o"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := GetSX3Cache( "TGY_TIPALO", cDescri ) //"Tipo Movimenta��o"
		aRet[nAux][DEF_IDENTIFICADOR] := "LCA_TIPTCU"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TGY_TIPALO")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .T. }
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "05"
		aRet[nAux][DEF_PICTURE] := "@!"
		If !lMV_MultFil
			aRet[nAux][DEF_LOOKUP] := "TCUALC"
		Else
			aRet[nAux][DEF_LOOKUP] := "T19TCA" //At190dCons("TCU_BUSCA")
		EndIf
		aRet[nAux][DEF_CAN_CHANGE] := .T.
		aRet[nAux][DEF_HELP] := {STR0520} //"Busca apenas atendentes com o Tipo de Movimenta��o informado neste campo (TGY_TIPALO = LCA_TIPTCU)"

	ElseIf cTable == "LGY"

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0079 //"Status"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0079 //"Status"
		aRet[nAux][DEF_IDENTIFICADOR] := "LGY_STATUS"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "BT"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "BT"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 1
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_VALID] := {||At190dllgy()}
		aRet[nAux][DEF_CODEBLOCK_INIT] := {|| "BR_VERMELHO"}
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "01"
		aRet[nAux][DEF_PICTURE] := ""
		aRet[nAux][DEF_CAN_CHANGE] := .T.

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0419 //"Tipo"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0419 //"Tipo"
		aRet[nAux][DEF_IDENTIFICADOR] := "LGY_TIPOAL"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 1
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_INIT] := {|| 1}
		aRet[nAux][DEF_LISTA_VAL] := { "1="+STR0497/*, "2=Cobertura"*/} //TODO Cobertura
		aRet[nAux][DEF_COMBO_VAL] := { "1="+STR0497/*, "2=Cobertura"*/} //TODO Cobertura
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.T.}
		aRet[nAux][DEF_CODEBLOCK_VALID] := {||.T.}
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "02"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .T.
		aRet[nAux][DEF_HELP] := {STR0420} //"Indica o tipo de aloca��o: 1= Efetivo tabela TGY ou 2=Cobertura, TGX"

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := GetSX3Cache( "AA1_CODTEC", cDescri )  //"Codigo do Atendente"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := GetSX3Cache( "AA1_CODTEC", cDescri ) //"Codigo do Atendente"
		aRet[nAux][DEF_IDENTIFICADOR] := "LGY_CODTEC"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("AA1_CODTEC")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_OBRIGAT] := .T.
		aRet[nAux][DEF_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "03"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_LOOKUP] := "T19AA1" //At190dCons("AA1")
		aRet[nAux][DEF_CAN_CHANGE] := .T.
		aRet[nAux][DEF_HELP] := {STR0023}	//"C�digo do atendente cadastrado no 'Gest�o de Servi�os'"

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := GetSX3Cache( "AA1_NOMTEC", cDescri )  //"Nome do Atendente"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := GetSX3Cache( "AA1_NOMTEC", cDescri )  //"Nome do Atendente"
		aRet[nAux][DEF_IDENTIFICADOR] := "LGY_NOMTEC"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("AA1_NOMTEC")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
		aRet[nAux][DEF_RECEBE_VAL] := .F.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "04"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .F.
		aRet[nAux][DEF_HELP] := {STR0096}	//"Nome do Atendente."

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0270	//"Aloca��o de?"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0270	//"Aloca��o de?"
		aRet[nAux][DEF_IDENTIFICADOR] := "LGY_DTINI"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "D"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "D"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 8
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.T.}
		aRet[nAux][DEF_OBRIGAT] := .T.
		aRet[nAux][DEF_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "05"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .T.
		aRet[nAux][DEF_HELP] := {STR0271}	//"Inicio do periodo de Aloca��o."

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0272	//"Aloca��o at�?"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0272	//"Aloca��o at�?"
		aRet[nAux][DEF_IDENTIFICADOR] := "LGY_DTFIM"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "D"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "D"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 8
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.T.}
		aRet[nAux][DEF_OBRIGAT] := .T.
		aRet[nAux][DEF_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "06"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .T.
		aRet[nAux][DEF_HELP] := {STR0273}	//"Fim do periodo de aloca��o"

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := GetSX3Cache( "TGY_FILIAL", cDescri )  //"Numero do Contrato"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := GetSX3Cache( "TGY_FILIAL", cDescri ) //"Numero do Contrato"
		aRet[nAux][DEF_IDENTIFICADOR] := "LGY_FILIAL"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := Len(cFilAnt)
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "07"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_LOOKUP] := "SM0"
		aRet[nAux][DEF_CAN_CHANGE] := .T.
		aRet[nAux][DEF_CODEBLOCK_INIT] := {|| cFilAnt}
		aRet[nAux][DEF_HELP] := {STR0498} //"Filial utilizada para alocar o atendente"

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0499 //"Descri��o da Filial"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0499 //"Descri��o da Filial"
		aRet[nAux][DEF_IDENTIFICADOR] := "LGY_DSCFIL"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := LEN(FWFilialName())
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
		aRet[nAux][DEF_RECEBE_VAL] := .F.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "08"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CODEBLOCK_INIT] := {|| Alltrim(FWFilialName(,cFilAnt))}
		aRet[nAux][DEF_CAN_CHANGE] := .F.

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := GetSX3Cache( "CN9_NUMERO", cDescri )  //"Numero do Contrato"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := GetSX3Cache( "CN9_NUMERO", cDescri ) //"Numero do Contrato"
		aRet[nAux][DEF_IDENTIFICADOR] := "LGY_CONTRT"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("CN9_NUMERO")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.T.}
		aRet[nAux][DEF_OBRIGAT] := .T.
		aRet[nAux][DEF_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "09"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_LOOKUP] := "T19DCY" //At190dCons("CONTRATO_LGY")
		aRet[nAux][DEF_CAN_CHANGE] := .T.
		aRet[nAux][DEF_HELP] := {STR0060}	//"N�mero do contrato."

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0031	//"Local de Atendimento"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0031	//"Local de Atendimento"
		aRet[nAux][DEF_IDENTIFICADOR] := "LGY_CODTFL"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TFL_CODIGO")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .T. }
		aRet[nAux][DEF_OBRIGAT] := .T.
		aRet[nAux][DEF_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "10"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_LOOKUP] := "T19CAY" //At190dCons("LOCAL_LGY")
		aRet[nAux][DEF_CAN_CHANGE] := .T.
		aRet[nAux][DEF_HELP] := {STR0094}	//"C�digo do Local de Atendimento."

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0063	//"Posto"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0063	//"Posto"
		aRet[nAux][DEF_IDENTIFICADOR] := "LGY_CODTFF"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TFF_COD")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .T. }
		aRet[nAux][DEF_OBRIGAT] := .T.
		aRet[nAux][DEF_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "11"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_LOOKUP] := "T19CFY" //At190dCons("POSTO_LGY")
		aRet[nAux][DEF_CAN_CHANGE] := .T.
		aRet[nAux][DEF_HELP] := {STR0064}	//"C�digo de recursos humanos."

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := GetSX3Cache( "TFF_ESCALA", cDescri )  //"C�digo da Escala"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := GetSX3Cache( "TFF_ESCALA", cDescri ) //"C�digo da Escala"
		aRet[nAux][DEF_IDENTIFICADOR] := "LGY_ESCALA"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TFF_ESCALA")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .T. }
		aRet[nAux][DEF_OBRIGAT] := .T.
		aRet[nAux][DEF_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "12"
		aRet[nAux][DEF_PICTURE] := "@!"
		If !lMV_MultFil
			aRet[nAux][DEF_LOOKUP] := "TDW"
		Else
			aRet[nAux][DEF_LOOKUP] := "T19ESY" //At190dCons("TDW_ALOCACOES")
		EndIf
		aRet[nAux][DEF_CAN_CHANGE] := .T.
		aRet[nAux][DEF_HELP] := {STR0065}	//"Preencher com C�digo da Escala."

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := GetSX3Cache( "TDW_DESC", cDescri )
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := GetSX3Cache( "TDW_DESC", cDescri )
		aRet[nAux][DEF_IDENTIFICADOR] := "LGY_DSCTDW"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TDW_DESC")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .F. }
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_RECEBE_VAL] := .F.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "13"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .F.
		aRet[nAux][DEF_HELP] := {STR0421}//"Descri��o da Escala"

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0069	//"Seq. Inicial"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0069	//"Seq. Inicial"
		aRet[nAux][DEF_IDENTIFICADOR] := "LGY_SEQ"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TGY_SEQ")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .T. }
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "14"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .T.
		aRet[nAux][DEF_LOOKUP] := "T19LSQ" //At190dCons("LGY_SEQ")
		aRet[nAux][DEF_HELP] := {STR0070}	//"Preencher com Sequencia do Turno."

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := GetSX3Cache( "TGY_TIPALO", cDescri )  //"Tipo Movimenta��o"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := GetSX3Cache( "TGY_TIPALO", cDescri ) //"Tipo Movimenta��o"
		aRet[nAux][DEF_IDENTIFICADOR] := "LGY_TIPTCU"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TGY_TIPALO")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .T. }
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "15"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CODEBLOCK_INIT] := {|| "001"}
		If !lMV_MultFil
			aRet[nAux][DEF_LOOKUP] := "TCUALC"
		Else
			aRet[nAux][DEF_LOOKUP] := "T19TPY" //At190dCons("TCU_ALOCACOES")
		EndIf
		aRet[nAux][DEF_CAN_CHANGE] := .T.
		aRet[nAux][DEF_HELP] := {STR0066}	//"Informe o tipo de movimenta��o."

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := GetSX3Cache( "TGY_GRUPO", cDescri )  //"Grupo"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := GetSX3Cache( "TGY_GRUPO", cDescri ) //"Grupo"
		aRet[nAux][DEF_IDENTIFICADOR] := "LGY_GRUPO"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "N"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "N"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TGY_GRUPO")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .T. }
		aRet[nAux][DEF_OBRIGAT] := .T.
		aRet[nAux][DEF_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "16"
		aRet[nAux][DEF_PICTURE] := "@E 999"
		aRet[nAux][DEF_CAN_CHANGE] := .T.
		aRet[nAux][DEF_LOOKUP] := "T19LGR" //At190dCons("LGY_GRUPO")
		aRet[nAux][DEF_HELP] := {STR0071}	//"Preencher com grupo do atendente."

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0073	//"RECNO"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0073	//"RECNO"
		aRet[nAux][DEF_IDENTIFICADOR] := "LGY_RECLGY"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "N"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "N"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 16
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "17"
		aRet[nAux][DEF_CAN_CHANGE] := .T.

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0422 //"Configura��o de Aloca��o"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0422 //"Configura��o de Aloca��o"
		aRet[nAux][DEF_IDENTIFICADOR] := "LGY_CONFAL"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TDX_COD")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .T. }
		aRet[nAux][DEF_OBRIGAT] := .T.
		aRet[nAux][DEF_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "18"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_LOOKUP] := "T19FAL" //At190dCons("LGY_CONFAL")
		aRet[nAux][DEF_CAN_CHANGE] := .T.
		aRet[nAux][DEF_HELP] := {STR0423} //"Configura��o de Tabela de Hor�rio e Sequ�ncia para efetivos ou do tipo de Cobertura"

		cOrdem := "18"

		For nC := 1 to 4
			cOrdem := Soma1(cOrdem)
			cCampoE := "LGY_ENTRA" + Str(nC,1)
			AADD(aRet, ARRAY(QUANTIDADE_DEFS))
			nAux := LEN(aRet)
			aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0074 + Str(nC,1)	//"Hora Ini "
			aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0075 + Str(nC,1)	//"Hor�rio de Entrada "
			aRet[nAux][DEF_IDENTIFICADOR] := cCampoE
			aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
			aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
			aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 5
			aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
			aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.T.}
			aRet[nAux][DEF_OBRIGAT] := .F.
			aRet[nAux][DEF_RECEBE_VAL] := .T.
			aRet[nAux][DEF_VIRTUAL] := .T.
			aRet[nAux][DEF_ORDEM] := cOrdem
			aRet[nAux][DEF_PICTURE] := "99:99"
			aRet[nAux][DEF_CAN_CHANGE] := .T.
			aRet[nAux][DEF_HELP] := {"Hor�rio de entrada"}

			cCampoS := "LGY_SAIDA" + Str(nC,1)
			cOrdem := Soma1(cOrdem)
			AADD(aRet, ARRAY(QUANTIDADE_DEFS))
			nAux := LEN(aRet)
			aRet[nAux][DEF_TITULO_DO_CAMPO] :=  STR0076 + Str(nC,1)	//"Hora Fim "
			aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0077 + Str(nC,1)	//"Hor�rio de Sa�da "
			aRet[nAux][DEF_IDENTIFICADOR] := cCampoS
			aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
			aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
			aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 5
			aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
			aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.T.}
			aRet[nAux][DEF_OBRIGAT] := .F.
			aRet[nAux][DEF_RECEBE_VAL] := .T.
			aRet[nAux][DEF_VIRTUAL] := .T.
			aRet[nAux][DEF_ORDEM] := cOrdem
			aRet[nAux][DEF_PICTURE] := "99:99"
			aRet[nAux][DEF_CAN_CHANGE] := .T.
			aRet[nAux][DEF_HELP] := {"Hor�rio de sa�da"}
		Next nC

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0500 //"Detalhes"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0500 //"Detalhes"
		aRet[nAux][DEF_IDENTIFICADOR] := "LGY_DETALH"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 185
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .F. }
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_RECEBE_VAL] := .F.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "27"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .F.
		aRet[nAux][DEF_HELP] := {STR0501} //"Detalhes da aloca��o"

	ElseIf cTable == "LAC"
		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0078		//"Agenda"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0078		//"Agenda"
		aRet[nAux][DEF_IDENTIFICADOR] := "LAC_SITABB"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "BT"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "BT"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 1
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_VALID] := {||At330AGtLA()}
		aRet[nAux][DEF_CODEBLOCK_INIT] := {|| "BR_VERDE"}
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "01"
		aRet[nAux][DEF_PICTURE] := ""
		aRet[nAux][DEF_CAN_CHANGE] := .T.

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0079	//"Status"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0079	//"Status"
		aRet[nAux][DEF_IDENTIFICADOR] := "LAC_SITALO"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "BT"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "BT"
		aRet[nAux][DEF_CODEBLOCK_INIT] := {|| "BR_VERDE"}
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 1
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_VALID] := {||At330AGtLS()}
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "02"
		aRet[nAux][DEF_PICTURE] := ""
		aRet[nAux][DEF_CAN_CHANGE] := .T.

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := GetSX3Cache( "TGY_GRUPO", cDescri )  //"Grupo"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := GetSX3Cache( "TGY_GRUPO", cDescri ) //"Grupo"
		aRet[nAux][DEF_IDENTIFICADOR] := "LAC_GRUPO"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "N"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "N"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TGY_GRUPO")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "03"
		aRet[nAux][DEF_PICTURE] := "@E 999"
		aRet[nAux][DEF_CAN_CHANGE] := .T.
		aRet[nAux][DEF_HELP] := {STR0071}	//"Preencher com grupo do atendente."

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := GetSX3Cache( "AA1_CODTEC", cDescri )  //"C�digo do Atendente"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := GetSX3Cache( "AA1_CODTEC", cDescri )  //"C�digo do Atendente"
		aRet[nAux][DEF_IDENTIFICADOR] := "LAC_CODTEC"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("AA1_CODTEC")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_RECEBE_VAL] := .F.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "04"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .F.
		aRet[nAux][DEF_HELP] := {STR0095}	//"C�digo do Atendente."

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := GetSX3Cache( "AA1_NOMTEC", cDescri )  //"Nome do Atendente"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := GetSX3Cache( "AA1_NOMTEC", cDescri )  //"Nome do Atendente"
		aRet[nAux][DEF_IDENTIFICADOR] := "LAC_NOMTEC"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("AA1_NOMTEC")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
		aRet[nAux][DEF_RECEBE_VAL] := .F.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "05"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .F.
		aRet[nAux][DEF_HELP] := {STR0096}	//"Nome do Atendente."

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0080	//"Dt. Refer�ncia"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0080	//"Dt. Refer�ncia"
		aRet[nAux][DEF_IDENTIFICADOR] := "LAC_DATREF"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "D"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "D"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 8
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "06"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .T.
		aRet[nAux][DEF_HELP] := {STR0081}	//"Data da aloca��o."

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0082	//"Data"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0082	//"Data"
		aRet[nAux][DEF_IDENTIFICADOR] := "LAC_DATA"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "D"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "D"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 8
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "07"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .T.
		aRet[nAux][DEF_HELP] := {STR0081}	//"Data da aloca��o."

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0027	//"Dia da Semana"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0027	//"Dia da Semana"
		aRet[nAux][DEF_IDENTIFICADOR] := "LAC_SEMANA"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 15
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_RECEBE_VAL] := .F.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "08"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .F.
		aRet[nAux][DEF_HELP] := {STR0083}	//"Dia da semana."

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0084	//"Hora de Entrada"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0084	//"Hora de Entrada"
		aRet[nAux][DEF_IDENTIFICADOR] := "LAC_ENTRADA"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 5
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_RECEBE_VAL] := .F.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "09"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .F.
		aRet[nAux][DEF_HELP] := {STR0084}	//"Hora de Entrada"

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0085	//"Hora de Sa�da"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0085	//"Hora de Sa�da"
		aRet[nAux][DEF_IDENTIFICADOR] := "LAC_SAIDA"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 5
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_RECEBE_VAL] := .F.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "10"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .F.
		aRet[nAux][DEF_HELP] := {STR0085}	//"Hora de Sa�da"

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0086	//"Sequencia"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0086	//"Sequencia"
		aRet[nAux][DEF_IDENTIFICADOR] := "LAC_SEQ"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 2
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "11"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .T.
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
		aRet[nAux][DEF_HELP] := {STR0070}	//"Preencher com Sequencia do Turno."

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0087	//"Tipo"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0087	//"Tipo"
		aRet[nAux][DEF_IDENTIFICADOR] := "LAC_TIPO"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 1
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_LISTA_VAL] := { "S="+STR0193, "C="+STR0194, "D="+STR0195, "E="+STR0490,"I="+STR0196,"N="+STR0196} //"S=Trabalhado;C=Compensado;D=D.S.R.;E=Hora Extra;I=Intervalo;N=Nao Trabalhado"
		aRet[nAux][DEF_COMBO_VAL] := { "S="+STR0193, "C="+STR0194, "D="+STR0195, "E="+STR0490,"I="+STR0196,"N="+STR0196}  //"S=Trabalhado;C=Compensado;D=D.S.R.;E=Hora Extra;I=Intervalo;N=Nao Trabalhado"
		aRet[nAux][DEF_RECEBE_VAL] := .F.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "12"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .F.
		aRet[nAux][DEF_HELP] := {STR0088}	//"Tipo de dia: Trabalhado, n�o trabalhado, folga ou DSR."

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := "KeyTGY"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := "KeyTGY"
		aRet[nAux][DEF_IDENTIFICADOR] := "LAC_KEYTGY"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TGY_ESCALA")[1] + TamSX3("TGY_CODTDX")[1] + TamSX3("TGY_CODTFF")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "13"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .T.

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0413 //"ItemTGY"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0413 //"ItemTGY"
		aRet[nAux][DEF_IDENTIFICADOR] := "LAC_ITTGY"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TGY_ITEM")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "14"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .T.

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := "EXSABB"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := "EXSABB"
		aRet[nAux][DEF_IDENTIFICADOR] := "LAC_EXSABB"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 1
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "15"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .T.

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0089	//"Turno"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0089	//"Turno"
		aRet[nAux][DEF_IDENTIFICADOR] := "LAC_TURNO"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TFF_TURNO")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "16"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .T.
		aRet[nAux][DEF_HELP] := {STR0090}	//"Preencher com o C�digo do Turno."

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0414 //"Item"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0414 //"Item"
		aRet[nAux][DEF_IDENTIFICADOR] := "LAC_ITEM"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "N"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "N"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 6
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "17"
		aRet[nAux][DEF_CAN_CHANGE] := .T.

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := "Desc. Conflito"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := "Desc. Conflito"
		aRet[nAux][DEF_IDENTIFICADOR] := "LAC_DSCONF"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 35
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_RECEBE_VAL] := .F.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "18"
		aRet[nAux][DEF_CAN_CHANGE] := .F.

	EndIf

Return aRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} InitDados

@description Bloco de c�digo executado no activate
@param oModel, obj, modelo em ativa��o

@author	boiani
@since	29/05/2019
/*/
//------------------------------------------------------------------------------
Static Function InitDados(oModel)
	Local oMdlABB := oModel:GetModel('ABBDETAIL')
	Local oMdlALC := oModel:GetModel('ALCDETAIL')
	Local oMdlLAC := oModel:GetModel('LACDETAIL')
	oMdlALC:SetNoInsertLine(.T.)
	oMdlALC:SetNoDeleteLine(.T.)
	oMdlABB:SetNoInsertLine(.T.)
	oMdlABB:SetNoDeleteLine(.T.)
	oMdlLAC:SetNoInsertLine(.T.)
	oMdlLAC:SetNoDeleteLine(.T.)
Return
//------------------------------------------------------------------------------
/*/{Protheus.doc} at190dSlct

@description Cria o bot�o "Marcar Todos"
@param oPanel, obj, dialog em que o bot�o ser� criado

@author	boiani
@since	29/05/2019
/*/
//------------------------------------------------------------------------------
Static Function at190dSlct(oPanel)

	TButton():New( (oPanel:nHeight / 2) - 13, 5, STR0038 , oPanel, { || At190dMrk(1) },43,12,,,.F.,.T.,.F.,,.F.,,,.F. )	//"Marcar Todos"

Return ( Nil )

//------------------------------------------------------------------------------
/*/{Protheus.doc} at190dEHr

@description Cria o bot�o "Editor de Horarios"
@param oPanel, obj, dialog em que o bot�o ser� criado

@author	fabiana.silva
@since	24/07/2019
/*/
//------------------------------------------------------------------------------
Static Function at190dEHr(oPanel)
	Local lMonitor := IsBlind() .OR. ((GetScreenRes()[2] <= 800) .AND. (GetScreenRes()[1] <= 1400)) //786 x 1366
	Local aTamanho := {}
	Local oModel := FwModelActive()

	If lMonitor
		AADD(aTamanho, 45.00)
	Else
		AADD(aTamanho, 44.00)
	EndIf

	TButton():New( (oPanel:nHeight / 2) - 13, (oPanel:nWidth/2) - aTamanho[1], STR0039 ,;
		oPanel, { || At190MEHr() },43,12,,,.F.,.T.,.F.,,.F.,;
		{|| !Empty(oModel:GetModel("TGYMASTER"):GetValue("TGY_ESCALA"))},,.F. )	//"Edit Hor�rios"

Return ( Nil )

//------------------------------------------------------------------------------
/*/{Protheus.doc} at190dMntR

@description Cria o bot�o "Manuten��es"
@param oPanel, obj, dialog em que o bot�o ser� criado

@author	boiani
@since	29/05/2019
/*/
//------------------------------------------------------------------------------
Static Function at190dMntR(oPanel)
	Local lMonitor := IsBlind() .OR. ((GetScreenRes()[2] <= 800) .AND. (GetScreenRes()[1] <= 1400)) //786 x 1366
	Local aTamanho := {}

	If lMonitor
		AADD(aTamanho, 00.50)
	Else
		AADD(aTamanho, 04.00)
	EndIf

	TButton():New( (oPanel:nHeight / 2) - 13, aTamanho[1], STR0040 , oPanel, { || at190d550("ABB") },53,12,,,.F.,.T.,.F.,,.F.,,,.F. )	//"Manut. Relacionadas"

Return ( Nil )
//------------------------------------------------------------------------------
/*/{Protheus.doc} at190dExAg

@description Cria o bot�o "Excluir Agendas"
@param oPanel, obj, dialog em que o bot�o ser� criado

@author	boiani
@since	29/05/2019
/*/
//------------------------------------------------------------------------------
Static Function at190dExAg(oPanel)
	Local lMonitor := IsBlind() .OR. ((GetScreenRes()[2] <= 800) .AND. (GetScreenRes()[1] <= 1400)) //786 x 1366
	Local aTamanho := {}

	If lMonitor
		AADD(aTamanho, 00.50)
	Else
		AADD(aTamanho, 00.00)
	EndIf

	TButton():New( (oPanel:nHeight / 2) - 13, aTamanho[1], STR0318, oPanel, { || IIF(At680Perm(NIL, __cUserId, "041", .T.), At190DDlt(), Help(,1,"at190dELoc",,STR0473, 1)) },53,12,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Excluir agendas"##"Usu�rio sem permiss�o de excluir agendas"

Return ( Nil )
//------------------------------------------------------------------------------
/*/{Protheus.doc} at190dExpA

@description Cria o bot�o "Exportar Dados"
@param oPanel, obj, dialog em que o bot�o ser� criado

@author	boiani
@since	29/05/2019
/*/
//------------------------------------------------------------------------------
Static Function at190dExpA(oPanel, cAba)
	Local lMonitor := IsBlind() .OR. ((GetScreenRes()[2] <= 800) .AND. (GetScreenRes()[1] <= 1400)) //786 x 1366
	Local aTamanho := {}

	If lMonitor
		AADD(aTamanho, 52.00)
	Else
		AADD(aTamanho, 44.00)
	EndIf

	TButton():New( (oPanel:nHeight / 2) - 13, (oPanel:nWidth/2) - aTamanho[1], STR0041 , oPanel, { || At190DExp(cAba)},43,12,,,.F.,.T.,.F.,,.F.,,,.F. )	//"Exportar Dados"

Return ( Nil )
//------------------------------------------------------------------------------
/*/{Protheus.doc} at190dGvMt

@description Cria o bot�o "Salvar"
@param oPanel, obj, dialog em que o bot�o ser� criado

@author	boiani
@since	05/07/2019
/*/
//------------------------------------------------------------------------------
Static Function at190dGvMt(oPanel)

	Local oButton	:= nil
	Local cSCSSBtn	:= ColorButton()
	Local aTamanho	:= {}

	If IsBlind() .OR. ((GetScreenRes()[2] <= 800) .AND. (GetScreenRes()[1] <= 1400))
		AADD(aTamanho, 20.00)
	Else
		AADD(aTamanho, 12.00)
	EndIf

// Ancoramos os objetos no oPanel passado
	@ (oPanel:nHeight / 2) - aTamanho[1], 05 Button oButton Prompt STR0042 Of oPanel Size 46,11 Pixel //"Salvar Manut."

// Define CSS
	oButton:SetCss( cSCSSBtn )

// Atribui��o de a��o ao acionamento do bot�o
	oButton:bAction	:= { || AT190dInMn() }

Return ( Nil )

//------------------------------------------------------------------------------
/*/{Protheus.doc} at190dUConf

@description Cria o bot�o "Carregar Ultima Aloca��o"
@param oPanel, obj, dialog em que o bot�o ser� criado

@author	boiani
@since	29/05/2019
/*/
//------------------------------------------------------------------------------
Static Function at190dUConf(oPanel)

	TButton():New( (oPanel:nHeight / 2) - 12, 5, STR0043 , oPanel, { || BuscUltAlc() },50,11,,,.F.,.T.,.F.,,.F.,,,.F. )	//"Buscar �ltima Aloc."

Return ( Nil )
//------------------------------------------------------------------------------
/*/{Protheus.doc} at190dPConf

@description Cria o bot�o "Projetar Aloc."
@param oPanel, obj, dialog em que o bot�o ser� criado

@author	boiani
@since	29/05/2019
/*/
//------------------------------------------------------------------------------
Function at190dPConf(oPanel)
	Local lMonitor	:= IsBlind() .OR. ((GetScreenRes()[2] <= 800) .AND. (GetScreenRes()[1] <= 1400)) //786 x 1366
	Local aTamanho	:= {}

	If lMonitor
		AADD(aTamanho, 02.00)
	Else
		AADD(aTamanho, 00.50)
	EndIf

	TButton():New( (oPanel:nHeight / 2) - 12, aTamanho[1], STR0044 , oPanel, { || ProjAloc() },50,11,,,.F.,.T.,.F.,,.F.,,,.F. )	//"Projetar Aloc."

Return ( Nil )
//------------------------------------------------------------------------------
/*/{Protheus.doc} at190dGrava

@description Cria o bot�o "Gravar Aloc."
@param oPanel, obj, dialog em que o bot�o ser� criado

@author	boiani
@since	29/05/2019
/*/
//------------------------------------------------------------------------------
Static Function at190dGrava(oPanel)
	Local oButton	:= nil
	Local cSCSSBtn	:= ColorButton()

// Ancoramos os objetos no oPanel passado
	@ (oPanel:nHeight / 2) - 12, 01 Button oButton Prompt STR0045 Of oPanel Size 50,11 Pixel	//"Gravar Aloc."

// Define CSS
	oButton:SetCss( cSCSSBtn )

// Atribui��o de a��o ao acionamento do bot�o
	oButton:bAction	:= { || GravaAloc() }

Return ( Nil )
//------------------------------------------------------------------------------
/*/{Protheus.doc} at190dBscA

@description Cria o bot�o "Buscar"
@param oPanel, obj, dialog em que o bot�o ser� criado

@author	boiani
@since	29/05/2019
/*/
//------------------------------------------------------------------------------
Static Function at190dBscA(oPanel)

	TButton():New( (oPanel:nHeight / 2) - 12, 2, STR0046 , oPanel, { || FwMsgRun(Nil,{|| AT190DLdLo()}, Nil, STR0047)},50,11,,,.F.,.T.,.F.,,.F.,,,.F. )	//"Buscar (F10)" ## "Buscando agendas..."

Return ( Nil )
//------------------------------------------------------------------------------
/*/{Protheus.doc} at190dMLoc

@description Cria o bot�o "Marcar Todos"
@param oPanel, obj, dialog em que o bot�o ser� criado

@author	boiani
@since	21/02/2020
/*/
//------------------------------------------------------------------------------
Static Function at190dMLoc(oPanel)

	TButton():New( (oPanel:nHeight / 2) - 12, 2, STR0038 , oPanel, { || At190dMrk(2) },50,11,,,.F.,.T.,.F.,,.F.,,,.F. )	//"Marcar Todos"

Return ( Nil )
//------------------------------------------------------------------------------
/*/{Protheus.doc} at190dAddA

@description Cria o bot�o "Buscar"
@param oPanel, obj, dialog em que o bot�o ser� criado

@author	boiani
@since	29/05/2019
/*/
//------------------------------------------------------------------------------
Static Function at190dAddA(oPanel)

	TButton():New( (oPanel:nHeight / 2) - 12, 2, STR0519 , oPanel, { || At190dLAGY()},55,11,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Buscar Atendentes"

Return ( Nil )
//------------------------------------------------------------------------------
/*/{Protheus.doc} at190dClry

@description Cria o bot�o "Limpar Atendentes"
@param oPanel, obj, dialog em que o bot�o ser� criado

@author	boiani
@since	29/05/2019
/*/
//------------------------------------------------------------------------------
Static Function at190dClry(oPanel)
	Local lMonitor := IsBlind() .OR. ((GetScreenRes()[2] <= 800) .AND. (GetScreenRes()[1] <= 1400)) //786 x 1366
	Local aTamanho := {}

	If lMonitor
		AADD(aTamanho, 00.50)
	Else
		AADD(aTamanho, 01.00)
	EndIf

	TButton():New( (oPanel:nHeight / 2) - 13, aTamanho[1], STR0424, oPanel, { || At190dApgY()},50,12,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Limpar Atendentes"

Return ( Nil )

//------------------------------------------------------------------------------
/*/{Protheus.doc} 

@description Cria o bot�o os resultados da Aloca��es em lote "Exportar CSV"
@param oPanel, obj, dialog em que o bot�o ser� criado

@author	Diego Bezerra
@since	22/05/2020
/*/
//------------------------------------------------------------------------------
Static Function at190dExpC(oPanel)
	Local lMonitor := IsBlind() .OR. ((GetScreenRes()[2] <= 800) .AND. (GetScreenRes()[1] <= 1400)) //786 x 1366
	Local aTamanho := {}

	If lMonitor
		AADD(aTamanho, 00.50)
	Else
		AADD(aTamanho, 01.00)
	EndIf

	TButton():New( (oPanel:nHeight / 2) - 13, aTamanho[1], STR0041, oPanel, { || at190dExp(STR0399)},50,12,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Exportar CSV"

Return ( Nil )

//------------------------------------------------------------------------------
/*/{Protheus.doc} at190dYAgnd

@description Cria o bot�o "Alocar"
@param oPanel, obj, dialog em que o bot�o ser� criado

@author	boiani
@since	29/05/2019
/*/
//------------------------------------------------------------------------------
Static Function at190dYAgnd(oPanel)

	TButton():New( (oPanel:nHeight / 2) - 12, 2, STR0425, oPanel, { || At190dYAgen()},50,11,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Projetar"

Return ( Nil )
//------------------------------------------------------------------------------
/*/{Protheus.doc} at190dYGrv

@description Cria o bot�o "Gravar"
@param oPanel, obj, dialog em que o bot�o ser� criado

@author	boiani
@since	03/02/2020
/*/
//------------------------------------------------------------------------------
Static Function at190dYGrv(oPanel)
	Local oButton	:= nil
	Local cSCSSBtn	:= ColorButton()

	@ (oPanel:nHeight / 2) - 12, 01 Button oButton Prompt STR0426 Of oPanel Size 50,11 Pixel //"Gravar"

	oButton:SetCss( cSCSSBtn )
	oButton:bAction	:= { || At190dYCmt() }

Return ( Nil )
//------------------------------------------------------------------------------
/*/{Protheus.doc} at190dMtPr

@description Cria o bot�o "Manuten��es"
@param oPanel, obj, dialog em que o bot�o ser� criado

@author	boiani
@since	29/05/2019
/*/
//------------------------------------------------------------------------------
Static Function at190dMtPr(oPanel)

	TButton():New( (oPanel:nHeight / 2) - 12, 2, STR0006 , oPanel, { || at190d550("LOC")},50,11,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Manuten��es"

Return ( Nil )
//------------------------------------------------------------------------------
/*/{Protheus.doc} at190dLOCd

@description Cria o bot�o "Excluir"
@param oPanel, obj, dialog em que o bot�o ser� criado

@author	boiani
@since	29/05/2019
/*/
//------------------------------------------------------------------------------
Static Function at190dLOCd(oPanel)

	TButton():New( (oPanel:nHeight / 2) - 12, 2, STR0318 , oPanel, { || IIF(At680Perm(NIL, __cUserId, "041", .T.), at190dELoc(), Help(,1,"at190dELoc",,STR0473, 1))},50,11,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Excluir Agendas"##"Usu�rio sem permiss�o de excluir agendas"

Return ( Nil )
//------------------------------------------------------------------------------
/*/{Protheus.doc} at190dBscB

@description Cria o bot�o "Buscar"
@param oPanel, obj, dialog em que o bot�o ser� criado

@author	boiani
@since	29/05/2019
/*/
//------------------------------------------------------------------------------
Static Function at190dBscB(oPanel)

	TButton():New( (oPanel:nHeight / 2) - 12, 2, STR0048 , oPanel, { || FwMsgRun(Nil,{|| AT190DHJLo()}, Nil, STR0047)},50,11,,,.F.,.T.,.F.,,.F.,,,.F. )	//"Buscar (F11)" # "Buscando agendas..."

Return ( Nil )
//------------------------------------------------------------------------------
/*/{Protheus.doc} At190dMrk

@description Marca/Desmarca todos os

@author	boiani
@since	29/05/2019
/*/
//------------------------------------------------------------------------------
Function At190dMrk(nOpc)
	Local oModel := FwModelActive()
	Local oView  := FwViewActive()
	Local oMdlGrd
	Local nLine
	Local cField
	Local nX
	Default nOpc := 1
	If nOpc == 1
		oMdlGrd := oModel:GetModel('ABBDETAIL')
		cField := "ABB_MARK"
	ElseIf nOpc == 2
		oMdlGrd := oModel:GetModel('LOCDETAIL')
		cField := "LOC_MARK"
	EndIf

	nLine := oMdlGrd:GetLine()

	If !(oMdlGrd:isEmpty())
		For nX := 1 To oMdlGrd:Length()
			oMdlGrd:GoLine(nX)
			oMdlGrd:SetValue(cField, !(oMdlGrd:GetValue(cField)))
		Next nX

		oMdlGrd:GoLine(nLine)
		If !IsBlind()
			oView:Refresh()
		EndIf
	EndIf

Return (.T.)
//------------------------------------------------------------------------------
/*/{Protheus.doc} At190DLoad

@description Faz a carga dos dados no grid "ABBDETAIL"

@author	boiani
@since	29/05/2019
/*/
//------------------------------------------------------------------------------
Function At190DLoad()
	Local oModel    := FwModelActive()
	Local oView		:= FwViewActive()
	Local oMdlAA1 := oModel:GetModel('AA1MASTER')
	Local oMdlDTS := oModel:GetModel('DTSMASTER')
	Local oMdlABB := oModel:GetModel('ABBDETAIL')
	Local oMdlMAN := oModel:GetModel('MANMASTER')
	Local cAtendente := oMdlAA1:GetValue("AA1_CODTEC")
	Local dDataDe := oMdlDTS:GetValue("DTS_DTINI")
	Local dDataAte := oMdlDTS:GetValue("DTS_DTFIM")
	Local cSql := ""
	Local cAliasQry
	Local nLinha := 1
	Local cTipoMV
	Local cTCU_DESC := PadR(STR0368, TamSx3("TCU_DESC")[1]) //"Outros Tipos"
	Local lPeAt190DL := ExistBlock("At190DLd")
	Local lMV_MultFil := TecMultFil() //Indica se a Mesa considera multiplas filiais
	Local aLinha	:= {}
	Local nC		:= 0

	oMdlABB:SetNoInsertLine(.F.)
	oMdlABB:SetNoDeleteLine(.F.)

	oMdlABB:ClearData()
	oMdlABB:InitLine()

	aMarks := {}
	aDels := {}
	cFiltro550 := ""
	CleanMAN(oMdlMAN,,.F.)

	If !EMPTY(cAtendente) .AND. !EMPTY(dDataDe) .AND. !EMPTY(dDataAte)
		cSql += " SELECT ABB.ABB_HRINI, ABB.ABB_HRFIM, TDV.TDV_DTREF, SB1.B1_DESC, ABS.ABS_DESCRI, ABB.ABB_TIPOMV, "
		cSql += " ABB.ABB_ATIVO, ABB.ABB_CODIGO, "
		cSql += " CASE WHEN TCU.TCU_DESC IS NOT NULL THEN TCU.TCU_DESC ELSE '" + cTCU_DESC+ "' END TCU_DESC "
		cSql += ", ABB.ABB_DTINI , ABB.ABB_DTFIM, ABB.ABB_FILIAL, ABB.R_E_C_N_O_ REC, "
		cSql += " ABB.ABB_ATENDE, ABB.ABB_CHEGOU, ABB.ABB_IDCFAL, ABQ.ABQ_CODTFF, ABB.ABB_OBSERV "
		cSql += " FROM " + RetSqlName( "ABB" ) + " ABB INNER JOIN " + RetSqlName( "TDV" ) + " TDV ON "
		cSql += " TDV.D_E_L_E_T_ = ' ' AND "
		If !lMV_MultFil
			cSql += " TDV.TDV_FILIAL = '" + xFilial("TDV") + "' AND "
		Else
			cSql += " " + FWJoinFilial("ABB" , "TDV" , "ABB", "TDV", .T.) + " AND "
		EndIf
		cSql += " TDV.TDV_CODABB = ABB.ABB_CODIGO "
		cSql += " INNER JOIN " + RetSqlName( "ABQ" ) + " ABQ ON ABB.ABB_IDCFAL = ABQ.ABQ_CONTRT || ABQ.ABQ_ITEM || ABQ.ABQ_ORIGEM AND "
		If !lMV_MultFil
			cSql += " ABQ.ABQ_FILIAL = '" + xFilial("ABQ") + "' AND "
		Else
			cSql += " " + FWJoinFilial("ABB" , "ABQ" , "ABB", "ABQ", .T.) + " AND "
		EndIf
		cSql += " ABQ.D_E_L_E_T_ = ' ' "
		cSql += " INNER JOIN " + RetSqlName( "SB1" ) + " SB1 ON SB1.B1_COD = ABQ.ABQ_PRODUT AND "
		If !lMV_MultFil
			cSql += " SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND "
		Else
			cSql += " " + FWJoinFilial("ABQ" , "SB1" , "ABQ", "SB1", .T.) + " AND "
			cSql += " " + FWJoinFilial("ABB" , "SB1" , "ABB", "SB1", .T.) + " AND "
		EndIf
		cSql += " SB1.D_E_L_E_T_ = ' ' "
		cSql += " INNER JOIN " + RetSqlName( "ABS" ) + " ABS ON ABB.ABB_LOCAL = ABS.ABS_LOCAL AND "
		If !lMV_MultFil
			cSql += " ABS.ABS_FILIAL = '" + xFilial("ABS") + "' "
		Else
			cSql += " " + FWJoinFilial("ABB" , "ABS" , "ABB", "ABS", .T.) + " "
		EndIf
		cSql += " AND ABS.D_E_L_E_T_ = ' ' " "
		cSql += " LEFT JOIN " + RetSqlName( "TCU" ) + " TCU ON TCU.TCU_COD = ABB.ABB_TIPOMV AND "
		If !lMV_MultFil
			cSql += " TCU.TCU_FILIAL = '" + xFilial("TCU") + "' "
		Else
			cSql += " " + FWJoinFilial("ABB" , "TCU" , "ABB", "TCU", .T.) + " "
		EndIF
		cSql += " AND TCU.D_E_L_E_T_ = ' ' "
		cSql += " WHERE ABB.D_E_L_E_T_ = ' ' AND "
		If !lMV_MultFil
			cSql += " ABB.ABB_FILIAL = '" + xFilial("ABB") + "' AND "
		EndIf
		cSql += " TDV.TDV_DTREF >= '" + DTOS(dDataDe) + "' AND TDV.TDV_DTREF <= '" + DTOS(dDataAte) + "' AND "
		cSql += " ABB.ABB_CODTEC = '"+cAtendente+"' ORDER BY TDV.TDV_DTREF, ABB.ABB_DTINI , ABB.ABB_HRINI"
		cSql := ChangeQuery(cSql)
		cAliasQry := GetNextAlias()
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSql),cAliasQry, .F., .T.)
		While !(cAliasQry)->(EOF())
			If !oMdlABB:IsEmpty()
				nLinha := oMdlABB:AddLine()
			EndIf
			oMdlABB:GoLine(nLinha)
			oMdlABB:LoadValue("ABB_DTREF", STOD((cAliasQry)->(TDV_DTREF)))
			oMdlABB:LoadValue("ABB_DOW", TECCdow(DOW(STOD((cAliasQry)->(TDV_DTREF)))))
			oMdlABB:LoadValue("ABB_HRINI", (cAliasQry)->(ABB_HRINI))
			oMdlABB:LoadValue("ABB_HRFIM", (cAliasQry)->(ABB_HRFIM))
			oMdlABB:LoadValue("ABB_ABSDSC", (cAliasQry)->(ABS_DESCRI))
			oMdlABB:LoadValue("ABB_B1DESC", (cAliasQry)->(B1_DESC))
			oMdlABB:LoadValue("ABB_TIPOMV", (cAliasQry)->(ABB_TIPOMV))
			oMdlABB:LoadValue("ABB_ATIVO", (cAliasQry)->(ABB_ATIVO))
			oMdlABB:LoadValue("ABB_CODIGO", (cAliasQry)->(ABB_CODIGO))
			oMdlABB:LoadValue("ABB_TCUDSC", (cAliasQry)->(TCU_DESC))
			oMdlABB:LoadValue("ABB_DTINI", STOD((cAliasQry)->(ABB_DTINI)))
			oMdlABB:LoadValue("ABB_DTFIM", STOD((cAliasQry)->(ABB_DTFIM)))
			oMdlABB:LoadValue("ABB_ATENDE", (cAliasQry)->(ABB_ATENDE))
			oMdlABB:LoadValue("ABB_CHEGOU", (cAliasQry)->(ABB_CHEGOU))
			oMdlABB:LoadValue("ABB_IDCFAL", (cAliasQry)->(ABB_IDCFAL))
			oMdlABB:LoadValue("ABB_ABQTFF", (cAliasQry)->(ABQ_CODTFF))
			oMdlABB:LoadValue("ABB_OBSERV", (cAliasQry)->(ABB_OBSERV))
			oMdlABB:LoadValue("ABB_FILIAL", (cAliasQry)->(ABB_FILIAL))
			oMdlABB:LoadValue("ABB_RECABB", (cAliasQry)->(REC) )
			If lMV_MultFil
				oMdlABB:LoadValue("ABB_DSCFIL", (cAliasQry)->(ABB_FILIAL) + " - " + Alltrim(FWFilialName(,(cAliasQry)->(ABB_FILIAL))))
			EndIf
			cTipoMV := oMdlABB:GetValue('ABB_TIPOMV')

			If oMdlABB:GetValue("ABB_ATENDE") == '1' .AND. oMdlABB:GetValue("ABB_CHEGOU") == 'S'
				oMdlABB:LoadValue("ABB_LEGEND","BR_PRETO") // "Agenda atendida"
			ElseIf oMdlABB:GetValue('ABB_ATIVO') == '2' .OR. HasABR((cAliasQry)->(ABB_CODIGO),(cAliasQry)->(ABB_FILIAL))
				oMdlABB:LoadValue("ABB_LEGEND","BR_MARROM") //"Agenda com Manuten��o"
			ElseIf cTipoMV == '004'
				oMdlABB:LoadValue("ABB_LEGEND","BR_VERMELHO") //"Excedente"
			ElseIf cTipoMV == '002'
				oMdlABB:LoadValue("ABB_LEGEND","BR_AMARELO") //"Cobertura"
			ElseIf cTipoMV == '001'
				oMdlABB:LoadValue("ABB_LEGEND","BR_VERDE") //"Efetivo"
			ElseIf cTipoMV == '003'
				oMdlABB:LoadValue("ABB_LEGEND","BR_LARANJA") //"Apoio"
			ElseIf cTipoMV == '006'
				oMdlABB:LoadValue("ABB_LEGEND","BR_CINZA") //"Curso"
			ElseIf cTipoMV == '007'
				oMdlABB:LoadValue("ABB_LEGEND","BR_BRANCO") //"Cortesia"
			ElseIf cTipoMV == '005'
				oMdlABB:LoadValue("ABB_LEGEND","BR_AZUL") //"Treinamento"
			Else
				oMdlABB:LoadValue("ABB_LEGEND","BR_PINK") //"Outros Tipos"
			EndIf
			If lPeAt190DL
				For nC := 1 To Len(oMdlABB:aHeader)
					aAdd(aLinha,{oMdlABB:aHeader[nC][2], oMdlABB:GetValue(oMdlABB:aHeader[nC][2])} )
				Next nC
				ExecBlock("At190DLd", .F., .F., {@oModel, @oMdlABB, cAtendente, aClone(aLinha)})
				aLinha := {}
			EndIf
			(cAliasQry)->(dbSkip())
		End
		(cAliasQry)->(dbCloseArea())
		oMdlABB:GoLine(1)
	EndIf

	oMdlABB:SetNoInsertLine(.T.)
	oMdlABB:SetNoDeleteLine(.T.)

	If !IsBlind()
		oView:Refresh('DETAIL_ABB')
	EndIf
Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At19DAGtLA

@description Cria as informa��es referentes a legenda do grid da ABB.
Importante - Caso inclua mais itens na Legenda, informar tamb�m na fun��o At190LgLOC

@author	boiani
@since	29/05/2019
/*/
//------------------------------------------------------------------------------
Function At19DAGtLA(cCampo)

	Local oLegABB := FwLegend():New()
	Local oMdlFull	 := FwModelActive()
	Local oMdlABB 	 := oMdlFull:GetModel('ABBDETAIL')

	Default cCampo := ""

	oLegABB:Add( "oMdlABB:GetValue('ABB_ATIVO') == '2'"		, "BR_MARROM"	, STR0049 )							//"Agenda com Manuten��o"
	oLegABB:Add( "oMdlABB:GetValue('ABB_TIPOMV') == '004'"	, "BR_VERMELHO"	, STR0050 )							//"Excedente"
	oLegABB:Add( "oMdlABB:GetValue('ABB_TIPOMV') == '002'"	, "BR_AMARELO" 	, STR0051 )							//"Cobertura"
	oLegABB:Add( "oMdlABB:GetValue('ABB_TIPOMV') == '001'"	, "BR_VERDE"	, STR0052 )							//"Efetivo"
	oLegABB:Add( "oMdlABB:GetValue('ABB_TIPOMV') == '003'"	, "BR_LARANJA" 	, STR0053 )							//"Apoio"
	oLegABB:Add( "oMdlABB:GetValue('ABB_TIPOMV') == '006'"	, "BR_CINZA"	, STR0054 )							//"Curso"
	oLegABB:Add( "oMdlABB:GetValue('ABB_TIPOMV') == '007'"	, "BR_BRANCO"	, STR0055 )							//"Cortesia"
	oLegABB:Add( "oMdlABB:GetValue('ABB_TIPOMV') == '005'"	, "BR_AZUL"	 	, STR0056 )							//"Treinamento"
	If cCampo $ "ABB_LEGEND|LOC_LEGEND"
		oLegABB:Add( "oMdlABB:GetValue('ABB_ATENDE') == '1'"	, "BR_PRETO"	, STR0190 )						//"Agenda Atendida"
	EndIf
	oLegABB:Add( "!(oMdlABB:GetValue('ABB_TIPOMV') $ '001|002|003|004|005|006|007')", "BR_PINK"	  , STR0057 )	//"Outros Tipos"
	oLegABB:View()

	DelClassIntf()
Return(.T.)

//------------------------------------------------------------------------------
/*/{Protheus.doc} At19DLegHj

@description Cria as informa��es referentes a legenda do grid da HOJ.

@author	boiani
@since	29/05/2019
/*/
//------------------------------------------------------------------------------
Function At19DLegHj()

	Local oLegABB := FwLegend():New()

	oLegABB:Add( "ABB_ATIVO == '2' .OR. HasABR(ABB_CODIGO)"			, "BR_MARROM"	, STR0049 )	//"Agenda com Manuten��o"
	oLegABB:Add( "ABB_TIPOMV == '004'"								, "BR_VERMELHO"	, STR0050 )	//"Excedente"
	oLegABB:Add( "ABB_TIPOMV == '002'"								, "BR_AMARELO" 	, STR0051 )	//"Cobertura"
	oLegABB:Add( "ABB_TIPOMV == '001'"								, "BR_VERDE"	, STR0052 )	//"Efetivo"
	oLegABB:Add( "ABB_TIPOMV == '003'"								, "BR_LARANJA" 	, STR0053 )	//"Apoio"
	oLegABB:Add( "ABB_TIPOMV == '006'"								, "BR_CINZA"	, STR0054 )	//"Curso"
	oLegABB:Add( "ABB_TIPOMV == '007'"								, "BR_BRANCO"	, STR0055 )	//"Cortesia"
	oLegABB:Add( "ABB_TIPOMV == '005'"								, "BR_AZUL"	 	, STR0056 )	//"Treinamento"
	oLegABB:Add( "!(ABB_TIPOMV) $ '001|002|003|004|005|006|007')"	, "BR_PINK"	  	, STR0057 )	//"Outros Tipos"
	oLegABB:Add( "ABB_TIPOMV == 'FOL'"								, "BR_VIOLETA"	, STR0058 )	//"Folga"
	oLegABB:Add( "ABB_TIPOMV == '   '"								, "BR_CINZA"	, STR0059 )	//"Agenda n�o projetada"
	oLegABB:View()

	DelClassIntf()

Return (.T.)
//------------------------------------------------------------------------------
/*/{Protheus.doc} At190WMan

@description Fun��o executada ao marcar qualquer agenda no grid ABB

@author	boiani
@since	29/05/2019
/*/
//------------------------------------------------------------------------------
Function At190WMan()
	Local oMdlFull := FwModelActive()
	Local oMdlABB := oMdlFull:GetModel('ABBDETAIL')
	Local oMdlMAN := oMdlFull:GetModel('MANMASTER')
	Local oStrMAN := oMdlMAN:GetStruct()
	Local lMark := oMdlABB:GetValue("ABB_MARK")
	Local oView := FwViewActive()

	If lMark
		If EMPTY(aMarks)
			oStrMAN:SetProperty("MAN_MOTIVO" , MODEL_FIELD_WHEN, {|| .T.})
			If !isBlind()
				oView:Refresh('VIEW_MAN')
			EndIF
		EndIF
		AADD(aMarks, {oMdlABB:GetValue("ABB_CODIGO"),;
			oMdlABB:GetValue("ABB_DTINI"),;
			oMdlABB:GetValue("ABB_HRINI"),;
			oMdlABB:GetValue("ABB_DTFIM"),;
			oMdlABB:GetValue("ABB_HRFIM"),;
			oMdlABB:GetValue("ABB_ATENDE"),;
			oMdlABB:GetValue("ABB_CHEGOU"),;
			oMdlABB:GetValue("ABB_IDCFAL"),;
			oMdlABB:GetValue("ABB_DTREF"),;
			.F.,;
			"",;
			oMdlABB:GetValue("ABB_FILIAL");
			})
		If !EMPTY(oMdlMAN:GetValue("MAN_MOTIVO"))
			If !(At190dMntP(oMdlMAN:GetValue("MAN_MOTIVO")))
				CleanMAN(oMdlMAN)
			EndIf
		EndIf
	Else
		aMarks[ASCAN(aMarks, {|a| a[1] == oMdlABB:GetValue("ABB_CODIGO")})][1] := ""
		If ASCAN(aMarks, {|a| !EMPTY(a[1])}) == 0
			CleanMAN(oMdlMAN)
			aMarks := {}
			oStrMAN:SetProperty("MAN_MOTIVO" , MODEL_FIELD_WHEN, {|| .F.})
		EndIf
	EndIf

Return .T.
//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At190dCons

Constru��o da consulta especifica para Mesa Operacional

@author boiani
@since 30/05/2019
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At190dCons(cTipo, lAutomato)

	Local lRet        := .F.
	Local oBrowse     := Nil
	Local cAls        := GetNextAlias()
	Local nSuperior   := 0
	Local nEsquerda   := 0
	Local nInferior   := 0
	Local nDireita    := 0
	Local cQry        := ""
	Local aIndex      := {}
	Local aSeek       := {}
	Local oDlgEscTela := Nil
	Local cTitle := ""
	Local cSpcCTR := Space(TamSx3("CN9_NUMERO")[1])
	Local oModel := FwModelActive()
	Local oMdlTGY := NIL
	Local oMdlTFL := NIL
	Local oMdlLCA := NIL
	Local oMdlLGY := NIL
	Local oMdlALC := Nil
	Local cContrat
	Local cCliente := ""
	Local cLoja := ""
	Local cLocAt := ""
	Local cProd :=  ""
	Local nX
	Local aAux
	Local aDias := {}
	Local aGrupos := {}
	Local aSeqs := {}
	Local aDados := {}
	Local oCombo
	Local cCombo
	Local oListBox
	Local oExit
	Local cSay := ""
	Local aTitulos := {}
	Local cTDX_TURNO
	Local aCampos := {}
	Local oPanel1 := NIL
	Local oPanel2 := 0
	Local nSize := ""
	Local dDataIni 		:= dDataBase
	Local dDataFim 		:= dDataBase
	Local oColumn := NIL
	Local aColumns := {}
	Local lAltera := .T.
	Local cTitulo := "X3_TITULO"
	Local aFieldFlt := {}
	Local aFilPar1 := {}
	Local aFilPar2 := {}
	Local cCBox := "X3_CBOX"
	Local aOpt := {}
	Local aTiposTGX := {}
	Local cDescri	:= "X3_DESCRIC"
	Local lMV_MultFil := TecMultFil() //Indica se a Mesa considera multiplas filiais
	Local cFil1 := ""
	Local lContinua := .T.
	Default lAutomato := IsBlind()
	Default cTipo := ""

	If cTipo <> "AA1"
		oMdlTGY := oModel:GetModel("TGYMASTER")
		oMdlLCA := oModel:GetModel("LCAMASTER")
		oMdlLGY := oModel:GetModel("LGYDETAIL")
		If RIGHT(cTipo,3) == "TFL" .AND. cTipo $ "PROD_TFL|CONTRATO_TFL|POSTO_TFL|LOCAL_TFL|CLIENTE_TFL"
			oMdlTFL := oModel:GetModel("TFLMASTER")
			cCliente := oMdlTFL:GetValue("TFL_CODENT")
			cLoja := oMdlTFL:GetValue("TFL_LOJA")
			cLocAt := oMdlTFL:GetValue("TFL_LOCAL")
			cProd :=  oMdlTFL:GetValue("TFL_PROD")
		EndIf
	EndIf

	#IFDEF SPANISH
		cTitulo	:= "X3_TITSPA"
		cCBox := "X3_CBOXSPA"
		cDescri	:= "X3_DESCSPA"
	#ELSE
		#IFDEF ENGLISH
			cTitulo	:= "X3_TITENG"
			cCBox := "X3_CBOXENG"
			cDescri	:= "X3_DESCENG"
		#ENDIF
	#ENDIF

	If cTipo $ "POSTO|LOCAL_TGY"
		cContrat := oMdlTGY:GetValue("TGY_CONTRT")
	ElseIf cTipo $ "LOCAL_LCA|POSTO_LCA"
		cContrat := oMdlLCA:GetValue("LCA_CONTRT")
	ElseIf cTipo $ "LOCAL_LGY|POSTO_LGY"
		cContrat := oMdlLGY:GetValue("LGY_CONTRT")
	ElseIf cTipo $ "POSTO_TFL|LOCAL_TFL|PROD_TFL"
		cContrat := oMdlTFL:GetValue("TFL_CONTRT")
	EndIf

	If cTipo $ "CONTRATO|CONTRATO_TFL|CONTRATO_LCA|CONTRATO_LGY"
		cTitle := STR0281	//"Contratos"

		Aadd( aSeek, { STR0060, {{"","C",TamSX3("CN9_NUMERO")[1],0,STR0060,,"CN9_NUMERO"}} } )	//"N�mero do Contrato" # "N�mero do Contrato"
		Aadd( aSeek, { STR0429, {{"","C",TamSX3("CN9_REVISA")[1],0,STR0429,,"CN9_REVISA"}} } ) //"Revis�o"
		Aadd( aSeek, { STR0430, {{"","C",TamSX3("TFJ_CODENT")[1],0,STR0430,,"TFJ_CODENT"}} } ) //"Cliente"
		Aadd( aSeek, { STR0431, {{"","C",TamSX3("TFJ_LOJA")[1],0,STR0431,,"TFJ_LOJA"}} } ) //"Loja"
		Aadd( aSeek, { STR0432, {{"","C",TamSX3("A1_NOME")[1],0,STR0432,,"A1_NOME"}} } ) //"Nome"

		Aadd( aIndex, "CN9_NUMERO" )
		Aadd( aIndex, "CN9_REVISA" )
		Aadd( aIndex, "TFJ_CODENT" )
		Aadd( aIndex, "TFJ_LOJA" )
		Aadd( aIndex, "A1_NOME" )
		Aadd( aIndex, "CN9_FILIAL")  // adicionado para n�o ter problema de n�o encontrar o �ltimo �ndice, em caso de adicionar mais deixe a filial por �ltimo

		cQry := " SELECT DISTINCT CN9_FILIAL, CN9.CN9_NUMERO, CN9.CN9_REVISA, TFJ.TFJ_CODENT, TFJ.TFJ_LOJA, SA1.A1_NOME "
		cQry += " FROM " + RetSqlName("CN9") + " CN9 "
		cQry += " INNER JOIN " + RetSqlName("TFJ") + " TFJ "
		If !lMV_MultFil
			cQry += " ON TFJ.TFJ_FILIAL = '" + xFilial("TFJ") + "' "
		Else
			cQry += " ON " + FWJoinFilial("CN9" , "TFJ" , "CN9", "TFJ", .T.) + " "
		EndIf
		cQry += " AND TFJ.D_E_L_E_T_ = ' ' "
		cQry += " AND TFJ.TFJ_CONTRT = CN9.CN9_NUMERO "
		cQry += " AND TFJ.TFJ_CONREV = CN9.CN9_REVISA "
		cQry += " AND TFJ.TFJ_STATUS = '1' "
		cQry += " INNER JOIN " + RetSqlName("TFL") + " TFL "
		If !lMV_MultFil
			cQry += " ON TFL.TFL_FILIAL = '" + xFilial("TFL") + "' "
		Else
			cQry += " ON " + FWJoinFilial("TFJ" , "TFL" , "TFJ", "TFL", .T.) + " "
		EndIf
		cQry += " AND TFL.D_E_L_E_T_ = ' ' "
		cQry += " AND TFL.TFL_CODPAI = TFJ.TFJ_CODIGO "
		cQry += " INNER JOIN " + RetSqlName("TFF") + " TFF "
		If !lMV_MultFil
			cQry += " ON TFF.TFF_FILIAL = '" + xFilial("TFF") + "' "
		Else
			cQry += " ON " + FWJoinFilial("TFL" , "TFF" , "TFL", "TFF", .T.) + " "
		EndIf
		cQry += " AND TFF.D_E_L_E_T_ = ' ' "
		cQry += " AND TFF.TFF_CODPAI = TFL.TFL_CODIGO "
		cQry += " INNER JOIN " + RetSqlName("SA1") + " SA1 "
		If !lMV_MultFil
			cQry += " ON SA1.A1_FILIAL = '" + xFilial("SA1") + "' "
		Else
			cQry += " ON " + FWJoinFilial("SA1" , "TFJ" , "SA1", "TFJ", .T.) + " "
		EndIf
		cQry += " AND SA1.D_E_L_E_T_ = ' ' "
		cQry += " AND SA1.A1_COD = TFJ.TFJ_CODENT "
		cQry += " AND SA1.A1_LOJA = TFJ.TFJ_LOJA "
		If !lMV_MultFil
			cQry += " WHERE CN9.CN9_FILIAL = '" +  xFilial('CN9') + "' AND "
		Else
			If cTipo == "CONTRATO_TFL"
				If !Empty(oMdlTFL:GetValue("TFL_FILIAL"))
					cQry += " WHERE CN9.CN9_FILIAL = '"
					cQry +=  oMdlTFL:GetValue("TFL_FILIAL") + "' AND "
				Else
					cQry += " WHERE "
				EndIf
			ElseIf cTipo == "CONTRATO"
				cQry += " WHERE CN9.CN9_FILIAL = '"
				cQry +=  oMdlTGY:GetValue("TGY_FILIAL") + "' AND "
			ElseIf cTipo == "CONTRATO_LCA"
				cQry += " WHERE CN9.CN9_FILIAL = '"
				cQry +=  oMdlLCA:GetValue("LCA_FILIAL") + "' AND "
			ElseIf cTipo == "CONTRATO_LGY"
				cQry += " WHERE CN9.CN9_FILIAL = '"
				cQry +=  oMdlLGY:GetValue("LGY_FILIAL") + "' AND "
			EndIf
		EndIf
		cQry += " CN9.D_E_L_E_T_ = ' ' "
		If cTipo == "CONTRATO_TFL" .AND. !EMPTY(cCliente)
			cQry += " AND TFJ.TFJ_CODENT = '" + cCliente + "' "
			If !EMPTY(cLoja)
				cQry += " AND TFJ.TFJ_LOJA = '" + cLoja + "' "
			EndIf
		EndIf
	ElseIf cTipo $ "SEQ|LGY_SEQ"
		cTitle := STR0282	//"Sequ�ncia"
		cSay := "Sequ�ncia do Turno: "
		aTitulos := {GetSX3Cache( "PJ_DIA", cTitulo ),;
			GetSX3Cache( "PJ_TPDIA", cTitulo ),;
			GetSX3Cache( "PJ_ENTRA1", cTitulo ),;
			GetSX3Cache( "PJ_SAIDA1", cTitulo ),;
			GetSX3Cache( "PJ_ENTRA2", cTitulo ),;
			GetSX3Cache( "PJ_SAIDA2", cTitulo ),;
			GetSX3Cache( "PJ_ENTRA3", cTitulo ),;
			GetSX3Cache( "PJ_SAIDA3", cTitulo ),;
			GetSX3Cache( "PJ_ENTRA4", cTitulo ),;
			GetSX3Cache( "PJ_SAIDA4", cTitulo )}
		cQry := " SELECT SPJ.PJ_DIA, SPJ.PJ_TPDIA, SPJ.PJ_ENTRA1, SPJ.PJ_SAIDA1, "
		cQry += " SPJ.PJ_ENTRA2, SPJ.PJ_SAIDA2, SPJ.PJ_ENTRA3, SPJ.PJ_SAIDA3, "
		cQry += " SPJ.PJ_ENTRA4, SPJ.PJ_SAIDA4, "
		If oModel:GetId() == 'TECA190G'
			oMdlALC := oModel:GetModel("ALCDETAIL")
			cQry += " SPJ.PJ_TURNO, SPJ.PJ_SEMANA "
			cQry += " FROM " + RetSqlName("SPJ") + " SPJ "
			cQry += " WHERE SPJ.D_E_L_E_T_ = ' ' "
			cQry += " AND SPJ.PJ_TURNO = '" + oMdlALC:GetValue("ALC_TURNO") + "' "
			cQry += " AND SPJ.PJ_FILIAL = '" + xFilial("SPJ",IIF(lMV_MultFil,oMdlTGY:GetValue("TGY_FILIAL"),cFilAnt)) + "' "
		Else
			cQry += " TDX.TDX_TURNO, TDX.TDX_SEQTUR"
			cQry += " FROM " + RetSqlName("TDX") + " TDX "
			cQry += " INNER JOIN " + RetSqlName("SPJ") + " SPJ "
			If lMV_MultFil
				If cTipo == "SEQ"
					cQry += " ON SPJ.PJ_FILIAL = '" + xFilial("SPJ",oMdlTGY:GetValue("TGY_FILIAL")) + "' AND "
				ElseIf cTipo == "LGY_SEQ"
					cQry += " ON SPJ.PJ_FILIAL = '" + xFilial("SPJ",oMdlLGY:GetValue("LGY_FILIAL")) + "' AND "
				EndIf
			Else
				cQry += " ON SPJ.PJ_FILIAL = '" + xFilial("SPJ") + "' AND "
			EndIf
			cQry += " SPJ.D_E_L_E_T_ = ' ' AND "
			cQry += " SPJ.PJ_TURNO = TDX.TDX_TURNO  AND "
			cQry += " SPJ.PJ_SEMANA = TDX.TDX_SEQTUR "
			cQry += " WHERE "
			If lMV_MultFil
				If cTipo == "SEQ"
					cQry += " TDX.TDX_FILIAL = '" + xFilial('TDX',oMdlTGY:GetValue("TGY_FILIAL")) + "' "
				ElseIf cTipo == "LGY_SEQ"
					cQry += " TDX.TDX_FILIAL = '" + xFilial('TDX',oMdlLGY:GetValue("LGY_FILIAL")) + "' "
				EndIf
			Else
				cQry += " TDX.TDX_FILIAL = '" + xFilial('TDX') + "' "
			EndIf
			cQry += " AND TDX.D_E_L_E_T_ = ' ' AND "
			If cTipo == 'SEQ'
				cQry += " TDX.TDX_CODTDW = '" + oMdlTGY:GetValue("TGY_ESCALA") + "' "
			ElseIf cTipo == 'LGY_SEQ'
				cQry += " TDX.TDX_CODTDW = '" + oMdlLGY:GetValue("LGY_ESCALA") + "' "
			EndIf
		EndIf

	ElseIf cTipo $ "TGY_GRUPO|LGY_GRUPO"
		cTitle := STR0283	//"Grupo"
		cSay := "Grupos: "
		aTitulos := {GetSX3Cache( "TGY_ATEND", cTitulo ),;
			GetSX3Cache( "AA1_NOMTEC", cTitulo ),;
			GetSX3Cache( "TGY_ULTALO", cTitulo ),;
			GetSX3Cache( "TDX_TURNO", cTitulo ),;
			GetSX3Cache( "TGY_SEQ", cTitulo ),;
			GetSX3Cache( "TGY_DTINI", cTitulo ),;
			GetSX3Cache( "TGY_DTFIM", cTitulo );
			}

		cQry := " SELECT TGY.TGY_ATEND, AA1.AA1_NOMTEC, TGY.TGY_ULTALO, "
		cQry += " TGY.TGY_GRUPO, TDX.TDX_TURNO ,TGY.TGY_SEQ, TGY.TGY_DTINI DTINI, TGY.TGY_DTFIM DTFIM"
		cQry += " FROM " + RetSqlName("TGY") + " TGY "
		cQry += " INNER JOIN " + RetSqlName("AA1") + " AA1 "
		If lMV_MultFil
			If cTipo == "TGY_GRUPO"
				cQry += " ON AA1.AA1_FILIAL = '" + xFilial("AA1",oMdlTGY:GetValue("TGY_FILIAL")) + "' AND "
			ElseIf cTipo == "LGY_GRUPO"
				cQry += " ON AA1.AA1_FILIAL = '" + xFilial("AA1",oMdlLGY:GetValue("LGY_FILIAL")) + "' AND "
			EndIf
		Else
			cQry += " ON AA1.AA1_FILIAL = '" + xFilial("AA1") + "' AND "
		EndIf
		cQry += " AA1.AA1_CODTEC = TGY.TGY_ATEND AND "
		cQry += " AA1.D_E_L_E_T_ = ' ' "
		cQry += " INNER JOIN " + RetSqlName("TDX") + " TDX "
		If lMV_MultFil
			If cTipo == "TGY_GRUPO"
				cQry += " ON TDX.TDX_FILIAL = '" + xFilial("TDX",oMdlTGY:GetValue("TGY_FILIAL")) + "' AND "
			ElseIf cTipo == "LGY_GRUPO"
				cQry += " ON TDX.TDX_FILIAL = '" + xFilial("TDX",oMdlLGY:GetValue("LGY_FILIAL")) + "' AND "
			EndIf
		Else
			cQry += " ON TDX.TDX_FILIAL = '" + xFilial("TDX") + "' AND "
		EndIf
		cQry += " TDX.TDX_SEQTUR = TGY.TGY_SEQ AND "
		cQry += " TDX.TDX_COD = TGY.TGY_CODTDX AND "
		cQry += " TDX.TDX_CODTDW = TGY.TGY_ESCALA AND "
		cQry += " TDX.D_E_L_E_T_ = ' ' "
		If lMV_MultFil
			If cTipo == "TGY_GRUPO"
				cQry += " WHERE TGY.TGY_FILIAL = '" +  xFilial('TGY',oMdlTGY:GetValue("TGY_FILIAL")) + "' AND "
			ElseIf cTipo == "LGY_GRUPO"
				cQry += " WHERE TGY.TGY_FILIAL = '" +  xFilial('TGY',oMdlLGY:GetValue("LGY_FILIAL")) + "' AND "
			EndIf
		Else
			cQry += " WHERE TGY.TGY_FILIAL = '" +  xFilial('TGY') + "' AND "
		EndIf
		cQry += " TGY.D_E_L_E_T_ = ' ' AND "
		If cTipo == 'TGY_GRUPO'
			cQry += " TGY.TGY_CODTFF = '" + oMdlTGY:GetValue("TGY_TFFCOD") + "' AND "
			cQry += " TGY.TGY_ESCALA = '" + oMdlTGY:GetValue("TGY_ESCALA") + "' "
		ElseIf cTipo == 'LGY_GRUPO'
			cQry += " TGY.TGY_CODTFF = '" + oMdlLGY:GetValue("LGY_CODTFF") + "' AND "
			cQry += " TGY.TGY_ESCALA = '" + oMdlLGY:GetValue("LGY_ESCALA") + "' "
			cQry += " UNION ALL "
			cQry += " SELECT TGZ.TGZ_ATEND, AA1.AA1_NOMTEC, '' TGY_ULTALO, TGZ.TGZ_GRUPO, 'COBERTURA' TDX_TURNO ,"
			cQry += " TGZ.TGZ_SEQ, TGZ.TGZ_DTINI DTINI, TGZ.TGZ_DTFIM DTFIM "
			cQry += " FROM " + RetSqlName("TGZ") + " TGZ "
			cQry += " INNER JOIN " + RetSqlName("AA1") + " AA1 "
			cQry += " ON AA1.AA1_FILIAL = '" + xFilial("AA1",oMdlLGY:GetValue("LGY_FILIAL")) + "' AND "
			cQry += " AA1.AA1_CODTEC = TGZ.TGZ_ATEND AND "
			cQry += " AA1.D_E_L_E_T_ = ' ' "
			cQry += " WHERE TGZ.TGZ_FILIAL = '" +  xFilial('TGZ',oMdlLGY:GetValue("LGY_FILIAL")) + "' AND "
			cQry += " TGZ.D_E_L_E_T_ = ' ' AND "
			cQry += " TGZ.TGZ_CODTFF = '" + oMdlLGY:GetValue("LGY_CODTFF") + "' AND "
			cQry += " TGZ.TGZ_ESCALA = '" + oMdlLGY:GetValue("LGY_ESCALA") + "' "
		EndIf
		cQry += " ORDER BY TGY.TGY_GRUPO "
	ElseIf cTipo $ "POSTO|POSTO_TFL|POSTO_LCA|POSTO_LGY"
		cTitle := STR0284	//"Posto de Trabalho"

		Aadd( aSeek, { STR0061, {{"","C",TamSX3("TFF_COD")[1],0,STR0061,,"TFF_COD"}} } )		//"C�digo do Posto" # "C�digo do Posto"
		Aadd( aSeek, { STR0103, {{"","C",TamSX3("ABS_DESCRI")[1],0,STR0103,,"ABS_DESCRI"}} } )	//"Descri��o do Posto" # "Descri��o do Posto"
		Aadd( aSeek, { STR0100, {{"","C",TamSX3("B1_COD")[1],0,STR0100,,"B1_COD"}} } )		//"C�digo do Produto" # "C�digo do Produto"
		Aadd( aSeek, { STR0101, {{"","C",TamSX3("B1_DESC")[1],0,STR0101,,"B1_DESC"}} } )		//"Descri��o" # "Descri��o"
		Aadd( aSeek, { STR0535, {{"","C",3,0,STR0535,,"TFF_COBCTR"}} } )	//"Cobra em Contr." # "Cobra em Contr."
		Aadd( aSeek, { STR0102, {{"","C",TamSX3("TFF_CONTRT")[1],0,STR0102,,"TFF_CONTRT"}} } )	//"Contrato" # "Contrato"
		Aadd( aSeek, { STR0371, {{"","C",TamSX3("TFF_FUNCAO")[1],0,STR0371,,"TFF_FUNCAO"}} } )	//"Codigo da Fun��o" # "Codigo da Fun��o"
		Aadd( aSeek, { STR0372, {{"","C",TamSX3("RJ_DESC")[1],0,STR0372,,"RJ_DESC"}} } )	//"Descri��o da Fun��o" # "Descri��o da Fun��o"
		Aadd( aSeek, { STR0373, {{"","C",TamSX3("TFF_TURNO")[1],0,STR0373,,"TFF_TURNO"}} } )	//"C�digo do Turno" # "C�digo do Turno"
		Aadd( aSeek, { STR0374, {{"","C",TamSX3("R6_DESC")[1],0,STR0374,,"R6_DESC"}} } )	//"Descri��o do Turno" # "Descri��o do Turno"
		Aadd( aSeek, { STR0375, {{"","C",TamSX3("TFF_ESCALA")[1],0,STR0375,,"TFF_ESCALA"}} } )	//"C�digo da Escala" # "Codigo da Escala"
		Aadd( aSeek, { STR0376, {{"","C",TamSX3("TDW_DESC")[1],0,STR0376,,"TDW_DESC"}} } )	//"Descri��o da Escala" # "Descri��o da Escala"

		Aadd( aIndex, "TFF_COD" )
		Aadd( aIndex, "ABS_DESCRI" )
		Aadd( aIndex, "B1_COD" )
		Aadd( aIndex, "B1_DESC" )
		Aadd( aIndex, "TFF_COBCTR" )
		Aadd( aIndex, "TFF_CONTRT" )
		Aadd( aIndex, "TFF_FUNCAO" )
		Aadd( aIndex, "RJ_DESC" )
		Aadd( aIndex, "TFF_TURNO" )
		Aadd( aIndex, "R6_DESC" )
		Aadd( aIndex, "TFF_ESCALA" )
		Aadd( aIndex, "TDW_DESC" )
		Aadd( aIndex, "TFF_FILIAL")  // adicionado para n�o ter problema de n�o encontrar o �ltimo �ndice, em caso de adicionar mais deixe a filial por �ltimo

		cQry := " SELECT TFF.TFF_FILIAL, TFF.TFF_COD, SB1.B1_COD, SB1.B1_DESC, TFF.TFF_CONTRT, ABS.ABS_DESCRI, TFF.TFF_PERINI, TFF.TFF_PERFIM, TFF.TFF_QTDVEN, "
		cQry += " TFF.TFF_FUNCAO, TFF.TFF_TURNO, TFF.TFF_ESCALA, "
		cQry += " CASE WHEN TFF_COBCTR = '1' THEN '"+ STR0533 +"' ELSE '"+ STR0534 +"' END TFF_COBCTR, " // SIM ## N�O
		cQry += " CASE WHEN RJ_DESC IS NOT NULL THEN RJ_DESC ELSE ' ' END RJ_DESC, "
		cQry += " CASE WHEN R6_DESC IS NOT NULL THEN R6_DESC ELSE ' ' END R6_DESC, "
		cQry += " CASE WHEN TDW_DESC IS NOT NULL THEN TDW_DESC ELSE ' ' END TDW_DESC "
		cQry += " FROM " + RetSqlName("TFF") + " TFF "
		cQry += " INNER JOIN " + RetSqlName( "SB1" ) + " SB1 ON SB1.B1_COD = TFF.TFF_PRODUT AND "
		If !lMV_MultFil
			cQry += " SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND "
		Else
			cQry += " " + FWJoinFilial("TFF" , "SB1" , "TFF", "SB1", .T.) + " AND "
		EndIf
		cQry += " SB1.D_E_L_E_T_ = ' ' "
		cQry += " LEFT JOIN " + RetSqlName( "SRJ" ) + " SRJ "
		If !lMV_MultFil
			cQry += " ON SRJ.RJ_FILIAL = '" + xFilial("SRJ") + "' "
		Else
			cQry += " ON " + FWJoinFilial("TFF" , "SRJ" , "TFF", "SRJ", .T.) + " "
		EndIf
		cQry += " AND SRJ.D_E_L_E_T_ = ' ' "
		cQry += " AND SRJ.RJ_FUNCAO = TFF.TFF_FUNCAO "
		cQry += " LEFT JOIN " + RetSqlName( "SR6" ) + " SR6 "
		If !lMV_MultFil
			cQry += " ON SR6.R6_FILIAL = '" + xFilial("SR6") + "' "
		Else
			cQry += " ON " + FWJoinFilial("TFF" , "SR6" , "TFF", "SR6", .T.) + " "
		EndIf
		cQry += " AND SR6.D_E_L_E_T_ = ' ' "
		cQry += " AND SR6.R6_TURNO = TFF.TFF_TURNO "
		cQry += " LEFT JOIN " + RetSqlName( "TDW" ) + " TDW "
		If !lMV_MultFil
			cQry += " ON TDW.TDW_FILIAL = '" + xFilial("TDW") + "' "
		Else
			cQry += " ON " + FWJoinFilial("TFF" , "TDW" , "TFF", "TDW", .T.) + " "
		EndIf
		cQry += " AND TDW.D_E_L_E_T_ = ' ' "
		cQry += " AND TDW.TDW_COD = TFF.TFF_ESCALA "
		cQry += " INNER JOIN " + RetSqlName("TFL") + " TFL "
		If !lMV_MultFil
			cQry += " ON TFL.TFL_FILIAL = '" + xFilial("TFL") + "' "
		Else
			cQry += " ON " + FWJoinFilial("TFF" , "TFL" , "TFF", "TFL", .T.) + " "
		EndIf
		cQry += " AND TFL.D_E_L_E_T_ = ' ' "
		cQry += " AND TFL.TFL_CODIGO = TFF.TFF_CODPAI "
		cQry += " INNER JOIN " + RetSqlName("TFJ") + " TFJ "
		If !lMV_MultFil
			cQry += " ON TFJ.TFJ_FILIAL = '" + xFilial("TFJ") + "' AND "
		Else
			If cTipo == "POSTO_TFL"
				If !EMPTY(oMdlTFL:GetValue("TFL_FILIAL"))
					cQry += " ON TFJ.TFJ_FILIAL = '" + oMdlTFL:GetValue("TFL_FILIAL") + "' AND "
				Else
					cQry += " ON "
				EndIf
			ElseIf cTipo == "POSTO"
				cQry += " ON TFJ.TFJ_FILIAL = '" + oMdlTGY:GetValue("TGY_FILIAL") + "' AND "
			ElseIf cTipo == "POSTO_LCA"
				cQry += " ON TFJ.TFJ_FILIAL = '" + oMdlLCA:GetValue("LCA_FILIAL") + "' AND "
			ElseIf cTipo == "POSTO_LGY"
				cQry += " ON TFJ.TFJ_FILIAL = '" + oMdlLGY:GetValue("LGY_FILIAL") + "' AND "
			EndIf
			cQry += FWJoinFilial("TFF" , "TFJ" , "TFF", "TFJ", .T.) + " AND "
		EndIf
		cQry += " TFJ.D_E_L_E_T_ = ' ' "
		cQry += " AND TFJ.TFJ_CODIGO = TFL.TFL_CODPAI "
		cQry += " AND TFJ.TFJ_STATUS = '1' "
		cQry += " AND TFJ.TFJ_CONTRT <> '" + cSpcCTR + "' "
		If !EMPTY(cContrat)
			cQry += " AND TFJ.TFJ_CONTRT = '" + cContrat + "' "
		EndIf
		cQry += " INNER JOIN " + RetSqlName( "ABS" ) + " ABS ON TFL.TFL_LOCAL = ABS.ABS_LOCAL AND "
		If !lMV_MultFil
			cQry += " ABS.ABS_FILIAL = '" + xFilial("ABS") + "' "
		Else
			cQry += " " + FWJoinFilial("ABS" , "TFL" , "ABS", "TFL", .T.) + " "
		EndIf
		cQry += " AND ABS.D_E_L_E_T_ = ' ' "
		cQry += " WHERE "
		If !lMV_MultFil
			cQry += " TFF.TFF_FILIAL = '" +  xFilial('TFF') + "' AND "
		EndIf
		cQry += " TFF.D_E_L_E_T_ = ' ' "
		If cTipo == "POSTO_TFL"
			If !EMPTY(cCliente)
				cQry += " AND TFJ.TFJ_CODENT = '" + cCliente + "' "
				If !EMPTY(cLoja)
					cQry += " AND TFJ.TFJ_LOJA = '" + cLoja + "' "
				EndIf
			EndIf

			If !EMPTY(cLocAt)
				cQry += " AND TFL.TFL_LOCAL = '" + cLocAt + "' "
			EndIf

			If !EMPTY(cProd)
				cQry += " AND TFF.TFF_PRODUT = '" + cProd + "' "
			EndIf
		ElseIf cTipo == "POSTO"
			cQry += " AND TFL.TFL_CODIGO = '" + oMdlTGY:GetValue("TGY_CODTFL") + "' "
		ElseIf cTipo == "POSTO_LCA" .AND. !EMPTY(oMdlLCA:GetValue("LCA_CODTFL"))
			cQry += " AND TFL.TFL_CODIGO = '" + oMdlLCA:GetValue("LCA_CODTFL") + "' "
		ElseIf cTipo == "POSTO_LGY" .AND. !EMPTY(oMdlLGY:GetValue("LGY_CODTFL"))
			cQry += " AND TFL.TFL_CODIGO = '" + oMdlLGY:GetValue("LGY_CODTFL") + "' "
		EndIf

		If cTipo != "POSTO_TFL"
			cQry += " AND TFF.TFF_ENCE != '1' "
		EndIf

	ElseIf cTipo $ "LOCAL_TFL|LOCAL_TGY|LOCAL_LCA|LOCAL_LGY"
		cTitle := STR0031	//"Local de Atendimento"

		If cTipo $ "LOCAL_TGY|LOCAL_LCA|LOCAL_LGY"
			Aadd( aSeek, { GetSX3Cache( "TFL_CODIGO", cDescri ), {{"","C",TamSX3("TFL_CODIGO")[1],0,GetSX3Cache( "TFL_CODIGO", cDescri ),,"TFL_CODIGO"}} } )
		EndIf
		Aadd( aSeek, { STR0104, {{"","C",TamSX3("ABS_LOCAL")[1],0,STR0104,,"ABS_LOCAL"}} } )	//"C�digo do Local" # "C�digo do Local"
		Aadd( aSeek, { STR0105, {{"","C",TamSX3("ABS_LOCPAI")[1],0,STR0105,,"ABS_LOCPAI"}} } )	//"Sublocal de" # "Sublocal de"
		Aadd( aSeek, { STR0101, {{"","C",TamSX3("ABS_DESCRI")[1],0,STR0101,,"ABS_DESCRI"}} } )	//"Descri��o" # "Descri��o"
		Aadd( aSeek, { STR0106, {{"","C",TamSX3("ABS_CCUSTO")[1],0,STR0106,,"ABS_CCUSTO"}} } )	//"C.Custo" # "C.Custo"
		Aadd( aSeek, { STR0107, {{"","C",TamSX3("ABS_REGIAO")[1],0,STR0107,,"ABS_REGIAO"}} } )	//"Regi�o" # "Regi�o"

		If cTipo $ "LOCAL_TGY|LOCAL_LCA|LOCAL_LGY"
			Aadd( aIndex, "TFL_CODIGO" )
		EndIf
		Aadd( aIndex, "ABS_LOCAL" )
		Aadd( aIndex, "ABS_LOCPAI" )
		Aadd( aIndex, "ABS_DESCRI" )
		Aadd( aIndex, "ABS_CCUSTO" )
		Aadd( aIndex, "ABS_REGIAO" )
		Aadd( aIndex, "ABS_FILIAL")  // adicionado para n�o ter problema de n�o encontrar o �ltimo �ndice, em caso de adicionar mais deixe a filial por �ltimo

		If cTipo $ "LOCAL_TFL
			cQry := " SELECT DISTINCT ABS.ABS_FILIAL FILLOC ,ABS.ABS_LOCAL, ABS.ABS_LOCPAI, ABS.ABS_DESCRI, ABS.ABS_CCUSTO, ABS.ABS_REGIAO, ABS.ABS_FILIAL "
		Else
			cQry := " SELECT DISTINCT TFL.TFL_FILIAL FILLOC ,TFL.TFL_CODIGO , ABS.ABS_LOCAL, ABS.ABS_LOCPAI, ABS.ABS_DESCRI, ABS.ABS_CCUSTO, ABS.ABS_REGIAO, ABS.ABS_FILIAL "
			cQry += " , TFL.TFL_DTINI , TFL.TFL_DTFIM "
		EndIf
		cQry += " FROM " + RetSqlName("ABS") + " ABS "
		cQry += " INNER JOIN " + RetSqlName("TFL") + " TFL "
		If !lMV_MultFil
			cQry += " ON TFL.TFL_FILIAL = '" + xFilial("TFL") + "' "
		Else
			cQry += " ON " + FWJoinFilial("ABS" , "TFL" , "ABS", "TFL", .T.) + " "
		EndIf
		cQry += " AND TFL.D_E_L_E_T_ = ' ' "
		cQry += " AND TFL.TFL_LOCAL = ABS.ABS_LOCAL "
		cQry += " INNER JOIN " + RetSqlName("TFJ") + " TFJ "
		If !lMV_MultFil
			cQry += " ON TFJ.TFJ_FILIAL = '" + xFilial("TFJ") + "' AND "
		Else
			If cTipo == 'LOCAL_TFL'
				If !EMPTY(oMdlTFL:GetValue("TFL_FILIAL"))
					cQry += " ON TFJ.TFJ_FILIAL = '" + oMdlTFL:GetValue("TFL_FILIAL") + "' AND "
				Else
					cQry += " ON "
				Endif
			ElseIf cTipo == 'LOCAL_TGY'
				cQry += " ON TFJ.TFJ_FILIAL = '" + oMdlTGY:GetValue("TGY_FILIAL") + "' AND "
			ElseIf cTipo == 'LOCAL_LCA'
				cQry += " ON TFJ.TFJ_FILIAL = '" + oMdlLCA:GetValue("LCA_FILIAL") + "' AND "
			ElseIf cTipo == 'LOCAL_LGY'
				cQry += " ON TFJ.TFJ_FILIAL = '" + oMdlLGY:GetValue("LGY_FILIAL") + "' AND "
			EndIf
			cQry += " " + FWJoinFilial("TFJ" , "TFL" , "TFJ", "TFL", .T.) + " AND "
		EndIf
		cQry += " TFJ.D_E_L_E_T_ = ' ' "
		cQry += " AND TFJ.TFJ_CODIGO = TFL.TFL_CODPAI "
		cQry += " AND TFJ.TFJ_STATUS = '1' "
		cQry += " AND TFJ.TFJ_CONTRT <> '" + cSpcCTR + "' "
		cQry += " WHERE "
		If !lMV_MultFil
			cQry += " ABS.ABS_FILIAL = '" +  xFilial('ABS') + "' AND "
		EndIf
		cQry += " ABS.D_E_L_E_T_ = ' ' "
		If !EMPTY(cContrat)
			cQry += " AND TFJ.TFJ_CONTRT = '" + cContrat + "' "
		EndIf
		If !EMPTY(cCliente) .AND. cTipo == "LOCAL_TFL"
			cQry += " AND TFJ.TFJ_CODENT = '" + cCliente + "' "
			If !EMPTY(cLoja)
				cQry += " AND TFJ.TFJ_LOJA = '" + cLoja + "' "
			EndIf
		EndIf
		If cTipo $ "LOCAL_LGY|LOCAL_TGY"
			cQry += " AND TFL.TFL_ENCE != '1' "
		EndIf
	ElseIf cTipo $ "PROD_TFL"
		cTitle := STR0285	//"Item de RH"

		Aadd( aSeek, { STR0100, {{"","C",TamSX3("B1_COD")[1],0,STR0100,,"B1_COD"}} } )	//"C�digo do Produto" # "C�digo do Produto"
		Aadd( aSeek, { STR0101, {{"","C",TamSX3("B1_DESC")[1],0,STR0101,,"B1_DESC"}} } )	//"Descri��o" # "Descri��o"

		Aadd( aIndex, "B1_COD" )
		Aadd( aIndex, "B1_DESC" )
		Aadd( aIndex, "B1_FILIAL")  // adicionado para n�o ter problema de n�o encontrar o �ltimo �ndice, em caso de adicionar mais deixe a filial por �ltimo

		cQry := " SELECT DISTINCT SB1.B1_COD, SB1.B1_DESC, SB1.B1_FILIAL "
		cQry += " FROM " + RetSqlName("SB1") + " SB1 "
		cQry += " INNER JOIN " + RetSqlName("TFF") + " TFF "
		If !Empty(oMdlTFL:GetValue("TFL_FILIAL")) .OR. !lMV_MultFil
			cQry += " ON TFF.TFF_FILIAL = '" + xFilial("TFF", IIF(lMV_MultFil,oMdlTFL:GetValue("TFL_FILIAL"),cFilAnt)) + "' AND "
		Else
			cQry += " ON "
		EndIf
		cQry += " TFF.D_E_L_E_T_ = ' ' "
		cQry += " AND TFF.TFF_PRODUT = SB1.B1_COD "
		cQry += " INNER JOIN " + RetSqlName("TFL") + " TFL "
		If !Empty(oMdlTFL:GetValue("TFL_FILIAL")) .OR. !lMV_MultFil
			cQry += " ON TFL.TFL_FILIAL = '" + xFilial("TFL",IIF(lMV_MultFil,oMdlTFL:GetValue("TFL_FILIAL"),cFilAnt)) + "' AND "
		Else
			cQry += " ON "
		EndIf
		cQry += " TFL.D_E_L_E_T_ = ' ' "
		cQry += " AND TFL.TFL_CODIGO = TFF.TFF_CODPAI "
		cQry += " INNER JOIN " + RetSqlName("TFJ") + " TFJ "
		If !Empty(oMdlTFL:GetValue("TFL_FILIAL")) .OR. !lMV_MultFil
			cQry += " ON TFJ.TFJ_FILIAL = '" + xFilial("TFJ",IIF(lMV_MultFil,oMdlTFL:GetValue("TFL_FILIAL"),cFilAnt)) + "' AND "
		Else
			cQry += " ON "
		EndIf
		cQry += " TFJ.D_E_L_E_T_ = ' ' "
		cQry += " AND TFJ.TFJ_CODIGO = TFL.TFL_CODPAI "
		cQry += " AND TFJ.TFJ_STATUS = '1' "
		cQry += " AND TFJ.TFJ_CONTRT <> '" + cSpcCTR + "' "
		If !Empty(oMdlTFL:GetValue("TFL_FILIAL")) .OR. !lMV_MultFil
			cQry += " WHERE SB1.B1_FILIAL = '" +  xFilial('SB1',IIF(lMV_MultFil,oMdlTFL:GetValue("TFL_FILIAL"),cFilAnt)) + "' AND "
		Else
			cQry += " WHERE "
		EndIf
		cQry += " SB1.D_E_L_E_T_ = ' ' "
		If !EMPTY(cContrat)
			cQry += " AND TFJ.TFJ_CONTRT = '" + cContrat + "' "
		EndIf
		If !EMPTY(cCliente)
			cQry += " AND TFJ.TFJ_CODENT = '" + cCliente + "' "
			If !EMPTY(cLoja)
				cQry += " AND TFJ.TFJ_LOJA = '" + cLoja + "' "
			EndIf
		EndIf
		If !EMPTY(cLocAt)
			cQry += " AND TFL.TFL_LOCAL = '" + cLocAt + "' "
		EndIf
	ElseIf cTipo == "MANUT"
		cTitle := STR0286	//"Motivo de Manuten��o"

		Aadd( aSeek, { STR0108, {{"","C",TamSX3("ABN_CODIGO")[1],0,STR0108,,"ABN_CODIGO"}} } )	//"C�digo" # "C�digo"
		Aadd( aSeek, { STR0101, {{"","C",TamSX3("ABN_DESC")[1],0,STR0101,,"ABN_DESC"}} } )	//"Descri��o" # "Descri��o"

		Aadd( aIndex, "ABN_CODIGO" )
		Aadd( aIndex, "ABN_DESC" )
		Aadd( aIndex, "ABN_FILIAL")  // adicionado para n�o ter problema de n�o encontrar o �ltimo �ndice, em caso de adicionar mais deixe a filial por �ltimo
		If lMV_MultFil
			For nX := 1 To LEN(aMarks)
				If !EMPTY(aMarks[nX][1])
					If Empty(cFil1)
						cFil1 := aMarks[nX][12]
					ElseIf cFil1 != aMarks[nX][12]
						Help( " ", 1, "MULTFIL", Nil, STR0479, 1 )
						//"A inclus�o de manuten��es em lote s� pode ser executada em registros da mesma filial. Selecione apenas registros da mesma filial e execute a inclus�o."
						lContinua := .F.
						Exit
					EndIf
				EndIf
			Next nX
		Else
			cFil1 := cFilAnt
		EndIf
		cQry := " SELECT ABN.ABN_FILIAL, ABN.ABN_CODIGO, ABN.ABN_DESC "
		cQry += " FROM " + RetSqlName("ABN") + " ABN "
		cQry += " WHERE ABN.ABN_FILIAL = '" +  xFilial('ABN', cFil1) + "' AND "
		cQry += " ABN.D_E_L_E_T_ = ' ' AND "
		cQry += " ABN.ABN_TIPO IN ( "
		aAux := AllowedTypes()
		For nX := 1 To LEN(aAux)
			cQry += "'" + aAux[nX] + "'"
			If nX != LEN(aAux)
				cQry += " , "
			EndIf
		Next nX
		cQry += " )"
	ElseIf cTipo == "AA1"
		aCampos := { { GetSx3Cache("AA1_NOMTEC", cTitulo),TamSX3("AA1_NOMTEC")[1], TamSX3("AA1_NOMTEC")[2] , GetSx3Cache("AA1_NOMTEC", "X3_TIPO") , GetSx3Cache("AA1_NOMTEC", "X3_PICTURE"), ""},;
			{ GetSx3Cache("AA1_NOMUSU", cTitulo),TamSX3("AA1_NOMUSU")[1], TamSX3("AA1_NOMUSU")[2], GetSx3Cache("AA1_NOMUSU", "X3_TIPO") , GetSx3Cache("AA1_NOMUSU", "X3_PICTURE"), ""},;
			{ GetSx3Cache("AA1_CODTEC", cTitulo),TamSX3("AA1_CODTEC")[1], TamSX3("AA1_CODTEC")[2], GetSx3Cache("AA1_CODTEC", "X3_TIPO"), GetSx3Cache("AA1_CODTEC", "X3_PICTURE"), "" },;
			{ GetSx3Cache("RA_TPCONTR", cTitulo),TamSX3("RA_TPCONTR")[1], TamSX3("RA_TPCONTR")[2], GetSx3Cache("RA_TPCONTR", "X3_TIPO"), GetSx3Cache("RA_TPCONTR", "X3_PICTURE"), GetSx3Cache("RA_TPCONTR", cCbox)} }



		Aadd( aSeek, { aCampos[01,01] ,{{"",aCampos[01,04],aCampos[01,02],aCampos[01,03],aCampos[01,01] ,,}}})
		Aadd( aSeek, { aCampos[02,01], {{"",aCampos[02,04],aCampos[02,02],aCampos[02,03],aCampos[02,01],,}}})
		Aadd( aSeek, { aCampos[03,01], {{"",aCampos[03,04],aCAmpos[03,02],,aCampos[03,03],aCampos[03,01],,}}})

		Aadd( aIndex, "AA1_NOMTEC" )
		Aadd( aIndex, "AA1_NOMUSU")
		Aadd( aIndex, "AA1_CODTEC")

		If !Empty( aCampos[04,06])
			aOpt := Separa(aCampos[04,06], ";", .F.)
		EndIf

		Aadd( aFieldFlt, {"AA1_NOMTEC" , aCampos[01,01] , aCampos[01,04], aCampos[01,02] , aCampos[01,03], aCampos[01,05],,} )
		Aadd( aFieldFlt, {"AA1_NOMUSU" , aCampos[02,01] , aCampos[02,04], aCampos[02,02] , aCampos[03,03], aCampos[02,05],,} )
		Aadd( aFieldFlt, {"AA1_CODTEC" , aCampos[03,01] , aCampos[03,04], aCampos[02,02] , aCampos[03,03], aCampos[03,05],,} )
		Aadd( aFieldFlt, {"RA_TPCONTR" , aCampos[04,01] , aCampos[04,04], aCampos[04,02] , aCampos[04,03], aCampos[04,05],aOpt} )


		cQry := " SELECT 'BR_MARROM      '	AS AA1_TMPLG, AA1.AA1_FILIAL, AA1.AA1_CODTEC, AA1.AA1_NOMTEC, AA1.AA1_NOMUSU, CASE WHEN SRA.RA_TPCONTR IS NULL THEN '" + space(aCampos[04,02])+ "' ELSE SRA.RA_TPCONTR END RA_TPCONTR "
		cQry += " FROM " + RetSqlName("AA1") + " AA1 "
		cQry += " LEFT JOIN " + RetSqlName("SRA") + " SRA ON ( "
		cQry += " SRA.RA_FILIAL =  AA1.AA1_FUNFIL AND SRA.RA_MAT = AA1.AA1_CDFUNC"
		If SRA->(FieldPos('RA_MSBLQL')) > 0
			cQry += " AND SRA.RA_MSBLQL <> '1'"
		EndIf
		cQry += " AND SRA.D_E_L_E_T_ = ' ' )"
		cQry += " WHERE AA1.AA1_FILIAL = '" +  xFilial('AA1') + "'"
		cQry += " AND AA1.D_E_L_E_T_ = ' '"

		//-- Necess�rio utilizar FieldPos, pois o campo de bloqueio de registro � opcional para o cliente.
		If AA1->(FieldPos('AA1_MSBLQL')) > 0
			cQry += " AND AA1.AA1_MSBLQL <> '1'"
		EndIf

		SAddFilPar("RA_TPCONTR","==" ,"%RA_TPCONTR%",@aFilPar1)
		SAddFilPar("RA_TPCONTR","!=" ,"%RA_TPCONTR%",@aFilPar2)
	ElseIf cTipo == "LGY_CONFAL"
		cTitle := STR0433 //"Configura��o de Aloca��o"
		cTipoAlo := oMdlLGY:GetValue("LGY_TIPOAL")

		If cTipoAlo == "1"
			Aadd( aSeek, { STR0089, {{"","C",TamSX3("TDX_TURNO")[1],0,STR0089,,"TDX_TURNO"}} } ) //"Turno"
			Aadd( aSeek, { STR0099, {{"","C",TamSX3("R6_DESC")[1],0,STR0099,,"LGY_TIPOAL"}} } ) //"Descri��o"

			Aadd( aIndex, "TDX_TURNO" )
			Aadd( aIndex, "R6_DESC" )
			Aadd( aIndex, "TDX_FILIAL")

			cQry := " SELECT TDX.TDX_COD COD, TDX.TDX_TURNO, TDX.TDX_SEQTUR, SR6.R6_DESC, TDX.TDX_FILIAL "
			cQry += " FROM " + RetSqlName("TDX") + " TDX "
			cQry += " INNER JOIN " + RetSqlName("SR6") + " SR6 ON "
			cQry += " SR6.R6_TURNO = TDX.TDX_TURNO AND "
			cQry += " SR6.R6_FILIAL = '" + xFilial("SR6") + "' AND "
			cQry += " SR6.D_E_L_E_T_ = ' ' "
			cQry += " WHERE TDX.TDX_FILIAL = '" + xFilial("TDX") + "' AND "
			cQry += " TDX.D_E_L_E_T_ = ' ' AND TDX.TDX_CODTDW = '" + oMdlLGY:GetValue("LGY_ESCALA") + "' "
		ElseIf cTipoAlo == "2"
			Aadd( aSeek, { STR0414, {{"","C",TamSX3("TGX_ITEM")[1],0,STR0414,,"TGX_ITEM"}} } ) // "Item"

			Aadd( aIndex, "TGX_ITEM" )
			Aadd( aIndex, "TGX_FILIAL")

			aTiposTGX :=  STRTOKARR(Alltrim(GetSx3Cache("TGX_TIPO", cCbox)),";")
			For nX := 1 To LEN(aTiposTGX)
				aTiposTGX[nX] := {LEFT(aTiposTGX[nX], AT('=',aTiposTGX[nX])-1 ),SUBSTR(aTiposTGX[nX],AT('=',aTiposTGX[nX])+1)}
			Next nX

			cQry := " SELECT DISTINCT TGX.TGX_COD COD, TGX.TGX_TIPO, TGX.TGX_ITEM, TGX.TGX_FILIAL, "
			cQry += " CASE "
			For nX := 1 to LEN(aTiposTGX)
				cQry += " WHEN TGX.TGX_TIPO = '" + aTiposTGX[nX][1] + "' THEN '" + aTiposTGX[nX][2] + "' "
			Next nX
			cQry += " END TGX_DESCR "
			cQry += " FROM " + RetSqlName("TGX") + " TGX "
			cQry += " WHERE TGX.TGX_FILIAL = '" +  xFilial('TGX') + "' AND "
			cQry += " TGX.D_E_L_E_T_ = ' ' AND TGX.TGX_CODTDW = '" + oMdlLGY:GetValue("LGY_ESCALA")  + "' "
		EndIf
	ElseIf cTipo $ "TDW|TDW_ALOCACOES"
		cTitle := STR0375 //"C�digo da Escala"

		Aadd( aSeek, { STR0482, {{"","C",TamSX3("TDW_FILIAL")[1],0,STR0482,,"TDW_FILIAL"}} } ) //"Filial"
		Aadd( aSeek, { STR0375, {{"","C",TamSX3("TDW_COD")[1],0,STR0375,,"TDW_COD"}} } ) //"C�digo da Escala"
		Aadd( aSeek, { STR0376, {{"","C",TamSX3("TDW_DESC")[1],0,STR0376,,"TDW_DESC"}} } ) //"Descri��o da Escala"
		Aadd( aSeek, { STR0079, {{"","C",TamSX3("TDW_STATUS")[1],0,STR0079,,"TDW_STATUS"}} } ) //"Status"

		Aadd( aIndex, "TDW_COD" )
		Aadd( aIndex, "TDW_DESC" )
		Aadd( aIndex, "TDW_FILIAL")  // adicionado para n�o ter problema de n�o encontrar o �ltimo �ndice, em caso de adicionar mais deixe a filial por �ltimo

		cQry := " SELECT TDW.TDW_FILIAL, TDW.TDW_COD, TDW.TDW_DESC, TDW.TDW_STATUS "
		cQry += " FROM " + RetSqlName("TDW") + " TDW "
		If cTipo == 'TDW'
			cQry += " WHERE TDW.TDW_FILIAL = '" + xFilial("TDW", oMdlTGY:GetValue("TGY_FILIAL")) + "' AND "
		ElseIf cTipo == 'TDW_ALOCACOES'
			cQry += " WHERE TDW.TDW_FILIAL = '" + xFilial("TDW", oMdlLGY:GetValue("LGY_FILIAL")) + "' AND "
		EndIf
		cQry += " TDW.D_E_L_E_T_ = ' ' "

	ElseIf cTipo $ "TCU|TCU_ALOCACOES|TCU_BUSCA"
		cTitle := STR0030 //"Tp. Movimenta��o"

		Aadd( aSeek, { STR0483, {{"","C",TamSX3("TCU_COD")[1],0,STR0483,,"TCU_COD"}} } ) //"C�digo"
		Aadd( aSeek, { STR0068, {{"","C",TamSX3("TCU_DESC")[1],0,STR0068,,"TCU_DESC"}} } ) //"Descri��o do tipo de movimenta��o."
		Aadd( aSeek, { STR0484, {{"","C",TamSX3("TCU_RESTEC")[1],0,STR0484,,"TCU_RESTEC"}} } ) //"Reserva T�cnica"

		Aadd( aIndex, "TCU_COD" )
		Aadd( aIndex, "TCU_DESC" )
		Aadd( aIndex, "TCU_FILIAL")  // adicionado para n�o ter problema de n�o encontrar o �ltimo �ndice, em caso de adicionar mais deixe a filial por �ltimo

		cQry := " SELECT TCU.TCU_FILIAL, TCU.TCU_COD, TCU.TCU_DESC, TCU.TCU_RESTEC "
		cQry += " FROM " + RetSqlName("TCU") + " TCU "
		If cTipo == "TCU"
			cQry += " WHERE TCU.TCU_FILIAL = '" + xFilial("TCU", oMdlTGY:GetValue("TGY_FILIAL")) + "' AND "
		ElseIf cTipo == "TCU_ALOCACOES"
			cQry += " WHERE TCU.TCU_FILIAL = '" + xFilial("TCU", oMdlLGY:GetValue("LGY_FILIAL")) + "' AND "
		ElseIf cTipo == "TCU_BUSCA"
			cQry += " WHERE TCU.TCU_FILIAL = '"
			If Empty(oMdlLCA:GetValue("LCA_FILIAL"))
				cQry += xFilial("TCU")
			Else
				cQry += xFilial("TCU", oMdlLCA:GetValue("LCA_FILIAL"))
			EndIf
			cQry += "' AND "
		EndIf
		cQry += " TCU.D_E_L_E_T_ = ' ' AND TCU.TCU_EXALOC = '1' "
	ElseIf cTipo == "CLIENTE_TFL"
		cTitle := STR0430 //"Cliente"

		Aadd( aSeek, { STR0482, {{"","C",TamSX3("A1_FILIAL")[1],0,STR0482,,"A1_FILIAL"}} } ) //"Filial"
		Aadd( aSeek, { STR0483, {{"","C",TamSX3("A1_COD")[1],0,STR0483,,"A1_COD"}} } ) //"C�digo"
		Aadd( aSeek, { STR0485, {{"","C",TamSX3("A1_LOJA")[1],0,STR0485,,"A1_LOJA"}} } ) //"Loja"
		Aadd( aSeek, { STR0486, {{"","C",TamSX3("A1_NOME")[1],0,STR0486,,"A1_NOME"}} } ) //"Nome"
		Aadd( aSeek, { STR0487, {{"","C",TamSX3("A1_EST")[1],0,STR0487,,"A1_EST"}} } ) //"UF"
		Aadd( aSeek, { STR0488, {{"","C",TamSX3("A1_MUN")[1],0,STR0488,,"A1_MUN"}} } ) //"Munic�pio"

		Aadd( aIndex, "A1_COD" )
		Aadd( aIndex, "A1_LOJA" )
		Aadd( aIndex, "A1_NOME" )
		Aadd( aIndex, "A1_EST" )
		Aadd( aIndex, "A1_MUN" )
		Aadd( aIndex, "A1_FILIAL")  // adicionado para n�o ter problema de n�o encontrar o �ltimo �ndice, em caso de adicionar mais deixe a filial por �ltimo

		cQry := " SELECT SA1.A1_FILIAL, SA1.A1_COD, SA1.A1_LOJA,SA1.A1_NOME,SA1.A1_EST,SA1.A1_MUN "
		cQry += " FROM " + RetSqlName("SA1") + " SA1 "
		If !Empty(oMdlTFL:GetValue("TFL_FILIAL")) .Or. !lMV_MultFil
			cQry += " WHERE SA1.A1_FILIAL = '" + xFilial("SA1", oMdlTFL:GetValue("TFL_FILIAL")) + "' AND "
		Else
			cQry += " WHERE "
		EndIf
		cQry += " SA1.D_E_L_E_T_ = ' ' "
	Elseif cTipo == "ORCITEXTR"
		cTitle := STR0539 //"Or�amento para Item Extra"

		Aadd( aSeek, { STR0482, {{"","C",TamSX3("TFJ_FILIAL")[1],0,STR0482,,"TFJ_FILIAL"}} } ) //"Filial"
		Aadd( aSeek, { STR0540, {{"","C",TamSX3("TFJ_CODIGO")[1],0,STR0540,,"TFJ_CODIGO"}} } ) //"C�digo Or�amento"
		Aadd( aSeek, { STR0541, {{"","C",TamSX3("TFJ_CODENT")[1],0,STR0541,,"TFJ_CODENT"}} } ) //"C�digo Cliente"
		Aadd( aSeek, { STR0542, {{"","C",TamSX3("TFJ_LOJA")[1]	,0,STR0542,,"TFJ_LOJA"	}} } ) //"Loja"
		Aadd( aSeek, { STR0543, {{"","C",TamSX3("A1_NOME")[1]	,0,STR0543,,"A1_NOME"	}} } ) //"Nome"
		Aadd( aSeek, { STR0545, {{"","C",TamSX3("TFJ_CONTRT")[1],0,STR0545,,"TFJ_CONTRT"}} } ) //"Contrato"
		Aadd( aSeek, { STR0546, {{"","C",TamSX3("TFJ_CONREV")[1],0,STR0546,,"TFJ_CONREV"}} } ) //"Revis�o"

		Aadd( aIndex, "TFJ_CODIGO" )
		Aadd( aIndex, "A1_NOME"    )
		Aadd( aIndex, "TFJ_FILIAL" )  // adicionado para n�o ter problema de n�o encontrar o �ltimo �ndice, em caso de adicionar mais deixe a filial por �ltimo

		cQry := " SELECT TFJ.TFJ_FILIAL, TFJ.TFJ_CODIGO, TFJ.TFJ_CODENT, TFJ.TFJ_LOJA, SA1.A1_NOME,TFJ_CONTRT,TFJ_CONREV "
		cQry += " FROM " + RetSqlName("TFJ") + " TFJ "
		cQry += " INNER JOIN " + RetSqlName("SA1") + " SA1 "
		cQry += " ON SA1.A1_FILIAL = '" + xFilial("SA1") + "' "
		cQry += " AND SA1.D_E_L_E_T_ = ' ' "
		cQry += " AND SA1.A1_COD = TFJ.TFJ_CODENT "
		cQry += " AND SA1.A1_LOJA = TFJ.TFJ_LOJA "
		cQry += " WHERE TFJ.TFJ_FILIAL = '" + xFilial("TFJ") + "' "
		cQry += " AND TFJ.TFJ_STATUS = '1' "
		cQry += " AND TFJ.TFJ_CONTRT <> '' "
		cQry += " AND TFJ.D_E_L_E_T_ = ' ' "
		cQry += " ORDER BY TFJ.TFJ_FILIAL,TFJ.TFJ_CODIGO "

	Elseif cTipo == "LOCITEXTR"
		cTitle := STR0544 //"Local para Item Extra"

		Aadd( aSeek, { STR0482, {{"","C",TamSX3("TFL_FILIAL")[1],0,STR0482,,"TFL_FILIAL"}} } ) //"Filial"
		Aadd( aSeek, { STR0548, {{"","C",TamSX3("TFL_LOCAL")[1]	,0,STR0548,,"TFL_LOCAL"	}} } ) //"C�digo Local Atend."
		Aadd( aSeek, { STR0549, {{"","C",TamSX3("ABS_DESCRI")[1],0,STR0549,,"ABS_DESCRI"}} } ) //"Descri��o"

		Aadd( aIndex, "TFL_LOCAL"  )
		Aadd( aIndex, "TFL_FILIAL" )  // adicionado para n�o ter problema de n�o encontrar o �ltimo �ndice, em caso de adicionar mais deixe a filial por �ltimo

		cQry := " SELECT TFL.TFL_FILIAL,TFL.TFL_LOCAL,ABS.ABS_DESCRI "
		cQry += " FROM " + RetSqlName("TFL") + " TFL "
		cQry += " INNER JOIN " + RetSqlName( "ABS" ) + " ABS "
		cQry += " ON ABS.ABS_FILIAL = '" + xFilial("ABS") + "' "
		cQry += " AND ABS.ABS_LOCAL = TFL.TFL_LOCAL "
		cQry += " AND ABS.D_E_L_E_T_ = ' ' " "
		cQry += " WHERE TFL.TFL_FILIAL = '" + xFilial("TFL") + "' "
		cQry += " AND TFL.TFL_CODPAI = '" + TFJ->TFJ_CODIGO + "' "
		cQry += " AND TFL.TFL_ENCE <> '1' "
		cQry += " AND TFL.D_E_L_E_T_ = ' ' "
		cQry += " GROUP BY TFL.TFL_FILIAL, TFL.TFL_LOCAL, ABS.ABS_DESCRI  "
		cQry += " ORDER BY TFL.TFL_FILIAL, TFL.TFL_LOCAL "
	EndIf

	cQry := ChangeQuery(cQry)

	If ASCAN({"SEQ","TGY_GRUPO","AA1","LGY_SEQ","LGY_GRUPO"}, cTipo) == 0
		nSuperior := 0
		nEsquerda := 0
		If !lAutomato .AND. lContinua

			nInferior := GetScreenRes()[2] * 0.6
			nDireita  := GetScreenRes()[1] * 0.65

			DEFINE MSDIALOG oDlgEscTela TITLE cTitle FROM nSuperior,nEsquerda TO nInferior,nDireita PIXEL

			oBrowse := FWFormBrowse():New()
			oBrowse:SetOwner(oDlgEscTela)
			oBrowse:SetDataQuery(.T.)
			oBrowse:SetAlias(cAls)
			oBrowse:SetQueryIndex(aIndex)
			oBrowse:SetQuery(cQry)
			oBrowse:SetSeek(,aSeek)
			oBrowse:SetDescription(cTitle)
			oBrowse:SetMenuDef("")
			oBrowse:DisableDetails()

			At190SetFlt(aSeek, @oBrowse)

			If cTipo $ "CONTRATO|CONTRATO_TFL|CONTRATO_LCA|CONTRATO_LGY"
				oBrowse:SetDoubleClick({ || cRetF3 := (oBrowse:Alias())->CN9_NUMERO, lRet := .T. ,oDlgEscTela:End()})
				oBrowse:AddButton( OemTOAnsi(STR0109), {|| cRetF3  := (oBrowse:Alias())->CN9_NUMERO, lRet := .T., oDlgEscTela:End() } ,, 2 )	//"Confirmar"
			ElseIf cTipo $ "POSTO|POSTO_TFL|POSTO_LCA|POSTO_LGY"
				oBrowse:SetDoubleClick({ || cRetF3 := (oBrowse:Alias())->TFF_COD, lRet := .T. ,oDlgEscTela:End()})
				oBrowse:AddButton( OemTOAnsi(STR0109), {|| cRetF3  := (oBrowse:Alias())->TFF_COD, lRet := .T., oDlgEscTela:End() } ,, 2 )	//"Confirmar"
			ElseIf cTipo $ "LOCAL_TFL"
				oBrowse:SetDoubleClick({ || cRetF3 := (oBrowse:Alias())->ABS_LOCAL, lRet := .T. ,oDlgEscTela:End()})
				oBrowse:AddButton( OemTOAnsi(STR0109), {|| cRetF3  := (oBrowse:Alias())->ABS_LOCAL, lRet := .T., oDlgEscTela:End() } ,, 2 )	//"Confirmar"
			ElseIf cTipo $ "LOCAL_TGY|LOCAL_LCA|LOCAL_LGY"
				oBrowse:SetDoubleClick({ || cRetF3 := (oBrowse:Alias())->TFL_CODIGO, lRet := .T. ,oDlgEscTela:End()})
				oBrowse:AddButton( OemTOAnsi(STR0109), {|| cRetF3  := (oBrowse:Alias())->TFL_CODIGO, lRet := .T., oDlgEscTela:End() } ,, 2 )	//"Confirmar
			ElseIf cTipo $ "PROD_TFL"
				oBrowse:SetDoubleClick({ || cRetF3 := (oBrowse:Alias())->B1_COD, lRet := .T. ,oDlgEscTela:End()})
				oBrowse:AddButton( OemTOAnsi(STR0109), {|| cRetF3  := (oBrowse:Alias())->B1_COD, lRet := .T., oDlgEscTela:End() } ,, 2 )	//"Confirmar"
			ElseIf cTipo $ "MANUT"
				oBrowse:SetDoubleClick({ || cRetF3 := (oBrowse:Alias())->ABN_CODIGO, lRet := .T. ,oDlgEscTela:End()})
				oBrowse:AddButton( OemTOAnsi(STR0109), {|| cRetF3  := (oBrowse:Alias())->ABN_CODIGO, lRet := .T., oDlgEscTela:End() } ,, 2 )	//"Confirmar"
			ElseIf cTipo $ "LGY_CONFAL"
				oBrowse:SetDoubleClick({ || cRetF3 := (oBrowse:Alias())->COD, lRet := .T. ,oDlgEscTela:End()})
				oBrowse:AddButton( OemTOAnsi(STR0109), {|| cRetF3  := (oBrowse:Alias())->COD, lRet := .T., oDlgEscTela:End() } ,, 2 )	//"Confirmar"
			ElseIf cTipo $ "TDW|TDW_ALOCACOES"
				oBrowse:SetDoubleClick({ || cRetF3 := (oBrowse:Alias())->TDW_COD, lRet := .T. ,oDlgEscTela:End()})
				oBrowse:AddButton( OemTOAnsi(STR0109), {|| cRetF3  := (oBrowse:Alias())->TDW_COD, lRet := .T., oDlgEscTela:End() } ,, 2 )	//"Confirmar"
			ElseIf cTipo $ "TCU|TCU_ALOCACOES|TCU_BUSCA"
				oBrowse:SetDoubleClick({ || cRetF3 := (oBrowse:Alias())->TCU_COD, lRet := .T. ,oDlgEscTela:End()})
				oBrowse:AddButton( OemTOAnsi(STR0109), {|| cRetF3  := (oBrowse:Alias())->TCU_COD, lRet := .T., oDlgEscTela:End() } ,, 2 )	//"Confirmar"
			Elseif cTipo $ "CLIENTE_TFL"
				oBrowse:SetDoubleClick({ || cRetF3 := (oBrowse:Alias())->A1_COD, cRetF3_2 := (oBrowse:Alias())->A1_LOJA, lRet := .T. ,oDlgEscTela:End()})
				oBrowse:AddButton( OemTOAnsi(STR0109), {|| cRetF3 := (oBrowse:Alias())->A1_COD, cRetF3_2 := (oBrowse:Alias())->A1_LOJA, lRet := .T., oDlgEscTela:End() } ,, 2 )	//"Confirmar"
			Elseif cTipo $ "ORCITEXTR"
				oBrowse:SetDoubleClick({ || cRetF3 := (oBrowse:Alias())->TFJ_CODIGO ,lRet := .T. ,oDlgEscTela:End()})
				oBrowse:AddButton( OemTOAnsi(STR0109), {|| cRetF3 := (oBrowse:Alias())->TFJ_CODIGO, lRet := .T., oDlgEscTela:End() } ,, 2 )	//"Confirmar"
			Elseif cTipo $ "LOCITEXTR"
				oBrowse:SetDoubleClick({ || cRetF3 := (oBrowse:Alias())->TFL_LOCAL ,lRet := .T. ,oDlgEscTela:End()})
				oBrowse:AddButton( OemTOAnsi(STR0109), {|| cRetF3 := (oBrowse:Alias())->TFL_LOCAL, lRet := .T., oDlgEscTela:End() } ,, 2 )	//"Confirmar"
			EndIf

			oBrowse:AddButton( OemTOAnsi(STR0232),  {|| cRetF3  := "",cRetF3_2 := "", oDlgEscTela:End() } ,, 2 )	//"Cancelar"
			oBrowse:DisableDetails()

			If cTipo $ "CONTRATO|CONTRATO_TFL|CONTRATO_LCA|CONTRATO_LGY"
				ADD COLUMN oColumn DATA { ||  CN9_FILIAL  } TITLE STR0482 SIZE TamSX3("CN9_FILIAL")[1] OF oBrowse
				ADD COLUMN oColumn DATA { ||  CN9_NUMERO  } TITLE STR0102 SIZE TamSX3("CN9_NUMERO")[1] OF oBrowse	//"Contrato"
				ADD COLUMN oColumn DATA { ||  CN9_REVISA  } TITLE STR0429  SIZE TamSX3("CN9_REVISA")[1] OF oBrowse //"Revis�o"
				ADD COLUMN oColumn DATA { ||  TFJ_CODENT  } TITLE STR0430 SIZE TamSX3("TFJ_CODENT")[1] OF oBrowse // "Cliente"
				ADD COLUMN oColumn DATA { ||  TFJ_LOJA  } TITLE STR0431 SIZE TamSX3("TFJ_LOJA")[1] OF oBrowse //"Loja"
				ADD COLUMN oColumn DATA { ||  A1_NOME  } TITLE STR0432 SIZE TamSX3("A1_NOME")[1] OF oBrowse //"Nome"
			ElseIf cTipo $ "POSTO|POSTO_TFL|POSTO_LCA|POSTO_LGY"
				ADD COLUMN oColumn DATA { ||  TFF_FILIAL  } TITLE STR0482 SIZE TamSX3("TFF_FILIAL")[1] OF oBrowse
				ADD COLUMN oColumn DATA { ||  TFF_COD  		} TITLE STR0061 SIZE TamSX3("TFF_COD")[1] OF oBrowse	//"C�digo do Posto"
				ADD COLUMN oColumn DATA { ||  B1_COD 		} TITLE STR0100 SIZE TamSX3("B1_COD")[1] OF oBrowse		//"C�digo do Produto"
				ADD COLUMN oColumn DATA { ||  B1_DESC  		} TITLE STR0101 SIZE TamSX3("B1_DESC")[1] OF oBrowse	//"Descri��o"
				ADD COLUMN oColumn DATA { ||  TFF_COBCTR  	} TITLE STR0535 SIZE 3 OF oBrowse //"Cobra em Contr."
				ADD COLUMN oColumn DATA { ||  TFF_CONTRT  	} TITLE STR0102 SIZE TamSX3("TFF_CONTRT")[1] OF oBrowse	//"Contrato"
				ADD COLUMN oColumn DATA { ||  ABS_DESCRI  	} TITLE STR0478 SIZE TamSX3("ABS_DESCRI")[1] OF oBrowse	//"Descri��o do Posto"
				ADD COLUMN oColumn DATA { ||  STOD(TFF_PERINI ) 	} TITLE STR0110 SIZE TamSX3("TFF_PERINI")[1] OF oBrowse	//"Per�odo Inicial"
				ADD COLUMN oColumn DATA { ||  STOD(TFF_PERFIM ) 	} TITLE STR0111 SIZE TamSX3("TFF_PERFIM")[1] OF oBrowse	//"Per�odo Final"
				ADD COLUMN oColumn DATA { ||  TFF_QTDVEN  	} TITLE GetSX3Cache( "TFF_QTDVEN", cDescri ) SIZE TamSX3("TFF_QTDVEN")[1] OF oBrowse
				ADD COLUMN oColumn DATA { ||  TFF_FUNCAO  	} TITLE STR0371 SIZE TamSX3("TFF_FUNCAO")[1] OF oBrowse	//"Codigo da Fun��o"
				ADD COLUMN oColumn DATA { ||  RJ_DESC 	 	} TITLE STR0372 SIZE TamSX3("RJ_DESC")[1] OF oBrowse	//"Descri��o da Fun��o"
				ADD COLUMN oColumn DATA { ||  TFF_TURNO  	} TITLE STR0373 SIZE TamSX3("TFF_TURNO")[1] OF oBrowse	//"C�digo do Turno"
				ADD COLUMN oColumn DATA { ||  R6_DESC	  	} TITLE STR0374 SIZE TamSX3("R6_DESC")[1] OF oBrowse	//"Descri��o do Turno"
				ADD COLUMN oColumn DATA { ||  TFF_ESCALA  	} TITLE STR0375 SIZE TamSX3("TFF_ESCALA")[1] OF oBrowse	//"Codigo da Escala"
				ADD COLUMN oColumn DATA { ||  TDW_DESC  	} TITLE STR0376 SIZE TamSX3("TDW_DESC")[1] OF oBrowse	//"Descri��o da Escala"
			ElseIf cTipo $ "LOCAL_TFL|LOCAL_TGY|LOCAL_LCA|LOCAL_LGY"
				ADD COLUMN oColumn DATA { ||  FILLOC  } TITLE STR0482 SIZE TamSX3("TFL_FILIAL")[1] OF oBrowse
				If cTipo $ "LOCAL_TGY|LOCAL_LCA|LOCAL_LGY"
					ADD COLUMN oColumn DATA { ||  TFL_CODIGO  	} TITLE GetSX3Cache( "TFL_CODIGO", cDescri ) SIZE TamSX3("TFL_CODIGO")[1] OF oBrowse	//"Regi�o"
					ADD COLUMN oColumn DATA { ||  STOD(TFL_DTINI)  	} TITLE GetSX3Cache( "TFL_DTINI", cDescri ) SIZE TamSX3("TFL_DTINI")[1] OF oBrowse
					ADD COLUMN oColumn DATA { ||  STOD(TFL_DTFIM)  	} TITLE GetSX3Cache( "TFL_DTFIM", cDescri ) SIZE TamSX3("TFL_DTFIM")[1] OF oBrowse
				EndIf
				ADD COLUMN oColumn DATA { ||  ABS_LOCAL  	} TITLE STR0104 SIZE TamSX3("ABS_LOCAL")[1] OF oBrowse	//"C�digo do Local"
				ADD COLUMN oColumn DATA { ||  ABS_LOCPAI 	} TITLE STR0105 SIZE TamSX3("ABS_LOCPAI")[1] OF oBrowse	//"Sublocal de"
				ADD COLUMN oColumn DATA { ||  ABS_DESCRI  	} TITLE STR0101 SIZE TamSX3("ABS_DESCRI")[1] OF oBrowse	//"Descri��o"
				ADD COLUMN oColumn DATA { ||  ABS_CCUSTO  	} TITLE STR0106 SIZE TamSX3("ABS_CCUSTO")[1] OF oBrowse	//"C.Custo"
				ADD COLUMN oColumn DATA { ||  ABS_REGIAO  	} TITLE STR0107 SIZE TamSX3("ABS_REGIAO")[1] OF oBrowse	//"Regi�o"
			ElseIf cTipo $ "PROD_TFL"
				ADD COLUMN oColumn DATA { ||  B1_FILIAL	} TITLE STR0482 SIZE TamSX3("B1_FILIAL")[1] OF oBrowse
				ADD COLUMN oColumn DATA { ||  B1_COD  	} TITLE STR0100 SIZE TamSX3("B1_COD")[1] OF oBrowse			//"C�digo do Produto"
				ADD COLUMN oColumn DATA { ||  B1_DESC 	} TITLE STR0101 SIZE TamSX3("B1_DESC")[1] OF oBrowse		//"Descri��o"
			ElseIf cTipo $ "MANUT"
				ADD COLUMN oColumn DATA { ||  ABN_FILIAL  	} TITLE STR0482 SIZE TamSX3("ABN_FILIAL")[1] OF oBrowse
				ADD COLUMN oColumn DATA { ||  ABN_CODIGO  	} TITLE STR0112 SIZE TamSX3("ABN_CODIGO")[1] OF oBrowse	//"C�digo da Manuten��o"
				ADD COLUMN oColumn DATA { ||  ABN_DESC 		} TITLE STR0101 SIZE TamSX3("ABN_DESC")[1] OF oBrowse	//"Descri��o"
			ElseIf cTipo $ "LGY_CONFAL"
				If cTipoAlo == "1"
					ADD COLUMN oColumn DATA { ||  COD  	} TITLE STR0108 SIZE TamSX3("TDX_COD")[1] OF oBrowse //"C�digo"
					ADD COLUMN oColumn DATA { ||  TDX_TURNO  	} TITLE STR0434 SIZE TamSX3("TDX_TURNO")[1] OF oBrowse //"Cod.Turno"
					ADD COLUMN oColumn DATA { ||  TDX_SEQTUR  	} TITLE STR0435 SIZE TamSX3("TDX_SEQTUR")[1] OF oBrowse //"Sequ�ncia"
					ADD COLUMN oColumn DATA { ||  R6_DESC 	} TITLE STR0436 SIZE TamSX3("R6_DESC")[1] OF oBrowse //"Descr.Turno"
				ElseIf cTipoAlo == "2"
					ADD COLUMN oColumn DATA { ||  COD  	} TITLE STR0108 SIZE TamSX3("TGX_COD")[1] OF oBrowse //"C�digo"
					ADD COLUMN oColumn DATA { ||  TGX_TIPO  	} TITLE STR0419 SIZE TamSX3("TGX_TIPO")[1] OF oBrowse //"Tipo"
					ADD COLUMN oColumn DATA { ||  TGX_ITEM  	} TITLE STR0414 SIZE TamSX3("TGX_ITEM")[1] OF oBrowse //"Item"
					ADD COLUMN oColumn DATA { ||  TGX_DESCR 	} TITLE STR0099 SIZE 35 OF oBrowse //"Descri��o"
				EndIf
			Elseif cTipo $ "TDW|TDW_ALOCACOES"
				ADD COLUMN oColumn DATA { ||  TDW_FILIAL  	} TITLE STR0482 SIZE TamSX3("TDW_FILIAL")[1] OF oBrowse
				ADD COLUMN oColumn DATA { ||  TDW_COD 		} TITLE STR0375 SIZE TamSX3("TDW_COD")[1] OF oBrowse
				ADD COLUMN oColumn DATA { ||  TDW_DESC  	} TITLE STR0376 SIZE TamSX3("TDW_DESC")[1] OF oBrowse	//"Descri��o da Escala"
				ADD COLUMN oColumn DATA { ||  X3Combo("TDW_STATUS",TDW_STATUS )  	} TITLE STR0079 SIZE TamSX3("TDW_STATUS")[1] OF oBrowse	//"Status"
			Elseif cTipo $ "TCU|TCU_ALOCACOES|TCU_BUSCA"
				ADD COLUMN oColumn DATA { ||  TCU_COD 		} TITLE STR0483 SIZE TamSX3("TCU_COD")[1] OF oBrowse
				ADD COLUMN oColumn DATA { ||  TCU_DESC  	} TITLE STR0030 SIZE TamSX3("TCU_DESC")[1] OF oBrowse
				ADD COLUMN oColumn DATA { ||  X3Combo("TCU_RESTEC",TCU_RESTEC )  	} TITLE STR0484 SIZE TamSX3("TCU_RESTEC")[1] OF oBrowse
			ElseIf cTipo == "CLIENTE_TFL"
				ADD COLUMN oColumn DATA { ||  A1_FILIAL	} TITLE STR0482 SIZE TamSX3("A1_FILIAL")[1] OF oBrowse
				ADD COLUMN oColumn DATA { ||  A1_COD 	} TITLE STR0483 SIZE TamSX3("A1_COD")[1] OF oBrowse
				ADD COLUMN oColumn DATA { ||  A1_LOJA  	} TITLE STR0485 SIZE TamSX3("A1_LOJA")[1] OF oBrowse
				ADD COLUMN oColumn DATA { ||  A1_NOME  	} TITLE STR0486 SIZE TamSX3("A1_NOME")[1] OF oBrowse
				ADD COLUMN oColumn DATA { ||  A1_EST 	} TITLE STR0487 SIZE TamSX3("A1_EST")[1] OF oBrowse
				ADD COLUMN oColumn DATA { ||  A1_MUN  	} TITLE STR0488 SIZE TamSX3("A1_MUN")[1] OF oBrowse
			ElseIf cTipo == "ORCITEXTR"
				ADD COLUMN oColumn DATA { ||  TFJ_FILIAL	} TITLE STR0482 SIZE TamSX3("TFJ_FILIAL")[1] OF oBrowse //"Filial"
				ADD COLUMN oColumn DATA { ||  TFJ_CODIGO 	} TITLE STR0540 SIZE TamSX3("TFJ_CODIGO")[1] OF oBrowse //"C�digo Or�amento"
				ADD COLUMN oColumn DATA { ||  TFJ_CODENT 	} TITLE STR0541 SIZE TamSX3("TFJ_CODENT")[1] OF oBrowse //"C�digo Cliente"
				ADD COLUMN oColumn DATA { ||  TFJ_LOJA 		} TITLE STR0542 SIZE TamSX3("TFJ_LOJA")[1] 	 OF oBrowse //"Loja"
				ADD COLUMN oColumn DATA { ||  A1_NOME 		} TITLE STR0543 SIZE TamSX3("A1_NOME")[1] 	 OF oBrowse //"Nome"
			ElseIf cTipo == "LOCITEXTR"
				ADD COLUMN oColumn DATA { ||  TFL_FILIAL	} TITLE STR0482 SIZE TamSX3("TFL_FILIAL")[1] OF oBrowse //"Filial"
				ADD COLUMN oColumn DATA { ||  TFL_LOCAL 	} TITLE STR0548 SIZE TamSX3("TFL_LOCAL")[1]  OF oBrowse //"C�digo Local Atend."
				ADD COLUMN oColumn DATA { ||  ABS_DESCRI 	} TITLE STR0549 SIZE TamSX3("ABS_DESCRI")[1] OF oBrowse //"Descri��o"
			EndIf
			oBrowse:Activate()

			ACTIVATE MSDIALOG oDlgEscTela CENTERED
		Else
			lRet := .T.
		EndIf
	ElseIf cTipo == "AA1"

		nSuperior := 0
		nEsquerda := 0
		nInferior := 580
		nDireita  := 800
		cTitle := FwSX2Util():GetX2Name( "AA1" )
		If !lAutomato
			DEFINE MSDIALOG oDlgEscTela TITLE cTitle FROM nSuperior,nEsquerda TO nInferior,nDireita PIXEL

			oPanel1 := TPanel():Create( oDlgEscTela, 5, 5, "", /*[ oFont ]*/, /*[ lCentered ]*/, /*[ uParam7 ]*/, /*[ nClrText ]*/, /*[ nClrBack ]*/,nDireita-25,  40  /*[ lLowered ]*/,.F. )
			nSize := CalcFieldSize("C", 12, 0, "@!", STR0348)//"Data Inicial"
			@ 00, 00 Say oSay1 Prompt STR0349 OF oPanel1 SIZE CalcFieldSize("C", Len(STR0349), 0, "@!", STR0349), 10 PIXEL //"Per�odo de Consulta da Situa��o"
			@ 15, 00 Say oSay1 Prompt STR0348 OF oPanel1 SIZE nSize, 10 PIXEL //"Data Inicial"
			@ 15, nSize+10 Say oSay1 Prompt STR0350 OF oPanel1 SIZE nSize, 10 PIXEL //"Data Final"
			@ 25, 00 GET oGet VAR dDataIni SIZE nSize,10 OF oPanel1 PIXEL VALID !empty(dDataIni) WHEN lAltera
			@ 25, nSize+10 GET oGet VAR dDataFim SIZE nSize,10 OF oPanel1 PIXEL VALID !empty(dDataFim) .AND. dDataFim >= dDataIni When lAltera

			oPanel2 := TPanel():Create( oDlgEscTela, 50, 0, , /*[ oFont ]*/, /*[ lCentered ]*/, /*[ uParam7 ]*/, /*[ nClrText ]*/, /*[ nClrBack ]*/,nDireita-410 , nInferior-345 , /*[ lLowered ]*/, /*[ lRaised ]*/ )

			oBrowse := FWFormBrowse():New()
			oBrowse:SetOwner(oPanel2)
			oBrowse:SetDataQuery(.T.)
			oBrowse:SetAlias(cAls)
			oBrowse:SetQueryIndex(aIndex)
			oBrowse:SetQuery(cQry)
			oBrowse:SetSeek(,aSeek)
			oBrowse:SetDescription(cTitle)  // "Atendentes"
			oBrowse:SetMenuDef("")

			oBrowse:SetTemporary(.T.)
			oBrowse:SetDBFFilter(.T.)
			oBrowse:SetFilterDefault( "" )
			oBrowse:SetUseFilter(.T.)

			oBrowse:AddFilter(aCampos[04,01] + STR0361, "RA_TPCONTR == '%RA_TPCONTR%'", .F., .F.,nil,.T., aFilPar1, 'RA_TPCONTR1') //" Igual a "
			oBrowse:AddFilter(aCampos[04,01] + STR0362, "RA_TPCONTR != '%RA_TPCONTR%'", .F., .F.,nil,.T., aFilPar2, 'RA_TPCONTR2')//" Diferente de "
			oBrowse:AddFilter(aCampos[04,01] + STR0363, "RA_TPCONTR == '"+ space(aCampos[04,02])+"'", .F., .F.,nil,.F., , 'RA_TPCONTR3') //" N�o informado "
			oBrowse:AddFilter(aCampos[04,01] + STR0364, "RA_TPCONTR != '"+ space(aCampos[04,02])+"'", .F., .F.,nil,.T., , 'RA_TPCONTR4') //" Informado"

			oBrowse:SetFieldFilter(aFieldFlt)
			oBrowse:DisableDetails()
			oBrowse:SetDoubleClick({ || cRetF3 := (oBrowse:Alias())->AA1_CODTEC, lRet := .T. ,oDlgEscTela:End()})
			oBrowse:AddButton( OemTOAnsi(STR0337), {|| cRetF3   := (oBrowse:Alias())->AA1_CODTEC, lRet := .T., oDlgEscTela:End() } ,, 2 ) //"Confirmar"
			oBrowse:AddButton( OemTOAnsi(STR0351),  {||   At19LAA1(oBrowse,dDataIni,dDataFim, @lAltera) } ,, 2 ) //"Consultar Situa��o"
			oBrowse:AddButton( OemTOAnsi(STR0338),  {||  cRetF3   := "", oDlgEscTela:End() } ,, 2 ) //"Cancelar"
			oBrowse:AddButton( OemTOAnsi(STR0352),{|| At330VsAtd((oBrowse:Alias())->AA1_CODTEC)},,,,.F.,1) 	// "Visualizar Atendente"
			oBrowse:AddButton( OemTOAnsi(STR0353),{|| At570Detal((oBrowse:Alias())->AA1_CODTEC, {{dDataIni, "", dDataFim, ""}} )},,,,.F.,1) 	// "Detalhes no RH"
			oBrowse:AddButton( OemTOAnsi(STR0354),{|| At330VsRest((oBrowse:Alias())->AA1_CODTEC)},,,,.F.,1)   // "Restri��es do atendente"
			oBrowse:AddButton( OemTOAnsi(STR0025),  {||  At330LMkA1(.T.)} ,, 2 ) //"Legenda"

			// Adiciona as colunas do Browse
			oColumn := FWBrwColumn():New()
			oColumn:SetData( {|| AA1_TMPLG } )
			oColumn:SetTitle( STR0025 ) //"Legenda"
			oColumn:SetSize(1)
			oColumn:SetDecimal(0)
			oColumn:SetPicture("@BMP")
			oColumn:SetImage(.T.)
			oColumn:SetDoubleClick({|| At330LMkA1(.T.) })
			AAdd( aColumns, oColumn)

			oColumn := FWBrwColumn():New()
			oColumn:SetData( {|| AA1_CODTEC } )
			oColumn:SetTitle( aCampos[03,01]  )
			oColumn:SetSize( aCampos[03,02])
			oColumn:SetDecimal( aCampos[03,03])
			AAdd( aColumns, oColumn)

			oColumn := FWBrwColumn():New()
			oColumn:SetData(  {|| AA1_NOMTEC } )
			oColumn:SetTitle( aCampos[01,01] )
			oColumn:SetSize(  aCampos[01,02])
			oColumn:SetDecimal( aCampos[01,03])
			AAdd( aColumns, oColumn)

			oColumn := FWBrwColumn():New()
			oColumn:SetData(  {|| AA1_NOMUSU } )
			oColumn:SetTitle( aCampos[02,01] )
			oColumn:SetSize(  aCampos[02,02])
			oColumn:SetDecimal(aCampos[02,03])
			AAdd( aColumns, oColumn)


			oColumn := FWBrwColumn():New()
			oColumn:SetData(  {|| RA_TPCONTR + " - " + X3Combo("RA_TPCONTR",RA_TPCONTR ) } )
			oColumn:SetTitle( aCampos[04,01] )
			oColumn:SetSize(  aCampos[04,02])
			oColumn:SetDecimal(aCampos[04,03])
			AAdd( aColumns, oColumn)

			oBrowse:SetColumns(aColumns)
			oBrowse:Activate()

			ACTIVATE MSDIALOG oDlgEscTela CENTERED
		Else

			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQry),cAls, .F., .F.)
			At19LAA1(NIL,dDataIni,dDataFim, @lAltera, .T., cAls)
			(cAls)->(DbCloseArea())
			lRet := .t.
		EndIf
	Else
		nSuperior := 0
		nEsquerda := 0
		nInferior := 432
		nDireita  := 864
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQry),cAls, .F., .T.)
		While !((cAls)->(EOF()))
			If cTipo $ "SEQ|LGY_SEQ"
				If oModel:GetId() == 'TECA190G'
					cTDX_TURNO := (cAls)->(PJ_TURNO)
					AADD(aDias, {TECCdow(VAL((cAls)->(PJ_DIA))),; 						//1
					CharToD((cAls)->(PJ_TPDIA)),;							//2
					NumToHr((cAls)->(PJ_ENTRA1)),;							//3
					NumToHr((cAls)->(PJ_SAIDA1)),;							//4
					NumToHr((cAls)->(PJ_ENTRA2)),;							//5
					NumToHr((cAls)->(PJ_SAIDA2)),;							//6
					NumToHr((cAls)->(PJ_ENTRA3)),;							//7
					NumToHr((cAls)->(PJ_SAIDA3)),;							//8
					NumToHr((cAls)->(PJ_ENTRA4)),;							//9
					NumToHr((cAls)->(PJ_SAIDA4)),;							//10
					(cAls)->(PJ_TURNO) + " - " + (cAls)->(PJ_SEMANA)})	//11
					If ASCAN(aSeqs, (cAls)->(PJ_TURNO) + " - " + (cAls)->(PJ_SEMANA)) == 0
						AADD(aSeqs, (cAls)->(PJ_TURNO) + " - " + (cAls)->(PJ_SEMANA))
					EndIf
				Else
					cTDX_TURNO := (cAls)->(TDX_TURNO)
					AADD(aDias, {TECCdow(VAL((cAls)->(PJ_DIA))),; 						//1
					CharToD((cAls)->(PJ_TPDIA)),;							//2
					NumToHr((cAls)->(PJ_ENTRA1)),;							//3
					NumToHr((cAls)->(PJ_SAIDA1)),;							//4
					NumToHr((cAls)->(PJ_ENTRA2)),;							//5
					NumToHr((cAls)->(PJ_SAIDA2)),;							//6
					NumToHr((cAls)->(PJ_ENTRA3)),;							//7
					NumToHr((cAls)->(PJ_SAIDA3)),;							//8
					NumToHr((cAls)->(PJ_ENTRA4)),;							//9
					NumToHr((cAls)->(PJ_SAIDA4)),;							//10
					(cAls)->(TDX_TURNO) + " - " + (cAls)->(TDX_SEQTUR)})	//11
					If ASCAN(aSeqs, (cAls)->(TDX_TURNO) + " - " + (cAls)->(TDX_SEQTUR)) == 0
						AADD(aSeqs, (cAls)->(TDX_TURNO) + " - " + (cAls)->(TDX_SEQTUR))
					EndIf
				EndIf
				If aDias[LEN(aDias)][3] == "00:00" .AND. aDias[LEN(aDias)][4] == "00:00"
					aDias[LEN(aDias)][3] := ""
					aDias[LEN(aDias)][4] := ""
				EndIf
				If aDias[LEN(aDias)][5] == "00:00" .AND. aDias[LEN(aDias)][6] == "00:00"
					aDias[LEN(aDias)][5] := ""
					aDias[LEN(aDias)][6] := ""
				EndIf
				If aDias[LEN(aDias)][7] == "00:00" .AND. aDias[LEN(aDias)][8] == "00:00"
					aDias[LEN(aDias)][7] := ""
					aDias[LEN(aDias)][8] := ""
				EndIf
				If aDias[LEN(aDias)][9] == "00:00" .AND. aDias[LEN(aDias)][10] == "00:00"
					aDias[LEN(aDias)][9] := ""
					aDias[LEN(aDias)][10] := ""
				EndIf
			ElseIf cTipo $ "TGY_GRUPO|LGY_GRUPO"
				AADD(aGrupos, {(cAls)->(TGY_ATEND),;
					ALLTRIM((cAls)->(AA1_NOMTEC)),;
					StoD((cAls)->(TGY_ULTALO)),;
					(cAls)->(TDX_TURNO),;
					(cAls)->(TGY_SEQ),;
					StoD((cAls)->(DTINI)),;
					StoD((cAls)->(DTFIM)),;
					(STR0437 + cValToChar((cAls)->(TGY_GRUPO))); //"Grupo: "
				})
				If ASCAN(aSeqs, STR0437 + cValToChar((cAls)->(TGY_GRUPO))) == 0 //"Grupo: "
					AADD(aSeqs, STR0437 + cValToChar((cAls)->(TGY_GRUPO))) //"Grupo: "
				EndIf
			EndIf
			(cAls)->(dbSkip())
		End
		(cAls)->(dbCloseArea())
		If cTipo $ "TGY_GRUPO|LGY_GRUPO" .AND. !EMPTY(aSeqs)
			If cTipo == "TGY_GRUPO"
				If !EMPTY(oMdlTGY:GetValue("TGY_GRUPO"))
					cCombo := STR0437 + cValToChar(oMdlTGY:GetValue("TGY_GRUPO")) //"Grupo: "
				Else
					cCombo := aSeqs[1]
				EndIf
			elseif cTipo == "LGY_GRUPO"
				If !EMPTY(oMdlLGY:GetValue("LGY_GRUPO"))
					cCombo := STR0437 + cValToChar(oMdlLGY:GetValue("LGY_GRUPO")) //"Grupo: "
				Else
					cCombo := aSeqs[1]
				EndIf
			EndIf
			aDados := GetGrupos(aGrupos,cCombo)
		ElseIf !EMPTY(aSeqs)
			If cTipo == 'SEQ'
				If oModel:GetId() <> 'TECA190G' .AND. !EMPTY(oMdlTGY:GetValue("TGY_SEQ"))
					cCombo := cTDX_TURNO + " - " + oMdlTGY:GetValue("TGY_SEQ")
				Else
					cCombo := aSeqs[1]
				EndIf
			ElseIf cTipo == 'LGY_SEQ'
				If !EMPTY(oMdlLGY:GetValue("LGY_SEQ")) .AND. !EMPTY(oMdlLGY:GetValue("LGY_CONFAL"))
					cCombo := POSICIONE('TDX',1,xFilial("TDX",oMdlLGY:GetValue("LGY_FILIAL")) + oMdlLGY:GetValue("LGY_CONFAL"), 'TDX_TURNO') + " - " + oMdlLGY:GetValue("LGY_SEQ")
				Else
					cCombo := aSeqs[1]
				EndIf
			EndIf

			aDados := GetPjs(aDias,cCombo)
		EndIf
		If !EMPTY(aSeqs)
			If !lAutomato
				DEFINE MSDIALOG oDlgEscTela TITLE cTitle FROM nSuperior,nEsquerda TO nInferior,nDireita PIXEL
				@ 5, 9 SAY STR0113 SIZE 50, 19 PIXEL	//"Sequ�ncia do Turno: "
				oCombo := TComboBox():New(012,009,{|u|if(PCount()>0,cCombo:=u,cCombo)},aSeqs,100,20,oDlgEscTela,,{|| At190dRfr(@oListBox,cCombo,aDias,aGrupos,cTipo)},,,,.T.,,,,,,,,,'cCombo')
				oExit := TButton():New( 12, 380, STR0109,oDlgEscTela,{|| oListBox:aARRAY := {}, oDlgEscTela:End() }, 35,10,,,.F.,.T.,.F.,,.F.,,,.F. )	//"Confirmar"
				oListBox := TWBrowse():New(030, 007, 415, 165,,{},,oDlgEscTela,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
				oListBox:addColumn(TCColumn():New(	aTitulos[1], &("{|| oListBox:aARRAY[oListBox:nAt,1] }"),,,,,39))
				oListBox:addColumn(TCColumn():New(	aTitulos[2], &("{|| oListBox:aARRAY[oListBox:nAt,2] }"),,,,,39))
				oListBox:addColumn(TCColumn():New(	aTitulos[3], &("{|| oListBox:aARRAY[oListBox:nAt,3] }"),,,,,39))
				oListBox:addColumn(TCColumn():New(	aTitulos[4], &("{|| oListBox:aARRAY[oListBox:nAt,4] }"),,,,,39))
				oListBox:addColumn(TCColumn():New(	aTitulos[5], &("{|| oListBox:aARRAY[oListBox:nAt,5] }"),,,,,39))
				oListBox:addColumn(TCColumn():New(	aTitulos[6], &("{|| oListBox:aARRAY[oListBox:nAt,6] }"),,,,,39))
				oListBox:addColumn(TCColumn():New(	aTitulos[7], &("{|| oListBox:aARRAY[oListBox:nAt,7] }"),,,,,39))
				If cTipo $ "SEQ|LGY_SEQ"
					oListBox:addColumn(TCColumn():New(	aTitulos[8], &("{|| oListBox:aARRAY[oListBox:nAt,8] }"),,,,,39))
					oListBox:addColumn(TCColumn():New(	aTitulos[9], &("{|| oListBox:aARRAY[oListBox:nAt,9] }"),,,,,39))
					oListBox:addColumn(TCColumn():New(	aTitulos[10], &("{|| oListBox:aARRAY[oListBox:nAt,10] }"),,,,,39))
				EndIf
				oListBox:SetArray(aDados)
				oListBox:Refresh()

				ACTIVATE MSDIALOG oDlgEscTela CENTERED
				If cTipo $ "SEQ|LGY_SEQ"
					cRetF3  := RIGHT(cCombo,2)
				Else
					cRetF3  := VAL(SUBSTR(cCombo, LEN("Grupo: ")))
				EndIf
			EndIf
			lRet := .T.
		Else
			If cTipo $ "TGY_GRUPO|LGY_GRUPO"
				lRet := .T.
				cRetF3 := 1
				Help( " ", 1, "NOREGS", Nil, STR0114, 1 )	//"Nenhum atendente configurado para estas op��es. O valor '1' ser� utilizado automaticamente"
			Else
				Help( " ", 1, "NOREGS", Nil, STR0115, 1 )	//"Nenhum registro localizado. Verifique o cadastro de Tabelas de Hor�rio"
			EndIf
		EndIf
	EndIf

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} At190dRF3()

Retorno da consulta especifica

@author boiani
@since 30/05/2019
/*/
//------------------------------------------------------------------
Function At190dRF3(nVarRet)
	Local cRet
	Default nVarRet := 1
	If nVarRet == 1
		cRet := cRetF3
	ElseIf nVarRet == 2
		cRet := cRetF3_2
	EndIf
Return cRet
//-------------------------------------------------------------------
/*/{Protheus.doc} HasABR()

Verifica se uma determina ABB possui uma ABR

@author boiani
@since 30/05/2019
/*/
//------------------------------------------------------------------
Static Function HasABR(cCodABB, cFilAg)
	Local lRet := .F.
	Local cQry := GetNextAlias()
	Local cXfilAbb
	Default cFilAg := cFilAnt

	cXfilAbb := xFilial("ABB",cFilAg)

	If !Empty(cCodABB)
		BeginSQL Alias cQry
		SELECT 1 REC
		  FROM %Table:ABR% ABR
		 WHERE ABR.ABR_FILIAL = %Exp:cXfilAbb%
		   AND ABR.%NotDel%
		   AND ABR.ABR_AGENDA = %Exp:cCodABB%
		EndSQL

		lRet := (cQry)->(!Eof())
		(cQry)->(DbCloseArea())
	EndIf

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} BuscUltAlc()

Chama a fun��o BscUltAlc2 dentro de um MsgRun

@author boiani
@since 30/05/2019
/*/
//------------------------------------------------------------------
Static Function BuscUltAlc()
	Local lRet

	FwMsgRun(Nil,{|| lRet := BscUltAlc2()}, Nil, STR0116)	//"Localizando...."

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} BscUltAlc2()

Busca e preenche os dados da �ltima TGY de um atendente

@author boiani
@since 30/05/2019
/*/
//------------------------------------------------------------------
Static Function BscUltAlc2()
	Local oModel := FwModelActive()
	Local oView := FwViewActive()
	Local oMdlAA1 := oModel:GetModel("AA1MASTER")
	Local oMdlTGY := oModel:GetModel("TGYMASTER")
	Local oMdlDTA := oModel:GetModel("DTAMASTER")
	Local cAtend := oMdlAA1:GetValue("AA1_CODTEC")
	Local cQry := GetNextAlias()
	Local lAchou := .F.
	Local cContrt := SPACE(TamSX3("TFJ_CONTRT")[1])
	Local cLoc := SPACE(TamSX3("TFL_CODIGO")[1])
	Local cTFF := SPACE(TamSX3("TFF_COD")[1])
	Local cEscala := SPACE(TamSX3("TFF_ESCALA")[1])
	Local cTpAlo := SPACE(TamSX3("TGY_TIPALO")[1])
	Local cSeq := SPACE(TamSX3("TGY_SEQ")[1])
	Local nGroup := 0
	Local dUltAl := CTOD("")
	Local lRet := .T.
	Local nRecno := 0
	Local cCpoGSGEHOR := ""
	Local nC := 0
	Local aCpos :={}
	Local lMV_GSGEHOR := TecXHasEdH()
	Local cEntra := ""
	Local cSaida := ""
	Local cSql := ""
	Local cFilTGY
	Local lMV_MultFil := TecMultFil() //Indica se a Mesa considera multiplas filiais

	If lMV_GSGEHOR
		For nC := 1 to 4
			cCpoGSGEHOR += " , TGY.TGY_ENTRA"+Str(nC, 1)+ ", TGY.TGY_SAIDA"+Str(nC, 1) + " "
		Next
	EndIf

	If !EMPTY(cAtend)
		cSql += " SELECT TFJ.TFJ_CONTRT, TFL.TFL_CODIGO, TFF.TFF_COD, TFF.TFF_ESCALA, "
		cSql += " TGY.TGY_TIPALO, TGY.TGY_SEQ, TGY.TGY_GRUPO, TGY.TGY_ULTALO, "
		cSql += " TGY.R_E_C_N_O_, TFF.TFF_FILIAL, TGY.TGY_FILIAL "
		cSql += cCpoGSGEHOR
		cSql += " FROM " + RetSqlName( "TGY" ) + " TGY "
		cSql += " JOIN " + RetSqlName( "TFF" ) + " TFF ON "
		If !lMV_MultFil
			cSql += " TFF.TFF_FILIAL = '" + xFilial("TFF") + "' AND "
		Else
			cSql += " " + FWJoinFilial("TGY" , "TFF" , "TGY", "TFF", .T.) + " AND "
		EndIf
		cSql += " TFF.D_E_L_E_T_ = ' ' "
		cSql += " AND TFF.TFF_COD = TGY.TGY_CODTFF
		cSql += " JOIN " + RetSqlName( "TFL" ) + " TFL ON "
		If !lMV_MultFil
			cSql += " TFL.TFL_FILIAL = '" + xFilial("TFL") + "' AND "
		Else
			cSql += " " + FWJoinFilial("TFL" , "TFF" , "TFL", "TFF", .T.) + " AND
		EndIf
		cSql += " TFL.D_E_L_E_T_ = ' ' "
		cSql += " AND TFL.TFL_CODIGO = TFF.TFF_CODPAI
		cSql += " JOIN " + RetSqlName( "TFJ" ) + " TFJ ON "
		If !lMV_MultFil
			cSql += " TFJ.TFJ_FILIAL = '" + xFilial("TFJ") + "' AND "
		Else
			cSql += " " + FWJoinFilial("TFJ" , "TFL" , "TFJ", "TFL", .T.) + " AND "
		EndIf
		cSql += " TFJ.D_E_L_E_T_ = ' ' "
		cSql += " AND TFJ.TFJ_CODIGO = TFL.TFL_CODPAI "
		cSql += " AND TFJ.TFJ_STATUS = '1' "
		cSql += " WHERE "
		If !lMV_MultFil
			cSql += " TGY.TGY_FILIAL = '" + xFilial("TGY") + "' AND "
		EndIf
		cSql += " TGY.D_E_L_E_T_ = ' ' "
		cSql += " AND TGY.TGY_ATEND = '" + cAtend + "' "
		cSql += " ORDER BY TGY.TGY_ULTALO DESC "

		cSql := ChangeQuery(cSql)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSql),cQry, .F., .T.)

		If !((cQry)->(EOF()))
			While Empty((cQry)->(TGY_ULTALO)) .AND. !((cQry)->(EOF()))
				(cQry)->(DbSkip())
			End
			If !((cQry)->(EOF()))
				cContrt := (cQry)->(TFJ_CONTRT)
				cLoc := (cQry)->(TFL_CODIGO)
				cTFF := (cQry)->(TFF_COD)
				cEscala := (cQry)->(TFF_ESCALA)
				cTpAlo := (cQry)->(TGY_TIPALO)
				cSeq := (cQry)->(TGY_SEQ)
				nGroup := (cQry)->(TGY_GRUPO)
				dUltAl := STOD((cQry)->(TGY_ULTALO))
				nRecno := (cQry)->(R_E_C_N_O_)
				cFilTGY := IIF(LEN(Rtrim((cQry)->TGY_FILIAL)) == LEN(RTrim(cFilAnt)),;
					(cQry)->TGY_FILIAL,;
					(cQry)->TFF_FILIAL)
				If lMV_GSGEHOR
					aCpos :=  {{"", ""}, {"", ""}, {"", ""}, {"", ""}}
					For nC := 1 to 4
						cEntra := (cQry)->(&("TGY_ENTRA"+Str(nC, 1)))
						cSaida := (cQry)->(&("TGY_SAIDA"+Str(nC, 1)))
						aCpos[nC,01] := cEntra
						aCpos[nC,02] := cSaida
					Next
				EndIf
				lAchou := .T.
			EndIf
		EndIf
		(cQry)->(DbCloseArea())
		If lMV_MultFil
			lRet := lRet .AND. oMdlTGY:SetValue("TGY_FILIAL",cFilTGY)
		EndIf
		lRet := lRet .AND. oMdlTGY:SetValue("TGY_CONTRT",cContrt)
		If lAchou
			lRet := lRet .AND. oMdlTGY:SetValue("TGY_CODTFL",cLoc)
			lRet := lRet .AND. oMdlTGY:SetValue("TGY_TFFCOD",cTFF)
			lRet := lRet .AND. oMdlTGY:LoadValue("TGY_ESCALA",cEscala)
			lRet := lRet .AND. oMdlTGY:SetValue("TGY_TIPALO",cTpAlo)
			lRet := lRet .AND. oMdlTGY:SetValue("TGY_SEQ",cSeq)
			lRet := lRet .AND. oMdlTGY:SetValue("TGY_GRUPO",nGroup)
			lRet := lRet .AND. oMdlTGY:LoadValue("TGY_ULTALO",dUltAl)
			If !EMPTY(dUltAl) .AND. (EMPTY(oMdlDTA:GetValue("DTA_DTINI")) .OR. oMdlDTA:GetValue("DTA_DTINI") < dUltAl) .AND.;
					!isInCallStack("gravaaloc2")
				lRet := lRet .AND. oMdlDTA:LoadValue("DTA_DTINI",dUltAl + 1)
			EndIf
		Else
			Help( " ", 1, "BscUltAlc2", Nil, STR0320, 1 )	//"N�o foi poss�vel encontrar a �ltima aloca��o."
		EndIf
		lRet := lRet .AND. oMdlTGY:LoadValue("TGY_RECNO",nRecno)
		If lMV_GSGEHOR
			For nC := 1 to Len(aCpos)
				lRet := lRet .and. oMdlTGY:LoadValue("TGY_ENTRA"+Str(nC, 1),aCpos[nC,01])
				lRet := lRet .and. oMdlTGY:LoadValue("TGY_SAIDA"+Str(nC, 1),aCpos[nC,02])
			Next nC
		EndIf
		If lAchou .AND. lRet
			WhensTGY(.T.,{"TGY_CODTFL", "TGY_TFFCOD", "TGY_TIPALO", "TGY_SEQ", "TGY_GRUPO"},.F.)
		ElseIf oModel:HasErrorMessage() .AND. !(lRet) .AND. lAchou
			AtErroMvc( oModel )
			If !IsBlind()
				MostraErro()
			EndIf
		EndIf
		If !IsBlind()
			oView:Refresh()
		EndIf
	Else
		Help( " ", 1, STR0117, Nil, STR0118, 1 )	//"Cod.Atend."	# "C�digo do atendente n�o preenchido. Por favor, preencha o c�digo do atendente"
	EndIf

Return (lRet .AND. lAchou)
//-------------------------------------------------------------------
/*/{Protheus.doc} At190DClr()

Limpa as informa��es na aba de Aloca��es

@author boiani
@since 30/05/2019
/*/
//------------------------------------------------------------------
Function At190DClr(cFldsNot, cField)
	Local oModel := FwModelActive()
	Local oView := FwViewActive()
	Local oMdlTGY := oModel:GetModel("TGYMASTER")
	Local oMdlALC := oModel:GetModel("ALCDETAIL")
	Local oMdlAA1 := oModel:GetModel("AA1MASTER")
	Local oMdlDTA := NIL
	Local oStrDTA := NIl
	Local cEscala
	Local nC := 0
	Local aHorarios := {}
	Local lPrHora	:= TecABBPRHR()

	Default cFldsNot := ""
	Default cField := ""

	WhensTGY( .F. ,{"TGY_CODTFL", "TGY_TFFCOD", "TGY_ESCALA", "TGY_TIPALO", "TGY_SEQ", "TGY_GRUPO"}, .F. )

	If Empty(oMdlAA1:GetValue("AA1_CODTEC"))
		oMdlTGY:LoadValue("TGY_CONTRT",SPACE(1))
		WhensTGY( .F. ,{"TGY_FILIAL","TGY_CONTRT","TGY_CODTFL", "TGY_TFFCOD", "TGY_ESCALA", "TGY_TIPALO", "TGY_SEQ", "TGY_GRUPO"}, .F. )
	Else
		WhensTGY(.T., {"TGY_FILIAL"}, .F.)
		If !EMPTY(oMdlTGY:GetValue("TGY_FILIAL"))
			WhensTGY(.T., {"TGY_CONTRT"}, .F.)
		Else
			WhensTGY(.F., {"TGY_CONTRT"}, .F.)
		EndIf
	EndIf


	If !("TGY_CONTRT" $ cFldsNot)
		oMdlTGY:LoadValue("TGY_CONTRT",SPACE(1))
	ElseIf !EMPTY(oMdlTGY:GetValue("TGY_CONTRT"))
		WhensTGY(.T., {"TGY_CONTRT","TGY_CODTFL"}, .F.)
	EndIf

	If !("TGY_CODTFL" $ cFldsNot)
		oMdlTGY:LoadValue("TGY_CODTFL",SPACE(1))
	ElseIf !EMPTY(oMdlTGY:GetValue("TGY_CODTFL"))
		WhensTGY(.T., {"TGY_CONTRT","TGY_CODTFL","TGY_TFFCOD"}, .F.)
	EndIf

	If !("TGY_TFFCOD" $ cFldsNot)
		oMdlTGY:LoadValue("TGY_TFFCOD",SPACE(1))
	ElseIf !EMPTY(oMdlTGY:GetValue("TGY_TFFCOD"))
		If lPrHora .AND.;
				Empty(POSICIONE("TFF",1,xFilial("TFF",oMdlTGY:GetValue("TGY_FILIAL"))+oMdlTGY:GetValue("TGY_TFFCOD"),"TFF_ESCALA")) .AND. !Empty(POSICIONE("TFF",1,xFilial("TFF",oMdlTGY:GetValue("TGY_FILIAL"))+oMdlTGY:GetValue("TGY_TFFCOD"),"TFF_QTDHRS"))
			WhensTGY(.T., {"TGY_CONTRT","TGY_CODTFL","TGY_TFFCOD","TGY_TIPALO" }, .T., .F.)
			oMdlTGY:LoadValue("TGY_TFFHRS", POSICIONE("TFF",1,xFilial("TFF",oMdlTGY:GetValue("TGY_FILIAL"))+oMdlTGY:GetValue("TGY_TFFCOD"),"TFF_HRSSAL"))
		Else
			If lPrHora
				oMdlTGY:LoadValue("TGY_TFFHRS",SPACE(1))
			EndIf
			WhensTGY(.T., {"TGY_CONTRT","TGY_CODTFL","TGY_TFFCOD","TGY_ESCALA","TGY_TIPALO","TGY_SEQ","TGY_GRUPO"}, .F., .T.)
		EndIf
	EndIf

	If !("TGY_ESCALA" $ cFldsNot)
		oMdlTGY:LoadValue("TGY_ESCALA",SPACE(1))
	EndIf

	If lPrHora
		If !("TGY_TFFHRS" $ cFldsNot)
			oMdlTGY:LoadValue("TGY_TFFHRS", "")
		EndIf
	EndIf
	If !("TGY_TIPALO" $ cFldsNot)
		oMdlTGY:LoadValue("TGY_TIPALO",SPACE(1))
	EndIf

	If !("TGY_SEQ" $ cFldsNot)
		oMdlTGY:LoadValue("TGY_SEQ",SPACE(1))
	EndIf

	If !("TGY_GRUPO" $ cFldsNot)
		oMdlTGY:LoadValue("TGY_GRUPO",0)
	EndIf

	If !("TGY_ULTALO" $ cFldsNot)
		oMdlTGY:LoadValue("TGY_ULTALO",CTOD(""))
	EndIf

	If !("TGY_DESMOV" $ cFldsNot)
		oMdlTGY:LoadValue("TGY_DESMOV",SPACE(1))
	EndIf

	If !("TGY_RECNO" $ cFldsNot)
		oMdlTGY:LoadValue("TGY_RECNO",0)
	EndIf

	If !("TGY_ENTRA" $ cFldsNot) .AND.  !("TGY_SAIDA" $ cFldsNot)
		For nC := 1 to 4
			oMdlTGY:LoadValue("TGY_ENTRA"+Str(nC,1),SPACE(1))
			oMdlTGY:LoadValue("TGY_SAIDA"+Str(nC,1),SPACE(1))
		Next nC
	EndIf

	aValALC := {}
	oMdlALC:ClearData()
	oMdlALC:InitLine()

	If cField == "TGY_TFFCOD"
		If !EMPTY((cEscala := POSICIONE("TFF",1,xFilial("TFF",oMdlTGY:GetValue("TGY_FILIAL"))+oMdlTGY:GetValue("TGY_TFFCOD"),"TFF_ESCALA")))
			oMdlTGY:LoadValue("TGY_ESCALA", cEscala)
			WhensTGY( .F. ,{"TGY_ESCALA"}, .F. )
			//Verifica se existe o hor�rios cadastrados
			aHorarios := GetHorTGY(oMdlTGY,oMdlAA1:GetValue("AA1_CODTEC") )
			For nC := 1 to Len(aHorarios)
				oMdlTGY:LoadValue("TGY_ENTRA"+Str(nC,1),aHorarios[nC, 01])
				oMdlTGY:LoadValue("TGY_SAIDA"+Str(nC,1),aHorarios[nC, 02])
			Next nC
		EndIf
	EndIf

	If !ISBlind() .AND. !IsInCallStack("AT190GCmt")
		oView:Refresh('VIEW_TGY')
		oView:Refresh('DETAIL_ALC')
	Endif

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} GravaAloc()

Chama a fun��o de Grava��o da agenda dentro de um MsgRun

@author boiani
@since 15/07/2019
/*/
//------------------------------------------------------------------
Static Function GravaAloc()
	If At680Perm(NIL, __cUserId, "040", .T.)
		FwMsgRun(Nil,{|| GravaAloc2()}, Nil, STR0119)	//"Inserindo agenda..."
	Else
		Help(,1,"GravaAloc",,STR0474, 1) //"Usu�rio sem permiss�o de gravar agenda projetada"
	EndIf
Return
//-------------------------------------------------------------------
/*/{Protheus.doc} ProjAloc()

Chama a fun��o de Proje��o da agenda dentro de um MsgRun

@author boiani
@since 30/05/2019
/*/
//------------------------------------------------------------------
Static Function ProjAloc()
	If At680Perm(NIL, __cUserId, "039", .T.)
		FwMsgRun(Nil,{|| ProjAloc2()}, Nil, STR0120)	//"Projetando agenda..."
	Else
		Help(,1,"ProjAloc",,STR0475, 1)//"Usu�rio sem permiss�o de projetar agenda"
	EndIf
Return
//-------------------------------------------------------------------
/*/{Protheus.doc} ProjAloc2()

Fun��o de proje��o da aloca��o do atendente

@author boiani
@since 30/05/2019
/*/
//------------------------------------------------------------------
Static Function ProjAloc2(lAuto)
	Local oModel 		:= FwModelActive()
	Local oView 		:= FwViewActive()
	Local oMdlTGY 		:= oModel:GetModel("TGYMASTER")
	Local oMdlDTA 		:= oModel:GetModel("DTAMASTER")
	Local oMdlAA1 		:= oModel:GetModel("AA1MASTER")
	Local oMdlALC 		:= oModel:GetModel("ALCDETAIL")
	Local oMdl580e
	Local oMdlAux1
	Local oMdlAux2
	Local aAux
	Local aAteAgeSt
	Local aXRet 		:= {}
	Local aAteEfe 		:= {}
	Local aHorarios 	:= {}
	Local aHorMdl 		:= {} //Horarios do Model
	Local aPeriodo		:= {}
	Local aResTec		:= {}
	Local aRestrTW2		:= {}
	Local aAuxDT
	Local nPos
	Local nLastPos 		:= 0
	Local nHrIni 		:= 0
	Local nGrupo 		:= oMdlTGY:GetValue("TGY_GRUPO")
	Local nHrFim 		:= 0
	Local nHrIniAge 	:= 0
	Local nHrFimAge 	:= 0
	Local nRecno 		:= 0
	Local nC 			:= 0
	Local nI 			:= 0
	Local nX 			:= 0
	Local nY 			:= 0
	Local nR 			:= 0
	Local nLinha 		:= 1
	Local nPosdIni
	Local nPosdFim
	Local nPosHrIni
	Local nPosHrFim
	Local lProcessa 	:= .T.
	Local lAtuTGY 		:= .T.
	Local lOk 			:= .T.
	Local lFound 		:= .F.
	Local lMV_GSGEHOR 	:= TecXHasEdH()
	Local lRestrRH 		:= .F.
	Local lBlqAgend		:= .F.
	Local lGerAgend		:= .T.
	Local lAgenFtr		:= .F.	//Indica se vai manter a agenda de reserva futura
	Local lInter		:= .F.
	Local lProje        := ExistBlock("At190dpro")
	Local lAviso		:= .T.
	Local lResTec		:= .F.
	Local lResRHTXB		:= TableInDic("TXB") //Restri��es de RH
	Local lGSVERHR 		:= SuperGetMV("MV_GSVERHR",,.F.)
	Local lMV_MultFil	:= TecMultFil() //Indica se a Mesa considera multiplas filiais
	Local lPrHora		:= TecABBPRHR() .AND. (!Empty(oMdlTGY:GetValue("TGY_TFFHRS")) .AND. Empty(oMdlTGY:GetValue("TGY_ESCALA")))
	Local cCodAtend 	:= oMdlAA1:GetValue("AA1_CODTEC")
	Local cCodFunc		:= oMdlAA1:GetValue("AA1_CDFUNC")
	Local cContra 		:= oMdlTGY:GetValue("TGY_CONTRT")
	Local cFunFil
	Local cCalend
	Local cEscala 		:= oMdlTGY:GetValue("TGY_ESCALA")
	Local cSeqIni 		:= oMdlTGY:GetValue("TGY_SEQ")
	Local cCodTDX
	Local cQry 			:= GetNextAlias()
	Local cTpAloc 		:= oMdlTGY:GetValue("TGY_TIPALO")
	Local cY_SEQ
	Local cY_GRUPO
	Local cMsgAvsCli	:= ""
	Local cMsgAvsLoc 	:= ""
	Local cMsgBlqCli	:= ""
	Local cMsgBlqLoc	:= ""
	Local cY_ATEND
	Local cY_CODTFF
	Local cY_ESCALA
	Local cY_CODTDX
	Local cY_ITEM
	Local cCodTFF 		:= oMdlTGY:GetValue("TGY_TFFCOD")
	Local cEXSABB 		:= ""
	Local cCodTFL 		:= oMdlTGY:GetValue("TGY_CODTFL")
	Local cLocal
	Local cChave		:= ""
	Local cFilTFF		:= ""
	Local cNotIdcFal	:= ""
	Local cHoraini		:= "     "
	Local cHoraFIm		:= "     "
	Local cTurno		:= ""
	Local cBkpFil		:= cFilAnt
	Local dDtIniPosto
	Local dDtFimPosto
	Local dDatIni 		:= oMdlDTA:GetValue("DTA_DTINI")
	Local dDatFim 		:= oMdlDTA:GetValue("DTA_DTFIM")
	Local dUltAloc
	Local dDtAlIni
	Local dDtAlFim
	Local dDtCnfFim
	Local dDtCnfIni
	Local dY_DTINI
	Local dY_DTFIM
	Local dMenorDt

	Default lAuto 		:= .F.

	If lMV_MultFil
		If cFilAnt != oMdlTGY:GetValue("TGY_FILIAL")
			cFilAnt := oMdlTGY:GetValue("TGY_FILIAL")
		EndIf
	EndIf

	cLocal := POSICIONE("TFL",1,xFilial("TFL") + cCodTFL,"TFL_LOCAL")
	dDtIniPosto := POSICIONE("TFF",1,xFilial("TFF")+cCodTFF,"TFF_PERINI")
	dDtFimPosto := POSICIONE("TFF",1,xFilial("TFF")+cCodTFF,"TFF_PERFIM")
	cTurno		:= POSICIONE("TFF",1,xFilial("TFF")+cCodTFF,"TFF_TURNO")

	If !lPrHora
		cCodTDX := GetTDX(cEscala, cSeqIni)
	EndIf

	oMdlALC:SetNoInsertLine(.F.)
	oMdlALC:SetNoDeleteLine(.F.)

	AT330ArsSt("",.T.)
	aValALC := {}
	aDels := {}

	If EMPTY(cCodAtend)
		Help( " ", 1, STR0117, Nil, STR0118, 1 )	//"Cod.Atend." # "C�digo do atendente n�o preenchido. Por favor, preencha o c�digo do atendente"
		lOk := .F.
	EndIf

	If lOk .AND. Posicione("TFF",1,xFilial("TFF")+cCodTFF,"TFF_ENCE") == '1'
		Help( " ", 1, "POSTOENC", Nil, STR0124, 1 )	//"Posto encerrado. N�o � poss�vel gerar novas agendas."
		lOk := .F.
	EndIf

	If lOk .And. !((FindFunction("U_PNMSESC") .And. FindFunction("U_PNMSCAL")) .OR. ( FindFunction( "TecExecPNM" ) .AND. TecExecPNM() ))
		Help( , , "PNMTABC01", Nil, STR0121, 1, 0,,,,,,{STR0378}) //"Funcionalidade de aloca��o de atendente integrada com o Gest�o de Escalas, n�o disponivel pois n�o esta com patch aplicado com as configura��es do RH (PNMTABC01) e o parametro 'MV_GSPNMTA' est� desabilitado." ## "Por favor, aplique o patch para as configura��es do RH (PNMTABC01) ou fa�a ativa��o do parametro 'MV_GSPNMTA' para utiliza��o."
		lOk := .F.
	EndIf

	If lOk .And. Posicione("AA1",1,xFilial("AA1")+cCodAtend,"AA1_ALOCA") == '2'
		Help( " ", 1, "AA1ALOCA", Nil, STR0347, 1 )	//"Atendente n�o est� dispon�vel para aloca��o, realize manuten��o no cadastro de Atendentes no campo AA1_ALOCA."
		lOk := .F.
	Endif

	If lPrHora .AND. lOk
		aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,"Salvar"},{.T.,"Cancelar"},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil}}
		FwExecView( STR0492, "VIEWDEF.TECA190G", MODEL_OPERATION_INSERT, /*oOwner*/, {||.T.}, /*bOk*/, 45, aButtons ) // "Aloca��o Por Hora"
		lOk := .F.
		At190DClr(, , .T.)
	EndIf

	If lOk .AND. ((Empty(cCodTFF) .OR. Empty(cEscala) .OR. Empty(nGrupo) .OR. Empty(dDatIni) .OR. Empty(dDAtFim) .OR. Empty(cSeqIni)))
		Help( " ", 1, "CPOSOBRIGAT", Nil, STR0122, 1 )	//"Os campos 'Posto', 'Escala', 'Sequ�ncia' ,'Grupo' e o Per�odo de Aloca��o s�o obrigat�rios para a proje��o da agenda"
		lOk := .F.
	EndIf

	If lOk .AND. dDatIni > dDAtFim
		Help( " ", 1, "DTMENOR", Nil, STR0123, 1 )	//"A data de in�cio deve ser menor ou igual a data de t�rmino."
		lOk := .F.
	EndIf

	If lOk .AND. (EMPTY(dDtIniPosto) .OR. EMPTY(dDtFimPosto))
		Help( " ", 1, "PERPOSTO", Nil, STR0125 + cCodTFF, 1 )	//"N�o foi poss�vel localizar o Per�odo Inicial (TFF_PERINI) ou o Per�odo Final (TFF_PERFIM) do posto "
		lOk := .F.
	EndIf

	If lOk .AND. (dDatIni < dDtIniPosto .OR. dDAtFim > dDtFimPosto)
		If !At680Perm( Nil, __cUserID, "015" )
			Help( " ", 1, "PERPOSTO", Nil, STR0126 + dToC(dDtIniPosto) + STR0207 + dToC(dDtFimPosto) + STR0127, 1 )	//"O per�odo de aloca��o estipulado no posto inicia-se em " # " e encerra-se em " # ". N�o � poss�vel projetar agenda fora deste per�odo."
			lOk := .F.
		ElseIf !(isInCallStack("GravaAloc2"))
			If lAuto
				lOk := .T.
			Else
				lOk := MsgYesNo(STR0126 + dToC(dDtIniPosto) + STR0207 + dToC(dDtFimPosto) + STR0128 + dToc(dDatIni) + " - " + dToc(dDAtFim) + ")")	//"O per�odo de aloca��o estipulado no posto inicia-se em " # " e encerra-se em " # ". Deseja prosseguir com a aloca��o? (per�odo selecionado: "
			EndIf
		EndIf
	EndIf

	If lProje
		lOk := lOk .AND. Execblock("At190dpro",.F.,.F.,{oModel})
	Endif

	If lOk
		If !Empty(cCodFunc) .AND. SuperGetMV("MV_GSXINT",,"2") == "2"

			cFunFil := Posicione("AA1",1,xFilial("AA1")+cCodAtend,"AA1_FUNFIL")

			DbSelectArea("SRA")
			SRA->(DbSetOrder(1))
			If SRA->(DbSeek(cFunFil+cCodFunc))
				If SRA->RA_TPCONTR == "3"
					aPeriodo := Tec190QPer(cCodFunc, cCodAtend, dDatIni, dDatFim, cFunFil)
					If !Empty(aPeriodo)
						lInter	:= .T.
					Else
						Help(NIL, NIL, "Tec190QPer", NIL, STR0340 + dToC(dDatIni) + STR0295 + dToC(dDatFim) , 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0341}) // "N�o � possivel fazer aloca��o do funcionario, pois, o mesmo � do tipo intermitente e n�o possui convoca��o para o periodo de aloca��o selecionado: " ## at� ## "Por favor fa�a uma convoca��o ou selecione um periodo valido."
						lOk := .F.
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

	If lOk
		//Verifica as restri��es TW2
		aRestrTW2 := TxRestrTW2(cCodAtend,dDatIni,dDatFim,cLocal)

		//Se existir monta as mensagens.
		For nX := 1 to Len(aRestrTW2)
			If aRestrTW2[nx,4] == "1" //Aviso
				If aRestrTW2[nx,5] == "1" //Cliente
					If Empty(cMsgAvsCli)
						cMsgAvsCli := STR0328+CRLF+CRLF //"Existem restri��es de aviso para o cliente no(s) per�odo(s): "
					Endif
					cMsgAvsCli += dToc(aRestrTW2[nx,2])+STR0339+dToc(aRestrTW2[nx,3])+CRLF //" � "
				Elseif aRestrTW2[nx,5] == "2" //Local de Atendimento
					If Empty(cMsgAvsLoc)
						cMsgAvsLoc := STR0329+CRLF+CRLF //"Existem restri��es de aviso para o local de atendimento no(s) per�odo(s): "
					Endif
					cMsgAvsLoc += dToc(aRestrTW2[nx,2])+STR0339+dToc(aRestrTW2[nx,3])+CRLF //" � "
				Endif
			ElseIf aRestrTW2[nx,4] == "2" //Bloqueio
				If aRestrTW2[nx,5] == "1" //Cliente
					If Empty(cMsgBlqCli)
						cMsgBlqCli := STR0330+CRLF+CRLF //"Existem restri��es de bloqueio para o cliente no(s) per�odo(s): "
					Endif
					cMsgBlqCli += dToc(aRestrTW2[nx,2])+STR0339+dToc(aRestrTW2[nx,3])+CRLF //" � "
				Elseif aRestrTW2[nx,5] == "2" //Local de Atendimento
					If Empty(cMsgBlqLoc)
						cMsgBlqLoc := STR0331+CRLF+CRLF //"Existem restri��es de bloqueio para o local de atendimento no(s) per�odo(s): "
					Endif
					cMsgBlqLoc += dToc(aRestrTW2[nx,2])+STR0339+dToc(aRestrTW2[nx,3])+CRLF //" � "
				Endif
			Endif
		Next nX
	Endif

//Se estiver preenchido mostra o aviso de restri��o
	If !Empty(cMsgAvsCli) .Or. !Empty(cMsgAvsLoc)
		If !lAuto
			Aviso(STR0332, STR0333+CRLF+CRLF+cMsgAvsCli+CRLF+cMsgAvsLoc, { STR0334 }, 2) //"Restri��es de Aviso."#"As agendas ser�o geradas normalmente para o(s) per�odo(s) abaixo: "#"Fechar"
		EndIf
	Endif

//Se estiver preenchido mostra o aviso de bloqueio
	If !Empty(cMsgBlqCli) .Or. !Empty(cMsgBlqLoc)
		If !lAuto
			lBlqAgend := (Aviso(STR0335, STR0336+CRLF+CRLF+cMsgBlqCli+CRLF+cMsgBlqLoc, { STR0337, STR0338 }, 2)) == 1 //"Restri��es de Bloqueio."#"N�o ser�o geradas as agendas no(s) per�odo(s) abaixo: "#"Confirmar"#"Cancelar"
		EndIf
		If !lBlqAgend
			lOk := .F.
		Endif
	Endif

//Caso haja mais de uma reserva tecnica no local, n�o permite o prosseguimento da rotina
	If oModel:GetId() == "TECA190D"
		lAgenFtr := At190dTCU(cTpAloc) //Verifica se vai apagar as agendas de reserva futura
		aResTec := getResTec(cCodAtend,dToS(dDatIni),If(lAgenFtr,dToS(dDatFim),"") )
		If Len(aResTec) > 1
			Help( " ", 1, "MAIS1RES", Nil, STR0377, 1 ) //"Encontrado no Per�odo de Aloca��o mais de um item de RH com Reserva T�cnica. Exclua todas as agendas de reserva t�cnica dos itens ou diminua o per�odo de aloca��o para englobar somente um item de RH "
			lOK := .F.
		EndIf
	EndIf

	If lOk
		If oMdlTGY:VldData()
			lOk := AjustaTGY()
			dUltAloc := oMdlTGY:GetValue("TGY_ULTALO")
			If lOk
				If Len(aResTec) > 0
					If At190DIsRT(cTpAloc) //Se for aloca��o da reserva, valida o codigo da TFF
						cChave := oMdlTGY:GetValue("TGY_TFFCOD")
						cFilTFF	:=  xFilial("TFF")
					EndIf
					For nI := 1 to Len(aResTec)
						If cChave <> aResTec[nI][03] .OR. cFilTFF <> aResTec[nI][04]
							aEval(aResTec[nI][02], { |l| aAdd(aDels, aClone(l))})
						EndIf
					Next nI
					lResTec := .T.
				EndIf

				cCalend := POSICIONE("TFF",1,xFilial("TFF")+cCodTFF,"TFF_CALEND")

				//Busca a TGY do model
				aHorarios := GetHorEdt(lMV_GSGEHOR, oMdlTGY, .F., ""/*cEscala*/, ""/**cCodTFF"*/)
				aEval(aHorarios, {|h|, Aadd(aHorMdl, { h[01, 02], h[02, 02]}) })
				aAux := At330AAtend( cCodTFF, cEscala, dDatIni, dDatFim, cCodAtend, cContra )
				If Empty(aAux)
					BeginSQL Alias cQry
					SELECT TGY.R_E_C_N_O_
					  FROM %Table:TGY% TGY
					 WHERE TGY.TGY_FILIAL = %xFilial:TGY%
					   AND TGY.%NotDel%
					   AND TGY.TGY_ATEND = %Exp:cCodAtend%
					   AND TGY.TGY_CODTFF = %Exp:cCodTFF%
					   AND TGY.TGY_ESCALA = %Exp:cEscala%
					   AND ( TGY.TGY_DTFIM <  %Exp:DTOS(dDatIni)%
					   OR  TGY.TGY_DTINI > %Exp:DTOS(dDatFim)% )
					EndSQL

					If !(cQry)->(EOF())
						nRecno := (cQry)->(R_E_C_N_O_)
						oMdlTGY:LoadValue("TGY_RECNO", nRecno)
						TGY->(DBGoTo(nRecno))

						cY_SEQ   	:= TGY->TGY_SEQ
						cY_GRUPO 	:= TGY->TGY_GRUPO
						dY_DTINI 	:= TGY->TGY_DTINI
						dY_DTFIM 	:= TGY->TGY_DTFIM
						cY_ATEND 	:= TGY->TGY_ATEND
						cY_CODTFF 	:= TGY->TGY_CODTFF
						cY_ESCALA 	:= TGY->TGY_ESCALA
						cY_CODTDX 	:= TGY->TGY_CODTDX
						cY_ITEM 	:= TGY->TGY_ITEM

						TFF->(DbSetOrder(1))
						If TFF->(DBSeek(xFilial("TFF") + cY_CODTFF))
							oMdl580e := FwLoadModel("TECA580E")
							oMdl580e:SetOperation(MODEL_OPERATION_UPDATE)
							lAtuTGY := oMdl580e:Activate()
							oMdlAux1 := oMdl580e:GetModel("TDXDETAIL")
							oMdlAux2 := oMdl580e:GetModel("TGYDETAIL")
							For nX := 1 to oMdlAux1:Length()
								oMdlAux1:GoLine(nX)
								For nY := 1 To oMdlAux2:Length()
									oMdlAux2:GoLine(nY)
									If oMdlAux2:GetValue("TGY_ATEND") == cY_ATEND .AND. oMdlAux2:GetValue("TGY_ESCALA") == cY_ESCALA .AND.;
											oMdlAux2:GetValue("TGY_CODTDX") == cY_CODTDX .AND. oMdlAux2:GetValue("TGY_ITEM") == cY_ITEM
										lAtuTGY := lAtuTGY .AND. oMdlAux2:SetValue("TGY_SEQ"  , cSeqIni)
										lAtuTGY := lAtuTGY .AND. oMdlAux2:SetValue("TGY_GRUPO", nGrupo)
										lAtuTGY := lAtuTGY .AND. oMdlAux2:SetValue("TGY_DTINI", dDatIni)
										If dY_DTFIM < dDatIni
											lAtuTGY := lAtuTGY .AND. oMdlAux2:SetValue("TGY_DTFIM", dDatFim)
										EndIf
										If (lAtuTGY := lAtuTGY .AND. oMdl580e:VldData() .And. oMdl580e:CommitData())
											oMdl580e:DeActivate()
											oMdl580e:Destroy()
										ElseIf oMdl580e:HasErrorMessage()
											AtErroMvc( oMdl580e )
											If !IsBlind()
												MostraErro()
											EndIf
										EndIf
										lFound := .T.
										Exit
									EndIf
								Next nY
								If lFound
									Exit
								EndIF
							Next nX
							If lMV_GSGEHOR .AND. Len(aHorarios) > 0
								TGY->(DBGoTo(nRecno))
								TGY->(RECLOCK("TGY", .F.))
								For nC := 1 to Len(aHorarios)
									TGY->(FieldPut(FieldPos(aHorarios[nC, 01, 01]), aHorarios[nC, 01, 02]) ) //TGY_ENTRA
									TGY->(FieldPut(FieldPos(aHorarios[nC, 02, 01]), aHorarios[nC, 02, 02]) ) //TGY_SAIDA
								Next nC
								TGY->(MSUNLOCK())
							EndIf
							FwModelActive(oModel)
						EndIf
					EndIf
					(cQry)->(DbCloseArea())
					aAux := At330AAtend( cCodTFF, cEscala, dDatIni, dDatFim, cCodAtend, cContra )
				EndIf
				If lAtuTGY
					aAteEfe := {{aAux[1][3],;
						cSeqIni,;
						cCodTDX,;
						{};
						}}

					If !lMV_GSGEHOR
						aAdd( aAteEfe[01,04], { nGrupo,;
							cCodAtend,;
							dDatIni,;
							dDatFim,;
							cSeqIni,;
							dUltAloc,;
							cTpAloc} )
					Else
						aAdd( aAteEfe[01,04], { nGrupo,;
							cCodAtend,;
							dDatIni,;
							dDatFim,;
							cSeqIni,;
							dUltAloc,;
							cTpAloc,;
							aHorMdl}  )		//aClone(aAux[1][16])
					EndIf

					aAteAgeSt := At330AAgAt( aAteEfe,{},dDatIni,dDAtFim,cEscala,cCalend,cCodTFF,/*cFilTFF*/,/*lGerConf*/,cCodAtend)

					nPosdIni := AScan(AT330ArsSt("aCfltHead"),{|e| e == 'DTINI'})
					nPosdFim := AScan(AT330ArsSt("aCfltHead"),{|e| e == 'DTFIM'})
					nPosHrIni := AScan(AT330ArsSt("aCfltHead"),{|e| e == 'HRINI'})
					nPosHrFim := AScan(AT330ArsSt("aCfltHead"),{|e| e == 'HRFIM'})

					FWModelActive(oModel)

					At330AVerABB( dDatIni, dDatFim, cCodTFF, xFilial("TFF"), cCodAtend, @cNotIdcFal )

					ChkCfltAlc(dDatIni, dDatFim, cCodAtend, /*cHoraIni*/, /*cHoraFim*/,;
						 /*lUsaStatic*/, /*aFieldsQry*/,/*aArrConfl*/, /*aArrDem*/,;
						 /*aArrAfast*/, /*aArrDFer*/, /*aArrDFer2*/, /*aArrDFer3*/,;
						cNotIdcFal )

					If lResRHTXB
						nPosTXBDtI:= AScan(AT330ArsSt("aCfltHead"),{|e| e == 'TXB_DTINI'})
						nPosTXBDtF:= AScan(AT330ArsSt("aCfltHead"),{|e| e == 'TXB_DTFIM'})
					Endif

					If oMdlALC:GetMaxLines() < LEN(aAteAgeSt)
						oMdlALC:SetMaxLine(LEN(aAteAgeSt))
					EndIf
					oMdlALC:ClearData()
					oMdlALC:InitLine()

					For nI := 1 To LEN(aAteAgeSt)

						lRestrRH := .F.
						cEXSABB := ""
						lGerAgend := .T.

						If Len(aXRet) > 0
							If Ascan(aXRet, {|x| x[2,9] == aAteAgeSt[nI,06] .And. x[2,5] == aAteAgeSt[nI,02] .And. x[2,7] == aAteAgeSt[nI,04] .And.  x[2,8] == aAteAgeSt[nI,05] .And. x[2,11] == aAteAgeSt[nI,08] }) > 0
								Loop
							EndIf
						EndIf

						If !lRestrRH .And. Len(AT330ArsSt("aDiasFer")) > 0
							nPos := Ascan(AT330ArsSt("aDiasFer"),{|x| Alltrim(x[1]) == Alltrim(aAteAgeSt[nI,06]) .AND.  aAteAgeSt[nI,2] >= x[2] .And. aAteAgeSt[nI,2] <= x[3]} )

							lRestrRH := nPos > 0
						EndIf

						If !lRestrRH .And. Len(AT330ArsSt("aDiasFer2")) > 0
							nPos := Ascan(AT330ArsSt("aDiasFer2"),{|x| Alltrim(x[1]) == Alltrim(aAteAgeSt[nI,06]) .AND.  aAteAgeSt[nI,2] >= x[2] .And. aAteAgeSt[nI,2] <= x[3]} )
							lRestrRH := nPos > 0
						EndIf

						If !lRestrRH .And. Len(AT330ArsSt("aDiasFer3")) > 0
							nPos := Ascan(AT330ArsSt("aDiasFer3"),{|x| Alltrim(x[1]) == Alltrim(aAteAgeSt[nI,06]) .AND.  aAteAgeSt[nI,2] >= x[2] .And. aAteAgeSt[nI,2] <= x[3] } )
							lRestrRH := nPos > 0
						EndIf

						If !lRestrRH .And. Len(AT330ArsSt("aDiasDem")) > 0
							nPos := Ascan(AT330ArsSt("aDiasDem"),{|x| Alltrim(x[1]) == Alltrim(aAteAgeSt[nI,06]) .AND. aAteAgeSt[nI,2] >= x[2] } )
							lRestrRH := nPos > 0
						EndIf

						If !lRestrRH .And. Len(AT330ArsSt("aDiasAfast")) > 0
							nPos := Ascan(AT330ArsSt("aDiasAfast"),{|x| Alltrim(x[1]) == Alltrim(aAteAgeSt[nI,06]) .AND.  aAteAgeSt[nI,2] >= x[2] .And. aAteAgeSt[nI,2] <= x[3] } )
							lRestrRH := nPos > 0
						EndIf

						If lResRHTXB .And. !lRestrRH .And. Len(AT330ArsSt("ACFLTATND")) > 0  .And. nPosTXBDtI > 0 .And. nPosTXBDtF > 0
							nPos := Ascan(AT330ArsSt("ACFLTATND"),{|x| Alltrim(x[2]) == Alltrim(aAteAgeSt[nI,06]) .And. !Empty(x[nPosTXBDtI]) .And. aAteAgeSt[nI,2] >= sTod(x[nPosTXBDtI]) .And. ( Empty(x[nPosTXBDtF]) .Or. aAteAgeSt[nI,2] <= sTod(x[nPosTXBDtF])) } )
							lRestrRH := nPos > 0
						Endif

						If !lRestrRH .And. Len(AT330ArsSt("ACFLTATND")) > 0
							nLastPos := 0
							nHrIniAge := VAL(AtJustNum(aAteAgeSt[nI,04]))
							nHrFimAge := VAL(AtJustNum(aAteAgeSt[nI,05]))
							lProcessa := .T.
							While lProcessa
								nLastPos++
								nPos := Ascan(AT330ArsSt("ACFLTATND"),{|x| Alltrim(x[2]) == Alltrim(aAteAgeSt[nI,06]) .And. (aAteAgeSt[nI,2] == x[nPosdIni] .Or.  aAteAgeSt[nI,2] == x[nPosdFim]) }, nLastPos )
								nLastPos := nPos
								If nPos > 0
									lRestrRH := .T.
									If lResTec
										For nR := 1 to Len(aResTec)
											If aScan(aResTec[nR][2], {|x| x[2] == dTos(aAteAgeSt[nI][16]) .Or. x[4] == dTos(aAteAgeSt[nI][16] ) } ) > 0
												cEXSABB := "2"
												Exit
											EndIf
										Next nR
									Else
										cEXSABB := "1"
									EndIf
									If ( Empty(aAteAgeSt[nI,10]) .OR. aAteAgeSt[nI,11] <> '1') .AND.;
											cEXSABB <> "2" .And. lRestrRH .And. lGSVERHR .And. (aAteAgeSt[nI,04] <> "FOLGA" .And. aAteAgeSt[nI,05] <> "FOLGA")

										nHrIni := VAL(AtJustNum(AT330ArsSt("ACFLTATND")[nPos,nPosHrIni]))
										nHrFim := VAL(AtJustNum(AT330ArsSt("ACFLTATND")[nPos,nPosHrFim]))
										dDtCnfIni := AT330ArsSt("ACFLTATND")[nPos,nPosdIni]
										dDtCnfFim := AT330ArsSt("ACFLTATND")[nPos,nPosdFim]
										dDtAlIni := aAteAgeSt[nI,2]
										dDtAlFim := aAteAgeSt[nI,2] + IIF(nHrIniAge >= nHrFimAge, 1,0)

										dMenorDt := CtoD("")
										aAuxDT := {dDtCnfIni,dDtCnfFim,dDtAlIni,dDtAlFim}
										For nC := 1 To LEN(aAuxDT)
											If EMPTY(dMenorDt) .OR. dMenorDt > aAuxDT[nC]
												dMenorDt := aAuxDT[nC]
											EndIf
										Next nC
										nHrIni += 2400 * (dDtCnfIni - dMenorDt)
										nHrFim += 2400 * (dDtCnfFim - dMenorDt)
										nHrIniAge += 2400 * (dDtAlIni - dMenorDt)
										nHrFimAge += 2400 * (dDtAlFim - dMenorDt)

										If nHrIniAge >= nHrIni .AND. nHrIniAge <= nHrFim
											lRestrRH := .T.
											cEXSABB := "1"
											lProcessa := .F.
										ElseIf nHrFimAge >= nHrIni .AND. nHrFimAge <= nHrFim
											lRestrRH := .T.
											cEXSABB := "1"
											lProcessa := .F.
										ElseIf nHrIniAge <= nHrIni .AND. nHrFimAge >= nHrFim
											lRestrRH := .T.
											cEXSABB := "1"
											lProcessa := .F.
										ElseIf nHrIniAge >= nHrIni .AND. nHrFimAge <= nHrFim
											lRestrRH := .T.
											cEXSABB := "1"
											lProcessa := .F.
										Else
											lRestrRH := .F.
											cEXSABB := "2"
										EndIf
									Else
										If (Upper(AllTrim(aAteAgeSt[nI,04])) == "FOLGA" .And. Upper(AllTrim(aAteAgeSt[nI,05])) == "FOLGA")
											lRestrRH := .F.
											cEXSABB := "2"
										EndIf
										lProcessa := .F.
									EndIf
								Else
									cEXSABB := "2"
									lProcessa := .F.
								EndIf
							End
						Else
							cEXSABB := "2"
						EndIf

						If lBlqAgend

							If Ascan(aRestrTW2,{|x| Alltrim(x[1]) == Alltrim(aAteAgeSt[nI,06]) .And.  aAteAgeSt[nI,16] >= x[2] .And. ( Empty(x[3]) .Or. aAteAgeSt[nI,16] <= x[3]) .And. x[4] == "2" } ) > 0
								lGerAgend := .F.
							Endif
						EndIf
						If lInter
							For nC := 1 To Len(aPeriodo)
								If Ascan(aPeriodo,{ |x| AllTrim(x[4]) == AllTrim(aAteAgeSt[nI,06]) .AND. x[2] <= aAteAgeSt[nI][2] .And.  aAteAgeSt[nI][2] <= x[3] } ) <= 0
									If lAviso
										Aviso(STR0187, STR0342, , 2) // "N�o sera gerada agenda para os dias que o atendente n�o possuir convoca��o. "
										lAviso := .F.
									EndIf
									lGerAgend := .F.
									Exit
								Endif
							Next nC
						EndIf
						If lGerAgend

							If !oMdlALC:IsEmpty()
								nLinha := oMdlALC:AddLine()
							EndIf

							oMdlALC:GoLine(nLinha)

							If Len(aResTec) > 0 .And. cEXSABB == "2"
								oMdlALC:LoadValue("ALC_SITABB", At330ACLgA( !Empty(aAteAgeSt[nI,10]), aAteAgeSt[nI,11], (aAteAgeSt[nI,19]=="1"), lRestrRH, .T. ))
							Else
								oMdlALC:LoadValue("ALC_SITABB", At330ACLgA( !Empty(aAteAgeSt[nI,10]), aAteAgeSt[nI,11], (aAteAgeSt[nI,19]=="1"), lRestrRH  ))
							EndIf

							oMdlALC:LoadValue("ALC_SITALO", At330ACLgS(aAteAgeSt[nI,8]))
							oMdlALC:LoadValue("ALC_GRUPO", 	aAteAgeSt[nI,01])
							oMdlALC:LoadValue("ALC_DATREF", aAteAgeSt[nI,16])
							oMdlALC:LoadValue("ALC_DATA", 	aAteAgeSt[nI,02])
							oMdlALC:LoadValue("ALC_SEMANA", aAteAgeSt[nI,03])
							oMdlALC:LoadValue("ALC_ENTRADA", aAteAgeSt[nI,04])
							oMdlALC:LoadValue("ALC_SAIDA", 	aAteAgeSt[nI,05])
							oMdlALC:LoadValue("ALC_TIPO",	aAteAgeSt[nI,08])
							oMdlALC:LoadValue("ALC_SEQ",	aAteAgeSt[nI,13])
							oMdlALC:LoadValue("ALC_EXSABB", cEXSABB)
							oMdlALC:LoadValue("ALC_KEYTGY",	aAteAgeSt[nI,17])
							oMdlALC:LoadValue("ALC_ITTGY",	aAteAgeSt[nI,18])
							oMdlALC:LoadValue("ALC_TURNO",	aAteAgeSt[nI,12])
							oMdlALC:LoadValue("ALC_ITEM", 	aAteAgeSt[nI,15])
							AADD(aValALC, {oMdlALC:GetValue("ALC_SITABB"),;
								oMdlALC:GetValue("ALC_SITALO"),;
								oMdlALC:GetValue("ALC_GRUPO"),;
								oMdlALC:GetValue("ALC_DATREF"),;
								oMdlALC:GetValue("ALC_DATA"),;
								oMdlALC:GetValue("ALC_SEMANA"),;
								oMdlALC:GetValue("ALC_ENTRADA"),;
								oMdlALC:GetValue("ALC_SAIDA"),;
								oMdlALC:GetValue("ALC_TIPO"),;
								oMdlALC:GetValue("ALC_SEQ"),;
								oMdlALC:GetValue("ALC_EXSABB"),;
								oMdlALC:GetValue("ALC_KEYTGY"),;
								oMdlALC:GetValue("ALC_ITTGY"),;
								oMdlALC:GetValue("ALC_TURNO"),;
								oMdlALC:GetValue("ALC_ITEM")})
						Endif

					Next nI
					If !IsBlind()
						oView:Refresh()
					EndIf
				EndIf
			Else
				Help(,,"NOPROJ",,STR0313,1,0) //"N�o foi poss�vel realizar a proje��o da agenda. Por favor, repita a opera��o no Gest�o de Escalas."
			EndIf
		Else
			AtErroMvc( oModel )
			If !IsBlind()
				MostraErro()
			EndIf
		Endif
	EndIf

	cFilAnt := cBkpFil

	oMdlALC:SetNoInsertLine(.T.)

Return lOk
//------------------------------------------------------------------------------
/*/{Protheus.doc} At190DLoad

@description Faz a carga dos dados no grid "LOCDETAIL"

@author	boiani
@since	29/05/2019
/*/
//------------------------------------------------------------------------------
Function AT190DLdLo(lRefresh)
	Local oView		:= FwViewActive()
	Local oModel := FwModelActive()
	Local oMdlLOC := oModel:GetModel('LOCDETAIL')
	Local oMdlTFL := oModel:GetModel('TFLMASTER')
	Local oMdlPRJ := oModel:GetModel('PRJMASTER')
	Local cSql := ""
	Local cAliasQry	:= ""
	Local dDataDe := oMdlPRJ:GetValue("PRJ_DTINI")
	Local dDataAte := oMdlPRJ:GetValue("PRJ_DTFIM")
	Local cCliente := oMdlTFL:GetValue("TFL_CODENT")
	Local cLoja := oMdlTFL:GetValue("TFL_LOJA")
	Local cContrt := oMdlTFL:GetValue("TFL_CONTRT")
	Local cLocal := oMdlTFL:GetValue("TFL_LOCAL")
	Local cProd := oMdlTFL:GetValue("TFL_PROD")
	Local cPosto := oMdlTFL:GetValue("TFL_TFFCOD")
	Local cFilBusca := oMdlTFL:GetValue("TFL_FILIAL")
	Local nLinha	:= 0
	Local cTipoMV	:= ""
	Local aFldPai	:= Nil  //Verifica se a aba Pai est� aberta
	Local aFolder	:= Nil   //Verifica se a aba filho est� aberta
	Local lContinua	:= .T.  //S� executa a rotina quando a aba Agendas Projetadas estiver ativa
	Local lPeAt190Lo := ExistBlock("AT19DLLo")
	Local aLinha	:= {}
	Local nC		:= 0
	Local lMV_MultFil := TecMultFil() //Indica se a Mesa considera multiplas filiais

	If !IsBlind()
		aFldPai := oView:GetFolderActive("TELA_ABAS", 2)
		aFolder := oView:GetFolderActive("ABAS_LOC", 2)
		lContinua := If(aFldPai[1] == 2 .And. aFolder[1] == 1,.T.,.F.)
	EndIf

	Default lRefresh := .T.

	If lContinua

		oMdlLOC:SetNoInsertLine(.F.)
		oMdlLOC:SetNoDeleteLine(.F.)

		oMdlLOC:ClearData()
		oMdlLOC:InitLine()

		cSql += " SELECT ABB.ABB_CODTEC, AA1.AA1_NOMTEC, ABB.ABB_DTINI, ABB.ABB_FILIAL, "
		cSql += " ABB.ABB_HRINI, ABB.ABB_HRFIM, TDV.TDV_DTREF, SB1.B1_DESC, "
		cSql += " ABS.ABS_DESCRI, ABS.ABS_LOCAL, ABB.ABB_TIPOMV, ABB.ABB_ATIVO, "
		cSql += " ABB.ABB_CODIGO , ABB.ABB_OBSERV , ABB.ABB_DTINI, ABB.ABB_DTFIM, "
		cSql += " ABB.ABB_ATENDE, TFF.TFF_COD, ABB.ABB_CHEGOU, ABB.ABB_IDCFAL, ABB.R_E_C_N_O_ RECNO "
		cSql += " FROM " + RetSqlName( "ABB" ) + " ABB INNER JOIN " + RetSqlName( "TDV" ) + " TDV ON "
		cSql += " TDV.D_E_L_E_T_ = ' ' AND "
		If !lMV_MultFil
			cSql += " TDV.TDV_FILIAL = '" + xFilial("TDV") + "' AND "
		Else
			cSql += " " + FWJoinFilial("ABB" , "TDV" , "ABB", "TDV", .T.) + " AND "
		EndIf
		cSql += " TDV.TDV_CODABB = ABB.ABB_CODIGO "
		cSql += " INNER JOIN " + RetSqlName( "ABQ" ) + " ABQ ON ABB.ABB_IDCFAL = ABQ.ABQ_CONTRT || ABQ.ABQ_ITEM || ABQ.ABQ_ORIGEM AND "
		If !lMV_MultFil
			cSql += " ABQ.ABQ_FILIAL = '" + xFilial("ABQ") + "' "
		Else
			cSql += " " + FWJoinFilial("ABB" , "ABQ" , "ABB", "ABQ", .T.) + " "
		Endif
		cSql += " AND ABQ.D_E_L_E_T_ = ' ' "
		cSql += " INNER JOIN " + RetSqlName( "SB1" ) + " SB1 ON SB1.B1_COD = ABQ.ABQ_PRODUT AND "
		If !lMV_MultFil
			cSql += " SB1.B1_FILIAL = '" + xFilial("SB1") + "' "
		Else
			cSql += " " + FWJoinFilial("SB1" , "ABQ" , "SB1", "ABQ", .T.) + " "
			cSql += " AND " + FWJoinFilial("SB1" , "ABB" , "SB1", "ABB", .T.) + " "
		EndIf
		cSql += " AND SB1.D_E_L_E_T_ = ' ' "
		cSql += " INNER JOIN " + RetSqlName( "ABS" ) + " ABS ON ABB.ABB_LOCAL = ABS.ABS_LOCAL AND "
		If !lMV_MultFil
			cSql += " ABS.ABS_FILIAL = '" + xFilial("ABS") + "' "
		Else
			cSql += " " + FWJoinFilial("ABS" , "ABB" , "ABS", "ABB", .T.) + " "
		EndIf
		cSql += " AND ABS.D_E_L_E_T_ = ' ' "
		If !EMPTY(cLocal)
			cSql += " AND ABS.ABS_LOCAL = '" + cLocal + "' "
		EndIf
		cSql += " INNER JOIN " + RetSqlName( "TFF" ) + " TFF ON TFF.TFF_COD = ABQ.ABQ_CODTFF AND TFF.TFF_FILIAL = ABQ.ABQ_FILTFF AND "
		If !lMV_MultFil
			cSql += " TFF.TFF_FILIAL = '" + xFilial("TFF") + "' "
		Else
			cSql += " " + FWJoinFilial("TFF" , "ABQ" , "TFF", "ABQ", .T.) + " "
		EndIf
		cSql += " AND TFF.D_E_L_E_T_ = ' ' "
		cSql += " INNER JOIN " + RetSqlName( "TFL" ) + " TFL ON TFL.TFL_CODIGO = TFF.TFF_CODPAI AND "
		If !lMV_MultFil
			cSql += " TFL.TFL_FILIAL = '" + xFilial("TFL") + "' "
		Else
			cSql += " " + FWJoinFilial("TFF" , "TFL" , "TFF", "TFL", .T.) + " "
		EndIf
		cSql += " AND TFL.D_E_L_E_T_ = ' ' "
		cSql += " AND ABS.ABS_LOCAL = TFL.TFL_LOCAL "
		cSql += " INNER JOIN " + RetSqlName( "TFJ" ) + " TFJ ON TFJ.TFJ_CODIGO = TFL.TFL_CODPAI AND "
		If !lMV_MultFil
			cSql += " TFJ.TFJ_FILIAL = '" + xFilial("TFJ") + "' "
		Else
			cSql += " " + FWJoinFilial("TFJ" , "TFL" , "TFJ", "TFL", .T.) + " "
		EndIf
		cSql += " AND TFJ.D_E_L_E_T_ = ' ' AND TFJ.TFJ_STATUS = '1' "
		cSql += " INNER JOIN " + RetSqlName( "AA1" ) + " AA1 ON AA1.AA1_CODTEC = ABB.ABB_CODTEC AND "
		If !lMV_MultFil
			cSql += " AA1.AA1_FILIAL = '" + xFilial("AA1") + "' "
		Else
			cSql += " " + FWJoinFilial("AA1" , "ABB" , "AA1", "ABB", .T.) + " "
		EndIf
		cSql += " AND AA1.D_E_L_E_T_ = ' ' "
		cSql += " WHERE ABB.D_E_L_E_T_ = ' ' "
		If !lMV_MultFil
			cSql += " AND ABB.ABB_FILIAL = '" + xFilial("ABB") + "' "
		EndIf
		If !EMPTY(dDataDe) .AND. !EMPTY(dDataAte)
			cSql += " AND TDV.TDV_DTREF >= '" + DTOS(dDataDe) + "' AND TDV.TDV_DTREF <= '" + DTOS(dDataAte) + "' "
		EndIf
		If !EMPTY(cCliente)
			cSql += " AND TFJ.TFJ_CODENT = '" + cCliente + "' "
		EndIf
		If !EMPTY(cLoja)
			cSql += " AND TFJ.TFJ_LOJA = '" + cLoja + "' "
		EndIf
		If !EMPTY(cContrt)
			cSql += " AND TFJ.TFJ_CONTRT = '" + cContrt + "' "
		EndIf
		If !EMPTY(cLocal)
			cSql += " AND ABQ.ABQ_LOCAL = '" + cLocal + "' "
		EndIf
		If !EMPTY(cProd)
			cSql += " AND TFF.TFF_PRODUT = '" + cProd + "' "
		EndIf
		If !EMPTY(cPosto)
			cSql += " AND TFF.TFF_COD = '" + cPosto + "' "
		EndIf
		If !EMPTY(cFilBusca) .AND. lMV_MultFil
			cSql += " AND ABB.ABB_FILIAL = '" + xFilial("ABB",cFilBusca) + "' "
			cSql += " AND TFJ.TFJ_FILIAL = '" + xFilial("TFJ",cFilBusca) + "' "
		EndIf
		cSql += " ORDER BY TDV.TDV_DTREF, ABB.ABB_CODTEC,ABB.ABB_DTINI, ABB.ABB_HRINI"

		cSql := ChangeQuery(cSql)
		cAliasQry := GetNextAlias()
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSql),cAliasQry, .F., .T.)
		While !(cAliasQry)->(EOF())
			If !oMdlLOC:IsEmpty()
				nLinha := oMdlLOC:AddLine()
			EndIf
			oMdlLOC:GoLine(nLinha)
			oMdlLOC:LoadValue("LOC_FILIAL", (cAliasQry)->(ABB_FILIAL))
			If lMV_MultFil
				oMdlLOC:LoadValue("LOC_DSCFIL", (cAliasQry)->(ABB_FILIAL) + " - " + Alltrim(FWFilialName(,(cAliasQry)->(ABB_FILIAL))))
			EndIf
			oMdlLOC:LoadValue("LOC_DTREF", STOD((cAliasQry)->(TDV_DTREF)))
			oMdlLOC:LoadValue("LOC_DOW", TECCdow(DOW(STOD((cAliasQry)->(TDV_DTREF)))))
			oMdlLOC:LoadValue("LOC_OBSERV", (cAliasQry)->(ABB_OBSERV))
			oMdlLOC:LoadValue("LOC_HRINI", (cAliasQry)->(ABB_HRINI))
			oMdlLOC:LoadValue("LOC_HRFIM", (cAliasQry)->(ABB_HRFIM))
			oMdlLOC:LoadValue("LOC_ABSDSC", (cAliasQry)->(ABS_DESCRI))
			oMdlLOC:LoadValue("LOC_B1DESC", (cAliasQry)->(B1_DESC))
			oMdlLOC:LoadValue("LOC_TIPOMV", (cAliasQry)->(ABB_TIPOMV))
			oMdlLOC:LoadValue("LOC_ATIVO", (cAliasQry)->(ABB_ATIVO))
			oMdlLOC:LoadValue("LOC_CODTEC", (cAliasQry)->(ABB_CODTEC))
			oMdlLOC:LoadValue("LOC_NOMTEC", (cAliasQry)->(AA1_NOMTEC))
			oMdlLOC:LoadValue("LOC_CODABB", (cAliasQry)->(ABB_CODIGO))
			oMdlLOC:LoadValue("LOC_ATENDE", (cAliasQry)->(ABB_ATENDE))
			oMdlLOC:LoadValue("LOC_CHEGOU", (cAliasQry)->(ABB_CHEGOU))
			oMdlLoc:LoadValue("LOC_LOCAL", (cAliasQry)->(ABS_LOCAL))
			oMdlLoc:LoadValue("LOC_ABBDTI", SToD((cAliasQry)->(ABB_DTINI)))
			oMdlLoc:LoadValue("LOC_ABBDTF", SToD((cAliasQry)->(ABB_DTFIM)))
			oMdlLoc:LoadValue("LOC_TFFCOD", (cAliasQry)->(TFF_COD) )
			oMdlLoc:LoadValue("LOC_IDCFAL", (cAliasQry)->(ABB_IDCFAL) )
			oMdlLoc:LoadValue("LOC_RECABB", (cAliasQry)->(RECNO) )
			cTipoMV := oMdlLOC:GetValue('LOC_TIPOMV')

			If oMdlLOC:GetValue("LOC_ATENDE") == '1' .AND. oMdlLOC:GetValue("LOC_CHEGOU") == 'S'
				oMdlLOC:LoadValue("LOC_LEGEND","BR_PRETO") // "Agenda atendida"
			ElseIf oMdlLOC:GetValue('LOC_ATIVO') == '2' .OR. HasABR((cAliasQry)->(ABB_CODIGO), (cAliasQry)->(ABB_FILIAL))
				oMdlLOC:LoadValue("LOC_LEGEND","BR_MARROM") //"Agenda com Manuten��o"
			ElseIf cTipoMV == '004'
				oMdlLOC:LoadValue("LOC_LEGEND","BR_VERMELHO") //"Excedente"
			ElseIf cTipoMV == '002'
				oMdlLOC:LoadValue("LOC_LEGEND","BR_AMARELO") //"Cobertura"
			ElseIf cTipoMV == '001'
				oMdlLOC:LoadValue("LOC_LEGEND","BR_VERDE") //"Efetivo"
			ElseIf cTipoMV == '003'
				oMdlLOC:LoadValue("LOC_LEGEND","BR_LARANJA") //"Apoio"
			ElseIf cTipoMV == '006'
				oMdlLOC:LoadValue("LOC_LEGEND","BR_CINZA") //"Curso"
			ElseIf cTipoMV == '007'
				oMdlLOC:LoadValue("LOC_LEGEND","BR_BRANCO") //"Cortesia"
			ElseIf cTipoMV == '005'
				oMdlLOC:LoadValue("LOC_LEGEND","BR_AZUL") //"Treinamento"
			Else
				oMdlLOC:LoadValue("LOC_LEGEND","BR_PINK") //"Outros Tipos"
			EndIf

			If lPeAt190Lo
				For nC := 1 To Len(oMdlLOC:aHeader)
					aAdd(aLinha,{oMdlLOC:aHeader[nC][2], oMdlLOC:GetValue(oMdlLOC:aHeader[nC][2])} )
				Next nC
				ExecBlock("AT19DLLo", .F., .F., {@oModel, @oMdlLOC, (cAliasQry)->(ABB_CODTEC), aClone(aLinha), lRefresh})
				aLinha := {}
			EndIf

			(cAliasQry)->(dbSkip())
		End
		(cAliasQry)->(dbCloseArea())
		oMdlLOC:GoLine(1)

		oMdlLOC:SetNoInsertLine(.T.)
		oMdlLOC:SetNoDeleteLine(.T.)

		If lRefresh
			oView:Refresh()
		EndIf

	EndIf

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} AT190DHJLo

@description Faz a carga dos dados no grid "HOJDETAIL"

@author	boiani
@since	29/05/2019
/*/
//------------------------------------------------------------------------------
Function AT190DHJLo(lRefresh)
	Local oView	:= FwViewActive()
	Local oModel := FwModelActive()
	Local oMdlHOJ := oModel:GetModel("HOJDETAIL")
	Local oMdlTFL := oModel:GetModel("TFLMASTER")
	Local oMdlDTR := oModel:GetModel("DTRMASTER")
	Local cCodCont	:= oMdlTFL:GetValue("TFL_CONTRT")
	Local aAtendts := {}
	Local cSql := ""
	Local dDataRef := oMdlDTR:GetValue("DTR_DTREF")
	Local cAliasQry	:= ""
	Local nAux		:= 0
	Local nX		:= 0
	Local nLinha	:= 0
	Local nFalta	:= 0
	Local nTotal	:= 0
	Local nFolga	:= 0
	Local cPosto := oMdlTFL:GetValue("TFL_TFFCOD")
	Local cLocal	:= oMdlTFL:GetValue("TFL_LOCAL")
	Local cProduto	:= oMdlTFL:GetValue("TFL_PROD")
	Local dDiaIni := POSICIONE("TFF",1,xFilial("TFF")+cPosto,"TFF_PERINI")
	Local dDiaFim := POSICIONE("TFF",1,xFilial("TFF")+cPosto,"TFF_PERFIM")
	Local aFldPai	:= Iif (!isBlind(), oView:GetFolderActive("TELA_ABAS", 2), {}) //Verifica se a aba Pai est� aberta
	Local aFolder	:= Iif (!isBlind(), oView:GetFolderActive("ABAS_LOC", 2), {})  //Verifica se a aba filho est� aberta
	Local lContinua	:= Iif (!IsBlind(), If(aFldPai[1] == 2 .And. aFolder[1] == 2,.T.,.F.), .T.) //S� executa a rotina quando a aba Agendas Projetadas estiver ativa

	Default lRefresh := .T.

	If lContinua

		oMdlHOJ:SetNoInsertLine(.F.)
		oMdlHOJ:SetNoDeleteLine(.F.)

		oMdlHOJ:ClearData()
		oMdlHOJ:InitLine()

		If !EMPTY(cCodCont) .OR. !EMPTY(cPosto)
			If DiaNoPosto(cCodCont,dDataRef, cPosto)
				cSql += " SELECT ABB.ABB_CODTEC, AA1.AA1_NOMTEC, ABB.ABB_HRINI, ABB.ABB_HRFIM, ABB.ABB_TIPOMV, ABB.ABB_ATIVO, ABB.ABB_DTINI, ABB.ABB_DTFIM, ABB.ABB_CODIGO, ABB.ABB_ATIVO "
				cSql += " FROM " + RetSqlName( "ABB" ) + " ABB INNER JOIN " + RetSqlName( "TDV" ) + " TDV ON "
				cSql += " TDV.D_E_L_E_T_ = ' ' AND TDV.TDV_FILIAL = '" + xFilial("TDV") + "' AND "
				cSql += " TDV.TDV_CODABB = ABB.ABB_CODIGO "
				cSql += " INNER JOIN " + RetSqlName( "ABQ" ) + " ABQ ON ABB.ABB_IDCFAL = ABQ.ABQ_CONTRT || ABQ.ABQ_ITEM || ABQ.ABQ_ORIGEM AND "
				cSql += " ABQ.ABQ_FILIAL = '" + xFilial("ABQ") + "' AND ABQ.D_E_L_E_T_ = ' ' "
				cSql += " INNER JOIN " + RetSqlName( "TFF" ) + " TFF ON TFF.TFF_COD = ABQ.ABQ_CODTFF AND TFF.TFF_FILIAL = ABQ.ABQ_FILTFF AND "
				cSql += " TFF.TFF_FILIAL = '" + xFilial("TFF") + "' AND TFF.D_E_L_E_T_ = ' ' "
				cSql += " INNER JOIN " + RetSqlName( "TFL" ) + " TFL ON TFL.TFL_CODIGO = TFF.TFF_CODPAI AND "
				cSql += " TFL.TFL_FILIAL = '" + xFilial("TFL") + "' AND TFL.D_E_L_E_T_ = ' ' "
				cSql += " INNER JOIN " + RetSqlName( "TFJ" ) + " TFJ ON TFJ.TFJ_CODIGO = TFL.TFL_CODPAI AND "
				cSql += " TFJ.TFJ_FILIAL = '" + xFilial("TFJ") + "' AND TFJ.D_E_L_E_T_ = ' ' AND TFJ.TFJ_STATUS = '1' "
				cSql += " INNER JOIN " + RetSqlName( "AA1" ) + " AA1 ON AA1.AA1_CODTEC = ABB.ABB_CODTEC AND "
				cSql += " AA1.AA1_FILIAL = '" + xFilial("AA1") + "' AND AA1.D_E_L_E_T_ = ' ' "
				cSql += " WHERE ABB.D_E_L_E_T_ = ' ' AND ABB.ABB_FILIAL = '" + xFilial("ABB") + "' "
				cSql += " AND TDV.TDV_DTREF = '" + DTOS(dDataRef) + "' "

				If !(Empty(cCodCont))
					cSql += " AND TFJ.TFJ_CONTRT = '" + cCodCont + "' "
				EndIf

				If !(Empty(cLocal))
					cSql += " AND TFL.TFL_LOCAL = '" + cLocal + "' "
				EndIf

				If !(Empty(cProduto))
					cSql += " AND TFF.TFF_PRODUT = '" + cProduto + "' "
				EndIf

				If !(Empty(cPosto))
					cSql += " AND TFF.TFF_COD = '" + cPosto + "' "
				EndIf

				cSql := ChangeQuery(cSql)
				cAliasQry := GetNextAlias()
				dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSql),cAliasQry, .F., .T.)
				While !(cAliasQry)->(EOF())
					If EMPTY(aAtendts) .OR. (nAux := ASCAN(aAtendts, {|a| a[1] == (cAliasQry)->(ABB_CODTEC)}) ) == 0
						AADD(aAtendts, {(cAliasQry)->(ABB_CODTEC),;				//1
						(cAliasQry)->(AA1_NOMTEC),;				//2
						(cAliasQry)->(ABB_HRINI),;				//3
						(cAliasQry)->(ABB_HRFIM),;				//4
						(cAliasQry)->(ABB_TIPOMV),;				//5
						(cAliasQry)->(ABB_ATIVO),;				//6
						STOD((cAliasQry)->(ABB_DTINI)),;		//7
						STOD((cAliasQry)->(ABB_DTFIM)),;		//8
						IIF(EMPTY((cAliasQry)->(ABB_TIPOMV)),;
							"Efetivo", Posicione("TCU",1,;
							xFilial("TCU")+(cAliasQry)->(ABB_TIPOMV),;
							"TCU_DESC")),;						//9
						IIF(EMPTY((cAliasQry)->(ABB_TIPOMV)),;
							"001",(cAliasQry)->(ABB_TIPOMV)),;	//10
						(cAliasQry)->(ABB_CODIGO),;				//11
						(cAliasQry)->(ABB_ATIVO)})				//12
					Else
						If aAtendts[nAux][7] > STOD((cAliasQry)->(ABB_DTINI))
							aAtendts[nAux][7] := STOD((cAliasQry)->(ABB_DTINI))
							aAtendts[nAux][3] := (cAliasQry)->(ABB_HRINI)
						ElseIf aAtendts[nAux][3] > (cAliasQry)->(ABB_HRINI)
							aAtendts[nAux][3] := (cAliasQry)->(ABB_HRINI)
						EndIf

						If aAtendts[nAux][8] < STOD((cAliasQry)->(ABB_DTFIM))
							aAtendts[nAux][8] := STOD((cAliasQry)->(ABB_DTFIM))
							aAtendts[nAux][4] := (cAliasQry)->(ABB_HRFIM)
						ElseIf aAtendts[nAux][4] < (cAliasQry)->(ABB_HRFIM)
							aAtendts[nAux][4] := (cAliasQry)->(ABB_HRFIM)
						EndIf
					EndIf
					(cAliasQry)->(DbSkip())
				End
				(cAliasQry)->(dbCloseArea())

				cSql := ""
				cSql += " SELECT DISTINCT ABB.ABB_CODTEC, AA1.AA1_NOMTEC "
				cSql += " FROM " + RetSqlName( "ABB" ) + " ABB "
				cSql += " INNER JOIN " + RetSqlName( "ABQ" ) + " ABQ ON ABB.ABB_IDCFAL = ABQ.ABQ_CONTRT || ABQ.ABQ_ITEM || ABQ.ABQ_ORIGEM AND "
				cSql += " ABQ.ABQ_FILIAL = '" + xFilial("ABQ") + "' AND ABQ.D_E_L_E_T_ = ' ' "
				cSql += " INNER JOIN " + RetSqlName( "TFF" ) + " TFF ON TFF.TFF_COD = ABQ.ABQ_CODTFF AND TFF.TFF_FILIAL = ABQ.ABQ_FILTFF AND "
				cSql += " TFF.TFF_FILIAL = '" + xFilial("TFF") + "' AND TFF.D_E_L_E_T_ = ' ' "
				cSql += " INNER JOIN " + RetSqlName( "TFL" ) + " TFL ON TFL.TFL_CODIGO = TFF.TFF_CODPAI AND "
				cSql += " TFL.TFL_FILIAL = '" + xFilial("TFL") + "' AND TFL.D_E_L_E_T_ = ' ' "
				cSql += " INNER JOIN " + RetSqlName( "TFJ" ) + " TFJ ON TFJ.TFJ_CODIGO = TFL.TFL_CODPAI AND "
				cSql += " TFJ.TFJ_FILIAL = '" + xFilial("TFJ") + "' AND TFJ.D_E_L_E_T_ = ' ' AND TFJ.TFJ_STATUS = '1' "
				cSql += " INNER JOIN " + RetSqlName( "AA1" ) + " AA1 ON AA1.AA1_CODTEC = ABB.ABB_CODTEC AND "
				cSql += " AA1.AA1_FILIAL = '" + xFilial("AA1") + "' AND AA1.D_E_L_E_T_ = ' ' "
				cSql += " INNER JOIN " + RetSqlName( "TGY" ) + " TGY ON TGY.TGY_ATEND = ABB.ABB_CODTEC AND "
				cSql += " TGY.TGY_FILIAL = '" + xFilial("TGY") + "' AND TGY.D_E_L_E_T_ = ' ' "
				cSql += " AND TGY.TGY_CODTFF = TFF.TFF_COD "
				cSql += " WHERE ABB.D_E_L_E_T_ = ' ' AND ABB.ABB_FILIAL = '" + xFilial("ABB") + "' "
				cSql += " AND TGY.TGY_ULTALO >= '" + DTOS(dDataRef) + "' "
				If !(Empty(cCodCont))
					cSql += " AND  TFJ.TFJ_CONTRT = '" + cCodCont + "' "
				EndIf

				If !(Empty(cLocal))
					cSql += " AND TFL.TFL_LOCAL = '" + cLocal + "' "
				EndIf

				If !(Empty(cProduto))
					cSql += " AND TFF.TFF_PRODUT = '" + cProduto + "' "
				EndIf

				If !(Empty(cPosto))
					cSql += " AND TFF.TFF_COD = '" + cPosto + "' "
				EndIf

				cSql := ChangeQuery(cSql)
				cAliasQry := GetNextAlias()
				dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSql),cAliasQry, .F., .T.)
				While !(cAliasQry)->(EOF())
					If EMPTY(aAtendts) .OR. (nAux := ASCAN(aAtendts, {|a| a[1] == (cAliasQry)->(ABB_CODTEC)}) ) == 0
						If GetDtTGY('MIN',(cAliasQry)->(ABB_CODTEC),cPosto, dDiaIni) <= dDataRef .AND.;
								GetDtTGY('MAX',(cAliasQry)->(ABB_CODTEC),cPosto, dDiaFim) >= dDataRef
							AADD(aAtendts, {(cAliasQry)->(ABB_CODTEC),;				//1
							(cAliasQry)->(AA1_NOMTEC),;				//2
							"  :  ",;								//3
							"  :  ",;								//4
							"FOL",;									//5
							"",;									//6
							CTOD(""),;								//7
							CTOD(""),;								//8
							STR0058,;								//9 # "FOLGA"
							"FOL",;									//10
							"",;									//11
							""})									//12
						EndIf
					EndIf
					(cAliasQry)->(DbSkip())
				End
				(cAliasQry)->(dbCloseArea())

				cSql := ""
				cSql += " SELECT DISTINCT TGY.TGY_ATEND, AA1.AA1_NOMTEC FROM " + RetSqlName( "TGY" ) + " TGY "
				cSql += " INNER JOIN " + RetSqlName( "TFF" ) + " TFF ON TFF.TFF_COD = TGY.TGY_CODTFF AND "
				cSql += " TFF.TFF_FILIAL = '" + xFilial("TFF") + "' AND TFF.D_E_L_E_T_ = ' ' "
				cSql += " INNER JOIN " + RetSqlName( "TFL" ) + " TFL ON TFL.TFL_CODIGO = TFF.TFF_CODPAI AND "
				cSql += " TFL.TFL_FILIAL = '" + xFilial("TFL") + "' AND TFL.D_E_L_E_T_ = ' ' "
				cSql += " INNER JOIN " + RetSqlName( "TFJ" ) + " TFJ ON TFJ.TFJ_CODIGO = TFL.TFL_CODPAI AND "
				cSql += " TFJ.TFJ_FILIAL = '" + xFilial("TFJ") + "' AND TFJ.D_E_L_E_T_ = ' ' AND TFJ.TFJ_STATUS = '1' "
				cSql += " INNER JOIN " + RetSqlName( "AA1" ) + " AA1 ON AA1.AA1_CODTEC = TGY.TGY_ATEND AND "
				cSql += " AA1.AA1_FILIAL = '" + xFilial("AA1") + "' AND AA1.D_E_L_E_T_ = ' ' "
				cSql += " WHERE "
				cSql += " TGY.TGY_FILIAL = '" + xFilial("TGY") + "' AND "
				cSql += " TGY.D_E_L_E_T_ = ' ' "

				If !(Empty(cCodCont))
					cSql += " AND TFJ.TFJ_CONTRT = '" + cCodCont + "' "
				EndIf

				If !(Empty(cLocal))
					cSql += " AND TFL.TFL_LOCAL = '" + cLocal + "' "
				EndIf

				If !(Empty(cProduto))
					cSql += " AND TFF.TFF_PRODUT = '" + cProduto + "' "
				EndIf

				If !(Empty(cPosto))
					cSql += " AND TFF.TFF_COD = '" + cPosto + "' "
				EndIf

				cSql := ChangeQuery(cSql)
				cAliasQry := GetNextAlias()
				dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSql),cAliasQry, .F., .T.)
				While !(cAliasQry)->(EOF())
					If EMPTY(aAtendts) .OR. (nAux := ASCAN(aAtendts, {|a| a[1] == (cAliasQry)->(TGY_ATEND)}) ) == 0
						AADD(aAtendts, {(cAliasQry)->(TGY_ATEND),;				//1
						(cAliasQry)->(AA1_NOMTEC),;				//2
						"  :  ",;								//3
						"  :  ",;								//4
						"",;									//5
						"",;									//6
						CTOD(""),;								//7
						CTOD(""),;								//8
						UPPER(STR0059),;						//9 # "Agenda n�o projetada"
						"",;									//10
						"",;									//11
						"" 	})									//12
					EndIf
					(cAliasQry)->(DbSkip())
				End
				(cAliasQry)->(dbCloseArea())

				For nX := 1 to LEN(aAtendts)
					If !oMdlHOJ:IsEmpty()
						nLinha := oMdlHOJ:AddLine()
					EndIf
					oMdlHOJ:GoLine(nLinha)
					oMdlHOJ:LoadValue("HOJ_CODTEC", aAtendts[nX][1])
					oMdlHOJ:LoadValue("HOJ_NOMTEC", aAtendts[nX][2])
					oMdlHOJ:LoadValue("HOJ_HRINI",	aAtendts[nX][3])
					oMdlHOJ:LoadValue("HOJ_HRFIM",	aAtendts[nX][4])
					oMdlHOJ:LoadValue("HOJ_SITUAC",	aAtendts[nX][9])

					If aAtendts[nX][6] == '2' .OR. HasABR(aAtendts[nX][11])
						oMdlHOJ:LoadValue("HOJ_LEGEND","BR_MARROM") //"Agenda com Manuten��o"
					Else
						If aAtendts[nX][10] <> "FOL" .AND. !EMPTY(aAtendts[nX][10])
							If aAtendts[nX][10] == '004'
								oMdlHOJ:LoadValue("HOJ_LEGEND","BR_VERMELHO") //"Excedente"
							ElseIf aAtendts[nX][10] == '002'
								oMdlHOJ:LoadValue("HOJ_LEGEND","BR_AMARELO") //"Cobertura"
							ElseIf aAtendts[nX][10] == '001'
								oMdlHOJ:LoadValue("HOJ_LEGEND","BR_VERDE") //"Efetivo"
							ElseIf aAtendts[nX][10] == '003'
								oMdlHOJ:LoadValue("HOJ_LEGEND","BR_LARANJA") //"Apoio"
							ElseIf aAtendts[nX][10] == '006'
								oMdlHOJ:LoadValue("HOJ_LEGEND","BR_PRETO") //"Curso"
							ElseIf aAtendts[nX][10] == '007'
								oMdlHOJ:LoadValue("HOJ_LEGEND","BR_BRANCO") //"Cortesia"
							ElseIf aAtendts[nX][10] == '005'
								oMdlHOJ:LoadValue("HOJ_LEGEND","BR_AZUL") //"Treinamento"
							Else
								oMdlHOJ:LoadValue("HOJ_LEGEND","BR_PINK") //"Outros Tipos"
							EndIf
						ElseIf aAtendts[nX][10] == "FOL"
							oMdlHOJ:LoadValue("HOJ_LEGEND","BR_VIOLETA") //Folga
							nFolga += 1
						Else
							oMdlHOJ:LoadValue("HOJ_LEGEND","BR_CINZA") //Agenda n�o projetada
						EndIf
					EndIf

					If aAtendts[nX][12] == "2"
						nFalta += 1
					EndIf

					nTotal	+= 1
				Next nX

				oMdlDTR:LoadValue("DTR_NUMATD", cValTOChar(LEN(aAtendts)))
				oMdlDTR:LoadValue("DTR_NUMEFE", cValTOChar(nTotal - nFolga - nFalta))
				oMdlDTR:LoadValue("DTR_NUMFAL", cValTOChar(nFalta))
				oMdlDTR:LoadValue("DTR_NUMFOL", cValTOChar(nFolga))
				If lRefresh .AND. !isBlind()
					oView:Refresh()
				EndIf
			Else
				If !(Empty(cPosto))
					Help(,,"AT190DDATA",,;
						STR0129 + DTOC(dDataRef) + STR0130 + DTOC(dDiaIni) + STR0131 + DTOC(dDiaFim) + ")",1,0)	//"A data selecionada (" # ") est� fora do per�odo do posto (" # " a "
				Else
					Help(,,"AT190DDATA",,;
						STR0356,1,0)	// "A data selecionada esta fora do periodo do contrato."
				EndIf
				oMdlDTR:LoadValue("DTR_NUMATD", '0')
				oMdlDTR:LoadValue("DTR_NUMEFE", '0')
				oMdlDTR:LoadValue("DTR_NUMFAL", '0')
				oMdlDTR:LoadValue("DTR_NUMFOL", '0')
				oMdlHOJ:ClearData()
				oMdlHOJ:InitLine()
				If lRefresh
					oView:Refresh()
				EndIf
			EndIf
		Else
			Help(,,"AT190DSEMFILTRO",,STR0355,1,0)	// "O campo Contrato ou Posto n�o est�o preenchido. Por favor, selecione um Contrato e/ou Posto."
			oMdlDTR:LoadValue("DTR_NUMATD", '0')
			oMdlDTR:LoadValue("DTR_NUMEFE", '0')
			oMdlDTR:LoadValue("DTR_NUMFAL", '0')
			oMdlDTR:LoadValue("DTR_NUMFOL", '0')
			oMdlHOJ:ClearData()
			oMdlHOJ:InitLine()
			If lRefresh
				oView:Refresh()
			EndIf
		EndIf

		oMdlHOJ:GoLine(1)

		oMdlHOJ:SetNoInsertLine(.T.)
		oMdlHOJ:SetNoDeleteLine(.T.)

	EndIf

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At190MHora

@description Adiciona manuten��es na agenda ao alterar o hor�rio no grid ABBDETAIL

@author	boiani
@since	07/06/2019
/*/
//------------------------------------------------------------------------------
Function At190MHora(cTipo)
	Local oModel 	:= FwModelActive()
	Local oMdlABB 	:= oModel:GetModel("ABBDETAIL")
	Local cHoraNew 	:= oMdlABB:GetValue(cTipo)
	Local cCodABB 	:= oMdlABB:GetValue("ABB_CODIGO")
	Local cChegou 	:= oMdlABB:GetValue("ABB_CHEGOU")
	Local oMdlMAN 	:= oModel:GetModel("MANMASTER")
	Local cHoraOld	:= Nil
	Local cManut 	:= ""
	Local oMdlAssist := Nil
	Local cABN_CODIGO := ""
	Local cOperation := ""
	Local lOk 		:= .T.
	Local cCpoABR 	:= "ABR" + STRTRAN(cTipo,"ABB")
	Local cMsgERR 	:= ""
	Local cParCpo 	:= IIF(cTipo == "ABB_HRINI","ABB_HRFIM","ABB_HRINI")
	Local cParHor 	:= oMdlABB:GetValue(cParCpo)
	Local cCpoDtABR := ""
	Local dDataAlter := CTOD("")
	Local lMV_MultFil := TecMultFil() //Indica se a Mesa considera multiplas filiais
	Local cBkpFil := cFilAnt

	If lMV_MultFil .AND. !Empty(oMdlABB:GetValue("ABB_FILIAL"))
		cFilAnt := oMdlABB:GetValue("ABB_FILIAL")
	EndIf

	At550SetGrvU(.T.)

	If !EMPTY(cCodABB)
		DbSelectArea("ABB")
		DbSetOrder(8)
		If ABB->(MsSeek(xFilial("ABB") + cCodABB ))
			cHoraOld := (&("ABB->(" + cTipo + ")"))
			If cChegou == "S"
				lOk := .F.
				oMdlABB:LoadValue(cTipo, cHoraOld)
				cMsgERR := STR0133	//"N�o � poss�vel incluir manuten��es para agendas j� atendidas."
			EndIf
			If lOk
				If cHoraOld <> cHoraNew
					dDataIni := ABB->ABB_DTINI
					dDataFim := ABB->ABB_DTFIM

					If cTipo == "ABB_HRINI"
						If HrsToVal(cHoraNew) > HrsToVal(cHoraOld)
							If dDataFim == dDataIni
								cManut := "AT"
								cOperation := STR0134	//"atraso"
								If HrsToVal(cHoraNew) >= HrsToVal(cParHor)
									cManut := "HE"
									cOperation := STR0135	//"hora extra"
									cCpoDtABR := "ABR_DTINI"
									dDataAlter := oMdlABB:GetValue("ABB_DTINI") - 1
								EndIf
							Else
								cManut := "AT"
								cOperation := STR0134	//"atraso"
							EndIf
						ElseIf HrsToVal(cHoraNew) < HrsToVal(cHoraOld)
							If dDataFim == dDataIni
								cManut := "HE"
								cOperation := STR0135	//"hora extra"
							Else
								cManut := "AT"
								cOperation := STR0134	//"atraso"
								cCpoDtABR := "ABR_DTINI"
								dDataAlter := oMdlABB:GetValue("ABB_DTINI") + 1
								If HrsToVal(cHoraNew) >= HrsToVal(cParHor)
									cOperation := STR0135	//"hora extra"
									cManut := "HE"
									cCpoDtABR := ""
									dDataAlter := CTOD("")
								EndIf
							EndIf
						EndIf
					ElseIf cTipo == "ABB_HRFIM"
						If HrsToVal(cHoraNew) > HrsToVal(cHoraOld)
							If dDataFim == dDataIni
								cManut := "HE"
								cOperation := STR0135	//"hora extra"
							Else
								cManut := "SA"
								cOperation := STR0136	//"sa�da antecipada"
								cCpoDtABR := "ABR_DTFIM"
								dDataAlter := oMdlABB:GetValue("ABB_DTFIM") - 1
								If HrsToVal(cHoraNew) <= HrsToVal(cParHor)
									cManut := "HE"
									cOperation := STR0135	//"hora extra"
									cCpoDtABR := ""
									dDataAlter := CTOD("")
								EndIf
							EndIf
						ElseIf HrsToVal(cHoraNew) < HrsToVal(cHoraOld)
							If dDataFim == dDataIni
								cManut := "SA"
								cOperation := STR0136	//"sa�da antecipada"
								If HrsToVal(cHoraNew) <= HrsToVal(cParHor)
									cManut := "HE"
									cOperation := STR0135	//"hora extra"
									cCpoDtABR := "ABR_DTFIM"
									dDataAlter := oMdlABB:GetValue("ABB_DTFIM") + 1
								EndIf
							Else
								cManut := "SA"
								cOperation := STR0136	//"sa�da antecipada"
							EndIf
						EndIf
					EndIf
					At550SetAlias("ABB")
					oMdlAssist := FwLoadModel("TECA550")
					oMdlAssist:SetOperation(MODEL_OPERATION_INSERT)
					If oMdlAssist:Activate()
						cABN_CODIGO := GetABN(cManut, cOperation)
						If !EMPTY(cABN_CODIGO)
							lOk := oMdlAssist:SetValue("ABRMASTER","ABR_MOTIVO", cABN_CODIGO)
							If !EMPTY(cCpoDtABR) .AND. !EMPTY(dDataAlter)
								lOk := lOk .AND. oMdlAssist:SetValue("ABRMASTER",cCpoDtABR,dDataAlter)
							EndIf
							lOk := lOk .AND. oMdlAssist:SetValue("ABRMASTER",cCpoABR, cHoraNew)
							lOk := lOk .AND. oMdlAssist:SetValue("ABRMASTER","ABR_OBSERV", At190dMsgM())
							If lOK .AND. MsgYesNo(STR0137 +;
									oMdlAssist:GetValue("ABRMASTER","ABR_TEMPO") + STR0138 + cOperation + "?")	//"Confirmar inclus�o de manuten��o de " # " de "
								If oMdlAssist:VldData() .And. oMdlAssist:CommitData()
									oMdlABB:LoadValue("ABB_LEGEND","BR_MARROM")
									If cManut $ "SA|HE|AT"
										oMdlABB:LoadValue("ABB_OBSERV", ABB->ABB_OBSERV)
									EndIf
									CleanMAN(oMdlMAN)
									oMdlAssist:DeActivate()
									oMdlAssist:Destroy()
								ElseIf oMdlAssist:HasErrorMessage()
									oMdlABB:LoadValue(cTipo, cHoraOld)
									AtErroMvc( oMdlAssist )
									If !IsBlind()
										MostraErro()
									EndIf
								EndIf
							Else
								oMdlABB:LoadValue(cTipo, cHoraOld)
								lOk := .F.
								cMsgERR := STR0139 + cOperation + "."	//"N�o foi poss�vel incluir manuten��o de "
							EndIf
						Else
							oMdlABB:LoadValue(cTipo, cHoraOld)
							lOk := .F.
							cMsgERR := STR0140 +;
								cOperation + STR0141	//"N�o foi poss�vel definir um Tipo de Manuten��o para a opera��o de " # ". Verifique o cadastro de Motivos de Manuten��o (TECA530)"
						EndIf
					ElseIf oMdlAssist:HasErrorMessage()
						oMdlABB:LoadValue(cTipo, cHoraOld)
						AtErroMvc( oMdlAssist )
						MostraErro()
					EndIf
					FwModelActive(oModel)
					At550SetAlias("")
				EndIf
			EndIf
		EndIf
	EndIf

	At550SetGrvU(.F.)

	cFilAnt := cBkpFil

	If !lOk .AND. !EMPTY(cMsgERR) .AND. !(IsBlind())
		MsgAlert(cMsgERR)
	EndIf

Return (.T.)
//------------------------------------------------------------------------------
/*/{Protheus.doc} GetABN

@description Retorna o c�digo da Manuten��o da Agenda de acordo com a opera��o realizada
em tela

@author	boiani
@since	07/06/2019
/*/
//------------------------------------------------------------------------------
Static Function GetABN(cManut, cOperation)
	Local cRet := ""
	Local cTipo := ""
	Local cSql := ""
	Local cAliasQry
	Local aABNs := {}
	Local oDlgSelect
	Local oCombo
	Local cCombo
	Local aABNAux := {}
	Local oOk

	If cManut == "AT"
		cTipo := "02"
	ElseIf cManut == "HE"
		cTipo := "04"
	ElseIf cManut == "SA"
		cTipo := "03"
	EndIf

	cSql += " SELECT ABN.ABN_CODIGO FROM " + RetSqlName( "ABN" ) + " ABN "
	cSql += " WHERE "
	cSql += " ABN.ABN_TIPO = '" + cTipo + "' AND ABN.ABN_FILIAL = '" + xFilial("ABN") + "' AND "
	cSql += " ABN.D_E_L_E_T_ = ' ' "

	cSql := ChangeQuery(cSql)
	cAliasQry := GetNextAlias()
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSql),cAliasQry, .F., .T.)

	While !((cAliasQry)->(EOF()))
		AADD(aABNs, (cAliasQry)->(ABN_CODIGO))
		AADD(aABNAux, (cAliasQry)->(ABN_CODIGO)+" - "+Alltrim(POSICIONE("ABN",1,xFilial("ABN")+(cAliasQry)->(ABN_CODIGO)+cTipo,"ABN_DESC")))
		(cAliasQry)->(DbSkip())
	End
	(cAliasQry)->(DbCloseArea())

	If LEN(aABNs) == 1 .OR. (LEN(aABNS) > 0 .AND. isBlind())
		cRet := aABNs[1]
	ElseIf LEN(aABNs) > 1
		cCombo := aABNAux[1]
		DEFINE MSDIALOG oDlgSelect FROM 0,0 TO 73,300 PIXEL Style 128 TITLE STR0142 + cOperation	//"Manuten��o de "
		oCombo := TComboBox():New(006,006,{|u|if(PCount()>0,cCombo:=u,cCombo)},aABNAux,100,20,oDlgSelect,,,,,,.T.,,,,,,,,,'cCombo')
		oOk := TButton():New( 008, 108, STR0109,oDlgSelect,{|| oDlgSelect:End() }, 38,12,,,.F.,.T.,.F.,,.F.,,,.F. )	//"Confirmar"
		ACTIVATE MSDIALOG oDlgSelect CENTER
		cRet := aABNs[ASCAN(aABNAux, cCombo)]
	EndIf

Return cRet
//------------------------------------------------------------------------------
/*/{Protheus.doc} HrsToVal

@description Converte uma String em formato de hor�rio em um valor num�rico

@author	boiani
@since	07/06/2019
/*/
//------------------------------------------------------------------------------
Static Function HrsToVal(cHora)

Return VAL(STRTRAN(cHora,":"))

//------------------------------------------------------------------------------
/*/{Protheus.doc} DiaNoPosto

@description Verifica se uma data est� dentro do per�odo do Posto de Atendimento

@author	boiani
@since	02/07/2019
/*/
//------------------------------------------------------------------------------
Static Function DiaNoPosto(cCodContr, dDia, cPosto)
	Local lRet := .F.
	Local cSql := ""
	Local cAliasQry

	Default cCodContr	:= ""
	Default dDia		:= sTod("")
	Default cPosto		:= ""

	cSql += " SELECT TFF.TFF_PERINI, TFF.TFF_PERFIM FROM " + RetSqlName( "TFF" ) + " TFF "
	cSql += " WHERE "
	cSql += " TFF.TFF_FILIAL = '" + xFilial("TFF") + "' AND "
	cSql += " TFF.D_E_L_E_T_ = ' ' AND '" + DTOS(dDia) + "' BETWEEN TFF.TFF_PERINI AND TFF.TFF_PERFIM "

	If !(Empty(cCodContr))
		cSql += " AND TFF.TFF_CONTRT = '" + cCodContr + "'
	EndIf

	If !(Empty(cPosto))
		cSql += " AND TFF.TFF_COD = '" + cPosto + "' "
	EndIf

	cSql := ChangeQuery(cSql)
	cAliasQry := GetNextAlias()
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSql),cAliasQry, .F., .T.)

	lRet := !((cAliasQry)->(EOF()))
	(cAliasQry)->(DbCloseArea())

Return lRet
//------------------------------------------------------------------------------
/*/{Protheus.doc} GetDtTGY

@description Retorna o primeiro ou o �ltimo dia de trabalho do atendente, conforme configura��o na TGY

@author	boiani
@since	02/07/2019
/*/
//------------------------------------------------------------------------------
Static Function GetDtTGY(cOper,cCodTec, cCodTFF, dDtMin)
	Local dRet
	Local cSql := ""
	Local cAliasQry

	cSql += " SELECT " + cOper + "(TGY.TGY_DT" + IIF(cOper == 'MIN', 'INI', 'FIM') + ") DT FROM " + RetSqlName( "TGY" ) + " TGY "
	cSql += " WHERE "
	cSql += " TGY.TGY_CODTFF = '" + cCodTFF + "' AND TGY.TGY_FILIAL = '" + xFilial("TGY") + "' AND "
	cSql += " TGY.D_E_L_E_T_ = ' ' AND TGY.TGY_ATEND = '" + cCodTec + "'"

	cSql := ChangeQuery(cSql)
	cAliasQry := GetNextAlias()
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSql),cAliasQry, .F., .T.)

	dRet := STOD((cAliasQry)->(DT))
	(cAliasQry)->(DbCloseArea())

	If EMPTY(dRet)
		dRet := dDtMin
	EndIf

Return dRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At19OVlTFL

@description Fun��o para validar os campos da estrutura TFL

@param cCampo - Campo que ser� validado

@author	Luiz Gabriel
@since	01/07/2019
/*/
//------------------------------------------------------------------------------
Static Function At19OVlTFL(cCampo)
	Local oModel    := FwModelActive()
	Local oView		:= FwViewActive()
	Local oMdlTFL 	:= oModel:GetModel('TFLMASTER')
	Local oMdlLOC 	:= oModel:GetModel('LOCDETAIL')
	Local oMdlHOJ 	:= oModel:GetModel("HOJDETAIL")
	Local oMdlDTR	:= oModel:GetModel("DTRMASTER")
	Local lRet		:= .T.
	Local aCampos	:= {}
	Local nPos		:= 0
	Local nX		:= 0
	Local cFilBusc	:= cFilAnt
	Local lMV_MultFil := TecMultFil() //Indica se a Mesa considera multiplas filiais

	If lMV_MultFil
		cFilBusc := oMdlTFL:GetValue("TFL_FILIAL")
	EndIf

	If !lMV_MultFil .OR. !Empty(cFilBusc)
		Do Case

		Case cCampo == "TFL_CODENT"
			lRet := At190Exist("SA1",oMdlTFL:GetValue(cCampo),1,cFilBusc)
		Case cCampo == "TFL_LOJA"
			lRet := !Empty(oMdlTFL:GetValue(cCampo)) .And. At190Exist("SA1",oMdlTFL:GetValue("TFL_CODENT") + oMdlTFL:GetValue(cCampo), 1,cFilBusc)
		Case cCampo == "TFL_CONTRT"
			lRet := At190Exist("CN9",oMdlTFL:GetValue(cCampo),1,cFilBusc)
		Case cCampo == "TFL_LOCAL"
			lRet := At190Exist("ABS",oMdlTFL:GetValue(cCampo),1,cFilBusc)
		Case cCampo == "TFL_PROD"
			lRet := ( At190Exist('SB1',oMdlTFL:GetValue(cCampo),1,cFilBusc) .AND. At190Exist('SB5',oMdlTFL:GetValue(cCampo),1,cFilBusc) )
		Case cCampo == "TFL_TFFCOD"
			lRet := At190Exist("TFF",oMdlTFL:GetValue(cCampo),1,cFilBusc)

		End Case
	EndIf
	If !lRet
		oModel:GetModel():SetErrorMessage(oModel:GetId(),cCampo,oModel:GetModel():GetId(),cCampo,cCampo,;
			STR0148, STR0149 )	//"N�o existe registro relacionado a este c�digo" # "Informe um c�digo valido"
	EndIf

//Realiza a limpeza dos campos posteriores e do Grid LOCDETAIL
	If lRet

		aCampos := AT190DDef("TFL")

		nPos := aScan(aCampos, {|a| a[3] == cCampo })

		If nPos > 0
			For nX := nPos+1 To Len(aCampos)
				If !Empty(oMdlTFL:GetValue(aCampos[nX][3]))
					oMdlTFL:LoadValue(aCampos[nX][3],"")
				EndIf
			Next nX
		EndIf

		If !oMdlLOC:IsEmpty()
			oMdlLOC:SetNoInsertLine(.F.)
			oMdlLOC:SetNoDeleteLine(.F.)

			oMdlLOC:ClearData()
			oMdlLOC:InitLine()

			oMdlLOC:SetNoInsertLine(.T.)
			oMdlLOC:SetNoDeleteLine(.T.)

			oView:Refresh('DETAIL_LOC')

		EndIf

		If !oMdlHOJ:IsEmpty() .Or. !Empty(oMdlDTR:GetValue("DTR_NUMATD"))

			If !Empty(oMdlDTR:GetValue("DTR_NUMATD"))
				oMdlDTR:LoadValue("DTR_NUMATD", '0')
				oMdlDTR:LoadValue("DTR_NUMEFE", '0')
				oMdlDTR:LoadValue("DTR_NUMFAL", '0')
				oMdlDTR:LoadValue("DTR_NUMFOL", '0')
			EndIf

			oMdlHOJ:SetNoInsertLine(.F.)
			oMdlHOJ:SetNoDeleteLine(.F.)

			oMdlHOJ:ClearData()
			oMdlHOJ:InitLine()

			oMdlHOJ:SetNoInsertLine(.T.)
			oMdlHOJ:SetNoDeleteLine(.T.)

			If !IsBlind()
				oView:Refresh('VIEW_DTR')
				oView:Refresh('DETAIL_HOJ')
			EndIf
		EndIf
	EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At190Exist

@description Fun��o para validar os registros

@param cTabela - Tabela a ser posicionada
@param cExpr - Express�o a ser utilizada para validar o registro
@param nIndice	- Indice utilizado para realizar a valida��o do registro

@author	Luiz Gabriel
@since	01/07/2019
/*/
//------------------------------------------------------------------------------
Function At190Exist(cTabela,cExpr,nIndice, cFilBusc)
	Local lRet	:= If(Empty(cExpr), .T., .F.)
	Local aArea	:= GetArea()
	Default cFilBusc := cFilAnt
	If !lRet
		DbSelectArea(cTabela)
		(cTabela)->(DbSetOrder(nIndice))

		If (cTabela)->(DbSeek(xFilial(cTabela, cFilBusc) + cExpr ))
			lRet := .T.
		EndIf
	EndIf

	RestArea(aArea)

Return lRet
//------------------------------------------------------------------------------
/*/{Protheus.doc} at190d550

@description Exibe um grid do TECA550 com as manuten��es relacionadas

@author	boiani
@since	03/07/2019
/*/
//------------------------------------------------------------------------------
Function at190d550(cTipo)
	Local oDlg
	Local oBrowse
	Local nX
	Local oModel  := FwModelActive()
	Local oMdlABB := oModel:GetModel("ABBDETAIL")
	Local oMdlMAN := oModel:GetModel("MANMASTER")
	Local oMdlLOC := oModel:GetModel("LOCDETAIL")
	Local cAtend  := oModel:GetValue("AA1MASTER","AA1_CODTEC")
	Local lHasABR := .F.
	Local lHelpSlc:= .T.
	Local nCount  := 0
	Local aManut  := {}
	Local cFiltro := ""

	Default cTipo := "ABB"

	Private aRotina 	:= MenuDef550()
	Private cCadastro	:= STR0156	//'Manuten��o da Agenda'

	At550SetAlias("ABB")
	At550SetGrvU(.T.)

	If cTipo == "ABB"
		cFiltro550 := ""
		AeVAL(aMarks, {|a| nCount += IIF(!EMPTY(a[1]) .AND. HasABR(a[1],a[12]), 1, 0)})
		If nCount < 90
			For nX := 1 To Len(aMarks)
				If !EMPTY(aMarks[nX][1]) .AND. HasABR(aMarks[nX][1],aMarks[nX][12])
					cFiltro550 += "(ABR_AGENDA='"+aMarks[nX][1] + "'.AND. ABR_FILIAL='"+xFilial("ABR",aMarks[nX][12])+"').OR."
					Aadd(aManut,{aMarks[nX][1],aMarks[nX][12]})
					If !lHasABR
						lHasABR := HasABR(aMarks[nX][1],aMarks[nX][12])
					EndIf
				EndIf
			Next nX
			If EMPTY(cFiltro550)

				cFiltro550 := "(ABR_AGENDA='"+oMdlABB:GetValue("ABB_CODIGO")+"' .AND. ABR_FILIAL='"+oMdlABB:GetValue("ABB_FILIAL")+"')"

				Aadd(aManut,{oMdlABB:GetValue("ABB_CODIGO"),oMdlABB:GetValue("ABB_FILIAL")})

				If !lHasABR
					lHasABR := HasABR(oMdlABB:GetValue("ABB_CODIGO"), oMdlABB:GetValue("ABB_FILIAL"))
				EndIf
			Else
				cFiltro550 := LEFT(cFiltro550,LEN(cFiltro550)-4)
			EndIf

			lHasABR := lHasABR .AND. !EMPTY(cAtend)
		Else
			lHelpSlc := .F.
			Help(,,"at190d550",,STR0323,1,0) //"N�o � poss�vel alterar mais que 90 dias de agenda de manuten��es relacionadas."
		Endif
	ElseIf cTipo == "LOC"
		cFiltro550 := ""
		For nX := 1 To oMdlLOC:Length()
			oMdlLOC:GoLine(nX)
			If oMdlLOC:GetValue("LOC_LEGEND") == "BR_MARROM"
				If oMdlLOC:GetValue("LOC_MARK") .AND. nCount < 90
					lHasABR := .T.
					nCount++
					cFiltro550 += "(ABR_AGENDA='"+oMdlLOC:GetValue("LOC_CODABB") +;
						"'.AND. ABR_FILIAL='"+xFilial("ABR",oMdlLOC:GetValue("LOC_FILIAL"))+"').OR."
					Aadd(aManut,{oMdlLOC:GetValue("LOC_CODABB"),oMdlLOC:GetValue("LOC_FILIAL")})
				ElseIf nCount >= 90
					lHelpSlc := .F.
					Help(,,"at190d550",,STR0323,1,0) //"N�o � poss�vel alterar mais que 90 dias de agenda de manuten��es relacionadas."
					aManut := {}
					Exit
				EndIf
			EndIf
		Next nX
		If !EMPTY(cFiltro550)
			cFiltro550 := LEFT(cFiltro550,LEN(cFiltro550)-4)
		EndIf
	EndIf

	If !Empty(aManut)
		cFiltro := At190dFilt(aManut)
	Endif

	If Len(cFiltro) <= 2000
		If lHasABR .And. !Empty(cFiltro)
			oDlg:= MSDIALOG():Create()
			oDlg:cName     		:= "oDlg"
			oDlg:cCaption  		:= STR0157	//"Manuten��es Relacionadas"
			oDlg:nLeft     		:= 0
			oDlg:nTop      		:= 0
			oDlg:nWidth    		:= 0.96 * GetScreenRes()[1]
			oDlg:nHeight   		:= 0.85 * GetScreenRes()[2]
			oDlg:lShowHint 		:= .F.
			oDlg:lCentered 		:= .T.

			oBrowse := FWMBrowse():New()
			oBrowse:SetAlias( "ABR" )
			oBrowse:SetFilterDefault( cFiltro )
			oBrowse:DisableDetails()
			oBrowse:Activate(oDlg)
			oDlg:Activate()

			aRotina := nil
			cCadastro := nil

			At550SetAlias("")
			At550SetGrvU(.F.)
			If cTipo == "ABB"
				At190DLoad()
			ElseIf cTipo == "LOC"
				AT190DLdLo()
			EndIf
		Else
			If lHelpSlc
				Help(,,"AT190DSEMABR",,STR0150,1,0)	//"Nenhuma agenda com manuten��o selecionada. Por favor, verifique se as agendas com legenda marrom (em manuten��o) est�o marcadas."
			ENdIf
		EndIf

		At550SetAlias("")
		At550SetGrvU(.F.)

		If cTipo == "ABB"
			CleanMAN(oMdlMAN)
		EndIf
	Else
		Help(,,"at190d550",,STR0537,1,0) //"N�o � poss�vel selecionar essa quantidade de agendas de manuten��es relacionadas."
	Endif

	cFiltro550 := ""

Return
//------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef550

@description MenuDef da rotina at190d550

@author	boiani
@since	03/07/2019
/*/
//------------------------------------------------------------------------------
Static Function MenuDef550()

	Local aRotina := {}

	ADD OPTION aRotina Title STR0152 Action "at190dV550(ABR->ABR_AGENDA, 4,ABR->ABR_FILIAL)" OPERATION MODEL_OPERATION_UPDATE	ACCESS 0	//"Alterar"
	ADD OPTION aRotina Title STR0153 Action "at190dV550(ABR->ABR_AGENDA, 5,ABR->ABR_FILIAL)" OPERATION MODEL_OPERATION_DELETE	ACCESS 0	//"Excluir"
	ADD OPTION aRotina Title STR0154 Action "at190dV550(ABR->ABR_AGENDA, 1,ABR->ABR_FILIAL)" OPERATION MODEL_OPERATION_VIEW ACCESS 0	//"Visualizar"

	aAdd(aRotina,{STR0155,"At190DlAll()",0 ,4})	//"Apagar todas"
	aAdd(aRotina,{STR0532,"At190SubLo()",0 ,4}) //"Substituto em Lote"

Return aRotina
//------------------------------------------------------------------------------
/*/{Protheus.doc} at190dV550

@description Posiciona na ABB antes de executar a view do TECA550

@author	boiani
@since	05/07/2019
/*/
//------------------------------------------------------------------------------
Function at190dV550(cAgenda, nOper, cFilABR)
	Local lPerm := .T.
	Local cBkpFil := cFilAnt
	Local lMV_MultFil := TecMultFil() //Indica se a Mesa considera multiplas filiais
	Local cFilBkp := cFilAnt
	Local lContinua := .T.
	If nOper == 1 .OR. (lPerm := At680Perm(NIL, __cUserId, "038", .T.))
		If lMV_MultFil
			If LEN(RTRIM(cFilABR)) == LEN(RTRIM(cFilAnt))
				cFilAnt := cFilABR
			Else
				lContinua := .F.
				Help(,1,"at190dV550",,STR0489, 1)
				//"O par�metro MV_GSMSFIL est� ativo, por�m a tabela de Manuten��es de agenda (ABR) n�o est� em modo Exclusivo. Opera��o cancelada."
			EndIf
		EndIf
		If lContinua
			ABB->(DbSetOrder(8))
			ABB->(MsSeek(xFilial("ABB") + cAgenda))

			ABQ->(DbSetOrder(1))
			ABQ->(MsSeek(xFilial("ABQ") + ABB->ABB_IDCFAL))

			TFF->(DbSetOrder(1))
			TFF->(MsSeek(xFilial("TFF") + ABQ->ABQ_CODTFF))

			FWExecView( STR0017, "VIEWDEF.TECA550", nOper, /*oDlg*/, {||.T.} /*bCloseOk*/,	{||.T.}/*bOk*/,20, /*aButtons*/, {||.T.}/*bCancel*/ ) //"Manuten��o"
		EndIf
	ElseIf !lPerm
		Help(,1,"at190dV550",,STR0476, 1) //"Usu�rio sem permiss�o de realizar manuten��o na agenda "
	EndIf
	cFilAnt := cFilBkp
Return
//------------------------------------------------------------------------------
/*/{Protheus.doc} At190DlAll

@description Apaga todas as ABRs presentes no grid

@author	boiani
@since	06/07/2019
/*/
//------------------------------------------------------------------------------
Function At190DlAll(lSemTela)
	Local aAux := {}
	Local cCopyFil := cFiltro550
	Local cQry
	Local oMdlAtv := FwModelActive()
	Local oMdl550 := FwLoadModel("TECA550")
	Local nFail := 0
	Local nCount := 0
	Local aErrors := {}
	Local aErroMVC := {}
	Local cMsg := ""
	Local nX
	Local nY
	Local cBkpFil := cFilAnt
	Local lMV_MultFil := TecMultFil() //Indica se a Mesa considera multiplas filiais
	Default lSemTela := isBlind()
	If At680Perm(NIL, __cUserId, "038", .T.)
		While "ABR_AGENDA"$ cCopyFil
			AADD(aAux, {SUBSTR(cCopyFil,AT("ABR_AGENDA",cCopyFil)+LEN("ABR_AGENDA='"),TamSX3("ABR_AGENDA")[1]),;
				SUBSTR(cCopyFil,AT("ABR_FILIAL",cCopyFil)+LEN("ABR_FILIAL='"),TamSX3("ABR_FILIAL")[1])})
			cCopyFil := SUBSTR(cCopyFil,AT("ABR_FILIAL",cCopyFil)+LEN("ABR_FILIAL=''")+TamSX3("ABR_FILIAL")[1])
		EndDo
		For nX := 1 To LEN(aAux)
			cQry := GetNextAlias()

			BeginSQL Alias cQry
			SELECT ABR.R_E_C_N_O_ REC
			  FROM %Table:ABR% ABR
			 WHERE ABR.ABR_FILIAL = %Exp:aAux[nX][2]%
			   AND ABR.%NotDel%
			   AND ABR.ABR_AGENDA = %Exp:aAux[nX][1]%
			EndSQL

			While !((cQry)->(EOF()))
				If lMV_MultFil
					cFilAnt := aAux[nX][2]
				EndIf
				ABB->(DbSetOrder(8))
				ABB->(DbSeek(xFilial("ABB") + aAux[nX][1]))

				DbSelectArea("ABR")
				ABR->(DbGoTo((cQry)->(REC)))

				oMdl550:SetOperation( MODEL_OPERATION_DELETE)
				oMdl550:Activate()
				Begin Transaction
					nCount++
					If !oMdl550:VldData() .OR. !oMdl550:CommitData()
						nFail++
						aErroMVC := oMdl550:GetErrorMessage()
						AADD(aErrors, {	 STR0158 + ' [' + AllToChar( aErroMVC[1] ) + ']',;	//"Id do formul�rio de origem:"
						STR0159 + ' [' + AllToChar( aErroMVC[2] ) + ']',;	//"Id do campo de origem:"
						STR0160 + ' [' + AllToChar( aErroMVC[3] ) + ']',;	//"Id do formul�rio de erro:"
						STR0161 + ' [' + AllToChar( aErroMVC[4] ) + ']',;	//"Id do campo de erro:"
						STR0162 + ' [' + AllToChar( aErroMVC[5] ) + ']',;	//"Id do erro:"
						STR0163 + ' [' + AllToChar( aErroMVC[6] ) + ']',;	//"Mensagem do erro:"
						STR0164 + ' [' + AllToChar( aErroMVC[7] ) + ']',;	//"Mensagem da solu��o:"
						STR0165 + ' [' + AllToChar( aErroMVC[8] ) + ']',;	//"Valor atribu�do:"
						STR0166 + ' [' + AllToChar( aErroMVC[9] ) + ']';	//"Valor anterior:"
						})
						DisarmTransacation()
						oMdl550:DeActivate()
					EndIf
				End Transaction
				(cQry)->(DbSkip())
				oMdl550:DeActivate()
			End
			(cQry)->(DbCloseArea())
		Next nX

		If !EMPTY(aErrors)
			cMsg += STR0167 + " " + cValToChar(nCount) + CRLF	//"Total de manuten��es processadas:"
			cMsg += STR0168 + " " + cValToChar(nCount - nFail) + CRLF	//"Total de manuten��es exclu�das:"
			cMsg += STR0169 + " " + cValToChar(nFail) + CRLF + CRLF	//"Total de manuten��es n�o exclu�das:"
			cMsg += STR0170 + CRLF + CRLF	//"As manuten��es abaixo n�o foram exclu�das: "
			For nX := 1 To LEN(aErrors)
				For nY := 1 To LEN(aErrors[nX])
					cMsg += aErrors[nX][nY] + CRLF
				Next
				cMsg += CRLF + REPLICATE("-",30) + CRLF
			Next
			cMsg += CRLF + STR0171	//"Por favor, utilize a exclus�o individual destes registros para mais detalhes do ocorrido."
			If !lSemTela
				AtShowLog(cMsg,STR0172,/*lVScroll*/,/*lHScroll*/,/*lWrdWrap*/,.F.)	//"Exclus�o das manuten��es"
			EndIf
		ElseIf !lSemTela
			MsgInfo(cValToChar(nCount) + STR0173)	//" registro(s) exclu�do(s)"
		EndIf

		FWModelActive(oMdlAtv)
	ElseIf !lSemTela
		Help(,1,"At190DlAll",,STR0476, 1) //"Usu�rio sem permiss�o de realizar manuten��o na agenda"
	EndIf

	cFilAnt := cBkpFil

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At190dMark

@description Verifica se algum registro do grid MAN est� marcado

@author	boiani
@since	06/07/2019
/*/
//------------------------------------------------------------------------------
Function At190dMark()
	Local lRet := .F.
	Local nX

	For nX := 1 To LEN(aMarks)
		If (lRet := !EMPTY(aMarks[nX][1]))
			Exit
		EndIf
	Next nX

	If !lRet
		Help(,,"At190dMark",,STR0174,1,0)	//"Para incluir uma Manuten��o na Agenda, � necess�rio selecionar ao menos um registro da agenda do atendente"
	EndIf

Return lRet
//------------------------------------------------------------------------------
/*/{Protheus.doc} AllowedTypes

@description Retorna em formato de Array os ABN_TIPOs permitidos

@author	boiani
@since	06/07/2019
/*/
//------------------------------------------------------------------------------
Static Function AllowedTypes()
	Local aRet := {'01',;	//FALTA
	'02',;	//ATRASO
	'03',;	//SAIDA ANTECIPADA
	'04',;	//HORA EXTRA
	'05',;	//CANCELAMENTO DE AGENDA
	'',;	//TRANSFERENCIA - [Descontinuado]
	'07',;	//AUSENCIA
	'08',;	//REALOCA��O
	'09'}	//COMPENSA��O
	Local aRet2 := {}
	Local aInfo := {}
	Local nX
	Local nY
	Local lMV_MultFil := TecMultFil() //Indica se a Mesa considera multiplas filiais
	Local cFil1 := ""
	Local lContinua := .T.

	If lMV_MultFil
		For nX := 1 To LEN(aMarks)
			If !EMPTY(aMarks[nX][1])
				If Empty(cFil1)
					cFil1 := aMarks[nX][12]
				ElseIf cFil1 != aMarks[nX][12]
					lContinua := .F.
				EndIf
			EndIf
		Next nX
	EndIf
	If lContinua
		For nX := 1 To LEN(aMarks)
			If !EMPTY(aMarks[nX][1])
				If Empty(aInfo)
					AADD(aInfo, {aMarks[nX][2],; //ABB_DTINI
					aMarks[nX][3],; //ABB_HRINI
					aMarks[nX][4],; //ABB_DTFIM
					aMarks[nX][5]}) //ABB_HRFIM
				Else
					For nY := 1 To LEN(aInfo)
						If HrsToVal(aInfo[nY][2]) != HrsToVal(aMarks[nX][3])
							aRet[2] := ""
							aRet[7] := ""
							aRet[4] := ""
						EndIf
						If HrsToVal(aInfo[nY][4]) != HrsToVal(aMarks[nX][5])
							aRet[3] := ""
							aRet[7] := ""
							aRet[4] := ""
						EndIf
					Next nY
					AADD(aInfo, {aMarks[nX][2],; //ABB_DTINI
					aMarks[nX][3],; //ABB_HRINI
					aMarks[nX][4],; //ABB_DTFIM
					aMarks[nX][5]}) //ABB_HRFIM
				EndIf
			EndIf
		Next nX
	Else
		For Nx := 1 To LEN(aRet)
			aRet[nX] := ""
		Next Nx
	EndIf

	For nY := 1 TO LEN(aRet)
		If !EMPTY(aRet[nY])
			AADD(aRet2, aRet[nY])
		EndIF
	Next nY

Return aRet2
//------------------------------------------------------------------------------
/*/{Protheus.doc} At190OpMan

@description Altera o WHEN dos demais campos da Manuten��o, dependendo do Motivo selecionado

@author	boiani
@since	06/07/2019
/*/
//------------------------------------------------------------------------------
Function At190OpMan(lRefresh)
	Local oView := FwViewActive()
	Local oModel := FwModelActive()
	Local oMdlMAN := oModel:GetModel("MANMASTER")
	Local oStrMAN := oMdlMAN:GetStruct()
	Local cTipo
	Local aAux := {}
	Local nX
	Local lMV_MultFil := TecMultFil() //Indica se a Mesa considera multiplas filiais
	Local cFil1 := ""
	Local lContinua := .T.
	Default lRefresh := .T.

	If lMV_MultFil
		For nX := 1 To Len(aMarks)
			If !EMPTY(aMarks[nX][1])
				If Empty(cFil1)
					cFil1 := aMarks[nX][12]
				ElseIf cFil1 != aMarks[nX][12]
					lContinua := .F.
					Exit
				EndIf
			EndIf
		Next nX
	Else
		cFil1 := cFilAnt
	EndIf

	If lContinua
		cTipo := GetTipoABN(oMdlMAN:GetValue("MAN_MOTIVO"), cFil1)
		aAux := CposxTipo(cTipo)

		CleanMAN(oMdlMAN, .F.)

		For nX := 1 TO LEN(aAux)
			oStrMAN:SetProperty(aAux[nX] , MODEL_FIELD_WHEN, {|| .T.})
			oMdlMAN:LoadValue("MAN_HRINI" ,aMarks[ASCAN(aMarks, {|a| !EMPTY(a[1])})][3])
			oMdlMAN:LoadValue("MAN_HRFIM" ,aMarks[ASCAN(aMarks, {|a| !EMPTY(a[1])})][5])
		Next nX

		If lRefresh
			oView:Refresh('VIEW_MAN')
		EndIf
	EndIf
Return
//------------------------------------------------------------------------------
/*/{Protheus.doc} At190dMntP

@description Valida o c�digo da manuten��o

@author	boiani
@since	06/07/2019
/*/
//------------------------------------------------------------------------------
Function At190dMntP(cABN_CODIGO)
	Local lMV_MultFil := TecMultFil() //Indica se a Mesa considera multiplas filiais
	Local nX
	Local cFil1 := ""
	Local lRet := .T.
	If lMV_MultFil
		For nX := 1 To LEN(aMarks)
			If !Empty(aMarks[nX])
				If EMPTY(cFil1)
					cFil1 := aMarks[nX][12]
				ElseIf cFil1 != aMarks[nX][12]
					lRet := .F.
					Help( " ", 1, "MULTFIL", Nil, STR0479, 1 )
					//"A inclus�o de manuten��es em lote s� pode ser executada em registros da mesma filial. Selecione apenas registros da mesma filial e execute a inclus�o."
					Exit
				EndIf
			Endif
		Next nX
	Else
		cFil1 := cFilAnt
	EndIf

Return lRet .AND. (ASCAN(AllowedTypes(), GetTipoABN(cABN_CODIGO, cFIl1))) > 0
//------------------------------------------------------------------------------
/*/{Protheus.doc} GetTipoABN

@description Retorna o ABN_TIPO apartir de um ABN_CODIGO

@author	boiani
@since	06/07/2019
/*/
//------------------------------------------------------------------------------
Static Function GetTipoABN(cCodigo, cFil)
	Local cRet := ""
	Local aArea := GetArea()
	Local cQry := GetNextAlias()
	Local cFilABN
	Default cFil := cFilAnt
	cCodigo := AT190dLimp(cCodigo)
	cFilABN := xFilial("ABN",cFil)
	BeginSQL Alias cQry
	SELECT ABN.ABN_TIPO
	  FROM %Table:ABN% ABN
	 WHERE ABN.ABN_FILIAL = %Exp:cFilABN%
	   AND ABN.%NotDel%
	   AND ABN.ABN_CODIGO = %Exp:cCodigo%
	EndSQL

	cRet := (cQry)->(ABN_TIPO)
	(cQry)->(DbCloseArea())

	RestArea(aArea)

Return cRet
//------------------------------------------------------------------------------
/*/{Protheus.doc} CposxTipo

@description Retorna quais campos podem ser modificados de acordo com o tipo da Manuten��o

@author	boiani
@since	06/07/2019
/*/
//------------------------------------------------------------------------------
Static Function CposxTipo(cTipo)
	Local aRet := {}

	If cTipo == '01' //Falta
		AADD(aRet, "MAN_CODSUB")
		AADD(aRet, "MAN_TIPDIA")
	ElseIf cTipo == '02' //Atraso
		AADD(aRet, "MAN_HRINI")
		AADD(aRet, "MAN_CODSUB")
		AADD(aRet, "MAN_TIPDIA")
	ElseIf cTipo == '03' //Sa�da Antecipada
		AADD(aRet, "MAN_HRFIM")
		AADD(aRet, "MAN_CODSUB")
		AADD(aRet, "MAN_TIPDIA")
	ElseIf cTipo == '04' //Hora Extra
		AADD(aRet, "MAN_HRINI")
		AADD(aRet, "MAN_HRFIM")
		AADD(aRet, "MAN_USASER")
	ElseIf cTipo == '05' //Cancelamento
		AADD(aRet, "MAN_CODSUB")
		AADD(aRet, "MAN_TIPDIA")
	ElseIf cTipo == '07' //Aus�ncia
		AADD(aRet, "MAN_HRINI")
		AADD(aRet, "MAN_HRFIM")
		AADD(aRet, "MAN_CODSUB")
	ElseIf cTipo $ '08*09' //Realoca��o
		AADD(aRet, "MAN_CODSUB")
		AADD(aRet, "MAN_TIPDIA")
	EndIf

Return aRet
//------------------------------------------------------------------------------
/*/{Protheus.doc} CleanMAN

@description Limpa os fields do model de manuten��o e trava o WHEN dos campos

@author	boiani
@since	06/07/2019
/*/
//------------------------------------------------------------------------------
Static Function CleanMAN(oMdlMan, lClnMotivo, lRefresh)
	Local oStrMAN := oMdlMAN:GetStruct()
	Local oView := FwViewActive()

	Default lClnMotivo := .T.
	Default lRefresh := .T.

	oStrMAN:SetProperty("MAN_HRINI" , MODEL_FIELD_WHEN, {|| .F.})
	oStrMAN:SetProperty("MAN_HRFIM" , MODEL_FIELD_WHEN, {|| .F.})
	oStrMAN:SetProperty("MAN_CODSUB", MODEL_FIELD_WHEN, {|| .F.})
	oStrMAN:SetProperty("MAN_USASER", MODEL_FIELD_WHEN, {|| .F.})
	oStrMAN:SetProperty("MAN_TIPDIA", MODEL_FIELD_WHEN, {|| .F.})

	If lClnMotivo
		oMdlMAN:ClearField("MAN_MOTIVO")
	EndIf

	oMdlMAN:ClearField("MAN_HRINI" )
	oMdlMAN:ClearField("MAN_HRFIM" )
	oMdlMAN:ClearField("MAN_CODSUB")
	oMdlMAN:LoadValue("MAN_USASER","2")
	oMdlMAN:ClearField("MAN_TIPDIA")
	oMdlMAN:ClearField("MAN_MODDT")
	oMdlMAN:LoadValue("MAN_MODFIM", 0)
	oMdlMAN:LoadValue("MAN_MODINI", 0)

	If !isBlind() .AND. lRefresh
		oView:Refresh('VIEW_MAN')
	EndIf

Return
//------------------------------------------------------------------------------
/*/{Protheus.doc} AT190dInMn

@description Chama a fun��o AT190dIMn2 dentro de um MsgRun

@author	boiani
@since	06/07/2019
/*/
//------------------------------------------------------------------------------
Function AT190dInMn()
	FwMsgRun(Nil,{|| AT190dIMn2()}, Nil, STR0175)	//"Inserindo Manuten��es..."
Return
//------------------------------------------------------------------------------
/*/{Protheus.doc} AT190dIMn2

@description Inclui manuten��es da agenda em lote

@author	boiani
@since	06/07/2019
/*/
//------------------------------------------------------------------------------
Static Function AT190dIMn2()
	Local oModel := FwModelActive()
	Local oView	 := FwViewActive()
	Local oMdlMAN := oModel:GetModel("MANMASTER")
	Local oMdlABB := oModel:GetModel("ABBDETAIL")
	Local oMdl550 := nil
	Local cMotivo := oMdlMAN:GetValue("MAN_MOTIVO")
	Local cHrIni := oMdlMAN:GetValue("MAN_HRINI")
	Local cHrFim := oMdlMAN:GetValue("MAN_HRFIM")
	Local cCodSub := oMdlMAN:GetValue("MAN_CODSUB")
	Local cUsaServ := oMdlMAN:GetValue("MAN_USASER")
	Local cTipoDia := oMdlMAN:GetValue("MAN_TIPDIA")
	Local cFil1 := ""
	Local cDtIniAux := ""
	Local cTitle := ""
	Local cMsg := ""
	Local cAuxTpos := ""
	Local cRtMotivo := ""
	Local cFilBkp := cFilAnt
	Local nDiasINI := oMdlMAN:GetValue("MAN_MODINI")
	Local nDiasFIM := oMdlMAN:GetValue("MAN_MODFIM")
	Local nCount := 0
	Local nFail := 0
	Local nY := 1
	Local nX := 0
	Local aDuplics := {}
	Local aDataRef := {}
	Local aErrors := {}
	Local aErroMVC := {}
	Local aMarkCert	:= {}
	Local aAuxMarks := {}
	Local aSubResTc := {}
	Local lRet := .T.
	Local lFirst := .T.
	Local lReplica := .F.
	Local lHelp	:= .T.
	Local lContinua := .T.
	Local lMV_MultFil := TecMultFil() //Indica se a Mesa considera multiplas filiais
	Local lPrHora 	:= TecABBPRHR()

	If !IsBlind()
		At550Reset()
	EndIf
	If lMV_MultFil
		For nY := 1 To LEN(aMarks)
			If !EMPTY(aMarks[nY][1])
				If EMPTY(cFil1)
					cFil1 := aMarks[nY][12]
				ElseIf cFil1 != aMarks[nY][12]
					lContinua := .F.
					Exit
				EndIf
			EndIf
		Next nY
		If lContinua
			cFilAnt := cFil1
		EndIf
	Else
		cFil1 := cFilAnt
	EndIf

	nY := 1
	cAuxTpos := GetTipoABN(cMotivo)
	cRtMotivo := AbnByType("05")

	ABR->(DbSetOrder(1))

	For nY := 1 To LEN(aMarks)
		If !EMPTY(aMarks[nY][1])
			If ABR->(MsSeek(xFilial("ABR") + aMarks[nY][1]))
				If GetTipoABN(ABR->ABR_MOTIVO) == '09'
					lContinua := .F.
					Help(,1,"AT190dIMn2",,STR0592, 1) //"N�o � possivel adicionar novas manuten��es em um dia que j� possu� manuten��o de compensa��o."
					lHelp := .F.
					Exit
				EndIf
			EndIf
		EndIf
	Next nY

	nY := 1

	If lContinua
		If At680Perm(NIL, __cUserId, "038", .T.)
			While nY <= LEN(aMarks)
				If !EMPTY(aMarks[nY][1])

					If !EMPTY(cCodSub)
						If cDtIniAux <> dToS(aMarks[nY][9]) .AND. cAuxTpos <> "08"
							cDtIniAux := dToS(aMarks[nY][9])
							at190sbtc(cCodSub, cDtIniAux, @aSubRestc, aMarks[nY][8]) // Valida se o substituto est� alocado em reserva t�cnica
						EndIf
					EndIf
					If (!EMPTY(cRtMotivo) .AND. !EMPTY(aSubRestc)) .OR. EMPTY(aSubRestc)
						nCount++
						If lFirst
							lFirst := .F.
							If cAuxTpos $ "01|05|08|09" //Falta | Cancelamento | Realoca��o | Compensa��o
								For nX := 1 To oMdlABB:Length()
									oMdlABB:GoLine(nX)
									If ASCAN(aMarks, {|a| !EMPTY(a[1]) .AND. a[8] == oMdlABB:GetValue("ABB_IDCFAL") .AND. a[9] == oMdlABB:GetValue("ABB_DTREF") }) > 0 .AND. !(oMdlABB:GetValue("ABB_MARK"))
										AADD(aDuplics, {oMdlABB:GetValue("ABB_CODIGO"),;
											oMdlABB:GetValue("ABB_DTINI"),;
											oMdlABB:GetValue("ABB_DTFIM"),;
											oMdlABB:GetValue("ABB_DTREF"),;
											oMdlABB:GetValue("ABB_HRINI"),;
											oMdlABB:GetValue("ABB_HRFIM"),;
											oMdlABB:GetValue("ABB_ATENDE"),;
											oMdlABB:GetValue("ABB_CHEGOU")})
									EndIf
								Next nX
							EndIf
							If !Empty(aDuplics) .And. (lReplica := MsgYesNo(STR0176))	//"Replicar a falta/cancelamento para todos os per�odos dos dias trabalhados?"
								For nX := 1 To LEN(aDuplics)
									AADD(aMarks, {aDuplics[nX][1],;		//01 - ABB_CODIGO
									aDuplics[nX][2],;	//02 - ABB_DTINI (D)
									aDuplics[nX][5],;	//03 - ABB_HRINI
									aDuplics[nX][3],;	//04 - ABB_DTFIM
									aDuplics[nX][6],;	//05 - ABB_HRFIM
									aDuplics[nX][7],;	//06 - ABB_ATENDE
									aDuplics[nX][8],;	//07 - ABB_CHEGOU
									"",;					//08 - ABB_IDCFAL
									aDuplics[nX][4],;	//09 - ABB_DTREF
									.F.,;				//10 - lResTec (ABS_RESTEC)
									""})				//11 - TFF_COD
								Next nX
							EndIf
						EndIf
						If (!lReplica .AND. !Empty(aDuplics)) .AND. cAuxTpos == '09'
							lContinua := .F.
							Help(,1,"AT190dIMn2",,STR0593, 1) //"� necess�rio replicar a manuten��o para todos os per�odos para utilizar a manuten��o do tipo compensa��o."
							Exit
						EndIf
						ABB->(DbSetOrder(8))
						ABB->(MsSeek(xFilial("ABB") + aMarks[nY][1]))

						ABQ->(DbSetOrder(1))
						ABQ->(MsSeek(xFilial("ABQ") + ABB->ABB_IDCFAL))

						TFF->(DbSetOrder(1))
						TFF->(MsSeek(xFilial("TFF") + ABQ->ABQ_CODTFF))

						At550SetAlias("ABB")
						At550SetGrvU(.T.)

						oMdl550 := FwLoadModel("TECA550")
						oMdl550:SetOperation( MODEL_OPERATION_INSERT)
						If lRet := oMdl550:Activate()
							lRet := lRet .AND. oMdl550:SetValue("ABRMASTER","ABR_MOTIVO", cMotivo)
							If cAuxTpos $ "02|04"
								lRet := lRet .AND. oMdl550:SetValue("ABRMASTER","ABR_DTINI", (aMarks[nY][2] + nDiasINI))
								lRet := lRet .AND. oMdl550:SetValue("ABRMASTER","ABR_HRINI", cHrIni )
							EndIf
							If cAuxTpos $ "03|04"
								lRet := lRet .AND. oMdl550:SetValue("ABRMASTER","ABR_DTFIM", (aMarks[nY][4] + nDiasFIM))
								lRet := lRet .AND. oMdl550:SetValue("ABRMASTER","ABR_HRFIM", cHrFim )
							EndIf
							If cAuxTpos == "07"
								lRet := lRet .AND. oMdl550:SetValue("ABRMASTER","ABR_HRINI", cHrIni )
								lRet := lRet .AND. oMdl550:SetValue("ABRMASTER","ABR_HRFIM", cHrFim )
							EndIf
							If !EMPTY(cCodSub) .AND. cAuxTpos $ "01|02|03|05|07|08|09"
								If cAuxTpos $ "01|05|08|09" .AND. aScan( aDataRef,aMarks[nY][9]) > 0
									lRet := lRet .AND. oMdl550:LoadValue("ABRMASTER","ABR_CODSUB", cCodSub )
								Else
									lRet := lRet .AND. oMdl550:SetValue("ABRMASTER","ABR_CODSUB", cCodSub )
									If lRet .AND. cAuxTpos $ "01|05|08|09"
										AADD(aDataRef, aMarks[nY][9])
									EndIf
								EndIf
							EndIf
							If !EMPTY(cUsaServ) .AND. cAuxTpos == "04"
								lRet := lRet .AND. oMdl550:SetValue("ABRMASTER","ABR_USASER", cUsaServ )
							EndIf
							If !EMPTY(cTipoDia) .AND. cAuxTpos $ "01|02|03|05|08|09"
								lRet := lRet .AND. oMdl550:SetValue("ABRMASTER","ABR_TIPDIA", cTipoDia )
							EndIf
							lRet := lRet .AND. oMdl550:SetValue("ABRMASTER","ABR_OBSERV", At190dMsgM())
							If lRet
								Begin Transaction
									If !oMdl550:VldData() .OR. !oMdl550:CommitData()
										nFail++
										aErroMVC := oMdl550:GetErrorMessage()
										at190err(@aErrors, aErroMVC, aMarks[nY][9])
										DisarmTransacation()
										oMdl550:DeActivate()
									Else
										AADD(aMarkCert, aMarks[nY])
									EndIf
								End Transaction
								oMdl550:DeActivate()
							Else
								nFail++
								aErroMVC := oMdl550:GetErrorMessage()
								at190err(@aErrors, aErroMVC, aMarks[nY][9])
								oMdl550:DeActivate()
							EndIf
						Else
							nFail++
							aErroMVC := oMdl550:GetErrorMessage()
							at190err(@aErrors, aErroMVC, aMarks[nY][9])
							oMdl550:DeActivate()
						EndIf
						At550SetAlias("")
						At550SetGrvU(.F.)
					Else
						lContinua := .F.
					EndIf
				EndIf
				nY++
			End

			FwModelActive(oModel)

			If lContinua
				// Cancelamento das agendas de reserva t�cnica, utilizadas na substitui��o.
				If !EMPTY(aSubRestc)
					at190drtc(aSubRestc, @aErrors, @nFail, cRtMotivo)
					FwModelActive(oModel)
				EndIf

				If !EMPTY(aErrors)
					cMsg += STR0167 + " " + cValToChar(nCount) + CRLF	//"Total de manuten��es processadas:"
					cMsg += STR0177 + " " + cValToChar(nCount - nFail) + CRLF	//"Total de manuten��es inclu�das:"
					cMsg += STR0178 + " " + cValToChar(nFail) + CRLF + CRLF	//"Total de manuten��es n�o inclu�das:"
					cMsg += STR0179 + CRLF + CRLF	//"As manuten��es abaixo n�o foram inseridas: "
					For nX := 1 To LEN(aErrors)
						For nY := 1 To LEN(aErrors[nX])
							cMsg += If(Empty(aErrors[nX][nY]), aErrors[nX][nY], aErrors[nX][nY] + CRLF )
						Next
						cMsg += CRLF + REPLICATE("-",30) + CRLF
					Next
					cMsg += CRLF + STR0180	//"Por favor, utilize a op��o 'Manut.Relacionadas' para estes registros para mais detalhes do ocorrido."
					If !ISBlind()
						AtShowLog(cMsg,STR0181,/*lVScroll*/,/*lHScroll*/,/*lWrdWrap*/,.F.)	//"Inclus�o das manuten��es"
					EndIf
				Else
					MsgInfo(cValToChar(nCount) + STR0182)	//" registro(s) inclu�dos(s)"
				EndIf

				If cAuxTpos $ '08|09'
					aAuxMarks := AClone ( aMarks )
					aMarks := AClone( aMarkCert )
					aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,"Salvar"},{.T.,"Cancelar"},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil}}
					If cAuxTpos == '08'
						cExecView := 'TECA190F'
						cTitle := STR0357 //"Realoca��o"
					ElseIf cAuxTpos == '09'
						cExecView := 'TECA190H'
						cTitle := STR0594 //"Compensa��o"
					EndIf
					If FwExecView( cTitle, "VIEWDEF."+cExecView, MODEL_OPERATION_INSERT, /*oOwner*/, {||.T.}, /*bOk*/, 45, aButtons ) == 1
						//Cancelou
						If cAuxTpos == '09'
							For nX := 1 To Len(aMarks)
								If !EMPTY(aMarks[nX][1]) .AND. HasABR(aMarks[nX][1],aMarks[nX][12])
									cFiltro550 += "(ABR_AGENDA='"+aMarks[nX][1] + "'.AND. ABR_FILIAL='"+xFilial("ABR",aMarks[nX][12])+"').OR."
								EndIf
							Next nX
							At550SetAlias("ABB")
							At550SetGrvU(.T.)

							At190DlAll(.T.)

							cFiltro550 := ""
							At550SetAlias("")
							At550SetGrvU(.F.)
						EndIf
					EndIf
					aMarks := AClone ( aAuxMarks )
				EndIf

				At550Reset()
				At190DLoad()

				If !isBlind()
					oView:Refresh('VIEW_MAN')
				EndIf
			Else
				Help( " ", 1, "AT190DMANUT", Nil, STR0358 , 1,,,,,,,;
					{ STR0359 } ) //"N�o foi poss�vel concluir a opera��o."#"Cadastre um motivo de manuten��o do tipo cancelamento."
			EndIf
		Else
			Help(,1,"AT190dIMn2",,STR0476, 1) //"Usu�rio sem permiss�o de realizar manuten��o de agenda"
			At190DLoad()
		EndIf
	Else
		If lHelp
			Help( " ", 1, "MULTFIL", Nil, STR0479, 1 )
			//"A inclus�o de manuten��es em lote s� pode ser executada em registros da mesma filial. Selecione apenas registros da mesma filial e execute a inclus�o."
		EndIf
	EndIf

	cFilAnt := cFilBkp
Return aErrors
//------------------------------------------------------------------------------
/*/{Protheus.doc} At190DExp

@description Fun��o para realizar a chamada na impress�o do .CSV

@param cAba - Nome do Aba que ser� exportada

@author	Luiz Gabriel
@since	01/07/2019
/*/
//------------------------------------------------------------------------------
Static Function At190DExp(cAba)
	Local oModel	:= FwModelActive()
	Local cIdMdl	:= ""
	Local cIdView	:= ""
	Local cIdVwS	:= ""
	Local aIncCpo	:= {}
	Local aNoCpo	:= {}
	Local aLegenda	:= {}
	Local cMdlID	:= oModel:GetId()
	Local cIdSub	:= ""
	Local aLegendaS	:= {}
	Local aNoCpoS	:= {}
	Local aIncCpoS	:= {}
	Local aNoCposU	:= {}
	Local aCpoVwS	:= {}

	Do Case
	Case cAba == STR0325 // "Agendas Projetadas"
		cIdMdl 		:= "LOCDETAIL"
		cIdView 	:= "DETAIL_LOC"
		At190LgLOC(@aLegenda,"LOC_LEGEND")
		TecGrd2CSV(cAba,cIdMdl,cIdView,,,aLegenda,cMdlID)
	Case cAba == STR0327 // "Controle de Aloca��o"
		cIdMdl 		:= "HOJDETAIL"
		cIdView 	:= "DETAIL_HOJ"
		aIncCpo		:= {{"VIEW_DTR","DTRMASTER",{"DTR_DTREF"}},{"VIEW_TFL","TFLMASTER",{"TFL_TFFCOD","TFL_PROD"}}}
		At190LgHJ(@aLegenda)
		TecGrd2CSV (cAba,cIdMdl,cIdView,,aIncCpo,aLegenda, cMdlID)
	Case cAba ==  STR0324 //"Manuten��o"
		cIdMdl 		:= "ABBDETAIL"
		cIdView 	:= "DETAIL_ABB"
		aNoCpo		:= {"ABB_MARK"}
		aIncCpo		:= {{"VIEW_MASTER","AA1MASTER",{"AA1_CODTEC","AA1_NOMTEC"}}}
		At190LgLOC(@aLegenda)
		TecGrd2CSV(cAba,cIdMdl,cIdView,aNoCpo,aIncCpo,aLegenda, cMdlID)
	Case cAba == STR0326 //"Aloca��o"
		cIdMdl 		:= "ALCDETAIL"
		cIdView 	:= "DETAIL_ALC"
		aIncCpo		:= {{"VIEW_MASTER","AA1MASTER",{"AA1_CODTEC","AA1_NOMTEC"}}}
		At190dAge(@aLegenda,"ALC_SITALO")
		At190AGtLA(@aLegenda,"ALC_SITABB")
		TecGrd2CSV(cAba,cIdMdl,cIdView,,aIncCpo,aLegenda, cMdlID, "ALC_DATREF")
	Case cAba == STR0399 // "Aloca��es em Lote"
		cIdMdl		:= "LGYDETAIL"
		cIdSub		:= "LACDETAIL"
		cIdView		:= "DETAIL_LGY"
		aIncCpo		:= {}
		cIdVwS		:= "DETAIL_LAC"
		At190LgMl(@aLegenda)
		At190dAge(@aLegendaS,"LAC_SITALO")
		At190AGtLA(@aLegendaS,"LAC_SITABB")

		TecGrd2CSV(cAba, cIdMdl, cIdView,, aIncCpo,aLegenda, cMdlID, , cIdSub, cIdVwS,,,aLegendaS )
	End Case

Return ( .T. )


//------------------------------------------------------------------------------
/*/{Protheus.doc} At190LgLOC
Retorna array com a regra de legenda, utilizado na exporta��o do CSV

@author		Luiz Gabriel
@since		03/07/2019
@version	P12.1.23
/*/
//------------------------------------------------------------------------------
Static Function At190LgLOC(aLegenda, cLegName)
	Local nLen 			:= 0

	Default aLegenda	:= {}
	Default cLegName	:= "ABB_LEGEND"

	aAdd( aLegenda, { cLegName, {}} )

	nLen := len(aLegenda)
	aAdd(aLegenda[nLen][2], {"BR_PRETO"	 	, STR0190} )		//"Agenda Atendida"
	aAdd(aLegenda[nLen][2], {"BR_MARROM"		, STR0049} )		//"Agenda com Manuten��o"
	aAdd(aLegenda[nLen][2], {"BR_VERMELHO"  	, STR0050} )		//"Excedente"
	aAdd(aLegenda[nLen][2], {"BR_AMARELO"  	, STR0051} )		//"Cobertura"
	aAdd(aLegenda[nLen][2], {"BR_VERDE"		, STR0052} )		//"Efetivo"
	aAdd(aLegenda[nLen][2], {"BR_LARANJA"  	, STR0053} )		//"Apoio"
	aAdd(aLegenda[nLen][2], {"BR_CINZA"		, STR0054} )		//"Curso"
	aAdd(aLegenda[nLen][2], {"BR_BRANCO"		, STR0055} )		//"Cortesia"
	aAdd(aLegenda[nLen][2], {"BR_AZUL"	 	    , STR0056} )		//"Treinamento"
	aAdd(aLegenda[nLen][2], {"BR_PINK"		    , STR0057} )		//"Outros Tipos"

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At190LgHJ
Retorna array com a regra de legenda, utilizado na exporta��o do CSV

@author		Luiz Gabriel
@since		03/07/2019
@version	P12.1.23
/*/
//------------------------------------------------------------------------------
Static Function At190LgHJ(alegenda)

	Local nLen := 0
	Default aLegenda	:= {}

	aAdd( aLegenda, {"HOJ_LEGEND", {}} )
	nLen := len(aLegenda)
	aAdd(aLegenda[nLen][2], {"BR_MARROM"		, STR0049} )		//"Agenda com Manuten��o"
	aAdd(aLegenda[nLen][2], {"BR_VERMELHO" 	, STR0050} )		//"Excedente"
	aAdd(aLegenda[nLen][2], {"BR_AMARELO"  	, STR0051} )		//"Cobertura"
	aAdd(aLegenda[nLen][2], {"BR_VERDE"		, STR0052} )		//"Efetivo"
	aAdd(aLegenda[nLen][2], {"BR_LARANJA" 	    , STR0053} ) 		//"Apoio"
	aAdd(aLegenda[nLen][2], {"BR_PRETO"		, STR0054} )		//"Curso"
	aAdd(aLegenda[nLen][2], {"BR_BRANCO"	 	, STR0055} )		//"Cortesia"
	aAdd(aLegenda[nLen][2], {"BR_AZUL"	    	, STR0056} )		//"Treinamento"
	aAdd(aLegenda[nLen][2], {"BR_PINK"	    	, STR0057} )		//"Outros Tipos"
	aAdd(aLegenda[nLen][2], {"BR_VIOLETA"		, STR0058} )		//"Folga"
	aAdd(aLegenda[nLen][2], {"BR_CINZA"		, STR0059} )		//"Agenda n�o projetada"

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At190AGtLA
Retorna array com a regra de legenda, utilizado na exporta��o do CSV
At190AGtLA

@author		Luiz Gabriel
@since		03/07/2019
@version	P12.1.23
/*/
//------------------------------------------------------------------------------
Static Function At190AGtLA(aLegenda, cLegName)

	Local nLen			:= 0
	Default aLegenda	:= {}
	Default cLegName	:= "ALC_SITABB"
	aAdd( aLegenda, { cLegName, {}} )
	nLen := len(aLegenda)
	aAdd( aLegenda[nLen][2], {"BR_VERMELHO", STR0189} )	//"Agenda Gerada"
	aAdd( aLegenda[nLen][2], {"BR_AMARELO" , STR0190} )	//"Agenda Atendida"
	aAdd( aLegenda[nLen][2], {"BR_VERDE"	 , STR0191} )	//"Agenda N�o Gerada"
	aAdd( aLegenda[nLen][2], {"BR_LARANJA" , STR0049} )	//"Agenda com Manuten��o"
	aAdd( aLegenda[nLen][2], {"BR_PRETO"	 , STR0192} )	//"Conflito de Aloca��o"
	aAdd( aLegenda[nLen][2], {"BR_PINK"	 , STR0322} )	//"Atendente com agenda em reverva t�cnica"

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At190dAge
Retorna array com a regra de legenda, utilizado na exporta��o do CSV
At330AGtLS

@author		Luiz Gabriel
@since		03/07/2019
@version	P12.1.23
/*/
//------------------------------------------------------------------------------
Static Function At190dAge(aLegenda,cLegName)
	Local nLen			:= 0
	Default aLegenda	:= {}
	Default cLegName	:= "ALC_SITALO"

	aAdd( aLegenda, { cLegName, {}} )
	nLen := len(aLegenda)
	aAdd( aLegenda[nLen][2], {"BR_VERDE"   , STR0193} )	//"Trabalhado"
	aAdd( aLegenda[nLen][2], {"BR_AMARELO" , STR0194} )	//"Compensado"
	aAdd( aLegenda[nLen][2], {"BR_AZUL"	 , STR0195} )	//"D.S.R."
	aAdd( aLegenda[nLen][2], {"BR_LARANJA" , STR0490} )	//"hora extra"
	aAdd( aLegenda[nLen][2], {"BR_PRETO"   , STR0196} )	//"Intervalo"
	aAdd( aLegenda[nLen][2], {"BR_VERMELHO", STR0197} )	//"N�o Trabalhado"

Return
//------------------------------------------------------------------------------
/*/{Protheus.doc} At190MODDT

@description Preenche os campos de "virada de dia" ao digitar os hor�rios da manuten��o

@author	boiani
@since	06/07/2019
/*/
//------------------------------------------------------------------------------
Function At190MODDT(cCpo)
	Local oModel := FwModelActive()
	Local oMdlMAN := oModel:GetModel("MANMASTER")
	Local cHIniMark
	Local cHFimMark
	Local dDiniMark
	Local dDfimMark
	Local cNewHora := oMdlMAN:GetValue(cCpo)
	Local cTipo := GetTipoABN(oMdlMAN:GetValue("MAN_MOTIVO"))
	Local nAux
	Local cMsg := ""

	If (nAux := ASCAN(aMarks, {|a| !EMPTY(a[1])})) > 0
		cHIniMark := aMarks[nAux][3]
		cHFimMark := aMarks[nAux][5]
		dDiniMark := aMarks[nAux][2]
		dDfimMark := aMarks[nAux][4]
		If cTipo  == '04' .AND. cCpo == "MAN_HRINI" .AND. HrsToVal(cNewHora) > HrsToVal(cHIniMark)
			cMsg := STR0198 + "(" + dTOC(dDiniMark) + " -> " + dTOC(dDiniMark - 1) + ")"	//"A hora extra modificar� a data de in�cio da agenda. "
			oMdlMAN:LoadValue("MAN_MODINI", oMdlMAN:GetValue("MAN_MODINI") - 1)
		ElseIf cTipo  == '02' .AND. cCpo == "MAN_HRINI" .AND. HrsToVal(cNewHora) < HrsToVal(cHIniMark)
			cMsg := STR0199 + "(" + dTOC(dDiniMark) + " -> " + dTOC(dDiniMark + 1) + ")"	//"O atraso modificar� a data de in�cio da agenda. "
			oMdlMAN:LoadValue("MAN_MODINI", oMdlMAN:GetValue("MAN_MODINI") + 1)
		ElseIf cTipo  == '03' .AND. cCpo == "MAN_HRFIM" .AND. HrsToVal(cNewHora) > HrsToVal(cHFimMark)
			cMsg := STR0200 + "(" + dTOC(dDfimMark) + " -> " + dTOC(dDfimMark - 1) + ")"	//"A sa�da antecipada modificar� a data de t�rmino da agenda. "
			oMdlMAN:LoadValue("MAN_MODFIM", oMdlMAN:GetValue("MAN_MODFIM") - 1)
		ElseIf  cTipo  == '04' .AND. cCpo == "MAN_HRFIM" .AND. HrsToVal(cNewHora) < HrsToVal(cHFimMark)
			cMsg := STR0201 + "(" + dTOC(dDiniMark) + " -> " + dTOC(dDiniMark + 1) + ")"	//"A hora extra modificar� a data de t�rmino da agenda. "
			oMdlMAN:LoadValue("MAN_MODFIM", oMdlMAN:GetValue("MAN_MODFIM") + 1)
		EndIf
	EndIf

	If !EMPTY(cMsg)
		oMdlMAN:LoadValue("MAN_MODDT", cMsg)
	Else
		oMdlMAN:LoadValue("MAN_MODFIM", 0)
		oMdlMAN:LoadValue("MAN_MODINI", 0)
	EndIf

Return cMsg
//------------------------------------------------------------------------------
/*/{Protheus.doc} At190dGVal

@description Executa um GetValue caso o FwFldGet n�o consiga retornar o valor do campo

@author	boiani
@since	06/07/2019
/*/
//------------------------------------------------------------------------------
Function At190dGVal(cForm, cField)
	Local xValue := FwFldGet(cField)
	Local oModel := FwModelActive()
	Local oSubModel
	If EMPTY(xValue) .AND. VALTYPE(oModel) == "O"
		oSubModel := oModel:GetModel(cForm)
		If VALTYPE(oSubModel) == "O"
			xValue := oSubModel:GetValue(cField)
		EndIf
	EndIf

Return xValue
//------------------------------------------------------------------------------
/*/{Protheus.doc} At190dMsgM

@description Mensagem inserida nas manuten��es da agenda

@author	boiani
@since	11/07/2019
/*/
//------------------------------------------------------------------------------
Function At190dMsgM()
	Local cRet := STR0202 +;	//"Manuten��o inclu�da atrav�s da Mesa Operacional."
	CRLF + STR0203 + __cUserID + CRLF +;	//"Usu�rio: "
	STR0204 + dToC(Date()) + CRLF +;	//"Data da inclus�o: "
	STR0205 + Time()	//"Hor�rio da inclus�o: "

Return cRet
//------------------------------------------------------------------------------
/*/{Protheus.doc} AT190dVldM

@description P�s-valid do modelo

@author	boiani
@since	11/07/2019
/*/
//------------------------------------------------------------------------------
Function AT190dVldM(oModel)

Return MsgNoYes(STR0206)	//"Confirmar encerramento da rotina? Manuten��es na agenda e aloca��es n�o salvas n�o ser�o inseridas."
//-------------------------------------------------------------------
/*/{Protheus.doc} VldGrvAloc()

Valida se � poss�vel realizar o GravaAloc

@author boiani
@since 10/10/2019
/*/
//------------------------------------------------------------------
Static Function VldGrvAloc(cSitABB, lDelConf,lCancela)
	Local lRet := .T.
	Local nI
	Local oModel := FwModelActive()
	Local oMdlAlc := oModel:GetModel('ALCDETAIL')
	Local lModiff := .F.
	Local lHasBRPret := .F.
	Local cEntrada
	Local cSaida
	Local lPermConfl:= AT680Perm(NIL, __cUserID, "017")
	Local nAviso	:= 0

	Default cSitABB := "BR_VERDE"
	Default lDelConf := .F.

	If EMPTY(aValALC) .AND. oModel:GetId() <> "TECA190G"
		lRet := .F.
		Help(,,"NOPROJ",,STR0265,1,0)	//"� necess�rio projetar a agenda do atendente antes de grav�-la."
	EndIf

	If lRet
		For nI := 1 To oMdlAlc:Length()
			oMdlAlc:GoLine(nI)
			If !oMdlAlc:IsDeleted()
				lModiff := ASCAN(aValALC, {|a| a[01] == oMdlALC:GetValue("ALC_SITABB") .AND.;
					a[02] == oMdlALC:GetValue("ALC_SITALO") .AND.;
					a[03] == oMdlALC:GetValue("ALC_GRUPO") .AND.;
					a[04] == oMdlALC:GetValue("ALC_DATREF") .AND.;
					a[05] == oMdlALC:GetValue("ALC_DATA") .AND.;
					a[06] == oMdlALC:GetValue("ALC_SEMANA") .AND.;
					a[07] == oMdlALC:GetValue("ALC_ENTRADA") .AND.;
					a[08] == oMdlALC:GetValue("ALC_SAIDA") .AND.;
					a[09] == oMdlALC:GetValue("ALC_TIPO") .AND.;
					a[10] == oMdlALC:GetValue("ALC_SEQ") .AND.;
					a[11] == oMdlALC:GetValue("ALC_EXSABB") .AND.;
					a[12] == oMdlALC:GetValue("ALC_KEYTGY") .AND.;
					a[13] == oMdlALC:GetValue("ALC_ITTGY") .AND.;
					a[14] == oMdlALC:GetValue("ALC_TURNO") .AND.;
					a[15] == oMdlALC:GetValue("ALC_ITEM") }) == 0
				If oMdlAlc:GetValue("ALC_SITABB") == "BR_PRETO"
					lHasBRPret := .T.
				EndIf

				cEntrada := AllTrim(oMdlAlc:GetValue("ALC_ENTRADA"))
				cSaida   := AllTrim(oMdlAlc:GetValue("ALC_SAIDA"))

				If Alltrim(cEntrada) == ":"
					cEntrada := "FOLGA"
					oMdlAlc:LoadValue("ALC_ENTRADA", cEntrada)
				EndIf

				If Alltrim(cSaida) == ":"
					cSaida := "FOLGA"
					oMdlAlc:LoadValue("ALC_SAIDA", cSaida)
				EndIf

				If 	(cEntrada == "FOLGA" .And. cSaida <> "FOLGA") .Or. ;
						(cEntrada <> "FOLGA" .And. cSaida == "FOLGA")
					Help(,,"At190dAPF",,STR0208 + DtoC(oMdlAlc:GetValue("ALC_DATA")),1,0)	//"Tipo de intervalo incorreto para aloca��o. Dia: "
					lRet := .F.
					Exit
				ElseIf (cEntrada == "FOLGA" .And. cSaida == "FOLGA") .And. ;
						oMdlAlc:GetValue("ALC_TIPO") <> "D" .And. ;
						oMdlAlc:GetValue("ALC_TIPO") <> "N" .And. ;
						oMdlAlc:GetValue("ALC_TIPO") <> "C"
					Help(,,"At190DPFS",,STR0209 + DtoC(oMdlAlc:GetValue("ALC_DATA")),1,0)	//"Tipo de trabalho invalido para o intervalo de horarios! Dia: "
					lRet := .F.
					Exit
				ElseIf (cEntrada <> "FOLGA" .And. cSaida <> "FOLGA") .And. lModiff .And.;
						oMdlAlc:GetValue("ALC_TIPO") $ "D|C|N"
					Help(,,"At190DPSF",,STR0210 + DtoC(oMdlAlc:GetValue("ALC_DATA")),1,0)	//"Tipo de intervalo incorreto para esse tipo de trabalho! Dia: "
					lRet := .F.
					Exit
				EndIf
			EndIf
		Next nI
	EndIf

	If lHasBRPret
		If !lPermConfl
			IF !(lRet := MsgYesNo(STR0211))	//"Existem dias com conflito de aloca��o e o usu�rio n�o possui permiss�o para aloca��o. Alocar apenas os dias sem conflito?"
				Help(,,"NOALOC",,STR0212,1,0)	//"Opera��o de aloca��o cancelada."
			EndIf
			lDelConf := lRet
		Else
			nAviso := Aviso(STR0187,STR0213,{STR0288,STR0287,STR0338},2) ////"Aten��o" # "Um ou mais dias possuem conflito de aloca��o. Deseja alocar o atendente mesmo com os conflitos ou alocar apenas nos dias dispon�veis?" # "Apenas disponiveis" # "Todos os dias" # "Cancelar"
			If nAviso == 3
				lRet := .F.
				lCancela := .T. //Seta a variavel para n�o limpar os arrays de proje��o
			ElseIf !(lDelConf := nAviso == 2)
				cSitABB += "|BR_PRETO"
			EndIf
		EndIf
	EndIf

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} GravaAloc2()

Fun��o de commit da aloca��o do atendente

@author boiani
@since 15/07/2019
/*/
//------------------------------------------------------------------
Static Function GravaAloc2(lExecValid, cSit190F, lPrHora, oMdl )
	Local oModel := IF(IsInCallStack("AT190GCmt"), oMdl, FwModelActive())
	Local oMdlAlc := oModel:GetModel('ALCDETAIL')
	Local oMdlTGY := oModel:GetModel('TGYMASTER')
	Local oMdlAA1 := oModel:GetModel('AA1MASTER')
	Local lResTec := .F.
	Local lChange := .F.
	Local lHasAbbR := .F.
	Local lDelConf := .F.
	Local lOk := .T.
	Local lNenhuma := .F.
	Local lAtDfTGY	:= SuperGetMv("MV_ATDFTGY",,.F.)
	Local nTotHrsTrb := 0
	Local nI := 0
	Local nY := 0
	Local nT := 0
	Local nPosDes := 0
	Local nPosTipMov := 0
	Local nSeq := 0
	Local nPosUltAlo := 0
	Local nTotHor := 0
	Local nPosAloc := 0
	Local nPos := 0
	Local nPosAtend := 0
	Local nPosPriDes := 0
	Local aAloTDV := {}
	Local aUltAloc := {}
	Local aInfo := {}
	Local aCalAtd := {}
	Local aAlocTipMov := {}
	Local aPriDes := {}
	Local aIteABQ := {}
	Local aAloc	:= {}
	Local aSeqs	:= {}
	Local aRDesAloc	:= {}
	Local dUltDatRef := STOD("")
	Local dAloFim
	Local dAloFimOri := STOD("")
	Local cSeq := ""
	Local cTurno := ""
	Local cIdCFal := ""
	Local cHorIni := ""
	Local cHorFim := ""
	Local cAliasABB
	Local cCodTec := oMdlAA1:GetValue("AA1_CODTEC")
	Local cNomTec := oMdlAA1:GetValue("AA1_NOMTEC")
	Local cCodTFF := oMdlTGY:GetValue("TGY_TFFCOD")
	Local cContra := oMdlTGY:GetValue("TGY_CONTRT")
	Local cCodTFL := oMdlTGY:GetValue("TGY_CODTFL")
	Local cTipoAloc := oMdlTGY:GetValue("TGY_TIPALO")
	Local cLocal
	Local cCDFUNC
	Local cFuncao
	Local cProdut
	Local cTurnTFF
	Local cCargoTFF
	Local cSitABB := "BR_VERDE"
	Local cEscala	:= oMdlTGY:GetValue("TGY_ESCALA")
	Local aHorarios := {}
	Local nC := 0
	Local lMV_GSGEHOR := TecXHasEdH()
	Local aBkpMarks := ACLONE(aMarks)
	Local lPegrava  := ExistBlock("At190Dalo")
	Local aInserted := {}
	Local lCancela	:= .F.
	Local lMdtGS 	:= SuperGetMv("MV_NG2GS",.F.,.F.) .And. TableInDic("TN5") .And. TableInDic("TN6")//Par�metro de integra��o entre o SIGAMDT x SIGATEC
	Local lMV_MultFil := TecMultFil() //Indica se a Mesa considera multiplas filiais
	Local cQueryTN5	:= ""
	Local nRecTar	:= 0
	Local dDtIniMdt	:= sTod("")
	Local lNewMdt	:= .F.
	Local cBkpFil	:= cFilAnt
	Local aTabPadrao	:= {}
	Local aTabCalend	:= {}
	Local cFilSR6
	Local nHorMen		:= 0
	Local nHorMai		:= 0
	Local cTotal		:= "00:00"

	Default lExecValid := .T.
	Default cSit190F	:= "BR_VERDE"
	Default lPrHora		:= .F.

	If Empty(cTipoAloc)
		cTipoAloc := "001"
	EndIf

	If lMV_MultFil
		If cFilAnt != oMdlTGY:GetValue("TGY_FILIAL")
			cFilAnt := oMdlTGY:GetValue("TGY_FILIAL")
		EndIf
	EndIf

	cFilSR6	:= xFilial("SR6")
	cLocal := POSICIONE("TFL",1,xFilial("TFL") + cCodTFL,"TFL_LOCAL")
	cCDFUNC := Posicione("AA1",1,xFilial("AA1")+cCodTec, "AA1_CDFUNC")
	cFuncao := Posicione("TFF",1,xFilial("TFF") + cCodTFF,"TFF_FUNCAO")
	cProdut := Posicione("TFF",1,xFilial("TFF") + cCodTFF,"TFF_PRODUT")
	cTurnTFF := Posicione("TFF",1,xFilial("TFF") + cCodTFF,"TFF_TURNO")
	cCargoTFF := Posicione("TFF",1,xFilial("TFF") + cCodTFF,"TFF_CARGO")

	dbSelectArea("ABQ")
	ABQ->(dbSetOrder(3))

	If lExecValid
		lOk := VldGrvAloc(@cSitABB, @lDelConf, @lCancela)
	Else
		cSitABB := cSit190F
	EndIf

	If lPegrava
		lOk := lOk .AND. ExecBlock("At190Dalo",.F.,.F.,{oModel} )
	EndIf

	If lOk

		If lMdtGS //Integra��o entre o SIGAMDT x SIGATEC
			// posicina TFF
			DbSelectArea("TFF")
			TFF->( DbSetOrder(1)) //TFF_FILIAL+TFF_COD

			//posicina TN5
			dbSelectArea("TN5")
			TN5->(dbSetOrder(1)) //TN5_FILIAL+TN5_CODTAR

			If (lMdtGS := (TFF->( ColumnPos("TFF_RISCO")) > 0 .And. TN5->(ColumnPos("TN5_LOCAL")) > 0 .And. TN5->(ColumnPos("TN5_POSTO")) > 0))


				//posicina TN6
				dbSelectArea("TN6")
				TN6->(dbSetOrder(1)) //TN6_FILIAL+TN6_CODTAR+TN6_MAT+DTOS(TN6_DTINIC)

				If TFF->(DbSeek(xFilial("TFF")+cCodTFF)) .And.;
						TFF->TFF_RISCO == "1" .And. !Empty(cCDFUNC)

					cQueryTN5	:= GetNextAlias()

					BeginSql Alias cQueryTN5
				
					SELECT TN5.R_E_C_N_O_ TN5RECNO
					FROM %Table:TN5% TN5
					WHERE TN5.TN5_FILIAL	= %exp:xFilial('TN5')%
						AND TN5.TN5_LOCAL	= %exp:TFF->TFF_LOCAL%
						AND TN5.TN5_POSTO	= %exp:TFF->TFF_FUNCAO% 
						AND TN5.%NotDel%
					EndSql

					If (cQueryTN5)->(!EOF())
						nRecTar := (cQueryTN5)->TN5RECNO
					Endif

					(cQueryTN5)->(DbCloseArea())

					If nRecTar > 0 //Integra��o entre o SIGAMDT x SIGATEC
						TN5->(DbGoTo(nRecTar))
						If !TN6->(dbSeek(xFilial("TN6")+TN5->TN5_CODTAR+cCDFUNC))
							lNewMdt := .T.
						Else
							dDtIniMdt := TN6->TN6_DTINIC
						Endif
					Endif
				Endif
			Endif
		Endif

		If Len(aDels) > 0
			aMarks := ACLONE(aDels)
			If Len(aMarks[1]) >= 10
				If aMarks[1][10]
					At190DDlt( .T. , .F.)
					cSitABB += "|BR_PINK"
				EndIf
			EndIf
		EndIf

		Begin transaction
			For nI := 1 To oMdlAlc:Length()
				oMdlAlc:GoLine(nI)
				If lDelConf .AND. oMdlAlc:GetValue("ALC_SITABB") == "BR_PRETO"
					oMdlAlc:DeleteLine()
				EndIf
				If nI == 1
					dbSelectArea("ABS")
					ABS->(dbSetOrder(1))
					If ABS->(dbSeek(xFilial("ABS")+cLocal)) .And. ABS->ABS_RESTEC == "1"
						lResTec := .T.
					EndIf
				EndIf

				nPosAtend := aScan( AT330ArsSt("aAtend"), { |x| x[15] == oMdlALC:GetValue("ALC_ITEM") } )

				lChange := .F.
				If !(oMdlAlc:IsDeleted()) .AND. ASCAN(aValALC, {|a| a[01] == oMdlALC:GetValue("ALC_SITABB") .AND.;
						a[02] == oMdlALC:GetValue("ALC_SITALO") .AND.;
						a[03] == oMdlALC:GetValue("ALC_GRUPO") .AND.;
						a[04] == oMdlALC:GetValue("ALC_DATREF") .AND.;
						a[05] == oMdlALC:GetValue("ALC_DATA") .AND.;
						a[06] == oMdlALC:GetValue("ALC_SEMANA") .AND.;
						a[07] == oMdlALC:GetValue("ALC_ENTRADA") .AND.;
						a[08] == oMdlALC:GetValue("ALC_SAIDA") .AND.;
						a[09] == oMdlALC:GetValue("ALC_TIPO") .AND.;
						a[10] == oMdlALC:GetValue("ALC_SEQ") .AND.;
						a[11] == oMdlALC:GetValue("ALC_EXSABB") .AND.;
						a[12] == oMdlALC:GetValue("ALC_KEYTGY") .AND.;
						a[13] == oMdlALC:GetValue("ALC_ITTGY") .AND.;
						a[14] == oMdlALC:GetValue("ALC_TURNO") .AND.;
						a[15] == oMdlALC:GetValue("ALC_ITEM") }) == 0
					lChange := .T.
				EndIf

				cHorIni := StrHora(oMdlAlc:GetValue("ALC_ENTRADA"))
				cHorFim := StrHora(oMdlAlc:GetValue("ALC_SAIDA"))

				oMdlAlc:LoadValue( "ALC_ENTRADA", cHorIni )
				oMdlAlc:LoadValue( "ALC_SAIDA", cHorFim )

				dAloFim := If( HoraToInt(oMdlAlc:GetValue("ALC_SAIDA")) < HoraToInt(oMdlAlc:GetValue("ALC_ENTRADA")),;
					oMdlAlc:GetValue("ALC_DATA")+1, oMdlAlc:GetValue("ALC_DATA"))

				If oMdlAlc:IsDeleted()
					nPosPriDes := aScan(aPriDes, {|x| x[1] == oMdlAlc:GetValue("ALC_KEYTGY") .AND. x[4] == oMdlAlc:GetValue("ALC_ITTGY")})
					If nPosPriDes > 0
						If (oMdlAlc:GetValue("ALC_DATREF") < aPriDes[nPosPriDes][2])
							aPriDes[nPosPriDes][2]  := oMdlAlc:GetValue("ALC_DATREF")
							aPriDes[nPosPriDes][3] 	:= oMdlAlc:GetValue("ALC_SEQ")
							aPriDes[nPosPriDes][6]	:= oMdlAlc:GetLine()
						Else
							aPriDes[nPosPriDes][7] 	:= oMdlAlc:GetValue("ALC_DATREF")
						EndIf
					Else
						//Inicia data e sequencia
						aAdd(aPriDes, Array(7))
						nPosPriDes := Len(aPriDes)
						aPriDes[nPosPriDes][1] := oMdlAlc:GetValue("ALC_KEYTGY")
						aPriDes[nPosPriDes][2] := oMdlAlc:GetValue("ALC_DATREF")
						aPriDes[nPosPriDes][3] := oMdlAlc:GetValue("ALC_SEQ")
						aPriDes[nPosPriDes][4] := oMdlAlc:GetValue("ALC_ITTGY")
						aPriDes[nPosPriDes][5] := oMdlAlc:GetValue("ALC_GRUPO")
						aPriDes[nPosPriDes][6] := oMdlAlc:GetLine()
						aPriDes[nPosPriDes][7] := oMdlAlc:GetValue("ALC_DATREF")
					EndIf
				Else
					If lPrHora
						cTotal := TecConvHr(SomaHoras(TecConvHr(Left(ElapTime(cHorIni+":00", cHorFim+":00"), 5)), TecConvHr(cTotal)))
					EndIf
					If 	lChange .AND. !lPrHora
						dAloFimOri := If( HoraToInt(AT330ArsSt("aAtend")[nPosAtend,5]) < HoraToInt(AT330ArsSt("aAtend")[nPosAtend,4]),;
							AT330ArsSt("aAtend")[nPosAtend,2]+1, AT330ArsSt("aAtend")[nPosAtend,2])
					EndIf
					If !AllTrim(oMdlAlc:GetValue("ALC_ENTRADA")) == "FOLGA" .AND. !AllTrim(oMdlAlc:GetValue("ALC_SAIDA")) == "FOLGA"
						If lChange .Or. ( !(!lResTec .And. At190dEABB(oMdlAlc)) .and. !(lResTec .AND. At190dEABB(oMdlAlc) ))
							If EMPTY(aIteABQ)
								aIteABQ := At330AABQ( cContra,;
									cProdut,;
									cLocal,;
									cFuncao,;
									cTurnTFF,;
									cCodTFF,;
									xFilial("TFF") )
							EndIf
							If Len(aIteABQ) > 0
								cIdCFal := aIteABQ[1][1] + aIteABQ[1][2] + aIteABQ[1][3]
								nTotHrsTrb := SubtHoras(oMdlAlc:GetValue("ALC_DATA"), oMdlAlc:GetValue("ALC_ENTRADA"),dAloFim, oMdlAlc:GetValue("ALC_SAIDA") )
								nTotHor += nTotHrsTrb
								aCalAtd := {}
								aAdd( aCalAtd, { 	oMdlAlc:GetValue("ALC_DATA"),;
									TxRtDiaSem(oMdlAlc:GetValue("ALC_DATA")),;
									AllTrim(oMdlAlc:GetValue("ALC_ENTRADA")),;
									AllTrim(oMdlAlc:GetValue("ALC_SAIDA")),;
									AtConvHora(nTotHrsTrb),;
									oMdlAlc:GetValue("ALC_SEQ") } )
								nPosTipMov := AScan(aAlocTipMov,{|x| x[1] == cTipoAloc })
								If nPosTipMov <= 0
									AAdd(aAlocTipMov,{cTipoAloc,{}})
									nPosTipMov := Len(aAlocTipMov)
								EndIf
								AAdd(aAlocTipMov[nPosTipMov,2],{ cCodTec					 ,;
									cNomTec						 ,;
									cCDFUNC						 ,;
									oMdlAlc:GetValue("ALC_TURNO"),;
									cFuncao						 ,;
									cCargoTFF					 ,;
									Alltrim(cIdCFal)			 ,;
									""							 ,;
									""							 ,;
									ACLONE(aCalAtd)				 ,;
									{} 							 ,;
									cLocal })

								aAdd( aAloTDV, {cCodTec,;
									oMdlAlc:GetValue("ALC_DATA"),;
									AllTrim(oMdlAlc:GetValue("ALC_ENTRADA")),;
									dAloFim,;
									AllTrim(oMdlAlc:GetValue("ALC_SAIDA")), {} } )
								If !lPrHora
									If Empty(AT330ArsSt("aAtend")[nPosAtend,14,1,2])
										AT330ArsSt("aAtend")[nPosAtend,14,1,2] := oMdlAlc:GetValue("ALC_DATREF")
									EndIf

									aAdd( aAloTDV[Len(aAloTDV),6], AT330ArsSt("aAtend")[nPosAtend,14,1] )

									If oMdlAlc:GetValue("ALC_TIPO") == "E"
										aAloTDV[Len(aAloTDV),6,1,10] := "N"
									ElseIf oMdlAlc:GetValue("ALC_TIPO") == "I"
										aAloTDV[Len(aAloTDV),6,1,10] := "S"
									ElseIf oMdlAlc:GetValue("ALC_TIPO") <> AT330ArsSt("aAtend")[nPosAtend,8]
										aAloTDV[Len(aAloTDV),6,1,10] := oMdlAlc:GetValue("ALC_TIPO")
									Endif
								Else
									If CriaCalend( 	oMdlALC:GetValue("ALC_DATREF")    ,;    //01 -> Data Inicial do Periodo
										oMdlALC:GetValue("ALC_DATREF")    ,;    //02 -> Data Final do Periodo
										oMdlALC:GetValue("ALC_TURNO")     ,;    //03 -> Turno Para a Montagem do Calendario
										oMdlALC:GetValue("ALC_SEQ")       ,;    //04 -> Sequencia Inicial para a Montagem Calendario
										@aTabPadrao,;    //05 -> Array Tabela de Horario Padrao
										@aTabCalend,;    //06 -> Array com o Calendario de Marcacoes
										cFilSR6    ,;    //07 -> Filial para a Montagem da Tabela de Horario
										Nil, Nil )
										If Len(aTabCalend[1,17]) > 0
											If !Empty(DTOS(aTabCalend[1,17][1]))
												nHorMen := SubtHoras(aTabCalend[1,17][1],AtConvHora(aTabCalend[1,17][2]),aTabCalend[1,01],If(cHorIni=="FOLGA", "00:00",cHorIni ),.T.)
											EndIf
										EndIf

										// Calculo para os limites de saida
										If Len(aTabCalend[2,17]) > 0
											If !Empty(DTOS(aTabCalend[2,17][1]))
												nHorMai := SubtHoras(aTabCalend[2,01],If(cHorFim=="FOLGA", "00:00",cHorIni ), aTabCalend[2,17][1],AtConvHora(aTabCalend[2,17][2]),.T.)
											EndIf
										EndIf

										aAdd( aAloTDV[Len(aAloTDV),6], { Nil,;
											aTabCalend[1,48],;
											aTabCalend[1,14],;
											oMdlALC:GetValue("ALC_SEQ"),;
											aTabCalend[1,12],;
											aTabCalend[1,13],;
											aTabCalend[1,16],;
											aTabCalend[1,18],;
											aTabCalend[1,55],;
											aTabCalend[1,06],;
											aTabCalend[1,17],;
											"N", "N", "N",;
											aTabCalend[1,22],;
											aTabCalend[1,20],;
											aTabCalend[1,21],;
											nHorMen,;
											nHorMai,;
											1,;
											aTabCalend[2,22],;//Feriado Sa�da
										aTabCalend[2,20],;//Tipo Hora extra saida
										aTabCalend[2,21];//Tipo Hora extra saida
										} )
									EndIf
								EndIf
							EndIf
						EndIf
					EndIf
					nPosUltAlo := aScan(aUltAloc, {|x| x[1] == oMdlAlc:GetValue("ALC_KEYTGY") .AND. x[4] == oMdlAlc:GetValue("ALC_ITTGY")})
					If nPosUltAlo > 0
						If (oMdlAlc:GetValue("ALC_DATREF") > aUltALoc[nPosUltAlo][2])
							aUltALoc[nPosUltAlo][2] := oMdlAlc:GetValue("ALC_DATREF")
							If !Empty(oMdlAlc:GetValue("ALC_SEQ"))
								aUltALoc[nPosUltAlo][3]	:= oMdlAlc:GetValue("ALC_SEQ")
							EndIf
							aUltALoc[nPosUltAlo][6]	:= oMdlAlc:GetLine()
						EndIf
					Else
						If oMdlAlc:GetValue("ALC_SITABB") $ cSitABB .AND. oMdlAlc:GetValue("ALC_TIPO") $"S|E"
							aAdd(aUltAloc, Array(6))
							nPosUltAlo := Len(aUltAloc)
							aUltAloc[nPosUltAlo][1]	:= oMdlAlc:GetValue("ALC_KEYTGY")
							aUltAloc[nPosUltAlo][2]	:= oMdlAlc:GetValue("ALC_DATREF")
							aUltAloc[nPosUltAlo][3]	:= oMdlAlc:GetValue("ALC_SEQ")
							aUltAloc[nPosUltAlo][4]	:= oMdlAlc:GetValue("ALC_ITTGY")
							aUltAloc[nPosUltAlo][5]	:= oMdlAlc:GetValue("ALC_GRUPO")
							aUltALoc[nPosUltAlo][6]	:= oMdlAlc:GetLine()
						EndIf
					EndIf
				EndIf
			Next nI

			aAloc	:= aClone(aUltAloc)
			aRDesAloc := aClone(aPriDes)

			For nI := 1 To Len(aUltAloc)
				nPos := aScan(aInfo, {|x| x[1] == aUltAloc[nI][1] .AND.  x[5] == aUltAloc[nI][5]})

				If nPos > 0
					//considera maior data
					If aInfo[nPos][2] < aUltAloc[nI][2]
						aInfo[nPos] := aUltAloc[nI]
					EndIf
				Else
					aAdd(aInfo, aUltAloc[nI])
				EndIf
			Next nI

			If !EMPTY(aPriDes)
				//verifica sequencia dos itens desalocados para atualizar controle de ultima aloca��o
				For nI := 1 To Len(aPriDes)

					//Caso n�o encontra aloca��o verifica a sequencia da primeira desaloca��o
					If aScan(aUltAloc, {|x| x[1] == aPriDes[nI][1] .AND. x[4] == aPriDes[nI][4]}) == 0
						nPos := aScan(aInfo, {|x| x[1] == aPriDes[nI][1] .AND. x[5] == aPriDes[nI][5] })
						If nPos > 0
							//considera menor data
							If aInfo[nPos][2] > aPriDes[nI][2]
								aInfo[nPos] := aPriDes[nI]
							EndIf
						Else
							aAdd(aInfo, aPriDes[nI])
						EndIf
					EndIf
				Next nI
			EndIf

			For nI:=1 To Len(aInfo)
				nSeq := 0
				dUltDatRef := STOD("")
				nPosDes := aScan(aPriDes, {|x| x[1] == aInfo[nI][1] .AND. x[5] == aInfo[nI][5]  .AND. x[2] == aInfo[nI][2]})
				nPosAloc := aScan(aUltAloc, {|x| x[1] == aInfo[nI][1] .AND. x[5] == aInfo[nI][5]  .AND. x[2] == aInfo[nI][2]})
				If nPosDes > 0 .AND. Empty(aInfo[nI][3])

					oMdlALC:GoLine(aInfo[nI][6])
					cTurno := oMdlALC:GetValue("ALC_TURNO")
					cSeq := oMdlALC:GetValue("ALC_SEQ")

					//posiciona na primeira data de folga e percorre model contando a continua��o da sequencia at� encontrar primeiro dia trabalhado
					For nY := aInfo[nI][6] To oMdlALC:Length()
						oMdlALC:GoLine(nY)
						If oMdlALC:GetValue("ALC_KEYTGY") == aInfo[nI][1]
							If dUltDatRef != oMdlALC:GetValue("ALC_DATREF") .AND. Dow(oMdlALC:GetValue("ALC_DATREF")) == 2//considera nova sequencia toda segunda-feira
								nSeq++
							EndIf
							If oMdlALC:GetValue("ALC_ENTRADA") != "FOLGA" .AND.  oMdlALC:GetValue("ALC_SAIDA") != "FOLGA"
								cSeq := oMdlALC:GetValue("ALC_SEQ")
								Exit
							EndIf
							dUltDatRef := oMdlALC:GetValue("ALC_DATREF")
						EndIf
					Next nY

					//Busca sequencia anterior conforme nSeq
					If nSeq > 0
						nPosSeq := LoadSeqs(aSeqs, cTurno)	//Recupera aSeq
						aInfo[nI][3] := GetSeq(aSeqs[nPosSeq][2],cSeq,nSeq, .F.)//Busca sequencia
					Else
						aInfo[nI][3] := cSeq
					EndIf
				ElseIf nPosAloc > 0 .AND.  Empty(aInfo[nI][3])
					oMdlAlc:GoLine(aInfo[nI][6])
					cTurno := oMdlAlc:GetValue("ALC_TURNO")
					cSeq := oMdlAlc:GetValue("ALC_SEQ")

					//posiciona na ultima data de folga e percorre o model contando a sequencia at� a ultima aloca��o
					For nY := aInfo[nI][6] To  1 Step -1
						oMdlAlc:GoLine(nY)
						If oMdlAlc:GetValue("ALC_KEYTGY") == aInfo[nI][1]
							If dUltDatRef != oMdlAlc:GetValue("ALC_DATREF") .AND. Dow(oMdlAlc:GetValue("ALC_DATREF")) == 2//considera nova sequencia toda segunda-feira
								nSeq++
							EndIf
							If Alltrim(oMdlAlc:GetValue("ALC_ENTRADA")) != "FOLGA" .AND. Alltrim(oMdlAlc:GetValue("ALC_SAIDA")) != "FOLGA"
								cSeq := oMdlAlc:GetValue("ALC_SEQ")
								Exit
							EndIf
							dUltDatRef := oMdlALC:GetValue("ALC_DATREF")
						EndIf
					Next nY

					//Busca sequencia posterior conforme nSeq
					If nSeq > 0
						nPosSeq := LoadSeqs(aSeqs, cTurno)//Recupera aSeq
						aInfo[nI][3] := GetSeq(aSeqs[nPosSeq][2],cSeq,nSeq, .T.)
					Else
						aInfo[nI][3] := cSeq
					EndIf
				EndIf
				If nPosAloc > 0
					If Dow(aInfo[nI][2]) == 1//Ultima Aloca��o no domingo
						oMdlAlc:GoLine(aInfo[nI][6])
						nPosSeq := LoadSeqs(aSeqs, oMdlAlc:GetValue("ALC_TURNO"))
						aInfo[nI][3] := GetSeq(aSeqs[nPosSeq][2],aInfo[nI][3], 1, .T. )//Recupera proxima Sequencia
						aAloc[1][3]	 := aInfo[nI][3]
					EndIf
				EndIf
				TGY->(DbSetOrder(1))
				If Len(aAloc) > 0 .AND. (nPosAloc > 0)
					For nT := 1 To Len(aAloc)
						If (TGY->(DbSeek(xFilial("TGY") + aAloc[nT][1] + aAloc[nT][4] ) );
								.AND.( xFilial("TGY") + aAloc[nT][1] + aAloc[nT][4]  == TGY->TGY_FILIAL + TGY->TGY_ESCALA + TGY->TGY_CODTDX+ TGY->TGY_CODTFF + TGY->TGY_ITEM );
								.AND. ( TGY->TGY_GRUPO == aAloc[nT][5] )) .OR. !EMPTY(oMdlTGY:GetValue("TGY_RECNO"))
							If !EMPTY(oMdlTGY:GetValue("TGY_RECNO"))
								TGY->(DbGoTo(oMdlTGY:GetValue("TGY_RECNO")))
							EndIf
							TGY->(RecLock("TGY", .F.))
							TGY->TGY_SEQ := aAloc[nT][3]		//-- Sequencia
							TGY->TGY_ULTALO	:= aAloc[nT][2]		//-- Dt da Ultima Aloca��o
							//Retorna os hor�rios alterados
							aHorarios := GetHorEdt(lMV_GSGEHOR, oMdlTGY, .T., ""/*cEscala*/,""/* cCodTFF*/)
							//Grava os Hor�rios do Model
							For nC := 1 to Len(aHorarios)
								TGY->(FieldPut(FieldPos(aHorarios[nC, 01, 01]),aHorarios[nC, 01, 02] ) ) //TGY_ENTRA
								TGY->(FieldPut(FieldPos(aHorarios[nC, 02, 01]),aHorarios[nC, 02, 02] ) )//TGY_SAIDA
							Next nC
							TGY->( MsUnlock() )
						EndIf
					Next nT
				ElseIf Len(aRDesAloc) > 0 .AND. (nPosDes > 0)
					For nT := 1 To Len(aRDesAloc)
						If (TGY->(DbSeek(xFilial("TGY") + aRDesAloc[nT][1] + aRDesAloc[nT][4] ) );
								.AND.( xFilial("TGY") + aRDesAloc[nT][1] + aRDesAloc[nT][4]  == TGY->TGY_FILIAL + TGY->TGY_ESCALA + TGY->TGY_CODTDX+ TGY->TGY_CODTFF + TGY->TGY_ITEM );
								.AND. ( TGY->TGY_GRUPO == aRDesAloc[nT][5] )) .OR. !EMPTY(oMdlTGY:GetValue("TGY_RECNO"))
							If !EMPTY(oMdlTGY:GetValue("TGY_RECNO"))
								TGY->(DbGoTo(oMdlTGY:GetValue("TGY_RECNO")))
							EndIf
							lHasAbbR := hasABBRig(aRDesAloc[nT][7], TGY->TGY_CODTFF, TGY->TGY_ATEND)
							TGY->(RecLock("TGY", .F.))
							If aRDesAloc[nT][2] <> TGY->TGY_DTINI .AND. lHasAbbR
								TGY->TGY_ULTALO	:= aRDesAloc[nT][2]-1	//-- ao desalocar considera ultima data valida como a anterior a desaloca��o
							Else
								If !lHasAbbR
									If aRDesAloc[nT][2] == TGY->TGY_DTINI
										TGY->TGY_ULTALO	:= CtoD(Space(08))
									Else
										TGY->TGY_ULTALO	:= aRDesAloc[nT][2]-1
									EndIf
									// Atualiza o campo TGY_DTFIM caso o par�metro MV_DFDTFIM == .T. e caso n�o existam agendas futuras para o atendente
									If lAtDfTGY
										TGY->TGY_DTFIM := aRDesAloc[nT][2]-1
									EndIf

									If nRecTar > 0 .And. !Empty(dDtIniMdt) //Integra��o entre o SIGAMDT x SIGATEC
										TN5->(DbGoTo(nRecTar))
										If TN6->(dbSeek(xFilial("TN6")+TN5->TN5_CODTAR+cCDFUNC+Dtos(dDtIniMdt)))
											RecLock("TN6",.F.)
											TN6->TN6_DTINIC	:= TGY->TGY_DTINI
											TN6->TN6_DTTERM	:= TGY->TGY_ULTALO
											TN6->(MsUnLock())
										Endif
									Endif

								EndIf
							EndIf

							TGY->( MsUnlock() )
						EndIf
					Next nT
				EndIf
			Next nI

			If Len(aAlocTipMov) > 0
				For nI := 1 To Len(aAlocTipMov)
					At330GvAlo(aAlocTipMov[nI,2],"CN9",aAlocTipMov[nI,1],,@aInserted)
				Next nI

				dbSelectArea("ABB")
				ABB->(dbSetOrder(1))
				For nI:=1 To Len(aAloTDV)
					cAliasABB 	:= GetNextAlias()
					BeginSql Alias cAliasABB
					SELECT COUNT(ABB_CODIGO) AS CNT,  ABB_CODIGO
					FROM
					%table:ABB% ABB
					WHERE ABB.ABB_FILIAL = %xFilial:ABB%
						AND ABB.ABB_CODTEC	= %Exp:aAloTDV[nI][1]%
						AND	ABB.ABB_DTINI 	= %Exp:DtoS(aAloTDV[nI][2])%
						AND	ABB.ABB_HRINI 	= %Exp:aAloTDV[nI][3]%
						AND	ABB.ABB_DTFIM 	= %Exp:DtoS(aAloTDV[nI][4])%
						AND	ABB.ABB_HRFIM 	= %Exp:aAloTDV[nI][5]%
						AND	ABB.ABB_ATIVO 	= '1'
						AND ABB.%notDel%
						GROUP BY ABB_CODIGO
						ORDER BY ABB_CODIGO 
					EndSql

					//No caso de conflito de aloca��o existe mais de uma ABB igual.
					While (cAliasABB)->(!Eof())
						aAloTDV[nI,6,1,1] := (cAliasABB)->ABB_CODIGO
						(cAliasABB)->(DbSkip())
					EndDo

					(cAliasABB)->( DbCloseArea() )
				Next nI
				TxSaldoCfg( cIdCFal, nTotHor, .F. )
				At330AUpTDV( .F., aAloTDV , @aInserted , .T. )
				If TableInDic("TXH")
					At58gGera(aInserted,cEscala,cCodTFF)
				EndIf
			Else
				lNenhuma := .T.
			EndIf
		End Transaction

		FwModelActive(oModel)
		AT330ArsSt("",.T.)
		If lNenhuma
			Help(,,"NOINSERT",,STR0214,1,0)	//"Nenhuma agenda inserida."
		EndIf
		If !isInCallStack("AT190dIMn2") .AND. !lPrHora
			If !EMPTY(oMdlTGY:GetValue("TGY_RECNO"))
				ProjAloc2()
			EndIf
			At190DLoad()
		EndIf

		If (nRecTar > 0 .And. !Empty(dDtIniMdt)) .Or. (nRecTar > 0 .And. lNewMdt)//Integra��o entre o SIGAMDT x SIGATEC
			TN5->(DbGoTo(nRecTar))
			If !lNewMdt
				If !TN6->(dbSeek(xFilial("TN6")+TN5->TN5_CODTAR+cCDFUNC+Dtos(dDtIniMdt)))
					RecLock("TN6",.T.)
					TN6->TN6_FILIAL	:= xFilial("TN6")
					TN6->TN6_CODTAR	:= TN5->TN5_CODTAR
					TN6->TN6_MAT	:= cCDFUNC
					TN6->TN6_DTINIC	:= TGY->TGY_DTINI
					TN6->TN6_DTTERM	:= TGY->TGY_ULTALO
					TN6->(MsUnLock())
				Else
					RecLock("TN6",.F.)
					TN6->TN6_DTINIC	:= TGY->TGY_DTINI
					TN6->TN6_DTTERM	:= TGY->TGY_ULTALO
					TN6->(MsUnLock())
				Endif
			else
				RecLock("TN6",.T.)
				TN6->TN6_FILIAL	:= xFilial("TN6")
				TN6->TN6_CODTAR	:= TN5->TN5_CODTAR
				TN6->TN6_MAT	:= cCDFUNC
				TN6->TN6_DTINIC	:= TGY->TGY_DTINI
				TN6->TN6_DTTERM	:= TGY->TGY_ULTALO
				TN6->(MsUnLock())
			EndIf
		Endif

		If lPrHora
			TFF->(DbSetOrder(1))
			If TFF->(DbSeek(xFilial("TFF") + cCodTFF))
				If !Empty(TFF->TFF_QTDHRS)
					TFF->(RecLock("TFF", .F.))
					TFF->TFF_HRSSAL := TecConvHr(SubHoras(TecConvHr(TFF->TFF_HRSSAL), TecConvHr(cTotal)))
					TFF->( MsUnlock() )
				EndIf
			EndIf
		EndIf

	EndIf

	If !lCancela
		aValALC := {}
		aDels := {}
		aMarks := ACLONE(aBkpMarks)
	EndIf

	cFilAnt := cBkpFil

Return lOk

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At190dEABB
@description  Retorna se ja existe ABB para determinada linha do grid

@author boiani
@since 15/07/2019
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At190dEABB(oMdlALC)

Return oMdlALC:GetValue("ALC_SITABB") == "BR_VERMELHO" .Or. (oMdlALC:GetValue("ALC_EXSABB") == "1" .And. oMdlALC:GetValue("ALC_SITABB") <> "BR_PRETO")

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} StrHora
@description  Ajusta o horario para receber o formato correto

@author boiani
@since 15/07/2019
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function StrHora(cHora)

	Local cRet    := ""
	Local cHorRet := AllTrim( cHora )

	If cHorRet <> "FOLGA"
		If Len( cHorRet ) < 4
			cHorRet := PadL( cHorRet, 4, "0" )
		EndIf

		If At( ":", cHorRet ) == 0
			cHorRet := Left( cHorRet, 2 ) + ":" + Right( cHorRet, 2 )
		EndIf
	EndIf

	cRet := cHorRet

Return(cRet)
//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AtConvHora
@description  Realiza convers�o de hora para formato utilizado pela rotina

@author boiani
@since 15/07/2019
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function AtConvHora(nHoras)
	Local nHora := Int(nHoras)//recupera somente a hora
	Local nMinuto := (nHoras - nHora)*100//recupera somento os minutos
Return(StrZero(nHora, 2) + ":" + StrZero(nMinuto, 2))
//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetTDX
@description  Retorna o TDX_COD utilizando a Escala/Sequ�ncia

@author boiani
@since 15/07/2019
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function GetTDX(cEscala, cSeqIni)
	Local cQry := GetNextAlias()
	Local cRet := ""

	BeginSQL Alias cQry
	SELECT TDX.TDX_COD
	  FROM %Table:TDX% TDX
	 WHERE TDX.TDX_FILIAL = %xFilial:TDX%
	   AND TDX.%NotDel%
	   AND TDX.TDX_CODTDW = %Exp:cEscala%
	   AND TDX.TDX_SEQTUR = %Exp:cSeqIni%
	EndSQL

	cRet := (cQry)->(TDX_COD)
	(cQry)->(DbCloseArea())

Return cRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} AT190ClDta
Realiza a chamada do objeto FWCalendar

@author		Diego Bezerra
@since		10/07/2019
@param oMdlAll	- Modelo da dados Geral
@param cIdMdl	- ID do modelo utilizado para gerar o calend�rio

@version	P12.1.23
/*/
//------------------------------------------------------------------------------
Static Function AT190ClDta(oMdlAll)

	Local aItens	 := {}
	Local oView 	 := FwViewActive()
	Local aFolder 	 := {}
	Local cModel 	 := ""
	Local lRet		 := .T.
	Default oMdlAll  := FWModelActive()

	aFolder := AT190FAct(oView)

	If aFolder[1][1] == 2 .AND. aFolder[1][2] == 2
		lRet := .F.
	Else
		If Len(aFolder) > 0
			If aFolder[1][1] == 1
				If aFolder[1][2] == 1
					cModel := "ABBDETAIL"
					aFld := {   {"ABBDETAIL","ABB_DTREF"},;
						{"ABBDETAIL","ABB_HRINI"},;
						{"ABBDETAIL","ABB_HRFIM"},;
						{"AA1MASTER","AA1_NOMTEC"},;
						{"ABBDETAIL","ABB_ABSDSC"},;
						{"AA1MASTER","AA1_CODTEC"};
						}
					cAba := "Manuten��o"
				Else
					cModel :=  "ALCDETAIL"
					aFld := {	{"ALCDETAIL","ALC_DATREF"},;
						{"ALCDETAIL","ALC_ENTRADA"},;
						{"ALCDETAIL","ALC_SAIDA"},;
						{"AA1MASTER","AA1_NOMTEC"},;
						{"TGYMASTER","TGY_CODTFL"},;
						{"AA1MASTER","AA1_CODTEC"};
						}
					cAba := "Aloca��o"
				EndIf
			Else
				cModel := "LOCDETAIL"
				aFld := {	{"LOCDETAIL","LOC_DTREF"},;
					{"LOCDETAIL","LOC_HRINI"},;
					{"LOCDETAIL","LOC_HRFIM"},;
					{"LOCDETAIL","LOC_NOMTEC"},;
					{"LOCDETAIL","LOC_ABSDSC"},;
					{"LOCDETAIL","LOC_CODTEC"};
					}
				cAba := "Agendas Projetadas"
			EndIf
		EndIf

		aItens := At190MnCld(oMdlAll, aFld, aFolder)
		FwMsgRun(Nil,{|| AT190DCld(aItens, cAba)}, Nil, STR0215)	//"Montando calend�rio..."
	EndIf

	If !lRet
		Help(,,"AT190ClDta",,STR0216,1,0)	//"Funcionalidade n�o dispon�vel para essa se��o."
	EndIf

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At190MnCld

Retorna dados para a cria��o do objeto FWCalendar

@author	Diego Bezerra
@since	10/07/2019
@param oMdl	- Modelo geral de dados
@param aFld - Campos do modelo, que ser�o considerados
@param aFolder - array com id das pastas

@version	P12.1.23
/*/
//------------------------------------------------------------------------------o
Static Function At190MnCld(oMdl, aFld, aFolder)

	Local aItens 	:= {}
	Local nX		:= 0
	Local cAux		:= ""
	Local nPos		:= 0
	Local c1stDate  := sToD("")
	Local nPosX		:= 0
	Local aAuxLoc	:= {}
	Local aAuxAtd	:= {}
	Local nPosLoc	:= 0
	Local cDescLoc	:= ""
	Local lFolga	:= .F.

	Default aFld 	:= {}
	Default aFolder := {}

	For nX := 1 to oMdl:GetModel(aFld[1][1]):Length()
		oMdl:GetModel(aFld[1][1]):goLine(nX)
		// Vari�vel utilizada para n�o exibir os dias de folga
		lFolga := ALLTRIM(oMdl:GetModel(aFld[2][1]):GetValue(aFld[2][2])) == "FOLGA" .AND. ALLTRIM(oMdl:GetModel(aFld[3][1]):GetValue(aFld[3][2])) == "FOLGA"
		If !Empty(oMdl:GetValue(aFld[1][1],aFld[1][2]))
			// Obt�m data base para in�cio da gera��o do calend�rio
			If nX == 1
				c1stDate := oMdl:GetModel(aFld[1][1]):GetValue(aFld[1][2])
			EndIf
			// Verifica se a data j� foi inclu�da no array de retorno
			nPos := aScan(aItens,{|x| x[1] == oMdl:GetModel(aFld[1][1]):GetValue(aFld[1][2])})

			If nPos == 0
				aAdd(aItens,{oMdl:GetModel(aFld[1][1]):GetValue(aFld[1][2]),{}})
				aAdd(aAuxAtd,{oMdl:GetModel(aFld[1][1]):GetValue(aFld[1][2]),{}})
			EndIf

			// Obt�m a descri��o do local de atendimento
			If aFolder[1][1] == 1 .AND. aFolder[1][2] == 2
				nPosLoc := aScan(aAuxLoc, {|x| x[1] == oMdl:GetModel(aFld[5][1]):GetValue(aFld[5][2])})
				If nPosLoc == 0
					aAdd(aAuxLoc,{oMdl:GetModel(aFld[5][1]):GetValue(aFld[5][2]), AT190DLoc(oMdl:GetModel(aFld[5][1]):GetValue(aFld[5][2]), aFld[5][2])})
					cDescLoc := aAuxLoc[len(aAuxLoc)][2]
				Else
					cDescLoc := aAuxLoc[nPosLoc][2]
				EndIf
			Else
				cDescLoc := oMdl:GetModel(aFld[5][1]):GetValue(aFld[5][2])
			EndIf
			cDescLoc := RTRIM(cDescLoc)

			If nPos == 0
				If !lFolga
					cAux = "  " + RTRIM(oMdl:GetModel(aFld[2][1]):GetValue(aFld[2][2])) + "-" + RTRIM(oMdl:GetModel(aFld[3][1]):GetValue(aFld[3][2]))
					aAdd(aItens[len(aItens)][2],RTRIM(oMdl:GetModel(aFld[4][1]):GetValue(aFld[4][2])) + " (" + cDescLoc + ")")
					aAdd(aAuxAtd[len(aAuxAtd)][2],RTRIM(oMdl:GetModel(aFld[6][1]):GetValue(aFld[6][2])) + cDescLoc )
					aAdd(aItens[len(aItens)][2],cAux)
					aAdd(aAuxAtd[len(aAuxAtd)][2],cAux)
					cAux := ""
				EndIf
			Else
				nPosX := aScan(aAuxAtd[nPos][2],{|x| x == RTRIM(oMdl:GetModel(aFld[6][1]):GetValue(aFld[6][2])) + cDescLoc })
				If nPosX == 0
					If !lFolga
						cAux := "  " + RTRIM(oMdl:GetModel(aFld[2][1]):GetValue(aFld[2][2])) + "-" + RTRIM(oMdl:GetModel(aFld[3][1]):GetValue(aFld[3][2]))
						aAdd(aItens[nPos][2],RTRIM(oMdl:GetModel(aFld[4][1]):GetValue(aFld[4][2])) + " (" + cDescLoc + ")" )
						aAdd(aAuxAtd[nPos][2],RTRIM(oMdl:GetModel(aFld[6][1]):GetValue(aFld[6][2])) + cDescLoc)
						aAdd(aItens[nPos][2],cAux)
						aAdd(aAuxAtd[nPos][2],cAux)
						cAux := ""
					EndIf
				Else
					If !lFolga
						cAux := "  " + RTRIM(oMdl:GetModel(aFld[2][1]):GetValue(aFld[2][2])) + "-" + RTRIM(oMdl:GetModel(aFld[3][1]):GetValue(aFld[3][2]))
						aAdd(aItens[nPos][2], cAux)
						aAdd(aAuxAtd[nPos][2],cAux)
						cAux := ""
					EndIf
				EndIf
			EndIf
		EndIf
	Next nX

Return {aItens, c1stDate}


//------------------------------------------------------------------------------
/*/{Protheus.doc} AT190DCld

Montagem e exibi��o do objeto FWCalendar

@author	Diego Bezerra
@since	10/07/2019
@param aItem - Dados para a gera��o do calend�rio

@version	P12.1.23
/*/
//------------------------------------------------------------------------------
Static Function AT190DCld(aItem, cAba)

	Local nI		:= 0
	Local nPos		:= 0
	Local nColor 	:= 16777215
	Local cMes     	:= ""
	Local cAno    	:= ""
	Local cMesAno 	:= ""
	Local cRet 		:= ""
	Local aList		:= {}
	Local aItems 	:= {}
	Local aSize		:= {}
	Local oCalend	:= Nil
	Local oFwLayer	:= Nil
	Local oPanSup	:= Nil
	Local dDtIni 	:= StoD("")
	Local dDiaSel	:= StoD("")

	Default aItems := {}
	Default cAba := ""

	aItems := aItem[1]
	dDtIni := aItem[2]

	If len(aItems) > 0
		aSize := FWGetDialogSize( oMainWnd )
		cMes    := StrZero( Month( dDtIni ) , 2 )
		cAno    := StrZero( Year( dDtIni )  , 4 )
		cMesAno := AllTrim( cMes ) + '/ ' + AllTrim( cAno )

		DEFINE MSDIALOG oDlg TITLE STR0217 + cAba  FROM aSize[1], aSize[2] TO aSize[3], aSize[4]*0.8 PIXEL	//'Calend�rio '

		oFwLayer := FwLayer():New()
		oFwLayer := FwLayer():New()
		oFwLayer:init(oDlg,.F.)

		oFWLayer:addLine("SUP", 5, .F.)
		oFWLayer:addLine("CALEND", 87, .F.)
		oFWLayer:addLine("INF", 3, .F.)

		oFWLayer:addCollumn( "COLCAL",100, .T. , 		"CALEND")
		oFWLayer:addCollumn( "BLANKCOL1",7, .T. ,		"SUP")
		oFWLayer:addCollumn( "BTNPREVMONTH",25, .T. ,	"SUP")
		oFWLayer:addCollumn( "TITLE",25, .T. ,   		"SUP")
		oFWLayer:addCollumn( "BTNNEXTMONTH",20, .T. ,	"SUP")
		oFWLayer:addCollumn( "BTNSAIR",20, .T. ,		"SUP")
		oFWLayer:addCollumn( "BTNCALEND",97, .T. ,		"INF")

		oPanTit	:= oFWLayer:GetColPanel( "TITLE",		"SUP")
		oPanSup := oFWLayer:GetColPanel( "COLCAL",		"CALEND")
		oPanPM 	:= oFWLayer:GetColPanel( "BTNPREVMONTH","SUP")
		oPanNM 	:= oFWLayer:GetColPanel( "BTNNEXTMONTH","SUP")
		oPanEnd	:= oFWLayer:GetColPanel( "BTNSAIR",		"SUP")
		oPanCl  := oFWLayer:GetColPanel( "BTNCALEND",	"INF")

		oCalend := FWCalendar():New( VAL(cMes), VAL(cAno) )
		oCalend:aNomeCol    := { STR0218, STR0219, STR0220, STR0221, STR0222, STR0223, STR0224, STR0225 }	//'Domingo'	# 'Segunda' # 'Ter�a' # 'Quarta' # 'Quinta'	# 'Sexta' # 'S�bado' # 'Semana'
		oCalend:lWeekColumn := .F.
		oCalend:lFooterLine := .F.
		oCalend:Activate( oPanSup )
		aList = Array(Len( oCalend:aCell ))

		For nI := 1 To Len( aItems )
			nPos := aScan(oCalend:aCell, {|x| x[3] == aItems[nI][1] })
			If nPos > 0
				oCalend:SetInfo( oCalend:aCell[nPos][1], aItems[nI][2] )
			EndIf
		Next

		oMesAtual := TSay():New( 0, 0, {||}, oPanTit,,,,,,.T.,20,20,,,,,,,, .T. )
		oMesAtual:Align := CONTROL_ALIGN_ALLCLIENT
		oMesAtual:nClrPane     := nColor

		cTitulo := oCalend:cNOMEMES + " / " + cAno
		cRet := AT190dTitle(cTitulo)
		oMesAtual:SetText( cRet )

		@ 0, 0 BTNBMP oPrevMonth Resource "PMSSETAESQ" Size 80, 90 Of oPanPM Pixel
		oPrevMontht:cToolTip := STR0226	//"Mes Anterior"
		oPrevMonth:bAction  := { || FwMsgRun(Nil, {|| AT190UpdM(oPanSup, oCalend, aItems, 2 )}, Nil, STR0215) }	//"Montando calend�rio..."
		oPrevMonth:Align    := CONTROL_ALIGN_RIGHT

		@ 0, 0 BTNBMP oNextMonth Resource "PMSSETADIR" Size 90, 90 Of oPanNM Pixel
		oNextMonth:cToolTip := STR0227	//"Proximo Mes"
		oNextMonth:bAction  := { || FwMsgRun(Nil, {|| AT190UpdM(oPanSup, oCalend, aItems, 1 )}, Nil, STR0215) }	//"Montando calend�rio..."
		oNextMonth:Align    := CONTROL_ALIGN_LEFT

		@ 0, 0 BTNBMP oButCal Resource "BTCALEND" Size 24, 24 Of oPanCl Pixel
		oButCal:cToolTip := STR0228	//"Alterar Calend�rio..."
		oButCal:bAction := { || FwMsgRun(Nil, {||AT190DTrc( oDlg, CTod( '01/' + oCalend:cRef ), @dDiaSel ),;
			oCalend:SetCalendar( oPanSup, Month( dDiaSel ) , Year( dDiaSel ) ) , oDlg:cTitle := STR0217 + oCalend:cRef,;	//'Calend�rio '
		AT190dAtu( oCalend, aItems, dDiaSel, oPanSup ) }, Nil, STR0215 ) }	//"Montando calend�rio..."
		oButCal:Align := CONTROL_ALIGN_RIGHT

		@ 0, 0 BTNBMP oButEnd Resource STR0229 Size 24, 24 Of oPanEnd Pixel	//"FINAL"
		oButEnd:cToolTip := STR0230			//"Sair"
		oButEnd:bAction  := {||oDlg:End()}
		oButEnd:Align    := CONTROL_ALIGN_RIGHT

		oCalend:SetInfo( oCalend:IdDay( 20 ), '<td>10</td><td>30</td><td>20</td>', .T.)
		oCalend:SetInfo( oCalend:IdDay( 21 ), '<td><tr><td>10</td><td>30</td><td>20</td></tr><tr><td>30</td><td>30</td><td>30</td></tr></td>', .T.)
		oCalend:SetInfo( oCalend:IdDay( 22 ), '<td>10</td><td>30</td><td>20</td>', .T.)

		oDlg:lMaximized := .F.

		Activate MsDialog oDlg Centered
	Else
		Help(,,"AT190CALEND",,STR0231,1,0)	//"N�o h� dados para serem exibidos."
	EndIf
Return NIL


//------------------------------------------------------------------------------
/*/{Protheus.doc} AT190FAct
Retorna a aba ativa
@author	Diego Bezerra
@since	10/07/2019
@param oView - Objeto view principal

@return aRet - Array com os Id e descri��es das pastas
@version	P12.1.23
/*/
//------------------------------------------------------------------------------
Static Function AT190FAct(oView)

	Local aFldPai	:= oView:GetFolderActive("TELA_ABAS", 2)
	Local aFolder	:= {}
	Local aRet		:= {}

	aAdd(aRet, {aFldPai[1]})
	If Len(aFldPai) > 0
		If aFldPai[2] == STR0398 //'Atendentes'
			aFolder	:= oView:GetFolderActive("ABAS", 2)
			aAdd(aRet[1],aFolder[1])
		Else
			aFolder	:= oView:GetFolderActive("ABAS_LOC", 2)
			aAdd(aRet[1],aFolder[1])
		EndIf
	EndIf
Return aRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} AT190UpdM
Fun��o utilizada para avan�ar ou retornar um m�s do calend�rio
@author	Diego Bezerra
@since	10/07/2019
@param oPan - Painel que cont�m o objeto fwcalendar
@param oCalend - Objeto fwcalendar
@param nOp - N�mero da op��o - 1 = Avan�ar, 2 = Voltar

@return Nil
@version	P12.1.23
/*/
//------------------------------------------------------------------------------
Static Function AT190UpdM(oPan, oCalend, aItems,nOp)

	Local nMonth    := oCalend:NMES
	Local nYear     := oCalend:NANO
	Local nI		:= 1
	Default	nOp		:= 1

	If nOp == 1
		If nMonth == 12
			nMonth := 01
			nYear += 1
		Else
			nMonth := nMonth += 1
		EndIf
	ElseIf nOp == 2
		If nMonth == 01
			nMonth := 12
			nYear -= 1
		Else
			nMonth := nMonth -= 1
		EndIf
	EndIf
	oCalend:SetCalendar( oPan, cValToChar(nMonth), cValToChar(nYear) )

	For nI := 1 To Len( aItems )
		nPos := aScan(oCalend:aCell, {|x| x[3] == aItems[nI][1] })
		If nPos > 0
			oCalend:SetInfo( oCalend:aCell[nPos][1], aItems[nI][2] )
		EndIf
	Next

	AT190DUpCld(oCalend,cValToChar(nMonth),cValToChar(nYear))

Return NIL


//------------------------------------------------------------------------------
/*/{Protheus.doc} AT190dTitle
Atualiza o t�tulo da janela do calend�rio
@author	Diego Bezerra
@since	10/07/2019
@param cMes - string com o m�s que ser� utilizado no t�tulo

@return cRet - string HTML utilizada para gerar o t�tulo da janela do calend�rio
@version	P12.1.23
/*/
//------------------------------------------------------------------------------
Static Function AT190dTitle(cMes)
	Local cRet := ''

	cRet += '<body>'
	cRet += '	<P ALIGN="Center">'
	cRet += '        <FONT FACE="MS SANS SERIF" COLOR="#000000"> <B> ' + cMes + ' </B> </FONT>'
	cRet += '</body>'
	cRet := StrTran( cRet, '  ', ' ' )

Return cRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} AT190DUpCld
Atualiza o calend�rio, baseando-se na informa��o escolhida no calend�rio miniatura
@author	Diego Bezerra
@since	10/07/2019
@param oCalend - Objeto do calend�rio
@param cMonth - M�s selecionado
@param cYear - Ano selecionado

@version	P12.1.23
/*/
//------------------------------------------------------------------------------
Static Function AT190DUpCld(oCalend,cMonth,cYear)

	Local cRet			:= ""
	Local cTitulo 		:= ""

	Default cMonth 		:= ""
	Default cYear		:= ""

//����������������������������������������������Ŀ
//�Cria String com o Mes e Ano corrente    	   �
//������������������������������������������������
	If !Empty(cMonth) .AND. !Empty(cYear)
		cTitulo := oCalend:cNOMEMES + " / " + cYear
		cRet := AT190dTitle(cTitulo)
	Else
		cMonth    	:= SubStr(oCalend:cRef, 1, 2)
		cYear 		:= SubStr(oCalend:cRef, 4, 7)
		cTitulo := oCalend:cNOMEMES + " / " + cYear
		cRet := AT190dTitle(cTitulo)
	EndIf

	oMesAtual:SetText( cRet )

Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} AT190DTrc
Abre calend�rio miniatura para a sele��o da base do objeto oCalendar
@author	Diego Bezerra
@since	10/07/2019
@param oWnd - Painel que contem o objeto fwcalendar
@param dRef - Array com os itens utilizados para a gera��o do calend�rio
@param dDiaSel - Novo dia base selecionado

@version	P12.1.23
/*/
//------------------------------------------------------------------------------
Static Function AT190DTrc( oWnd, dRef, dDiaSel )

	Local oDlgTroc												//Dialog
	Local oPanel 												//Objeto Panel
	Local oCalend												//Objeto Calendario
	Local oFooter												//Rodap�
	Local oOk													//Objeto OK
	Local oCancel												//Objeto Cancel
	Local dRet := IIf( Empty( dRef ) , Date() , dRef )		//Data de referencia

//�����������������������������������������Ŀ
//�	Cria a tela para o calendario(MsCalend) �
//�������������������������������������������
	If !(isBlind())
		Define MsDialog oDlgTroc FROM 000, 000 To 200, 300 Pixel Of oWnd

		@ 000, 000 MsPanel oPanel Of oDlgTroc Size 100, 100
		oPanel:Align := CONTROL_ALIGN_ALLCLIENT

		oCalend := MsCalend():New( 01, 01, oPanel, .T. )
		oCalend:Align   := CONTROL_ALIGN_ALLCLIENT

		//�����������������������������������������Ŀ
		//�	Define o dia a ser exibido no calend�rio �
		//�������������������������������������������
		oCalend:dDiaAtu := dRet

		//�����������������������������������������Ŀ
		//�	Code-Block para mudan�a de Dia			  �
		//�������������������������������������������
		oCalend:bChange := { || dRet :=  oCalend:dDiaAtu }

		oCalend:CanMultSel := .F.

		@ 000, 000 MsPanel oFooter Of oDlgTroc Size 000, 010
		oFooter:Align   := CONTROL_ALIGN_BOTTOM

		@ 000, 000 Button oCancel Prompt STR0232  Of oFooter Size 030, 000 Pixel //"Cancelar"
		oCancel:bAction := { || oDlgTroc:End() }
		oCancel:Align   := CONTROL_ALIGN_RIGHT

		@ 000, 000 Button oOk     Prompt STR0109 Of oFooter Size 030, 000 Pixel //"Confirmar"
		oOk:bAction     := { || dRet := oCalend:dDiaAtu, oDlgTroc:End() }
		oOk:Align       := CONTROL_ALIGN_RIGHT

		Activate MsDialog oDlgTroc Centered
	EndIf

	dDiaSel := dRet

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} AT190dAtu
Atualiza informa��es do calend�rio
@author	Diego Bezerra
@since	10/07/2019
@param oCalend - Objeto do calend�rio
@param aItems - Array com os itens utilizados para a gera��o do calend�rio
@param dDiaSel - Novo dia base selecionado
@param oPanSup - Painel que cont�m o objeto do calend�rio
@version	P12.1.23
/*/
//------------------------------------------------------------------------------
Static Function AT190dAtu( oCalend, aItems, dDiaSel, oPanSup )

	Local nI		:= 1
	Default aItems	:= {}
	Default	nOp		:= 1

	oCalend:SetCalendar( oPanSup, MONTH(dDiaSel), YEAR(dDiasel) )

	For nI := 1 To Len( aItems )
		nPos := aScan(oCalend:aCell, {|x| x[3] == aItems[nI][1] })
		If nPos > 0
			oCalend:SetInfo( oCalend:aCell[nPos][1], aItems[nI][2] )
		EndIf
	Next

	AT190DUpCld(oCalend,cValToChar( MONTH(dDiaSel)), cValToChar( YEAR(dDiasel)))

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} AT190DLoc
Retorna a descri��o de um local de atendimento
@author	Diego Bezerra
@since	10/07/2019
@param cLocId - C�digo do local de atendimento
@return cLocDesc - String com a descri��o do local
@version	P12.1.23
/*/
//------------------------------------------------------------------------------
Static Function AT190DLoc(cLocId, cField)

	Local cAliasABS := GetNextAlias()
	Local cLocDesc	:= ""

	Default cField := ""

	If EMPTY(cField)
		BeginSQL Alias cAliasABS
		SELECT
			DISTINCT ABS_DESCRI FROM %table:ABS% ABS
			INNER JOIN %table:ABB% ABB ON ABB_LOCAL = ABS_LOCAL
		WHERE ABB_FILIAL = %xFilial:ABB%
			AND ABS_FILIAL = %xFilial:ABS%
			AND ABB.%NotDel% AND ABS.%NotDel%
			AND ABB_LOCAL = %Exp:cLocId%
		EndSQL
	Else
		BeginSQL Alias cAliasABS
		SELECT
			DISTINCT ABS_DESCRI FROM %table:ABS% ABS
			INNER JOIN %table:TFL% TFL ON TFL_LOCAL = ABS_LOCAL
		WHERE ABS_FILIAL = %xFilial:ABS%
			AND TFL_FILIAL = %xFilial:TFL%
			AND ABS.%NotDel%
			AND TFL.%NotDel%
			AND TFL.TFL_CODIGO = %Exp:cLocId%
		EndSQL
	EndIf
	If (cAliasABS)->(!EOF())
		cLocDesc := (cAliasABS)->ABS_DESCRI
	EndIf

	(cAliasABS)->(DBCloseArea())

Return cLocDesc
//-------------------------------------------------------------------
/*/{Protheus.doc} LoadSeqs()

Carrega sequencias do turno por demanda e retorna posi��o do turno das seqeuncias do turno

@author boiani
@since 16/07/2019
/*/
//------------------------------------------------------------------
Static Function LoadSeqs(aSeqs, cTurno)
	Local nPosSeq := 0

	//Carrega aSeqs por demanda
	nPosSeq := aScan(aSeqs, {|x| x[1] == cTurno})
	If nPosSeq == 0
		aAdd(aSeqs, {cTurno, At580GtSeq(cTurno)})
		nPosSeq := Len(aSeqs)
	EndIf

Return nPosSeq
//-------------------------------------------------------------------
/*/{Protheus.doc} GetSeq()

Retorna numero da sequencia conforme parametros

@author boiani
@since 16/07/2019
/*/
//------------------------------------------------------------------
Static Function GetSeq(aSeqs, cSeqAtu, nNumSeq, lNext)
	Local cSeq := cSeqAtu
	Local nPos := 0
	Local nCount := 0

	If Len(aSeqs) > 0
		nPos := aScan(aSeqs, {|x| x[2]==cSeqAtu})
		If nPos > 0
			//Raliza calculo para percorrer a sequencia at� achar a correspondente
			If lNext
				nCount := nNumSeq + nPos
				While (nCount>Len(aSeqs))
					nCount -= Len(aSeqs)
				End
			Else
				nCount := nPos - nNumSeq
				While (nCount<=0)
					nCount += Len(aSeqs)
				End
			EndIf
			cSeq := aSeqs[nCount][2]
		EndIf
	EndIf
Return cSeq
//-------------------------------------------------------------------
/*/{Protheus.doc} WhensTGY()

Modifica o WHEN dos campos da TGY

@author boiani
@since 18/07/2019
/*/
//------------------------------------------------------------------
Static Function WhensTGY(lOpc, aFields, lRefresh, lTravaDTA)
	Local oModel := FwModelActive()
	Local oView := FwViewActive()
	Local oMdlTGY := oModel:GetModel("TGYMASTER")
	Local oMdlDTA := oModel:GetModel("DTAMASTER")
	Local oStrDTA := oMdlDTA:GetStruct()
	Local oStrTGY := oMdlTGY:GetStruct()
	Local nX
	Local lMV_MultFil := TecMultFil() //Indica se a Mesa considera multiplas filiais

	Default aFields := {}
	Default lRefresh := .F.
	Default lTravaDTA := .T.

	If Empty(aFields)
		If lMV_MultFil
			aFields := {"TGY_CONTRT","TGY_CODTFL", "TGY_TFFCOD", "TGY_ESCALA", "TGY_TIPALO", "TGY_SEQ", "TGY_GRUPO"}
		Else
			aFields := {"TGY_CODTFL", "TGY_TFFCOD", "TGY_ESCALA", "TGY_TIPALO", "TGY_SEQ", "TGY_GRUPO"}
		EndIf
	EndIf

	oStrDTA:SetProperty("DTA_DTINI", MODEL_FIELD_WHEN, {|| lTravaDTA})
	oStrDTA:SetProperty("DTA_DTFIM", MODEL_FIELD_WHEN, {|| lTravaDTA})
	If !IsBlind()
		oView:Refresh('VIEW_DTA')
	EndIf
	For nX := 1 to LEN(aFields)
		If lOpc .AND.  aFields[nX] == "TGY_ESCALA"
			//Se for habilitar o campo TGY_ESCALA, retorna o valid da permiss�o para alterar a escala
			oStrTGY:SetProperty(aFields[nX], MODEL_FIELD_WHEN, { || At680Perm( Nil, __cUserID, "014" ) } )
		Else
			oStrTGY:SetProperty(aFields[nX], MODEL_FIELD_WHEN, {|| lOpc})
		EndIf
	Next nX

	If lRefresh .OR. isInCallStack("ProjAloc2")
		oView:Refresh('VIEW_TGY')
	EndIf

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} GetPjs()

Retorna em formato de array os dias da PJ de acordo com a sequ�ncia solicitada

@author boiani
@since 19/07/2019
/*/
//------------------------------------------------------------------
Static Function GetPjs(aDias,cCombo)
	Local aRet := {}
	Local nX

	For nX := 1 to LEN(aDias)
		If aDias[nX][11] == cCombo
			AADD(aRet, aDias[nX])
		EndIf
	Next nX

	ASORT(aRet,,, { |x, y| IIF(TecNumDow(x[1]) == 1,TecNumDow(x[1])+7,TecNumDow(x[1])) <;
		IIF(TecNumDow(y[1]) == 1,TecNumDow(y[1])+7,TecNumDow(y[1])) } )

Return aRet
//-------------------------------------------------------------------
/*/{Protheus.doc} GetGrupos()

Retorna em formato de array os dados do grupo selecionado no combobox

@author boiani
@since 22/07/2019
/*/
//------------------------------------------------------------------
Static Function GetGrupos(aGrupos, cGrupo)
	Local aRet := {}
	Local nX

	For nX := 1 to LEN(aGrupos)
		If aGrupos[nX][8] == cGrupo
			AADD(aRet, aGrupos[nX])
		EndIf
	Next nX

Return aRet
//-------------------------------------------------------------------
/*/{Protheus.doc} At190dRfr()

Realiza o REFRESH no F3 do campo TGY_SEQ

@author boiani
@since 19/07/2019
/*/
//------------------------------------------------------------------
Function At190dRfr(oListBox,cCombo,aDias, aGrupos, cTipo)
	Local aDados

	Default aGrupos := {}
	Default aDias := {}

	If VAlTYPE(oListBox) == 'O' .AND. VALTYPE(oListBox:aARRAY) == 'A'
		oListBox:aARRAY := {}
	EndIf
	If cTipo $ "TGY_GRUPO|LGY_GRUPO"
		aDados := GetGrupos(aGrupos,cCombo)
	Else
		aDados := GetPjs(aDias,cCombo)
	EndIf
	If VAlTYPE(oListBox) == 'O' .AND. VALTYPE(oListBox:aARRAY) == 'A'
		oListBox:aARRAY := aDados
		oListBox:Refresh()
	EndIf

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} CharToD()

Retorna o resultado de um char de acordo com a SPJ

@author boiani
@since 19/07/2019
/*/
//------------------------------------------------------------------
Static Function CharToD(cChar)
	Local cRet := ""

	If cChar == "S"
		cRet := STR0193	//"Trabalhado"
	ElseIf cChar == "D"
		cRet := STR0195	//"D.S.R."
	ElseIf cChar == "C"
		cRet := STR0194	//"Compensado"
	ElseIf cChar == "E"
		cRet := STR0490	//"Hora Extra"
	ElseIf cChar == "I"
		cRet := STR0196	//"Intervalo"
	ElseIf cChar == "N"
		cRet := STR0197	//"N�o Trabalhado"
	EndIf

Return cRet
//-------------------------------------------------------------------
/*/{Protheus.doc} CharToD()

Retorna o resultado de um char de acordo com a SPJ

@author boiani
@since 19/07/2019
/*/
//------------------------------------------------------------------
Static Function NumToHr(nHora)

Return TecNumToHr(nHora)
//------------------------------------------------------------------------------
/*/{Protheus.doc} PreLinAlc()

Fun��o de Prevalidacao da grid de aloca��o ALC

@author boiani
@since 23/07/2019
/*/
//------------------------------------------------------------------------------
Function PreLinAlc(oMdlG, nLine, cAcao, cCampo, xValue, xOldValue)
	Local lRet := .T.
	Local aSaveLines	:= FWSaveRows()
	Local aArea		:= GetArea()
	Local oView := FwViewActive()
	Local oModel := oMdlG:GetModel()
	Local oMdlTGY := oModel:GetModel("TGYMASTER")
	Local dUltAloc := oMdlTGY:GetValue("TGY_ULTALO")

	If cAcao == 'DELETE'
		If oMdlG:GetValue("ALC_SITABB") == "BR_VERMELHO"
			lRet := .F.
			Help( " ", 1, "PreLinAlc", Nil, STR0236, 1 )	//"Opera��o n�o permitida para agendas j� geradas. Para excluir essa agenda, utilize a aba 'Manuten��o'"
		EndIf
	EndIf

	If cAcao == 'SETVALUE'
		If !EMPTY(dUltAloc) .AND. !(cCampo $ "ALC_SITABB|ALC_SITALO")
			If oMdlG:GetValue("ALC_DATA") <= dUltAloc
				lRet := .F.
				Help( " ", 1, "PreLinAlc", Nil, STR0237 + dToC(dUltAloc) + STR0238, 1 )	//"Opera��o n�o permitida para agendas anteriores a data da �ltima aloca��o (" # "). Para modificar essa agenda, utilize a aba 'Manuten��o'"
			EndIf
		EndIf

		If oMdlG:GetValue("ALC_SITABB") == "BR_VERMELHO" .AND. !(cCampo $ "ALC_SITABB|ALC_SITALO")
			lRet := .F.
			Help( " ", 1, "PreLinAlc", Nil, STR0239, 1 )	//"Opera��o n�o permitida para agendas j� geradas. Para modificar essa agenda, utilize a aba 'Manuten��o'"
		EndIf

		If lRet
			If (cCampo == "ALC_ENTRADA" .OR. cCampo == "ALC_SAIDA") .AND. xValue <> "FOLGA"
				If xValue == SPACE(5)
					xValue := "FOLGA"
				EndIf
				If LEN(ALLTRIM(xValue)) == 5 .AND. AT(":",xValue) == 0
					lRet := .F.
					Help( " ", 1, "PreLinAlc", Nil, STR0233, 1 )	//"Hor�rio inv�lido. Por favor, insira um hor�rio no formato HH:MM"
				EndIf
				If AT(":",xValue) == 0 .AND. AtJustNum(Alltrim(xValue)) == Alltrim(xValue) .AND. lRet
					If LEN(Alltrim(xValue)) == 4
						xValue := LEFT(Alltrim(xValue),2) + ":" + RIGHT(Alltrim(xValue),2)
					ElseIf LEN(Alltrim(xValue)) == 2
						xValue := Alltrim(xValue) + ":00"
					ElseIf LEN(Alltrim(xValue)) == 1
						xValue := "0" + Alltrim(xValue) + ":00"
					EndIf
				EndIf
				If xValue <> "FOLGA" .AND. lRet
					lRet := AtVldHora(Alltrim(xValue))
				EndIf
			EndIf

			If cCampo == "ALC_TIPO"
				Do Case
				Case xValue == "S" 	; cCor := "BR_VERDE"
				Case xValue == "C" 	; cCor := "BR_AMARELO"
				Case xValue == "D" 	; cCor := "BR_AZUL"
				Case xValue == "E" 	; cCor := "BR_LARANJA"
				Case xValue == "I" 	; cCor := "BR_PRETO"
				OtherWise			; cCor := "BR_VERMELHO"
				EndCase
				If cCor != oMdlG:GetValue( "ALC_SITALO")
					lRet := oMdlG:LoadValue( "ALC_SITALO", cCor )
					If cCor $ "BR_VERDE|BR_LARANJA"
						oMdlG:LoadValue("ALC_ENTRADA", "  :  ")
						oMdlG:LoadValue("ALC_SAIDA", "  :  ")
					Else
						oMdlG:LoadValue("ALC_ENTRADA", "FOLGA")
						oMdlG:LoadValue("ALC_SAIDA", "FOLGA")
					EndIf
					oView:Refresh("DETAIL_ALC")
				EndIf
			EndIf
		EndIf
	EndIf

	FWRestRows( aSaveLines )
	RestArea(aArea)
Return lRet
//------------------------------------------------------------------------------
/*/{Protheus.doc} AjustaTGY()

Ajusta a TGY de acordo com os dados informados na TGYMASTER

@author boiani
@since 24/07/2019
/*/
//------------------------------------------------------------------------------
Static Function AjustaTGY()
	Local cQry := GetNextAlias()
	Local oModel := FwModelActive()
	Local oMdlTGY := oModel:GetModel("TGYMASTER")
	Local oMdlDTA := oModel:GetModel("DTAMASTER")
	Local cCodTec := oModel:GetValue("AA1MASTER","AA1_CODTEC")
	Local cCodTFF := oMdlTGY:GetValue("TGY_TFFCOD")
	Local cEscala := oMdlTGY:GetValue("TGY_ESCALA")
	Local cTipoMV := oMdlTGY:GetValue("TGY_TIPALO")
	Local nGrupo := oMdlTGY:GetValue("TGY_GRUPO")
	Local cSeq := oMdlTGY:GetValue("TGY_SEQ")
	Local cCodTDX
	Local cItem
	Local lEOF := .F.
	Local lFound := .F.
	Local nRECNO := 0
	Local dDataIni := oMdlDTA:GetValue("DTA_DTINI")
	Local dDataFim := oMdlDTA:GetValue("DTA_DTFIM")
	Local dUltALoc
	Local oMdl580e
	Local oMdl580c
	Local oMdlAux1
	Local oMdlAux2
	Local oMdlAux3
	Local nX
	Local nY
	Local cTurno := GetTurno(cEscala, cSeq)
	Local lRet := .T.
	Local aEditHor := {}
	Local nC := 0
	Local lMV_GSGEHOR := TecXHasEdH()
	Local lUsaEscala := .F.

	BeginSQL Alias cQry
	SELECT TGY.R_E_C_N_O_, TGY.TGY_ULTALO
	  FROM %Table:TGY% TGY
	 WHERE TGY.TGY_FILIAL = %xFilial:TGY%
	   AND TGY.%NotDel%
	   AND TGY.TGY_ATEND = %Exp:cCodTec%
	   AND TGY.TGY_CODTFF = %Exp:cCodTFF%
	   AND TGY.TGY_ESCALA = %Exp:cEscala%
	EndSQL
	lEOF := (cQry)->(EOF())
	If !lEOF
		nRECNO := (cQry)->(R_E_C_N_O_)
		dUltALoc := (cQry)->(TGY_ULTALO)
	EndIf
	(cQry)->(DbCloseArea())
	If !lEOF
		oMdlTGY:LoadValue("TGY_RECNO", nRECNO)
		If !Empty(dUltALoc)
			oMdlTGY:LoadValue("TGY_ULTALO", StoD(dUltALoc))
		EndIf
		TGY->(DbGoTo(nRECNO))
		//Alimenta o Hash do gest�o de horarios e a array de horarios
		aEditHor := GetHorEdt(lMV_GSGEHOR, oMdlTGY,!lEOF, cEscala, cCodTFF, @lUsaEscala)
		If nGrupo != TGY->TGY_GRUPO .OR. (cTipoMV != TGY->TGY_TIPALO .AND. !EMPTY(cTipoMV)) .OR.;
				Len(aEditHor) > 0 .OR. dDataFim > TGY->TGY_DTFIM
			cEscala := TGY->TGY_ESCALA
			cItem := TGY->TGY_ITEM
			cCodTDX := TGY->TGY_CODTDX
			TFF->(DbSetOrder(1))
			If !(lRet := lRet .AND. TFF->(DbSeek(xFilial("TFF") + cCodTFF)))
				Help( " ", 1, "NOTFOUND", Nil, STR0240 + cCodTFF + STR0241, 1 )	//"N�o foi poss�vel localizar o posto " # " na tabela de Itens de RH (TFF)"
			EndIf
			If lRet
				At580EGHor(lUsaEscala)
				oMdl580e := FwLoadModel("TECA580E")
				oMdl580e:SetOperation(MODEL_OPERATION_UPDATE)
				lRet := lRet .AND. oMdl580e:Activate()
				oMdlAux1 := oMdl580e:GetModel("TDXDETAIL")
				oMdlAux2 := oMdl580e:GetModel("TGYDETAIL")

				For nX := 1 to oMdlAux1:Length()
					oMdlAux1:GoLine(nX)
					For nY := 1 To oMdlAux2:Length()
						oMdlAux2:GoLine(nY)
						If oMdlAux2:GetValue("TGY_ATEND") == cCodTec .AND. oMdlAux2:GetValue("TGY_ESCALA") == cEscala .AND.;
								oMdlAux2:GetValue("TGY_CODTDX") == cCodTDX .AND. oMdlAux2:GetValue("TGY_ITEM") == cItem
							lRet := lRet .AND. oMdlAux2:SetValue("TGY_GRUPO", nGrupo)
							If dDataFim > oMdlAux2:GetValue("TGY_DTFIM")
								oMdlAux2:SetValue("TGY_DTFIM", dDataFim)
							EndIf
							If !EMPTY(cTipoMV)
								lRet := lRet .AND. oMdlAux2:SetValue("TGY_TIPALO", cTipoMV)
							EndIF
							If Len(aEditHor) > 0
								For nC := 1 to Len(aEditHor)
									If At580eWhen(Str(nC, 1))
										lRet := lRet .AND. oMdlAux2:LoadValue(aEditHor[nC, 01, 01], aEditHor[nC, 01, 02]) //TGY_ENTRA
										lRet := lRet .AND. oMdlAux2:LoadValue(aEditHor[nC, 02, 01], aEditHor[nC, 02, 02]) //TGY_SAIDA
									EndIf
								Next nC
							EndIf
							If (lRet := lRet .AND. oMdl580e:VldData() .And. oMdl580e:CommitData())
								oMdl580e:DeActivate()
								oMdl580e:Destroy()
								FwModelActive(oModel)
							ElseIf oMdl580e:HasErrorMessage()
								AtErroMvc( oMdl580e )
								If !IsBlind()
									MostraErro()
								EndIf
							EndIf
							lFound := .T.
							Exit
						EndIf
					Next nY
					If lFound
						Exit
					EndIf
				Next nX
			EndIf
		EndIf
	Else
		//Alimenta o Hash do gest�o de horarios e a array de horarios
		aEditHor := GetHorEdt(lMV_GSGEHOR, oMdlTGY,!lEOF, cEscala, cCodTFF, @lUsaEscala)
		//necess�rio criar a TGY
		cQry := GetNextAlias()
		BeginSQL Alias cQry
		SELECT TFF.R_E_C_N_O_
			FROM %Table:TFF% TFF
		INNER JOIN %Table:TDW% TDW ON
			TDW.TDW_FILIAL = %xFilial:TDW%
			AND TDW.TDW_COD = %Exp:cEscala%
			AND TDW.%NotDel%
		INNER JOIN %Table:TDX% TDX ON
			TDX.TDX_FILIAL = %xFilial:TDX%
			AND TDX.%NotDel%
			AND TDX.TDX_CODTDW = TDW.TDW_COD
			AND TDX.TDX_TURNO = %Exp:cTurno%
		WHERE TFF.TFF_FILIAL = %xFilial:TFF%
		   AND TFF.%NotDel%
		   AND TFF.TFF_COD = %Exp:cCodTFF%
		   AND TFF.TFF_ESCALA = %Exp:cEscala%
		EndSQL
		lEOF := (cQry)->(EOF())
		nRECNO := 0
		If !lEOF
			nRECNO := (cQry)->(R_E_C_N_O_)
		EndIf
		(cQry)->(DbCloseArea())
		If lEOF
			TFF->(DbSetOrder(1))
			If !(lRet := lRet .AND. TFF->(DbSeek(xFilial("TFF") + cCodTFF)))
				Help( " ", 1, "NOTFOUND", Nil, STR0240 + cCodTFF + STR0241, 1 )	//"N�o foi poss�vel localizar o posto " # " na tabela de Itens de RH (TFF)"
			EndIf
			nRECNO := TFF->(Recno())
			oMdl580c := FwLoadModel("TECA580C")
			oMdl580c:SetOperation(MODEL_OPERATION_UPDATE)
			lRet := lRet .AND. oMdl580c:Activate()
			oMdlAux3 := oMdl580c:GetModel("TFFMASTER")
			lRet := lRet .AND. oMdlAux3:SetValue("TFF_ESCALA", cEscala)
			If (lRet := lRet .AND. oMdl580c:VldData() .And. oMdl580c:CommitData())
				oMdl580c:DeActivate()
				oMdl580c:Destroy()
			ElseIf oMdl580c:HasErrorMessage()
				AtErroMvc( oMdl580c )
				If !IsBlind()
					MostraErro()
				EndIf
			EndIf
		EndIf

		If !EMPTY(nRECNO) .AND. lRet
			TFF->(dbGoTo(nRECNO))
			At580EGHor(lUsaEscala)
			oMdl580e := FwLoadModel("TECA580E")
			oMdl580e:SetOperation(MODEL_OPERATION_UPDATE)
			lRet := lRet .AND. oMdl580e:Activate()
			oMdlAux1 := oMdl580e:GetModel("TDXDETAIL")
			oMdlAux2 := oMdl580e:GetModel("TGYDETAIL")

			If lRet
				lRet := .F.
				For nX := 1 to oMdlAux1:Length()
					oMdlAux1:GoLine(nX)

					If oMdlAux1:GetValue("TDX_CODTDW") 	== cEscala .AND.;
							oMdlAux1:GetValue("TDX_TURNO") 	== cTurno  .AND.;
							oMdlAux1:GetValue("TDX_SEQTUR") 	== cSeq

						oMdlAux2:GoLine(oMdlAux2:Length())

						If !Empty(oMdlAux2:GetValue("TGY_ATEND"))
							oMdlAux2:AddLine()
						Endif

						If Empty(oMdlAux2:GetValue("TGY_ATEND"))

							lRet := oMdlAux2:LoadValue("TGY_ATEND", cCodTec)
							lRet := lRet .AND. oMdlAux2:LoadValue("TGY_SEQ", cSeq)
							lRet := lRet .AND. oMdlAux2:SetValue("TGY_GRUPO", nGrupo)
							lRet := lRet .AND. oMdlAux2:SetValue("TGY_DTINI", dDataIni)
							lRet := lRet .AND. oMdlAux2:SetValue("TGY_DTFIM", dDataFim)
							lRet := lRet .AND. oMdlAux2:SetValue("TGY_TIPALO", cTipoMV)
							lRet := lRet .AND. oMdlAux2:LoadValue("TGY_TURNO", ALLTRIM(POSICIONE("AA1",1,XFILIAL("AA1") + cCodTec,"AA1_TURNO")))
							lRet := lRet .AND. oMdlAux2:LoadValue("TGY_ITEM", TecXMxTGYI(cEscala, GetTDX(cEscala, cSeq), cCodTFF))
							For nC := 1 to Len(aEditHor)
								If At580eWhen(Str(nC, 1))
									lRet := lRet .AND. oMdlAux2:LoadValue(aEditHor[nC, 01, 01], aEditHor[nC, 01, 02]) //TGY_ENTRA
									lRet := lRet .AND. oMdlAux2:LoadValue(aEditHor[nC, 02, 01], aEditHor[nC, 02, 02]) //TGY_SAIDA
								EndIf
							Next nC
							Exit
						Endif
					EndIf
				Next nX
				If (lRet := lRet .AND. oMdl580e:VldData() .And. oMdl580e:CommitData())
					oMdl580e:DeActivate()
					oMdl580e:Destroy()
				ElseIf oMdl580e:HasErrorMessage()
					AtErroMvc( oMdl580e )
					If !IsBlind()
						MostraErro()
					EndIf
				EndIf
			EndIf
			FwModelActive(oModel)
			lRet := lRet .AND. AjustaTGY()
		Else
			FwModelActive(oModel)
		EndIf
	EndIf

Return lRet
//------------------------------------------------------------------------------
/*/{Protheus.doc} GetTurno()

Retorna o turno utilizando o c�digo da escala e a sequ�ncia

@author boiani
@since 24/07/2019
/*/
//------------------------------------------------------------------------------
Static Function GetTurno(cCodTDW, cSeqTur)
	Local cRet := ""
	Local aArea := GetArea()
	Local cQry := GetNextAlias()

	BeginSQL Alias cQry
	SELECT TDX.TDX_TURNO
	FROM %Table:TDX% TDX
	WHERE TDX.TDX_FILIAL = %xFilial:TDX%
		AND TDX.%NotDel%
		AND TDX.TDX_CODTDW = %Exp:cCodTDW%
		AND TDX.TDX_SEQTUR = %Exp:cSeqTur%
	EndSql

	cRet := (cQry)->(TDX_TURNO)
	(cQry)->(DbCloseArea())

	RestArea(aArea)
Return cRet
//------------------------------------------------------------------------------
/*/{Protheus.doc} At190dHora()

Ajusta o valor do campo de ENTRADA / SAIDA da grid ALC

@author boiani
@since 26/07/2019
/*/
//------------------------------------------------------------------------------
Function At190dHora(oMdlG,cCampo,xValue)
	Local oView := FwViewActive()

	If xValue == SPACE(5) .AND. oMdlg:GetModel():GetId() <> 'TECA190G'
		xValue := "FOLGA"
		oMdlG:LoadValue(cCampo, xValue)
		oView:Refresh("DETAIL_ALC")
	EndIf

	If AT(":",xValue) == 0
		If LEN(Alltrim(xValue)) == 4
			xValue := LEFT(Alltrim(xValue),2) + ":" + RIGHT(Alltrim(xValue),2)
			oMdlG:LoadValue(cCampo, xValue)
			oView:Refresh("DETAIL_ALC")
		ElseIf LEN(Alltrim(xValue)) == 2
			xValue := Alltrim(xValue) + ":00"
			oMdlG:LoadValue(cCampo, xValue)
			oView:Refresh("DETAIL_ALC")
		ElseIf LEN(Alltrim(xValue)) == 1
			xValue := "0" + Alltrim(xValue) + ":00"
			oMdlG:LoadValue(cCampo, xValue)
			oView:Refresh("DETAIL_ALC")
		EndIf
	EndIf

Return .T.
//------------------------------------------------------------------------------
/*/{Protheus.doc} GetHorTGY

@description Caputa os horarios da TGY
@author	fabiana.silva
@since	24/07/2019
/*/
//-----------------------------------------------------------------------------
Static Function GetHorTGY(oMdlTGY, cCodTEC)
	Local lMV_GSGEHOR := TecXHasEdH()
	Local cQry := GetNextAlias()
	Local cCpoGSGEHOR := ""
	Local aHorarios := {}
	Local cCodTFF := oMdlTGY:GetValue("TGY_TFFCOD")
	Local cEscala := oMdlTGY:GetValue("TGY_ESCALA")
	Local nC := 0

	If lMV_GSGEHOR
		For nC := 1 to 4
			cCpoGSGEHOR += ", TGY.TGY_ENTRA"+Str(nC, 1)+ ", TGY.TGY_SAIDA"+Str(nC, 1)
		Next

		cCpoGSGEHOR := "%"+cCpoGSGEHOR+"%"

		BeginSQL Alias cQry
		SELECT TGY.R_E_C_N_O_
			%exp:cCpoGSGEHOR%
		  FROM %Table:TGY% TGY
		 WHERE TGY.TGY_FILIAL = %xFilial:TGY%
		   AND TGY.%NotDel%
		   AND TGY.TGY_ATEND = %Exp:cCodTec%
		   AND TGY.TGY_CODTFF = %Exp:cCodTFF%
		   AND TGY.TGY_ESCALA = %Exp:cEscala%
		EndSQL

		If !(cQry)->(EOF())
			aHorarios := {{"",""}, {"",""}, {"",""}, {"", ""}}
			For nC := 1 to 4
				aHorarios[nC, 01] := (cQry)->&("TGY_ENTRA"+Str(nC, 1))
				aHorarios[nC, 02] := (cQry)->&("TGY_SAIDA"+Str(nC, 1))
			Next nC

		EndIf
		(cQry)->(DbCloseArea())
	EndIf
Return aHorarios
//------------------------------------------------------------------------------
/*/{Protheus.doc} GetHorEdt

@description Captura o horario
@author	fabiana.silva
@since	24/07/2019
/*/
//-----------------------------------------------------------------------------
Static Function GetHorEdt(lMV_GSGEHOR, oMdlTGY, lLoadDiff, cEscala, cCodTFF, lUsaEscala)
	Local aHoraRet := {}
	Local aHoraTmp := {}
	Local lIguais := .T.
	Local cK := ""
	Local nK := ""
	Local cEntra := ""
	Local cSaida := ""
	Local cBkpFil := cFilAnt
	Local lMV_MultFil := TecMultFil() //Indica se a Mesa considera multiplas filiais
	Default cEscala := ""

	lIguais := lLoadDiff

	If lMV_GSGEHOR .AND. oMdlTGY <> NIL

		If lMV_MultFil
			If cFilAnt != oMdlTGY:GetValue("TGY_FILIAL")
				cFilAnt := oMdlTGY:GetValue("TGY_FILIAL")
			EndIf
		EndIf

		If !Empty(cEscala)
			lUsaEscala := VldEscala(0, cEscala, cCodTFF, .F.)
		EndIf

		For nK := 1 to 4
			cK := Str(nK, 1)
			cEntra := oMdlTGY:GetValue("TGY_ENTRA"+cK)
			cSaida := oMdlTGY:GetValue("TGY_SAIDA"+cK)

			If Empty(cEntra) .AND.  Empty(cSaida) .AND. lUsaEscala
				cEntra := TxValToHor(At580bHGet(("PJ_ENTRA"+ cK))) //Captura o Horario da escala
				cSaida := TxValToHor(At580bHGet(("PJ_SAIDA"+ cK))) //Captura o Horario da escala
			EndIf

			If (!Empty(cEntra) .AND. Val(StrTran(cEntra, ":")) > 0 ) .OR. ( !Empty(cSaida) .AND. Val(StrTran(cSaida, ":")) > 0 )
				aAdd(aHoraTmp, { {"TGY_ENTRA"+cK, cEntra}, {"TGY_SAIDA"+cK, cSaida}})
				If lIguais
					//TGY j� est� posicionado
					lIguais := cEntra  == TGY->(FieldGet(FieldPos("TGY_ENTRA"+cK))) .AND.  cSaida == TGY->(FieldGet(FieldPos("TGY_SAIDA"+cK)))
				EndIf
			EndIf
		Next nK
	EndIf
	If !lLoadDiff .OR. !lIguais
		aHoraRet := aClone(aHoraTmp)
	EndIf
	cFilAnt := cBkpFil
Return aHoraRet
//------------------------------------------------------------------------------
/*/{Protheus.doc} At190MEHr

@description bot�o "Editor de Horarios"
@author	fabiana.silva
@since	24/07/2019
/*/
//------------------------------------------------------------------------------
Static Function At190MEHr()

	Local oModel 	:= FwModelActive()
	Local oModelTGY :=  oModel:GetModel("TGYMASTER")
	Local cEscala 	:= ""
	Local lProssegue := .F.

	If !Empty(cEscala := oModelTGY:GetValue("TGY_ESCALA"))
		lProssegue := VldEscala(0, cEscala, oModelTGY:GetValue("TGY_TFFCOD"))
		At580EGHor(lProssegue)
		If lProssegue
			At190DHr(oModelTGY)	 //Chama o Dialog do Editor de Hor�rios
		EndIf
	Else
		Help(,,"At190MEHr",,STR0314,1,0)//"Informar uma escala"
	EndIf

Return .T.
//------------------------------------------------------------------------------
/*/{Protheus.doc} At190DHr

@description Dialog do Editor de Hor�rios
@author	fabiana.silva
@since	24/07/2019
/*/
//-----------------------------------------------------------------------------
Static Function At190DHr(oModelTGY)
	Local nC := 1
	Local aCmpoView := {}
	Local aObjects := {}
	Local aEdit := {}
	Local aInfo := {}
	Local cCampoE := ""
	Local cCampoS := ""
	Local nSuperior := 0
	Local nEsquerda := 0
	Local nInferior := GetScreenRes()[2] * 0.4
	Local nDireita  := GetScreenRes()[1] * 0.45
	Local cCpo := ""
	Local uValueE := ""
	Local uValueS := ""
	Local aPosObj := {}
	Local aFields := {}
	Local cValidCpo := ""
	Local cTitulo := "X3_TITULO"
	Local cValid := ""
	Local cWhen := ""

	#IFDEF SPANISH
		cTitulo	:= "X3_TITSPA"
	#ELSE
		#IFDEF ENGLISH
			cTitulo	:= "X3_TITENG"
		#ENDIF
	#ENDIF

//������������������������������������������������������Ŀ
//� Cria Variaveis de Memoria da Enchoice                �
//��������������������������������������������������������

	aAdd(aCmpoView, "NOUSER")
	For nC := 1 to 4
		cCpo  := Str(nC, 1)
		cCampoE := "TGY_ENTRA"+cCpo
		cCampoS := "TGY_SAIDA"+cCpo
		aAdd(aCmpoView, AllTrim(cCampoE))
		aAdd(aCmpoView, AllTrim(cCampoS))
		M->&(cCampoE) := CriaVar(cCampoE)
		M->&(cCampoS) := CriaVar(cCampoS)
		M->&(StrTran(cCampoE, "_")) := M->&(cCampoE)
		M->&(StrTran(cCampoS, "_")) := M->&(cCampoS)
		If At580eWhen(cCpo)
			uValueE := oModelTGY:GetValue(cCampoE)
			uValueS := oModelTGY:GetValue(cCampoS)
			If Empty(uValueE) .AND. Empty(uValueS)
				uValueE := TxValToHor(At580bHGet(("PJ_ENTRA"+ cCpo)))
				uValueS := TxValToHor(At580bHGet(("PJ_SAIDA"+ cCpo)))
			EndIf
			M->&(cCampoE) := uValueE
			M->&(cCampoS) := uValueS
			M->&(StrTran(cCampoE, "_")) := uValueE
			M->&(StrTran(cCampoS, "_")) := uValueS
			aAdd(aEdit, AllTrim(cCampoE))
			aAdd(aEdit, AllTrim(cCampoS))
		EndIf
	Next nC

	For nC := 1 to Len(aCmpoView)

		If !Empty(GetSX3Cache( aCmpoView[nC], "X3_TIPO" ))

			cValidCpo := "At190DVHr(FwFldGet('"+AllTrim(aCmpoView[nC])+"'))"



			cValid := GetSX3Cache( aCmpoView[nC], "X3_VALID" )
			cWhen := GetSX3Cache( aCmpoView[nC], "X3_WHEN" )

			Aadd(aFields, {GetSX3Cache( aCmpoView[nC], cTitulo ),;
				aCmpoView[nC],;
				GetSX3Cache( aCmpoView[nC], "X3_TIPO" ),;
				GetSX3Cache( aCmpoView[nC], "X3_TAMANHO" ),;
				GetSX3Cache( aCmpoView[nC], "X3_DECIMAL" ),;
				GetSX3Cache( aCmpoView[nC], "X3_PICTURE" ),;
				If(!Empty(cValid),&("{||"+cValid + ".AND."+ cValidCpo+" }"),&("{||"+cValidCpo+" }")),;
					.F.,;
					GetSX3Cache( aCmpoView[nC], "X3_NIVEL" ),;
					GetSX3Cache( aCmpoView[nC], "X3_RELACAO" ),;
					GetSX3Cache( aCmpoView[nC], "X3_F3" ),;
					If(!Empty(cWhen),&("{||"+cWhen+"}"),""),;
						.F.,;
						.F.,;
						GetSX3Cache( aCmpoView[nC], "X3_CBOX" ),;
						1,;
						.F.,;
						GetSX3Cache( aCmpoView[nC], "X3_PICTVAR" ),;
						GetSX3Cache( aCmpoView[nC], "X3_TRIGGER" )})
				EndIf

			Next

			M->EDIT_AUTM := .F.
			aAdd(aCmpoView, "EDIT_AUTM")
			aAdd(aEdit, "EDIT_AUTM")

			Aadd(aFields, {STR0343, ; //"Ajustar Diferen�a de Hor�rios Automaticamente"
			"EDIT_AUTM",;
				"L", ;
				1,;
				0,;
				"",;
				"",;
				.F.,;
				1, ;
				"",;
				"", ;
				"", ;
				.F., ;
				.F.,;
				"",;
				1, ;
				.F., ;
				"", ;
				"N"})


			AAdd( aObjects, { 100, 100, .t., .t. } )

			aInfo := {nEsquerda, nSuperior, nInferior, nDireita, 3,3}
			aPosObj := MsObjSize( aInfo, aObjects )
			aPosObj[01,01] += 30
			aPosObj[01,02] += 3
			aPosObj[01,04] -= 3
			aPosObj[01,03] := (nInferior/2)

			DEFINE MSDIALOG oDlg TITLE STR0244 FROM nSuperior,nEsquerda TO nInferior,nDireita PIXEL	//"Editor de Hor�rios"

			Enchoice ( "TGY", /*[ nReg ]*/, 3,/* [ aCRA ]*/,/* [ cLetras ]*/, /*[ cTexto ] */,aCmpoView ,aPosObj[1] ,/* [ aCpos ]*/aEdit ,;
				2, /*[ nColMens ]*/,/* [ cMensagem ]*/ ,/*[ cTudoOk ]*/, oDlg,;
					 /*[ lF3 ]*/ ,.t. ,/*[ lColumn ]*/ ,/*[ caTela ] */,.t., /*[ lProperty ]*/,aFields,{},/* [ lCreate ] */,/*[ lNoMDIStrech ]*/, /*[ cTela ] */)

			ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| IIF(AT580ePosV(NIL,NIL,"TGY",.T.), ( At190GR(oModelTGY), oDlg:End() ) , NIL)},{||oDlg:End()}, .F., nil, nil, nil, .f., .f., .f., .t., .f., nil)

			Return
//------------------------------------------------------------------------------
/*/{Protheus.doc} At190GR

@description Confirma��o do Editor de Hor�rios
@author	fabiana.silva
@since	24/07/2019
/*/
//-----------------------------------------------------------------------------
Function At190GR(oModelTGY)
	Local nK := 0
	Local cK := ""
	Local cTGY_Entra := ""
	Local cTGY_Saida := ""

	For nK := 1 To 4
		cK := Str(nK, 1)
		cCampoE := "TGY_ENTRA"+ cK
		cCampoS := "TGY_SAIDA"+ cK

		cTGY_Entra := M->&(cCampoE)
		cTGY_Saida := M->&(cCampoS)

		oModelTGY:LoadValue(cCampoE , cTGY_Entra)
		oModelTGY:LoadValue(cCampoS ,cTGY_Saida)
	Next

Return
//------------------------------------------------------------------------------
/*/{Protheus.doc} ValidSXB()

Realiza a valida��o das consultas.

aVldSXB[nX,1] = Consulta
aVldSXB[nX,2] = Tipo da consulta
aVldSXB[nX,3] = Descri��o
aVldSXB[nX,4] = Tabela
aVldSXB[nX,5] = Express�o
aVldSXB[nX,6] = Retorno

@author kaique.olivero
@since 26/07/2019
/*/
//------------------------------------------------------------------------------
Static Function ValidSXB()
	Local lRet 		:= .T.
	Local nX		:= 0
	Local cMsgSXB	:= ""
	Local cTabAA1   := FwSX2Util():GetX2Name("AA1")
	Local lMV_MultFil := TecMultFil() //Indica se a Mesa considera multiplas filiais

	Local aVldSXB	:= {{"T19DCN",STR0245,STR0246	,"CN9",'At190dCons("CONTRATO")'	 	,"At190dRF3()"},;	//"Consulta Espec�fica" # "Contratos - Mesa Op."
	{"T19DCL",STR0245,STR0246	,"CN9",'At190dCons("CONTRATO_TFL")'	,"At190dRF3()"},;	//"Consulta Espec�fica"	# "Contratos - Mesa Op."
	{"T19DBL",STR0245,STR0247  	,"SB1",'At190dCons("PROD_TFL")'	 	,"At190dRF3()"},;	//"Consulta Espec�fica" # "Produto."
	{"T19DFL",STR0245,STR0248  	,"TFF",'At190dCons("POSTO_TFL")'	,"At190dRF3()"},;	//"Consulta Espec�fica" # "Posto de Trabalho."
	{"T19DTF",STR0245,STR0248	,"TFF",'At190dCons("POSTO")'		,"At190dRF3()"},;	//"Consulta Espec�fica" # "Posto de Trabalho."
	{"T19DYL",STR0245,STR0249	,"ABS",'At190dCons("LOCAL_TGY")'	,"At190dRF3()"},;	//"Consulta Espec�fica" # "Local de Atendimento."
	{"T19DLL",STR0245,STR0249	,"ABS",'At190dCons("LOCAL_TFL")'	,"At190dRF3()"},;	//"Consulta Espec�fica" # "Local de Atendimento."
	{"T19DMN",STR0245,STR0250	,"ABN",'At190dCons("MANUT")'		,"At190dRF3()"},;	//"Consulta Espec�fica" # "Motivos Manuten��o."
	{"T19GRP",STR0245,STR0251	,"TGY",'At190dCons("TGY_GRUPO")'	,"At190dRF3()"},;	//"Consulta Espec�fica" # "Grupo."
	{"T19SEQ",STR0245,STR0252	,"TGY",'At190dCons("SEQ")'			,"At190dRF3()"},;	//"Consulta Espec�fica" # "Sequ�ncia."
	{"T19AA1",STR0245,cTabAA1	,"AA1",'At190dCons("AA1")'			,"At190dRF3()"},;	//"Consulta Espec�fica" # "AA1.
	{"T19CAL",STR0245,STR0249	,"TFL",'At190dCons("LOCAL_LCA")'	,"At190dRF3()"},;	//"Consulta Espec�fica" # "Local de Atendimento."
	{"T19DCA",STR0245,STR0246	,"CN9",'At190dCons("CONTRATO_LCA")' ,"At190dRF3()"},;	//"Consulta Espec�fica"	# "Contratos - Mesa Op."
	{"T19DCY",STR0245,STR0246	,"CN9",'At190dCons("CONTRATO_LGY")' ,"At190dRF3()"},;	//"Consulta Espec�fica"	# "Contratos - Mesa Op."
	{"T19CAP",STR0245,STR0248	,"TFF",'At190dCons("POSTO_LCA")'	,"At190dRF3()"},;	//"Consulta Espec�fica" # "Posto de Trabalho."
	{"T19CAY",STR0245,STR0249	,"TFL",'At190dCons("LOCAL_LGY")'	,"At190dRF3()"},;	//"Consulta Espec�fica" # "Local de Atendimento."
	{"T19CFY",STR0245,STR0248	,"TFF",'At190dCons("POSTO_LGY")'	,"At190dRF3()"},;	//"Consulta Espec�fica" # "Posto de Trabalho."
	{"T19TPY",STR0245,STR0030	,"TCU",'At190dCons("TCU_ALOCACOES")',"At190dRF3()"},;	//"Consulta Espec�fica" # "Tp. Movimenta��o."
	{"T19ESY",STR0245,STR0375	,"TDW",'At190dCons("TDW_ALOCACOES")',"At190dRF3()"},; 	//"Consulta Espec�fica" # "C�digo da Escala."
	{"T19FAL",STR0245,STR0502	,"TDX",'At190dCons("LGY_CONFAL")'	,"At190dRF3()"},;
		{"T19LSQ",STR0245,STR0252	,"SPJ",'At190dCons("LGY_SEQ")'		,"At190dRF3()"},;	//"Consulta Espec�fica" # "Sequ�ncia."
	{"T19LGR",STR0245,STR0251	,"TGY",'At190dCons("LGY_GRUPO")'	,"At190dRF3()"};	//"Consulta Espec�fica" # "Grupo."
	}
	If lMV_MultFil
		AADD(aVldSXB, {"T19TDW",STR0245,STR0375,"TDW",'At190dCons("TDW")',"At190dRF3()"}) //"Consulta Espec�fica" # "C�digo da Escala."
		AADD(aVldSXB, {"T19TCU",STR0245,STR0030,"TCU",'At190dCons("TCU")',"At190dRF3()"}) //"Consulta Espec�fica" # "Tp. Movimenta��o."
		AADD(aVldSXB, {"T19TCA",STR0245,STR0030,"TCU",'At190dCons("TCU_BUSCA")',"At190dRF3()"}) //"Consulta Espec�fica" # "Tp. Movimenta��o."
		AADD(aVldSXB, {"T19SA1",STR0245,STR0430,"SA1",'At190dCons("CLIENTE_TFL")',STR0481}) //"Consulta Espec�fica" # "Cliente" # "1� retorno: At190dRF3(1) ; 2� retorno: At190dRF3(2)"
	EndIf

	If At190dItOp()
		AADD(aVldSXB, {"T19TFJ",STR0245,STR0550,"TFJ",'At190dCons("ORCITEXTR")',"At190dRF3()"}) //"Consulta Espec�fica" # "Orc. Item Extra"
		AADD(aVldSXB, {"T19TFL",STR0245,STR0551,"TFL",'At190dCons("LOCITEXTR")',"At190dRF3()"}) //"Consulta Espec�fica" # "Local Item Extra"
	Endif

	DbSelectArea("SXB")
	SXB->(DbSetOrder(1))

	For nX := 1 To Len(aVldSXB)
		If !SXB->(DbSeek(aVldSXB[nX,1]))

			If Empty(cMsgSXB)
				cMsgSXB := STR0253 + "(SXB):"+CRLF+CRLF //"Realize a inclus�o da Consulta Padr�o - "
			Endif

			cMsgSXB += STR0254 + aVldSXB[nX,1]+CRLF			//"Consulta: "
			cMsgSXB += STR0255 + aVldSXB[nX,2]+CRLF			//"Tipo da consulta: "
			cMsgSXB += STR0256 + aVldSXB[nX,3]+CRLF			//"Descri��o: "
			cMsgSXB += STR0257 + aVldSXB[nX,4]+CRLF			//"Tabela: "
			cMsgSXB += STR0258 + aVldSXB[nX,5]+CRLF			//"Express�o: "
			cMsgSXB += STR0259 + aVldSXB[nX,6]+CRLF+CRLF	//"Retorno: "

		Endif
	Next nX

	If !Empty(cMsgSXB)
		AtShowLog(cMsgSXB,STR0260, .T., .T., .F.)	//"Inconsist�ncia na Consulta Padr�o."
		lRet := .F.
	Endif

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At190DAvis()

Aviso informando que j� esta dispon�vel a nova mesa operacional.

@author kaique.olivero
@since 26/07/2019
/*/
//------------------------------------------------------------------------------
Function At190DAvis()
	Local oDlg	 := Nil
	Local cLink  := "http://tdn.totvs.com/pages/viewpage.action?pageId=501478324"

	DEFINE MSDIALOG oDlg TITLE OemToAnsi("Aten��o.") FROM 0,0 TO 200,760 PIXEL

	TSay():New( 010,010,{||OemToAnsi(STR0261)},oDlg,,TFont():New("Tahoma",,-12,.T.,.T.) ,.F.,.F.,.F.,.T.,CLR_BLACK)  //"A nova mesa operacional j� est� dispon�vel."
	TSay():New( 025,010,{||OemToAnsi(STR0262)},oDlg,,TFont():New("Tahoma",,-12,.T.,.T.) ,.F.,.F.,.F.,.T.,CLR_BLACK) //"Consulte mais informa��es sobre esta altera��o no TDN:"
	TGet():New( 040,010,{||cLink },oDlg, 195, 09, "@!",,,,,,,.T.,,,,,,,.T.)

	TButton():New(040,230, OemToAnsi(STR0263), oDlg,{|| ShellExecute("Open", cLink, "", "", SW_NORMAL) },030,011,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Abrir Link"
	TButton():New(040,300, OemToAnsi(STR0264), oDlg,{|| oDlg:End() },26,11,,,.F.,.T.,.F.,,.F.,,,.F. )  //"Ok"

	ACTIVATE MSDIALOG oDlg CENTER

Return ( .T. )
//------------------------------------------------------------------------------
/*/{Protheus.doc} at190dGrava

@description Adicionar cor e alterar a fonte nos bot�es

@author	augusto.albuquerque
@since	29/07/2019
/*/
//------------------------------------------------------------------------------
Static Function ColorButton()
	Local cCssCor	:= "QPushButton{margin-top:1px; border-color:#1F739E; font:bold; border-radius:2px; background-color:#1F739E; color:#ffffff; border-style: outset; border-width:1px; }"

Return (cCssCor)
//------------------------------------------------------------------------------
/*/{Protheus.doc} PreLinTGY()

Fun��o de Prevalidacao dos fields de aloca��o TGY

@author boiani
@since 29/07/2019
/*/
//------------------------------------------------------------------------------
Function PreLinTGY(oMdlTGY,cAction,cField,xValue)
	Local lRet := .T.
	Local nQTDV
	Local lMV_MultFil := TecMultFil() //Indica se a Mesa considera multiplas filiais
	If VALTYPE(oMdlTGY) == 'O' .AND. oMdlTGY:GetId() == "TGYMASTER"
		If cAction == "SETVALUE"
			If cField == "TGY_FILIAL"
				If !EMPTY(xValue) .AND. !(ExistCpo("SM0", cEmpAnt+xValue)                                                                                          )
					lRet := .F.
					Help( " ", 1, "PRELINTGY", Nil, STR0480, 1 ) //O campo filial deve ser preenchido com uma filial v�lida
				Else
					WhensTGY( .F. ,{"TGY_CODTFL", "TGY_TFFCOD", "TGY_ESCALA", "TGY_TIPALO", "TGY_SEQ", "TGY_GRUPO"},.F.)
				EndIf
			ElseIf cField == "TGY_CONTRT"
				If !EMPTY(xValue)
					lRet := CheckContrt(AT190dLimp(xValue), oMdlTGY:GetValue("TGY_FILIAL"))
				Else
					WhensTGY( .F. ,{"TGY_CODTFL", "TGY_TFFCOD", "TGY_ESCALA", "TGY_TIPALO", "TGY_SEQ", "TGY_GRUPO"},.F.)
				EndIf
			ElseIf cField == "TGY_CODTFL"
				If !EMPTY(xValue)
					lRet := CheckTFL(AT190dLimp(xValue) , oMdlTGY:GetValue("TGY_CONTRT"), oMdlTGY:GetValue("TGY_FILIAL") )
				Else
					WhensTGY( .F. ,{ "TGY_TFFCOD", "TGY_ESCALA", "TGY_TIPALO", "TGY_SEQ", "TGY_GRUPO"},.F.)
				EndIf
			ElseIf cField == "TGY_TFFCOD"
				If !EMPTY(xValue)
					lRet := CheckTFF(AT190dLimp(xValue) , oMdlTGY:GetValue("TGY_CONTRT") , oMdlTGY:GetValue("TGY_CODTFL"), oMdlTGY:GetValue("TGY_FILIAL"))
					If lRet
						If Posicione("TFF",1,xFilial("TFF",IIF(lMV_MultFil,;
								oMdlTGY:GetValue("TGY_FILIAL"),cFilAnt)) + xValue, "TFF_ENCE") == '1'
							lRet := .F.
							Help( " ", 1, "PRELINTGY", Nil, STR0518 , 1 ) //"N�o � poss�vel gerar novas agendas em um posto encerrado."
						EndIf
					EndIf
				Else
					WhensTGY( .F. ,{ "TGY_ESCALA", "TGY_TIPALO", "TGY_SEQ", "TGY_GRUPO"},.F.)
				EndIf
			ElseIf cField == "TGY_ESCALA"
				If !EMPTY(xValue)
					lRet := CheckTDW(AT190dLimp(xValue), oMdlTGY:GetValue("TGY_FILIAL"))
				Else
					WhensTGY( .F. ,{"TGY_TIPALO", "TGY_SEQ", "TGY_GRUPO"},.F.)
				EndIf
			ElseIf cField == "TGY_TIPALO"
				If !EMPTY(xValue)
					lRet := CheckTCU(AT190dLimp(xValue),oMdlTGY:GetValue("TGY_FILIAL"))
				EndIf
			ElseIf cField == "TGY_SEQ"
				If !EMPTY(xValue)
					lRet := CheckTDX(AT190dLimp(xValue), oMdlTGY:GetValue("TGY_ESCALA"),,oMdlTGY:GetValue("TGY_FILIAL") )
				EndIf
			ElseIf cField == "TGY_GRUPO"
				If !EMPTY(xValue)
					nQTDV := Posicione("TFF", 1, xFilial("TFF",IIF(lMV_MultFil,oMdlTGY:GetValue("TGY_FILIAL"),cFilAnt)) + oMdlTGY:GetValue("TGY_TFFCOD"), "TFF_QTDVEN")
					If (!(At680Perm( Nil, __cUserID, "005" )) .AND. ( nQTDV < xValue))
						Help( " ", 1, "PRELINTGY", Nil, STR0319 + cValToChar(nQTDV) + ")", 1 ) //"A quantidade de atendentes (grupos) ultrapassou o permitido no posto (limite de "
						lRet	:= .F.
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

Return lRet
//------------------------------------------------------------------------------
/*/{Protheus.doc} QryEOF()

Executa uma qry e retorna se EOF

@author boiani
@since 29/07/2019
/*/
//------------------------------------------------------------------------------
Static Function QryEOF(cSql, lChangeQry)
	Local lRet := .F.
	Local cAliasQry := GetNextAlias()
	Default lChangeQry := .T.
	If lChangeQry
		cSql := ChangeQuery(cSql)
	EndIf
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSql),cAliasQry, .F., .T.)
	lRet := (cAliasQry)->(EOF())
	(cAliasQry)->(DbCloseArea())
Return lRet
//------------------------------------------------------------------------------
/*/{Protheus.doc} PreLinAA1()

Fun��o de Prevalidacao dos fields de atendente AA1

@author boiani
@since 30/07/2019
/*/
//------------------------------------------------------------------------------
Static Function PreLinAA1(oMdlAA1,cAction,cField,xValue)
	Local lRet := .T.
	Local cQry
	If VALTYPE(oMdlAA1) == 'O' .AND. oMdlAA1:GetId() == "AA1MASTER"
		If cAction == "SETVALUE"
			If cField == "AA1_CODTEC"
				If !EMPTY(xValue)
					xValue := AT190dLimp(xValue)
					cQry := " SELECT 1 "
					cQry += " FROM " + RetSqlName("AA1") + " AA1 "
					cQry += " WHERE AA1.AA1_FILIAL = '" +  xFilial('AA1') + "' AND "
					cQry += " AA1.D_E_L_E_T_ = ' ' "
					cQry += " AND AA1.AA1_CODTEC = '" + xValue + "' "
					If (QryEOF(cQry))
						lRet := .F.
					EndIf
				EndIf
			EndIF
		EndIf
	EndIf

Return lRet
//------------------------------------------------------------------------------
/*/{Protheus.doc} At190DDlt()

Fun��o para desalocar atendentes na aba de manuten��o de agendas
	
@author Diego Bezerra
@since 25/07/2019
/*/
//------------------------------------------------------------------------------
Function At190DDlt(lProjRes, lTrcEft, cCodTec, cMsg, lAutomato, cPrimCbo, nSucc, nFail, aErrors, lShowRet, lPergManut)
	Local nX
	Local lMV_MultFil := TecMultFil() //Indica se a Mesa considera multiplas filiais
	Local lRet
	Local lMultFils := .F.
	Local cFil1 := ""
	Local oModel := FwModelActive()
	Local oMdlABB := oModel:GetModel("ABBDETAIL")
	Local aDados := {}
	Local cFilBkp := cFilAnt
	Default lAutomato := .F.
	For nX := 1 To Len(aMarks)
		If !Empty(aMarks[nX][1])
			If EMPTY(cFil1)
				cFil1 := aMarks[nX][12]
			ElseIf cFil1 != aMarks[nX][12]
				lMultFils := .T.
				Exit
			EndIf
		EndIf
	Next nX

	If lMV_MultFil .AND. lMultFils
		If lAutomato .OR. isBlind() .OR. MsgYesNo(STR0472) //"Confirmar a exclus�o das agendas selecionadas?"
			For nX := 1 To oMdlABB:Length()
				oMdlABB:GoLine(nX)
				If oMdlABB:GetValue("ABB_MARK")
					AADD(aDados, {oMdlABB:GetValue("ABB_CODIGO"),;
						oMdlABB:GetValue("ABB_FILIAL"),;
						oModel:GetValue("AA1MASTER","AA1_CODTEC"),;
						oMdlABB:GetValue("ABB_IDCFAL"),;
						oMdlABB:GetValue("ABB_DTINI"),;
						oMdlABB:GetValue("ABB_HRINI"),;
						oMdlABB:GetValue("ABB_DTFIM"),;
						oMdlABB:GetValue("ABB_HRFIM"),;
						oMdlABB:GetValue("ABB_ATENDE"),;
						oMdlABB:GetValue("ABB_CHEGOU"),;
						oMdlABB:GetValue("ABB_DTREF"),;
						oMdlABB:GetValue("ABB_RECABB");
						})
				EndIf
			Next nX
			at190dELoc(aDados, .F.)
			At190DLoad()
		Else
			Help( " ", 1, "VldDelLOC", Nil, STR0299, 1 ) //"Opera��o cancelada."
		EndIf
	Else
		If lMV_MultFil .AND. !EMPTY(cFil1)
			cFilAnt := cFil1
		EndIf
		lRet := At190DDlt2(lProjRes, lTrcEft, cCodTec, cMsg, lAutomato, cPrimCbo, @nSucc, @nFail, @aErrors, lShowRet, lPergManut)
	EndIf

	cFilAnt := cFilBkp

Return lRet
//------------------------------------------------------------------------------
/*/{Protheus.doc} At190DDlt2()

Fun��o para desalocar atendentes na aba de manuten��o de agendas
	
@author Diego Bezerra
@since 25/07/2019
/*/
//------------------------------------------------------------------------------
Function At190DDlt2(lProjRes, lTrcEft, cCodTec, cMsg, lAutomato, cPrimCbo, nSucc, nFail, aErrors, lShowRet, lPergManut)

	Local oModel	:= FwModelActive()
	Local oMdlAA1	:= NIL
	Local nX 		:= 0
	Local nY		:= 1
	Local nI		:= 0
	Local nCount	:= 0
	Local cError	:= ""
	Local lContinua	:= .T.
	Local lManut	:= .F.
	Local cLog		:= ""
	Local lGrvCus	:= SuperGetMv("MV_GRVTWZ",,.T.)
	Local aPostos	:= {}
	Local lRetPosto	:= .F.
	Local lSucesso 	:= .T. //Rotina Executada com sucesso
	Local lCompen	:= TecABRComp()
	Local oMdlABB	:= oModel:GetModel("ABBDETAIL")
	Local dDataAux	:= StoD("")
	Local lManutAux	:= .F.

	Default lProjRes	:= .F. //Dele��o de agenda via grava��o de agenda, em caso de reserva t�cnica
	Default lTrcEft 	:= .F. //exclus�o pela troca de efetivo
	Default cMsg		:= ""
	Default lAutomato   := .F.
	Default cPrimCbo	:= ""
	Default nFail		:= 0
	Default nSucc		:= 0
	Default aErrors		:= {}
	Default lShowRet 	:= .T.
	Default lPergManut  := .T.

	At550SetAlias("ABB")
	At550SetGrvU(.T.)

	If !lTrcEft
		oMdlAA1 := oModel:GetModel("AA1MASTER")
		If Empty(cCodTec)
			cCodTec := oMdlAA1:GetValue("AA1_CODTEC")
		EndIf
	EndIf


	If Empty(cCodTec)
		cError := STR0289 // "Atendente n�o selecionado."
		lContinua := .F.
	EndIf

	If lContinua .AND. !lTrcEft
		//Troca de efetivo j� valida manuten��o de agendas
		For nI := 1 To Len(aMarks)
			If !EMPTY(aMarks[nI][1])
				lManutAux := .F.
				If ABR->(DbSeek(xFilial("ABR")+aMarks[nI][1]))
					lManut := .T.
					lManutAux := .T.
				EndIf
				If lCompen
					If dDataAux <> aMarks[nI][9]
						If !lManutAux .OR. !Empty(ABR->ABR_COMPEN)
							If !DayAbbComp( aMarks[nI][9], lManutAux, cCodTec)
								lContinua := .F.
								cError := STR0595
								//"N�o � possivel prosseguir com a opera��o de exclus�o, pois uma das agendas selecionadas cont�m manuten��o do tipo compensa��o.
								//	Selecione todas as agendas do dia para prosseguir."
								Exit
							EndIf
						EndIf
						dDataAux := aMarks[nI][9]
					EndIf
				EndIf
				nCount++
			EndIf
		Next nI
	ElseIf lContinua .AND. lTrcEft
		nCount := Len(aMarks)
	EndIf

	If lContinua .AND. nCount > 0
		If !lProjRes .AND. !lTrcEft  .AND. !lAutomato .AND. !isInCallStack("at190DeLoc")
			lContinua := MsgYesNo(STR0290) //"Voc� est� prestes a deletar algumas agendas selecionadas. Deseja continuar?"
		EndIf

		If lContinua .AND. Len(aMarks) > 0
			lRetPosto := getPosto(cCodTec, @aPostos, lAutomato, cPrimCbo)

			If lContinua .AND. lRetPosto

				DbSelectArea("ABB")
				DbSetOrder(1)

				DbSelectArea("ABR")
				DbSetOrder(1)

				If nCount > 0

					If lManut
						If lPergManut
							lContinua := (Aviso(STR0187,STR0315,{STR0316,STR0317},2) == 1)	//"Aten��o" #"Foram encontradas uma ou mais agendas com manuten��es relacionadas. Escolha SEM MANUTEN��O para excluir apenas as agendas sem manuten��o, ou EXCLUIR TUDO, para excluir as agendas, manuten��es e agenda dos substitutos"#"Excluir tudo"#"Sem Manuten��o"
						Else
							lContinua := .T.
						EndIf
					EndIf
					If lProjRes
						cMsgProc	:= STR0321 // "Removendo as agendas do posto de reserva"
					ElseIf !lTrcEft
						cMsgProc 	:= STR0312 //"Processando a remo��o das agendas selecionadas... "
					Else
						cMsgProc 	:= STR0344 //"Processando a remo��o das agendas de efetivo... "
					EndIf
					// Realiza o processamento das exclus�es
					If !isBlind() .AND. !isInCallStack("at190DeLoc")
						FwMsgRun(Nil, {||  at190drdl(@oModel,cCodTec, lManut, lContinua, @nCount, @nFail, @nSucc, @cLog, lGrvCus, @aErrors, lProjRes, lTrcEft ) }, Nil, cMsgProc,50,11,,,.F.,.T.,.F.,,.F.,,,.F. )
					Else
						at190drdl(@oModel,cCodTec, lManut, lContinua, @nCount, @nFail, @nSucc, @cLog, lGrvCus, @aErrors, lProjRes, lTrcEft )
					EndIf
				Else
					Help(,,"AT190DDLT",,STR0298,1,0) //"N�o h� dados selecionados para deletar."
				EndIf
			Else
				If !lRetPosto
					lSucesso := .F.
					Help( " ", 1, "AT190DDLT", Nil, STR0536+cCodTec, 1 ) //"Falha na exclus�o de agendas do atendente: "
					FwModelActive(oModel)
					// refresh
					If !lTrcEft
						At190DLoad()
					EndIf
				Else
					FwModelActive(oModel)
					// refresh
					If !lTrcEft
						At190DLoad()
					EndIf
				EndIf
			EndIf
		Else
			If Len(aMarks) < 1
				Help(,,"AT190DDLT",,STR0298 ,1,0)//"N�o h� dados selecionados para deletar."
			Else
				If !lTrcEft
					At190DLoad()
				EndIf
			EndIf
		EndIf

	Else
		If!Empty(cError)
			Help(,,"AT190DDLT",,cError,1,0)
		EndIf
		FwModelActive(oModel)
	EndIf
	If lShowRet
		If !EMPTY(aErrors)
			cMsg += STR0300 + " " + cValToChar(nSucc+nFail) + CRLF // "Total de agendas processadas:"
			cMsg += STR0301 + " " + cValToChar(nSucc) + CRLF //"Total de manuten��es exclu�das:"
			cMsg += STR0302 + " " + cValToChar(nFail) + CRLF + CRLF //"Total de manuten��es n�o exclu�das:"
			cMsg += STR0303 + CRLF + CRLF //"As agendas abaixo n�o foram exclu�das: "

			For nX := 1 To LEN(aErrors)
				For nY := 1 To LEN(aErrors[nX])
					cMsg += aErrors[nX][nY] + CRLF
				Next
				cMsg += CRLF + REPLICATE("-",30) + CRLF
			Next
			cMsg += CRLF + STR0304 //"Ocorreram problemas ao excluir esse registro."
			If !ISBlind() .AND. !lTrcEft
				AtShowLog(cMsg,STR0305 ,/*lVScroll*/,/*lHScroll*/,/*lWrdWrap*/,.F.) //"Exclus�o de agendas"
			EndIf
			lSucesso := .F.
		Else
			If nSucc > 0 .AND. !lProjRes .AND. !lTrcEft
				MsgInfo(cValToChar(nSucc) + STR0306) //" registro(s) exclu�do(s)"
			EndIf
		EndIf
	EndIf
	At550SetAlias("")
	At550SetGrvU(.F.)

	If !lProjRes .AND. !lTrcEft .AND. !isInCallStack("At190deLoc")
		At190DClr()
	Endif

Return lSucesso

//------------------------------------------------------------------------------
/*/{Protheus.doc} At190DDlt()

Utilizada para atualizar a data da �ltima aloc�o (TGY) na remo��o das agendas
@param cCodABB C�digo da agenda do primeiro dia desalocado
@param dDtIni Primeira data desalocada
@param cHrini Hor�rio inicial da primeira agenda desalocada

@author Diego Bezerra
@since 25/07/2019
/*/
//------------------------------------------------------------------------------
Function at190Dult(cCodABB, aPriDes, aUltDes, cKeyTGY, cIdcfal, cCodTFF, lProjRes, aErrors)

	Local cQueryTGY := ""
	Local cSql 		:= ""
	Local lAtDfTGY	:= SuperGetMv("MV_ATDFTGY",,.F.) // Par�metro que controla a atualiza��o do campo TGY_DTFIM
	Local lHasAbbR 	:= .T.
	Local lHasAbbL	:= .T.
	Local dDtIni  	:= aPriDes[1][1]
	Local dUltDes	:= aUltDes[1][1]
	Local dUltAlo	:= sTod("")
	Local lAux		:= .F.
	Local oMdl580e  := Nil
	Local oMdlTDX   := Nil
	Local oMdlTGY	:= Nil
	Local nX		:= 0
	Local cY_ATEND  := ""
	Local cY_ESCALA := ""
	Local cY_CODTDX := ""
	Local cY_ITEM   := ""
	Local lMdtGS 	:= SuperGetMv("MV_NG2GS",.F.,.F.) .And. TableInDic("TN5") .And. TableInDic("TN6") //Par�metro de integra��o entre o SIGAMDT x SIGATEC
	Local nRecTar	:= 0
	Local cQueryTN5	:= ""

	Default lProjRes 	:= .F. // .T. = Atualiza��o de �ltima aloca��o para contrato de reserva t�cnica
	Default cKeyTGY 	:= ""
	Default cIdcfal		:= ""
	Default cCodTFF		:= ""

	If Empty(cKeyTGY)

		cSql += " SELECT  TGY_FILIAL, TGY_ESCALA, TGY_CODTDX, TGY_CODTFF, TGY_ITEM FROM "+RetSqlName( "ABB" ) + " ABB"
		cSql += " INNER JOIN " + RetSqlName("TDV") + " TDV ON ABB.ABB_CODIGO = TDV.TDV_CODABB"
		cSql += " INNER JOIN " + RetSqlName("TDX") + " TDX ON TDX.TDX_TURNO = TDV.TDV_TURNO"
		cSql += " INNER JOIN " + RetSqlName("TGY") + " TGY ON TGY.TGY_ATEND = ABB.ABB_CODTEC
		cSql += " INNER JOIN " + RetSqlName("ABQ") + " ABQ ON (ABQ.ABQ_CONTRT || ABQ.ABQ_ITEM || ABQ.ABQ_ORIGEM = ABB.ABB_IDCFAL AND ABQ.ABQ_CODTFF = TGY.TGY_CODTFF) "
		cSql += " INNER JOIN " + RetSqlName("TDW") + " TDW ON ( TDW.TDW_COD = TDX.TDX_CODTDW AND TDW.TDW_COD = TGY.TGY_ESCALA) "
		cSql += " WHERE "
		cSql += " ABB.ABB_FILIAL = '" + xFilial("ABB") + "' AND ABB.D_E_L_E_T_ = ' ' AND"
		cSql += " TDV.TDV_FILIAL = '" + xFilial("TDV") + "' AND TDV.D_E_L_E_T_ = ' ' AND"
		cSql += " TDX.TDX_FILIAL = '" + xFilial("TDX") + "' AND TDX.D_E_L_E_T_ = ' ' AND"
		cSql += " TGY.TGY_FILIAL = '" + xFilial("TGY") + "' AND TGY.D_E_L_E_T_ = ' ' AND"
		If !Empty(cCodTFF)
			cSql += " TGY.TGY_CODTFF = '" + cCodTFF + "' AND"

		EndIf
		cSql += " ABB.ABB_CODIGO = '" + cCodABB + "' AND ABB.ABB_DTINI = '" + dToS(dDtini) + "' AND ABB.ABB_HRINI = '" + aPriDes[1][2] + "' AND"
		cSql += " ABB.ABB_IDCFAL = '" + cIdcfal + "'"
		cSql := ChangeQuery(cSql)

		cQueryTGY := GetNextAlias()
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSql),cQueryTGY, .F., .T.)

		If (cQueryTGY)->(!EOF())
			cKeyTGY := (cQueryTGY)->TGY_FILIAL + (cQueryTGY)->TGY_ESCALA + (cQueryTGY)->TGY_CODTDX + (cQueryTGY)->TGY_CODTFF + (cQueryTGY)->TGY_ITEM
		EndIf
		(cQueryTGY)->(dbCloseArea())
	Else

		DbSelectArea("TGY")
		TGY->(DbSetOrder(1))
		If TGY->(DbSeek( cKeyTGY ) )
			lHasAbbR := ABBRigIdC(dDtIni, TGY->TGY_CODTFF, TGY->TGY_ATEND, cIdcfal)
			lHasAbbL := HasAbbL(dDtIni, TGY->TGY_CODTFF, TGY->TGY_ATEND, cIdcfal)

			If !lHasAbbR .AND. !lHasAbbL
				dUltAlo := cToD(SPACE(08))
				lAux := .T.
			EndIf

			If !lAux
				If !lHasAbbR
					lAux := ABBRigIdC(dUltDes, TGY->TGY_CODTFF, TGY->TGY_ATEND, cIdcfal)

					If lAux .And. lHasAbbl
						dUltAlo := dUltDes-1
					Else
						If lAux
							dUltAlo := dDtIni-1
						Else
							dUltAlo := dUltDes-1
						EndIf
					EndIf
				Else
					dUltAlo := dDtIni-1
				EndIf
			EndIf

			TGY->(RecLock("TGY", .F.))

			If !lHasAbbR
				If lAtDfTGY
					TGY->TGY_DTFIM := dUltDes-1
				EndIf
				TGY->TGY_ULTALO := dUltAlo
			EndIf

			TGY->( MsUnlock() )

			If lMdtGS //Integra��o entre o SIGAMDT x SIGATEC
				// posicina TFF
				DbSelectArea("TFF")
				TFF->( DbSetOrder(1)) //TFF_FILIAL+TFF_COD

				//posicina TN5
				dbSelectArea("TN5")
				TN5->(dbSetOrder(1)) //TN5_FILIAL+TN5_CODTAR

				If TFF->( ColumnPos("TFF_RISCO")) > 0 .And. TN5->(ColumnPos("TN5_LOCAL")) > 0 .And. TN5->(ColumnPos("TN5_POSTO")) > 0


					//posicina TN6
					dbSelectArea("TN6")
					TN6->(dbSetOrder(1)) //TN6_FILIAL+TN6_CODTAR+TN6_MAT+DTOS(TN6_DTINIC)

					If TFF->(DbSeek(xFilial("TFF")+TGY->TGY_CODTFF)) .And.;
							AA1->(DbSeek(xFilial("AA1")+TGY->TGY_ATEND)) .And.;
							!Empty(AA1->AA1_CDFUNC) .And. TFF->TFF_RISCO == "1"

						cQueryTN5	:= GetNextAlias()

						BeginSql Alias cQueryTN5
					
						SELECT TN5.R_E_C_N_O_ TN5RECNO
						FROM %Table:TN5% TN5
						WHERE TN5.TN5_FILIAL	= %exp:xFilial('TN5')%
							AND TN5.TN5_LOCAL	= %exp:TFF->TFF_LOCAL%
							AND TN5.TN5_POSTO	= %exp:TFF->TFF_FUNCAO%
							AND TN5.%NotDel%
						EndSql

						If (cQueryTN5)->(!EOF())
							nRecTar := (cQueryTN5)->TN5RECNO
							TN5->(DbGoTo(nRecTar))

							If !lHasAbbR .And. nRecTar > 0 .And. TN6->(dbSeek(xFilial("TN6")+TN5->TN5_CODTAR+AA1->AA1_CDFUNC+Dtos(TGY->TGY_DTINI)))
								TN6->(RecLock("TN6", .F.))
								TN6->TN6_DTTERM := TGY->TGY_ULTALO
								TN6->( MsUnlock() )
							Endif
						Endif
						(cQueryTN5)->(DbCloseArea())
					Endif
				Endif
			Endif

			DbSelectArea("TFF")
			TFF->(DbSetOrder(1))

			If !lHasAbbR .AND. !lHasAbbL .And. TFF->(DBSeek(xFilial("TFF") + TGY->TGY_CODTFF))

				cY_ATEND  := TGY->TGY_ATEND
				cY_ESCALA := TGY->TGY_ESCALA
				cY_CODTDX := TGY->TGY_CODTDX
				cY_ITEM   := TGY->TGY_ITEM

				oMdl580e := FwLoadModel("TECA580E")
				oMdl580e:SetOperation(MODEL_OPERATION_UPDATE)
				oMdl580e:Activate()

				oMdlTDX := oMdl580e:GetModel("TDXDETAIL")
				oMdlTGY := oMdl580e:GetModel("TGYDETAIL")

				At580VdFolder({1})

				For nX := 1 to oMdlTDX:Length()
					oMdlTDX:GoLine(nX)

					If oMdlTGY:SeekLine({{ "TGY_ATEND"	, cY_ATEND },;
							{ "TGY_ESCALA"	, cY_ESCALA},;
							{ "TGY_CODTDX"	, cY_CODTDX},;
							{ "TGY_ITEM"	, cY_ITEM  }})

						If oMdlTGY:DeleteLine()

							If !(oMdl580e:VldData() .And. oMdl580e:CommitData())
								at190DErr( @aErrors, oMdl580e )
							Else
								If nRecTar > 0
									TN6->(RecLock("TN6", .F.))
									TN6->(DbDelete())
									TN6->( MsUnlock() )
								Endif
							Endif

						Else
							at190DErr( @aErrors, oMdl580e )
						Endif

					Endif

				Next nX

				oMdl580e:DeActivate()
				oMdl580e:Destroy()

			Endif
		EndIf
	EndIf

Return cKeyTGY

//------------------------------------------------------------------------------
/*/{Protheus.doc} at190dSubs()

Verifica se uma agenda possui manuten��o com substituto

@param cAbbCodSb string, c�digo do atendente
@param dAbbDtIni data, data in�cio da agenda
@param dAbbDtFim data, data Final da Agenda
@param cAbbHrFim string, hor�rio final da agenda
@param cAbbHrini string, hor�rio inicial da agenda

@author Diego Bezerra
@since 27/07/2019
/*/
//------------------------------------------------------------------------------
Static Function at190dSubs(cAbbCodSb, dAbbDtIni, cAbbHrini, dAbbDtFim, cAbbHrFim  )

	Local cQueryAbb	:= ""
	Local cSql		:= ""
	Local nRec		:= 0

	Default cAbbCodSb	:= ""
	Default dAbbDtIni	:= sTod("")
	Default cAbbHrini	:= ""
	Default dAbbDtFim	:= sTod("")
	Default cAbbHrFim	:= ""

	cSql := "SELECT R_E_C_N_O_ AS REC FROM "+RetSqlName("ABR")+" ABR WHERE ABR_FILIAL = '"+xFilial("ABR")+"' AND ABR_CODSUB ='" + cAbbCodSb + "' AND ABR_DTINI = '" + dTos(dAbbDtIni)
	cSql += "' AND ABR_HRINIA ='" + cAbbHrini + "' AND ABR_DTFIM = '" + dTos(dAbbDtFim) + "' " + " AND ABR_HRFIMA = '" + cAbbHrFim
	cSql += "' AND ABR.D_E_L_E_T_ = ' '"

	cQueryAbb := getNextAlias()
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSql),cQueryAbb, .F., .T.)

	If (cQueryAbb)->(!EOF())
		nRec := (cQueryAbb)->REC
	EndIf

	(cQueryAbb)->(dbCloseArea())

Return nRec

//------------------------------------------------------------------------------
/*/{Protheus.doc} at190DErr()

Utilizada para preencher o array de erros aError

@param aError array, cont�m mensagens de erro MVC
@param oModel objeto, modelo ativo
@param cLog string, cont�m mensagens de erro espec�ficas

@author Diego Bezerra
@since 27/07/2019
/*/
//------------------------------------------------------------------------------
Static function at190DErr(aErrors, oModel, cLog)
	Local aErroMVC	:= {}

	Default oModel	:= Nil
	Default cLog	:= ""

	If ValType(oModel) == "O"
		aErroMVC := oModel:GetErrorMessage()
	EndIf

	If oModel != Nil
		AADD(aErrors, {	 STR0158 + ' [' + AllToChar( aErroMVC[1] ) + ']',; //"Id do formul�rio de origem:"
		STR0159 + ' [' + AllToChar( aErroMVC[2] ) + ']',; //"Id do campo de origem:"
		STR0160 + ' [' + AllToChar( aErroMVC[3] ) + ']',; //"Id do formul�rio de erro:"
		STR0161 + ' [' + AllToChar( aErroMVC[4] ) + ']',; //"Id do campo de erro:"
		STR0162 + ' [' + AllToChar( aErroMVC[5] ) + ']',; //"Id do erro:"
		STR0163 + ' [' + AllToChar( aErroMVC[6] ) + ']',; //"Mensagem do erro:"
		STR0164 + ' [' + AllToChar( aErroMVC[7] ) + ']',; //"Mensagem da solu��o:"
		STR0165 + ' [' + AllToChar( aErroMVC[8] ) + ']',; //"Valor atribu�do:"
		STR0166 + ' [' + AllToChar( aErroMVC[9] ) + ']'}) //"Valor anterior:"

	Else
		AADD(aErrors,{ cLog })
	EndIf

Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} getPosto

Organiza array aMarks conforme postos de trabalho

@param cCodTec, string, c�digo do atendente
@param aPostos, array, array auxiliar utilizado para agrupar o array aMarks

@author	Diego Bezerra
@since	29/07/2019
/*/
//------------------------------------------------------------------------------
Static Function getPosto(cCodTec, aPostos, lAutomato, cPrimCbo)

	Local cSql		:= ""
	Local nI 		:= 0
	Local dDtIni	:= sTod("")
	Local dDtFim	:= sTod("")
	Local cIdCFal	:= ""
	Local lIdcFal	:= .F.
	Local cQueryLoc := ""
	Local cCombo
	Local aCombo	:= {}
	Local aDados	:= {}
	Local nPos		:= 0
	Local nRet		:= 1
	Local nSuperior := 0
	Local nEsquerda := 0
	Local nInferior := 432
	Local nDireita  := 864
	Local lRet		:= .T.
	Local oCombo	:= NIL
	Local cChave 	:= ""
	Local nTamCombo := 0

	Default aPostos	:= {}
	Default lAutomato := .F.
	Default cPrimCbo := ""

	For nI := 1 to Len(aMarks)
		If !Empty(aMarks[nI][1])
			If !Empty(cIdcFal) .AND. !lIdcFal
				If cIdcFal != aMarks[nI][8]  .AND. !Empty(aMarks[nI][8])
					lIdcFal := .T.
				EndIf
			Else
				cIdcFal := aMarks[nI][8]
			EndIf

			If !Empty(dDtIni)
				If dDtIni > aMarks[nI][2]
					dDtIni := aMarks[nI][2]
				EndIf
			Else
				dDtIni := aMarks[nI][2]
			EndIf

			If !Empty(dDtFim)
				If dDtFim < aMarks[nI][4]
					dDtFim := aMarks[nI][4]
				EndIf
			Else
				dDtFim := aMarks[nI][4]
			EndIf
		EndIf
	Next nI

	cSql += " SELECT ABS_LOCAL, ABS_DESCRI, TFF_PRODUT, ABB_IDCFAL, ABB_CODIGO, ABQ_CODTFF, ABB_DTINI, ABB_HRINI, ABB_DTFIM, ABB_HRFIM, ABB_ATENDE, ABB_CHEGOU, TDV_DTREF AS ABB_DTREF, TFF_COD, TFL_CODIGO, ABS_RESTEC"
	cSql += " FROM " + RetSqlName("ABB") + " ABB"
	cSql += " INNER JOIN " + RetSqlName("ABQ") + " ABQ ON ABB_IDCFAL = ABQ.ABQ_CONTRT || ABQ.ABQ_ITEM || ABQ.ABQ_ORIGEM"
	cSql += " INNER JOIN " + RetSqlName("TFF") + " TFF ON TFF_COD = ABQ_CODTFF AND TFF_FILIAL = ABQ_FILTFF "
	cSql += " INNER JOIN " + RetSqlName("TFL") + " TFL ON TFL_CODIGO = TFF_CODPAI"
	cSql += " INNER JOIN " + RetSqlName("ABS") + " ABS ON ABS_LOCAL = TFL_LOCAL"
	cSql += " INNER JOIN " + RetSqlName("TDV") + " TDV ON TDV_CODABB = ABB_CODIGO"
	cSql += " WHERE
	cSql += " ABB.ABB_FILIAL = '" + xFilial("ABB") + "' AND ABB.D_E_L_E_T_ = ' ' AND"
	cSql += " ABQ.ABQ_FILIAL = '" + xFilial("ABQ") + "' AND ABQ.D_E_L_E_T_ = ' ' AND"
	cSql += " TFF.TFF_FILIAL = '" + xFilial("TFF") + "' AND TFF.D_E_L_E_T_ = ' ' AND"
	cSql += " TFL.TFL_FILIAL = '" + xFilial("TFL") + "' AND TFL.D_E_L_E_T_ = ' ' AND"
	cSql += " ABS.ABS_FILIAL = '" + xFilial("ABS") + "' AND ABS.D_E_L_E_T_ = ' ' AND"
	csql += " TDV.TDV_FILIAL = '" + xFilial("TDV") + "' AND TDV.D_E_L_E_T_ = ' ' AND"
	cSql += " ABB_DTINI BETWEEN '" + Iif(ValType(dDtIni) == "D",dToS(dDtIni),dDtIni ) + "' AND '" + Iif(ValType(dDtFim)=="D",dToS(dDtFim), dDtFim) + "'"
	cSql += " AND ABB_CODTEC = '" + cCodTec + "'"

	cSql := ChangeQuery(cSql)
	cQueryLoc := GetNextAlias()
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSql),cQueryLoc, .F., .T.)

	While ((cQueryLoc)->(!EOF()))

		cChave := RTRIM((cQueryLoc)->ABS_DESCRI) + " - " + RTRIM((cQueryLoc)->TFF_PRODUT) + " - " + (cQueryLoc)->TFF_COD
		If !Empty(cPrimCbo) .AND. cPrimCbo == (cQueryLoc)->ABS_LOCAL
			cPrimCbo := cChave
		EndIf

		nPos := aScan(aDados, {|x| x[1] == cChave })
		If aScan(aMarks, {|x| x[1] == (cQueryLoc)->ABB_CODIGO} ) > 0

			If aScan(aCombo,{|x| x == cChave }) == 0
				nTamCombo := Max(Len(cChave),nTamCombo)
				aAdd(aCombo, cChave)
			EndIf
			If nPos == 0
				aAdd(aDados, {cChave }, {})
				nPos := Len(aDados)
			EndIf
			aAdd(aDados[nPos], {(cQueryLoc)->ABB_CODIGO,;
				StoD((cQueryLoc)->ABB_DTINI),;
				(cQueryLoc)->ABB_HRINI,;
				StoD((cQueryLoc)->ABB_DTFIM),;
				(cQueryLoc)->ABB_HRFIM,;
				(cQueryLoc)->ABB_ATENDE,;
				(cQueryLoc)->ABB_CHEGOU,;
				(cQueryLoc)->ABB_IDCFAL,;
				StoD((cQueryLoc)->ABB_DTREF),;
				.F.,;//Reserva Tecnica
			(cQueryLoc)->TFF_COD})
		EndIf
		(cQueryLoc)->(DbSkip())
	End

	(cQueryLoc)->(DbCloseArea())

	If LEN(aCombo) > 1
		lRet := .F.
		cCombo := aCombo[1]
		aPostos := {}
		for nI := 1 to Len(aDados[1])
			If ValType(aDados[1][nI]) == "A"
				aAdd(aPostos,aDados[1][nI])
			EndIf
		Next nI

		If !lAutomato
			DEFINE MSDIALOG oDlgEscTela TITLE STR0307 FROM nSuperior,nEsquerda TO nInferior,nDireita PIXEL //"Sele��o de postos"

			@ 2, 9 SAY STR0308 SIZE 300, 19 PIXEL //"Existem agendas para mais de um posto de trabalho, referente ao atendente selecionado. Escolha o posto de trabalho para o qual deseja excluir as agendas. "
			oCombo := TComboBox():New(016,006,{|u|if(PCount()>0,cCombo:=u,cCombo)},aCombo,CalcFieldSize("C", nTamCombo, 2, "@!", STR0307),20,oDlgEscTela,,{|| at190dRfp(@aDados, cCombo, @nRet, @oListBox, lAutomato ) },,,,.T.,,,,,,,,,'cCombo')
			oListBox := TWBrowse():New(039, 007, 415, 165,,{},,oDlgEscTela,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
			oListBox:addColumn(TCColumn():New(STR0012 ,&("{|| oListBox:aARRAY[oListBox:nAt,9] }"),,,,,45)) //"Data de Refer�ncia"
			oListBox:addColumn(TCColumn():New("Dia",&("{|| TECCdow(DOW(oListBox:aARRAY[oListBox:nAt,02])) }"),,,,,39))
			oListBox:addColumn(TCColumn():New(STR0309 ,&("{|| oListBox:aARRAY[oListBox:nAt,3] }"),,,,,39)) //"Horario Inicial"
			oListBox:addColumn(TCColumn():New(STR0310 ,&("{|| oListBox:aARRAY[oListBox:nAt,5] }"),,,,,39)) //"Horario Final"
			oExit := TButton():New( 12, 380, STR0109 ,oDlgEscTela,{|| oListBox:aARRAY := {}, lRet := .T., oDlgEscTela:End() }, 38,12,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Confirmar"

			oListBox:SetArray(aPostos)
			oListBox:Refresh()
			ACTIVATE MSDIALOG oDlgEscTela CENTERED
		Else
			at190dRfp(@aDados, cPrimCbo, @nRet, NIL, lAutomato)
			lRet := .t.
		EndIf

	EndIf

	If lRet
		aPostos := {}
		If LEN(aDados) > 0 .AND. nRet > 0
			for nI := 1 to Len(aDados[nRet])
				If ValType(aDados[nRet][nI]) == "A"
					aAdd(aPostos,aDados[nRet][nI])
				EndIf
			Next nI

			aMarks := aClone(aPostos)
		Else
			lRet := .F.
		EndIf
	EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} at190dRfp()

Atualiza objeto oListBox da tela de sele��o dos postos, ao excluir agendas

@param aDados, array, dados das agendas que est�o sendo exclu�das
@param cCombo, string, op��o selecionada no combobox
@param nRet, num�rico, posi��o referente a divis�o do array aMarks

@author Diego Bezerra
@since 27/07/2019
/*/
//------------------------------------------------------------------------------
Static Function at190dRfp(aDados, cCombo, nRet, oListBox, lAutomato )

	Local nI := 0

	Default lAutomato := .f.

	If !lAutomato .AND. VAlTYPE(oListBox) == 'O' .AND. VALTYPE(oListBox:aARRAY) == 'A'
		oListBox:aARRAY := {}
	EndIf

	nRet := ASCAN(aDados,{|x| x[1] == cCombo})
	aPostos := {}

	for nI := 1 to Len(aDados[nRet])
		If ValType(aDados[nRet][nI]) == "A"
			aAdd(aPostos,aDados[nRet][nI])
		EndIf
	Next nI

	If !lAutomato  .and. VAlTYPE(oListBox) == 'O' .AND. VALTYPE(oListBox:aARRAY) == 'A'
		oListBox:aARRAY := aPostos
		oListBox:Refresh()
	EndIf

Return Nil

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} hasABBRig
@description  Retorna se Existe ABB depois de uma determinada data
@return lRet, Bool
@author Diego Bezerra
@since  30/07/2019
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function ABBRigIdC(dtFim, codTFF, codAtd, idcfal)

	Local cAliasLAg := getNextAlias()
	Local lRet := .F.

	Default codTFF := ""

	BeginSql Alias cAliasLAg

	COLUMN ABB_DTINI AS DATE
	SELECT DISTINCT ABB_IDCFAL  	
	FROM 
		%table:TGY% TGY INNER JOIN %table:ABB% ABB
		ON ABB.ABB_CODTEC = TGY.TGY_ATEND
		WHERE 
		    ABB.ABB_FILIAL = %xFilial:ABB% AND TGY.TGY_FILIAL = %xFilial:TGY%
			AND TGY.TGY_CODTFF = %Exp:codTFF% AND TGY.TGY_ATEND = %Exp:codAtd% AND ABB.ABB_DTINI > %Exp:dtFim%
			AND ABB.ABB_IDCFAL = %Exp:idcfal% 
			AND ABB.%NotDel% AND TGY.%NotDel% 
 
	EndSql

	If (cAliasLAg)->(!Eof())
		lRet := .T.
	EndIf

	(cAliasLAg)->(dbCloseArea())

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} at190drdl
@description  Retorna se Existe ABB depois de uma determinada data
@param oModel objeto, modelo de dados ativo
@param cCodTec string, c�digo do atendente
@param lManut booleano, indica se ser�o (.T.) ou n�o (.F.) exclu�das as agendas com manuten��es e suas respectivas manuten��es
@param lContinua booleano, vari�vel de controle de erro utilizada na fun��o chamadora
@param nCount num�rico, contador de registros processados
@param nFail num�rico, contador de registros processados que falharam
@param nSucc num�rico, contador de registros processados que obtiveram sucesso
@param cLog string, mensagem de erro para registro n�o processado
@param lGrvCus booleano, utilizada para controlar o par�metro MV_GRVTWZ (grava ou n�o custo)
@param aErrors array, cont�m todas as mensagens de erro do processamento atual
@return lRet, Bool
@author Diego Bezerra
@since  31/07/2019
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function at190drdl(oModel, cCodTec, lManut,lContinua,;
		nCount,nFail,nSucc,cLog,lGrvCus,;
		aErrors, lProjRes, lTrocEf )

	Local cCodSub	:= ""
	Local lChegou 	:= .F.
	Local aPriDes 	:= {}
	Local aUltDes	:= {}
	Local nSaldo	:= 0
	Local cLog		:= ""
	Local cIdCfalAt	:= ""
	Local oModelABR	:= Nil
	Local nI		:= 1
	Local aAreaABB	:= Nil
	Local nAbbRec	:= 0
	Local nAbrRec	:= 0
	Local lFailABR
	Local lPrHora 	:= TecABBPRHR()
	Local lCompen	:= TecABRComp()
	Local cCodABB	:= ""
	Local oMdl550 	:= FwLoadModel("TECA550")
	Local aErroMVC	:= {}

	Default lProjRes := .F.
	Default lTrocEf := .F.

	For nI := 1 To Len(aMarks)
		Begin Transaction
			If !Empty(aMarks[nI][1])

				cCodSub := ""
				lChegou := .F.
				nSaldo	:= 0
				cLog 	:= ""
				nAbrRec := 0
				nAbbRec := 0
				aAreaABB := ABB->(getArea())
				ABB->(DbSetOrder(8))
				If ABB->( DbSeek(xFilial("ABB") + aMarks[nI][1]))
					lFailABR := .F.
					nAbbRec := ABB->(Recno())
					cCodABB := ABB->ABB_CODIGO

					If ABB->ABB_CHEGOU == "S" .OR. ABB->ABB_ATENDE == "1"
						nFail++
						lChegou := .T.
						cLog := STR0293 +; // "Agenda In�cio em "
						dToC(aMarks[nI][2])+ STR0294+; //" �s "
						aMarks[nI][3] + STR0295+; //" at� "
						dToC(aMarks[nI][4]) + STR0294 +; //" �s "
						aMarks[nI][5] + STR0296 + CRLF //" n�o pode ser deletada, pois j� foi atendida "
						If isInCallStack("at190dELoc")
							cLog := STR0003 + ": " + ABB->ABB_CODTEC + ": " + cLog //Atendente
						EndIf
					EndIf

					lManut := ABR->(DbSeek(xFilial("ABR")+aMarks[nI][1]))

					If ((lManut .AND. lContinua) .OR. !lManut ) .AND. !lChegou

						// Manuten��es
						If lManut
							If lContinua
								While !lFailABR .AND. ABR->(!Eof()) .AND. ABR->ABR_FILIAL == xFilial("ABR") .AND. ABR->ABR_AGENDA == aMarks[nI][1]
									Begin Transaction
										aMarks[nI][3] := ABR->ABR_HRINIA
										aMarks[nI][5] := ABR->ABR_HRFIMA
										aMarks[nI][9] := ABR->ABR_DTFIMA
										oModelABR := FWLoadModel("TECA550")
										oModelABR:SetOperation(MODEL_OPERATION_DELETE)

										If oModelABR:Activate() .AND. oModelABR:VldData() .AND. oModelABR:CommitData()
											oModelABR:DeActivate()
											oModelABR:Destroy()
										Else
											DisarmTransaction()
											nFail++
											If oModelABR:HasErrorMessage()
												at190DErr(@aErrors, oModelABR)
											EndIf
											lFailABR := .T.
										EndIf

										FwModelActive(oModel)
										ABR->(DbSkip())
										RestArea(aAreaABB)
									End Transaction
								End
							EndIf
						Else
							lManut := .F.
						EndIf
						If !lFailABR
							nAbrRec := at190dSubs(cCodTec, aMarks[nI][2], aMarks[nI][3] , aMarks[nI][4], aMarks[nI][5])
							If nAbrRec == 0

								If Len(aPriDes) == 0
									aAdd(aPrides, {aMarks[nI][2], aMarks[nI][3] })
									cKeyTGY := at190Dult(aMarks[nI][1], aPriDes, aPriDes,/*cKeyTGY*/,aMarks[nI][8], aMarks[nI][11])
								Else
									If aPriDes[1][1] < aMarks[nI][2]
										aPriDes[1][1] := aMarks[nI][2]
										aPriDes[1][2] := aMarks[nI][3]
									EndIf
								EndIf

								If Len(aUltDes) == 0
									aAdd(aUltDes, {aMarks[nI][2], aMarks[nI][3]} )
								Else
									If aUltDes[1][1] > aMarks[nI][2]
										aUltDes[1][1] := aMarks[nI][2]
										aUltDes[1][2] := aMarks[nI][3]
									EndIf
								EndIf

								// Atualizar Custo
								If lGrvCus
									lRetCusto := At330GrvCus( ABB->ABB_IDCFAL, ABB->ABB_CODTWZ, .T. )
								EndIf

								If lRetCusto
									// Atualizar saldo da ABQ
									nSaldo := TecDifHr( VAL(Alltrim(STRTRAN(ABB->ABB_HRINI, ":","."))),VAL(Alltrim(STRTRAN( ABB->ABB_HRFIM, ":","."))))
									TxSaldoCfg(ABB->ABB_IDCFAL,nSaldo,.T.)
								Else
									DisarmTransaction()
									cLog :=  STR0293 +; //" Agenda In�cio em "
									dTos(aMarks[nI][2])+ STR0294 +; //" �s "
									aMarks[nI][3] + STR0295 +; //" at� "
									dTos(aMarks[nI][4]) + STR0294+; //" �s "
									aMarks[nI][5] + STR0297 +;  //" - Erro ao atualizar o saldo do contrato "
									CRLF

									at190DErr(@aErrors, , cLog)
									nFail++
								EndIf

								If lCompen
									cCodABB := HasCompen( cCodABB )
									If !Empty( cCodABB )
										DbSelectArea("ABR")
										ABR->(DbSetOrder(1))
										If ABB->( DbSeek(xFilial("ABB") + cCodABB)) .AND. ABR->( DbSeek(xFilial("ABR") + cCodABB))
											ABB->(RecLock("ABB", .F.))
											ABB->ABB_MANUT := "2"
											ABB->ABB_ATIVO := "1"
											ABB->(MsUnlock())

											oMdl550:SetOperation( MODEL_OPERATION_DELETE)
											oMdl550:Activate()
											If !oMdl550:VldData() .OR. !oMdl550:CommitData()
												nFail++
												aErroMVC := oMdl550:GetErrorMessage()
												at190err(@aErrors, aErroMVC)
												DisarmTransacation()
												oMdl550:DeActivate()
											EndIf
											oMdl550:DeActivate()
										EndIf
									EndIf
								EndIf
								//Posiciona novamente para garantir a exclus�o da ABB correta.
								ABB->(dbGoTo(nAbbRec))

								// Apagar a TDV
								If TDV->(DbSeek(xFilial("TDV") + ABB->ABB_CODIGO))
									TDV->(RecLock("TDV", .F.))
									TDV->(DbDelete())
									TDV->(MsUnlock())
								EndIf

								// Apagar a ABB
								ABB->(RecLock("ABB",.F.))
								ABB->(DbDelete())
								ABB->(MsUnlock())
								nSucc++

								If lPrHora
									TFF->(DbSetOrder(1))
									If TFF->(DbSeek(xFilial("TFF") + aMarks[nI][11]))
										If !Empty(TFF->TFF_QTDHRS)
											TFF->(RecLock("TFF", .F.))
											TFF->TFF_HRSSAL := TecConvHr(SomaHoras(TFF->TFF_HRSSAL, TecConvHr(Left(ElapTime(aMarks[nI][3]+":00", aMarks[nI][5]+":00"), 5))))
											TFF->( MsUnlock() )
										EndIf
									EndIf
								EndIf
							Else
								// Valida se a agenda percente a um substituto e limpa o campo ABR_CODSUB da agenda de cobertura excluida
								DbSelectArea("ABR")
								ABR->(dbGoTo(nAbrRec))
								oModelABR := FWLoadModel("TECA550")
								oModelABR:SetOperation(MODEL_OPERATION_UPDATE)

								If oModelABR:Activate()
									If oModelABR:SetValue("ABRMASTER","ABR_CODSUB","") .AND. oModelABR:VldData() .AND. oModelABR:CommitData()
										nSucc++
										oModelABR:DeActivate()
										oModelABR:Destroy()
									ElseIf oModelABR:HasErrorMessage()
										at190DErr(@aErrors, oModelABR )
										nFail++
										DisarmTransaction()
										Break
									EndIf
								Else
									at190DErr(@aErrors, oModelABR )
									nFail++
									DisarmTransaction()
									Break
								EndIf
							EndIf
						EndIf
						FwModelActive(oModel)
					Else
						If lChegou
							at190DErr(@aErrors, , cLog)
						EndIf
					EndIf
				EndIf
			EndIf
		End Transaction

		If nAbrRec == 0 .AND. Empty(cLog)
			If cIdCfalAt != aMarks[nI][8]
				cIdCfalAt := aMarks[nI][8]
			EndIf
		EndIf

	Next nI

	If nAbrRec == 0 .AND. Len(aPriDes) > 0 .AND. Len(aUltDes) > 0
		at190Dult(aMarks[Len(aMarks)][1], aPriDes, aUltDes, cKeyTGY, cIdCfalAt,/*codtff*/, lProjRes,@aErrors)
	EndIf

	FwModelActive(oModel)
// refresh
	If !lTrocEf .AND. !isInCallStack("At190DeLoc")
		At190DLoad()
	EndIf

Return Nil

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} hasABBRig
@description  Retorna se Existe ABB antes de uma determinada data
@return lRet, Bool
@author Diego Bezerra
@since  01/08/2019
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function HasAbbL(dtIni, codTFF, codAtd, idcfal)

	Local cAliasLAg := getNextAlias()
	Local lRet := .F.

	Default codTFF := ""

	BeginSql Alias cAliasLAg

	COLUMN ABB_DTINI AS DATE
	SELECT DISTINCT ABB_IDCFAL  	
	FROM 
		%table:TGY% TGY INNER JOIN %table:ABB% ABB
		ON ABB.ABB_CODTEC = TGY.TGY_ATEND
		WHERE 
		    ABB.ABB_FILIAL = %xFilial:ABB% AND TGY.TGY_FILIAL = %xFilial:TGY% 
			AND TGY.TGY_CODTFF = %Exp:codTFF% AND TGY.TGY_ATEND = %Exp:codAtd% AND ABB.ABB_DTINI < %Exp:dtIni%
			AND ABB.ABB_IDCFAL = %Exp:idcfal% 
			AND ABB.%NotDel% AND TGY.%NotDel% 
 
	EndSql

	If (cAliasLAg)->(!Eof())
		lRet := .T.
	EndIf

	(cAliasLAg)->(dbCloseArea())

Return lRet
//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} getResTec
@description  Retorna se Existe ABB antes de uma determinada data
@return lRet, Bool
@author Diego Bezerra
@since  01/08/2019
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function getResTec(cCodTec,cDtIni,cDtFim)

	Local aAgResTec := {}
	Local cQryRsTec := ""
	Local cAliasTc	:= getNextAlias()
	Local nPos		:= 0

	Default cCodTec := ""
	Default cDtFim	:= ""

	cQryRsTec += "SELECT ABB_CODIGO, ABB_IDCFAL, ABB_DTINI, ABB_DTFIM, ABB_HRINI, ABB_HRFIM, ABB_ATENDE,ABB_CHEGOU, TDV_DTREF AS ABB_DTREF, TCU.TCU_DESC, TCU.TCU_RESTEC, ABQ.ABQ_CODTFF, ABQ.ABQ_FILTFF, ABB.ABB_FILIAL "
	cQryRsTec += "FROM "+RetSqlName("ABB")+" ABB "
	cQryRsTec += "INNER JOIN "+RetSqlName("TCU")+" TCU ON (ABB.ABB_TIPOMV = TCU.TCU_COD AND TCU.TCU_RESTEC = '1' AND TCU.TCU_FILIAL = '"+xFilial("TCU")+"' AND TCU.D_E_L_E_T_ = ' '  ) "
	cQryRsTec += "INNER JOIN " + RetSqlName("TDV") + " TDV ON ( TDV.TDV_CODABB = ABB.ABB_CODIGO AND TDV.TDV_FILIAL = '"+xFilial("TDV")+"' AND TDV.D_E_L_E_T_ = ' ' ) "
	cQryRsTec += "INNER JOIN " + RetSqlName("ABQ") + " ABQ ON ( ABQ.ABQ_CONTRT || ABQ.ABQ_ITEM || ABQ.ABQ_ORIGEM = ABB.ABB_IDCFAL AND ABQ.ABQ_FILIAL = '"+xFilial("ABQ")+"' AND ABQ.D_E_L_E_T_ = ' ' ) "

	If !Empty(cDtFim)
		cQryRsTec += "WHERE ABB.ABB_CODTEC = '"+cCodTec+"' AND TDV.TDV_DTREF >= '"+cDtIni+"' AND TDV.TDV_DTREF <= '"+cDtFim+"' "
	Else
		cQryRsTec += "WHERE ABB.ABB_CODTEC = '"+cCodTec+"' AND TDV.TDV_DTREF >='"+cDtIni+"' "
	EndIf

	cQryRsTec += "AND ABB.ABB_FILIAL = '"+xFilial("ABB") +"' "
	cQryRsTec += " AND ABB.D_E_L_E_T_ = ' ' ORDER BY ABB_DTINI DESC"

	cQryRsTec := ChangeQuery(cQryRsTec)

	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQryRsTec),cAliasTc, .F., .T.)

	While (cAliasTc)->(!EOF())
		nPos := aScan(aAgResTec, {|x| x[1] == (cAliasTc)->ABB_IDCFAL })
		If nPos == 0
			aAdd(aAgResTec, { (cAliasTc)->ABB_IDCFAL, {} , (cAliasTc)->ABQ_CODTFF, (cAliasTc)->ABQ_FILTFF})
			nPos := Len(aAgResTec)
		EndIf

		aAdd(aAgResTec[nPos][2],{;
			(cAliasTc)->ABB_CODIGO,;//1
		(cAliasTc)->ABB_DTINI,;//2
		(cAliasTc)->ABB_HRINI,;//3
		(cAliasTc)->ABB_DTFIM,;//4
		(cAliasTc)->ABB_HRFIM,;//5
		(cAliasTc)->ABB_ATENDE,;//6
		(cAliasTc)->ABB_CHEGOU,;//7
		(cAliasTc)->ABB_IDCFAL,;//8
		(cAliasTc)->ABB_DTREF,;//9
		.T.,;//10
		"",;//11
		(cAliasTc)->ABB_FILIAL})//12

		(cAliasTc)->(DbSkip())
	End
	(cAliasTc)->(DbCloseArea())

Return aAgResTec

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At190dTCU
@description  Verifica se ir� manter as agendas de reserva t�cnicas futuras

@param cTpAloc - Caracter - Codigo do tipo de Aloca��o(TCU_COD)

@return lRet, Bool - Indica se a agenda futura de reserva vai ser mantida

@author Luiz Gabriel
@since  22/08/2019
/*/ 
//--------------------------------------------------------------------------------------------------------------------
Static Function At190dTCU(cTpAloc)
	Local lRet 	:= .F.
	Local aConf	:= {}

	DbSelectArea("TCU")

	If ColumnPos("TCU_RESFTR") > 0
		aConf := TxConfTCU(cTpAloc,{"TCU_RESFTR"})

		If Len(aConf) > 0 .And. (!Empty(aConf[1][1]) .And. aConf[1][1] = "TCU_RESFTR")
			If aConf[1][2] = "1" //"1=Sim;2=N�o"
				lRet := .T.
			EndIf
		EndIf

	EndIf

Return lRet


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AT190dLimp
@description  Verifica se esxiste aspa simples para n�o dar error.log
@return xValue
@author Augusto Albuquerque
@since  27/08/2019
/*/
//--------------------------------------------------------------------------------------------------------------------
Function AT190dLimp(xValue)

	If At("'", xValue) > 0
		xValue := STRTRAN(xValue, "'","")
	EndIf

Return xValue

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Tec190QPer
@description  Retorna array com informa��es sobre funcionario com tipo de contrato intermitente.
@return aPeriodo -  codigo da solicita��o, data inicial, data final e codigo do atendente
@author Augusto Albuquerque
@since  09/09/2019
/*/
//--------------------------------------------------------------------------------------------------------------------
Function Tec190QPer(cCodFunc, cCodAtend, dDataIni, dDataFim, cFunFil)
	Local cAliasQry := GetNextAlias()
	Local aPeriodo	:= {}

	Default cCodFunc  	:= ""
	Default cCodAtend 	:= ""
	Default dDataIni	:= sTod("")
	Default dDataFim	:= sTod("")
	Default cFunFil		:= xFilial("SRA")

	BeginSql Alias cAliasQry
	COLUMN V7_DTINI AS DATE
	COLUMN V7_DTFIM AS DATE
	Select 	SV7.V7_COD,
			SV7.V7_DTINI,
			SV7.V7_DTFIM
	  From
	  	%Table:SV7% SV7
	  INNER JOIN %table:SRA% SRA 
	  	ON 	SRA.RA_FILIAL = %Exp:cFunFil%
	  	AND SRA.RA_MAT = SV7.V7_MAT
	  	AND SRA.%NotDel%
	  Where SV7.V7_FILIAL=%xFilial:SV7%
	   	And 	SV7.V7_MAT = %Exp:cCodFunc%
	   	And 	SV7.%NotDel%
	   	AND (SV7.V7_DTINI  <= %Exp:dDataIni% AND SV7.V7_DTFIM >= %Exp:dDataFim%)
	EndSql

	While (cAliasQry)->(!EOF())
		aADD(aPeriodo, {(cAliasQry)->V7_COD,; // Codigo da Solicita��o
		(cAliasQry)->V7_DTINI,; // Data Inicial do periodo
		(cAliasQry)->V7_DTFIM,; // Data Final do Periodo
		cCodAtend}) // Codigo do Atendente
		(cAliasQry)->(dbSkip())
	EndDo

	(cAliasQry)->(DbCloseArea())

Return (aPeriodo)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At190DSMar
@description  Retorna a variavel aMarks

@param aMarks - aMarks - Array das marca��es

@author fabiana.silva
@since  10/09/2019
/*/ 
//--------------------------------------------------------------------------------------------------------------------
Function At190DSMar(aStMarc)

	If Valtype(aStMarc) == "A"
		aMarks := aClone(aStMarc)
	EndIf

Return aMarks

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At190TrEft
@description  Realiza a troca de Efetivo

@param oModel - Objeto - Modelo de dados

@author Luiz Gabriel
@since  10/09/2019
/*/ 
//--------------------------------------------------------------------------------------------------------------------
Function At190TrEft()
	Local oModel := NIL
	Local aButtons := {}
	Local lPerm := At680Perm(NIL, __cUserId, "042", .T.)

	If lPerm
		oModel := FwModelActive()
		aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,STR0346},; //"Trocar"
		{.T.,STR0001},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} // "Fechar"

		FWExecView( STR0345, "VIEWDEF.TECA190E", MODEL_OPERATION_INSERT, /*oDlg*/, {||.T.}/*bCloseOk*/,	{||.T.}/*bOk*/,30, aButtons, {||.T.}/*bCancel*/ ) //"Troca de Efetivo"
		FwModelActive(oModel)
		At190DLoad()
	Else
		Help(,1,"At190TrEft",,STR0477, 1) //"Usu�rio sem permiss�o de realizar troca de efetivo"
	EndIf

Return
//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At190DVHr
@description Ajusta os demais hor�rios, conforme a diferen�a atual

@param cValue - Valor do Hor�rio Alterado
@return lRet - horario valido
@author fabiana.silva
@since  18/09/2019
/*/ 
//--------------------------------------------------------------------------------------------------------------------
Static Function At190DVHr(cValue)
	Local cVar 		:= AllTrim(Substr(ReadVar(),4)) //Vari�vel corrente
	Local nC 		:= 1 //Contador
	Local cCnt 		:= "" //Contador Caractere
	Local cValAnt 	:= "" //Valor Anterior
	Local nDifHor 	:= 0 //Diferen�a de Hor�rio
	Local cCpoE 	:= "" //Campo de Entrada
	Local cCpoS 	:= "" //Campo de Sa�da
	Local nValue 	:= 0 //Hora Inteira
	Local nValueA 	:=  0 //Hora Alterada Inteira

	cValAnt := &(StrTran(ReadVar(),"_"))

	If M->EDIT_AUTM .AND. cValAnt <> cValue
		nDifHor := At190DifHo(cValAnt, cValue)
		For nC := 1 to  4
			cCnt := LTrim(Str(nC))
			cCpoE := "TGY_ENTRA"+cCnt
			cCpoS := "TGY_SAIDA"+cCnt
			If At580eWhen(cCnt)
				If cVar <> cCpoE
					nValue := HoratoInt(M->&(cCpoE))
					nValueA := nDifHor + nValue
					If nValueA >= 24
						nValueA := nValueA-24
					EndIf
					M->&(cCpoE) := IntToHora(nValueA)
					M->&(StrTran(cCpoE,"_")) :=  M->&(cCpoE)
				EndIf
				If cVar <> cCpoS
					nValue := HoratoInt(M->&(cCpoS))
					nValueA := nDifHor + nValue
					If nValueA >= 24
						nValueA := nValueA-24
					EndIf
					M->&(cCpoS)  :=  IntToHora(nValueA)
					M->&(StrTran(cCpoS,"_")) := M->&(cCpoS)
				EndIf
			EndIf
		Next nC
		&(StrTran(ReadVar(),"_")) := cValue
	EndIf

Return .T.
//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} DifHor
@description Retorna a diferen�a de horario, apartir de da saida e a proxima entrada
@author      fabiana.silva
@since        18/09/2019
@param 		cHoraI - Horario Inicial
@param		cHoraF - Hor�rio Final
@return       nRet - Diferen�a
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At190DifHo(cHoraI, cHoraF)
	Local nRet := 0
	Local nHoraI := HoratoInt(cHoraI)
	Local nHoraF := HoratoInt(cHoraF)

	If nHoraI > nHoraF
		nHoraF += 24
	EndIF
	nRet := nHoraF - nHoraI

Return nRet
//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At19LAA1
@description Fun��o que consulta situa��o do atendente
@author      fabiana.silva
@since        23/09/2019
@param 		oBrowse - Browse se Atendentes
@param 		dDtIni - Horario Inicial
@param		dDtFim - Hor�rio Final
@param		lAltera - Altera per�odo
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At19LAA1(oBrowse, dDtIni, dDtFim, lAltera, lAutomato, cAlias)
	Local aRet   	:= {}
	Local cLeg   	:= ""
	Local nPos   	:= 1

	Default lAutomato := .F.
	Default cAlias	  := ""

	If !lAutomato
		nPos := oBrowse:At()
		cAlias := oBrowse:Alias()
	EndIf

	If nPos > 0 .AND. !Empty((cAlias)->AA1_CODTEC) .AND.  Alltrim((cAlias)->AA1_TMPLG) == "BR_MARROM"
		aRet := ListarApoio( dDtIni, dDtFim, /*aCargos*/, /*aFuncoes*/, /*aHabil*/, /*cDisponib*/,;
						  /*cContIni*/,  /*cContFim*/,  /*xCCusto*/,  /*cLista*/,  1,  /*cItemOS*/,;
						  /*aTurnos*/,  /*aRegiao*/,  /*lEstrut*/,  /*aPeriodos*/,  /*cIdCfAbq*/,  /*cLocOrc*/,;
						 /* aSeqTrn*/,  /*aPeriodRes*/,  /*cLocalAloc*/, /*aCarac*/,  /*aCursos*/, (cAlias)->AA1_CODTEC )
			If Len(aRet) > 0
			lAltera := .F.
			(aRet[01])->(DbGoTop())
			If (aRet[01])->(!Eof())
				cLeg := (aRet[01])->TMP_LEGEN
			EndIf
			(aRet[01])->(DbCloseArea())
			If !Empty(cLeg) .AND. !lAutomato //MsUnLock falhando em tabela temporaria
				RecLock(cAlias, .F.)
				(cAlias)->AA1_TMPLG := cLeg
				(cAlias)->(MsUnLock())
				oBrowse:LineRefresh()
			EndIf
		EndIf
	EndIf

Return
//------------------------------------------------------------------------------
/*/{Protheus.doc} At190dExec
Executa um comando gen�rico recebido via string

@author		Diego Bezerra
@since		07/10/2019
@param 		cCommand - Comando via string a ser executado
@return 	xRet	 - Retorno da macro execu��o

@version	P12.1.23
/*/
//------------------------------------------------------------------------------
Function At190dExec( cCommand, xPar)
	Local xRet := (&(cCommand))

Return xRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} at190drtc

Realiza o cancelamento de agendas, utilizando o modelo do TECA550

@author Diego Bezerra
@since 08/10/2019
@param aSubResTc, array, com as agendas a serem excluidas, no formato do aMarks
@param aErrors, array, par�metro que dever� ser recebido como refer�ncia, para retornar os erros de processamento
@param nFail, numerico, contador do n�mero de processamentos que falharam
@param cRtMotivo, String, c�digo do motivo de manuten��o de cancelamento das agendas

@version P12.1.23
/*/
//------------------------------------------------------------------------------
Function at190drtc(aSubResTc, aErrors, nFail, cRtMotivo)

	Local aErroMVC := {}
	Local nX := 1
	Default cRtMotivo := ""

	While nX <= Len(aSubResTc)
		ABB->(DbSetOrder(8))
		ABB->(MsSeek(xFilial("ABB") + aSubResTc[nX][1]))
		ABQ->(DbSetOrder(1))
		ABQ->(MsSeek(xFilial("ABQ") + ABB->ABB_IDCFAL))
		TFF->(DbSetOrder(1))
		TFF->(MsSeek(xFilial("TFF") + ABQ->ABQ_CODTFF))

		At550SetAlias("ABB")
		At550SetGrvU(.T.)

		oMdl550 := FwLoadModel("TECA550")
		oMdl550:SetOperation( MODEL_OPERATION_INSERT)
		If lRet := oMdl550:Activate()
			lRet := lRet .AND. oMdl550:SetValue("ABRMASTER","ABR_MOTIVO", cRtMotivo)
			lRet := lRet .AND. oMdl550:SetValue("ABRMASTER","ABR_OBSERV", At190dMsgM())
			If lRet
				Begin Transaction
					If !oMdl550:VldData() .OR. !oMdl550:CommitData()
						nFail++
						aErroMVC := oMdl550:GetErrorMessage()
						at190err(@aErrors, aErroMVC)
						DisarmTransacation()
						oMdl550:DeActivate()
					EndIf
				End Transaction
				oMdl550:DeActivate()
			Else
				nFail++
				aErroMVC := oMdl550:GetErrorMessage()
				at190err(@aErrors, aErroMVC)
				oMdl550:DeActivate()
			EndIf
		Else
			nFail++
			aErroMVC := oMdl550:GetErrorMessage()
			at190err(@aErrors, aErroMVC)
			oMdl550:DeActivate()
		EndIf
		At550SetAlias("")
		At550SetGrvU(.F.)
		nX ++
	End
Return


//------------------------------------------------------------------------------
/*/{Protheus.doc} at190sbtc

Preencha array aSubRestc quando for realizada manuten��o com substituto que venha de
um local da reserva t�cnica

@author Diego Bezerra
@since 08/10/2019
@param cCodTec, String, C�digo do atendente 
@param aSubResTc, array, com as agendas a serem excluidas, no formato do aMarks
@param cIdCfal, string, idcfal da agenda efetiva que est� sofrendo manuten��o

@version P12.1.23
/*/
//------------------------------------------------------------------------------
Static Function at190sbtc(cCodTec, cDtIni, aSubRestc, cIdCfal)

	Local cQry := ""
	Local cAliasABB := getNextAlias()

	cQry := "SELECT ABB_CODIGO, ABB_DTINI, ABB_HRINI, ABB_DTFIM, ABB_HRFIM, ABB_ATENDE, ABB_CHEGOU, ABB_IDCFAL, TDV_DTREF AS ABB_DTREF, ABS_RESTEC "
	cQry += "FROM "+retSqlName("ABB")+" ABB INNER JOIN "+retSqlName("TDV")+" TDV ON ABB.ABB_CODIGO = TDV.TDV_CODABB "
	cQry += "AND ABB.ABB_FILIAL = '"+xFilial("ABB")+"' AND TDV.TDV_FILIAL = '"+xFilial("TDV")+"' "
	cQry += "INNER JOIN "+retSqlName("ABS")+" ABS ON ABS.ABS_LOCAL = ABB.ABB_LOCAL "+"AND ABS.ABS_FILIAL = '"+xFilial("ABS")+"' "
	cQry += "WHERE ABB_CODTEC = '"+cCodTec+"' AND ABB_DTINI = '"+cDtIni+"' AND ABB_IDCFAL <> '"+cIdCfal+"' AND ABS_RESTEC = '1' "
	cQry += "AND ABB.D_E_L_E_T_ = ' ' AND TDV.D_E_L_E_T_ = ' ' AND ABS.D_E_L_E_T_ = ' '"
	cQry := ChangeQuery(cQry)

	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQry),cAliasABB, .F., .T.)

	WHILE (cAliasABB)->(!EOF())
		aAdd(aSubRestc, {(cAliasABB)->ABB_CODIGO,;
			(cAliasABB)->ABB_DTINI,;
			(cAliasABB)->ABB_HRINI,;
			(cAliasABB)->ABB_DTFIM,;
			(cAliasABB)->ABB_HRFIM,;
			(cAliasABB)->ABB_ATENDE,;
			(cAliasABB)->ABB_CHEGOU,;
			(cAliasABB)->ABB_IDCFAL,;
			(cAliasABB)->ABB_DTREF,;
			.F.,;
			"";
			})
		(cAliasABB)->(dbSkip())
	End
	(cAliasABB)->(dbCloseArea())
Return aSubRestc

//------------------------------------------------------------------------------
/*/{Protheus.doc} AbnByType

Retorna o primeiro motivo de manuten��o do tipo informado

@author Diego Bezerra
@since 08/10/2019
@param cType, string, c�digo do tipo de manuten��o
@return cCodABN, String, c�digo do motivo de manuten��o

@version P12.1.23
/*/
//------------------------------------------------------------------------------
Static Function AbnByType(cType)

	Local aArea 	:= GetArea()
	Local cCodABN 	:= ""
	Local cQry 		:= ""
	Local aABNs 	:= {}
	Local aABNAux 	:= {}
	Local cAliasABN := getNextAlias()
	Local cCombo	:= ""
	Local oOk
	Local oCombo
	Local oDlgSelect
	Local oSay


	cQry += "SELECT ABN_CODIGO FROM "+retSqlName("ABN")+" ABN WHERE ABN_TIPO = '"+cType+"' "
	cQry += "AND ABN.D_E_L_E_T_ = ' ' AND ABN.ABN_FILIAL = '"+xFilial("ABN")+"'"
	cQry := ChangeQuery(cQry)

	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQry),cAliasABN, .F., .T.)
	While(cAliasABN)->(!EOF())
		aAdd(aABNS,(cAliasABN)->ABN_CODIGO)
		AADD(aABNAux, (cAliasABN)->(ABN_CODIGO)+" - "+Alltrim(POSICIONE("ABN",1,xFilial("ABN")+(cAliasABN)->(ABN_CODIGO)+cType,"ABN_DESC")))
		(cAliasABN)->(dbSkip())
	End
	(cAliasABN)->(dbCloseArea())

	If LEN(aABNs) == 1 .OR. ( !EMPTY(aABNs) .AND. IsBlind() )
		cCodABN := aABNs[1]
	ElseIf LEN(aABNs) > 1
		cCombo := aABNAux[1]
		DEFINE MSDIALOG oDlgSelect FROM 0,0 TO 180,380  PIXEL Style 128 TITLE "Motivo de manuten��o"
		oSay := TSay():New( 010,010,{||OemToAnsi(STR0360)},;
			oDlgSelect,,TFont():New("Arial",,-11,.T.,.F.) ,,,,.T.,,,168,130,,,,,,.T.)  //"<p>Escolha um motivo de manuten��o do tipo cancelamento, que ser� utilizado na manuten��o das <b>agendas da reserva t�cnica</b>. </p>"
		oSay:lWordWrap = .F.
		oCombo := TComboBox():New(040,006,{|u|if(PCount()>0,cCombo:=u,cCombo)},aABNAux,130,20,oDlgSelect,,,,,,.T.,,,,,,,,,'cCombo')
		oOk := TButton():New( 042, 140, STR0109,oDlgSelect,{|| oDlgSelect:End() }, 38,12,,,.F.,.T.,.F.,,.F.,,,.F. )	//"Confirmar"
		ACTIVATE MSDIALOG oDlgSelect CENTER
		cCodABN := aABNs[ASCAN(aABNAux, cCombo)]
	EndIf

	RestArea(aArea)

Return cCodABN


//------------------------------------------------------------------------------
/*/{Protheus.doc} at190err

Repons�vel pela montagem do array aErrors, com as mensagens de erro do processamento
das manuten��es das agendas

@author Diego Bezerra
@since 08/10/2019
@param aErrors, array, array passado como refer�ncia que armazena as mensagens de erro do processamento
@param aErroMVC, array, array com mensagens de erro do modelo

@version P12.1.23
/*/
//------------------------------------------------------------------------------
Static function at190err(aErrors, aErroMVC, dDiaRef)

	Default dDiaRef := CToD("")
	AADD(aErrors, {	 STR0158 + ' [' + AllToChar( aErroMVC[1] ) + ']',;	//"Id do formul�rio de origem:"
	STR0159 + ' [' + AllToChar( aErroMVC[2] ) + ']',;	//"Id do campo de origem:"
	STR0160 + ' [' + AllToChar( aErroMVC[3] ) + ']',;	//"Id do formul�rio de erro:"
	STR0161 + ' [' + AllToChar( aErroMVC[4] ) + ']',;	//"Id do campo de erro:"
	STR0162 + ' [' + AllToChar( aErroMVC[5] ) + ']',;	//"Id do erro:"
	STR0163 + ' [' + AllToChar( aErroMVC[6] ) + ']',;	//"Mensagem do erro:"
	If(!Empty(dDiaRef), STR0365 + DToC(dDiaRef), ""),; // "Dia de conflito: "
		STR0164 + ' [' + AllToChar( aErroMVC[7] ) + ']',;	//"Mensagem da solu��o:"
		STR0165 + ' [' + AllToChar( aErroMVC[8] ) + ']',;	//"Valor atribu�do:"
		STR0166 + ' [' + AllToChar( aErroMVC[9] ) + ']';	//"Valor anterior:"
		})
		Return
//------------------------------------------------------------------------------
/*/{Protheus.doc} At190dllgy

@description Legenda do campo LGY_STATUS

@author	boiani
@since	15/01/2020
/*/
//------------------------------------------------------------------------------
Static Function At190dllgy()
	Local	oLegABB := FwLegend():New()
	oLegABB:Add( "", "BR_VERMELHO", STR0438)//"N�o processado"
	oLegABB:Add( "", "BR_AMARELO" , STR0439) //"Agenda projetada"
	oLegABB:Add( "", "BR_VERDE"	  , STR0440) //"Agenda gravada"
	oLegABB:Add( "", "BR_PRETO"	  , STR0441) //"Conflito de Aloca��o"
	oLegABB:Add( "", "BR_LARANJA" , STR0503) //"Falha na aloca��o"
	oLegABB:Add( "", "BR_CANCEL"  , STR0504) //"Falha na proje��o"
	oLegABB:Add( "", "BR_PINK"    , STR0505) //"Atendente com Restri��o"
	oLegABB:View()
	DelClassIntf()
Return(.T.)
//------------------------------------------------------------------------------
/*/{Protheus.doc} At190dLAGY

@description Executa a carga dos atendentes na grid LGY ao pressionar o bot�o
de busca de atendentes

@author	boiani
@since	15/01/2020
/*/
//------------------------------------------------------------------------------
Function At190dLAGY()
	Local oModel := FwModelActive()
	Local oMdlLCA := oModel:GetModel("LCAMASTER")
	Local oMdlLGY := oModel:GetModel("LGYDETAIL")
	Local oMdlLAC := oModel:GetModel("LACDETAIL")
	Local cContra := oMdlLCA:GetValue("LCA_CONTRT")
	Local cCodTFL := oMdlLCA:GetValue("LCA_CODTFL")
	Local cCodTFF := oMdlLCA:GetValue("LCA_TFFCOD")
	Local cCodTCU := oMdlLCA:GetValue("LCA_TIPTCU")
	Local oView := FwViewActive()
	Local cSql := ""
	Local cAliasQry := GetNextAlias()
	Local lCobertura := .F.
	Local cFilBkp := cFilAnt
	Local aResult := {}
	Local nX
	Local nAux

	If TecMultFil()
		cFilAnt := oMdlLCA:GetValue("LCA_FILIAL")
	EndIf

	If !EMPTY(Alltrim(cContra+cCodTFL+cCodTFF))
		cSql += " SELECT TGY.TGY_ATEND ATEND, "
		cSql += " '2' COBERTURA, "
		cSql += " TFF.TFF_CONTRT, TFF.TFF_CODPAI, TFF.TFF_COD, TFF.TFF_ESCALA, TGY.TGY_TIPALO TGY_TIPALO, "
		cSql += " TGY.TGY_GRUPO GRUPO, TGY.TGY_DTINI DTINI, TGY.TGY_DTFIM DTFIM, "
		cSql += " TGY.TGY_SEQ, TGY.R_E_C_N_O_ REC, TDX.TDX_COD LGY_CONFAL, 0 TGZ_HORINI, 0 TGZ_HORFIM, "
		cSql += " TGY.TGY_ENTRA1, "
		cSql += " TGY.TGY_SAIDA1, "
		cSql += " TGY.TGY_ENTRA2, "
		cSql += " TGY.TGY_SAIDA2, "
		cSql += " TGY.TGY_ENTRA3, "
		cSql += " TGY.TGY_SAIDA3, "
		cSql += " TGY.TGY_ENTRA4, "
		cSql += " TGY.TGY_SAIDA4, TGY.TGY_FILIAL FILIAL, TGY.TGY_ULTALO ULTALO, AA1.AA1_FILIAL "
		cSql += " FROM "  + RetSqlName( "TFF" ) + " TFF "
		cSql += " INNER JOIN " + RetSqlName( "TDX" ) + " TDX ON "
		cSql += " TDX.TDX_CODTDW = TFF.TFF_ESCALA AND TDX.TDX_FILIAL = '" + xFilial("TDX") + "' AND TDX.D_E_L_E_T_ = ' ' "
		cSql += " INNER JOIN " + RetSqlName( "TFL" ) + " TFL ON "
		cSql += " TFL.TFL_CODIGO = TFF.TFF_CODPAI AND TFL.TFL_FILIAL = '" + xFilial("TFL") + "' AND TFL.D_E_L_E_T_ = ' ' "
		cSql += " INNER JOIN " + RetSqlName( "TFJ" ) + " TFJ ON "
		cSql += " TFJ.TFJ_CODIGO = TFL.TFL_CODPAI AND TFJ.TFJ_FILIAL = '" + xFilial("TFJ") + "' AND TFJ.D_E_L_E_T_ = ' ' "
		cSql += " LEFT JOIN " + RetSqlName( "TGY" ) + " TGY ON "
		cSql += " TGY.TGY_ESCALA = TFF.TFF_ESCALA AND TGY.TGY_CODTDX = TDX.TDX_COD AND TGY.TGY_CODTFF = TFF.TFF_COD "
		cSql += " AND TGY.TGY_FILIAL = '" + xFilial("TGY") + "' AND TGY.D_E_L_E_T_ = ' ' AND TDX.TDX_COD = TGY.TGY_CODTDX  "
		If !EMPTY(cCodTCU)
			cSql += " AND TGY.TGY_TIPALO = '" + cCodTCU + "' "
		EndIf
		cSql += " LEFT JOIN " + RetSqlName( "AA1" ) + " AA1 ON "
		cSql += " AA1.AA1_CODTEC = TGY.TGY_ATEND AND AA1.AA1_FILIAL = '" + xFilial("AA1") + "' AND AA1.D_E_L_E_T_ = ' ' AND AA1.AA1_ALOCA = '1' "
		cSql += " WHERE "
		cSql += " TFF.D_E_L_E_T_ = ' ' AND TFF.TFF_FILIAL = '" + xFilial("TFF") + "' "
		cSql += " AND TFJ.TFJ_STATUS = '1' "
		If !EMPTY(cContra)
			cSql += " AND TFF.TFF_CONTRT = '" + cContra + "' "
		EndIf
		If !EMPTY(cCodTFL)
			cSql += " AND TFF.TFF_CODPAI = '" + cCodTFL + "' "
		EndIf
		If !EMPTY(cCodTFF)
			cSql += " AND TFF.TFF_COD = '" + cCodTFF + "' "
		EndIf
	/*
	cSql += " UNION ALL "
	cSql += " SELECT  "
	cSql += " TGZ.TGZ_ATEND ATEND, "
	cSql += " '1' COBERTURA, "
	cSql += " TFF.TFF_CONTRT, TFF.TFF_CODPAI, TFF.TFF_COD, TFF.TFF_ESCALA, '' TGY_TIPALO, "
	cSql += " TGZ.TGZ_GRUPO GRUPO, TGZ.TGZ_DTINI DTINI, TGZ.TGZ_DTFIM DTFIM, "
	cSql += " '' TGY_SEQ, TGZ.R_E_C_N_O_ REC, TGX.TGX_COD LGY_CONFAL, TGZ.TGZ_HORINI TGZ_HORINI, TGZ.TGZ_HORFIM TGZ_HORFIM, "
	cSql += " '' TGY_ENTRA1, "
	cSql += " '' TGY_SAIDA1, "
	cSql += " '' TGY_ENTRA2, "
	cSql += " '' TGY_SAIDA2, "
	cSql += " '' TGY_ENTRA3, "
	cSql += " '' TGY_SAIDA3, "
	cSql += " '' TGY_ENTRA4, "
	cSql += " '' TGY_SAIDA4, TGZ.TGZ_FILIAL FILIAL, '' ULTALO, AA1.AA1_FILIAL "
	cSql += " FROM "  + RetSqlName( "TFF" ) + " TFF "
	cSql += " INNER JOIN " + RetSqlName( "TDX" ) + " TDX ON "
	cSql += " TDX.TDX_CODTDW = TFF.TFF_ESCALA AND TDX.TDX_FILIAL = '" + xFilial("TDX") + "' AND TDX.D_E_L_E_T_ = ' ' "
	cSql += " INNER JOIN " + RetSqlName( "TGX" ) + " TGX ON " 
	cSql += " TGX.TGX_CODTDW = TFF.TFF_ESCALA AND TGX.TGX_FILIAL = '" + xFilial("TGX") + "' AND "
	cSql += " TGX.D_E_L_E_T_ = ' ' "
	cSql += " INNER JOIN " + RetSqlName( "TFL" ) + " TFL ON "
	cSql += " TFL.TFL_CODIGO = TFF.TFF_CODPAI AND TFL.TFL_FILIAL = '" + xFilial("TFL") + "' AND TFL.D_E_L_E_T_ = ' ' "
	cSql += " INNER JOIN " + RetSqlName( "TFJ" ) + " TFJ ON "
	cSql += " TFJ.TFJ_CODIGO = TFL.TFL_CODPAI AND TFJ.TFJ_FILIAL = '" + xFilial("TFJ") + "' AND TFJ.D_E_L_E_T_ = ' ' "
	cSql += " LEFT JOIN " + RetSqlName( "TGZ" ) + " TGZ ON "
	cSql += " TGZ.TGZ_ESCALA = TFF.TFF_ESCALA AND TGZ.TGZ_CODTDX = TGX.TGX_COD AND TGZ.TGZ_CODTFF = TFF.TFF_COD "
	cSql += " AND TGZ.TGZ_FILIAL = '" + xFilial("TGZ") + "' AND TGZ.D_E_L_E_T_ = ' ' "
	cSql += " WHERE "
	cSql += " TFF.D_E_L_E_T_ = ' ' AND TFF.TFF_FILIAL = '" + xFilial("TFF") + "' "
	cSql += " AND TFJ.TFJ_STATUS = '1' "
		If !EMPTY(cContra)
		cSql += " AND TFF.TFF_CONTRT = '" + cContra + "' "
		EndIf
		If !EMPTY(cCodTFL)
		cSql += " AND TFF.TFF_CODPAI = '" + cCodTFL + "' "
		EndIf
		If !EMPTY(cCodTFF)
		cSql += " AND TFF.TFF_COD = '" + cCodTFF + "' "
		EndIf
	*/
		cSql := ChangeQuery(cSql)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSql),cAliasQry, .F., .T.)
		While !(cAliasQry)->(EOF())
			nAux := 0
			If EMPTY((cAliasQry)->ATEND)
				(cAliasQry)->(DbSkip())
				Loop
			Endif
			lCobertura := (cAliasQry)->COBERTURA == '1'
			If !lCobertura .AND. !EMPTY((cAliasQry)->REC) .AND. oMdlLGY:SeekLine({{"LGY_TIPOAL",'1'},{"LGY_RECLGY",(cAliasQry)->REC}})
				(cAliasQry)->(DbSkip())
				Loop
			ElseIf lCobertura .AND. !EMPTY((cAliasQry)->REC) .AND.  oMdlLGY:SeekLine({{"LGY_TIPOAL",'2'},{"LGY_RECLGY",(cAliasQry)->REC}})
				(cAliasQry)->(DbSkip())
				Loop
			Endif

			If EMPTY(aResult) .OR. (nAux := ASCAN(aResult, {|a| a[1] == (cAliasQry)->ATEND .AND. a[26] == (cAliasQry)->AA1_FILIAL})) == 0
				AADD(aResult, {;
					(cAliasQry)->ATEND,;					//[01]
				(cAliasQry)->ULTALO,;					//[02]
				(cAliasQry)->DTINI,;					//[03]
				(cAliasQry)->DTFIM,;					//[04]
				(cAliasQry)->FILIAL,;					//[05]
				(cAliasQry)->TGZ_HORINI,;				//[06]
				(cAliasQry)->TGZ_HORFIM,;				//[07]
				(cAliasQry)->TGY_ENTRA1,;				//[08]
				(cAliasQry)->TGY_SAIDA1,;				//[09]
				(cAliasQry)->TGY_ENTRA2,;				//[10]
				(cAliasQry)->TGY_SAIDA2,;				//[11]
				(cAliasQry)->TGY_ENTRA3,;				//[12]
				(cAliasQry)->TGY_SAIDA3,;				//[13]
				(cAliasQry)->TGY_ENTRA4,;				//[14]
				(cAliasQry)->TGY_SAIDA4,;				//[15]
				(cAliasQry)->REC,;						//[16]
				(cAliasQry)->TFF_CONTRT,;				//[17]
				(cAliasQry)->TFF_CODPAI,;				//[18]
				(cAliasQry)->TFF_COD,;					//[19]
				(cAliasQry)->TFF_ESCALA,;				//[20]
				Posicione("TDW",1,xFilial("TDW") +;
					(cAliasQry)->TFF_ESCALA,"TDW_DESC"),;	//[21]
				(cAliasQry)->LGY_CONFAL,;				//[22]
				(cAliasQry)->TGY_SEQ,;					//[23]
				(cAliasQry)->TGY_TIPALO,;				//[24]
				(cAliasQry)->GRUPO,;					//[25]
				(cAliasQry)->AA1_FILIAL,;				//[26]
				(cAliasQry)->COBERTURA == '1';			//[27]
				})
			ElseIf nAux > 0 .AND. !EMPTY((cAliasQry)->ULTALO) .AND. STOD((cAliasQry)->ULTALO) > STOD(aResult[nAux][2])
				aResult[nAux][1] := (cAliasQry)->ATEND
				aResult[nAux][2] := (cAliasQry)->ULTALO
				aResult[nAux][3] := (cAliasQry)->DTINI
				aResult[nAux][4] := (cAliasQry)->DTFIM
				aResult[nAux][5] := (cAliasQry)->FILIAL
				aResult[nAux][6] := (cAliasQry)->TGZ_HORINI
				aResult[nAux][7] := (cAliasQry)->TGZ_HORFIM
				aResult[nAux][8] := (cAliasQry)->TGY_ENTRA1
				aResult[nAux][9] := (cAliasQry)->TGY_SAIDA1
				aResult[nAux][10] := (cAliasQry)->TGY_ENTRA2
				aResult[nAux][11] := (cAliasQry)->TGY_SAIDA2
				aResult[nAux][12] := (cAliasQry)->TGY_ENTRA3
				aResult[nAux][13] := (cAliasQry)->TGY_SAIDA3
				aResult[nAux][14] := (cAliasQry)->TGY_ENTRA4
				aResult[nAux][15] := (cAliasQry)->TGY_SAIDA4
				aResult[nAux][16] := (cAliasQry)->REC
				aResult[nAux][17] := (cAliasQry)->TFF_CONTRT
				aResult[nAux][18] := (cAliasQry)->TFF_CODPAI
				aResult[nAux][19] := (cAliasQry)->TFF_COD
				aResult[nAux][20] := (cAliasQry)->TFF_ESCALA
				aResult[nAux][21] := Posicione("TDW",1,xFilial("TDW") +	(cAliasQry)->TFF_ESCALA,"TDW_DESC")
				aResult[nAux][22] := (cAliasQry)->LGY_CONFAL
				aResult[nAux][23] := (cAliasQry)->TGY_SEQ
				aResult[nAux][24] := (cAliasQry)->TGY_TIPALO
				aResult[nAux][25] := (cAliasQry)->GRUPO
				aResult[nAux][26] := (cAliasQry)->AA1_FILIAL
				aResult[nAux][27] := (cAliasQry)->COBERTURA == '1'
			EndIf
			(cAliasQry)->(DbSkip())
		End
		(cAliasQry)->(DbCloseArea())
		nAux := 0
		For nX := 1 To Len(aResult)
			lCobertura := aResult[nX][27]
			oMdlLGY:GoLine(oMdlLGY:Length())
			If !EMPTY(oMdlLGY:GetValue("LGY_CODTEC"))
				oMdlLGY:AddLine()
				oMdlLAC:InitLine()
				oMdlLAC:LoadValue("LAC_SITABB","BR_VERDE")
				oMdlLAC:LoadValue("LAC_SITALO","BR_VERDE")
			EndIf
			oMdlLGY:SetValue("LGY_CODTEC",aResult[nX][1])

			If EMPTY(STOD(aResult[nX][2]))
				oMdlLGY:LoadValue("LGY_DTINI",STOD(aResult[nX][3]))
			Else
				oMdlLGY:LoadValue("LGY_DTINI",STOD(aResult[nX][2]) + 1)
			EndIf
			If oMdlLGY:GetValue("LGY_DTINI") > STOD(aResult[nX][4])
				oMdlLGY:LoadValue("LGY_DTFIM", oMdlLGY:GetValue("LGY_DTINI"))
			Else
				oMdlLGY:LoadValue("LGY_DTFIM",STOD(aResult[nX][4]))
			EndIf
			oMdlLGY:SetValue("LGY_FILIAL",aResult[nX][5])
			If lCobertura
				oMdlLGY:LoadValue("LGY_TIPOAL",'2')
				oMdlLGY:LoadValue("LGY_ENTRA1",TecNumToHr(aResult[nX][6]))
				oMdlLGY:LoadValue("LGY_SAIDA1",TecNumToHr(aResult[nX][7]))
			Else
				oMdlLGY:LoadValue("LGY_TIPOAL",'1')
				oMdlLGY:LoadValue("LGY_ENTRA1",aResult[nX][8])
				oMdlLGY:LoadValue("LGY_SAIDA1",aResult[nX][9])
				oMdlLGY:LoadValue("LGY_ENTRA2",aResult[nX][10])
				oMdlLGY:LoadValue("LGY_SAIDA2",aResult[nX][11])
				oMdlLGY:LoadValue("LGY_ENTRA3",aResult[nX][12])
				oMdlLGY:LoadValue("LGY_SAIDA3",aResult[nX][13])
				oMdlLGY:LoadValue("LGY_ENTRA4",aResult[nX][14])
				oMdlLGY:LoadValue("LGY_SAIDA4",aResult[nX][15])
			EndIf
			oMdlLGY:LoadValue("LGY_RECLGY",aResult[nX][16])
			oMdlLGY:LoadValue("LGY_CONTRT", aResult[nX][17])
			oMdlLGY:LoadValue("LGY_CODTFL", aResult[nX][18])
			oMdlLGY:LoadValue("LGY_CODTFF", aResult[nX][19])
			oMdlLGY:LoadValue("LGY_ESCALA", aResult[nX][20])
			oMdlLGY:LoadValue("LGY_DSCTDW", aResult[nX][21])
			oMdlLGY:LoadValue("LGY_CONFAL", aResult[nX][22])
			oMdlLGY:LoadValue("LGY_SEQ", aResult[nX][23])
			oMdlLGY:LoadValue("LGY_TIPTCU", aResult[nX][24])
			oMdlLGY:LoadValue("LGY_GRUPO", aResult[nX][25])
		Next nX

		oMdlLGY:GoLine(1)
		If !isBlind()
			oView:Refresh('DETAIL_LGY')
		EndIf
	Else
		Help(,,"At190dLAGY",,STR0442,1,0) //"Selecione o Contrato, o Local ou o Posto que deve ser considerado na busca dos atendentes."
	EndIf
	cFilAnt := cFilBkp
Return
//------------------------------------------------------------------------------
/*/{Protheus.doc} At190dApgY

@description Limpa os dados da grid LGY

@author	boiani
@since	15/01/2020
/*/
//------------------------------------------------------------------------------
Function At190dApgY()
	Local oModel := FwModelActive()
	Local oView := FwViewActive()
	Local oMdlLGY := oModel:GetModel("LGYDETAIL")
	Local oMdlLac := oModel:GetModel("LACDETAIL")

	aAlocLGY := {}

	oMdlLGY:ClearData()
	oMdlLGY:InitLine()
	oMdlLAC:ClearData()
	oMdlLAC:InitLine()
	oView:Refresh("DETAIL_LGY")
	oView:Refresh("DETAIL_LAC")

Return
//------------------------------------------------------------------------------
/*/{Protheus.doc} At190dF10

@description Tecla F10 na Mesa Operacional

@author	boiani
@since	15/01/2020
/*/
//------------------------------------------------------------------------------
Function At190dF10()
	Local oView := FwViewActive()
	Local aFldPai	:= oView:GetFolderActive("TELA_ABAS", 2) //Verifica se a aba Pai est� aberta

	If aFldPai[1] == 3
		CopyLineTGY()
	Else
		FwMsgRun(Nil,{|| AT190DLdLo()}, Nil, STR0047)
	EndIf

Return
//------------------------------------------------------------------------------
/*/{Protheus.doc} At190dF11

@description Tecla F11 na Mesa Operacional

@author	boiani
@since	15/01/2020
/*/
//------------------------------------------------------------------------------
Function At190dF11()
	Local oView := FwViewActive()
	Local aFldPai	:= oView:GetFolderActive("TELA_ABAS", 2) //Verifica se a aba Pai est� aberta

	If aFldPai[1] == 3
		PasteLineTGY()
	Else
		FwMsgRun(Nil,{|| AT190DHJLo()}, Nil, STR0047)
	EndIf

Return
//------------------------------------------------------------------------------
/*/{Protheus.doc} CopyLineTGY

@description Op��o de c�pia de linha na LGY

@author	boiani
@since	15/01/2020
/*/
//------------------------------------------------------------------------------
Static Function CopyLineTGY()
	Local oModel := FwModelActive()
	Local oModlLGY := oModel:GetModel("LGYDETAIL")
	Local oStruct := oModlLGY:GetStruct()
	Local aCampos := oStruct:GetFields()
	Local nI
	Local cCposNot := "LGY_STATUS|LGY_RECLGY"
	Local nAux

	For nI := 1 To Len(aCampos)
		If !(aCampos[nI][MODEL_FIELD_IDFIELD] $ cCposNot)
			If (nAux := ASCAN(aLineLGY, {|q| q[1] == aCampos[nI][MODEL_FIELD_IDFIELD]})) != 0
				aLineLGY[nAux][2] := oModlLGY:GetValue(aCampos[nI][MODEL_FIELD_IDFIELD])
			Else
				AADD(aLineLGY, {aCampos[nI][MODEL_FIELD_IDFIELD] , oModlLGY:GetValue(aCampos[nI][MODEL_FIELD_IDFIELD]) })
			EndIf
		EndIf
	Next nI

Return
//------------------------------------------------------------------------------
/*/{Protheus.doc} PasteLineTGY

@description Op��o de cola de linha na LGY

@author	boiani
@since	15/01/2020
/*/
//------------------------------------------------------------------------------
Static Function PasteLineTGY()
	Local oView := FwViewActive()
	Local oModel := FwModelActive()
	Local oModlLGY := oModel:GetModel("LGYDETAIL")
	Local nI
	If !EMPTY(aLineLGY)
		oModlLGY:LoadValue("LGY_RECLGY",0)
		For nI := 1 To LEN(aLineLGY)
			oModlLGY:LoadValue(aLineLGY[nI][1],aLineLGY[nI][2])
		Next nI
	EndIf

	oView:Refresh("DETAIL_LGY")

Return
//------------------------------------------------------------------------------
/*/{Protheus.doc} At190dYAgen

@description Executa a aloca��o de acordo com os dados na LGY

@author	boiani
@since	15/01/2020
/*/
//------------------------------------------------------------------------------
Function At190dYAgen()
	Local oModel := FwModelActive()
	Local oMdlLGY := oModel:GetModel("LGYDETAIL")
	Local oMdlLAC := oModel:GetModel("LACDETAIL")
	Local oView := FwViewActive()
	Local oDlg := nil
	Local oSayMtr := nil
	Local oMeter := nil
	Local nX
	Local nY
	Local nMeter := 0

	oMdlLAC:SetNoInsertLine(.F.)
	oMdlLAC:SetNoDeleteLine(.F.)

	If isBlind()
		remDeleted(@oMdlLGY, "LGY", @oMdlLAC, "LAC")
	Else
		FwMsgRun(Nil,{|| remDeleted(@oMdlLGY, "LGY", @oMdlLAC, "LAC")}, Nil, STR0506) //"Iniciando a proje��o . . ."
	EndIf

	If checkLGY() //Valida as linhas da LGY
		If isBlind()
			ProjLAC()
		Else
			DEFINE MSDIALOG oDlg FROM 0,0 TO 5,60 TITLE STR0531 Style 128 //"Projetar aloca��es"
			oSayMtr := tSay():New(10,10,{||STR0507},oDlg,,,,,,.T.,,,220,20) //"Processando, aguarde..."
			oMeter  := tMeter():New(20,10,{|u|if(Pcount()>0,nMeter:=u,nMeter)},oMdlLGY:Length(),oDlg,220,10,,.T.)

			ACTIVATE MSDIALOG oDlg CENTERED ON INIT (ProjLAC(@oDlg,@oMeter))
		EndIf
		oMdlLGY:GoLine(1)
	EndIf

	oMdlLAC:SetNoInsertLine(.T.)
	oMdlLAC:SetNoDeleteLine(.T.)

	FwModelActive(oModel)

	oMdlLAC:GoLine(1)

	oView:Refresh("DETAIL_LAC")
	oView:Refresh("DETAIL_LGY")

Return
//------------------------------------------------------------------------------
/*/{Protheus.doc} At190dYCmt

@description Grava as agendas instanciadas em GsAloc

@author	boiani
@since	15/01/2020
/*/
//------------------------------------------------------------------------------
Function At190dYCmt()
	Local oDlg := nil
	Local oSayMtr := nil
	Local oMeter := NIL
	Local oModel := FwModelActive()
	Local oView := FwViewActive()
	Local oMdlLGY := oModel:GetModel("LGYDETAIL")
	Local nMeter := 0
	Local nLineLgy

	If At680Perm(NIL, __cUserId, "040", .T.)
		If isBlind()
			GravLGY()
		Else
			DEFINE MSDIALOG oDlg FROM 0,0 TO 5,60 TITLE "Gravar aloca��es" Style 128
			oSayMtr := tSay():New(10,10,{||STR0507},oDlg,,,,,,.T.,,,220,20) //"Processando, aguarde..."
			oMeter  := tMeter():New(20,10,{|u|if(Pcount()>0,nMeter:=u,nMeter)},LEN(aAlocLGY),oDlg,220,10,,.T.)

			ACTIVATE MSDIALOG oDlg CENTERED ON INIT (GravLGY(@oDlg,@oMeter))
		EndIf

		remDeleted(oMdlLGY, "LGY")
		If !isBlind()
			oView:Refresh('DETAIL_LGY')
			oView:Refresh('DETAIL_LAC')
		EndIf
	Else
		Help(,1,"At190dYCmt",,STR0474, 1) //"Usu�rio sem permiss�o de gravar agenda projetada"
	EndIf
Return
//------------------------------------------------------------------------------
/*/{Protheus.doc} CheckContrt

@description Verifica se o valor xValue � um contrato v�lido

@author	boiani
@since	15/01/2020
/*/
//------------------------------------------------------------------------------
Static Function CheckContrt(xValue, cFilCtr)
	Local cQry
	Local lRet := .T.
	Local lMV_MultFil := TecMultFil() //Indica se a Mesa considera multiplas filiais

	Default cFilCtr := xFilial('CN9')

	cQry := " SELECT 1 "
	cQry += " FROM " + RetSqlName("CN9") + " CN9 "
	cQry += " INNER JOIN " + RetSqlName("TFJ") + " TFJ "
	If !lMV_MultFil
		cQry += " ON TFJ.TFJ_FILIAL = '" + xFilial("TFJ") + "' "
	Else
		cQry += " ON " + FWJoinFilial("CN9" , "TFJ" , "CN9", "TFJ", .T.) + " "
	EndIf
	cQry += " AND TFJ.D_E_L_E_T_ = ' ' "
	cQry += " AND TFJ.TFJ_CONTRT = CN9.CN9_NUMERO "
	cQry += " AND TFJ.TFJ_CONREV = CN9.CN9_REVISA "
	cQry += " AND TFJ.TFJ_STATUS = '1' "
	cQry += " INNER JOIN " + RetSqlName("TFL") + " TFL "
	If !lMV_MultFil
		cQry += " ON TFL.TFL_FILIAL = '" + xFilial("TFL") + "' "
	Else
		cQry += " ON " + FWJoinFilial("TFL" , "TFJ" , "TFL", "TFJ", .T.) + " "
	EndIf
	cQry += " AND TFL.D_E_L_E_T_ = ' ' "
	cQry += " AND TFL.TFL_CODPAI = TFJ.TFJ_CODIGO "
	cQry += " INNER JOIN " + RetSqlName("TFF") + " TFF "
	If !lMV_MultFil
		cQry += " ON TFF.TFF_FILIAL = '" + xFilial("TFF") + "' "
	Else
		cQry += " ON " + FWJoinFilial("TFL" , "TFF" , "TFL", "TFF", .T.) + " "
	EndIf
	cQry += " AND TFF.D_E_L_E_T_ = ' ' "
	cQry += " AND TFF.TFF_CODPAI = TFL.TFL_CODIGO "
	cQry += " WHERE CN9.CN9_FILIAL = '" +  cFilCtr + "' AND "
	cQry += " CN9.D_E_L_E_T_ = ' ' AND CN9.CN9_NUMERO = '" + xValue + "' "
	If (QryEOF(cQry))
		lRet := .F.
	EndIf

Return lRet
//------------------------------------------------------------------------------
/*/{Protheus.doc} CheckTFL

@description Verifica se o valor xValue � um Local de Atendimento v�lido

@author	boiani
@since	15/01/2020
/*/
//------------------------------------------------------------------------------
Static Function CheckTFL(xValue, cContrt, cFilTFJ)
	Local cQry
	Local lRet := .T.
	Local lMV_MultFil := TecMultFil() //Indica se a Mesa considera multiplas filiais
	Local cTamCtr := SPACE(TamSX3("CN9_NUMERO")[1])
	Default cFilTFJ := xFilial("TFJ")
	cQry := " SELECT 1 "
	cQry += " FROM " + RetSqlName("TFL") + " TFL "
	cQry += " INNER JOIN " + RetSqlName("TFJ") + " TFJ "
	If !lMV_MultFil
		cQry += " ON TFJ.TFJ_FILIAL = '" + xFilial("TFJ") + "' "
	Else
		cQry += " ON " + FWJoinFilial("TFJ" , "TFL" , "TFJ", "TFL", .T.) + " "
	EndIf
	cQry += " AND TFJ.D_E_L_E_T_ = ' ' "
	cQry += " AND TFJ.TFJ_CODIGO = TFL.TFL_CODPAI "
	cQry += " AND TFJ.TFJ_STATUS = '1' "
	cQry += " WHERE  "
	cQry += " TFL.D_E_L_E_T_ = ' ' "
	cQry += " AND TFJ.TFJ_CONTRT = '" + cContrt + "' "
	cQry += " AND TFJ.TFJ_CONTRT != '" + cTamCtr + "' "
	cQry += " AND TFL.TFL_CODIGO = '" + xValue + "' "
	cQry += " AND TFJ.TFJ_FILIAL = '" + cFilTFJ + "' "
	If !lMV_MultFil
		cQry += " AND TFL.TFL_FILIAL = '" + xFilial("TFL") + "' "
	EndIf
	If (QryEOF(cQry))
		lRet := .F.
	EndIf

Return lRet
//------------------------------------------------------------------------------
/*/{Protheus.doc} CheckTFF

@description Verifica se o valor xValue � um Posto v�lido

@author	boiani
@since	15/01/2020
/*/
//------------------------------------------------------------------------------
Static Function CheckTFF(xValue, cContrt, cCodTFL, cFilTFJ)
	Local cQry
	Local lRet := .T.
	Local cTamCtr := SPACE(TamSX3("CN9_NUMERO")[1])
	Local lMV_MultFil := TecMultFil() //Indica se a Mesa considera multiplas filiais
	Default cFilTFJ := xFilial("TFJ")
	cQry := " SELECT 1 "
	cQry += " FROM " + RetSqlName("TFF") + " TFF "
	cQry += " INNER JOIN " + RetSqlName("TFL") + " TFL "
	cQry += " ON "
	cQry += " TFL.D_E_L_E_T_ = ' ' "
	cQry += " AND TFL.TFL_CODIGO = TFF.TFF_CODPAI "
	If !lMV_MultFil
		cQry += " AND TFL.TFL_FILIAL = '" + xFilial("TFL") + "' "
	Else
		cQry += " AND " + FWJoinFilial("TFF" , "TFL" , "TFF", "TFL", .T.) + " "
	EndIf
	cQry += " INNER JOIN " + RetSqlName("TFJ") + " TFJ "
	If !lMV_MultFil
		cQry += " ON TFJ.TFJ_FILIAL = '" + xFilial("TFJ") + "' "
	Else
		cQry += " ON " + FWJoinFilial("TFJ" , "TFL" , "TFJ", "TFL", .T.) + " "
	EndIf
	cQry += " AND TFJ.D_E_L_E_T_ = ' ' "
	cQry += " AND TFJ.TFJ_CODIGO = TFL.TFL_CODPAI "
	cQry += " AND TFJ.TFJ_STATUS = '1' "
	cQry += " AND TFJ.TFJ_CONTRT = '" + cContrt + "' "
	cQry += " AND TFJ.TFJ_CONTRT != '" + cTamCtr + "' "
	cQry += " WHERE "
	cQry += " TFF.D_E_L_E_T_ = ' ' "
	cQry += " AND TFL.TFL_CODIGO = '" + cCodTFL + "' "
	cQry += " AND TFF.TFF_COD = '" + xValue + "' "
	cQry += " AND TFJ.TFJ_FILIAL = '" + cFilTFJ + "' "
	If !lMV_MultFil
		cQry += " AND TFF.TFF_FILIAL = '" + xFilial("TFF") + "' "
	EndIf
	If (QryEOF(cQry))
		lRet := .F.
	EndIf

Return lRet
//------------------------------------------------------------------------------
/*/{Protheus.doc} CheckTDW

@description Verifica se o valor xValue est� contido na tabela TDW, no campo TDW_COD

@author	boiani
@since	15/01/2020
/*/
//------------------------------------------------------------------------------
Static Function CheckTDW(xValue, cFilCtr)
	Local cQry
	Local lRet := .T.
	Local lMV_MultFil := TecMultFil() //Indica se a Mesa considera multiplas filiais
	Default cFilCtr := cFilAnt
	cQry := " SELECT 1 "
	cQry += " FROM " + RetSqlName("TDW") + " TDW "
	cQry += " WHERE TDW.TDW_FILIAL = '" +  xFilial('TDW', IIF(lMV_MultFil,cFilCtr,cFilAnt)) + "' AND "
	cQry += " TDW.D_E_L_E_T_ = ' ' "
	cQry += " AND TDW.TDW_COD = '" + xValue + "' "
	If (QryEOF(cQry))
		lRet := .F.
	EndIf

Return lRet
//------------------------------------------------------------------------------
/*/{Protheus.doc} CheckTCU

@description Verifica se xValue � um C�digo de Tipo de Mov. v�lido

@author	boiani
@since	15/01/2020
/*/
//------------------------------------------------------------------------------
Static Function CheckTCU(xValue,cFilCtr)
	Local cQry
	Local lRet := .T.
	Local lMV_MultFil := TecMultFil() //Indica se a Mesa considera multiplas filiais
	Default cFilCtr := cFilAnt
	cQry := " SELECT 1 "
	cQry += " FROM " + RetSqlName("TCU") + " TCU "
	cQry += " WHERE TCU.TCU_FILIAL = '" +  xFilial('TCU',IIF(lMV_MultFil,cFilCtr,cFilAnt)) + "' AND "
	cQry += " TCU.D_E_L_E_T_ = ' ' "
	cQry += " AND TCU.TCU_COD = '" + xValue + "' "
	cQry += " AND TCU.TCU_EXALOC = '1' "
	If (QryEOF(cQry))
		lRet := .F.
	EndIf

Return lRet
//------------------------------------------------------------------------------
/*/{Protheus.doc} CheckTDX

@description Verifica se o item de Efetivo da Escala � v�lido

@author	boiani
@since	15/01/2020
/*/
//------------------------------------------------------------------------------
Static Function CheckTDX(xValue, cEscala, cTDXCod, cFilCtr)
	Local lRet := .T.
	Local cQry
	Local lMV_MultFil := TecMultFil()//Indica se a Mesa considera multiplas filiais
	Default cFilCtr := cFilAnt
	Default cTDXCod := ""

	cQry := " SELECT 1 "
	cQry += " FROM " + RetSqlName("TDX") + " TDX "
	cQry += " WHERE TDX.TDX_FILIAL = '" +  xFilial('TDX',IIF(lMV_MultFil,cFilCtr,cFilAnt)) + "' AND "
	cQry += " TDX.D_E_L_E_T_ = ' ' "
	If !EMPTY(xValue)
		cQry += " AND TDX.TDX_SEQTUR = '" + xValue + "' "
	EndIF
	If !EMPTY(cTDXCod)
		cQry += " AND TDX.TDX_COD = '" + cTDXCod + "' "
	EndIF
	cQry += " AND TDX.TDX_CODTDW = '" + cEscala + "' "
	If (QryEOF(cQry))
		lRet := .F.
	EndIf

Return lRet
//------------------------------------------------------------------------------
/*/{Protheus.doc} CheckTGX

@description Verifica se o item de Cobertura da Escala � v�lido

@author	boiani
@since	15/01/2020
/*/
//------------------------------------------------------------------------------
Static Function CheckTGX(cTGXCod, cEscala, cFilChk)
	Local lRet := .T.
	Local cQry
	Default cFilChk := cFilAnt
	cQry := " SELECT 1 "
	cQry += " FROM " + RetSqlName("TGX") + " TGX "
	cQry += " WHERE TGX.TGX_FILIAL = '" +  xFilial('TGX', cFilChk) + "' "
	cQry += " AND TGX.D_E_L_E_T_ = ' ' "
	cQry += " AND TGX.TGX_COD = '" + cTGXCod + "' "
	cQry += " AND TGX.TGX_CODTDW = '" + cEscala + "' "
	If (QryEOF(cQry))
		lRet := .F.
	EndIf

Return lRet
//------------------------------------------------------------------------------
/*/{Protheus.doc} CheckPJSem

@description Verifica se a Semana / Escala � v�lida de acordo com a Escala

@author	boiani
@since	15/01/2020
/*/
//------------------------------------------------------------------------------
Static Function CheckPJSem(cSeq, cTurno, cEscala, cFilChk)
	Local lRet := .T.
	Local cQry
	Default cTurno := ""
	Default cEscala := ""
	Default cFilChk := cFilAnt
	cQry := " SELECT 1 "
	cQry += " FROM " + RetSqlName("SPJ") + " SPJ "
	cQry += " WHERE SPJ.PJ_FILIAL = '" +  xFilial('SPJ',cFilChk) + "' "
	cQry += " AND SPJ.D_E_L_E_T_ = ' ' "
	If !EMPTY(cTurno)
		cQry += " AND SPJ.PJ_TURNO = '" + cTurno + "' "
	EndIf
	If !EMPTY(cEscala)
		cQry += " AND SPJ.PJ_TURNO IN ( SELECT TDX.TDX_TURNO FROM " + RetSqlName("TDX") + " TDX "
		cQry += " WHERE TDX.TDX_FILIAL = '" +  xFilial('TDX',cFilChk) + "' AND TDX.D_E_L_E_T_ = ' ' "
		cQry += " AND TDX.TDX_CODTDW = '" + cEscala + "' "
		cQry += " ) "
	EndIf
	cQry += " AND SPJ.PJ_SEMANA = '" + cSeq + "' "
	If (QryEOF(cQry))
		lRet := .F.
	EndIf

Return lRet
//------------------------------------------------------------------------------
/*/{Protheus.doc} At19dVlLGY

@description preValid da grid LGY

@author	boiani
@since	15/01/2020
/*/
//------------------------------------------------------------------------------
Function At19dVlLGY(oMdlG, nLine, cAcao, cCampo, xValue, xOldValue)
	Local lRet := .T.
	Local nRecTGY := 0
	Local nX
	Local nY
	Local nC
	Local cContrt := ""
	Local cCodTfl := ""
	Local cEscala := ""
	Local cTurno := ""
	Local cConFal := ""
	Local cCpoE
	Local cCpoS
	Local nDifHor
	Local oModel
	Local oMdlLAC
	Local oView
	Local aFieldsLGY := {}

	If cAcao == "SETVALUE" .AND. VALTYPE(oMdlG) == "O"
		Do Case
		Case cCampo == "LGY_FILIAL"
			If EMPTY(xValue) .OR. !(ExistCpo("SM0", cEmpAnt+xValue))
				lRet := .F.
				Help( " ", 1, "PRELINTGY", Nil, STR0480, 1 ) //O campo filial deve ser preenchido com uma filial v�lida
			EndIf
		Case cCampo == "LGY_CODTEC"
			If !(EMPTY(xValue)) .AND. !(ExistCpo("AA1", xValue))
				lRet := .F.
				Help(,,"PRELINTGY",,STR0515 + xValue + STR0516,1,0) //"C�digo do atendente " # " n�o localizado."
			EndIf
		Case cCampo == "LGY_DTINI"
			If xValue > oMdlG:GetValue("LGY_DTFIM") .AND. !EMPTY(oMdlG:GetValue("LGY_DTFIM")) .AND. !EMPTY(xValue)
				lRet := .F.
				Help(,,"PRELINTGY",,STR0444,1,0) //"A data de in�cio da aloca��o deve ser menor ou igual a data final de aloca��o"
			EndIf
		Case cCampo == "LGY_DTFIM"
			If xValue < oMdlG:GetValue("LGY_DTINI") .AND. !EMPTY(oMdlG:GetValue("LGY_DTINI")) .AND. !EMPTY(xValue)
				lRet := .F.
				Help(,,"PRELINTGY",,STR0445,1,0) //"A data final da aloca��o deve ser maior ou igual a data inicial de aloca��o"
			EndIf
		Case cCampo == "LGY_CONTRT"
			If EMPTY(xValue)
				oMdlG:SetValue("LGY_CODTFL", "")
				oMdlG:SetValue("LGY_CODTFF", "")
			EndIf
			If !EMPTY(xValue) .AND. !CheckContrt(AT190dLimp(xValue), oMdlG:GetValue("LGY_FILIAL"))
				lRet := .F.
				Help(,,"PRELINTGY",,STR0446,1,0) //"Contrato n�o localizado."
			EndIf
			If !EMPTY(xValue) .AND. xValue != xOldValue .AND. !EMPTY(oMdlG:GetValue("LGY_CODTFL"))
				If (QryEOF("SELECT 1 FROM " + RetSqlName( "TFL" ) + " TFL "+;
						" INNER JOIN " + RetSqlName( "TFJ" ) + " TFJ ON " +;
						" TFJ_FILIAL = '"+xFilial("TFJ",oMdlG:GetValue("LGY_FILIAL"))+"' AND TFL_CODPAI = TFJ_CODIGO AND " +;
						" TFJ.D_E_L_E_T_ = ' ' AND TFJ_STATUS = '1' AND TFJ_CONTRT = '" + xValue + "' " +;
						" WHERE TFL_CODIGO = '" + oMdlG:GetValue("LGY_CODTFL") +;
						"' AND TFL.D_E_L_E_T_ = ' ' AND TFL_FILIAL = '"+;
						xFilial("TFL",oMdlG:GetValue("LGY_FILIAL")) + "' AND TFL_CONTRT = '" + xValue + "' "))
					oMdlG:SetValue("LGY_CODTFL","")
				EndIf
			EndIf
		Case cCampo == "LGY_CODTFL"
			If EMPTY(xValue)
				oMdlG:SetValue("LGY_CODTFF", "")
			EndIf
			If Empty(oMdlG:GetValue("LGY_CONTRT"))
				cContrt := Posicione("TFL",1,xFilial("TFL",oMdlG:GetValue("LGY_FILIAL")) + xValue, "TFL_CONTRT")
			else
				cContrt := oMdlG:GetValue("LGY_CONTRT")
			EndIf
			If !EMPTY(xValue) .AND. !CheckTFL(AT190dLimp(xValue), cContrt, oMdlG:GetValue("LGY_FILIAL"))
				lRet := .F.
				Help(,,"PRELINTGY",,STR0447,1,0) //"C�digo do Local de Atendimento (LGY_CODTFL) n�o localizado no contrato."
			EndIf
			If xValue != xOldValue .AND. !EMPTY(oMdlG:GetValue("LGY_CODTFF"))
				If (QryEOF("SELECT 1 FROM " + RetSqlName( "TFF" ) + " TFF WHERE TFF_COD = '" + oMdlG:GetValue("LGY_CODTFF") +;
						"' AND D_E_L_E_T_ = ' ' AND TFF_FILIAL = '"+;
						xFilial("TFF",oMdlG:GetValue("LGY_FILIAL")) + "' AND TFF_CODPAI = '" + xValue + "' "))
					oMdlG:SetValue("LGY_CODTFF","")
				EndIf
			EndIf
		Case cCampo == "LGY_CODTFF"
			If Empty(oMdlG:GetValue("LGY_CONTRT"))
				cContrt := Posicione("TFF",1,xFilial("TFF",oMdlG:GetValue("LGY_FILIAL")) + xValue, "TFF_CONTRT")
			else
				cContrt := oMdlG:GetValue("LGY_CONTRT")
			EndIf

			If Empty(oMdlG:GetValue("LGY_CODTFL"))
				cCodTfl := Posicione("TFF",1,xFilial("TFF",oMdlG:GetValue("LGY_FILIAL")) + xValue, "TFF_CODPAI")
			else
				cCodTfl := oMdlG:GetValue("LGY_CODTFL")
			EndIf

			If !EMPTY(xValue) .AND. !CheckTFF(AT190dLimp(xValue), cContrt, cCodTfl, oMdlG:GetValue("LGY_FILIAL"))
				lRet := .F.
				Help(,,"PRELINTGY",,STR0448,1,0) //"C�digo do Posto (LGY_CODTFF) n�o localizado no contrato ou no Local de Atendimento."
			EndIf

			If lRet .AND. !EMPTY(xValue)
				If Posicione("TFF",1,xFilial("TFF",oMdlG:GetValue("LGY_FILIAL")) + xValue, "TFF_ENCE") == '1'
					lRet := .F.
					Help( " ", 1, "PRELINLGY", Nil, STR0518 , 1 ) //"N�o � poss�vel gerar novas agendas em um posto encerrado."
				EndIf
			EndIf

			If lRet .AND. !EMPTY(xValue) .AND. !EMPTY( (cEscala := Posicione("TFF",1,xFilial("TFF",oMdlG:GetValue("LGY_FILIAL"))+xValue,"TFF_ESCALA") ) )
				oMdlG:LoadValue("LGY_CONTRT",cContrt)
				oMdlG:LoadValue("LGY_CODTFL",cCodTfl)
				oMdlG:LoadValue("LGY_ESCALA", cEscala)
				oMdlG:LoadValue("LGY_DSCTDW", Posicione("TDW",1,xFilial("TDW",oMdlG:GetValue("LGY_FILIAL")) + cEscala, "TDW_DESC"))
			EndIf
		Case cCampo == "LGY_ESCALA"
			If (Empty(oMdlG:GetValue("LGY_CODTFF")) .OR. Empty(oMdlG:GetValue("LGY_CODTFL")) .OR.;
					Empty(oMdlG:GetValue("LGY_CONTRT"))) .AND. !EMPTY(xValue)

				lRet := .F.
				Help(,,"PRELINTGY",,STR0449,1,0) //"Para informar a Escala, � necess�rio preencher os campos Contrato, C�digo do Local e C�digo do Posto."
			EndIf

			If lRet
				If !EMPTY((cEscala := Posicione("TFF",1,xFilial("TFF",oMdlG:GetValue("LGY_FILIAL"))+oMdlG:GetValue("LGY_CODTFF"),"TFF_ESCALA"))) .AND. !EMPTY(xValue) .AND.;
						!EMPTY(xOldValue) .AND. xValue != cEscala
					lRet := .F.
					Help(,,"PRELINTGY",,STR0450 + cEscala + STR0451+ oMdlG:GetValue("LGY_CODTFF") + STR0452,1,0) //"A escala "#" j� est� vinculada a este posto (" #"). Para modifica-l�, utiliza a rotina Posto x Escala no Gest�o de Escalas."
				EndIf

				If lRet .AND. cEscala != xValue .AND. !EMPTY(xValue) .AND. !EMPTY(cEscala)
					lRet := .F.
					Help(,,"PRELINTGY",,STR0450 + cEscala + STR0451 + oMdlG:GetValue("LGY_CODTFF") + STR0452,1,0) //"A escala "#" j� est� vinculada a este posto (" #"). Para modifica-l�, utiliza a rotina Posto x Escala no Gest�o de Escalas."
				EndIf

				If lRet .AND. !EMPTY(xValue) .AND. !CheckTDW(AT190dLimp(xValue), oMdlG:GetValue("LGY_FILIAL"))
					lRet := .F.
					Help(,,"PRELINTGY",,STR0453 + xValue + STR0454,1,0) //"C�digo de Escala ("##") n�o cadastrado."
				EndIf
			EndIf
		Case cCampo == "LGY_CONFAL"
			If !EMPTY(xValue) .AND. xValue != xOldValue
				If  (Empty(oMdlG:GetValue("LGY_CODTFF")) .OR. Empty(oMdlG:GetValue("LGY_ESCALA")))
					lRet := .F.
					Help(,,"PRELINTGY",,STR0455,1,0) //"Antes de preencher a configura��o de aloca��o, � necess�rio informar a Escala e o Posto."
				EndIf
				If lRet .AND. oMdlG:GetValue("LGY_TIPOAL") == '1' //Efetivo
					If !CheckTDX("",oMdlG:GetValue("LGY_ESCALA"),xValue,oMdlG:GetValue("LGY_FILIAL"))
						lRet := .F.
						Help(,,"PRELINTGY",,STR0456,1,0) //"C�digo de Configura��o de Aloca��o de Efetivo n�o localizado."
					EndIf
				ElseIf lRet .AND. oMdlG:GetValue("LGY_TIPOAL") == '2' //Cobertura
					If !CheckTGX(xValue,oMdlG:GetValue("LGY_ESCALA"),oMdlG:GetValue("LGY_FILIAL"))
						lRet := .F.
						Help(,,"PRELINTGY",,STR0457,1,0) //"C�digo de Configura��o de Aloca��o de Cobertura n�o localizado."
					EndIF
				EndIf
				If lRet .AND. !EMPTY(oMdlG:GetValue("LGY_CODTEC"))
					If oMdlG:GetValue("LGY_TIPOAL") == '1' //Efetivo
						If (nRecTGY := getTGY(oMdlG:GetValue("LGY_CODTEC"),;
								oMdlG:GetValue("LGY_CODTFF"),;
								oMdlG:GetValue("LGY_ESCALA"),,;
								oMdlG:GetValue("LGY_FILIAL"))) > 0
							If xValue != (cConFal := At190GTCNF(,"LGY_CONFAL",oMdlG:GetValue("LGY_SEQ"),.T.))
								lRet := .F.
								Help(,,"PRELINTGY",,STR0458+ Alltrim(oMdlG:GetValue('LGY_NOMTEC')) +; //"O atendente "
								STR0459+ cConFal +; //" j� est� vinculado a Configura��o de Aloca��o "
								".",1,0)
							EndIf
							If TecXHasEdH()
								TGY->(DbGoTo(nRecTGY))
								For nX := 1 To 4
									IF !EMPTY(StrTran(&("TGY->TGY_ENTRA"+cValToChar(nX)),":"))
										oMdlG:SetValue(("LGY_ENTRA"+cValToChar(nX)), &("TGY->TGY_ENTRA"+cValToChar(nX)))
									EndIf
									IF !EMPTY(StrTran(&("TGY->TGY_SAIDA"+cValToChar(nX)),":"))
										oMdlG:SetValue(("LGY_SAIDA"+cValToChar(nX)), &("TGY->TGY_SAIDA"+cValToChar(nX)))
									EndIf
								Next nX
							EndIf
						ElseIf TecXHasEdH() .AND. VldEscala(0, oMdlG:GetValue("LGY_ESCALA"), oMdlG:GetValue("LGY_CODTFF"),.F.,oMdlG:GetValue("LGY_FILIAL"))
							For nX := 1 To 4
								If ( At580bHGet(( "PJ_ENTRA" + cValToChar(nX) )) != 0 .OR. At580bHGet(("PJ_SAIDA" + cValToChar(nX))) != 0 )
									oMdlG:LoadValue(("LGY_ENTRA"+ cValToChar(nX) ) ,TxValToHor(At580bHGet(("PJ_ENTRA"+ cValToChar(nX)))))
									oMdlG:LoadValue(("LGY_SAIDA"+ cValToChar(nX) ) ,TxValToHor(At580bHGet(("PJ_SAIDA"+ cValToChar(nX)))))
								EndIf
							Next
						EndIf
						At580BClHs()
					Else //oMdlG:GetValue("LGY_TIPOAL") == '2' //Cobertura
						If hasTGZ(oMdlG:GetValue("LGY_CODTEC"),oMdlG:GetValue("LGY_CODTFF"),oMdlG:GetValue("LGY_ESCALA"),oMdlG:GetValue("LGY_FILIAL")) .AND.;
								xValue != (cConFal := At190GTCNF(,"LGY_CONFAL",,.T.))
							Help(,,"PRELINTGY",,STR0458 + Alltrim(oMdlG:GetValue('LGY_NOMTEC')) +; //"O atendente "
							STR0459 + cConFal +; //" j� est� vinculado a Configura��o de Aloca��o "
							".",1,0)
						Endif
					EndIf
				EndIf
			EndIf
		Case cCampo == "LGY_TIPOAL"
			If xValue != xOldValue
				If !EMPTY(oMdlG:GetValue("LGY_CONFAL"))
					oMdlG:SetValue("LGY_CONFAL", "")
				EndIf
				if xValue == '2'
					If !EMPTY(oMdlG:GetValue("LGY_SEQ"))
						oMdlG:SetValue("LGY_SEQ","")
					EndIf
					If !EMPTY(oMdlG:GetValue("LGY_TIPTCU"))
						oMdlG:SetValue("LGY_TIPTCU","")
					EndIf
				EndIf
			EndIf
		Case cCampo == "LGY_SEQ"
			If !EMPTY(xValue)
				If oMdlG:GetValue("LGY_TIPOAL") == '2' //Cobertura
					lRet := .F.
					Help(,,"PRELINTGY",,STR0460,1,0) //"O campo Sequ�ncia n�o � utilizado em aloca��es do tipo Cobertura."
				ElseIf oMdlG:GetValue("LGY_TIPOAL") == '1'
					If !EMPTY(oMdlG:GetValue("LGY_CONFAL")) .AND. !CheckPJSem(xValue,;
							(cTurno := POSICIONE("TDX",1,xFilial("TDX",oMdlG:GetValue("LGY_FILIAL"))+oMdlG:GetValue("LGY_CONFAL"),'TDX_TURNO')),;
																				/*cEscala*/,oMdlG:GetValue("LGY_FILIAL"))
							lRet := .F.
						Help(,,"PRELINTGY",,STR0461 + xValue + STR0462 + cTurno + " - " +; //"Sequ�ncia ("##") n�o localizada no turno "
						Posicione("SR6",1,xFilial("SR6",oMdlG:GetValue("LGY_FILIAL")) + cTurno , 'R6_DESC') ,1,0)
					ElseIf EMPTY(oMdlG:GetValue("LGY_CONFAL")) .AND. !EMPTY((cEscala := oMdlG:GetValue("LGY_ESCALA")))
						If !CheckPJSem(xValue,/*cTurno*/,cEscala,oMdlG:GetValue("LGY_FILIAL"))
							lRet := .F.
							Help(,,"PRELINTGY",,STR0461 + xValue + STR0463 + cEscala + " - " +; //"Sequ�ncia ("##") n�o localizada na escala "
							Posicione("TDW",1,xFilial("TDW",oMdlG:GetValue("LGY_FILIAL")) + cEscala , 'TDW_DESC') ,1,0)
						EndIf
					EndIf
				EndIf
			EndIf
		Case cCampo == 'LGY_TIPTCU'
			If !EMPTY(xValue)
				If oMdlG:GetValue("LGY_TIPOAL") == '2' //Cobertura
					lRet := .F.
					Help(,,"PRELINTGY",,STR0464,1,0) //"O campo Tipo de Aloca��o n�o � utilizado em aloca��es do tipo Cobertura."
				Else
					If !CheckTCU(xValue, oMdlG:GetValue("LGY_FILIAL"))
						lRet := .F.
						Help(,,"PRELINTGY",,STR0465,1,0)//"C�digo do tipo de aloca��o n�o localizado ou n�o configurado para ser exibido para aloca��o (TCU_EXALOC)."
					EndIf
				EndIf
			EndIf
		Case 'LGY_ENTRA' $ cCampo .OR. 'LGY_SAIDA' $ cCampo
			If oMdlG:GetValue("LGY_TIPOAL") == '2' //Cobertura
				If RIGHT(Alltrim(cCampo),1) != '1'
					lRet := .F.
					Help(,,"PRELINTGY",,STR0466,1,0) //"Campo n�o utilizado para o tipo de aloca��o de Cobertura. Utilize os campos Entrada 1 e Sa�da 1"
				EndIf
			EndIf

			If !EMPTY(xValue) .AND. lRet
				lRet := AtVldHora(xValue)
			EndIf

			If lRet .AND. cCampo == 'LGY_ENTRA1'
				If VldEscala(0, oMdlG:GetValue("LGY_ESCALA"),oMdlG:GetValue("LGY_CODTFF"), .F.,oMdlG:GetValue("LGY_FILIAL"))
					nDifHor := At190DifHo(oMdlG:GetValue("LGY_ENTRA1"), xValue)
					For nC := 1 to 4
						cCpoE := "LGY_ENTRA"+cValToChar(nC)
						cCpoS := "LGY_SAIDA"+cValToChar(nC)
						If At580eWhen(cValToChar(nC))
							If cCpoE != "LGY_ENTRA1"
								nValue := HoratoInt(oMdlG:GetValue(cCpoE))
								nValueA := nDifHor + nValue
								If nValueA >= 24
									nValueA := nValueA-24
								EndIf
								oMdlG:SetValue(cCpoE,IntToHora(nValueA))
							EndIf
							nValue := HoratoInt(oMdlG:GetValue(cCpoS))
							nValueA := nDifHor + nValue
							If nValueA >= 24
								nValueA := nValueA-24
							EndIf
							oMdlG:SetValue(cCpoS,IntToHora(nValueA))
						EndIf
					Next nC
				EndIf
				At580BClHs()
			EndIf
		EndCase
		If lRet .AND. oMdlG:GetValue("LGY_STATUS") != "BR_VERMELHO" .AND.;
				cCampo != "LGY_STATUS" .AND. (xValue != xOldValue .OR. xValue != oMdlG:GetValue(cCampo))
			oModel := oMdlG:GetModel()
			oMdlLAC := oModel:GetModel("LACDETAIL")
			If oMdlG:GetValue("LGY_STATUS") != "BR_CANCEL"
				oMdlLAC:ClearData()
				oMdlLAC:InitLine()
			EndIf
			oMdlG:LoadValue("LGY_STATUS", "BR_VERMELHO")
			oMdlG:LoadValue("LGY_DETALH", "")
			If !EMPTY(aAlocLGY)
				For nY := 1 To LEN(aAlocLGY)
					If VALTYPE(aAlocLGY[nY]) == 'O'
						If aAlocLGY[nY]:defTec() == oMdlG:GetValue("LGY_CODTEC")
							aAlocLGY[nY]:destroy()
							aAlocLGY[nY] := nil
						EndIf
					EndIf
				Next nY
			EndIf
			If !isBlind()
				oView := FwViewActive()
				oView:Refresh("DETAIL_LAC")
				oView:Refresh("DETAIL_LGY")
			EndIf
		EndIf
	EndIf

Return lRet
//------------------------------------------------------------------------------
/*/{Protheus.doc} At190GTCNF

@description Retorna o valor do campo cCpoRet de acordo com a TGY/TGZ/Posto

@author	boiani
@since	15/01/2020
/*/
//------------------------------------------------------------------------------
Function At190GTCNF(cCodTFF, cCpoRet, cSeq, lForceChng)
	Local oModel := FwModelActive()
	Local oMdlLGY := oModel:GetModel("LGYDETAIL")
	Local cCodTec := oMdlLGY:GetValue("LGY_CODTEC")
	Local cEscala := oMdlLGY:GetValue("LGY_ESCALA")
	Local lCobertura := oMdlLGY:GetValue("LGY_TIPOAL") == '2'
	Local cFilChk := oMdlLGY:GetValue("LGY_FILIAL")
	Local cSql := ""
	Local cAliasQry := ""
	Local xRet
	Local nCount := 0
	Local nCntAtd := 0
	Local lContinua := .F.

	Default cCodTFF := oMdlLGY:GetValue("LGY_CODTFF")
	Default cSeq := ""
	Default lForceChng := .F.

	If !EMPTY(cCodTec) .AND. !EMPTY(cCodTFF) .AND. !EMPTY(cEscala)
		If !lCobertura
			cSql += " SELECT TDX.TDX_COD, TGY.TGY_GRUPO, TGY.TGY_SEQ, TGY.TGY_TIPALO "
			cSql += " FROM " + RetSqlName( "TDX" ) + " TDX LEFT JOIN " + RetSqlName( "TGY" ) + " TGY ON "
			cSql += " TGY.D_E_L_E_T_ = ' ' AND TGY.TGY_FILIAL = '" + xFilial("TGY",cFilChk) + "' AND "
			cSql += " TGY.TGY_ATEND = '" + cCodTec + "' AND TGY.TGY_CODTFF = '" + cCodTFF + "' "
			cSql += " AND TGY.TGY_CODTDX = TDX.TDX_COD "
			cSql += " WHERE TDX.D_E_L_E_T_ = ' ' AND TDX.TDX_FILIAL = '" + xFilial("TDX",cFilChk) + "' AND "
			cSql += " TDX.TDX_CODTDW = '" + cEscala + "' "
			If !EMPTY(cSeq)
				cSql += " AND TDX.TDX_SEQTUR = '" + cSeq + "' "
			Endif
			cSql := ChangeQuery(cSql)
			cAliasQry := GetNextAlias()
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSql),cAliasQry, .F., .T.)

			While !(cAliasQry)->(EOF())
				nCount++
				If !EMPTY((cAliasQry)->(TGY_GRUPO))
					nCntAtd++
				EndIf
				(cAliasQry)->(DbSkip())
			End
			(cAliasQry)->(DbgoTop())
			If nCount == 1
				lContinua := .T.
			ElseIf nCntAtd == 1 .AND. nCount > 1
				lContinua := .T.
				While !(cAliasQry)->(EOF())
					If !EMPTY((cAliasQry)->(TGY_GRUPO))
						Exit
					EndIf
					(cAliasQry)->(DbSkip())
				End
			EndIf
			If !(cAliasQry)->(EOF())  .AND. lContinua
				If cCpoRet == "LGY_CONFAL" .AND. !EMPTY((cAliasQry)->TDX_COD)
					If EMPTY(oMdlLGY:GetValue("LGY_CONFAL")) .OR. lForceChng .OR. !(getTGY(cCodTec,cCodTFF,cEscala,,cFilChk) > 0)
						xRet := (cAliasQry)->TDX_COD
					Else
						xRet := oMdlLGY:GetValue("LGY_CONFAL")
					EndIf
				ElseIf cCpoRet == "LGY_GRUPO" .AND. !EMPTY((cAliasQry)->TGY_GRUPO)
					If EMPTY(oMdlLGY:GetValue("LGY_GRUPO")) .OR. lForceChng
						xRet := (cAliasQry)->TGY_GRUPO
					Else
						xRet := oMdlLGY:GetValue("LGY_GRUPO")
					Endif
				ElseIf cCpoRet == "LGY_SEQ" .AND. !EMPTY((cAliasQry)->TGY_SEQ)
					If EMPTY(oMdlLGY:GetValue("LGY_SEQ")) .OR. lForceChng
						xRet := (cAliasQry)->TGY_SEQ
					Else
						xRet := oMdlLGY:GetValue("LGY_SEQ")
					Endif
				ElseIf cCpoRet == "LGY_TIPTCU" .AND. !EMPTY((cAliasQry)->TGY_TIPALO)
					If EMPTY(oMdlLGY:GetValue("LGY_TIPTCU")) .OR. lForceChng
						xRet := (cAliasQry)->TGY_TIPALO
					Else
						xRet := oMdlLGY:GetValue("LGY_TIPTCU")
					Endif
				EndIf
			EndIf
		Else //Cobertura
			cSql += " SELECT TGX.TGX_COD, TGZ.TGZ_GRUPO "
			cSql += " FROM " + RetSqlName( "TGX" ) + " TGX LEFT JOIN " + RetSqlName( "TGZ" ) + " TGZ ON "
			cSql += " TGZ.D_E_L_E_T_ = ' ' AND TGZ.TGZ_FILIAL = '" + xFilial("TGZ",cFilChk) + "' AND "
			cSql += " TGZ.TGZ_ATEND = '" + cCodTec + "' AND TGZ.TGZ_CODTFF = '" + cCodTFF + "' "
			cSql += " AND TGZ.TGZ_CODTDX = TGX.TGX_COD "
			cSql += " WHERE TGX.D_E_L_E_T_ = ' ' AND TGX.TGX_FILIAL = '" + xFilial("TGX",cFilChk) + "' AND "
			cSql += " TGX.TGX_CODTDW = '" + cEscala + "' "
			cSql := ChangeQuery(cSql)
			cAliasQry := GetNextAlias()
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSql),cAliasQry, .F., .T.)

			While !(cAliasQry)->(EOF())
				nCount++
				If !EMPTY((cAliasQry)->(TGZ_GRUPO))
					nCntAtd++
				EndIf
				(cAliasQry)->(DbSkip())
			End
			(cAliasQry)->(DbgoTop())
			If nCount == 1
				lContinua := .T.
			ElseIf nCntAtd == 1 .AND. nCount > 1
				lContinua := .T.
				While !(cAliasQry)->(EOF())
					If !EMPTY((cAliasQry)->(TGZ_GRUPO))
						Exit
					EndIf
					(cAliasQry)->(DbSkip())
				End
			EndIf
			If !(cAliasQry)->(EOF())  .AND. lContinua
				If cCpoRet == "LGY_CONFAL" .AND. !EMPTY((cAliasQry)->TGX_COD)
					If EMPTY(oMdlLGY:GetValue("LGY_CONFAL")) .OR. lForceChng .OR. !hasTGZ(cCodTec,cCodTFF,cEscala,cFilChk)
						xRet := (cAliasQry)->TGX_COD
					Else
						xRet := oMdlLGY:GetValue("LGY_CONFAL")
					EndIf
				ElseIf cCpoRet == "LGY_GRUPO" .AND. !EMPTY((cAliasQry)->TGZ_GRUPO)
					If EMPTY(oMdlLGY:GetValue("LGY_GRUPO")) .OR. lForceChng
						xRet := (cAliasQry)->TGZ_GRUPO
					Else
						xRet := oMdlLGY:GetValue("LGY_GRUPO")
					Endif
				EndIf
			EndIf
		EndIf
		(cAliasQry)->(dbCloseArea())
	Endif
	If EMPTY(xRet)
		If cCpoRet == "LGY_TIPTCU" .AND. !lCobertura
			xRet := oMdlLGY:GetValue("LGY_TIPTCU")
		EndIf
	EndIf
Return xRet
//------------------------------------------------------------------------------
/*/{Protheus.doc} At190dGSeq

@description Retorna a sequ�ncia de acordo com a Escala

@author	boiani
@since	15/01/2020
/*/
//------------------------------------------------------------------------------
Function At190dGSeq(cEscala)
	Local cRet := ""
	Local oModel := FwModelActive()
	Local oMdlLGY := oModel:GetModel("LGYDETAIL")
	Local cCodTec := oMdlLGY:GetValue("LGY_CODTEC")
	Local cCodTFF := oMdlLGY:GetValue("LGY_CODTFF")
	Local lCobertura := oMdlLGY:GetValue("LGY_TIPOAL") == '2'
	Local cQry
	Local nCount := 0

	If !EMPTY(cEscala)
		If !EMPTY(cCodTec)
			//Verifica se localiza o atendente na TGY
			cQry := GetNextAlias()

			BeginSQL Alias cQry
			SELECT TGY.TGY_SEQ
				FROM %Table:TGY% TGY
				WHERE TGY.TGY_FILIAL = %xFilial:TGY%
				AND TGY.%NotDel%
				AND TGY.TGY_ATEND = %Exp:cCodTec%
				AND TGY.TGY_CODTFF = %Exp:cCodTFF%
				AND TGY.TGY_ESCALA = %Exp:cEscala%
			EndSQL
			If !(cQry)->(EOF())
				cRet := (cQry)->TGY_SEQ
			EndIf
			(cQry)->(DbCloseArea())
		EndIF

		If EMPTY(cRet)
			If !lCobertura
				cQry := GetNextAlias()

				BeginSQL Alias cQry
				SELECT TDX.TDX_SEQTUR
					FROM %Table:TDX% TDX
					WHERE TDX.TDX_FILIAL = %xFilial:TDX%
					AND TDX.%NotDel%
					AND TDX.TDX_CODTDW = %Exp:cEscala%
				EndSQL
				While !(cQry)->(EOF())
					nCount++
					(cQry)->(DbSkip())
				End
				(cQry)->(DbGoTop())
				If nCount == 1
					cRet := (cQry)->TDX_SEQTUR
				EndIf
				(cQry)->(DbCloseArea())
			EndIf
		EndIf
	EndIf

Return cRet
//------------------------------------------------------------------------------
/*/{Protheus.doc} T190dEscCA

@description Retorna a Configura��o de Aloca��o de acordo com a Escala

@author	boiani
@since	15/01/2020
/*/
//------------------------------------------------------------------------------
Function T190dEscCA(cEscala)
	Local cRet := ""
	Local oModel := FwModelActive()
	Local oMdlLGY := oModel:GetModel("LGYDETAIL")
	Local cConFal := oMdlLGY:GetValue("LGY_CONFAL")
	Local cSeqTur := oMdlLGY:GetValue("LGY_SEQ")
	Local cCodTFF := oMdlLGY:GetValue("LGY_CODTFF")
	Local lCobertura := oMdlLGY:GetValue("LGY_TIPOAL") == '2'
	Local cFilBusca := oMdlLGY:GetValue("LGY_FILIAL")
	Local xRet

	If !EMPTY(cEscala)
		If !lCobertura
			If CheckTDX(cSeqTur,cEscala,cConFal,cFilBusca)
				cRet := cConFal
			ElseIf !EMPTY(xRet := At190GTCNF(cCodTFF,"LGY_CONFAL", cSeqTur, .T.)) .AND. xRet != cConFal
				cRet := xRet
			EndIf
		EndIf
	EndIf

Return cRet
//------------------------------------------------------------------------------
/*/{Protheus.doc} getTGY

@description Verifica se existe uma TGY v�lida de acordo com os par�metros de
Atendente/posto/escala e Configura��o de Aloca��o e retorna seu RECNO

@author	boiani
@since	15/01/2020
/*/
//------------------------------------------------------------------------------
Static Function getTGY(cCodTec,cCodTFF,cEscala,cCodTDX, cFilChk)
	Local cQry
	Local cAliasQry := GetNextAlias()
	Local nRecTGY := 0

	Default cCodTDX := ""
	Default cFilChk := cFilAnt

	cQry := " SELECT TGY.R_E_C_N_O_ REC "
	cQry += " FROM " + RetSqlName("TGY") + " TGY "
	cQry += " WHERE TGY.TGY_FILIAL = '" +  xFilial('TGY',cFilChk) + "' AND "
	cQry += " TGY.D_E_L_E_T_ = ' ' "
	cQry += " AND TGY.TGY_ATEND = '" + cCodTec + "' "
	cQry += " AND TGY.TGY_CODTFF = '" + cCodTFF + "' "
	cQry += " AND TGY.TGY_ESCALA = '" + cEscala + "' "
	If !EMPTY(cCodTDX)
		cQry += " AND TGY.TGY_CODTDX = '" + cCodTDX + "' "
	EndIf

	cQry := ChangeQuery(cQry)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQry),cAliasQry, .F., .T.)

	If !(cAliasQry)->(EOF())
		nRecTGY := (cAliasQry)->REC
	EndIf

	DbCloseArea(cAliasQry)

Return nRecTGY
//------------------------------------------------------------------------------
/*/{Protheus.doc} hasTGZ

@description Verifica se existe uma TGZ v�lida de acordo com os par�metros de
Atendente/posto/escala e Configura��o de Aloca��o

@author	boiani
@since	15/01/2020
/*/
//------------------------------------------------------------------------------
Static Function hasTGZ(cCodTec,cCodTFF,cEscala,cCodTGX, cFilChk)
	Local cQry
	Local lRet := .T.
	Default cCodTGX := ""
	Default cFilChk := cFilAnt
	cQry := " SELECT 1 "
	cQry += " FROM " + RetSqlName("TGZ") + " TGZ "
	cQry += " WHERE TGZ.TGZ_FILIAL = '" +  xFilial('TGZ',cFilChk) + "' AND "
	cQry += " TGZ.D_E_L_E_T_ = ' ' "
	cQry += " AND TGZ.TGZ_ATEND = '" + cCodTec + "' "
	cQry += " AND TGZ.TGZ_CODTFF = '" + cCodTFF + "' "
	cQry += " AND TGZ.TGZ_ESCALA = '" + cEscala + "' "
	If !EMPTY(cCodTGX)
		cQry += " AND TGZ.TGZ_CODTDX = '" + cCodTGX + "' "
	EndIf

	If (QryEOF(cQry))
		lRet := .F.
	EndIf

Return lRet
//------------------------------------------------------------------------------
/*/{Protheus.doc} checkLGY

@description Valida os dados da grid LGY

@author	boiani
@since	03/02/2020
/*/
//------------------------------------------------------------------------------
Static Function checkLGY()
	Local lRet := .T.
	Local oModel := FwModelActive()
	Local oMdglLGY := oModel:GetModel("LGYDETAIL")
	Local aSaveLines := FWSaveRows( oModel )
	Local nX
	Local dDtIniPosto
	Local dDtFimPosto
	Local aAtendentes := {}
	Local cEscala := ""

	If lRet .And. !((FindFunction("U_PNMSESC") .And. FindFunction("U_PNMSCAL")) .OR. ( FindFunction( "TecExecPNM" ) .AND. TecExecPNM() ))
		Help( , , "PNMTABC01", Nil, STR0121, 1, 0,,,,,,{STR0378}) //"Funcionalidade de aloca��o de atendente integrada com o Gest�o de Escalas, n�o disponivel pois n�o esta com patch aplicado com as configura��es do RH (PNMTABC01) e o parametro 'MV_GSPNMTA' est� desabilitado." ## "Por favor, aplique o patch para as configura��es do RH (PNMTABC01) ou fa�a ativa��o do parametro 'MV_GSPNMTA' para utiliza��o."
		lRet := .F.
	EndIf

	If !At680Perm(NIL, __cUserId, "039", .T.)
		Help(,1,"ProjAloc",,STR0475, 1)//"Usu�rio sem permiss�o de projetar agenda"
		lRet := .F.
	EndIf

	If lRet
		For nX := 1 To oMdglLGY:Length()
			oMdglLGY:GoLine(nX)
			If oMdglLGY:GetValue("LGY_STATUS") == "BR_CANCEL"
				oMdglLGY:LoadValue("LGY_STATUS", "BR_VERMELHO")
			EndIf

			If EMPTY(oMdglLGY:GetValue("LGY_CODTEC"))
				oMdglLGY:LoadValue("LGY_DETALH", STR0118) //"C�digo do atendente n�o preenchido. Por favor, preencha o c�digo do atendente"
				oMdglLGY:LoadValue("LGY_STATUS", "BR_CANCEL")
				Loop
			EndIf

			If EMPTY(aAtendentes) .OR. (ASCAN(aAtendentes, oMdglLGY:GetValue("LGY_CODTEC")) == 0)
				AADD(aAtendentes, oMdglLGY:GetValue("LGY_CODTEC"))
			ElseIf ASCAN(aAtendentes, oMdglLGY:GetValue("LGY_CODTEC")) != 0
				lRet := .F.
				oMdglLGY:LoadValue("LGY_STATUS", "BR_CANCEL")
				Help(,1,"ProjAloc",,STR0508 + aAtendentes[ASCAN(aAtendentes, oMdglLGY:GetValue("LGY_CODTEC"))] + STR0509, 1) //"O atendente " ## " est� duplicado no grid de Atendetes."
				Exit
			EndIf

			If Posicione("AA1",1,xFilial("AA1", oMdglLGY:GetValue("LGY_FILIAL"))+oMdglLGY:GetValue("LGY_CODTEC"),"AA1_ALOCA") == '2'
				oMdglLGY:LoadValue("LGY_DETALH", STR0347) //"Atendente n�o est� dispon�vel para aloca��o, realize manuten��o no cadastro de Atendentes no campo AA1_ALOCA."
				oMdglLGY:LoadValue("LGY_STATUS", "BR_CANCEL")
				Loop
			EndIf

			If (Empty(oMdglLGY:GetValue("LGY_CODTFF")) .OR.;
					Empty(oMdglLGY:GetValue("LGY_GRUPO")) .OR.;
					Empty(oMdglLGY:GetValue("LGY_DTINI")) .OR.;
					Empty(oMdglLGY:GetValue("LGY_DTFIM")) .OR.;
					Empty(oMdglLGY:GetValue("LGY_SEQ")) .OR.;
					Empty(oMdglLGY:GetValue("LGY_ESCALA")) .OR.;
					Empty(oMdglLGY:GetValue("LGY_TIPTCU"));
					)
				oMdglLGY:LoadValue("LGY_DETALH", STR0122) //"Os campos 'Posto', 'Escala', 'Sequ�ncia' ,'Grupo' e o Per�odo de Aloca��o s�o obrigat�rios para a proje��o da agenda"
				oMdglLGY:LoadValue("LGY_STATUS", "BR_CANCEL")
				Loop
			EndIf

			dDtIniPosto := POSICIONE("TFF",1,xFilial("TFF",oMdglLGY:GetValue("LGY_FILIAL"))+oMdglLGY:GetValue("LGY_CODTFF"),"TFF_PERINI")
			dDtFimPosto := POSICIONE("TFF",1,xFilial("TFF",oMdglLGY:GetValue("LGY_FILIAL"))+oMdglLGY:GetValue("LGY_CODTFF"),"TFF_PERFIM")
			cEscala := POSICIONE("TFF",1,xFilial("TFF",oMdglLGY:GetValue("LGY_FILIAL"))+oMdglLGY:GetValue("LGY_CODTFF"),"TFF_ESCALA")

			If TecABBPRHR()
				If TecConvHr(POSICIONE("TFF",1,xFilial("TFF",oMdglLGY:GetValue("LGY_FILIAL"))+oMdglLGY:GetValue("LGY_CODTFF"),"TFF_QTDHRS")) > 0
					oMdglLGY:LoadValue("LGY_DETALH", STR0510) //"Utilize a aba Atendentes para realizar Aloca��o por hora"
					oMdglLGY:LoadValue("LGY_STATUS", "BR_CANCEL")
					Loop
				EndIf
			EndIf

			If oMdglLGY:GetValue("LGY_DTINI") > oMdglLGY:GetValue("LGY_DTFIM")
				oMdglLGY:LoadValue("LGY_DETALH", STR0123) //"A data de in�cio deve ser menor ou igual a data de t�rmino."
				oMdglLGY:LoadValue("LGY_STATUS", "BR_CANCEL")
				Loop
			EndIf

			If EMPTY(cEscala) .OR. cEscala != oMdglLGY:GetValue("LGY_ESCALA")
				oMdglLGY:LoadValue("LGY_DETALH", STR0517) //"A escala informada difere da escala do posto."
				oMdglLGY:LoadValue("LGY_STATUS", "BR_CANCEL")
				Loop
			EndIf

			If Posicione("TFF",1,xFilial("TFF",oMdglLGY:GetValue("LGY_FILIAL"))+oMdglLGY:GetValue("LGY_CODTFF"),"TFF_ENCE") == '1'
				oMdglLGY:LoadValue("LGY_DETALH", STR0124) //"Posto encerrado. N�o � poss�vel gerar novas agendas."
				oMdglLGY:LoadValue("LGY_STATUS", "BR_CANCEL")
				Loop
			EndIf

			If EMPTY(dDtIniPosto) .OR. EMPTY(dDtFimPosto)
				oMdglLGY:LoadValue("LGY_DETALH", STR0125 + oMdglLGY:GetValue("LGY_CODTFF"))	//"N�o foi poss�vel localizar o Per�odo Inicial (TFF_PERINI) ou o Per�odo Final (TFF_PERFIM) do posto "
				oMdglLGY:LoadValue("LGY_STATUS", "BR_CANCEL")
				Loop
			EndIf

			If (oMdglLGY:GetValue("LGY_DTINI") < dDtIniPosto .OR. oMdglLGY:GetValue("LGY_DTFIM") > dDtFimPosto)
				oMdglLGY:LoadValue("LGY_DETALH", STR0126 + dToC(dDtIniPosto) + STR0207 + dToC(dDtFimPosto) + STR0127 )
				//"O per�odo de aloca��o estipulado no posto inicia-se em " # " e encerra-se em " # ". N�o � poss�vel projetar agenda fora deste per�odo."
				oMdglLGY:LoadValue("LGY_STATUS", "BR_CANCEL")
				Loop
			EndIf
		Next nX
	EndIf
	FWRestRows( aSaveLines )
Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At190DIsRT
@description  Verifica se o tipo de movimentaco � reserva tecnica

@param cTpAloc - Caracter - Codigo do tipo de Aloca��o(TCU_COD)
@return lRet, Bool - Indica se a agenda futura de reserva vai ser mantida

@author  fabiana.silva
@since  20/01/2020
/*/ 
//--------------------------------------------------------------------------------------------------------------------
Static Function At190DIsRT(cTpAloc)
	Local lRet 	:= .F.
	Local aConf	:= {}

	DbSelectArea("TCU")

	aConf := TxConfTCU(cTpAloc,{"TCU_RESTEC"})

	If Len(aConf) > 0 .And. (!Empty(aConf[1][1]) .And. aConf[1][1] = "TCU_RESTEC")
		If aConf[1][2] = "1" //"1=Sim;2=N�o"
			lRet := .T.
		EndIf
	EndIf

Return lRet
//------------------------------------------------------------------------------
/*/{Protheus.doc} AT190UbCp

@description Op��o de "Copiar" dentro do "Outras A��es"

@author	boiani
@since	05/02/2020
/*/
//------------------------------------------------------------------------------
Function AT190UbCp()
	Local oView := FwViewActive()
	Local aFldPai	:= oView:GetFolderActive("TELA_ABAS", 2) //Verifica se a aba Pai est� aberta

	If aFldPai[1] == 3
		At190dF10()
	Else
		Help( " ", 1, "COPYLINE", Nil, "Op��o de copiar linha dispon�vel apenas na aba de Aloca��es", 1 )
	EndIf

Return
//------------------------------------------------------------------------------
/*/{Protheus.doc} AT190UbPt

@description Op��o de "Colar" dentro do "Outras A��es"

@author	boiani
@since	05/02/2020
/*/
//------------------------------------------------------------------------------
Function AT190UbPt()
	Local oView := FwViewActive()
	Local aFldPai	:= oView:GetFolderActive("TELA_ABAS", 2) //Verifica se a aba Pai est� aberta

	If aFldPai[1] == 3
		At190dF11()
	Else
		Help( " ", 1, "PASTELINE", Nil, "Op��o de colar linha dispon�vel apenas na aba de Aloca��es", 1 )
	EndIf

Return
//------------------------------------------------------------------------------
/*/{Protheus.doc} ProjLAC

@description Executa a proje��o das agendas dentro de uma barra de progresso

@author	boiani
@since	05/02/2020
/*/
//------------------------------------------------------------------------------
Static Function ProjLAC(oDlg,oMeter)
	Local oModel := FwModelActive()
	Local oMdlLAC := oModel:GetModel("LACDETAIL")
	Local oMdlLGY := oModel:GetModel("LGYDETAIL")
	Local nX
	Local nY
	Local nAux
	Local nCount := 0
	Local lLoadBar := .F.
	Local lJaProj := .F.

	Default oDlg := nil
	Default oMeter := nil

	lLoadBar := !isBlind() .AND. oMeter != nil .AND. oDlg != nil

	For nX := 1 To oMdlLGY:Length()
		oMdlLGY:GoLine(nX)
		If oMdlLGY:GetValue("LGY_STATUS") == "BR_CANCEL" .OR. oMdlLGY:GetValue("LGY_STATUS") == "BR_VERDE"
			If lLoadBar
				oMeter:Set(++nCount)
				oMeter:Refresh()
			EndIf
			Loop
		EndIf
		lJaProj := .F.
		For nY := 1 To LEN(aAlocLGY)
			lJaProj := .F.
			If VALTYPE(aAlocLGY[nY]) == 'O'
				If aAlocLGY[nY]:defCob() == (oMdlLGY:GetValue("LGY_TIPOAL") == '2') .AND.;
						aAlocLGY[nY]:defEscala() == oMdlLGY:GetValue("LGY_ESCALA") .AND.;
						aAlocLGY[nY]:defPosto() == oMdlLGY:GetValue("LGY_CODTFF") .AND.;
						aAlocLGY[nY]:defSeq() == oMdlLGY:GetValue("LGY_SEQ") .AND.;
						aAlocLGY[nY]:defTec() == oMdlLGY:GetValue("LGY_CODTEC") .AND.;
						aAlocLGY[nY]:defGrupo() == oMdlLGY:GetValue("LGY_GRUPO") .AND.;
						aAlocLGY[nY]:defConfal() == oMdlLGY:GetValue("LGY_CONFAL") .AND.;
						aAlocLGY[nY]:defDate()[1] == oMdlLGY:GetValue("LGY_DTINI") .AND.;
						aAlocLGY[nY]:defDate()[2] == oMdlLGY:GetValue("LGY_DTFIM")
					If TecXHasEdH()
						If aAlocLGY[nY]:defGeHor()[1][1] == oMdlLGY:GetValue("LGY_ENTRA1") .AND.;
								aAlocLGY[nY]:defGeHor()[1][2] == oMdlLGY:GetValue("LGY_SAIDA1") .AND.;
								aAlocLGY[nY]:defGeHor()[2][1] == oMdlLGY:GetValue("LGY_ENTRA2") .AND.;
								aAlocLGY[nY]:defGeHor()[2][2] == oMdlLGY:GetValue("LGY_SAIDA2") .AND.;
								aAlocLGY[nY]:defGeHor()[3][1] == oMdlLGY:GetValue("LGY_ENTRA3") .AND.;
								aAlocLGY[nY]:defGeHor()[3][2] == oMdlLGY:GetValue("LGY_SAIDA3") .AND.;
								aAlocLGY[nY]:defGeHor()[4][1] == oMdlLGY:GetValue("LGY_ENTRA4") .AND.;
								aAlocLGY[nY]:defGeHor()[4][2] == oMdlLGY:GetValue("LGY_SAIDA4")
							lJaProj := .T.
						EndIf
					Else
						lJaProj := .T.
					EndIf
				EndIf
			EndIf
			If lJaProj
				Exit
			EndIf
		Next nY
		If lJaProj
			Loop
		EndIf

		oMdlLAC:ClearData()
		oMdlLAC:InitLine()
		If !EMPTY(oMdlLGY:GetValue("LGY_ESCALA"))
			AADD(aAlocLGY, {})
			nAux := LEN(aAlocLGY)
			aAlocLGY[nAux] := GsAloc():New()
			If TecMultFil()
				aAlocLGY[nAux]:defFil(oMdlLGY:GetValue("LGY_FILIAL"))
			EndIf
			aAlocLGY[nAux]:defEscala(oMdlLGY:GetValue("LGY_ESCALA"))
			aAlocLGY[nAux]:defPosto(oMdlLGY:GetValue("LGY_CODTFF"))
			aAlocLGY[nAux]:defTec(oMdlLGY:GetValue("LGY_CODTEC"))
			aAlocLGY[nAux]:defGrupo(oMdlLGY:GetValue("LGY_GRUPO"))
			aAlocLGY[nAux]:defConfal(oMdlLGY:GetValue("LGY_CONFAL"))
			aAlocLGY[nAux]:defDate(oMdlLGY:GetValue("LGY_DTINI"),oMdlLGY:GetValue("LGY_DTFIM"))
			aAlocLGY[nAux]:defSeq(oMdlLGY:GetValue("LGY_SEQ"))
			aAlocLGY[nAux]:defTpAlo(oMdlLGY:GetValue("LGY_TIPTCU"))
			aAlocLGY[nAux]:defCob((oMdlLGY:GetValue("LGY_TIPOAL") == '2'))
			If TecXHasEdH()
				aAlocLGY[nAux]:defGeHor({;
					{oMdlLGY:GetValue("LGY_ENTRA1"),;
					oMdlLGY:GetValue("LGY_SAIDA1")},;
					{oMdlLGY:GetValue("LGY_ENTRA2"),;
					oMdlLGY:GetValue("LGY_SAIDA2")},;
					{oMdlLGY:GetValue("LGY_ENTRA3"),;
					oMdlLGY:GetValue("LGY_SAIDA3")},;
					{oMdlLGY:GetValue("LGY_ENTRA4"),;
					oMdlLGY:GetValue("LGY_SAIDA4")};
					})
			EndIf
			aAlocLGY[nAux]:projAloc()
			If !EMPTY( aAlocLGY[nAux]:defMessage() )
				oMdlLGY:LoadValue("LGY_DETALH", LEFT(aAlocLGY[nAux]:defMessage(), 185))
			EndIf
			If aAlocLGY[nAux]:getConfl()
				oMdlLGY:LoadValue("LGY_STATUS", "BR_PRETO")
			ElseIf aAlocLGY[nAux]:temBloqueio() .OR. aAlocLGY[nAux]:temAviso()
				oMdlLGY:LoadValue("LGY_STATUS", "BR_PINK")
			ElseIf !(aAlocLGY[nAux]:PermAlocarInter())
				oMdlLGY:LoadValue("LGY_STATUS", "BR_CANCEL")
			Else
				oMdlLGY:LoadValue("LGY_STATUS", "BR_AMARELO")
			EndIf

			For nY := 1 To LEN(aAlocLGY[nAux]:getProj())
				If oMdlLAC:GetMaxLines() < LEN(aAlocLGY[nAux]:getProj())
					oMdlLAC:SetMaxLine(LEN(aAlocLGY[nAux]:getProj()))
				EndIf
				If nY != 1
					oMdlLAC:AddLine()
				EndIf

				oMdlLAC:LoadValue("LAC_SITABB", aAlocLGY[nAux]:getProj()[nY][1])
				oMdlLAC:LoadValue("LAC_SITALO", At330ACLgS(aAlocLGY[nAux]:getProj()[nY][11]))
				oMdlLAC:LoadValue("LAC_GRUPO", 	aAlocLGY[nAux]:getProj()[nY][3])
				oMdlLAC:LoadValue("LAC_DATREF", aAlocLGY[nAux]:getProj()[nY][4])
				oMdlLAC:LoadValue("LAC_DATA", 	aAlocLGY[nAux]:getProj()[nY][5])
				oMdlLAC:LoadValue("LAC_SEMANA", aAlocLGY[nAux]:getProj()[nY][6])
				oMdlLAC:LoadValue("LAC_ENTRADA",aAlocLGY[nAux]:getProj()[nY][7])
				oMdlLAC:LoadValue("LAC_SAIDA", 	aAlocLGY[nAux]:getProj()[nY][8])
				oMdlLAC:LoadValue("LAC_TIPO",	aAlocLGY[nAux]:getProj()[nY][11])
				oMdlLAC:LoadValue("LAC_SEQ",	aAlocLGY[nAux]:getProj()[nY][15])
				oMdlLAC:LoadValue("LAC_EXSABB", aAlocLGY[nAux]:getProj()[nY][19])
				oMdlLAC:LoadValue("LAC_KEYTGY",	aAlocLGY[nAux]:getProj()[nY][17])
				oMdlLAC:LoadValue("LAC_ITTGY",	aAlocLGY[nAux]:getProj()[nY][18])
				oMdlLAC:LoadValue("LAC_TURNO",	aAlocLGY[nAux]:getProj()[nY][14])
				oMdlLAC:LoadValue("LAC_ITEM", 	aAlocLGY[nAux]:getProj()[nY][16])
				oMdlLAC:LoadValue("LAC_CODTEC",	aAlocLGY[nAux]:getProj()[nY][9])
				oMdlLAC:LoadValue("LAC_NOMTEC",	aAlocLGY[nAux]:getProj()[nY][10])
				oMdlLAC:LoadValue("LAC_DSCONF", LEFT(aAlocLGY[nAux]:getProj()[nY][23],35))
			Next nY
		EndIf
		If lLoadBar
			oMeter:Set(++nCount)
			oMeter:Refresh()
		EndIf
	Next nX
	If lLoadBar
		oDlg:End()
	EndIf
Return
//------------------------------------------------------------------------------
/*/{Protheus.doc} GravLGY

@description Executa o save das agendas dentro de uma barra de progresso

@author	boiani
@since	05/02/2020
/*/
//------------------------------------------------------------------------------
Static Function GravLGY(oDlg,oMeter)
	Local nX
	Local nY
	Local nCount := 0
	Local nPos := 0
	Local oModel := FwModelActive()
	Local oMdlLGY := oModel:GetModel("LGYDETAIL")
	Local oMdlLAC := oModel:GetModel("LACDETAIL")
	Local lLoadBar := .F.
	Local lPermConfl:= AT680Perm(NIL, __cUserID, "017")
	Local lContinua := .T.
	Local lAlocConf := .F.
	Local nAviso
	Default oDlg := nil
	Default oMeter := nil

	lLoadBar := !isBlind() .AND. oMeter != nil .AND. oDlg != nil

	For nX := 1 To oMdlLGY:Length()
		oMdlLGY:GoLine(nX)
		If oMdlLGY:GetValue("LGY_STATUS") == "BR_PRETO"
			If !lPermConfl
				IF !(lContinua := MsgYesNo(STR0511)) //"Existem dias com conflito de aloca��o e o usu�rio n�o possui permiss�o para aloca��o. Alocar apenas os dias sem conflito? (Esta op��o ser� aplicada em todos os atendentes)"
					Help(,,"NOALOC",,STR0212,1,0)	//"Opera��o de aloca��o cancelada."
				EndIf
				lAlocConf := .F.
			Else
				nAviso := Aviso(STR0187,; //"Aten��o"
				STR0512,; //"Um ou mais dias possuem conflito de aloca��o. Deseja alocar todos os atendentes mesmo com os conflitos ou alocar apenas nos dias dispon�veis? Esta op��o ser� aplicada em todos os atendentes."
				{STR0288,; //"Apenas disponiveis"
				STR0287,; //"Todos os dias"
				STR0338},2) //"Cancelar"
				If nAviso == 3 //Cancelar
					lContinua := .F.
				ElseIf nAviso == 1 //Alocar mesmo com conflito
					lAlocConf := .T.
				ElseIf nAviso == 2 //Alocar apenas dias sem conflitos
					lAlocConf := .F.
				EndIf
			EndIf
			Exit
		EndIf
	Next nX

	If !isBlind()
		For nX := 1 To oMdlLGY:Length()
			oMdlLGY:GoLine(nX)
			If oMdlLGY:GetValue("LGY_STATUS") == "BR_PINK"
				lContinua := MsgYesNo(STR0513) //"Um ou mais atendentes possuem restri��es no per�odo. Deseja continuar?"
				Exit
			EndIf
		Next nX
	EndIf

	If lContinua
		For nX := 1 To oMdlLGY:Length()
			nPos := 0
			oMdlLGY:GoLine(nX)
			For nY := 1 TO Len(aAlocLGY)
				If VALTYPE(aAlocLGY[nY]) == 'O' .AND.;
						aAlocLGY[nY]:defCob() == (oMdlLGY:GetValue("LGY_TIPOAL") == '2') .AND.;
						aAlocLGY[nY]:defEscala() == oMdlLGY:GetValue("LGY_ESCALA") .AND.;
						aAlocLGY[nY]:defPosto() == oMdlLGY:GetValue("LGY_CODTFF") .AND.;
						aAlocLGY[nY]:defSeq() == oMdlLGY:GetValue("LGY_SEQ") .AND.;
						aAlocLGY[nY]:defTec() == oMdlLGY:GetValue("LGY_CODTEC") .AND.;
						aAlocLGY[nY]:defGrupo() == oMdlLGY:GetValue("LGY_GRUPO") .AND.;
						aAlocLGY[nY]:defConfal() == oMdlLGY:GetValue("LGY_CONFAL") .AND.;
						aAlocLGY[nY]:defDate()[1] == oMdlLGY:GetValue("LGY_DTINI") .AND.;
						aAlocLGY[nY]:defDate()[2] == oMdlLGY:GetValue("LGY_DTFIM")
					If TecXHasEdH()
						If aAlocLGY[nY]:defGeHor()[1][1] == oMdlLGY:GetValue("LGY_ENTRA1") .AND.;
								aAlocLGY[nY]:defGeHor()[1][2] == oMdlLGY:GetValue("LGY_SAIDA1") .AND.;
								aAlocLGY[nY]:defGeHor()[2][1] == oMdlLGY:GetValue("LGY_ENTRA2") .AND.;
								aAlocLGY[nY]:defGeHor()[2][2] == oMdlLGY:GetValue("LGY_SAIDA2") .AND.;
								aAlocLGY[nY]:defGeHor()[3][1] == oMdlLGY:GetValue("LGY_ENTRA3") .AND.;
								aAlocLGY[nY]:defGeHor()[3][2] == oMdlLGY:GetValue("LGY_SAIDA3") .AND.;
								aAlocLGY[nY]:defGeHor()[4][1] == oMdlLGY:GetValue("LGY_ENTRA4") .AND.;
								aAlocLGY[nY]:defGeHor()[4][2] == oMdlLGY:GetValue("LGY_SAIDA4")
							nPos := nY
							Exit
						Endif
					Else
						nPos := nY
						Exit
					EndIf
				EndIf
			Next nY
			If nPos > 0
				If !(oMdlLGY:isDeleted())
					aAlocLGY[nPos]:alocaConflitos(lAlocConf)
					If aAlocLGY[nPos]:gravaAloc()
						oMdlLGY:LoadValue("LGY_STATUS","BR_VERDE")
						If !Empty(aAlocLGY[nPos]:getLastSeq())
							oMdlLGY:LoadValue("LGY_SEQ",aAlocLGY[nPos]:getLastSeq())
						EndIf
					Else
						oMdlLGY:LoadValue("LGY_STATUS","BR_LARANJA")
					EndIf
					oMdlLGY:LoadValue("LGY_DETALH",LEFT(aAlocLGY[nPos]:defMessage(), 185))
				EndIf
				oMdlLAC:GoLine(1)
				oMdlLAC:ClearData()
				oMdlLAC:InitLine()
			EndIf
			If lLoadBar
				oMeter:Set(++nCount)
				oMeter:Refresh()
			EndIf
		Next nX

		For nX := 1 To LEN(aAlocLGY)
			If VALTYPE(aAlocLGY[nX]) == 'O'
				aAlocLGY[nX]:destroy()
				aAlocLGY[nX] := nil
			EndIf
		Next nX
		aAlocLGY := {}
	Else
		If !isBlind()
			MsgAlert(STR0514) //"Opera��o cancelada."
		EndIf
	EndIf

	If lLoadBar
		oDlg:End()
	EndIf

Return
//------------------------------------------------------------------------------
/*/{Protheus.doc} remDeleted

@description Remove linhas deletadas de um grid MVC

@author	boiani
@since	20/04/2020
/*/
//------------------------------------------------------------------------------
Static Function remDeleted(oMdlGrid, cTable, oMdlChild, cTbChild)
	Local nX
	Local nY
	Local nZ
	Local nK
	Local aValues := {}
	Local aValChild := {}
	Local aAux := AT190DDef(cTable)
	Local aAuxChild := {}
	Local aResChild := {}
	Local aCpos := {}
	Local aCposChild := {}
	Local lExecuta := .F.

	Default oMdlChild := NIL
	Default cTbChild := ""

	For nX := 1 To oMdlGrid:Length()
		oMdlGrid:GoLine(nX)
		If (lExecuta := oMdlGrid:isDeleted())
			Exit
		EndIf
	Next nX

	If lExecuta
		For nX := 1 To oMdlGrid:Length()
			aCpos := {}
			oMdlGrid:GoLine(nX)
			If !oMdlGrid:isDeleted()
				For nY := 1 TO LEN(aAux)
					AADD(aCpos, { aAux[nY][DEF_IDENTIFICADOR] ,oMdlGrid:GetValue(aAux[nY][DEF_IDENTIFICADOR])})
				Next nY
				If !EMPTY(cTbChild)
					aAuxChild := AT190DDef(cTbChild)
					aValChild := {}
					For nZ := 1 To oMdlChild:Length()
						oMdlChild:GoLine(nZ)
						aCposChild := {}
						For nY := 1 TO LEN(aAuxChild)
							AADD(aCposChild, { aAuxChild[nY][DEF_IDENTIFICADOR] ,oMdlChild:GetValue(aAuxChild[nY][DEF_IDENTIFICADOR]) })
						Next nY
						AADD(aValChild, aCposChild)
					Next nZ
					AADD(aResChild, aValChild)
				EndIF
				AADD(aValues, aCpos)

			ElseIf !Empty(aAlocLGY) .AND. cTable == "LGY"
				For nY := 1 TO LEN(aAlocLGY)
					If VALTYPE(aAlocLGY[nY]) == 'O'
						If aAlocLGY[nY]:defCob() == (oMdlGrid:GetValue("LGY_TIPOAL") == '2') .AND.;
								aAlocLGY[nY]:defEscala() == oMdlGrid:GetValue("LGY_ESCALA") .AND.;
								aAlocLGY[nY]:defPosto() == oMdlGrid:GetValue("LGY_CODTFF") .AND.;
								aAlocLGY[nY]:defSeq() == oMdlGrid:GetValue("LGY_SEQ") .AND.;
								aAlocLGY[nY]:defTec() == oMdlGrid:GetValue("LGY_CODTEC") .AND.;
								aAlocLGY[nY]:defGrupo() == oMdlGrid:GetValue("LGY_GRUPO") .AND.;
								aAlocLGY[nY]:defConfal() == oMdlGrid:GetValue("LGY_CONFAL") .AND.;
								aAlocLGY[nY]:defDate()[1] == oMdlGrid:GetValue("LGY_DTINI") .AND.;
								aAlocLGY[nY]:defDate()[2] == oMdlGrid:GetValue("LGY_DTFIM")
							If TecXHasEdH()
								If aAlocLGY[nY]:defGeHor()[1][1] == oMdlGrid:GetValue("LGY_ENTRA1") .AND.;
										aAlocLGY[nY]:defGeHor()[1][2] == oMdlGrid:GetValue("LGY_SAIDA1") .AND.;
										aAlocLGY[nY]:defGeHor()[2][1] == oMdlGrid:GetValue("LGY_ENTRA2") .AND.;
										aAlocLGY[nY]:defGeHor()[2][2] == oMdlGrid:GetValue("LGY_SAIDA2") .AND.;
										aAlocLGY[nY]:defGeHor()[3][1] == oMdlGrid:GetValue("LGY_ENTRA3") .AND.;
										aAlocLGY[nY]:defGeHor()[3][2] == oMdlGrid:GetValue("LGY_SAIDA3") .AND.;
										aAlocLGY[nY]:defGeHor()[4][1] == oMdlGrid:GetValue("LGY_ENTRA4") .AND.;
										aAlocLGY[nY]:defGeHor()[4][2] == oMdlGrid:GetValue("LGY_SAIDA4")
									aAlocLGY[nY]:deActivate()
								EndIf
							Else
								aAlocLGY[nY]:deActivate()
							EndIf
						EndIf
					EndIf
				Next nY
			EndIf
		Next nX

		oMdlGrid:ClearData()
		oMdlGrid:InitLine()

		For nX := 1 TO LEN(aValues)
			If nX != 1
				oMdlGrid:AddLine()
			EndIf
			For nY := 1 TO LEN(aValues[nX])
				oMdlGrid:LoadValue(aValues[nX][nY][1], aValues[nX][nY][2])
			Next nY
			If !EMPTY(cTbChild)
				For nZ := 1 TO LEN(aResChild[nX])
					If nZ != 1
						oMdlChild:AddLine()
					EndIf
					For nK := 1 To LEN(aResChild[nX][nZ])
						oMdlChild:LoadValue(aResChild[nX][nZ][nK][1], aResChild[nX][nZ][nK][2])
					Next nK
				Next nZ
			EndIf
		Next nX
	EndIf

	oMdlGrid:GoLine(1)

Return
//------------------------------------------------------------------------------
/*/{Protheus.doc} AT190SupAT

@description Chama a fun��o AT190DTSup dentro de um MsgRun
@author	Augusto Albuquerque
@since	07/02/2020
/*/
//------------------------------------------------------------------------------
Static Function AT190SupAT( oView )
	FwMsgRun(Nil,{|u| AT190DTSup( oView )}, Nil, STR0379) // "Montando tela com os atendentes supervisionados."
Return .T.

//------------------------------------------------------------------------------
/*/{Protheus.doc} AT190DTSup

@description Monta a tela de Atendente Supervisonados
@author	Augusto Albuquerque
@since	07/02/2020
/*/
//------------------------------------------------------------------------------
Static Function AT190DTSup( oView )
	Local aFldPai	:= {}
	Local aFolder	:= {}
	Local aCombo	:= {}
	Local aDados	:= {}
	Local aSorting	:= {0, .F.}
	Local aCombo	:= {STR0380} // "Todos os Supervisores"
	Local cDescri	:= "X3_DESCRIC"
	Local cCombo	:= ""
	Local lContinua	:= .T.
	Local nLineBkp	:= 0
	Local oModel	:= FWModelActive()
	Local oMdlLOC	:= oModel:GetModel('LOCDETAIL')
	Local oDlgSelect
	Local oCombo
	Local oExit
	Local oListBox

	Default oView := Nil

	#IFDEF SPANISH
		cDescri	:= "X3_DESCSPA"
	#ELSE
		#IFDEF ENGLISH
			cDescri	:= "X3_DESCENG"
		#ENDIF
	#ENDIF

	If !IsBlind()
		aFldPai := oView:GetFolderActive("TELA_ABAS", 2)
		aFolder := oView:GetFolderActive("ABAS_LOC", 2)
		lContinua := If(aFldPai[1] == 2 .And. aFolder[1] == 1,.T.,.F.)
	EndIf

	If lContinua
		If !oMdlLOC:IsEmpty()
			nLineBkp := oMdlLOC:GetLine()
			aDados := AT190DDSup( @aCombo )

			If Len( aDados ) > 0
				DEFINE MSDIALOG oDlgSelect FROM 0,0 TO 530,1000 PIXEL TITLE STR0381 // "Atendente Supervisonados"

				@ 007, 015 SAY STR0382 SIZE 100, 50 PIXEL // "Nome do Supervisor"

				@ 015, 450 BUTTON STR0383 OF oDlgSelect ACTION (  FwMsgRun(Nil,{|u| ImpCSV( oListBox:aARRAY, STR0381)}, Nil, STR0384) )    SIZE 50,10 PIXEL // "Exporta CSV" ## "Atendente Supervisonados" ## "Exportando CSV"

				oCombo := TComboBox():New(015,015,{|u|if(PCount()>0,cCombo:=u,cCombo), If(PCount()>0,ATRunSup( @oListBox, cCombo ), aCombo[1])},aCombo,100,20,oDlgSelect,,,,,,.T.,,,,,,,,,'cCombo')

				oExit := TButton():New( 245, 470, STR0230,oDlgSelect,{|| oListBox:aARRAY := {}, oDlgSelect:End() }, 30,20,,,.F.,.T.,.F.,,.F.,,,.F. ) // "Sair"

				oListBox := TWBrowse():New(040, 009, 490, 200,,{},,oDlgSelect,,,,,,,,,,,,.F.,,.T.,,.F.,,.T.,.T.)
				oListBox:addColumn(TCColumn():New(	GetSX3Cache( "AA1_CODTEC", cDescri ), &("{|| oListBox:aARRAY[oListBox:nAt,1] }"),,,,,TamSX3("AA1_CODTEC")[1]))
				oListBox:addColumn(TCColumn():New(	GetSX3Cache( "AA1_NOMTEC", cDescri ), &("{|| oListBox:aARRAY[oListBox:nAt,2] }"),,,,,TamSX3("AA1_NOMTEC")[1]))
				oListBox:addColumn(TCColumn():New(	GetSX3Cache( "TDV_DTREF", cDescri ), &("{|| oListBox:aARRAY[oListBox:nAt,3] }"),,,,,15))
				oListBox:addColumn(TCColumn():New(	GetSX3Cache( "ABS_LOCAL", cDescri ), &("{|| oListBox:aARRAY[oListBox:nAt,4] }"),,,,,TamSX3("ABS_LOCAL")[1]))
				oListBox:addColumn(TCColumn():New(	GetSX3Cache( "ABS_DESCRI", cDescri ), &("{|| oListBox:aARRAY[oListBox:nAt,9] }"),,,,,TamSX3("ABS_DESCRI")[1]))
				oListBox:addColumn(TCColumn():New(	STR0385, &("{|| oListBox:aARRAY[oListBox:nAt,5] }"),,,,,TamSX3("AA1_NOMTEC")[1])) // "Nome do Superior"
				oListBox:addColumn(TCColumn():New(	STR0386, &("{|| oListBox:aARRAY[oListBox:nAt,6] }"),,,,,TamSX3("AA1_CODTEC")[1])) // "Codigo do Superior"
				oListBox:addColumn(TCColumn():New(	STR0396, &("{|| oListBox:aARRAY[oListBox:nAt,10] }"),,,,,25)) // "Fim do Supervisor no Local"
				oListBox:addColumn(TCColumn():New(	STR0387, &("{|| oListBox:aARRAY[oListBox:nAt,7] }"),,,,,TamSX3("TFF_COD")[1])) // "Codigo do Posto"
				oListBox:addColumn(TCColumn():New(	GetSX3Cache( "B1_DESC", cDescri ), &("{|| oListBox:aARRAY[oListBox:nAt,8] }"),,,,,180))
				oListBox:SetArray(aDados)
				oListBox:lAutoEdit    := .T.
				oListBox:bHeaderClick := { |a, b| { AT190DClic(oListBox:aARRAY, oListBox, a, b, aSorting, oDlgSelect) }}
				oListBox:Refresh()

				ACTIVATE MSDIALOG oDlgSelect CENTER
			Else
				Help( , , "AT190DTSup", , STR0388, 1, 0,,,,,,{STR0389}) // "N�o foi encontrado nenhum local definido com supervis�o." ## "Por favor acesse a rotina de Supervisor de Posto e fa�a a inclus�o do local de atendimento ao tecnico."
			EndIf
			oMdlLoc:GoLine( nLineBkp )
		Else
			Help( , , "AT190DTSup", , STR0390, 1, 0,,,,,,{STR0391}) // "O grid n�o possui informa��es."## "Por favor revise os parametros e busque agendas para um periodo."
		EndIf
	Else
		Help( , , "AT190DTSup", , STR0392, 1, 0,,,,,,{STR0393}) // "N�o � possivel utilizar a funcionalidade desta tela."
	EndIf
Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} AT190DDSup

@description Faz o preenchimento do array com os dados a serem exibidos na tela
@author	Augusto Albuquerque
@since	07/02/2020
/*/
//------------------------------------------------------------------------------
Static Function AT190DDSup( aCombo )
	Local aPosSer	:= {}
	Local aLocal	:= {}
	Local aRet		:= {}
	Local cAliasTXI	:= GetNextAlias()
	Local cFilPesq	:= ""
	Local cCodTec	:= ""
	Local cCodSup	:= ""
	Local cDatIni	:= ""
	Local cDatFim	:= ""
	Local cDatRef	:= ""
	Local cDatMax	:= DToS(SuperGetMv("MV_CNVIGCP",,cTod("31/12/2049")))
	Local nX
	Local nY
	Local oModel	:= FWModelActive()
	Local oMdlLOC	:= oModel:GetModel('LOCDETAIL')
	Local oMdlPRJ	:= oModel:GetModel("PRJMASTER")

	Default aCombo	:= {}

	cDatIni := DToS( oMdlPRJ:GetValue("PRJ_DTINI") )
	cDatFim := DToS( oMdlPRJ:GetValue("PRJ_DTFIM") )

	For nX := 1 To oMdlLOC:Length()
		oMdlLoc:GoLine(nX)
		If !(cFilPesq $ oMdlLoc:GetValue("LOC_LOCAL") )
			If nX > 1
				cFilPesq += "','"
			EndIf
			cFilPesq += oMdlLoc:GetValue("LOC_LOCAL")
		EndIf
	Next nX
	BEGINSQL ALIAS cAliasTXI
	SELECT TXI.TXI_CODTEC, TXI.TXI_LOCAL, AA1.AA1_SUPERV,
	CASE WHEN TXI.TXI_DTINI = '' THEN %Exp:cDatIni% ELSE TXI.TXI_DTINI END TXI_DTINI,
	CASE WHEN TXI.TXI_DTFIM = '' THEN %Exp:cDatMax% ELSE TXI.TXI_DTFIM END TXI_DTFIM
	FROM %Table:TXI% TXI 
	INNER JOIN %Table:AA1% AA1
		ON AA1.AA1_CODTEC = TXI_CODTEC
	WHERE TXI.TXI_FILIAL = %xFilial:TXI% 
		AND TXI.%NotDel%
		AND TXI.TXI_LOCAL IN ( %Exp:cFilPesq% )
		AND AA1.AA1_FILIAL = %xFilial:AA1%
		AND AA1.%NotDel%
	ENDSQL

	While !( cAliasTXI )->( EOF() )
		If ((cDatIni >= ( cAliasTXI )->TXI_DTINI .AND. cDatIni <= ( cAliasTXI )->TXI_DTFIM ) .OR.;
				cDatIni <= ( cAliasTXI )->TXI_DTINI .AND. cDatFim >= ( cAliasTXI )->TXI_DTINI ) .AND.;
				( cAliasTXI )->AA1_SUPERV == '1'
			AADD( aLocal, { Posicione("AA1",1,xFilial("AA1") + ( cAliasTXI )->TXI_CODTEC ,"AA1_NOMTEC"),;
				( cAliasTXI )->TXI_CODTEC,;
				( cAliasTXI )->TXI_DTINI,;
				( cAliasTXI )->TXI_DTFIM,;
				( cAliasTXI )->TXI_LOCAL})
			AADD( aCombo, Posicione("AA1",1,xFilial("AA1") + ( cAliasTXI )->TXI_CODTEC ,"AA1_NOMTEC"))
		EndIf
		( cAliasTXI )->( DbSkip() )
	EndDo
	( cAliasTXI )->( DbCloseArea() )

	If Len( aLocal ) > 0
		For nX := 1 To oMdlLOC:Length()
			oMdlLoc:GoLine(nX)
			aPosSer	:= PosSuperv( aLocal, oMdlLoc )
			If Len( aPosSer ) > 0
				For nY := 1 To Len( aPosSer )
					lTrocou := Ascan( aRet, { |a| oMdlLoc:GetValue("LOC_CODTEC") == a[1] .AND.;
						aPosSer[nY][2] == a[6] .OR. ( oMdlLoc:GetValue("LOC_LOCAL") == a[4] .AND.;
						oMdlLoc:GetValue("LOC_CODTEC") == a[1] .AND. aPosSer[nY][2] == a[6] ) .AND.;
						oMdlLoc:GetValue("LOC_DTREF") <> a[3] }) == 0
					If lTrocou
						AADD( aRet, {oMdlLoc:GetValue("LOC_CODTEC"),;
							oMdlLoc:GetValue("LOC_NOMTEC"),;
							DToC(oMdlLoc:GetValue("LOC_DTREF")),;
							oMdlLoc:GetValue("LOC_LOCAL"),;
							aPosSer[nY][1],;
							aPosSer[nY][2],;
							oMdlLoc:GetValue("LOC_TFFCOD"),;
							oMdlLoc:GetValue("LOC_B1DESC"),;
							oMdlLoc:GetValue("LOC_ABSDSC"),;
							IF(aPosSer[nY][4] == cDatMax, DToC(SToD("")), DToC(SToD(aPosSer[nY][4])))/*DToC(SToD(aPosSer[nY][4]))*/} )
							cCodTec := oMdlLoc:GetValue("LOC_CODTEC")
							cCodSup	:= aPosSer[nY][2]
						EndIf
					Next nY
				EndIf
			Next nX
		EndIf

		Return aRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} ATRunSup

@description Chama a fun��o AT190DFSup dentro de um MsgRun
@author	Augusto Albuquerque
@since	07/02/2020
/*/
//------------------------------------------------------------------------------
Static Function ATRunSup( oListBox, cCombo )
	FwMsgRun(Nil,{|u| AT190DFSup( @oListBox, cCombo )}, Nil, STR0394) // "Buscando atendentes relacionados ao supervisor!"
Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} AT190DFSup

@description realiza o filtro do supervisor na tela
@author	Augusto Albuquerque
@since	07/02/2020
/*/
//------------------------------------------------------------------------------
Static Function AT190DFSup( oListBox, cCombo )
	Local aRet	:= {}
	Local aAux	:= {}
	Local nX

	If oListBox != NIL
		oListBox:aARRAY := {}
		If cCombo <> STR0380 // "Todos os Supervisores"
			aAux := AT190DDSup()
			For nX := 1 To Len( aAux )
				If cCombo $ aAux[nX][5]
					AADD( aRet, aAux[nX])
				EndIf
			Next nX

			oListBox:aARRAY := aRet
		Else
			oListBox:aARRAY := AT190DDSup()
		EndIf
		oListBox:Refresh()
	EndIf

Return


//------------------------------------------------------------------------------
/*/{Protheus.doc} AT190DClic

@description Organiza a tela pelo clique nas colunas.
@author	Augusto Albuquerque
@since	07/02/2020
/*/
//------------------------------------------------------------------------------
Static Function AT190DClic(aRegs, oListBox, a, b, aSorting, oDlgSelect)

	If aSorting[1] == b .and. aSorting[2]
		aSorting[2] := .F.
		aRegs := aSort(aRegs, 1, Len(aRegs), {|l1, l2| TecNumDow(l1[b]) > TecNumDow(l2[b])})
	Else
		If aSorting[1] != b
			aSorting[1] := b
		EndIf
		aSorting[2] := .T.
		aRegs := aSort(aRegs, 1, Len(aRegs), {|l1, l2| TecNumDow(l1[b]) < TecNumDow(l2[b])})
	EndIf
	oListBox:SetArray(aRegs)
	oListBox:Refresh()

Return .T.

//------------------------------------------------------------------------------
/*/{Protheus.doc} ImpCSV

@description Gerar o .csv
@author	Augusto Albuquerque
@since	07/02/2020
/*/
//------------------------------------------------------------------------------
Static Function ImpCSV( aDados, cArquivo )
	Local cCampos	:= CamposCSV( )
	Local cDados	:= TecImpIt( aDados )
	Local cCSV		:= cCampos + cDados
	Local cNomArq	:= DtoS(dDataBase) + '_' + StrTran(Time(), ':', '') + '_' + cArquivo
	Local cPasta 	:= TecSelPast()
	Local nHandle	:= 0
	Local lRet		:= .F.

	If !Empty(cPasta)

		nHandle := fCreate(cPasta+""+cNomArq+".CSV")

		If nHandle > 0
			FWrite(nHandle, cCsv)
			FClose(nHandle)
			lRet := .T.
			MsgAlert(STR0395) // "Processo Concluido!"
		EndIf
	EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} CamposCSV

@description Adi��o dos cabe�alhos no array para transforma em string
@author	Augusto Albuquerque
@since	07/02/2020
/*/
//------------------------------------------------------------------------------
Static Function CamposCSV()
	Local aCampos	:= {}
	Local cRet		:= ""
	Local cDescri	:= "X3_DESCRIC"

	#IFDEF SPANISH
		cDescri	:= "X3_DESCSPA"
	#ELSE
		#IFDEF ENGLISH
			cDescri	:= "X3_DESCENG"
		#ENDIF
	#ENDIF

	aCampos := { { Nil, GetSX3Cache( "AA1_CODTEC", cDescri ) },;
		{Nil, GetSX3Cache( "AA1_NOMTEC", cDescri ) },;
		{Nil, GetSX3Cache( "TDV_DTREF", cDescri ) },;
		{Nil, GetSX3Cache( "ABS_LOCAL", cDescri )},;
		{Nil, GetSX3Cache( "ABS_DESCRI", cDescri ) },;
		{Nil, STR0385 },; // "Nome do Superior"
	{Nil, STR0386 },; // "Codigo do Superior"
	{Nil, STR0387 },; // "Codigo do Posto"
	{Nil, GetSX3Cache( "B1_DESC", cDescri )} }
	cRet := TecImpCab( aCampos )

Return cRet
//------------------------------------------------------------------------------
/*/{Protheus.doc} PosSuperv

@description Faz o preenchimento do array utilizado na carga da tela
@author	Augusto Albuquerque
@since	07/02/2020
/*/
//------------------------------------------------------------------------------
Static Function PosSuperv( aLocal, oMdlLoc )
	Local aRet	:= {}
	Local nX

	For nX := 1 To Len( aLocal )
		If oMdlLoc:GetValue("LOC_LOCAL") == aLocal[nX][5] .AND.;
				( DToS(oMdlLoc:GetValue("LOC_ABBDTI")) <= aLocal[nX][4] .AND. DToS(oMdlLoc:GetValue("LOC_ABBDTF")) >= aLocal[nX][3] )
			AADD( aRet, aLocal[nX])
		EndIf
	Next nX
Return aRet
//------------------------------------------------------------------------------
/*/{Protheus.doc} at190dELoc

@description Exclui as agendas marcadas na tela
@author	boiani
@since	21/02/2020
/*/
//------------------------------------------------------------------------------
Function at190dELoc(aDados, lExecValid, lPergManut, lApgManut, lAutomato)
	Local oModel := FwModelActive()
	Local oMdlLOC := oModel:GetModel("LOCDETAIL")
	Local oDlg := nil
	Local oSayMtr := nil
	Local oMeter := NIL
	Local aBkpAmarks := ACLONE(aMarks)
	Local aAux := {}
	Local lHasManut := .F.
	Local nX
	Local nAux
	Local nAviso := 0
	Local nMeter := 0
	Local lValid := .T.
	Default lExecValid := .T.
	Default aDados := {}
	Default lPergManut := !(isBlind())
	Default lApgManut := .F.
	Default lAutomato := .F.
	If lExecValid
		lValid := VldDelLOC()
	EndIf

	If EMPTY(aDados)
		For nX := 1 To oMdlLoc:Length()
			oMdlLOC:GoLine(nX)
			If oMdlLOC:GetValue("LOC_MARK")
				AADD(aDados, {oMdlLOC:GetValue("LOC_CODABB"),; 	//[01] - ABB_CODIGO
				oMdlLOC:GetValue("LOC_FILIAL"),;	//[02] - ABB_FILIAL
				oMdlLOC:GetValue("LOC_CODTEC"),;	//[03] - ABB_CODTEC
				oMdlLOC:GetValue("LOC_IDCFAL"),;	//[04] - ABB_IDCFAL
				oMdlLOC:GetValue("LOC_ABBDTI"),;	//[05] - SToD(ABB_DTINI)
				oMdlLOC:GetValue("LOC_HRINI"),;		//[06] - ABB_HRINI
				oMdlLOC:GetValue("LOC_ABBDTF"),;	//[07] - SToD(ABB_DTFIM)
				oMdlLOC:GetValue("LOC_HRFIM"),;		//[08] - ABB_HRFIM
				oMdlLOC:GetValue("LOC_ATENDE"),;	//[09] - ABB_ATENDE
				oMdlLOC:GetValue("LOC_CHEGOU"),;	//[10] - ABB_CHEGOU
				oMdlLOC:GetValue("LOC_DTREF"),;		//[11] - STOD(TDV_DTREF)
				oMdlLOC:GetValue("LOC_RECABB");		//[12] - ABB.R_E_C_N_O_
				})
			EndIf
		Next nX
	EndIf

	If lValid
		For nX := 1 To LEN(aDados)
			If (lHasManut := HasAbr(aDados[nX][1], aDados[nX][2]))
				Exit
			EndIf
		Next nX
		If lHasManut .AND. lPergManut
			nAviso := Aviso(STR0187,;
				STR0467,; //"Um ou mais dias selecionados possuem manuten��es de agenda. Para excluir a agenda com manuten��o (legenda marrom), tamb�m � necess�rio excluir a manuten��o relacionada a agenda. Dentre os itens selecionados, deseja excluir as agendas e manuten��es ou apenas agendas sem manuten��es?"
			{STR0468,STR0469,STR0232},2) //"Agendas e manuten��es" # "Apenas agendas" # "Cancelar"
			lValid := nAviso != 3
			lApgManut := nAviso == 1
		EndIf
		If lValid
			For nX := 1 To LEN(aDados)
				If !lApgManut .AND. lHasManut .AND. HasAbr(aDados[nX][1], aDados[nX][2])
					Loop
				EndIf
				If EMPTY(aAux) .OR. (nAux := ASCAN(aAux,;
						{|s| s[1] == aDados[nX][3] .AND.;
						s[2] == aDados[nX][4] .AND.;
						s[4] == aDados[nX][2]})) == 0
					AADD(aAux, {;
						aDados[nX][3],;
						aDados[nX][4],;
						{{;
						aDados[nX][1],;
						aDados[nX][5],;
						aDados[nX][6],;
						aDados[nX][7],;
						aDados[nX][8],;
						aDados[nX][9],;
						aDados[nX][10],;
						aDados[nX][4],;
						aDados[nX][11],;
						.F.,;
						"",;
						aDados[nX][12];
						}},;
						aDados[nX][2];
						})
				ElseIf nAux > 0
					AADD(aAux[nAux][3], {;
						aDados[nX][1],;
						aDados[nX][5],;
						aDados[nX][6],;
						aDados[nX][7],;
						aDados[nX][8],;
						aDados[nX][9],;
						aDados[nX][10],;
						aDados[nX][4],;
						aDados[nX][11],;
						.F.,;
						"",;
						aDados[nX][12];
						})
				EndIf
			Next nX
			If !Empty(aAux)
				If isBlind() .OR. lAutomato
					ProcDel(aAux,/*oDlg*/,/*oMeter*/,lAutomato)
				Else
					DEFINE MSDIALOG oDlg FROM 0,0 TO 5,60 TITLE STR0305 Style 128 //"Exclus�o de agendas"
					oSayMtr := tSay():New(10,10,{||STR0312},oDlg,,,,,,.T.,,,220,20) //"Processando a remo��o das agendas selecionadas... "
					oMeter  := tMeter():New(20,10,{|u|if(Pcount()>0,nMeter:=u,nMeter)},LEN(aAux),oDlg,220,10,,.T.)

					ACTIVATE MSDIALOG oDlg CENTERED ON INIT (ProcDel(aAux,@oDlg,@oMeter))
				EndIf
				aMarks := ACLONE(aBkpAmarks)
				If !isBlind()
					AT190DLdLo()
					If !EMPTY(oModel:GetValue("AA1MASTER","AA1_CODTEC")) .AND.;
							ASCAN(aAux,{|s| s[1] == oModel:GetValue("AA1MASTER","AA1_CODTEC")}) != 0
						At190DLoad()
					EndIf
				EndIf
			ElseIf !lAutomato
				MsgInfo(STR0470) //"Nenhum registro apagado."
			EndIf
		EndIf
	EndIf

Return .T.
//------------------------------------------------------------------------------
/*/{Protheus.doc} VldDelLOC

@description Valida��o executada antes da exclus�o da agenda
@author	boiani
@since	25/02/2020
/*/
//------------------------------------------------------------------------------
Static Function VldDelLOC()
	Local lRet := .F.
	Local oModel := FwModelActive()
	Local oMdlLOC := oModel:GetModel("LOCDETAIL")
	Local nX

	For nX := 1 To oMdlLOC:Length()
		oMdlLOC:GoLine(nX)
		If ( lRet := oMdlLOC:GetValue("LOC_MARK") )
			Exit
		EndIf
	Next nX

	If !lRet
		Help( " ", 1, "VldDelLOC", Nil, STR0471, 1 ) //"Nenhuma agenda selecionada para exclus�o."
	EndIf

	If lRet .AND. !isBlind()
		If !(lRet := MsgYesNo(STR0472)) //"Confirmar a exclus�o das agendas selecionadas?"
			Help( " ", 1, "VldDelLOC", Nil, STR0299, 1 ) //"Opera��o cancelada."
		EndIf
	EndIf

Return lRet
//------------------------------------------------------------------------------
/*/{Protheus.doc} ProcDel

@description Chama a fun��o de exclus�o dentro de um loadbar para cada atendente / IDCFAL
@author	boiani
@since	25/02/2020
/*/
//------------------------------------------------------------------------------
Static Function ProcDel(aDels,oDlg,oMeter, lAutomato)
	Local nX
	Local nY
	Local lLoadBar
	Local nSucc := 0
	Local nFail := 0
	Local aErrors := {}
	Local aProcs := {}
	Local cFilBkp := cFilAnt
	Local lMV_MultFil := TecMultFil() //Indica se a Mesa considera multiplas filiais
	Default oDlg := nil
	Default oMeter := nil
	Default lAutomato := .F.
	lLoadBar := !lAutomato .AND. !isBlind() .AND. oMeter != nil .AND. oDlg != nil

	For nX := 1 To LEN(aDels)
		aProcs := {}
		For nY := 1 To Len(aDels[nX][3])
			If !(QryEOF("SELECT 1 FROM " + RetSqlName( "ABB" ) +;
					" ABB WHERE ABB.D_E_L_E_T_ = ' ' AND ABB.R_E_C_N_O_ = " +;
					cValToChar(aDels[nX][3][nY][12])))
				AADD(aProcs, aDels[nX][3][nY])
			EndIf
		Next nY
		If !EMPTY(aProcs)
			aMarks := ACLONE(aProcs)
			For nY := 1 To LEN(aMarks)
				aMarks[nY][12] := aDels[nX][4]
			Next nY
			If lMV_MultFil
				cFilAnt := aDels[nX][4]
			EndIf
			At190DDlt(/*lProjRes*/, /*lTrcEft*/, aDels[nX][1],;
				/*cMsg*/, lAutomato, /*cPrimCbo*/,;
				@nSucc, @nFail, @aErrors, (nX == LEN(aDels) .AND. !lAutomato), .F.)
		EndIf
		If lLoadBar
			oMeter:Set(nX)
			oMeter:Refresh()
		EndIf
	Next nX
	If lLoadBar
		oDlg:End()
	EndIf
	cFilAnt := cFilBkp
Return .T.

//------------------------------------------------------------------------------
/*/{Protheus.doc} At190SetFlt

@description Chama a fun��o que cria os filtros nas consultas padr�es
@author	fabiana.silva	
@since	05/03/2020
/*/
//------------------------------------------------------------------------------
Static Function At190SetFlt(aSeek, oBrowse)

	Local aFilter := {}
	Local nC := 0

	For nC := 1 to Len(aSeek)
		If Len(aSeek[nC]) >= 2 .and. Len(aSeek[nC, 02]) == 1 .AND.  Len(aSeek[nC, 02, 01]) >= 7 .and. !Empty(aSeek[nC, 02, 01 ,07])
			If aScan(aFilter, {|f| f[1] == aSeek[nC, 02, 01, 07]}) == 0
				aAdd(aFilter, {aSeek[nC, 02, 01, 07], aSeek[nC, 02,01, 05], aSeek[nC, 02,01, 02], aSeek[nC, 02,01, 03], aSeek[nC, 02,01, 04], IIF(Empty(aSeek[nC, 02,01, 06]), "", aSeek[nC, 02, 01, 06])})
			EndIf
		EndIf
	Next nC


	If Len(aFilter) > 0
		oBrowse:SetTemporary(.T.)
		oBrowse:SetDBFFilter(.T.)
		oBrowse:SetFilterDefault( "" )
		oBrowse:SetUseFilter(.T.)
		oBrowse:SetFieldFilter(aFilter)
	EndIf
Return
//------------------------------------------------------------------------------
/*/{Protheus.doc} At19dVlTFL()

Fun��o de Prevalidacao dos fields de locais (TFL)

@author boiani
@since 17/03/2020
/*/
//------------------------------------------------------------------------------
Function At19dVlTFL(oMdlTFL,cAction,cField,xValue)
	Local lRet := .T.
	Local lMV_MultFil := TecMultFil() //Indica se a Mesa considera multiplas filiais

	If lMV_MultFil
		If VALTYPE(oMdlTFL) == 'O' .AND. oMdlTFL:GetId() == "TFLMASTER"
			If cAction == "SETVALUE"
				If cField == "TFL_FILIAL"
					If !EMPTY(xValue) .AND. !(ExistCpo("SM0", cEmpAnt+xValue)                                                                                          )
						lRet := .F.
						Help( " ", 1, "PRELINTFL", Nil, STR0480, 1 ) //"O campo filial deve ser preenchido com uma filial v�lida"
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

Return lRet
//------------------------------------------------------------------------------
/*/{Protheus.doc} TecMultFil()

Retorna se a mesa deve ser executada em modo Multiplas Filiais

@author boiani
@since 17/03/2020
/*/
//------------------------------------------------------------------------------
Function TecMultFil()
	If EMPTY(cMultFil)
		If SuperGetMV("MV_GSMSFIL",,.F.) .AND. At680Perm(NIL, __cUserId, "043", .T.)
			cMultFil := '1'
		Else
			cMultFil := '2'
		EndIf
	EndIf
Return (cMultFil == '1')
//------------------------------------------------------------------------------
/*/{Protheus.doc} At19dVlLCA()

Valida��o do form LCA

@author boiani
@since 23/03/2020
/*/
//------------------------------------------------------------------------------
Function At19dVlLCA(oMdlLCA,cAction,cField,xValue)
	Local lRet := .T.

	If VALTYPE(oMdlLCA) == 'O' .AND. oMdlLCA:GetId() == "LCAMASTER"
		If cAction == "SETVALUE"
			If cField == "LCA_FILIAL"
				If EMPTY(xValue) .OR. !(ExistCpo("SM0", cEmpAnt+xValue))
					lRet := .F.
					Help( " ", 1, "PRELINLCA", Nil, STR0480, 1 ) //O campo filial deve ser preenchido com uma filial v�lida
				EndIf
			EndIf
		EndIf
	EndIf

Return lRet
//------------------------------------------------------------------------------
/*/{Protheus.doc} HasPJEnSd()

Verifica se alguma tabela de hor�rio possui Hor�rio no conjunto ENTRADA/SAIDA

@author boiani
@since 17/04/2020
/*/
//------------------------------------------------------------------------------
Static Function HasPJEnSd(cField)
	Local lRet := .T.
	Local cSql := ""
	Local cAliasQry

	cSql += " SELECT 1 FROM " + RetSqlName( "SPJ" ) + " SPJ "
	cSql += " WHERE "
	cSql += " ( SPJ.PJ_ENTRA"+cField+" != 0 OR "
	cSql += " SPJ.PJ_SAIDA"+cField+" != 0 ) AND "
	cSql += " SPJ.D_E_L_E_T_ = ' ' "

	cSql := ChangeQuery(cSql)
	cAliasQry := GetNextAlias()
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSql),cAliasQry, .F., .T.)
	lRet := !((cAliasQry)->(Eof()))
	(cAliasQry)->(dbCloseArea())
Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} AT190DDetA

@description Fun��o para grava��o do campo observ

@author	augusto.albuquerque
@since	30/04/2020
/*/
//------------------------------------------------------------------------------
Function AT190DDetA( cAba )
	Local oModel 	:= FwModelActive()
	Local oMdlABB 	:= Nil
	Local oMdlLoc	:= Nil
	Local cCodABB 	:= ""
	Local cMsg		:= ""
	Local lMV_MultFil := TecMultFil() //Indica se a Mesa considera multiplas filiais
	Local cBkpFil := cFilAnt

	If cAba == 'LOC'
		oMdlLoc := oModel:GetModel("LOCDETAIL")
		cCodABB	:= oMdlLoc:GetValue("LOC_CODABB")
		cMsg	:= oMdlLoc:GetValue("LOC_OBSERV")
	Else
		oMdlABB := oModel:GetModel("ABBDETAIL")
		cCodABB	:= oMdlABB:GetValue("ABB_CODIGO")
		cMsg	:= oMdlABB:GetValue("ABB_OBSERV")
	EndIf

	If lMV_MultFil .AND. !Empty(oMdlABB:GetValue("ABB_FILIAL"))
		If cAba == 'LOC'
			cFilAnt := oMdlABB:GetValue("LOC_FILIAL")
		Else
			cFilAnt := oMdlABB:GetValue("ABB_FILIAL")
		EndIf
	EndIf

	If !EMPTY(cCodABB)
		DbSelectArea("ABB")
		DbSetOrder(8)
		If ABB->(MsSeek(xFilial("ABB") + cCodABB ))
			RecLock("ABB",.F.)
			Replace ABB_OBSERV	With AllTrim(cMsg)
			ABB->(MsUnLock())
		EndIf
	EndIf

	cFilAnt := cBkpFil

Return ( .T. )

//------------------------------------------------------------------------------
/*/{Protheus.doc} At190SubLo
@description tela para escolha do substituto em lote
@author	augusto.albuquerque
@since	14/05/2020
/*/
//------------------------------------------------------------------------------
Function At190SubLo()
	Local aAux 			:= {}
	Local aOpc			:= {STR0521, STR0522, STR0523} // "Alterar em todos" ## "Apenas sem cobertura" ## "Cancelar"
	Local cCopyFil 		:= cFiltro550
	Local cQry			:= GetNextAlias()
	Local cCodSub 		:= 	"" + Space(TamSX3("AA1_CODTEC")[1])+ ""
	Local cCodAgen 		:= " IN ("
	Local lRet 			:= .F.
	Local nOpc			:= 1
	Local nTotal		:= 0
	Local oDlgSelect	:= Nil
	Local oDlg			:= Nil
	Local oDataDe		:= Nil
	Local oDataAte		:= Nil
	Local oRefresh		:= Nil
	Local oExit			:= Nil

	DEFINE MSDIALOG oDlgSelect FROM 0,0 TO 100,180 PIXEL TITLE STR0527 // "Substituto"
	@ 5, 9 SAY STR0003 SIZE 50, 19 PIXEL // "Atendente"

	oNameLike := TGet():New( 015, 009, { | u | If(PCount() > 0, cCodSub := u, cCodSub) },oDlgSelect, ;
		080, 010, "!@",{ || !Empty(cCodSub) .AND. ValidaAten(cCodSub)}, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cCodSub",,,,.T.  )
	oNameLike:cF3 := 'T19AA1'

	oExit := TButton():New( 035, 055, STR0230,oDlgSelect,{|| oDlgSelect:End() }, 30,10,,,.F.,.T.,.F.,,.F.,,,.F. ) // "Sair"

	oRefresh := TButton():New( 035, 010, STR0528,oDlgSelect,{|| /*FwMsgRun(Nil,{|| SubstLote( cCodSub )}, Nil, STR0529),*/ lRet := .T., oDlgSelect:End() }, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. ) // "Confirma" ## "Realizando manuten��o"

	ACTIVATE MSDIALOG oDlgSelect CENTER

	If lRet
		If At680Perm(NIL, __cUserId, "038", .T.)
			While "ABR_AGENDA"$ cCopyFil
				AADD(aAux, {SUBSTR(cCopyFil,AT("ABR_AGENDA",cCopyFil)+LEN("ABR_AGENDA='"),TamSX3("ABR_AGENDA")[1]),;
					SUBSTR(cCopyFil,AT("ABR_FILIAL",cCopyFil)+LEN("ABR_FILIAL='"),TamSX3("ABR_FILIAL")[1])})
				cCodAgen += "'" + SUBSTR(cCopyFil,AT("ABR_FILIAL",cCopyFil)+LEN("ABR_FILIAL='"),TamSX3("ABR_FILIAL")[1])
				cCodAgen += SUBSTR(cCopyFil,AT("ABR_AGENDA",cCopyFil)+LEN("ABR_AGENDA='"),TamSX3("ABR_AGENDA")[1]) + "',"
				cCopyFil := SUBSTR(cCopyFil,AT("ABR_FILIAL",cCopyFil)+LEN("ABR_FILIAL=''")+TamSX3("ABR_FILIAL")[1])
			EndDo
			cCodAgen := SubStr(cCodAgen, 1, Len(cCodAgen)-1)
			cCodAgen += " )"
			cCodAgen := "%" + cCodAgen + "%"
			BeginSQL Alias cQry
			SELECT 1 REC
			FROM %Table:ABR% ABR
			WHERE ABR.ABR_FILIAL || ABR.ABR_AGENDA %Exp:cCodAgen%
			AND ABR.%NotDel%
			AND ABR.ABR_CODSUB <> ""
			EndSQL

			If (cQry)->(!Eof())
				nOpc := Aviso(STR0524, STR0525, aOpc, 2) // "Substituto existente" ## "A opera��o de Inclus�o de Substituo em lote localizou uma ou mais manuten��es de agenda com substituto j� informado. Deseja manter o subtituto para estas manuten��es e inserir apenas nas manuten��es sem cobertura ou deseja alterar o substituto de todas as manuten��es?"
			EndIf
			(cQry)->(DbCloseArea())
			nTotal := LEN(aAux)
			If nOpc <> 3 .AND. nTotal > 0
				oDlgSelect := nil
				oSayMtr := nil
				nMeter := 0
				DEFINE MSDIALOG oDlgSelect FROM 0,0 TO 5,60 TITLE STR0530//"Alocando o Atendente"
				oSayMtr := tSay():New(10,10,{||STR0507},oDlgSelect,,,,,,.T.,,,220,20) //"Processando, aguarde..."
				oMeter  := tMeter():New(20,10,{|u|if(Pcount()>0,nMeter:=u,nMeter)},nTotal,oDlgSelect,220,10,,.T.,/*uParam10*/,/*uParam11*/,.T.)
				ACTIVATE MSDIALOG oDlgSelect CENTERED ON INIT (SubstLote( cCodSub, aAux, nOpc, @oDlgSelect, @oMeter))
			Else
				MsgInfo(STR0526) //"Opera��o cancelada!"
			EndIf
		Else
			Help(,1,"At190SubLo",,STR0476, 1) //"Usu�rio sem permiss�o de realizar manuten��o na agenda"
		EndIf
	EndIf
Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} SubstLote
@description Adiciona substituto em lote
@author	augusto.albuquerque
@since	14/05/2020
/*/
//------------------------------------------------------------------------------
Static Function SubstLote( cCodSub, aAux, nOpc, oDlg, oMeter )
	Local aErrors 	:= {}
	Local aErroMVC 	:= {}
	Local cMsg 		:= ""
	Local nFail 	:= 0
	Local nCount 	:= 0
	Local nBarraLoa	:= 0
	Local nX
	Local nY
	Local lRet 		:= .T.
	Local lContinua	:= .T.
	Local oMdlAtv 	:= FwModelActive()
	Local oMdl550 	:= FwLoadModel("TECA550")
	Local cBkpFil 	:= cFilAnt
	Local lMV_MultFil := TecMultFil() //Indica se a Mesa considera multiplas filiais

	Default cCodSub := ""
	Default aAux	:= {}
	Default	nOpc	:= 1
	Default oDlg	:= Nil
	Default oMeter	:= Nil

	For nX := 1 To Len(aAux)
		lContinua := .T.
		ABR->(DbSetOrder(1))
		If lMV_MultFil
			cFilAnt := aAux[nX][2]
		EndIf
		If ABR->(DbSeek(xFilial("ABR") + aAux[nX][1]))
			oMdl550:SetOperation( MODEL_OPERATION_UPDATE )
			nCount++
			If lRet := oMdl550:Activate()

				If nOpc == 1
					lRet := lRet .AND. oMdl550:SetValue("ABRMASTER","ABR_CODSUB", cCodSub )
				Else
					If Empty(ABR->ABR_CODSUB)
						lRet := lRet .AND. oMdl550:SetValue("ABRMASTER","ABR_CODSUB", cCodSub )
					Else
						lContinua := .F.
					EndIf
				EndIf

				If lContinua
					If lRet
						Begin Transaction
							If !oMdl550:VldData() .OR. !oMdl550:CommitData()
								nFail++
								aErroMVC := oMdl550:GetErrorMessage()
								at190err(@aErrors, aErroMVC, ABR->ABR_DTINI)
								DisarmTransacation()
								oMdl550:DeActivate()
							EndIf
						End Transaction
						oMdl550:DeActivate()
					Else
						nFail++
						aErroMVC := oMdl550:GetErrorMessage()
						at190err(@aErrors, aErroMVC, ABR->ABR_DTINI)
						oMdl550:DeActivate()
					EndIf
				Else
					nCount--
					oMdl550:DeActivate()
				EndIf
			Else
				nFail++
				aErroMVC := oMdl550:GetErrorMessage()
				at190err(@aErrors, aErroMVC, ABR->ABR_DTINI)
				oMdl550:DeActivate()
			EndIf
		EndIf
		oMeter:Set(++nBarraLoa)
		oMeter:Refresh()
	Next nX

	If !EMPTY(aErrors)
		cMsg += STR0167 + " " + cValToChar(nCount) + CRLF	//"Total de manuten��es processadas:"
		cMsg += STR0177 + " " + cValToChar(nCount - nFail) + CRLF	//"Total de manuten��es inclu�das:"
		cMsg += STR0178 + " " + cValToChar(nFail) + CRLF + CRLF	//"Total de manuten��es n�o inclu�das:"
		cMsg += STR0179 + CRLF + CRLF	//"As manuten��es abaixo n�o foram inseridas: "
		For nX := 1 To LEN(aErrors)
			For nY := 1 To LEN(aErrors[nX])
				cMsg += If(Empty(aErrors[nX][nY]), aErrors[nX][nY], aErrors[nX][nY] + CRLF )
			Next
			cMsg += CRLF + REPLICATE("-",30) + CRLF
		Next
		cMsg += CRLF + STR0180	//"Por favor, utilize a op��o 'Manut.Relacionadas' para estes registros para mais detalhes do ocorrido."
		If !ISBlind()
			AtShowLog(cMsg,STR0181,/*lVScroll*/,/*lHScroll*/,/*lWrdWrap*/,.F.)	//"Inclus�o das manuten��es"
		EndIf
	Else
		MsgInfo(cValToChar(nCount) + STR0182)	//" registro(s) inclu�dos(s)"
	EndIf

	oDlg:End()
	cFilAnt := cBkpFil
Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} ValidaAten
@description Valida��o do atendente digitado
@author	augusto.albuquerque
@since	14/05/2020
/*/
//------------------------------------------------------------------------------
Static Function ValidaAten( cCodSub )
	Local lRet := .T.
	Local cQry

	cQry := " SELECT 1 "
	cQry += " FROM " + RetSqlName("AA1") + " AA1 "
	cQry += " WHERE AA1.AA1_FILIAL = '" +  xFilial('AA1') + "' AND "
	cQry += " AA1.D_E_L_E_T_ = ' ' "
	cQry += " AND AA1.AA1_CODTEC = '" + cCodSub + "' "

	If (QryEOF(cQry))
		lRet := .F.
	EndIf

Return lRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} At190LgMl
Retorna array com a regra de legenda, utilizado na exporta��o do CSV da aba de multiplas alocacoes
At190LgMl

@author		Diego Bezerra
@since		28/05/2020
@version	P12.1.23
/*/
//------------------------------------------------------------------------------
Static Function At190LgMl(aLegenda)

	Local nLen			:= 0
	Default aLegenda	:= {}
	Default cLegName	:= "LGY_STATUS"

	aAdd( aLegenda, { cLegName, {}} )
	nLen := len(aLegenda)

	aAdd( aLegenda[nLen][2], {"BR_VERMELHO" , STR0438} ) //"N�o processado"
	aAdd( aLegenda[nLen][2], {"BR_AMARELO" , STR0439} )	//"Agenda projetada"
	aAdd( aLegenda[nLen][2], {"BR_VERDE" , STR0440} )	//"Agenda gravada"
	aAdd( aLegenda[nLen][2], {"BR_PRETO" , STR0441} )	//"Conflito de Aloca��o
	aAdd( aLegenda[nLen][2], {"BR_LARANJA" , STR0503} )	//"Falha na aloca��o"
	aAdd( aLegenda[nLen][2], {"BR_CANCEL" , STR0503} )	//"Falha na proje��o"
	aAdd( aLegenda[nLen][2], {"BR_PINK" , STR0505} )	//"Atendente com Restri��o"

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At190dFilt
Retorna a variavel do filtro de browse das manuten��es relacionadas - teca550.
At190dFilt

@author		Kaique Schiller
@since		29/05/2020
/*/
//------------------------------------------------------------------------------
Static Function At190dFilt(aManut)
	Local cRetFilt := ""
	Local cFilABR  := ""
	Local nX	   := 0

	aManut := ASort(aManut,,,{|x,y| x[2]<y[2]})

	For nX := 1 To Len(aManut)

		If cFilABR <> aManut[nX][2]
			If !Empty(cRetFilt)
				cRetFilt += "') .OR. "
			Endif
			cRetFilt += "(ABR_FILIAL='"+xFilial("ABR",aManut[nX][2])+"' .AND. ABR_AGENDA $ '"+aManut[nX][1]
		Else
			cRetFilt += "|"+aManut[nX][1]
		Endif

		If nX == Len(aManut)
			cRetFilt += "')"
		Endif

		cFilABR := aManut[nX][2]

	Next nX

Return cRetFilt

//------------------------------------------------------------------------------
/*/{Protheus.doc} AT190FacD
Realiza a chamada da funcionade de r�plica para data na aba de multiplas aloca��es

@author		Diego Bezerra
@since		26/06/2020
@param oMdlAll	- Modelo da dados Geral

@version	P12.1.23
/*/
//------------------------------------------------------------------------------
Static Function AT190FacD(oMdlAll)

	Local oDlgSelect
	Local oView 	 	:= FwViewActive()
	Local oDataDe
	Local oDataAte
	Local dGetDtDe 		:= Date()
	Local dGetDtAte 	:= Date()
	Local oListBox
	Local aDados		:= {}
	Local oMdlLGY		:= oMdlAll:GetModel("LGYDETAIL")
	Local nX			:= 0
	Local oMarkT    	:= LoadBitmap(GetResources(), "LBOK")
	Local oMarkF     	:= LoadBitmap(GetResources(), "LBNO")
	Local oMkAll
	Local oSair
	Local aSorting   	:= {0, .F.}
	Local oView 	 	:= FwViewActive()
	Local aRet 	 	 	:= {}
	Local lDtIni	 	:= .F.
	Local lDtFim	 	:= .F.

	aRet := AT190FAct(oView)

	If aRet[1][1] == 3
		If oMdlLGY:Length() > 0 .AND. !Empty(oMdlLGY:GetValue("LGY_CODTEC"))
			For nX := 1 to oMdlLGY:Length()
				oMdlLGY:GoLine(nX)
				aAdd(aDados, { 'S',;							//1
				oMdlLGY:GetValue("LGY_CODTEC"),; 	//2
				oMdlLGY:GetValue("LGY_NOMTEC"),; 	//3
				oMdlLGY:GetValue("LGY_DTINI"),; 	//4
				oMdlLGY:GetValue("LGY_DTFIM"),;	//5
				oMdlLGY:GetValue("LGY_CONTRT"),;	//6
				oMdlLGY:GetValue("LGY_CODTFL"),;	//7
				oMdlLGY:GetValue("LGY_CODTFF"),;	//8
				oMdlLGY:GetValue("LGY_SEQ")	,;		//9
				oMdlLGY:GetValue("LGY_GRUPO"),;	//10
				oMdlLGY:GetValue("LGY_CONFAL");	//11
				})
			Next nX

			DEFINE MSDIALOG oDlgSelect FROM 0,0 TO 440,900 PIXEL TITLE STR0587 //"R�plica de valores"
			@ 5, 9 SAY STR0585 SIZE 50, 19 PIXEL //Data de In�cio
			@ 5, 80 SAY STR0584 SIZE 50, 19 PIXEL //Data de T�rmino
			oCheck1 := TCheckBox():New(09,150,STR0582,{|u| if( pcount()==0,lDtIni,lDtIni := u) },oDlgSelect,100,210,,,,,,,,.T.,,,)//'Replicar Data Ini.'
			oCheck2 := TCheckBox():New(09,210,STR0583,{|u| if( pcount()==0,lDtFim,lDtFim := u)},oDlgSelect,100,210,,,,,,,,.T.,,,)//'Replicar Data Fim'
			oDataDe := TGet():New( 015, 009, { | u | If( PCount() == 0, dGetDtDe, dGetDtDe := u ) },oDlgSelect, ;
				060, 010, "@D",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"dGetDtDe",,,,.T.)

			oDataAte := TGet():New( 015, 80, { | u | If( PCount() == 0, dGetDtAte, dGetDtAte := u ) },oDlgSelect, ;
				060, 010, "@D",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"dGetDtAte",,,,.T.)

			oSair := TButton():New( 204, 414, STR0581,oDlgSelect,{|| oListBox:aARRAY := {}, oDlgSelect:End() }, 30,10,,,.F.,.T.,.F.,,.F.,,,.F. ) //Sair
			oListBox := TWBrowse():New(030, 007, 445, 170,,{},,oDlgSelect,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
			oListBox:addColumn(TCColumn():New(	"", &("{|| IIF(oListBox:aARRAY[oListBox:nAt,1] == 'S', oMarkF, oMarkT ) }"),,,,,10,.T.))
			oListBox:addColumn(TCColumn():New(	GetSX3Cache( "ABB_CODTEC", "X3_TITULO" ), &("{|| oListBox:aARRAY[oListBox:nAt,2] }"),,,,,80))
			oListBox:addColumn(TCColumn():New(	GetSX3Cache( "AA1_NOMTEC", "X3_TITULO" ), &("{|| oListBox:aARRAY[oListBox:nAt,3] }"),,,,,100))
			oListBox:addColumn(TCColumn():New(	GetSX3Cache( "ABB_DTINI", "X3_TITULO" ), &("{|| oListBox:aARRAY[oListBox:nAt,4] }"),,,,,30))
			oListBox:addColumn(TCColumn():New(	GetSX3Cache( "ABB_DTFIM", "X3_TITULO" ), &("{|| oListBox:aARRAY[oListBox:nAt,5] }"),,,,,30))
			oListBox:addColumn(TCColumn():New(	GetSX3Cache( "ABQ_CONTRT", "X3_TITULO" ), &("{|| oListBox:aARRAY[oListBox:nAt,6] }"),,,,,30))
			oListBox:SetArray(aDados)
			oListBox:lAutoEdit    := .T.
			oListBox:bHeaderClick := { |a, b| { T190dClick(oListBox:aARRAY, oListBox, a, b, aSorting, oDlgSelect) }}
			oListBox:bLDblClick := { || {IIF(oListBox:aARRAY[oListBox:nAt,1] == 'N', oListBox:aARRAY[oListBox:nAt,1] := 'S', oListBox:aARRAY[oListBox:nAt,1] := 'N')} }
			oListBox:Refresh()

			oMkAll	:= TButton():New( 014, 340, STR0579,oDlgSelect,{|| LGYMkAll(@oListBox)}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )//"Marcar todos"
			oRefresh := TButton():New( 014, 405, STR0580,oDlgSelect,{|| LGYUpdt(oMdlLGY, @oListBox,dGetDtDe,dGetDtAte, oDlgSelect,lDtIni, lDtFim)}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Aplicar"
			ACTIVATE MSDIALOG oDlgSelect CENTER
		Else
			Help(,,STR0575,,STR0576,1,0)//"Sem dados para exibir"//"� necess�rio filtrara dados na se��o atendentes antes de utilizar essa op��o."
		EndIf
	Else
		Help(,,STR0577,,STR0578,1,0)//"Opera��o n�o permitida"//"Op��o dispon�vel apenas para a aba ALOCA��ES EM LOTE"
	EndIf

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} LGYUpdt
Realiza a atualiza��o das informa��es da grid Aloca��es em Lote, via op��o de r�plica
@author		Diego Bezerra
@since		30/06/2020
@param oMdlLGY	- Modelo da dados LGY
@param oListBox - Objet do tipo twbrowse manipulado
@param cDtIni - Nova data inicial que ser� aplicada para as linhas selecionada
@param cDtFim - Nova data final que ser� aplicada para as linhas selecionada
@param oDlgSelect - Caixa de di�logo do tipo MSDIALOG ativa
@param lDtIni - L�gico, Aplica altera��es para a data inicial
@param lDtFim - L�gico, Aplica altera��es para a data final
@version	P12.1.30
/*/
//------------------------------------------------------------------------------
Static function LGYUpdt(oMdlLGY,oListBox, cDtIni, cDtFim, oDlgSelect, lDtIni, lDtFim)

	Local nX
	Local nY
	Local nPos := 0
	Local aAux := oListBox:aArray
	Local lRet := .F.
	Local nAlter	:= 0

	If lDtIni .OR. lDtFim
		If cDtFim >= cDtIni
			lRet := MsgYesNo(STR0588)//"Deseja replicar as novas datas para os atendentes selecionados?"
			If lRet
				For nY := 1 to oMdlLGY:Length()
					oMdlLGY:GoLine(nY)
					For nX := 1 To Len(aAux)
						nPos := aScan(aAux, {|x|										 ;
							x[1] == 'N' 							.AND.;
							x[2] == oMdlLGY:GetValue("LGY_CODTEC") .AND.;
							x[6] == oMdlLGY:GetValue("LGY_CONTRT") .AND.;
							x[7] == oMdlLGY:GetValue("LGY_CODTFL") .AND.;
							x[8] == oMdlLGY:GetValue("LGY_CODTFF") .AND.;
							x[9] == oMdlLGY:GetValue("LGY_SEQ") 	.AND.;
							x[10] == oMdlLGY:GetValue("LGY_GRUPO") .AND.;
							x[11] == oMdlLGY:GetValue("LGY_CONFAL");
							})
						If nPos > 0
							Exit
						EndIf
					Next nX

					If nPos > 0
						nAlter ++
						If lDtIni
							oMdlLGY:SetValue("LGY_DTINI",cDtIni)
						EndIf

						If lDtFim
							oMdlLGY:SetValue("LGY_DTFIM",cDtFim)
						EndIf
					EndIF

				Next nY
				If nAlter > 0
					oDlgSelect:End()
					Help(,,STR0567,,STR0568,1,0)//"Replica concluida"//"Os hor�rios foram replicados com sucesso"
				Else
					Help(,,STR0569,,STR0570,1,0)//"Nenhum registro selecionado"//"Favor selecione algum registro no browse antes de clicar em Aplicar"
				EndIf
			Else
				Help(,,STR0571,,STR0572,1,0)//"Replica cancelada"//"Nenhum valor foi alterado no grid"
			EndIf
		Else
			Help(,,STR0590,,STR0589,1,0) //"Data de T�rmino Inv�lida"//"A Data de T�rmino deve ser maior ou igual a Data de Inicio"
		EndIf
	Else
		Help(,,STR0573,,STR0574 ,1,0)//"Nenhuma op��o selecionada"//"Selecione ao menos uma das op��es dispon�veis (Replicar Data ini., Replicar Data fim)"
	EndIf
Return .T.

//------------------------------------------------------------------------------
/*/{Protheus.doc} LGYMkAll
Realiza a sele��o de todos as linhas de um browse com mark
@author		Diego Bezerra
@since		30/06/2020
@param oListBox - Objet do tipo twbrowse manipulado

@version	P12.1.30
/*/
//------------------------------------------------------------------------------
Static function LGYMkAll(oListBox)

	Local nX
	Local aAux := oListBox:aArray

	For nX := 1 to Len(aAux)
		If aAux[nX][1] == 'S'
			aAux[nX][1] := 'N'
		Else
			aAux[nX][1] := 'S'
		EndIf
	Next nX
	oListBox:SetArray(aAux)
	oListBox:Refresh()
Return .T.


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} T190dClick
@description Faz o sort dos dados ao clicar no cabe�alho da coluna
@author       Diego Bezerra
@since        12/08/2018
@param        aRegs, array, registros presentes no grid
@param        oListBox, obj, objeto TWBrowse
@param        b, int, coluna selecionada
@param        aSorting, array, utilizado para definir se a busca sera a > b ou a < b
@param        oDlgSelect, obj, tela em que o TWBrowse � filho
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function T190dClick(aRegs, oListBox, a, b, aSorting, oDlgSelect)

	If b <> 1
		If aSorting[1] == b .and. aSorting[2]
			aSorting[2] := .F.
			aRegs := aSort(aRegs, 1, Len(aRegs), {|l1, l2| TecNumDow(l1[b]) > TecNumDow(l2[b])})
		Else
			If aSorting[1] != b
				aSorting[1] := b
			EndIf
			aSorting[2] := .T.
			aRegs := aSort(aRegs, 1, Len(aRegs), {|l1, l2| TecNumDow(l1[b]) < TecNumDow(l2[b])})
		EndIf
		oListBox:SetArray(aRegs)
		oListBox:Refresh()
	Else
		LGYMkAll(oListBox)
	EndIf

Return .T.

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} HasCompen
@description Fun��o para retorno da agenda "pai" que originou o dia compensado
@author Augusto Albuquerque
@since  07/07/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function HasCompen( cCodABB )
	Local cQuery 	:= ""
	Local cAliasABB	:= GetNextAlias()
	Local cRet		:= ""

	cQuery := ""
	cQuery += " SELECT ABR.ABR_AGENDA "
	cQuery += " FROM " + RetSqlName("ABR") + " ABR "
	cQuery += " INNER JOIN " + RetSqlName("ABB") + " ABB "
	cQuery += " ON ABB.ABB_FILIAL = '" + xFilial("ABB") + "' "
	cQuery += " AND ABR.ABR_COMPEN = ABB.ABB_CODIGO "
	cQuery += " AND ABB.D_E_L_E_T_ = '' "
	cQuery += " WHERE ABR.ABR_FILIAL = '" + xFilial("ABR") + "' "
	cQuery += " AND ABR.ABR_COMPEN = '" + cCodABB + "' "
	cQuery += " AND ABR.D_E_L_E_T_ = '' "

	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasABB, .F., .T.)

	If !(cAliasABB)->(EOF())
		cRet := (cAliasABB)->ABR_AGENDA
	EndIf

	(cAliasABB)->(DbCloseArea())

Return cRet
//------------------------------------------------------------------------------
/*/{Protheus.doc} At190dGrOrc
Tela de Item Extra Operacional
@author		Kaique Schiller
@since		23/06/2020
/*/
//------------------------------------------------------------------------------
Function At190dGrOrc()
	Local oCampo
	Local oCampo1
	Local oCampo2
	Local oExit
	Local oDlgSelect
	Local oRefresh
	Local lMV_MultFil := TecMultFil() //Indica se a Mesa considera multiplas filiais
	Local cFilBkp 	  := cFilAnt
	Local cFil		  := cFilBkp
	Local lRet		  := .F.
	Local cCodOrc 	  :=  "" + Space(TamSX3("TFJ_CODIGO")[1])+ ""
	Local cLocal 	  :=  "" + Space(TamSX3("TFL_LOCAL")[1])+ ""
	Local oMdl

	If lMV_MultFil
		DEFINE MSDIALOG oDlgSelect FROM 0,0 TO 235,180 PIXEL TITLE STR0552 //"Item Extra Operacional"

		@ 5, 9 SAY STR0553 SIZE 90, 19 PIXEL // "Filial do Sistema"

		oCampo := TGet():New( 015, 009, { | u | If(PCount() > 0, cFil := u, cFil ) },oDlgSelect, ;
			080, 010, "!@",{ || ValidaOrc("FILIAL",cFil) }, 0, 16777215,,.F.,,.T.,,.F.,/*{|| .F. }*/,.F.,.F.,,.F.,.F. ,,"cFil",,,,.T.  )

		oCampo:cF3 := 'SM0'

		@ 35, 9 SAY STR0554 SIZE 90, 19 PIXEL // "C�digo do Or�amento"

		oCampo1 := TGet():New( 045, 009, { | u | If(PCount() > 0, cCodOrc := u, cCodOrc) },oDlgSelect, ;
			080, 010, "!@",{ || ValidaOrc("CODORC",cFil,cCodOrc)}, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cCodOrc",,,,.T.  )

		oCampo1:cF3 := 'T19TFJ'

		@ 65, 9 SAY STR0555 SIZE 90, 19 PIXEL // "C�digo do Local"

		oCampo2 := TGet():New( 075, 009, { | u | If(PCount() > 0, cLocal := u, cLocal)},oDlgSelect, ;
			080, 010, "!@",{ || ValidaOrc("CODLOC",cFil,cCodOrc,cLocal)}, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cLocal",,,,.T.  )

		oCampo2:cF3 := 'T19TFL'

		oExit := TButton():New( 100, 055, STR0556,oDlgSelect,{|| oDlgSelect:End() }, 30,10,,,.F.,.T.,.F.,,.F.,,,.F. ) // "Sair"

		oRefresh := TButton():New( 100, 010, STR0557,oDlgSelect,{|| lRet := .T., oDlgSelect:End() }, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. ) // "Confirma"

		ACTIVATE MSDIALOG oDlgSelect CENTER

	Else
		DEFINE MSDIALOG oDlgSelect FROM 0,0 TO 200,180 PIXEL TITLE STR0552 //"Item Extra Operacional"

		@ 5, 9 SAY STR0554 SIZE 90, 19 PIXEL // "C�digo do Or�amento"

		oCampo1 := TGet():New( 015, 009, { | u | If(PCount() > 0, cCodOrc := u, cCodOrc) },oDlgSelect, ;
			080, 010, "!@",{ || ValidaOrc("CODORC",,cCodOrc)}, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cCodOrc",,,,.T.  )

		oCampo1:cF3 := 'T19TFJ'

		@ 35, 9 SAY STR0555 SIZE 90, 19 PIXEL // "C�digo do Local"

		oCampo2 := TGet():New( 045, 009,  { | u | If(PCount() > 0, cLocal := u, cLocal)},oDlgSelect, ;
			080, 010, "!@",{ || ValidaOrc("CODLOC",,cCodOrc,cLocal) }, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cLocal",,,,.T.  )

		oCampo2:cF3 := 'T19TFL'

		oExit := TButton():New( 080, 055, STR0556,oDlgSelect,{|| oDlgSelect:End() }, 30,10,,,.F.,.T.,.F.,,.F.,,,.F. ) // "Sair"

		oRefresh := TButton():New( 080, 010, STR0557,oDlgSelect,{|| lRet := .T., oDlgSelect:End() }, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. ) // "Confirma"

		ACTIVATE MSDIALOG oDlgSelect CENTER
	Endif

	If lRet
		If !Empty(cCodOrc)
			If !Empty(cLocal)
				cCodLcItEx := cLocal
			Endif
			oMdl := FwModelActive()
			FwMsgRun(Nil,{|| lRet := At870GerOrc(cCodOrc)}, Nil, STR0558) //"Montando or�amento..."
			FwModelActive(oMdl)
		Else
			Help( , , "ValidaOrc", Nil, STR0559, 1, 0,,,,,,{STR0560}) //"C�digo de or�amento est� em branco."#"Execute a rotina novamemte e informe um c�digo de or�amento existente."
			lRet := .F.
		Endif
	Endif

	If lMV_MultFil .And. cFilBkp <> cFilAnt
		cFilAnt := cFilBkp
	Endif

	cCodLcItEx := ""

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} ValidaOrc
Valida��o da tela de Item Extra Operacional
@author		Kaique Schiller
@since		23/06/2020
/*/
//------------------------------------------------------------------------------
Static Function ValidaOrc(cCamp,cFil,cCodOrc,cCodLoc)
	Local lRet := .T.
	Default cFil	:= ""
	Default cCodOrc := ""
	Default cCodLoc := ""

	If cCamp == "FILIAL"
		If !Empty(cFil) .And. FwFilExist(cEmpAnt,cFil)
			If cFil <> cFilAnt
				cFilAnt := cFil
			Endif
		Else
			Help( , , "ValidaOrc", Nil, STR0561, 1, 0,,,,,,{STR0562}) //"Filial n�o existe."#"Informe uma filial existente."
			lRet := .F.
		Endif
	ElseIf cCamp == "CODORC"
		If !Empty(cCodOrc)
			DbSelectArea("TFJ")
			TFJ->(DbSetOrder(1))
			If !TFJ->(DbSeek(xFilial("TFJ")+cCodOrc))
				Help( , , "ValidaOrc", Nil, STR0563, 1, 0,,,,,,{STR0564}) //"C�digo de or�amento n�o existe."#"Informe um c�digo de or�amento existente."
				lRet := .F.
			Endif
		Endif
	ElseIf cCamp == "CODLOC"
		If !Empty(cCodLoc)
			DbSelectArea("TFL")
			TFL->(DbSetOrder(3))
			If !TFL->(DbSeek(xFilial("TFL")+cCodLoc))
				Help( , , "ValidaOrc", Nil, STR0565, 1, 0,,,,,,{STR0566}) //"C�digo de local n�o existe."#"Informe um c�digo de local existente."
				lRet := .F.
			Endif
		Endif
	Endif

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At190dItOp
Pr� condi��es para o Item Extra Operacional 
@author		Kaique Schiller
@since		23/06/2020
/*/
//------------------------------------------------------------------------------
Function At190dItOp()
Return SuperGetMV("MV_GSITEXT",,.F.) .And. TFF->(ColumnPos("TFF_ITEXOP")) > 0

//------------------------------------------------------------------------------
/*/{Protheus.doc} At190dGetLc
Retorna o c�digo do local inserido na tela de item extra operacional
@author		Kaique Schiller
S@since		23/06/2020
/*/
//------------------------------------------------------------------------------
Function At190dGetLc()
Return cCodLcItEx

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} DayAbbComp
@description Fun��o para verifica��o se as abbs do dia foi selecionado certo para exclus�o
@author Augusto Albuquerque
@since  07/07/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function DayAbbComp( dDataRef, lManut, cCodTec )
	Local cQuery	:= ""
	Local cAliasABB	:= GetNextAlias()
	Local lRet		:= .T.

	Default lManut := .F.

	cQuery := ""
	cQuery += " SELECT ABB.ABB_CODIGO "
	cQuery += " FROM " + RetSqlName("ABB") + " ABB "
	cQuery += " INNER JOIN " + RetSqlName("TDV") + " TDV "
	cQuery += " ON TDV.TDV_FILIAL = '" + xFilial("TDV") + "' "
	cQuery += " AND TDV.D_E_L_E_T_ = ' ' "
	cQuery += " AND TDV.TDV_CODABB = ABB.ABB_CODIGO "
	cQuery += " AND TDV.TDV_DTREF = '" + DToS( dDataRef ) + "' "
	If !lManut
		cQuery += " INNER JOIN " + RetSqlName("ABR") + " ABR "
		cQuery += " ON ABR.ABR_FILIAL = '" + xFilial("ABR") + "' "
		cQuery += " AND ABR.D_E_L_E_T_ = ' ' "
		cQuery += " AND ABR.ABR_COMPEN = ABB.ABB_CODIGO "
	EndIf
	cQuery += " WHERE ABB.ABB_FILIAL = '" + xFilial("ABB") + "' "
	cQuery += " AND ABB.ABB_CODTEC = '" + cCodTec + "' "
	cQuery += " AND ABB.D_E_L_E_T_ = ' ' "

	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasABB, .F., .T.)

	While !(cAliasABB)->(EOF())
		If ASCAN(aMarks, {|a| !EMPTY(a[1]) .AND. a[1] == (cAliasABB)->ABB_CODIGO }) == 0
			lRet := .F.
			Exit
		EndIf
		(cAliasABB)->(dbSkip())
	EndDo

	(cAliasABB)->(dbCloseArea())

Return lRet
