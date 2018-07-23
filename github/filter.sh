cd /home/ubuntu/github/temp
rm *.md

chmod -R 775 temp
for file in *.*
do
grep -v '#' $file > temp
cat temp > $file
done
