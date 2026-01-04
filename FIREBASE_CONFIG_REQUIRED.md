# ⚠️ IMPORTANTE: Configuração do Firebase

## ❌ Erro Atual

A aplicação está usando **configurações demo** do Firebase que não funcionam em produção.

## 🔧 Como Configurar Corretamente

### Opção 1: Usar FlutterFire CLI (Recomendado)

1. **Instalar FlutterFire CLI:**
```bash
dart pub global activate flutterfire_cli
```

2. **Fazer login no Firebase:**
```bash
firebase login
```

3. **Configurar o projeto:**
```bash
flutterfire configure
```

Este comando irá:
- Criar/selecionar um projeto Firebase
- Gerar automaticamente o arquivo `lib/firebase_options.dart` com as configurações reais
- Configurar todas as plataformas (Android, iOS, Web)

### Opção 2: Configurar Manualmente

#### Para Web:

1. **No Firebase Console:**
   - Vá para Project Settings > Your apps
   - Clique em "Add app" > Web (ícone </>)
   - Registre seu app
   - Copie as configurações do Firebase

2. **Cole no arquivo `lib/firebase_options.dart`:**
```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'SUA_API_KEY_AQUI',
  appId: 'SEU_APP_ID_AQUI',
  messagingSenderId: 'SEU_MESSAGING_SENDER_ID',
  projectId: 'SEU_PROJECT_ID',
  authDomain: 'seu-project.firebaseapp.com',
  storageBucket: 'seu-project.appspot.com',
  measurementId: 'G-XXXXXXXXXX',
);
```

#### Para Android:

1. **No Firebase Console:**
   - Adicione um app Android
   - Package name: `com.example.medicamentos`
   - Baixe `google-services.json`
   - Coloque em `android/app/google-services.json`

2. **Atualize `lib/firebase_options.dart`:**
```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'SUA_ANDROID_API_KEY',
  appId: 'SEU_ANDROID_APP_ID',
  messagingSenderId: 'SEU_MESSAGING_SENDER_ID',
  projectId: 'SEU_PROJECT_ID',
  storageBucket: 'seu-project.appspot.com',
);
```

## 🌐 Para Testar Agora (Web)

Se você quer apenas testar a aplicação no web sem Firebase real:

1. **Use o Emulador Firebase:**
```bash
firebase emulators:start
```

2. **Configure para usar emulador** (adicione no `main.dart` após inicializar):
```dart
if (kDebugMode && kIsWeb) {
  FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
}
```

## 📱 Para Testar no Android

Se você configurou o `google-services.json` corretamente:

```bash
flutter run -d android
```

## ✅ Verificar se Configuração Está Correta

Após configurar, execute:

```bash
flutter run -d chrome
```

Você deve ver no console:
```
Firebase inicializado com sucesso
```

## 🔍 Troubleshooting

### Erro: "FirebaseOptions cannot be null"
- Você está usando as configurações demo
- Siga os passos acima para configurar corretamente

### Erro: "No Firebase App '[DEFAULT]' has been created"
- O Firebase não foi inicializado
- Verifique se há erros no console durante a inicialização

### Erro: "API key not valid"
- Suas configurações estão incorretas
- Reconfigure usando FlutterFire CLI

## 📝 Arquivo Atual

O arquivo `lib/firebase_options.dart` atual contém **configurações DEMO** que devem ser substituídas por configurações reais de um projeto Firebase.

### Valores Demo Atuais (NÃO FUNCIONAM):
- `apiKey: 'AIzaSyDemoKeyForDevelopment123456789'`
- `projectId: 'medicamentos-dev'`
- etc.

Estes valores precisam ser substituídos pelos valores reais do seu projeto Firebase.

## 🚀 Próximos Passos

1. ✅ Crie um projeto no Firebase Console: https://console.firebase.google.com/
2. ✅ Execute `flutterfire configure` para gerar configurações reais
3. ✅ (Opcional) Configure emuladores para desenvolvimento local
4. ✅ Execute `flutter run` novamente

---

**Nota:** As configurações demo permitem que a aplicação compile, mas **NÃO** funcionarão com o Firebase real. Você precisa configurar um projeto Firebase real para usar Firestore, Authentication e Cloud Messaging.

