#==============================================================================#
app.carregar_funcoes = function(){
  # Carregando as funções moduláres e funcionais
  # Source das funções
  source("./src/conv/XavierConversion.R")
  source("./src/conv/modulos.R")
}
#==============================================================================#

#==============================================================================#
# Carregando pacotes a serem utilizados
app.LoadPackages = function() {
  library(terra)
  library(dplyr)
  library(tidyr)
  library(stringr)
  library(data.table)
  library(compiler)
}
#==============================================================================#

#==============================================================================#
app.compilar_todas_funcoes <- function(env = .GlobalEnv) {
  if (!requireNamespace("compiler", quietly = TRUE)) {
    stop("O pacote 'compiler' é necessário.")
  }
  
  # Lista todos os objetos do ambiente
  objetos <- ls(env)
  
  for (nome in objetos) {
    obj <- get(nome, envir = env)
    
    # Verifica se é uma função
    if (is.function(obj)) {
      funcao_compilada <- compiler::cmpfun(obj)
      assign(nome, funcao_compilada, envir = env)
      message(sprintf("Função '%s' compilada com sucesso.", nome))
    }
  }
}
#==============================================================================#

#==============================================================================#
# Iniciando parametros contigos no arq.config
config.treatment = function(arq.config){
  
  con = file(arq.config)
  open(con)
  
  linhas = readLines(con)
  linhas = linhas[linhas != ""]
  linhas = linhas[-grep("!",linhas)]
  
  input = list()
  for(i in linhas){
    i = strsplit(i,"=")[[1]]
    
    index = gsub(" ","",i[1])
    valor = gsub(" ","",i[2])
    valor = strsplit(valor,",")[[1]]
    
    input[[index]] = valor
  }
  
  close(con)
  
  return(input)
}
#==============================================================================#

#==============================================================================#
# Função para criar diretórios de saída
criar_diretorios = function(dir_saida, municipios_df){
  if(!dir.exists(dir_saida)) dir.create(dir_saida)
  
  estados_unicos = unique(municipios_df$estado)
  
  if(is.null(estados_unicos)){
  }else{
    for(estado in estados_unicos){
      dir_estado = sprintf("%s/%s", dir_saida, estado)
      if(!dir.exists(dir_estado)) dir.create(dir_estado)
    }
  }
}

#==============================================================================#
# Função para criar diretórios de saída
escrever_var_temp = function(arq_path, df_per_municipio){
  # Checando se arquivo já existe
  if(file.exists(arq_path)){
    # Adicionando ao final
    fwrite(df_per_municipio, arq_path, append = TRUE)
  }else{
    # Inicializando o arquivo
    fwrite(df_per_municipio, arq_path)
  }
}
#==============================================================================#

#==============================================================================#
# Função para extrair variável e datas do nome do arquivo
extrair_info_arquivo <- function(filename) {
  base <- basename(filename)
  parts <- strsplit(base, "_")[[1]]
  var <- parts[1]
  data_ini <- as.Date(parts[2], format = "%Y%m%d")
  data_fim <- as.Date(parts[3], format = "%Y%m%d")
  list(var = var, data_ini = data_ini, data_fim = data_fim)
}