#!/usr/bin/env bash

strategies='hybrid interrupt polling'
outfuns='constante escalonada normal picos poisson'
hyph="_"
dev='devs'
mtime='maxtime'
bfz='buffer'
wtime='wtime'
poccup='poccup'
for fun in $outfuns 
 do
 if [ "$fun" == "constante" ];then
  devices='1 2 3 5 10 25 50 100'
 else
  devices='3'
 fi
 for strategy in $strategies
  do
  for ndev in $devices
   do
    if [ "$ndev" == "3" ] && [ "$fun" == "constante" ];then
     max_times='0.015 0.125 0.5 1'
    else
     max_times='0.125'
    fi
    for t in $max_times
     do
     if [ "$ndev" == "3" ] && [ "$fun" == "constante" ] &&  [ "$t" == "0.125" ]; then
       wait_times='0.000000001 0.0000001 0.000001 0.00001 0.0001 0.001 0.01 0.1 1 2'
       buffer_size='20 50 100 1000'
       perc_occup='95 80 65 50'
     else
      wait_times='0.0000001'
      buffer_size='20'
      perc_occup='80'
     fi
     for wt in $wait_times
      do
      for bfsz in $buffer_size
       do
       for poc in $perc_occup
        do
        exp=$fun$hyph$strategy$hyph$dev$ndev$hyph$mtime$t$hyph$bfz$bfsz$hyph$wtime$wt$hyph$poccup$poc
        echo $exp
        python apps.py --experiment $exp &
        python kernel.py --experiment $exp --calendar $strategy --sz $bfsz --perc_occup $poc&
        python device.py --experiment $exp --fun $fun --dev $ndev --wait $wt --maxtime $t
      done
     done
    done
   done
  done
 done
done
echo All done

