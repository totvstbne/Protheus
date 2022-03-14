//Bibliotecas
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
 
//Vari�veis Est�ticas
Static cTitulo := "Bandeiras de Cart�o"
 
/*/{Protheus.doc} YCADZF1
Cadastro de Bandeiras de Cart�o
@author Alana Oliveira
@since 26/11/2021
@version 1.0
    @return Nil, Fun��o n�o tem retorno
    @example
    u_YCADZF1()
/*/
 
User Function YCADZF1()
    Local aArea   := GetArea()
    Local oBrowse
    Local cFunBkp := FunName()
     
    SetFunName("YCADZF1")
     
    //Inst�nciando FWMBrowse - Somente com dicion�rio de dados
    oBrowse := FWMBrowse():New()
     
    //Setando a tabela de cadastro de Bandeiras de Cart�o
    oBrowse:SetAlias("ZF1")
 
    //Setando a descri��o da rotina
    oBrowse:SetDescription(cTitulo)
     
    //Filtrando
    //oBrowse:SetFilterDefault("ZF1->ZF1_CODIGO >= '000000' .And. ZF1->ZF1_CODIGO <= 'ZZZZZZ'")
     
    //Ativa a Browse
    oBrowse:Activate()
     
    SetFunName(cFunBkp)
    RestArea(aArea)
Return Nil
 
/*---------------------------------------------------------------------*
 | Func:  MenuDef                                                      |
 | Autor: Alana Oliveira                                               |
 | Data:  26/11/2021                                                   |
 | Desc:  Cria��o do menu MVC                                          |
 *---------------------------------------------------------------------*/
 
Static Function MenuDef()
    Local aRot := {}
     
    //Adicionando op��es
    ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.YCADZF1' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
    ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.YCADZF1' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
    ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.YCADZF1' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
    ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.YCADZF1' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
 
Return aRot
 
/*---------------------------------------------------------------------*
 | Func:  ModelDef                                                     |
 | Autor: Alana Oliveira                                               |
 | Data:  26/11/2021                                                   |
 | Desc:  Cria��o do modelo de dados MVC                               |
 *---------------------------------------------------------------------*/
 
Static Function ModelDef()
    //Cria��o do objeto do modelo de dados
    Local oModel := Nil
     
    //Cria��o da estrutura de dados utilizada na interface
    Local oStZF1 := FWFormStruct(1, "ZF1")
     
    //Editando caracter�sticas do dicion�rio
    oStZF1:SetProperty('ZF1_CODIGO',   MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    '.F.'))                                 //Modo de Edi��o
    oStZF1:SetProperty('ZF1_CODIGO',   MODEL_FIELD_INIT,    FwBuildFeature(STRUCT_FEATURE_INIPAD,  'GetSXENum("ZF1", "ZF1_CODIGO")'))         //Ini Padr�o
    oStZF1:SetProperty('ZF1_DESC',  MODEL_FIELD_VALID,   FwBuildFeature(STRUCT_FEATURE_VALID,   'Iif(Empty(M->ZF1_DESC), .F., .T.)'))   //Valida��o de Campo
    oStZF1:SetProperty('ZF1_DESC',  MODEL_FIELD_OBRIGAT, Iif(RetCodUsr()!='000000', .T., .F.) )                                         //Campo Obrigat�rio
     
    //Instanciando o modelo, n�o � recomendado colocar nome da user function (por causa do u_), respeitando 10 caracteres
    oModel := MPFormModel():New("YCADZF1M",/*bPre*/, /*bPos*/,/*bCommit*/,/*bCancel*/) 
     
    //Atribuindo formul�rios para o modelo
    oModel:AddFields("FORMZF1",/*cOwner*/,oStZF1)
     
    //Setando a chave prim�ria da rotina
    oModel:SetPrimaryKey({'ZF1_FILIAL','ZF1_CODIGO'})
     
    //Adicionando descri��o ao modelo
    oModel:SetDescription("Modelo de Dados do Cadastro "+cTitulo)
     
    //Setando a descri��o do formul�rio
    oModel:GetModel("FORMZF1"):SetDescription("Formul�rio do Cadastro "+cTitulo)
Return oModel
 
/*---------------------------------------------------------------------*
 | Func:  ViewDef                                                      |
 | Autor: Alana Oliveira                                               |
 | Data:  26/11/2021                                                   |
 | Desc:  Cria��o da vis�o MVC                                         |
 *---------------------------------------------------------------------*/
 
Static Function ViewDef()
    Local aStruZF1    := ZF1->(DbStruct())
     
    //Cria��o do objeto do modelo de dados da Interface do Cadastro de Bandeiras de Cart�o
    Local oModel := FWLoadModel("YCADZF1")
     
    //Cria��o da estrutura de dados utilizada na interface do cadastro de Bandeiras de Cart�o
    Local oStZF1 := FWFormStruct(2, "ZF1")  //pode se usar um terceiro par�metro para filtrar os campos exibidos { |cCampo| cCampo $ 'ZF1_NOME|ZF1_DTAFAL|'}
     
    //Criando oView como nulo
    Local oView := Nil
 
    //Criando a view que ser� o retorno da fun��o e setando o modelo da rotina
    oView := FWFormView():New()
    oView:SetModel(oModel)
     
    //Atribuindo formul�rios para interface
    oView:AddField("VIEW_ZF1", oStZF1, "FORMZF1")
     
    //Criando um container com nome tela com 100%
    oView:CreateHorizontalBox("TELA",100)
     
    //Colocando t�tulo do formul�rio
    oView:EnableTitleView('VIEW_ZF1', 'Dados - '+cTitulo )  
     
    //For�a o fechamento da janela na confirma��o
    oView:SetCloseOnOk({||.T.})
     
    //O formul�rio da interface ser� colocado dentro do container
    oView:SetOwnerView("VIEW_ZF1","TELA")
     
    /*
    //Tratativa para remover campos da visualiza��o
    For nAtual := 1 To Len(aStruZF1)
        cCampoAux := Alltrim(aStruZF1[nAtual][01])
         
        //Se o campo atual n�o estiver nos que forem considerados
        If Alltrim(cCampoAux) $ "ZF1_CODIGO;"
            oStZF1:RemoveField(cCampoAux)
        EndIf
    Next
    */
Return oView
 