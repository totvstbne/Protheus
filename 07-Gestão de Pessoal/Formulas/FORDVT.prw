#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "topconn.ch"
#INCLUDE "tbiconn.ch"

// AUTO : JOAO FILHO - TOTVS CE
// OBJETIVO : ESSE FONTE É CHAMADO POR UMA FORMULA NO ROTEIRO DE CALCULO FOL 
//            FORMUMA UFOR0003, VERIFICA OS DIAS DE ATESTADOS E FALTAS (201,098,100) E MULTIPLICA PELO
//            VALOR DO DIA DO VALE TRANSPORTE E GERAR A VERBA 247

user function FORDVT()

	// R0_TPVALE = 0=Vale Transporte;1=Vale Refeição;2=Vale Alimentação
	// R0_CODIGO = DIZ QUAL O VALE O FUNCIONÁRIO TEM DIREITO SE RELACIONA COM RFO

	cQuery := " SELECT R0_MAT,R0_TPVALE,R0_CODIGO,R0_QDIAINF , RN_VUNIATU
	cQuery += " FROM "+RetSqlName("SR0")+" SR0 , "+RetSqlName("SRN")+" SRN 
	cQuery += " WHERE SR0.D_E_L_E_T_= '' AND SRN.D_E_L_E_T_='' 
	cQuery += " AND R0_FILIAL = '"+ alltrim(xfilial("SR0",SRA->RA_FILIAL)) +"'
	cQuery += " AND RN_FILIAL = '"+ alltrim(xfilial("RFO",SRA->RA_FILIAL)) +"'
	cQuery += " AND R0_TPVALE = '0'    
	cQuery += " AND R0_CODIGO = RN_COD 
	cQuery += " AND R0_MAT = '"+SRA->RA_MAT+"'

	IF SELECT("T01") > 0
		T01->(DbClosearea())
	ENDIF

	__ExecSql("T01",cQuery,{},.T.) 

	if !T01->(eof())

		fgeraverba("247",((FBUSCAPD("100","H") + FBUSCAPD("098","H")+ (FBUSCAPD("201","H") * -1 ) ) * T01->RN_VUNIATU ) * T01->R0_QDIAINF )	

	endif

	T01->(DbClosearea())

return