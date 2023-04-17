# Set Env Variables
#####################################

username=kovach3

ENVNAME=py365ht120
ENVDIR=$ENVNAME
flightname=$1
site=$(echo $flightname | cut -d'_' -f 4)
flightdate=$(echo $flightname | cut -d'_' -f 5)
year=$(echo $flightdate | cut -c1-4)
month=$(echo $flightdate | cut -c5-6)
month2=$(expr $month + 1)
date="${year}-${month}"
date2="${year}-0${month2}"

# Set Environment
#####################################

cp /staging/$username/support/NEON/$ENVNAME.tar.gz ./

mkdir $ENVDIR
tar -xzf $ENVNAME.tar.gz -C $ENVDIR
rm $ENVNAME.tar.gz

export PATH=$(pwd)/$ENVDIR:$(pwd)/$ENVDIR/lib:$(pwd)/$ENVDIR/share:$PATH

. $ENVDIR/bin/activate

# Initial Processing Steps
#####################################

mkdir coeffs/
mkdir imagery/
mkdir ${flightname}_all
mkdir ${flightname}_brdf
flightnamefolder=${flightname}_all
brdffolder=${flightname}_brdf

cp /staging/$username/support/NEON/data_pull.py ./
cp /staging/$username/support/NEON/image_correct120.py ./
cp /staging/$username/support/NEON/image_correct_json_generate120_1.py ./
cp /staging/$username/support/NEON/image_correct_json_generate120_2.py ./
cp /staging/$username/support/NEON/image_correct_json_generate120_3.py ./
cp /staging/$username/support/NEON/NEON_Use_Lines.txt ./
cp /staging/$username/support/NEON/trait_estimate.py ./
cp /staging/$username/support/NEON/trait_estimate_json_generate.py ./
cp /staging/$username/support/NEON/trait_models.tar ./ #Subset Traits

mkdir jsons/
mkdir traits/
mkdir trait_models/
traitmodels=trait_models
tar -xf trait_models.tar -C trait_models/ #Subset Traits
#tar -xzf trait_models.tar.gz -C trait_models/ #Full Traits

python ./data_pull.py $site $date $flightdate $(pwd) $flightnamefolder

python ./data_pull.py $site $date2 $flightdate $(pwd) $flightnamefolder

python ./image_correct_json_generate120_1.py $flightname $flightnamefolder $(pwd)

python ./image_correct120.py ic_config_$flightname.json

filelist=$(column -s, -t < NEON_Use_Lines.txt | awk -v var="$flightname" '($1 == var)')
linklist=$(awk -F' ' '{print$2}' <<< "$filelist")
linklist=$(echo $linklist | tr -d '\r')

for g in $linklist; do mv $flightnamefolder/$g $brdffolder; done

python ./image_correct_json_generate120_2.py $flightname $brdffolder $(pwd)

python ./image_correct120.py ic_config_$flightname.json

brdfaddfiles=$(diff -q $flightnamefolder $brdffolder | grep $flightnamefolder | awk '{print substr( $4,1,length($4)-3)}')
difflist=$(awk -F' ' '{print$1}' <<< "$brdfaddfiles")
difflist=$(echo $difflist | tr -d '\r')
brdffile=`ls -d -1 "coeffs/"*brdf_coeffs_.* | head -1`

for i in $difflist; do cp $brdffile "coeffs/"$i"_brdf_coeffs_.json"; done

mv $brdffolder/* $flightnamefolder

python ./image_correct_json_generate120_3.py $flightname $flightnamefolder $(pwd)

python ./image_correct120.py ic_config_$flightname.json 

python ./trait_estimate_json_generate.py $flightname $flightnamefolder $(pwd)

python ./trait_estimate.py trait_config_$flightname.json

mv coeffs/*.json jsons/

# Handle and Resort Output
#####################################

rm -rf $flightnamefolder

rm -rf $brdffolder

mv ic_config_$flightname.json imagery/

tar -cvf ${flightname}_imagery.tar imagery/

rm -r imagery/

mv trait_config_$flightname.json traits/

tar -cvf ${flightname}_traits.tar traits/

rm -rf traits/

tar -cvf ${flightname}_jsons.tar jsons/

rm -rf jsons/

tar -czvf ${flightname}_imagery-jsons-traits.tar.gz ${flightname}_imagery.tar ${flightname}_jsons.tar ${flightname}_traits.tar

mv ${flightname}_imagery-jsons-traits.tar.gz /staging/$username/imagery_output/NEON/

# Remove Files
#####################################

rm -rf $ENVDIR

# rm -r NEON_joblist.txt

rm -r NEON_Use_Lines.txt

rm -rf coeffs/

rm -rf trait_models/

rm -f image_correct_json_generate120_1.py
rm -f image_correct_json_generate120_2.py
rm -f image_correct_json_generate120_3.py

rm -f image_correct120.py

rm -f trait_estimate_json_generate.py

rm -f trait_estimate.py

rm -f trait_models.tar

rm -f trait_models.tar.gz

rm -f data_pull.py

rm -f ${flightname}_traits.tar

rm -f ${flightname}_imagery.tar

rm -f ${flightname}_jsons.tar

rm -f ${flightname}_imagery-jsons-traits.tar

mailx -s '5) Job Done' 8149374272@vtext.com < status.txt

rm -f status.txt

exit

exit