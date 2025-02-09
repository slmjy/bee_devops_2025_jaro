echo "Spusten script LOG"
#------------------------
echo "Vložený text - datum a čas: $(date)" >> log_lekce5.log

ln -s log_lekce5.log /tmp/softlink_log.txt
#OK
ln log_lekce5.log /tmp/hardlink_log.txt
#ln: failed to create hard link '/tmp/hardlink_log.txt' => 'log_lekce5.log': Invalid cross-device link
echo "Ukoncen script LOG"
