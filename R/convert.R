
run_convert<-function(infile="midcorout.csv",outfile='smprow'){
  write("",outfile);
  rada<-read.table(infile, sep=",");   # read experimental data
  tit<-data.frame(lapply(rada[1,], as.character), stringsAsFactors=FALSE)
  rada<- droplevels(rada[-1,])
  print(tit)
        abund<- grep("concentration", tit)  # calculated fractions of isotopologs
        colmet<- grep("Metab", tit)  # column of metabolite name
        colfrg<- grep("atomic", tit)  # carbon positions in the fragment
        coltrac<- grep("tracer", tit)  # carbon positions in the fragment
        colab<- grep("labell", tit)  # carbon positions in the fragment
        colfr<- grep("abundance", tit)[1]  # carbon positions in the fragment
        colcel<- grep("cells", tit)  # carbon positions in the fragment
        coltim<- grep("time", tit)  # carbon positions in the fragment
    levtrac<-levels(rada[,coltrac][drop=T])
    levlpos<-levels(rada[,colab][drop=T])
    levabun<-levels(rada[,colfr][drop=T])
   for(trlev in levtrac){ iso<- 0; abun<- 0 # select tracer
        trc<- subset(rada,trlev==rada[,coltrac])
        if(nchar(trlev)>3){
         llev <- as.character(trc[1,colab])
          a<- strsplit(llev,',')[[1]]
          ara<- length(a)-which(grepl('1',a))
          for(il in 1:length(ara)) iso<- iso+2**ara[il]
          abun <- as.numeric(as.character(trc[1,colfr]))/100.
        }
        write(paste("TRACER:",trlev,iso,abun),outfile,append=T)
        levcel<-levels(trc[,colcel][drop=T])
   for(celev in levcel){ # select cells
        cll<- subset(trc,celev==trc[,colcel])
        write(paste("CELLS:",celev),outfile,append=T);
        levmet<- levels(cll[,colmet][drop=T])
   for(mlev in levmet){ # select metabolite
        met<- subset(cll,mlev==cll[,colmet])
        levfr<- levels(met[,colfrg][drop=T]) 
    for(frlev in levfr){ # select fragment
        tot<-data.frame();
        metfr<- subset(met,frlev==met[,colfrg])
       pCf<-gregexpr("C",frlev)[[1]]; # C-position in formula
       iCb<- as.numeric(substr(frlev,pCf[1]+1,pCf[1]+1))-1
       iCe<- as.numeric(substr(frlev,pCf[2]+1,nchar(frlev)))-1
       nCfrg<- iCe-iCb+1
        write(paste(paste("name:",mlev),iCb,iCe,sep=','),outfile,append=T);
        levtim<- levels(metfr[,coltim][drop=T])
    for(tilev in levtim){ # select fragment
        metfrt<- subset(metfr,tilev==metfr[,coltim])
        if(nchar(tilev)>0) write(paste("t=",tilev),outfile,append=T) else
         write("t= 0",outfile,append=T)
        levsmp<- levels(metfrt[,1][drop=T])
     for(smplev in levsmp){ # select sample
        df<- data.frame()
        smp<- subset(metfrt,(smplev==metfrt[,1])&(!grepl('-1',metfr[,abund-1])))
        dis<- as.numeric(as.character(smp[,abund]))
        df[1,1]<- smp[1,1];
        for(idis in 1:(nCfrg+1)) df[1,1+idis]<- round(dis[idis],4)
    tot<- rbind(tot,df)
      	   }
   write.table(tot,outfile,sep=",",append=T,col.names=FALSE, row.names = F);
          }
         }
        }
       }
      }
}
#   write.table(tot,outfile,sep=",",append=TRUE,col.names=FALSE, row.names = F);

msdlist<-function(trati) { nln<-length(trati)
        ntrati<-lapply(strsplit(trati, " "),as.numeric)
        lnumv<-!lapply(ntrati,is.na)[[1]]
        mdis<-matrix(ncol=length(ntrati[[1]][lnumv]),nrow=nln,0)
        mdis[1,]<-ntrati[[1]][lnumv]
      if(nln>1)for(i in 2:nln){
        lnumv<-!lapply(ntrati,is.na)[[i]]
        mdis[i,]<-ntrati[[i]][lnumv]
      } 
        mval<-round(apply(mdis,2,mean),4)
        sdv<-round(apply(mdis,2,sd))
 return(list(mval,sdv))}
 
 vybor<-function(spis,obr){
 	lspis<-grepl(obr,spis)
 return(spis[lspis]) }
 
 isoform<-function(isofi='smprow'){
        cntn<-readLines(isofi)
        rowtrac<-grep('TRAC',cntn)
        rowtrac<-c(rowtrac,length(cntn)+1)
    for(itr in 1:(length(rowtrac)-1))
      if(nchar(cntn[rowtrac[itr]])>15){
       atr<-cntn[rowtrac[itr]:(rowtrac[itr+1]-1)]
       trspl<- strsplit(atr[1],' ')[[1]]
       rowcel<- grep('CELL',atr)
       rowcel<- c(rowcel,length(atr)+1)
      for(icel in 1:(length(rowcel)-1)){
        acel<- atr[rowcel[icel]:(rowcel[icel+1]-1)]
        celspl<- strsplit(acel[1],' ')[[1]]
         fi<-paste(celspl[2],trspl[2],sep='')
         write("",fi);
         rowname<- grep('name',acel)
         rowname<- c(rowname,length(acel)+1)
       for(ina in 1:(length(rowname)-1)){
          aname<- acel[rowname[ina]:(rowname[ina+1]-1)]
          naspl<- strsplit(aname[1],' ')[[1]]
          write(naspl[2],fi,append=T);
          rowti<- grep('t=',aname)
          rowti<- c(rowti,length(aname)+1)
         for(iti in 1:(length(rowti)-1)){
           ati<- aname[rowti[iti]:(rowti[iti+1]-1)]
          write(ati[1],fi,append=T);
           tispl<- strsplit(ati,',')
           dis<- matrix(nrow=length(ati)-1,ncol=length(tispl[[2]])-1)
           for(i in 1:nrow(dis)) dis[i,1:ncol(dis)]<-as.numeric(tispl[[i+1]][2:(ncol(dis)+1)])
           mdis<- apply(dis,2,mean)
           sdis<- apply(dis,2,sd)
          write.table(round(t(mdis),3),fi,append=T, col.names = F, row.names = F);
          write.table(round(t(sdis),3),fi,append=T, col.names = F, row.names = F);
         }
       }
      }
     }
        
}
