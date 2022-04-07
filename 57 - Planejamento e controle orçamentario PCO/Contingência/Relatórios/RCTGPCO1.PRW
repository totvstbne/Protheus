#include 'parmtype.ch'
#include "rwmake.ch"
#include "protheus.ch"  
#INCLUDE "COLORS.CH" 
#include "TOPCONN.ch"
#define DMPAPER_A4 9
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ºPrograma  RCTGPCO1   ºAutora  Alana Oliveira       º Data ³  04/03/22  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Relatorio - Listagem de Contingências PCO                   º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/

User function RCTGPCO1()

Local oReport 
Local aArea	 :=	GetArea()
Private cAlias:="ALI"
Private aCampos:={}
Private cPerg := "RCTGPCO1"
Private cAliasTab := GetNextAlias()
Private cCmpSelect:="%" 

oReport := reportDef(@aCampos)                            
oReport:printDialog()

RestArea(aArea) 

Return


Static function reportDef(aCampos)   

Local oReport
Local oSection1
Local cTitulo    := 'Liberação de Contingências'     

oTFont1 := TFont():New('Arial',0,-10,,.F.,,,,,.F.,.T.)
oTFont2 := TFont():New('Arial',0,-9,,.F.,,,,,.F.,.F.)
oTFont3 := TFont():New('Arial',0,-2,,.F.,,,,,.F.,.F.)

Pergunte(cPerg,.f.)

oReport := TReport():New('RCTGPCO1', cTitulo,'RCTGPCO1' , {|oReport| PrintReport(oReport)},"Contingências")
oReport:SetLandscape(.F.)  // Aqui que define Retrato ou Paisagem  
oReport:SetTotalInLine(.F.) 
oReport:SetPortrait(.T.) 
oReport:ShowHeader()
oReport:SetLineHeight(50)   
oReport:SetColSpace(1) 
oReport:SetLeftMargin(0) 

oSection1 := TRSection():New(oReport,"Liberação de Contingências - Cabeçalho",{"ALI","ALJ","AK6","AK5"}) 

oSection1 :SetTotalInLine(.F.)
oSection1 :SetTotalText("TOTAL") //"Total Geral "
oSection1:SetPageBreak(.F.)  
oSection1:OFONTBODY:= oTFont2 
oSection1:OFONTBODY:NAME:= "ARIAL"
oSection1:OFONTBODY:NHEIGHT:=-10 
oSection1:OFONTBODY:BOLD:=.T.
oSection1:lAutoSize:=.T.

TRCell():New(oSection1, "ALI_CDCNTG","ALI","Cod.Conting.",PesqPict("ALI","ALI_CDCNTG"),TamSX3("ALI_CDCNTG")[1],/*lPixel*/,{|| ALLTRIM(&(cAliasTAB+"->ALI_CDCNTG"))})
TRCell():New(oSection1, "ALI_NOMSOL","ALI","Nome Solic." ,PesqPict("ALI","ALI_NOMSOL"),TamSX3("ALI_NOMSOL")[1]+5,/*lPixel*/ ,{|| ALLTRIM(&(cAliasTAB+"->ALI_NOMSOL"))})
TRCell():New(oSection1, "ALI_DTSOLI","ALI","Dt.Solicit." ,PesqPict("ALI","ALI_DTSOLI"),TamSX3("ALI_DTSOLI")[1],/*lPixel*/ ,{|| &(cAliasTAB+"->ALI_DTSOLI")})
TRCell():New(oSection1, "ALJ_CLASSE","ALJ","Classe de Valor" ,PesqPict("ALJ","ALJ_CLASSE"),TamSX3("ALJ_CLASSE")[1],/*lPixel*/ ,{|| ALLTRIM(&(cAliasTAB+"->ALJ_CLASSE"))})
TRCell():New(oSection1, "AK6_DESCRI","AK6","Descr. da Classe" ,PesqPict("AK6","AK6_DESCRI"),TamSX3("AK6_DESCRI")[1],/*lPixel*/ ,{|| ALLTRIM(&(cAliasTAB+"->AK6_DESCRI"))})
TRCell():New(oSection1, "ALJ_CO","ALJ","C.O." ,PesqPict("ALJ","ALJ_CO"),TamSX3("ALJ_CO")[1],/*lPixel*/ ,{|| ALLTRIM(&(cAliasTAB+"->ALJ_CO"))})
TRCell():New(oSection1, "AK5_DESCRI","AK5","Descricao da C.O." ,PesqPict("AK5","AK5_DESCRI"),TamSX3("AK5_DESCRI")[1],/*lPixel*/ ,{|| ALLTRIM(&(cAliasTAB+"->AK5_DESCRI"))})
TRCell():New(oSection1, "ALJ_VALOR1","ALJ","Vlr.Lancto." ,PesqPict("ALJ","ALJ_VALOR1"),TamSX3("ALJ_VALOR1")[1]+8,/*lPixel*/ ,{|| &(cAliasTAB+"->ALJ_VALOR1")},"RIGHT",,"RIGHT")
TRCell():New(oSection1, "STATUS","ALI","Status" ,"!@",40,/*lPixel*/ ,{|| &(cAliasTAB+"->STATLIB")})
TRCell():New(oSection1, "ALI_DTLIB","ALI","Data liber." ,PesqPict("ALI","ALI_DTLIB"),TamSX3("ALI_DTLIB")[1],/*lPixel*/ ,{|| &(cAliasTAB+"->ALI_DTLIB")})
TRCell():New(oSection1, "ALI_NOMLIB","ALI","Nome Lib." ,PesqPict("ALI","ALI_NOMLIB"),TamSX3("ALI_NOMLIB")[1]+10,/*lPixel*/ ,{|| &(cAliasTAB+"->ALI_NOMLIB")})


