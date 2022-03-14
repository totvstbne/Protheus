/*/{Protheus.doc} User Function At930Cab
    (PE para acesso ao campos da medição a partir da apruação ágil.)
    @type  User Function
    @author Mateus da Silva Teixeira
    @since 06/01/2021
    @version undefined
    @param Nil
    @return NIl
    /*/
User Function At930Cab()
	Local aCab      := Paramixb[1]
	Local oMdl930A  := Paramixb[2]
	Local oMdlCNT
	If ValType(oMdl930A)!="U"
		oMdlCNT   := oMdl930A:GetModel("CNTMASTER")
		aAdd(aCab, {"CND_YFATMU", if(EmpTy(oMdlCNT:GetValue("CNT_YFATMU")), "1", oMdlCNT:GetValue("CNT_YFATMU")), NIL})    
	EndIf
Return aCab
