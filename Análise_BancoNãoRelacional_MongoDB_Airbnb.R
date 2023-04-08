#MapReduce Para Análise de Dados com R e MongoDB 

#setwd("C:/Users")
#getwd()

library(ggplot2)
library("devtools")
library(mongolite)
library(dplyr)

# Conexão com MongoDB
con <- mongo(collection = "airbnb",
             db = "dsadb",
             #url = "mongodb://XXX",
             verbose = FALSE,
             options = ssl_options())

# Visualizar a conexão
print(con)

# Visualizar os dados
dados <- con$find()
View(dados)

# Verificar o número de registros no conjunto de dados (total, cochete vazio)
con$count('{}')

##### Buscar uma amostra de dados somente com propriedades do tipo House e as suas políticas de cancelamento
amostra1 <- con$find(
  query = '{"property_type" : "House" }', 
  fields = '{"property_type" : true, "cancellation_policy" : true}'
  )
View(amostra1)

# Descartar o campo de id
amostra2 <- con$find(
  query = '{"property_type" : "House" }', 
  fields = '{"property_type" : true, "cancellation_policy" : true, "_id": false}'
)
View(amostra2)

##### ORDENAR o resultado
amostra3 <- con$find(
  query = '{"property_type" : "House" }', 
  fields = '{"property_type" : true, "cancellation_policy" : true, "_id": false}',
  sort = '{"cancellation_policy": -1}'
)
View(amostra3)

#Salvar em CSV
write.table(amostra3, file = "Amostra_Política de Cancelamento para Casas.csv", sep = ",", row.names = FALSE)

####### Agregar os dados e retornar a média da quantidade de reviews por tipo de propriedade
amostra4 <- con$aggregate(
  '[{"$group":{"_id":"$property_type", "count": {"$sum":1}, "average":{"$avg":"$number_of_reviews"}}}]',
  options = '{"allowDiskUse":true}'
)
names(amostra4) <- c("Tipo de Propriedade", "Contagem", "Quantidade de Reviews em Média")
amostra4$`Quantidade de Reviews em Média` <-round(amostra4$`Quantidade de Reviews em Média`)
View(amostra4)

#Salvar em CSV
write.table(amostra4, file = "Amostras_Tipos de Propriedade.csv", sep = ",", row.names = FALSE)

####################### MapReduce - Mapeamento e Redução

# Contagem (de 1 a 1) do número de reviews considerando todas as propriedades
resultado <- con$mapreduce(
  map = "function(){emit(Math.floor(this.number_of_reviews), 1)}", 
  reduce = "function(id, counts){return Array.sum(counts)}"
)
names(resultado) <- c("numero_reviews", "contagem")
View(resultado)

# Plot
ggplot(aes(numero_reviews, contagem), data = resultado) + geom_col()

### Contagem (separado por faixa, de 100 em 100) do número de reviews por faixa considerando todas as propriedades
resultado <- con$mapreduce(
  map = "function(){emit(Math.floor(this.number_of_reviews/100)*100, 1)}", 
  reduce = "function(id, counts){return Array.sum(counts)}"
)
names(resultado) <- c("numero_reviews", "contagem")
View(resultado)

# Nova coluna com percentuais
resultado$percent <- resultado$contagem/sum(resultado$contagem)*100

resultado
str(resultado)

# Convertendo variáveis e limitando casas decimais
resultado$numero_reviews <- as.factor(resultado$numero_reviews)
resultado$percent <- as.numeric(resultado$percent)
str(resultado)

options(digits = 1)
resultado

# Plot
ggplot(aes(numero_reviews, percent), data = resultado) + geom_col(fill='darkgreen') + labs(x = "Número de Reviews (Faixas)", y = "Percentual do Total", title = "Quantidade de Reviews") + scale_y_continuous(breaks = seq(0, 100, by = 20))

#### Contagem do número de quartos considerando todas as propriedades
resultado2 <- con$mapreduce(
  map = "function(){emit(Math.floor(this.bedrooms), 1)}", 
  reduce = "function(id, counts){return Array.sum(counts)}"
)
names(resultado2) <- c("numero_quartos", "contagem")
View(resultado2)

# Plot
ggplot(aes(numero_quartos, contagem), data = resultado2) + geom_col(fill='darkgreen') + labs(x = "Número de Quartos", y = "Contagem", title = "Imóveis por Quantidade de Quartos") + coord_cartesian(xlim = c(0, 9)) + scale_x_continuous(breaks = 0:9)