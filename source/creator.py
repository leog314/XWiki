import wikipediaapi
import csv

def clip_string(string, max_sentences=5):
    information = string.split(".")
    
    clipped = ""
    counter = 0

    while counter < min(max_sentences, len(information)):
        clipped += information[counter] + "."
        counter += 1
    return clipped

wiki_wiki = wikipediaapi.Wikipedia(user_agent='XWiki', language='en')

data = []

with open("source/articles.txt") as file:
    reader = file.read().split("\n")

    for key in reader:
        data.append(key)# .replace(" ", "_"))

with open("source/database.lua", "w") as f:

    f.writelines("""-----------------------------------------
-- XWiki - a portable knowledge source --
-- by Leonard Großmann ------------------
-- 3/2/2025 -----------------------------
-----------------------------------------

--------------- database ----------------

local database = {}

database['XWiki'] = 'XWiki is a portable knowledge source for TI-nspire calculator series (and probably some more). It compresses a five sentence summary of the 1000 most vital (and some more) articles in English Wikipedia. It was implemented by Leonard Großmann (leog314). Wikipedia is a free-content online encyclopedia written and maintained by a community of volunteers, known as Wikipedians, through open collaboration and the wiki software MediaWiki. Founded by Jimmy Wales and Larry Sanger on January 15, 2001, Wikipedia has been hosted since 2003 by the Wikimedia Foundation, an American nonprofit organization funded mainly by donations from readers. Wikipedia is the largest and most-read reference work in history.' 
""")

    for art in data:
        page = wiki_wiki.page(art)
        title, summary = page.title.replace("'", "\\'").replace("_", " "), page.summary.replace("\n", " ").replace("'", "\\'")

        if sum([k in summary.lower() or k in title.lower() for k in ["sex", "xxx", "pornographic", "coitus", "porn", "image", "xhamster"]])==0: # exclude discusting or irrevalent topics
            print(page.title)
            f.writelines("database['" + title + "'] = '" + clip_string(summary) + "'\n")
    f.writelines("\n")