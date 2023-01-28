import 'package:i18n_extension/i18n_extension.dart';

final server = Translations('en') +
    // auth
    {'en': 'Please authenticate to show account balance', 'es': 'Por favor, autentificate para mostrar tu balance'} +
    {'en': 'Biometrics Not Supported!', 'es': 'Esta función no está soportado!'} +
    {'en': 'Confirm fingerprint to continue.', 'es': 'Confirmar huella para continuar'} +
    {'en': 'Authentication In Progress.', 'es': 'Autentificar en progreso.'} +
    {'en': 'Authentication Not Supported.', 'es': 'Autentificación no soportada.'} +
    {'en': 'Error on authenticate with biometric.', 'es': 'Error al autentificar via huella digital.'} +
    {'en': 'Fingerprint Unlock', 'es': 'Desbloquear con huella.'} +
    {'en': 'Touch Sensor', 'es': 'Toque el Sensor'} +
    {'en': 'Try again!', 'es': 'Intente nuevamente!'} +
    {'en': 'Disable Fingerprint', 'es': 'Desactivar huella'} +

    // database
    {'en': 'Document Not Exist', 'es': 'Documento no Existe'} +

    // user_service
    {'en': 'Name Not Set', 'es': 'Sin Nombre'} +
    {
      'en': 'User has Cancelled or no Internet on SignUp.',
      'es': 'Usuario canceló o no hay internet al Crear Usuario.'
    } +
    {'en': 'User has Cancelled or no Internet on Login.', 'es': 'Usuario canceló o no hay internet al Iniciar Sesión.'};
