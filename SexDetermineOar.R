args=(commandArgs(TRUE))
Samtools_Location <- "samtools"
numthreads <- 12
IDX_Location <- 0

InputFileType <-as.character(args[1])
Input_Location <- as.character(args[2])
ApplyQF <- as.character(args[3])

if(is.na(ApplyQF)){
  ApplyQF <- 0 
}


if (InputFileType == "-bam"){
  BAM_Location <- Input_Location
} else if (InputFileType == "-idx"){
  IDX_Location <- Input_Location
} else {
  stop("Wrong File Type Paramateter")
}

if (file.exists(Input_Location) == 0){
  stop("Wrong Filename or Path")
}


if (IDX_Location != 0){
  idx <- read.table(IDX_Location,nrows=27,row.names = 1)
  templist <- strsplit(IDX_Location, split = "/")
  IDX <- sapply(templist, tail, 1)
  PREFIX <- strsplit(IDX, split =".idxstats")
  PREFIX <- as.character(PREFIX)
  
  templist2 <-  strsplit(PREFIX, split = "_")
  templist3 <- lapply(templist2, function(x) x[1])
  templist3 <- as.character(templist3)
  
  Sample <-  strsplit(templist3, split = "-")
  Sample <- lapply(templist3, function(x) x[1])
  Sample <- as.character(Sample)
} else {
  templist <- strsplit(BAM_Location, split = "/")
  BAMFILE <- sapply(templist, tail, 1)
  PREFIX <- strsplit(BAMFILE, split =".bam")
  PREFIX <- as.character(PREFIX)
  
  templist2 <-  strsplit(PREFIX, split = "_")
  templist3 <- lapply(templist2, function(x) x[1])
  templist3 <- as.character(templist3)
  
  Sample <-  strsplit(templist3, split = "-")
  Sample <- lapply(templist3, function(x) x[1])
  Sample <- as.character(Sample)
  
  if (ApplyQF == 0) {
    IDXFILE <- paste(PREFIX,'idxstats',sep='.')
    run_idx=paste(Samtools_Location,"idxstats","-@",numthreads,BAM_Location,">",IDXFILE,sep=' ')
    system(run_idx)
    idx <- read.table(IDXFILE,nrows=27,row.names = 1)
    remover <- paste("rm",IDXFILE,sep = ' ')
    system(remover)
  } else {
    QSample <- paste(Sample,"Q",sep = '_')
    QBAMFILE <- paste(QSample,"bam",sep = '.')
    QIDXFILE <- paste(QSample,'idxstats',sep='.')
    QualityFilter = paste(Samtools_Location,"view","-@",numthreads,"-q 30 -b",BAM_Location,">",QBAMFILE,sep = ' ')
    system(QualityFilter)
    Indexer = paste(Samtools_Location,"index",QBAMFILE,sep = ' ')
    system(Indexer)
    run_idx=paste(Samtools_Location,"idxstats","-@",numthreads,QBAMFILE,">",QIDXFILE,sep=' ')
    system(run_idx)
    run_idx=paste(Samtools_Location,"idxstats","-@",numthreads,QBAMFILE,"| awk '$1 ~ /^[1-9]$|^1[0-9]$|^2[0-6]$|^X$/' | sort  -k1,1V >",QIDXFILE,sep=' ')
    system(run_idx)
    
    idx <- read.table(QIDXFILE,nrows=27,row.names = 1)
    remover <- paste("rm",QIDXFILE,sep = ' ')
    system(remover)
    remover <- paste("rm",QBAMFILE,sep = ' ')
    system(remover)
    remover <- paste("rm",paste(QBAMFILE,"bai",sep = '.'),sep = ' ')
    system(remover)
  }
}
TotalRead <- sum(idx$V3)
idx$ReadsOverLength <- idx$V3/idx$V2
temp1  <- idx[-27,]
Xreads <- idx[27,"V3"]


# Rx 
Xratio <- idx[27,"ReadsOverLength"]
temp1$Rx <- Xratio/temp1$ReadsOverLength

Rxs <- temp1$Rx
sdrx <- sqrt(sum((Rxs - mean(Rxs)) ^ 2 / (length(Rxs) - 1)))
SErx <- sdrx/sqrt(length(Rxs)) 
Rx <- mean(Rxs)
LRx <- Rx - 1.96*SErx
URx <- Rx + 1.96*SErx

if (Rx =="Inf" || Rx =="NaN"){
  Rxsex = "NA"
} else {
  if (LRx > 0.65) {
    Rxsex = "XX"
  } else if (URx < 0.5) {
    Rxsex = "XY"
  } else if (LRx > 0.5 && URx > 0.65) {
    Rxsex = "XX?"
  } else if (LRx < 0.5 && URx < 0.65) {
    Rxsex = "XY?"
  } else {
    Rxsex = "NA"
  }
}



cat("Sample: ",Sample," Total Reads: ",TotalRead," Xreads: ",Xreads," Rx: ",Rx," Rx 95% CI: ",LRx,"-",URx," Rx Sex: ",Rxsex,"\n")
