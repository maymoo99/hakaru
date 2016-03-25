kernelopts(assertlevel=2): # be strict on all assertions while testing
kernelopts(opaquemodules=false): # allow testing of internal routines
if not (NewSLO :: `module`) then
  WARNING("loading NewSLO failed");
  `quit`(3);
end if;

with(NewSLO):

#####################################################################
#
# plate/array tests
#
#####################################################################

triv := Plate(ary(k, i, Ret(i))):
TestHakaru(triv, Ret(ary(k, i, i)), label="Dirac Plate");

ary0 := Bind(Plate(ary(k, i, Gaussian(0,1))), xs, Ret([xs])):
TestHakaru(ary0, ary0, label="plate roundtripping", ctx = [k::nonnegint]);

ary1  := Bind(Gaussian(0,1), x,
         Bind(Plate(ary(n, i, Weight(density[Gaussian](x,1)(idx(t,i)), Ret(Unit)))), ys,
         Ret(x))):
ary1w := 2^(-(1/2)*n+1/2)*exp((1/2)*((sum(idx(t,i),i=1..n))^2-(sum(idx(t,i)^2,i=1..n))*n-(sum(idx(t,i)^2,i=1..n)))/(n+1))*Pi^(-(1/2)*n)/sqrt(2+2*n):
TestHakaru(ary1, 
  Weight(ary1w, Gaussian((sum(idx(t, i), i = 1 .. n))/(n+1), 1/sqrt(n+1))),
  label="Wednesday goal", ctx = [n::nonnegint]);
TestHakaru(Bind(ary1, x, Ret(Unit)), Weight(ary1w, Ret(Unit)), 
  label="Wednesday goal total", ctx = [n::nonnegint]);
ary2  := Bind(Gaussian(0,1), x,
         Bind(Plate(ary(n, i, Bind(Gaussian(idx(t,i),1),z, Weight(density[Gaussian](x,1)(idx(t,i)), Ret(z+1))))), ys,
         Ret(ys))):
TestHakaru(ary2, 
  Weight(ary1w, Bind(Plate(ary(n, i, Gaussian(idx(t,i),1))), zs, Ret(ary(n, i, idx(zs,i)+1)))), 
  label="Reason for fission", ctx = [n::nonnegint]);
ary3  := Bind(Gaussian(0,1), x,
         Bind(Plate(ary(n, i, Bind(Gaussian(idx(t,i),1),z, Weight(density[Gaussian](x,1)(idx(t,i)), Ret(z))))), zs,
         Ret(zs))):
TestHakaru(ary3, Weight(ary1w, Plate(ary(n, i, Gaussian(idx(t,i),1)))),
  label="Array eta", ctx = [n::nonnegint]);

bry1  := Bind(BetaD(alpha,beta), x,
         Bind(Plate(ary(n, i, Weight(x    ^piecewise(idx(y,i)=true ,1) *
                                     (1-x)^piecewise(idx(y,i)=false,1),
                              Ret(Unit)))), ys,
         Ret(x))):
bry1s := Weight(Beta(alpha+sum(piecewise(idx(y,i)=true ,1), i=1..n),
                     beta +sum(piecewise(idx(y,i)=false,1), i=1..n))/Beta(alpha,beta),
         BetaD(alpha+sum(piecewise(idx(y,i)=true ,1), i=1..n),
               beta +sum(piecewise(idx(y,i)=false,1), i=1..n))):
TestHakaru(bry1, bry1s, 
  label="first way to express flipping a biased coin many times (currently fails)",
  ctx = [n::nonnegint]);

bry2  := Bind(BetaD(alpha,beta), x,
         Bind(Plate(ary(n, i, Weight(x    ^(  idx(y,i)) *
                                     (1-x)^(1-idx(y,i)),
                              Ret(Unit)))), ys,
         Ret(x))):
bry2s := Weight(Beta(alpha+  sum(idx(y,i),i=1..n),
                     beta +n-sum(idx(y,i),i=1..n))/Beta(alpha,beta),
         BetaD(alpha+  sum(idx(y,i),i=1..n),
               beta +n-sum(idx(y,i),i=1..n))):
TestHakaru(bry2, bry2s, 
  label="second way to express flipping a biased coin many times", 
  ctx = [n::nonnegint]);

fission     := Bind(Plate(ary(k, i, Gaussian(0,1))), xs, Plate(ary(k, i, Gaussian(idx(xs,i),1)))):
fusion      := Plate(ary(k, i, Bind(Gaussian(0,1), x, Gaussian(x,1)))):
conjugacies := Plate(ary(k, i, Gaussian(0, sqrt(2)))):
TestHakaru(fission, conjugacies, label="Reason for fusion (currently fails)"); # This currently (2016-03-21) fails
TestHakaru(fusion,  conjugacies, label="Conjugacy in plate");

# Simplifying gmm below is a baby step towards index manipulations we need
# gmm is not tested?
gmm := Bind(Plate(ary(k, c, Gaussian(0,1))), xs,
       Bind(Plate(ary(n, i, Weight(density[Gaussian](idx(xs,idx(cs,i)),1)(idx(t,i)), Ret(Unit)))), ys,
       Ret(xs))):
