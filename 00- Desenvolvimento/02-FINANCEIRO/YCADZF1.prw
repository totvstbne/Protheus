//Bibliotecas
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
 
//Variáveis Estáticas
Static cTitulo := "Bandeiras de Cartão"
 
/*/{Protheus.doc} YCADZF1
Cadastro de Bandeiras de Cartão
@author Alana Oliveira
@since 26/11/2021
@version 1.0
    @return Nil, Função não tem retorno
    @example
    u_YCADZF1()
/*/
 
User Function YCADZF1()
    Local aArea   := GetArea()
    Local oBrowse
    Local cFunBkp := FunName()
     
    SetFunName("YCADZF1")
     
    //Instânciando FWMBrowse - Somente com dicionário de dados
    oBrowse := FWMBrowse():New()
     
    //Setando a tabela de cadastro de Bandeiras de Cartão
    oBrowse:SetAlias("ZF1")
 
    //Setando a descrição da rotina
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
 | Desc:  Criação do menu MVC                                          |
 *---------------------------------------------------------------------*/
 
Static Function MenuDef()
    Local aRot := {}
     
    //Adicionando opções
    ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.YCADZF1' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
    ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.YCADZF1' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
    ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.YCADZF1' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
    ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.YCADZF1' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
 
Return aRot
 
/*---------------------------------------------------------------------*
 | Func:  ModelDef                                                     |
 | Autor: Alana Oliveira                                               |
 | Data:  26/11/2021                                                   |
 | Desc:  Criação do modelo de dados MVC                               |
 *---------------------------------------------------------------------*/
 
Static Function ModelDef()
    //Criação do objeto do modelo de dados
    Local oModel := Nil
     
    //Criação da estrutura de dados utilizada na interface
    Local oStZF1 := FWFormStruct(1, "ZF1")
     
    //Editando características do dicionário
    oStZF1:SetProperty('ZF1_CODIGO',   MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    '.F.'))                                 //Modo de Edição
    oStZF1:SetProperty('ZF1_CODIGO',   MODEL_FIELD_INIT,    FwBuildFeature(STRUCT_FEATURE_INIPAD,  'GetSXENum("ZF1", "ZF1_CODIGO")'))         //Ini Padrão
    oStZF1:SetProperty('ZF1_DESC',  MODEL_FIELD_VALID,   FwBuildFeature(STRUCT_FEATURE_VALID,   'Iif(Empty(M->ZF1_DESC), .F., .T.)'))   //Validação de Campo
    oStZF1:SetProperty('ZF1_DESC',  MODEL_FIELD_OBRIGAT, Iif(RetCodUsr()!='000000', .T., .F.) )                                         //Campo Obrigatório
     
    //Instanciando o modelo, não é recomendado colocar nome da user function (por causa do u_), respeitando 10 caracteres
    oModel := MPFormModel():New("YCADZF1M",/*bPre*/, /*bPos*/,/*bCommit*/,/*bCancel*/) 
     
    //Atribuindo formulários para o modelo
    oModel:AddFields("FORMZF1",/*cOwner*/,oStZF1)
     
    //Setando a chave primária da rotina
    oModel:SetPrimaryKey({'ZF1_FILIAL','ZF1_CODIGO'})
     
    //Adicionando descrição ao modelo
    oModel:SetDescription("Modelo de Dados do Cadastro "+cTitulo)
     
    //Setando a descrição do formulário
    oModel:GetModel("FORMZF1"):SetDescription("Formulário do Cadastro "+cTitulo)
Return oModel
 
/*---------------------------------------------------------------------*
 | Func:  ViewDef                                                      |
 | Autor: Alana Oliveira                                               |
 | Data:  26/11/2021                                                   |
 | Desc:  Criação da visão MVC                                         |
 *---------------------------------------------------------------------*/
 
Static Function ViewDef()
    Local aStruZF1    := ZF1->(DbStruct())
     
    //Criação do objeto do modelo de dados da Interface do Cadastro de Bandeiras de Cartão
    Local oModel := FWLoadModel("YCADZF1")
     
    //Criação da estrutura de dados utilizada na interface do cadastro de Bandeiras de Cartão
    Local oStZF1 := FWFormStruct(2, "ZF1")  //pode se usar um terceiro parâmetro para filtrar os campos exibidos { |cCampo| cCampo $ 'ZF1_NOME|ZF1_DTAFAL|'}
     
    //Criando oView como nulo
    Local oView := Nil
 
    //Criando a view que será o retorno da função e setando o modelo da rotina
    oView := FWFormView():New()
    oView:SetModel(oModel)
     
    //Atribuindo formulários para interface
    oView:AddField("VIEW_ZF1", oStZF1, "FORMZF1")
     
    //Criando um container com nome tela com 100%
    oView:CreateHorizontalBox("TELA",100)
     
    //Colocando título do formulário
    oView:EnableTitleView('VIEW_ZF1', 'Dados - '+cTitulo )  
     
    //Força o fechamento da janela na confirmação
    oView:SetCloseOnOk({||.T.})
     
    //O formulário da interface será colocado dentro do container
    oView:SetOwnerView("VIEW_ZF1","TELA")
     
    /*
    //Tratativa para remover campos da visualização
    For nAtual := 1 To Len(aStruZF1)
        cCampoAux := Alltrim(aStruZF1[nAtual][01])
         
        //Se o campo atual não estiver nos que forem considerados
        If Alltrim(cCampoAux) $ "ZF1_CODIGO;"
            oStZF1:RemoveField(cCampoAux)
        EndIf
    Next
    */
Return oView
 