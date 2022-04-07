#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#include "topconn.ch"

/*/
Função    : RAPRCTG1
Descrição : Aprovação de Contigência em Lote
Autora    : Alana Oliveira
Data      : 18/02/2022
/*/

User Function RAPRCTG1()
    //Declarar variáveis locais
    Local aCampos	:= {}
    Local cIndice1, cIndice2, cIndice3,cIndice4 := ""
    Local lMarcar  	:= .F.
    Local aSeek   := {}
  //  Local bKeyF12	:= {||  U_MCFG006M(),oBrowse:SetInvert(.F.),oBrowse:Refresh(),oBrowse:GoTop(.T.) } //Programar a tecla F12
    Local aSaveArea := GetArea()  

    //Declarar variáveis privadas
    Private oBrowse 	:= Nil
    Private aRotina		:= MenuDef()
    Private cCadastro 	:= "Aprovação de Contigência em Lote"
    Private cAlias      := "TRBCTG"
    Private cAliasTmp   := "TRBCTG"
    Private cArqTRBCTG 

    //Criar a tabela temporária
    AAdd(aCampos,{"TR_OK"  	  ,"C",002,0}) //Este campo será usado para marcar/desmarcar
    AAdd(aCampos,{"TR_FILIAL" ,"C",006,0}) 
    AAdd(aCampos,{"TR_CDCNTG" ,"C",005,0})
    AAdd(aCampos,{"TR_NOMSOL" ,"C",025,0})
    AAdd(aCampos,{"TR_DTSOLI" ,"D",008,0})
    AAdd(aCampos,{"TR_CLASSE" ,"C",006,0})
    AAdd(aCampos,{"TR_DESCCO" ,"C",060,0})
    AAdd(aCampos,{"TR_CO"     ,"C",012,0})
    AAdd(aCampos,{"TR_DESCCA" ,"C",060,0})
    AAdd(aCampos,{"TR_VALOR1" ,"N",012,2})
    AAdd(aCampos,{"TR_EMPVAL" ,"N",012,2})
    AAdd(aCampos,{"TR_STATUS" ,"C",002,2})
    AAdd(aCampos,{"TR_REC"    ,"N",012,0})
 
    //Se o alias estiver aberto, fechar para evitar erros com alias aberto
    If (Select("TRBCTG") > 0)
        dbSelectArea("TRBCTG")
        TRBCTG->(dbCloseArea())
    Endif
 
    //A função CriaTrab() retorna o nome de um arquivo de trabalho que ainda não existe e dependendo dos parâmetros passados, pode criar um novo arquivo de trabalho.
    cArqTRBCTG := CriaTrab(aCampos,.T.)
    
    //Criar indices
    cIndice1 := Alltrim(CriaTrab(,.F.))
    cIndice2 := cIndice1
    cIndice3 := cIndice1
    cIndice4 := cIndice1
    
    cIndice1 := Left(cIndice1,5) + Right(cIndice1,2) + "A"
    cIndice2 := Left(cIndice2,5) + Right(cIndice2,2) + "B"
    cIndice3 := Left(cIndice3,5) + Right(cIndice3,2) + "C"
    cIndice4 := Left(cIndice4,5) + Right(cIndice4,2) + "D"
    
    //Se indice existir excluir
    If File(cIndice1+OrdBagExt())
        FErase(cIndice1+OrdBagExt())
    EndIf
    If File(cIndice2+OrdBagExt())
        FErase(cIndice2+OrdBagExt())
    EndIf
    If File(cIndice3+OrdBagExt())
        FErase(cIndice3+OrdBagExt())
    EndIf
    If File(cIndice4+OrdBagExt())
        FErase(cIndice4+OrdBagExt())
    EndIf
    
    //A função dbUseArea abre uma tabela de dados na área de trabalho atual ou na primeira área de trabalho disponível
    dbUseArea(.T.,,cArqTRBCTG,"TRBCTG",Nil,.F.)
 
    //A função IndRegua cria um índice temporário para o alias especificado, podendo ou não ter um filtro
    IndRegua("TRBCTG", cIndice1, "TR_CDCNTG",,, "Indice Cod. Contingencia...")
    IndRegua("TRBCTG", cIndice2, "TR_DTSOLI",,, "Indice Data Solicitação...")
    IndRegua("TRBCTG", cIndice3, "TR_CLASSE",,, "Indice Classe...")
    IndRegua("TRBCTG", cIndice4, "TR_CO"	,,, "Indice Conta...")
    
    //Fecha todos os índices da área de trabalho corrente.
    dbClearIndex()
 
    //Acrescenta uma ou mais ordens de determinado índice de ordens ativas da área de trabalho.
    dbSetIndex(cIndice1+OrdBagExt())
    dbSetIndex(cIndice2+OrdBagExt())
    dbSetIndex(cIndice3+OrdBagExt())
    dbSetIndex(cIndice4+OrdBagExt())

    cQry:= " SELECT ALI_CDCNTG,
    cQry+= "        ALI_NOMSOL,
    cQry+= "        ALI_DTSOLI,
    cQry+= "        ALJ_CLASSE,
    cQry+= "        AK6_DESCRI,  
    cQry+= "        ALJ_CO,
    cQry+= "        AK5_DESCRI,
    cQry+= "        ALJ_VALOR1,
    cQry+= "        ALJ_EMPVAL,
    cQry+= "        ALI_STATUS,
    cQry+= "        ALI.R_E_C_N_O_ AS RECALI
    cQry+= " FROM "+RetSqlName("ALI")+" ALI
    cQry+= " JOIN "+RetSqlName("ALJ")+" ALJ ON (ALI_LOTEID = ALJ_LOTEID
    cQry+= "                     AND ALI_CDCNTG = ALJ_CDCNTG
    cQry+= "                     AND ALJ.D_E_L_E_T_ = '')
    cQry+= " JOIN "+RetSqlName("AK5")+" AK5 ON (AK5_CODIGO = ALJ_CO
    cQry+= "                     AND AK5.D_E_L_E_T_ = '')
    cQry+= " JOIN "+RetSqlName("AK6")+" AK6 ON (AK6_CODIGO = ALJ_CLASSE
    cQry+= "                     AND AK6.D_E_L_E_T_ = '')
    cQry+= " WHERE ALI.D_E_L_E_T_ = ''
    cQry+= " AND ALI_STATUS <> '03'
    cQry+= " AND ALI_STATUS <> '04'
    cQry+= " AND ALI_STATUS <> '05'
    cQry+= " AND ALI_STATUS <> '06'
    cQry+= " AND ALI_USER = '"+__cUserId+"'

    IF SELECT("TRBRA") >0
	    TRBRA->(DBCLOSEAREA())
    ENDIF

    TCQUERY cQry NEW ALIAS "TRBRA"

    If TRBRA->(EOF())

        Alert("Não existem contigências em aberto")

    Endif

    While !TRBRA->(EOF()) // Se existir contigência em aberto
    
        //Popular tabela temporária
        If RecLock("TRBCTG",.T.)
 
            TRBCTG->TR_OK    := "  "
            TRBCTG->TR_FILIAL:= cFilAnt
            TRBCTG->TR_CDCNTG:= TRBRA->ALI_CDCNTG
            TRBCTG->TR_NOMSOL:= TRBRA->ALI_NOMSOL
            TRBCTG->TR_DTSOLI:= stod(TRBRA->ALI_DTSOLI)
            TRBCTG->TR_CLASSE:= TRBRA->ALJ_CLASSE
            TRBCTG->TR_DESCCO:= TRBRA->AK6_DESCRI
            TRBCTG->TR_CO    := TRBRA->ALJ_CO
            TRBCTG->TR_DESCCA:= TRBRA->AK5_DESCRI
            TRBCTG->TR_VALOR1:= TRBRA->ALJ_VALOR1
            TRBCTG->TR_EMPVAL:= TRBRA->ALJ_EMPVAL
            TRBCTG->TR_STATUS:= TRBRA->ALI_STATUS
            TRBCTG->TR_REC   := TRBRA->RECALI

            MsUnLock()
        Endif
    
        TRBCTG->(DbGoTop())
    
        If TRBCTG->(!Eof())
            //Pesquisa que será apresentada na tela
            aAdd(aSeek,{"Contingência"	,{{"","C",005,0,"Contingência"	,"@!"}} } )
            aAdd(aSeek,{"Data Solicitação"	,{{"","D",008,0,"Data Solicitação"	,""}} } )
            aAdd(aSeek,{"Clase",{{"","C",006,0,"Classe","@!"}} } )
            aAdd(aSeek,{"C.O."	,{{"","C",012,0,"C.O."	,"@!"}} } )
        
            //Classe FWMarkBrowse
            oBrowse:= FWMarkBrowse():New()
            oBrowse:SetDescription(cCadastro) //Titulo da Janela
            //oBrowse:SetParam(bKeyF12) // Seta tecla F12
            oBrowse:SetAlias("TRBCTG") //Indica o alias da tabela que será utilizada no Browse
            oBrowse:SetFieldMark("TR_OK") //Indica o campo que deverá ser atualizado com a marca no registro
            oBrowse:oBrowse:SetDBFFilter(.T.)
            oBrowse:oBrowse:SetUseFilter(.T.) //Habilita a utilização do filtro no Browse
            oBrowse:oBrowse:SetFixedBrowse(.T.)
            oBrowse:SetWalkThru(.F.) //Habilita a utilização da funcionalidade Walk-Thru no Browse
            oBrowse:SetAmbiente(.T.) //Habilita a utilização da funcionalidade Ambiente no Browse
            oBrowse:SetTemporary() //Indica que o Browse utiliza tabela temporária
            oBrowse:oBrowse:SetSeek(.T.,aSeek) //Habilita a utilização da pesquisa de registros no Browse
            oBrowse:oBrowse:SetFilterDefault("") //Indica o filtro padrão do Browse
        
            //Permite adicionar legendas no Browse
            oBrowse:AddLegend("TR_STATUS=='01'","BR_AZUL" 	,"Bloqueado p/ sistema (aguardando outros niveis)")
            oBrowse:AddLegend("TR_STATUS=='02'","DISABLE"   ,"Aguardando Liberacao do usuario")
            oBrowse:AddLegend("TR_STATUS=='03'","ENABLE"    ,"Liberado pelo usuario")
            oBrowse:AddLegend("TR_STATUS=='04'","BR_PRETO"  ,"Cancelado")
            oBrowse:AddLegend("TR_STATUS=='05'","BR_LARANJA","Liberado por outro usuario")
            oBrowse:AddLegend("TR_STATUS=='06'","BR_CINZA"  ,"Cancelado por outro usuario")

            //Adiciona uma coluna no Browse em tempo de execução
            oBrowse:SetColumns(MontaColunas("TR_CDCNTG","Cod. Cont."  ,01,"@!",1,005,0))
            oBrowse:SetColumns(MontaColunas("TR_NOMSOL","Solicitante" ,02,"@!",1,025,0))
            oBrowse:SetColumns(MontaColunas("TR_DTSOLI","Dt. Solic."  ,03,""  ,1,008,0))
            oBrowse:SetColumns(MontaColunas("TR_CLASSE","Classe"	  ,04,"@!",1,006,0))
            oBrowse:SetColumns(MontaColunas("TR_DESCCA","Desc. Classe",05,"@!",1,060,0))
            oBrowse:SetColumns(MontaColunas("TR_CO"    ,"C.O."	      ,06,"@!",1,012,0))
            oBrowse:SetColumns(MontaColunas("TR_DESCCO","Desc. C.O."  ,07,"@!",1,060,0))
            oBrowse:SetColumns(MontaColunas("TR_VALOR1","Vlr.Lancto." ,08,"@E 999,999,999.99",2,012,2))
            oBrowse:SetColumns(MontaColunas("TR_EMPVAL","Vlr.Empenhad",09,"@R 999,999,999.99",2,012,2))

            //Indica o Code-Block executado no clique do header da coluna de marca/desmarca
           // oBrowse:bAllMark := { || MCFG6Invert(oBrowse:Mark(),lMarcar := !lMarcar ), oBrowse:Refresh(.T.)  }
 
            //Método de ativação da classe
            oBrowse:Activate()
        
            oBrowse:oBrowse:Setfocus() //Seta o foco na grade
        Else
            Return
        EndIf
    
        TRBRA->(DBSKIP())
    Enddo

    TRBRA->(DBCLOSEAREA())

    //Limpar o arquivo temporário
    If !Empty(cArqTRBCTG)
        Ferase(cArqTRBCTG+GetDBExtension())
        Ferase(cArqTRBCTG+OrdBagExt())
        cArqTRBCTG := ""
        TRBCTG->(DbCloseArea())
    Endif

    RestArea(aSaveArea) 

