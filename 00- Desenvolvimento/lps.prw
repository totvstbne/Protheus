IIF(POSICIONE("CT1",1,xFilial("CT1")+CTK->CTK_DEBITO,"CT1_CCOBRG")=="1",IIF(EMPTY(SD2->D2_CCUSTO),POSICIONE("SC5",1,SD2->(D2_FILIAL+D2_PEDIDO),"C5_YCC"),SD2->D2_CCUSTO),"")

IIF(POSICIONE("CT1",1,xFilial("CT1")+CTK->CTK_DEBITO,"CT1_CCOBRG")=="1",SD1->D1_CC,"") 


classe cliente 
IIF(POSICIONE("CT1",1,xFilial("CT1")+CTK->CTK_CREDIT,"CT1_CLOBRG")=="1",U_CLVLCTA("SA1->A1_COD"),"")                                                                                                    

 
Classe fornecedor 
IIF(POSICIONE("CT1",1,xFilial("CT1")+CTK->CTK_CREDIT,"CT1_CLOBRG")=="1",U_CLVLCTA("SA2->A2_COD"),"")                                                                                                                                                                                                



IIF(POSICIONE("CT1",1,xFilial("CT1")+CT2->CT2_CREDIT,"CT1_YPCO")=="1",SD1->D1_CC,"") IIF(SF4->F4_ESTOQUE="S",SB1->B1_CONTA,IIF(SF4->F4_ATUATF="S",SB1->B1_YCTATIV,SB1->B1_YCTCUST)) 

buscar conta orçamentatia 
IIF(POSICIONE("CT1",1,xFilial("CT1")+CT2->CT2_CREDIT,"CT1_YPCO")=="1",CT1->CT1_YCTAOR,"")

buscar Classe orçamentaria centro de custo 

IIF(POSICIONE("CTT",1,xFilial("CTT")+CT2->CT2_CCC,"CTT_YPCO")=="1",CTT->CTT_YCLAOR,"")

IIF(POSICIONE("CT1",1,xFilial("CT1")+CTK->CTK_CREDIT,"CT1_CCOBRG")=="1",SD1->D1_CC,"")     

buscar filial 
SUBSTR(SM0->M0_CODFIL,1,2) 


VALOR 
 IF(SD1->D1_EMISSAO>=STOD('20211001').AND.GetAdvFVal("CV0","CV0_XPCOIN",xFilial("CV0")+"05"+ALLTRIM(SD1->D1_CC)+FORMULA("002"),1,"")=="S",FORMULA("005"),0)
 

IF(!(SD1->D1_TES$"013-050-090-112-113-111-157"),SD1->(D1_TOTAL-IIF(SF4->F4_CREDICM=='N',0,D1_VALICM)-D1_VALIMP5-D1_VALIMP6-D1_VALDESC+D1_VALFRE+D1_VALIPI+D1_ICMSRET+D1_DESPESA),0)                                                                           
IIF(SD1->D1_RATEIO=="2".AND.SUBSTR(SD1->D1_CF,2,3)$"000_933",SD1->(D1_TOTAL-D1_VALDESC+D1_VALFRE+D1_SEGURO+D1_DESPESA+D1_VALIPI+D1_ICMSRET),0)                                                                                                                                                                                     
 parei no lançamento 001 regra de valor 


IIF(POSICIONE("CT1",1,xFilial("CT1")+SC7->C7_CONTA,"CT1_YPCO")=="1",CT1->CT1_YCTAOR,"")                                                                                                                                                                     

IIF(SF4->F4_ESTOQUE="S",SB1->B1_CONTA,IIF(SF4->F4_ATUATF="S",SB1->B1_YCTATIV,SB1->B1_YCTCUST))

IIF(POSICIONE("CTT",1,xFilial("CTT")+SD1->D1_CC,"CTT_YPCO")=="1",CTT->CTT_YCLAOR,"")  


IF(SD1->D1_EMISSAO>=STOD('20211001').AND.GetAdvFVal("CV0","CV0_XPCOIN",xFilial("CV0")+"05"+ALLTRIM(SD1->D1_CC)+FORMULA("002"),1,"")=="S",FORMULA("005"),0)                                                                                                
IIF(SD1->D1_EMISSAO>=STOD('20211001').AND.SD1->D1_RATEIO=="2".AND.SUBSTR(SD1->D1_CF,2,3)$"000_933",SD1->(D1_TOTAL-D1_VALDESC+D1_VALFRE+D1_SEGURO+D1_DESPESA+D1_VALIPI+D1_ICMSRET),0)                                                                                                            

U_CLVLCTA("SA2->A2_COD")
U_ITEMCTB(SD1->(D1_FORNECE+D1_LOJA),"SA2")   

070101

SM0->M0_CODFIL  
SD1->D1_FILIAL                                                                                                                                                                                                                                           

IF(SC7->C7_TES $ "037" .OR. SC7->C7_FILIAL == "0801", SF4->F4_CTB001,SC7->C7_CONTA)   
IIF(POSICIONE("CTT",1,xFilial("CTT")+SC7->C7_CC,"CTT_YPCO")=="1",CTT->CTT_YCLAOR,"")                                                                                                                                                                                                                                                                                                                                          
SC7->C7_CC
SC7->C7_FILIAL
U_CLVLCTA("SA2->A2_COD")                                                                                                                                                                                                                                                                                                                                                                                                                                                                                


IF(SC7->C7_EMISSAO>=STOD('20211001'),SD1->D1_QUANT*SC7->C7_PRECO,0)                                


IIF(POSICIONE("CTT",1,xFilial("CTT")+SD1->D1_CC,"CTT_YPCO")=="1",CTT->CTT_YCLAOR,"")                                                                                                                                                                      


IIF(POSICIONE("CT1",1,xFilial("CT1")+CTK->CTK_DEBITO,"CT1_CCOBRG")=="1",SD1->D1_CC,"")                                                                                                                                                                    


IIF(SF4->F4_ATUATF="S",SB1->B1_YCTATIV,SB1->B1_YCTCUST)


IIF(SF4->F4_ATUATF="S",SB1->B1_YCTATIV,SB1->B1_YCTCUST)

IIF(POSICIONE("CT1",1,XFILIAL("CT1")+POSICIONE("SB1",1,XFILIAL("SB1")+SD1->D1_COD,"B1_YCTCUST"),"CT1_YPCO")=="1",CT1->CT1_YCTAOR,"")

IIF(POSICIONE("CT1",1,XFILIAL("CT1")+B1_YCTCUST,"CT1_YPCO")=="1",CT1->CT1_YCTAOR,"")                                                                                                                                                                   


IIF(POSICIONE("CT1",1,XFILIAL("CT1")+SB1->B1_CONTA,"CT1_YPCO")=="1",CT1->CT1_YCTAOR,"")                                                                                                                                                                   

IIF(POSICIONE("CTT",1,SUBSTR(SD1->D1_FILIAL,1,2)+ALLTRIM(SD1->D1_CC),"CTT_YPCO")=="1",CTT->CTT_YCLAOR,"")                                                                                                                                                             
