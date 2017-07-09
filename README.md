# soccer_position
Project to discover from which position a unknow player is, based in some characteristcs

## R
Responsible for the analysis.
* database.sqlite: download it [here](https://www.kaggle.com/hugomathien/soccer).

## Python
Scrap data collected form html.

## How the html data was collected?
Using the shell command:
```
cat ids.txt | xargs -i wget "https://sofifa.com/player/{}" --load-cookies=cookies.txt
```

* ids.txt: ids from fifa's players.
* cookies.txt: a file with cookie that was [captured](https://chrome.google.com/webstore/detail/cookiestxt/njabckikapfpffapmjgojcnbfjonfjfg?utm_source=chrome-app-launcher-info-dialog) from sofifa website.
