# **Wikipedia comes to your calculator!**

<img src="https://github.com/leog314/XWiki/blob/main/build/media/wiki_animation.gif?raw=true" width="400">

## **General:**

XWiki is a portable knowledge source for the TI-Nspire calculator series written in Lua. It compresses a short summary of the 1000 most vital articles in English Wikipedia.

<img src="https://github.com/leog314/XWiki/blob/main/build/media/wiki1.png?raw=true" width="270"> <img src="https://github.com/leog314/XWiki/blob/main/build/media/wiki2.png?raw=true" width="270"> <img src="https://github.com/leog314/XWiki/blob/main/build/media/wiki3.png?raw=true" width="270">

## **Input and Controls:**

To search for something use the keypad for typing in the article name. After that press "enter" or use the handheld's cursor to select an article.
You will be redirected to the article, if it's available, otherwise the most promising page will open.

By pressing the "return" key you get redirected to a randomly chosen article.

Any page consists of a text editor, where you can read the content of the article. Usually the content is a five-sentence summary of the Wikipedia article.
Switch back to the homescreen by pressing "esc".

You can change the background color (=switch to dark/light mode) using "tab".
Characters (in the search bar) can be deleted using "del" (deletes last char) or "clear" (clears the search bar).

## **Recompiling the project (add articles)**

If you want to load articles that you find more interesting, just modify the content of source/articles.txt. Make sure that every keyword in that file is the title of an **actual** Wikipedia article.

For the next step you'll need some python libraries installed:

    pip install wikipedia-api nltk

With this execute the source/creator.py file. Once the program finishes, which might take a while, the contents of source/database.lua should have changed.

After that you only need to run the source/combiner.sh script and you will find a new wiki.tns file in the build directory.

Transfer it to your calculator and have fun!

In summary use something like this:

    # Modify source/articles.txt by adding valid article names
    python source/creator.py
    # ... wait until the program finishes
    source/combiner.sh
    # transfer wiki.tns to your calculator and enjoy reading :)

Note: **This was only tested on Linux and won't work in the same (but in a similar) way on Windows.**

## **Last remarks**

The project is open source, you can load your own articles and modify the GUI, if you want to. Please just mention this project, if you do so.

Anyway, I am not in any way responsible for the contents of this wiki nor of its modifications. While disgusting content should have been filtered out to some degree, this isn't guaranteed. You use the app at your own risk!

**Work is still in progress!**

## **Licensing and Attribution Notice**

This app uses content from Wikipedia, which is available under the Creative Commons Attribution-ShareAlike 3.0 License (CC BY-SA 3.0).

Some summaries and text shown in this app are based on original Wikipedia articles and may have been edited or condensed by the app author.

By using this app, you acknowledge that:
 - The original content was created by Wikipedia contributors.
 - Modifications may have been made to adapt the content.
 - The full license is available at: https://creativecommons.org/licenses/by-sa/3.0/
 - You can access the original articles and their edit history via the source links provided with each summary.

Wikipedia® is a trademark of the Wikimedia Foundation. This app is not affiliated with or endorsed by the Wikimedia Foundation.

This project used 'Better Lua Api' by adriweb + contributors and Luna by Vogtinator + contributors.