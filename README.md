# Biblioteca Nair Magalhães Guerra — Biblivre Reestruturado

Reestruturação visual e de interface do **Biblivre 4** para a Biblioteca
Nair Magalhães Guerra.

⚠️ **Isto NÃO é um patch de personalização.** É uma **versão derivada
completa** do Biblivre, com CSS reescrito e páginas JSP modificadas
por toda a aplicação. Para migrar para outro ambiente, é preciso
substituir a instalação inteira — não basta copiar alguns arquivos.

---

## Índice

- [Sobre esta versão](#sobre-esta-versão)
- [O que mudou em relação ao Biblivre original](#o-que-mudou-em-relação-ao-biblivre-original)
- [Como fazer backup](#como-fazer-backup)
- [Como migrar para outro servidor](#como-migrar-para-outro-servidor)
- [Como aplicar em produção](#como-aplicar-em-produção)
- [Estrutura típica da instalação](#estrutura-típica-da-instalação)
- [Detalhes técnicos das principais mudanças](#detalhes-técnicos-das-principais-mudanças)
- [Reversão para o Biblivre original](#reversão-para-o-biblivre-original)
- [Licença e créditos](#licença-e-créditos)

---

## Sobre esta versão

Este repositório contém o **Biblivre 4 reestruturado**. A instalação
completa está organizada da mesma forma que o Biblivre oficial, mas com:

- **Todos os arquivos CSS** reescritos sob uma camada de tema moderno
- **Múltiplos arquivos JSP** modificados (home redesenhada, menus,
  páginas de busca, circulação, catalogação e administração)
- **Scripts JavaScript** novos para comportamentos específicos
  (auto-hide do cabeçalho, item "Início" no menu, botão de voltar)

O framework original, banco de dados e regras de negócio continuam
intactos — apenas a camada de apresentação foi reestruturada.

---

## O que mudou em relação ao Biblivre original

### Interface

- Home editorial com hero navy, busca integrada, temas em alta e
  botão "Descobrir"
- Estante temática com 11 categorias navegáveis (Fantasia, HQ,
  Animais, Terror, Ciência, Clássicos, etc.)
- Rankings: mais lidos, desafio das turmas, clube da leitura
- Painel de atrasos visível apenas para usuários logados
- Cabeçalho com auto-hide: sobe ao tirar o mouse, desce ao passar
  na faixa superior da tela
- Item "Início" no menu de navegação, presente em todas as páginas
- Fonte editorial: Lora (títulos) + Inter (corpo)
- Paleta sóbria: tinta, papel, bronze e bordô
- Acessibilidade: foco visível, `prefers-reduced-motion`, contraste AA

### Arquivos modificados

**CSS** — todos os arquivos de estilo foram reorganizados sob uma
camada de tema central (`biblivre.modern.css`) que sobrescreve o CSS
base do Biblivre. Arquivos como `biblivre.core.css`, `biblivre.index.css`
e `biblivre.multi_schema.css` continuam sendo carregados, mas o tema
moderno tem precedência.

**JSP** — os arquivos `.jsp/` foram revisados página a página. A maior
parte das mudanças está em:

- `jsp/index.jsp` — home completamente redesenhada
- `jsp/search/*.jsp` — layout modernizado dos resultados
- `jsp/circulation/*.jsp` — formulários e listagens
- `jsp/cataloging/*.jsp` — MARC e visualizador bibliográfico
- `jsp/administration/*.jsp` — telas de configuração
- Todos os demais — receberam inclusão do script `menu-inicio.js`

**JavaScript** — novos scripts em `static/scripts/`:

- `menu-inicio.js` — injeta o item "Início" no menu, com detecção
  automática da base (funciona em qualquer domínio/pasta)
- `home-button.js` (opcional) — botão flutuante de voltar à home

---

## Como fazer backup

Como a reestruturação afeta a instalação inteira, o backup precisa
ser da **pasta `Biblivre4/` completa**.

### Windows (PowerShell)

```powershell
cd "C:\Program Files\Apache Software Foundation\Tomcat 7.0\webapps"
Compress-Archive -Path "Biblivre4" -DestinationPath "Biblivre4-backup-$(Get-Date -Format 'yyyy-MM-dd').zip"
