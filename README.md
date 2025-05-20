---
output:
  html_document: default
  pdf_document: default
---
# Execução do programa Brazilian Daily Weather Gridded Data (BR-DWGD)

Este guia orienta sobre como configurar e executar o programa de obtenção de dados climáticos através da base de dados Xavier.  
Para obtenção dos dados é necessário a coordenada Latitude e Longitude.  
Os dados climáticos disponíveis são: ETo, pr, RH, Rs, Tmax, Tmin, u2.

## Etapa 1: Download do banco de dados do Xavier

O Banco de dados usado no programa pode ser obtido em:

-   [No Drive dos anos de 1961 à 2024](https://drive.google.com/drive/folders/11-qnvwojirAtaQxSE03N0_SUrbcsz44N)
-   [No site do BR-DWGD](https://sites.google.com/site/alexandrecandidoxavierufes/brazilian-daily-weather-gridded-data)

O banco de dados deve ser baixado e extraído para a pasta `data` (ou ver o arquivo de configuração)

## Etapa 2: Instalar os pacotes do R

Os pacotes utilizados neste programa estão explicitados abaixo:

`terra`  
`dplyr`  
`tidyr`  
`stringr`  
`data.table`  
`compiler`  

Caso haja problema durante a instalação do pacote `terra`, atualize o pacote `Rtools`, ou tente baixar a versão binária.

## Etapa 3: Inserção do arquivo de input

Para definir os municípios a serem selecionados, deve-se adicionar a pasta `input` o arquivo contendo os dados de latitude e longitude.  
Por padrão, o arquivo de leitura das informações de entrada se chama `Coordenadas_municipio_data.csv`  
Para alteração, veja o arquivo de configuração, atente-se ao modelo de referência dentro da pasta `referências`  

É possível utilizar uma coluna nesse arquivo de entrada para explicitar o estado ao qual o município pertence. Com essa coluna, a saída será separada automaticamente por estados.  

Dentro da paste de `referências` há a relação de municípios, latitude, longitude e estados. No arquivo `latitude-longitude-cidades.csv`

## Etapa 4: Configuração do programa

O programa pode ser configurado para alterar as saídas e leituras, através do arquivo:

`StartValues.config`

Podendo alterar os arquivos de entrada, saída e quais varriáveis devem ser extraídas.

## Etapa 5: Rodar o programa

Para rodar o programa, basta rodar o script `start_BR_DWGD.R`