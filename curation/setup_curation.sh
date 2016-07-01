###### GLOBAL SETUP

if [ -f "reference/REL606.L20.G15.P0.M35.mask.gd" ];
then
  ## Make table of masked regions
  mummer -maxmatch -b -c -l 20 reference/REL606.fna reference/REL606.fna > ../../reference/input.coords
  gdtools mummer2mask -g 15 -p 0 -m 35 -r ../../reference/REL606.fna -o ../../reference/REL606.L20.G15.P0.M35.mask.gd ../../reference/input.coords
  rm ../../reference/input.coords

  ## Add the 7 x 4 bp repeat as a masked region
  echo "MASK	.	.	REL606	2103889	31	note=manually added\n" >> ../../REL606.L20.G15.P0.M35.mask.gd
fi


###### PER-POPULATION SETUP

## copy over appropriate ancestor
perl batch_run.pl -p Ara- "cp ../../LTEE-clone-curated/Anc-_0gen_REL606.gd ."
perl batch_run.pl -p Ara+ "cp ../../LTEE-clone-curated/Anc+_0gen_REL607.gd ."
perl batch_run.pl -p MAE "cp ../../LTEE-clone-curated/Anc+_REL1207.gd ."
