#' Posterior Samples of the Outcomes
#' 
#' Obtain posterior sampels of the outcomes, E[Y1] and E[Y0].
#' @param obj1 The fitted model of the observed data under Z=1 from DPdensity
#' @param obj0 The fitted model of the observed data under Z=0 from Dpdensity
#' @param q A dimension of the observed data, i.e., number of covariates plus 2
#' @return Y1 Posterior samples of E[Y1]
#' @return Y0 Posterior samples of E[Y0]
#' @return TMean The posterior mean of the total effect
#' @return TCI 95\% C.I. of the total effect
#' @export

OutSamples <- function(obj1, obj0, q){
  obj1.dim <- dim(obj1$save.state$randsave)[2]-(q*(q+1)/2+2*q-1)
  obj0.dim <- dim(obj0$save.state$randsave)[2]-(q*(q+1)/2+2*q-1)
  MCMC <- dim(obj0$save.state$randsave)[1]
  Y1 <- apply(obj1$save.state$randsave[,seq(1, obj1.dim, by=(q*(q+1)/2+q))], 1, mean)
  Y0 <- apply(obj0$save.state$randsave[,seq(1, obj0.dim, by=(q*(q+1)/2+q))], 1, mean)
  z <- list(Y1=Y1, Y0=Y0)
  class(z) <- "Posterior"
  zz <- list(TMean=mean(Y1-Y0), TCI=c(sort(Y1-Y0)[MCMC*0.025],sort(Y1-Y0)[MCMC*0.975]))
  return(c(z,zz))
}