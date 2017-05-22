plot_effects <- function(obj){
  d_T <- density(obj$Y11-obj$Y00)
  d_I <- density(obj$Y11-obj$Y10)
  d_D <- density(obj$Y10-obj$Y00)
  xrange <- c(min(c(d_T$x, d_I$x, d_D$x)),max(c(d_T$x, d_I$x, d_D$x)))
  yrange <- c(min(c(d_T$y, d_I$y, d_D$y)),max(c(d_T$y, d_I$y, d_D$y)))
  plot(d_T, main="Posterior Distributions of the Effects", col="black", xlim=xrange, ylim=yrange, xlab="")
  lines(d_I, col="red")
  lines(d_D, col="blue")  
  legend("topright", c("ETE","ENIE","ENDE"), fill=c("black","red","blue"))
}