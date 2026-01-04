# Firebase Authentication - Guia de Implementação

## 📋 Visão Geral

O sistema de autenticação foi implementado usando **Firebase Authentication** integrado com o sistema de PIN existente. Agora a aplicação suporta múltiplos usuários com dados completamente isolados.

## 🔐 Funcionalidades Implementadas

### 1. Sistema de Autenticação

#### Registro de Usuário
- Email e senha (mínimo 6 caracteres)
- Nome completo
- Tipo de usuário (Paciente ou Cuidador)
- PIN personalizado de 4 dígitos
- Validação em tempo real

**Localização**: `lib/screens/auth/register_screen.dart`

#### Login
- Email e senha
- Recuperação de senha via email
- Mensagens de erro descritivas
- Tratamento de casos especiais (conta bloqueada, muitas tentativas, etc.)

**Localização**: `lib/screens/auth/login_screen.dart`

#### Logout
- Logout completo do Firebase Auth
- Limpeza do estado local
- Redirecionamento automático para tela de login

### 2. Tipos de Usuário

#### Paciente
- Usuário final que gerencia sua própria medicação
- Acesso total aos seus medicamentos
- Configurações pessoais
- Histórico individual

#### Cuidador
- Profissional ou familiar que cuida de outras pessoas
- Mesmas funcionalidades que o paciente
- **Preparado** para vincular-se a múltiplos pacientes (funcionalidade futura)

### 3. Perfil de Usuário

**Localização**: `lib/screens/auth/profile_screen.dart`

Mostra:
- Avatar (foto ou ícone padrão)
- Nome e email
- Badge do tipo de usuário
- UID do Firebase
- Data de criação da conta
- Último acesso
- Gerenciamento de PIN
- Botão de logout

### 4. Isolamento de Dados

Cada usuário tem seus próprios dados isolados no Firestore:

```
users/
├── {userId1}/
│   ├── medicamentos/
│   │   ├── {medId1}
│   │   └── {medId2}
│   ├── configuracoes/
│   │   └── app_config
│   └── historico/
│       ├── {histId1}
│       └── {histId2}
└── {userId2}/
    ├── medicamentos/
    ├── configuracoes/
    └── historico/
```

## 🏗️ Arquitetura

### Modelo de Usuário

**Arquivo**: `lib/models/user_model.dart`

```dart
class UserModel {
  final String uid;              // ID único do Firebase
  final String email;            // Email de login
  final String? displayName;     // Nome de exibição
  final String? photoUrl;        // URL da foto de perfil
  final String role;             // 'patient' ou 'caregiver'
  final String pin;              // PIN de 4 dígitos
  final List<String> linkedUsers; // UIDs de usuários vinculados
  final DateTime createdAt;      // Data de criação
  final DateTime lastLogin;      // Último acesso
}
```

### AuthService

**Arquivo**: `lib/services/auth_service.dart`

Gerencia toda a lógica de autenticação:

#### Métodos Principais

```dart
// Registro
Future<UserModel?> registerWithEmailPassword({
  required String email,
  required String password,
  required String displayName,
  required String role,
  String pin = '1234',
})

// Login
Future<UserModel?> signInWithEmailPassword({
  required String email,
  required String password,
})

// Logout
Future<void> signOut()

// Recuperação de senha
Future<bool> sendPasswordResetEmail(String email)

// Atualizar PIN
Future<bool> updateUserPin(String newPin)

// Vincular cuidador a paciente
Future<bool> linkCaregiverToPatient(String patientUid)
```

#### Propriedades

```dart
Stream<User?> authStateChanges  // Stream de mudanças de autenticação
User? currentUser               // Usuário atual do Firebase
UserModel? currentUserModel     // Modelo completo do usuário
bool isLoggedIn                 // Se há usuário autenticado
```

### FirebaseService

**Arquivo**: `lib/services/firebase_service.dart`

Atualizado para isolar dados por usuário:

#### Antes (dados globais)
```dart
collection('medicamentos')
```

#### Depois (dados por usuário)
```dart
collection('users')
  .doc(userId)
  .collection('medicamentos')
```

Todos os métodos foram atualizados:
- `getMedicamentosStream()`
- `getMedicamentos()`
- `adicionarMedicamento()`
- `atualizarMedicamento()`
- `deletarMedicamento()`
- `atualizarEstadoMedicamento()`
- `getConfiguracoes()`
- `salvarConfiguracoes()`
- `adicionarAoHistorico()`
- `getHistorico()`

### AuthWrapper

**Arquivo**: `lib/screens/auth/auth_wrapper.dart`

Componente que decide qual tela mostrar baseado no estado de autenticação:

```dart
StreamBuilder<User?>(
  stream: AuthService().authStateChanges,
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      return HomeScreen();  // Usuário autenticado
    }
    return LoginScreen();   // Sem autenticação
  },
)
```

## 🚀 Como Usar

### 1. Primeiro Acesso

