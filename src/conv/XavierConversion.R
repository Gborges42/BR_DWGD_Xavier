#==============================================================================#
XavierConversion = function(input){
  
  # --- Configurações ---
  # Caminho para a pasta onde estão os arquivos NetCDF
  input = config.treatment("./StartValues.config")
  ncdf_dir <- input$ncdf_path
  
  # Caminho para o arquivo CSV com municipios, latidude, longitude
  csv_municipios = sprintf("input/%s", input$arquivo_coordenadas)
  
  # Pasta onde salvar os CSVs por município
  dir_saida <- input$dir_saida
  
  # --- Ler CSV de municípios ---
  municipios_df <- fread(csv_municipios, stringsAsFactors = FALSE)
  
  # Criar diretórios
  criar_diretorios(dir_saida, municipios_df)
  
  # --- Montar condiguração NetCDF ---
  # Listar arquivos e extrair informações
  nc_files <- list.files(ncdf_dir, pattern = "\\.nc$", full.names = TRUE)
  
  infos <- lapply(nc_files, extrair_info_arquivo)
  infos_df <- do.call(rbind, lapply(infos, function(x) data.frame(var = x$var, data_ini = x$data_ini, data_fim = x$data_fim, stringsAsFactors=FALSE)))
  infos_df$filepath <- nc_files
  
  # Agrupar arquivos por variável
  vars_unique <- unique(infos_df$var)
  vars_unique = vars_unique[vars_unique %in% input$vars] 
  
  # Definindo pontos por longitude e latitude
  pontos <- vect(municipios_df[, c("longitude", "latitude")], geom=c("longitude","latitude"), crs="EPSG:4326")
  # Adicionando ID a cada município
  municipios_df$ID <- 1:nrow(municipios_df)
  
  
  # --- Criando valores ---
  lapply(vars_unique, FUN = acesso_por_var, municipios_df=municipios_df,
                     infos_df=infos_df,input=input, pontos=pontos)
  # --- Salvando valores por município ---
  lapply(unique(municipios_df$municipio), FUN = juntar_municipios,
                     municipios_df=municipios_df,input=input)
}