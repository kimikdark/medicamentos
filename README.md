# Gestor de Medicação para Idosos

## Objetivo do Projeto

Uma aplicação de saúde focada em ajudar idosos a gerir a sua medicação diária de forma simples e intuitiva, ao mesmo tempo que oferece tranquilidade aos familiares através de notificações.

## Funcionalidades Implementadas

### Ecrã Principal (Foco no Idoso)

*   **Lista de Medicamentos:** Apresenta uma lista clara e legível dos medicamentos do dia.
*   **Ações Simplificadas:** O idoso tem apenas duas interações possíveis:
    1.  Tocar em **"Tomei"** para confirmar a toma de um medicamento.
    2.  Tocar no card do medicamento para ver mais detalhes.
*   **Feedback Visual:**
    *   Ao clicar em "Tomei", o botão muda de cor e exibe o texto "✓ Tomado", oferecendo uma confirmação visual imediata.

### Ecrã de Detalhes

*   **Informação Clara:** Ao selecionar um medicamento, o idoso vê:
    *   Nome e dose do medicamento.
    *   Horários das tomas.
    *   Instruções de uso (ex: "Tomar após o almoço").
*   **Navegação Simples:** Um botão "Voltar" grande e de fácil acesso no topo do ecrã permite retornar à lista principal sem complicações.
*   **Segurança:** Este ecrã é apenas para visualização, impedindo que o idoso altere qualquer informação por engano.

### Design e Interface

*   **Paleta de Cores:** Utiliza uma paleta de cores extraída do logotipo, com tons de verde e azul, pensada para ser agradável e de alto contraste.
*   **Logotipo:** O logotipo da aplicação está integrado na barra de navegação principal.
*   **Simplicidade:** A interface foi desenhada para ser o mais simples possível, sem menus complexos ou elementos desnecessários que possam confundir o utilizador idoso.

## Próximos Passos

*   Implementar a animação e o feedback tátil ao clicar em "Tomei".
*   Integrar o Firebase para:
    *   Gestão de utilizadores (Autenticação).
    *   Armazenamento dos dados de medicação (Firestore).
    *   Envio de notificações push para os familiares (Firebase Cloud Messaging).
*   Adicionar a funcionalidade de histórico diário de tomas para consulta dos familiares.
*   Permitir a adição de fotos dos comprimidos para fácil identificação.
