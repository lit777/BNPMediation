bnpmediation<-function(obj1, obj0, q, NN=10, n1, n0, extra.thin=0){
  
  library(mnormt)
  obj1.dim <- dim(obj1$save.state$randsave)[2]-(q*(q+1)/2+2*q-1)
  obj0.dim <- dim(obj0$save.state$randsave)[2]-(q*(q+1)/2+2*q-1)

  Len.MCMC <- 1:dim(obj0$save.state$randsave)[1]
  if(extra.thin!=0){
    Len.MCMC <- Len.MCMC[seq(1, length(Len.MCMC), extra.thin)]
  }
  
  Ysamples<-OutSamples(obj1, obj0, q)
  Y11 <- Ysamples$Y1[Len.MCMC]
  Y00 <- Ysamples$Y0[Len.MCMC]
  
  mat.given.ij <- function(x, y) ifelse(x <= y, (q-1)*(x-1)+y-x*(x-1)/2, (q-1)*(y-1)+x-y*(y-1)/2) 
  mat <- function(q) outer( 1:q, 1:q, mat.given.ij ) 
  
  pb <- txtProgressBar(min = 0, max = length(Len.MCMC), style = 3)
  
  Y10<-NULL
  
  index<-0
  for(j in Len.MCMC){
    index <- index + 1   
    mu2 <- sapply(seq(2,obj0.dim, by=(q*(q+1)/2+q)), function(x)  obj0$save.state$randsave[j,x[1]:(x[1]+q-2)])
    sigma22 <- sapply(seq(q+q+1,obj0.dim, by=(q*(q+1)/2+q)), function(x)  obj0$save.state$randsave[j,x[1]:(x[1]+(q-1)*(q)/2-1)][mat(q-1)])
    joint0 <- do.call("rbind", replicate(NN, data.frame(sapply(1:n0, function(x) rmnorm(1,mu2[,x],matrix(sigma22[,x],q-1,q-1,byrow=T) )))))
    
    unique.val <- unique(obj1$save.state$randsave[j,seq(1,obj1.dim,by=(q*(q+1)/2+q))])
    unique.ind <- NULL
    unique.prop <- NULL
    for(k in 1:length(unique.val)){
      unique.ind[k] <- which(obj1$save.state$randsave[j,seq(1,obj1.dim,by=(q*(q+1)/2+q))]==unique.val[k])[1]
      unique.prop[k] <- length(which(fit.a.1$save.state$randsave[j,seq(1,obj1.dim,by=(q*(q+1)/2+q))]==unique.val[k]))/n1
    }
    b01 <- NULL
    Weight.num0 <- matrix(nrow=length(unique.val), ncol=n0*NN)
    B0 <- matrix(nrow=length(unique.val),ncol=n0*NN)
    
    t.ind<-0
    for(k in unique.ind){
      t.ind<-1+t.ind
      mu1<-obj1$save.state$randsave[j,(q*(q+1)/2+q)*k-(q*(q+1)/2+q)+1]
      mu2<-obj1$save.state$randsave[j,((q*(q+1)/2+q)*k-(q*(q+1)/2+q)+2):((q*(q+1)/2+q)*k-(q*(q+1)/2+q)+q)]
      sigma1<-obj1$save.state$randsave[j,(q*(q+1)/2+q)*k-(q*(q+1)/2+q)+q+1]
      sigma12<-obj1$save.state$randsave[j,(q*(q+1)/2+q)*k-(q*(q+1)/2+q)+((q+2):(2*q))]
      sigma22<-matrix(obj1$save.state$randsave[j,((q*(q+1)/2+q)*k-(q*(q+1)/2+q)+2*q+1):((q*(q+1)/2+q)*k)][mat(q-1)],q-1,q-1,byrow=TRUE)
      Weight.num0[t.ind,1:(n0*NN)]<-unique.prop[t.ind]*dmnorm(joint0,mu2,sigma22)
      b01[t.ind]<-mu1-sigma12%*%solve(sigma22)%*%t(t(mu2))
      B0[t.ind,1:(n0*NN)]<-sigma12%*%solve(sigma22)%*%t(joint0)
    }
    Weight=apply(Weight.num0, 2, function(x) x/sum(x))
    test <- Weight*(b01+B0)
    Y10[index]<-mean(apply(test, 2, sum))
    Sys.sleep(0.05)
    setTxtProgressBar(pb, index)
  }
  
  z <- list(Y11=Y11, 
            Y00=Y00, 
            Y10=Y10, 
            ENIE=mean(Y11-Y10), 
            ENDE=mean(Y10-Y00), 
            ETE=mean(Y11-Y00), 
            TE.c.i=c(sort(Y11-Y00)[length(Len.MCMC)*0.025],sort(Y11-Y00)[length(Len.MCMC)*0.975]),
            IE.c.i=c(sort(Y11-Y10)[length(Len.MCMC)*0.025],sort(Y11-Y10)[length(Len.MCMC)*0.975]),
            DE.c.i=c(sort(Y10-Y00)[length(Len.MCMC)*0.025],sort(Y10-Y00)[length(Len.MCMC)*0.975]))  
  z$call <- match.call()
  class(z) <- "bnpmediation"
  return(z)
}