Return(.T.)

Static Function MontaColunas(cCampo,cTitulo,nArrData,cPicture,nAlign,nSize,nDecimal)
	Local aColumn
	Local bData 	:= {||}
	Default nAlign 	:= 1
	Default nSize 	:= 20
	Default nDecimal:= 0
	Default nArrData:= 0
	
	If nArrData > 0
		bData := &("{||" + cCampo +"}") //&("{||oBrowse:DataArray[oBrowse:At(),"+STR(nArrData)+"]}")
	EndIf
	
	/* Array da coluna
	[n][01] Título da coluna
	[n][02] Code-Block de carga dos dados
	[n][03] Tipo de dados
	[n][04] Máscara
	[n][05] Alinhamento (0=Centralizado, 1=Esquerda ou 2=Direita)
	[n][06] Tamanho
	[n][07] Decimal
	[n][08] Indica se permite a edição
	[n][09] Code-Block de validação da coluna após a edição
	[n][10] Indica se exibe imagem
	[n][11] Code-Block de execução do duplo clique
	[n][12] Variável a ser utilizada na edição (ReadVar)
	[n][13] Code-Block de execução do clique no header
	[n][14] Indica se a coluna está deletada
	[n][15] Indica se a coluna será exibida nos detalhes do Browse
	[n][16] Opções de carga dos dados (Ex: 1=Sim, 2=Não)
	*/
	aColumn := {cTitulo,bData,,cPicture,nAlign,nSize,nDecimal,.F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,{}}

