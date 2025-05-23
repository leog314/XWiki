# **Wikipedia comes to your calculator!**

<img src="https://github.com/leog314/XWiki/blob/main/build/media/wiki.gif?raw=true" width="500">

## **General:**

XWiki is a portable knowledge source for the TI-nspire calculator series written in Lua. It compresses a short summary of the 1000 most vital articles in English Wikipedia.

<img src="https://github.com/leog314/XWiki/blob/main/build/media/wiki1.png?raw=true" width="320"> <img src="https://github.com/leog314/XWiki/blob/main/build/media/wiki2.png?raw=true" width="320"> <img src="https://github.com/leog314/XWiki/blob/main/build/media/wiki3.png?raw=true" width="320">

## **Input and Controls:**

To search something use the keypad for typing in the article name. After that press "enter" or use the handheld's cursor to select an article.
You will be redirected to the article, if it's available, otherwise the most promissing page will open.

By pressing the "return" key you get redirected to a randomly chosen article.

Any page consists of a text editor, where you can read the content of the article. Usually the content is a five sentence summary of the Wikipedia article.
Switch back to the homescreen by pressing "esc".

You can change the background color (=switch to dark/light mode) using "tab".
Characters (in the search bar) can be deleted using "del" (deletes last char) or "clear" (clears the search bar).

## **Cleanbuilding the project**

If you want to load articles that you find interesting, just modify the contents of source/articles.txt. Make sure that every keyword in that file is the title of an **actual** Wikipedia article.
For next step you'll need some python libraries:

    pip install wikipedia-api nltk

Then execute the source/creator.py file. Once this program ran through all of the articles, which might take a while, the contents of source/database.lua should have changed.
After that you only need to run the source/combiner.sh script and you will find a new wiki.tns file in the build directory.
In summary use something like this:

    # Modify source/articles.txt by adding valid article names
    python creator.py
    # ...wait until the program finishes
    source/combiner.sh
    # transfer wiki.tns to your calculator and have fun :)

Note: This was only tested on Linux.

## **Last remarks**

The project is open source, you can load your own articles and modify the GUI, if you want to. Please just mention this project, if you do so.

Anyway, I am not in any means responsible for the contents of this wiki nor of it's modifications. While discusting content should have been filtered out to some degree, this isn't guaranteed. You use the app at your own risk!

*This project used 'Better Lua Api' by adriweb + contributors and Luna by Vogtinator + contributors.*