1. Execute a aplicação
2. Verá a tela de login
3. Clique em "Registrar"
4. Preencha:
   - Nome completo
   - Email
   - Tipo de usuário (Paciente ou Cuidador)
   - Senha (mínimo 6 caracteres)
   - Confirme a senha
   - PIN de 4 dígitos
5. Clique em "CRIAR CONTA"

### 2. Login

1. Digite seu email e senha
2. Clique em "ENTRAR"
3. Será redirecionado para a tela principal

### 3. Recuperar Senha

1. Na tela de login
2. Digite seu email
3. Clique em "Esqueceu a senha?"
4. Receberá um email com instruções

### 4. Ver Perfil

1. Na tela principal
2. Clique no ícone de perfil (👤) no canto superior direito
3. Verá suas informações
4. Pode atualizar seu PIN

### 5. Logout

1. Entre no perfil
2. Clique em "SAIR DA CONTA"
3. Confirme
4. Será redirecionado para tela de login

## 🔧 Modo Desenvolvimento (Mock)

Para testar sem Firebase:

**Arquivo**: `lib/main.dart`

```dart
const bool USE_MOCK_DATA = true;  // Ativa modo mock
```

Quando `USE_MOCK_DATA = true`:
- Autenticação é desabilitada
- Vai direto para HomeScreen
- Usa dados mock locais
- Não precisa configurar Firebase

## 🔒 Segurança

### Firestore Rules (Recomendado)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Usuários podem apenas ler/escrever seus próprios dados
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      match /medicamentos/{medicamentoId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
      
      match /configuracoes/{configId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
      
      match /historico/{historicoId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```

### Boas Práticas Implementadas

1. ✅ **Validação de Email**: Verifica formato antes de enviar
2. ✅ **Senha Forte**: Mínimo 6 caracteres (Firebase requerimento)
3. ✅ **PIN Seguro**: Validação de 4 dígitos numéricos
4. ✅ **Tratamento de Erros**: Mensagens descritivas para o usuário
5. ✅ **Isolamento de Dados**: Cada usuário só acessa seus dados
6. ✅ **Logout Seguro**: Limpa completamente o estado
7. ✅ **Recuperação de Senha**: Via email do Firebase

### Melhorias Futuras de Segurança

- [ ] Criptografar PIN no Firestore
- [ ] Autenticação de dois fatores (2FA)
- [ ] Biometria (impressão digital/Face ID)
- [ ] Timeout de sessão automático
- [ ] Histórico de acessos
- [ ] Notificação de login em novo dispositivo

## 🧪 Testes

### Testar Registro

1. Use um email válido e único
2. Senha com pelo menos 6 caracteres
3. Verifique se o usuário aparece no Firebase Console
4. Verifique se os dados estão em `users/{userId}`

### Testar Login

1. Use credenciais de um usuário existente
2. Verifique se entra na HomeScreen
3. Verifique se o perfil mostra dados corretos

### Testar Isolamento

1. Registre 2 usuários diferentes
2. Adicione medicamentos em cada conta
3. Faça logout e login alternado
4. Verifique que cada usuário vê apenas seus dados

### Testar Recuperação de Senha

1. Use um email cadastrado
2. Clique em "Esqueceu a senha?"
3. Verifique o email recebido
4. Use o link para redefinir

## 🐛 Troubleshooting

### Erro: "User not found"
- Verifique se o email está correto
- Verifique se o usuário foi criado no Firebase Console

### Erro: "Wrong password"
- Senha incorreta
- Tente recuperar senha

### Erro: "Email already in use"
- Esse email já está registrado
- Tente fazer login ou use outro email

### Erro: "Weak password"
- Senha precisa ter pelo menos 6 caracteres
- Use uma senha mais forte

### Não recebe email de recuperação
- Verifique spam/lixo eletrônico
- Verifique se o email está correto
- Aguarde alguns minutos

### Dados não aparecem após login
- Verifique conexão com internet
- Verifique Firestore Rules
- Verifique console para erros

## 📱 Fluxo de Telas

```
AuthWrapper
    ↓
    ├─→ (Não autenticado) LoginScreen
    │       ↓
    │       ├─→ RegisterScreen → (Após registro) HomeScreen
    │       └─→ (Após login) HomeScreen
    │
    └─→ (Autenticado) HomeScreen
            ↓
            └─→ ProfileScreen → (Após logout) LoginScreen
```

## 🎯 Próximos Passos

1. **Vinculação Cuidador-Paciente**
   - Cuidador pode gerenciar múltiplos pacientes
   - Código de vinculação único
   - Permissões granulares

2. **Sincronização em Tempo Real**
   - Notificar cuidador sobre mudanças
   - Dashboard do cuidador

3. **Avatares Personalizados**
   - Upload de foto de perfil
   - Integração com Firebase Storage

4. **Autenticação Social**
   - Login com Google
   - Login com Apple
   - Login com Facebook

5. **Autenticação Biométrica**
   - Impressão digital
   - Face ID
   - Como alternativa ao PIN

---

**Implementado com ❤️ para facilitar o gerenciamento de medicação com segurança e privacidade**