Return {aColumn}

/*/{Protheus.doc} RAPRCTG3
    Aprovação de Contingência em Lote
    @type  Function
    @author Alana Oliveira
    @since 21/02/2022
/*/
User Function RAPRCTG3

    Local aArea  := getArea()

	If TRBCTG->(Eof())
		//TRBCTG->(dbCloseArea())
		MsgAlert("Não há itens selecionados", "Atenção!")	
		Return
	Endif

	While TRBCTG->(!Eof())

        If !Empty(TRBCTG->TR_OK)
		    ALI->(dbGoto(TRBCTG->TR_REC))
            nRecnoALI:= TRBCTG->TR_REC
            lAuto:= .T.
            Processa({|| u_YLIBCTG1('ALI',nRecnoALI,2,,,lAuto)}, "Aprovando a contingência: " + ALI->ALI_CDCNTG)  // Libera contingencia selecionada  
            //PCOA500LIB(cAlias,nRecnoALI,nCallOpcx,cR1,cR2,lAuto)  // Libera contingencia selecionada  
		Endif
        TRBCTG->(dbSkip())

	Enddo

	//TRBCTG->(dbCloseArea())

	RestArea(aArea)

Return 


/*/{Protheus.doc} RAPRCTG4
    Cancelamento de Contingência em Lote
    @type  Function
    @author Alana Oliveira
    @since 21/02/2022
/*/
User Function RAPRCTG4

    Local aArea  := getArea()

    dbselectarea("TRBCTG")
    TRBCTG->(DBGOTOp())

	If TRBCTG->(Eof())
		//TRBCTG->(dbCloseArea())
		MsgAlert("Não há itens selecionados", "Atenção!")	
		Return
	Endif

	While TRBCTG->(!Eof())

        If !Empty(TRBCTG->TR_OK)
		    ALI->(dbGoto(TRBCTG->TR_REC))
            nRecnoALI:= TRBCTG->TR_REC
           // lAuto:= .T.
            //Processa({|| PCOA500BLQ('ALI',nRecnoALI,4,,,lAuto)}, "Cancelando a contingência: " + ALI->ALI_CDCNTG)  // Cancela contingencia selecionada  
            //PCOA500BLQ(cAlias,nRecnoALI,nCallOpcx,cR1,cR2,lAuto) // Cancela contingencia selecionada 
        
            If ALI->ALI_STATUS $ "03/05"
	            Aviso("Atencao" , "Solicitação de contingencia ja liberada!" ,{"Ok"}) //"Atencao"###"Solicitação de contingencia ja liberada!"
            ElseIf ALI->ALI_STATUS $ "04/06"
	            Aviso("Atencao", "Solicitação de contingencia cancelada!", {"Ok"}) //"Atencao"###"Solicitação de contingencia cancelada!"
            Else
    	        dbSelectArea("ALI")
		   		dbGoto(nRecnoALI)
		        PCOA530ALC(6)

                //  RECLOCK("TRBCTG", .F.)

                //      TRBCTG->TR_STATUS := "04"

                // TRBCTG->(MSUNLOCK())     // It unlocks the record.
		
		        //P_EÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		        //P_E³ Ponto de entrada utilizado para inclusao de funcoes de usuarios na     ³
		        //P_E³ preparacao da contingencia para Solicitação de Compras Customizado     ³
		        //P_E³ Implementado para satisfazer o GAP087, na data de 24/02/2012           ³
		        //P_EÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		        If ExistBlock( "PC500BLQ" )
			        ExecBlock( "PC500BLQ", .F., .F.)
		        EndIf
            Endif
	    EndIf

        TRBCTG->(dbSkip())
	Enddo

	//TRBCTG->(dbCloseArea())

	RestArea(aArea)

