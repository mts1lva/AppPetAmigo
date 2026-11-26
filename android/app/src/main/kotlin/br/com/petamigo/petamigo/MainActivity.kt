package br.com.petamigo.petamigo

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.Manifest
import android.app.NotificationManager
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val preferencias = getSharedPreferences("permissoes", Context.MODE_PRIVATE)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "br.com.petamigo/permissoes")
            .setMethodCallHandler { chamada, resposta ->
                when (chamada.method) {
                    "registrarPedidoNotificacoes" -> {
                        preferencias.edit().putBoolean("notificacoesPedidas", true).apply()
                        resposta.success(null)
                    }
                    "notificacoesNegadasPermanentemente" -> {
                        val permanente = if (Build.VERSION.SDK_INT >= 33) {
                            preferencias.getBoolean("notificacoesPedidas", false) &&
                                checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) != PackageManager.PERMISSION_GRANTED &&
                                !shouldShowRequestPermissionRationale(Manifest.permission.POST_NOTIFICATIONS)
                        } else {
                            !getSystemService(NotificationManager::class.java).areNotificationsEnabled()
                        }
                        resposta.success(permanente)
                    }
                    else -> resposta.notImplemented()
                }
            }
    }
}
