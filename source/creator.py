import wikipediaapi
import csv
from nltk.tokenize import sent_tokenize

def clip_string(string, max_sentences=5):
    information = sent_tokenize(string)
    
    clipped = ""
    counter = 0

    while counter < min(max_sentences, len(information)):
        clipped += information[counter] + " "
        counter += 1
    return clipped

wiki_wiki = wikipediaapi.Wikipedia(user_agent='XWiki', language='en')

data = []

with open("source/articles.txt") as file:
    reader = file.read().split("\n")

    for key in reader:
        data.append(key)

with open("source/database.lua", "w") as f:

    f.writelines("""-----------------------------------------
-- XWiki - a portable knowledge source --
-- by Leonard Großmann ------------------
-- 3/2/2025 -----------------------------
-----------------------------------------

--------------- database ----------------

local database = {}

database['XWiki'] = 'XWiki is a portable knowledge source for the TI-Nspire calculator series written in Lua. It compresses a five sentence summary of the 1000 most vital (and some more) articles in English Wikipedia. XWiki was developed by leog314 in 2025. Wikipedia is a free-content online encyclopedia written and maintained by a community of volunteers, known as Wikipedians, through open collaboration and the wiki software MediaWiki. Founded by Jimmy Wales and Larry Sanger on January 15, 2001, Wikipedia has been hosted since 2003 by the Wikimedia Foundation, an American nonprofit organization funded mainly by donations from readers. Wikipedia is the largest and most-read reference work in history.' 
database['TI-Nspire CAS'] = 'The TI-Nspire CAS calculator is capable of displaying and evaluating values symbolically, not just as floating-point numbers. It includes algebraic functions such as a symbolic differential equation solver: deSolve(...), the complex eigenvectors of a matrix: eigVc(...), as well as calculus based functions, including limits, derivatives, and integrals. For this reason, the TI-Nspire CAS is more comparable to the TI-89 Titanium and Voyage 200 than to other calculators. Unlike the TI-Nspire, it is not compatible with the snap-in TI-84 Plus keypad. It is accepted in the SAT and AP exams (without a QWERTY keyboard) but not in the ACT, IB or British GCSE and A level.'
database['TI-Nspire CX (CAS)'] = 'In 2011, the TI-Nspire CX and CX CAS were announced as updates to TI-Nspire series. They have a thinner design, with a thickness of 1.57 cm (almost half of the TI-89), a 1,200 mA·h (1,060 mAh before 2013) rechargeable battery (wall adapter is included in the American retail package), a 320 by 240 pixel full color backlit display (3.2" diagonal), and OS 3.0 which includes features such as 3D graphing. The TI-Nspire CX series differ from all previous TI graphing calculator models in that the CX series are the first to use a rechargeable 1,060 mAh lithium-ion battery (upgraded to 1,200 mAh in the 2013 revision). The device is charged via a USB cable.'
database['TI-Nspire CX II (CAS)'] = 'In 2019, Texas Instruments introduced the TI-Nspire CX II and TI-Nspire CX II CAS. They feature a slightly different operating system with several enhancements and slightly improved hardware, including Python integration. The non-CAS version lacks the exact math mode which is included in the CAS version as well as all the models dedicated to the European/China market (T and C versions).'
database['Ndless'] = 'Ndless (alternatively stylized Ndl3ss) is a third-party jailbreak for the TI-Nspire calculators that allows native programs, such as C, C++, and ARM assembly programs, to run. Ndless was developed initially by Olivier Armand and Geoffrey Anneheim and released in February 2010 for the Clickpad handheld. Organizations such as Omnimaga and TI-Planet promoted Ndless and built a community around Ndless and Ndless programs. With Ndless, low-level operations can be accomplished, for example overclocking, allowing the handheld devices to run faster. Downgrade prevention can be defeated as well. In addition, Game Boy, Game Boy Advance, and Nintendo Entertainment System emulators exist for the handhelds with Ndless. Major Ndless-powered programs also include a port of the game Doom. Unlike Lua scripts, which are supported by Texas Instruments, Ndless is actively counteracted by TI. Each subsequent OS attempts to block Ndless from operating.'
""") # predefined articles -> CX and CX II as well as ndless missing

    for art in data:
        page = wiki_wiki.page(art)
        title, summary = page.title.replace("'", "\\'").replace("_", " "), page.summary.replace("\n", "\\n").replace("'", "\\'")

        if sum([k in summary.lower() or k in title.lower() or summary=="." for k in ["xxx", "pornographic", "porn", "image", "onlyfans"]])==0: # exclude discusting or irrevalent topics
            print(page.title)
            f.writelines("database['" + title + "'] = '" + clip_string(summary) + "'\n")

        else:
            print(f"Failed to parse keyword: {title}")
    f.writelines("\n")