TRFunction():New(oSection1:Cell("ALJ_VALOR1"),"TOTAL","SUM",/*oBreak*/,/*cTitle*/,"@E 999,999,999.99",/*uFormula*/,.T./*lEndSection*/,.T./*lEndReport*/,/*lEndPage*/)

oSection1:Cell("ALJ_VALOR1"):SetAlign("RIGHT")

dbselectArea("SX3")
dbseek(cAlias)

Return (oReport)


Static Function PrintReport(oReport)

Local oSection1 := oReport:Section(1)  

oSection1:Init() 
oSection1:SetHeaderSection(.T.) 
cAlias:="ALI" 

MV_PAR03:= IIF(EMPTY(MV_PAR03),"ZZZZZZ",MV_PAR03) //6
MV_PAR05:= IIF(EMPTY(MV_PAR05),"ZZZZZZZZZZZZ",MV_PAR05) //MV_PAR04 E 05 - 12

DbSelectArea("ALI")

_cFiltro:="% ALJ_CLASSE BETWEEN '"+MV_PAR02+"' AND '"+MV_PAR03+"' "  
_cFiltro+="  AND ALJ_CO BETWEEN '"+MV_PAR04+"' AND '"+MV_PAR05+"' "  

If mv_par01 == 2
	_cFiltro+= " AND ALI_STATUS IN ('01', '02')%" // Somente Aguardando Liberação
Elseif mv_par01 == 3
	_cFiltro+= " AND ALI_STATUS IN ('03', '04')%" // Somente Liberadas   
Elseif mv_par01 == 4
   _cFiltro+= " AND ALI_STATUS IN ('04', '06')%" // Somente Canceladas 
else
   _cFiltro+= "%"	  
Endif
   		
MakeSqlExpr(cPerg)

cTblALI:="%"+RetSqlName("ALI")+"%"        
cTblALJ:="%"+RetSqlName("ALJ")+"%"

oSection1:BeginQuery() 

BeginSql alias cAliasTAB  
	
	SELECT ALI_CDCNTG,
       ALI_NOMSOL,
       ALI_DTSOLI,
       ALJ_CLASSE,
       ALJ_CO,
       AK5_DESCRI,
       AK6_DESCRI,
       ALJ_UNIORC,
       ALJ_VALOR1,
       ALJ_EMPVAL,
       CASE
           WHEN ALI_STATUS IN ('01',
                               '02') THEN 'Aguardando liberação'
           WHEN ALI_STATUS IN ('03',
                               '04') THEN 'Liberado'
           WHEN ALI_STATUS IN ('04',
                               '06') THEN 'Cancelado'
           ELSE ''
       END AS STATLIB,
	   ALI_DTLIB,
	   ALI_NOMLIB
	FROM %exp:cTblALI% ALI
	JOIN %exp:cTblALJ% ALJ ON (ALI_LOTEID = ALJ_LOTEID
                    AND ALI_CDCNTG = ALJ_CDCNTG
                    AND ALJ.%notdel%)
	JOIN AK5010 AK5 ON (AK5_CODIGO = ALJ_CO
                    AND AK5.%notdel%)
	JOIN AK6010 AK6 ON (AK6_CODIGO = ALJ_CLASSE
                    AND AK6.%notdel%)
	WHERE ALI.%notdel%
	AND %EXP:_cFiltro%
	ORDER BY ALI_CDCNTG
	
EndSql

oSection1:EndQuery()

DbSelectArea(cAliasTAB)
oReport:SetMeter(&(cAliasTAB+"->(RecCount())"))
dbGoTop()    

oTFont1 := TFont():New('Arial',0,-10,,.F.,,,,,.F.,.T.)
oTFont2 := TFont():New('Arial',0,-10,,.F.,,,,,.F.,.F.)
// Negrito,Sublinhado,Itálico

oSection1:Init() 

While &(cAliasTAB+"->(!Eof())")   

	If oReport:Cancel()
		Exit
	EndIf    
	
	oReport:IncMeter()  
	 
	oSection1:PrintLine() 

	&(cAliasTAB+"->(dbSkip())") 
	
EndDo
      

oSection1:Finish() 


Return                 

