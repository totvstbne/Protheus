#Include 'Protheus.ch'


User Function CTA030TOK()

Local nOpc := PARAMIXB

Local lRet := .F.  // retornando FALSE sempre continua com as demais validacoes e gravacao 123456

If M->CTT_YPCO = '1' .AND. EMPTY(M->CTT_YCLAOR)

    lRet := .T. 
    Alert("Preencha o Campo Classe Or�amentaria") 

EndIf

Return( lRet ) 
