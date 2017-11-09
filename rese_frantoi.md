Analisi delle rese dichiarate dai frantoi in Liguria
================

Analisi delle rese dichiarate dai frantoi in Liguria
----------------------------------------------------

In questo breve documento voglio condividere alcune analisi ottenute utilizzando i dati pubblici diffusi dal Centro di Agrometeorologia Applicata Regionale ligure, il [CAAR](http://www.agriligurianet.it/it/impresa/assistenza-tecnica-e-centri-serivizio/agrometeo-caar.html), relativi alle rese degli olivicoltori che hanno compilato il modulo online.

I dati provengono dal bot Telegram [CAARserviziBot](https://t.me/CAARserviziBot), e sono rappresentati in formato tabellare all'interno di un file pdf.

Import e pulizia dei dati
=========================

Per riuscire a leggere i dati ho deciso di utilizzare il package [Tabulizer](https://github.com/ropensci/tabulizer), non disponibile su CRAN ma scaricabile direttamente tramite GitHub:

> library(devtools) devtools::install\_github(c("ropenscilabs/tabulizerjars", "ropenscilabs/tabulizer"), args = "--no-multiarch")

Oltre a questo, procedo quindi nel caricamento di altri package che utilizzerò nell'analisi.

A questo punto, posso procedere alla lettura del file pdf e ad alcune veloci operazioni di pulizia.

``` r
data <- extract_tables("Rese_frantoi_17.pdf")
str(data)
```

    ## List of 4
    ##  $ : chr [1:48, 1:5] "Provincia oliveto" "GENOVA" "GENOVA" "GENOVA" ...
    ##  $ : chr [1:48, 1:5] "Provincia oliveto" "" "IMPERIA" "IMPERIA" ...
    ##  $ : chr [1:46, 1:5] "Provincia oliveto" "LA SPEZIA" "LA SPEZIA" "LA SPEZIA" ...
    ##  $ : chr [1:46, 1:5] "Provincia oliveto" "LA SPEZIA" "LA SPEZIA" "LA SPEZIA" ...

``` r
head(data[[1]])
```

    ##      [,1]                [,2]             [,3]     [,4]             
    ## [1,] "Provincia oliveto" "Comune oliveto" "Resa %" "Data frangitura"
    ## [2,] "GENOVA"            "sestri levante" "16,0%"  "29/09"          
    ## [3,] "GENOVA"            "sori"           "18,0%"  "29/09"          
    ## [4,] "GENOVA"            "Leivi"          "18,0%"  "30/09"          
    ## [5,] "GENOVA"            "chiavari"       "20,1%"  "02/10"          
    ## [6,] "GENOVA"            "Leivi"          "14,0%"  "02/10"          
    ##      [,5]       
    ## [1,] "Settimana"
    ## [2,] "39"       
    ## [3,] "39"       
    ## [4,] "39"       
    ## [5,] "40"       
    ## [6,] "40"

Innanzitutto, tabulizer restituisce le tabelle esattamente così come sono nel file PDF: l'output del comando `extract_table()` sarà quindi una lista di matrici (ossia una lista di tabelle, come si vede stampando le prime righe del primo elemento della lista, `data[[1]]`). Abbiamo quindi una serie di matrici, una per foglio del file PDF, ed ognuna ha al suo interno righe "sporche" date dall'intestazione e dalla riga del totale per provincia.

Di conseguenza, decido di procedere selezionando esclusivamente le righe il cui valore per la prima colonna è contenuto nella lista dei capoluoghi di provincia, ossia il vettore `province`. Unisco quindi le quattro matrici una all'altra, assegno nuovamente l'intestazione e rinuncio alla colonna "Settimana" contentente la settimana dell'anno perché facilmente desumibile dalla data di frangitura.

Infine, pulisco le singole colonne elimando il simbolo di percentuale dalla resa e rendendola numerica, rendendo minuscolo il nome del comune e rendendo la data un oggetto di tipo *Date*.

``` r
province <- c("GENOVA","IMPERIA","LA SPEZIA","SAVONA")
data <- lapply(data,function(x)(x[x[,1] %in% province,]))
data <- do.call(rbind,data)

headers <- c("Provincia_oliveto","Comune_oliveto","Resa_perc","Data_frangitura","Settimana")
colnames(data) <- headers
data <- as.data.frame(data[,-5])

data$Resa_perc <- as.numeric(sub(",",".",sub("%","",data$Resa_perc)))
data$Data_frangitura <- as.Date(paste0(data$Data_frangitura,"/2017"),format = "%d/%m/%Y")
data$Comune_oliveto <- tolower(data$Comune_oliveto)
data$Comune_oliveto <- ifelse(data$Comune_oliveto=="",as.character(data$Provincia_oliveto),data$Comune_oliveto)
head(data)
```

    ##   Provincia_oliveto Comune_oliveto Resa_perc Data_frangitura
    ## 1            GENOVA sestri levante      16.0      2017-09-29
    ## 2            GENOVA           sori      18.0      2017-09-29
    ## 3            GENOVA          leivi      18.0      2017-09-30
    ## 4            GENOVA       chiavari      20.1      2017-10-02
    ## 5            GENOVA          leivi      14.0      2017-10-02
    ## 6            GENOVA sestri levante      17.5      2017-10-02

Including Plots
---------------

You can also embed plots, for example:

![](rese_frantoi_files/figure-markdown_github-ascii_identifiers/pressure-1.png)

Note that the `echo = FALSE` parameter was added to the code chunk to prevent printing of the R code that generated the plot.
