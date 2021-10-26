#Include 'Protheus.ch'

User Function At930ACa()
    Local cTipo := ParamIxb[1]
    Local aRet  := {}

    If cTipo == "FIL"
        aAdd(aRet, "ABS_YAGRUP")
    ElseIf cTipo == "CNT"
        aAdd(aRet, "CNT_YFATMU")
    EndIf
    
Return aRet
