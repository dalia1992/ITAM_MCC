#!/usr/bin/env bash

strategies='hybrid interrupt polling'
fun='constante'
ndev='3'
wait_times='5.000000e-03 4.250000e-03 3.612500e-03 3.070625e-03 2.610031e-03 2.218527e-03 1.885748e-03 1.602885e-03 1.362453e-03 1.158085e-03 9.843720e-04 8.367162e-04 7.112088e-04 6.045275e-04 5.138483e-04 4.367711e-04 3.712554e-04 3.155671e-04 2.682320e-04 2.279972e-04 1.937977e-04 1.647280e-04 1.400188e-04 1.190160e-04 1.011636e-04 8.598905e-05 7.309069e-05 6.212709e-05 5.280802e-05 4.488682e-05 3.815380e-05 3.243073e-05 2.756612e-05 2.343120e-05 1.991652e-05 1.692904e-05 1.438969e-05 1.223123e-05 1.039655e-05 8.837066e-06 7.511506e-06 6.384780e-06 5.427063e-06 4.613004e-06 3.921053e-06 3.332895e-06 2.832961e-06 2.408017e-06 2.046814e-06 1.739792e-06 1.478823e-06 1.257000e-06 1.068450e-06 9.081824e-07 7.719550e-07 6.561618e-07 5.577375e-07 4.740769e-07 4.029653e-07 3.425205e-07 2.911425e-07 2.474711e-07 2.103504e-07 1.787979e-07 1.519782e-07 1.291815e-07 1.098042e-07 9.333360e-08 7.933356e-08 6.743353e-08 5.731850e-08 4.872072e-08 4.141262e-08 3.520072e-08 2.992061e-08 2.543252e-08 2.161764e-08 1.837500e-08 1.561875e-08 1.327594e-08 1.128455e-08 9.591863e-09 8.153084e-09 6.930121e-09 5.890603e-09 5.007013e-09 4.255961e-09 3.617567e-09 3.074932e-09 2.613692e-09 2.221638e-09 1.888392e-09 1.605134e-09 1.364364e-09 1.159709e-09 9.857526e-10 8.378897e-10 7.122063e-10 6.053753e-10 5.145690e-10 4.373837e-10 3.717761e-10 3.160097e-10 2.686083e-10 2.283170e-10 1.940695e-10 1.649590e-10 1.402152e-10 1.191829e-10 1.013055e-10 8.610965e-11 7.319320e-11 6.221422e-11 5.288209e-11 4.494978e-11 3.820731e-11 3.247621e-11 2.760478e-11 2.346406e-11 1.994445e-11 1.695279e-11 1.440987e-11 1.224839e-11 1.041113e-11 8.849460e-12 7.522041e-12 6.393735e-12 5.434675e-12 4.619474e-12 3.926553e-12 3.337570e-12 2.836934e-12 2.411394e-12 2.049685e-12 1.742232e-12 1.480897e-12 1.258763e-12 1.069948e-12 9.094561e-13 7.730377e-13 6.570821e-13 5.585197e-13 4.747418e-13 4.035305e-13 3.430009e-13 2.915508e-13 2.478182e-13 2.106455e-13 1.790486e-13 1.521913e-13 1.293626e-13 1.099582e-13 9.346451e-14'
bfsz='1000'
poc='80'
t='0.2'

hyph="_"
dev='devs'
mtime='maxtime'
bfz='buffer'
wtime='wtime'
poccup='poccup'

for strategy in $strategies
 do
 for wt in $wait_times
  do
  exp=$fun$hyph$strategy$hyph$dev$ndev$hyph$mtime$t$hyph$bfz$bfsz$hyph$wtime$wt$hyph$poccup$poc
  python apps.py --experiment $exp &
  python kernel.py --experiment $exp --calendar $strategy --sz 100 --perc_occup 80&
  python device.py --experiment $exp --fun constante --dev 3 --wait $wt --maxtime 0.2
 done
done
echo All done

