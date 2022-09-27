
opnmfR_ranksel_perm_boot <- function(X, rs, W0=NULL, use.rcpp=TRUE, nperm=1, boot=TRUE, nboot=1,
                                plots=TRUE, fact=TRUE, seed=NA, rtrue=NA, ...) {
  stopifnot(ncol(X)>=max(rs))
  start_time <- Sys.time()
  
  # original data
  cat("original data... ")
  nn <- list()
  mse <- list()
  if(is.na(seed)) seed <- sample(1:10^6, 1)
  if(boot) {
    mse <- vector(mode = "list", length = length(rs))
   
    for (b in 1:nboot) {
      set.seed(seed+b)
      nn[[b]] <- list()
      Xboot <- X[ ,sample(ncol(X), replace = TRUE)]
      for (r in 1:length(rs)) {
        if(use.rcpp) {
          
          nn[[b]]$boot[[r]] <- opnmfR::opnmfRcpp(Xboot, rs[r], W0=W0, ...)
        }   else {
        
          nn[[b]]$boot[[r]] <- opnmfR::opnmfR(Xboot, rs[r], W0=W0, ...)
        }
        
        cat("orig", "rank:", r, "Bootstrap", b, "iter:", nn[[b]]$boot[[r]]$iter, 
            "time:", nn[[b]]$boot[[r]]$time, "diffW:", nn[[b]]$boot[[r]]$diffW, "\n")
        #mse[[r]] <- list()
        #mse[[r]]$orig <- rep(NA,length(nboot))
        mse[[r]]$orig[b] <- opnmfR::opnmfR_mse(Xboot, nn[[b]]$boot[[r]]$W, nn[[b]]$boot[[r]]$H)
      }
    }
    cat("done\n")
    
  } else {

    for(r in 1:length(rs)) {
      if(use.rcpp) {
        nn[[r]] <- opnmfR::opnmfRcpp(X, rs[r], W0=W0, ...)
      } else {
        nn[[r]] <- opnmfR::opnmfR(X, rs[r], W0=W0, ...)
      }
      
      cat("orig", "rank:", r, "iter:", nn[[r]]$iter, "time:", nn[[r]]$time, 
          "diffW:", nn[[r]]$diffW, "\n")
      
      mse[[r]] <- list()
      mse[[r]]$orig <- opnmfR::opnmfR_mse(X, nn[[r]]$W, nn[[r]]$H)
  }

  }
  cat("done\n")
  
  # permuted data
  cat("permuted data... ")
  for(p in 1:nperm) {
    set.seed(seed+p)
    Xperm <- apply(X,2,sample) # permute the rows in each column
    for(r in 1:length(rs)) {
      if(use.rcpp) {
        nnp <- opnmfR::opnmfRcpp(Xperm, rs[r], W0=W0, ...)
      } else {
        nnp <- opnmfR::opnmfR(Xperm, rs[r], W0=W0, ...)
      }
      
      cat("perm", p, "rank:", r, "iter:", nnp$iter, "time:", nnp$time,"diffW:", nnp$diffW, "\n")
      mse[[r]]$perm <- c(mse[[r]]$perm, opnmfR_mse(Xperm, nnp$W, nnp$H))
    }
  }
  cat("done\n")
  
  names(mse) <- rs
  names(nn) <- rs
  if(boot) {
    mseorig <- sapply(mse, function(xx) mean(xx$orig))
  } else {
    mseorig <- sapply(mse, function(xx) xx$orig)
  }
 
  mseperm <- sapply(mse, function(xx) mean(xx$perm))
  mseorig <- mseorig / max(mseorig)
  mseperm <- mseperm / max(mseperm)
  
  sel <- which(diff(mseorig) > diff(mseperm))
  selr <- rs[sel]
  
  if(plots) {
    maxi <- max(c(mseorig, mseperm))
    mini <- min(c(mseorig, mseperm))
    
    plot(NA, xlim=c(min(rs),max(rs)), ylim=c(mini,maxi), xlab="Rank", ylab="MSE (scaled)")
    points(rs, mseorig, type='b', pch=16)
    points(rs, mseperm, type='b', pch=17, lty=2)
    points(selr, mseorig[sel], cex=2, pch=1, lwd=2, col="red")
    if(!is.na(rtrue)) abline(v=rtrue, lty=2, col="gray")
    legend("bottomleft", legend = c("Orig.","Perm."), pch=16:17)
    title(main="Permutation", sub=paste("Selected rank = ", min(selr)))
  }
  
  if(fact) {
    fact <- nn
  } else {
    fact <- nn[sel]
  }
  
  end_time <- Sys.time()
  tot_time <- end_time - start_time
  
  return(list(mse=mse, selected=selr, factorization=fact, time=tot_time, seed=seed))
  
}