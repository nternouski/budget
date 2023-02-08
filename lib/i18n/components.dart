import 'package:i18n_extension/i18n_extension.dart';

final components = Translations('en') +
    // classes
    {'en': 'Income', 'es': 'Ingreso'} +
    {'en': 'Expense', 'es': 'Gasto'} +
    {'en': 'Transfer', 'es': 'Transfer'} +

    // bottom_navigation_bar_widget
    {'en': 'Double Tap to Exit', 'es': 'Doble toque para salir'} +

    // create_or_update_category
    {'en': 'Choose Category', 'es': 'Elegir Categoría'} +
    {'en': 'Long press on category to edit it.', 'es': 'Mantén presionado para editar.'} +
    {'en': 'No categories at the moment..', 'es': 'No hay categoría por el momento.'} +
    {'en': 'Select Category', 'es': 'Elegir una Categoría'} +
    {'en': 'Select Multi Categories', 'es': 'Elegir Multiples Categorías'} +

    // create_or_update_label
    {'en': 'Label Search', 'es': 'Buscar Label'} +
    {'en': 'Create Label', 'es': 'Crear Label'} +

    // icon_picker
    {'en': 'Icon', 'es': 'Icono'} +

    // nav_draw
    {'en': 'Mobile Calculator', 'es': 'Calculadora de Plan'} +
    {'en': 'Statistics', 'es': 'Estadísticas'} +
    {'en': 'Expense Simulation', 'es': 'Simulación'} +
    {'en': 'Wise Sync', 'es': 'Wise Sync'} +
    {'en': 'Logout', 'es': 'Cerrar Sesión'} +
    {'en': 'About', 'es': 'Sobre la App'} +
    {'en': 'Name Not Set', 'es': 'Sin nombre'} +

    // current_rates_settings
    {'en': 'Choice rates', 'es': 'Elegir rate'} +
    {
      'en':
          'We found %d new rates'.zero('We not found rates').one('We found %d new rate').many('We found %d new rates'),
      'es': 'Encontramos %d nuevos rates'
          .zero('No encontramos ningún %d rate')
          .one('Encontramos %d un rate')
          .many('Encontramos %d nuevos rates')
    } +
    {'en': 'Do you want to update the rate?', 'es': 'Quieres actualizar el rate?'} +
    {'en': 'Update Currency Rate?', 'es': '¿Quieres Actualizar?'} +
    {'en': 'Currency Rates', 'es': 'Cambio de Moneda'} +
    {'en': 'From Rate', 'es': 'Desde'} +
    {'en': 'To Rate', 'es': 'Hacia'} +

    // profile_settings
    {'en': 'Profile', 'es': 'Perfil'} +
    {'en': 'Are you sure?', 'es': '¿Estás seguro?'} +
    {'en': 'YES', 'es': 'SI'} +
    {'en': 'The new default currency will be', 'es': 'La nueva moneda será'} +
    {'en': 'Default Currency', 'es': 'Moneda por Defecto'} +
    {'en': 'The default currency must be set', 'es': 'Debes agregar una moneda por defecto'} +

    // select_currency
    {'en': 'No Currency at the moment..', 'es': 'No hay moneda por le momento'} +
    {'en': 'No Currency', 'es': 'No hay moneda'} +
    {'en': 'Select Currency', 'es': 'Seleccionar'};
