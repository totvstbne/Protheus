#INCLUDE "Protheus.ch"
#Include "Totvs.ch"
#Include "FwMvcDef.ch"
#Include "RWMAKE.CH"
#Include "TOPCONN.CH"

/*--------------------------------------------------------------------------------------------------------------*
 | Função: YFatAut                                                                                              |
 | Autora: Alana Oliveira em 19.11.2021                                                                         |
 | Desc  : Irá gerar a fatura referente a bandeira de cartão informada na SE2                                   |
 *--------------------------------------------------------------------------------------------------------------*/
  

User Function YFatAut()
 
Local aArea	        :=	GetArea()
Local cFiltro       := ""
Local cPerg         := "YFATAUT"  

Private oMark       := FwMarkBrowse():New()
Private lMsErroAuto := .F.


IF !PERGUNTE(cPerg,.t.,"Geração Fatura de Cartão de Crédito")
    MsgAlert("Processo cancelado!","Atenção")
    RETURN
Elseif Empty(mv_par09)
    MsgAlert("Informe a bandeira do cartão!","Atenção")
    RETURN
Elseif Empty(mv_par07) .OR. Empty(mv_par08)
    MsgAlert("Informar fornecedor e loja!","Atenção")
    RETURN
ELSE
    // Inclui filtro na rotina 

    cFiltro += " E2_YBANDEI = '"+MV_PAR09+"'  .AND. E2_SALDO > 0 .AND."
    cFiltro += " E2_EMISSAO >= '"+DTOS(MV_PAR05)+"' .AND. E2_EMISSAO <= '"+DTOS(MV_PAR06)+"' "

    If GetMv("MV_CTLIPAG")
		cFiltro += " .AND. E2_DATALIB <> ' '"
	Endif

ENDIF

oMark:SetAlias('SE2')
oMark:SetFieldMark('E2_OK')
oMark:SetDescription('Geração de Fatura de Cartão de Crédito')
oMark:SetFilterDefault(cFiltro)
oMark:Activate()

RestArea(aArea) 

Return

Static Function MenuDef()    

Local aArea :=	GetArea()
Local aMenu	 :=	{}

Add Option aMenu Title 'Pesquisar'     Action 'PesqBrw' 	     		Operation 1 Access 0
Add Option aMenu Title 'Visual'        Action 'AXVISUAL' 			Operation 2 Access 0
Add Option aMenu Title 'Gerar Fatura'  Action 'U_BRWMKE01()' 			Operation 3 Access 0

RestArea(aArea) 

Return aMenu

User Function BRWMKE01() 

Local aArea :=	GetArea()
Local cMarca := oMark:Mark()
Local _nCont := 0    
Local nSaldo := 0
Local aTits  := {}
Local aFatPag  :={}
Local cDtDe := dtos(MV_PAR05)
Local cDtAte := dtos(MV_PAR06)

// Inclui filtro na rotina 

cFiltro := " SE2->E2_YBANDEI = '"+MV_PAR09+"'  .AND. SE2->E2_SALDO > 0 .AND."
cFiltro += " SE2->E2_EMISSAO >= '"+DTOS(MV_PAR05)+"' .AND. SE2->E2_EMISSAO <= '"+DTOS(MV_PAR06)+"' "

If GetMv("MV_CTLIPAG")
	cFiltro += " .AND. E2_DATALIB <> ' '"
Endif

bCondicao :=  {|| SE2->E2_YBANDEI == MV_PAR09 .AND. SE2->E2_SALDO > 0; 
.AND. SE2->E2_EMISSAO  >= MV_PAR05 .AND. SE2->E2_EMISSAO <= MV_PAR06;
.AND. !empty(SE2->E2_DATALIB) }

//SE2->(dbSetFilter(bCondicao,cfiltro))
Set Filter TO SE2->E2_YBANDEI == MV_PAR09 .AND. SE2->E2_SALDO > 0; 
.AND. SE2->E2_EMISSAO  >= MV_PAR05 .AND. SE2->E2_EMISSAO <= MV_PAR06;
.AND. !empty(SE2->E2_DATALIB)

SE2->(dbGoTop())

PROCREGUA( 0 )

While SE2->(!Eof())  

   If oMark:IsMark(cMarca)    

      IF SE2->E2_YBANDEI == MV_PAR09  .AND. SE2->E2_SALDO > 0 .AND.  SE2->E2_EMISSAO  >= MV_PAR05;
         .AND. SE2->E2_EMISSAO <= MV_PAR06 .AND. !EMPTY(SE2->E2_DATALIB)
      
            nSaldo+= SE2->E2_SALDO

            //[13] - ARRAY com os titulos da fatura - Geradores (esses títulos devem existir na base)
            //[13,1] Prefixo
            //[13,2] Numero
            //[13,3] Parcela
            //[13,4] Tipo
            //[13,5] Título localizado na geracao de fatura (lógico). Iniciar com falso.
            //[13,6] Fornecedor
            //[13,7] Loja
            //[13,8] Filial (utilizada em fatura de títulos de diferentes filiais)

            aAdd(aTits,{SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_TIPO,.F.,SE2->E2_FORNECE,SE2->E2_LOJA,SE2->E2_FILIAL})
      ENDIF  
       
   EndIf    

   _nCont++

   SE2->(dbSkip())
   
   incproc( "Geração de Fatura Processando")

EndDo

//Descricao do Array aFatPag
//[01] - Prefixo
//[02] - Tipo
//[03] - Numero da Fatura (se o numero estiver em branco obtem pelo FINA290)
//[04] - Natureza
//[05] - Data de
//[06] - Data Ate
//[07] - Fornecedor
//[08] - Loja
//[09] - Fornecedor para geracao
//[10] - Loja do fornecedor para geracao
//[11] - Condicao de pagto
//[12] - Moeda
//[13] - ARRAY com os titulos da fatura - Geradores
//[14] - Valor de decrescimo
//[15] - Valor de acrescimo

If empty(mv_par03) 
	aTam    := TamSx3("E2_NUM")
	cFatura	:= Soma1(GetMv("MV_NUMFATP"), aTam[1])
	cFatura	:= Pad(cFatura,aTam[1])
else    
    cFatura:=mv_par03
Endif  

_aFatPag := { mv_par01, mv_par02 , cFatura , mv_par04, mv_par05, mv_par06,MV_PAR07,MV_PAR08, MV_PAR07,MV_PAR08, "001", 01, aTits ,0 ,0 }

RestArea(aArea) 
//SE2->(DBClearFilter())
MsExecAuto( { |x,y| FINA290(x,y)}, 3, _aFatPag )

If lMsErroAuto
    MostraErro()
Else
    Alert("Fatura gerada com sucesso.Valor total R$ "+CValToChar(nSaldo))
Endif
 
oMark:DeActivate()


Return 
 



