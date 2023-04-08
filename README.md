# Análise de Banco de Dados Não Relacional - MongoDB e Airbnb

Este projeto analisou dados do Airbnb, salvos em um banco de dados não relacional e semi estruturado, em formato de texto originalmente, em um servidor de MongoDB. Todo processo foi realizado em linguagem R, e o script se encontra disponível com o nome “Análise_BancoNãoRelacional_MongoDB_Airbnb”.

O pacote “Mongolite” da linguagem R proporciona conexões diretas com um banco de dados MongoDB, onde foi realizado o processo de ETL (extração, limpeza e tratamento) dos dados, foi feita a análise através de técnicas de mapeamento e redução (MapReduce), e por fim foram geradas amostras em formato estruturado e também gráficos:

“Amostra_Imóveis por Quantidade de Quartos”
 	
“Amostra_Número de Reviews de todos os Tipos de Propriedades”
 	
“Amostra_Política de Cancelamento para Casas”
 	
“Amostra_Tipos de Propriedade”

O script permite a automatização do tratamento dos dados: toda vez que os dados no servidor forem atualizados, serão estruturados e os bancos resultantes serão atualizados ao se rodar o script novamente.
