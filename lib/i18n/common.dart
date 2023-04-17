import 'package:i18n_extension/i18n_extension.dart';

final common = Translations('en') +
    // classes
    {'en': 'Initializing..', 'es': 'Inicializando..'} +
    {
      'en': 'Special thanks to "stories" on freepik for the pictures.',
      'es': 'Gracias por "stories" en freepik por las imágenes.'
    } +

    // version_checker
    {
      'en': 'The target platform "%s" is not yet supported by this package.',
      'es': 'La version de la plataforma "%s" no esta soportado por el momento.'
    } +
    {
      'en': 'You have a new version available, please go to the store and update.',
      'es': 'Tienes una version nueva de la aplicación.'
    } +

    // period_status
    {
      'en': '%d Days'.zero('%d Days').one('%d day').many('%d Days'),
      'es': '%d Días'.zero('%d Días').one('%d Día').many('%d Días')
    } +
    {
      'en': '%d Months'.zero('%d Months').one('%d Month').many('%d Months'),
      'es': '%d Meses'.zero('%d Meses').one('%d Mes').many('%d Meses')
    } +
    // Footer
    {'en': 'Daily', 'es': 'Actividad'} +
    {'en': 'Daily', 'es': 'Actividad'};
