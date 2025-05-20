#==============================================================================#
acesso_por_var = function(v, municipios_df, infos_df, input, pontos){
  cat("\nExtraindo valores para a variável: ", v)
  
  # Filtrar arquivos da variável v, ordenar por data inicial
  arquivos_var <- infos_df %>% filter(var == v) %>% arrange(data_ini)
  
  apply(arquivos_var, MARGIN=1, FUN=extrair_valores, municipios_df=municipios_df,
        input=input, pontos=pontos, v=v)
}
#==============================================================================#

#==============================================================================#
extrair_valores = function(l_arquivo_var, municipios_df, input, pontos, v){
  cat("\nExtraindo valores para a data: ", l_arquivo_var[2], " até ", l_arquivo_var[3])
  # Configurando valores
  nc_file <- l_arquivo_var[4]
  data_ini <- as.Date(l_arquivo_var[2])
  data_fim <- as.Date(l_arquivo_var[3])
  datas_seq <- seq(data_ini, data_fim, by = "day")
  
  # Criando raster para o arquivo NetCDF
  rast_nc <- rast(nc_file)
  
  # Conferir se número de camadas bate com número de dias
  if(nlyr(rast_nc) != length(datas_seq)){
    warning(paste("Número de camadas diferente do número de dias esperado no arquivo", nc_file))
  }
  
  # Extraindo valores
  valores <- terra::extract(rast_nc, pontos)
  
  # Transformar para long format
  valores <- valores %>%
    tidyr::pivot_longer(
      cols = -ID,
      names_to = "layer",
      values_to = v
    )
  
  # Extrair índice da camada para casar com datas
  valores$layer_index <- as.integer(gsub(".*?(\\d+)$", "\\1", valores$layer))
  valores$data <- datas_seq[valores$layer_index]
  
  # Selecionando colunas de interesse
  valores <- valores %>%
    select(ID, data, all_of(v))
  
  # Juntar com municípios
  valores <- valores %>%
    left_join(municipios_df[, c("ID", "municipio", "latitude", "longitude")], by = "ID") %>%
    select(municipio, latitude, longitude, data, all_of(v))

  # Gerando Data frame para criar arquivos temporários
  unicos_municipio = unique(municipios_df$municipio)
  
  # Gerando arquivos temporários
  for(um_municipio in unicos_municipio){
    df_per_municipio = valores %>% filter(municipio == um_municipio) %>% arrange(data)
    arq_path = sprintf("tmp/%s_%s_temp.fst", um_municipio, v)
    escrever_var_temp(arq_path, df_per_municipio)
  }
}
#==============================================================================#

#==============================================================================#
juntar_municipios = function(nome_mun, input, municipios_df){
     cat("\nReunindo arquivo do município: ", nome_mun)
     # Definindo path para arquivos temporários
     tmp_arq_path = sprintf("tmp/%s_%s_temp.fst", nome_mun, input$vars)
     # Lendo tabelas
     tabelas <- lapply(tmp_arq_path, fread)
     
     # Garante que todos os arquivos contenham as colunas-chave
     chaves <- c("municipio", "latitude", "longitude", "data")
     
     # Definindo chaves para aumentar a eficiência
     tabelas <- lapply(tabelas, function(dt) {
          missing <- setdiff(chaves, names(dt))
          if (length(missing) > 0) {
               stop(paste("Colunas obrigatórias ausentes:", paste(missing, collapse = ", ")))
          }
          setkeyv(dt, chaves)  # define as chaves de cada tabela
          return(dt)
     })
     
     # Faz merge sucessivos mantendo todas as colunas com base nas chaves
     resultado <- Reduce(function(x, y) merge(x, y, by = chaves, all = TRUE), tabelas)
     
     # Define caminho de saída
     if(is.null(municipios_df$estado)){
          arq_out_path = sprintf("%s/%s.csv", input$dir_saida, nome_mun)
     }else{
          estado = pull(municipios_df[municipios_df$municipio==nome_mun,"estado"])
          arq_out_path = sprintf("%s/%s/%s.csv", input$dir_saida, estado, nome_mun)
     }
     
     # Salvando arquivo
     fwrite(resultado, arq_out_path)
     unlink(tmp_arq_path)
     cat("\nMunicípio ", nome_mun, " Finalizado!!")
}