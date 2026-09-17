<!-- Alterar apenas o que tá em italico (o que está entre um único asteristico, ex: *batata doce com abobrinha*. -->



## 1. Caracterização da Organização
<!-- *(vale 7,5% — Dimensão Conceitual)* -->

- **Nome e natureza da organização:**
  
*A organização escolhida para o desenvolvimento do projeto é a Namiê Brasil Ltda., empresa do segmento de moda feminina, com atuação na fabricação e comercialização de peças de vestuário, especialmente roupas jeans femininas. A empresa possui atuação tanto no comércio atacadista quanto no varejista. Informações públicas cadastrais classificam sua atividade principal como confecção de peças do vestuário, além de atividades de comércio atacadista e varejista de artigos do vestuário.*
  
- **Contexto e porte:**
  
*A Namiê Brasil está localizada no bairro do Brás, em São Paulo – SP, e possui aproximadamente 50 pessoas envolvidas em suas operações. A organização possui diferentes setores, incluindo produção, costura, acabamento, expedição, pontos de venda, e-commerce, financeiro, recursos humanos e diretoria.

A empresa trabalha com fabricação própria de roupas femininas e comercializa seus produtos em diferentes canais. No atacado, as vendas ocorrem presencialmente nos pontos de venda e também por meio do WhatsApp, tendo como público principal as revendedoras. No varejo, as vendas são realizadas por meio do site e de marketplaces, atendendo diretamente consumidores finais.

O processo produtivo envolve a definição do modelo e do tecido, aquisição de matéria-prima quando necessária, corte, costura, lavanderia e acabamento. O acabamento compreende atividades como aplicação de botões, etiquetas, tags e demais aviamentos. Algumas etapas, como costura e acabamento, podem ser realizadas internamente ou por terceiros.*

- **Problemas e necessidades identificados:**
  
*Durante o levantamento realizado com a organização, foi identificada uma fragmentação no controle das informações de estoque e vendas, que atualmente são distribuídas entre diferentes ferramentas.

O controle de matérias-primas, cortes, costura, acabamento e determinadas movimentações é realizado por meio do sistema Omiê. O controle dos estoques de produtos acabados, incluindo o estoque geral e o estoque destinado à feira, é realizado por meio de planilhas eletrônicas. Já as vendas realizadas pelo site e marketplaces são controladas pelo sistema Bling ERP, que também mantém o estoque destinado às vendas online.

Essa divisão faz com que as informações de estoque não estejam centralizadas em um único sistema. Além disso, as planilhas não são atualizadas necessariamente no momento em que ocorre uma movimentação, podendo ocorrer divergências entre o estoque registrado e a quantidade efetivamente disponível.

Também foi identificado que, em determinadas situações, uma peça pode ser vendida sem que sua disponibilidade seja previamente confirmada, ocasionando a venda de produtos que não estão disponíveis em estoque. Nas vendas realizadas na feira, a baixa das peças pode ocorrer imediatamente ou posteriormente, contribuindo para a possibilidade de divergências no controle.

Outro ponto identificado é a ausência de um estoque mínimo definido, fazendo com que a necessidade de produção ou reposição seja percebida principalmente quando a quantidade disponível se torna insuficiente ou se esgota.*

- **Justificativa da escolha:**
  
*A Namiê Brasil foi escolhida por apresentar uma operação real que envolve diferentes processos relacionados à produção, controle de estoque e comercialização de produtos, proporcionando quantidade e variedade suficientes de informações para a realização da modelagem conceitual.

Além disso, um dos integrantes do grupo possui acesso à organização, permitindo o levantamento de requisitos diretamente com base nos processos reais observados. A existência de diferentes ferramentas utilizadas simultaneamente para controle das operações também proporciona um problema concreto para análise e modelagem de uma possível solução integrada.

O controle de produtos acabados apresenta ainda diferentes características que precisam ser consideradas pelo sistema, como modelo, coleção, cor, tamanho e SKU, além da existência de diferentes locais de estoque e canais de venda.*

- **Evidências da organização:**

*Namiê Brasil possui presença pública na internet por meio de seu site oficial:*

https://www.namiebrasil.com.br/

*E pelo instagram:*

https://www.instagram.com/namiebrasil/


*A empresa está localizada no bairro do Brás, em São Paulo – SP. Informações públicas de cadastro empresarial indicam a sede na Rua Piratininga, 514, conjunto 500, Brás, São Paulo – SP, CEP 03042-000.
Porém, possui 3 lojas físicas.

As demais evidências referentes ao acesso do grupo à organização, como registros da pesquisa de campo, fotografias e identificação do responsável que forneceu as informações, serão anexadas ou apresentadas conforme a documentação disponível ao grupo.*
<!-- Falta pegar as fotos -->
---

## 2. Processos de Negócio
<!-- *(vale 10% — Dimensão Procedimental)* -->

- **Principais processos mapeados:**
  
*A produção inicia-se com a definição do modelo e do tecido pela diretoria. Após verificar a disponibilidade da matéria-prima, o tecido é adquirido quando necessário. Em seguida, o material passa pelas etapas de corte, costura, lavanderia e acabamento, todas realizadas pela própria fábrica. No acabamento são aplicados itens como botões, etiquetas, tags e demais aviamentos. Após a conclusão, as peças são encaminhadas à expedição, que registra a produção e realiza a entrada dos produtos acabados no estoque.*
  
*Após a conclusão da produção, os produtos acabados são encaminhados à expedição, que registra sua entrada no estoque. O estoque geral é utilizado como principal estoque de produtos acabados e pode abastecer o estoque destinado à feira. Quando necessário, ocorre uma transferência do estoque geral para o estoque da feira, atualmente realizada por meio de planilhas.
O estoque destinado às vendas online é controlado separadamente pelo Bling ERP. Dessa forma, os estoques geral, feira e online possuem controles distintos.
Peças que apresentam defeitos, são perdidas, utilizadas como amostras ou retornam da feira são destinadas ao “defeitão”, não sendo consideradas no estoque normal. Já devoluções de vendas online que retornam sem danos podem voltar ao estoque online por meio do processo automatizado do Bling.*

*As vendas no atacado são realizadas presencialmente nos pontos de venda, principalmente na Feira da Madrugada, ou de forma online por meio do WhatsApp. O público principal é composto por revendedoras e outros clientes que adquirem produtos para revenda, embora também possam ocorrer vendas para consumidores finais.
O cliente informa os produtos desejados, identificados principalmente por modelo, cor e tamanho. Após a definição dos produtos e quantidades, é aplicado o preço de atacado e o pedido é realizado.
Atualmente, os pedidos de atacado não possuem o mesmo nível de estruturação das vendas online. As informações são tratadas principalmente por meio do atendimento e dos controles internos da empresa.
Após a venda, os produtos são separados e o estoque correspondente é atualizado. Na feira, essa baixa pode ocorrer imediatamente ou posteriormente, o que pode contribuir para divergências entre o estoque registrado e o estoque físico.*

*As vendas no varejo são realizadas por meio do site da empresa e de marketplaces. Quando o cliente realiza uma compra, o pedido é registrado no Bling ERP, que também realiza o controle do estoque destinado às vendas online.
O produto é identificado de forma mais precisa por meio do SKU ou EAN-13. Após o registro do pedido, o produto disponível é separado para expedição e posteriormente enviado ao cliente.
O estoque online é controlado separadamente dos demais estoques. Em caso de devolução de uma peça sem danos, o produto pode retornar ao estoque online, com a entrada sendo realizada automaticamente pelo Bling.*

  
- **Fluxogramas:** 
### 2.1 Produção de peças

```mermaid
  flowchart TD
    A([Início]) --> B[Definição do modelo e tecido]
    B --> C[Verificar disponibilidade da matéria-prima]
    C --> D{Matéria-prima disponível?}
    D -- Não --> E[Comprar tecido]
    E --> F[Corte]
    D -- Sim --> F
    F --> G[Costura]
    G --> H[Lavanderia]
    H --> I[Acabamento]
    I --> J[Expedição]
    J --> K[Registrar produção]
    K --> L[Entrada no estoque]
    L --> M([Fim])
```


### 2.2 Abastecimento e movimentação de estoque

```mermaid
  flowchart TD
    A([Início]) --> B[Produto acabado recebido pela expedição]
    B --> C[Registrar entrada no estoque geral]
    C --> D{Necessidade de abastecimento?}
    D -- Não --> E([Fim])
    D -- Sim --> F{Destino é a feira?}
    F -- Sim --> G[Transferir para estoque da feira]
    F -- Não --> H[Disponibilizar para venda online]
    G --> I[Atualizar estoque correspondente]
    H --> I
    I --> E
```

### 2.3 Venda no atacado

```mermaid
  flowchart TD
    A([Início]) --> B[Cliente solicita produtos]
    B --> C[Identificar modelo, cor e tamanho]
    C --> D[Verificar disponibilidade]
    D --> E{Produto disponível?}
    E -- Não --> F[Informar indisponibilidade]
    F --> G([Fim])
    E -- Sim --> H[Definir preço de atacado]
    H --> I[Registrar pedido]
    I --> J[Separar produtos]
    J --> K[Entregar ao cliente]
    K --> L[Baixar estoque]
    L --> G
```

### 2.4 Venda no varejo

```mermaid
  flowchart TD
    A([Início]) --> B[Cliente realiza compra no site ou marketplace]
    B --> C[Pedido registrado no Bling]
    C --> D[Verificar estoque online]
    D --> E{Produto disponível?}
    E -- Não --> F[Informar indisponibilidade]
    F --> G([Fim])
    E -- Sim --> H[Separar produto]
    H --> I[Expedição]
    I --> J[Enviar ao cliente]
    J --> K[Atualizar estoque]
    K --> G
```
---
## 3. Requisitos do Sistema
<!-- *(esta seção e a Seção 4 "Regras de Negócio" DIVIDEM 7,5% na dimensão conceitual — juntas valem 7,5%, não 7,5% cada — + 4% exclusivos desta seção na organização/documentação)* -->

### 3.1 Requisitos Funcionais
<!-- *O que o sistema precisa FAZER (ex.: "o sistema deve permitir registrar uma venda").* -->
| ID       | Requisito                                                                                           |
| -------- | --------------------------------------------------------------------------------------------------- |
| **RF01** | O sistema deve permitir cadastrar e consultar produtos/modelos.                                     |
| **RF02** | O sistema deve permitir cadastrar as variações de um produto, considerando cor, tamanho e SKU.      |
| **RF03** | O sistema deve permitir cadastrar e associar produtos às suas respectivas coleções.                 |
| **RF04** | O sistema deve permitir cadastrar clientes e seus dados necessários para realização de pedidos.     |
| **RF05** | O sistema deve permitir registrar pedidos de venda no atacado.                                      |
| **RF06** | O sistema deve permitir registrar pedidos de venda no varejo.                                       |
| **RF07** | O sistema deve permitir adicionar produtos, quantidades e preços aos pedidos.                       |
| **RF08** | O sistema deve permitir consultar a disponibilidade de produtos em cada local de estoque.           |
| **RF09** | O sistema deve permitir registrar entradas e saídas de produtos do estoque.                         |
| **RF10** | O sistema deve permitir registrar transferências de produtos entre estoques.                        |
| **RF11** | O sistema deve permitir registrar produtos destinados ao estoque de itens defeituosos (“defeitão”). |
| **RF12** | O sistema deve permitir registrar ordens de produção e suas respectivas quantidades produzidas.     |
| **RF13** | O sistema deve permitir associar as quantidades produzidas às respectivas variações/SKUs.           |
| **RF14** | O sistema deve permitir registrar a entrada de produtos acabados no estoque após a produção.        |
| **RF15** | O sistema deve permitir consultar o histórico de movimentações de estoque.                          |
| **RF16** | O sistema deve permitir consultar os pedidos de venda realizados.                                   |
| **RF17** | O sistema deve permitir diferenciar os preços praticados no atacado e no varejo.                    |
| **RF18** | O sistema deve permitir identificar o canal de venda associado a cada pedido.                       |

### 3.2 Requisitos Não Funcionais
<!-- *Características de qualidade (ex.: desempenho, segurança, usabilidade, disponibilidade).* -->
| ID        | Requisito                                                                                                                                        |
| --------- | ------------------------------------------------------------------------------------------------------------------------------------------------ |
| **RNF01** | O sistema deve possuir interface simples e intuitiva, permitindo que os funcionários realizem as operações sem conhecimentos técnicos avançados. |
| **RNF02** | Os dados armazenados devem possuir mecanismos de proteção contra acesso não autorizado.                                                          |
| **RNF03** | O sistema deve manter registro das movimentações realizadas, permitindo identificar alterações de estoque e pedidos.                             |
| **RNF04** | As consultas de produtos e estoques devem apresentar os resultados em tempo adequado para utilização durante as operações da empresa.            |
| **RNF05** | O sistema deve possuir mecanismo de backup periódico dos dados armazenados.                                                                      |
| **RNF06** | O sistema deve preservar a integridade dos dados, evitando registros inconsistentes de produtos, pedidos e estoques.                             |
| **RNF07** | O sistema deve permitir utilização simultânea por diferentes usuários autorizados.                                                               |
                                                            


---

## 4. Regras de Negócio
<!-- *(esta seção DIVIDE com a Seção 3 "Requisitos do Sistema" os mesmos 7,5% da dimensão conceitual — juntas valem 7,5%, não 7,5% cada — + 4% exclusivos desta seção na documentação. "Regras de negócio" é o termo técnico usado em modelagem de dados para as regras de funcionamento de qualquer organização, com ou sem fins lucrativos)* -->
- **Regras operacionais:**
  <!-- *condições que a organização impõe (ex.: "um pedido só pode ser fechado se houver estoque disponível", "uma doação só pode ser registrada com identificação do doador", "um ritual só pode ser agendado se o espaço estiver disponível").* -->
  
RN01 — Identificação de produtos
Cada produto deve ser identificado por um modelo, uma cor e um tamanho, formando uma variação específica com seu respectivo SKU.

RN02 — Associação entre produto e coleção
Um produto pode estar associado a uma coleção, sendo que a coleção é determinada de acordo com a cor utilizada no produto

RN03 — Controle de estoque por localização
Os produtos acabados devem possuir controle de estoque separado de acordo com sua localização ou finalidade: estoque geral, estoque da feira e estoque online.

RN04 — Transferência para a feira
Quando houver necessidade de abastecimento da feira, os produtos devem ser transferidos do estoque geral para o estoque da feira, reduzindo a quantidade disponível no estoque de origem e aumentando a quantidade no estoque de destino.

RN05 — Disponibilidade para venda
Um produto somente deve ser disponibilizado para venda quando houver quantidade disponível no estoque correspondente ao canal de venda.

RN06 — Diferenciação de preços
O preço de venda de um produto deve considerar o tipo de venda, diferenciando os valores praticados no atacado e no varejo.

RN07 — Composição do pedido
Um pedido deve possuir um cliente e ser composto por um ou mais itens, sendo cada item relacionado a uma variação específica de produto e sua respectiva quantidade.

RN08 — Registro de produção
Toda produção de produtos acabados deve ser registrada, informando as variações produzidas e suas respectivas quantidades.

RN09 — Entrada de produtos acabados
Após a conclusão da produção e o recebimento pela expedição, os produtos acabados devem ser registrados como entrada no estoque geral.

RN10 — Produtos com defeito
Produtos considerados defeituosos, perdidos, devolvidos com problema ou utilizados como amostras devem ser direcionados ao estoque denominado “defeitão” e não devem compor o estoque normal disponível para venda.

RN11 — Devoluções do e-commerce
Produtos devolvidos por clientes de vendas online que estejam em condições adequadas para comercialização devem retornar ao estoque online.
  
- **Restrições organizacionais:**
  <!-- *limitações que afetam o modelo (ex.: políticas internas, prazos, exigências legais, normas religiosas ou estatutárias) — e por que elas importam.* -->

RO01 — Estoques separados por canal
Os estoques geral, da feira e online são mantidos separadamente pela organização. Essa característica deve ser considerada no modelo para permitir o controle individual das quantidades disponíveis em cada local.

RO02 — Diferentes sistemas utilizados pela organização
A organização utiliza ferramentas distintas para diferentes operações: Omiê para processos relacionados à matéria-prima e produção, planilhas eletrônicas para determinados controles de produtos acabados e estoques, e Bling ERP para as vendas online. Essa fragmentação justifica a necessidade de um modelo que centralize as informações relevantes para os processos analisados.

RO03 — Produção própria
As etapas de corte, costura, lavanderia e acabamento são realizadas internamente pela própria fábrica. O modelo deve, portanto, representar a produção como um processo interno da organização.

---

## 5. Dicionário de Dados Conceitual (Preliminar)
<!-- *(vale 10% — Dimensão Procedimental)* -->
<!-- Para cada entidade identificada, liste:

| Atributo | Descrição | Regra de negócio associada |
|----------|-----------|------------------------------|
| *nome do atributo* | *o que ele representa* | *se houver alguma regra (obrigatoriedade, valores possíveis, etc.)* |

*Mantenha o dicionário organizado e padronizado (mesmo formato de tabela para todas as entidades).*

**Atenção à privacidade:** se forem usados exemplos de valores para ilustrar os atributos, esses exemplos devem ser **fictícios** — não utilize dados reais de clientes, fiéis, beneficiários, doadores ou funcionários da organização (nomes, CPFs, contatos etc.), mesmo que tenham sido observados durante a pesquisa de campo. Os exemplos devem apenas ser **coerentes com as operações reais** observadas. -->
**COLEÇÃO**
| Atributo   | Descrição                | Regra de negócio associada                  |
| ---------- | ------------------------ | ------------------------------------------- |
| id_colecao | Identificador da coleção | Deve identificar unicamente cada coleção    |
| nome       | Nome da coleção          | Deve permitir identificar a coleção         |
| tipo       | Classificação da coleção | Pode representar coleção normal ou especial |

**PRODUTO/MODELO**
| Atributo   | Descrição                            | Regra de negócio associada                   |
| ---------- | ------------------------------------ | -------------------------------------------- |
| id_produto | Identificador do modelo do produto   | Deve identificar unicamente cada modelo      |
| nome       | Nome do modelo do produto            | Obrigatório                                  |
| descricao  | Descrição do modelo                  | Pode ser utilizada para detalhar o produto   |
| id_colecao | Identificação da coleção relacionada | O produto deve estar associado a uma coleção |

**VARIAÇÃO/SKU**
| Atributo    | Descrição                           | Regra de negócio associada                                        |
| ----------- | ----------------------------------- | ----------------------------------------------------------------- |
| id_variacao | Identificador da variação           | Deve identificar unicamente a variação                            |
| sku         | Código de identificação da variação | Cada combinação de modelo, cor e tamanho possui um SKU específico |
| cor         | Cor da peça                         | Obrigatória                                                       |
| tamanho     | Tamanho da peça                     | Obrigatório                                                       |
| id_produto  | Produto/modelo ao qual pertence     | Toda variação deve pertencer a um modelo                          |

**PREÇO**
PREÇO

| Atributo      | Descrição                             | Regra de negócio associada                                      |
| ------------- | ------------------------------------- | --------------------------------------------------------------- |
| id_preco      | Identificador do preço                | Deve identificar unicamente o registro de preço                 |
| preco_atacado | Preço praticado nas vendas de atacado | Deve representar o valor utilizado para vendas de atacado       |
| preco_varejo  | Preço praticado nas vendas de varejo  | Deve representar o valor utilizado para vendas de varejo        |
| id_produto    | Modelo relacionado                    | Cada registro de preço deve estar associado a um produto/modelo |


**ESTOQUE**
| Atributo    | Descrição                      | Regra de negócio associada                                           |
| ----------- | ------------------------------ | -------------------------------------------------------------------- |
| id_estoque  | Identificador do estoque       | Deve identificar unicamente cada estoque                             |
| localização | Local ou finalidade do estoque | Deve diferenciar, no mínimo, geral, feira, online e defeitão         |

**ITEM DE ESTOQUE**
| Atributo        | Descrição                                         | Regra de negócio associada                                 |
| --------------- | ------------------------------------------------- | ---------------------------------------------------------- |
| id_item_estoque | Identificador do registro de estoque              | Deve identificar unicamente o registro                     |
| quantidade      | Quantidade disponível da variação naquele estoque | Deve ser maior ou igual a zero                             |
| id_estoque      | Estoque relacionado                               | Todo item de estoque deve pertencer a um estoque           |
| id_variacao     | Variação/SKU armazenada                           | Todo item de estoque deve estar relacionado a uma variação |

**MOVIMENTAÇÃO DE ESTOQUE**
| Atributo           | Descrição                          | Regra de negócio associada                                                   |
| ------------------ | ---------------------------------- | ---------------------------------------------------------------------------- |
| id_movimentacao    | Identificador da movimentação      | Deve identificar unicamente cada movimentação                                |
| tipo               | Tipo da movimentação               | Deve indicar entrada, saída ou transferência                                 |
| quantidade         | Quantidade movimentada             | Deve ser maior que zero                                                      |
| data_hora          | Data e horário da movimentação     | Deve registrar quando a movimentação ocorreu                                 |
| id_estoque_origem  | Estoque de origem da movimentação  | Deve referenciar o estoque de origem quando houver saída ou transferência    |
| id_estoque_destino | Estoque de destino da movimentação | Deve referenciar o estoque de destino quando houver entrada ou transferência |
| id_variacao        | Variação movimentada               | Toda movimentação deve estar relacionada a uma variação/SKU                  |

**ORDEM DE PRODUÇÃO**
| Atributo    | Descrição                          | Regra de negócio associada                          |
| ----------- | ---------------------------------- | --------------------------------------------------- |
| id_ordem    | Identificador da ordem de produção | Deve identificar unicamente cada ordem              |
| data_inicio | Data de início da produção         | Registra o início da ordem                          |
| data_fim    | Data de conclusão da produção      | Deve ser preenchida quando a produção for concluída |
| status      | Situação da ordem                  | Deve representar a situação atual da produção       |

**ITEM DA PRODUÇÃO**
| Atributo         | Descrição                         | Regra de negócio associada                                          |
| ---------------- | --------------------------------- | ------------------------------------------------------------------- |
| id_item_producao | Identificador do item da produção | Deve identificar unicamente o item                                  |
| quantidade       | Quantidade produzida              | Deve ser maior que zero                                             |
| id_ordem         | Ordem de produção relacionada     | Todo item deve pertencer a uma ordem de produção                    |
| id_variacao      | Variação produzida                | Permite registrar diferentes tamanhos, cores ou SKUs na mesma ordem |

**CLIENTE**
| Atributo   | Descrição                | Regra de negócio associada                                         |
| ---------- | ------------------------ | ------------------------------------------------------------------ |
| id_cliente | Identificador do cliente | Deve identificar unicamente cada cliente                           |
| nome       | Nome do cliente          | Obrigatório                                                        |
| tipo       | Tipo de cliente          | Deve diferenciar, no mínimo, revendedor/empresa e consumidor final |

**PEDIDO**
| Atributo   | Descrição                | Regra de negócio associada                    |
| ---------- | ------------------------ | --------------------------------------------- |
| id_pedido  | Identificador do pedido  | Deve identificar unicamente cada pedido       |
| data_hora  | Data e horário do pedido | Registra quando o pedido foi realizado        |
| canal      | Canal de venda           | Deve diferenciar atacado e varejo             |
| id_cliente | Cliente relacionado      | Todo pedido deve estar associado a um cliente |

**ITEM DO PEDIDO**
| Atributo       | Descrição               | Regra de negócio associada                          |
| -------------- | ----------------------- | --------------------------------------------------- |
| id_item_pedido | Identificador do item   | Deve identificar unicamente o item                  |
| quantidade     | Quantidade solicitada   | Deve ser maior que zero                             |
| preco_unitario | Preço unitário aplicado | Deve considerar o tipo de venda                     |
| id_pedido      | Pedido relacionado      | Todo item deve pertencer a um pedido                |
| id_variacao    | Variação comercializada | Cada item deve estar relacionado a uma variação/SKU |




---

## 6. Modelagem Conceitual (Entidades, Atributos, Relacionamentos)
<!-- *(vale 7,5% na dimensão conceitual)*
- **Entidades reconhecidas:** *liste e justifique brevemente cada uma.*
- **Atributos e classificações:** *quais atributos pertencem a cada entidade.*
- **Relacionamentos pertinentes:** *como as entidades se conectam.*
- **Restrições e políticas organizacionais aplicadas ao modelo.** -->

O modelo conceitual proposto para a Namiê Brasil representa os principais dados envolvidos nos processos de produção, controle de estoque e comercialização de produtos.

## 6.1 Entidades e relacionamentos

*COLEÇÃO ↔ PRODUTO/MODELO**

Uma coleção pode possuir um ou vários produtos.
Cada produto/modelo pertence a uma coleção.

**PRODUTO/MODELO → VARIAÇÃO/SKU**

Um produto pode possuir uma ou várias variações.
Cada variação pertence a um único produto.
A variação representa a combinação de cor e tamanho, identificada por um SKU.

Exemplo:

Produto: Cropped Faixa Elástico
| -→ Off White / P
| -→ Off White / M
| -→ Off White / G

Isso está de acordo com a estrutura observada no arquivo de estoque, que possui produtos-pai e suas respectivas variações.

## 6.2 Produtos e estoques

**VARIAÇÃO/SKU ↔ ITEM DE ESTOQUE ↔ ESTOQUE**

Uma variação pode possuir registros de quantidade em diferentes estoques. Cada item de estoque relaciona uma variação específica a um estoque e registra a quantidade disponível naquele local.

Um estoque representa um local ou finalidade de armazenamento, enquanto o item de estoque representa a quantidade de uma determinada variação armazenada nesse estoque.

Os estoques considerados no modelo são:

- Geral
- Feira
- Online
- Defeitão

Exemplo:

> SKU X → Estoque Geral → 20 unidades  
> SKU X → Estoque Feira → 5 unidades

Dessa forma, a mesma variação pode estar presente em diferentes estoques, com quantidades independentes.

## 6.3 Movimentação de estoque

VARIAÇÃO/SKU → MOVIMENTAÇÃO DE ESTOQUE

Uma variação pode participar de várias movimentações. Cada movimentação refere-se a uma única variação e registra a quantidade movimentada, o tipo da movimentação e a data e horário em que ocorreu.

A movimentação pode envolver um estoque de origem e um estoque de destino.

- Em uma entrada, o estoque de destino é informado.
- Em uma saída, o estoque de origem é informado.
- Em uma transferência, os estoques de origem e destino são informados.

Exemplo:

> 20 unidades do SKU X | Estoque Geral → Estoque Feira

Nesse caso, a movimentação reduz a quantidade do SKU X no estoque geral e aumenta sua quantidade no estoque da feira.

Essa estrutura permite registrar o histórico das movimentações e manter o controle das transferências entre os diferentes estoques.

## 6.4 Produção

**ORDEM DE PRODUÇÃO → ITEM DA PRODUÇÃO**

Uma ordem de produção pode possuir um ou vários itens.
Cada item pertence a uma única ordem de produção.

**ITEM DA PRODUÇÃO → VARIAÇÃO/SKU**

Uma variação pode aparecer em diferentes ordens de produção.
Cada item da produção corresponde a uma única variação.
O item registra a quantidade produzida daquela variação.

Portanto:

**ORDEM DE PRODUÇÃO → ITEM DA PRODUÇÃO → VARIAÇÃO/SKU**

Essa estrutura permite que uma mesma ordem de produção registre diferentes variações/SKUs, inclusive diferentes combinações de cor e tamanho.

## 6.5 Clientes e pedidos

**CLIENTE → PEDIDO**

Um cliente pode realizar zero ou vários pedidos.
Cada pedido pertence a um cliente.

**PEDIDO → ITEM DO PEDIDO**

Cada item do pedido registra a quantidade e o preço unitário efetivamente aplicado naquela venda. Dessa forma, o pedido mantém o valor praticado no momento da venda, independentemente de alterações posteriores nos preços cadastrados do produto.
Cada item pertence a um único pedido.

**ITEM DO PEDIDO → VARIAÇÃO/SKU**

Uma variação pode aparecer em vários itens de pedidos.
Cada item do pedido corresponde a uma única variação.

Assim:

**CLIENTE → PEDIDO → ITEM DO PEDIDO → VARIAÇÃO/SKU**

Isso permite registrar, por exemplo:

Cliente X
Pedido 001
| -→ 5 × Calça modelo A / 38
| -→ 3 × Calça modelo A / 40
| -→ 2 × Cropped modelo B / M

## 6.6 Estrutura conceitual preliminar

Juntando as entidades e relacionamentos apresentados:

```

                    COLEÇÃO
                       │
                       │
                 PRODUTO/MODELO
                    │       │
                    │       └──── PREÇO
                    │
                    ▼
                VARIAÇÃO/SKU
              /      |       \
             /       |        \
            ▼        ▼         ▼
   ITEM DE ESTOQUE  ITEM DA   ITEM DO PEDIDO
        │           PRODUÇÃO       │
        │              │           │
        ▼              ▼           ▼
     ESTOQUE      ORDEM DE       PEDIDO
                      PRODUÇÃO      │
                                    ▼
                                  CLIENTE

VARIAÇÃO/SKU
      │
      ▼
MOVIMENTAÇÃO DE ESTOQUE
      │
      ├──── ESTOQUE DE ORIGEM
      │
      └──── ESTOQUE DE DESTINO
   ```      
---

## 7. Diagrama Entidade-Relacionamento (DER)
*(vale 20% — é o item de maior peso da entrega)*

- Anexe o DER (em imagem).
- O diagrama deve representar corretamente:
  - Entidades
  - Atributos
  - Relacionamentos
  - **Cardinalidades**
- O modelo deve ser **consistente** e já demonstrar potencial de **escalabilidade e integração** (pensando nas próximas etapas do projeto).

---

## 8. Justificativa Técnica
*(vale 7,5% — sozinho, é o subcritério de maior peso dentro da Dimensão Conceitual)*

*Explique e defenda as decisões de abstração e modelagem tomadas: por que essas entidades, esses atributos, esses relacionamentos e essas cardinalidades — e não outras alternativas possíveis?*

---

## 9. Uso de Inteligência Artificial
*(documentação obrigatória — não é opcional se o grupo usou IA em qualquer etapa: pesquisa, escrita, organização de ideias ou revisão de texto)*

Se o grupo usou alguma ferramenta de IA (ChatGPT, Claude, Gemini, Perplexity etc.) em qualquer parte do trabalho, registre **para cada uso relevante**:

| Item | O que registrar |
|------|------------------|
| **Ferramenta e etapa** | Qual IA foi usada e em qual parte do trabalho (ex.: pesquisa sobre o setor da organização, redação do README, organização dos requisitos, revisão ortográfica/gramatical). |
| **Motivação** | Por que o grupo recorreu à IA nesse ponto específico. |
| **Prompt(s) utilizados** | Texto exato (ou muito próximo) do que foi perguntado/pedido à IA. |
| **Resposta recebida** | Resumo ou trecho relevante da resposta da IA. |
| **Fontes consultadas e verificadas** | Se a IA citou fontes/dados, quais foram checadas pelo grupo e como (ex.: comparação com o que foi observado na visita de campo). |
| **Trechos rejeitados ou corrigidos** | O que da resposta da IA foi descartado, editado ou corrigido manualmente, e por quê. |
| **Justificativa da escolha final** | Por que o grupo manteve, adaptou ou rejeitou o que a IA sugeriu. |
| **Reflexão crítica** | Limites, vieses ou erros identificados no uso da IA nessa etapa (ex.: informação desatualizada, alucinação, generalização incorreta sobre o tipo de organização). |

*Se o grupo não usou nenhuma ferramenta de IA, declare isso explicitamente nesta seção.*

---

<!-- ## Critérios Atitudinais (20%)
**Estes critérios NÃO constam explicitamente como item de entrega no README.** Eles são avaliados por meio de **Avaliação 360º entre os integrantes do grupo** (cada membro avalia os colegas de equipe) e, no caso da Colaboração, também pela **colaboração equilibrada no histórico de commits** do repositório GitHub — não pela leitura do restante do repositório nem pela apresentação:

- **Participação (5%):** envolvimento nas discussões técnicas e nas decisões do grupo.
- **Comprometimento (5%):** cumprimento de prazos e responsabilidades assumidas.
- **Colaboração (5%):** respeito às contribuições dos colegas, cooperação na construção do projeto e colaboração equilibrada no histórico de commits do repositório GitHub.
- **Autonomia (5%):** busca independente de soluções e proposta de melhorias. --> 