Return 

Static Function MenuDef()

	Local aArea		:= GetArea()
	Local aRotina 	:= {}

    ADD OPTION aRotina TITLE 'Visualizar' ACTION 'U_RTELCTG()' OPERATION 2 ACCESS 0
    ADD OPTION aRotina TITLE 'Liberar'  ACTION 'U_RAPRCTG3()' OPERATION 2 ACCESS 0
    ADD OPTION aRotina TITLE 'Cancelar' ACTION 'U_RAPRCTG4()' OPERATION 6 ACCESS 0

    RestArea(aArea)

Return( aRotina )

#Include "PROTHEUS.CH"
//--------------------------------------------------------------
/*/{Protheus.doc} MyFunction
Description

@param xParam Parameter Description
@return xRet Return Description
@author  Alana Oliveira
@since 21/02/2022
/*/
//--------------------------------------------------------------
User Function RTELCTG()

Local oGroup1
Local oSay1,oSay2,oSay3,oSay4,oSay5,oSay6,oSay7,oSay8

Static oDlg
dDtIni := FirstYDate(TRBCTG->TR_DTSOLI)
dDtFim := LastDate(TRBCTG->TR_DTSOLI)
aVlPrv := xVlDisp(TRBCTG->TR_CO+TRBCTG->TR_CLASSE,dDtIni,dDtFim)
nVlPrv := aVlPrv[1]
nVlRe  := aVlPrv[2]

  DEFINE MSDIALOG oDlg TITLE "Contingência" FROM 000, 000  TO 500, 500 COLORS 0, 16777215 PIXEL

    @ 028, 007 GROUP oGroup1 TO 209, 234 PROMPT "Detalhes" OF oDlg COLOR 0, 16777215 PIXEL

    @ 036, 011 SAY oSay1 PROMPT "Contingência "+alltrim(TRBCTG->TR_CDCNTG) SIZE 080, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 046, 011 SAY oSay2 PROMPT "Data Solicitação "+dtoc(TRBCTG->TR_DTSOLI) SIZE 080, 007 OF oGroup1 COLORS 0, 16777215 PIXEL
    @ 056, 011 SAY oSay3 PROMPT "Solicitante "+alltrim(TRBCTG->TR_NOMSOL) SIZE 080, 007 OF oGroup1 COLORS 0, 16777215 PIXEL
    @ 066, 011 SAY oSay4 PROMPT "C.O. "+alltrim(TRBCTG->TR_CO)+'-'+alltrim(TRBCTG->TR_DESCCO) SIZE 100, 007 OF oGroup1 COLORS 0, 16777215 PIXEL
    @ 076, 011 SAY oSay5 PROMPT "Classe "+alltrim(TRBCTG->TR_CLASSE)+'-'+alltrim(TRBCTG->TR_DESCCA) SIZE 100, 007 OF oGroup1 COLORS 0, 16777215 PIXEL
    @ 086, 011 SAY oSay6 PROMPT "Valor Total Orçado Inicial R$ "+alltrim(TRANSFORM(nVlPrv,"@E 999,999.999.99"))SIZE 100, 007 OF oGroup1 COLORS 0, 16777215 PIXEL
    @ 096, 011 SAY oSay7 PROMPT "Valor Total Realizado R$ "+alltrim(TRANSFORM(nVlRe,"@E 999,999.999.99")) SIZE 100, 007 OF oGroup1 COLORS 0, 16777215 PIXEL
    @ 106, 011 SAY oSay8 PROMPT "Valor Total do Pedido R$ "+alltrim(TRANSFORM(TRBCTG->TR_VALOR1+TRBCTG->TR_EMPVAL,"@E 999,999.999.99")) SIZE 100, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 116, 011 SAY oSay8 PROMPT "Valor para Aprovação R$ "+alltrim(TRANSFORM(TRBCTG->TR_VALOR1,"@E 999,999.999.99")) SIZE 100, 007 OF oDlg COLORS 0, 16777215 PIXEL

  ACTIVATE MSDIALOG oDlg CENTERED
    
