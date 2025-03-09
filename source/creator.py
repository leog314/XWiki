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

with open("source/undefined.csv") as csvfile:
    reader = csv.DictReader(csvfile)

    for row in reader:
        data.append(row["article"])

with open("source/database.lua", "w") as f:

    f.writelines("""-----------------------------------------
-- XWiki - a portable knowledge source --
-- by Leonard Großmann ------------------
-- 3/2/2025 -----------------------------
-----------------------------------------

--------------- database ----------------
    
""")
    f.writelines("local database = {}\n\n")

    for art in data:
        page = wiki_wiki.page(art)
        title, summary = page.title.replace("'", ' ').replace("_", " "), page.summary.replace("\n", " ").replace("'", ' ')

        if sum([k in summary.lower() or k in title.lower() for k in ["sex", "xxx", "pornographic", "coitus", "porno", "wikipedia"]])==0: # exclude discusting or irrevalent topics
            print(page.title)
            f.writelines("database['" + title + "'] = {content='" + clip_string(summary) + "'}\n")
    f.writelines("\n")