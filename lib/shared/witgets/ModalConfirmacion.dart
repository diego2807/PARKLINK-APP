import 'package:flutter/material.dart';
import '../../app_theme.dart';

/// Widget reutilizable para mostrar diálogos de confirmación con estilo
/// consistente en toda la app de vigilancia.
///
/// Uso rápido:
/// ```dart
/// final confirmado = await ModalConfirmacionScreen.mostrar(
///   context,
///   titulo: "Confirmar acción",
///   mensaje: "¿Deseas continuar?",
/// );
/// if (confirmado == true) { ... }
/// ```
class ModalConfirmacionScreen extends StatelessWidget {
  final String titulo;
  final String mensaje;
  final String textoConfirmar;
  final String textoCancelar;
  final IconData icono;
  final Color colorIcono;

  const ModalConfirmacionScreen({
    super.key,
    required this.titulo,
    required this.mensaje,
    this.textoConfirmar = "Confirmar",
    this.textoCancelar = "Cancelar",
    this.icono = Icons.help_outline_rounded,
    this.colorIcono = AppTheme.primary,
  });

  static Future<bool?> mostrar(
    BuildContext context, {
    required String titulo,
    required String mensaje,
    String textoConfirmar = "Confirmar",
    String textoCancelar = "Cancelar",
    IconData icono = Icons.help_outline_rounded,
    Color colorIcono = AppTheme.primary,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => ModalConfirmacionScreen(
        titulo: titulo,
        mensaje: mensaje,
        textoConfirmar: textoConfirmar,
        textoCancelar: textoCancelar,
        icono: icono,
        colorIcono: colorIcono,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(22),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: colorIcono.withOpacity(0.12), shape: BoxShape.circle),
              child: Icon(icono, color: colorIcono, size: 32),
            ),
            const SizedBox(height: 18),
            Text(titulo, textAlign: TextAlign.center, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
            const SizedBox(height: 10),
            Text(mensaje, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13.5, color: AppTheme.textMuted)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppTheme.textMuted),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(textoCancelar, style: const TextStyle(color: AppTheme.textMuted, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorIcono,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(textoConfirmar, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
