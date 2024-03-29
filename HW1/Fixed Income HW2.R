rm(list=ls())
library(xts)
library(ggplot2)
library(dplyr)
library(data.table)
library(readxl)
strips<-read_excel("~/Desktop/Homework 2 Data.xlsx") %>% as.data.table()
#Q1--------------------------------------------------
strips[,dis:=Price*0.01]
strips[,spotr:=2*(dis^(-1/(2*Maturity))-1)]   
qplot(Maturity,spotr,data=strips,ylab="Spot Rate",geom="line",col=I("blue"),
      main="Spot Rate vs Maturity") + theme_bw()
strips[,fordr:=4*(Price/shift(Price,type='lead')-1)]
qplot(Maturity,fordr,data=strips,ylab="Forward Rate",geom="line",col=I("steelblue"),
      main="Forward Rate vs Maturity") + theme_bw()
#Q2--------------------------------------------------
reg2<-lm(log(dis)~Maturity+I(Maturity^2)+I(Maturity^3)+I(Maturity^4)+I(Maturity^5)+0,strips)
#without intercept
coef<-coef(reg2)
#Q3---------------------------------------------------
#spot rate 
time<-seq(1/2,25,by=1/2)
reg_dist<-exp(coef[1]*time+coef[2]*(time^2)+coef[3]*(time^3)+coef[4]*(time^4)+coef[5]*(time^5))
reg_spot<-2*(reg_dist^(-1/(2*time))-1)
qplot(time,reg_spot,ylab="Reg Spot Rate",geom="line",col=I("blue"),
      main="Regressed Spot Rate vs Maturity") + theme_bw()
#Q4----------------------------------------------------
#par rate
reg_par<-c()
for (i in 1:50){reg_par[i]<-2*(1-reg_dist[i])/(sum(reg_dist[1:i]))}
qplot(time,reg_par,ylab="Reg Par Rate",geom="line",col=I("blue"),
      main="Regressed Par Rate vs Maturity") + theme_bw()
#Q5-------------------------------------------------------
#forward rate
reg_fordr<-c()
for (i in 1:49){reg_fordr[i]=2*(reg_dist[i]/reg_dist[i+1]-1)}
qplot(time[1:49],reg_fordr,ylab="Reg Forward Rate",xlab="maturity",geom="line",col=I("blue"),
      main="Regressed Forward Rate vs Maturity") + theme_bw()
#Q6---------------------------------------------------------
bootstrap<-read_excel("~/Desktop/Homework 2 Data.xlsx",2) %>% as.data.table()
reg6<-lm(Yield~Maturity+I(Maturity^2)+I(Maturity^3)+I(Maturity^4)+I(Maturity^5),bootstrap)
#with intercept
coef6<-coef(reg6)
#to simplify,I treat the regression result as par rate
new_par<-(coef6[1]+coef6[2]*time+coef6[3]*(time^2)+coef6[4]*(time^3)+coef6[5]*(time^4)+coef6[6]*(time^5))/100
#get discount rate
new_dist<-c()
new_dist[1]=2/(2+new_par[1])
for (i in 2:50){new_dist[i]=(2-new_par[i]*sum(new_dist))/(new_par[i]+2)}
#get spot rate
new_spot=2*(new_dist^(-1/(2*time))-1)
#get forward rate
new_fordr<-c()
for (i in 1:49){new_fordr[i]=2*(new_dist[i]/new_dist[i+1]-1)}
qplot(time[-1],new_spot[-1],ylab="Rate",xlab="maturity",geom="line",col=I("blue")) +
  theme_bw()+geom_line(aes(y=new_par[-1]),col=I("red"),linetype=2)+
  geom_line(aes(y=new_fordr),col=I("green")) 