Return

Static Function xVlDisp(cChaveR,dDtAnt,aDtFim)


/* Retorna o saldo do cubo da chave informada em uma determinada data */ 

//Tipo de Saldo: 'RE' - Realizado
aSldREIni:= PCORETSLD("02",cChaveR+"RE",dDtAnt)
aSldREFim:= PCORETSLD("02",cChaveR+"RE",aDtFim)

aSldREALA:= U_YSLDALA("02",cChaveR+"RE",dDtAnt,aDtFim) // Tabela ALA

//Tipo de Saldo: 'EM' - Empenhado
aSldEMIni:= PCORETSLD("02",cChaveR+"EM",dDtAnt)
aSldEMFim:= PCORETSLD("02",cChaveR+"EM",aDtFim)

aSldEMALA:= U_YSLDALA("02",cChaveR+"EM",dDtAnt,aDtFim) // Tabela ALA

//Tipo de Saldo: 'OR' - Orçado
aSldORIni:= PCORETSLD("02",cChaveR+"0R",dDtAnt)
aSldORFim:= PCORETSLD("02",cChaveR+"0R",aDtFim)

aSldORALA:= U_YSLDALA("02",cChaveR+"0R",dDtAnt,aDtFim) // Tabela ALA

//Tipo de Saldo: '0I' - Orçado Inicial
aSldOIIni:= PCORETSLD("02",cChaveR+"0I",dDtAnt)
aSldOIFim:= PCORETSLD("02",cChaveR+"0I",aDtFim)

