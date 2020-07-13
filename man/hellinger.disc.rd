\name{hellinger.disc}
\alias{hellinger.disc}
\alias{hellinger.boot.disc}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Estimate Mixture Complexity Based on Hellinger Distance
}
\description{
Estimation of the complexity and the component parameters of an underlying discrete mixture based on minimizing the squared hellinger distance to the empirical mass function and comparing the difference in minimized squared distances to a given threshold or two bootstrapped quantiles.
}
\usage{
hellinger.disc(obj, j.max = 10, threshold = "AIC", control = c(trace = 0))

hellinger.boot.disc(obj, j.max = 10, B = 100, ql = 0.025, qu = 0.975,
                    control = c(trace = 0), ...)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{obj}{object of class \code{datMix}.}
      
  \item{j.max}{integer stating the maximal number of components to be considered.}
  
  \item{threshold}{character string in \code{c("AIC", "SBC")} specifying which threshold
    should be used to compare two mixture estimates of complexities \eqn{j} and \eqn{j+1}.}
  
  \item{B}{integer specifying the number of bootstrap replicates.}
  
  \item{ql}{numeric between \eqn{0} and \eqn{1} specifying the lower quantile to which
    the observed value will be compared.}
    
  \item{qu}{numeric between \eqn{0} and \eqn{1} specifying the upper quantile to which
    the observed value will be compared.}  
    
  \item{control}{control list of optimization parameters, see \code{\link[Rsolnp]{solnp}}.}    
    
  \item{\dots}{further arguments passed to the \code{\link[boot]{boot}} function.}
}
\details{

Define the \eqn{order} or \eqn{complexity} of a finite mixture \eqn{F} as the smallest integer \eqn{p}, 
such that its density (read as pmf, as this function only works for discrete mixtures) \eqn{f} can be written as

\eqn{f(x) = w_1*g(x;\theta _1) + \dots + w_p*g(x;\theta _p)}.

To estimate \eqn{p}, \code{hellinger.disc} iteratively increases the assumed order \eqn{j} and finds the "best" estimate for both, the density of a mixture with \eqn{j} and \eqn{j+1} components, by calculating the parameters that minimize the squared hellinger distances to the empirical mass function. Once these parameters are obtained, the difference in squared distances is compared to a predefined \code{threshold}. If this difference is smaller than the threshold, the algorithm terminates and the true order is estimated as \eqn{j}, otherwise \eqn{j} is increased by 1 and the procedure is started over. The available thresholds are defined as \code{"LIC"} (\eqn{2/n}) and \code{"SBC"} (\eqn{log(n)/n}), \eqn{n} being the size of the data.

\code{hellinger.boot.disc} does the same as \code{hellinger.disc} with the exception that the difference is not compared to a predefined threshold but to a value generated by bootstrap. In every iteration (of \eqn{j}), a parametric bootstrap is used to generate \code{B} samples of size \eqn{n} from a \eqn{j} component mixture (given the previously calculated "best" parameter values). For each of the bootstrap samples, again the "best" estimates corresponding to densities with \eqn{j} and \eqn{j+1} components are calculated, as well as the difference in squared hellinger distances from the empirical mass function. The original difference in squared distances is then compared to the \code{ql} and \code{qu} quantiles of the bootstrapped ones; if it lies within this range, \eqn{j} is returned as the order estimate, otherwise \eqn{j} is increased by 1 and the procedure is started over.

To calculate the minimum of the hellinger distance (and the corresponding parameter values), the solver
\code{\link[Rsolnp]{solnp}} is used. As initial values (for \code{\link[Rsolnp]{solnp}}), the data is 
clustered into \eqn{j} groups via \code{\link[cluster]{clara}} and the data corresponding to each group is
given to \code{MLE.function} (if supplied, otherwise numerical optimization is used here as well). The size
of the groups is taken as initial component weights and the MLEs are taken as initial parameter estimates.
}
\value{
Object of class \code{paramEst} with the following attributes

\item{dat}{numeric of underlying data of \code{obj}.}

\item{dist}{character string stating the (abbreviated) name of the component distribution.}

\item{ndistparams}{integer specifying the number of parameters identifying the distribution       
  \code{dist}.}

\item{formals.dist}{string vector specifying the names of the formals identifying the distribution   \code{dist}.}

\item{discrete}{logical indicating whether the underlying mixture distribution is discrete.}

\item{mle.fct}{attribute \code{MLE.function} of \code{obj}.}

\item{pars}{Say \eqn{d = } \code{ndistparams}. Then \code{pars} is a numeric of parameter estimates of size \eqn{(d+1)*p-1}, given as 

\eqn{(w_1, ... w_{p-1}, \theta 1_1, ... \theta 1_p, \theta 2_1, ... \theta d_p)}.}

\item{values}{numeric of function values gone through during optimization, where the last one is the value at the optimum.}

\item{convergence}{indicates whether the solver has converged (0) or not (1 or 2).}
}
\references{
M.-J. Woo and T. Sriram, "Robust estimation of mixture complexity for count data", Computational Statistics and Data Analysis 51, 4379-4392, 2007.

M.-J. Woo and T. Sriram, "Robust Estimation of Mixture Complexity", Journal of the American Statistical Association, Vol. 101, No. 476, 1475-1486, Dec. 2006.
}
\author{
%%  ~~who you are~~
}
\note{
%%  ~~further notes~~
}

%% ~Make other sections like Warning with \section{Warning }{....} ~

\seealso{
\code{\link{L2.disc}} for the same estimation method using the L2 distance, \code{\link[Rsolnp]{solnp}} 
for the solver, \code{\link{datMix}} for the creation of the \code{datMix} object. 
}
\examples{
## create 'Mix' object
poisMix <- Mix("pois", w = c(0.45, 0.45, 0.1), lambda = c(1, 5, 10))


## create random data based on 'Mix' object (gives back 'rMix' object)
set.seed(0)
poisRMix <- rMix(1000, obj = poisMix)


## create 'datMix' object for estimation

# generate list of parameter bounds
poisList <- vector(mode = "list", length = 1)
names(poisList) <- "lambda"
poisList$lambda <- c(0, Inf)

# generate MLE function
MLE.pois <- function(dat){
  mean(dat)
}

# generating 'datMix' object
pois.dM <- RtoDat(poisRMix, param.bound.list = poisList, MLE.function = MLE.pois)


## complexity and parameter estimation 
set.seed(0)
res <- hellinger.disc(pois.dM)
plot(res)

set.seed(0)
res <- hellinger.boot.disc(pois.dM, B = 30)
plot(res)
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{cluster}