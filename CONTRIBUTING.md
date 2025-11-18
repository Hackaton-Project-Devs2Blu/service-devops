# Padrões de Contribuição do Projeto (Hackathon)

## 1. Filosofia: Commits Pequenos, PRs Atômicos

Nosso recurso mais valioso neste hackathon é o **tempo de revisão de código**.

* **Regra de Ouro:** Um Pull Request (PR) deve ser **pequeno** e **focado**. Ele deve endereçar *apenas uma* funcionalidade ou *apenas uma* correção.
* **Tamanho Máximo:** Um PR não deve conter mais do que **~300 linhas de modificação** (excluindo arquivos gerados). Se for maior, quebre-o em PRs menores.
* **Benefício:** PRs pequenos são revisados em minutos, não em horas. Isso evita gargalos e mantém a `develop` sempre fresca.

## 2. Estratégia de Branching (Git Flow Leve)

Temos duas branches protegidas e permanentes:
* `main`: Representa o código de produção (o que será apresentado).
* `develop`: Nossa branch principal de integração. **Todo o trabalho novo começa e termina aqui.**

### Padrão de Nomenclatura de Branch

Sempre crie sua branch a partir da `develop`. Use os seguintes prefixos:

* **Nova Funcionalidade:** `feat/`
    * *Exemplo:* `feat/endpoint-login`
* **Correção de Bug:** `fix/`
    * *Exemplo:* `fix/cors-error-no-java`
* **Melhoria/Refatoração:** `refactor/`
    * *Exemplo:* `refactor/simplificar-jwt-service`

### Fluxo de Trabalho Padrão

1.  `git checkout develop`
2.  `git pull origin develop` (Sempre sincronize antes de começar)
3.  `git checkout -b feat/minha-nova-feature`
4.  *... faça seu trabalho (commits pequenos) ...*
5.  `git push origin feat/minha-nova-feature`
6.  Abra um **Pull Request (PR)** com o *target* (alvo) na branch `develop`.

> **Exceção (Hotfix):** Se um bug *crítico* for encontrado na `main` (após uma demo, por exemplo), a branch deve ser criada a partir da `main` com o prefixo `hotfix/` e ter como alvo a `main`.
> *Exemplo: `hotfix/corrigir-crash-demo`*

## 3. Padrão de Mensagens de Commit

Usaremos **Conventional Commits** para manter nosso histórico limpo e legível. Isso nos ajuda a entender rapidamente o que mudou.

**Formato:** `tipo(escopo): mensagem curta`

* **`feat`:** (Nova Funcionalidade)
    * `feat(java-api): adiciona endpoint POST /usuarios`
* **`fix`:** (Correção de bug)
    * `fix(flutter-ui): corrige botão de login que não respondia`
* **`docs`:** (Mudanças na documentação)
    * `docs: atualiza README com instruções de setup`
* **`style`:** (Formatação, linting, sem mudança de lógica)
    * `style(csharp): formata código com dotnet format`
* **`refactor`:** (Refatoração sem mudança de comportamento)
    * `refactor(java-api): extrai lógica de validação para UserValidator`
* **`test`:** (Adicionando ou corrigindo testes)
    * `test(csharp-service): adiciona teste unitário para CalculoService`

## 4. Definição de "Pronto" (Definition of Done) para um PR

Um PR só pode ser "mergeado" na `develop` se todas as condições abaixo forem verdadeiras:

1.  **[x] PR Atômico:** O PR endereça apenas *uma* coisa (ver Filosofia).
2.  **[x] Título e Descrição Claros:** O título segue o padrão Conventional Commits e a descrição explica *o que* foi feito e *por que*.
3.  **[x] Linked Issue (Se aplicável):** O PR menciona a Issue que ele resolve (ex: `Resolves #12`).
4.  **[x] Revisão Aprovada:** O PR tem pelo menos **1 aprovação** de outro membro da equipe (conforme nosso `ruleset`).
5.  **[x] Conflitos Resolvidos:** O PR não tem nenhum conflito de merge com a `develop`.
6.  **[x] CI Verde (Futuro):** O pipeline de CI (build, test, scan) está passando (assim que o implementarmos).