//Tipo de Saldo: 'CT' - Contingência
aSldCTIni:= PCORETSLD("02",cChaveR+"CT",dDtAnt)
aSldCTFim:= PCORETSLD("02",cChaveR+"CT",aDtFim)

aSldCTALA:= U_YSLDALA("02",cChaveR+"CT",dDtAnt,aDtFim) // Tabela ALA

nValReal := ((aSldREFim[1,1]-aSldREFim[2,1])  -  (aSldREIni[1,1]-aSldREIni[2,1])) + ((aSldEMFim[1,1]-aSldEMFim[2,1])  -  (aSldEMIni[1,1]-aSldEMIni[2,1]))
nValReal += (aSldREALA[1]-aSldREALA[2]) + (aSldEMALA[1]-aSldEMALA[2]) // Realizado + Empenhado tabela ALA 

nValPrv  := (aSldORALA[1]-aSldORALA[2]) + (aSldCTALA[1]+aSldCTALA[2]) // Orçado + Contigência tabela ALA


nVlPrIni:= ((aSldORFim[1,1]-aSldORFim[2,1])  -  (aSldORIni[1,1]-aSldORIni[2,1])) 
If nVlPrIni == 0
    nVlPrIni+= ((aSldOIFim[1,1]-aSldOIFim[2,1])  -  (aSldOIIni[1,1]-aSldOIIni[2,1]))
