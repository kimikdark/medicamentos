# App to Drugs - Aplicação de Gestão de Medicação

## 📱 Sobre o Projeto

Aplicação móvel Android para tracking e gestão de medicação, especialmente desenvolvida para idosos e pessoas com problemas de saúde. A interface foi projetada com **alta legibilidade** e **botões grandes** para facilitar o uso.

## 🎯 Funcionalidades Principais

### Tela Principal (Home)
- ✅ AppBar verde com nome "app to drugs" e botão de administração
- ✅ Lista de medicamentos "Por Tomar" e "Tomado"
- ✅ Badges coloridos mostrando estados (clicáveis para mudar para "Tomado")
- ✅ Ícones indicando tipo de medicamento (comprimido, gotas, injetável, etc.)
- ✅ Ordenação cronológica por hora de toma
- ✅ Botão "+" para criar entradas já finalizadas
- ✅ Ao clicar em medicamento, abre tela de detalhes

### Sistema de Estados
- **Por Tomar** (verde): Medicamento pendente
- **Tomado** (azul): Confirmado pelo usuário
- **Finalizado** (cinza): Após X minutos de ser marcado como tomado (configurável, padrão 10min)
- **Não Tomado** (vermelho): Estado manual - medicamento pode ser marcado manualmente como não tomado
- **Cancelado** (preto): Cancelado manualmente

### Transições Automáticas
- ✅ **Tomado → Finalizado**: Após tempo configurável (padrão 10 minutos) desde o momento em que foi marcado como tomado
- 📌 **Medicamentos "Por Tomar" permanecem visíveis**: Não mudam automaticamente de estado se não forem tomados

### Notificações
- ✅ Notificações locais na hora de cada toma
- ✅ Mensagem: "{Nome do medicamento} por tomar"
- ✅ Clicável para abrir a aplicação
- ✅ Integração com Firebase Cloud Messaging (FCM)

### Autenticação e Gestão de Usuários
- ✅ **Sistema de Autenticação Firebase Auth**
  - Login com email e senha
  - Registro de novos usuários
  - Recuperação de senha via email
  - Logout seguro
- ✅ **Tipos de Usuário**
  - **Paciente**: Para uso próprio (gerenciar própria medicação)
  - **Cuidador**: Para gerenciar medicação de outras pessoas
- ✅ **Perfil de Usuário**
  - Visualização de informações da conta
  - Gerenciamento de PIN pessoal
  - Data de criação e último acesso
- ✅ **Isolamento de Dados**
  - Cada usuário tem seus próprios medicamentos
  - Configurações individualizadas por usuário
  - Histórico separado por usuário
- ✅ **Modo Mock/Desenvolvimento**
  - Possibilidade de usar a app sem Firebase (USE_MOCK_DATA = true)
  - Facilita testes e desenvolvimento local

### Área Administrativa (Protegida por PIN)
Acesso através do botão no topo direito com verificação de PIN de 4 dígitos.

#### 1. Configuração de Medicação
- ✅ Lista de medicamentos "Por Tomar"
- ✅ Botões para editar e apagar
- ✅ Botão "+" para adicionar novo medicamento
- ✅ Formulário com campos:
  - **Obrigatórios**: Nome, Hora da toma
  - **Opcionais**: Dose, Tipo, Notas, Repetição (diária/semanal/mensal)

#### 2. Administração
- ✅ Configurar PIN de acesso
- ✅ Definir tempo de transição "Tomado → Finalizado"
- ✅ Definir tempo de transição "Por Tomar → Não Tomado"
- ✅ Configurar números de telefone dos cuidadores (para SMS)

#### 3. Histórico
- ✅ Visualização de todas as entradas em todos os estados
- ✅ Filtro por texto (buscar por nome)
- ✅ Filtro por estado
- ✅ Ordenação cronológica (crescente/decrescente)

#### 4. Acessibilidade
- ✅ Opção para Screen Reader
- ✅ Modo Alto Contraste
- ✅ Ajuste de tamanho de texto (80% a 200%)
- ✅ Preview em tempo real

#### 5. Parcerias
- ✅ Carrossel automático com produtos/serviços de parceiros
- ✅ Cards clicáveis com links externos
- ✅ Lista completa de parceiros
- ✅ Dados fictícios para demonstração

### Tela de Detalhes
- ✅ Exibe todas as informações do medicamento
- ✅ Ícone grande do tipo de medicamento
- ✅ Badge de estado atual
- ✅ Hora da toma
- ✅ Notas (se disponível)
- ✅ Botão grande "TOMEI" (apenas para estado "Por Tomar")

## 🏗️ Arquitetura do Projeto

```
lib/
├── main.dart                          # Inicialização da app
├── models/                            # Modelos de dados
│   ├── medicamento.dart              # Modelo de medicamento com estados
│   ├── configuracao.dart             # Modelo de configurações
│   └── user_model.dart               # Modelo de usuário
├── screens/                           # Telas da aplicação
│   ├── auth/                          # Autenticação
│   │   ├── auth_wrapper.dart         # Gerencia estado de autenticação
│   │   ├── login_screen.dart         # Tela de login
│   │   ├── register_screen.dart      # Tela de registro
│   │   └── profile_screen.dart       # Perfil do usuário
│   ├── home/
│   │   └── home_screen.dart          # Tela principal
│   ├── detalhes/
│   │   └── detalhes_medicamento_screen.dart
│   ├── admin/                         # Área administrativa
│   │   ├── pin_verification_screen.dart
│   │   ├── admin_main_screen.dart    # Navbar com 5 opções
│   │   ├── configuracao_medicacao_screen.dart
│   │   ├── administracao_screen.dart
│   │   ├── historico_screen.dart
│   │   ├── acessibilidade_screen.dart
│   │   └── parcerias_screen.dart
│   └── formulario/
│       └── medicamento_form_screen.dart
├── services/                          # Lógica de negócio
│   ├── firebase_service.dart         # CRUD Firestore (isolado por usuário)
│   ├── auth_service.dart             # Firebase Auth + PIN
│   ├── notification_service.dart     # Notificações locais e FCM
│   ├── sms_service.dart              # Envio de SMS
│   └── estado_service.dart           # Transições automáticas
├── widgets/                           # Componentes reutilizáveis
│   ├── medicamento_card.dart
│   ├── estado_badge.dart
│   └── custom_app_bar.dart
└── utils/                             # Utilitários
    ├── constants.dart                 # Cores, tamanhos, strings
    └── helpers.dart                   # Funções auxiliares
```

