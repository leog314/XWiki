cd source
cat *.lua >> XWiki.lua
cd ..
mv source/XWiki.lua build
./luna build/XWiki.lua build/wiki.tns