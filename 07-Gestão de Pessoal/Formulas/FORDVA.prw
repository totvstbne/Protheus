#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "topconn.ch"
#INCLUDE "tbiconn.ch"

// AUTO : JOAO FILHO - TOTVS CE
// OBJETIVO : ESSE FONTE É CHAMADO POR UMA FORMULA NO ROTEIRO DE CALCULO FOL 
//            FORMUMA UFOR0002, VERIFICA OS DIAS DE ATESTADOS E FALTAS (201,098,100) E MULTIPLICA PELO
//            VALOR DO DIA DO VALE ALIMENTAÇÃO E GERAR A VERBA 246

user function FORDVA()

	// R0_TPVALE = 0=Vale Transporte;1=Vale Refeição;2=Vale Alimentação
	// R0_CODIGO = DIZ QUAL O VALE O FUNCIONÁRIO TEM DIREITO SE LERACIONA COM RFO

	cQuery := " SELECT R0_MAT,R0_TPVALE,R0_CODIGO,RFO_CODIGO,RFO_VALOR
	cQuery += " FROM "+RetSqlName("SR0")+"  SR0 , "+RetSqlName("RFO")+"  RFO
	cQuery += " WHERE SR0.D_E_L_E_T_= '' AND RFO.D_E_L_E_T_=''
	cQuery += " AND R0_FILIAL = '"+ alltrim(xfilial("SR0",SRA->RA_FILIAL)) +"' AND RFO_FILIAL = '"+ alltrim(xfilial("RFO",SRA->RA_FILIAL)) +"'
	cQuery += " AND R0_TPVALE = '2'   
	cQuery += " AND R0_TPVALE = RFO_TPVALE
	cQuery += " AND R0_CODIGO = RFO_CODIGO
	cQuery += " AND R0_MAT = '"+SRA->RA_MAT+"'
	
	IF SELECT("T01") > 0
		T01->(DbClosearea())
	ENDIF
	
	__ExecSql("T01",cQuery,{},.T.) 
	
	if !T01->(eof())
		
		fgeraverba("246",(FBUSCAPD("100","H") + FBUSCAPD("098","H")+ (FBUSCAPD("201","H") * -1 )  ) * T01->RFO_VALOR )	
		
	endif
	
	T01->(DbClosearea())
	
return