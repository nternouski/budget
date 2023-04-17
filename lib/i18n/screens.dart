import 'package:i18n_extension/i18n_extension.dart';

final screens = Translations('en') +
    // COMMONS
    {'en': 'Create', 'es': 'Crear'} +
    {'en': 'Save', 'es': 'Actualizar'} +
    {'en': 'Edit', 'es': 'Editar'} +
    {'en': 'Delete', 'es': 'Eliminar'} +
    {'en': 'Are you sure you want to delete?', 'es': '¿Esta seguro de eliminarlo?'} +
    {'en': 'Is Required', 'es': 'Es Requerido'} +
    {'en': 'Date', 'es': 'Fecha'} +
    {'en': 'No wallets at the moment.', 'es': 'No hay billeteras'} +

    // budgets_screen
    {'en': 'Budgets', 'es': 'Presupuesto'} +
    {'en': 'No budgets at the moment..', 'es': 'No hay presupuestos'} +
    {'en': 'Finished', 'es': 'Finalizado'} +
    {
      'en': '%d days left'.zero('%d days left').one('%d day left').many('%d days left'),
      'es': '%d días restantes'.zero('%d días restantes').one('%d día restante').many('%d días restantes')
    } +

    // create_or_update_budget_screen
    {'en': 'Budget', 'es': 'Presupuesto'} +
    {'en': 'You need select at least one category.', 'es': 'Se necesita seleccionar al menos una categoría.'} +
    {'en': 'Name', 'es': 'Nombre'} +
    {'en': 'Amount', 'es': 'Monto'} +
    {'en': 'Period', 'es': 'Periodo'} +

    // create_or_update_transaction_screen
    {'en': 'Transaction', 'es': 'Transacción'} +
    {'en': 'Add money To', 'es': 'Billetera origen'} +
    {'en': 'From', 'es': 'Desde'} +
    {'en': 'To', 'es': 'Hacia'} +
    {'en': 'Pay with', 'es': 'Pagando con'} +
    {'en': 'Description', 'es': 'Descripción'} +
    {'en': 'Amount is Required and Grater than 0', 'es': 'Monto es requerido y mayor a 0'} +
    {
      'en': 'You can\'t update type, please delete the transaction and create a new one.',
      'es': 'No se puede actualizar el tipo, por favor elimine la transacción y vuelva a crearla.'
    } +
    {'en': 'Fee', 'es': 'Comisión'} +
    {'en': 'The name must not be empty.', 'es': 'Falta agregar el nombre.'} +
    {'en': 'You must choice a wallet first.', 'es': 'Debes elegir un billetera.'} +
    {
      'en': 'You must choice the wallet of from and to transaction is made.',
      'es': 'Debes elegir la billetera que va a extraer y la de destino.'
    } +
    {'en': 'Wallet must not be the same.', 'es': 'Las billetera no deben ser iguales.'} +
    {'en': 'You must have a default currency first.', 'es': 'Debes tener una moneda por defecto.'} +
    {'en': 'You must choice a category first.', 'es': 'Debes elegir una categoría.'} +
    {
      'en': 'Amount is required and must be grater than 0.',
      'es': 'El monto es requerido y tiene que ser mayor a cero.'
    } +

    // create_or_update_wallet_screen
    {'en': 'Wallet must not be the same.', 'es': 'Las billetera no deben ser iguales.'} +
    {'en': 'Wallet', 'es': 'Billetera'} +
    {'en': 'Initial Amount', 'es': 'Monto Inicial'} +
    {'en': 'Wallet Name', 'es': 'Nombre'} +
    {'en': 'Bank XX', 'es': 'Banco XX'} +
    {'en': 'Currency', 'es': 'Moneda'} +

    // daily_screen
    {'en': 'Daily Transaction', 'es': 'Transacciones'} +
    {'en': 'What will be your first spend?', 'es': 'Cual es to primer gasto?'} +
    {'en': 'See All', 'es': 'Ver Más'} +

    // email_verification_screen
    {'en': 'Email Successfully Verified', 'es': 'Se verificó el email correctamente'} +
    {'en': 'Logout successfully!', 'es': 'Sesión cerrada'} +
    {'en': 'Email Verification', 'es': 'Verificación de email'} +
    {'en': 'Check your Email', 'es': 'Comprueba tu mail'} +
    {'en': 'We have sent you a Email on %s', 'es': 'Email enviado a %s'} +
    {'en': 'Verifying email..', 'es': 'Verificando..'} +
    {'en': 'Resend', 'es': 'Re-enviar'} +

    // faq_screen
    {'en': 'Search', 'es': 'Buscar'} +
    {'en': 'How to create a transaction?', 'es': '¿Como crear una transacción?'} +
    {
      'en': 'First you need to create a wallet, the transaction belong to a wallet with a specific currency.',
      'es':
          'Primero necesitas crear una billetera, las transacciones se realiza sobre una billetera con una moneda especifica.'
    } +
    {'en': 'How can I remove the Ads?', 'es': '¿Como eliminar la publicidad?'} +
    {
      'en':
          'We use Ads to pay server expenses in the app, but if you insist on hiding ads, you can contact me by email and I will do something about it.',
      'es':
          'Usamos publicidad para pagar los gastos de servidores, pero si insistes en quitarlo puedes contactarte conmigo por email.'
    } +
    {'en': 'Do you notice some wrong in the wallet?', 'es': '¿Notas algo raro en la billetera?'} +
    {
      'en': 'There are admin features, just let me know and I will enable those functions in your account.',
      'es': 'Hay funciones de admin, puedes contactar conmigo y lo habilitare para tu cuenta usuario.'
    } +
    {'en': 'My currency rate it is wrong?', 'es': '¿El cambio de moneda está mal?'} +
    {
      'en':
          'You can change the rate manually, go to Settings > Scroll down to \'Currency Rates\' > Click on the rate and will apear the form.',
      'es':
          'Puedes cambiarlo manualmente, vaya a Configuración > Dirigese a \'Cambio\' > Clickea en el cambio y aparecerá el formulario para modificar.'
    } +
    {'en': 'What it is Wise Sync?', 'es': '¿Que es Wise Sync?'} +
    {
      'en': 'The feature is to update wise movement, but it\'s in alpha and not works properly.',
      'es':
          'Se trata de una recopilar tus movimientos de wise para que no tengas que cargar manualmente, pero esta en version de prueba y por le momento no funciona correctamente.'
    } +
    {'en': 'How can I contact with the developer?', 'es': '¿Como puedo contactarme con el desarrollador?'} +
    {'en': 'You can send email to nahuelternouski@gmail.com.', 'es': 'Envíame un email a nahuelternouski@gmail.com.'} +

    // mobile_calculator_screen
    {'en': 'Mobile Data Calculator', 'es': 'Calculadora de saldo'} +
    {'en': 'Data Spent', 'es': 'Dato gastado'} +
    {'en': 'Please enter your a value grater than', 'es': 'Por favor, ingrese un valor mayor a'} +
    {'en': 'Calculate', 'es': 'Calcular'} +
    {'en': 'Select Plan', 'es': 'Seleccionar Plan'} +
    {'en': 'Result', 'es': 'Resultado'} +
    {'en': 'Avg reminding', 'es': 'Restante promedio'} +
    {'en': 'Gb/day', 'es': 'Gb/dia'} +
    {'en': 'Days reminder', 'es': 'Dias restantes'} +
    {'en': 'Start Date Plan', 'es': 'Inicio del Plan'} +

    // expense_prediction_screen
    {'en': 'Item', 'es': 'Registro'} +
    {'en': 'Group', 'es': 'Grupo'} +
    {'en': 'List', 'es': 'Lista'} +
    {'en': 'Durations (Days)', 'es': 'Duración (Días)'} +
    {
      'en': '%d days'.zero('%d days').one('%d day').many('%d days'),
      'es': '%d días'.zero('%d días').one('%d día').many('%d días')
    } +
    {
      'en': 'in %d days '.zero('in %d days ').one('in %d day  ').many('in %d days '),
      'es': 'en %d días '.zero('en %d días ').one('en %d día  ').many('en %d días ')
    } +
    {'en': 'Empty List', 'es': 'Lista vacía'} +
    {'en': 'Prediction ON', 'es': 'Predicción Activada'} +
    {'en': 'Prediction OFF', 'es': 'Predicción Desactivada'} +

    // onboarding
    {'en': 'First you must set a default currency.', 'es': 'Primero debes seleccionar una moneda'} +
    {'en': 'First you must set a email and password.', 'es': 'Primero debes seleccionar agregar email y contraseña'} +
    {'en': 'You must accept the terms and conditions.', 'es': 'Debes aceptar los Términos y Condiciones.'} +
    {'en': 'Welcome to Budget App', 'es': 'Bienvenido/a a Budget App'} +
    {
      'en': 'Login with your user created with the button below or keep the steps to Sign Up.',
      'es':
          'Inicia sesión con tu usuario ya creado con el siguiente botón o sigue los pasos para crear una nueva cuenta.',
    } +
    {'en': 'Sign in with Google', 'es': 'Iniciar sesión con Google'} +
    {'en': ' Sign in with Email ', 'es': 'Iniciar sesión con Email'} +
    {
      'en': 'Password min %d characters.'.one('Password min %d character.').many('Password min %d characters.'),
      'es':
          'Contraseña mínimo %d caracteres'.one('Contraseña mínimo %d carácter').many('Contraseña mínimo %d caracteres')
    } +
    {'en': 'Password', 'es': 'Contraseña'} +
    {'en': 'Enter your password', 'es': 'Ingrese su contraseña'} +
    {'en': 'Cancel', 'es': 'Cancelar'} +
    {'en': 'LOGIN', 'es': 'INICIAR'} +
    {
      'en': 'Before start we need to know what will be the default currency, you can change later.',
      'es': 'Antes de empezar necesitamos saber su moneda, puedes cambiarlo luego.'
    } +
    {'en': 'Sign Up with Google', 'es': 'Crear sesión con Google'} +
    {'en': ' Sign Up with Email ', 'es': 'Crear sesión con Email'} +
    {'en': 'SIGN UP', 'es': 'CREAR USUARIO'} +
    {'en': 'By continuing, I agree to ', 'es': 'Al continuar, estoy de acuerdo con '} +
    {'en': 'Terms & Conditions', 'es': 'Términos & Condiciones'} +
    {'en': ' and ', 'es': ' y '} +
    {'en': 'Privacy Policy', 'es': 'Políticas de Privacidad'} +
    {'en': 'Open Store', 'es': 'Abrir Tienda'} +
    {'en': ' and allow to verify credentials.', 'es': ' y acepto verificar las credenciales.'} +
    {'en': 'BACK', 'es': 'ATRÁS'} +
    {'en': 'LOGIN', 'es': 'INICIAR SESIÓN'} +

    // settings
    {'en': 'Settings', 'es': 'Configuración'} +
    {'en': 'Common', 'es': 'Configuración'} +
    {'en': 'Period of Time', 'es': 'Periodo de Tiempo'} +
    {'en': 'That will affect the graphics and stats', 'es': 'Esto afectará gráficos y las estadísticas'} +
    {'en': 'Choose Language', 'es': 'Elegir Idioma'} +
    {'en': 'Language', 'es': 'Idioma'} +
    {'en': 'Period of Analytics', 'es': 'Periodo de Análisis'} +
    {'en': 'Auth With Biometric', 'es': 'Autentificar con Huella'} +
    {'en': 'Dark Theme', 'es': 'Modo Oscuro'} +
    {'en': 'Show Default Currency', 'es': 'Mostrar moneda por defecto'} +
    {'en': 'Both', 'es': 'Ambos'} +
    {'en': 'Integrations', 'es': 'Integraciones'} +
    {'en': 'Please write', 'es': 'Por favor escribe'} +
    {
      'en': 'To delete permanently your user and all the data related to you.',
      'es': 'Para eliminar permanentemente to usuario y toda la información relevante'
    } +
    {'en': 'Danger Zone', 'es': 'Zona de Peligro'} +
    {'en': 'DELETE USER', 'es': 'ELIMINAR USUARIO'} +

    // stats_screen
    {'en': 'Statistics', 'es': 'Estadísticas'} +
    {'en': 'Transaction types', 'es': 'Tipos de transacción'} +
    {'en': 'Categories', 'es': 'Categorías'} +
    {
      'en': 'The Last %d months'.zero('The Last %d months').one('The Last %d month').many('The Last %d months'),
      'es': 'En los últimos %d meses'
          .zero('En los últimos %d meses')
          .one('En los últimos mes')
          .many('En los últimos %d meses')
    } +
    {'en': 'Period', 'es': 'Periodo'} +
    {'en': 'Category', 'es': 'Categoría'} +
    {'en': 'Currency', 'es': 'Total'} +

    // wallets_screen
    {'en': 'No wallets at the moment.', 'es': 'No hay billeteras por el momento'} +
    {'en': 'Wallets', 'es': 'Billeteras'} +
    {'en': 'Re calculate Wallets', 'es': 'Re-calcular billetera'} +
    {
      'en': 'This action will delete all transaction of this wallets too.',
      'es': 'Esta acción va a eliminar todas las transacciones de esta billetera permanentemente.'
    } +
    {'en': 'It\'s equivalent to', 'es': 'Es equivalente a'} +

    // wise_sync
    {'en': 'Wise Transactions', 'es': 'Transacciones de Wise'} +
    {'en': 'Api key not set.', 'es': 'Api key inexistente.'} +
    {'en': 'In Construction', 'es': 'En construcción.'};
