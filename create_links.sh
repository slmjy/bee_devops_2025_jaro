mkdir ~/test
echo "Ahoj" > ~/test/hello.txt
ln -s ~/test/hello.txt /tmp/softlink
ln ~/test/hello.txt /tmp/hardlink