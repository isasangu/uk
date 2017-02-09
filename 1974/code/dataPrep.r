# Fuente de los datos: http://www.politicsresources.net/

rm(list = ls())
setwd("/home/eric/Dropbox/data/elecs/uk/1974/data/")
#setwd("/home/lobo/Github/uk/1974/data/")

# lee datos brutos
feb <- read.csv("uk1974febRaw.csv", stringsAsFactors = FALSE)
oct <- read.csv("uk1974octRaw.csv", stringsAsFactors = FALSE)
incumb<-read.csv("Ganadores.csv", stringsAsFactors = FALSE)

# funcion para procesar los datos
procesa <- function(X = NULL){
    X$constituency <- gsub("&amp;", "and", X$constituency) # limpia nombre del distrito
    X$turnout <- X$turnout/100
    # distritos norirlandeses
    sel <- grep("Antrim North|Antrim South|Armagh|Belfast East|Belfast North|Belfast South|Down North|Down South|Fermanagh and South Tyrone|Londonderry|Ulster Mid", X$constituency)
    X$norirl <- 0; X$norirl[sel] <- 1
    # así se hace en R un by yr mo: egen tmp=sum(invested) de stata
    X$vtot <- ave(X$v, as.factor(X$constituency), FUN=sum, na.rm=TRUE)
    X$ncand <- ave(X$n, as.factor(X$constituency), FUN=function(x) length(x), na.rm=TRUE)
    X$v3 <- X$v2 <- X$v1 <- 0
    X$p3 <- X$p2 <- X$p1 <- NA
    X$c3 <- X$c2 <- X$c1 <- NA
    # extrae votos del 2do, 3ero
    for (i in 1:max(X$n)){
        #i <- 1 #debug
        sel <- which(X$n==i)
        tmp <- nrow(X[sel,])
        X$v1[sel] <- sort(X$v[sel], partial = tmp)[tmp]    # partial saves computing time
        X$c1[sel] <- X$name[sel][which(X$v[sel]==X$v1[sel][1])]
        X$p1[sel] <- X$party[sel][which(X$v[sel]==X$v1[sel][1])]
        if (X$ncand[sel][1]==1) next
        X$v2[sel] <- sort(X$v[sel], partial = tmp-1)[tmp-1]
        X$c2[sel] <- X$name[sel][which(X$v[sel]==X$v2[sel][1])]
        X$p2[sel] <- X$party[sel][which(X$v[sel]==X$v2[sel][1])]
        if (X$ncand[sel][1]==2) next
        X$v3[sel] <- sort(X$v[sel], partial = tmp-2)[tmp-2]
        X$c3[sel] <- X$name[sel][which(X$v[sel]==X$v3[sel][1])]
        X$p3[sel] <- X$party[sel][which(X$v[sel]==X$v3[sel][1])]
    }
    X$voth <- X$vtot - X$v1 - X$v2 - X$v3
    X$sh1 <- X$v1/X$vtot
    X$sh2 <- X$v2/X$vtot
    X$sh3 <- X$v3/X$vtot
    X$shoth <- X$voth/X$vtot
    X <- X[duplicated(X$n)==FALSE,]
    X <- X[,c("n","constituency","region","norirl","status","electorate","turnout","ncand","vtot","v1","v2","v3","voth","sh1","sh2","sh3","shoth","c1","c2","c3","p1","p2","p3")]
    return(X)
    }

# prepara datos de la eleccion de febrero
feb <- procesa(feb)
# prepara datos de la eleccion de octubre
oct <- procesa(oct)

# ARIAN
# FALTA CODIFICAR CUATRO DUMMIES
# feb$i1   = 1 si c1 es incumbent (si ganó el distrito en t-1),   = 0 de otro modo
#feb$i1<-as.numeric(pmatch(feb$c1,incumb[,1], nomatch=0)>0)
# feb$i2   = 1 si c2 es incumbent (si ganó el distrito en t-1),   = 0 de otro modo
#feb$i2<-as.numeric(pmatch(feb$c2,incumb[,1], nomatch=0)>0)
# feb$i3   = 1 si c3 es incumbent (si ganó el distrito en t-1),   = 0 de otro modo
#feb$i3<-as.numeric(pmatch(feb$c3,incumb[,1], nomatch=0)>0)
# feb$ioth = 1 si otro es incumbent (si ganó el distrito en t-1), = 0 de otro modo
#feb$ioth<-as.numeric( !(feb$i1+feb$i2+feb$i3)>0)
incumbent <- function(X=NULL, incu=NULL,colaño=NULL){
  X$i1<-as.numeric(pmatch(X$c1,incu[,colaño], nomatch=0)>0)
  X$i2<-as.numeric(pmatch(X$c2,incu[,colaño], nomatch=0)>0)
  X$i3<-as.numeric(pmatch(X$c3,incu[,colaño], nomatch=0)>0)
  #X$ioth<-as.numeric( !(X$i1+X$i2+X$i3)>0) <- ARIAN: ESTO ESTA MAL, DE ESTE MODO ES COMPLEMENTO... HAY QUE BUSCAR DESDE BASE febRaw SI ALGUN NOMBRE COINCIDE.
  return(X)
}

feb<-incumbent(feb,incumb,1)
oct<-incumbent(oct,incumb,2)

head(feb)

write.csv(feb, file = "uk1974feb.csv", row.names = FALSE)
write.csv(oct, file = "uk1974oct.csv", row.names = FALSE)

# ARIAN: PREPARA codebook.txt que describa las variables de los datos anteriores 


