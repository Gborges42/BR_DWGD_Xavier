# Acessar conversão Xavier
source("./src/funcional.R")

# Configuração do ambiente
app.carregar_funcoes()
app.LoadPackages()
app.compilar_todas_funcoes()

# Definir o input
input = config.treatment("./StartValues.config")

# Gerar conversão Xavier
XavierConversion(input)