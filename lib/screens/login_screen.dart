import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'dart:async';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  bool _isLoading = false;

  StateMachineController? controller;
  SMIBool? isChecking;
  SMIBool? isHandsUp;
  SMITrigger? trigSuccess;
  SMITrigger? trigFail;
  SMINumber? numLook;

  final emailFocus = FocusNode();
  final passFocus = FocusNode();
  Timer? _typingDebounce;
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  // VARIABLES PARA CHECKLIST DINÁMICO Y ERROR ÚNICO
  String? _currentError;
  bool _isEmailValid = false;
  bool _isPasswordValid = false;

  // VALIDADORES
  bool isValidEmail(String email) {
    if (email.isEmpty) return false;
    final re = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return re.hasMatch(email);
  }

  bool isValidPassword(String pass) {
    if (pass.isEmpty) return false;
    final re = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}$',
    );
    return re.hasMatch(pass);
  }

  // ACTUALIZAR VALIDACIÓN EN TIEMPO REAL
  void _updateValidation() {
    final email = emailCtrl.text.trim();
    final pass = passCtrl.text;

    final wasEmailValid = _isEmailValid;
    final wasPasswordValid = _isPasswordValid;

    _isEmailValid = isValidEmail(email);
    _isPasswordValid = isValidPassword(pass);

    // SOLO MOSTRAR EL PRIMER ERROR QUE APLICA
    String? newError;
    if (email.isNotEmpty && !_isEmailValid) {
      newError = "Email inválido";
    } else if (pass.isNotEmpty && !_isPasswordValid) {
      newError =
          "Mínimo 8 caracteres, 1 Mayúscula, 1 Número, 1 Minuscula y 1 Caracter Especial";
    } else {
      newError = null;
    }

    // Solo actualizar si hay cambios
    if (newError != _currentError ||
        wasEmailValid != _isEmailValid ||
        wasPasswordValid != _isPasswordValid) {
      if (mounted) {
        setState(() {
          _currentError = newError;
        });
      }
    }
  }

  // CORRECCIÓN DEL "DOBLE TAP"
  Future<void> _onLogin() async {
    if (_isLoading) return;

    // 1. NORMALIZAR ESTADO INMEDIATAMENTE
    FocusScope.of(context).unfocus();
    _typingDebounce?.cancel();
    isChecking?.change(false);
    isHandsUp?.change(false);
    numLook?.value = 50.0;

    // 2. ESPERAR UN FRAME
    await Future.delayed(Duration.zero);

    // 3. ACTUALIZAR VALIDACIÓN FINAL ANTES DE MOSTRAR CARGA
    _updateValidation();

    // 4. ACTIVAR ESTADO DE CARGA
    setState(() {
      _isLoading = true;
    });

    // 5. VALIDACIÓN FINAL
    final isEmailValid = isValidEmail(emailCtrl.text.trim());
    final isPasswordValid = isValidPassword(passCtrl.text);

    // Simular envío (~1 segundo)
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    // 6. DISPARAR TRIGGERS
    if (isEmailValid && isPasswordValid) {
      trigSuccess?.fire();
    } else {
      trigFail?.fire();
    }

    // 7. DESACTIVAR CARGA
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();

    // Listeners para campos
    emailFocus.addListener(() {
      if (emailFocus.hasFocus) {
        isHandsUp?.change(false);
        numLook?.value = 50.0;
        isChecking?.change(true);
      } else {
        isChecking?.change(false);
        _updateValidation(); // Actualizar validación al perder foco
      }
    });

    passFocus.addListener(() {
      isHandsUp?.change(passFocus.hasFocus && _obscurePassword);
      isChecking?.change(false);
      if (!passFocus.hasFocus) {
        _updateValidation(); // Actualizar validación al perder foco
      }
    });

    // LISTENERS PARA VALIDACIÓN EN TIEMPO REAL
    emailCtrl.addListener(_updateValidation);
    passCtrl.addListener(_updateValidation);
  }

  @override
  void dispose() {
    emailFocus.dispose();
    passFocus.dispose();
    emailCtrl.dispose();
    passCtrl.dispose();
    _typingDebounce?.cancel();
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  width: size.width,
                  height: 200,
                  child: RiveAnimation.asset(
                    'assets/animated_login_character.riv',
                    stateMachines: ["Login Machine"],
                    onInit: (artboard) {
                      controller = StateMachineController.fromArtboard(
                        artboard,
                        "Login Machine",
                      );
                      if (controller == null) return;
                      artboard.addController(controller!);

                      isChecking = controller!.findSMI<SMIBool>('isChecking');
                      isHandsUp = controller!.findSMI<SMIBool>('isHandsUp');
                      trigSuccess = controller!.findSMI<SMITrigger>(
                        'trigSuccess',
                      );
                      trigFail = controller!.findSMI<SMITrigger>('trigFail');
                      numLook = controller!.findSMI('numLook');
                    },
                  ),
                ),
                const SizedBox(height: 10),

                // CAMPO EMAIL
                TextField(
                  focusNode: emailFocus,
                  controller: emailCtrl,
                  onChanged: (value) {
                    isChecking?.change(value.isNotEmpty);
                    isHandsUp?.change(false);

                    final look = (value.length / 120.0 * 100.0).clamp(
                      0.0,
                      100.0,
                    );
                    numLook?.value = look;

                    _typingDebounce?.cancel();
                    _typingDebounce = Timer(
                      const Duration(milliseconds: 1500),
                      () {
                        if (!mounted) return;
                        isChecking?.change(false);
                        numLook?.value = 50.0;
                      },
                    );

                    // ACTUALIZAR VALIDACIÓN EN TIEMPO REAL MIENTRAS SE ESCRIBE
                    _updateValidation();
                  },
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: "Email",
                    prefixIcon: const Icon(Icons.mail),
                    // SOLO muestra error si es email inválido (no vacío)
                    errorText: emailCtrl.text.isNotEmpty && !_isEmailValid
                        ? "Email inválido"
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // CAMPO PASSWORD
                TextField(
                  focusNode: passFocus,
                  controller: passCtrl,
                  onChanged: (value) {
                    // ACTUALIZAR VALIDACIÓN EN TIEMPO REAL MIENTRAS SE ESCRIBE
                    _updateValidation();
                  },
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: "Password",
                    prefixIcon: const Icon(Icons.lock),
                    // SOLO muestra error si hay contenido y es inválido
                    errorText: passCtrl.text.isNotEmpty && !_isPasswordValid
                        ? "Mínimo 8 caracteres, 1 Mayúscula, 1 Número, 1 Minuscula y 1 Caracter Especial"
                        : null,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                          isHandsUp?.change(
                            _obscurePassword && passFocus.hasFocus,
                          );
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // CHECKLIST DINÁMICO (AHORA SÍ REACCIONA EN VIVO)
                Container(
                  width: size.width,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildChecklistItem("Email válido", _isEmailValid),
                      _buildChecklistItem(
                        "Contraseña segura",
                        _isPasswordValid,
                      ),
                    ],
                  ),
                ),

                // MENSAJE DE ERROR ACTUAL (SOLO UNO)
                if (_currentError != null)
                  Container(
                    width: size.width,
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Text(
                      _currentError!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),

                SizedBox(
                  width: size.width,
                  child: const Text(
                    "Forgot Password?",
                    textAlign: TextAlign.right,
                    style: TextStyle(decoration: TextDecoration.underline),
                  ),
                ),
                const SizedBox(height: 10),

                // BOTÓN CON ESTADO DE CARGA
                MaterialButton(
                  minWidth: size.width,
                  height: 50,
                  color: Colors.purple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onPressed: _isLoading ? null : _onLogin,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          "Login",
                          style: TextStyle(color: Colors.white),
                        ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account?"),
                      TextButton(
                        onPressed: _isLoading ? null : () {},
                        child: const Text(
                          "Sign Up",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // WIDGET PARA ITEMS DEL CHECKLIST
  Widget _buildChecklistItem(String text, bool isValid) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.cancel,
            color: isValid ? Colors.green : Colors.red,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: isValid ? Colors.green : Colors.red,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
