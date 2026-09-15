import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_config.dart';
import '../../../../core/utils/json_utils.dart';
import '../../domain/models/panel_usuario_model.dart';

/// ParkLink - Servicio del panel del usuario final.
///
/// Endpoint cubierto (Blueprint `usuario_bp`):
/// - `GET /api/usuario/panel`
///
/// Entrega los contadores del dashboard y los últimos cinco movimientos
/// registrados en el parqueadero.
class UsuarioPanelService {
  UsuarioPanelService({ApiClient? cliente})
      : _cliente = cliente ?? ApiClient.instance;

  final ApiClient _cliente;

  /// Obtiene los datos del panel principal.
  Future<PanelUsuarioModel> obtenerPanel() async {
    final dynamic respuesta = await _cliente.get('${ApiConfig.usuario}/panel');
    return PanelUsuarioModel.fromJson(JsonUtils.parseMapa(respuesta));
  }
}