Endif    
nValPrv := nValPrv + nVlPrIni + ((aSldCTFim[1,1]-aSldCTFim[2,1])  -  (aSldCTIni[1,1]-aSldCTIni[2,1]))

cDisp  := Alltrim(STR(nValPrv - (nValReal),17,2))
cDIf   := Alltrim(STR(abs((nValPrv - (nValReal))),17,2))
    
Return {nVlPrIni,nValReal}

 /*/{Protheus.doc} YLIBCTG1
    (long_description)
    @type  Function
    @author Alana Oliveira
    @since 18/03/2022
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
User Function YLIBCTG1(cAlias,nRecnoALI,nCallOpcx,cR1,cR2,lAuto)

If ALI->ALI_STATUS $ "03/05"
	Aviso("Atencao", "Solicitação de contingencia ja liberada!",{"Ok"}) //"Atencao"###"Solicitação de contingencia ja liberada!"
ElseIf ALI->ALI_STATUS == "01"
	Aviso("Atencao", "Solicitação de contingencia aguardando liberacao de nivel anterior!",{"Ok"}) //"Atencao"###"Solicitação de contingencia aguardando liberacao de nivel anterior!"
ElseIf ALI->ALI_STATUS $ "04/06"
	Aviso("Atencao", "Solicitação de contingencia cancelada!",{"Ok"}) //"Atencao"###"Solicitação de contingencia cancelada!"

Else//If	//PCOA500DLG(cAlias,nRecnoALI,4,cR1,cR2,lAuto)  //alterar
	//If Aviso("Atencao", "Liberar a solicitação de contingencia ?",{"Sim", "Nao"}, 2) == 1 //"Atencao"###"Liberar a solicitação de contingencia ?"###"Sim"###"Nao"
		PCOA500GER()
		dbSelectArea(cAlias)
//		SET FILTER TO &cFiltroRot.
		//P_EÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//P_E³ Ponto de entrada utilizado para inclusao de funcoes de usuarios na     ³
		//P_E³ preparacao da contingencia para Solicitação de Compras Customizado     ³
		//P_E³ Implementado para satisfazer o GAP087, na data de 24/02/2012           ³
		//P_EÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ExistBlock( "PC500LIB" )
			ExecBlock( "PC500LIB", .F., .F.)
		EndIf
	//EndIf
EndIf
    
Return 
