# Configuração do Firebase para Android

## Passos para Configurar Firebase

### 1. Criar Projeto no Firebase Console
1. Acesse [Firebase Console](https://console.firebase.google.com/)
2. Clique em "Adicionar projeto"
3. Nome do projeto: "medicamentos" (ou outro nome de sua preferência)
4. Siga os passos de criação

### 2. Adicionar App Android
1. No console do Firebase, clique no ícone Android
2. **Package name**: `com.example.medicamentos`
3. **App nickname**: "App to Drugs"
4. Baixe o arquivo `google-services.json`
5. Coloque o arquivo em: `android/app/google-services.json`

### 3. Habilitar Serviços

#### Firestore Database
1. No menu lateral, vá em "Firestore Database"
2. Clique em "Criar banco de dados"
3. Selecione "Iniciar no modo de teste" (para desenvolvimento)
4. Escolha localização: `europe-west1` (ou mais próxima)

**Regras de segurança (para desenvolvimento):**
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;  // APENAS PARA DESENVOLVIMENTO
    }
  }
}
```

**⚠️ IMPORTANTE**: Em produção, configure regras mais seguras!

#### Authentication
1. No menu lateral, vá em "Authentication"
2. Clique em "Primeiros passos"
3. Por enquanto, não ative nenhum provedor (apenas preparação futura)

#### Cloud Messaging (FCM)
1. Já está automaticamente ativado ao adicionar o app Android
2. Token FCM será gerado automaticamente na primeira execução

### 4. Configurar build.gradle

**android/build.gradle** (nível projeto):
```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

**android/app/build.gradle**:
```gradle
plugins {
    id "com.android.application"
    id "kotlin-android"
    id "dev.flutter.flutter-gradle-plugin"
    id "com.google.gms.google-services"  // Adicione esta linha
}

android {
    defaultConfig {
        minSdkVersion 21  // Importante para Firebase
        targetSdkVersion flutter.targetSdkVersion
    }
}
```

### 5. Permissões Necessárias

**android/app/src/main/AndroidManifest.xml**:
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Permissões necessárias -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.SEND_SMS" />
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
    <uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
    <uses-permission android:name="android.permission.USE_EXACT_ALARM" />
    <uses-permission android:name="android.permission.WAKE_LOCK" />
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />

    <application
        android:label="App to Drugs"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        
        <!-- Receiver para notificações -->
        <receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" />
        <receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
            <intent-filter>
                <action android:name="android.intent.action.BOOT_COMPLETED"/>
                <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
                <action android:name="android.intent.action.QUICKBOOT_POWERON" />
                <action android:name="com.htc.intent.action.QUICKBOOT_POWERON"/>
            </intent-filter>
        </receiver>
        
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            <meta-data
              android:name="io.flutter.embedding.android.NormalTheme"
              android:resource="@style/NormalTheme"
              />
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
        
        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>
</manifest>
```

### 6. Testar Conexão

Execute o app e verifique os logs:
```bash
flutter run
```

Procure por mensagens como:
- "Firebase inicializado com sucesso"
- "NotificationService inicializado"

### 7. Estrutura de Dados Firestore

#### Collection: medicamentos
```json
{
  "nome": "Ben-u-ron",
  "dose": "1g",
  "horaToma": "08:00",
  "tipo": 0,
  "estado": 0,
  "notas": "Tomar com água",
  "frequenciaRepeticao": 1,
  "dataCriacao": Timestamp,
  "dataUltimaMudancaEstado": Timestamp,
  "dataTomada": null
}
```

#### Collection: configuracoes
```json
{
  "pin": "1234",
  "minutosParaFinalizado": 10,
  "minutosParaNaoTomado": 60,
  "numerosCuidadores": ["+351912345678"],
  "fatorTamanhoFonte": 1.0,
  "altoContraste": false,
  "screenReaderAtivo": false
}
```

#### Collection: historico
```json
{
  "medicamentoId": "abc123",
  "nome": "Ben-u-ron",
  "estado": 1,
  "estadoString": "Tomado",
  "horaToma": "08:00",
  "timestamp": Timestamp
}
```

### 8. Solução de Problemas

#### Erro: "google-services.json not found"
- Verifique se o arquivo está em `android/app/google-services.json`
- Execute `flutter clean` e `flutter pub get`

#### Erro: "Firebase not initialized"
- Verifique se o `google-services.json` está configurado corretamente
- Veja os logs para detalhes do erro

#### Notificações não funcionam
- Verifique permissões no AndroidManifest.xml
- No Android 13+, solicite permissão de notificações
- Teste em dispositivo real (emulador pode ter problemas)

#### SMS não abre
- A funcionalidade atual apenas abre o app de SMS nativo
- Para envio automático real, considere integrar com Twilio ou AWS SNS

### 9. Comandos Úteis

```bash
# Limpar cache
flutter clean

# Instalar dependências
flutter pub get

# Ver logs em tempo real
flutter logs

# Build para release
flutter build apk --release

# Analisar tamanho do APK
flutter build apk --analyze-size
```

### 10. Próximos Passos

1. ✅ Configurar Firebase
2. ✅ Testar em dispositivo real
3. ⏳ Configurar regras de segurança Firestore
4. ⏳ Adicionar autenticação de usuários
5. ⏳ Configurar envio automático de SMS
6. ⏳ Deploy para Google Play Store

---

**Suporte**: Consulte a [documentação oficial do Firebase](https://firebase.google.com/docs)

