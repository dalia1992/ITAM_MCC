library(data.tree)

base_url    <- "https://programminghistorian.org/assets/basic-text-processing-in-r"
url         <- sprintf("%s/sotu_text/236.txt", base_url)
text        <- paste(readLines(url), collapse = "\n")

Huffman <- function(text, Print = FALSE){
  Frequencies <- table(strsplit(text, "")[[1]])
  efun <- environment()
  n <- dim(Frequencies)
  Q <- Frequencies
  for(i in 1:(n-1)){
    Newtree  <- Node$new(paste0("Tree: ", i, " count: ", min(Q)+min(Q[-min(Q)])))
    x.freq   <- min(Q)
    if(substr(names(which.min(Q)),3,3+nchar(n))==""){
      Newtree$AddChild(paste0("Char: ", names(which.min(Q)), " Freq: ", x.freq))
    }else{
      Newtree$AddChildNode(get(
        paste0("Tree_", substr(names(which.min(Q)),3,5)), envir = efun))
    }
    Q        <- Q[-which.min(Q)]
    y.freq   <- min(Q)
    if(substr(names(which.min(Q)),3,5)==""){
      Newtree$AddChild(paste0("Char: ", names(which.min(Q)), " Freq: ", y.freq))
    }else{
      Newtree$AddChildNode(get(
        paste0("Tree_", substr(names(which.min(Q)),3,5)), envir = efun))
    }  
    Q        <- Q[-which.min(Q)]
    z.freq   <- x.freq + y.freq
    Q <- c(Q, z.freq)
    names(Q)[n-i] <- paste0("T_",i)
    if(Print){
      print(Newtree)
    }
    assign(paste0("Tree_",i),Newtree, envir = efun)
  }
  return(get(paste0("Tree_",n-1), envir = efun))
}

getCoding <- function(Tree){
  TravList <- Traverse(Tree,"pre-order")
  N        <- length(TravList)
  char     <- c()
  freq     <- c()
  coding   <- c()
  code     <- ""
  for (i in 1:N) {
    if(TravList[[i]]$isLeaf){
      char   <- c(char, strsplit(TravList[[i]]$name, " ")[[1]][2])
      if(char[length(char)]==""){
        freq   <- c(freq,strsplit(TravList[[i]]$name, " ")[[1]][5])
      }else{
        freq   <- c(freq,strsplit(TravList[[i]]$name, " ")[[1]][4])
      }
      coding  <- c(coding, code)
      if(any(strsplit(code,"")[[1]]=="0")){
        aux     <- max(which(strsplit(code,"")[[1]]=="0"))
        code    <- paste0(substr(code,1,aux-1), "1")
      }
    } else{
      code   <- paste0(code,"0")
    }
  }
  
  CodingList      <- data.frame(cbind("character"=char, "frequency"=freq,
                                      coding),
                                      stringsAsFactors=FALSE)
  CodingList$frequency <- as.numeric(CodingList$frequency)
  CodingList$bits      <- nchar(CodingList$coding)
  CodingList$Nbits     <- CodingList$frequency*CodingList$bits
  CodingList           <- CodingList[order(CodingList$frequency, decreasing = TRUE),]
  return(CodingList)
}