## 🔥 Firebase

### Collections Firestore
- **users**: Armazena dados dos usuários (perfil, role, PIN)
  - **{userId}/medicamentos**: Medicamentos de cada usuário (isolados)
  - **{userId}/configuracoes**: Configurações de cada usuário
  - **{userId}/historico**: Histórico de cada usuário
- **medicamentos** (legacy): Mantido para compatibilidade com modo mock
- **configuracoes** (legacy): Mantido para compatibilidade com modo mock
- **historico** (legacy): Mantido para compatibilidade com modo mock

### Serviços Utilizados
- ✅ **Firestore**: Database em tempo real com dados isolados por usuário
- ✅ **Firebase Auth**: Autenticação completa com email/senha
- ✅ **Firebase Cloud Messaging (FCM)**: Notificações push

## 📦 Dependências Principais

```yaml
dependencies:
  # Firebase
  firebase_core: ^3.8.1
  cloud_firestore: ^5.5.1
  firebase_auth: ^5.3.4
  firebase_messaging: ^15.1.5
  
  # Notificações
  flutter_local_notifications: ^18.0.1
  timezone: ^0.9.4
  
  # Utilitários
  url_launcher: ^6.3.1
  shared_preferences: ^2.3.3
  pin_code_fields: ^8.0.1
  carousel_slider: ^5.0.0
  intl: ^0.19.0
  provider: ^6.1.2
```

## 🎨 Design para Acessibilidade

### Cores
- **Verde Principal**: `#82CF40`
- **Verde Escuro**: `#388E3C` (navbar)
- **Azul**: `#2D9CDB` (estado "Tomado")
- **Vermelho**: Estados de erro/não tomado
- **Cinza**: Estado finalizado

### Tamanhos
- **Botões**: Mínimo 56dp de altura (recomendado para idosos)
- **Fonte base**: 18sp (escalável via configurações)
- **Ícones**: 48dp (grandes para facilitar visualização)

## 🚀 Como Executar

### ⚠️ IMPORTANTE: Configuração do Firebase

**A aplicação usa configurações DEMO do Firebase que precisam ser substituídas.**

Antes de executar, você deve:
1. Configurar um projeto Firebase real seguindo: **[FIREBASE_CONFIG_REQUIRED.md](FIREBASE_CONFIG_REQUIRED.md)**
2. OU usar emuladores Firebase para desenvolvimento local

### Pré-requisitos
1. Flutter SDK instalado
2. Android Studio ou VS Code com extensões Flutter
3. Projeto Firebase configurado

### Passos
```bash
# Instalar dependências
flutter pub get

# Executar em modo debug
flutter run

# Build para produção
flutter build apk --release
```

### Configuração Firebase
1. Criar projeto no [Firebase Console](https://console.firebase.google.com/)
2. Adicionar app Android
3. Baixar `google-services.json` e colocar em `android/app/`
4. Habilitar Firestore, Authentication e Cloud Messaging

## 🔐 Segurança

- **PIN padrão**: `1234` (configurável na área de administração)
- **Firestore Rules**: Configurar regras de segurança em produção
- **Dados locais**: PIN armazenado em SharedPreferences (criptografar em produção)

## 📝 Próximos Passos / TODOs

- [x] **Implementar autenticação real com Firebase Auth (múltiplos usuários)** ✅
  - Sistema completo de registro e login
  - Suporte para múltiplos tipos de usuário (Paciente e Cuidador)
  - Perfil de usuário com gerenciamento de PIN
  - Dados isolados por usuário (cada usuário vê apenas seus medicamentos)
  - Recuperação de senha via email
- [ ] Implementar vinculação entre cuidadores e pacientes
- [ ] Adicionar fotos aos medicamentos
- [ ] Implementar repetição semanal/mensal completa
- [ ] Adicionar gráficos de adesão ao tratamento
- [ ] Implementar sincronização offline robusta
- [ ] Background tasks para transições de estado (WorkManager)
- [ ] Envio de SMS real via serviço terceiro (Twilio)
- [ ] Testes unitários e de integração
- [ ] Internacionalização (i18n)
- [ ] Modo escuro

## 👥 Uso

### Para Idosos (Tela Principal)
1. Ver lista de medicamentos pendentes
2. Tocar no badge verde "Por Tomar" para marcar como tomado
3. Tocar no medicamento para ver detalhes

### Para Cuidadores (Área Admin)
1. Tocar no botão de administração (canto superior direito)
2. Inserir PIN (padrão: 1234)
3. Configurar medicamentos, horários e alertas
4. Monitorar histórico de tomas

## 📄 Licença

Este projeto é para fins educacionais e demonstrativos.

---

**Desenvolvido com ❤️ para facilitar o cuidado de pessoas que precisam de ajuda com medicação**

