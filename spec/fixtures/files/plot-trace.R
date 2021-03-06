args <- commandArgs(trailingOnly = T)
if(length(args) != 2) { # check number of args
 write("Error: commandline arguments for <infile> <outfile> is required", stderr())
 write("Usage: R --vanilla --slave --args data.csv plot.pdf < plot-trac.R", stderr())
 q() #finish
}
input = args[1]
output = args[2]
pdf(output)
tbl0 <- read.csv(input,header=T,stringsAsFactors=F)

### constant definition made on January 14, 2015
### refer by index <- c(do.call("cbind",Z[c("Li","Rb")]))
###       or index <- unlist(Z[c("Li","Rb")],use.names=FALSE)
Z            <- list("Li"=3,"Be"=4,"B"=5,"Rb"=37,"Sr"=38,"Y"=39,"Zr"=40,"Nb"=41,"Cs"=55,"Ba"=56,"La"=57,"Ce"=58,"Pr"=59,"Nd"=60,"Sm"=62,"Eu"=63,"Gd"=64,"Tb"=65,"Dy"=66,"Ho"=67,"Er"=68,"Tm"=69,"Yb"=70,"Lu"=71,"Hf"=72,"Ta"=73,"Pb"=82,"Th"=90,"U"=92)
volatii      <- list("Pb"=1,"Cs"=2,"Rb"=3,"B"=4,"Li"=5,"Eu"=6,"Be"=7,"Ba"=8,"Sr"=9,"Ce"=10,"Yb"=11,"Nb"=12,"Ta"=13,"La"=14,"Pr"=15,"Sm"=16,"Nd"=17,"U"=18,"Y"=19,"Gd"=20,"Tb"=21,"Dy"=22,"Ho"=23,"Er"=24,"Tm"=25,"Lu"=26,"Th"=27,"Hf"=28,"Zr"=29)
compati      <- list("Li"=23,"Be"=-1,"B"=7,"Rb"=2,"Sr"=14,"Y"=24,"Zr"=17,"Nb"=8,"Cs"=1,"Ba"=3,"La"=10,"Ce"=11,"Pr"=13,"Nd"=15,"Sm"=16,"Eu"=19,"Gd"=20,"Tb"=21,"Dy"=22,"Ho"=25,"Er"=26,"Tm"=27,"Yb"=28,"Lu"=29,"Hf"=18,"Ta"=-1,"Pb"=12,"Th"=4,"U"=5)
ref          <- list("Cs"=0.19,"Rb"=2.3,"Ba"=2.41,"Th"=0.029,"U" =0.0074,"B" =0.9,"Nb"=0.24,"La"=0.237,"Ce"=0.613,"Pb"=2.47,"Pr"=0.0928,"Sr"=7.25,"Nd"=0.457,"Sm"=0.148,"Zr"=3.82,"Hf"=0.103,"Eu"=0.0563,"Gd"=0.199,"Tb"=0.0361,"Dy"=0.246,"Li"=1.5,"Y" =1.57,"Ho"=0.0546,"Er"=0.16,"Tm"=0.0247,"Yb"=0.161,"Lu"=0.0246) # Wasson and Kallemeyn (1988) except for Rb, Cs, Pb (Schaefer and Fegley Jr, 2010) and B (Zhai, 1994)

tbl0		 <- subset(tbl0, element %in% names(ref))
tbl0$Z       <- unlist(Z[tbl0$element],use.names=FALSE)
tbl0$volatii <- unlist(volatii[tbl0$element],use.names=FALSE)
tbl0$compati <- unlist(compati[tbl0$element],use.names=FALSE)
tbl0$ref     <- unlist(ref[tbl0$element],use.names=FALSE)
tbl0[tbl0 == 0] <- NA

#######################################
### REE AND SPIDER
#######################################
tbl       <- tbl0
regexp    <- "CBK"
acq       <- "5f" # 5f or ICP-MS
### RARE EARTH ONLY
tbl_ree   <- subset(tbl,subset=(Z > 56 & Z < 72 & Z != 65 & Z != 67 & Z != 69 )) # REE extraction
tbl_ree   <- tbl_ree[sort.list(tbl_ree$Z),] # Rage for order
xxx_ree   <- tbl_ree$Z
tll_ree1  <- tbl_ree[grep(regexp,names(tbl_ree))] # extract certain dataset
tll_ree2  <- tll_ree1 / tbl_ree$ref
### SPIDER TRACE
if (acq == "5f") {
  tbl     <- tbl[sort.list(tbl$compati),]
  xxx_trc <- tbl$compati
} else {
  tbl     <- tbl[sort.list(tbl$volatii),]
  xxx_trc <- tbl$volatii
}
tll2      <- tbl[grep(regexp,names(tbl))] # extract certain dataset
tll3      <- tll2 / tbl$ref
col2      <- rainbow(ncol(tll_ree2))
pch2      <- c(1,1,1,2,3,4)
lty2      <- c(1,1,1,2,3,4)
cex2      <- c(0.7)
ylim2     <- c(0.001,10)
legend2   <- names(tll_ree2)
par(mfrow=c(2,1))
par(mar=c(2.5,3,0,0))
matplot(ylim=ylim2, log="y", xaxt="n", yaxt="n", xlab="" ,ylab="[Z] over CI",
         xxx_ree,tll_ree2,type="o",col=col2,pch=pch2,lty=lty2)
abline(h=c(1),col="gray",lty=2)
axis(1,at=xxx_ree,labels=tbl_ree$element,cex.axis=0.9,las=2)
axis(2,axTicks(2),axTicks(2))
legend("bottomright",legend=legend2,col=col2,pch=pch2,lty=lty2,cex=cex2,ncol=5)
par(mar=c(2.5,3,0,0))
matplot(ylim=ylim2,log="y",xaxt="n",yaxt="n",xlab="",ylab="[Z] over CI",
         xxx_trc,tll3,type="o",col=col2,pch=pch2,lty=lty2)
abline(h=c(1),col="gray",lty=2)
axis(1,at=xxx_trc,labels=tbl$element,cex.axis=0.9,las=2)
axis(2,axTicks(2),axTicks(2))
#
dev.off()
